///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Main Class File:  Shell.java
// File:             BrokenString.java
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
 * A performance mishap representing an musician with a broken string. Each
 * string corresponds to a single numeric note pitch, and turns all such notes
 * played by this musician into silent rests. Only affects musicians whose
 * {@linkplain Musician#powerSource power source} is "strings".
 */
public class BrokenString implements Mishap {

	//Player to be affected.
	private Musician musician = new Musician(null, 0, 0, null, 1);
	//Pitch to be affected.
	private int pitch = 0;

    /**
     * Create a broken-string mishap for a single string (numeric pitch) of a
     * single musician.
     * 
     * @param affectedMusician
     *            musician whose string broke
     * @param affectedPitch
     *            numeric pitch played by broken string, which will now be
     *            silenced
     * @throws IllegalArgumentException
     *             if the affected musician’s {@linkplain Musician#powerSource
     *             power source} is not "strings"
     */
    public BrokenString(Musician affectedMusician, int affectedPitch) {
        if (affectedMusician.powerSource.equals("strings")) {
        	musician = affectedMusician;
            pitch = affectedPitch;
        }
        else {
        	throw new IllegalArgumentException();
        }
    }

    /**
     * Silences all notes of the affected pitch played by the affected musician.
     * Has no effect on parts not played by this musician, or on this musician’s
     * notes with pitches different from the affected string.
     * 
     * @return true iff at least one note used to be played but was changed into
     *         a silent rest
     */
    public boolean mutate(AbstractSong song) {
    	boolean mutated = false;
    	Iterator<AbstractPart> iterPart = song.iterator();
    	while (iterPart.hasNext()) {
    		Part part = (Part) iterPart.next();
    		if (part.getPlayer().name == musician.name) {
    			Iterator<Note> iterNote = part.iterator();
    			while (iterNote.hasNext()) {
    				Note note = iterNote.next();
    				System.out.println("note pitch = " + note.getPitch());
    				if (note.getPitch() == pitch) {
    					System.out.println("Mutated note pitch = " + note.getPitch());
    					note.becomeRest();
    					mutated = true;
    				}
    			}
    		}
    	}
        return mutated;
    }
}