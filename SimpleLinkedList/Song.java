///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Main Class File:  Shell.java
// File:             Song.java
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
 * A collection of single-musician {@linkplain Part parts} to be performed as a
 * complete song.
 */
public class Song implements AbstractSong {

	/**
	 * The storage mechanism used to store parts.
	 */
	private SimpleLinkedList<AbstractPart> list = new SimpleLinkedList<AbstractPart>();

	/**
	 * Adds a part to the end of the storage list.
	 * 
	 * @param AbstractPart part 
	 * 			AbstractPart containing one musician and notes to be played in perform. 
	 */
    public void addPart(AbstractPart part) {
        list.add(part);
    }

    /**
     * Returns an iterator of the storage list for parts.
     * 
     * @return Iterator<AbstractPart> iterator
     * 				Iterator of storage list.
     */
    public Iterator<AbstractPart> iterator() {
    	return list.iterator();
    }

    /**
     * Iterates the storage list, playing all notes in order of beat. 
     * Calls PerformancePrinter to print out to the console.
     * 
     * @throws BadMusicException
     * 			If notes are not playable.
     */
    public void perform() throws BadMusicException {
    	PerformancePrinter print = null;
    	SimpleLinkedList<PlayPosition> positions = new SimpleLinkedList<PlayPosition>();
    	int beat = 0;
    	for (int i = 0; i < list.size(); i++) {
    		PlayPosition pos = new PlayPosition(list.get(i));
    		positions.add(pos);
    	}
    	
    	//populate list of iterators to return notes
    	
    	while (!positions.isEmpty()) {
    		Iterator<PlayPosition> posIter = positions.iterator();
    		while (posIter.hasNext()) {
    			PlayPosition currPos = posIter.next();
    			if (currPos.getNextNoteChange() == 0) {
	    			if (currPos.notes.hasNext()) {	
	    					Note note = currPos.notes.next();
	    					print.printEvent(beat, currPos.player, note);
	        				currPos.setNextNoteChange(note.getBeats() -1);
	    			}
	    			else {
	    				posIter.remove();
	    			}
    			}
    			else {
    				currPos.setNextNoteChange(currPos.getNextNoteChange() - 1);
    			}
    		}
    		beat++;
    	}
    }
}
