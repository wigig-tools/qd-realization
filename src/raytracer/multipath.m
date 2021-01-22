function [qdRay, multipath] =...
    multipath(ArrayOfPlanes, ArrayOfPoints, Rx, Tx, CADOutput,...
    numberOfRowsArraysOfPlanes, MaterialLibrary, arrayOfMaterials,...
    switchMaterial, velocityTx, velocityRx, ...
   qdGeneratorSwitch, frequency, varargin)
%INPUT -
%ArrayOfPoints - combinations of multiple triangles, every row is a unique
%combination. every triangle occupies 9 columns (3 vertices). (o/p of
%treetraversal)
%ArrayOfPlanes - Similar to Array of points. Each triangle occupies 4
%columns (plane equation). The first column has the order of reflection
%(o/p of treetraversal)
%Rx - Rx position
%Tx - Tx position
%CADop - CAD output
%MaterialLibrary - Similar to Array of points. Each triangle occupies 1
%triangle. The data is the row number of material from Material library
%arrayOfMaterials - Similar to Array of points. Each triangle occupies 1
%triangle. The data is the row number of material from Material library
%switchMaterial - whether triangle materials properties are present
% vtx, vrx are velocities of tx and rx respectively
% QDGeneratorSwitch - Switch to turn ON or OFF the Qausi dterministic module
% 1 = ON, 0 = OFF
% frequency: the carrier frequency at which the system operates
%
%OUTPUT -
%output - multipath parameters
%multipath - output to be plottd on f1 multipath plot
%
% The phase information in case of presence of polarization information and is
% encoded in the Jones vector. In case of absence of polarization, order of
% reflection is multiplied by pi to give phase shift


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
% and distributing the software and you assume all risks associated with its use, including
% but not limited to the risks and costs of program errors, compliance with applicable
% laws, damage to or loss of data, programs or equipment, and the unavailability or
% interruption of operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property. The software
% developed by NIST employees is not subject to copyright protection within the United
% States.
%
% Modified by: Mattia Lecci <leccimat@dei.unipd.it>, Used MATLAB functions instead of custom ones,
%    vectorized code, improved access to MaterialLibrary

%% Varargin processing 
p = inputParser;
addParameter(p,'indStoc',1)
addParameter(p,'qTx',struct('center', Tx, 'angle', [0 0 0]))
addParameter(p,'qRx',struct('center', Rx, 'angle', [0 0 0]))
addParameter(p,'reflectionLoss',10);
parse(p, varargin{:});
qTx = p.Results.qTx;
qRx = p.Results.qRx;
rl  = p.Results.reflectionLoss;

%% Init
indexMultipath = 1;
indexOutput = 1;
nVarOut = 21;
sizeArrayOfPlanes = size(ArrayOfPlanes);
dRay = zeros(1, nVarOut);
multipath = [];
c = getLightSpeed;
wavelength = c / frequency;
outputQd = struct('dRay', cell(sizeArrayOfPlanes(1),1), ...
    'rPreCursor', cell(sizeArrayOfPlanes(1),1), ...
    'rPostCursor', cell(sizeArrayOfPlanes(1),1));
%%
if numberOfRowsArraysOfPlanes>0
    orderOfReflection = ArrayOfPlanes(1,1);
    
    % the for loop iterates through all the rows of ArrayOfPlanes,
    % ArrayOfPoints and provides a single row as input to
    % singleMultipathGenerator function
    % QD model is present in  this loop
    multipath = zeros(numberOfRowsArraysOfPlanes,orderOfReflection * 3 + 1);
    for iterateNumberOfRowsArraysOfPlanes = 1:numberOfRowsArraysOfPlanes
        
        indexOrderOfReflection = 1;
        multipath(indexMultipath, (indexOrderOfReflection-1)*3 + 1) = orderOfReflection;
        multipath(indexMultipath, (indexOrderOfReflection-1)*3 + 1 + (1:3)) = Rx;
        Reflected = Rx;
        
        % a single row of ArrayOfPlanes,ArrayOfPoints is fed to
        % singleMultipathGenerator function to know whether a path exists. If a
        % path exists then what are vectors that form the path (stored in
        % multipath parameter)                
        [isMpc,~,dod,doa,multipath,distance,dopplerFactor,...
           ~] = singleMultipathGenerator...
            (iterateNumberOfRowsArraysOfPlanes,orderOfReflection,indexOrderOfReflection,ArrayOfPlanes,...
            ArrayOfPoints,Reflected,Rx,Tx,CADOutput,...
            multipath,indexMultipath,velocityTx,velocityRx);
        
        % Apply node rotation
        dod = coordinateRotation(dod,[0 0 0], qTx.angle, 'frame');
        doa = coordinateRotation(doa,[0 0 0], qRx.angle, 'frame');
        
        % Compute reflection loss
        if  switchMaterial == 1
            reflectionLoss = getReflectionLoss(MaterialLibrary,...
                arrayOfMaterials(iterateNumberOfRowsArraysOfPlanes,:), 'randOn', qdGeneratorSwitch);
        else
            % Assumption: rl loss at each reflection
            reflectionLoss = rl*orderOfReflection; 
        end
        
        % Corner case: MPC on the edge of triangles would be considered
        % twice. Check if it has been already stored otherwise discard.
        if isMpc == 1
            for i = 1:indexMultipath - 1
                isMpcNonUnique = 1;
                for j = 1:(orderOfReflection * 3) + 6
                    isMpcNonUnique = isMpcNonUnique && (multipath(i,j) == multipath(indexMultipath,j));
                end
                isMpc = isMpc && ~isMpcNonUnique;
            end
        end
        
        % the delay, AoA, AoD, path loss of the path are stored in output parameter
        if  isMpc == 1
            
            dRay(1) = indexMultipath;
            % dod - direction of departure
            dRay(2:4) = dod;
            % doa - direction of arrival
            dRay(5:7) = doa;
            % Time delay
            dRay(8) = distance/c;
            % Friis transmission loss
            dRay(9) = 20*log10(wavelength / (4*pi*distance)) - reflectionLoss;            
            % Aod azimuth
            dRay(10) = mod(atan2d(dod(2),dod(1)), 360);
            % Aod elevation
            dRay(11) = acosd(dod(3) / norm(dod));
            % Aoa azimuth
            dRay(12) = mod(atan2d(doa(2),doa(1)), 360);
            % Aoa elevation
            dRay(13) = acosd(doa(3) / norm(doa));
            dRay(18) = orderOfReflection*pi;
            dRay(20) = dopplerFactor * frequency;
            dRay(21) = 0;
            outputQd(indexOutput).dRay = dRay;
            
            % refer to "multipath - WCL17_revised.pdf" in this folder for QD model
            if  switchMaterial == 1 && qdGeneratorSwitch == 1
                [~, rPreCursor, rPostCursor] =...
                    qdGenerator(outputQd(indexOutput).dRay, arrayOfMaterials(iterateNumberOfRowsArraysOfPlanes,:), MaterialLibrary);
                outputQd(indexOutput).rPreCursor  = rPreCursor;
                outputQd(indexOutput).rPostCursor = rPostCursor;

            end
            
            indexOutput = indexOutput + 1;
            indexMultipath = indexMultipath + 1;

        end
    end
    
    qdRay =     [ ...
    reshape([outputQd.dRay],nVarOut, []).';...
    reshape([outputQd.rPreCursor].', nVarOut, []).';...
    reshape([outputQd.rPostCursor].', nVarOut, []).'];
    qdRay(isnan(qdRay(:,1)),:) =[];
    
    if indexMultipath>=1
        multipath(indexMultipath:end,:) = [];
    end
    
end

end
