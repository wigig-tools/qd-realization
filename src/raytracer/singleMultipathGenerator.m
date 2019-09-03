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


% Refer to http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=6503917&isnumber=6503052
% Refer to "singleMultipathGenerator - Method of Images. ppt". The ppt has a slide show. Each
% step is explained in the notes
%INPUT:
%number - number of row of Array_of_planes/Array_of_points for which
%multipath has to be generated (o/p of multipath) 
%order_of_R - order of reflection
%order_of_i - order within recursion. recursion occurs for a number equal
%to order_of_R
%Array_of_points - combinations of multiple triangles, every row is a unique
%combination. every triangle occupies 9 columns (3 vertices). (o/p of
%treetraversal)
%Array_of_planes - Similar to Array of points. Each triangle occupies 4
%columns (plane equation). The first column has the order of reflection
%(o/p of treetraversal) 
%Reflected - reflected image of Tx
%Rx - Rx position
%Tx - Tx position
%CADop - CAD output
%multipath - vectors and points of intersection of multipath
%count - number of rows of Array_of_planes/Array_of_points (o/p of
%treetraversal) 
% vtx, vrx are velocities of tx and rx respectively
% Polarization_switch_temp - switch to enable or disable polarization
% module 
% Polarization_tx/ Polarization_rx - Tx/Rx Polarization
% Antenna_orientation_tx/ Antenna_orientation_rx - Tx/Rx antenna
% oreientation 
% nt_array - 
%switch_cp - a boolean to describe whether cross polarization is selected
%or not. 1 means there is cross polarization and 0 means there is no cross
%polarization

%OUTPUT:
%booleanMultipathExistance - whether multipath exists
%Intersection - intersection of multipath vector to plane
%dod - direction of departure
%doa - direction of arrival
%multipath
%distance - total length of multipath
% doppler_factor - doppler factor
% PL - path loss
% Polarization_tx/ Polarization_rx - Tx/Rx Polarization
% phi_x,phi_y - vectors of Jones vector directions for polarization in
% global coordinate system
% Antenna_orientation_tx/ Antenna_orientation_rx - Tx/Rx antenna
% v_temp - relative velocity


function [booleanMultipathExistance,Intersection,directionOfDeparture,directionOfArrival,multipath,distance,dopplerFactor,...
    PathLoss,PolarizationTx,phaseXDimension,phaseYDimension,AntennaOrientationTx,velocityTemporary]...
    =singleMultipathGenerator(iterateNumberOfRowsArraysOfPlanes,orderOfReflection,indexMultipath,ArrayOfPlanes,...
    ArrayOfPoints,ReflectedPoint,Rx,Tx,CADOutput,...
    multipath,indexOrderOfReflection,velocityTx,velocityRx,PolarizationSwitchTemporary,PolarizationTx,...
    AntennaOrientationTx,PolarizationRx,AntennaOrientationRx,...
    nt_array,switchCP)
velocityTemporary=0;
dopplerFactor=1;
PathLoss=0;
phaseXDimension=0;
phaseYDimension=0;
%     Antenna_orientation=[];
%     Polarization_tx=[];
% order_of_i
%Extracting plane equations from Array_of_planes

plane = ArrayOfPlanes(iterateNumberOfRowsArraysOfPlanes,...
    indexMultipath*4 + (-2:1));

%For Higher order refelctions 

if indexMultipath >1
    plane2 = ArrayOfPlanes(iterateNumberOfRowsArraysOfPlanes,...
        (indexMultipath*4) + (-6:-3));
end
% Finding image in a particular plane
ReflectedPoint=reflectedImagePointPlane(ReflectedPoint, plane);
% Velocity of reflected image
[velocityRx]=reflectedVelocity(velocityRx, plane);
%% For Higher order reflection recursion is applied
if indexMultipath<orderOfReflection
    %order_of_i=order_of_i+1;
    [booleanMultipathExistance,Intersection1,directionOfDeparture,...
        directionOfArrival,multipath,distance,dopplerFactor,PathLoss,...
        PolarizationTx,phaseXDimension,phaseYDimension,...
        AntennaOrientationTx,velocityTemporary] = ...
        singleMultipathGenerator(iterateNumberOfRowsArraysOfPlanes,...
        orderOfReflection,indexMultipath+1,ArrayOfPlanes,ArrayOfPoints,...
        ReflectedPoint,Rx,Tx,CADOutput,multipath,indexOrderOfReflection,...
        velocityTx,velocityRx,PolarizationSwitchTemporary,PolarizationTx,...
        AntennaOrientationTx,PolarizationRx,AntennaOrientationRx,nt_array,switchCP);
    %[switch1,Intersection1,dod,doa,multipath]=Path(number,order_of_R,Array_of_planes,Array_of_points,Reflected,Rx,Tx,count); %Angle/path loss/clustering needed to be added in output
%% For the last vector of Multipath (DoD)   
else
    
    directionOfDeparture=ReflectedPoint-Tx;
    %delay is the total length of multipath
    distance=norm(directionOfDeparture);
    velocityTxAlongDirectionofDeparture=dot(velocityTx, -directionOfDeparture) / norm(directionOfDeparture);
    velocityRxAlongDirectionofDeparture=dot(velocityRx, -directionOfDeparture) / norm(directionOfDeparture);
    velocityTemporary=velocityRx;
    c=3e8;
    dopplerFactor=(velocityRxAlongDirectionofDeparture-velocityTxAlongDirectionofDeparture)/(c);
    % Source of multipath
    Intersection1=Tx;
    multipath(indexOrderOfReflection,indexMultipath*3 + (5:7)) = Tx;
    
    booleanMultipathExistance=1;
end
%% 
if booleanMultipathExistance==1
vector=ReflectedPoint-Intersection1;
Intersection=pointOnPlaneVector(ReflectedPoint,vector, plane);
% corner case where the previous intersection (Intersection) is equal to
% source (Intersection1)
if Intersection1==Intersection
     booleanMultipathExistance=0;
end
%remove this - only for testing
% Intersection
%

% intersection of planes are stored in multipath. This will be used to
% construct maultipath
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
% Polarization raytracing (yet to be tested)
% Antenna orientation and Jones vector to be passed down as input
%-----------------Polarization Part Omitted------------------------------%
% if PolarizationSwitchTemporary == 1
%     Thetai=acos((dot(-directionOfArrival,[plane(1),plane(2),plane(3)]))/(norm([plane(1),plane(2),plane(3)])*norm(directionOfArrival)));
%     [PL_temp,PolarizationTx,phaseXDimension,phaseYDimension,AntennaOrientationTx]=Polarization(AntennaOrientationTx,PolarizationTx,plane,-directionOfArrival,Thetai,switchCP,nt_array(indexMultipath));
%     if Intersection1 == Tx
%         PathLoss=PL_temp;
%         
%     else
%         PathLoss=PathLoss+PL_temp;
%     end
% else
    PathLoss=0;
    phaseXDimension=0;
    phaseYDimension=0;
% end
%-----------------Polarization Part Omitted------------------------------%
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
%-----------------Polarization Part Omitted------------------------------%    
%     if PolarizationSwitchTemporary == 1
%         directionOfArrival=-directionOfArrival;
%     Thetai=dot(directionOfArrival,[plane(1),plane(2),plane(3)]/(norm([plane(1),plane(2),plane(3)])*norm(directionOfArrival)));
% %      [PathLoss,PolarizationTx,phi_x,phi_y,AntennaOrientation]=Polarization(AntennaOrientationTx,PolarizationTx,plane,directionOfArrival,Thetai,y(orderOfReflection));
%     Antenna_x=[AntennaOrientationTx(1,1),AntennaOrientationTx(1,2),AntennaOrientationTx(1,3)];
% Antenna_y=[AntennaOrientationTx(2,1),AntennaOrientationTx(2,2),AntennaOrientationTx(2,3)];
% Antenna_z=[AntennaOrientationTx(3,1),AntennaOrientationTx(3,2),AntennaOrientationTx(3,3),0];
% 
% % Propagation vector
% %  Vector=[1,3,4];
% [Ex,Ey]=Calculate_Ex_Ey(Antenna_z,directionOfArrival,Antenna_x,Antenna_y);
% % % Plane equation
% %  Plane=[1,2,1,3];
% % % Jones Vector (Ex,Ey)
% %  JV=[1,1i];
% %% Algorithm
% % Ex Ey
% 
%  Antenna_x=[AntennaOrientationRx(1,1),AntennaOrientationRx(1,2),AntennaOrientationRx(1,3)];
% Antenna_y=[AntennaOrientationRx(2,1),AntennaOrientationRx(2,2),AntennaOrientationRx(2,3)];
% Antenna_z=[AntennaOrientationRx(3,1),AntennaOrientationRx(3,2),AntennaOrientationRx(3,3),0];
% if switchCP == 0
% [Ex1,Ey1]=Calculate_Ex_Ey(Antenna_z,directionOfArrival,Antenna_x,Antenna_y);
% Antenna_orientation=[Ex1;Ey1;directionOfArrival];
% [theta]=Calc_angle(Ex,Ex1,directionOfArrival);
% ni=1;
% % nt=2;
% % thetai=theta;
% %import Theta i from outside
% PolarizationTx=[cos(theta),-sin(theta);sin(theta),cos(theta)]*PolarizationTx(1,:)';
% elseif switchCP==1
%      for i=1:2
%          [Ex1,Ey1]=Calculate_Ex_Ey(Antenna_z,directionOfArrival,Antenna_x,Antenna_y);
% Antenna_orientation=[Ex1;Ey1;directionOfArrival];
% [theta]=Calc_angle(Ex,Ex1,directionOfArrival);
% ni=1;
% % nt=2;
% % thetai=theta;
% %import Theta i from outside
% PolarizationTx(i,:)=[cos(theta),-sin(theta);sin(theta),cos(theta)]*PolarizationTx(i,:)';
%      end
% end
% % [Ex1,Ey1]=Calculate_Ex_Ey(Antenna_z,doa,Antenna_x,Antenna_y);
% % Antenna_orientation=[Ex1;Ey1;doa];
% % [theta]=Calc_angle(Ex,Ex1);
% % ni=1;
% % % nt=2;
% % % thetai=theta;
% % %import Theta i from outside
% % Polarization_tx=[cos(theta),-sin(theta);sin(theta),cos(theta)]*Polarization_tx';
% directionOfArrival=-directionOfArrival;
%     end
%-----------------Polarization Part Omitted------------------------------%

end

end