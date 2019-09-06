function setupRxSlider(app,value)
% remember old index to check for same tx/rx
oldValue = app.rxIndex;

% update value
app.rxIndex = value; % from 1
app.RxDropdown.Value = app.RxDropdown.Items{value};

% check if tx/rx have same value
if app.txIndex == app.rxIndex
    setupTxSlider(app, oldValue)
end
end