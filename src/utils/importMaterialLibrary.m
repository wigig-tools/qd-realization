function tab = importMaterialLibrary(path)
%IMPORTMATERIALLIBRARY Import material library in a table. Assumes the
% structure described in the documentation.
%
% INPUT:
% - path: path and file name of the material library to be imported
% OUTPUT:
% - tab: table version of the material library
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