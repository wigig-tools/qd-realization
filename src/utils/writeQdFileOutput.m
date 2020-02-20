function writeQdFileOutput(output, useOptimizedOutputToFile,...
    fids, iTx, iRx, qdFilesPath, precision)
%WRITEQDFILEOUTPUT Writes timestamp information to QdFile
%
% INPUTS:
% - output: output matrix formatted as in MULTIPATH and LOSOUTPUTGENERATOR
% - useOptimizedOutputToFile: see PARAMETERCFG
% - fids: see GETQDFILESIDS
% - iTx: index of the TX
% - iRx: index of the RX
% - qdFilesPath: path to Output/Ns3/QdFiles
% - precision: floating point output precision in number of digits
%
% SEE ALSO: GETQDFILESIDS, CLOSEQDFILESIDS, MULTIPATH, LOSOUTPUTGENERATOR, PARAMETERCFG


% Copyright (c) 2019, University of Padova, Department of Information
% Engineering, SIGNET lab.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

if ~useOptimizedOutputToFile
    filename = sprintf('Tx%dRx%d.txt', iTx - 1, iRx - 1);
    filepath = fullfile(qdFilesPath, filename);
    fid = fopen(filepath, 'A');
else
    fid = fids(iTx, iRx);
end
    

numRays = size(output,1);
fprintf(fid, '%d\n', numRays);

if isempty(output)
    return
end

if any(any(isnan(output(:, [8, 9, 18, 11, 10, 13, 12]))))
    warning('Writing NaN in QD file')
end

floatFormat = sprintf('%%.%dg',precision);
formatSpec = [repmat([floatFormat,','],1,numRays-1), [floatFormat,'\n']];

% Stores delay [s]
fprintf(fid,formatSpec,output(:,8));

% Stores  path gain [dB]
fprintf(fid,formatSpec,output(:,9));

% Stores  phase [rad]
fprintf(fid,formatSpec,output(:,18));

% Stores Angle of departure elevation [deg]
fprintf(fid,formatSpec,output(:,11));

% Stores Angle of departure azimuth [deg]
fprintf(fid,formatSpec,output(:,10));

% Stores Angle of arrival elevation [deg]
fprintf(fid,formatSpec,output(:,13));

% Stores Angle of arrival azimuth [deg]
fprintf(fid,formatSpec,output(:,12));

if ~useOptimizedOutputToFile
    fclose(fid);
end

end