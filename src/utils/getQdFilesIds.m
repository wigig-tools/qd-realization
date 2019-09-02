function fids = getQdFilesIds(qdFilesPath,numberOfNodes)
%GETQDFILESIDS Opens/creates all QdFiles with 'At' permission (create or
% append to text file without automatic flushing).
%
% INPUTS
% - qdFilesPath: folder path to QdFiles
% - numberOfNodes: number of nodes in the simulation
% OUTPUT
% - fids: matrix of File IDs. The main diagonal is NaN-filled
%
% SEE ALSO: CLOSEQDFILESIDS, WRITEQDFILEOUTPUT
fids = nan(numberOfNodes, numberOfNodes);

for iTx = 1:numberOfNodes
    for iRx = 1:numberOfNodes
        if iTx == iRx
            continue
        end
        
        filename = sprintf('Tx%dRx%d.txt', iTx-1, iRx-1);
        filepath = [qdFilesPath, '/', filename];
        
        fids(iTx,iRx) = fopen(filepath,'At');
    end
end

end