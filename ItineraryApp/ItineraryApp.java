///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Title:            ItineraryApp
// Files:            ItineraryApp.java, Itiniterary.java, Destination.java
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


import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Scanner;

public class ItineraryApp 
{
	
	/**
	* The ItineraryApp loads a list of destinations from a source file, then
	* uses the list to do a statistical analysis. The ItineraryApp gives a
	* convenient method of implementing the Itinerary and Destination classes.
	*
	* @author Josh Gachnang
	* @author Kris Stuvengen
	* @version 0.0.1
	*/
	
	//An iterable ArrayList of Itineraries. This stores each line of the input 
	//file as a new Itinerary. Basic storage for app.
	private static ArrayList<Itinerary> itinList = new ArrayList<Itinerary>();
	
   /**         
    * Reads in the source file and populates the itinList with a new
    * Itinerary per line. Throws FileNotFoundException for files not 
    * found, or unreadable/improperly formatted source files.
    *
    * @param args The command line arg of source file location.
    */
	
	public static void main (String args[]) 
	{	
		//Checks the args to be exactly one in length.
		if (args.length != 1) {
			System.out.println("Usage: java ItineraryApp FileName");
			//Error code 2 indicates improper usage.
			System.exit(2);
		}
		
		try {
			File srcFile = new File("sample.txt");
			Scanner scanner = new Scanner(srcFile);
			while (scanner.hasNext()) {
				//Temporary itinerary to be stored in itinList
				Itinerary itin = new Itinerary();
				String line = scanner.nextLine();
				String[] split = line.split(":");
				
				//Splits the read in lines into parameters for Destinations
				for (int i = 0; i < split.length; i += 2) {
					try {
						if (Integer.parseInt(split[i+1].trim()) > 0) {
							itin.addDestination(split[i], Integer.parseInt(split[i+1].trim()));
						}
						else {
							//If numbers of days is put in improperly or other errors.
							throw new FileNotFoundException();
						}
					} catch (FileNotFoundException e) {
						//Error code 4 indicates the file had incorrect parameters. 
						//Expected int above 0, got something else.
						System.exit(4);
					}
				}
				itinList.add(itin);
			}
		} catch (FileNotFoundException e) {
			//Error code 3 indicates either file not found, or the scanner cannot read the file.
			System.exit(3);
		}
		//Boolean, false for first time, true for second time printing statistics.
		boolean printedBefore = false;
		printStatistics(printedBefore);
		printedBefore = true;
		itinList.remove(0);
		System.out.println("Removed first itinerary");
		printStatistics(printedBefore);
	}
	
   /**         
    * Runs statistical analysis on itinList. Prints results
    * to the console.
    *
    * @param printedBefore 
    * @return Prints to console.
    */
	
	private static void printStatistics(boolean printedBefore) 
	{
		//Itinerary of unique destinations.
		Itinerary combinedItin = new Itinerary();
		//List of itineraries (combinedItin) containing unique destinations.
		ArrayList<String> combinedList = new ArrayList<String>();
		//Ints for statistical analysis (longest, shortest, average).
		int total = 0, count = 0, longest = 0, shortest = 0;
		//Array that acts a list of non-unique destinations
		ArrayList<String> nonUnique = new ArrayList<String>();
		Iterator<Itinerary> itinListIter = itinList.iterator();
		
		//Loops through itinList building initial variables to be used in statistics.
		while (itinListIter.hasNext()) {
			//Temporary Itinerary for doing comparisons.
			Itinerary tempItin = itinListIter.next();
			Iterator<Destination> tempItinIter = tempItin.iterator();
			//Tracks total days per itinerary to for longest, shortest, average.
			int tempTotal = 0;
			//Loops through the itinList, building a unique and non-unique list, and
			//keeping track of count.
			while (tempItinIter.hasNext()) {
				Destination tempDest = tempItinIter.next();
				count++;
				tempTotal += tempDest.getDays();
				nonUnique.add(tempDest.getDestination());
				if (combinedItin.containsDestination(tempDest.getDestination())) {
					int daysAdded = combinedItin.getDays(tempDest.getDestination()) + tempDest.getDays();
					combinedItin.setDays(tempDest.getDestination(), daysAdded);
				}
				else {
					combinedItin.addDestination(tempDest.getDestination(), tempDest.getDays());
					combinedList.add(tempDest.getDestination());
				}
				
			}
			total += tempTotal;
			//Determines the longest and shortest itineraries.
			if (tempTotal > longest) {
				longest = tempTotal;
			}
			if (tempTotal < shortest || shortest == 0) {
				shortest = tempTotal;
			}
		}

		System.out.println("Itineraries: " + itinList.size() +", Total Destinations: " + count + ", Unique: " + combinedItin.size());
		System.out.println("Length of itineraries: longest " + longest + ", shortest " + shortest + ", average " + total/itinList.size());
		//ArrayList of destinations tied for most common.
		ArrayList<String> commonList = new ArrayList<String>();
		if (!printedBefore) {
			int mostCommonCount = 0;
			//Loops through unique list, compares value to time it appears in non-unique list.
			//Adds all unique cities to commonList, and tracks the number of times they appear
			//via testCount and mostCommonCount
			for (int i = 0; i < combinedList.size(); i++) {
				int testCount = 0;
				for (int j = 0; j < nonUnique.size(); j++) {
					if (nonUnique.get(j).equals(combinedList.get(i))) {
						testCount++;
					}
				}
				if (testCount > mostCommonCount) {
					commonList.clear();
					commonList.add(combinedList.get(i));
					mostCommonCount = testCount;		
				}
				else if (testCount == mostCommonCount) {
					commonList.add(combinedList.get(i));
				}
			}
			//Goes through commonList to build a string to print to console.
			String mostCommon = "Most Common: ";
			int commonCount = 0;
			for (int i = 0; i < commonList.size(); i++) {
				if (commonCount > 0) {
					mostCommon += ",";
				}
				mostCommon += commonList.get(i);
				commonCount++;
			}
			System.out.println(mostCommon + " " + mostCommonCount);
		}
		
		
		Iterator<Destination> combinedIter = combinedItin.iterator();
		//Variables for tracking the most and least popular destinations
		int most = 0, least = 0;
		//Lists to store most and least popular destinations
		ArrayList<Destination> mostPop = new ArrayList<Destination>();
		ArrayList<Destination> leastPop = new ArrayList<Destination>();
		
		//loops through unique list to find (un)popular destinations and compare
		//them to current values.
		while (combinedIter.hasNext()) {
			Destination tempDest = combinedIter.next();
			if (tempDest.getDays() > most) {
				most = tempDest.getDays();
				mostPop.clear();
				mostPop.add(tempDest);
			}
			else if (tempDest.getDays() == most) {
				mostPop.add(tempDest);
			}
			if (tempDest.getDays() < least || least == 0) {
				least = tempDest.getDays();
				leastPop.clear();
				leastPop.add(tempDest);
			}
			else if (tempDest.getDays() == least) {
				leastPop.add(tempDest);
			}
		}
		//Builds the most popular string and prints to console.
		String mostPopular = "Most Popular: ";
		int mostCount = 0;
		for (int i = 0; i < mostPop.size(); i++) {
			if (mostCount > 0) {
				mostPopular += ",";
			}
			mostPopular += mostPop.get(i).getDestination();
			mostCount++;
		}
		mostPopular += " " + most;
		System.out.print(mostPopular);
		//Builds and prints the least popular string (if it is first pass).
		if (!printedBefore) {
			String leastPopular = "\nLeast Popular: ";
			int leastCount = 0;
			for (int i = 0; i < leastPop.size(); i++) {
				if (leastCount > 0) {
					leastPopular += ",";
				}
				leastPopular += leastPop.get(i).getDestination();
				leastCount++;
			}
			leastPopular += " " + least;
			System.out.println(leastPopular);
		}
		printedBefore = true;
	}
}
