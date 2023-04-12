# SFC_Placement_in_VNF
This repository contains the code for the Genetic Algorithm-based solution to the famous SFC placement problem in NFV. The objective was to give 3-4 levels of backup assignments for the SFCs minimizing the overall cost. Before browsing this repository, please ensure you have gone through the basics of NFV. Find the report [here](./report.pdf).

# Getting Started
## List of active files
| File Name | LOC | Purpose | 
| :--------: | :--------: | :--------: | 
| [main](./main.m) | 575 | Driver File |
| [greedyHosting](./greedyHosting.m) | 59 | Function to host the VMs |
| [generateVNFData](./generateVNFData.m) | 110 | Function to generate the VNF data before Deployment |
| [reliableMetaHeuristicDeployment](./reliableMetaHeuristicDeployment.m) | 92 | Meta Heuristic Deployment with Reliability |
| [reliableGeneticAlgorithm](./reliableGeneticAlgorithm.m) | 224 | Genetic Algorithm with Reliability |
| [generatePopulation](./generatePopulation.m) | 57 | Function to generate the initial population with Reliability |
| [crossoverRel](./crossoverRel.m) | 269 | Hybrid Offspring Formation Algorithm with Reliability |
| [getSortedChildrenRel](./getSortedChildrenRel.m) | 65 | Function to sort the offsprings with Reliability |
| [calculateReliableFitnessValue](./calculateReliableFitnessValue.m) | 317 | Function to adjust the chromosomes in Genetic Algorithm with Reliability |
| [allPairShortestPath](./allPairShortestPath.m) | 39 | Floyd-Warshall Algorithm |
| [y1Rel](./y1Rel.m) | 13 | Function to calculate y1 with Reliability|
| [y2Rel](./y2Rel.m) | 46 | Function to calculate y2 with Reliability|
| [y3Rel](./y3Rel.m) | 37 | Function to calculate y3 with Reliability|
| [Node](./Node.m) | 14 | Class for Physical Nodes |
| [VM](./VM.m) | 14 | Class for VMs |
| [SFC](./SFC.m) | 18 | Class for SFCs |
| [generateNetwork](./generateNetwork.m) | 151 | Function to generate Network for testing |
| [generateBandwidth](./generateBandwidth) | 13 | Function to generate Network Bandwidths for testing |

## List of potentially usable files
| File Name | LOC | Purpose | 
| :--------: | :--------: | :--------: | 
| [plotTemp](./plotTemp.m) | 23 | Rough File to generate plots |
| [print](./print.m) | 365 | Sample code to print variables into a file |
| [findBridges](./findBridges.m) | 51 | Function to find the Bridges in a network |
| [FileReadTest](./FileReadTest.m) | 367 | Rough File to check new things |

## List of outdated files
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

Last updated on: 11-Apr-2023 05:34 PM

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