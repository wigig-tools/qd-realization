function checkOutputFile(testCase,scenarioFolder,scenarioFileName,...
    exampleFolder,exampleFileName)
% Check if the same file was passed
assertEqual(testCase,scenarioFileName,exampleFileName)

scenarioFilePath = sprintf('%s/%s',scenarioFolder,scenarioFileName);
exampleFilePath = sprintf('%s/%s',exampleFolder,exampleFileName);

if isNodesPosition(scenarioFilePath)
    scenarioOut = readNodesPosition(scenarioFilePath);
    exampleOut = readNodesPosition(exampleFilePath);
elseif isQdFile(scenarioFilePath)
    scenarioOut = readQdFile(scenarioFilePath);
    exampleOut = readQdFile(exampleFilePath);
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