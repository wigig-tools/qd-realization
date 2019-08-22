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


%Input/output -
%vtx: Velocity of Tx
%Plane: Plane on which the Tx is reflecting
%v_reflected: Reflected velocity of Tx
%ref - https://www.youtube.com/watch?annotation_id=annotation_1975598373&feature=iv&src_vid=o5tXemaDpnI&v=4tAd2dGrj70
function [velocityReflected]=reflectedVelocity(velocityTx, plane)
vector(1)=plane(1);
vector(2)=plane(2);
vector(3)=plane(3);
dp=dot(velocityTx,vector);

if dp~=0
    vectorAlongNormal=(-1*dp).*vector;
    theta=acos(dp/norm(velocityTx));
    vectorOrthogonal=cross(vector,cross(velocityTx,vector));
    if norm(vectorOrthogonal)~=0
        vectorOrthogonal=vectorOrthogonal./norm(vectorOrthogonal);
    end
    vectorOrthogonal=(dp*tan(theta)).*vectorOrthogonal;
    velocityReflected=vectorOrthogonal+vectorAlongNormal;
else
    velocityReflected=velocityTx;
end

