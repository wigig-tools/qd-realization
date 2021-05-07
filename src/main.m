
% -------------------------Software Disclaimer-----------------------------
%
% NIST-developed software is provided by NIST as a public service. You may 
% use, copy and distribute copies of the software in any medium, provided 
% that you keep intact this entire notice. You may improve, modify and  
% create derivative works of the software or any portion of the software, 
% and you  may copy and distribute such modifications or works. Modified 
% works should carry a notice stating that you changed the software and  
% should note the date and nature of any such change. Please explicitly  
% acknowledge the National Institute of Standards and Technology as the 
% source of the software.
% 
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION  
% OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND 
% DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF 
% THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS 
% WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS  
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT 
% NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF 
% THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using 
% and distributing the software and you assume all risks associated with  
% its use, including but not limited to the risks and costs of program 
% errors, compliance with applicable laws, damage to or loss of data, 
% programs or equipment, and the unavailability or interruption of 
% operation. This software is not intended to be used in any situation  
% where a failure could cause risk of injury or damage to property. The 
% software developed by NIST employees is not subject to copyright 
% protection within the United States.
%
% Modified by: 
% Mattia Lecci <leccimat@dei.unipd.it>, Automatic path check

clear
close all
clc
t0 = tic; % parallel processing-safe
addpath('raytracer', 'utils', 'utils/quaternions')

%% Initialization
rootFolderPath = pwd;
fprintf('----- NIST/CTL Quasi-Deterministic mmWave Channel Model -----\n');
fprintf('Current root folder:\n\t%s\n',rootFolderPath);
[path,folderName] = fileparts(rootFolderPath);
if strcmp(folderName, 'src')
    fprintf('Start to run.\n');
else
    error('The root folder should be ''src''');
end

%% Input
% Leave empty for default 'ScenarioTest'
scenarioNameStr = 'examples/BoxLectureRoom';

if ~isempty(scenarioNameStr)
    fprintf('Use customized scenario: %s.\n',scenarioNameStr);
else
    scenarioNameStr = 'ScenarioTest';
    fprintf('Use default scenario: ScenarioTest.\n');
end
scenarioPathStr = fullfile(rootFolderPath, scenarioNameStr);

% Check Input Scenario File
if ~isfolder(scenarioPathStr)
    scenarioInputPath = fullfile(rootFolderPath, scenarioNameStr, 'Input');
    mkdir(scenarioInputPath);
    
    copyfile(fullfile(rootFolderPath, 'Input'), scenarioInputPath);
    
    fprintf(['%s folder does not exist, creating a new folder with',...
        ' default scenario from root Input folder.\n'],scenarioNameStr);
    
else
    fprintf('%s folder already exists and using this scenario to process.\n',...
        scenarioNameStr);
    
end

% Input System Parameters
paraCfg = parameterCfg(scenarioNameStr);
% Input Node Related Parameters
[paraCfg, nodeCfg] = nodeProfileCfg(paraCfg);
% Run Raytracing Function and Generate Output
outputPath = Raytracer(paraCfg, nodeCfg);

fprintf('Save output data to:\n%s\n',outputPath);
toc(t0);
fprintf('--------- Simulation Complete ----------\n');