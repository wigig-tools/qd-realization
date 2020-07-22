function [cadData, switchMaterial] = importObjFile(file, materialLibrary,...
    referencePoint, r)
%IMPORTOBJFILE Import OBJ file format as specified by the ray-tracer
%
% INPUTS:
%- file: path to OBJ file
%- materialLibrary: table material library
%- referencePoint: unused
%- r: unused
%
% OUTPUTS:
%- cadData: matrix containing CAD data. Rows represent faces of triangles,
%the first 9 columns represent vertex coordinates, the next 4 the plane
%equation (with normalized normal vectors), the last the materialLibrary
%index
%- switchMaterial: 1 (true) if all materials have been associated to the
%material library, associating OBJ's 'usemtl' to materialLibrary.Reflector.
%Currently, an error is thrown if not all materials are found.

objOut = objFileReader(file);
nFaces = length(objOut.face);

% Pre-allocate cadData matrix
cadData = nan(nFaces, 3*3 + 4 + 1);
switchMaterial = 1;
for i = 1:nFaces
    face = objOut.face(i);
    
    % face vertices
    p1 = objOut.v(face.vIdx(1), :);
    p2 = objOut.v(face.vIdx(2), :);
    p3 = objOut.v(face.vIdx(3), :);
    
    % face normal
    if all(face.vnIdx == face.vnIdx(1))
        vn = objOut.vn(face.vnIdx(1), :);
        vn = vn / norm(vn); % normalize
    else
        switchMaterial = 0;
        error('Unexpected condition: vertex normals are not all equal for face ID %d', i)
    end
    
    % constant of plane equation
    d = -vn * p1.';
    
    % face material
    materialIdx = find(strcmp(materialLibrary.Reflector, face.materialName));
    if isempty(materialIdx)
        error('Material ''%s'' not found in materialLibrary', face.materialName)
    end
    
    cadData(i, :) = [p1, p2, p3, vn, d, materialIdx];
end

end


%% UTILS
function objOut = objFileReader(file)
%OBJFILEREADER Import OBJ file with the required features. Only vertices
%and triangle faces are supported.
%
% INPUTS:
%- file: path to the OBJ file
%
% OUTPUTS:
%- objOut: structure with fields 'v', and 'face'. Field 'v' is an Nx3
%array containing vertices' coordinates. Field 'face' is a struct with
%fields 'vIdx', 'vnIdx' and 'materialName'. Field 'vIdx' is a vector with
%indices indicating which vertices the face includes. Field 'vnIdx' is a
%vector with indices indicationg the vertex normals. Field 'materialName'
%contains an array of char indicating the face material.


fid = fopen(file);
assert(fid ~= -1, 'file ''%s'' could not be opened', file)

objOut = struct();

i = 1;
vIdx = 1;
vnIdx = 1;
faceIdx = 1;
currentMaterialName = '';
while ~feof(fid)
    line = fgetl(fid);
    elem = split(line, ' ');
    
    switch(elem{1})
        case '#'
            % Comment: ignore it
            
        case 'v'
            % Vertex with (x, y, z [,w]) coordinates, w is optional and
            % defaults to 1.0.
            objOut.v(vIdx, :) = cellfun(@str2double, elem(2:4)).';
            vIdx = vIdx + 1;
            
        case 'vt'
            % Texture coordinates in (u, [,v ,w]) coordinates, these will
            % vary between 0 and 1. v, w are optional and default to 0.
            %
            % Not used, ignore
            
        case 'vn'
            % Normals in (x,y,z) form; normals might not be unit vectors.
            objOut.vn(vnIdx, :) = cellfun(@str2double, elem(2:4)).';
            vnIdx = vnIdx + 1;
            
        case 'vp'
            % Parameter space vertices in ( u [,v] [,w] ) form;
            % free form geometry statement
            %
            % Not used, ignore
            
        case 'f'
            % Polygon face elements
            % Check if triangle: 'f' + 3 elements
            assert(length(elem) == 4, ['Invalid polygon face element ''%s''. '...
                'Only triangles are supported'], line)
            
            % extract vertices/texture coords/normals
            v = nan(1, length(elem)-1);
            vn = nan(1, length(elem)-1);
            for i = 2:length(elem)
                faceElem = split(elem{i}, '/');
                % vertex index
                v(i-1) = str2double(faceElem{1});
                % ignore texture coords
                % normal index
                vn(i-1) = str2double(faceElem{3});
            end
            
            objOut.face(faceIdx).vIdx = v;
            objOut.face(faceIdx).vnIdx = vn;
            objOut.face(faceIdx).materialName = currentMaterialName;
            
            faceIdx = faceIdx + 1;
            
        case 'l'
            % Line element
            %
            % Not used, ignore
            
        case 'mtllib'
            % External MTL (MaTerial Library) file
            %
            % Not used, ignore
            
        case 'usemtl'
            currentMaterialName = strjoin(elem(2:end));
            
        case 'o'
            % Object name
            %
            % Not used, ignore
            
        case 'g'
            % Group name
            %
            % Not used, ignore
            
        case 's'
            % Smooth shading
            %
            % Not used, ignore
            
        otherwise
            warning('Line %d begins with ''%s''', i, elem{1})
            
    end
    
    i = i + 1;
end

fclose(fid);
end