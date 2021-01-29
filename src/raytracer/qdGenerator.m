function [output,  outputPre, outputPost] =...
    qdGenerator(dRayOutput, arrayOfMaterials, materialLibrary,...
    qdModelSwitch, scenarioName, diffusePathGainThreshold)
% QDGENERATOR generates diffused or intra-cluster components starting 
% from deterministic rays following 
%   - NIST's Quasi-deterministic (QD) model if qdModelSwitch is set as 
%     nistMeasurements 
%   - Quasi-deterministic model given in 802.11ay channel document if 
%     qdModelSwitch is set as tgayMeasurements
% 
% Inputs:
% dRayOutput - deterministic ray parameter obtained using ray tracing
% arrayOfMaterials - array of materials corresponding to each of the planes
%   where a ray is reflected. The dats is the row number of material from 
%   MaterialLibrary. 
% materialLibrary - For tgayMeasurements, materialLibrary contains each of 
%   the reflectors along with their material and relative permittivity value
%   For nistMeasurements, materialLibrary contains each of the reflectors
%   and their QD parameters
% qdModelSwitch - defines QD model
% scenarioName - defines scenario name
% diffusePathGainThreshold - defines threshold to filter out diffuse 
% components.  
%
% Outputs:
% output - contains ray parameters for deterministic and pre/post cursor
%   diffuse components
% outputPre - contains ray parameters for pre cursor diffuse components
% outputPost - contains ray parameters for post cursor diffuse components

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

%--------------------------Software Disclaimer-----------------------------
%
% NIST-developed software is provided by NIST as a public service. You may 
% use, copy and distribute copies of the software in any medium, provided 
% that you keep intact this entire notice. You may improve, modify and  
% create derivative works of the software or any portion of the software, 
% and you  may copy and distribute such modifications or works. Modified 
% works should carry a notice stating that you changed the software and  
% should note the date and nature of any such change. Please explicitly  
% acknowledge the National Institute of Standards and Technology as the 
% source of the software.
% 
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION  
% OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND 
% DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF 
% THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS 
% WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS  
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT 
% NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF 
% THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% and distributing the software and you assume all risks associated with  
% its use, including but not limited to the risks and costs of program 
% errors, compliance with applicable laws, damage to or loss of data, 
% programs or equipment, and the unavailability or interruption of 
% operation. This software is not intended to be used in any situation  
% where a failure could cause risk of injury or damage to property. The 
% software developed by NIST employees is not subject to copyright 
% protection within the United States.

% Modified by: Neeraj Varshney <neeraj.varshney@nist.gov>, to generate
% diffuse components based on 802.11ay channel document

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

% Pre/post cursors output
switch qdModelSwitch
    case 'nistMeasurements'
        outputPre = getNistQdOutput(cursorOutput, arrayOfMaterials,...
            materialLibrary, diffusePathGainThreshold, 'pre');
        outputPost = getNistQdOutput(cursorOutput, arrayOfMaterials,...
            materialLibrary, diffusePathGainThreshold, 'post');
    case 'tgayMeasurements'
        outputPre = getTgayQdOutput(cursorOutput, scenarioName, 'pre');
        outputPost = getTgayQdOutput(cursorOutput, scenarioName, 'post');
    otherwise
        error('switchQDModel can be either nistMeasurements or tgayMeasurements.');
end

output = [outputPre; cursorOutput; outputPost];

end

%% Utils
function output = getNistQdOutput(dRayOutput, arrayOfMaterials, ...
    materialLibrary, diffusePathGainThreshold, prePostParam)
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

% Remove MPCs with more power than main cursor and  consider only MPCs up 
% to diffusePathGainThreshold dB below the main cursor
removeMpcMask = pg >= pg0db | pg <= pg0db + diffusePathGainThreshold;
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
output(end+1:end+mpcRemoved, :) = nan(mpcRemoved,size(dRayOutput,2));

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
        params.nRays = materialLibrary.n_Precursor(materialIdx);
        
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
        params.nRays = materialLibrary.n_Postcursor(materialIdx);;
        
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


function output = getTgayQdOutput(dRayOutput, scenarioName, prePostParam)
intraClusterParams = getIntraClusterParams(scenarioName, prePostParam);
aodAzCursor = dRayOutput(10);
aodElCursor = dRayOutput(11);
aoaAzCursor = dRayOutput(12);
aoaElCursor = dRayOutput(13);  

if intraClusterParams.n ~= 0
    output = zeros(intraClusterParams.n,21);
    taus = nan(intraClusterParams.n+1, 1);
    taus(1) = dRayOutput(8); 
    % generate path gain, delay, doa/dod, AOA/AOD (AZ & EL) and phase offset 
    for i = 1:intraClusterParams.n
        output(i, 1) = (dRayOutput(1)+(i)./10^ceil(log10(intraClusterParams.n)));
        
        diff = randomExponetialGenerator(intraClusterParams.lambda);
		taus(i+1) = taus(i)+intraClusterParams.delayMultiplier*diff;
        output(i,8) = taus(i+1);
        
        output(i, 9) =  pow2db((db2pow(dRayOutput(9)...
            -intraClusterParams.Kfactor)).*...
            exp(-intraClusterParams.delayMultiplier...
            *((taus(i+1)-taus(1))/intraClusterParams.gamma)));
        
        angleSpread = intraClusterParams.sigma*randn(1,4);            
        output(i, 10:11) = wrapAngles(aodAzCursor + angleSpread(1),...
            aodElCursor + angleSpread(2)); % aod az/el
         
        output(i, 12:13) = wrapAngles(aoaAzCursor + angleSpread(3), ...
            aoaElCursor + angleSpread(4)); % aoa az/el
        
        output(i,18) = rand*2*pi;   % phase shift          
        
        output(i,20) = 0;           % doppler frequency
        
        output(i, 2:4) = angle2vector(output(i, 10),...
            output(i, 11),output(i,8)); % dod
        
        output(i, 5:7) = angle2vector(output(i, 12),...
            output(i, 13),output(i,8)); % doa
   end
else
    output = [];
end    
end

function intraClusterParams = getIntraClusterParams(scenarioName, prePostParam)
icParams = importIntraClusterParameters('material_libraries/intraClusterTgayParameters.txt');
indexScenario = [];
for iRow = 1:length(icParams.Scenario)
        if strcmp(icParams.Scenario{iRow},scenarioName)
            indexScenario = iRow;
        end
end
if isempty(indexScenario)
    error('Intra-cluster parameters are not available for this scenatrio.');
end    
switch(prePostParam)
    case 'pre'
        intraClusterParams.n = icParams.nPre(indexScenario);
        intraClusterParams.Kfactor = icParams.KfactorPre(indexScenario);
        intraClusterParams.gamma = icParams.gammaPre(indexScenario);
        intraClusterParams.lambda = icParams.lambdaPre(indexScenario);
        intraClusterParams.delayMultiplier = -1;
    case 'post'
        intraClusterParams.n = icParams.nPost(indexScenario);
        intraClusterParams.Kfactor = icParams.KfactorPost(indexScenario);
        intraClusterParams.gamma = icParams.gammaPost(indexScenario);
        intraClusterParams.lambda = icParams.lambdaPost(indexScenario);
        intraClusterParams.delayMultiplier = 1;
    otherwise
        error('prePostParam=''%s''. Should be ''pre'' or ''post''', prePostParam)
end
intraClusterParams.sigma = icParams.sigma(indexScenario);
end