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

% Updated by: Neeraj Varshney <neeraj.varshney@nist.gov> for JSON format, 
% node rotation and paa orientation

plotNodes(app)
plotRays(app)
plotQd(app,'aod')
plotQd(app,'aoa')
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
        if ~isempty(timestampInfo.paaInfo(ipaatx,ipaarx).qdInfo)
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

