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
%
% TODO license

% Check if the same file was passed
assertEqual(testCase,scenarioFileName,exampleFileName)

scenarioFilePath = sprintf('%s/%s',scenarioFolder,scenarioFileName);
exampleFilePath = sprintf('%s/%s',exampleFolder,exampleFileName);

if isNodesPosition(scenarioFilePath)
    scenarioOut = readNodesPosition(scenarioFilePath);
    exampleOut = readNodesPosition(exampleFilePath);
elseif isQdFile(scenarioFilePath)
    scenarioOut = readQdFile(scenarioFilePath,...
        {'delay','pathGain','phaseOffset','aodEl','aodAz','aoaEl','aoaAz'});
    exampleOut = readQdFile(exampleFilePath,...
        {'delay','pathGain','phaseOffset','aodEl','aodAz','aoaEl','aoaAz'});
elseif isMpcCoordinates(scenarioFilePath)
    scenarioOut = readMpcCoordinates(scenarioFilePath);
    exampleOut = readMpcCoordinates(exampleFilePath);
elseif isNodePositions(scenarioFilePath)
    scenarioOut = readNodePositions(scenarioFilePath);
    exampleOut = readNodePositions(exampleFilePath);
elseif isRoomCoordinates(scenarioFilePath)
    scenarioOut = readRoomCoordinates(scenarioFilePath);
    exampleOut = readRoomCoordinates(exampleFilePath);
else
    verifyTrue(testCase,false,...
        sprintf('File path ''%s'' not recognized',scenarioFilePath))
end

% check equivalence of output file
verifyInstanceOf(testCase, scenarioOut, class(exampleOut))
verifyEqual(testCase, scenarioOut, exampleOut, 'RelTol', 1e-10)

end