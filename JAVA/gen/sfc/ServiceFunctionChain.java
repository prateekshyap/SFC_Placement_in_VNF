package gen.sfc;

import java.util.Map;
import java.util.List;

public interface ServiceFunctionChain
{
	public void setId(int id);
	public int getId();
	public void setLength(int length);
	public int getLength();
	public void setChain(Map<Integer,List<Integer>> chain);
	public Map<Integer,List<Integer>> getChain();
	public void setArrivalRate(double[] arrivalRate);
	public double[] getArrivalRate();
	public void setDropRate(double[] dropRate);
	public double[] getDropRate();
	public String toString();
}