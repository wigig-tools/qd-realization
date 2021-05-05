function outputPath = Raytracer(paraCfgInput, nodeCfgInput, varargin)
%%RAYTRACER generates the QD channel model.
% Inputs:
% paraCfgInput - Simulation configuration
% nodeCfgInput - Node configuration


%--------------------------Software Disclaimer-----------------------------
%
% NIST-developed software is provided by NIST as a public service. You may
% use, copy and distribute copies of the software in any medium, provided
% that you keep intact this entire notice. You may improve, modify and
% create derivative works of the software or any portion of the software,
% and you  may copy and distribute such modifications or works. Modified
% works should carry a notice stating that you changed the software and
% should note the date and nature of any such change. Please explicitly
% acknowledge the National Institute of Standards and Technology as the
% source of the software.
%
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION
% OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND
% DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF
% THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS
% WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT
% NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF
% THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% and distributing the software and you assume all risks associated with
% its use, including but not limited to the risks and costs of program
% errors, compliance with applicable laws, damage to or loss of data,
% programs or equipment, and the unavailability or interruption of
% operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property. The
% software developed by NIST employees is not subject to copyright
% protection within the United States.
%
% Modified by: Mattia Lecci <leccimat@dei.unipd.it>, Refactored code
%              Steve Blandino <steve.blandino@nist.gov>

%% Input Parameters Management and preallocation
p = inputParser;
addOptional(p,'target',[]);
parse(p, varargin{:});
trgCfgInput = p.Results.target;
if isempty(trgCfgInput)
    trgtNum = 0;
else
    trgtNum = size(trgCfgInput.trgtPosition,3);
end

nodePosition = nodeCfgInput.nodePosition;
nPAA_centroids = cellfun(@(x) x.nPAA_centroids, nodeCfgInput.paaInfo );
Mpc = cell(paraCfgInput.numberOfNodes,...
    max(nPAA_centroids),...
    paraCfgInput.numberOfNodes,...
    max(nPAA_centroids),...
    paraCfgInput.totalNumberOfReflections+1,...
    paraCfgInput.numberOfTimeDivisions+1 );
MpcTarget = cell(paraCfgInput.numberOfNodes,...
    max(nPAA_centroids),...
    trgtNum,...
    paraCfgInput.numberOfTimeDivisions);

keepBothQDOutput = strcmp(paraCfgInput.outputFormat, 'both');
isJsonOutput = strcmp(paraCfgInput.outputFormat, 'json');
displayProgress = 1;
ts = paraCfgInput.totalTimeDuration/paraCfgInput.numberOfTimeDivisions;
outputPaa = cell(paraCfgInput.numberOfNodes,paraCfgInput.numberOfNodes);

% List of paths
inputPath = fullfile(paraCfgInput.inputScenarioName, 'Input');
outputPath = fullfile(paraCfgInput.inputScenarioName, 'Output');
ns3Path = fullfile(outputPath, 'Ns3');
qdFilesPath = fullfile(ns3Path, 'QdFiles');

if paraCfgInput.switchSaveVisualizerFiles == 1
    visualizerPath = fullfile(outputPath, 'Visualizer');
end

% Subfolders creation
if ~isfolder(qdFilesPath)
    mkdir(qdFilesPath)
end

% Init output files
if ~isJsonOutput || keepBothQDOutput
    fids = getQdFilesIds(qdFilesPath, paraCfgInput.numberOfNodes,...
        paraCfgInput.useOptimizedOutputToFile);
end

%% Init
switchPolarization = 0;
switchCp = 0;
polarizationTx = [1, 0];

MaterialLibrary = importMaterialLibrary(paraCfgInput.materialLibraryPath);

% Extracting CAD file and storing in an XMl file, CADFile.xml
[CADop, switchMaterial] = getCadOutput(paraCfgInput.environmentFileName,...
    inputPath, MaterialLibrary, paraCfgInput.referencePoint,...
    paraCfgInput.selectPlanesByDist, paraCfgInput.indoorSwitch);
% staticCad = CADop;
if paraCfgInput.switchSaveVisualizerFiles == 1
    % Save output file with room coordinates for visualization
    RoomCoordinates = CADop(:, 1:9);
    csvwrite(fullfile(visualizerPath, 'RoomCoordinates.csv'),...
        RoomCoordinates);
end

%% Node to node ray tracing
if paraCfgInput.nodeMobility
    T = paraCfgInput.numberOfTimeDivisions;
else
    T = 1;
end

for iterateTimeDivision = 1:T
    if mod(iterateTimeDivision,100)==0 && displayProgress
        disp([fprintf('%2.2f', iterateTimeDivision/T*100),'%'])
    end
    
    %% Point rotation
    % PAAs not centered [0,0,0] have a
    % different position in the global frame if the node rotates. Compute
    % the new PAAs position as well as the equivalent angle resulting from
    % successive transformations (initial PAA orientation + rotation of the
    % node over time)
    for nodeId = 1:paraCfgInput.numberOfNodes
        centerRotation = nodePosition(iterateTimeDivision,:, nodeId);
        nodeRotationEucAngles = nodeCfgInput.nodeRotation(iterateTimeDivision,:, nodeId);
        paaInitialPosition = reshape(squeeze(...
            nodeCfgInput.paaInfo{nodeId}.centroidTimePosition(iterateTimeDivision,:,:)), [], 3);
        [paaRotatedPosition, nodeEquivalentRotationAngle] = coordinateRotation(paaInitialPosition, ...
            centerRotation,...
            nodeRotationEucAngles ...
            );
        nodeCfgInput.nodeEquivalentRotationAngle(iterateTimeDivision,:, nodeId) = nodeEquivalentRotationAngle;
        nodeCfgInput.paaInfo{nodeId}.centroid_position_rot(iterateTimeDivision,:,:) =paaRotatedPosition;
    end
    
    %% Iterates through all the PAA centroids
    for iterateTx = 1:paraCfgInput.numberOfNodes
        
        for iterateRx = iterateTx+1:paraCfgInput.numberOfNodes
            
            for iteratePaaTx = 1:nPAA_centroids(iterateTx)
                
                for iteratePaaRx = 1:nPAA_centroids(iterateRx)
                    output = [];
                    
                    % Update centroids position
                    Tx = squeeze(nodeCfgInput.paaInfo{iterateTx}.centroid_position_rot(iterateTimeDivision,iteratePaaTx,:)).';
                    Rx = squeeze(nodeCfgInput.paaInfo{iterateRx}.centroid_position_rot(iterateTimeDivision,iteratePaaRx,:)).';
                    
                    % Update rotation Tx struct
                    QTx.center(1,:) = nodePosition(iterateTimeDivision,:,iterateTx);
                    QTx.angle(1,:) = nodeCfgInput.nodeRotation(iterateTimeDivision,:, iterateTx);
                    
                    % Update rotation Rx struct
                    QRx.center(1,:) = nodePosition(iterateTimeDivision,:,iterateRx);
                    QRx.angle(1,:) = nodeCfgInput.nodeRotation(iterateTimeDivision,:, iterateRx);
                    
                    % Update node velocity
                    previousTxPosition =  squeeze(nodeCfgInput.paaInfo{iterateTx}.centroid_position_rot(max(iterateTimeDivision-1,1),iteratePaaTx,:)).';
                    previousRxPosition =  squeeze(nodeCfgInput.paaInfo{iterateRx}.centroid_position_rot(max(iterateTimeDivision-1,1),iteratePaaRx,:)).';
                    
                    vtx = (Tx-previousTxPosition)./ts;
                    vrx = (Rx-previousRxPosition)./ts;
                    
                    % LOS Path generation
                    [isLos, output] = LOSOutputGenerator(CADop, Rx, Tx,...
                        output, vtx, vrx, switchPolarization, switchCp,...
                        polarizationTx, paraCfgInput.carrierFrequency, 'qTx', QTx, 'qRx', QRx);
                    
                    % Store MPC
                    if paraCfgInput.switchSaveVisualizerFiles && isLos
                        multipath1 = [Tx, Rx];
                        Mpc{iterateTx,iteratePaaTx,iterateRx,iteratePaaRx, 1, iterateTimeDivision+1} =multipath1;
                    end
                    
                    % Higher order reflections (Non LOS)
                    for iterateOrderOfReflection = 1:paraCfgInput.totalNumberOfReflections
                        numberOfReflections = iterateOrderOfReflection;
                        
                        [ArrayOfPoints, ArrayOfPlanes, numberOfPlanes,...
                            ~, ~, arrayOfMaterials, ~] = treetraversal(CADop,...
                            numberOfReflections, numberOfReflections,...
                            0, 1, 1, 1, Rx, Tx, [], [],...
                            switchMaterial, [], 1);
                        
                        numberOfPlanes = numberOfPlanes - 1;
                        
                        [outputTemporary, multipathTemporary] = ...
                            multipath(...
                            ArrayOfPlanes, ArrayOfPoints, Rx, Tx, ...
                            CADop, numberOfPlanes, ...
                            MaterialLibrary, arrayOfMaterials, ...
                            switchMaterial, vtx, vrx, ...
                            paraCfgInput.switchDiffuseComponent,...
                            paraCfgInput.switchQDModel,...
                            paraCfgInput.inputScenarioName(10:end),...
                            paraCfgInput.carrierFrequency,...
                            paraCfgInput.diffusePathGainThreshold,...
                            'rotTx', QTx.angle, 'rotRx', QRx.angle, ...
                            'reflectionLoss', paraCfgInput.reflectionLoss);
                        
                        nMpc = size(multipathTemporary,1);
                        %Store MPC
                        if paraCfgInput.switchSaveVisualizerFiles &&...
                                nMpc > 0
                            multipath1 = multipathTemporary(:,...
                                2:end); %Discard reflection order column
                            Mpc{iterateTx,iteratePaaTx,...
                                iterateRx,iteratePaaRx, ...
                                iterateOrderOfReflection+1, iterateTimeDivision+1} =multipath1;
                        end
                        
                        %Store QD output
                        if size(output) > 0
                            output = [output;outputTemporary]; %#ok<AGROW>
                            
                        elseif size(outputTemporary) > 0
                            output = outputTemporary;
                            
                        end
                        
                    end
                    
                    % Create outputPAA array of struct. Each entry of the
                    % array is a struct relative to a NodeTx-NodeRx
                    % combination. Each struct has the entries
                    % - paaTxXXpaaRxYY: channel between paaTx XX and paaRx
                    % YY.
                    outputPaa{iterateTx, iterateRx}.(sprintf('paaTx%dpaaRx%d', iteratePaaTx-1, iteratePaaRx-1))= output;
                    outputPaa{iterateRx, iterateTx}.(sprintf('paaTx%dpaaRx%d', iteratePaaRx-1, iteratePaaTx-1))= reverseOutputTxRx(output);
                    
                end
            end
            
        end
        
        
    end
    
    %% Generate channel for each PAA given the channel of the centroids
    outputPaaTime(:,:,iterateTimeDivision) = generateChannelPaa(outputPaa, nodeCfgInput.paaInfo);  %#ok<AGROW>
    
    %% Write QD output in CSV files
    if ~isJsonOutput || keepBothQDOutput
        for iterateTx = 1:paraCfgInput.numberOfNodes
            for iterateRx = iterateTx+1:paraCfgInput.numberOfNodes
                writeQdFileOutput(outputPaaTime{iterateTx, iterateRx,iterateTimeDivision},...
                    paraCfgInput.useOptimizedOutputToFile, fids, iterateTx, iterateRx,...
                    qdFilesPath, paraCfgInput.qdFilesFloatPrecision);
                
                writeQdFileOutput(outputPaaTime{iterateRx,iterateTx,iterateTimeDivision},...
                    paraCfgInput.useOptimizedOutputToFile, fids, iterateRx,iterateTx,...
                    qdFilesPath, paraCfgInput.qdFilesFloatPrecision);
            end
        end
    end
    
    clear outputPAA
end

if paraCfgInput.nodeMobility
else
    outputPaaTime(:,:,2:paraCfgInput.numberOfTimeDivisions) = repmat(outputPaaTime(:,:,1), [1 1 paraCfgInput.numberOfTimeDivisions-1]);
    Mpc(:,:,:,:,:,3:end) = repmat(Mpc(:,:,:,:,:,2), [1 1 1 1 1 paraCfgInput.numberOfTimeDivisions-1]);
end

%% Node to target ray tracing
 if trgtNum
cf = paraCfgInput.carrierFrequency;
saveVisualOut = paraCfgInput.switchSaveVisualizerFiles;
reflectionOrder = paraCfgInput.totalNumberOfReflectionsSens;
isDiffuse = paraCfgInput.switchDiffuseComponent;
isQD = paraCfgInput.switchQDModel;
scenarioName = paraCfgInput.inputScenarioName(10:end);
diffusePathGainThreshold =  paraCfgInput.diffusePathGainThreshold;
reflectionLoss = paraCfgInput.reflectionLoss;
for iterateTimeDivision = 1:paraCfgInput.numberOfTimeDivisions
%     if mod(iterateTimeDivision,100)==0 && displayProgress
        disp([fprintf('%2.2f', iterateTimeDivision/paraCfgInput.numberOfTimeDivisions*100),'%'])
%     end
   
        for nodeId = 1:paraCfgInput.numberOfNodes
            for paaId = 1:nPAA_centroids(nodeId)
                nodePaa = squeeze(nodeCfgInput.paaInfo{nodeId}.centroid_position_rot(min(T,iterateTimeDivision),paaId,:)).';
                previousNodePaaPosition =  squeeze(nodeCfgInput.paaInfo{nodeId}.centroid_position_rot(max(min(T,iterateTimeDivision)-1,1),paaId,:)).';
                mpcParFor = cell(1,trgtNum);
                trgtPosition = trgCfgInput.trgtPosition(iterateTimeDivision,:, :);
                previousTargetPosition = trgCfgInput.trgtPosition(max(1,iterateTimeDivision-1),:, :);
                rotAngle = nodeCfgInput.nodeRotation(iterateTimeDivision,:, nodeId);
                parfor trgtId = 1:trgtNum
                    % Update centroids position
                    target = trgtPosition(:, :, trgtId);
                    vNode = (nodePaa-previousNodePaaPosition)./ts;
                    vTarget = (target-previousTargetPosition(:,:,trgtId))./ts;
                    
                    % LOS Path generation
                    [isLos, output] = getLos(CADop, target, nodePaa,...
                        [], vNode, vTarget, cf, 'rotTx',rotAngle);
                    
                    % Store MPC
                    if saveVisualOut && isLos
                        mpcLos = [nodePaa, target];
                        mpcLosParFor{trgtId} = mpcLos;
                        MpcTarget{nodeId,paaId,...
                            trgtId, iterateTimeDivision}{1} = mpcLos;
                    else
                        MpcTarget{nodeId,paaId,...
                            trgtId, iterateTimeDivision}{1} = [];
                    end
                    
                    for iterateOrderOfReflection = 1:reflectionOrder
                        numberOfReflections = iterateOrderOfReflection;
                        
                        [ArrayOfPoints, ArrayOfPlanes, numberOfPlanes,...
                            ~, ~, arrayOfMaterials, ~] = treetraversal(CADop,...
                            numberOfReflections, numberOfReflections,...
                            0, 1, 1, 1, target, nodePaa, [], [],...
                            switchMaterial, [], 1);
                        
                        numberOfPlanes = numberOfPlanes - 1;
                        
                        [outputTemporary, multipathTemporary] = ...
                            multipath(...
                            ArrayOfPlanes, ArrayOfPoints, target, nodePaa, ...
                            CADop, numberOfPlanes, ...
                            MaterialLibrary, arrayOfMaterials, ...
                            switchMaterial, vNode, vTarget, ...
                            isDiffuse, isQD, scenarioName, cf,...
                            diffusePathGainThreshold,...
                            'rotTx', rotAngle, ...
                            'reflectionLoss', reflectionLoss);
                        
                        nMpc = size(multipathTemporary,1);
                        %Store MPC
                        if saveVisualOut && nMpc > 0
                            multipath1 = multipathTemporary(:,...
                                2:end); %Discard reflection order column
                            mpcParFor{trgtId}{iterateOrderOfReflection} =multipath1;
                            MpcTarget{nodeId,paaId,...
                                trgtId,iterateTimeDivision}{iterateOrderOfReflection+1} = multipath1;
                        else
                            MpcTarget{nodeId,paaId,...
                                trgtId,iterateTimeDivision}{iterateOrderOfReflection+1} = [];
                        end
                        
                        %Store QD output
                        if size(output) > 0
                            output = [output;outputTemporary]; %#ok<AGROW>
                            
                        elseif size(outputTemporary) > 0
                            output = outputTemporary;
                            
                        end
                        
                    end
                    
                    outputPaaTarget{nodeId, trgtId}.(sprintf('paaTx%dTarget%d', paaId-1, trgtId-1))= output;
                    outputPaaTargetReverse{trgtId, nodeId}.(sprintf('paaTarget%dpaaRx%d', trgtId-1, paaId-1))= reverseOutputTxRx(output);                   
                    
                end
            end
        end
    
    trgOutChan(:,:,iterateTimeDivision)  = generateChannelTargetPaa(outputPaaTarget, outputPaaTargetReverse,nodeCfgInput.paaInfo, trgCfgInput.trgtFrisCorrection);
end
    MpcTargetMat  = cell(paraCfgInput.numberOfNodes,...
        max(nPAA_centroids),...
        trgtNum,reflectionOrder+1, ...
        paraCfgInput.numberOfTimeDivisions);
    for  i =1: reflectionOrder+1
        [MpcTargetMat{:,:,:,i,:}] = deal(MpcTarget{i});
    end
end

%% Write output in JSON files
% QD output
if isJsonOutput  || keepBothQDOutput
    writeQdJsonOutput(outputPaaTime,cellfun(@(x) x.nPaa,  nodeCfgInput.paaInfo),...
        qdFilesPath);
    if trgtNum
        writeQdJsonTargetOutput(trgOutChan, cellfun(@(x) x.nPaa,  nodeCfgInput.paaInfo), qdFilesPath)
    end
end

if paraCfgInput.switchSaveVisualizerFiles
    Mpc(:,:,:,:,:,1) = [];
    writeVisualizerJsonOutput(visualizerPath, paraCfgInput, nodeCfgInput, nPAA_centroids, nodePosition, Mpc)
    if trgtNum
        writeVisualizerTargetJsonOutput(visualizerPath, paraCfgInput, nodeCfgInput, nPAA_centroids, nodePosition,trgCfgInput,MpcTarget)
    end
end

if ~isJsonOutput || keepBothQDOutput
    closeQdFilesIds(fids, paraCfgInput.useOptimizedOutputToFile);
end

%% Write useful output information.
writeReportOutput = 0 ; %Set to 0 to allow succeful test.
if writeReportOutput
    f = fopen(strcat(outputPath, filesep,'report.dat'), 'w'); %#ok<UNRCH>
    fprintf(f, 'Device Rotation:\t%d\n', paraCfgInput.isDeviceRotationOn);
    fprintf(f, 'Initial Orientation:\t%d\n', paraCfgInput.isInitialOrientationOn);
    fprintf(f, 'PAA centered:\t%d\n', paraCfgInput.isPaaCentered);
    fclose(f);
end
end