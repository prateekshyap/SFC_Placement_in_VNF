package est;

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

import env.network.Node;
import env.vm.VirtualMachine;

public class Establishment
{
	private static int V; // total number of VM instances
	private static int[] vmNodeMap; // a map indicating the corresponding node for each VM instance
	private static int[] vmType; // indicates the type of VM for each instace
	private static int[] vmCount; // indicates the count of instances for each VM type
	private static double vmCost; // cost of VMs for the current node
	private static List<Integer> vmCombination; // combination of VMs for the current node
	public static void greedyHosting(int N, int V_t, Map<Integer,String> nodeIdName, Map<String,Node> nodes, Map<Integer,VirtualMachine> vmTypes)
	{
		Map<Integer,Integer> coreVMIndex = new HashMap<>(); // stores the VM type to VM index map
		for (int v = 0; v < V_t; ++v) // for each VM type
			coreVMIndex.put(vmTypes.get(v).getCoreRequirement(),v); // put the index as the value and the number of cores required as the key
		int[][] allocationMatrix = new int[N][V_t]; // this will store the count of VMs used for each node
		for (int n = 0; n < N; ++n) // for each node
		{
			int totalCores = nodes.get(nodeIdName.get(n)).getCores(); // get the total cores available
			vmCost = Double.MAX_VALUE; // re-initialize cost
			vmCombination = new ArrayList<>(); // re-initialize combination
			recurHost(totalCores,V_t,vmTypes,0,new ArrayList<Integer>()); // call recursion
			for (Integer vm : vmCombination) // for each VM in the combination
				++allocationMatrix[n][coreVMIndex.get(vm)]; // store the count in the allocation matrix
		}
		vmCount = new int[V_t];
		for (int v = 0; v < V_t; ++v) // for each VM type
			for (int n = 0; n < N; ++n) // for each node
				vmCount[v] += allocationMatrix[n][v]; // add the count for the corresponding VM type
		V = 0;
		for (int v = 0; v < V_t; ++v) // for each VM type
			V += vmCount[v]; // add the count to the variable
		int index = 0;
		vmNodeMap = new int[V];
		vmType = new int[V];
		for (int v = 0; v < V_t; ++v) // for each VM type
		{
			for (int n = 0; n < N; ++n) // for each node
			{
				while (allocationMatrix[n][v] > 0) // till more VM instances are remaining
				{
					vmNodeMap[index] = n; // store the node in the corresponding index
					vmType[index] = v; // store the VM type in the corresponding index
					++index; // increment the index
					--allocationMatrix[n][v]; // decrement the count
				}
			}
		}
		int[] vmCountPerNode = new int[N];
		List[] vmListPerNode = new List[N];
		for (int n = 0; n < N; ++n)
			vmListPerNode[n] = new ArrayList<Integer>();
		for (int v = 0; v < V; ++v)
		{
			++vmCountPerNode[vmNodeMap[v]];
			vmListPerNode[vmNodeMap[v]].add(v);
		}
		for (int n = 0; n < N; ++n)
		{
			Node node = nodes.get(nodeIdName.get(n));
			node.setVMCount(vmCountPerNode[n]);
			node.setVMList(vmListPerNode[n]);
		}
	}

	public static int getVMInstanceCount() { return V; }
	public static int[] getVMNodeMap() { return vmNodeMap; }
	public static int[] getVMCount() { return vmCount; }
	public static int[] getVMType() { return vmType; }

	private static void recurHost(int availableCores, int V_t, Map<Integer,VirtualMachine> vmTypes, double currCost, List<Integer> currCombination)
	{
		if (availableCores == 0) // if the node becomes full
		{
			if (currCost < vmCost) // if the cost is less
			{
				vmCost = currCost; // update the cost
				// update the combination
				vmCombination = new ArrayList<>();
				for (Integer val : currCombination)
					vmCombination.add(val);
			}
			return;
		}

		for (int v = 0; v < V_t; ++v) // for each VM type
		{
			int requiredCores = vmTypes.get(v).getCoreRequirement(); //get the required cores for the current VM type
			if (requiredCores <= availableCores) // if required cores is less than the available cores on the node
			{
				currCombination.add(requiredCores); // add the core to the combination
				recurHost(availableCores-requiredCores,V_t,vmTypes,currCost+vmTypes.get(v).getCost(),currCombination); // recursion call for the remaining cores
				currCombination.remove(currCombination.size()-1); // backtrack
			}
		}
	}
}