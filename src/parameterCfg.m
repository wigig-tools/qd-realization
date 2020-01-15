function para = parameterCfg(scenarioNameStr)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% -------------Software Disclaimer---------------
%
% NIST-developed software is provided by NIST as a public service. You may use, copy
% and distribute copies of the software in any medium, provided that you keep intact this
% entire notice. You may improve, modify and create derivative works of the software or
% any portion of the software, and you may copy and distribute such modifications or
% works. Modified works should carry a notice stating that you changed the software
% and should note the date and nature of any such change. Please explicitly
% acknowledge the National Institute of Standards and Technology as the source of the
% software.
%
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
% OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
% WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
% NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS
% NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE
% UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE
% CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF,
% INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
% RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% and distributing the software and you assume all risks associated with its use, including
% but not limited to the risks and costs of program errors, compliance with applicable
% laws, damage to or loss of data, programs or equipment, and the unavailability or
% interruption of operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property. The software
% developed by NIST employees is not subject to copyright protection within the United
% States.
%
% Modified by: Mattia Lecci <leccimat@dei.unipd.it>, Updated implementation


% Load Parameters
cfgPath = fullfile(scenarioNameStr, 'Input/paraCfgCurrent.txt');
paraList = readtable(cfgPath,'Delimiter','\t');

paraCell = (table2cell(paraList))';
para = cell2struct(paraCell(2,:), paraCell(1,:), 2);

% Generalized Scenario
% = 1 (Default)
para = fieldToNum(para, 'generalizedScenario', [0,1], 1);

% Switch Indoor
% = 1;
para = fieldToNum(para, 'indoorSwitch', [0,1], 1);

% Input Scenario Filename
% = 'Case1'
para.inputScenarioName = scenarioNameStr;

% This is switch to turn on or off mobility.
% 1 = mobility ON, 0 = mobility OFF (Default)
% TODO: can be made smart checking if file exists
defaultMobilitySwitch = getDefaultMobilitySwitch(scenarioNameStr);
para = fieldToNum(para, 'mobilitySwitch', [0,1], defaultMobilitySwitch);

% This switch lets the user to decide the input to mobility
% 1 = Linear (Default), 2 = input from File
% TODO: make it smart: is a valid mobility file is present, set 2
defaultMobilityType = getDefaultMobilityType(scenarioNameStr, para.mobilitySwitch);
para = fieldToNum(para, 'mobilityType', [0,1,2], defaultMobilityType); % TODO: 0 should not be valid

% n is the total number of time divisions. If n  = 100 and t  = 10, then we
% have 100 time divisions for 10 seconds. Each time division is 0.1 secs in
% length
% = 10 (Default)
para = fieldToNum(para, 'numberOfTimeDivisions', [], 10);

% Reference point is the center of limiting sphere.
% = [3,3,2] (Default)
% TODO: default value is arbitrary and not generic at all
if isfield(para,'referencePoint')
    para.referencePoint = str2num(para.referencePoint); %#ok<ST2NM>
else
    para.referencePoint = [3,3,2];
end

% This is selection of planes/nodes by distance. r = 0 means that there is
% no limitation (Default).
para = fieldToNum(para, 'selectPlanesByDist', [], 0);

% Switch to turn ON or OFF the Qausi dterministic module
% 1 = ON, 0 = OFF (Default)
para = fieldToNum(para, 'switchQDGenerator', [0,1], 0);

% This is switch to turn ON or OFF randomization.
% 1 = random (Default), 0 = Tx,Rx are determined by Tx,Rx paramters
para = fieldToNum(para, 'switchRandomization', [0,1], 1);

% This parameter denotes the number of nodes
% = 2  (Default)
switch(para.switchRandomization)
    case 0
        defaultNumberOfNodes = []; % specified by nodes.dat
    case 1
        defaultNumberOfNodes = 2;
    otherwise
        error('Cannot handle switchRandomization=%f',para.switchRandomization)
end
para = fieldToNum(para, 'numberOfNodes', [], defaultNumberOfNodes);

% Order of reflection.
% 1 = multipath until first order, 2 = multipath until second order (Default)
para = fieldToNum(para, 'totalNumberOfReflections', [], 2);

% t is the time period in seconds. The time period for which the simulation
% has to run when mobility is ON
% = 1 (Default)
para = fieldToNum(para, 'totalTimeDuration', [], 1);

% Switch to enable or disable csv outputs in Output/Visualizer folder
% = 0 (Default)
para = fieldToNum(para, 'switchSaveVisualizerFiles', [0,1], 0);

% Carrier frequency [Hz]
% Default: 60 GHz
para = fieldToNum(para, 'carrierFrequency', [], 60e9);

% Precision of QdFiles output, used as %.(precision)g
% Default: 6 digits
para = fieldToNum(para, 'qdFilesFloatPrecision', [], 6);

% Use optimized output to file. Might create problems when files are too
% many, especially on servers. In this case, try to disable it (=0)
% Default: 1 (true)
para = fieldToNum(para, 'useOptimizedOutputToFile', [], 1);

end


%% Utils
function para = fieldToNum(para, field, validValues, defaultValue)
% INPUTS:
% - para: structure to convert numeric fields in-place
% - field: field name of the target numeric field
% - validValues: set of valid numerical values on which assert is done
% - defaultValue: if field not found, set value to this default
% OUTPUT: para, in-place update

if isfield(para, field)
    para.(field) = str2double(para.(field));
else
    para.(field) = defaultValue;
end

if isempty(validValues)
    % No defined set of valid values
    return
end

assert(any(para.(field) == validValues),...
    'Invalid value %d for field ''%s''', para.(field), field)
end


function defaultMobilitySwitch = getDefaultMobilitySwitch(scenarioNameStr)
if isNodePositionPresent(scenarioNameStr)
    defaultMobilitySwitch = 1;
else
    defaultMobilitySwitch = 0;
end

end


function defaultMobilityType = getDefaultMobilityType(scenarioNameStr, mobilitySwitch)
if ~mobilitySwitch
    defaultMobilityType = 1;
    return
end

% Mobility switch activated
if isNodePositionPresent(scenarioNameStr)
    defaultMobilityType = 1;
else
    defaultMobilityType = 0;
end

end

function b = isNodePositionPresent(path)
files = dir(fullfile(path, 'Input'));

b = any(startsWith({files.name},'NodePosition'));
end