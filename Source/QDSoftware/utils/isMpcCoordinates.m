function b = isMpcCoordinates(path)
splitPath = split(path,'/');

b = ~isempty(regexp(splitPath{end},...
    'MpcTx[\d]+Rx[\d]+Refl[\d]+Trc[\d]+.csv',...
    'once'));

b = b && strcmp(splitPath{end-1}, 'MpcCoordinates');
b = b && strcmp(splitPath{end-2}, 'Visualizer');
b = b && strcmp(splitPath{end-3}, 'Output');
end