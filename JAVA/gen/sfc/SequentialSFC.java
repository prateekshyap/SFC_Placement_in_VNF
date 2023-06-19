package gen.sfc;

import java.util.Map;
import java.util.TreeMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Queue;
import java.util.LinkedList;

// import env.vnf.VirtualNetworkFunction;

public class SequentialSFC implements ServiceFunctionChain
{
	private int id;
	private int length;
	private Map<Integer,List<Integer>> chain;
	private double[] arrivalRate, dropRate;
	public SequentialSFC() // please use setter methods
	{
		this.id = -1; // please use setter methods
		this.length = 0; // please use setter methods
		this.chain = new TreeMap<Integer,List<Integer>>(); // please use setter methods
		this.arrivalRate = new double[10]; // please use setter methods
		this.dropRate = new double[10]; // please use setter methods
	}
	public SequentialSFC(int id, int length, int[] chain, double[] arrivalRate, double[] dropRate)
	{
		this.id = id;
		this.length = length;
		this.chain = new TreeMap<Integer,List<Integer>>();
		for (int i = 0; i < length; ++i)
			this.chain.put(chain[i],Arrays.asList(chain[i+1]));
		this.arrivalRate = arrivalRate;
		this.dropRate = dropRate;
	}
	public void setId(int id) { this.id = id; }
	public int getId() { return this.id; }
	public void setLength(int length) { this.length = length; }
	public int getLength() { return this.length; }
	public void setChain(Map<Integer,List<Integer>> chain) { this.chain = chain; }
	public Map<Integer,List<Integer>> getChain() { return this.chain; }
	public void setArrivalRate(double[] arrivalRate) { this.arrivalRate = arrivalRate; }
	public double[] getArrivalRate() { return this.arrivalRate; }
	public void setDropRate(double[] dropRate) { this.dropRate = dropRate; }
	public double[] getDropRate() { return this.dropRate; }
	@Override
	public String toString()
	{
		String desc = "("+this.id+", "+this.length+", [";
		Queue<Integer> queue = new LinkedList<>();
		queue.add(0);
		while (!queue.isEmpty())
		{
			int src = queue.poll();
			desc = desc+"\n";
			if (!chain.containsKey(src)) break;
			for (Integer dest : chain.get(src))
			{
				queue.add(dest);
				if (src != 0) desc = desc+src+" -> "+dest+", ";
			}
		}
		desc = desc+"]\n[";
		for (int i = 0; i < arrivalRate.length; ++i)
			desc = desc+"\n"+arrivalRate[i]+", ";
		desc = desc+"]\n[";
		for (int i = 0; i < dropRate.length; ++i)
			desc = desc+"\n"+dropRate[i]+", ";
		desc = desc+"])\n";
		return desc;
	}
}