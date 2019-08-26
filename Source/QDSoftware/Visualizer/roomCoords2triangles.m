function [Tri,X,Y,Z] = roomCoords2triangles(roomCoords)
nTriangles = size(roomCoords,1);

X=roomCoords(:,1:3:end)';
Y=roomCoords(:,2:3:end)';
Z=roomCoords(:,3:3:end)';

Tri = reshape(1:nTriangles*3, 3, [])';

end