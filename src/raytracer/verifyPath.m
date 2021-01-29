function pathExists = verifyPath(Intersection, Reflected, vector, plane,...
    plane2, CADOutput, condition1, isVerifyMobility)
%  Given the CAD model and the vectors one can verify if the vector passes
%  through any one of the planes in the CAD model. While verifying about
%  the intersection of line with triangle we consider intersection inside
%  triangle case only (not on triangle).
%
%  Inputs:
%  Intersection - point of origin of vector
%  Reflected - point of destination of vector
%  vector - vectorial representation of the path that has to be verified
%  Plane - plane where point of origin is present on
%  plane2 - plane where point of destination is present
%  CADOutput - output of xmlreader (see xml reader for more information)
%  Condition1 - describes the scenario where the path has to be verified
%             case 0 = when the path reflects from a plane and is 
%                      going impede on another plane
%             case 1 = when the path reflects from a plane and is 
%                      moving towards Rx
%             case -1 = when the path comes from Tx and impedes on
%                       a plane
%             case 2 = LOS condition
%  isVerifyMobility - flag. True if path's origin could also lie on
%  the plane, false if the intersection point can only lie between
%  the point of origin and the destination.
%
%  Output:
%  pathExists - boolean which has information whether the path exists or not


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
% instead of custom ones, supporting mobility check, improved if/else chain


pathExists = 1;

% Loop which iterates through all the planes of the CAD file
for i = 1:size(CADOutput,1)
    plane1 = CADOutput(i,10:13);
    Point1 = CADOutput(i,1:3);
    Point2 = CADOutput(i,4:6);
    Point3 = CADOutput(i,7:9);
    
    % This part checks whether the path intersects with a given plane
    pointIntersection = pointOnPlaneVector(Reflected,vector, plane1);
    switch1 = 0;
    
    % Check whether path intersects with the plane and does the
    % intersection point lie between the point of origin and destination
    dotIntersects = round(dot(Reflected-pointIntersection,...
        Intersection-pointIntersection), 3);
    
    if dotIntersects < 0 ||...
            (isVerifyMobility && dotIntersects == 0)
        % Switch is boolean whether the intersection point lies within
        % triangle described by CAD file
        switch1 = PointInTriangle(pointIntersection,Point1,Point2,Point3);
    end
    
    if condition1 == 0 && any(plane ~= plane1) && any(plane ~= plane2)
        pathExists = ~switch1;
        
    elseif condition1 == -1 && any(plane ~= plane1)
        pathExists = ~switch1;
        
    elseif condition1 == 1 && any(plane ~= plane2)
        pathExists = ~switch1;
        
    elseif condition1 == 2
        pathExists = ~switch1;
        
    end
    
    if pathExists == 0
        break;
    end
    
end

end