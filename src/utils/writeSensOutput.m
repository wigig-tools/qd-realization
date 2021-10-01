function writeSensOutput(outputComm,outputSens, paaNodes, qdFilesPath)
%WRITEQDJSONFILEOUTPUT Writes information to QdFile
%
% INPUTS:
% - output: output matrix
% - paaNodes: vector of PAAs per node
% - qdFilesPath: path to Output/Ns3/QdFiles
%

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

filepath = fullfile(qdFilesPath, 'qdTargetOutput.json');
fid = fopen(filepath, 'w');
NODES = size(outputSens,1);
ITER  = size(outputSens,3);
nodeList = 1:NODES;
Noutput = 21;

for tx = nodeList
    for rx = nodeList(nodeList~=tx)
        for txPaa = 1:paaNodes(tx)
            for rxPaa = 1:paaNodes(rx)
                mimoCh = squeeze(outputSens(tx,rx,:));
                %                     mimoCh = cellfun(@(x) appendNan(x,Noutput,paaNodes(tx)*paaNodes(rx)), mimoCh, 'UniformOutput', false);
                sisoChSens =cell2mat(cellfun(@(x) x(:,:,(txPaa-1)*paaNodes(rx)+rxPaa), mimoCh,'UniformOutput', false));
                rowDistSens = cellfun(@(x) size(x,1), mimoCh);
                mimoCh = squeeze(outputComm(tx,rx,:));
                mimoCh = cellfun(@(x) appendNan(x,Noutput,paaNodes(tx)*paaNodes(rx)), mimoCh, 'UniformOutput', false);
                sisoChComm =cell2mat(cellfun(@(x) x(:,:,(txPaa-1)*paaNodes(rx)+rxPaa), mimoCh,'UniformOutput', false));
                rowDistComm = cellfun(@(x) size(x,1), mimoCh);
                delaySens = mat2cell(single(sisoChSens(:,8)), rowDistSens);
                delayComm = mat2cell(single(sisoChComm(:,8)), rowDistComm);
                gainSens = mat2cell(single(real(sisoChSens(:,9))), rowDistSens);
                gainComm =mat2cell(single(real(sisoChComm(:,9))), rowDistComm);                
                phaseSens = mat2cell(single(sisoChSens(:,18)), rowDistSens);
                phaseComm = mat2cell(single(sisoChComm(:,18)), rowDistComm);                
                aodElSens = mat2cell(single(sisoChSens(:,11)), rowDistSens);
                aodElComm = mat2cell(single(sisoChComm(:,11)), rowDistComm);                
                aodAzSens = mat2cell(single(sisoChSens(:,10)), rowDistSens);
                aodAzComm = mat2cell(single(sisoChComm(:,10)), rowDistComm);                
                aoaElSens = mat2cell(single(sisoChSens(:,13)), rowDistSens);
                aoaElComm = mat2cell(single(sisoChComm(:,13)), rowDistComm);                
                aoaAzSens = mat2cell(single(sisoChSens(:,12)), rowDistSens);
                aoaAzComm = mat2cell(single(sisoChComm(:,12)), rowDistComm);
                delay = cell(ITER,1);
                gain = cell(ITER,1);
                phase = cell(ITER,1);
                aodEl =  cell(ITER,1);
                aodAz= cell(ITER,1);
                aoaAz= cell(ITER,1);
                aoaEl= cell(ITER,1);
                
                for t = 1:ITER
                    delaySensT = delaySens{t};
                    delayCommT = delayComm{t};
                    
                    [delayT, order] = sort([delayCommT; delaySensT], 'ascend');
                    delay{t} = delayT;
                    gain{t}  = mergeSort(gainComm{t},gainSens{t},order);
                    phase{t}  = mergeSort(phaseComm{t},phaseSens{t},order);
                    aodEl{t}  = mergeSort(aodElComm{t},aodElSens{t},order);
                    aodAz{t}  = mergeSort(aodAzComm{t},aodAzSens{t},order);
                    aoaEl{t}  = mergeSort(aoaElComm{t},aoaElSens{t},order);
                    aoaAz{t}  = mergeSort(aoaAzComm{t},aoaAzSens{t},order);
                    
                    
                end
                
                s = struct('tx', tx-1, 'rx', rx-1,...
                    'paaTx', txPaa-1, 'paaRx', rxPaa-1);
                s.delay = delay;%mat2cell(single(sisoChSens(:,8)), rowDistSens);
                s.gain  = gain;%mat2cell(single(real(sisoChSens(:,9))), rowDist);
                s.phase = phase;%mat2cell(single(sisoChSens(:,18)), rowDist);
                s.aodEl = aodEl;%mat2cell(single(sisoChSens(:,11)), rowDist);
                s.aodAz = aodAz;%mat2cell(single(sisoChSens(:,10)), rowDist);
                s.aoaEl = aoaEl;%mat2cell(single(sisoChSens(:,13)), rowDist);
                s.aoaAz = aoaAz;%mat2cell(single(sisoChSens(:,12)), rowDist);
                json = jsonencode(s);
                str2remove =',null'; %Temporary string to remove
                rem_ind_start = num2cell(strfind(json, str2remove)); % Find start string to remove
                index2rm = cell2mat(cellfun(@(x) x:x+length(str2remove)-1,rem_ind_start,'UniformOutput',false)); % Create index of char to remove
                json(index2rm) = [];
                str2remove ='null';
                rem_ind_start = num2cell(strfind(json, str2remove)); % Find start string to remove
                index2rm = cell2mat(cellfun(@(x) x:x+length(str2remove)-1,rem_ind_start,'UniformOutput',false)); % Create index of char to remove
                json(index2rm) = [];
                fprintf(fid, '%s\n', json);
            end
        end
    end
end
fclose(fid);


end

function x = getMat2D(x)
x = permute(x,[1 3 2]);
x = reshape(x,[size(x,1)*size(x,2) size(x,3)]);
end


function x = appendNan(x,n,m)
if isempty(x)
    x = nan(2,n,m);
elseif size(x,3)<m
    x(:, :, size(x,3)+1:m) = nan;
    x(end+1,:,:) = nan;
else
    x(end+1,:,:) = nan;
end
end

function x = mergeSort(y1,y2,order)
y = [y1(:); y2(:)];
x = y(order);
end