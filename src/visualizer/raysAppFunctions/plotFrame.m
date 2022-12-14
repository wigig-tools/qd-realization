function plotFrame(app)
%PLOTFRAME Plot the frame of the current timestamp


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

plotNodes(app)
plotRays(app)
if isfile(sprintf('%s/TargetPositions.json',app.visualizerPath)) && ...
        isfile(sprintf('%s/TargetMpc.json',app.visualizerPath))
    plotTargets(app)
    plotTargetRays(app)
end
plotQd(app,'aod')
plotQd(app,'aoa')
end

function plotTargets(app)
delete(app.targetsPlotHandle)
 
t = app.currentTimestep;
targetsPos = app.timestepInfo(t).targetPos;
targetIndex = app.timestepInfo(t).numTarget;

for iTarget = 1:length(targetIndex)
    dirFile = [app.visualizerPath,'/TargetConnection',...
            num2str(targetIndex(iTarget)),'.txt'];
    if isfile(dirFile) % human target with connections
    targetConnection = load(dirFile);
    targetPos = targetsPos((size(targetConnection,1)+1)*iTarget-(size(targetConnection,1)+1)+1 :...
        (size(targetConnection,1)+1)*(iTarget+1)-(size(targetConnection,1)+1),:); 
    for i = 1:size(targetConnection,1)
        app.targetsPlotHandle = [app.targetsPlotHandle; plot3(app.UIAxes,targetPos(targetConnection(i,:)+1,1),...
            targetPos(targetConnection(i,:)+1,2),...
            targetPos(targetConnection(i,:)+1,3),'Color','k','LineWidth',3)];
    end
    else % point target        
        app.targetsPlotHandle = scatter3(app.UIAxes,...
            targetsPos(:,1), targetsPos(:,2), targetsPos(:,3),10,'s',...
            'm', 'filled');
    end

end
end

function plotTargetRays(app)
delete(app.targetRaysPlotHandle)

refOrder = str2double(app.RefOrderDropdown.Value);
t = app.currentTimestep;
tx = app.txIndex;
rx = app.rxIndex;
paaTx = app.numPaas(tx);
paaRx = app.numPaas(rx);

for ipaatx = 1:paaTx
    for ipaarx = 1:paaRx
        
        timestepInfo = app.timestepInfo(t);
        if isempty(timestepInfo.targetInfo(tx,paaTx).mpcs) || refOrder == 0
            % no rays
            return
        else
%         [numTargets, numJoints] = size(timestepInfo.targetInfo(tx,paaTx).mpcs(1,:,1)); %size(timestepInfo.targetInfo(tx,paaTx).mpcs);
        [numTargets, numJoints, ~] = size(timestepInfo.targetInfo(tx,paaTx).mpcs);
        for iReflection = 1:refOrder
        coords= [];
        for iTarget = 1:numTargets
            for iJoint = 1:numJoints
                mpcs1 = timestepInfo.targetInfo(tx,paaTx).mpcs{iTarget,iJoint,iReflection};
                mpcs2 = timestepInfo.targetInfo(rx,paaRx).mpcs{iTarget,iJoint,iReflection};
                coords = [coords;mpcs1;mpcs2];
            end
        end
        
        app.targetRaysPlotHandle = [app.targetRaysPlotHandle;...
            plot3(app.UIAxes,...
            coords(:,1:3:end)',coords(:,2:3:end)',coords(:,3:3:end)',...
            '--','Color',[0 1 1],...
            'LineWidth',0.5)];
        end
        end
    end
end

end

function plotNodes(app)
delete(app.nodesPlotHandle)
delete(app.paaFrontTxPlotHandle)
delete(app.paaBackTxPlotHandle)
delete(app.paaFrontRxPlotHandle)
delete(app.paaBackRxPlotHandle)


t = app.currentTimestep;
tx = app.txIndex;
rx = app.rxIndex;
paaPosTx = cell2mat(app.timestepInfo(t).paaPos(:,tx));
paaPosRx = cell2mat(app.timestepInfo(t).paaPos(:,rx));
paaOriTx = cell2mat(app.timestepInfo(t).paaOri(:,tx));
paaOriRx = cell2mat(app.timestepInfo(t).paaOri(:,rx));
nodeRotTx = app.timestepInfo(t).rot(tx,:);
nodeRotRx = app.timestepInfo(t).rot(rx,:);

[app.paaFrontTxPlotHandle,app.paaBackTxPlotHandle] = plotPaa(app.UIAxes,...
    paaPosTx,paaOriTx,nodeRotTx);
[app.paaFrontRxPlotHandle,app.paaBackRxPlotHandle] = plotPaa(app.UIAxes,...
    paaPosRx,paaOriRx,nodeRotRx);

nodesPos = app.timestepInfo(t).pos([tx,rx],:);
app.nodesPlotHandle = scatter3(app.UIAxes,...
    nodesPos(:,1), nodesPos(:,2), nodesPos(:,3),100,'s',...
    'm', 'filled');

end

function plotRays(app)
delete(app.raysPlotHandle)

refOrder = str2double(app.RefOrderDropdown.Value) + 1;
t = app.currentTimestep;
tx = app.txIndex;
rx = app.rxIndex;
paaTx = app.numPaas(tx);
paaRx = app.numPaas(rx);
for ipaatx = 1:paaTx
    for ipaarx = 1:paaRx
        
        timestepInfo = app.timestepInfo(t);
        if isempty(timestepInfo.paaInfo(ipaatx,ipaarx).mpcs)
            % no rays
            return
        end
        % if and else loop to deal with discarded combinations in Mpc.json
        if size(timestepInfo.paaInfo(ipaatx,ipaarx).mpcs,1) >= tx
            mpcs = timestepInfo.paaInfo(ipaatx,ipaarx).mpcs(tx,rx,1:refOrder);
        else
            % use reverse rx/tx 
            mpcs = timestepInfo.paaInfo(ipaarx,ipaatx).mpcs(rx,tx,1:refOrder);
        end
        if all(cellfun(@isempty, mpcs))
            % use reverse rx/tx
            mpcs = timestepInfo.paaInfo(ipaarx,ipaatx).mpcs(rx,tx,1:refOrder);
        end

        for i = 1:length(mpcs)
            reflOrder = i - 1;

            coords = mpcs{i};
            [color, width] = getRayAspect(reflOrder);

            app.raysPlotHandle = [app.raysPlotHandle;...
                plot3(app.UIAxes,...
                coords(:,1:3:end)',coords(:,2:3:end)',coords(:,3:3:end)',...
                'Color',color,...
                'LineWidth',width)];
        end
    end
end

end

function plotQd(app, direction)

tx = app.txIndex;
rx = app.rxIndex;
t = app.currentTimestep;
numPaasTx = app.numPaas(tx);
numPaasRx = app.numPaas(rx);
timestampInfo = app.timestepInfo(t);
for ipaatx = 1:numPaasTx
    for ipaarx = 1:numPaasRx
        if isfield(timestampInfo.paaInfo(ipaatx,ipaarx),'qdInfo')
            if  ~isempty(timestampInfo.paaInfo(ipaatx,ipaarx).qdInfo)
                qd = timestampInfo.paaInfo(ipaatx,ipaarx).qdInfo(tx,rx);
                raysAppPlotQdStruct(app, qd, direction)
            else
                switch(direction)
                    case 'aoa'
                        delete(app.aoaPlotHandle)
                    case 'aod'
                        delete(app.aodPlotHandle)
                    otherwise
                        error('direction should be either ''aoa'' or ''aod''')
                end
            end
        else
            switch(direction)
                case 'aoa'
                    delete(app.aoaPlotHandle)
                case 'aod'
                    delete(app.aodPlotHandle)
                otherwise
                    error('direction should be either ''aoa'' or ''aod''')
            end
        end
    end
end

end

function [paaFrontNodePlotHandle,paaBackNodePlotHandle] = plotPaa(UIAxes,...
    paaLocation, paaOrientation, nodeRotation)
paaFrontNodePlotHandle = zeros(1,size(paaLocation,1));
paaBackNodePlotHandle = zeros(1,size(paaLocation,1));
rng(4); % Seed to fix the same PAA face color at each time instant
color =  rand(size(paaLocation,1),3);
for ipaa = 1:size(paaLocation,1)
    % Back Face
    left = paaLocation(ipaa,2) - 0.25;
    right = paaLocation(ipaa,2) + 0.25;
    bottom = paaLocation(ipaa,3) - 0.15;
    top = paaLocation(ipaa,3) + 0.15;
    y = [left left right right];
    z = [bottom top top bottom];
    x = zeros(size(y)) + paaLocation(ipaa,1);
    
    % Front Face where PAA is oriented
    x1 = zeros(size(y)) + paaLocation(ipaa,1) + 0.01;
    
    orientedPaa = coordinateRotation([x', y', z'; x1', y' z'],...
        paaLocation(ipaa,:), paaOrientation(ipaa,:)); 
 
    rotatedNode = coordinateRotation(orientedPaa, paaLocation(ipaa,:),...
        nodeRotation);
    paaBackNodePlotHandle(ipaa) = fill3(UIAxes,rotatedNode(1:4,1),...
        rotatedNode(1:4,2), rotatedNode(1:4,3),'k'); % Back Face
    paaFrontNodePlotHandle(ipaa) = fill3(UIAxes, rotatedNode(5:8,1),...
        rotatedNode(5:8,2), rotatedNode(5:8,3), color(ipaa,:));  % Front Face 
end

end

