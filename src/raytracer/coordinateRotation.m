function [P, varargout] = coordinateRotation(P, C, euler, varargin)
%COORDINATEROTATION rotates a point in the QD software using quaternions.
%
%   P = COORDINATEROTATION(P,PC,EUL) or 
%   P = COORDINATEROTATION(P,PC,EUL, 'point') rotates the point P = (px, py, pz)
%   with respect to a reference system centered in C = (cx,cy,cz) by the
%   euclidians angles EUL. EUL is the Nx3 matrix where N indicates
%   consecutive rotations. If C is a 1x3 vector the same center is assumed
%   for each of the N rotations. If C is a Nx3 matrix a each rotation uses
%   a different center of rotation.
%   The point rotation is used to model the device rotation, which brings
%   the PAAs  in  a  different  position  in  the global  frame.
%   Default euclidian sequence is assumed 'ZXY'.
%
%   P = COORDINATEROTATION(P,PC,EUL, 'frame') returns the coordinates of
%   the point P when the reference frame centered in PC is rotated by the
%   euclidians angles EUL. The  frame  rotation  is used to transform AOA
%   and AOD from global to local coordinates. Default euclidian sequence is
%   assumed 'ZXY'.
%
%  [P SUCCESSIVE_EUL] = COORDINATEROTATION(..) returns the euler angle
%  SUCCESSIVE_EUL equivalent to the consecutive rotations in EUL

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
% 2020 NIST/CTL (steve.blandino@nist.gov)

%% Vargin processing
p = inputParser;
addOptional(p,'rotateFrame','point',@(x) any(validatestring(x,{'point', 'frame'})));
parse(p, varargin{:});
rotateFrame = p.Results.rotateFrame;

assert(size(C,1) == size(euler,1) || size(C,1) ==1, 'Provide correct', ...
'centroids to perform rotation')

Nrotations = size(euler,1) ;

if isempty(P)
    return
end

if size(C,1) ==1
    C = repmat(C,[Nrotations,1]);
end

%% Convert from Euler to quaternions
switch rotateFrame
    case 'frame'
        Q = qtrnConj(qtrnFeul(euler , 'ZXY'));
    case 'point'
        Q = qtrnFeul(euler , 'ZXY');
end

%% Apply rotations and compute equivalent quaternion
for j = 1:Nrotations    
    P = qtrnRotatepoint(Q(j,:),P-C(j,:))+C(j,:);  
 
    if j <= Nrotations - 1
        Q(j,:) = qtrnMultiply(Q(j,:), Q(j+1,:)); % Store at index j the prod 1:j+1
    end
end

%% Output
varargout{1} = eulFqtrn(Q(max(Nrotations-1,1),:), 'ZXY'); % Return the euclidian angle
% correspondent to the quaternion Q at index Nrotations-1
end
