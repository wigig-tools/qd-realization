function [node, nodeVelocity] = NodeExtractor(numberOfNodes,...
    switchRandomization, timeDivision, node, nodeVelocity, NodePosition, delt)
% INPUT:
% number_of_nodes - number of nodes
% switch_randomization - This is switch to turn ON or OFF randomization.
% 1 = random
% time_division - it is the time instance number
% node - 2d array which contains all node locations
% node_v - 2d array which contains all node velocities
% NodePosition - these are positions of nodes in a 2D array which are
% extracted from a file
% vtx, vrx are velocities of tx and rx respectively
% delt - it is the time interval between consecutive time instances
% number_rows_CADop - number of rows of CAD output
% OUTPUT:
% node - 2d array which contains all node locations
% node_v - 2d array which contains all node velocities
%
% This function is to extract node positions from a file and compute node
% velocities from the position values


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


% This case is for number of nodes greater than 2 or when nodes are
% randomly generated
% For the first time division, the code extracts Tx position from
% NodePosition parameter. The velocity is computed from the difference in
% nodepositions

if (numberOfNodes>2 || switchRandomization==1) && timeDivision==0
    node = nan(numberOfNodes, 3);
    for Tx_i = 1:numberOfNodes
        node(Tx_i,:) = NodePosition(1,:,Tx_i);
        
        nodeVelocity(Tx_i,:)= (NodePosition(timeDivision+1,:,Tx_i)...
            - NodePosition(timeDivision+2,:,Tx_i))./delt;
    end
end

% This case is for number of nodes equal to 2 and when nodes are not
% randomly generated
% For the first time division, the code extracts Tx/Rx position from
% NodePosition parameter. The velocity is computed from the difference in
% nodepositions

if timeDivision==0 && ~(numberOfNodes>2 || switchRandomization==1)
    Tx = NodePosition(timeDivision+1,:,1);
    Rx = NodePosition(timeDivision+1,:,2);
    node(1,:)=Tx;
    node(2,:)=Rx;
    
    nodeVelocity(1,:)= (NodePosition(timeDivision+1,:,1)...
        - NodePosition(timeDivision+2,:,1))./delt;
    nodeVelocity(2,:)= (NodePosition(timeDivision+1,:,2)...
        - NodePosition(timeDivision+2,:,2))./delt;
    
end

% This case is for number of nodes greater than 2 or when nodes are
% randomly generated
% For the nth time division, the code extracts Tx position from
% NodePosition parameter. The velocity is computed from the difference in
% nodepositions

if (numberOfNodes>2 || switchRandomization==1) && timeDivision>0
    node = nan(numberOfNodes, 3);
    for Tx_i = 1:numberOfNodes
        node(Tx_i, :) = NodePosition(timeDivision+1,:,Tx_i);
        
        nodeVelocity(Tx_i,:)= (NodePosition(timeDivision+1,:,Tx_i)...
            - NodePosition(timeDivision+2,:,Tx_i))./delt;
        
    end
end

% This case is for number of nodes equal to 2 and when nodes are not
% randomly generated
% For the first nth division, the code extracts Tx/Rx position from
% NodePosition parameter. The velocity is computed from the difference in
% nodepositions

if timeDivision>0 && ~(numberOfNodes>2 || switchRandomization==1)
    Tx = NodePosition(timeDivision+1,:,1);
    Rx = NodePosition(timeDivision+1,:,2);
    node(1,:)=Tx;
    node(2,:)=Rx;
    
    nodeVelocity(1,:)= (NodePosition(timeDivision+1,:,1)...
        - NodePosition(timeDivision+2,:,1))./delt;
    nodeVelocity(2,:)= (NodePosition(timeDivision+1,:,2)...
        - NodePosition(timeDivision+2,:,2))./delt;
    
end

end