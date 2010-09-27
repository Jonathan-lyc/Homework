import java.io.*;
import java.util.Collection;
import java.util.HashSet;

/**
 * Main movie path-finding application.
 */
public class MovieApp {

    /**
     * Analyze the given actor/movie graph and print some interesting
     * information about it.
     * 
     * @param graph
     *            graph with actor nodes linked by movie edges
     */
    public static void analyze(final AbstractGraph graph) {
        // TODO: implement this method
    }

    /**
     * Create a {@link Graph} instance from the named file.
     * <p>
     * <em>Do not change this method in any way!</em>
     * 
     * @param filename
     *            name of file containing movie information
     * @return corresponding {@link Graph} instance
     */
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

    /**
     * Main movie path-finding application. Call with one command-line argument:
     * the name of the file containing movie information.
     * <p>
     * <em>Do not change this method in any way!</em>
     * 
     * @param args
     *            command-line arguments
     */
    public static void main(final String[] args) {

        // Do not change this method in any way!

        if (args.length != 1) {
            System.err.println("Usage: java MovieApp <file-name>");
            System.exit(2);
        }

        final File filename = new File(args[0]);
        final AbstractGraph graph = build(filename);
        analyze(graph);
    }
}
