function cs = array2cellstr(a)
c = num2cell(a);
cs = cellfun(@(n) num2str(n), c, 'UniformOutput', false);
end