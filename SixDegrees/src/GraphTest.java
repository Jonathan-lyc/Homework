import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import junit.framework.*;

public class GraphTest extends TestCase {
	Graph graph = new Graph();
	
	public static Test suite() {
		return new TestSuite(GraphTest.class);
	}
	
	public void setUp() {
		//final File filename = new File("small.txt");
        //final AbstractGraph graph = build(filename);
		Graph graph = new Graph();
	}
	
	public void tearDown() {
	}
	
	
	public void testAddNode() {
		graph.addNode("1");
		graph.addNode("2");
		graph.addEdge("1", "2", "1-2");
	}
	
	
	
	public static AbstractGraph build(final File filename) {

        // Do not change this method in any way!

        try {
            final BufferedReader reader = new BufferedReader(new FileReader(filename));
            final AbstractGraph graph = new Graph();

            while (true) {
                final String movie = reader.readLine();
                if (movie == null)
                    break;

                final Collection<String> cast = new HashSet<String>();

                while (true) {
                    final String star = reader.readLine();
                    if (star == null || star.isEmpty())
                        break;

                    graph.addNode(star);
                    for (final String costar : cast) {
                        final String oldEdgeLabel = graph.getEdge(star, costar);
                        if (oldEdgeLabel == null || oldEdgeLabel.compareTo(movie) > 0)
                            graph.addEdge(star, costar, movie);
                    }

                    cast.add(star);
                }
            }

            return graph;

        } catch (final IOException e) {
            System.err.println("cannot read " + e.getLocalizedMessage());
            System.exit(1);
            return null;
        }
    }
}