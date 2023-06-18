package gen;

import java.util.Map;
import java.util.List;

public class NetworkPaths
{
	private static double[][] shortestPathMatrix;
	private static int[][] nextHop;
	public static void executeFloydWarshall(int N, Map<Integer,List<List<Double>>> network)
	{
		shortestPathMatrix = new double[N][N];
		nextHop = new int[N][N];
		double[][] D0 = new double[N][N];
		for (Map.Entry link : network.entrySet()) // for each link in the adjacency matrix
		{
			int src = (Integer)link.getKey(); // get the source
			List<List<Double>> destWeights = (List)link.getValue(); // get the list of destinations and weights
			for (List<Double> destWeight : destWeights) // for each destination and weight
			{
				int dest = ((Double)destWeight.get(0)).intValue(); // get the destination
				double weight = (Double)destWeight.get(1); // get the weight
				D0[src][dest] = weight; // store in the matrix
			}
		}
		for (int r = 0; r < N; ++r)
			for (int c = 0; c < N; ++c)
				if (D0[r][c] == 0 && r != c)
					D0[r][c] = Double.MAX_VALUE;
		for (int r = 0; r < N; ++r)
			for (int c = 0; c < N; ++c)
				if (D0[r][c] == Double.MAX_VALUE)
					nextHop[r][c] = -1;
				else nextHop[r][c] = c;
		for (int k = 0; k < N; ++k)
			for (int r = 0; r < N; ++r)
				for (int c = 0; c < N; ++c)
				{
					if (D0[r][k] == Double.MAX_VALUE || D0[k][c] == Double.MAX_VALUE)
						continue;
					if (D0[r][c] > D0[r][k]+D0[k][c])
					{
						D0[r][c] = D0[r][k]+D0[k][c];
						nextHop[r][c] = nextHop[r][k];
					}
				}
		for (int r = 0; r < N; ++r)
			for (int c = 0; c < N; ++c)
				shortestPathMatrix[r][c] = D0[r][c];
	}
	public static double[][] getShortestPathMatrix() { return shortestPathMatrix; }
	public static int[][] getNextHop() { return nextHop; }
}