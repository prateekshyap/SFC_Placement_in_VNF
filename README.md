# SFC_Placement_in_VNF
Assignment of Service Function Chains to Virtual Network Functions

# Input File Formats
1. constants.txt <br>
This file contains six constant values in a row separated by spaces. The values are in the following order:
    1) Number of nodes in the network
    2) Types of VMs being considered (based on their capacity to host VNFs)
    3) Total number of VM instances
    4) Types of VNFs being considered (based on their functionalities)
    5) Total number of VNF instances
    6) Total number of SFCs
    7) Failure probability of nodes
    8) Failure probability of VMs
    9) Failure probability of VNFs

2. network.txt <br>
This file contains the network in adjacency matrix format.

3. vmTypes.txt <br>
This file contains a 1-D array which indicates the respective number of instances of each VM type.

4. vms.txt <br>
This file contains a 1-D array indicating the type of each VM instance.

5. vnfInstanceCount.txt <br>
This file contains a 1-D array indicating the respective number of instances of each VNF.

6. vnfs.txt <br>
This file contains a 1-D array indicating the type of each VNF instance.

7. sfcLengths.txt <br>
This file contains a 1-D array indicating the length of each SFC.

8. costVN.txt <br>
Cost matrix of hosting VMs on physical nodes.

9. costFV.txt <br>
Cost matrix of deploying VNFs on VMs.