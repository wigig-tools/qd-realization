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

% Modified by: Neeraj Varshney <neeraj.varshney@nist.gov>, for new material
% library in txt format

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
tab = table('Size', [0,26],...
    'VariableTypes', {'cellstr',... % Reflector
    'double','double',... % n_Precursor, n_Postcursor
    'double','double',... % (s/sigma)_K_Precursor
    'double','double',... % (s/sigma)_K_Postcursor
    'double','double',... % (s/sigma)_gamma_Precursor
    'double','double',... % (s/sigma)_gamma_Postcursor
    'double','double',... % (s/sigma)_sigmaS_Precursor
    'double','double',... % (s/sigma)_sigmaS_Postcursor
    'double','double',... % (s/sigma)_lambda_Precursor
    'double','double',... % (s/sigma)_lambda_Postcursor
    'double','double',... % (s/sigma)_sigmaAlphaAz
    'double','double',... % (s/sigma)_sigmaAlphaEl
    'double','double',... % (s/sigma)_RL
    'double'},... % mu_RL
    'VariableNames', {'Reflector',...
    'n_Precursor','n_Postcursor',...
    's_K_Precursor','sigma_K_Precursor',...
    's_K_Postcursor','sigma_K_Postcursor',...
    's_gamma_Precursor','sigma_gamma_Precursor',...
    's_gamma_Postcursor','sigma_gamma_Postcursor',...
    's_sigmaS_Precursor','sigma_sigmaS_Precursor',...
    's_sigmaS_Postcursor','sigma_sigmaS_Postcursor',...
    's_lambda_Precursor','sigma_lambda_Precursor',...
    's_lambda_Postcursor','sigma_lambda_Postcursor',...
    's_sigmaAlphaAz','sigma_sigmaAlphaAz',...
    's_sigmaAlphaEl','sigma_sigmaAlphaEl',...
    's_RL','sigma_RL','mu_RL'});

i = 1;
while ~feof(fid)
    line = fgetl(fid);
    line = replace(line,'""','"0"'); % convert "" to "0"
    line = replace(line,'"',''); % remove ""
    tab(i,:) = textscan(line,'%q%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Delimiter',',');
    
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