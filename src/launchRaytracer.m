function outputPath = launchRaytracer(varargin)
%LAUNCHRAYTRACER Launch raytracer with given parameters. Acts as a
%functionalized main script
%
%LAUNCHRAYTRACER(): runs default scenario ('ScenarioTest')
%LAUNCHRAYTRACER(scenarioPath): runs the scenario from the given path.
%Default: '', traslated into 'ScenarioTest'.
%LAUNCHRAYTRACER(scenarioName, forcedParaCfg): additionally, forcedParaCfg
%overwrites the configuration parameters obtained by the configuration
%input file. Default: struct().
%LAUNCHRAYTRACER(__, 'verbose', v): 'verbose' parameter with level v. If
%v==0, no information is written on the command window. Default: v = 1.


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

% Input handling
p = inputParser;

addOptional(p, 'scenarioPath', '', @(x) isStringScalar(x) || ischar(x));
addOptional(p, 'forcedParaCfg', struct(), @isstruct);
addParameter(p, 'verbose', 1, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar', 'nonempty', 'integer', 'nonnegative'},...
    mfilename, 'verbose'));

parse(p, varargin{:});

scenarioPath = p.Results.scenarioPath;
forcedParaCfg = p.Results.forcedParaCfg;
verbose = p.Results.verbose;

% Init
functionPath = fileparts(mfilename('fullpath'));
addpath(fullfile(functionPath, 'raytracer'),...
    fullfile(functionPath, 'utils'))

% Input
if ~isempty(scenarioPath)
    if verbose > 0
        fprintf('Use customized scenario: %s.\n', scenarioPath);
    end
else
    scenarioPath = fullfile(functionPath, 'ScenarioTest');
    
    if verbose > 0
        fprintf('Use default scenario: ScenarioTest.\n');
    end
end

% Check input scenario file
if ~isfolder(scenarioPath)
    scenarioInputPath = fullfile(functionPath, scenarioPath, 'Input');
    mkdir(scenarioInputPath);
    
    copyfile(fullfile(functionPath, 'Input'), scenarioInputPath);
    
    if verbose > 0
        fprintf(['%s folder does not exist, creating a new folder with',...
            ' default scenario from root Input folder.\n'],scenarioPath);
    end
    
else
    if verbose > 0
        fprintf('%s folder already exists and using this scenario to process.\n',...
            scenarioPath);
    end
    
end

% Input system and node-related parameters
paraCfg = parameterCfg(scenarioPath);
[paraCfg, nodeCfg] = nodeProfileCfg(paraCfg);

% Apply forced configuration parameters
paraCfg = applyForcedCfgParams(paraCfg, forcedParaCfg);

% Run raytracing function and generate outputs
outputPath = Raytracer(paraCfg, nodeCfg);

end