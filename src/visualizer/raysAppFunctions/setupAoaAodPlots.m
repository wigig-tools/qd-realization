function setupAoaAodPlots(app)
% Reference sphere
[sphX,sphY,sphZ] = sphere();
app.powerLim = [-120, -80];

privateSetupOnePlot(app, sphX, sphY, sphZ, app.AodAxes)
privateSetupOnePlot(app, sphX, sphY, sphZ, app.AoaAxes)

end


%% Utils
function privateSetupOnePlot(app, sphX, sphY, sphZ, ax)
surf(ax,...
    sphX,sphY,sphZ,...
    'LineStyle','none',...
    'FaceColor','k',...
    'FaceAlpha',0.1);
hold(ax, 'on')

colorbar(ax);
caxis(ax, app.powerLim)

axis(ax, 'equal')
lim = [-1,1] * 1.1;
xlim(ax,lim)
ylim(ax,lim)
zlim(ax,lim)

xlabel(ax,'x')
ylabel(ax,'y')
zlabel(ax,'z')

end