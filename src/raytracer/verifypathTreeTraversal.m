function isPathPossible = verifypathTreeTraversal(Point11, Point12, Point13,...
    Point21, Point22, Point23, Normal1, Normal2, Plane1, Plane2, condition1)
% verifypathTreeTraversal is used to check whether two planes are facing
% each other or whether the the point and the plane (normal) are on the same 
% side.
%
% For two planes to be facing each other the dot product between one plane's
% normal and the difference vector between a pair of points on either plane
% should be less than or equal to zero. A corner case arises when two
% triangles have a cammon side. the difference vector can be zero in such a
% case. to get around this case we take the difference between three
% distinct pairs and check for dotproduct.
%
% For a plane and a point to be on same side. We populate the vertices input
% with three copies of the point coordinates. Normal of the plane doesnt
% matter. The function will perform all the above steps for two planes while
% avoiding the reciprocal case.
%
% Inputs:
% Point11, Point12, Point13 - vertices of triangle 1
% Point21, Point22, Point23 - vertices of triangle 2
% Normal1 - normal of the plane of triangle 1
% Normal2 - normal of the plane of triangle 2
% Plane1 - plane equation of triangle 1
% Plane2 - plane equation of triangle 2
% condition1 - -1 to verify path between Tx and plane
%               0 to verify path between two planes
%               1 to verify path between plane and Rx
%
% Output:
% isPathPossible - boolean which holds the information of possibility of path


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
% instead of custom ones, exploiting MATLAB's short-circuit logic


vectorPoint1Plane1Point1Plane2 = Point11 - Point21;
vectorPoint1Plane2Point1Plane1 = Point21 - Point11;
vectorPoint2Plane1Point2Plane2 = Point12 - Point22;
vectorPoint2Plane2Point2Plane1 = Point22 - Point12;
vectorPoint3Plane1Point3Plane2 = Point13 - Point23;
vectorPoint3Plane2Point3Plane1 = Point23 - Point13;

% Using short-circuit logic
isPathPossible = dot(vectorPoint1Plane1Point1Plane2,Normal1) <= 0 &&...
    dot(vectorPoint2Plane1Point2Plane2,Normal1) <= 0 &&...
    dot(vectorPoint3Plane1Point3Plane2,Normal1) <= 0 &&...
    (distanceOfPointFromPlane(Point21, Plane1) ~= 0 ||...
    distanceOfPointFromPlane(Point22, Plane1)~=0 ||...
    distanceOfPointFromPlane(Point23, Plane1)~=0);

if(condition1==0)
    isPathPossible = isPathPossible &&...
        dot(vectorPoint1Plane2Point1Plane1,Normal2) <= 0 &&...
        dot(vectorPoint2Plane2Point2Plane1,Normal2) <= 0 &&...
        dot(vectorPoint3Plane2Point3Plane1,Normal2) <= 0 &&...
        (distanceOfPointFromPlane(Point11, Plane2) ~= 0 ||...
        distanceOfPointFromPlane(Point12, Plane2) ~= 0 ||...
        distanceOfPointFromPlane(Point13, Plane2) ~= 0);
end

end