///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Main Class File:  Shell.java
// File:             Overslept.java
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
 * A performance mishap representing a {@link Musician} over-sleeping and
 * arriving after the song has already started. Changes all of this musician’s
 * notes into silent rests until he or she finally arrives and starts playing.
 */
public class Overslept implements Mishap {

    /**
     * Create an over-sleeping mishap.
     * 
     * @param sleeper
     *            musician who over-slept
     * @param arrivalBeat
     *            time (in song beats) that the musician finally arrives
     * @throws IllegalArgumentException
     *             if {@code arrivalBeat} is negative or zero
     */
	private Musician musician = new Musician(null, 0, 0, null, 1);
	private int beat = 0;
	
    public Overslept(Musician sleeper, int arrivalBeat) {
    	if (arrivalBeat <= 0) {
    		throw new IllegalArgumentException();
    	}
    	musician = sleeper;
    	beat = arrivalBeat;
    	
    }

    /**
     * Changes all of this musician’s notes into silent rests until he or she
     * finally arrives and starts playing. Late musicians do not begin mid-note:
     * if a long note begins before the musician arrives and ends after, then
     * the <em>entire</em> note is turned into a silent rest.
     * 
     * @return true iff the musician’s late arrival actually turned any played
     *         notes into rests
     */
    public boolean mutate(AbstractSong song) {
    	
    	boolean mutated = false;
    	Iterator<AbstractPart> iterPart = song.iterator();
    	while (iterPart.hasNext()) {
    		Part part = (Part) iterPart.next();
    		if (part.getPlayer().name.equals(musician.name)) {
    			Iterator<Note> iterNote = part.iterator();
    			int count = 0;
    			while (iterNote.hasNext() && count < beat) {
    				Note note = iterNote.next();
    				if (!note.isRest()) {
    					mutated = true;
    				}
    				note.becomeRest();
    				count = count + note.getBeats();
    			}
    		}
    	}
        return mutated;
    }
}