function R = phaseRotation(theta, phi, centrShift, varargin)
%%PHASEROTATION returns the channel phase rotation R with respect the
%%centroid position in a 60GHz channel.
%        R = phaseRotation(theta,phi, centr_shift)
%        
%        **theta, phi are elevation and azimut angles in rad of rays
%        impinging on the array
%        **centr_shift is the shift wrt the centroid position in which R
%        needs to be computed
%
%        R = PHASEROTATION(theta,phi, centr_shift, 'fc', [value])
%        Computes R when the central frequency is set to [value] Hz
%

% NIST-developed software is provided by NIST as a public service. You may 
% use, copy and distribute copies of the software in any medium, provided 
% that you keep intact this entire notice. You may improve,modify and 
% create derivative works of the software or any portion of the software, 
% and you may copy and distribute such modifications or works. Modified 
% works should carry a notice stating that you changed the software and 
% should note the date and nature of any such change. Please explicitly 
% acknowledge the National Institute of Standards and Technology as the 
% source of the software. NIST-developed software is expressly provided 
% "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR
% ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED 
% WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, 
% NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS 
% THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, 
% OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY
% REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF,
% INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY,
% OR USEFULNESS OF THE SOFTWARE.
% 
% You are solely responsible for determining the appropriateness of using 
% and distributing the software and you assume all risks associated with 
% its use,including but not limited to the risks and costs of program 
% errors, compliance with applicable laws, damage to or loss of data, 
% programs or equipment, and the unavailability or interruption of 
% operation. This software is not intended to be used in any situation 
% where a failure could cause risk of injury or damage to property. 
% The software developed by NIST employees is not subject to copyright 
% protection within the United States.
%
% 2019-2020 NIST/CTL (steve.blandino@nist.gov)


%% Input processing
p = inputParser;
addParameter(p,'fc', 60e9)% Carrier Frequency
parse(p, varargin{:});
fc  = p.Results.fc;

dx = centrShift(:,1);
dy = centrShift(:,2);
dz = centrShift(:,3);

%% 
lambda = getLightSpeed/fc;
k = 2*pi/lambda; 

kx =  k*(sin(theta).*cos(phi))*dx.';
ky =  k*sin(theta).*sin(phi)*dy.';
kz =  k*cos(theta)*dz.';

R = exp(1i*(kz + ky + kx)); %6.87A Balanis 4ed
end