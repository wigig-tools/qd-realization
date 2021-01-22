function eout = eulFqtrn(q ,rot)
%QPARTS2FEUL - Euler angles from quaternion parts

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


%column-ize quaternion parts
qa = q(:,1);
qb = q(:,2);
qc = q(:,3);
qd = q(:,4);
the1 = ones(size(qa), 'like', qa);
the2 = 2*the1;

found = true;
switch upper(rot)
    case 'YZY'
        tmp = qa.^2.*the2 - the1 + qc.^2.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = acos(tmp);
        a = atan2((qa.*qb.*the2 + qc.*qd.*the2),(qa.*qd.*the2 - qb.*qc.*the2));
        c = -atan2((qa.*qb.*the2 - qc.*qd.*the2),(qa.*qd.*the2 + qb.*qc.*the2));
    case 'YXY'
        tmp = qa.^2.*the2 - the1 + qc.^2.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = acos(tmp);
        a = -atan2((qa.*qd.*the2 - qb.*qc.*the2),(qa.*qb.*the2 + qc.*qd.*the2));
        c = atan2((qa.*qd.*the2 + qb.*qc.*the2),(qa.*qb.*the2 - qc.*qd.*the2));
    case 'ZYZ'
        tmp = qa.^2.*the2 - the1 + qd.^2.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = acos(tmp);
        a = -atan2((qa.*qb.*the2 - qc.*qd.*the2),(qa.*qc.*the2 + qb.*qd.*the2));
        c = atan2((qa.*qb.*the2 + qc.*qd.*the2),(qa.*qc.*the2 - qb.*qd.*the2));
    case 'ZXZ'
        tmp = qa.^2.*the2 - the1 + qd.^2.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = acos(tmp);
        a = atan2((qa.*qc.*the2 + qb.*qd.*the2),(qa.*qb.*the2 - qc.*qd.*the2));
        c = -atan2((qa.*qc.*the2 - qb.*qd.*the2),(qa.*qb.*the2 + qc.*qd.*the2));
    case 'XYX'
        tmp = qa.^2.*the2 - the1 + qb.^2.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = acos(tmp);
        a = atan2((qa.*qd.*the2 + qb.*qc.*the2),(qa.*qc.*the2 - qb.*qd.*the2));
        c = -atan2((qa.*qd.*the2 - qb.*qc.*the2),(qa.*qc.*the2 + qb.*qd.*the2));
    case 'XZX'
        tmp = qa.^2.*the2 - the1 + qb.^2.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = acos(tmp);
        a = -atan2((qa.*qc.*the2 - qb.*qd.*the2),(qa.*qd.*the2 + qb.*qc.*the2));
        c = atan2((qa.*qc.*the2 + qb.*qd.*the2),(qa.*qd.*the2 - qb.*qc.*the2));
    case 'XYZ'
        tmp = qa.*qc.*the2 + qb.*qd.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = asin(tmp);
        a = atan2((qa.*qb.*the2 - qc.*qd.*the2),(qa.^2.*the2 - the1 + qd.^2.*the2));
        c = atan2((qa.*qd.*the2 - qb.*qc.*the2),(qa.^2.*the2 - the1 + qb.^2.*the2));
    case 'YZX'
        tmp = qa.*qd.*the2 + qb.*qc.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = asin(tmp);
        a = atan2((qa.*qc.*the2 - qb.*qd.*the2),(qa.^2.*the2 - the1 + qb.^2.*the2));
        c = atan2((qa.*qb.*the2 - qc.*qd.*the2),(qa.^2.*the2 - the1 + qc.^2.*the2));
    case 'ZXY'
        tmp = qa.*qb.*the2 + qc.*qd.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = asin(tmp);
        a = atan2((qa.*qd.*the2 - qb.*qc.*the2),(qa.^2.*the2 - the1 + qc.^2.*the2));
        c = atan2((qa.*qc.*the2 - qb.*qd.*the2),(qa.^2.*the2 - the1 + qd.^2.*the2));
    case 'XZY'
        tmp = qb.*qc.*the2 - qa.*qd.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = -asin(tmp);
        a = atan2((qa.*qb.*the2 + qc.*qd.*the2),(qa.^2.*the2 - the1 + qc.^2.*the2));
        c = atan2((qa.*qc.*the2 + qb.*qd.*the2),(qa.^2.*the2 - the1 + qb.^2.*the2));
    case 'ZYX'
        tmp = qb.*qd.*the2 - qa.*qc.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = -asin(tmp);
        a = atan2((qa.*qd.*the2 + qb.*qc.*the2),(qa.^2.*the2 - the1 + qb.^2.*the2));
        c = atan2((qa.*qb.*the2 + qc.*qd.*the2),(qa.^2.*the2 - the1 + qd.^2.*the2));
    case 'YXZ'
        tmp = qc.*qd.*the2 - qa.*qb.*the2;
        tmp(tmp > the1(1)) = the1(1);
        tmp(tmp < -the1(1)) = -the1(1);
        b = -asin(tmp);
        a = atan2((qa.*qc.*the2 + qb.*qd.*the2),(qa.^2.*the2 - the1 + qd.^2.*the2));
        c = atan2((qa.*qd.*the2 + qb.*qc.*the2),(qa.^2.*the2 - the1 + qc.^2.*the2));
    otherwise
        found = false;
        a = zeros(size(qa), 'like', qa);
        b = zeros(size(qa), 'like', qa);
        c = zeros(size(qa), 'like', qa);
end

assert(found, 'Rotation case not found');
eout = [a b c];
end