package env.network;

import java.util.List;

public interface Node
{
	public void setId(int id);
	public int getId();
	public void setName(String name);
	public String getName();
	public void setCores(int cores);
	public int getCores();
	public void setLatitude(double latitude);
	public double getLatitude();
	public void setLongitude(double longitude);
	public double getLongitude();
	public void setVMCount(int vmCount);
	public int getVMCount();
	public void setVMList(List<Integer> vms);
	public List<Integer> getVMList();
	public String toString();
}