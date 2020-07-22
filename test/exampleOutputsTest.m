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

tests = functiontests(localfunctions);
end


%% Fixture Functions
% Called once at beginning and end of ALL tests

function setupOnce(testCase)
% Save important folders & move to src folder
testCase.TestData.testFolderPath = pwd;

srcFolder = '../src';

addpath(srcFolder,...
    fullfile(srcFolder, 'raytracer'),...
    fullfile(srcFolder,'utils'))

testCase.TestData.examplesFolderPath = fullfile(srcFolder,'examples');
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
mkdir(fullfile(testCase.TestData.scenarioFolderPath, 'Input'));

% Reset RNG for reproducibility
rng('default')
end

function teardown(testCase)
status = rmdir(testCase.TestData.scenarioFolderPath,'s');
assert(status,...
    'Errors found while deleting tmp scenario folder ''%s''',...
    testCase.TestData.scenarioFolderPath)
end


%% Tests
% DataCenter
function dataCenterTest(testCase)
exampleName = 'DataCenter';
runRaytracer(testCase, exampleName);
checkOutput(testCase, exampleName);
end

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

% StreetCanyon
function streetCanyonTest(testCase)
exampleName = 'StreetCanyon';
runRaytracer(testCase, exampleName);
checkOutput(testCase, exampleName);
end


%% Utils
function runRaytracer(testCase, exampleName)

% Copy example scenario to new temporary folder
copyfile(fullfile(testCase.TestData.examplesFolderPath, exampleName, 'Input'),...
    fullfile(testCase.TestData.scenarioFolderPath, 'Input'));
delete(fullfile(testCase.TestData.scenarioFolderPath, 'Input/cachedCadOutput.mat'))

% Force settings
paraCfg.switchSaveVisualizerFiles = 1;
% Run raytracing function and generate output files
launchRaytracer(testCase.TestData.scenarioFolderPath,...
    'Verbose', 0, 'forcedParaCfg', paraCfg);

end


function checkOutput(testCase, exampleName)
% list of output files
scenarioFiles = dir(fullfile(...
    testCase.TestData.scenarioFolderPath, 'Output/**'));
scenarioFiles = scenarioFiles(~[scenarioFiles.isdir]);

exampleFiles = dir(fullfile(...
    testCase.TestData.examplesFolderPath, exampleName, 'Output/**'));
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