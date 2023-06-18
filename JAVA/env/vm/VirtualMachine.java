package env.vm;

public interface VirtualMachine
{
	public void setId(int id);
	public int getId();
	public void setCoreRequirement(int cores);
	public int getCoreRequirement();
	public void setCost(double cost);
	public double getCost();
	public String toString();
}