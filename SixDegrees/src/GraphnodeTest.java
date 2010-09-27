import java.util.Iterator;
import junit.framework.*;

public class GraphnodeTest extends TestCase {
	Graphnode node = new Graphnode("0");
	Graphnode succ1 = new Graphnode("0");
	Graphnode succ2 = new Graphnode("0");
	Graphnode succ3 = new Graphnode("0");

	public static Test suite() {
		return new TestSuite(GraphnodeTest.class);
	}
	
	public void setUp() {
		node = new Graphnode("0");
		succ1 = new Graphnode("1");
		succ2 = new Graphnode("2");
		succ3 = new Graphnode("3");
	}
	
	public void tearDown() {
		node = new Graphnode("0");
	}
	
	public void testSuccessors() {
		add3();
		boolean correct = true;
		
		Iterator iter = node.getSuccessors().iterator();
		
		for(int i = 1; i < 4; i++) {
			Graphnode tmp = (Graphnode) iter.next();
			if (!tmp.getData().equals(String.valueOf(i))) {
				correct = false;
			}
		}
		assertTrue(correct);
	}
	
	public void testSize() {
		add3();
		assertTrue(node.size() == 3);
	}
	
	public void testGetData() {
		assertTrue(node.getData().equals("0"));
	}
	
	public void testGetEdges() {
		add3();
		boolean correct = true;
		
		Iterator iter = node.getEdges().iterator();
		
		for(int i = 1; i < 4; i++) {
			String tmp = (String) iter.next();
			if (!tmp.equals("0-" + String.valueOf(i))) {
				correct = false;
			}
		}
		assertTrue(correct);
	}
	
	public void testGetSuccessor() {
		add3();
		Graphnode tmp;
		/**tmp = node.getSuccessor("1");
		assertTrue(tmp.getData().equals("1"));
		tmp = node.getSuccessor("2");
		assertTrue(tmp.getData().equals("2"));
		tmp = node.getSuccessor("3");
		assertTrue(tmp.getData().equals("3"));
		*/
	}
	
	public void testGetEdge() {
		add3();
		/**String tmp = node.getEdge("1");
		assertTrue(tmp.equals("0-1"));
		tmp = node.getEdge("2");
		assertTrue(tmp.equals("0-2"));
		tmp = node.getEdge("3");
		assertTrue(tmp.equals("0-3"));
		*/
	}
	private void add3() {
		node.addSuccessor(succ1, "0-1");
		node.addSuccessor(succ2, "0-2");
		node.addSuccessor(succ3, "0-3");
	}
	
	
}
