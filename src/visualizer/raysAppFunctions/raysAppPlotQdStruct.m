function raysAppPlotQdStruct(app, qd, direction)
%RAYSAPPPLOTQDSTRUCT Plot rays on AoA/AoD spheres
%
% INPUTS:
%- app: the app object
%- qd: a qd struct for a single timestep
%- direction: either 'aoa' or 'aod'
%
%SEE ALSO: READQDFILE


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

% spherical to cartesian coords
switch(direction)
    case 'aod'
        el = qd.AODEL;
        az = qd.AODAZ;
        ax = app.AodAxes;
        delete(app.aodPlotHandle)
        
    case 'aoa'
        el = qd.AOAEL;
        az = qd.AOAAZ;
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
normPathGain = (qd.Gain - app.powerLim(1)) / (app.powerLim(2) - app.powerLim(1));
normPathGain = min(normPathGain, 1);
normPathGain = max(normPathGain, 0);

s = normPathGain*20 + 1;
c = qd.Gain;

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