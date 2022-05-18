function [ch, varargout] = ddir2MIMOtarget(ddirInTxTrg, ddirInTrgRx, info, ptr,trgtFriisFactor)
%%DDIR2MIMOTARGET Converts the double direction impulse response in the MIMO
% channel matrix assigning phase rotations according with PAA centroids
% positions and angles of departure/arrival
%
% ch = DDIR2MIMOTARGET(TT, TR, I, P, RCS) returns the tx-target-rx MIMO
% channel given the TT tx-target channel, the TR target-receiver channel,
% the cell array with PAA information I, the pointer P to the entry of I
% and the radar cross section RCS.
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


nMpcTxTrg = size(ddirInTxTrg,1);
nMpcTrgRx = size(ddirInTrgRx,1);
orientation.tx = info{ptr.nt}.orientation{ptr.paatx};
orientation.rx = info{ptr.nr}.orientation{ptr.paarx};
ddirTxRx = zeros(nMpcTxTrg*nMpcTrgRx,21);
paaTx = info{ptr.nt}.nodePAAInfo{ptr.paatx}.rotated_channel(ptr.iid_tx);
paaRx = info{ptr.nr}.nodePAAInfo{ptr.paarx}.rotated_channel(ptr.iid_rx);
ch = zeros([size(ddirTxRx),paaTx*paaRx]);

for pT = 1: paaTx
    for pR = 1: paaRx
        
        for txTr = 1:nMpcTxTrg
            for trRx =  1:nMpcTrgRx
                
                mpcTxTrg = ddirInTxTrg(txTr,:);
                mpcTrgRx = ddirInTrgRx(trRx,:);
                
                dod = coordinateRotation(mpcTxTrg(:,2:4), [0, 0, 0], orientation.tx, 'frame'); %ddirInTxTrg %ddir(:, 2:4)
                doa = coordinateRotation(mpcTrgRx(:,5:7), [0, 0, 0], orientation.rx, 'frame'); %ddirInTrgRx % ddir(:, 5:7)
                [aodAz, aodEl] = vector2angle(dod);
                [aoaAz, aoaEl] = vector2angle(doa);
                rowOut =  (txTr-1)*nMpcTrgRx+ trRx;
                ddirTxRx(rowOut,1) = rowOut;
                ddirTxRx(rowOut,2:4) = dod;
                ddirTxRx(rowOut,5:7) = doa;
                ddirTxRx(rowOut,8) = mpcTxTrg(8)+mpcTrgRx(8);
                ddirTxRx(rowOut,9) = mpcTxTrg(9)+mpcTrgRx(9)+trgtFriisFactor;
                ddirTxRx(rowOut,10) = aodAz;
                ddirTxRx(rowOut,11) = aodEl;
                ddirTxRx(rowOut,12) = aoaAz;
                ddirTxRx(rowOut,13) = aoaEl;
                phaseAod = phaseRotation(aodEl,aodAz, info{ptr.nt}.centroidsShift{t}(pT,:));
                phaseAoa = phaseRotation(aoaEl,aoaAz, info{ptr.nr}.centroidsShift{r}(pR,:));
                ddirTxRx(rowOut,18) = wrapTo2Pi(mpcTxTrg(18)+mpcTrgRx(18)+angle(phaseAod)+angle(phaseAoa)); % phase
                ddirTxRx(rowOut,20) = mpcTxTrg(19)+mpcTrgRx(19);
                ddirTxRx(rowOut,21) = 0;
                
            end
        end
        
        ch(:,:, paaRx*(pT-1)+ pR) = ddirTxRx;
    end
    
end


[A,B] = meshgrid(info{ptr.nt}.paaInCluster{t}, info{ptr.nr}.paaInCluster{r});
varargout{1} = [A(:), B(:)];

end