function [outputPaaTime, Mpc, nodeCfgInput] = rtTargetUnrelated(nodeCfgInput, paraCfgInput, cadInfo, polCfg, writeCfg,varargin)
%%RTTARGETUNRELATED Target unrelated rays 
%
% [turRay,M] = RTTARGETUNRELATED(N, T, P, C) returns target unrelated
% rays turRay and the relative mpc M given as input the node configuration
% N, the target configuration T, the parameters configuration P, the cad info C
%
% [turRay,M] = RTTARGETRELATED(..., 'displayProgress', val), disable the
% print of the status of the ray tracing when val is 0, otherwise it prints
% the percentage completed

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
% Steve Blandino <steve.blandino@nist.gov>

%% Input processing
p = inputParser;
addOptional(p,'displayProgress',1);
parse(p, varargin{:});
displayProgress = p.Results.displayProgress;

%% Init params
nodePosition = nodeCfgInput.nodePosition;
nPAA_centroids = cellfun(@(x) x.nPAA_centroids, nodeCfgInput.paaInfo );
Mpc = cell(paraCfgInput.numberOfNodes,...
    max(nPAA_centroids),...
    paraCfgInput.numberOfNodes,...
    max(nPAA_centroids),...
    paraCfgInput.totalNumberOfReflections+1,...
    paraCfgInput.numberOfTimeDivisions+1 );
ts = paraCfgInput.totalTimeDuration/paraCfgInput.numberOfTimeDivisions;
switchPolarization = polCfg.isPol;
switchCp = polCfg.isXPol;
polarizationTx = polCfg.txPol;
CADop =cadInfo.cad;
MaterialLibrary = cadInfo.materialLibrary;
switchMaterial = cadInfo.allMaterialDefined;
[~, scenarioName] = fileparts(paraCfgInput.inputScenarioName);
isJsonOutput = writeCfg.isJsonOutput;
keepBothQDOutput = writeCfg.keepBothQDOutput;
fids = writeCfg.fids;
qdFilesPath = writeCfg.qdFilesPath;


if paraCfgInput.nodeMobility
    targetUnreleatedSimLength = paraCfgInput.numberOfTimeDivisions; 
else
    targetUnreleatedSimLength = 1;
end

%% Time loop
for iterateTimeDivision = 1:targetUnreleatedSimLength
    if mod(iterateTimeDivision,100)==0 && displayProgress
        fprintf('%2.2f%%\n', iterateTimeDivision/targetUnreleatedSimLength*100)
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
                    [isLos, delayLos, output] = LOSOutputGenerator(CADop, Rx, Tx,...
                        output, vtx, vrx, switchPolarization, switchCp,...
                        polarizationTx, paraCfgInput.carrierFrequency, ...
                        'rotTx', QTx.angle, 'rotRx', QRx.angle, 'enablePhase', paraCfgInput.enablePhaseOutput);

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
                            multipath(delayLos,...
                            ArrayOfPlanes, ArrayOfPoints, Rx, Tx,...
                            CADop, numberOfPlanes,...
                            MaterialLibrary, arrayOfMaterials, ...
                            switchMaterial, vtx, vrx,...
                            paraCfgInput.switchDiffuseComponent,...
                            paraCfgInput.switchQDModel,...
                            scenarioName,...
                            paraCfgInput.carrierFrequency,...
                            paraCfgInput.diffusePathGainThreshold,...
                            paraCfgInput.reflectionLoss,...
                            'rotTx', QTx.angle, 'rotRx', QRx.angle,...
                            'enablePhase', paraCfgInput.enablePhaseOutput);

                        nMpc = size(multipathTemporary,1);
                        %Store MPC
                        if paraCfgInput.switchSaveVisualizerFiles && nMpc > 0
                            multipath1 = multipathTemporary(:,2:end); %Discard reflection order column
                            Mpc{iterateTx,iteratePaaTx,...
                                iterateRx,iteratePaaRx, ...
                                iterateOrderOfReflection+1,...
                                iterateTimeDivision+1} = multipath1;
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

if ~paraCfgInput.nodeMobility
    outputPaaTime(:,:,2:paraCfgInput.numberOfTimeDivisions) = repmat(outputPaaTime(:,:,1), [1 1 paraCfgInput.numberOfTimeDivisions-1]);
    Mpc(:,:,:,:,:,3:end) = repmat(Mpc(:,:,:,:,:,2), [1 1 1 1 1 paraCfgInput.numberOfTimeDivisions-1]);
end

end