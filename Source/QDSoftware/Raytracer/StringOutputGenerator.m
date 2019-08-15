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
% Stores number of multipath
if time_division == 0
    StringOutput = strcat(num2str(count1), '\n');
else
    StringOutput = strcat(StringOutput, num2str(count1), '\n');
end

% Stores delay (secs)
for i = 1:count1
    
    if i == count1
        StringOutput = strcat(StringOutput, num2str(output(i,8)), '\n');
    else
        StringOutput = strcat(StringOutput, num2str(output(i,8)), ',');
    end
end

% Stores  path gain (dB)
for i = 1:count1
    
    if i == count1
        StringOutput = strcat(StringOutput, num2str(output(i,9)), '\n');
    else
        StringOutput = strcat(StringOutput, num2str(output(i,9)), ',');
    end
end

% Stores  phase (radians)
for i = 1:count1
    
    if i == count1
        StringOutput = strcat(StringOutput, num2str(output(i,18)), '\n');
        %StringOutput = strcat(StringOutput, num2str(0), '\n');
    else
        StringOutput=strcat(StringOutput,...
            num2str(output(i,18)),',');
            %StringOutput=strcat(StringOutput,num2str(0),',');
    end
end

% Stores Angle of departure elevation
for i = 1:count1
    
    if i == count1
        StringOutput = strcat(StringOutput, num2str(output(i,11)), '\n');
    else
        StringOutput = strcat(StringOutput, num2str(output(i,11)), ',');
    end
end

% Stores Angle of departure azimuth
for i = 1:count1
    
    if i == count1
        StringOutput = strcat(StringOutput, num2str(output(i,10)), '\n');
    else
        StringOutput = strcat(StringOutput, num2str(output(i,10)), ',');
    end
end

% Stores Angle of arrival elevation
for i = 1:count1
    if i == count1
        StringOutput = strcat(StringOutput, num2str(output(i,13)), '\n');
    else
        StringOutput = strcat(StringOutput, num2str(output(i,13)), ',');
    end
end

% Stores Angle of arrival azimuth
for i = 1:count1
    if i == count1
        StringOutput = strcat(StringOutput, num2str(output(i,12)), '\n');
    else
        StringOutput = strcat(StringOutput, num2str(output(i,12)), ',');
    end
end

