function writeTargetConnections(tgtNum, visualizerPath)
%%WRITETARGETCONNECTIONS write joints indeces in visualizer output folder. 
%
%   WRITETARGETCONNECTIONS(T,P) write the files targetConnections in the
%   visualizer output folder, given the number of T-rays ray traced T and
%   the path of the visualizer folder. 
%   It assumes a human target with 17joints. In case the simulated targets
%   T are not multiple of 17 the file is not written and a warning is
%   raised.
%

%----------------------Software Disclaimer-----------------------------
%
% NIST-developed software is provided by NIST as a public service. You may
% use, copy and distribute copies of the software in any medium, provided
% that you keep intact this entire notice. You may improve, modify and
% create derivative works of the software or any portion of the software,
% and you  may copy and distribute such modifications or works. Modified
% works should carry a notice stating that you changed the software and
% should note the date and nature of any such change. Please explicitly
% acknowledge the National Institute of Standards and Technology as the
% source of the software.
%
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION
% OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND
% DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF
% THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS
% WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT
% NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF
% THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% and distributing the software and you assume all risks associated with
% its use, including but not limited to the risks and costs of program
% errors, compliance with applicable laws, damage to or loss of data,
% programs or equipment, and the unavailability or interruption of
% operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property. The
% software developed by NIST employees is not subject to copyright
% protection within the United States.
%
% Modified by: Steve Blandino <steve.blandino@nist.gov>


connections = [...
    0, 1;...
    1, 2;...
    1, 3; ...
    1, 4;...
    4, 6;...
    6, 8;...
    3, 5;...
    5, 7;...
    0, 10;...
    0, 9;...
    10, 12;...
    9, 11;...
    12, 14;...
    11, 13;...
    14, 16; ...
    13, 15 ...
    ];

if mod(tgtNum,17)==0
    for targetId = 1:(tgtNum/17)
        writematrix(connections, fullfile(visualizerPath,sprintf('target%dconnection.txt', targetId)))
    end
else
    warning('Define connection for visualizer')
end

end