function b = isQdFile(path)
%ISQDFILE Function that checks whether the given path matches with
% the expected QD file output file position (as given by the
% documentation). This allows to safely read the file later.
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% SEE ALSO: READQDFILE
%
% TODO license
splitPath = split(path,'/');

b = ~isempty(regexp(splitPath{end}, 'Tx[\d]+Rx[\d]+.txt', 'once'));

b = b && strcmp(splitPath{end-1}, 'QdFiles');
b = b && strcmp(splitPath{end-2}, 'Ns3');
b = b && strcmp(splitPath{end-3}, 'Output');
end