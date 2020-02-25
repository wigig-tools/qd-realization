function updateScenario(app, mainPath)
%UPDATESCENARIO Prepare visualization of new scenario. Plots new
%environment, read and load Output/ files.
%
%SEE ALSO: RAYSAPPPLOTROOM, SETUPTXSLIDER, SETUPRXSLIDER, UPDATETIMESTEP


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

if nargin < 2
    mainPath = uigetdir(app.srcPath);
end

if mainPath == 0
    return
end

scenarioName = getScenarioNameFromPath(mainPath, true);
if strcmp(scenarioName, '')
    uialert(app.Visualizer,...
        'Selected path is not a valid scenario to be visualized',...
        'Invalid path')
    return
else
    app.scenarioName = scenarioName;
end

if strcmp(app.UIAxes.Title.Interpreter, 'latex')
    app.UIAxes.Title.String = strrep(scenarioName, '_', '\_');
else
    app.UIAxes.Title.String = scenarioName;
end

app.outputPath = fullfile(mainPath,'Output');
app.visualizerPath = fullfile(app.outputPath,'Visualizer');
app.ns3Path = fullfile(app.outputPath,'Ns3');

raysAppPlotRoom(app)

setupNodes(app);
setupTimestepInfo(app);

end


%% Utils
function setupNodes(app)
initialPos = readNodesPosition(sprintf('%s/NodesPosition/NodesPosition.csv',...
    app.ns3Path));

app.numNodes = size(initialPos,1);

if app.numNodes < 2
    error('There should be at least 2 nodes in the scenario')
end

% else
setupTxRxSliders(app);
setupTxSlider(app,1);
setupRxSlider(app,2);

end


function setupTxRxSliders(app)
app.TxDropdown.Items = array2cellstr(0:app.numNodes-1);
app.RxDropdown.Items = array2cellstr(0:app.numNodes-1);
end


function setupTimestepInfo(app)
app.timestepInfo = struct();

extractQdFilesInfo(app);
extractMpcCoordinatesInfo(app);
extractNodePositionsInfo(app);

totalTimesteps = length(app.timestepInfo);
app.currentTimestep = 1; % added listener to this variable 

if totalTimesteps < 2
    app.TimestepSlider.Limits = [0,1];
    app.TimestepSpinner.Limits = [0,1];
    
    app.TimestepSlider.Enable = 'off';
    app.TimestepSpinner.Enable = 'off';
    app.PlayButton.Enable = 'off';
    app.PauseButton.Enable = 'off';
else
    app.TimestepSlider.Limits = [1, totalTimesteps];
    app.TimestepSpinner.Limits = [1, totalTimesteps];
    
    app.TimestepSlider.Enable = 'on';
    app.TimestepSpinner.Enable = 'on';
    app.PlayButton.Enable = 'on';
    app.PauseButton.Enable = 'on';
end
end


function extractQdFilesInfo(app)
qdFiles = dir(sprintf('%s/QdFiles',app.ns3Path));

for i = 1:length(qdFiles)
    token = regexp(qdFiles(i).name,'Tx(\d+)Rx(\d+).txt','tokens');
    if isempty(token)
        continue
    end
    
    % else
    Tx = str2double(token{1}{1}) + 1;
    Rx = str2double(token{1}{2}) + 1;
    
    qd = readQdFile(sprintf('%s/%s',...
        qdFiles(i).folder,qdFiles(i).name));
    
    for t = 1:length(qd)
        app.timestepInfo(t).qdInfo(Tx,Rx) = qd(t);
    end
end
end


function extractMpcCoordinatesInfo(app)
mpcFiles = dir(sprintf('%s/MpcCoordinates',app.visualizerPath));

for i = 1:length(mpcFiles)
    token = regexp(mpcFiles(i).name,'MpcTx(\d+)Rx(\d+)Refl(\d+)Trc(\d+).csv','tokens');
    if isempty(token)
        continue
    end
    
    % else
    Tx = str2double(token{1}{1}) + 1;
    Rx = str2double(token{1}{2}) + 1;
    Refl = str2double(token{1}{3}) + 1;
    timestep = str2double(token{1}{4}) + 1;
    
    if timestep > length(app.timestepInfo) ||...
            ~isfield(app.timestepInfo(timestep),'mpcs') ||...
            isempty(app.timestepInfo(timestep).mpcs)
        app.timestepInfo(timestep).mpcs = cell(app.numNodes,app.numNodes,0);
    end
    
    mpcs = readNodePositions(sprintf('%s/%s',...
        mpcFiles(i).folder,mpcFiles(i).name));
    app.timestepInfo(timestep).mpcs{Tx,Rx,Refl} = mpcs;
end
end


function extractNodePositionsInfo(app)
posFiles = dir(sprintf('%s/NodePositions',app.visualizerPath));

for i = 1:length(posFiles)
    t = regexp(posFiles(i).name,'NodePositionsTrc(\d+).csv','tokens');
    if isempty(t)
        continue
    end
    
    % else
    timestep = str2double(t{1}{1}) + 1;
    pos = readNodePositions(sprintf('%s/%s',...
        posFiles(i).folder,posFiles(i).name));
    app.timestepInfo(timestep).pos = pos;
end
end