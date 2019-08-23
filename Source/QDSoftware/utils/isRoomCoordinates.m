function b = isRoomCoordinates(path)
splitPath = split(path,'/');

b = strcmp(splitPath{end}, 'RoomCoordinates.csv');
b = b && strcmp(splitPath{end-1}, 'RoomCoordinates');
b = b && strcmp(splitPath{end-2}, 'Visualizer');
b = b && strcmp(splitPath{end-3}, 'Output');
end