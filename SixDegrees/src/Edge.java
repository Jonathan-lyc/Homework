
public class Edge {
		private Node node;
		private String edge = new String();
		
		public Edge(Node node, String edge) {
			this.node = node;
			this.edge = edge;
		}
		
		public Node getNode() {
			return node;
		}
		
		public String getEdge() {
			return edge;
		}
}
