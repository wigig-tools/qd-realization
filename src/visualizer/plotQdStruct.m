function plotQdStruct(qd, nodeType)

% spherical to cartesian coords
switch(nodeType)
    case 'Tx'
        el = qd.aodEl;
        az = qd.aodAz;
        
    case 'Rx'
        el = qd.aoaEl;
        az = qd.aoaAz;
        
    otherwise
        error('nodeType should be either ''Tx'' or ''Rx''')
        
end

r = 1;
x = r .* sind(el) .* cosd(az);
y = r .* sind(el) .* sind(az);
z = r .* cosd(el);

% Prepare power-related information
pathGainLims = [min(qd.pathGain), max(qd.pathGain)];
normPathGain = (qd.pathGain - pathGainLims(1)) / (pathGainLims(2) - pathGainLims(1));

s = normPathGain*20 + 1;
c = qd.pathGain;

%% Plot
figure
% Reference sphere
[sphX,sphY,sphZ] = sphere();
surf(sphX,sphY,sphZ,...
    'LineStyle','none',...
    'FaceColor','k',...
    'FaceAlpha',0.2)
hold on

% Rays
scatter3(x,y,z,s,c)
hold off

% Visual improvements
colorbar
caxis(pathGainLims)

axis equal
lim = [-1,1] * 1.5;
xlim(lim)
ylim(lim)
zlim(lim)

xlabel('x')
ylabel('y')
zlabel('z')

end