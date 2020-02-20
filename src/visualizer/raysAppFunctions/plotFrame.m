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

plotNodes(app)
plotRays(app)
plotQd(app,'aod')
plotQd(app,'aoa')
end


function plotNodes(app)
delete(app.nodesPlotHandle)

t = app.currentTimestep;
tx = app.txIndex;
rx = app.rxIndex;

pos = app.timestepInfo(t).pos([tx,rx],:);

app.nodesPlotHandle = scatter3(app.UIAxes,...
    pos(:,1), pos(:,2), pos(:,3),...
    'k', 'filled');

end

function plotRays(app)
delete(app.raysPlotHandle)

t = app.currentTimestep;
tx = app.txIndex;
rx = app.rxIndex;

timestepInfo = app.timestepInfo(t);
if isempty(timestepInfo.mpcs)
    % no rays
    return
end

mpcs = timestepInfo.mpcs(tx,rx,:);
if all(cellfun(@isempty, mpcs))
    % use reverse rx/tx
    mpcs = timestepInfo.mpcs(rx,tx,:);
end

for i = 1:length(mpcs)
    relfOrder = i - 1;
    
    coords = mpcs{i};
    [color, width] = getRayAspect(relfOrder);
    
    app.raysPlotHandle = [app.raysPlotHandle;...
        plot3(app.UIAxes,...
        coords(:,1:3:end)',coords(:,2:3:end)',coords(:,3:3:end)',...
        'Color',color,...
        'LineWidth',width)];
end
end


function plotQd(app,direction)

Tx = app.txIndex;
Rx = app.rxIndex;
t = app.currentTimestep;

timestampInfo = app.timestepInfo(t);
if ~isempty(timestampInfo.qdInfo)
    qd = timestampInfo.qdInfo(Tx,Rx);
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