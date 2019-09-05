function raysAppPlotRoom(app)

% Delete current content
ch = get(app.UIAxes,'Children');

for  i = 1:length(ch)
    delete(ch(i))
end

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
copyobj(get(gca,'Children'),app.UIAxes)
close(fig)

% activate 3D rotations
view(app.UIAxes, [45,45])

app.UIAxes.XLabel.String = 'x';
app.UIAxes.YLabel.String = 'y';
app.UIAxes.ZLabel.String = 'z';

end