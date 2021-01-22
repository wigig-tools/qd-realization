function output = fillOutput(reflOrder, dod, doa, delay, pathGain,...
    aod, aoa, txPolarization, reflPhaseShift, xPolPathGain, dopplerFreq)
%FILLOUTPUT Systematically creates a consistent output vector for a given
%ray. Columns are as follows:
% 1. Reflection order
% 2-4. Direction of Departure (AoD, vector pointing from TX to RX, if LoS
% ray, or to first reflection point, if NLoS ray)
% 5-7. Direction of Arrival (AoA, vector pointing from RX to TX, if LoS
% ray, or to last reflection point, if NLoS ray)
% 8. Time delay [s] (ray length at speed of light)
% 9. Path Gain [dB]
% 10-11. AoD azimuth/elevation [deg]
% 12-13. AoA azimuth/elevation [deg]
% 14-17. TX polarization matrix [(1,1), (1,2), (2,1), (2,2)]
% 18. Phase shift (caused by reflections, i.e. reflOrder*pi) [rad]
% 19. Cross-Polarization path gain [?]
% 20. Doppler frequency
% 21. 0 (for backward compatibility)


% Copyright (c) 2019, University of Padova, Department of Information
% Engineering, SIGNET lab.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

nOut = size(reflOrder, 1);
output = nan(nOut, 21);

% Reflection Order
output(:, 1) = reflOrder;
% Direction of Departure
output(:, 2:4) = dod;
% Direction of Arrival
output(:, 5:7) = doa;
% Time delay
output(:, 8) = delay;
% Path gain
output(:, 9) = pathGain;
% AoD [azimuth, elevation]
output(:, 10:11) = aod;
% AoA [azimuth, elevation]
output(:, 12:13) = aoa;
% Tx polarization
output(:, 14:17) = txPolarization;
% Phase shift caused by reflections
output(:, 18) = reflPhaseShift;
% Cross-polarization Path Gain
output(:, 19) = xPolPathGain;
% Doppler frequency
output(:, 20) = dopplerFreq;
% (Unknown - for retrocompatibility)
output(:, 21) = 0;

end