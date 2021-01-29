function output = fillOutputQd(delay, pathGain, aodAz, aodEl,...
    aoaAz, aoaEl, phase, dopplerFreq, dRayIndex)
%FILLOUTPUTQD Systematically creates a consistent output vector for a 
%diffused ray.
%
%SEE ALSO: FILLOUTPUT


% Copyright (c) 2020, University of Padova, Department of Information
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

if isempty(delay)
    output = [];
    return
end

nOut = size(delay, 1);

% Compute missing outputs
reflOrder = (dRayIndex+(1:nOut)./10^ceil(log10(nOut))).';
dod = angle2vector(aodAz, aodEl,delay);
doa = angle2vector(aoaAz, aoaEl,delay);

txPolarization = nan(nOut, 4);
xPolPathGain = nan(nOut, 1);

output = fillOutput(reflOrder, dod, doa, delay, pathGain,...
    [aodAz, aodEl], [aoaAz, aoaEl], txPolarization, phase,...
    xPolPathGain, dopplerFreq);

end