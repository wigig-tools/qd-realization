function switch1 = verifydistance(r, Tx, CADop, i)
% This part of the code verifies whether the given triangle (denoted by ith
% row of CAop) is within a sphere of radius r and centered at Tx.
% Please refer to "verifydistance - Limitation by distance.pdf" in this folder


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
%
% Modified by: Mattia Lecci <leccimat@dei.unipd.it>, Used MATLAB functions instead of custom ones


plane1 = CADop(i,10:13);
switch1 = 0;

% checks whether vertices are within the sphere
for iterator = 1:3
    d = norm([CADop(i,(iterator - 1) + 1) - Tx(1),...
        CADop(i,(iterator - 1) + 2) - Tx(2),...
        CADop(i,(iterator - 1) + 3) - Tx(3)]);
    
    if d <= r
        switch1 = 1;
        break;
    end
    
end

if switch1 ~= 1
    d1 = (distanceOfPointFromPlane(Tx, plane1));
    Point = point_on_plane(Tx, plane1);
    Point1 = CADop(i, 1:3);
    Point2 = CADop(i, 4:6);
    Point3 = CADop(i, 7:9);
    
    % checks whether projection of center (Tx) on to plane of triangle lies within
    % triangle and sphere
    switch_triangle = PointInTriangle(Point,Point1,Point2,Point3);
    
    if d1 <= r && switch_triangle == 1
        switch1 = 1;
        
    elseif d1 <= r && switch_triangle == 0
        Triangle_Vertices = [Point1;Point2;Point3;Point1];
        
        %  calculates distance of projection of center (Tx) on to plane of triangle from
        %  the 3 sides of triangle. From pythagoras theorem we get the closest
        %  distance between Tx and any side is less than r. If not then the
        %  triangle lies outside the sphere.
        for iterator = 1:3
            v1 = Triangle_Vertices(iterator,:);
            v2 = Triangle_Vertices(iterator + 1,:);
            t = -dot(v1-Point,v1-v2) / dot(v1-v2,v1-v2);
            Point_on_side = v1 + (t.* (v1-v2));
            d2 = (dot(Point_on_side-Point,...
                Point_on_side-Point));
            
            if dot(v1-Point_on_side, v2-Point_on_side) <= 0 &&...
                    (d1^2) + (d2) <= r^2
                switch1 = 1;
                break;
            end
            
        end
    end
end

end