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
% number_of_nodes - number of nodes
% switch_randomization - This is switch to turn ON or OFF randomization. 
% 1 = random
% time_division - it is the time instance number
% node - 2d array which contains all node locations
% node_v - 2d array which contains all node velocities
% vtx, vrx are velocities of tx and rx respectively
% Tx_initial and Rx_initial - these are locations of Rx/Tx in first time
% instance
% delt - it is the time interval between consecutive time instances
% CADop - CAD output
% Tx and Rx - these are locations of Rx/Tx in current time instance
% OUTPUT:
% node - 2d array which contains all node locations
% vtx, vrx are velocities of tx and rx respectively
% node_v - 2d array which contains all node velocities

% This function is to generate node locations according linear mobility 
% model and to avoid nodes crashing into walls.


function [node,Tx,Rx,vtx, vrx,node_v] = LinearMobility(number_of_nodes, switch_randomization,...
    time_division, node, node_v, vtx, vrx,Tx_initial,Rx_initial,delt,CADop,Tx,Rx)
% node= []; vtx =[];
% vrx =[]; node_v =[];

% This case is for number of nodes greater than 2 or when nodes are
% randomly generated
% For the first time division, the code computes Tx position from
% velocity and time difference, delt. The newly determined Tx postion is
% checked if it exists in the box (room) or not

if (number_of_nodes>=2 || switch_randomization==1) && time_division==0
        for Tx_i=1:number_of_nodes
            Tx=node(Tx_i,:)+(node_v(Tx_i,:).*delt.*time_division);
            
            node(Tx_i,:)=Tx;
            
            Tx_test=node(Tx_i,:)+(node_v(Tx_i,:).*delt...
                .*(time_division+1));
            
            Reflected=Tx_test;
            Intersection1=Tx;
            
            vector=Reflected-Intersection1;
            [switch3]=verifyPathMobility(Tx_test,Tx,vector,[0,0,0],...
                [0,0,0],CADop,2);
            if switch3==0 && number_of_nodes>2
                node_v(Tx_i,:)=-node_v(Tx_i,:);
            elseif switch3==0 && number_of_nodes==2
                vtx=-vtx;
            end
        end
    
end

% % This case is for number of nodes equal to 2 and when nodes are not
% % randomly generated
% % For the first time division, the code computes Tx position from
% % velocity and time difference, delt. The newly determined Tx postion is
% % checked if it exists in the box (room) or not
% 
% if time_division==0 && ~(number_of_nodes>2 || switch_randomization==1)
%         Tx=Tx_initial+(vtx.*delt.*time_division);
%         Rx=Rx_initial+(vrx.*delt.*time_division);
%         Tx_test=Tx_initial+(vtx.*delt.*(time_division+1));
%         Rx_test=Rx_initial+(vrx.*delt.*(time_division+1));
%         
%         Reflected=Tx_test;
%         Intersection1=Tx;
%         
%         vector=Reflected-Intersection1;
%         [switch3]=verifyPathMobility(Tx_test,Tx,vector,[0,0,0],[0,0,0],...
%             number_rows_CADop,CADop,2);
%         if switch3==0 && number_of_nodes>2
%             node_v(Tx_i,:)=-node_v(Tx_i,:);
%         elseif switch3==0 && number_of_nodes==2
%             vtx=-vtx;
%         end
%         
%         Reflected=Rx_test;
%         Intersection1=Rx;
%         
%         vector=Reflected-Intersection1;
%         [switch3]=verifyPathMobility(Rx_test,Rx,vector,[0,0,0],[0,0,0],...
%             number_rows_CADop,CADop,2);
%         if switch3==0 && number_of_nodes>2
%             node_v(Rx_i,:)=-node_v(Rx_i,:);
%         elseif switch3==0 && number_of_nodes==2
%             vrx=-vrx;
%             
%         end
% end

% This case is for number of nodes greater than 2 or when nodes are
% randomly generated
% For the first time division, the code computes Tx position from
% velocity and time difference, delt. The newly determined Tx postion is
% checked if it exists in the box (room) or not

if (number_of_nodes>=2 || switch_randomization==1) && time_division>0
        for Tx_i=1:number_of_nodes
            Tx=node(Tx_i,:)+(node_v(Tx_i,:).*delt);
            
            node(Tx_i,:)=Tx;
            
            Tx_test=node(Tx_i,:)+(node_v(Tx_i,:).*delt.*(1+1));
            
            Reflected = Tx_test;
            Intersection1 = Tx;
            
            vector = Reflected-Intersection1;
            [switch3] = verifyPathMobility(Tx_test, Tx,vector, [0,0,0],...
                [0,0,0], CADop, 2);
            if switch3==0
                
                node_v(Tx_i,:)=-node_v(Tx_i,:);
                
            end
        end
    
end

% % This case is for number of nodes equal to 2 and when nodes are not
% % randomly generated
% % For the nth time division, the code computes Tx position from
% % velocity and time difference, delt. The newly determined Tx postion is
% % checked if it exists in the box (room) or not
% 
% if time_division>0 && ~(number_of_nodes>2 || switch_randomization==1)
%         Tx=Tx+(vtx.*delt);
%         Rx=Rx+(vrx.*delt);
%         Tx_test=Tx+(vtx.*delt);
%         Rx_test=Rx+(vrx.*delt);
%         
%         Reflected=Tx_test;
%         Intersection1=Tx;
%         
%         vector=Reflected-Intersection1;
%         [switch3]=verifyPathMobility(Tx_test,Tx,vector,[0,0,0],[0,0,0],...
%             number_rows_CADop,CADop,2);
%         if switch3==0
%             vtx=-vtx;
%         end
%         
%         Reflected=Rx_test;
%         Intersection1=Rx;
%         
%         vector=Reflected-Intersection1;
%         [switch3]=verifyPathMobility(Rx_test,Rx,vector,[0,0,0],[0,0,0],...
%             number_rows_CADop,CADop,2);
%         if switch3==0
%             vrx=-vrx;
%         end
%         
% end

end