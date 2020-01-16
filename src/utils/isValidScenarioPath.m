function flag = isValidScenarioPath(path, needVisualizerPath)
%ISVALIDSCENARIOPATH Returns a flag whether the given path points to a
%valid scenario or not.
%
%Inputs:
% - path
% - needVisualizerPath: flag. Default: false
%
%Output:
% - scenarioName: true if path is valid scenario


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
if ~isfolder(fullfile(path, 'Input'))
    warning('Invalid scenario path: ''Input/'' folder not found')
    flag = false;
    return
end
if ~isfolder(fullfile(path, 'Output/Ns3/NodesPosition'))
    warning('Invalid scenario path: ''Output/Ns3/NodesPosition/'' folder not found')
    flag = false;
    return
end
if ~isfolder(fullfile(path, 'Output/Ns3/QdFiles'))
    warning('Invalid scenario path: ''Output/Ns3/QdFiles/'' folder not found')
    flag = false;
    return
end

if needVisualizerPath
    if ~isfolder(fullfile(path, 'Output/Visualizer/MpcCoordinates'))
        warning('Invalid scenario path: ''Output/Visualizer/MpcCoordinates/'' folder not found')
        flag = false;
        return
    end
    if ~isfolder(fullfile(path, 'Output/Visualizer/NodePositions'))
        warning('Invalid scenario path: ''Output/Visualizer/NodePositions/'' folder not found')
        flag = false;
        return
    end
    if ~isfolder(fullfile(path, 'Output/Visualizer/RoomCoordinates'))
        warning('Invalid scenario path: ''Output/Visualizer/RoomCoordinates/'' folder not found')
        flag = false;
        return
    end
end

flag = true;

end