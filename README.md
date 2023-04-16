# SFC_Placement_in_VNF
This repository contains the code for the Genetic Algorithm-based solution to the famous SFC placement problem in NFV. The objective was to give 3-4 levels of backup assignments for the SFCs minimizing the overall cost. Before browsing this repository, please ensure you have gone through the basics of NFV. Find the report [here](./report.pdf).

# Getting Started
## List of active files
These files are actively modified and working properly.

| File Name | LOC | Purpose | 
| :--------: | :--------: | :--------: | 
| [main](./main.m) | 593 | Driver File |
| [greedyHosting](./greedyHosting.m) | 59 | Function to host the VMs |
| [generateVNFData](./generateVNFData.m) | 110 | Function to generate the VNF data before Deployment |
| [reliableMetaHeuristicDeployment](./reliableMetaHeuristicDeployment.m) | 158 | Meta Heuristic Deployment with Reliability |
| [reliableGeneticAlgorithm](./reliableGeneticAlgorithmImpl.m) | 245 | Genetic Algorithm with Reliability |
| [generatePopulation](./generatePopulation.m) | 57 | Function to generate the initial population with Reliability |
| [crossoverRel](./crossoverRel.m) | 294 | Hybrid Offspring Formation Algorithm with Reliability |
| [getSortedChildrenRel](./getSortedChildrenRel.m) | 65 | Function to sort the offsprings with Reliability |
| [calculateReliableFitnessValue](./calculateReliableFitnessValue.m) | 346 | Function to adjust the chromosomes in Genetic Algorithm with Reliability |
| [allPairShortestPath](./allPairShortestPath.m) | 39 | Floyd-Warshall Algorithm |
| [y1Rel](./y1Rel.m) | 13 | Function to calculate y1 with Reliability|
| [y2Rel](./y2Rel.m) | 46 | Function to calculate y2 with Reliability|
| [y3Rel](./y3Rel.m) | 37 | Function to calculate y3 with Reliability|
| [Node](./Node.m) | 14 | Class for Physical Nodes |
| [VM](./VM.m) | 14 | Class for VMs |
| [SFC](./SFC.m) | 18 | Class for SFCs |
| [generateNetwork](./generateNetwork.m) | 151 | Function to generate Network for testing |
| [generateBandwidth](./generateBandwidth) | 14 | Function to generate Network Bandwidths for testing |
| Total | 2273 |  |

## List of potentially usable files
| File Name | LOC | Purpose | 
| :--------: | :--------: | :--------: | 
| [plotTemp](./plotTemp.m) | 23 | Rough File to generate plots |
| [print](./print.m) | 365 | Sample code to print variables into a file |
| [findBridges](./findBridges.m) | 51 | Function to find the Bridges in a network |
| [FileReadTest](./FileReadTest.m) | 408 | Rough File to check new things |
| Total | 847 |  |

## List of outdated files
These files have not been modified recently. If you want to run them, you might need to change some variable dimensions and function parameters.

| File Name | LOC | Purpose | 
| :--------: | :--------: | :--------: | 
| [sampleNetworks](./sampleNetworks.m) | 1219 | Old Driver File |
| [VMHost](./VMHost.m) | 53 | Sequential VM Hosting |
| [VNFDeploy](./VNFDeploy.m) | 50 | Sequential VNF Deployment |
| [greedyDeployment](./greedyDeployment.m) | 7 | Function to deploy the VNFs |
| [metaHeuristicDeployment](./metaHeuristicDeployment.m) | 169 | Meta Heuristic Deployment without Reliability |
| [geneticAlgorithm](./geneticAlgorithm.m) | 409 | Genetic Algorithm without Reliability |
| [crossover](./crossover.m) | 254 | Hybrid Offspring Formation Algorithm without Reliability |
| [getSortedChildren](./getSortedChildren.m) | 62 | Function to sort the offsprings without Reliability |
| [getBestTwoChildren](./getBestTwoChildren.m) | 26 | Function to get the two best performing offsprings |
| [bruteForceDeployment](./bruteForceDeployment.m) | 94 | Name suffices |
| [bruteForceAssignment](./bruteForceAssignment.m) | 86 | Name suffices |
| [SFCAssign](./SFCAssign.m) | 26 | Sequential SFC Assignment |
| [calculateFitnessValue](./calculateFitnessValue.m) | 118 | Function to adjust the chromosomes in Genetic Algorithm without Reliability |
| [calculateCost](./calculateCost.m) | 47 | Function to calculate y1, y2, y3 together |
| [bellmanFord](./bellmanFord.m) | 39 | Bellman Ford Algorithm |
| [getY1](./getY1.m) | 14 | Function to calculate y1 without Reliability|
| [getY2](./getY2.m) | 19 | Function to calculate y2 without Reliability|
| [getY3](./getY3.m) | 18 | Function to calculate y3 without Reliability|
| [objective](./objective.m) | 139 | Function to calculate y1, y2 and y3 together |
| [Function](./Function.m) | 5 |  |
| Total | 2854 |  |

Last updated on: 13-Apr-2023 10:33 AM

## Input File Formats
1. **constants.txt** <br>
### Description
This file contains some constant values in a row separated by spaces. The values are in the following order:
    1) Number of nodes in the network
    2) Types of VMs being considered (based on their capacity to host VNFs)
    3) Types of VNFs being considered (based on their functionalities)
    4) Number of cores required by each VNF
    5) Type of the transmission medium
    6) Value of weighing factor i.e. \alpha
    7) Failure probability of nodes
    8) Failure probability of VMs
    9) Failure probability of VNFs
    10) Fixed packet size

2. **network.txt** <br>
This file contains the network in adjacency matrix format.

3. **bandwidth.txt** <br>
This file contains the bandwidths of each physical link in adjacency matrix format.

4. **nodeStatus.txt** <br>
This file contains a 1-D array which indicates the number of cores in each physical node.

5. **vmTypes.txt** <br>
This file contains a 1-D array which indicates the respective numbers of cores required by each VM type.

6. **vnfTypes.txt** <br>
This file contains a 1-D array which indicates the respective number of instances of each VNF type.

7. **bandwidthRange.txt** <br>
This file contains the range of bandwidth in Mbps.

10. **costVN.txt** <br>
Cost matrix of hosting VMs on physical nodes.

11. **costFV.txt** <br>
Cost matrix of deploying VNFs on VMs.

12. **GAPar.txt** <br>
Parameters for Genetic Algorithm.

## main.m
Execution starts from this file.
1. At **line number - 34** log file is opened. You can copy the print statements from [print](./print.m) file to other files and the corresponding results will be stored in the log file.
2. You can change the input and output file paths at **line number - 45** and **46**. This change should be done according to the network being chosen. Note that some of the network input data are incomplete. Take the files with a pinch of salt.
3. You can change the number of SFCs at **line number - 168**.
4. You can change or add VM hosting strategies at **line number - 200**.
5. You can change or add VNF deployment strategies at **line number - 219**.
6. Image generation is done at **line number - 319**. Graphviz files are generated for the network and the SFC assignments.

## greedyHosting.m
It uses a greedy backtracking approach to host the VMs on the physical network ensuring cost minimization.

## generateVNFData.m
This file generates the number of VNF instances required for each VNF according to the given set of SFCs. There are two strategies i.e. **random increment with floor function** and **strategic decrement with round function**. You can comment and uncomment the respective blocks to change the strategy.

## reliableMetaHeuristicDeployment.m
This is the parent file that calls [Reliable Genetic Algorithm](./reliableGeneticAlgorithm.m) for each SFC. You can change the capacity calculation strategies at **line number - 34**. You can set the GA parameters at **line number - 51**. There are different blocks of code to get the results. You can comment and uncomment them according to the requirement.

## reliableGeneticAlgorithmImpl.m
This file contains the implementation of Genetic Algorithm. You can set the total number of offsprings at **line number - 19**. Note that this step will break the entire code writen further. Please change the logic accordingly. Initial population generation is done at **line number - 21**. Offspring formation is done at **line number - 57**. You should uncomment the blocks at **line number - 71** and **81** when you are executing GA with uniform crossover. Mutagenesis is performed at **line number - 153**. Progress bar implementation is done at **line number - 218**.

## generatePopulation.m
This file contains the code to generate the initial node and VM population.

## crossoverRel.m
This file contains different crossover and offspring generation strategies namely cyclic crossover, standard two-point crossover, uniform crossover and hybrid crossover and generation. You can uncomment the respective blocks. Please make sure that the other blocks are properly commented. You can add more operations. Currently all the operations support four offsprings.

## getSortedChildrenRel.m
This file contains the code to sort the offsprings in increasing order according to their fitness values.

## calculateReliableFitnessValue.m
This file adjusts the chromosomes before calculating the fitness value. Objective function is calculated at **line number - 344**.

## y1Rel.m - y3Rel.m
These files calculate the fitness value. For more details please refer to the [report](./report.pdf).