package env.network;

import java.util.List;
import java.util.ArrayList;

public class GenericServer implements Node
{
	private int id;
	private String name;
	private int cores;
	private double latitude, longitude;
	private int vmCount;
	private List<Integer> vms;
	public GenericServer() //please use setter methods
	{
		this.id = this.cores = this.vmCount = -1; //please use setter methods
		this.name = ""; //please use setter methods
		this.latitude = this.longitude = -1.0; //please use setter methods
		this.vms = new ArrayList<>(); //please use setter methods
	}
	public GenericServer(int id, String name, int cores, double latitude, double longitude)
	{
		this.id = id;
		this.name = name;
		this.cores = cores;
		this.latitude = latitude;
		this.longitude = longitude;
		this.vmCount = 0;
		this.vms = new ArrayList<>();
	}
	public void setId(int id) { this.id = id; }
	public int getId() { return this.id; }
	public void setName(String name) { this.name = name; }
	public String getName() { return this.name; }
	public void setCores(int cores) { this.cores = cores; }
	public int getCores() { return this.cores; }
	public void setLatitude(double latitude) { this.latitude = latitude; }
	public double getLatitude() { return this.latitude; }
	public void setLongitude(double longitude) { this.longitude = longitude; }
	public double getLongitude() { return this.longitude; }
	public void setVMCount(int vmCount) { this.vmCount = vmCount; }
	public int getVMCount() { return this.vmCount; }
	public void setVMList(List<Integer> vms) { this.vms = vms; }
	public List<Integer> getVMList() { return this.vms; }
	@Override
	public String toString() { return "("+this.id+", "+this.name+", "+this.cores+" cores at location "+this.latitude+" "+this.longitude+" having "+this.vmCount+" VM instances with IDs "+this.vms+")\n"; }
}