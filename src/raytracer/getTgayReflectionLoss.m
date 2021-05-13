function reflectionLossdB = getTgayReflectionLoss(MaterialLibrary,...
                arrayOfMaterials, multipath)
% GETTGAYREFLECTIONLOSS returns the ray reflection loss in dB 
% based on TGay measurements [1]
% [1] A. Maltsev, A. Pudeyev, A. Lomayev, and I. Bolotin, "Channel models 
% for IEEE 802.11ay," IEEE doc, pp. 802{11, 2017.
%
% This function first calculates the reflectances for vertical and 
% horizontal polarization for each reflection using the incident angle and  
% relative permittivity of the material in the Fresnel equation.
% Subsequently, the reflection loss for each reflection is calculated by 
% the taking the average of the vertical and horizontal reflectance powers.
% For REFLECTIONCOEFFICIENT calculation, refer to equation 7.4.2 
% https://www.ece.rutgers.edu/~orfanidi/ewa/
%
% Inputs:
% MaterialLibrary - contains each of the reflectors along with their
%   material and relative permittivity value
% arrayOfMaterials - array of materials corresponding to each of the planes
%   where a ray is reflected. The dats is the row number of material from 
%   MaterialLibrary. 
% multipath - consists of specular multipath parameters. This vector is
%   used to calculate angle(s) of incident and also to get information about
%   the order of reflection
%
% Output: 
% reflectionLossdB - ray reflection loss in dB

% NIST-developed software is provided by NIST as a public service. You may
% use, copy and distribute copies of the software in any medium, provided
% that you keep intact this entire notice. You may improve,modify and
% create derivative works of the software or any portion of the software,
% and you may copy and distribute such modifications or works. Modified
% works should carry a notice stating that you changed the software and
% should note the date and nature of any such change. Please explicitly
% acknowledge the National Institute of Standards and Technology as the
% source of the software. NIST-developed software is expressly provided
% "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR
% ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
% WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
% NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS
% THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE,
% OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY
% REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF,
% INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY,
% OR USEFULNESS OF THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% and distributing the software and you assume all risks associated with
% its use,including but not limited to the risks and costs of program
% errors, compliance with applicable laws, damage to or loss of data,
% programs or equipment, and the unavailability or interruption of
% operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property.
% The software developed by NIST employees is not subject to copyright
% protection within the United States.
%
% 2020-2021 NIST/CTL (neeraj.varshney@nist.gov)

% Get reflectances for Vertical and Horizontal polarization
reflectionCoefficient = getReflectance(MaterialLibrary,arrayOfMaterials,multipath);
% Calculate reflection loss. It is the sum (in dB) of the mean
% of the Vertical and Horizontal reflectances for each reflection.
reflectionLoss = prod(sqrt(mean(abs(reflectionCoefficient).^2))); 
reflectionLossdB = -20*log10(reflectionLoss); 
end

function reflectionCoefficient = getReflectance(MaterialLibrary,...
                                                arrayOfMaterials,multipath)
% REFLECTIONCOEFFICIENT function returns reflectances for Vertical and 
% Horizontal polarization for each reflection using the incident angle and  
% relative permittivity of the material in the Fresnel equation.
% 
% Inputs:
% MaterialLibrary - contains each of the reflectors along with their
%   material and relative permittivity value
% arrayOfMaterials - array of materials corresponding to each of the planes
%   where a ray is reflected. The dats is the row number of material from 
%   MaterialLibrary. 
% multipath - consists of specular multipath parameters. This vector is
%   used to calculate angle(s) of incident and also to get information about
%   the order of reflection
% 
% Output:
% reflectionCoefficient - reflectances for Vertical and Horizontal 
% polarization for each of the reflections

incidentAngle = angleOfIncidence(multipath);
orderReflection = multipath(1,1);
reflectionCoefficient = ones(2, orderReflection);
for reflectionOrderIndex = 1:orderReflection
    if reflectionOrderIndex == 1
        reflectionMaterialIndex = arrayOfMaterials(1,1);
    elseif  reflectionOrderIndex == 2
        reflectionMaterialIndex = arrayOfMaterials(1,2);
    else
        error(strcat('Incident angles are obtained till second order ',...
        'reflection. Thus, order of reflection cannot be considered ',... 
        'higher than second order reflection.'));
    end
    % Use Fresnel equation to derive power reflectivity                
    relativePermittivity = MaterialLibrary.RelativePermittivity...
                            (reflectionMaterialIndex); 
    aor = incidentAngle(reflectionOrderIndex);
    B_h =  relativePermittivity - sind(aor)^2;                
    B_v = (relativePermittivity - sind(aor)^2)/relativePermittivity^2; 
    reflectionCoefficient(:, reflectionOrderIndex) = [ ...
        (-cosd(aor) + sqrt(B_v))/(cosd(aor) + sqrt(B_v)); ... % Vertical 
        (cosd(aor) - sqrt(B_h))/(cosd(aor) + sqrt(B_h))];    % Horizontal
end     
end

function incidentAngle = angleOfIncidence(multipath) 
% ANGLEOFINCIDENCE returns angle of incident for first and second order
% reflections
% 
% Inputs:
% multipath - consists of specular multipath parameters. This vector is
% used to calculate angle(s) of incident.
% 
% Output: 
% incidentAngle - incident angles till second order reflections

differenceVectorRxFirstPoI = (multipath(1,2:4) - multipath(1,5:7))...
                                /norm(multipath(1,2:4) - multipath(1,5:7));
% differenceVectorRxFirstPoI is the difference vector between Rx 
% and first point of incidence (PoI).
differenceVectorTxFirstPoI = (multipath(1,8:10) - multipath(1,5:7))...
                            /( norm(multipath(1,8:10) - multipath(1,5:7)));
% differenceVectorTxFirstPoI is the difference vector between Tx 
% and first point of incidence (PoI). 
dpAoI = dot(differenceVectorRxFirstPoI, differenceVectorTxFirstPoI);
% dpAoI is the dot product between differenceVectorRxFirstPoI and 
% differenceVectorTxFirstPoI will give the cos of angle between the vectors.
incidentAngle(1) = 0.5*acosd(dpAoI);
% Half of the angle between the vectors differenceVectorRxFirstPoI and 
% differenceVectorTxFirstPoI is the angle of incidence. This is because 
% angle of incidence is equal to angle of reflection.
if multipath(1,1) == 2 % This is for second order reflection
    differenceVectorRxSecondPoI = (multipath(1,2:4) - multipath(1,5:7))...
                                /norm(multipath(1,2:4) - multipath(1,5:7));
    differenceVectorFirstPoISecondPoI =...  
                            (multipath(1,8:10) - multipath(1,5:7))...
                            /( norm(multipath(1,8:10) - multipath(1,5:7)));
    differenceVectorSecondPoIFirstPoI = -differenceVectorFirstPoISecondPoI;
    differenceVectorTxFirstPoI =...
        (multipath(1,11:13) - multipath(1,8:10))/...
        norm((multipath(1,11:13) - multipath(1,8:10)));
    dpAoI = dot(differenceVectorSecondPoIFirstPoI,...
                differenceVectorTxFirstPoI);
    incidentAngle(1) = 0.5*acosd(dpAoI);
    dpAoI = dot(differenceVectorRxSecondPoI,...
                differenceVectorFirstPoISecondPoI);
    incidentAngle(2)  = 0.5*acosd(dpAoI);
end
end