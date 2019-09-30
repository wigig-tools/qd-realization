function raysAppPlotRoom(app)

% Delete current room
delete(app.roomPlotHandle)

% Prepare data
path = sprintf('%s/RoomCoordinates/RoomCoordinates.csv', app.visualizerPath);

roomCoords = readRoomCoordinates(path);
[Tri,X,Y,Z] = roomCoords2triangles(roomCoords); % triangle vertices

% trisurf cannot plot directly to specified UIAxes
% Plot on a new figure and copy the Patch object to UIAxes instead
fig = figure('Visible','off');
trisurf(Tri,X,Y,Z,...
    'FaceColor',[0.9,0.9,0.9],...
    'FaceAlpha',0.5,...
    'EdgeColor','k')
app.roomPlotHandle = copyobj(get(gca,'Children'),app.UIAxes);
close(fig)

% activate 3D rotations
view(app.UIAxes, [45,45])

app.UIAxes.XLabel.String = 'x';
app.UIAxes.YLabel.String = 'y';
app.UIAxes.ZLabel.String = 'z';

% Do not overwrite plot from now on
hold(app.UIAxes,'on')

end