function plotFrame(app)
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
    coords = mpcs{i};
    
    color = app.rayColors(i,:);
    width = app.rayWidth(i);
    
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