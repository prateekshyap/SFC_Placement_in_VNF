import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;

import java.util.Map;
import java.util.TreeMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

import env.network.Node;
import env.network.GenericServer;
import env.vm.VirtualMachine;
import env.vm.GenericVirtualMachine;
import env.vnf.VirtualNetworkFunction;
import gen.NetworkPaths;
import gen.Bandwidth;
import gen.sfc.ServiceFunctionChain;
import gen.sfc.SequentialSFC;
import est.Establishment;

/**
 * -------------------------------------------------------------------------------
 * 							List of variables used
 * -------------------------------------------------------------------------------
 * 
 * 1. Physical network
 * 
 * N = number of nodes in the network
 * physicalCores = number of cores available in each node
 * medium = inverted velocity depending on the transmission medium
 * L = average packet length
 * bandwidthRange = bandwidth range
 * nodes = set of nodes for the current network
 * networkGraph = current network as adjacency list
 * 
 * 2. VM
 * 
 * V_t = types of VMs
 * vmCoreRequirement = core requirement of each VM type
 * vmCost = cost of each VM type
 * vmTypes = list of VMs
 * 
 * 3. VNF
 * 
 * F_t = types of VNFs
 * vnfCoreRequirement = core requirement of each VNF type
 * vnfCost = cost of each VNF type for each VM type
 * vnfTypes = list of VNFs
 * 
 * 4. SFC
 * 
 * S = number of SFCs
 * sfcList = list of SFCs
 * 
 * 4. Objective function
 * 
 * alpha = weighing factor
 * 
 * 5. Reliability
 * 
 * rhoNode = failure probability of physical node
 * rhoVM = failure probability of VM
 * rhoVNF = failure probability of VNF
 * 
 * 6. GA
 * 
 * mutationProbability = mutation probability
 * mutagenesisProbability = mutagenesis probability
 * generations = number of generations
 * populationSize = size of population
 * 
 * */

class MainRel
{
	public static void main(String[] args) throws IOException
	{
		// setting the network path
		String inputFilePath = "input/newyork_16_49/";
		String outputFilePath = "output/newyork_16_49/";


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////// Reading Input Data ///////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		///////////////////////////////////////////// Reading Network Data ///////////////////////////////////////////////

		BufferedReader inputFile = new BufferedReader(new FileReader(new File(inputFilePath+"network.txt")));
		// First line: Number of nodes in the network (N)
		int N = Integer.parseInt(inputFile.readLine());
		// Second line: Number of cores available in each node
		int[] physicalCores = new int[N];
		String[] lineTokens = inputFile.readLine().trim().split("\\s+");
		for (int i = 0; i < N; ++i)
			physicalCores[i] = Integer.parseInt(lineTokens[i]);
		// Third line: Inverted velocity depending on transmission medium
		double medium = Double.parseDouble(inputFile.readLine());
		// Fourth line: Average packet length in bits
		int L = Integer.parseInt(inputFile.readLine());
		// Fifth line: Bandwidth range in bits per micro seconds
		double[] bandwidthRange = new double[2];
		String[] bandwidthRangeString = inputFile.readLine().trim().split(" +");
		bandwidthRange[0] = Double.parseDouble(bandwidthRangeString[0]);
		bandwidthRange[1] = Double.parseDouble(bandwidthRangeString[1]);
		// newyork.txt will give the adjacency matrix
		Map<String,Node> nodes = new TreeMap<>(); // stores the node objects pointed by their names
		Map<Integer,String> nodeIdName = new TreeMap<>(); // stores the node name to id map
		Map<Integer,List<List<Double>>> networkGraph = new TreeMap<>(); // stores the actual graph in adjacency list format
		inputFile = new BufferedReader(new FileReader(new File(inputFilePath+"newyork.txt")));
		String line = "";
		int nodeCount = 0;
		boolean nodeReading = false, linkReading = false;
		while ((line = inputFile.readLine()) != null) // till there is a new line
		{
			if (line.equals("NODES (")) // if nodes block started
			{
				nodeReading = true; // mark it
				continue;
			}
			else if (line.equals("LINKS (")) // if links block started
			{
				linkReading = true; // mark it
				continue;
			}
			else if (line.equals(")")) // if any block ended
				nodeReading = linkReading = false; // mark everything as false
			if (nodeReading) // if node reading is being done
			{
				String[] tokens = line.trim().split("\\s+");
				/*
				1st parameter: Node name as given in the input file
				2nd parameter: GenericServer object
				Inside GenericServer object:
				1st parameter: Node id (0 based indexing)
				2nd parameter: Node name as given in the input file
				3rd parameter: Number of physicalCores available
				4th parameter: Latitude value
				5th parameter: Longitude value
				*/
				nodeIdName.put(nodeCount++,tokens[0]);
				nodes.put(tokens[0],new GenericServer(nodes.size(),tokens[0],physicalCores[nodes.size()],Double.parseDouble(tokens[2]),Double.parseDouble(tokens[3])));
			}
			if (linkReading) // if link reading is being done
			{
				String[] tokens = line.trim().split("\\s+");
				Node node1 = nodes.get(tokens[2]); // get the first node
				Node node2 = nodes.get(tokens[3]); // get the second node
				int n1 = node1.getId();
				int n2 = node2.getId();
				double x1 = node1.getLatitude();
				double y1 = node1.getLongitude();
				double x2 = node2.getLatitude();
				double y2 = node2.getLongitude();
				if (!networkGraph.containsKey(n1)) networkGraph.put(n1,new ArrayList<>());
				if (!networkGraph.containsKey(n2)) networkGraph.put(n2,new ArrayList<>());
				// euclidean distance
				networkGraph.get(n1).add(Arrays.asList((double)n2,Math.sqrt(Math.pow((x2-x1),2)+Math.pow((y2-y1),2))));
				networkGraph.get(n2).add(Arrays.asList((double)n1,Math.sqrt(Math.pow((x2-x1),2)+Math.pow((y2-y1),2))));
			}
		}

		// System.out.println(nodes);
		// System.out.println(networkGraph);


		///////////////////////////////////////////// Reading VM Data ///////////////////////////////////////////////

		inputFile = new BufferedReader(new FileReader(new File(inputFilePath+"vm.txt")));
		// First line: Types of VMs
		int V_t = Integer.parseInt(inputFile.readLine());
		// Second line: Core requirements for each VM type
		lineTokens = inputFile.readLine().trim().split("\\s+");
		int[] vmCoreRequirement = new int[V_t];
		for (int i = 0; i < V_t; ++i)
			vmCoreRequirement[i] = Integer.parseInt(lineTokens[i]);
		// Third line: Cost of each VM type
		lineTokens = inputFile.readLine().trim().split("\\s+");
		double[] vmCost = new double[V_t];
		for (int i = 0; i < V_t; ++i)
			vmCost[i] = Double.parseDouble(lineTokens[i]);
		// store the VM types
		Map<Integer,VirtualMachine> vmTypes = new TreeMap<>();
		for (int i = 0; i < V_t; ++i)
			vmTypes.put(i,new GenericVirtualMachine(i,vmCoreRequirement[i],vmCost[i]));

		// System.out.println(vmTypes);


		///////////////////////////////////////////// Reading VNF Data ///////////////////////////////////////////////

		inputFile = new BufferedReader(new FileReader(new File(inputFilePath+"vnf.txt")));
		// First line: Types of VNFs
		int F_t = Integer.parseInt(inputFile.readLine());
		// Second line: Core requirements for each VNF type
		lineTokens = inputFile.readLine().trim().split("\\s+");
		int[] vnfCoreRequirement = new int[F_t];
		for (int i = 0; i < F_t; ++i)
			vnfCoreRequirement[i] = Integer.parseInt(lineTokens[i]);
		// Next V_t lines: Cost of each VNF type on each VM type
		double[][] vnfCost = new double[F_t][V_t]; 
		for (int vt = 0; vt < V_t; ++vt)
		{
			lineTokens = inputFile.readLine().trim().split("\\s+");
			for (int i = 0; i < F_t; ++i)
				vnfCost[i][vt] = Double.parseDouble(lineTokens[i]);
		}
		// store the VNF types
		Map<Integer,VirtualNetworkFunction> vnfTypes = new TreeMap<>();
		for (int i = 0; i < F_t; ++i)
		{
			double serviceRate = 1; // generate a random service rate for this function, or read from file, currently it is 1
			vnfTypes.put(i+1,new VirtualNetworkFunction(i+1,vnfCoreRequirement[i],vnfCost[i],serviceRate));
		}

		// System.out.println(vnfTypes);


		///////////////////////////////////////////// Reading Objective Data ///////////////////////////////////////////////

		inputFile = new BufferedReader(new FileReader(new File(inputFilePath+"obj.txt")));
		double alpha = Double.parseDouble(inputFile.readLine());
		int S = Integer.parseInt(inputFile.readLine());


		///////////////////////////////////////////// Reading Reliability Data ///////////////////////////////////////////////

		inputFile = new BufferedReader(new FileReader(new File(inputFilePath+"rel.txt")));
		// First line: Failure probability of physical node
		double rhoNode = Double.parseDouble(inputFile.readLine());
		// Second line: Failure probability of VM
		double rhoVM = Double.parseDouble(inputFile.readLine());
		// Third line: Failure probability of VNF
		double rhoVNF = Double.parseDouble(inputFile.readLine());


		///////////////////////////////////////////// Reading GA Data ///////////////////////////////////////////////

		inputFile = new BufferedReader(new FileReader(new File(inputFilePath+"ga.txt")));
		// First line: Probability of Mutation
		double mutationProbability = Double.parseDouble(inputFile.readLine());
		// Second line: Probability of Mutagenesis
		double mutagenesisProbability = Double.parseDouble(inputFile.readLine());
		// Third line: Number of generations
		int generations = Integer.parseInt(inputFile.readLine());
		// Fourth line: Population size
		int populationSize = Integer.parseInt(inputFile.readLine());


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////// Generating Required Data ///////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		///////////////////////////////////////////// Shortest Path Data ///////////////////////////////////////////////
		NetworkPaths.executeFloydWarshall(N,networkGraph);
		
		///////////////////////////////////////////// Bandwidth Data ///////////////////////////////////////////////
		Bandwidth.generateBandwidth(N,networkGraph,bandwidthRange);

		///////////////////////////////////////////// SFC Data ///////////////////////////////////////////////

		Map<Integer,ServiceFunctionChain> sfcList = new TreeMap<>();
		for (int i = 0; i < S; ++i)
		{
			int length = (int)((Math.random()*((0.8*F_t)-3))+3); // generating a random length
			// generating a random permutation
			List<Integer> perm = new ArrayList<>();
			for (int j = 1; j <= F_t; ++j)
				perm.add(j);
			Collections.shuffle(perm);
			int[] chain = new int[length+1];
			// taking the first length items as the SFC
			for (int j = 0; j < length; ++j)
				chain[j+1] = (Integer)perm.get(j);
			// generating arrival and drop rates
			double[] arrivalRate = new double[F_t+1];
			double[] dropRate = new double[F_t+1];
			for (int j = 0; j < length; ++j)
				arrivalRate[chain[j+1]] = Math.round(Math.random()*(10-1)+1);
			sfcList.put(i,new SequentialSFC(i,length,chain,arrivalRate,dropRate));
		}

		// System.out.println(sfcList);

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////// Designed Algorithm ///////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		///////////////////////////////////////////// Greedy VM Hosting ///////////////////////////////////////////////

		Establishment.greedyHosting(N,V_t,nodeIdName,nodes,vmTypes);
		int V = Establishment.getVMInstanceCount();
		int[] vmNodeMap = Establishment.getVMNodeMap();
		int[] vmCount = Establishment.getVMCount();
		int[] vmType = Establishment.getVMType();

		// System.out.println(nodes);
		// for (int v = 0; v < V_t; ++v)
		// 	System.out.print(vmCount[v]+" ");
		// System.out.println();
		// for (int v = 0; v < V; ++v)
		// 	System.out.print(vmType[v]+" ");
		// System.out.println();
		// for (int v = 0; v < V; ++v)
		// 	System.out.print(vmNodeMap[v]+" ");
		// System.out.println();
	
		///////////////////////////////////////////// GA Based Deployment and Assignment ///////////////////////////////////////////////


	}
}