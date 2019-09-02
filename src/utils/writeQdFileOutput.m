function writeQdFileOutput(output, fid, precision)
%WRITEQDFILEOUTPUT Writes timestamp information to QdFile
% INPUTS:
% - output: output matrix formatted as in MULTIPATH and LOSOUTPUTGENERATOR
% - fid: File ID of the target file
% - precision: floating point output precision in number of digits
%
% SEE ALSO: GETQDFILESIDS, CLOSEQDFILESIDS, MULTIPATH, LOSOUTPUTGENERATOR
numRays = size(output,1);
fprintf(fid, '%d\n', numRays);

if isempty(output)
    return
end

floatFormat = sprintf('%%.%dg',precision);
formatSpec = [repmat([floatFormat,','],1,numRays-1), [floatFormat,'\n']];

% Stores delay (secs)
fprintf(fid,formatSpec,output(:,8));

% Stores  path gain (dB)
fprintf(fid,formatSpec,output(:,9));

% Stores  phase (radians)
fprintf(fid,formatSpec,output(:,18));

% Stores Angle of departure elevation
fprintf(fid,formatSpec,output(:,11));

% Stores Angle of departure azimuth
fprintf(fid,formatSpec,output(:,10));

% Stores Angle of arrival elevation
fprintf(fid,formatSpec,output(:,13));

% Stores Angle of arrival azimuth
fprintf(fid,formatSpec,output(:,12));

% formatSpecLine = [repmat('%.9g,',1,numRays-1), '%.9g\n'];
% formatSpecMatrix = repmat(formatSpecLine,1,7);
% 
% fprintf(fid,formatSpecMatrix, output(:, [8,9,18,11,10,13,12]));

end