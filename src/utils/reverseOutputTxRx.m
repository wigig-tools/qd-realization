function outrev = reverseOutputTxRx(output)
%REVERSEOUTPUTTXRX Function to reverse Tx and Rx columns from output.
% Output format can be seen in LOSOutputGenerator or multipath functions.
%
% INPUTS:
% - output: viriable with format given by LOSOutputGenerator or multipath
%
% OUTPUTS:
% - outrev: output input variable with reversed Tx/Rx columns
%
% NOTE: Currently the code doesn't support variables for Tx/Rx
% Polarization, although in the output coulumns 14:17 describe
% PolarizationTx. As PolarizationRx is not present in the output variable,
% it is impossible to flip the two.
%
% SEE ALSO: LOSOUTPUTGENERATOR, MULTIPATH


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

outrev = output;

if isempty(output)
    return
end

% Flip all columns containing directional information between Rx and Tx
% Flip DoD/DoA
outrev(:,2:4,:) = output(:,5:7,:);
outrev(:,5:7,:) = output(:,2:4,:);

% Flip AoD/AoA Az/El
outrev(:,10:11,:) = output(:,12:13,:);
outrev(:,12:13,:) = output(:,10:11,:);

end