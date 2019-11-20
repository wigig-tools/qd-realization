function [paraCfg, nodeCfg] = nodeProfileCfg(paraCfg)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

scenarioNameStr = paraCfg.inputScenarioName;
% Input Parameters to be Updated
environmentFileName = paraCfg.environmentFileName;
% scenarioNameStr = paraCfg.scenarioNameStr;
mobilitySwitch = paraCfg.mobilitySwitch;
mobilityType = paraCfg.mobilityType;
numberOfNodes = paraCfg.numberOfNodes;
numberOfTimeDivisions = paraCfg.numberOfTimeDivisions;
switchRandomization = paraCfg.switchRandomization;

% List of paths
inputPath = strcat(scenarioNameStr, '/Input');
nodesPositionPath = strcat(scenarioNameStr,'/Output/Ns3/NodesPosition');

%% Code
nodePosition = [];

%% Random generation of node positions
if switchRandomization == 1
    xCoordinateRandomizer = rand * 8 + 1;
    yCoordinateRandomizer = rand * 17 + 1;
    zCoordinateRandomizer = 2.5;
    Tx = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
    
    xCoordinateRandomizer = rand * 8 + 1;
    yCoordinateRandomizer = rand * 17 + 1;
    zCoordinateRandomizer = 1.6;
    Rx = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
    
    mobilityType = 1;
end

%% Extracting data from nodes.dat and nodeVelocities.dat file.
% nodes.dat file contains nodes locations and nodeVelocities contains their
% velocities
if switchRandomization == 0
    try
        nodeLoc = csvread(strcat(inputPath, '/nodes.dat'));
        nodeVelocities = csvread(strcat(inputPath, '/nodeVelocities.dat'));
    catch
        switchRandomization = 1;
    end
    
    if size(nodeLoc,1) ~= size(nodeVelocities,1) && mobilitySwitch == 1
        error(['nodes.dat and nodeVelocities.dat do not have same number ',...
            'of rows. Please check the input files in the Input folder.'])
    end
    if ~isempty(numberOfNodes) && numberOfNodes ~= size(nodeLoc,1)
        warning(['"numberOfNodes" parameter does not match the number of ',...
            'nodes given in file. The "numberOfNodes" is adjusted to ',...
            'the number of nodes given in file']);
    end
    numberOfNodes = size(nodeLoc,1);
    
    if mobilitySwitch == 1
        nodeVelocitiesTemp = nodeVelocities;
        clear nodeVelocities;
        nodeVelocities = nodeVelocitiesTemp(1:numberOfNodes, :);
    else
        clear nodeVelocities;
        nodeVelocities = zeros(numberOfNodes, 3);
    end
    if mobilityType == 2
        listing = dir(strcat(scenarioNameStr, '/Input'));
        sizeListing = size(listing);
        countListing = 0;
        for iterateSizeListing = 1:sizeListing(1)
            ln = listing(iterateSizeListing).name;
            
            for iterateNumberOfNodes = 1:numberOfNodes
                if strcmp(ln, strcat('NodePosition', num2str(iterateNumberOfNodes), '.dat'))
                    nodePositionTemp = load(strcat(inputPath, '/', ln));
                    try
                        nodePosition(:, :, iterateNumberOfNodes) = nodePositionTemp;
                        countListing = countListing + 1;
                    catch
                        warning(['Node Position input incorrect. Linear',...
                            'mobility model is chosen']);
                        mobilityType = 1;
                    end
                end
            end
        end
        sizeNodePosition = size(nodePosition);
        if mobilityType == 2 && countListing < numberOfNodes
            warning(['Node Position input incorrect. Linear mobility',...
                'model is chosen']);
            mobilityType = 1;
        elseif mobilityType == 2 && countListing == numberOfNodes
            numberOfTimeDivisions = sizeNodePosition(1) - 2;
        end
    end
end

iterateNumberOfNodes = 1;
%% This part of code generates other parameters of
nodeAntennaOrientation = zeros(numberOfNodes, 3, 3);
nodePolarization = zeros(iterateNumberOfNodes, 2);
while iterateNumberOfNodes <= numberOfNodes
    nodeAntennaOrientation(iterateNumberOfNodes, :, :) = [1, 0, 0; 0, 1, 0; 0, 0, 1];
    nodePolarization(iterateNumberOfNodes, :) = [1, 0];
    if switchRandomization == 1 && iterateNumberOfNodes > 0
        xCoordinateRandomizer = rand * 8 + 1;
        yCoordinateRandomizer = rand * 17 + 1;
        zCoordinateRandomizer = 1.6;
        nodeLoc(iterateNumberOfNodes, :) = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
        xCoordinateRandomizer = rand * 0.7;
        yCoordinateRandomizer = sqrt((0.7^2) - (xCoordinateRandomizer^2));
        zCoordinateRandomizer = 0;
        nodeVelocities(iterateNumberOfNodes, :) = [xCoordinateRandomizer, yCoordinateRandomizer, zCoordinateRandomizer];
    end
    iterateNumberOfNodes = iterateNumberOfNodes + 1;
end

switchRandomization = 0;

% Check Temp Output Folder
status = rmdir(strcat(scenarioNameStr,'/Output'), 's');

mkdir(strcat(scenarioNameStr,'/Output'));
mkdir(strcat(scenarioNameStr,'/Output/Ns3'));
mkdir(strcat(scenarioNameStr,'/Output/Visualizer'));

sizeNode = size(nodeLoc);

if ~isfolder(nodesPositionPath)
    mkdir(nodesPositionPath)
end

csvwrite(strcat(nodesPositionPath, '/',...
    'NodesPosition.csv'), nodeLoc);

warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')

paraCfg.mobilityType = mobilityType;
paraCfg.numberOfNodes = numberOfNodes;
paraCfg.numberOfTimeDivisions = numberOfTimeDivisions;
paraCfg.switchRandomization = switchRandomization;

nodeCfg.nodeLoc = nodeLoc;
nodeCfg.nodeAntennaOrientation = nodeAntennaOrientation;
nodeCfg.nodePolarization = nodePolarization;
nodeCfg.nodePosition = nodePosition;
nodeCfg.nodeVelocities = nodeVelocities;

end
