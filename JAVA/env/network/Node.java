package env.network;

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
	public String toString();
}