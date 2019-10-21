function writeQdFileOutput(output, fid, precision)
%WRITEQDFILEOUTPUT Writes timestamp information to QdFile
%
% INPUTS:
% - output: output matrix formatted as in MULTIPATH and LOSOUTPUTGENERATOR
% - fid: File ID of the target file
% - precision: floating point output precision in number of digits
%
% SEE ALSO: GETQDFILESIDS, CLOSEQDFILESIDS, MULTIPATH, LOSOUTPUTGENERATOR


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

end