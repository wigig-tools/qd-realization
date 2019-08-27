clear
close all
clc

addpath('../utils')

%% data loading
scenario = 'SpatialSharing'; % select the scenario to visualize. Must respect the folder structure
path = ['../',scenario];
visualizerPath = strcat(path,'/Output/Visualizer');

roomCoordPath = strcat(visualizerPath,'/RoomCoordinates/RoomCoordinates.csv');
roomCoords = readRoomCoordinates(roomCoordPath);

%% visualization
[Tri,X,Y,Z] = roomCoords2triangles(roomCoords); % triangle vertices

saveGif=true;
orderColor=true;
visualizeRays(Tri,X,Y,Z,visualizerPath,0,3,saveGif,orderColor)

% color selection
% boxTriangles = xml2struct(strcat(path,'/Input/BoxTriangles.xml'));

%
% axis equal
% xlabel('x')
% ylabel('y')
% zlabel('z')
