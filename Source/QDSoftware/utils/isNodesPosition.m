function b = isNodesPosition(path)
splitPath = split(path,'/');

b = strcmp(splitPath{end}, 'NodesPosition.csv');
b = b && strcmp(splitPath{end-1}, 'NodesPosition');
b = b && strcmp(splitPath{end-2}, 'Ns3');
b = b && strcmp(splitPath{end-3}, 'Output');
end