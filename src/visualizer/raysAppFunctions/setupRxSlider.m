function setupRxSlider(app,value)
%SETUPRXSLIDER Change RX node from slider


% Copyright (c) 2020, University of Padova, Department of Information
% Engineering, SIGNET lab.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

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