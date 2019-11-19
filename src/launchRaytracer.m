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