function [outputPath] = Raytracer(paraCfgInput,nodeCfgInput)
% Inputs:
% RootFolderPath - it is the current location of the folder where the function is called from
% environmentFileName - it is the CAD file name
% switchRandomization - boolean to either randomly generates nodes and velocity or not
% mobilitySwitch -  is boolean to either have mobility or not
% totalNumberOfReflections - is the highest order of reflections to be computed
% switchQDGenerator - Switch to turn ON or OFF the Qausi dterministic module 1 = ON, 0 = OFF
% nodeLoc - 2d array which contains all node locations
% nodeVelocities - 2d array which contains all node velocities
% nodePolarization - 2d array which contains all node polarization
% nodeAntennaOrientation - 2d array which contains all node antenna orientation
% totalTimeDuration, n1 are for granularity in time domain. t is total period and n is the
% number of divisions of that time period
% mobilityType - This switch lets the user to decide the input to mobility
% 1 = Linear, 2 = input from File
% nodePosition - these are positions of nodes in a 2D array which are
% extracted from a file
% indoorSwitch - This boolean lets user say whether the given CAD file
% is indoor or outdorr. If indoor, then the value is 1 else the value is 0.
% generalizedScenario - This boolean lets user say whether a scenario
% conforms to a regular indoor or outdoor environment or it is a more
% general scenario.
% selectPlanesByDist - This is selection of planes/nodes by distance. 
% r = 0 means that there is no limitation.  
% referencePoint - Reference point is the center of limiting sphere 
%
% Outputs:
% N/A


% -------------Software Disclaimer---------------
%
% NIST-developed software is provided by NIST as a public service. You may use, copy
% and distribute copies of the software in any medium, provided that you keep intact this
% entire notice. You may improve, modify and create derivative works of the software or
% any portion of the software, and you may copy and distribute such modifications or
% works. Modified works should carry a notice stating that you changed the software
% and should note the date and nature of any such change. Please explicitly
% acknowledge the National Institute of Standards and Technology as the source of the
% software.
%
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
% OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
% WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
% NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS
% NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE
% UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE
% CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF,
% INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
% RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% anddistributing the software and you assume all risks associated with its use, including
% but not limited to the risks and costs of program errors, compliance with applicable
% laws, damage to or loss of data, programs or equipment, and the unavailability or
% interruption of operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property. The software
% developed by NIST employees is not subject to copyright protection within the United
% States.



%% Input Parameters Management
environmentFileName = paraCfgInput.environmentFileName;
generalizedScenario = paraCfgInput.generalizedScenario;
indoorSwitch = paraCfgInput.indoorSwitch;
inputScenarioName = paraCfgInput.inputScenarioName;
mobilitySwitch = paraCfgInput.mobilitySwitch;
mobilityType = paraCfgInput.mobilityType;
numberOfNodes = paraCfgInput.numberOfNodes;
numberOfTimeDivisions = paraCfgInput.numberOfTimeDivisions;
selectPlanesByDist = paraCfgInput.selectPlanesByDist;
referencePoint = paraCfgInput.referencePoint;
switchQDGenerator = paraCfgInput.switchQDGenerator;
switchRandomization = paraCfgInput.switchRandomization;
switchVisuals = paraCfgInput.switchVisuals;
totalNumberOfReflections = paraCfgInput.totalNumberOfReflections;
totalTimeDuration = paraCfgInput.totalTimeDuration;

nodeLoc = nodeCfgInput.nodeLoc;
nodeAntennaOrientation = nodeCfgInput.nodeAntennaOrientation;
nodePolarization = nodeCfgInput.nodePolarization;
nodePosition = nodeCfgInput.nodePosition;
nodeVelocities = nodeCfgInput.nodeVelocities;

% Input checking
if paraCfgInput.switchQDGenerator == 1 &&...
        paraCfgInput.carrierFrequency ~= 60e9
    warning(['Please, note that diffuse scattering model is only ',...
        'valid for fc=60 GHz'])
end

% List of paths
inputPath = strcat(inputScenarioName, '/Input');
outputPath = strcat(inputScenarioName, '/Output');

ns3Path = strcat(outputPath, '/Ns3');
qdFilesPath = strcat(ns3Path, '/QdFiles');

if paraCfgInput.switchSaveVisualizerFiles == 1
    visualizerPath = strcat(outputPath, '/Visualizer');
    
    nodePositionsPath = strcat(visualizerPath, '/NodePositions');
    roomCoordinatesPath = strcat(visualizerPath, '/RoomCoordinates');
    mpcCoordinatesPath = strcat(visualizerPath, '/MpcCoordinates');
end

% Subfolders creation
if ~isfolder(qdFilesPath)
    mkdir(qdFilesPath)
end

if paraCfgInput.switchSaveVisualizerFiles == 1
    
    if ~isfolder(nodePositionsPath)
        mkdir(nodePositionsPath)
    end
    if ~isfolder(roomCoordinatesPath)
        mkdir(roomCoordinatesPath)
    end
    if ~isfolder(mpcCoordinatesPath)
        mkdir(mpcCoordinatesPath)
    end
    
end

% Init output files
fids = getQdFilesIds(qdFilesPath,numberOfNodes);

%% ------------ Original Raytracer --------------

Tx = nodeLoc(1,:);
Rx = nodeLoc(2,:);
vtx = nodeVelocities(1,:);
vrx = nodeVelocities(2,:);


if switchVisuals == 1
    f1 = figure;
    set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    view([9 90]) % change view for f1 here
    hold on
end

colorArray = ['selectPlanesByDistInput', 'c', 'g', 'y', 'y', 'b', 'k'];
lineArray = [1.8, 0.3];

%-----------------Polarization Part Omitted------------------------------%
% Polarization_switch=0;
% switch_cp=0;
% Polarization_tx = [0,1];
% Polarization_rx = [0,1];
%-----------------Polarization Part Omitted------------------------------%
AntennaOrientationTx = [1, 0, 0; 0, 1, 0; 0, 0, 1];

AntennaOrientationRx = [1, 0, 0; 0, 1, 0; 0, 0, 1];
multipath1 = [];
output = [];
MaterialLibrary = importMaterialLibrary('raytracer/Material_library.txt');
%-----------------Polarization Part Omitted------------------------------%
% number_of_nodes=2;
% switch_randomization=0;
% switch_distance_limitation=0;
% selectPlanesByDistInput=10;
% if switch_distance_limitation==0
%     selectPlanesByDistInput=0;
% end
% if Polarization_switch==1
%     if switch_cp==1
%         try
%             switch_cp=(Polarization_tx(2,2)==Polarization_tx(2,2));
%             switch_cp=(Polarization_rx(2,2)==Polarization_rx(2,2));
%         catch
%             switch_cp=0;
%         end
%     end
% else
%     switch_cp=0;
% end
%-----------------Polarization Part Omitted------------------------------%

% indoorSwitchInput = 1;

% environmentFileName = 'Box.xml';       % courtesy - http://amf.wikispaces.com/AMF+test+files

%Reference point is the center of limiting sphere. 
% referencePoint = Tx;

% This is selection of planes/nodes by distance. selectPlanesByDistInput = 0 means that there is
% no limitation. 
% selectPlanesByDistInput = 0;

%% Extracting CAD file and storing in an XMl file, CADFile.xml
[CADop, switchMaterial] = getCadOutput(environmentFileName,...
    inputPath, MaterialLibrary, referencePoint, selectPlanesByDist, indoorSwitch);

if paraCfgInput.switchSaveVisualizerFiles == 1
    % Save output file with room coordinates for visualization
    RoomCoordinates = CADop(:, 1:9);
    csvwrite(sprintf('%s/RoomCoordinates.csv',roomCoordinatesPath),...
        RoomCoordinates);
end
% channel model figure activates only when material data is present
% if switchMaterial==1 && switchVisualsInput == 1
%     f2=figure;
%     %For f2 to be displayed in full screen
%     set(gcf,'units','normalized','outerposition',[0 0 1 1])
% end

% node_map is a 2D matrix which holds the permutations of different pairs
% of Tx and Rx.

str = cell(numberOfNodes, numberOfNodes);


%% Randomization
%if number of nodes is greater than 1 or switch_randomization is set to 1,
%the program generates nodes randomly. If one has more than 2 nodes but
%know the exact locations of nodes, then disable this if statement and
%replace node and node_v with the values of node positions and node
%velocities repsectively

TxInitial = Tx;
RxInitial = Rx;
% t - total time period, n - number of divisions
if mobilitySwitch == 1
    timeDivisionValue = totalTimeDuration / numberOfTimeDivisions;
else
    numberOfTimeDivisions = 0;
    timeDivisionValue = 0;
end

% Finite difference method to simulate mobility. x=x0 + v*dt.
% This method ensures the next position wouldnt collide with any of the
% planes. If that occurs then the velocities are simply reversed (not
% reflected). At every time step the positions of all nodes are updated

for iterateTimeDivision = 0:numberOfTimeDivisions
    if mobilitySwitch == 1
        
        if switchVisuals == 1
            set(0, 'CurrentFigure', f1)
            clf
            view([9 90])

            if switchMaterial == 1 
                set(0, 'CurrentFigure',  f1)
            end
        end
        
    end
    
    if mobilityType == 1
        if numberOfNodes == 2
            [nodeLoc,Tx,Rx,vtx, vrx, nodeVelocities] = LinearMobility...
                (numberOfNodes, switchRandomization, ...
                iterateTimeDivision, nodeLoc, nodeVelocities, vtx,...
                vrx,TxInitial, RxInitial, timeDivisionValue,...
                CADop, Tx, Rx);
        else
            [nodeLoc,Tx,Rx,vtx, vrx, nodeVelocities] = LinearMobility...
                (numberOfNodes, switchRandomization,...
                iterateTimeDivision, nodeLoc, nodeVelocities,...
                [], [], TxInitial, RxInitial, timeDivisionValue, ...
                CADop, Tx, Rx);
        end
        
    elseif mobilityType == 2
        [nodeLoc, nodeVelocities] = NodeExtractor...
            (numberOfNodes,  switchRandomization, ...
            iterateTimeDivision, nodeLoc, nodeVelocities, nodePosition, timeDivisionValue);
    end
    
    if paraCfgInput.switchSaveVisualizerFiles == 1 && mobilitySwitch >=0
        csvwrite(sprintf('%s/NodePositionsTrc%d.csv',...
            nodePositionsPath, iterateTimeDivision),...
            nodeLoc);
    end
    
    % Iterates through all the nodes
    
    for iterateTx = 1:numberOfNodes
        for iterateRx = iterateTx+1:numberOfNodes
            
            output = [];
            if (numberOfNodes >= 2 || switchRandomization == 1)
                Tx = nodeLoc(iterateTx, :);
                Rx = nodeLoc(iterateRx, :);

                vtx = nodeVelocities(iterateTx, :);
                vrx = nodeVelocities(iterateRx, :);
%                 elseif (numberOfNodesInput == 2 && iterateTx == 2)
%                     RxTemp = Rx;
%                     Rx = Tx;
%                     Tx = RxTemp;
                    
%-----------------Polarization Part Omitted------------------------------%                    
%                     if Polarization_switch==1 && switch_cp==0
%                         Polarization_tx = [nodePolarization(iterateTx,1),...
%                             nodePolarization(iterateTx,2)];
%                         AntennaOrientationTx=[nodeAntennaOrientation(iterateTx,1,1),...
%                             nodeAntennaOrientation(iterateTx,1,2),nodeAntennaOrientation(iterateTx,1,3);...
%                             nodeAntennaOrientation(iterateTx,2,1),nodeAntennaOrientation(iterateTx,2,2),...
%                             nodeAntennaOrientation(iterateTx,2,3);nodeAntennaOrientation(iterateTx,3,1),...
%                             nodeAntennaOrientation(iterateTx,3,2),nodeAntennaOrientation(iterateTx,3,3)];
%                         Polarization_rx = [nodePolarization(iterateRx,1),...
%                             nodePolarization(iterateRx,2)];
%                         AntennaOrientationRx=[nodeAntennaOrientation(iterateRx,1,1),...
%                             nodeAntennaOrientation(iterateRx,1,2),nodeAntennaOrientation(iterateRx,1,3);...
%                             nodeAntennaOrientation(iterateRx,2,1),nodeAntennaOrientation(iterateRx,2,2),...
%                             nodeAntennaOrientation(iterateRx,2,3);nodeAntennaOrientation(iterateRx,3,1),...
%                             nodeAntennaOrientation(iterateRx,3,2),nodeAntennaOrientation(iterateRx,3,3)];
%                     end
%-----------------Polarization Part Omitted------------------------------%

            end
                
            %% LOS Path generation
            % Plot the figure outside
            [switchLOS, output] = LOSOutputGenerator(iterateTimeDivision, ...
                CADop, Rx, Tx, output, vtx, vrx, 0,...
                [1, 0], switchMaterial, mobilitySwitch, numberOfNodes,...
                paraCfgInput.carrierFrequency);
            if switchVisuals == 1 && switchLOS == 1
                set(0, 'CurrentFigure', f1)
                % Plotting QD graph
                if switchMaterial == 1
                    set(0, 'CurrentFigure', f1)
                    if mobilitySwitch == 1 && numberOfNodes == 2
                        %clf
                        view([9 90])
                    end
                    pts = [Tx; Rx];
                    % Plot LOS for raytracing visuals (f1)
                    plot3(pts(:, 1), pts(:, 2), pts(:, 3),'k',...
                        'LineStyle', '-.', 'LineWidth', 3.5);
                end
            end
            if paraCfgInput.switchSaveVisualizerFiles == 1 &&...
                    switchLOS == 1 &&...
                    iterateTx < iterateRx
                
                multipath1 = [Tx,Rx];
                csvwrite(sprintf('%s/MpcTx%dRx%dRefl%dTrc%d.csv',...
                    mpcCoordinatesPath, iterateTx-1, iterateRx-1, 0, iterateTimeDivision),...
                    multipath1); 

            end
                
            %% Higher order reflections (Non LOS)
            for iterateOrderOfReflection = 1:totalNumberOfReflections
                numberOfReflections = iterateOrderOfReflection;
                        
                [ArrayOfPoints, ArrayOfPlanes, number,...
                    index, indexPlanes, arrayOfMaterials,...
                    indexMaterials] = treetraversal(CADop,...
                    numberOfReflections, numberOfReflections,...
                    0, 1, 1, 1, Rx, Tx, [], [],...
                    switchMaterial, [], 1,generalizedScenario);
                        
                number = number - 1;
                        
                if mobilitySwitch == -1
                    vtx = [0, 0, 0];
                    vrx = vtx;
                end
%-----------------Polarization Part Omitted------------------------------%
                %  See multipath for more info
%                         if Polarization_switch==1 && switch_cp==0 &&...
%                                 switchRandomizationInput==1
%                             Polarization_tx = [...
%                                 nodePolarization(iterateTx,1),...
%                                 nodePolarization(iterateTx,2)];
%                             AntennaOrientationTx = [...
%                                 nodeAntennaOrientation(iterateTx,1,1),nodeAntennaOrientation(iterateTx,1,2),...
%                                 nodeAntennaOrientation(iterateTx,1,3);nodeAntennaOrientation(iterateTx,2,1),...
%                                 nodeAntennaOrientation(iterateTx,2,2),nodeAntennaOrientation(iterateTx,2,3);...
%                                 nodeAntennaOrientation(iterateTx,3,1),nodeAntennaOrientation(iterateTx,3,2),...
%                                 nodeAntennaOrientation(iterateTx,3,3)];
%                             Polarization_rx = [...
%                                 nodePolarization(iterateRx,1),...
%                                 nodePolarization(iterateRx,2)];
%                             AntennaOrientationRx = [...
%                                 nodeAntennaOrientation(iterateRx,1,1),nodeAntennaOrientation(iterateRx,1,2),...
%                                 nodeAntennaOrientation(iterateRx,1,3);nodeAntennaOrientation(iterateRx,2,1),...
%                                 nodeAntennaOrientation(iterateRx,2,2),nodeAntennaOrientation(iterateRx,2,3);...
%                                 nodeAntennaOrientation(iterateRx,3,1),nodeAntennaOrientation(iterateRx,3,2),...
%                                 nodeAntennaOrientation(iterateRx,3,3)];
%                         end
%-----------------Polarization Part Omitted------------------------------%

                [QD, switchQD, outputTemporary, multipathTemporary,...
                    count, countQD] = multipath(...
                    ArrayOfPlanes, ArrayOfPoints, Rx, Tx, ...
                    CADop, number, ...
                    MaterialLibrary, arrayOfMaterials, ...
                    switchMaterial, vtx, vrx, ...
                    0, [1, 0], ...
                    AntennaOrientationTx, [1, 0], ...
                    AntennaOrientationRx, 0, switchQDGenerator,paraCfgInput.carrierFrequency);
                        
                %Plots channel model if material switch is 1
                if paraCfgInput.switchSaveVisualizerFiles == 1 &&...
                        iterateTx < iterateRx &&...
                        size(multipathTemporary,1) ~= 0
                    
                    multipath1 = multipathTemporary(1:count, 2:size(multipathTemporary,2));
                    csvwrite(sprintf('%s/MpcTx%dRx%dRefl%dTrc%d.csv',...
                        mpcCoordinatesPath, iterateTx-1, iterateRx-1,...
                        iterateOrderOfReflection, iterateTimeDivision),...
                        multipath1);
                end
                        
                if size(output) > 0
                    output = [output;outputTemporary];
                    multipath1 = multipathTemporary;
                elseif size(outputTemporary) > 0
                    output = outputTemporary;
                    multipath1 = multipathTemporary;
                end
                if switchVisuals == 1
                    set(0, 'CurrentFigure', f1)


                    %Plots CAD file from CADop
                    if iterateTx == 1 && iterateRx == 2 
                        for i = 1:size(CADop,1)

                            hold on
                            v1 = [CADop(i, 1), CADop(i, 2), CADop(i, 3)];...
                                v2=[CADop(i, 4), CADop(i, 5), CADop(i, 6)...
                                ]; v3=[CADop(i, 7), CADop(i, 8), ...
                                CADop(i, 9)];

                            triangle = 1. * [v1(:), v2(:), v3(:), v1(:)];

                            h=fill3(triangle(1, :), triangle(2, :),...
                                triangle(3, :), [0.5 0.5 0.5]);
                            h.FaceAlpha = 0.1;
                            h.EdgeAlpha = 0.5;
                            set(h, 'edgecolor', [1 1 1], 'LineWidth', 0.5);

                        end
                    end

                    % plots multipath function output on to CAD model
                    sizeMultipath1 = size(multipath1);
                    if sizeMultipath1(1) >0
                        for i = 1:count

                            iterateOrderOfReflection = multipath1(i, 1);
                            for j = 1:iterateOrderOfReflection + 1
                                P1 = [multipath1(i, j * 3 - 1),...
                                    multipath1(i, j * 3),...
                                    multipath1(i, j * 3 + 1)];
                                P2 = [multipath1(i, j * 3 + 2),...
                                    multipath1(i, j * 3 + 3),...
                                    multipath1(i, j * 3 + 4)];

                                % Their vertial concatenation is what you want
                                pts = [P1; P2];

                                % Alternatively, you could use plot3:
                                hold on

                                if iterateOrderOfReflection<4
                                    plot3(pts(:, 1),  pts(:, 2), ...
                                        pts(:, 3), 'k', 'LineWidth', ...
                                        lineArray(iterateOrderOfReflection))
                                else
                                    plot3(pts(:, 1), pts(:, 2),...
                                        pts(:, 3), colorArray(4), ...
                                        'LineWidth', 0.8)

                                end
                            end
                        end
                        view([9 90])
                    end

                    % Plots nodes
                    scatter3(Tx(1), Tx(2), Tx(3), 100, 'k', '.');
                    text(Tx(1), Tx(2), Tx(3), 'Tx', 'Fontsize', 6);
                    rx1 = scatter3(Rx(1), Rx(2), Rx(3), 100, 'k', '.');
                    text(Rx(1), Rx(2), Rx(3), 'Rx', 'Fontsize', 6);
                end                     
            end
            
            % The ouput from previous iterations is stored in files
            % whose names are TxiRxj.txt. i,j is the link
            % between ith node as Tx and jth as Rx.
            writeQdFileOutput(output, fids(iterateTx,iterateRx),...
                paraCfgInput.qdFilesFloatPrecision);
            writeQdFileOutput(reverseOutputTxRx(output), fids(iterateRx,iterateTx),...
                paraCfgInput.qdFilesFloatPrecision);


%                 if Mobility_switch~=1
%                     savefig(f1,strcat(outputPath, '/', 'Rays',num2str(iter)));
%                     savefig(f2,strcat(outputPath, '/', 'Rays-QD',num2str(iter)));
%                 end

        end
    end
    
    %  set(0,'CurrentFigure',f3)
    %  F(time_division+1)=getframe(gcf);
    %  movie(f3,F,1);
    %
    %       v1 = VideoWriter('movie.avi');
    %        v1.FrameRate=3;
    %       open(v1)
    %       writeVideo(v1,F)

end

% close all
%% Makes video of CAD model based multipath and channel model
% %Changed
%         if Mobility_switch==1
%       fig=figure;
%       movie(f1,F,1);
%
%       v1 = VideoWriter('movie.avi');
%        v1.FrameRate=3;
%       open(v1)
%       writeVideo(v1,F)
%       close(v1)
%       if switch_material==1
%           set(0,'CurrentFigure',f2)
%           fig=figure;
%       movie(f2,fr1,1);
%
%       v2 = VideoWriter('movie_QD.avi');
%        v2.FrameRate=3;
%       open(v2)
%       writeVideo(v2,fr1)
%       close(v2)
%       end
%       set(0,'CurrentFigure',f1)
%
%         end


%  clearvars -except number_of_iteration wb

%  close all

closeQdFilesIds(fids);

end