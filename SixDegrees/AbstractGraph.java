import java.util.Collection;

/**
 * Required interface for undirected graphs with string-labeled nodes and edges.
 * Do not modify this file in any way!
 */
public interface AbstractGraph {

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
    void addEdge(final String nodeLabel1, final String nodeLabel2, final String edgeLabel);

    /**
     * Add a labeled node to the graph. Quietly does nothing if a node with this
     * label already exists.
     * 
     * @param label
     *            label of the newly-created node
     * @throws IllegalArgumentException
     *             if label is null
     */
    void addNode(final String label);

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
    Iterable<String> bfs(final String label);

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
    Iterable<String> dfs(final String label);

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
    String getEdge(final String label1, final String label2);

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
    Iterable<String> getNeighbors(String label);

    /**
     * Return a collection of all node labels in the graph, in alphabetical
     * order.
     * 
     * @return collection of all node labels in the graph, in alphabetical order
     */
    Iterable<String> getNodes();

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
    boolean hasEdge(final String label1, final String label2);

    /**
     * Test for the existence of an node with the given label.
     * 
     * @param label
     *            label of the possibly-extant node
     * @return true if and only if a node exists with the given label
     * @throws IllegalArgumentException
     *             if label is null
     */
    boolean hasNode(final String label);

    /**
     * Test whether the graph contains no nodes.
     * 
     * @return true if and only if the graph contains no nodes
     */
    boolean isEmpty();

    /**
     * Return the number of edges in this graph.
     * 
     * @return number of edges in this graph
     */
    int numEdges();

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
    Collection<String> shortestPath(final String startLabel, final String finishLabel);

    /**
     * Return the number of nodes in this graph.
     * 
     * @return number of nodes in this graph
     */
    int size();

}
