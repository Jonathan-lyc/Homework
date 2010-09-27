import java.util.Collection;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.Map.Entry;

public class Graphnode implements Comparable {
	//Use a TreeMap to store all connected people
	private String data;
	private TreeMap<Graphnode, String> successors = new TreeMap<Graphnode, String>();
	private boolean visited = false;
	private int distance;
	/**
	 * Constructs a Graphnode with the contained value.
	 * 
	 * @param data
	 * 		Data to be stored in the Graphnode
	 */
	public Graphnode (String data) {
		if (data == null) {
			throw new IllegalArgumentException();
		}
		this.data = data;
	}
	
	/**
	 * Adds a successor to the TreeMap of successors.  If the successor already
	 * exists in the TreeMap, the value is updated to the new edgeName value.
	 * 
	 * @param successor
	 * 		Pointer to a Graphnode that is connected to this Graphnode
	 * @param edgeName
	 * 		Named edge between this Graphnode and the successor
	 * @throws IllegalArgumentException
	 * 		If either param is null
	 */
	public void addSuccessor(Graphnode successor, String edgeName) {
		//Adds successor if successor isn't already in TreeMap.  Otherwise, just updates edgeName
		if (successor == null || edgeName == null) {
			throw new IllegalArgumentException();
		}
		successors.put(successor, edgeName);
	}
	
	/**
	 * Returns an iterator for the TreeMap of successors, returning a 
	 * Graphnode each time.
	 * @return 
	 * @return Iterator iter
	 * 		Iterator of the TreeMap, returning the pointers to the next 
	 * 		Graphnodes.
	 */
	public Set<Graphnode> getSuccessors() {
		return successors.keySet();
	}
	
	public Collection<String> getEdges() {
		return successors.values();
	}
	
	public Set<Entry<Graphnode, String>> getEntries() {
		return successors.entrySet();
	}
	
	public String edge(String label) {
		for (Entry<Graphnode, String> a: successors.entrySet()) {
			if (a.getKey().data.equals(label)) {
				return a.getValue();
			}
		}
		return null;
		
	}
	/**
	 * Compares two Graphnodes, only if they both contain strings.
	 * 
	 * @param arg0
	 * 		Object to be compared.
	 * @throws ClassCastException
	 * 		If arg0 isn't a Graphnode, or either doesn't contain a String.
	 */
	public int compareTo(Object arg0) {
		//Check if Object is a Graphnode
		if (!(arg0 instanceof Graphnode)) {
			throw new ClassCastException("A Graphnode object expected.");
		}
		Graphnode arg = (Graphnode) arg0;
		//Compare Strings stored by Graphnodes
		return (data.compareToIgnoreCase(arg.getData()));
	}
	
	/**
	 * Mark the node visited
	 * 
	 * @param boolean visited
	 * 		Whether the node should be set to visited or not.
	 */
	public void setVisited(boolean visited) {
		this.visited = visited;
	}
	
	/**
	 * Return visited or not
	 * @return boolean visited
	 * 		Whether the node has been visited or not
	 */
	public boolean getVisited() {
		return visited;
	}
	
	public void setDistance(int distance) {
		this.distance = distance;
	}
	
	public int getDistance() {
		return distance;
	}
	
	/**
	 * Returns the number of Graphnodes this Graphnode is connected to
	 * @return int size
	 * 		Number of Graphnodes connected to
	 */
	public int size(){ 
		return successors.size();
	}
	
	/**
	 * Returns the data stored in this Graphnode
	 * @return E data
	 * 		The data stored in this Graphnode
	 */
	public String getData() {
		return data;
	}
}
