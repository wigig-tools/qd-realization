function tab = importIntraClusterParameters(path)
% importIntraClusterParameters function imports intra cluster parameters in a table. Assumes the
% structure described in the documentation.
%
% INPUTS:
% - path: path and name of the intra cluster parameter file to be imported
%
% OUTPUTS:
% - tab: table version of the material library


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

% Modified by: Neeraj Varshney <neeraj.varshney@nist.gov>, to import
% intra-cluster parameters
[~, ~, ext] = fileparts(path);

switch(ext)
    case '.txt'
        tab = importTxtIntraClusterParameters(path);
    case '.csv'
        tab = importCsvIntraClusterParameters(path);
    otherwise
        error('Exension ''%s'' not supported for material libraries', ext)
end

end

%% Importing different material library extensions
% TXT
function tab = importTxtIntraClusterParameters(path)

fid = fopen(path);

fgetl(fid); % ignore first line: hard code column names
tab = table('Size', [0,10],...
    'VariableTypes', {'cellstr',... % Scenario
    'double','double',... % nPre,KfactorPre,
    'double','double',... % gammaPre,lambdaPre,
    'double','double',... % nPost,KfactorPost,
    'double','double','double'},... % gammaPost,sigma
    'VariableNames', {'Scenario', 'nPre',...
    'KfactorPre','gammaPre',...
    'lambdaPre','nPost',...
    'KfactorPost','gammaPost',...
    'lambdaPost','sigma'});

i = 1;
while ~feof(fid)
    line = fgetl(fid);
    line = replace(line,'""','"0"'); % convert "" to "0"
    line = replace(line,'"',''); % remove ""
    tab(i,:) = textscan(line,'%q%f%f%f%f%f%f%f%f%f','Delimiter',',');
    
    i = i+1;
end

fclose(fid);

end

% CSV
function tab = importCsvIntraClusterParameters(path)

if contains(pwd, 'test')
    path  = fullfile('..\src', path);
end

tab = readtable(path);

end