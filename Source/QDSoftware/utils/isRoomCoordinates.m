function b = isRoomCoordinates(path)
%ISROOMCOORDINATES Function that checks whether the given path matches with
% the expected Room Coordinates output file position (as given by the
% documentation). This allows to safely read the file later.
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% SEE ALSO: READROOMCOORDINATES
%
% TODO license
splitPath = split(path,'/');

b = strcmp(splitPath{end}, 'RoomCoordinates.csv');
b = b && strcmp(splitPath{end-1}, 'RoomCoordinates');
b = b && strcmp(splitPath{end-2}, 'Visualizer');
b = b && strcmp(splitPath{end-3}, 'Output');
end