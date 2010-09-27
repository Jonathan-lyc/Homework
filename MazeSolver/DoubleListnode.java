/**
 * 
 */

/**
 * @author Josh Gachnang and Kris Stuvengen
 *
 */
public class DoubleListnode<E> {
	
	private Object data;
	private DoubleListnode<E> previous = null;
	private DoubleListnode<E> next = null;
	
	public DoubleListnode(Object item) {
		data = item;
	}
	
	public E getData() {
		return (E) data;
	}
	
	public DoubleListnode<E> getNext() {
		if (next == null) {
			throw new NullPointerException();
		}
		return next;
	}
	
	public DoubleListnode<E> getPrevious() {
		if (previous == null) {
			throw new NullPointerException();
		}
		return previous;
	}
	
	public void setNext(DoubleListnode<E> newNext) {
		next = newNext;
	}
	
	public void setPrev(DoubleListnode<E> newPrev) {
		previous = newPrev;
	}
	
}
