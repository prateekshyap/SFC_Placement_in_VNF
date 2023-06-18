package env.network;

public class GenericServer implements Node
{
	private int id;
	private String name;
	private int cores;
	private double latitude, longitude;
	public GenericServer() //please use setter methods
	{
		this.id = this.cores = -1; //please use setter methods
		this.name = ""; //please use setter methods
		this.latitude = this.longitude = -1.0; //please use setter methods
	}
	public GenericServer(int id, String name, int cores, double latitude, double longitude)
	{
		this.id = id;
		this.name = name;
		this.cores = cores;
		this.latitude = latitude;
		this.longitude = longitude;
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
	@Override
	public String toString() { return "("+this.id+", "+this.name+", "+this.cores+" cores at location "+this.latitude+" "+this.longitude+")\n"; }
}