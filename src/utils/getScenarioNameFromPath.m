function scenarioName = getScenarioNameFromPath(path, needVisualizerPath)
%GETSCENARIONAMEFROMPATH Returns scenario name from given path while
%checking if it is a valid scenario path
%
%Inputs:
% - path
% - needVisualizerPath: flag. Default: false
%
%Output:
% - scenarioName: if path is valid, return scenario name, otherwise return
% empty string


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

if nargin < 2
    needVisualizerPath = false;
end

% check if valid scenario path
if ~exist(fullfile(path, 'Input'), 'dir')
    warning('Invalid scenario path: ''Input/'' folder does not exist')
    scenarioName = '';
    return
end


if ~exist(fullfile(path, 'Output/Ns3/QdFiles'), 'dir')
    warning('Invalid scenario path: ''Output/Ns3/QdFiles/'' folder does not exist')
    scenarioName = '';
    return
end

if needVisualizerPath
    if ~exist(fullfile(path, 'Output/Visualizer/Mpc.json'), 'file')
        warning('Invalid scenario: ''Output/Visualizer/Mpc.json'' file does not exist')
        scenarioName = '';
        return
    end
    if ~exist(fullfile(path, 'Output/Visualizer/NodePositions.json'), 'file')
        warning('Invalid scenario: ''Output/Visualizer/NodePositions.json'' file does not exist')
        scenarioName = '';
        return
    end
    if ~exist(fullfile(path, 'Output/Visualizer/RoomCoordinates.csv'), 'file')
        warning('Invalid scenario: ''Output/Visualizer/RoomCoordinates.csv'' file does not exist')
        scenarioName = '';
        return
    end
    if ~exist(fullfile(path, 'Output/Visualizer/PAAPosition.json'), 'file')
        warning('Invalid scenario: ''Output/Visualizer/PAAPosition.json'' file does not exist')
        scenarioName = '';
    return
    end
end

[~, scenarioName] = fileparts(path);

end