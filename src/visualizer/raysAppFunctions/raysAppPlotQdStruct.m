function raysAppPlotQdStruct(app, qd, direction)

% spherical to cartesian coords
switch(direction)
    case 'aod'
        el = qd.aodEl;
        az = qd.aodAz;
        ax = app.AodAxes;
        delete(app.aodPlotHandle)
        
    case 'aoa'
        el = qd.aoaEl;
        az = qd.aoaAz;
        ax = app.AoaAxes;
        delete(app.aoaPlotHandle)
        
    otherwise
        error('direction should be either ''aoa'' or ''aod''')
end

r = 1;
x = r .* sind(el) .* cosd(az);
y = r .* sind(el) .* sind(az);
z = r .* cosd(el);

% Prepare power-related information
normPathGain = (qd.pathGain - app.powerLim(1)) / (app.powerLim(2) - app.powerLim(1));
normPathGain = min(normPathGain, 1);
normPathGain = max(normPathGain, 0);

s = normPathGain*20 + 1;
c = qd.pathGain;

%% Plot
% Rays
scatterPlot = scatter3(ax,...
    x,y,z,...
    s,c);

switch(direction)
    case 'aoa'
        app.aoaPlotHandle = scatterPlot;
    case 'aod'
        app.aodPlotHandle = scatterPlot;
    otherwise
        error('direction should be either ''aoa'' or ''aod''')
end
        

% Viewing angle
viewAngle = app.UIAxes.View;
if any(viewAngle ~= ax.View)
    % Avoid costly operation if possible
    view(ax, viewAngle(1), viewAngle(2))
end

end