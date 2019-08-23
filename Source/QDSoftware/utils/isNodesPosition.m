function b = isNodesPosition(path)
%ISNODESPOSITION Function that checks whether the given path matches with
% the expected Nodes Position output file position (as given by the
% documentation). This allows to safely read the file later.
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% SEE ALSO: READNODESPOSITION
%
% TODO license
splitPath = split(path,'/');

b = strcmp(splitPath{end}, 'NodesPosition.csv');
b = b && strcmp(splitPath{end-1}, 'NodesPosition');
b = b && strcmp(splitPath{end-2}, 'Ns3');
b = b && strcmp(splitPath{end-3}, 'Output');
end