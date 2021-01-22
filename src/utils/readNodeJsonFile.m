function out = readNodeJsonFile(path)
%READNODEJSONFILE extracts the node information from the output JSON file
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% OUTPUTS:
% - out: array of JSON struct
% Copyright 2019-2020 NIST/CTL (steve.blandino@nist.gov)

fid = fopen(path);

out = struct('Node', [], ...
    'Position',[], ...
    'Rotation', [] ...
    );

line = 1;
isEof = false;
while ~isEof
    tline = fgetl(fid);
    if ischar( tline )
        out(line) = jsondecode(tline);
        line = line + 1;
    else
        isEof = true;
    end
end

fclose(fid);
end