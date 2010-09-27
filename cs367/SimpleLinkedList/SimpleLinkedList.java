///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Main Class File:  Shell.java
// File:             SimpleLinkedList.java
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

import java.util.Iterator;

import cs367.p2.*;

/**
 * Implementation of the {@link SimpleList} interface using doubly linked lists.
 * <strong>Modify this class to implement the required constructor and
 * {@link SimpleList} methods.</strong>
 * 
 * @param <E>
 *            the type of data to be stored in this list
 */	
public class SimpleLinkedList<E> implements SimpleList<E> {

	//Creates an integer to keep track of the size of the List.
	private int numItems;
	//Only these two items are allowed to contain null as data, as they are never
	//directly added to the list, but are just linked.
	private DoubleListnode<E> head = new DoubleListnode<E>(null);
	private DoubleListnode<E> tail = new DoubleListnode<E>(null);
	
    /**
     * Create a new, empty list. Constructor.
     */
    public SimpleLinkedList() {
        numItems = 0;
        head.setNext(tail);
        head.setPrev(null);
        tail.setPrev(head);
        tail.setNext(null);
        //Next lines for debugging only. Remove before final.
        tail.setData(null);
        head.setData(null);
    }
    /**         
     * Adds an item to the end of the list.
     *
     * @param <E> item 
     * 			Data to be added to the list.
     * @throws IllegalArgumentException
     * 			If data is null.
     */
    public void add(E item) {
    	if (item == null) {
    		throw new IllegalArgumentException();
    	}
    	DoubleListnode<E> newItem = new DoubleListnode<E>(item);
    	newItem.setPrev(tail.getPrev());
    	tail.getPrev().setNext(newItem);
    	newItem.setNext(tail);
    	tail.setPrev(newItem);
        numItems++;
    }

    /**
     * Generic add method that adds Listnode containing item at index.
     * 
     * @param int index
     * 			Index to be added at.  If item exists at that spot, all 
     * 			Listnodes to the right are shifted one position right.
     * @param E item
     * 			Data to be stored in Listnode.
     */
    public void add(int index, E item) {
    	//Check for item == null
    	if (!checkIndex(index)) {
    		throw new IndexOutOfBoundsException();
    	}
    	if (index == 0) {
    		addBegin(item);
    		return;
    	}
    	
    	if  (numItems == index) {
    		
    		add(item);
    	}
    	if (numItems == 0) {
    		DoubleListnode<E> newItem = new DoubleListnode<E>(item);
    		newItem.setNext(null);
    		newItem.setPrev(null);
    		tail = newItem;
    		head = newItem;
    	}
    	DoubleListnode<E> newItem = new DoubleListnode<E>(item);
    	DoubleListnode<E> temp = getNode(index);
    	newItem.setPrev(temp);
    	newItem.setNext(temp.getNext());
    	temp.getNext().setPrev(newItem);
    	temp.setNext(newItem);
    	numItems++;
    	
    }

    /**
     * Adds item to beginning of list.
     * Private method to reduce redundant code.
     * 
     * @param E item
     * 			Data to be stored at beginning of list.
     */
    private void addBegin(E item) {
    	DoubleListnode<E> newItem = new DoubleListnode<E>(item);
    	newItem.setNext(head.getNext());
    	head.getNext().setPrev(newItem);
    	head.setNext(newItem);
    	newItem.setPrev(head);
    	numItems++;
    }
    
    /**
     * Checks list if any Listnode contains data equal to param.
     * 
     * @param Object target
     * 			Object to check against in list.
     * @return boolean contains
     * 			True: Listnode with Object target as data exists.
     * 			False: No such Listnode found.
     */
    public boolean contains(Object target) {
    	DoubleListnode check = head.getNext();
    	boolean found = false;
    	while (!found && check.getNext() != null) {
    		if (check.getData().equals(target)) {
    			found = true;
    		}
    		check = check.getNext();
    	}
        return found;
        
    }

    /**
     * Gets an item from the List and returns its data.
     * 
     * @param int index
     * 			Index of item to return data from.
     * @return E data
     * 			Data that is stored in specified Listnode.
     */
    public E get(int index) {
    	DoubleListnode temp = getNode(index);
        return (E) temp.getData();
    }

    /**
     * Get a specific node in the list.
     * @param int index
     * 			Index of node to be returned.
     * @return DoubleListnode<E> node
     * 			Finds DoubleListnode and returns node, instead of data. Internal method.
     */
    private DoubleListnode<E> getNode(int index) {
    	//This method should be made more efficient.  Divide index by numItems, and see if we should start at
    	//tail or head, thereby cutting operations by up to half.
    	if (!checkIndex(index)) {
    		throw new IndexOutOfBoundsException();
    	}
        DoubleListnode<E> temp = head.getNext();
        for (int i = 0; i < index; i++) {
        	temp = temp.getNext();
        }
        return temp;
    }
    
    /**
     * Checks if list has Listnodes other than head and tail
     * 
     * @return boolean empty
     * 			True: List is empty.
     * 			False: List has Listnodes in it.
     */
    public boolean isEmpty() {
        if (numItems == 0) {
        	return true;
        }
        else {
        	return false;
        }
    }

    /**
     * Returns iterator of list.
     * 
     * @return Iterator<E> iterator
     * 			Iterator of list.
     */
    public Iterator<E> iterator() {
        SimpleLinkedListIterator<E> iter = new SimpleLinkedListIterator<E>(head, this);
        return iter;
    }

    /**
     * Removes the given node from this list. Intended for use <em>only</em> by
     * {@link SimpleLinkedListIterator#remove()}.
     * 
     * @param chaff
     *            the node to be removed
     */
    void remove(DoubleListnode<E> chaff) {
        DoubleListnode prev = chaff.getPrev();
        DoubleListnode next = chaff.getNext();
        prev.setNext(next);
        next.setPrev(prev);
        numItems--;
        }

    /**
     * Removes Listnode from list and returns data stored in Listnode.
     * 
     * @param int index
     * 			Index of Listnode to remove.
     * @return E item
     * 			Returns data from removed Listnode.
     */
    public E remove(int index) {
    	if (!checkIndex(index)) {
    		throw new IndexOutOfBoundsException();
    	}
        DoubleListnode<E> remove = getNode(index);
        if (remove.getPrev() != null && remove.getNext() != null) {
        	DoubleListnode<E> prev = remove.getPrev();
        	DoubleListnode<E> next = remove.getNext();
            prev.setNext(next);
            next.setPrev(prev);
            numItems--;
            return (E) remove.getData();
        }
        else {
        	if (remove.getPrev() == null) {
        		//Node to be removed is first in list.
        		DoubleListnode<E> next = remove.getNext();
                next.setPrev(head);
                head.setNext(next);
                numItems--;
                return (E) remove.getData();
        	}
        	else {
        		//Node to be removed is last in list.
        		DoubleListnode<E> prev = remove.getPrev();
        		prev.setNext(tail);
        		tail.setPrev(prev);
        		numItems--;
        		return (E) remove.getData();
        	}
        }
    }
    
    /**
     * Finds the node in the list and sets the data in it to value.
     * 
     * @param int index
     * 			Index of node to change.
     * @param E value
     * 			Data to be stored in Listnode.
     * @return int numItems
     * 			Int keep track of size of list.
     */
    public void set(int index, E value) {
    	
        DoubleListnode<E> setItem = getNode(index);
        setItem.setData(value);
    }
    
    /**
     * Returns size of list from data member
     * 
     * @return int numItems
     * 			Int keep track of size of list.
     */
    public int size() {
        return numItems;
    }
    
    /**
     * Checks if index is within the bounds of the list.
     * 
     * @return Boolean valid
     * 			True: Index is a valid index.
     * 			False: Index is not valid.
     */
    private boolean checkIndex(int index) {
    	boolean valid = true;
    	if (index < 0 || index >= numItems) {
    		valid = false;
    	}
		return valid;
    	
    }
}