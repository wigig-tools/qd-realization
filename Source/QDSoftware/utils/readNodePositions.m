function out = readNodePositions(path)
%READNODEPOSITIONS Function that extracts the Node Positions from the 
% output file, as described by the documentation).
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% OUTPUTS:
% - out: matrix version of the csv file
%
% SEE ALSO: ISNODEPOSITIONS
%
% TODO license
out = readtable(path,...
    'FileType', 'text',...
    'ReadVariableNames', false,...
    'Delimiter', ',');
out = out{:,:}; % return matrix

end