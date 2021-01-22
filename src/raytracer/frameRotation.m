function [dod, doa, AOD_az, AOD_el, AOA_az, AOA_el] = frameRotation(frmRotMpInfo, orientation)
%%FRAMEROTATION extracts the angular information from frmRotMpInfo and
%%converts aoa and aod from global coordinates to local coordinates 


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
 
% Extract info and apply frame rotation 
dod = reshape(cell2mat(...
arrayfun(@(x) coordinateRotation(x.dod, [0 0 0], orientation.tx, 'frame'), ...
frmRotMpInfo, 'UniformOutput', false)... %arrayfun
),... %cell2mat
 3, []);%reshape

doa = reshape(cell2mat(...
arrayfun(@(x) coordinateRotation(x.doa, [0 0 0], orientation.rx, 'frame'), ...
 frmRotMpInfo, 'UniformOutput', false)...
),...
 3, []);

% Aod azimuth
AOD_az = deg2rad(mod(atan2d(dod(2,:),dod(1,:)), 360).');
% Aod elevation
AOD_el = deg2rad(acosd(dod(3,:)./vecnorm(dod)).');
% Aoa azimuth
AOA_az = deg2rad(mod(atan2d(doa(2,:),doa(1,:)), 360).');
% Aoa elevation
AOA_el = deg2rad(acosd(doa(3,:)./vecnorm(doa)).');

dod = dod.';
doa = doa.';

end