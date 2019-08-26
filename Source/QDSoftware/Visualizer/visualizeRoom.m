clear
close all
clc

addpath('../utils')

%%
path = '../L-Room/Output/Visualizer/RoomCoordinates/RoomCoordinates.csv';
roomCoords = readRoomCoordinates(path);

[Tri,X,Y,Z] = roomCoords2triangles(roomCoords);

trisurf(Tri,X,Y,Z,'FaceColor',[0.9,0.9,0.9],'FaceAlpha',0.9,'EdgeColor','k')

axis equal
xlabel('x')
ylabel('y')
zlabel('z')
