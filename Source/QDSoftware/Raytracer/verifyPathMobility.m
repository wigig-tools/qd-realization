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


%  Given the CAD model and the vectors one can verify if the vector passes
%  through any one of the planes in the CAD model. While verifying about
%  the intersection of line with triangle we consider intersection inside
%  triangle and on triangle cases).


% Inputs  =  vector - vectorial representation of the path that has to be verified
%          Intersection - point of origin of vector
%          Reflected - point of destination of vector
%          Plane - plane where point of origin is present on
%          plane2 - plane where point of destination is present
%          CADop, number_rows_CADop - output of xmlreader (see xml reader for more information)
%          Condition1 - describes the scenario where the path has to be verified
%                     case 0 = when the path reflects from a plane and is going impede on another plane
%                     case 1 = when the path reflects from a plane and is moving towards Rx
%                     case -1 = when the path comes from Tx and impedes on a plane
%                     case 2 = LOS condition

% Outputs = switch3 - boolean which has information whether the path exists or not

function [switch3] = verifyPathMobility(Intersection,Reflected,vector,plane,plane2,number_rows_CADop,CADop,condition1)
switch3 = 1;

% Loop which iterates through all the planes of the CAD file
for i = 1:number_rows_CADop
    plane1(1) = CADop(i,10);
    plane1(2) = CADop(i,11);
    plane1(3) = CADop(i,12);
    plane1(4) = CADop(i,13);
    
    Point1(1) = CADop(i,1);
    Point1(2) = CADop(i,2);
    Point1(3) = CADop(i,3);
    Point2(1) = CADop(i,4);
    Point2(2) = CADop(i,5);
    Point2(3) = CADop(i,6);
    Point3(1) = CADop(i,7);
    Point3(2) = CADop(i,8);
    Point3(3) = CADop(i,9);
    
    % This part checks whether the path intersects with a given plane
    pointIntersection = pointOnPlaneVector(Reflected,vector, plane1);
    switch1 = 0;
    (dot(Reflected-pointIntersection,...
        Intersection-pointIntersection));%>0
    
    % If condition checks whether path intersects with the plane and does the
    % intersection point lie between the point of origin (<) and destination or
    % pathis origin lies on plane (==)
    if (dot(Reflected-pointIntersection,...
            Intersection-pointIntersection)) <= 0
        % Switch is boolean whether the intersection point lies within triangle described by CAD file
        switch1 = PointInTriangle(pointIntersection,Point1,Point2,Point3);
    end
    if (condition1 == 0)
        %checking the condition
        if (plane(4) ~= plane1(4) || plane(1) ~= plane1(1) || ...
                plane(2) ~= plane1(2) || plane(3) ~= plane1(3)...
                && plane(4) ~= plane2(4) || plane(1) ~= plane2(1) ||...
                plane(2) ~= plane2(2) || plane(3) ~= plane2(3))
            switch3 = (~switch1);
        end
    elseif (condition1 == -1)
        if (plane(4) ~= plane1(4) || plane(1) ~= plane1(1) ||...
                plane(2) ~= plane1(2) || plane(3) ~= plane1(3))
            switch3 = (~switch1);
        end
    elseif (condition1 == 1)
        if (plane(4) ~= plane2(4) || plane(1) ~= plane2(1) ||...
                plane(2) ~= plane2(2) || plane(3) ~= plane2(3))
            switch3 = (~switch1);
        end
    elseif (condition1 == 2)
        switch3 = (~switch1);
    end
    if switch3 == 0
        break;
    end
end