function setupAoaAodPlots(app)
%SETUPAOAAODPLOTS Prepare spheres for AoA/AoD plots


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