function checkOutputFile(testCase,scenarioFolder,scenarioFileName,...
    exampleFolder,exampleFileName)
%CHECKOUTPUTFILE Used by tests to check whether output files of tested
% scenario and baseline (example) scenario are the same
%
% INPUTS:
% - testCase: matlab.unittest.TestCase instance which is used to pass or
% fail the verification in conjunction with the test running framework.
% - scenarioFolder: folder containing the desired output file given by the
% recently run test
% - scenarioFileName: file name of the output file from the scenario
% - exampleFolder: folder containing the desired output file from the
% baseline/example scenario
% - exampleFileName:file name of the output file from the baseline/example
% scenario
%
% SEE ALSO: EXAMPLEOUTPUTSTEST


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

% Check if the same file was passed
assertEqual(testCase,scenarioFileName,exampleFileName)

scenarioFilePath = fullfile(scenarioFolder, scenarioFileName);
exampleFilePath = fullfile(exampleFolder, exampleFileName);

if isQdFile(scenarioFilePath)
    sortBy = {'delay','pathGain','phaseOffset','aodEl','aodAz','aoaEl','aoaAz'};
    scenarioOut = readQdFile(scenarioFilePath, sortBy);
    exampleOut = readQdFile(exampleFilePath, sortBy);
elseif isRoomCoordinates(scenarioFilePath)
    scenarioOut = readRoomCoordinates(scenarioFilePath);
    exampleOut = readRoomCoordinates(exampleFilePath);
elseif isQdJsonFile(scenarioFilePath)
    scenarioOut = readQdJsonFile(scenarioFilePath);
    exampleOut  = readQdJsonFile(exampleFilePath);
elseif isMpcJsonCoordinates(scenarioFilePath)
    scenarioOut = readMpcJsonFile(scenarioFilePath);
    exampleOut  = readMpcJsonFile(exampleFilePath);
elseif isNodePositionsJson(scenarioFilePath)
    scenarioOut = readNodeJsonFile(scenarioFilePath);
    exampleOut  = readNodeJsonFile(exampleFilePath);
elseif isPaaPositionsJson(scenarioFilePath)
    scenarioOut = readPaaJsonFile(scenarioFilePath);
    exampleOut  = readPaaJsonFile(exampleFilePath);
else
    verifyTrue(testCase,false,...
        sprintf('File path ''%s'' not recognized', scenarioFilePath))
end

% check equivalence of output file
verifyInstanceOf(testCase, scenarioOut, class(exampleOut))
verifyEqual(testCase, scenarioOut, exampleOut, 'RelTol', 1e-4)

end