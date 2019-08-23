function b = isNodePositions(path)
splitPath = split(path,'/');

b = ~isempty(regexp(splitPath{end}, 'NodePositionsTrc[\d]+.csv', 'once'));

b = b && strcmp(splitPath{end-1}, 'NodePositions');
b = b && strcmp(splitPath{end-2}, 'Visualizer');
b = b && strcmp(splitPath{end-3}, 'Output');
end