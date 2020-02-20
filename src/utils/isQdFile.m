function b = isQdFile(path)
%ISQDFILE Function that checks whether the given path matches with
% the expected QD file output file position (as given by the
% documentation). This allows to safely read the file later.
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% SEE ALSO: READQDFILE


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

[remainingPath, fileName, extension] = fileparts(path);
b = ~isempty(regexp([fileName, extension], 'Tx[\d]+Rx[\d]+.txt', 'once'));

[remainingPath, qdFilesFolder] = fileparts(remainingPath);
b = b && strcmp(qdFilesFolder, 'QdFiles');

[remainingPath, ns3Folder] = fileparts(remainingPath);
b = b && strcmp(ns3Folder, 'Ns3');

[~, outputFolder] = fileparts(remainingPath);
b = b && strcmp(outputFolder, 'Output');

end