///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Main Class File:  ItineraryApp.java
// File:             Itinerary.java
// Semester:         Spring 2009
//
// Author:           Josh Gachnang gachnang@cs.wisc.edu
// CS Login:         gachnang
// Lecturer's Name:  Rebecca Hasti
// Lab Section:      Lec-001
//
//                   PAIR PROGRAMMERS COMPLETE THIS SECTION
// Pair Partner:     Kris Stuvengen stuvengen@wisc.edu
// CS Login:         kristoff
// Lecturer's Name:  Rebecca Hasti
// Lab Section:      Lec-001
//
//                   STUDENTS WHO GET HELP FROM ANYONE OTHER THAN THEIR PARTNER
// Credits:          
//////////////////////////// 80 columns wide //////////////////////////////////

import java.util.ArrayList;
import java.util.Iterator;

/**
 * Itinerary stores and manipulates collections of destinations. Destinations
 * are stored in an ArrayList backend.  Destinations or destination parameters
 * can be added or modified.
 * 
 * @author Josh Gachnang
 * @author Kris Stuvengen
 * @version 0.0.1
 * @see also Destination, ItineraryApp
 */
public class Itinerary 
{
	//Backend storage for the destinations
	private ArrayList<Destination> storage = new ArrayList<Destination>();
	
	/**
	 * Constructor: empty.
	 */
	public Itinerary() 
	{
	}
	
	/**
	 * Check if storage already contains a destination with the same 
	 * Destination string
	 * 
	 * @param dest String name of destination
	 * @return boolean True: Contains destination. False: Doestn't contain destination.
	 */
	public boolean containsDestination(String dest) 
	{
		
		for (Destination iterDest : storage) {
			if (compareStrings(iterDest.getDestination(), dest)) {
				return true;
			}
		}
		return false;		
	}
	
	/**
	 * Creates a new destination, and stores it in storage.
	 * If destination already exists, runs setDays().
	 * 
	 * @param dest String representing name of destination
	 * @param days Length of time spent at destination
	 */
	public void addDestination(String dest, int days) 
	{
		if (containsDestination(dest)){
			setDays(dest, days);
		}
		else {
			try {	
				Destination newDest = new Destination(dest, days);
				storage.add(newDest);
			} catch (IllegalArgumentException e) {
				System.exit(1);
			}
		}
	}
	
	/**
	 * Removes destination from storage (if valid).
	 * 
	 * @param dest String representation of the destination
	 * @return boolean. True: Remove sucessful. False: Remove failed.
	 */
	public boolean removeDestination(String dest) 
	{
		//Why doesn't this work like the rest of the language? This method should
		//be a void, and throw an exception.
		int pos = findDestPos(dest);
		if (pos < 0) {
			return false;
		}
		else {
			storage.remove(pos);
			return true;
		}
	}
	
	/**
	 * Sets days for existing destination.
	 * 
	 * @param dest String representation of destination
	 * @param days Length of time spent at destination
	 */
	public void setDays(String dest, int days) throws IllegalArgumentException 
	{
		int destRemove = findDestPos(dest);
		if (days < 0) {
			throw new IllegalArgumentException();
		}
		else {
			storage.get(destRemove).setDays(days); 
		}
	}
	
	/**
	 * Returns the days of a specified destination
	 * 
	 * @param dest String representation of destination
	 * @return int Days spent at location
	 */
	public int getDays(String dest) 
	{
		Destination targetDest = storage.get(findDestPos(dest));
		if (targetDest != null) {
			return targetDest.getDays();
		}
		else {
			return 0;
		}
		
	}
	
	/**
	 * Returns size of Itinerary
	 * 
	 * @return int Number of destinations
	 */
	public int size() 
	{
		return storage.size();
		
	}
	
	/**
	 * Returns total days spent at all destinations in Itinerary
	 * 
	 * @return int Number of days total in Itinerary
	 */
	public int days() 
	{
		int totalDays = 0;
		for (Destination iterDest : storage) {
			totalDays += iterDest.getDays();
		}
		return totalDays;	
	}
	
	/**
	 * Checks if any destinations exist in storage
	 * 
	 * @return boolan True: no destinations. False: contains destinations
	 */
	public boolean isEmpty() 
	{
		if (storage.size() == 0) {
			return true;
		}
		else {
			return false;
		}
		
	}
	
	/**
	 * Returns iterator inherited from ArrayList
	 * 
	 * @return iterator
	 */
	public Iterator<Destination> iterator()
	{
		return storage.iterator();
	}
	
	/**
	 * Private method to find the position in storage based on given destination
	 * 
	 * @param dest String representation of destination
	 * @return int Index in storage of specified destinatino
	 */
	private int findDestPos(String dest) 
	{
		//Extra class to remove redundancy.
		//Finds a Destination with the parameter and returns it's position in the storage array, 
		//or returns -1 if no matches exist.
		int pos = 0;
		for (Destination iterDest : storage) {
		//This is Java's enhanced loop.  It iterates the list in the simplest way possible.
			if (compareStrings(dest, iterDest.getDestination())) {
				return pos;
			}
			pos++;
		}
		return -1;
	}
	
	/**
	 * Private method that compares two destinations represented by Strings.
	 * 
	 * @param first First destination string to compare.
	 * @param second Second destination string to compare.
	 * @return boolean True: Same destination. False: Different destination.
	 */
	private boolean compareStrings(String first, String second) 
	{
		first = first.replaceAll(" ", "");
		second = second.replaceAll(" ", "");
		if (first.equalsIgnoreCase(second)) {
			return true;
		}
		else {
			return false;
		}
	}	
}
