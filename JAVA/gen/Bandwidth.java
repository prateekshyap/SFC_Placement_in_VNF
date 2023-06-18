package gen;

import java.util.Map;
import java.util.TreeMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Queue;
import java.util.LinkedList;

public class Bandwidth
{
	private static Map<Integer,List<List<Double>>> bandwidth;
	public static void generateBandwidth(int N, Map<Integer,List<List<Double>>> network, double[] range)
	{
		bandwidth = new TreeMap<>(); // stores the bandwidth data as adjacency list
		Map<String,Double> linkBandwidthMap = new TreeMap<>(); // stores the bidirectional bandwidth value for each link
		for (Map.Entry link : network.entrySet()) // for each source and its corresponding destinations in the graph
		{
			int src = (Integer)link.getKey(); // get the source
			bandwidth.put(src,new ArrayList<>()); // add the source to the bandwidth map
			List<List<Double>> destWeights = (List)link.getValue(); // get the destinations and weights
			for (List<Double> destWeight : destWeights) // for each link
			{
				List<Double> destBand = new ArrayList<>(); // create a new link
				int dest = ((Double)destWeight.get(0)).intValue(); // get the destination
				String linkName = src < dest ? src+" "+dest : dest+" "+src; // create the key for bidirectional bandwidth value map
				if (!linkBandwidthMap.containsKey(linkName)) // if the key is not present in the map that means we need to generate a new bandwidth value and store it
					linkBandwidthMap.put(linkName,(Math.random()*(range[1]-range[0]))+range[0]); // random number generation within the given range
				destBand.add(destWeight.get(0)); // add the destination node to the new list
				destBand.add(linkBandwidthMap.get(linkName)); // add the corresponding bandwidth value
				bandwidth.get(src).add(destBand); // add the link to the bandwidth map for the current source
			}
		}
	}
	public static Map<Integer,List<List<Double>>> getBandwidthData() { return bandwidth; }
}