function PointInTriangle = PointInTriangle(point1, a, b, c)
%PointInTriangle verifies whether the point lies in the triangle
% ref: http://blackpawn.com/texts/pointinpoly/
% Inputs-
% a,b,c: arrays which denote vertices of a triangle
% point1: point to be verified
%
% Ouput-
% PointInTriangle: boolean


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

v0=c-a;
v1=b-a;
v2=point1-a;

dot00=dot(v0,v0);
dot01=dot(v0,v1);
dot02=dot(v0,v2);
dot11=dot(v1,v1);
dot12=dot(v1,v2);

invDenom=1/((dot00*dot11)-(dot01*dot01));
u=((dot11 * dot02) - (dot01 * dot12)) * invDenom;
v = ((dot00 * dot12) - (dot01 * dot02)) * invDenom;

% Check if point is in triangle
if ((round(u,4) >= 0) && (round(v,4) >= 0) && (u + v < 1))
    PointInTriangle=1;
else
    PointInTriangle=0;
end

end