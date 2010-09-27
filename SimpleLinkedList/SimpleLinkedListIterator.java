///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Main Class File:  Shell.java
// File:             SimpleLinkedListIterator.java
// Semester:         Spring 2010
//
// Author:           Josh Gachnang gachnang@cs.wisc.edu
// CS Login:         gachnang
// Lecturer's Name:  Rebecca Hasti
// Lab Section:      001
//
//                   PAIR PROGRAMMERS COMPLETE THIS SECTION
// Pair Partner:     Kris Stuvengen
// CS Login:         kristoff
// Lecturer's Name:  Rebecca Hasti
// Lab Section:      001
//
//                   STUDENTS WHO GET HELP FROM ANYONE OTHER THAN THEIR PARTNER
// Credits:          (list anyone who helped you write your program)
//////////////////////////// 80 columns wide //////////////////////////////////

import java.util.ConcurrentModificationException;
import java.util.Iterator;

import cs367.p2.*;

/**
 * Implementation of the {@link Iterator} interface for use with
 * {@link SimpleLinkedList} and {@link DoubleListnode}. <strong>Modify this
 * class to implement a constructor, the required {@link Iterator} methods, and
 * any private fields or methods you feel are necessary.</strong>
 * 
 * @param <E>
 *            the type of data stored in the list
 */

public class SimpleLinkedListIterator<E> implements Iterator<E> {

	//Used to keep track of when remove() is called, to avoid
	//IllegalOperations
	private boolean removed = false;
	//Current Listnode to be returned/removed.
	private DoubleListnode<E> curr = new DoubleListnode<E>(null);
	//Private data storage.
	private SimpleLinkedList list = new SimpleLinkedList();
	//The size the list is expected to be, used to check for ConMods.
	private int expectedSize = 0;
	
    /**
	 * Constructor should only be called by SimpleLinkedList.
	 */
	public SimpleLinkedListIterator(DoubleListnode head, SimpleLinkedList lst) {
		curr = head;
		list = lst;
		expectedSize = list.size();
	}
	
	/**
	 * Checks to make sure underlying list has not had anything added or subtracted
	 * by a method other than iterator.remove().
	 * 
	 * @throws ConcurrentModificationException
	 * 			While iterating, iterator.remove() is the only method
	 * 			that can modify the underlying list.
	 */
    private void conMod() {
    	if (expectedSize != list.size()) {
    		throw new ConcurrentModificationException();
    	}
    }
	
    /**
	 * Checks to see if there is another Listnode next, or the tail.
	 * 
	 * @return Boolean next
	 * 			True: Next Listnode is not tail.
	 * 			False: Next Listnode is tail, therefore, no more Listnodes.
	 */
    public boolean hasNext() {
    	//Checks to see if the next item is the tail, in which case, the getNext of tail = null.
    	conMod();
    	if (list.size() == 0) {
    		return false;
    	}
        if (curr.getNext().getData() != null) {
        	return true;
        }
        return false;
    }

    /**
	 * Returns the data from the next Listnode in the list.
	 * 
	 * @return E data
	 * 			Data that was stored in the Listnode.
	 * @throws UnsupportedOperationException
	 * 			If the next time is the tail.
	 */
    public E next() {
    	conMod();
    	removed = false;
    	if (curr.getNext().getData() != null) {
    		curr = curr.getNext();
    		return (E) curr.getData();
    	}
    	else {
    		throw new UnsupportedOperationException();
    	}
    }

    /**
	 * Removes current Listnode from the list. Must be called after
	 * a next(), and only once per next().
	 * 
	 * @throws UnsupportedOperationException
	 * 			Current is still head, or called more than once
	 * 			per next().
	 */
    public void remove() {
    	conMod();
    	if (curr.getPrev() == null) {
    		//Curr is still head, need to call next before using remove.
    		throw new UnsupportedOperationException();
    	}
    	if (removed == true) {
    		//Remove can only be called once per next().
    		throw new UnsupportedOperationException();
    	}
    	list.remove(curr);
    	removed = true;
    	expectedSize--;
    }
}
