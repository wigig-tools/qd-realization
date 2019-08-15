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

% This function returns angle between two vectors in 4 quadrant system (from 0 to 2pi)


function [theta]=Calc_angle(V1,V2,Vector)
theta_s=asin(magnitude(crossproduct(V1,V2))/(magnitude(V2)*(magnitude(V1))));

switch1=1;
if dotproduct(crossproduct(V1,V2),Vector)<0
    switch1=0;
end
theta_c=acos(dotproduct(V1,V2)/(magnitude(V2)*(magnitude(V1))));
switchc=(dotproduct(V1,V2))>=0;
theta=0;
if switch1==1 && switchc==1
    theta=theta_s;
elseif switch1==1 && switchc==0
    theta=theta_c;
elseif switch1==0 && switchc==0
    theta=pi+(theta_s);
elseif switch1==0 && switchc==1
    theta=(2*pi)-(theta_c);
end

% if switch1==1 && theta_c>=0
%     theta=theta_s;
% elseif switch1==1 && theta_c<0
%     theta=theta_c;
% elseif switch1==0 && theta_c<=0
%     theta=pi+(theta_s);
% elseif switch1==0 && theta_c>0
%     theta=(3*pi/2)+(theta_c);
% end