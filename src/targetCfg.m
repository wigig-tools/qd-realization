function  trgCfg  = targetCfg(paraCfg)
%TARGETCFG import target configuration.
%   [P, T] = TARGETCFG(P) imports the target configuration parameter struct
%   T given the system configuration struct P
%


%--------------------------Software Disclaimer-----------------------------
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
% Modified by: Steve Blandino <steve.blandino@nist.gov>

% Find list of file in input folder
scenarioNameStr = paraCfg.inputScenarioName;
inputPath = fullfile(scenarioNameStr, 'Input');
fileList = dir(inputPath);
% Count target position files
numberOfTargets = sum(arrayfun(@(x) startsWith(x.name,'TargetBase'), ...
    fileList));
% Init
trgtBase = cell(numberOfTargets,1);
trgtJoint = cell(numberOfTargets,1);
trgtJointsMat = cell(numberOfTargets,1);
trgtRotationTime= zeros(paraCfg.numberOfTimeDivisions,3, numberOfTargets);
trgtPositionTime = zeros(paraCfg.numberOfTimeDivisions,3, numberOfTargets);
trgtJoints = zeros(numberOfTargets,1);

%% Loop over target position files
for trgtId = 1:numberOfTargets
    %Check if files relative to trgtId are defined
    trgtBaseFile = sprintf('TargetBase%d.dat',trgtId-1);
    trgtJointsFile = sprintf('TargetJoints%d.dat',trgtId-1);
    isTrgtBase = any(arrayfun(@(x) strcmp(x.name,trgtBaseFile), ...
        fileList));
    isTrgtJoints = any(arrayfun(@(x) strcmp(x.name,trgtJointsFile), ...
        fileList));
    
    if ~isTrgtBase
        error([ trgtBaseFile, ' not defined.']);
    end
    
    %Load Target position
    trgtBase{trgtId} = readmatrix(fullfile(inputPath,...
        trgtBaseFile));
    trgtTimeSamples = size(trgtBase{trgtId},1);
    
    if isTrgtJoints
        trgtJoint{trgtId} = readmatrix(fullfile(inputPath,...
            trgtJointsFile));
        assert(trgtTimeSamples == size(trgtJoint{trgtId},1), 'Base and joints need to have the same temporal size')
        numJoints = size(trgtJoint{trgtId},2)/3;
        trgtJointsMat{trgtId} = reshape(trgtJoint{trgtId}, trgtTimeSamples, 3, numJoints);
    else
        trgtTimeSamples = 1;
        trgtJoint{trgtId} = repmat([0 0 0], trgtTimeSamples,numJoints);
        writematrix(trgtJoint{trgtId}, fullfile(inputPath,...
            trgtJointsFile));
        warning([trgtJointsFile, ' not defined. Static target'])
    end
    
    % Target position points in time needs to match node position
    % information
    if  trgtTimeSamples~= paraCfg.numberOfTimeDivisions &&  ...
            paraCfg.numberOfTimeDivisions > 1
        error('Target number of points do not match config description')
    end
    
    %     trgtPositionTime(1:trgtTimeSamples, :, trgtId) = ...
    %         trgtInitialPosition{trgtId}(1:trgtTimeSamples,:);
    %     trgtPositionTime(trgtTimeSamples+1:end, :, trgtId) = ...
    %         repmat(trgtInitialPosition{trgtId}(1,:), [paraCfg.numberOfTimeDivisions-1,1,1]);
    %
    %     trgtRotationTime(1:trgtTimeSamples, :, trgtId) = ...
    %         trgtDynamics{trgtId}(1:trgtTimeSamples,:);
    %     trgtRotationTime(trgtTimeSamples+1:end, :, trgtId) = ...
    %         repmat(trgtDynamics{trgtId}(1,:), [paraCfg.numberOfTimeDivisions-1,1,1]);
    
    trgtJoints(trgtId) = numJoints+1;
    trgtJointsMat{trgtId} = cat(3, trgtBase{trgtId}(:,1:3),  trgtJointsMat{trgtId} );
end
trgtJointsMat = cat(3, trgtJointsMat{:});
trgtPositionTime = trgtJointsMat(:, 1:3,:);
trgtRotationTime = cat(3, trgtBase{:});
trgtRotationTime(:,1:3,:) =[];

%% Output
paraCfg.numberOfTargets = numberOfTargets;
trgCfg.trgtJoints = trgtJoints;
trgCfg.trgtPosition = trgtPositionTime;
trgCfg.trgtRotation = trgtRotationTime;
end