function out = readNodesPosition(path)
fid = fopen(path,'r');

assert(fid ~= -1,...
    'File path ''%s'' not valid', path)

i = 1;
while ~feof(fid)
    line = fgetl(fid);
    out(i,:) = sscanf(line,'%f,%f,%f');
    i = i+1;
end

fclose(fid);

end