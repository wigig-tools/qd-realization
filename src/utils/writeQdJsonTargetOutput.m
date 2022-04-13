function writeQdJsonTargetOutput(output, paaNodes, qdFilesPath, varargin)
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

p = inputParser;
addParameter(p,'index',[])
parse(p, varargin{:});
index = p.Results.index;
nTarget = length(index);

filepath = fullfile(qdFilesPath, 'qdTargetOutput.json');
fid = fopen(filepath, 'w');
nodeList = 1:size(output,1);
nOutput = 21;

for tx = nodeList
    for rx = nodeList(nodeList~=tx)
        for txPaa = 1:paaNodes(tx)
            for rxPaa = 1:paaNodes(rx)
                for nT = 0:nTarget-1
                    % Get MIMO channel per PAA
                    mimoCh = squeeze(output(tx,rx,:));
                    % Extract MIMO channel per target
                    mimoCh = cellfun(@(x) x(index(nT+1),:), mimoCh, 'UniformOutput', false);
                    % Add NAN row at the end (To correct matlab behavior when handling a single entry) 
                    mimoCh = cellfun(@(x) appendNan(x,nOutput,paaNodes(tx)*paaNodes(rx)), mimoCh, 'UniformOutput', false);
                    % Get SISO
                    sisoCh =cell2mat(cellfun(@(x) x(:,:,(txPaa-1)*paaNodes(rx)+rxPaa), mimoCh,'UniformOutput', false));
                    % Rows to read in the matrix 
                    rowDist = cellfun(@(x) size(x,1), mimoCh);
                    % JSON struct
                    s = struct('tx', tx-1, 'rx', rx-1, ...
                        'paaTx', txPaa-1, 'paaRx', rxPaa-1,'target', nT);
                    s.delay = mat2cell(single(sisoCh(:,8)), rowDist);
                    s.gain  = mat2cell(single(real(sisoCh(:,9))), rowDist);
                    s.phase = mat2cell(single(sisoCh(:,18)), rowDist);
                    s.aodEl = mat2cell(single(sisoCh(:,11)), rowDist);
                    s.aodAz = mat2cell(single(sisoCh(:,10)), rowDist);
                    s.aoaEl = mat2cell(single(sisoCh(:,13)), rowDist);
                    s.aoaAz = mat2cell(single(sisoCh(:,12)), rowDist);
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