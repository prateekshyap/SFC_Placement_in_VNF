# Input File Formats

1. network.txt

First line: Number of nodes in the network (N)
Second line: Number of cores available in each node
Third line: Inverted velocity depending on transmission medium
Fourth line: Average packet length in bits
Fifth line: Bandwidth range in bits per micro seconds
Next N lines: Adjacency matrix of the network

2. vm.txt

First line: Number of VM types (V_t)
Second line: Number of cores required for each VM type
Third line: Cost of each VM type

3. vnf.txt

First line: Number of VNF types (F_t)
Second line: Number of cores required for each VNF type
Next V_t lines: Cost of each VNF type for each VM type

4. rel.txt

First line: Failure probability of physical node
Second line: Failure probability of VM
Third line: Failure probability of VNF

5. obj.txt

First line: Value of alpha
Second line: Number of SFCs

6. ga.txt

First line: Probability of Mutation
Second line: Probability of Mutagenesis
Third line: Number of generations
Fourth line: Population size

# 