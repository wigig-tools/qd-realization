function [output,  outputPre, outputPost] =...
    qdGenerator(dRayOutput, arrayOfMaterials, materialLibrary)
%QDGENERATOR Generate diffused components starting from deterministic rays
%following NIST's Quasi-Deterministic model.


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

if dRayOutput(1) == 0
    % no diffused components for LoS ray
    cursorOutput = dRayOutput;
    outputPre = [];
    outputPost = [];
    output = cursorOutput;
    return;
end

% Add randomness to deterministic reflection loss
cursorOutput = dRayOutput;
% cursorOutput(9) = getRandomPg0(dRayOutput, arrayOfMaterials, materialLibrary);

% Pre/post cursors output
outputPre = getQdOutput(cursorOutput, arrayOfMaterials, materialLibrary, 'pre');
outputPost = getQdOutput(cursorOutput, arrayOfMaterials, materialLibrary, 'post');

output = [outputPre; cursorOutput; outputPost];

end


%% Utils
function pg = getRandomPg0(dRayOutput, arrayOfMaterials, materialLibrary)
% Baseline: deterministic path gain
pg = dRayOutput(9);
for i = 1:length(arrayOfMaterials)
    matIdx = arrayOfMaterials(i);
    
    s_material = materialLibrary.s_RL(matIdx);
    sigma_material = materialLibrary.sigma_RL(matIdx);
    rl = rndRician(s_material, sigma_material, 1, 1);
    
    muRl = materialLibrary.mu_RL(matIdx);
    pg = pg - (rl - muRl);
end

end


function output = getQdOutput(dRayOutput, arrayOfMaterials, materialLibrary, prePostParam)
params = getParams(arrayOfMaterials, materialLibrary, prePostParam);

% delays
tau0 = dRayOutput(8); % main cursor's delay [s]
pg0db = dRayOutput(9); % main cursor's path gain [dB]
aodAzCursor = dRayOutput(10); % main cursor's AoD azimuth [deg]
aodElCursor = dRayOutput(11); % main cursor's AoD elevation [deg]
aoaAzCursor = dRayOutput(12); % main cursor's AoA azimuth [deg]
aoaElCursor = dRayOutput(13); % main cursor's AoA elevation [deg]

lambda = rndRician(params.s_lambda, params.sigma_lambda, 1, 1) * 1e9; % [1/s]

if isnan(lambda) || lambda == 0
    % No pre/post cursors
    output = [];
    return;
end

interArrivalTime = rndExp(lambda, params.nRays, 1); % [s]
taus = tau0 + params.delayMultiplier*cumsum(interArrivalTime); % [s]
% TODO: remove rays arriving before LoS

% path gains
Kdb = rndRician(params.s_K, params.sigma_K, 1, 1); % [dB]
gamma = rndRician(params.s_gamma, params.sigma_gamma, 1, 1) * 1e-9; % [s]
sigma_s = rndRician(params.s_sigmaS, params.sigma_sigmaS, 1, 1); % [std.err in exp]

s = sigma_s * randn(params.nRays, 1);
pg = pg0db - Kdb + 10*log10(exp(1)) * (-abs(taus - tau0)/gamma + s);

% Remove MPCs with more power than main cursor
removeMpcMask = pg >= pg0db;
taus(removeMpcMask) = [];
pg(removeMpcMask) = [];
mpcRemoved = sum(removeMpcMask);
params.nRays = length(taus);

% angle spread
aodAzimuthSpread = rndRician(params.s_sigmaAlphaAz, params.sigma_sigmaAlphaAz, 1, 1);
aodElevationSpread = rndRician(params.s_sigmaAlphaEl, params.sigma_sigmaAlphaEl, 1, 1);
aoaAzimuthSpread = rndRician(params.s_sigmaAlphaAz, params.sigma_sigmaAlphaAz, 1, 1);
aoaElevationSpread = rndRician(params.s_sigmaAlphaEl, params.sigma_sigmaAlphaEl, 1, 1);
[aodAz, aodEl] = getDiffusedAngles(aodAzCursor, aodElCursor,...
    aodAzimuthSpread, aodElevationSpread, params.nRays);
[aoaAz, aoaEl] = getDiffusedAngles(aoaAzCursor, aoaElCursor,...
    aoaAzimuthSpread, aoaElevationSpread, params.nRays);

% Combine results into output matrix
phase = rand(params.nRays, 1) * 2*pi;
dopplerShift = zeros(params.nRays, 1);
output = fillOutputQd(taus, pg, aodAz, aodEl, aoaAz, aoaEl, phase, dopplerShift, dRayOutput(1));
output(end+1:end+mpcRemoved, :) = nan(mpcRemoved, size(output,2));

end


function params = getParams(arrayOfMaterials, materialLibrary, prePostParam)

materialIdx = arrayOfMaterials(end); % QD based on last reflector

switch(prePostParam)
    case 'pre'
        params.s_K = materialLibrary.s_K_Precursor(materialIdx);
        params.sigma_K = materialLibrary.sigma_K_Precursor(materialIdx);
        params.s_gamma = materialLibrary.s_gamma_Precursor(materialIdx);
        params.sigma_gamma = materialLibrary.sigma_gamma_Precursor(materialIdx);
        params.s_sigmaS = materialLibrary.s_sigmaS_Precursor(materialIdx);
        params.sigma_sigmaS = materialLibrary.sigma_sigmaS_Precursor(materialIdx);
        params.s_lambda = materialLibrary.s_lambda_Precursor(materialIdx);
        params.sigma_lambda = materialLibrary.sigma_lambda_Precursor(materialIdx);
        params.delayMultiplier = -1;
        params.nRays = 3;
        
    case 'post'
        params.s_K = materialLibrary.s_K_Postcursor(materialIdx);
        params.sigma_K = materialLibrary.sigma_K_Postcursor(materialIdx);
        params.s_gamma = materialLibrary.s_gamma_Postcursor(materialIdx);
        params.sigma_gamma = materialLibrary.sigma_gamma_Postcursor(materialIdx);
        params.s_sigmaS = materialLibrary.s_sigmaS_Postcursor(materialIdx);
        params.sigma_sigmaS = materialLibrary.sigma_sigmaS_Postcursor(materialIdx);
        params.s_lambda = materialLibrary.s_lambda_Postcursor(materialIdx);
        params.sigma_lambda = materialLibrary.sigma_lambda_Postcursor(materialIdx);
        params.delayMultiplier = 1;
        params.nRays = 16;
        
    otherwise
        error('prePostParam=''%s''. Should be ''pre'' or ''post''', prePostParam)
end

params.s_sigmaAlphaAz = materialLibrary.s_sigmaAlphaAz(materialIdx);
params.sigma_sigmaAlphaAz = materialLibrary.sigma_sigmaAlphaAz(materialIdx);
params.s_sigmaAlphaEl = materialLibrary.s_sigmaAlphaEl(materialIdx);
params.sigma_sigmaAlphaEl = materialLibrary.sigma_sigmaAlphaEl(materialIdx);

end


function [az, el] = getDiffusedAngles(azCursor, elCursor,...
azimuthSpread, elevationSpread, nRays)
az = rndLaplace(azCursor, azimuthSpread, nRays, 1);
el = rndLaplace(elCursor, elevationSpread, nRays, 1);
[az, el] = wrapAngles(az, el);
end


function [az, el] = wrapAngles(az, el)
% If elevation is negative, bring it back in [0,180] and rotate azimuth by
% half a turn
negativeElMask = el < 0;
el(negativeElMask) = -el(negativeElMask);
az(negativeElMask) = az(negativeElMask) + 180;

% If elevation is over 180, bring it back in [0,180] and rotate azimuth by
% half a turn
over180ElMask = el > 180;
el(over180ElMask) = 360 - el(over180ElMask);
az(over180ElMask) = az(over180ElMask) + 180;

% Wrap azimuth to [0,360)
az = mod(az, 360);

end