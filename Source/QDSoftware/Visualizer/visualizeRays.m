function [] = visualizeRays(Tri,X,Y,Z,visualizerPath,txIndex,rxIndex,saveGif,orderColor)
%VISUALIZERAYS Utility to quickly plot the rays in a given scenario
%   Detailed explanation goes here

if orderColor
    colorMap = ['k','r','b','o','g','c','m'];
end
scenarioName = string({extractBetween(visualizerPath,'../','/Output')});

nodeFolder = [visualizerPath,'/NodePositions/']; % create the path to the node positions files
nodeFileList = dir(nodeFolder); % list files and directories
nodeFileList = nodeFileList(~[nodeFileList.isdir]); % remove dirs, keep files only
nodeFileList = string({nodeFileList.name});
totalTimeStepsNodes = length(nodeFileList);

mpcFolder = [visualizerPath,'/MpcCoordinates/'];
mpcFileList = dir(mpcFolder);
mpcFileList = mpcFileList(~[mpcFileList.isdir]);
mpcFileList = string({mpcFileList.name});
selTxRx = contains(mpcFileList,sprintf('Tx%dRx%d',txIndex,rxIndex));
if ~any(selTxRx)
    error('The nodes you selected are not present in the scenario.')
end
mpcFileList = mpcFileList(selTxRx);
totalFileList = length(mpcFileList);

mpc = struct('reflOrd',cell(totalFileList,1),'coord',cell(totalFileList,1));
for i = 1:length(mpcFileList)
    timeStep = double(extractBetween(mpcFileList(i),'Trc','.csv'));
    
    reflectOrder = double(extractBetween(mpcFileList(i),'Refl','Trc'));
    mpc(timeStep+1).reflOrd(reflectOrder+1) = reflectOrder;
    
    reflectCoord = readMpcCoordinates(strcat(mpcFolder, mpcFileList(i)));
    mpc(timeStep+1).coord(reflectOrder+1,:) = {reflectCoord};
end
totalMpcNodes = sum(~cellfun(@isempty,{mpc.reflOrd}));
overallTimeSteps = max(totalTimeStepsNodes,totalMpcNodes); 
mpc = mpc(1:overallTimeSteps);

% plotting
h = figure('Position', [10 10 900 600]);

if saveGif
    filename = strcat(scenarioName, '-trc.gif');
end
for timeStep = 1:overallTimeSteps % open each file (one per time step)
    
    reflOrd = [mpc(timeStep).reflOrd];
    for order = reflOrd
        rayCoord = cell2mat(mpc(timeStep).coord(order+1));
        nRays = size(rayCoord,1);
        for ray = 1:nRays
            currRayCoord = rayCoord(ray,:);
            currRayCoord = reshape(currRayCoord,[3,order+2]).'; % convert to matrix: (pointID) x (coord), i.e. number of reflections x 3
            plot3(currRayCoord(:,1),currRayCoord(:,2),currRayCoord(:,3),colorMap(order+1))
            hold on
        end
    end
    trisurf(Tri,X,Y,Z,'FaceColor',[0.9,0.9,0.9],'FaceAlpha',0.4,'EdgeColor','k')
    hold on
    
    nodePos = readNodePositions([nodeFolder,sprintf('/NodePositionsTrc%d.csv',timeStep-1)]);
    txPos = nodePos(txIndex+1,:);
    rxPos = nodePos(rxIndex+1,:);
    
    scatter3(txPos(1),txPos(2),txPos(3),[],'r','filled');
    text(txPos(1),txPos(2),txPos(3),'TX','HorizontalAlignment',...
        'left','FontSize',12,'FontWeight','bold');
    hold on
    
    scatter3(rxPos(1),rxPos(2),rxPos(3),[],'b','filled');
    text(rxPos(1),rxPos(2),rxPos(3),'RX','HorizontalAlignment',...
        'left','FontSize',12,'FontWeight','bold','Position',[1,5,5]);

    
    view(30,40)
    hold off
    if saveGif
        drawnow
        % Capture the plot as an image
        frame = getframe(h);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        % Write to the GIF File
        if timeStep == 1
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.005);
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.005);
        end
    end
end

end

