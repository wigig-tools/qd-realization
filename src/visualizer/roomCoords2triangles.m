function [Tri,X,Y,Z] = roomCoords2triangles(roomCoords)
%ROOMCOORDS2TRIANGLES Takes Nx9 matrix containing he three vertices per
%face of each of the N triangles composing the environment and turns it
%into coordinates compatible for plotting (trisurf function).
%
% INPUTS:
%- roomCoords: Nx9 matrix. Columns represent respectively
%[x1,y1,z1,x2,y2.z2.x3.y3.z3] of the N triangles composing the scene.
%
% OUTPUTS:
%- Tri: Nx3 matrix with indices indicating the coordinates for the 3
%vertices of the N faces
%- X,Y,Z: 3xN coordinates of the vertices
%
%SEE ALSO: TRISURF


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

nTriangles = size(roomCoords,1);

X=roomCoords(:,1:3:end)';
Y=roomCoords(:,2:3:end)';
Z=roomCoords(:,3:3:end)';

Tri = reshape(1:nTriangles*3, 3, [])';

end