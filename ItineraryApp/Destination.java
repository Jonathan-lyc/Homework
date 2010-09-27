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


/**
 * Destination stores two values: String of destination name, 
 * and amount of time spent at destination (in days). Contains methods
 * to set and modify both params
 * 
 * @author Josh Gachnang
 * @author Kris Stuvengen
 * @version 0.0.1
 * @see also Itinerary, ItineraryApp
 */
public class Destination 
{
	//Local storage and tracking of Destination's two main variable.
	private int locationDays;
	private String location = new String();
	
	/**
	 * Constructor: Builds a new Destination based on location and days.
	 * Throws IllegalArgument if params are outside accepted values.
	 * 
	 * @param loc String representation of destination, must be valid string
	 * @param days Days spent at destination, must be positive integer.
	 * @throws IllegalArgumentException
	 */
	public Destination(String loc, int days) throws IllegalArgumentException 
	{
		if (loc != null){
			location = loc;
		}
		else {
			throw new IllegalArgumentException();
		}
		if (days > 0){
			locationDays = days;
		}
		else {
			throw new IllegalArgumentException();
		}
	}
	
	/**
	 * Returns store destination representation.
	 * 
	 * @return String representation of destination.
	 */
	public String getDestination() 
	{
		return location;
	}
	
	/**
	 * Returns days for destination representation
	 * 
	 * @return int Amount of days at destination.
	 */
	public int getDays() {
		return locationDays;
	}
	
	/**
	 * Sets destination location to new location.
	 * 
	 * @param newLoc String representation of new destination name
	 * @throws IllegalArgumentException
	 */
	public void setDestination(String newLoc) throws IllegalArgumentException 
	{
		if (newLoc != null) {
			location = newLoc;
		}
		else {
			throw new IllegalArgumentException();
		}
	}
	
	/**
	 * Sets destination days to new amount of days
	 * @param newDays Int for new days at location.
	 * @throws IllegalArgumentException
	 */
	public void setDays(int newDays) 
	{
		if (newDays > 0) {
			locationDays = newDays;
		}
		else {
			throw new IllegalArgumentException();
		}
	}
	
	/**
	 * Returns destination and days as String representation.
	 * 
	 * @return String of destination name and days combination.
	 */
	public String toString() 
	{
		String returnString = new String();
		returnString = location + " (" + locationDays + ")";
		return returnString;
	}
}
