
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import junit.framework.JUnit4TestAdapter;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;

/**
 * 
 */

/**
 * @author Josh Gachnang and Kris Stuvengen
 * @param <E>
 *
 */
public class TestStack<E> extends TestCase {

	private Stack<String> stack = new Stack<String>();
	/**
	 * @throws java.lang.Exception
	 */
	@Before
	public void setUp() throws Exception {
		stack = new Stack<String>();
		stack.push("4");
		stack.push("3");
		stack.push("2");
		stack.push("1");
	}

	/**
	 * @throws java.lang.Exception
	 */
	@After
	public void tearDown() throws Exception {
		stack = null;
	}
	
	public static TestSuite testSuite() {
		TestSuite suite = new TestSuite();
	    suite.addTest(new TestStack());
		return suite;
	}
	
	@Test
	public void testIsEmpty() throws Exception {
		assertTrue(!stack.isEmpty());
	}
	
	@Test
	public void testPeek() throws EmptyStackException, Exception {
		assertTrue(stack.peek().equals("1"));
	} 
	
	@Test
	public void testPeekEmptyStack() throws EmptyStackException {
		stack = new Stack<String>();
		try {
			stack.peek();
			fail("Peeking at empty stack should throw EmptyStackException");
		} catch (EmptyStackException e) {}
	}
	
	@Test
	public void testPush() throws Exception {
		stack.push("Test");
		try {
			stack.push(null);
			fail("Pushing null onto stack should throw NullPointerException");
		} catch (NullPointerException e) {}
	}
	
	
	@Test
	public void testPop() throws EmptyStackException, Exception {
		assertTrue(stack.pop() == "1");
		stack.push("One");
		assertTrue(stack.pop().equals("One"));
	}
	
	@Test
	public void testSize() throws Exception {
		assertTrue(stack.size() == 4);
		stack = new Stack<String>();
		assertTrue(stack.size() == 0);
		stack.push("Test");
		assertTrue(stack.size() == 1);
		stack.pop();
		assertTrue(stack.size() == 0);
	}
}
