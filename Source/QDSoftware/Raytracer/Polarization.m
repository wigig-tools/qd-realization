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

% This function is in still under development. Yet to be tested. Please
% ignore this function

%Refer to "Polarization raytracing. pdf" for theoretical background

%% Input
% Antenna ground plane equation
% JV - Jones vector
% Plane - plane equation of the plane where reflection occurs
% Vector - Propagating vector
% Thetai - Angle of incidence
% nt - dielectric constant of plane
%% Output
% PL - Path loss (1-Reflectivity)
% JV_final - New Jones Vector
% phi_x,phi_y - phase shift in the horizontal and vertical axis
% respectively
% Antenna_orientation - x,y,z axis of antenna coordinate system defined in
% global coordinate systen

% Patch update - Line 75 to 99

function [PL,JV_final,phi_x,phi_y,Antenna_orientation]=Polarization(Antenna_orientation,JV,Plane,Vector,Thetai,switch_cp,nt)
% x,y,z axis of antenna coordinate system defined in
% global coordinate systen
Antenna_x=[Antenna_orientation(1,1),Antenna_orientation(1,2),Antenna_orientation(1,3)];
Antenna_y=[Antenna_orientation(2,1),Antenna_orientation(2,2),Antenna_orientation(2,3)];
Antenna_z=[Antenna_orientation(3,1),Antenna_orientation(3,2),Antenna_orientation(3,3),0];

% calculating horizontal and vertical polarization vector for given antenna
% orientation
[Ex,Ey]=Calculate_Ex_Ey(Antenna_z,Vector,Antenna_x,Antenna_y);

%% Algorithm
% calculating horizontal and vertical polarization vector for given plane
[Ex1,Ey1]=Calculate_Ex_Ey(Plane,Vector,Ex,Ey);
Antenna_orientation=[Ex1;Ey1;Vector];
% calculating the angle between the previous horizontal axis and present
% horizontal axis
[theta]=Calc_angle(Ex,Ex1,Vector);
% Assuming that the wave is incident on reflecting surface from air
ni=1;
if switch_cp==0
    % Calculating new jones vector and phase shift from Fresnel equations
    JV1=[cos(theta),-sin(theta);sin(theta),cos(theta)]*JV(1,:)';
    [JV_final,phi_x,phi_y]=Fresnel(ni,nt,Thetai,JV1);
    % Calculating path loss
    PL=-abs(10*log10((((JV1'*conj(JV1))/(JV_final*conj(JV_final'))))));
    % Normalizing jones vector. Since Jones vector is a unit vector
    JV_final=JV_final./(sqrt(JV_final*conj(JV_final')));
    
elseif switch_cp==1
    % A for loop is initiaited to iterate through both the cross
    % polarizations
    for i=1:2
        JV_temp=JV(i,:);
        JV1=[cos(theta),-sin(theta);sin(theta),cos(theta)]*JV_temp';
        [JV_final,phi_x,phi_y]=Fresnel(ni,nt,Thetai,JV1);
        % Calculating path loss
        PL(i)=-abs(10*log10((((JV1*conj(JV1'))/(JV_final*conj(JV_final'))))));
        % Normalizing jones vector. Since Jones vector is a unit vector
        JV_final=JV_final./(sqrt(JV_final*conj(JV_final')));
        JV_final1(i,:)=JV_final;
    end
    %The final polarization is 2X2 matrix
    JV_final=JV_final1;
end


