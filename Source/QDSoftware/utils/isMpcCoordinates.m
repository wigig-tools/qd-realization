function b = isMpcCoordinates(path)
%ISMPCCOORDINATES Function that checks whether the given path matches with
% the expected MPC Coordinates output file position (as given by the
% documentation). This allows to safely read the file later.
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% SEE ALSO: READMPCCOORDINATES
%
% TODO license
splitPath = split(path,'/');

b = ~isempty(regexp(splitPath{end},...
    'MpcTx[\d]+Rx[\d]+Refl[\d]+Trc[\d]+.csv',...
    'once'));

b = b && strcmp(splitPath{end-1}, 'MpcCoordinates');
b = b && strcmp(splitPath{end-2}, 'Visualizer');
b = b && strcmp(splitPath{end-3}, 'Output');
end