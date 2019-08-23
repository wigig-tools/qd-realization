function b = isQdFile(path)
splitPath = split(path,'/');

b = ~isempty(regexp(splitPath{end}, 'Tx[\d]+Rx[\d]+.txt', 'once'));

b = b && strcmp(splitPath{end-1}, 'QdFiles');
b = b && strcmp(splitPath{end-2}, 'Ns3');
b = b && strcmp(splitPath{end-3}, 'Output');
end