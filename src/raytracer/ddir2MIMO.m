function [ch, varargout] = ddir2MIMO(ddirIn, info, ptr)
%%DDIR2MIMO Converts the double direction impulse response in the MIMO 
% channel matrix assigning phase rotations according with PAA centroids 
% positions and angles of departure/arrival
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

[~,b] = unique(info{ptr.nt}.centroids);
b = sort(b);
idx = find(info{ptr.nt}.centroids == info{ptr.nt}.centroids(b(ptr.paatx)));
t= idx(ptr.iid_tx); %Pointer to centroid in cell array in info{ptr.nt}

[~,b] = unique(info{ptr.nr}.centroids);
b = sort(b);
idx = find(info{ptr.nr}.centroids == info{ptr.nr}.centroids(b(ptr.paarx)));
r= idx(ptr.iid_rx); %Pointer to centroid in cell array in info{ptr.nr}

%% Overwrite angles

nAod = info{ptr.nt}.nodePAAInfo{ptr.paatx}.rotated_channel(ptr.iid_tx);
nAoa = info{ptr.nr}.nodePAAInfo{ptr.paarx}.rotated_channel(ptr.iid_rx);

ch = zeros([size(ddirIn), nAod*nAoa]);

for idAod = 1:nAod
    for idAoa = 1:nAoa
        ddir = ddirIn;
        orientation.tx = info{ptr.nt}.orientation{t}(idAod,:);
        orientation.rx = info{ptr.nr}.orientation{r}(idAoa,:);
        ddir(:, 2:4) = coordinateRotation(ddir(:,2:4), [0, 0, 0], orientation.tx, 'frame');
        ddir(:, 5:7) = coordinateRotation(ddir(:,5:7), [0, 0, 0], orientation.rx, 'frame');
        [aodAz, aodEl] = vector2angle(ddir(:, 2:4));
        [aoaAz, aoaEl] = vector2angle(ddir(:, 5:7));
        ddir(:,10) = aodAz;
        ddir(:,11) = aodEl;
        ddir(:,12) = aoaAz;
        ddir(:,13) = aoaEl;
        R_AOD = phaseRotation(aodAz,aodEl, info{ptr.nt}.centroidsShift{t}(idAod,:));
        R_AOA = phaseRotation(aoaAz,aoaEl, info{ptr.nr}.centroidsShift{r}(idAoa,:));
        
        ch(:,:, (idAod-1)*(nAoa)+idAoa) = ddir;
        ch(:,18, (idAod-1)*(nAoa)+idAoa) = wrapTo2Pi(ch(:,18,idAod)+angle(R_AOD)+angle(R_AOA));
    end
end
[A,B] = meshgrid(info{ptr.nt}.paaInCluster{t}, info{ptr.nr}.paaInCluster{r});
varargout{1} = [A(:), B(:)];
end