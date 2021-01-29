function [booleanMultipathExistance, Intersection, directionOfDeparture,...
    directionOfArrival, multipath, distance, dopplerFactor, ...
     velocityTemporary] =...
    singleMultipathGenerator(iterateNumberOfRowsArraysOfPlanes,...
    orderOfReflection, indexMultipath, ArrayOfPlanes, ArrayOfPoints,...
    ReflectedPoint, Rx, Tx, CADOutput, multipath, indexOrderOfReflection,...
    velocityTx, velocityRx)
% Refer to http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=6503917&isnumber=6503052
% Refer to "singleMultipathGenerator - Method of Images. ppt". The ppt has a slide show. Each
% step is explained in the notes
%INPUT:
%iterateNumberOfRowsArraysOfPlanes - number of row of Array_of_planes/Array_of_points for which
%multipath has to be generated (o/p of multipath)
%orderOfReflection - order of reflection
%indexMultipath
%indexOrderOfReflection - order within recursion. recursion occurs for a number equal
%to order_of_R
%Array_of_planes - Similar to Array of points. Each triangle occupies 4
%columns (plane equation). The first column has the order of reflection
%(o/p of treetraversal)
%Array_of_points - combinations of multiple triangles, every row is a unique
%combination. every triangle occupies 9 columns (3 vertices). (o/p of
%treetraversal)
%ReflectedPoint - reflected image of Tx
%Rx - Rx position
%Tx - Tx position
%CADop - CAD output
%multipath - vectors and points of intersection of multipath
%vtx, vrx are velocities of tx and rx respectively
%switch_cp - a boolean to describe whether cross polarization is selected

%
% OUTPUTS:
% booleanMultipathExistance - whether multipath exists
% Intersection - intersection of multipath vector to plane
% dod - direction of departure
% doa - direction of arrival
% multipath
% distance - total length of multipath
% doppler_factor - doppler factor
% v_temp - relative velocity


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
%
% Modified by: Mattia Lecci <leccimat@dei.unipd.it>, Used MATLAB functions 
% instead of custom ones, vectorized code


PathLoss=0;
c=getLightSpeed;

% Extracting plane equations from Array_of_planes
plane = ArrayOfPlanes(iterateNumberOfRowsArraysOfPlanes,...
    indexMultipath*4 + (-2:1));

% For Higher order refelctions
if indexMultipath >1
    plane2 = ArrayOfPlanes(iterateNumberOfRowsArraysOfPlanes,...
        (indexMultipath*4) + (-6:-3));
end

% Finding image in a particular plane
ReflectedPoint=reflectedImagePointPlane(ReflectedPoint, plane);
% Velocity of reflected image
[velocityRx]=reflectedVelocity(velocityRx, plane);

% For Higher order reflection recursion is applied
if indexMultipath<orderOfReflection
    [booleanMultipathExistance,Intersection1,directionOfDeparture,...
        directionOfArrival,multipath,distance,dopplerFactor,...
        velocityTemporary] = ...
        singleMultipathGenerator(iterateNumberOfRowsArraysOfPlanes,...
        orderOfReflection,indexMultipath+1,ArrayOfPlanes,ArrayOfPoints,...
        ReflectedPoint,Rx,Tx,CADOutput,multipath,indexOrderOfReflection,...
        velocityTx,velocityRx...
        );
    % For the last vector of Multipath (DoD)
else
    
    directionOfDeparture=ReflectedPoint-Tx;
    % delay is the total length of multipath
    distance=norm(directionOfDeparture);
    velocityTxAlongDirectionofDeparture=dot(velocityTx, -directionOfDeparture) / norm(directionOfDeparture);
    velocityRxAlongDirectionofDeparture=dot(velocityRx, -directionOfDeparture) / norm(directionOfDeparture);
    velocityTemporary=velocityRx;
    dopplerFactor=(velocityRxAlongDirectionofDeparture-velocityTxAlongDirectionofDeparture)/(c);
    % Source of multipath
    Intersection1=Tx;
    multipath(indexOrderOfReflection,indexMultipath*3 + (5:7)) = Tx;
    
    booleanMultipathExistance=1;
end

if booleanMultipathExistance==1
    vector=ReflectedPoint-Intersection1;
    Intersection=pointOnPlaneVector(ReflectedPoint,vector, plane);
    
    % corner case where the previous intersection (Intersection) is equal to
    % source (Intersection1)
    if Intersection1==Intersection
        booleanMultipathExistance=0;
    end
    
    multipath(indexOrderOfReflection,indexMultipath*3 + (2:4)) = Intersection;
    
    % Direction of arrival changes dynamically until the last recursion
    directionOfArrival=Intersection1-Intersection;   % check sign
    
    % Extracting information from Array_of_points
    Point1 = ArrayOfPoints(iterateNumberOfRowsArraysOfPlanes,...
        indexMultipath*9 - (8:-1:6));
    Point2 = ArrayOfPoints(iterateNumberOfRowsArraysOfPlanes,...
        indexMultipath*9 - (5:-1:3));
    Point3 = ArrayOfPoints(iterateNumberOfRowsArraysOfPlanes,...
        indexMultipath*9 - (2:-1:0));
    
    % To verify whether the intersection point is within triangle
    booleanMultipathExistance = booleanMultipathExistance &&...
        PointInTriangle(Intersection,Point1,Point2,Point3) &&...
        round(dot(ReflectedPoint-Intersection, Intersection1-Intersection),3) < 0;
    
    if booleanMultipathExistance==1
        if indexMultipath >1 && indexMultipath <orderOfReflection
            condition1=0;
            
        elseif indexMultipath == 1
            condition1=-1;
            plane2=[0,0,0,0];
            
        else
            condition1=1;
            
        end
        
        [booleanMultipathExistance] = verifyPath(Intersection,Intersection1,...
            directionOfArrival,plane,plane2,CADOutput,condition1,false);
        PathLoss=0;
        
    end
    
else
    Intersection=Intersection1;
    booleanMultipathExistance=0;
    
end

% To verify whether DoA vector exists
if indexMultipath == 1 && booleanMultipathExistance==1
    directionOfArrival = -1 * (Rx-Intersection);
    condition1=-1;
    plane2=[0,0,0,0];
    [booleanMultipathExistance] = verifyPath(Rx,Intersection,...
        directionOfArrival,plane,plane2,CADOutput,condition1,false);
    
end

end