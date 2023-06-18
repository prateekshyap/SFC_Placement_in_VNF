package env.vm;

public class GenericVirtualMachine implements VirtualMachine
{
	private int id;
	private int requiredCores;
	private double cost;
	public GenericVirtualMachine() //please use setter methods
	{
		this.id = this.requiredCores = -1; // please use setter methods
		this.cost = 0.0; // please use setter methods
	}
	public GenericVirtualMachine(int id, int cores, double cost)
	{
		this.id = id;
		this.requiredCores = cores;
		this.cost = cost;
	}
	public void setId(int id) { this.id = id; }
	public int getId() { return this.id; }
	public void setCoreRequirement(int cores) { this.requiredCores = cores; }
	public int getCoreRequirement() { return this.requiredCores; }
	public void setCost(double cost) { this.cost = cost; }
	public double getCost() { return this.cost; }
	@Override
	public String toString() { return "("+this.id+", "+this.requiredCores+", "+this.cost+")\n"; }
}