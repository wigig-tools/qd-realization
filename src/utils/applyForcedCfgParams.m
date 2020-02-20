function paraCfg = applyForcedCfgParams(paraCfg, forcedParaCfg)
%APPLYFORCEDCFGPARAMS Apply given parameters to the configuration
%structure. Throws an error if the forced parameter is not found in the
%configuration structure, assuming it contains all possible parameters,
%including default ones.
%
% INPUTS:
%- paraCfg: the original configuration structure
%- forcedParaCfg: the parameters to force
%
% OUTPUTS:
%- paraCfg: the updated parameter configuration structure
%
%SEE ALSO: PARAMETERCFG


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

forcedParaCfgFields = fieldnames(forcedParaCfg);
for i = 1:length(forcedParaCfgFields)
    
    field = forcedParaCfgFields{i};
    if isfield(paraCfg, field)
        paraCfg.(field) = forcedParaCfg.(field);
    else
        error('Forced field ''%s'' was not recognized as a valid configuration parameter', field)
    end
    
end

end