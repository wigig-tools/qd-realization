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

% 2022-2023 Neeraj Varshney NIST/CTL (neeraj.varshney@nist.gov)
% Support JSON format, node rotation, paa orientation and target

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
setupPaas(app);

setupTimestepInfo(app);

end


%% Utils
function setupNodes(app)
initialPos = readNodeJsonFile(sprintf('%s/NodePositions.json',...
    app.visualizerPath));

app.numNodes = size([initialPos.Node],2);

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
extractPaasInfo(app);

if isfile(sprintf('%s/TargetPositions.json',app.visualizerPath)) && ...
        isfile(sprintf('%s/TargetMpc.json',app.visualizerPath))
    extractTargetPositionsInfo(app);
    extractTargetMpcCoordinatesInfo(app);
end

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

function extractTargetPositionsInfo(app)
targetPosOutput = readTargetJsonFile(sprintf('%s/TargetPositions.json',...
    app.visualizerPath));
for timestep = 1:size(app.timestepInfo,2) 
    targetPos = zeros(size(targetPosOutput,2),3);
    targetRot = zeros(size(targetPosOutput,2),3);
    for i = 1:size(targetPosOutput,2)
        targetPos(i,:) = targetPosOutput(i).position(timestep,:,:);
        if size(targetPosOutput(i).rotation,1)==size(app.timestepInfo,2)
           targetRot(i,:) = targetPosOutput(i).rotation(timestep,:,:);
        else
           if sum(isnan(targetPosOutput(i).rotation(1,:,:)))>0 
               targetRot(i,:) = [0 0 0];
           else
               targetRot(i,:) = targetPosOutput(i).rotation(1,:,:);
           end
        end

    end
    app.timestepInfo(timestep).targetPos = targetPos;
    app.timestepInfo(timestep).targetRot = targetRot;
    app.timestepInfo(timestep).numTarget = unique([targetPosOutput.target]);
end

end

function extractTargetMpcCoordinatesInfo(app)
targetMpcOutput = readTargetMpcJsonFile(sprintf('%s/TargetMpc.json',...
    app.visualizerPath));

nodeList = [targetMpcOutput.node];
nodePaaList = [targetMpcOutput.nodePaa];
targetList = [targetMpcOutput.target];
jointList = [targetMpcOutput.joint];
reflOrder = [targetMpcOutput.Rorder];
% app.RefOrderDropdown.Items = array2cellstr([1:max(reflOrder),0]);
for i = 1:size(targetMpcOutput,2)

    node = nodeList(i) + 1;
    nodePaa = nodePaaList(i) + 1;
    target = targetList(i) + 1;
    joint = jointList(i) + 1;    
    refl = reflOrder(i) + 1;
    switch refl
        case 1
            numColumns = 6;
        case 2
            numColumns = 9;
        case 3
            numColumns = 12;
        case 4
            numColumns = 15;
    end
    for timestep = 1:size(targetMpcOutput(i).MPC,1)
%         if ~iscell(targetMpcOutput(i).mpc)            
            app.timestepInfo(timestep).targetInfo(node,nodePaa).mpcs{target,joint,refl} ...
                        = reshape(targetMpcOutput(i).MPC(timestep,:,:),[],numColumns);
%          else
%              app.timestepInfo(timestep).targetInfo(node,nodePaa).mpcs{target,joint,refl} = [];
%         end

    end
end

end

function extractQdFilesInfo(app)

qdFiles = dir(sprintf('%s/QdFiles',app.ns3Path));
if isfile(fullfile(qdFiles(1).folder, 'qdOutput.json')) 
    if ~isfile(fullfile(qdFiles(1).folder, 'qdTargetOutput.json'))
        qdOutput = readQdJsonFile(sprintf('%s/QdFiles/qdOutput.json',...
            app.ns3Path));
    else
        qdOutput = readQdTargetJsonFile(sprintf('%s/QdFiles/qdOutput.json',...
            app.ns3Path));
        % rename the fields (capitalize) to use a consistent notation
        qdOutput = cell2struct(struct2cell(qdOutput), ...
            {'TX', ...
            'RX', ...
            'PAA_TX', ...
            'PAA_RX', ...
            'Delay', ...
            'Gain', ...
            'Phase', ...
            'AODEL', ...
            'AODAZ', ...
            'AOAEL', ...
            'AOAAZ'});

    end        
    for i = 1:size(qdOutput,2)
        for timestep = 1:size(qdOutput(1).Delay,1)
            out = struct('TX', cell(1,1), ...
                'RX', cell(1,1), ...
                'PAA_TX', cell(1,1), ...
                'PAA_RX', cell(1,1), ...
                'Delay', cell(1,1), ...
                'Gain', cell(1,1), ...
                'Phase', cell(1,1), ...
                'AODEL', cell(1,1), ...
                'AODAZ', cell(1,1), ...
                'AOAEL', cell(1,1), ...
                'AOAAZ', cell(1,1) ...
                );
            out.TX = qdOutput(i).TX + 1;
            out.RX = qdOutput(i).RX + 1;
            out.PAA_TX = qdOutput(i).PAA_TX + 1;
            out.PAA_RX = qdOutput(i).PAA_RX + 1;
            if size(qdOutput(1).Delay,1) > 1 && iscell(qdOutput(1).Delay)
                out.Delay =  cell2mat(qdOutput(i).Delay(timestep, :));
                out.Gain =   cell2mat(qdOutput(i).Gain(timestep, :));
                out.Phase =  cell2mat(qdOutput(i).Phase(timestep, :));
                out.AODEL =  cell2mat(qdOutput(i).AODEL(timestep, :));
                out.AODAZ =  cell2mat(qdOutput(i).AODAZ(timestep, :));
                out.AOAEL =  cell2mat(qdOutput(i).AOAEL(timestep, :));
                out.AOAAZ =  cell2mat(qdOutput(i).AOAAZ(timestep, :));
            else
                out.Delay =  (qdOutput(i).Delay(timestep, :));
                out.Gain =   (qdOutput(i).Gain(timestep, :));
                out.Phase =  (qdOutput(i).Phase(timestep, :));
                out.AODEL =  (qdOutput(i).AODEL(timestep, :));
                out.AODAZ =  (qdOutput(i).AODAZ(timestep, :));
                out.AOAEL =  (qdOutput(i).AOAEL(timestep, :));
                out.AOAAZ =  (qdOutput(i).AOAAZ(timestep, :));
            end
            
            app.timestepInfo(timestep).paaInfo(out.PAA_TX,out.PAA_RX)...
                .qdInfo(out.TX,out.RX) = out;
        end
    end
else
    warning('QD components cannot be displayed for txt format. Set outputFormat = json (or both) in paraCfgCurrent.txt')
end

end


function extractMpcCoordinatesInfo(app)
mpcOutput = readMpcJsonFile(sprintf('%s/Mpc.json',...
    app.visualizerPath));
txList = [mpcOutput.TX];
rxList = [mpcOutput.RX];
paaTxList = [mpcOutput.PAA_TX];
paaRxList = [mpcOutput.PAA_RX];
reflOrder = [mpcOutput.Rorder];
app.RefOrderDropdown.Items = array2cellstr([1:max(reflOrder),0]);
for i = 1:size(mpcOutput,2)

    tx = txList(i) + 1;
    rx = rxList(i) + 1;
    paaTx = paaTxList(i) + 1;
    paaRx = paaRxList(i) + 1;    
    refl = reflOrder(i) + 1;
    
    for timestep = 1:size(mpcOutput(i).MPC,1)
        if ~iscell(mpcOutput(i).MPC)
            switch refl 
                case 1
                    numColumns = 6;
                case 2
                    numColumns = 9;
                case 3 
                    numColumns = 12;
                case 4
                    numColumns = 15;
            end
            app.timestepInfo(timestep).paaInfo(paaTx,paaRx).mpcs{tx,rx,refl} ...
                        = reshape(mpcOutput(i).MPC(timestep,:,:),[],numColumns);
         else
             app.timestepInfo(timestep).paaInfo(paaTx,paaRx).mpcs{tx,rx,refl} = [];
        end

    end
end

end


function extractNodePositionsInfo(app)
posOutput = readNodeJsonFile(sprintf('%s/NodePositions.json',...
    app.visualizerPath));

for timestep = 1:size(app.timestepInfo,2) 
    pos = zeros(size(posOutput,2),3);
    rot = zeros(size(posOutput,2),3);
    for i = 1:size(posOutput,2)
        pos(i,:) = posOutput(i).Position(timestep,:,:);
        if size(posOutput(i).Rotation,1)==size(app.timestepInfo,2)
           rot(i,:) = posOutput(i).Rotation(timestep,:,:);
        else
           rot(i,:) = posOutput(i).Rotation(1,:,:);
        end

    end
    app.timestepInfo(timestep).pos = pos;
    app.timestepInfo(timestep).rot = rot;

end

end

function setupPaas(app)

paaOutput = readPaaJsonFile(sprintf('%s/PAAPosition.json',...
    app.visualizerPath));

getPaaInfo = tabulate([paaOutput.Node]);

app.numPaas = getPaaInfo(:,2);

if app.numPaas < 1
    error('There should be at least 1 paa per node in the scenario')
end

end

function extractPaasInfo(app)

paaPosOutput = readPaaJsonFile(sprintf('%s/PAAPosition.json',...
    app.visualizerPath));
getPaaInfo = tabulate([paaPosOutput.Node]);
for timestep = 1:size(app.timestepInfo,2) 
    index  = 1;
    paaPos = cell(max(getPaaInfo(:,2)),size(getPaaInfo,1));
    paaOri = cell(max(getPaaInfo(:,2)),size(getPaaInfo,1));
    for iNode = 1:size(getPaaInfo,1)       
        for iPaa = 1:getPaaInfo(iNode,2)
            if size(paaPosOutput(index).Position,1)== size(app.timestepInfo,2)
                paaPos{iPaa,iNode} = paaPosOutput(index).Position(timestep,:,:);
            else
                paaPos{iPaa,iNode} = paaPosOutput(index).Position(1,:,:);
            end
            paaOri{iPaa,iNode} = reshape(paaPosOutput(index).Orientation,1,[]);

            index = index+1;
        end        
    end
    app.timestepInfo(timestep).paaPos = paaPos;
    app.timestepInfo(timestep).paaOri = paaOri; 

end

end