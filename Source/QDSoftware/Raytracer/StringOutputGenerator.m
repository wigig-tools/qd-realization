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
% INPUT:
% time_division - it is the time instance number
% String_output - it is the final output of multipath stored as string
% output - matlab variable which contains multipath variables
% count1 - index of current row used in output parameter
% OUTPUT:
% String_output - it is the final output of multipath stored as string

% This function generates the string output which is then written onto a
% text file

function [StringOutput] = StringOutputGenerator(time_division,...
    StringOutput, output)
sizeOutput = size(output);
count1 = sizeOutput(1);
StringOutput = char(StringOutput);
% Stores number of multipath
if time_division == 0
    StringOutput = [];
end

% Number of rays in this time step
numRays = [num2str(count1), '\n'];

% Stores delay (secs)
delay = col2str(output,8,count1);

% Stores  path gain (dB)
pathGain = col2str(output,9,count1);

% Stores  phase (radians)
phase = col2str(output,18,count1);

% Stores Angle of departure elevation
aodEl = col2str(output,11,count1);

% Stores Angle of departure azimuth
aodAz = col2str(output,10,count1);

% Stores Angle of arrival elevation
aoaEl = col2str(output,13,count1);

% Stores Angle of arrival azimuth
aoaAz = col2str(output,12,count1);

% Concatenate
StringOutput = [StringOutput,...
    numRays,delay,pathGain,phase,aodEl,aodAz,aoaEl,aoaAz];

end

function s = col2str(output,col,count1)

s = cell(1,count1);
for i = 1:count1
    if i == count1
        s{i} = [num2str(output(i,col)), '\n'];
    else
        s{i} = [num2str(output(i,col)), ','];
    end
end

if isempty(s)
    s = [];
else
    s = strcat(s{:});
end

end
