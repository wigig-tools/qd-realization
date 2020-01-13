function closeQdFilesIds(fids, useOptimizedOutputToFile)
%CLOSEQDFILESIDS Closes and flushes opened QdFiles given in the fids matrix
%
% INPUTS:
% - fids: matrix of file IDs previously opened. The main diagonal is
% NaN-filled
% - useOptimizedOutputToFile: see PARAMETERCFG
%
% SEE ALSO: GETQDFILESIDS, WRITEQDFILEOUTPUT, PARAMETERCFG


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
    % do nothing, files are already closed
    return
end

for i = 1:numel(fids)
    if ~isnan(fids(i))
        fclose(fids(i));
    end
    
end

end