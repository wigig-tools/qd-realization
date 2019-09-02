function closeQdFilesIds(fids)
%CLOSEQDFILESIDS Closes and flushes opened QdFiles given in the fids matrix
% INPUT
% - fids: matrix of file IDs previously opened. The main diagonal is
% NaN-filled
%
% SEE ALSO: GETQDFILESIDS, WRITEQDFILEOUTPUT
for i = 1:numel(fids)
    if ~isnan(fids(i))
        fclose(fids(i));
    end
end

end