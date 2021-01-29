function [ArrayOfPoints, ArrayOfPlanes, numberOfPlanes,...
    pointIndexOfPresentIteration, planeIndexofPresentIteration,...
    arrayOfMaterials, indexMaterials] = treetraversal(CADop,...
    totalNumberOfReflections, numberOfReflections,...
    previousIterationRowNumber, numberOfPlanes, pointIndexOfPresentIteration,...
    planeIndexofPresentIteration, Rx, Tx, ArrayOfPoints, ArrayOfPlanes,...
    switchMaterial, arrayOfMaterials, indexMaterials)
% Treetraversal generates all plane combinations for nth order reflections
% using backtracking (special case of DFS).
%
% Refer to "treetraversal - Backtracking algorithm. ppt". The ppt has a
% slide show. Each step is explained in the notes.
%
% Outputs:
% Array_of_points- combinations of multiple triangles, every row is a unique
% combination. every triangle occupies 9 columns (3 vertices).
% Array_of_planes- Similar to Array of points. Each triangle occupies 4 
% columns (plane equation). The first column has the order of reflection
% pointIndexOfPresentIteration- keeps track of the column where the data 
% (vertices of triangles) should be inserted
% planeIndexofPresentIteration- similar to index but data is plane equations.
% index_materials- similar to index but data is materials.
%
% Inputs:
% CADop- points and plane equations from CAD file
% number_of_R- order of reflection
% previousIterationRowNumber- row of CADop from previous recursion. For the 
% first traversal the value is zero.
% numberOfPlanes- number of rows in the Array_of_planes and Array_of_points
% Rx- Rx location
% Tx-Tx location
% switchMaterial- whether triangle materials properties are present
% array_of_materials- Similar to Array of points. Each triangle occupies 1
% triangle. The data is the row number of material from Material library


%--------------------------Software Disclaimer-----------------------------
%
% NIST-developed software is provided by NIST as a public service. You may 
% use, copy and distribute copies of the software in any medium, provided 
% that you keep intact this entire notice. You may improve, modify and  
% create derivative works of the software or any portion of the software, 
% and you  may copy and distribute such modifications or works. Modified 
% works should carry a notice stating that you changed the software and  
% should note the date and nature of any such change. Please explicitly  
% acknowledge the National Institute of Standards and Technology as the 
% source of the software.
% 
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION  
% OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND 
% DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF 
% THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS 
% WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS  
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT 
% NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF 
% THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% and distributing the software and you assume all risks associated with  
% its use, including but not limited to the risks and costs of program 
% errors, compliance with applicable laws, damage to or loss of data, 
% programs or equipment, and the unavailability or interruption of 
% operation. This software is not intended to be used in any situation  
% where a failure could cause risk of injury or damage to property. The 
% software developed by NIST employees is not subject to copyright 
% protection within the United States.


numberTemporary = numberOfPlanes;
iterateCount = 0;

% Loop to iterate through all the triangle in CADop
for iterateNumberofRows = 1:size(CADop,1)
    % To protect the information in indices from being lost, it is
    % transfered to temporary parameters
    indexPlanesTemporary = planeIndexofPresentIteration;
    indexTemporary = pointIndexOfPresentIteration;
    indexMaterialsTemporary = indexMaterials;
    % given that the previous plane is not the same as present plane and number of reflection is greater than 1
    if (iterateNumberofRows ~= previousIterationRowNumber && numberOfReflections > 1)
        % Transfering the information of triangles from CADop to Array_of_points
        ArrayOfPoints(numberOfPlanes,indexTemporary:indexTemporary + 8) = CADop(iterateNumberofRows,1:9);
        
        % Transfering the information of triangles from CADop to
        % Array_of_planes, given that this is not first traversal. because
        % the first column is order of reflection, we need to add that
        % information to array of planes before any information
        if previousIterationRowNumber == 0
            % Extracting information of plane equations from CADop and storing
            % it as an array, plane1
            plane1=CADop(iterateNumberofRows,10:13);
            
            % Extracting information of normal vector of a plane from plane1
            % array and storing it as an array, normalPlane1
            normalPlane1 = plane1(1:3);
            
            % Extracting information of points and storing it as three distinct
            % points - point11, Point12, point13
            Point1Plane1 = ArrayOfPoints(numberOfPlanes,indexTemporary:indexTemporary + 2);
            Point2Plane1 = ArrayOfPoints(numberOfPlanes,indexTemporary + 3:indexTemporary + 5);
            Point3Plane1 = ArrayOfPoints(numberOfPlanes,indexTemporary + 6:indexTemporary + 8);
            
            % the first column is information of order of reflection
            ArrayOfPlanes(numberOfPlanes,indexPlanesTemporary) = totalNumberOfReflections;
            indexPlanesTemporary = indexPlanesTemporary + 1;
            
            % for condition1 see verify_treetraversal
            scenario = -1;
            
            % checking whether a path exists between the plane and Tx
            booleanPathExistence = 1;
            if booleanPathExistence == 1
                ArrayOfPlanes(numberOfPlanes,...
                    indexPlanesTemporary:indexPlanesTemporary + 3) = CADop(iterateNumberofRows,10:13);
            end
            
        else
            ArrayOfPlanes(numberOfPlanes,...
                indexPlanesTemporary:indexPlanesTemporary + 3) = CADop(iterateNumberofRows,10:13);
            plane1 = ArrayOfPlanes(numberOfPlanes,...
                indexPlanesTemporary:indexPlanesTemporary + 3);
            
            normalPlane1 = plane1(1:3);
            
            Point1Plane1 = ArrayOfPoints(numberOfPlanes,indexTemporary:indexTemporary + 2);
            Point2Plane1 = ArrayOfPoints(numberOfPlanes,indexTemporary + 3:indexTemporary + 5);
            Point3Plane1 = ArrayOfPoints(numberOfPlanes,indexTemporary + 6:indexTemporary + 8);
            
            % for condition1 see verify_treetraversal
            scenario = 0;
            
            % plane2, point21, point22, point23 correspond to previous planes
            % and points in Array_of_planes and Array_of_points
            plane2 = ArrayOfPlanes(numberOfPlanes,indexPlanesTemporary - 4:indexPlanesTemporary - 1);
            normal2 = plane2(1:3);
            point1Plane2 = ArrayOfPoints(numberOfPlanes,indexTemporary - 9:indexTemporary - 7);
            point2Plane2 = ArrayOfPoints(numberOfPlanes,indexTemporary - 6:indexTemporary - 4);
            point3Plane2 = ArrayOfPoints(numberOfPlanes,indexTemporary - 3:indexTemporary - 1);
            
            % checking whether a path exists between the plane1 and plane2
              booleanPathExistence = 1;
        end
        
        if booleanPathExistence == 0
            if previousIterationRowNumber == 0
                indexPlanesTemporary = indexPlanesTemporary - 1;
            end
            continue
            
        else
            indexPlanesTemporary = indexPlanesTemporary + 4;
            indexTemporary = indexTemporary + 9;
            if switchMaterial == 1
                arrayOfMaterials(numberOfPlanes,indexMaterialsTemporary) = CADop(iterateNumberofRows,14);
                indexMaterialsTemporary = indexMaterialsTemporary + 1;
            end
            
        end
        
        % When a combination is possible recursion is performed in this step
        if booleanPathExistence == 1
            % This chunk of code replicates the previous traversal information
            % (DFS) if the traversal changes course. For example 1->3->2->3,
            % needs to copy the part, 1->3->2 for 1->3->2->4.
            if(iterateCount>0 && numberOfPlanes>1 && previousIterationRowNumber ~= 0)
                for j = 1:pointIndexOfPresentIteration - 1
                    ArrayOfPoints(numberOfPlanes,j) = ArrayOfPoints(numberOfPlanes - 1,j);
                end
                
                for j = 1:planeIndexofPresentIteration - 1
                    ArrayOfPlanes(numberOfPlanes,j) = ArrayOfPlanes(numberOfPlanes - 1,j);
                end
                
                if switchMaterial == 1
                    for j = 1:indexMaterials - 1
                        arrayOfMaterials(numberOfPlanes,j) = arrayOfMaterials(numberOfPlanes - 1,j);
                    end
                end
                
            end
            
            iterateCount = iterateCount + 1;
            [ArrayOfPoints,ArrayOfPlanes,numberOfPlanes,indexTemporary,...
                indexPlanesTemporary,arrayOfMaterials,...
                indexMaterialsTemporary] = treetraversal(CADop,...
                totalNumberOfReflections, numberOfReflections - 1,iterateNumberofRows,...
                numberOfPlanes,indexTemporary,indexPlanesTemporary,Rx,Tx,...
                ArrayOfPoints,ArrayOfPlanes,...
                switchMaterial,arrayOfMaterials,indexMaterialsTemporary);
        end
    end
    
    %% given that the previous plane is not the same as present plane and number of reflection is equal to 1
    if (numberOfReflections == 1 && iterateNumberofRows ~= previousIterationRowNumber)
        scenario = 0;
        
        % This chunk of code replicates the previous traversal information
        % (DFS) if the traversal changes course. For example 1->3->2->3,
        % needs to copy the part, 1->3->2 for 1->3->2->4.
        if(iterateNumberofRows>1)
            for j = 1:pointIndexOfPresentIteration - 1
                ArrayOfPoints(numberTemporary,j) = ArrayOfPoints(numberOfPlanes,j);
            end
            
            for j = 1:planeIndexofPresentIteration - 1
                ArrayOfPlanes(numberTemporary,j) = ArrayOfPlanes(numberOfPlanes,j);
            end
            
            if switchMaterial == 1
                for j = 1:indexMaterials - 1
                    arrayOfMaterials(numberTemporary,j) = arrayOfMaterials(numberOfPlanes,j);
                end
            end
            
        end
        
        % Extracting information of vertices of triangle from CADop and storing
        % it as 3 distinct arrays, point11, point12, point13
        Point1Plane1 = CADop(iterateNumberofRows, 1:3);
        Point2Plane1 = CADop(iterateNumberofRows, 4:6);
        Point3Plane1 = CADop(iterateNumberofRows, 7:9);
        
        % Extracting information of plane equations from CADop and storing
        % it as an array, plane1
        plane1 = CADop(iterateNumberofRows, 10:13);
        
        % In case the total order of reflection is 1, we have plane2=plane1
        % else we extract previous plane equation and store it in plane2
        if previousIterationRowNumber == 0
            plane2 = plane1;
            
        else
            plane2 = ArrayOfPlanes(numberOfPlanes,...
                indexPlanesTemporary - 4:indexPlanesTemporary - 1);
            
        end
        
        normalPlane1 = plane1(1:3);
        booleanPathExistence = 0;
        
        if previousIterationRowNumber == 0
            scenario = 1;
            booleanPathExistence = 1;
            
            if booleanPathExistence == 1
                ArrayOfPlanes(numberTemporary,indexPlanesTemporary) = numberOfReflections;
                indexPlanesTemporary = indexPlanesTemporary + 1;
            end
        end
        
        % Verifying whther path exists between plane and Rx
        if ((previousIterationRowNumber ~= 0 || (booleanPathExistence == 1 && previousIterationRowNumber == 1)) && ...
                totalNumberOfReflections > 1) || (totalNumberOfReflections == 1 && booleanPathExistence == 1)
            scenario = 1;
            booleanPathExistence = 1;
            
            
        end
        
        if booleanPathExistence == 1
            ArrayOfPoints(numberTemporary,indexTemporary:indexTemporary + 8) = CADop(iterateNumberofRows,1:9);
            ArrayOfPlanes(numberTemporary,indexPlanesTemporary:indexPlanesTemporary + 3) = CADop(iterateNumberofRows,10:13);
            
            if switchMaterial == 1
                arrayOfMaterials(numberTemporary,indexMaterialsTemporary) = CADop(iterateNumberofRows,14);
            end
            
            iterateCount = iterateCount + 1;
            numberTemporary = numberTemporary + 1;
            
        end
    end
end

% After all interations that occur for first order reflections or last
% itertion of an nth order reflection the count is increased

if (numberOfReflections == 1)
    numberOfPlanes = numberTemporary;
end

end