import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.IOException;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.File;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.TreeMap;
import java.util.Set;
import java.util.LinkedHashSet;
import java.util.Arrays;

class ImportNetwork
{
	public static void main(String[] args) throws IOException
	{
		boolean nodeReading = false, linkReading = false;
		// BufferedReader fileReader = new BufferedReader(new FileReader(new File("input/newyork_16_49/newyork.txt")));
		// BufferedReader fileReader = new BufferedReader(new FileReader(new File("input/germany_50_88/germany50.txt")));
		// BufferedReader fileReader = new BufferedReader(new FileReader(new File("input/india_35_80/india35.txt")));
		BufferedReader fileReader = new BufferedReader(new FileReader(new File("input/ta2_65_108/ta2.txt")));
		Map<String,List<Double>> nodes = new LinkedHashMap<>();
		Set<String> links = new LinkedHashSet<>();
		String line = "";
		while ((line = fileReader.readLine()) != null)
		{
			if (line.equals("NODES ("))
			{
				nodeReading = true;
				continue;
			}
			else if (line.equals("LINKS ("))
			{
				linkReading = true;
				continue;
			}
			else if (line.equals(")"))
				nodeReading = linkReading = false;

			if (nodeReading)
			{
				String[] tokens = line.trim().split(" +");
				nodes.put(tokens[0],Arrays.asList((double)(nodes.size()),Double.parseDouble(tokens[2]),Double.parseDouble(tokens[3])));
			}

			if (linkReading)
			{
				String[] tokens = line.trim().split(" +");
				links.add(tokens[2]+" "+tokens[3]);
			}
		}

		fileReader.close();

		int N = nodes.size();
		int E = links.size();
		
		double[][] network = new double[N][N];
		for (String link : links)
		{
			String[] tokens = link.split(" ");
			List<Double> node1 = nodes.get(tokens[0]);
			List<Double> node2 = nodes.get(tokens[1]);
			int n1 = node1.get(0).intValue();
			int n2 = node2.get(0).intValue();
			double x1 = node1.get(1);
			double x2 = node2.get(1);
			double y1 = node1.get(2);
			double y2 = node2.get(2);
			network[n1][n2] = network[n2][n1] = Math.sqrt(Math.pow((x2-x1),2)+Math.pow((y2-y1),2));
		}

		int[] degrees = new int[N];
		for (int i = 0; i < N; ++i)
			for (int j = 0; j < N; ++j)
				if (network[i][j] != 0)
					++degrees[i];

		// BufferedWriter fileWriter = new BufferedWriter(new FileWriter(new File("input/newyork_16_49/Network_Data.txt")));
		// BufferedWriter fileWriter = new BufferedWriter(new FileWriter(new File("input/germany_50_88/Network_Data.txt")));
		// BufferedWriter fileWriter = new BufferedWriter(new FileWriter(new File("input/india_35_80/Network_Data.txt")));
		BufferedWriter fileWriter = new BufferedWriter(new FileWriter(new File("input/ta2_65_108/Network_Data.txt")));
		fileWriter.write("Adjacency Matrix:"); fileWriter.newLine(); fileWriter.newLine();
		for (int i = 0; i < N; ++i)
		{
			for (int j = 0; j < N; ++j)
				fileWriter.write(network[i][j]+" ");
			fileWriter.newLine();
		}
		fileWriter.newLine(); fileWriter.newLine();
		fileWriter.write("Node Degrees:"); fileWriter.newLine(); fileWriter.newLine();
		for (int i = 0; i < N; ++i)
			fileWriter.write(i+1+"\t");
		fileWriter.newLine();
		for (int i = 0; i < N; ++i)
			fileWriter.write(degrees[i]+"\t");
		fileWriter.newLine(); fileWriter.newLine();
		fileWriter.write("Degree Frequencies:"); fileWriter.newLine(); fileWriter.newLine();
		Map<Integer,Integer> degreeFreqs = new TreeMap<>();
		for (int i = 0; i < N; ++i)
		{
			degreeFreqs.putIfAbsent(degrees[i],0);
			degreeFreqs.put(degrees[i],degreeFreqs.get(degrees[i])+1);
		}
		for (Map.Entry entry : degreeFreqs.entrySet())
		{
			Integer key = (Integer)entry.getKey();
			Integer value = (Integer)entry.getValue();
			fileWriter.write(key+" -> "+value);
			fileWriter.newLine();
		}
		// fileWriter.write(degreeFreqs);
		fileWriter.close();
	}
}