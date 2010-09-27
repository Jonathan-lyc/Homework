///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Main Class File:  Shell.java
// File:             OutOfTune.java
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
 * A performance mishap representing a {@link Musician} who is out of tune. The
 * pitches of all notes played by this musician are shifted up or down by some
 * fixed amount. Silent rests are unaffected.
 */
public class OutOfTune implements Mishap {

    // TODO add any private fields or methods that you need

    /**
     * Create an out-of-tune mishap for a single musician.
     * 
     * @param affectedMusician
     *            musician who is out of tune
     * @param pitchChange
     *            value to be added to all notes’ original pitches
     * @throws IllegalArgumentException
     *             if {@code pitchChange} is zero
     */
	private Musician musician = new Musician(null, 0, 0, null, 1);
	private int pitch = 0;
	
    public OutOfTune(Musician affectedMusician, int pitchChange) {
        if (pitchChange == 0) {
        	throw new IllegalArgumentException();
        }
        musician = affectedMusician;
        pitch = pitchChange;
    }

    /**
     * Shift the pitch of all notes played by the affected musician. Has no
     * effect on silent rests or on parts not played by this musician.
     * 
     * @return true iff this musician had at least one played note which is now
     *         out of tune
     */
    @Override
    public boolean mutate(AbstractSong song) {
    	boolean mutated = false;
    	Iterator<AbstractPart> iterPart = song.iterator();
    	while (iterPart.hasNext()) {
    		Part part = (Part) iterPart.next();
    		if (part.getPlayer().name == musician.name) {
    			Iterator<Note> iterNote = part.iterator();
    			while (iterNote.hasNext()) {
    				Note note = iterNote.next();
    				if (!note.isRest()) {
    					note.setPitch(note.getPitch() + pitch);
    					mutated = true;
    				}
    			}
    		}
    	}
        return mutated;
    }
}