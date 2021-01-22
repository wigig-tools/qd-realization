function tab = importMaterialLibrary(path)
%IMPORTMATERIALLIBRARY Import material library in a table. Assumes the
% structure described in the documentation.
%
% INPUTS:
% - path: path and file name of the material library to be imported
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

[~, ~, ext] = fileparts(path);

switch(ext)
    case '.txt'
        tab = importTxtMaterialLibrary(path);
    case '.csv'
        tab = importCsvMaterialLibrary(path);
    otherwise
        error('Exension ''%s'' not supported for material libraries', ext)
end

end

%% Importing different material library extensions
% TXT
function tab = importTxtMaterialLibrary(path)

fid = fopen(path);

fgetl(fid); % ignore first line: hard code column names
tab = table('Size', [0,19],...
    'VariableTypes', {'double','cellstr',... % PrimaryKey, Reflector
    'double','double',... % (mu/sigma)_k_Precursor
    'double','double',... % (mu/sigma)_k_Postcursor
    'double','double',... % (mu/sigma)_Y_Precursor
    'double','double',... % (mu/sigma)_Y_Postcursor
    'double','double',... % (mu/sigma)_lambda_Precursor
    'double','double',... % (mu/sigma)_lambda_Postcursor
    'double','double',... % (mu/sigma)_sigmaTheta
    'double','double',... % (mu/sigma)_RL
    'double'},... % DielectricConstat
    'VariableNames', {'PrimaryKey', 'Reflector',...
    'mu_k_Precursor','sigma_k_Precursor',...
    'mu_k_Postcursor','sigma_k_Postcursor',...
    'mu_Y_Precursor','sigma_Y_Precursor',...
    'mu_Y_Postcursor','sigma_Y_Postcursor',...
    'mu_lambda_Precursor','sigma_lambda_Precursor',...
    'mu_lambda_Postcursor','sigma_lambda_Postcursor',...
    'mu_sigmaTheta','sigma_sigmaTheta',...
    'mu_RL','sigma_RL',...
    'DielectricConstant'});

i = 1;
while ~feof(fid)
    line = fgetl(fid);
    line = replace(line,'""','"0"'); % convert "" to "0"
    line = replace(line,'"',''); % remove ""
    tab(i,:) = textscan(line,'%d%q%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Delimiter',',');
    
    i = i+1;
end

fclose(fid);

end

% CSV
function tab = importCsvMaterialLibrary(path)

if contains(pwd, 'test')
    path  = fullfile('..\src', path);
end

tab = readtable(path);

end