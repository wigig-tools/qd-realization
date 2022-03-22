function [trgOutChan,MpcTarget] = rtTargetRelated(nodeCfgInput, trgCfgInput, paraCfgInput, cadInfo,varargin)
%%RTTARGETRELATED Target related rays 
%
% [trRay,M] = RTTARGETRELATED(N, T, P, C) returns target related
% rays trRay and the relative mpc M given as input the node configuration
% N, the target configuration T, the parameters configuration P, the cad info C
%
% [trRay,M] = RTTARGETRELATED(..., 'displayProgress', val), disable the
% print of the status of the ray tracing when val is 0, otherwise it prints
% the percentage completed

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
% Steve Blandino <steve.blandino@nist.gov>

%% Input processing
p = inputParser;
addOptional(p,'displayProgress',1);
parse(p, varargin{:});
displayProgress = p.Results.displayProgress;

%% Init params
if isempty(trgCfgInput)
    trgtNum = 0;
else
    trgtNum = size(trgCfgInput.trgtPosition,3);
end

if paraCfgInput.nodeMobility
    targetUnreleatedSimLength = paraCfgInput.numberOfTimeDivisions; 
else
    targetUnreleatedSimLength = 1;
end

nPAA_centroids = cellfun(@(x) x.nPAA_centroids, nodeCfgInput.paaInfo);
ts = paraCfgInput.totalTimeDuration/paraCfgInput.numberOfTimeDivisions;
CADop = cadInfo.cad;
MaterialLibrary = cadInfo.materialLibrary;
switchMaterial = cadInfo.allMaterialDefined;
[~, scenarioName] = fileparts(paraCfgInput.inputScenarioName);

if trgtNum
    cf = paraCfgInput.carrierFrequency;
    saveVisualOut = paraCfgInput.switchSaveVisualizerFiles;
    reflectionOrder = paraCfgInput.totalNumberOfReflectionsSens;
    isDiffuse = paraCfgInput.switchDiffuseComponent;
    isQD = paraCfgInput.switchQDModel;
    diffusePathGainThreshold =  paraCfgInput.diffusePathGainThreshold;
    reflectionLoss = paraCfgInput.reflectionLoss;
    for iterateTimeDivision = 1:paraCfgInput.numberOfTimeDivisions
        if mod(iterateTimeDivision,100)==0 && displayProgress
            fprintf('%2.2f%%\n', iterateTimeDivision/paraCfgInput.numberOfTimeDivisions*100)
        end
        for nodeId = 1:paraCfgInput.numberOfNodes
            for paaId = 1:nPAA_centroids(nodeId)
                nodePaa = squeeze(nodeCfgInput.paaInfo{nodeId}.centroid_position_rot(min(targetUnreleatedSimLength,iterateTimeDivision),paaId,:)).';
                previousNodePaaPosition =  squeeze(nodeCfgInput.paaInfo{nodeId}.centroid_position_rot(max(min(targetUnreleatedSimLength,iterateTimeDivision)-1,1),paaId,:)).';
                mpcParFor = cell(1,trgtNum);
                trgtPosition = trgCfgInput.trgtPosition(iterateTimeDivision,:, :);
                previousTargetPosition = trgCfgInput.trgtPosition(max(1,iterateTimeDivision-1),:, :);
                rotAngle = nodeCfgInput.nodeRotation(iterateTimeDivision,:, nodeId);
                for trgtId = 1:trgtNum
                    % Update centroids position
                    target = trgtPosition(:, :, trgtId);
                    vNode = (nodePaa-previousNodePaaPosition)./ts;
                    vTarget = (target-previousTargetPosition(:,:,trgtId))./ts;
                    
                    % LOS Path generation
                    [isLos, ~, output] = LOSOutputGenerator(CADop, target, ...
                        nodePaa, [], vNode, vTarget,0,[],0,cf, ...
                        'rotTx',rotAngle, 'enablePhase', paraCfgInput.enablePhaseOutput);
                    
                    % Store MPC
                    if saveVisualOut && isLos
                        mpcLos = [nodePaa, target];
                        MpcTarget{nodeId,paaId,...
                            trgtId, iterateTimeDivision}{1} = mpcLos;
                    else
                        MpcTarget{nodeId,paaId,...
                            trgtId, iterateTimeDivision}{1} = [];
                    end
                    
                    for iterateOrderOfReflection = 1:reflectionOrder
                        numberOfReflections = iterateOrderOfReflection;
                        
                        [ArrayOfPoints, ArrayOfPlanes, numberOfPlanes,...
                            ~, ~, arrayOfMaterials, ~] = treetraversal(CADop,...
                            numberOfReflections, numberOfReflections,...
                            0, 1, 1, 1, target, nodePaa, [], [],...
                            switchMaterial, [], 1);
                        
                        numberOfPlanes = numberOfPlanes - 1;
                        
                        [outputTemporary, multipathTemporary] = ...
                            multipath(0, ... % 0 delay LOS
                            ArrayOfPlanes, ArrayOfPoints, target, nodePaa, ...
                            CADop, numberOfPlanes, ...
                            MaterialLibrary, arrayOfMaterials, ...
                            switchMaterial, vNode, vTarget, ...
                            isDiffuse, isQD, scenarioName, cf,...
                            diffusePathGainThreshold,...
                            reflectionLoss, ...
                            'rotTx', rotAngle);
                        
                        nMpc = size(multipathTemporary,1);
                        %Store MPC
                        if saveVisualOut && nMpc > 0
                            multipath1 = multipathTemporary(:,...
                                2:end); %Discard reflection order column
                            mpcParFor{trgtId}{iterateOrderOfReflection} =multipath1;
                            MpcTarget{nodeId,paaId,...
                                trgtId,iterateTimeDivision}{iterateOrderOfReflection+1} = multipath1;
                        else
                            MpcTarget{nodeId,paaId,...
                                trgtId,iterateTimeDivision}{iterateOrderOfReflection+1} = [];
                        end
                        
                        %Store QD output
                        if size(output) > 0
                            output = [output;outputTemporary]; %#ok<AGROW>
                            
                        elseif size(outputTemporary) > 0
                            output = outputTemporary;
                            
                        end
                        
                    end
                    
                    outputPaaTarget{nodeId, trgtId}.(sprintf('paaTx%dTarget%d', paaId-1, trgtId-1))= output;
                    outputPaaTargetReverse{trgtId, nodeId}.(sprintf('paaTarget%dpaaRx%d', trgtId-1, paaId-1))= reverseOutputTxRx(output);
                    
                end
            end
        end
        
        trgOutChan(:,:,iterateTimeDivision)  = generateChannelTargetPaa(outputPaaTarget, outputPaaTargetReverse,nodeCfgInput.paaInfo, trgCfgInput.trgtFrisCorrection);
    end
    MpcTargetMat  = cell(paraCfgInput.numberOfNodes,...
        max(nPAA_centroids),...
        trgtNum,reflectionOrder+1, ...
        paraCfgInput.numberOfTimeDivisions);
    for  i =1: reflectionOrder+1
        [MpcTargetMat{:,:,:,i,:}] = deal(MpcTarget{i});
    end
else
    trgOutChan = {};
    MpcTarget = {};
end


end