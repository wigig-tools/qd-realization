function paaInfo = clusterPaa(nodeTimePosition, nodePaaPosition, nodePaaOrientation, varargin)
%CLUSTERPAA returns the cell array paaInfo of lenght 1xN being N the nodes.
% Each entry of the array is a struct storing information about the PAAs
% in a node.
%
%   paaInfo  =  CLUSTERPAA(nodeTimePosition, nodePaaPosition, nodePaaOrientation)
%   **nodeTimePosition is the Tx3xN matrix containing the 3D coordinates of the N
%   nodes at different T time instances
%   **nodePaaPosition is the Nx1 cell array containing the 3D coordinates of
%   each PAA of N nodes in the node local frame (e.g. [0 0 0] if the PAA is
%   centered in the center of the node). If PAAs are not defined the input
%   is the Nx1 cell array of zeros 1x3 vectors (Only 1 PAA at the center of
%   the node)
%   **nodePaaOrientation is the Nx1 cell array containing the PAAs
%   orientation.
%
%   paaInfo{i}:
%     **nPaa: number of PAA in node i
%     **centroids: centroid vector i.e. centroid of each cluster
%     **paaInCluster: cell array. Each entry is a vector of PAAs clustered
%     **centroidsShift: position of the PAAs wrt the centroid.
%     **PAA_loc: PAAs position over time in the global frame
%     **orientation: orientation of each PAA in cluster
%     **nodePAAInfo: flags for interfacing with Raytracer
%     **generationMethod: channel generation method. 0: common channel 1:
%     common deterministic part 2: independent channels
%     **centroidTimePosition: position of the centroid in time in the
%     global framce
%     **node_centroid: position of the node in time in the global frame
%     **PAA_position: matrix of unique centroid positions. If no PAAs are
%     defined in input, the output is the location of the node
%     **nPAA_centroids: number of unique centroids
%
%   [PAA_info]  =  CLUSTER_PAA(nodeLoc, nodePAA_position, option, value)
%
%   options
%     'fc': specify central frequncy in Hz (Default 60e9 Hz)
%     'corrDistance':  Correlation distance: above this threshold PAAs
%          are uncorrelated (Default: 50)
%     'fullCorrDistance': Full correlation distance: below this
%          threshold PAAs are fully correlated (Default: 1)

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
p = inputParser;
addParameter(p,'fc', 60e9)% Carrier Frequency
addParameter(p,'corrDistance',1)% Correlation distance: above this threshold PAAs are uncorrelated
addParameter(p,'fullCorrDistance',1) %Full correlation distance: below this threshold PAAs are fully correlated
parse(p, varargin{:});
fc  = p.Results.fc;
corrDistance = p.Results.corrDistance;
fullCorrDistance = p.Results.fullCorrDistance;

assert(size(nodeTimePosition,ndims(nodeTimePosition)-1) == 3, ...
    'Provide (x,y,z) coordinates as input of cluster_paa')
assert(size(nodeTimePosition,ndims(nodeTimePosition)) == length(nodePaaPosition),...
    'Provide correct input: each node should have a correspondent PAAs description')

C = getLightSpeed;
wavelength =C/fc;
squeezeAndReshape = @(x) reshape(squeeze(x), [], 3); % Helper anonymus for using unique when multiple time divisions
findRow = @(x,y) sum(ismember(x,y),2)>0; % Helper anonymus find the row index of the matrix x containing y
nodeTimePosition = permute(nodeTimePosition, [1 3 2]); % nodeLoc is a timeDivision x Nodes x coordinates

%% Process PAA positions
numberOfNodes = length(nodePaaPosition);
paaPairwiseDistance = cell([1,numberOfNodes]);
paaInfo = cell([1,numberOfNodes]);
numberTimeDivision = size(nodeTimePosition,1);

%% Clustering: loop on nodes
for node_id = 1:numberOfNodes
    nPaa = size(nodePaaPosition{node_id},1); % Number of PAAs at node node_id
    if nPaa == 1, nPaa =0;end % nchoosek returns an empty vector if nPaa 0
    paaInfo{node_id}.nPaa = nPaa;
    paaInfo{node_id}.centroids = 1;
    paaVector = 1:nPaa;
    paaNode2cluster = 1:nPaa; % Indexes of nodes to cluster
    paaClustered = [];        % PAAs in the cluster
    paaTimePosition = [];
    idx_paa=0;
    paaIdComb  = nchoosek(paaVector ,2); % Indexes of all PAA combinations    
    paaPairwiseDistance{node_id} = sqrt(...
        sum(abs(...
        nodePaaPosition{node_id}(paaIdComb(:,1),:)-...
        nodePaaPosition{node_id}(paaIdComb(:,2),:)...
        ).^2, ...
        2)...
        ); % Compute pairwise distances
    
    %% Find possible clusters of PAA closer than l/2
    fullCorrPaaCouple = paaIdComb(paaPairwiseDistance{node_id}<= fullCorrDistance * (wavelength/2) +eps,:);

    if any(fullCorrPaaCouple(:))
        idx_paa=idx_paa+1;
        % This couples can be combined in an unique centroid
        paaFullCorr = unique(fullCorrPaaCouple(:)); % Remove redundancy

        while numel(paaFullCorr)
            [~, popularPaaId] = max(histc(fullCorrPaaCouple(:), paaFullCorr)); % Find PAA with most connections
            paaCluster =  reshape(...
                unique(fullCorrPaaCouple(findRow(fullCorrPaaCouple,paaFullCorr(popularPaaId)), :)),...
                [], 1); % Find the rows in fullCorrIdx where relative to the
            % node with most connection and store the PAA connected with
            % it.

            % Update paaInfo struct
            paaInfo{node_id}.paaInCluster{idx_paa} = paaCluster;
            paaInfo{node_id}.centroids(idx_paa) = paaFullCorr(popularPaaId); % Store centroid label
            paaTimePosition(:,idx_paa, :) =squeezeAndReshape(nodeTimePosition(:,node_id, :)) + ...
                repmat(nodePaaPosition{node_id}(paaInfo{node_id}.centroids(idx_paa),:), ...
                [numberTimeDivision, 1,1]);%#ok<*EMGRO> % Add PAA shifts to PAA locations to compute PAA position in the global frame
            paaInfo{node_id}.generationMethod(idx_paa) = 0;
            paaClustered = [paaClustered; paaCluster];  %#ok<AGROW>
            paaInfo{node_id}.centroidsShift{idx_paa} = repmat(nodePaaPosition{node_id}(paaInfo{node_id}.centroids(idx_paa),:), ...
                length(paaCluster),1)...
                -nodePaaPosition{node_id}(paaCluster ,:); % Save shift from centroid
            paaInfo{node_id}.orientation{idx_paa} = nodePaaOrientation{node_id}(paaCluster, :);
            paaFullCorr = paaFullCorr(~ismember(paaFullCorr,  paaCluster)); % Node not considered in cluster
            idx_paa = idx_paa+1;
        end
        idx_paa = idx_paa-1;
        uniquePaaClustered = unique(paaClustered);

        % Check if cluster can be further merged
        if any(histc(paaClustered, uniquePaaClustered)>1)             %#ok<*HISTC>
            [rep, ~] = histc(paaClustered, uniquePaaClustered);
            merge_paa = cell2mat(cellfun(@(x) any(ismember(x,uniquePaaClustered(rep>1))), paaInfo{node_id}.paaInCluster, 'UniformOutput', 0));
            node2merge = cellfun(@(x) x(~ismember(x,uniquePaaClustered(rep>1))) , paaInfo{node_id}.paaInCluster(merge_paa), 'UniformOutput', 0);
            node_merged = sort([ vertcat(node2merge{:}); uniquePaaClustered(rep>1)]);
            cluster_idx = find(merge_paa, 1 );
            merge_paa = find(merge_paa);
            cluster2del =  merge_paa((merge_paa~=cluster_idx));
            
            % Update paaInfo struct
            paaInfo{node_id}.paaInCluster{cluster_idx} = node_merged;
            getCentralValue = @(x) x(ceil(end/2));
            paaInfo{node_id}.centroids(cluster_idx) = getCentralValue(uniquePaaClustered(rep>1));
            paaInfo{node_id}.generationMethod(cluster_idx) = 0;
            paaInfo{node_id}.paaInCluster = paaInfo{node_id}.paaInCluster(~ismember(1:numel(paaInfo{node_id}.paaInCluster), cluster2del)); % Double-check this line
            paaInfo{node_id}.centroids(cluster2del) = [];
            paaInfo{node_id}.generationMethod(cluster2del) = [];
            paaTimePosition(:,cluster2del, :) = [];
            paaInfo{node_id}.centroidsShift{cluster_idx} = repmat(nodePaaPosition{node_id}(paaInfo{node_id}.centroids(cluster_idx),:), length(node_merged),1)-...
                nodePaaPosition{node_id}(paaInfo{node_id}.paaInCluster{cluster_idx} ,:);
            paaInfo{node_id}.centroidsShift(cluster2del) = [];
            idx_paa = idx_paa-1;
        end
    end
    
    %% Find possible clusters of PAA between l/2 and l_cor*lambda
    residualPaaIdx = paaNode2cluster(~ismember(paaNode2cluster,paaClustered) ); % Node not clustered yet
    rowCombidx = find(findRow(paaIdComb, residualPaaIdx));
    stochUncorrPaaIdx = paaPairwiseDistance{node_id}(rowCombidx,:)<= corrDistance*wavelength/2 ...
        & paaPairwiseDistance{node_id}(rowCombidx,:)> fullCorrDistance * (wavelength/2);

    if  any(stochUncorrPaaIdx)
        stochUncorrPaaCouple = paaIdComb(rowCombidx(stochUncorrPaaIdx),:);% This couples can be combined

        if any(~ismember(stochUncorrPaaCouple(:),paaClustered))

            if isfield(paaInfo{node_id}, 'paaInCluster')
                % If a cluster has been found before try add PAAs to
                % previous centroid
                row_with_centroid = stochUncorrPaaCouple(findRow(stochUncorrPaaCouple, paaInfo{node_id}.centroids),:);  % These couples can be combined
                
                % Check first in previous centroids
                for ct = 1:numel(paaInfo{node_id}.centroids)
                    idx_paa = idx_paa+1;
                    paaCluster = unique(row_with_centroid(findRow(row_with_centroid, paaInfo{node_id}.centroids(ct)),:));
                    
                    % Update paaInfo struct
                    paaInfo{node_id}.paaInCluster{idx_paa}  = paaCluster(~ismember(paaCluster,paaClustered));
                    paaInfo{node_id}.centroids(idx_paa) =paaInfo{node_id}.centroids(ct);
                    paaInfo{node_id}.centroidsShift{idx_paa}  = ...
                        repmat(nodePaaPosition{node_id}(paaInfo{node_id}.centroids(idx_paa),:),...
                        length(paaInfo{node_id}.paaInCluster{idx_paa}),1)-nodePaaPosition{node_id}(paaInfo{node_id}.paaInCluster{idx_paa} ,:);
                    paaInfo{node_id}.orientation{idx_paa} =  nodePaaOrientation{node_id}(paaInfo{node_id}.paaInCluster{idx_paa}, :);
                    paaTimePosition(:,idx_paa, :) =squeezeAndReshape(nodeTimePosition(:,node_id, :)) + nodePaaPosition{node_id}(paaInfo{node_id}.centroids(idx_paa),:);
                    paaInfo{node_id}.generationMethod(idx_paa) = 1;
                    paaClustered = [paaClustered;paaInfo{node_id}.paaInCluster{idx_paa}]; %#ok<AGROW>
                end
            end
            % Among the stochUncorrPAA check now the one that have not been
            % clustered
            stochUncorrPaa = unique(stochUncorrPaaCouple(:));
            stochUncorrPaa = stochUncorrPaa(~ismember(stochUncorrPaa,  paaClustered)); % Node not considered in cluster
            
            if isempty(stochUncorrPaa) % Compensate index decrement when skipping while loop
                idx_paa = idx_paa+1;
            end
            
            while numel(stochUncorrPaa)
                idx_paa = idx_paa+1;
                [~, popularPaaId] = max(histc(stochUncorrPaaCouple(:),stochUncorrPaa));
                paaCluster =  reshape(unique(stochUncorrPaaCouple(findRow(stochUncorrPaaCouple, stochUncorrPaa(popularPaaId)),:)), [], 1);
                % Find the rows in fullCorrIdx where relative to the
                % node with most connection and store the PAA connected with
                % it.

                % Update paaInfo struct
                paaInfo{node_id}.paaInCluster{idx_paa}  = paaCluster(~ismember(paaCluster,paaClustered));
                paaInfo{node_id}.centroids(idx_paa) =stochUncorrPaa(popularPaaId);
                paaInfo{node_id}.centroidsShift{idx_paa}  = ...
                    repmat(nodePaaPosition{node_id}(paaInfo{node_id}.centroids(idx_paa),:),...
                    length(paaInfo{node_id}.paaInCluster{idx_paa}),1)-nodePaaPosition{node_id}(paaInfo{node_id}.paaInCluster{idx_paa} ,:);
                paaInfo{node_id}.orientation{idx_paa} =  nodePaaOrientation{node_id}(paaInfo{node_id}.paaInCluster{idx_paa}, :);
                paaTimePosition(:,idx_paa, :) =squeezeAndReshape(nodeTimePosition(:,node_id, :)) + nodePaaPosition{node_id}(paaInfo{node_id}.centroids(idx_paa),:);
                paaInfo{node_id}.generationMethod(idx_paa) = 1;
                paaClustered = [paaClustered;paaInfo{node_id}.paaInCluster{idx_paa}]; %#ok<AGROW>
                stochUncorrPaa = stochUncorrPaa(~ismember(stochUncorrPaa,  paaCluster)); % Node not considered in cluster
            end
            idx_paa = idx_paa-1;
        end
    end
    
    
    %% No cluster found
    if any(~ismember(1:nPaa,paaClustered))
        uncorrPaa = paaVector(~ismember(1:nPaa,paaClustered));

        for m_id = 1:numel(uncorrPaa)
            paaInfo{node_id}.paaInCluster{idx_paa+m_id} = uncorrPaa(m_id);
            paaInfo{node_id}.centroids(idx_paa+m_id) = uncorrPaa(m_id);
            paaInfo{node_id}.centroidsShift{idx_paa+m_id}  = zeros(1,3);
            paaInfo{node_id}.orientation{idx_paa+m_id} = nodePaaOrientation{node_id}(uncorrPaa(m_id), :);
            paaTimePosition(:,idx_paa+m_id, :) =squeezeAndReshape(nodeTimePosition(:,node_id, :)) + nodePaaPosition{node_id}(paaInfo{node_id}.centroids(idx_paa+m_id),:);
            paaInfo{node_id}.generationMethod(idx_paa+m_id)=2;
        end
    end
    
    %% Finalize struct
    if paaInfo{node_id}.nPaa ~=0
        paaInfo{node_id}.PAA_loc = paaTimePosition;

    else
        paaInfo{node_id}.nPaa = 1;
        paaInfo{node_id}.paaInCluster = {1};
        paaInfo{node_id}.centroids = 1;
        paaInfo{node_id}.centroidsShift =nodePaaPosition(node_id);
        paaInfo{node_id}.PAA_loc =nodeTimePosition(:,node_id, :);
        paaInfo{node_id}.orientation{1} = nodePaaOrientation{node_id};
        paaInfo{node_id}.generationMethod = 2;
    end
end

%% Interface with channel model
paa_id_init = 0;

for node_id  = 1:numberOfNodes
    [~, id ] = unique(squeezeAndReshape(paaInfo{node_id}.PAA_loc(1,:,:)), 'rows', 'stable');
    unique_PAA_location = paaInfo{node_id}.PAA_loc(:,id,:);
    [unique_centroids,position_centroids] = unique(paaInfo{node_id}.centroids);
    [~,position_centroids_sorted] = sort(position_centroids);
    centroid_rep = histc(paaInfo{node_id}.centroids, unique_centroids);
    centroid_rep = centroid_rep(position_centroids_sorted);
    numberPaaCentroid= cellfun(@(x) length(x), paaInfo{node_id}.paaInCluster);
    unique_centroids=unique_centroids(position_centroids_sorted);

    for paa_id = 1:length(centroid_rep)
        idxCentr = paaInfo{node_id}.centroids==unique_centroids(paa_id);
        %centroid_id: id of PAA considered as centroid of the cluster 
        paaInfo{node_id}.nodePAAInfo{paa_id_init+paa_id,1}.centroid_id = unique_centroids(paa_id);
        numberPaaCentroidNode  = numberPaaCentroid(idxCentr);
        %tot_channel: number of channels associated with centroid_id
        paaInfo{node_id}.nodePAAInfo{paa_id_init+paa_id,1}.tot_channel = sum(numberPaaCentroidNode);
        %Number of channels that are obtained with generation method 1
        numberPaaGenMet1 = numberPaaCentroidNode(paaInfo{node_id}.generationMethod(idxCentr)==1);

        if isempty(numberPaaGenMet1)
            numberPaaGenMet1 = 1;
        end
        %indep_stoch_channel: channel generated with independent stochastic
        %component numberPaaGenMet1 + number of different cluster having
        %the same centroid -1
        paaInfo{node_id}.nodePAAInfo{paa_id_init+paa_id,1}.indep_stoch_channel = centroid_rep(paa_id)-1+numberPaaGenMet1;
        %rotated_channel: Channels obtained with MPC phase rotation
        paaInfo{node_id}.nodePAAInfo{paa_id_init+paa_id,1}.rotated_channel = numberPaaCentroid(paaInfo{node_id}.centroids==unique_centroids(paa_id));
        %paa_id: indeces PAAs in cluster
        paaInfo{node_id}.nodePAAInfo{paa_id_init+paa_id,1}.paa_id = cell2mat(paaInfo{node_id}.paaInCluster(paaInfo{node_id}.centroids==unique_centroids(paa_id)).');
    end
    paa_id_init = 0;
    paaInfo{node_id}.centroidTimePosition = unique_PAA_location;
    paaInfo{node_id}.nPAA_centroids = size(paaInfo{node_id}.centroidTimePosition,2);
    paaInfo{node_id}.node_centroid(1:numberTimeDivision, 1:3)  =   squeezeAndReshape(nodeTimePosition(:, node_id,:));
end

end
