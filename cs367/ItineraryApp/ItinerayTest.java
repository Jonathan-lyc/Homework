
public class ItinerayTest {
	public void main() {
		Destination dest1 = new Destination("Madison", 4);
		Destination dest2 = new Destination("St. Paul", 6);
		Destination dest3 = new Destination("Milwaukee", 1);
		System.out.println("Destinations created");
		System.out.println("Dest1 dest = " + dest1.getDestination());
		System.out.println("Dest1 days = " + dest1.getDays());
		dest1.setDays(6);
		dest1.setDestination("Wisconsin Rapids");
		System.out.println("Dest1 dest, modified = " + dest1.getDestination());
		System.out.println("Dest1 days, modified = " + dest1.getDays());
		System.out.println("Dest1 to string = " + dest1.toString());
		System.out.println("Begin testing errors:");
		System.out.println();
		try {
			Destination dest4 = new Destination("Chicago", -1);
		} catch (IllegalArgumentException e) {
			System.out.println("Illegal argument, negative number, in Dest4 caught");
		}
		try {
			Destination dest4 = new Destination(null, 3);
		} catch (IllegalArgumentException e) {
			System.out.println("Illegal argument, null string, in Dest4 caught");
		}
		try {
			dest3.setDays(-1);
		} catch (IllegalArgumentException e) {
			System.out.println("Illegal argument in setDays, negative number, in Dest3 caught");
		}
		try {
			dest3.setDestination(null);
		} catch (IllegalArgumentException e) {
			System.out.println("Illegal argument in setDestination, null string, in Dest3 caught");
		}
		System.out.println();
		System.out.println("Destination tests completed sucessfully. Moving to Itinerary:");
		System.out.println();
		
		Itinerary itin = new Itinerary();
		if (itin.isEmpty()){
			System.out.println("itin is empty.");
		}
		else {
			System.out.println("itin is not empty.");
		}
		itin.addDestination("Milwaukee", 3);
		itin.addDestination("Fake City", 365);
		itin.addDestination("Madison", 20);
		System.out.println("Added destinations");
		System.out.println("First destination getDays = " + itin.getDays("madison"));
		System.out.println("Size = " + itin.size());
		itin.removeDestination("madison");
		System.out.println("Removed madison");
		System.out.println("Size = " + itin.size());
		try {
			System.out.println("First destination getDays = " + itin.getDays("Madison"));
		} catch (IndexOutOfBoundsException e) {
			System.out.println("Destination getDays through exception");
		}
		System.out.println("Total days = " + itin.days());
		if (itin.isEmpty()){
			System.out.println("itin is empty.");
		}
		else {
			System.out.println("itin is not empty.");
		}
		itin.addDestination("Fake City", 42);
		System.out.println("Total days = " + itin.days());
	}
}
