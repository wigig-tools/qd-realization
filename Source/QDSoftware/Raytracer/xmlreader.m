% -------------Software Disclaimer---------------
%
% NIST-developed software is provided by NIST as a public service. You may use, copy
% and distribute copies of the software in any medium, provided that you keep intact this
% entire notice. You may improve, modify and create derivative works of the software or
% any portion of the software, and you may copy and distribute such modifications or
% works. Modified works should carry a notice stating that you changed the software
% and should note the date and nature of any such change. Please explicitly
% acknowledge the National Institute of Standards and Technology as the source of the
% software.
%
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
% OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
% WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
% NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS
% NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE
% UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE
% CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF,
% INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
% RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% anddistributing the software and you assume all risks associated with its use, including
% but not limited to the risks and costs of program errors, compliance with applicable
% laws, damage to or loss of data, programs or equipment, and the unavailability or
% interruption of operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property. The software
% developed by NIST employees is not subject to copyright protection within the United
% States.


%XML redaer extracts the information of CAD file (AMF). The input of the
%function is filename, the material database with all the material
%parameters (Material_library), reference point (referencePoint) and distance limitation(r)
%The output is extracted triangles (CADop), number of rows in CADop
%(count_rows), and a boolean to know whether the material information is
%present in the CAD file (switch1)

function [CADOutput,countRows,switch1]=xmlreader(filename,MaterialLibrary,referencePoint,r,IndoorSwitch)
[ s ] = xml2struct( filename );
switch1=1;
%% Probing whether material information is present or not

try
    materials=s.amf.material;
catch
    switch1=0;
end

if switch1==1
    sizeMaterials1=size(s.amf.material');
    if sizeMaterials1(2)>1 &&  sizeMaterials1(1)==1
        sizeMaterials = sizeMaterials1;
    else
        sizeMaterials = sizeMaterials1(1);
    end
end
%% Iterating through all the subdivisions (volumes) and extracting the triangle information

volume=s.amf.object.mesh.volume';
countRows=1;
sizeVolume=size(volume);
for iterateVolume=1:size(volume)
    if sizeVolume(1)~=1
        triangles=s.amf.object.mesh.volume{1,iterateVolume}.triangle';
    else
        triangles=s.amf.object.mesh.volume.triangle';
    end
    % vertices=s.amf.mesh.vertices.vertex;
    if switch1==1
        if sizeVolume(1)~=1
            materialid=s.amf.object.mesh.volume{1,iterateVolume}.Attributes.materialid;
        else
            materialid=s.amf.object.mesh.volume.Attributes.materialid;
        end
        % materialid=s.amf.object.mesh.volume{1,j}.Attributes.materialid;
        for iterateMaterials=1:sizeMaterials
            if sizeMaterials~=1
                if str2num(materialid)==str2num(s.amf.material{1,iterateMaterials}.Attributes.id)
                    Material=s.amf.material{1,iterateMaterials}.metadata.Text;
                end
            elseif sizeVolume(1)==1 && sizeMaterials == 1
                if str2num(materialid)==str2num(s.amf.material.Attributes.id)
                    Material=s.amf.material.metadata.Text;
                    
                end
            end
        end
    end
    %% Extracting the vertices information of the triangles
    
    sizeTriangle=size(triangles);
    for iterateTriangles=1:sizeTriangle(1)
        indexCADOutput=countRows;%((j-1)*size_triangle(1))+i;
        if sizeVolume(1)~=1
            vertex1=str2num(s.amf.object.mesh.volume{1,iterateVolume}.triangle{1,iterateTriangles}.v1.Text)+1;
        else
            vertex1=str2num(s.amf.object.mesh.volume.triangle{1,iterateTriangles}.v1.Text)+1;
        end
        %     vertex1=str2num(s.amf.object.mesh.volume{1,j}.triangle{1,i}.v1.Text)+1;
        x1=str2num(s.amf.object.mesh.vertices.vertex{1,vertex1}.coordinates.x.Text);
        y1=str2num(s.amf.object.mesh.vertices.vertex{1,vertex1}.coordinates.y.Text);
        z1=str2num(s.amf.object.mesh.vertices.vertex{1,vertex1}.coordinates.z.Text);
        
        if sizeVolume(1)~=1
            vertex2=str2num(s.amf.object.mesh.volume{1,iterateVolume}.triangle{1,iterateTriangles}.v2.Text)+1;
        else
            vertex2=str2num(s.amf.object.mesh.volume.triangle{1,iterateTriangles}.v2.Text)+1;
        end
        %     vertex2=str2num(s.amf.object.mesh.volume{1,j}.triangle{1,i}.v2.Text)+1;
        x2=str2num(s.amf.object.mesh.vertices.vertex{1,vertex2}.coordinates.x.Text);
        y2=str2num(s.amf.object.mesh.vertices.vertex{1,vertex2}.coordinates.y.Text);
        z2=str2num(s.amf.object.mesh.vertices.vertex{1,vertex2}.coordinates.z.Text);
        
        if sizeVolume(1)~=1
            vertex3=str2num(s.amf.object.mesh.volume{1,iterateVolume}.triangle{1,iterateTriangles}.v3.Text)+1;
        else
            vertex3=str2num(s.amf.object.mesh.volume.triangle{1,iterateTriangles}.v3.Text)+1;
        end
        %     vertex3=str2num(s.amf.object.mesh.volume{1,j}.triangle{1,i}.v3.Text)+1;
        x3=str2num(s.amf.object.mesh.vertices.vertex{1,vertex3}.coordinates.x.Text);
        y3=str2num(s.amf.object.mesh.vertices.vertex{1,vertex3}.coordinates.y.Text);
        z3=str2num(s.amf.object.mesh.vertices.vertex{1,vertex3}.coordinates.z.Text);
        %% Calculating the plane equation of triangles
        
        vector1 = [x2,y2,z2] - [x3,y3,z3];
        vector2 = -([x2,y2,z2] - [x1,y1,z1]);
        % Multiply with -1 for 'example.xml', 'sphere.xml','material_prism.xml'
        normal=1*crossproduct(vector2,vector1)*(1-(2*IndoorSwitch));
        normal=round(normal./(magnitudeOfThreePoints(normal(1),normal(2),normal(3))),4);
        vector3=[x2,y2,z2];
        %for box. remove for others
        
        D=-1*dot(normal,vector3);
        %% Storing Material information in output if the material exists in the material database
        
        if switch1==1
            sizeMaterialLibrary=size(MaterialLibrary);
            switch2=0;
            for iterateMaterials=1:sizeMaterialLibrary(1)
                if strcmp(lower(char(MaterialLibrary{iterateMaterials,2})),lower(Material))
                    CADOutput(indexCADOutput,14)=str2num(char(MaterialLibrary{iterateMaterials,1}));
                    switch2=1;
                end
            end
            
            %     if switch2==0
            %         msgID = 'MYFUN:incorrectMaterial';
            %         msg = 'The materials in the file donot match with Material Library. Please create those materials in Material Library.';
            %         causeException2 = MException(msgID,msg);
            % %         baseException = addCause(baseException,causeException2);
            %         throw(causeException2)
            %     end
            
            %% Storing triangle vertices and plane equations in output
            %Part where output file is created. It contains the triangle vertices
            %in first nine columns, plane equations in the next four columns
            
            if switch2==0
                switch1=0;
            end
            
            
        end
        CADOutput(indexCADOutput,1)=round(x1,6);
        CADOutput(indexCADOutput,2)=round(y1,6);
        CADOutput(indexCADOutput,3)=round(z1,6);
        CADOutput(indexCADOutput,4)=round(x2,6);
        CADOutput(indexCADOutput,5)=round(y2,6);
        CADOutput(indexCADOutput,6)=round(z2,6);
        CADOutput(indexCADOutput,7)=round(x3,6);
        CADOutput(indexCADOutput,8)=round(y3,6);
        CADOutput(indexCADOutput,9)=round(z3,6);
        CADOutput(indexCADOutput,10)=round(normal(1),4);
        CADOutput(indexCADOutput,11)=round(normal(2),4);
        CADOutput(indexCADOutput,12)=round(normal(3),4);
        CADOutput(indexCADOutput,13)=round(D,4);

        %We are using distance limitation at this step
        
        if r==0
            [switchDistance] = 1;
        else
            [switchDistance] = verifydistance(r,referencePoint,CADOutput,indexCADOutput);
        end
        %If the triangles are within the given distance we increase the count,
        %else the next triangle will replace the present row (as count remains constant)
        
        if switchDistance==1
            countRows=countRows+1;
        end
    end
end
countRows=countRows-1;