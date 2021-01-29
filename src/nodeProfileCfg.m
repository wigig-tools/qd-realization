function [paraCfg, nodeCfg] = nodeProfileCfg(paraCfg)
%NODEPROFILECFG imports the node information such as the node and PAA
%positions and orientation over time

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
% Modified by: Mattia Lecci <leccimat@dei.unipd.it>, Updated implementation
%              Steve Blandino <steve.blandino@nist.gov>

warning('off', 'MATLAB:MKDIR:DirectoryExists');

scenarioNameStr = paraCfg.inputScenarioName;

% Input Parameters to be Updated
numberOfTimeDivisions = paraCfg.numberOfTimeDivisions;

% List of paths
inputPath = fullfile(scenarioNameStr, 'Input');

%% Back compatibility code. To be removed in future versions of the software
% Try to open previous config: nodes.dat. If it exist convert it into new
% config i.e. NodePositionX.dat
try
    obsoletePosition = csvread(fullfile(inputPath, 'nodes.dat'));
    warning('Configuration obsolete. nodes.dat not used anymore: node information loaded from NodePosition.dat')
    listing = dir(fullfile(scenarioNameStr, 'Input'));
    for nodeId = 1: size(obsoletePosition,1)
        if ~sum(arrayfun(@(x) strcmp(x.name,['NodePosition',num2str(nodeId-1), '.dat']), listing))
            writematrix(obsoletePosition(nodeId,1:3), fullfile(inputPath, ['NodePosition', num2str(nodeId-1),'.dat']))
        end
    end
catch
end

%% Init
listing = dir(fullfile(scenarioNameStr, 'Input'));
paraCfg.numberOfNodes = sum(arrayfun(@(x) startsWith(x.name,'NodePosition'), listing));
numberOfNodes = paraCfg.numberOfNodes;
assert(numberOfNodes>=2, 'At least 2 nodes need to be defined');
nodeRotationTime= zeros(paraCfg.numberOfTimeDivisions,3, paraCfg.numberOfNodes);
nodeInitialPosition = zeros( paraCfg.numberOfNodes, 3);
nodePositionTime = zeros(paraCfg.numberOfTimeDivisions,3, paraCfg.numberOfNodes);
nodePositionTimeRaw = cell(numberOfNodes,1);
nodeRotationTimeRaw = cell(numberOfNodes,1);

%% Load NodePositionX.dat and NodeRotationX.dat
for iterateNumberOfNodes = 1:numberOfNodes
    nodePositionFile = sprintf('NodePosition%d.dat',iterateNumberOfNodes-1);
    nodeRotationFile = sprintf('NodeRotation%d.dat',iterateNumberOfNodes-1);
    isNodePosition = any(arrayfun(@(x) strcmp(x.name,nodePositionFile), listing));
    isNodeRotation = any(arrayfun(@(x) strcmp(x.name,nodeRotationFile), listing));
    
    if ~isNodePosition
        error([ nodePositionFile, ' not defined.']);
    end
    nodePositionTimeRaw{iterateNumberOfNodes} = readmatrix(fullfile(inputPath,nodePositionFile));
    
    if ~isNodeRotation
        nlines = size(nodePositionTimeRaw{iterateNumberOfNodes},1);
        nodeRotationTimeRaw{iterateNumberOfNodes} = repmat([0 0  0], nlines,1);
        writematrix(nodeRotationTimeRaw{iterateNumberOfNodes}, fullfile(inputPath,nodeRotationFile));
        warning([nodeRotationFile, ' not defined. Rotation set to [0,0,0] for all time instances.'])
        
    else
        nodeRotationTimeRaw{iterateNumberOfNodes} = readmatrix(fullfile(inputPath,nodeRotationFile));
        
    end
    
end

%%  NodePositionX.dat and NodeRotationX.dat processing
for iterateNumberOfNodes = 1:numberOfNodes
    % NodePosition processing
    nodePositionTimeTmp = nodePositionTimeRaw{iterateNumberOfNodes};
    timeSamplesFile = size(nodePositionTimeTmp,1);
    
    % Config file defines fewer positions in time than the numberOfTimeDivisions
    % defined in paraCfg
    if  timeSamplesFile< paraCfg.numberOfTimeDivisions &&  ...
            timeSamplesFile > 1
        nodePositionTime = nodePositionTime(1:timeSamplesFile, :,:);
        paraCfg.numberOfTimeDivisions = timeSamplesFile;
        numberOfTimeDivisions = paraCfg.numberOfTimeDivisions;
        warning('Time divisition too long.')
        
    end
    numberTracePoints = min(timeSamplesFile,paraCfg.numberOfTimeDivisions);
    nodePositionTime(1:numberTracePoints, :, iterateNumberOfNodes) = ...
        nodePositionTimeTmp(1:numberTracePoints,:);
    nodePositionTime(numberTracePoints+1:end, :, iterateNumberOfNodes) = ...
        repmat(nodePositionTimeTmp, [paraCfg.numberOfTimeDivisions-numberTracePoints,1,1]);
    nodeInitialPosition(iterateNumberOfNodes,:) = squeeze(nodePositionTime(1,:,iterateNumberOfNodes));
    
    % NodeRotation processing
    nodeRotationTimeTemp = nodeRotationTimeRaw{iterateNumberOfNodes};
    timeSamplesFile = size(nodeRotationTimeTemp,1);

    % Config file defines fewer rotations in time than the numberOfTimeDivisions
    % defined in paraCfg
    if  timeSamplesFile< paraCfg.numberOfTimeDivisions &&  ...
            timeSamplesFile> 1
        nodeRotationTime = nodeRotationTime(1:size(nodeRotationTimeTemp,1), :,:);
        paraCfg.numberOfTimeDivisions = size(nodeRotationTimeTemp,1) ;
        numberOfTimeDivisions = paraCfg.numberOfTimeDivisions;
        warning('Time divisition too long.')
    end
    numberTracePoints =  min(size(nodeRotationTimeTemp,1),paraCfg.numberOfTimeDivisions);
    nodeRotationTime(1:numberTracePoints, :, iterateNumberOfNodes) = ...
        nodeRotationTimeTemp(1:numberTracePoints,:);
    nodeRotationTime(numberTracePoints+1:end, :, iterateNumberOfNodes) = ...
        repmat(nodeRotationTimeTemp, [paraCfg.numberOfTimeDivisions-numberTracePoints,1,1]);        
   
end

%% PAA init
nodePaaInitialPosition = cell(numberOfNodes,1); %PAA vector position w.r.t node center
nodePaaOrientation     = cell(numberOfNodes,1); 

for iterateNumberOfNodes = 1:numberOfNodes
    paaFile = fullfile(inputPath, sprintf('NodePaa%d.dat', iterateNumberOfNodes-1));
    
    % If NodePaaX.dat is defined
    if isfile(paaFile)
        nodePaaInfo =  readmatrix(paaFile);
        
        if isempty(nodePaaInfo)
            nodePaaInitialPosition{iterateNumberOfNodes}  = nodePaaInfo;
            
        else
            nodePaaInitialPosition{iterateNumberOfNodes}  = nodePaaInfo(:, 1:3);
            
        end
        
        % PAA orientation not defined
        if size(nodePaaInfo, 2) == 3
            nodePaaOrientation{iterateNumberOfNodes}  = zeros(size(nodePaaInfo));
            
            % PAA orientation
        elseif size(nodePaaInfo, 2) == 6
            nodePaaOrientation{iterateNumberOfNodes}  = nodePaaInfo(:,4:6);
            
        end
        
        % If nodeXpaa.dat is not defined
    else
        nodePaaInitialPosition{iterateNumberOfNodes} = zeros(1,3);
        nodePaaOrientation{iterateNumberOfNodes}  = zeros(1,3);
        
    end
    
end

%% Process PAA position
paaInfo  = clusterPaa(nodePositionTime, nodePaaInitialPosition, nodePaaOrientation);

%% Output
% Check Temp Output Folder
rmdirStatus = rmdir(fullfile(scenarioNameStr, 'Output'), 's'); %#ok<NASGU>

mkdir(fullfile(scenarioNameStr, 'Output'));
mkdir(fullfile(scenarioNameStr, 'Output/Ns3'));
mkdir(fullfile(scenarioNameStr, 'Output/Visualizer'));

warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')

paraCfg.numberOfNodes = numberOfNodes;
paraCfg.numberOfTimeDivisions = numberOfTimeDivisions;
nodeCfg.nodeLoc = nodeInitialPosition;
nodeCfg.nodeAntennaOrientation = nodePaaOrientation;
nodeCfg.nodePosition = reshape(nodePositionTime, [], 3, numberOfNodes);
nodeCfg.nodeRotation = nodeRotationTime;
nodeCfg.paaInfo = paaInfo;
paraCfg.isInitialOrientationOn = any(cellfun(@(x) any(reshape(x, [],1)), nodePaaOrientation));
paraCfg.isDeviceRotationOn = any(nodeRotationTime(:));
paraCfg.isPaaCentered = ~any(cellfun(@(x) any(x(:)), nodePaaInitialPosition));
end
