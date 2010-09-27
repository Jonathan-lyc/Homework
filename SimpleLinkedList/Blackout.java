///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Main Class File:  Shell.java
// File:             Blackout.java
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
 * A performance mishap representing an electrical blackout. All notes for
 * electricity-powered musicians turn into silent rests. Musicians with other
 * {@linkplain Musician#powerSource power sources} are unaffected.
 */
public class Blackout implements Mishap {

    /**
     * Silences all notes in all parts whose {@linkplain Musician#powerSource
     * power source} is "electricity". Has no effect on musicians with other
     * power sources.
     * 
     * @return true iff at least one note used to be played but was changed into
     *         a silent rest
     */
    public boolean mutate(AbstractSong song) {
    	boolean mutated = false;
    	Iterator<AbstractPart> iterPart = song.iterator();
    	while (iterPart.hasNext()) {
    		Part part = (Part) iterPart.next();
    		if (part.getPlayer().powerSource.equals("electricity")) {
    			mutated = true;
    			Iterator<Note> iterNote = part.iterator();
    			while (iterNote.hasNext()) {
    				iterNote.next().becomeRest();
    			}
    			
    		}
    	}
        return mutated;
    }
}
