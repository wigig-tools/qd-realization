Primary steps to perform:

1.	The working root folder to has to be 'QDSoftware\', neither it’s subfolder 
nor it’s mother folder.
2.	Create or enter the existed scenario name to process at command line. You can
 use any scenario name to indicate the type, e.g. dense area. 
3.	Always configure all parameters in paraCfgCurrent.txt of the customized scenario 
folder, i.e. 'QDSoftware\CUSTOMIZEDSCENARIO\Input\paraCfgCurrent.txt'; if this 
'paraCfgCurrent.txt' file is not existed in this folder, the 'paraCfgDefault.txt' will 
be loaded as default setting.
4.	 Run the Matlab program 'main.m' present in root folder of step 1..The software 
first tries to load the existed input data of a customized scenario folder; if the 
customized input data does not exist, the software automatically load a default scenario 
with input data from RootFolder\InternalInput.
5.	The input parameters of Raytracer function has been combined into structure type. 
The main file calls 'raytracer.m'.
6.	The 'QDSoftware\Input\' folder includes the source file of input data, it should be 
kept in root folder as always. Unless the user create the new scenario folder manually, 
every new scenario created by script will copy the input data automatically to it's folder 
from QDSoftware\Input, including the paraCfgCurrent.txt and paraCfgDefault.txt as a reference.
7.	Last output data of the current scenario can be found in 'QDSoftware\CUSTOMIZEDSCENARIO\Output\'. 

X-------------------X---------------------X----------------------X---------------------X
Input:
The QD software has input read from files.
These files are present in the 'Input' folder. These files are not needed when 
switchRandomization = 1.
There are three types of files:
1) nodes.dat - this file contains the node coordinates (x, y, z) in each row. Make 
sure that the node coordinates are within the following ranges:


2) nodeVelocities.dat - this file contains the node velocities in x, y and z 
directions in each row. Make sure that the nodes.dat and nodeVelocities.dat have 
same number of rows. If this is not the case then an error will be thrown. This 
file is needed when MobilityType = 1 (linear mobility). 

3) NodePosition(n).dat - These files contain the set of node postions which evolve with
time. NodePosition(n) is the set of node positions of nth node which is given by first 
row in nodes.dat file. Similarly, NodePosition2 is the set of node positions of node
2 which is given by second row in nodes.dat file. This file is needed when 
MobilityType = 2.

4)parameterCfg.txt - This file is a customized input configuration file which has several 
important system parameters as listed in section below from customized input configuration 
file. If the paraCfgCurrent.txt does not exist, a default input configuration file 
paraCfgDefault.txt in folder Input will be used.
X-------------------X---------------------X----------------------X---------------------X
Parameters present in parameterCfg.txt file:
1) environmentFileName - This parameter defines the file name of the environment
to be setup in the system. 

2) generalizedScenario - This parameter defines the generalized scenario flag in
the system. A generalized scenario is a scenario which cannot be classified as purely 
indoor or outdoor scenario. For instance, building where there are nodes both inside 
the building and outside the building. The default setting is generalizedScenario = 1.

3) indoorSwitch - This parameter defines indoor switch flag in the system. The default
setting is indoorSwitch = 1.

4) inputScenarioName - This parameter defines customized input scenario name in the
system. The user is required to enter this as string value when prompted via MATLAB
command line.  

5) mobilitySwitch - This parameter indicates whether mobility is present or not in 
the given scenario. If mobilitySwitch = 1 specifies that the nodes are mobile. On the 
other hand, mobilitySwitch = 0 specifies that the nodes are static or stationary. 

6) mobilityType - This parameter defines the mobility model where mobilityType = 1 
indicates linear mobility and mobilityType = 2 indicates custom mobility.

7) numberOfNodes - This parameter defines the number of nodes present in the network. 

8) numberOfTimeDivisions - This parameter defines the total number of time steps. If 
numberOfTimeDivisions = 100 and totalTimeDuration = 10, then we have 100 time divisions 
for 10 seconds. Each time division is 0.1 secs in length.

9) referencePoint - This parameter defines the reference point of the center of limiting
 sphere. The default setting is referencePoint = [3,3,2].

10)selectPlanesByDist - This parameter defines the selection of planes/nodes by distance. 
selectPlanesByDist = 0 means that there is no limitation (Default). 

11)switchQDGenerator - This parameter indicates whether the diffuse components are generated 
or not while generating the components. If switchQDGenerator = 1 then diffuse components are 
generated with specular components otherwise only specular components are generated.

12)switchRandomization - This parameter indicates whether the location and velocity of each 
of the nodes are randomly generated or not. If switchRandomization = 1 then the locations and 
the velocities are generated randomly. On the other hand, if switchRandomization = 0 the locations 
and the velocities are imported from the files present in the Input folder.  

13)switchVisuals - This parameter defines the switch visual flag for the system. The default 
setting is switchVisuals = 0.

14)totalNumberOfReflections - This parameter denotes the highest order of reflection considered 
in the model. For example, totalNumberOfReflections = 2 means the model considers the LOS, the first 
and the second order reflections. The default setting is totalNumberOfReflections = 2.

15)totalTimeDuration - This parameter defines the time period  in seconds for which the simulation 
must run when the nodes are assumed to be mobile. The default setting is \textit{totalTimeDuration = 1.
X-------------------X---------------------X----------------------X---------------------X
Output files:

Ouput files are generated and saved in the 'Output' folder. Output folder further 
contains two folders: Ns3 and Visualizer.

Ns3 further has 2 folders- NodesPosition and QdFiles
1) NodesPosition - this folder consists of NodesPosition.txt file. The file contains
the node postions at first time interval. This is equivalent to nodes.dat file in
Input folder.

2) Qdfiles - this folder consists of Tx(i-1)Rx(j-1).txt trace files for ith and jth node that
will used as input for NS-3. The file format is :
i.     number of multipaths occupies the first row
ii.    Delay of each multipath is stored in the second row
iii.   pathGain of each multipath is stored in third row
iv.    phase offset of each multipath is stored in fourth row
v.     Angle of Departure, Elevation of each multipath is stored in fifth row
vi.    Angle of Departure, Azimuth of each multipath is stored in sixth row
vii.   Angle of Arrival, Elevation of each multipath is stored in seventh row
viii.  Angle of Arrival, Azimuth of each multipath is stored in eighth row
This format is repeated for every time instance if mobility is present. This means
ninth row will be number of multipath, tenth row will be delay of each multipath 
and so on.


Visualizer has 3 folders - MpcCoordinates, NodePositions and Roomcoordinates
1) MpcCoordinates - this folder contains multiple files whose nomeclature is given by 
MpcTx(i-1)Rx(j-1)Refl(m)Trc(n).dat. Here i and j are nodes, m is the order of reflection
and n is the number of time instance.
In the file, the first column gives the order of reflection. The number of columns
after the first column is 3*(m+2), where m is order of reflection. The 2-4 columns
are one of the node positions x,y,z parameters and the last three columns are the
other node positions x,y,z. The rest of the unmentioned column are points of 
intersections. To model the multipath, one has to simply connect the points in 
columns 2-4 to that of the columns in next three columns. The point in this set of 
three columns has to be connected to the next three columns. This has to be repeated
until the last three columns.

2) NodePositions - this folder consists of NodePositionsTrc(n).dat files - these are 
the node positions of nth time instance. These files are equivalent to nodes.dat 
file in Input folder.

3) RoomCoordinates - this folder consists of RoomCoordinates.dat file. This file has
coordinates of the CAD file used. In our case, it is a room. 
The format for RoomCoordinates.dat is described by a 2D array.Each row represents
a triangle. Each row is given as follows:
x1,y1,z1,x2,y2,x3,y3,z3
Where x1,y1,z1 are x,y,z coordinates of 1st vertex
x2,y2,z2 are x,y,z coordinates of 2nd vertex
x3,y3,z3 are x,y,z coordinates of 3rd vertex



