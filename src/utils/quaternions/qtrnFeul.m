function q = qtrnFeul(ein, rot)
%QTRNFEUL Create a quaternion vector from the euler angle rotation.  The 
%   default order for Euler angle rotations is 'ZYX'.
%
%   Q = QTRNFEUL(ein) returns the quaternion Q equivalent to the euler
%   rotation EIN = [E1, E2, E3]  to rotate a point about the EIN-direction
%
%   Q = QTRNFEUL(ein, sequence) returns the quaternion Q equivalent to the
%   euler rotation. The Euler angles are specified in the axis rotation 
%   sequence
%   Valid sequences: 'YZY','YXY','ZYZ','ZXZ','XYX','XZX','XYZ','YZX','ZXY',
%   'XZY','ZYX','YXZ'.
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



if ~exist('rot', 'var')
    rot = 'ZYX';
end


ein = ein./2;
a = ein(:,1);
b = ein(:,2);
c = ein(:,3);

switch upper(rot)
    case 'YZY'
        qa = cos(a + c).*cos(b);
        qb = sin(b).*sin(a - c);
        qc = sin(a + c).*cos(b);
        qd = sin(b).*cos(a - c);
    case 'YXY'
        qa = cos(a + c).*cos(b);
        qb = sin(b).*cos(a - c);
        qc = sin(a + c).*cos(b);
        qd = -sin(b).*sin(a - c);
    case 'ZYZ'
        qa = cos(a + c).*cos(b);
        qb = -sin(b).*sin(a - c);
        qc = sin(b).*cos(a - c);
        qd = sin(a + c).*cos(b);
    case 'ZXZ'
        qa = cos(a + c).*cos(b);
        qb = sin(b).*cos(a - c);
        qc = sin(b).*sin(a - c);
        qd = sin(a + c).*cos(b);
    case 'XYX'
        qa = cos(a + c).*cos(b);
        qb = sin(a + c).*cos(b);
        qc = sin(b).*cos(a - c);
        qd = sin(b).*sin(a - c);
    case 'XZX'
        qa = cos(a + c).*cos(b);
        qb = sin(a + c).*cos(b);
        qc = -sin(b).*sin(a - c);
        qd = sin(b).*cos(a - c);
    case 'XYZ'
        qa = cos(a).*cos(b).*cos(c) - sin(a).*sin(b).*sin(c);
        qb = cos(b).*cos(c).*sin(a) + cos(a).*sin(b).*sin(c);
        qc = cos(a).*cos(c).*sin(b) - cos(b).*sin(a).*sin(c);
        qd = cos(a).*cos(b).*sin(c) + cos(c).*sin(a).*sin(b);
    case 'YZX'
        qa = cos(a).*cos(b).*cos(c) - sin(a).*sin(b).*sin(c);
        qb = cos(a).*cos(b).*sin(c) + cos(c).*sin(a).*sin(b);
        qc = cos(b).*cos(c).*sin(a) + cos(a).*sin(b).*sin(c);
        qd = cos(a).*cos(c).*sin(b) - cos(b).*sin(a).*sin(c);
    case 'ZXY'
        qa = cos(a).*cos(b).*cos(c) - sin(a).*sin(b).*sin(c);
        qb = cos(a).*cos(c).*sin(b) - cos(b).*sin(a).*sin(c);
        qc = cos(a).*cos(b).*sin(c) + cos(c).*sin(a).*sin(b);
        qd = cos(b).*cos(c).*sin(a) + cos(a).*sin(b).*sin(c);
    case 'XZY'
        qa = cos(a).*cos(b).*cos(c) + sin(a).*sin(b).*sin(c);
        qb = cos(b).*cos(c).*sin(a) - cos(a).*sin(b).*sin(c);
        qc = cos(a).*cos(b).*sin(c) - cos(c).*sin(a).*sin(b);
        qd = cos(a).*cos(c).*sin(b) + cos(b).*sin(a).*sin(c);
    case 'ZYX'
        qa = cos(a).*cos(b).*cos(c) + sin(a).*sin(b).*sin(c);
        qb = cos(a).*cos(b).*sin(c) - cos(c).*sin(a).*sin(b);
        qc = cos(a).*cos(c).*sin(b) + cos(b).*sin(a).*sin(c);
        qd = cos(b).*cos(c).*sin(a) - cos(a).*sin(b).*sin(c);
    case 'YXZ'
        qa = cos(a).*cos(b).*cos(c) + sin(a).*sin(b).*sin(c);
        qb = cos(a).*cos(c).*sin(b) + cos(b).*sin(a).*sin(c);
        qc = cos(b).*cos(c).*sin(a) - cos(a).*sin(b).*sin(c);
        qd = cos(a).*cos(b).*sin(c) - cos(c).*sin(a).*sin(b);
    otherwise
        qa = zeros(size(a), 'like', a);
        qb = zeros(size(a), 'like', a);
        qc = zeros(size(a), 'like', a);
        qd = zeros(size(a), 'like', a);
end

q = [qa qb qc qd];
end
