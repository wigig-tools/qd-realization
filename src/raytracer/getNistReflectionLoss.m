function reflectionLoss = getNistReflectionLoss(materialLibrary, arrayOfMaterials, varargin)
% GETNISTREFLECTIONLOSS returns the ray reflection loss based on NIST 
% measurements
% 
% reflectionLoss = GETNISTREFLECTIONLOSS(materialLibrary, arrayOfMaterials)
%
% reflectionLoss = GETNISTREFLECTIONLOSS(___, 'randOn', value) can be used to
% specify if the reflection loss returned is deterministic (value = 0) and
% correspondent to mean value u measured. Otherwise (value = 1) the
% reflection loss is extracted from a rician distribution with parameters s
% (Noncentrality), sigma(Scale) which have been measured.

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

%% Varargin processing
p = inputParser;
addParameter(p,'randOn',0)
parse(p, varargin{:});
randOn = p.Results.randOn;

%% Init
reflectionLoss = 0;

%% Loop over reflection order
for i = 1:length(arrayOfMaterials)
    matIdx = arrayOfMaterials(i);
    if randOn ==0
        muRl = materialLibrary.mu_RL(matIdx);
        reflectionLoss = reflectionLoss + muRl;

    else
        s_material = materialLibrary.s_RL(matIdx);
        sigma_material = materialLibrary.sigma_RL(matIdx);
        rl = rndRician(s_material, sigma_material, 1, 1);
        reflectionLoss = reflectionLoss + rl ;
    end
end
end