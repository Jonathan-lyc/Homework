/**
 * 
 */
/**
 * @author Josh Gachnang and Kris Stuvengen
 *
 */
public class Stack<E> implements StackADT<E> {
	
	private int size;
	private DoubleListnode<E> bottom = new DoubleListnode<E>(null);
	private DoubleListnode<E> top = new DoubleListnode<E>(null);
	
	/**
	 * Constructs a new Stack of size 0.
	 */
	public Stack() {
		size = 0;
		bottom.setNext(null);
		bottom.setPrev(top);
		top.setNext(bottom);
		top.setPrev(null);
	}
	
	/**
	 * Checks to see if the Stack contains any items.
	 * 
	 * @return boolean empty
	 * 		True: No items in Stack
	 * 		False: Some items in Stack
	 * 
	 */
	public boolean isEmpty() {
		if (size < 0) {
			throw new IndexOutOfBoundsException();
		}
		if (size > 0) {
			return false;
		}
		return true;
	}

	/**
	 * Checks the data inside the item at the top of stack, leaving
	 * the size the same
	 * 
	 * @return E data
	 * 		The data inside the Listnode at the top
	 * @throws EmptyStackException
	 * 		If stack is empty
	 */
	public E peek() throws EmptyStackException {
		if (size == 0) {
			throw new EmptyStackException("Can't peek an empty stack");
		}
		return top.getNext().getData();
	}

	/**
	 * Returns the data inside the item at the top of stack, shrinking
	 * the stack by 1
	 * 
	 * @return E data
	 * 		The data inside the Listnode at the top
	 * @throws EmptyStackException
	 * 		If stack is empty
	 */
	public E pop() throws EmptyStackException {
		if (size == 0) {
			throw new EmptyStackException("Can't pop an empty stack");
		}
		size--;
		return top.getNext().getData();
	}

	/**
	 * Adds arg0 to the top of the Stack
	 * 
	 * @arg E arg0
	 * 		Data to be stored on the Stack
	 * @throws NullPointerException 
	 * 		If arg0 is null
	 */
	public void push(E arg0) {
		if (arg0 == null) {
			throw new NullPointerException();
		}
		DoubleListnode<E> item = new DoubleListnode<E>(arg0);
		item.setNext(top.getNext());
		item.getNext().setPrev(item);
		item.setPrev(top);
		top.setNext(item);
		size++;
	}

	/**
	 * Checks the size of the stack
	 * 
	 * @return int size
	 * 		The size of the stack
	 */
	public int size() {
		return size;
	}

}
