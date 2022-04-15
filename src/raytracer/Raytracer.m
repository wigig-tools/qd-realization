function outputPath = Raytracer(paraCfgInput, nodeCfgInput, varargin)
%%RAYTRACER generates a realization of the QD channel model.
%
% RAYTRACER(paraCfgInput,nodeCfgInput) generates a realization of the Q-D
% model between nodes in a static environment. paraCfgInput is the
% simulation struct. nodeCfgInput is the node struct.
%
% RAYTRACER(-, 'target', TG) generates a realization of the Q-D model in
% presence of moving targets. TG is the target struct.


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

% List of paths
inputPath = fullfile(paraCfgInput.inputScenarioName, 'Input');
outputPath = fullfile(paraCfgInput.inputScenarioName, 'Output');
ns3Path = fullfile(outputPath, 'Ns3');
qdFilesPath = fullfile(ns3Path, 'QdFiles');

if paraCfgInput.switchSaveVisualizerFiles == 1
    visualizerPath = fullfile(outputPath, 'Visualizer');
else
    visualizerPath = [];
end

% Subfolders creation
if ~isfolder(qdFilesPath)
    mkdir(qdFilesPath)
end

% Init output files
keepBothQDOutput = strcmp(paraCfgInput.outputFormat, 'both');
isJsonOutput = strcmp(paraCfgInput.outputFormat, 'json');
if ~isJsonOutput || keepBothQDOutput
    fids = getQdFilesIds(qdFilesPath, paraCfgInput.numberOfNodes,...
        paraCfgInput.useOptimizedOutputToFile);
else 
    fids = [];
end
writeCfg.isJsonOutput= isJsonOutput;
writeCfg.keepBothQDOutput = keepBothQDOutput;
writeCfg.fids = fids;
writeCfg.inputPath=inputPath;
writeCfg.outputPath = outputPath;
writeCfg.ns3Path = ns3Path;
writeCfg.visualizerPath = visualizerPath;
writeCfg.qdFilesPath = qdFilesPath;

%% Init
polarizationCfg.isPol = 0;
polarizationCfg.isXPol = 0;
polarizationCfg.txPol = [1,0];
nPaaCentroids = cellfun(@(x) x.nPAA_centroids, nodeCfgInput.paaInfo);
printRtStatus = 1;
%% Get CAD info
MaterialLibrary = importMaterialLibrary(paraCfgInput.materialLibraryPath);

% Extracting CAD file and storing in an XMl file, CADFile.xml
[CADop, switchMaterial] = getCadOutput(paraCfgInput.environmentFileName,...
    inputPath, MaterialLibrary, paraCfgInput.referencePoint,...
    paraCfgInput.selectPlanesByDist, paraCfgInput.indoorSwitch);

if paraCfgInput.switchSaveVisualizerFiles == 1
    % Save output file with room coordinates for visualization
    RoomCoordinates = CADop(:, 1:9);
    csvwrite(fullfile(visualizerPath, 'RoomCoordinates.csv'),...
        RoomCoordinates); %#ok<CSVWT> 
cadInfo.roomCoordinates = RoomCoordinates;

end

cadInfo.cad = CADop;
cadInfo.allMaterialDefined = switchMaterial;
cadInfo.materialLibrary = MaterialLibrary;

%% Node-node ray tracing
[outputPaaTime, mpc, nodeCfg] = rtTargetUnrelated(nodeCfgInput, paraCfgInput, ...
    cadInfo, polarizationCfg, writeCfg, 'displayProgress',printRtStatus); 

%% Node-target-node ray tracing
[trgOutChan,mpcTarget] = rtTargetRelated(nodeCfg, trgCfgInput, paraCfgInput, ...
    cadInfo,'displayProgress',printRtStatus);

%% Write output in JSON files
% QD output
if isJsonOutput  || keepBothQDOutput
    if trgtNum
        writeSensOutput(outputPaaTime, trgOutChan, cellfun(@(x) x.nPaa,  nodeCfg.paaInfo), qdFilesPath)
        writeQdJsonTargetOutput(trgOutChan, cellfun(@(x) x.nPaa,  nodeCfg.paaInfo), qdFilesPath, 'index', trgCfgInput.trgtBaseIndex)

    else
        writeQdJsonOutput(outputPaaTime,cellfun(@(x) x.nPaa,  nodeCfg.paaInfo),...
            qdFilesPath);
    end
end

if paraCfgInput.switchSaveVisualizerFiles
    mpc(:,:,:,:,:,1) = [];
    writeVisualizerJsonOutput(visualizerPath, paraCfgInput, nodeCfg, nPaaCentroids, mpc)
    if trgtNum
        writeVisualizerTargetJsonOutput(visualizerPath, paraCfgInput, nodeCfg, nPaaCentroids, trgCfgInput,mpcTarget)
        writeTargetConnections(trgtNum, visualizerPath)
    end
end

if ~isJsonOutput || keepBothQDOutput
    closeQdFilesIds(fids, paraCfgInput.useOptimizedOutputToFile);
end

%% Write useful output information.
writeReportOutput = 0 ; %Set to 0 to allow succeful test.
if writeReportOutput
    f = fopen(fullfile(outputPath, 'report.dat'), 'w'); %#ok<UNRCH>
    fprintf(f, 'Device Rotation:\t%d\n', paraCfgInput.isDeviceRotationOn);
    fprintf(f, 'Initial Orientation:\t%d\n', paraCfgInput.isInitialOrientationOn);
    fprintf(f, 'PAA centered:\t%d\n', paraCfgInput.isPaaCentered);
    fclose(f);
end
end