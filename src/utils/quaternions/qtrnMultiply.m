function qout = qtrnMultiply(q, varargin)
%  QUATMULTIPLY Calculate the product of two quaternions.
%   N = QUATMULTIPLY( Q, R ) calculates the quaternion product, N, for two
%   given quaternions, Q and R.  Inputs Q and R can be either M-by-4 matrices 
%   containing M quaternions, or a single 1-by-4 quaternion.  N returns an 
%   M-by-4 matrix of quaternion products.  Each element of Q and R must be a
%   real number.  Additionally, Q and R have their scalar number as the first 
%   column.
%
%   Examples:
%
%   Determine the product of two 1-by-4 quaternions:
%      q = [1 0 1 0];
%      r = [1 0.5 0.5 0.75];
%      mult = quatmultiply(q, r)
%
%   Determine the product of a 1-by-4 quaternion with itself:
%      q = [1 0 1 0];
%      mult = quatmultiply(q)
%
%   Determine the product of 1-by-4 and 2-by-4 quaternions:
%      q = [1 0 1 0];
%      r = [1 0.5 0.5 0.75; 2 1 0.1 0.1];
%      mult = quatmultiply(q, r)
%

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

narginchk(1, 2);

if any(~isreal(q(:)))
    error(message('qtrnMultiply:isNotReal1'));
end

if (size(q,2) ~= 4)
    error(message('qtrnMultiply:wrongDimension1'));
end

if nargin == 1
    r = q;
else
    r = varargin{1};
    if any(~isreal(r(:)))
        error(message('qtrnMultiply:isNotReal2'));
    end
    if (size(r,2) ~= 4)
        error(message('qtrnMultiply:wrongDimension2'));
    end
    if (size(r,1) ~= size(q,1) && ~( size(r,1) == 1 || size(q,1) == 1))
         error(message('qtrnMultiply:wrongDimension3'));
    end
end

% Calculate vector portion of quaternion product
% vec = s1*v2 + s2*v1 + cross(v1,v2)
vec = [q(:,1).*r(:,2) q(:,1).*r(:,3) q(:,1).*r(:,4)] + ...
         [r(:,1).*q(:,2) r(:,1).*q(:,3) r(:,1).*q(:,4)]+...
         [ q(:,3).*r(:,4)-q(:,4).*r(:,3) ...
           q(:,4).*r(:,2)-q(:,2).*r(:,4) ...
           q(:,2).*r(:,3)-q(:,3).*r(:,2)];

% Calculate scalar portion of quaternion product
% scalar = s1*s2 - dot(v1,v2)
scalar = q(:,1).*r(:,1) - q(:,2).*r(:,2) - ...
             q(:,3).*r(:,3) - q(:,4).*r(:,4);
    
qout = [scalar  vec];
