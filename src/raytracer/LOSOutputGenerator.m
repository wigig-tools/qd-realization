function [switchLOS, output] = LOSOutputGenerator(CADoutput, Rx, Tx,...
    output, velocityTx, velocityRx, switchPolarization, switchCp,...
    PolarizationTx, frequency)
% This part of code compute LOS between two nodes
%
%Inputs:
%CADoutput - CAD output
%Tx and Rx locations if using two nodes
%velocityTx, velocityRx are velocities of tx and rx respectively
%output - multipath parameters
%switchPolarization - a boolean to describe whether polarization is
%selected
%switchCp - a boolean to describe whether cross polarization is selected
%or not. 1 means there is cross polarization and 0 means there is no cross
%polarization
%PolarizationTx - gives polarization information of Tx location
%f1 - figure that displays multipath
%f2 - figure that displays channel model
%properties are presnet in CAD output
%output - multipath parameters
% frequency: the carrier frequency at which the system operates
%
%Outputs:
%f1 - figure that displays multipath
%f2 - figure that displays channel model
%switchLOS - a boolean which gives information whether LOS exist or not.
%1 stands for existant while 0 is for non existant case
%output - multipath parameters

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
% Modified by: Mattia Lecci <leccimat@dei.unipd.it>, Used MATLAB functions instead of custom ones


% Direction of departure (DoD) is simple the difference of position vectors
% of Tx and Rx
dod=Rx-Tx;
% delay is the total length of multipath
delay=norm(dod);
% Direction of arrival (DoA) is negative of DoD
doa=-dod;
% Calculating Doppler factor for LOS
velocityTxAlongDirectionOfDeparture=dot(velocityTx,-1.*dod);
velocityRxAlongDirectionOfDeparture=dot(velocityRx,-1.*dod);
c=3e8;
dopplerFactor=(velocityRxAlongDirectionOfDeparture-velocityTxAlongDirectionOfDeparture)/(c);
% To verify whether DoA vector exists
vector=Tx-Rx;
[switch3]=verifyPath(Tx,Rx,vector,[0,0,0],...
    [0,0,0],CADoutput,2,false);
switchLOS=switch3;
if switch3==1 % if DoA exists
    output1 = nan(1,21);
    
    lambda=c/frequency;
    output1(1) = 1;
    % dod - direction of departure
    output1(2:4) = dod;
    % doa - direction of arrival
    output1(5:7) = doa;
    % Time delay
    output1(1,8)=delay/c;
    % Path gain
    output1(1,9) = 20*log10(lambda/(4*pi*delay));
    % Aod azimuth
    output1(10) = mod(atan2d(dod(2),dod(1)), 360);
    % Aod elevation
    output1(11) = acosd(dod(3)/norm(dod));
    % Aoa azimuth
    output1(12) = mod(atan2d(doa(2),doa(1)), 360);
    % Aoa elevation
    output1(13)=acosd(doa(3)/norm(doa));
    % Polarization Jones vector
    if switchPolarization
        output1(14:15) = PolarizationTx(1,:);
        % Cross polarization Jones vector
        if switchCp
            output1(16:17) = PolarizationTx(2,:);
        end
    end
    output1(18) = 0;
    % Doppler Factor
    output1(20) = dopplerFactor*frequency;
    output1(21) = 0;
    % Cross polarization path gain
    if switchCp==1
        output1(19) = 20*log10(lambda/(4*pi*delay));
    else
        output1(19) = 0;
    end
    
    if size(output)>0
        output = [output; output1];
    else
        output = output1;
    end
end

end