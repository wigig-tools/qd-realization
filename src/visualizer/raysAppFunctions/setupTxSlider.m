function setupTxSlider(app,value)
% remember old index to check for same tx/rx
oldValue = app.txIndex;

% update value
app.txIndex = value; % from 1
app.TxDropdown.Value = app.TxDropdown.Items{value};

% check if tx/rx have same value
if app.txIndex == app.rxIndex
    setupRxSlider(app, oldValue)
end
end