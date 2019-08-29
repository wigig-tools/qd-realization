function out = readNodesPosition(path)
%READNODESPOSITION Function that extracts the Nodes Position from the 
% output file, as described by the documentation).
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% OUTPUTS:
% - out: matrix version of the csv file
%
% SEE ALSO: ISNODESPOSITION
%
% TODO license
out = readtable(path,...
    'FileType', 'text',...
    'ReadVariableNames', false,...
    'Delimiter', ',');
out = out{:,:}; % return matrix

end