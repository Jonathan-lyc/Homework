///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Main Class File:  Shell.java
// File:             Part.java
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
 * One part of a song, represented as a sequence of {@link Note}s. Each part is
 * played by a single musician. A collection of single parts forms a
 * {@link Song}.
 * <p>
 * Initially a part has no musician assigned to play it. Use
 * {@link #setPlayer(Musician)} to assign a musician to play a given part.
 */
public class Part implements AbstractPart {

	//Player of the song.  Created as data member, initialized in constructor.
	private Musician player = new Musician(null, 0, 0, null, 1);
	//Private storage list for Notes in Part.
	private SimpleLinkedList<Note> list = new SimpleLinkedList<Note>();
	
	/**
     * Appends note to end of list.
     * 
     * @param Note note
     * 			Note to be added to end of list. Must have positive beats.
     * @throws IllegalArgumentException
     *          If beats == 0
     */
    public void appendNote(Note note) {
    	if (note.getBeats() == 0) {
    		throw new IllegalArgumentException("Notes must be at least 1 beat long");
    	}
    	list.add(note);
    }
   
    /**
     * Gets the musician of the 
     * 
     * @return Musician player
     * 			Musician of this part.
     * @throws IllegalArgumentException
     *          If musician has not been set yet.
     */
    public Musician getPlayer() {
    	if (player.name == null) {
    		throw new IllegalArgumentException();
    	}
        return player;
    }

    /**
     * Appends note to end of list.
     * 
     * @return Boolean playable
     * 			True: Part has notes which are playable, and a musician, or has
     * 			no notes (playable without musician)
     * 			False: Either no musician, or notes unplayable.
     * @throws IllegalArgumentException
     *          If beats == 0
     */
    public boolean isPlayable() {
        if (list.size() == 0) {
        	return true;
        }
        if (player.name == null) {
        	return false;
        }
    	Iterator<Note> iter = list.iterator();
    	boolean playable = true;
    	while (iter.hasNext() && playable) {
    		Note temp = iter.next();
    		if (!lungCheck(temp)) {
    			return false;
    		}
    		if (temp.getPitch() > player.highestPitch || temp.getPitch() < player.lowestPitch) {
    			return false;
    		}
        }
    	return true;        
    }
    
    /**
     * Private method to reduce redundant code
     * 
     * @param Note check
     * 			Note to be check against lung capacity
     * @returns boolean capable
     * 			True: Note is playable by musician
     * 			False: Note is too long for musician
     */
    private boolean lungCheck(Note check) {
    	if (player.powerSource.equals("lungs") && !check.isRest()) {
	    		if (check.getBeats() > player.lungCapacity) {
					return false;
			}
    	}
		return true;
    }

    /**
     * Returns an iterator of the storage list for notes.
     * 
     * @return Iterator<Note> iterator
     * 				Iterator of storage list.
     */
    public Iterator<Note> iterator() {
    	return list.iterator();
    }

    /**
     * Finds adjacent notes and merges them.
     * 
     * @return boolean merged
     * 			True: Some notes were merged.
     * 			False: No notes were merged.
     */
    public boolean mergeAdjacentRests() { 
    	Iterator<Note> listIter = list.iterator();
    	boolean merged = false;
    	boolean lastRest = false;
    	Note change = new Note(50);
    	while (listIter.hasNext()) {
    		Note temp = listIter.next();
    		if (temp.isRest()) {
    			if (lastRest) {
    				change.setBeats(temp.getBeats() + change.getBeats());
    				listIter.remove();
    			}
    			else {
    				change = temp;
    			}
    			lastRest = true;
    			merged = true;
    		}
    		else {
    			lastRest = false;
    		}
    	}
		return merged;
    	
    	
    	
    	
    	
    	
    	
    	/*int counter = 0;
    	boolean merged = false;
    	SimpleLinkedList<Integer> intList = new SimpleLinkedList<Integer>();
    	SimpleLinkedList<Integer> beatList = new SimpleLinkedList<Integer>();
    	Iterator<Note> iter = list.iterator();
    	Iterator<Note> iter2 = list.iterator();
    	Note note2 = iter2.next();
    	
    	while (iter2.hasNext()) {
    		Note note1 = iter.next();
    		note2 = iter2.next();
    		if (note1.isRest() && note2.isRest()) {
    			merged = true;
    			intList.add(counter);
    			beatList.add(note1.getBeats() + note2.getBeats());
    		}
    		else {
    		counter++;
    	}
    	
    	Iterator<Integer> intIter = intList.iterator();
    	Iterator<Integer> beatIter = beatList.iterator();
    	int offset = 0;
    	while(intIter.hasNext()) {
    		int pos = intIter.next();
    		int beats = beatIter.next();
    		
    		list.remove(pos - offset);
    		list.remove(pos - offset);
    		offset++;
    		Note noteAdd = new Note(beats);
    		noteAdd.becomeRest();
    		list.add(noteAdd);
    	}
    	return merged;*/
    }

    public void setPlayer(Musician player) {
        this.player = player;
    }
}
