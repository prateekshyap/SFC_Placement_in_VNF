package env.vnf;

public class VirtualNetworkFunction
{
	private int id;
	private int requiredCores;
	private double[] cost;
	private double serviceRate;
	public VirtualNetworkFunction() // please use setter methods
	{
		this.id = this.requiredCores = -1; // please use setter methods
		this.cost = new double[10]; // please use setter methods
		this.serviceRate = -1.0; // please use setter methods
	}
	public VirtualNetworkFunction(int id, int cores, double[] cost, double serviceRate)
	{
		this.id = id;
		this.requiredCores = cores;
		this.cost = cost;
		this.serviceRate = serviceRate;
	}
	public void setId(int id) { this.id = id; }
	public int getId() { return this.id; }
	public void setCoreRequirement(int cores) { this.requiredCores = cores; }
	public int getCoreRequirement() { return this.requiredCores; }
	public void setCost(double[] cost) { this.cost = cost; }
	public double[] getCost() { return this.cost; }
	public void setServiceRate(double serviceRate) { this.serviceRate = serviceRate; }
	public double getServiceRate() { return this.serviceRate; }
	@Override
	public String toString()
	{
		String desc = "("+this.id+", "+this.requiredCores+", "+this.serviceRate+", [";
		for (int i = 0; i < cost.length; ++i)
			desc = desc+" "+cost[i]+",";
		desc = desc+"])\n";
		return desc;
	}
}