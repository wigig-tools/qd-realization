function b = isNodePositions(path)
%ISNODEPOSITIONS Function that checks whether the given path matches with
% the expected Node Positions output file position (as given by the
% documentation). This allows to safely read the file later.
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% SEE ALSO: READNODEPOSITIONS
%
% TODO license
splitPath = split(path,'/');

b = ~isempty(regexp(splitPath{end}, 'NodePositionsTrc[\d]+.csv', 'once'));

b = b && strcmp(splitPath{end-1}, 'NodePositions');
b = b && strcmp(splitPath{end-2}, 'Visualizer');
b = b && strcmp(splitPath{end-3}, 'Output');
end