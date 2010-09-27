import java.util.Collection;
import java.util.HashMap;
import java.util.Set;
import java.util.TreeMap;
import java.util.Map.Entry;


public class Node implements Comparable {
	private TreeMap<String, Edge> connections;
	private String data;
	private boolean visited;
	private int distance;
	
	public Node(String data) {
		connections = new TreeMap<String, Edge>();
		this.data = data;
		visited = false;
		distance = 0;
	}
	
	public String getData() {
		return data;
	}
	public void addNode(Node node, String edge) {
		if (node == null || edge == null) {
			throw new IllegalArgumentException();
		}
		Edge newEdge = new Edge(node, edge);
		connections.put(node.getData(), newEdge);
	}
	
	public String getEdge(String label) {
		return connections.get(label).getEdge();
	}
	
	public Set<String> connectionsSet() {
		return connections.keySet();
	}
	
	public Collection<Edge> edgeSet() {
		return connections.values();
	}
	public int compareTo(Object arg0) {
		//Check if Object is a Node
		if (!(arg0 instanceof Node)) {
			throw new ClassCastException("A Node object expected.");
		}
		Node arg = (Node) arg0;
		//Compare Strings stored by Node
		return (data.compareTo(arg.getData()));
	}
	
	public int size() {
		return connections.size();
	}

	public  Set<Entry<String, Edge>> getEntries() {
		return connections.entrySet();
	}
	public void setVisited(boolean visited) {
		this.visited = visited;
	}
	public boolean getVisited() {
		return visited;
	}
	public void setDistance(int distance) {
		this.distance = distance;
	}
	public int getDistance() {
		return distance;
	}
	public boolean hasEdge(String label2) {
		return connections.containsKey(label2);
	}
}
