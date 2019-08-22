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

% This part of code compute LOS between two nodes

%Inputs:
% timeDivision - it is the time instance number
%numberRowsCADoutput - number of rows of CAD output
%CADoutput - CAD output
%Tx and Rx locations if using two nodes
%velocityTx, velocityRx are velocities of tx and rx respectively
%output - multipath parameters
%switchCP - a boolean to describe whether cross polarization is selected
%or not. 1 means there is cross polarization and 0 means there is no cross
%polarization
%PolarizationTx - gives polarization information of Tx location
%f1 - figure that displays multipath
%f2 - figure that displays channel model
%switchMaterial - boolean which gives information whether material
%properties are presnet in CAD output
%output - multipath parameters
%MobilitySwitch is boolean to either have mobility or not
%numberOfNodes - total number of nodes

%Outputs:
%f1 - figure that displays multipath
%f2 - figure that displays channel model
%switchLOS - a boolean which gives information whether LOS exist or not. 
%1 stands for existant while 0 is for non existant case
%output - multipath parameters

function [switchLOS, output] = LOSOutputGenerator(timeDivision,...
    numberRowsCADoutput, CADoutput ,Rx, Tx, output, velocityTx, velocityRx, switchCP,...
    PolarizationTx, switchMaterial, MobilitySwitch, numberOfNodes)

%Direction of departure (DoD) is simple the difference of position vectors
% of Tx and Rx
dod=Rx-Tx;
%delay is the total length of multipath
delay=magnitude(dod);
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
    [0,0,0],numberRowsCADoutput,CADoutput,2);
switchLOS=switch3;
if switch3==1 % if DoA exists
    c=3e8;
    freq=60e9;
    lambda=c/freq;
    output1(1,1)=1;
    %dod - direction of departure
    output1(1,2)=dod(1);
    output1(1,3)=dod(2);
    output1(1,4)=dod(3);
    %doa - direction of arrival
    output1(1,5)=doa(1);
    output1(1,6)=doa(2);
    output1(1,7)=doa(3);
    %Time delay
    output1(1,8)=delay/c;
    %Path gain
    output1(1,9)=20*log10(lambda/(4*pi*delay));
    %Aod azimuth
    if dod(2)==dod(1) && dod(1)==0
        output1(1,10)=90;
    elseif dod(2)<0 && dod(1)>=0
        output1(1,10)=360+(180*(atan(dod(2)/dod(1)))...
            /pi);
    elseif dod(2)<=0 && dod(1)<0
        output1(1,10)=(180*(atan(dod(2)/dod(1)))/pi)...
            +180;
    elseif dod(2)>0 && dod(1)<0
        output1(1,10)=(180*(atan(dod(2)/dod(1)))/pi)...
            +180;
    else
        output1(1,10)=(180*(atan(dod(2)/dod(1)))/pi);
    end
    %Aod elevation
    output1(1,11)=180*(acos(dod(3)/magnitude(dod)))/pi;
    % doa(3)=-doa(3);
    % doa(2)=-doa(2);
    % doa(1)=-doa(1);
    %Aoa azimuth
    if doa(1) == 0
        doa(1) = 0;
    end
    if doa(2)==doa(1) && doa(1)==0
        output1(1,12)=90;
    elseif doa(2)<0 && doa(1)>=0
        output1(1,12)=360+(180*(atan(doa(2)/doa(1)))...
            /pi);
    elseif doa(2)<=0 && doa(1)<0
        output1(1,12)=(180*(atan(doa(2)/doa(1)))/pi)...
            +180;
    elseif doa(2)>0 && doa(1)<0
        output1(1,12)=(180*(atan(doa(2)/doa(1)))/pi)...
            +180;
    else
        output1(1,12)=180*(atan(doa(2)/doa(1)))/pi;
    end
    %Aoa elevation
    output1(1,13)=180*(acos(doa(3)/magnitude(doa)))/pi;
    %Polarization Jones vector
    output1(1,14)=PolarizationTx(1,1);
    output1(1,15)=PolarizationTx(1,2);
    %Cross polarization Jones vector
    if switchCP==1
        output1(1,16)=PolarizationTx(2,1);
        output1(1,17)=PolarizationTx(2,2);
    end
    output1(1,18)=0;
    %Doppler Factor
    output1(1,20)=dopplerFactor*freq;
    output1(1,21)=0;
    %Cross polarization path gain
    if switchCP==1
        output1(1,19)=20*log10(lambda/(4*pi*delay));
    else
        output1(1,19)=0;
    end
    % QD plot(f2) parameters 
    if dod(1) == 0
        dod(1) = 0;
    end
    output2(1,1,timeDivision+1)=delay/c;
    output2(1,2,timeDivision+1)=20*log10(lambda/...
        (4*pi*delay));
    output2(1,3,timeDivision+1)=180*atan(dod(2)...
        /dod(1))/pi;
    output2(1,4,timeDivision+1)=180*acos(dod(3)/...
        magnitude(dod))/pi;
    output2(1,5,timeDivision+1)=180*atan(doa(2)/...
        doa(1))/pi;
    output2(1,6,timeDivision+1)=180*acos(doa(3)/...
        magnitude(doa))/pi;
    
    if size(output)>0
        output=[output;output1];
    else
        output=output1;
    end
end