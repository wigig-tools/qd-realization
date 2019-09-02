function [CADop, switchMaterial] =...
    getCadOutput(environmentFileName, inputPath, MaterialLibrary,...
    referencePoint, selectPlanesByDist, indoorSwitch)
%GETCADOUTPUT Function to handle smart CAD file import. It tries to create
% a .mat cache file containing the preprocessed CAD file, as importing a
% raw CAD can be vary time consuming.
% The code checks whether a cache already exist and, if so, whether it is
% older than the CAD file. If the cache does not exist or is outdated,
% import the CAD from scratch a create (or overwrite) the cached output,
% otherwise quickly import the cache.
%
% INPUTS:
% - environmentFileName: file name of CAD environment
% - inputPath: input path of selected scenario, containing environmentFileName
% - MaterialLibrary: see XMLREADER
% - referencePoint: see XMLREADER
% - selectPlanesByDist: see XMLREADER
% - indoorSwitch: see XMLREADER
%
% OUTPUTS: Same outputs as XMLREADER
% 
% SEE ALSO: XMLREADER
%
% TODO: license

% Importing CAD/AMF/XML files is very slow, especially for large scenarios
% Check first if cached
cacheFilePath = strcat(inputPath, '/cachedCadOutput.mat');
environmentFilePath = strcat(inputPath, '/', environmentFileName);

if exist(cacheFilePath, 'file')
    cacheAttribs = dir(cacheFilePath);
    envirnomentAttribs = dir(environmentFilePath);
    
    % If the cache is older than the env. file, it might have been changed
    % Load it only if cache is recent
    if cacheAttribs.datenum >= envirnomentAttribs.datenum
        load(cacheFilePath,...
            'CADop', 'switchMaterial');
        return
        
    else
        warning('Cache file exists but might be outdated. Ignoring it.')
        
    end
end

% Cache either does not exist or outdated
tmpXmlFilePath = strcat(inputPath, '/CADFile.xml');

[~,~,extension] = fileparts(environmentFileName);
switch(extension(2:end))
    case {'xml', 'amf'}
        copyfile(environmentFilePath, tmpXmlFilePath);
        
    otherwise
        error('Cannot handle ''%s'' extension properly', extension)
        
end

[CADop, switchMaterial] = xmlreader(tmpXmlFilePath,...
    MaterialLibrary, referencePoint, selectPlanesByDist, indoorSwitch);

delete(tmpXmlFilePath);
save(cacheFilePath, 'CADop', 'switchMaterial');

end