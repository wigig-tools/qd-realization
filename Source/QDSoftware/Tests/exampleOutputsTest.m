function tests = exampleOutputsTest
%EXAMPLEOUTPUTTEST Tests to check whether new fixes, improvements, or
% changes affect the output of the ray-tracer. The example scenarios are
% taken as baselines, specifically:
% - DenserScenario
% - Indoor1
% - Indoor2
% - L-Room
% - Outdoor1
% - SpatialSharing
% The Output/ folders contain the results of the respective scenario run
% using rng('default'). For the current MATLAB version, the documentation
% states that: "This way, the same random numbers are produced as if you
% restarted MATLAB. The default settings are the Mersenne Twister with
% seed 0."
% MATLAB's Unit Testing Framework is being used to efficiently and reliably
% run all tests at once.
%
% SEE ALSO: TESTSUITE
%
% TODO license

tests = functiontests(localfunctions);
end


%% Fixture Functions
% Called once at beginning and end of ALL tests

function setupOnce(testCase)
% Setup path
addpath('..', '../Raytracer', '../utils')

% Save important folders
testCase.TestData.testFolderPath = pwd;

cd('..')
testCase.TestData.mainFolderPath = pwd;
[~,folderName] = fileparts(testCase.TestData.mainFolderPath);
assert(strcmp(folderName, 'QDSoftware'),...
    'The root folder should be QDSoftware');

testCase.TestData.examplesFolderPath = pwd;
end

function teardownOnce(testCase)
cd(testCase.TestData.testFolderPath)

end


%% Fresh Fixture Functions
% Called at beginning and end of EACH test

function setup(testCase)
% Input
% Using timestamp (tic) to avoid duplicating folder's name
testCase.TestData.scenarioFolderPath = sprintf('ScenarioTest_%d',...
    tic);

% Check Input Scenario File
assert(~isfolder(testCase.TestData.scenarioFolderPath),...
    'Problem creating tmp scenario folder: ''%s'' already exists',...
    testCase.TestData.scenarioFolderPath)

% Setup folder
mkdir(sprintf('%s/Input',testCase.TestData.scenarioFolderPath));

% Reset RNG for reproducibility
rng('default')
end

function teardown(testCase)
cd(testCase.TestData.mainFolderPath)

status = rmdir(testCase.TestData.scenarioFolderPath,'s');
assert(status,...
    'Errors found while deleting tmp scenario folder ''%s''',...
    testCase.TestData.scenarioFolderPath)
end


%% Tests
% DenserScenario
function denserScenarioTest(testCase)
exampleName = 'DenserScenario';
runRaytracer(testCase, exampleName);
checkOutput(testCase, exampleName);
end


% Indoor1
function indoor1Test(testCase)
exampleName = 'Indoor1';
runRaytracer(testCase, exampleName);
checkOutput(testCase, exampleName);
end


% Indoor2
function indoor2Test(testCase)
exampleName = 'Indoor2';
runRaytracer(testCase, exampleName);
checkOutput(testCase, exampleName);
end


% L-Room
function lRoomTest(testCase)
exampleName = 'L-Room';
runRaytracer(testCase, exampleName);
checkOutput(testCase, exampleName);
end


% Outdoor1
function outdoor1Test(testCase)
exampleName = 'Outdoor1';
runRaytracer(testCase, exampleName);
checkOutput(testCase, exampleName);
end


% SpatialSharing
function spatialSharingTest(testCase)
exampleName = 'SpatialSharing';
runRaytracer(testCase, exampleName);
checkOutput(testCase, exampleName);
end


%% Utils
function runRaytracer(testCase, exampleName)

copyfile(sprintf('%s/%s/Input/',...
    testCase.TestData.examplesFolderPath, exampleName),...
    sprintf('%s/Input/', testCase.TestData.scenarioFolderPath));

% Input System Parameters
paraCfg = parameterCfg(testCase.TestData.mainFolderPath,...
    testCase.TestData.scenarioFolderPath);
% Input Node related parameters
[paraCfg, nodeCfg] = nodeProfileCfg(testCase.TestData.mainFolderPath,...
    paraCfg);
% Run raytracing function and generate outputs
Raytracer(testCase.TestData.mainFolderPath, paraCfg, nodeCfg);

cd(testCase.TestData.mainFolderPath)

end


function checkOutput(testCase, exampleName)
% list of output files
scenarioFiles = dir(sprintf('%s/Output/**',...
    testCase.TestData.scenarioFolderPath));
scenarioFiles = scenarioFiles(~[scenarioFiles.isdir]);

exampleFiles = dir(sprintf('%s/%s/Output/**',...
    testCase.TestData.examplesFolderPath, exampleName));
exampleFiles = exampleFiles(~[exampleFiles.isdir]);

verifyLength(testCase, scenarioFiles, length(exampleFiles),...
    'Run scenario and baseline (example) should have the same number of output files')

for i = 1:length(scenarioFiles)
    scenarioFolder = scenarioFiles(i).folder;
    scenarioFileName = scenarioFiles(i).name;
    
    % extract same file from examples
    exampleFileIdx = find(strcmp({exampleFiles.name},scenarioFileName));
    if length(exampleFileIdx) ~= 1
        verifyLength(testCase, exampleFileIdx, 1,...
            'There should only be one corresponding file in examples')
        continue
    end
    
    exampleFolder = exampleFiles(exampleFileIdx).folder;
    exampleFileName = exampleFiles(exampleFileIdx).name;
    
    checkOutputFile(testCase,scenarioFolder,scenarioFileName,...
        exampleFolder,exampleFileName)
end

end