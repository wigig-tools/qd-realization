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

function [para] = parameterCfg(rootFolderStr,scenarioNameStr)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Load Parameters
try
    para.cfgCustomPath = strcat(rootFolderStr,'/',scenarioNameStr,'/Input/paraCfgCurrent.txt');
    paraList = readtable(para.cfgCustomPath,'Delimiter','\t');
catch
    para.cfgDefaultPath = strcat(rootFolderStr,'/Input/paraCfgDefault.txt');
    paraList = readtable(para.cfgDefaultPath,'Delimiter','\t');
end

% numPara = size(paraList,1);
paraCell = (table2cell(paraList))';
paraNameList = paraCell(1,:);
paraStruct = cell2struct(paraCell(2,:),paraNameList,2);

% Environment file name
% = 'Box.xml';       % courtesy - http://amf.wikispaces.com/AMF+test+files
para.environmentFileName = paraStruct.environmentFileName;

% Generalized Scenario
% = 1 (Default)
para.generalizedScenario = str2double(paraStruct.generalizedScenario);

% Switch Indoor
% = 1;
para.indoorSwitch = str2double(paraStruct.indoorSwitch);

% Input Scenario Filename 
% = 'Case1'
% para.inputScenarioName = paraStruct.inputScenarioName;
para.inputScenarioName = scenarioNameStr;

% This is switch to turn on or off mobility.
% 1 = mobility ON, 0 = mobility OFF (Default)
para.mobilitySwitch = str2double(paraStruct.mobilitySwitch);

% This switch lets the user to decide the input to mobility
% 1 = Linear (Default), 2 = input from File
para.mobilityType = str2double(paraStruct.mobilityType);

% This parameter denotes the number of nodes
% = 2  (Default)
para.numberOfNodes = str2double(paraStruct.numberOfNodes);

% n is the total number of time divisions. If n  = 100 and t  = 10, then we
% have 100 time divisions for 10 seconds. Each time division is 0.1 secs in
% length
% = 10 (Default)
para.numberOfTimeDivisions = str2double(paraStruct.numberOfTimeDivisions);

%Referrence point is the center of limiting sphere. 
% = [3,3,2] (Default)
para.referrencePoint = char(paraStruct.referrencePoint);

% This is selection of planes/nodes by distance. r = 0 means that there is
% no limitation (Default). 
para.selectPlanesByDist = str2double(paraStruct.selectPlanesByDist);

% Switch to turn ON or OFF the Qausi dterministic module
% 1 = ON, 0 = OFF (Default)
para.switchQDGenerator = str2double(paraStruct.switchQDGenerator);

% This is switch to turn ON or OFF randomization.
% 1 = random (Default), 0 = Tx,Rx are determined by Tx,Rx paramters
para.switchRandomization = str2double(paraStruct.switchRandomization);

% Switch to enable or disable the visuals
% = 0 (Default)
para.switchVisuals = str2double(paraStruct.switchVisuals);

% Order of reflection.
% 1 = multipath until first order, 2 = multipath until second order (Default)
para.totalNumberOfReflections = str2double(paraStruct.totalNumberOfReflections);

% t is the time period in seconds. The time period for which the simulation
% has to run when mobility is ON
% = 1 (Default)
para.totalTimeDuration = str2double(paraStruct.totalTimeDuration);

end