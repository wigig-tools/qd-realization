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

% This function is in still under development. Yet to be tested

function [JV_final,phi_x,phi_y]=Fresnel(ni,nt,thetai,JV1)
if nt==100
    r_parallel=1;
    r_perpendicular=1;
    phi_x=pi;
    phi_y=0;
else
    
    cosi=cos(thetai);
    cost=sqrt(1-(((ni/nt)*sin(thetai))^2));
    r_parallel=((ni*cosi)-(nt*cost))/((ni*cosi)+(nt*cost));
    r_perpendicular=(-(ni*cost)+(nt*cosi))/((ni*cost)+(nt*cosi));
    % r_parallel
    % r_perpendicular
    theta_B=atan(nt/ni);
    phi_x=pi;
    phi_y=0;
    if thetai>theta_B
        phi_x=0;
        r_perpendicular=0;
    end
end

JV_final(1)=(JV1(1)*exp(1i*phi_x)*r_parallel);
JV_final(2)=(JV1(2)*exp(1i*phi_y)*r_perpendicular);

