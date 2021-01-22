function writeQdJsonOutput(output, paaNodes, qdFilesPath)
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




filepath = fullfile(qdFilesPath, 'qdOutput.json');
fid = fopen(filepath, 'w');
NODES = size(output,1);
% ITER  = size(output,3);
% floatFormat = sprintf('%%.%dg',precision);
nodeList = 1:NODES;
Noutput = 21;

for tx = nodeList
    for rx = nodeList(nodeList~=tx)
            for txPaa = 1:paaNodes(tx)
                for rxPaa = 1:paaNodes(rx)
                    mimoCh = squeeze(output(tx,rx,:));
                    mimoCh = cellfun(@(x) appendNan(x,Noutput,paaNodes(tx)*paaNodes(rx)), mimoCh, 'UniformOutput', false);
                    sisoCh =cell2mat(cellfun(@(x) x(:,:,(txPaa-1)*paaNodes(rx)+rxPaa), mimoCh,'UniformOutput', false));
                    rowDist = cellfun(@(x) size(x,1), mimoCh);
                    s = struct('TX', tx-1, 'RX', rx-1,...
                        'PAA_TX', txPaa-1, 'PAA_RX', rxPaa-1);
                    s.Delay = mat2cell(single(sisoCh(:,8)), rowDist);
                    s.Gain  = mat2cell(single(real(sisoCh(:,9))), rowDist);
                    s.Phase = mat2cell(single(sisoCh(:,18)), rowDist);
                    s.AODEL = mat2cell(single(sisoCh(:,11)), rowDist);
                    s.AODAZ = mat2cell(single(sisoCh(:,10)), rowDist);
                    s.AOAEL = mat2cell(single(sisoCh(:,13)), rowDist);
                    s.AOAAZ = mat2cell(single(sisoCh(:,12)), rowDist);
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