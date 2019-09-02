function outrev = reverseOutputTxRx(output)
%REVERSEOUTPUTTXRX Function to reverse Tx and Rx columns from output.
% Output format can be seen in LOSOutputGenerator or multipath functions.
%
% INPUT:
% - output: viriable with format given by LOSOutputGenerator or multipath
% OUTPUT:
% - outrev: output input variable with reversed Tx/Rx columns
%
% NOTE: Currently the code doesn't support variables for Tx/Rx
% Polarization, although in the output coulumns 14:17 describe
% PolarizationTx. As PolarizationRx is not present in the output variable,
% it is impossible to flip the two.
%
% SEE ALSO: LOSOUTPUTGENERATOR, MULTIPATH
outrev = output;

if isempty(output)
    return
end

% Flip all columns containing directional information between Rx and Tx
% Flip DoD/DoA
outrev(:,2:4) = output(:,5:7);
outrev(:,5:7) = output(:,2:4);

% Flip AoD/AoA Az/El
outrev(:,10:11) = output(:,12:13);
outrev(:,12:13) = output(:,10:11);

end