# SFC_Placement_in_VNF
Assignment of Service Function Chains to Virtual Network Functions

# Input File Formats
1. constants.txt <br>
This file contains some constant values in a row separated by spaces. The values are in the following order:
    1) Number of nodes in the network
    2) Types of VMs being considered (based on their capacity to host VNFs)
    3) Total number of VM instances
    4) Types of VNFs being considered (based on their functionalities)
    5) Total number of VNF instances
    6) Total number of SFCs
    7) Failure probability of nodes
    8) Failure probability of VMs
    9) Failure probability of VNFs
    10) Fixed packet size
    11) Bandwidth

2. network.txt <br>
This file contains the network in adjacency matrix format.

3. bandwidth.txt <br>
This file contains the bandwidths of each physical link in adjacency matrix format.

4. nodeStatus.txt <br>
This file contains a 1-D array which indicates the number of cores in each physical node.

5. vmTypes.txt <br>
This file contains a 1-D array which indicates the respective number of instances of each VM type.

6. vms.txt <br>
This file contains a 1-D array which indicates the type of each VM instance.

7. vnfTypes.txt <br>
This file contains a 1-D array which indicates the respective number of instances of each VNF type.

8. vnfs.txt <br>
This file contains a 1-D array which indicates the type of each VNF instance.

9. sfcLengths.txt <br>
This file contains a 1-D array which indicates the length of each SFC.

10. costVN.txt <br>
Cost matrix of hosting VMs on physical nodes.

11. costFV.txt <br>
Cost matrix of deploying VNFs on VMs.

12. GAPar.txt <br>
Parameters for GA

# sampleNetworks.m
This is the main file for the first small sample network taken for verification purpose.

# main.m
This is the main file considered after all the skeletal implementations are finalized.

#