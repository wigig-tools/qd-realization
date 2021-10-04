% function writeVisualizerTargetJsonOutput(visualizerPath, paraCfgInput, nodeCfgInput, nPaaCentroids, nodePosition, mpc)
function writeVisualizerTargetJsonOutput(visualizerPath, paraCfgInput, nodeCfgInput,  nPaaCentroids, nodePosition,trgCfgInput, MpcTarget)
%%WRITEVISUALIZERJSONOUTPUT 

% NIST-developed software is provided by NIST as a public service. You may 
% use, copy and distribute copies of the software in any medium, provided 
% that you keep intact this entire notice. You may improve,modify and 
% create derivative works of the software or any portion of the software, 
% and you may copy and distribute such modifications or works. Modified 
% works should carry a notice stating that you changed the software and 
% should note the date and nature of any such change. Please explicitly 
% acknowledge the National Institute of Standards and Technology as the 
% source of the software. NIST-developed software is expressly provided 
% "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR
% ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED 
% WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, 
% NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS 
% THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, 
% OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY
% REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF,
% INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY,
% OR USEFULNESS OF THE SOFTWARE.
% 
% You are solely responsible for determining the appropriateness of using 
% and distributing the software and you assume all risks associated with 
% its use,including but not limited to the risks and costs of program 
% errors, compliance with applicable laws, damage to or loss of data, 
% programs or equipment, and the unavailability or interruption of 
% operation. This software is not intended to be used in any situation 
% where a failure could cause risk of injury or damage to property. 
% The software developed by NIST employees is not subject to copyright 
% protection within the United States.
%
% 2019-2020 NIST/CTL (steve.blandino@nist.gov)

trgtObjectNum = size(trgCfgInput.trgtJoints,1);
trgtJointsNum = size(trgCfgInput.trgtPosition,3);
timeSamples = paraCfgInput.numberOfTimeDivisions;
trgtMpcTime = cell(timeSamples,1);

% if 0
%% Write Mpc.json
f = fopen(fullfile(visualizerPath, 'TargetMpc.json'), 'w');
for iterateTx = 1:paraCfgInput.numberOfNodes
    
    for iterateTarget = 1:trgtObjectNum
        
        for iteratePaaTx = 1:nPaaCentroids(iterateTx)
            nodeTxCluster  = nodeCfgInput.paaInfo{iterateTx}.paaInCluster{iteratePaaTx};
            
            for txPaaCluster = 1:length(nodeTxCluster)
                
                for iterateJoint = 1:trgCfgInput.trgtJoints(iterateTarget)
                    
                    
                    for reflOrd = 1:paraCfgInput.totalNumberOfReflectionsSens+1
                        jsonStruct = struct('node', iterateTx-1, 'nodePaa', nodeTxCluster(txPaaCluster)-1,...
                            'target', iterateTarget-1, 'joint', iterateJoint-1, ...
                            'Rorder', reflOrd-1);
                        [trgtMpcTime{:}] = deal(MpcTarget{iterateTx,iteratePaaTx,iterateJoint+sum(trgCfgInput.trgtJoints(1:iterateTarget-1)),...
                            :});%{reflOrd})
                        trgtMpcTime2 = vertcat(trgtMpcTime{:});
                        mpcTmp = trgtMpcTime2(:,reflOrd);
                        matSize = cell2mat(cellfun(@size ,mpcTmp ,'UniformOutput' ,false));
                        [~, maxId] = max(matSize(:,1));
                        maxSize = matSize(maxId,:);
                        mpcTmp= cellfun(@(x) padNan(x, maxSize),mpcTmp,'UniformOutput',false);
                        jsonStruct.MPC =  mpcTmp;
                        json = jsonencode(jsonStruct);
                        fprintf(f, '%s\n', json);
                        
                    end
                    
                end
                                
            end
            
        end
        
    end
    
end
fclose(f);

%% Write TargetPositions.json
filename = sprintf('TargetPositions.json');
f = fopen(fullfile(visualizerPath, filename), 'w');

for i = 1:trgtObjectNum
    for j = 1:trgCfgInput.trgtJoints(i)
    jsonStruct = struct('target' , i-1, ...
        'joint', j-1, ...
        'position', [trgCfgInput.trgtPosition(:,:, j+sum(trgCfgInput.trgtJoints(1:i-1)) ); [inf inf inf]], ...
        'rotation', [trgCfgInput.trgtRotation(:,:,i); [inf inf inf]]);
    json = jsonencode(jsonStruct); % Add a temporary inf vector to make sure
    % more than a single vector will be encoded. Matlab json
    % encoder loses the square brackets when encoding vectors.
    str2remove =',[null,null,null]'; %Temporary string to remove
    rem_ind_start = num2cell(strfind(json, str2remove)); % Find start string to remove
    index2rm = cell2mat(cellfun(@(x) x:x+length(str2remove)-1,rem_ind_start,'UniformOutput',false)); % Create index of char to remove
    json(index2rm) = []; % Remove temporary vector.
    fprintf(f, '%s\n', json);
    end
end
fclose(f);

end

function x = padNan(x, maxSize)
if ~all(size(x) == maxSize)
    sizeX = size(x);
    x(sizeX(1)+1:maxSize(1),1:maxSize(2)) = nan;
end
end