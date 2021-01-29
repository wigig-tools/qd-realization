function isTriangleWithinSphere = verifydistance(r, referencePoint, CADop, i)
% This part of the code verifies whether the given triangle (denoted by ith
% row of CAD output) is within a sphere of radius r and centered at 
% referencePoint.
%
% Inputs:
% r - denotes radius of the sphere
% referencePoint - denotes the center of the sphere
% CADop - contains either one row or each of the rows of CAD output
% i - 1 if CADop contains one row otherwise it defines ith row of CADop
%
% Output:
% isTriangleWithinSphere - 0 if triangle is within sphere otherwise 1

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
% instead of custom ones


plane1 = CADop(i,10:13);
isTriangleWithinSphere = 0;

% checks whether vertices are within the sphere
for iterator = 1:3
    d = norm([CADop(i,(iterator - 1) + 1) - referencePoint(1),...
        CADop(i,(iterator - 1) + 2) - referencePoint(2),...
        CADop(i,(iterator - 1) + 3) - referencePoint(3)]);
    
    if d <= r
        isTriangleWithinSphere = 1;
        break;
    end
    
end

if isTriangleWithinSphere ~= 1
    d1 = (distanceOfPointFromPlane(referencePoint, plane1));
    Point = pointOnPlane(referencePoint, plane1);
    Point1 = CADop(i, 1:3);
    Point2 = CADop(i, 4:6);
    Point3 = CADop(i, 7:9);
    
    % checks whether projection of center (Tx) on to plane of 
    % triangle lies within triangle and sphere
    switchtriangle = PointInTriangle(Point,Point1,Point2,Point3);
    
    if d1 <= r && switchtriangle == 1
        isTriangleWithinSphere = 1;
        
    elseif d1 <= r && switchtriangle == 0
        triangleVertices = [Point1;Point2;Point3;Point1];
        
        %  calculates distance of projection of center (Tx) on to plane 
        %  of triangle from the 3 sides of triangle. From pythagoras 
        %  theorem we get the closest distance between Tx and any side is 
        %  less than r. If not then the triangle lies outside the sphere.
        for iterator = 1:3
            v1 = triangleVertices(iterator,:);
            v2 = triangleVertices(iterator + 1,:);
            t = -dot(v1-Point,v1-v2) / dot(v1-v2,v1-v2);
            pointOnSide = v1 + (t.* (v1-v2));
            d2 = (dot(pointOnSide-Point,...
                pointOnSide-Point));
            
            if dot(v1-pointOnSide, v2-pointOnSide) <= 0 &&...
                    (d1^2) + (d2) <= r^2
                isTriangleWithinSphere = 1;
                break;
            end
            
        end
    end
end

end