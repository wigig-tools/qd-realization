clear
close all
clc

addpath('../utils')

%% data loading
scenario = 'SpatialSharing'; % select the scenario to visualize. Must respect the folder structure
Tx = 0;
Rx = 1;
timestep = 1;

scenarioPath = ['../',scenario];
ns3Path = sprintf('%s/Output/Ns3', scenarioPath);
qdFilePath = sprintf('%s/QdFiles/Tx%dRx%d.txt', ns3Path, Tx, Rx);

qdFile = readQdFile(qdFilePath);

%% Visualization
qdStruct = qdFile(timestep);

plotQdStruct(qdStruct, 'Tx')