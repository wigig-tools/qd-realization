function raysAppPlotRoom(app)
%RAYSAPPPLOTROOM Plot room coordinates


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

% Delete current room
delete(app.roomPlotHandle)

% Prepare data
path = sprintf('%s/RoomCoordinates.csv', app.visualizerPath);

roomCoords = readRoomCoordinates(path);
[Tri,X,Y,Z] = roomCoords2triangles(roomCoords); % triangle vertices

% trisurf cannot plot directly to specified UIAxes
% Plot on a new figure and copy the Patch object to UIAxes instead
fig = figure('Visible','off');
trisurf(Tri,X,Y,Z,...
    'FaceColor',[0.9,0.9,0.9],...
    'FaceAlpha',0.1,...
    'EdgeColor','k')
app.roomPlotHandle = copyobj(get(gca,'Children'),app.UIAxes);
close(fig)

% activate 3D rotations
view(app.UIAxes, [45,45])

app.UIAxes.XLabel.String = 'x [m]';
app.UIAxes.YLabel.String = 'y [m]';
app.UIAxes.ZLabel.String = 'z [m]';

axis(app.UIAxes, 'equal')

% Do not overwrite plot from now on
hold(app.UIAxes,'on')

end