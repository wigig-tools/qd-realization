function ddirTxRx = ddir2MIMOtarget(ddirInTxTrg, ddirInTrgRx, info, ptr)
%%DDIR2MIMOTARGET Converts the double direction impulse response in the MIMO
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

%% Overwrite angles

nMpcTxTrg = size(ddirInTxTrg,1);
nMpcTrgRx = size(ddirInTrgRx,1);
orientation.tx = info{ptr.nt}.orientation{ptr.paatx};
orientation.rx = info{ptr.nr}.orientation{ptr.paarx};
ddirTxRx = zeros(nMpcTxTrg*nMpcTrgRx,21);

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
        ddirTxRx(rowOut,9) = mpcTxTrg(9)+mpcTrgRx(9)+10*log10(4*pi/(0.005^2))-8; 
        ddirTxRx(rowOut,10) = aodAz;
        ddirTxRx(rowOut,11) = aodEl;
        ddirTxRx(rowOut,12) = aoaAz;
        ddirTxRx(rowOut,13) = aoaEl;
        ddirTxRx(rowOut,18) = mpcTxTrg(18)+mpcTrgRx(18); % phase
        ddirTxRx(rowOut,20) = mpcTxTrg(19)+mpcTrgRx(19);
        ddirTxRx(rowOut,21) = 0;
        
    end
end


end