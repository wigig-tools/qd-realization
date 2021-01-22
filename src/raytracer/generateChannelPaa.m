function chOut = generateChannelPaa(ch_in, infoPAA)
%GENERATECHANNEL_PAA returns the QD channel for each PAA_TX - PAA_RX
%combination.
%
%   [CH_OUT]  =  GENERATECHANNELPAA(ch_in, info)
%   **ch_in is the diagonal NxN cell array where N is the number of nodes.
%   Each cell includes structs with fields:
%      - channel between PAAs.
%      - rotation informations
%   **info is the supporting structure with PAAs information and indices
%   generated in cluster_paa.
%
%   CH_OUT is the diagonal NxN cell array where N is the number of nodes.
%   The (i,j) cell includes the Nray x Nprop x (PAA_TX x PAA_RX) matrix
%   relative to the i_th TX node and j_th RX node. Nray is the number of
%   rays generated in the QD, Nprop is the number of properties and
%   PAA_TX x PAA_RX is the number of channel connecting the i_th TX node
%   and j_th RX node
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

%% Input processing 
numNodes = length(infoPAA);
nodesVector = 1:numNodes;
chOut = cell(size(ch_in));
nvar = 21;
paa_comb_struct = {};

%% Generate channel for each PAA
for nt = nodesVector % Loop on tx nodes
    for nr = nodesVector(nodesVector~=nt)% Loop on rx nodes
        chMIMOtx_rx = []; % Channel between one tx and one rx
        paaComb = [];
        i = 0;
        for c_t = 1:infoPAA{nt}.nPAA_centroids % Loop on transmitter centroid
            for c_r = 1:infoPAA{nr}.nPAA_centroids % Loop on receiver centroid
                chMimoCentroid = []; % Channel between tx and rx centroid
                paaCombtmp = [];
                chSisoTmp = ch_in{nt,nr}.(sprintf('paaTx%dpaaRx%d', c_t-1, c_r-1));
                nIidTx = infoPAA{nt}.nodePAAInfo{c_t}.indep_stoch_channel;
                nIidRx = infoPAA{nr}.nodePAAInfo{c_r}.indep_stoch_channel;
                for iid_tx = 1:nIidTx
                    % Loop on TX PAA genarated with the same centroid 
                    for iid_rx = 1:nIidRx
                        % Loop on RX PAA generated with the same centroid
                        if ~isempty(chSisoTmp)
                            chSiso = chSisoTmp(:,:,(iid_tx-1)*nIidRx+iid_rx);
                        else
                            chSiso = [];
                        end
                        
                        % Pointer struct. Indeces  to retreive PAA
                        % information in infoPAA
                        ptr.nt = nt;    %TX NODE ID
                        ptr.nr = nr;    %RX NODE ID
                        ptr.paatx = c_t; %TX PAA centroid pointer
                        ptr.paarx = c_r; %RX PAA centroid pointer
                        ptr.iid_tx = iid_tx; %TX PAA rotated channel pointer
                        ptr.iid_rx = iid_rx; %RX PAA rotated channel pointer
                        
                        % Get channel between tx and rx cluster (a
                        % centroid can be the center of different clusters.
                        % Eg cluster 1: PAA generated with the same channel
                        % but different rotation. cluster 2: PAA channels
                        % generated with different stochastic component)
                        if isempty(chSiso)
                            chMimoCluster = [];
                        else
                            [chMimoCluster, paaCombtmp] = ...
                           ddir2MIMO(chSiso, infoPAA, ptr);
                        end
                        chMimoCentroid = cat(3, chMimoCentroid, chMimoCluster);
                        paaComb = [paaComb; paaCombtmp];
                    end
                end
                i = i+1;
                chMIMOtx_rx{i} =chMimoCentroid; %cat(3, ch_t_r, ch_t);
                paa_comb_struct{i} = paaComb;
            end
        end
        if isempty(chMIMOtx_rx)
            chMIMOtx_rx = [];
        else
            M = max(cellfun(@(x) size(x,1), chMIMOtx_rx));
            chNanPad= cellfun(@(x) appendNan(x,M,nvar),chMIMOtx_rx,'UniformOutput',false);
            chMIMOtx_rx = cat(3,chNanPad{:});
        end
        if ~isempty(paaComb)
            [~, index_sorted] = sortrows(paaComb,1);
            chOut{nt, nr} = chMIMOtx_rx(:,:, index_sorted);
        else
            chOut{nt, nr} = chMIMOtx_rx;
        end

    end
end

end
%% Append NAN
function x = appendNan(x, M, nvar)
if size(x,1)<M
    x(end+1:M,1:nvar,:) = nan;
end
end
