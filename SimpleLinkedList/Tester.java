///////////////////////////////////////////////////////////////////////////////
//ALL STUDENTS COMPLETE THESE SECTIONS
//Main Class File:  Shell.java
//File:             Tester.java
//Semester:         Spring 2010
//
//Author:           Josh Gachnang gachnang@cs.wisc.edu
//CS Login:         gachnang
//Lecturer's Name:  Rebecca Hasti
//Lab Section:      001
//
//PAIR PROGRAMMERS COMPLETE THIS SECTION
//Pair Partner:     Kris Stuvengen
//CS Login:         kristoff
//Lecturer's Name:  Rebecca Hasti
//Lab Section:      001
//
//STUDENTS WHO GET HELP FROM ANYONE OTHER THAN THEIR PARTNER
//Credits:          (list anyone who helped you write your program)
////////////////////////////80 columns wide //////////////////////////////////

import java.util.ArrayList;
import java.util.ConcurrentModificationException;
import java.util.Iterator;

import cs367.p2.Musician;
import cs367.p2.Note;

/**
 * Tester for linked list implementation.
 */
public class Tester {

	//Output holds any errors found in the code (Is an arrayList since the SimpleLinkedList
	//is the data structure being tested for accuracy). Block is used to indicate
	//where errors occur for more efficient debugging.
	private static ArrayList<String> output = new ArrayList<String>();
	private static String block = new String();
	
	
    /**
     * Test the {@link SimpleLinkedList} linked list implementation.
     * Prints to the console any errors it finds at the ends, catches almost 
     * all exceptions.
     * 
     * Adds all errors to ArrayList output, along with a block Stringtelling 
     * where the error occurred. Also prints stack traces. Tests 
     * SimpleLinkedList, SimpleLinkedListIterator, and Part.  Song and Mishaps
     * are tested interactively via the shell (they build on these three).
     * 
     * @param args
     *            command-line arguments
     */
    public static void main(String[] args) {
    	//New test style.  Tests SimpleLinkedList (minus remove to be used by iterator).
    	//output is an array of strings that what will be output in case of error. All
    	//exceptions should be caught, output is printed no matter what. Block keeps track of
    	//where the program is to make life easier when debugging.
    	try {
	    	testSimpleLinkedList();
	    	testPart();
    	} finally {
	    	for (int i = 0; i < output.size(); i++) {
	    		System.out.println(output.get(i));
	    	}
	    	if (output.size() == 0) {
	    		System.out.println("All Tests Passed");
	    	}
    	}
    }
    
    /**
     * Tests Part for conceivable errors, and adds errors to output with 
     * block telling where errors occured
     */
    private static void testPart() {
    	Part part = new Part();
    	try {
    		block = "Part, Set/Get: ";
    		if (!part.isPlayable()) {
    			output.add(block + "not working with 0 notes, no musician");
    		}
    		Musician musician = new Musician("Test", 2, 10, "lungs", 4);
    		part.setPlayer(musician);
    		if (part.getPlayer().toString() != "Test") {
    			output.add(block + "Set/Get Musician name didn't work");
    		}
    		block = "Part, isPlayable: ";
    		if (!part.isPlayable()) {
    			output.add(block + "not working with 0 notes, test musician");
    		}
    		Note note = new Note(12);
    		note.setPitch(6);
    		part.appendNote(note);
    		
    		if (part.isPlayable()) {
    			output.add(block + "not working with notes > lung capacity");
    		}
    		Note note2 = new Note(3);
    		note2.setPitch(11);
    		part.appendNote(note2);
    		
    		if (part.isPlayable()) {
    			output.add(block + "not working with out-of-range pitch");
    		}
    		
    		block = "Part, Iterator/MergeAdjacent: ";
    		Note note3 = new Note(4);
    		note3.becomeRest();
    		part.appendNote(note3);
    		Note note4 = new Note(7);
    		note4.becomeRest();
    		part.appendNote(note4);
    		part.mergeAdjacentRests();
    		boolean correct = false;
    		Iterator<Note> iter = part.iterator();
    		while (iter.hasNext() && !correct) {
    			Note temp = iter.next();
    			
    			if (temp.getBeats() == 11 && temp.isRest()) {
    				correct = true;
    			}
    		}
    		if (!correct) {
    			output.add(block + "not merging notes properly");
    		}
    	} catch (NullPointerException e) {
    		block = ("Part, Null Exc: ");
    		output.add(block + "Caught Null, end of try");
    		e.printStackTrace();
    	}
    	
    }
    /**
     * Tests the SimpleLinkedList and Iterator for all possible errors,
     * adding errors to output along with block where error occurred. Catches
     * exceptions, and prints stack trace when possible.
     */
    private static void testSimpleLinkedList() {
    	SimpleLinkedList list = new SimpleLinkedList();	
    	try{		    	
	    	try {
	    		list.add("Test 2");
	    		list.add("Test 3");
	    		list.add(0, "Test 1");
	    		list.add(0, "Test 0");
	    		block = "SLL, Add/Get: ";
	    		if (list.size() != 4) {
	    			output.add(block + "Problem with size()");
	    		}
	    		if (list.get(0) != "Test 0") {
	    			output.add(block + "Problem with get(0), returned: " + list.get(0));
	    		}
	    		if (list.get(1) != "Test 1") {
	    			output.add(block + "Problem with get(1), returned: " + list.get(1));
	    		}
	    		if (list.get(2) != "Test 2") {
	    			output.add(block + "Problem with get(2), returned: " + list.get(2));
	    		}
	    		if (list.get(3) != "Test 3") {
	    			output.add(block + "Problem with get(3), returned: " + list.get(3));
	    		}
	    	} catch (IllegalArgumentException e) {
	    		output.add(block + "Problem adding to list, IllegalArg");
	    	}
	    	catch (IndexOutOfBoundsException e) {
	    		output.add(block + "IndexOutOfBounds");
	    	}
	    	block = "SLL, Remove: ";
	    	Object remove = list.remove(2);
	    	if (remove != "Test 2") {
    			output.add(block + "Problem with remove(2), returned: " + remove);
    		}
	    	remove = list.remove(0);
	    	if (remove != "Test 0") {
    			output.add(block + "Problem with remove(0), returned: " + remove);
    		}
	    	remove = list.remove(1);
	    	if (remove != "Test 3") {
    			output.add(block + "Problem with remove(1), returned: " + remove);
    		}
	    	block = "SLL, Set: ";
	    	list.set(0, "Test 123");
	    	if (list.get(0) != "Test 123") {
	    		output.add(block + "Set failed.");
	    	}
	    	block = "SLL, Contains: ";
	    	if (!list.contains("Test 123")) {
	    		output.add(block + "Problem finding Test 123 with contains");
	    	}
	    	list.remove(0);
	    	
	    	//Rebuild List, move on to testing Iterator.
	    	block = "Iterator, Remove: ";
	    	
	    	list.add("Test 0");
	    	list.add("Test 1");
	    	list.add("Test 2");
	    	list.add("Test 3");
	    	Iterator<String> iter = list.iterator();
	    	while (iter.hasNext()) {
	    		String temp = iter.next();
	    		if (temp == "Test 1") {
	    			iter.remove();
	    		}
	    	}
	    	if (list.get(1) != "Test 2") {
	    		output.add(block + "Removed, got improper value");
	    	}
	    	Iterator<String> iter2 = list.iterator();
	    	block = "Iterator, ConMod: ";
	    	boolean conMod = false;
		    try{
	    		String conModExc = iter2.next();
		    	list.remove(1);
		    	conModExc = iter2.next();
		    } catch (ConcurrentModificationException e) {
		    	conMod = true;
		    }
		    if (conMod == false) {
		    	output.add(block + "No ConModExc thrown");
		    }
	    } catch (IllegalArgumentException e) {
	    	block = "SLL, end: ";
	    	output.add(block + "Null caught at end of try");
	    }
    }
}
