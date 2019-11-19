function paraCfg = applyForcedCfgParams(paraCfg, forcedParaCfg)

forcedParaCfgFields = fieldnames(forcedParaCfg);
for i = 1:length(forcedParaCfgFields)
    
    field = forcedParaCfgFields{i};
    if isfield(paraCfg, field)
        paraCfg.(field) = forcedParaCfg.(field);
    else
        error('Forced field ''%s'' was not recognized as a valid configuration parameter', field)
    end
    
end

end