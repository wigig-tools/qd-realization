function  trgCfg  = targetCfg(paraCfg)
%TARGETCFG import target configuration.
%   T = TARGETCFG(P) imports the target configuration parameter struct
%   T given the parameter configuration struct P
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

%% Init operations
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
trgtJoints = zeros(numberOfTargets,1);

%% Loop over target position files
for trgtId = 1:numberOfTargets
    % Load target base file relative to trgtId
    trgtBaseFile = sprintf('TargetBase%d.dat',trgtId-1);
    isTrgtBase = any(arrayfun(@(x) strcmp(x.name,trgtBaseFile), ...
        fileList));
    assert(isTrgtBase, [ trgtBaseFile, ' not defined.']);
    %Load Target position
    trgtBase{trgtId} = readmatrix(fullfile(inputPath,...
        trgtBaseFile));
    trgtTimeSamples = size(trgtBase{trgtId},1);
    
    % Load target joints file
    trgtJointsFile = sprintf('TargetJoints%d.dat',trgtId-1);
    isTrgtJoints = any(arrayfun(@(x) strcmp(x.name,trgtJointsFile), ...
        fileList));

    if isTrgtJoints
        trgtJoint{trgtId} = readmatrix(fullfile(inputPath,...
            trgtJointsFile));
        assert(trgtTimeSamples == size(trgtJoint{trgtId},1), ...
            'Base and joints need to have the same temporal size')
        assert(mod(size(trgtJoint{trgtId},2),3)==0, ...
            'Target joints and base require a 3D config')
        numJoints = size(trgtJoint{trgtId},2)/3;
        trgtJointsMat{trgtId} = reshape(trgtJoint{trgtId}, ...
            trgtTimeSamples, 3, numJoints); % Time x 3 x numJoints
    else
        numJoints = 0;
        warning([trgtJointsFile, ' not defined.'])
    end
    
    % If node are mobile Target position points in time needs to match node
    % position information
    if paraCfg.nodeMobility 
        assert(trgtTimeSamples== paraCfg.numberOfTimeDivisions, ...
            'Target number of points do not match config description')
    end
    
    trgtJoints(trgtId) = numJoints+1; % Add base
    trgtJointsMat{trgtId} = cat(3, trgtBase{trgtId}(:,1:3),...
    trgtJointsMat{trgtId} );
end

if numberOfTargets > 0
    trgtBaseIndex = cumsum([1; cellfun(@(x) size(x,3), trgtJointsMat)]);
    trgtBaseIndex(end) = [];
    trgtJointsMat = cat(3, trgtJointsMat{:});
    trgtPositionTime = trgtJointsMat(:, 1:3,:);
    trgtRotationTime = cat(3, trgtBase{:});
    trgtRotationTime(:,1:3,:) =[];
    
    %% Output
    paraCfg.numberOfTargets = numberOfTargets;
    trgCfg.trgtJoints = trgtJoints;
    trgCfg.trgtPosition = trgtPositionTime;
    trgCfg.trgtRotation = trgtRotationTime;
    trgCfg.trgtRcs = 8; % Hard coded temporarly. Waiting for measurements
    trgCfg.trgtFrisCorrection = 10*log10(4*pi/((getLightSpeed/paraCfg.carrierFrequency)^2))-trgCfg.trgtRcs;
    trgCfg.trgtBaseIndex = trgtBaseIndex;
else
    trgCfg = [];
end
end