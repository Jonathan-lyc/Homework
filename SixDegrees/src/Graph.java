import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.TreeMap;
import java.util.Map.Entry;

//Can we build a second graph of only the ones connected to Kevin Bacon?? Booyah!!

public class Graph<E> implements AbstractGraph {
	//Keeps track of the size of the Graph.
	private int size = 0;
	//TreeMap of all nodes
	private TreeMap<String, Node> nodes = new TreeMap<String, Node>();
	private int edges = 0;
	private LinkedList<Node> queue = new LinkedList<Node>();
	//Path for DFS
	private Stack<String> shortestPath = new Stack<String>();
	LinkedList<String> path = new LinkedList<String>();
	
	/**
     * Add an undirected edge from one node to another.
     * 
     * If there is already an edge between these two nodes, then the label of
     * this edge is <em>changed</em> to the edge label given here as an
     * argument.
     * 
     * @param nodeLabel1
     *            label of the node at one end the edge
     * @param nodeLabel2
     *            label of the node at the other end of the edge
     * @param edgeLabel
     *            label of the newly-created edge
     * @throws IllegalArgumentException
     *             if any argument label is null, or if either node label does
     *             not correspond to an existing node
     */
    public void addEdge(final String nodeLabel1, final String nodeLabel2, final String edgeLabel) {
    	
    	//TODO: Fix! Reporting too many edges
    	if (edgeLabel == null) {
    		throw new IllegalArgumentException();
    	}
    	Node node1 = nodes.get(nodeLabel1);
    	Node node2 = nodes.get(nodeLabel2);
    	if (node1 == null || node2 == null) {
    		throw new IllegalArgumentException();
    	
    	}
    	node1.addNode(node2, edgeLabel);
    	node2.addNode(node1, edgeLabel);   	
    	edges++;
	}
    
    /**
     * Add a labeled node to the graph. Quietly does nothing if a node with this
     * label already exists.
     * 
     * @param label
     *            label of the newly-created node
     * @throws IllegalArgumentException
     *             if label is null
     */
    public void addNode(final String label) {
    	if (label == null) {
    		throw new IllegalArgumentException();
    	}
    	Node tmp = nodes.get(label);
    	if (tmp == null) {
    		Node node = new Node(label);
    		nodes.put(label, node);
    	}     	
	}

    /**
     * Perform a breadth-first search over the graph. Whenever a node has
     * multiple neighbors, the neighbors are visited in alphabetical order.
     * 
     * @param label
     *            label of the start node
     * @return sequence of node labels visited in order
     * @throws IllegalArgumentException
     *             if label is null or does not correspond to an existing node
     */
    public Iterable<String> bfs(final String label) {
    	clearVisited();
    	
    	LinkedList<String> path = new LinkedList<String>();
    	LinkedList<Node> queue = new LinkedList<Node>();
    	
    	Node n = nodes.get(label); 
        n.setVisited(true);
        queue.add( n );
        path.add(n.getData());

        
        while (!queue.isEmpty()) {
            Node current = queue.remove();//remove last element
            for (Entry<String, Edge> k : current.getEntries()) {
                if (! k.getValue().getNode().getVisited()){
                	k.getValue().getNode().setVisited(true);
                    queue.add(k.getValue().getNode());
                    path.add(k.getKey());
                } // end if k not visited
            } // end for every successor k
        } // end while queue not empty
		return path;
	}

    /**
     * Perform a depth-first search over the graph. Whenever a node has multiple
     * neighbors, the neighbors are visited in alphabetical order.
     * 
     * @param label
     *            label of the start node
     * @return sequence of node labels visited in order
     * @throws IllegalArgumentException
     *             if label is null or does not correspond to an existing node
     */
    public Iterable<String> dfs(final String label) {
    	clearVisited();
    	
    	path = new LinkedList<String>(); //List to be returned
		Node root = nodes.get(label); //Get first node
		dfsHelp(root);
		
		return path;
	}
    
    private void dfsHelp(Node n) {
    	n.setVisited(true);
    	path.add(n.getData());
        for (Edge m : n.edgeSet()) {
            if (! m.getNode().getVisited()) {
                dfsHelp(m.getNode());
            }
        }
    }

    /**
     * Return the label of the edge connecting the two named nodes, if any.
     * 
     * @param label1
     *            label of the node at one end the edge
     * @param label2
     *            label of the node at the other end of the edge
     * @return label of the edge between these two nodes, or null if no such
     *         edge exists
     * @throws IllegalArgumentException
     *             if either node label is null, or if either node label does
     *             not correspond to an existing node
     */
    public String getEdge(final String label1, final String label2) {
    	if (label1 == null || label2 == null) {
    		throw new IllegalArgumentException();
    	}
    	//Based on other code, if n has the edge, other Node
    	//must also have this edge (no available remove method and 
    	//addEdge automagically adds to both nodes simultaneously)
    	Node n = nodes.get(label1);
    	if (n == null) {
    		throw new IllegalArgumentException();
    	}
		for ( Entry<String, Edge> a : n.getEntries()) {
			if (a.getKey().equals(label2)) {
				return a.getValue().getEdge();
			}
		}
		return null;
	}

    /**
     * Return labels of immediate neighbors of the given node in alphabetical
     * order.
     * 
     * @param label
     *            label of the start node
     * @return labels of immediate neighbors of the start node in alphabetical
     *         order
     * @throws IllegalArgumentException
     *             if label is null or does not correspond to an existing node
     */
    public Iterable<String> getNeighbors(String label) {
    	Node tmp = nodes.get(label);
    	if (tmp == null) {
    		throw new IllegalArgumentException();
    	}
    	return tmp.connectionsSet();
	}

    /**
     * Return a collection of all node labels in the graph, in alphabetical
     * order.
     * 
     * @return Iterable<String> keySet
     * 		collection of all node labels in the graph, in alphabetical order
     */
    public Iterable<String> getNodes() {
		return nodes.keySet();
	}

    /**
     * Test for the existence of an edge connecting the two named nodes.
     * 
     * @param label1
     *            label of the node at one end the edge
     * @param label2
     *            label of the node at the other end of the edge
     * @return true if and only if an edge exists between these two nodes
     * @throws IllegalArgumentException
     *             if either node label is null, or if either node label does
     *             not correspond to an existing node
     */
    public boolean hasEdge(final String label1, final String label2) {
    	String n = getEdge(label1, label2);
    	if (n == null) {
    		return false;
    	}
    	else {
    		return true;
    	}
	}

    /**
     * Test for the existence of an node with the given label.
     * 
     * @param label
     *            label of the possibly-extant node
     * @return true if and only if a node exists with the given label
     * @throws IllegalArgumentException
     *             if label is null
     */
    public boolean hasNode(final String label) {
    	if (label == null) {
    		throw new IllegalArgumentException();
    	}
    	Node tmp = nodes.get(label);
    	if (tmp == null) {
    		return false;
    	}
    	return true;
	}

    /**
     * Test whether the graph contains no nodes.
     * 
     * @return true if and only if the graph contains no nodes
     */
    public boolean isEmpty() {
		if (nodes.size() > 0) {
			return false;
		}
		else {
			return true;
		}
	}

    /**
     * Return the number of edges in this graph.
     * 
     * @return number of edges in this graph
     */
    public int numEdges() {
    	return edges;
	}

    /**
     * Find the shortest path from a start node to a finish node. Whenever a
     * node has multiple neighbors, the neighbors are visited in alphabetical
     * order. Returns the complete list of node labels along the path, with the
     * start node label appearing first and the finish node label appearing
     * last.
     * 
     * @param startLabel
     *            label of the start node
     * @param finishLabel
     *            label of the finish node
     * @return sequence of nodes along the path, or null if there is no such
     *         path
     * @throws IllegalArgumentException
     *             if either node label is null, or if either node label does
     *             not correspond to an existing node
     */
    public Collection<String> shortestPath(final String startLabel, final String finishLabel) {
    	clearVisited();
    	LinkedList<Node> queue = new LinkedList<Node>();
    	
    	Node n = nodes.get(startLabel);
    	if (n.getData() == null) {
    		throw new IllegalArgumentException();
    	}
        n.setVisited(true);
        n.setDistance(0);
        queue.add(n);
        while (!queue.isEmpty()) {
            Node current = queue.pop();
            for (Edge k : current.edgeSet()) {
            	if (k.getNode().getData().equals(finishLabel)) {
            		break;
            	}
                if (! k.getNode().getVisited()){
                    k.getNode().setVisited(true);
                    k.getNode().setDistance(current.getDistance() + 1);
                    queue.add(k.getNode());
                } // end if k not visited
            } // end for every successor k
        } // end while queue not empty
        
		return null;
    	
    }
    /**
     * Return the number of nodes in this graph.
     * 
     * @return number of nodes in this graph
     */
    public int size() {
		return nodes.size();
	}
    
    private void clearVisited() {
    	for (Node n : nodes.values()) { 
    		n.setVisited(false); 
		}
    }
    	
}

