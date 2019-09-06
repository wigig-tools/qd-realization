function updateScenario(app)

scenarioName = app.ScenarioDropdown.Value;
app.scenarioName = scenarioName;
app.UIAxes.Title.String = scenarioName;

app.outputPath = sprintf('../%s/Output', scenarioName);
app.visualizerPath = sprintf('../%s/Output/Visualizer', scenarioName);
app.ns3Path = sprintf('../%s/Output/Ns3', scenarioName);

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
app.currentTimestep = 1;

if totalTimesteps < 2
    app.TimestepSlider.Limits = [0,1];
    app.TimestepSlider.Enable = 'off';
    
    app.TimestepSpinner.Limits = [0,1];
    app.TimestepSpinner.Enable = 'off';
else
    app.TimestepSlider.Limits = [1, totalTimesteps];
    app.TimestepSlider.Enable = 'on';
    
    app.TimestepSpinner.Limits = [1, totalTimesteps];
    app.TimestepSpinner.Enable = 'on';
end
end


function qdFiles = extractQdFilesInfo(app)

end


function extractMpcCoordinatesInfo(app)
mpcFiles = dir(sprintf('%s/MpcCoordinates',app.visualizerPath));

for i = 1:length(mpcFiles)
    t = regexp(mpcFiles(i).name,'MpcTx(\d+)Rx(\d+)Refl(\d+)Trc(\d+).csv','tokens');
    if isempty(t)
        continue
    end
    
    % else
    Tx = str2double(t{1}{1}) + 1;
    Rx = str2double(t{1}{2}) + 1;
    Refl = str2double(t{1}{3}) + 1;
    timestep = str2double(t{1}{4}) + 1;
    
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