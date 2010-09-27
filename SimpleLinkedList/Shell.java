///////////////////////////////////////////////////////////////////////////////
//                   ALL STUDENTS COMPLETE THESE SECTIONS
// Title:            MusicApp
// Files:            Blackout.java, BrokenString.java, OutOfTune.java, 
//					 Overslept.java, Part.java, Shell.java, 
//					 SimpleLinkedList.java, SimpleLinkedListIterator.java,
//					 Song.java, Tester.java
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
 * A music-related command shell. This class handles enacting commands parsed by
 * its {@link ShellBase} superclass.
 */
public class Shell extends ShellBase {

	private Part part = new Part();
	private Song song = new Song();
	private Musician musician = new Musician(null, 0, 0, null, 1);
	private SimpleLinkedList<Musician> musicianList = new SimpleLinkedList<Musician>();	
	
    /**
     * Main entry point to launch a music-command shell.
     * 
     * @param args
     *            command-line arguments
     */
    public static void main(String[] args) {
        // Do not change this method!
        new Shell().run(args);
    }

    /**
	 * Adds the given note to the end of the part to be played
	 * 
	 * @param beats 
	 * 			Int of how many beats the note is play for.
	 * @param pitch 
	 * 			Integer of the pitch of the note.
	 */
    protected void appendNote(int beats, Integer pitch) {
        if (part.getPlayer() == null) {
        	throw new IllegalArgumentException();
        }
        
        Note note = new Note(beats);
        if (pitch == null) {
        	note.becomeRest();
        }
        else {
        	note.setPitch(pitch);
        }
        part.appendNote(note);
    }
    
    /**
	 * Applies a Blackout Mishap, rendering all electric instruments silent
	 * 
	 * @param dest String name of destination
	 * @return boolean True: Turned at least one note into a rest.
	 * 				   False: No musicians use electric instruments or have notes.
	 */
    protected boolean applyBlackout() {
        Blackout blackout = new Blackout();
        boolean mutated = blackout.mutate(song);
        return mutated;
    }

    /**
	 * Applies the BrokenString Mishap, silencing string notes for a given pitch.
	 * 
	 * @param musicianName 
	 * 			String of the unfortunate musician to break a string.
	 * @param affectedPitch 
	 * 			Int of the pitch to be silence
	 * 
	 * @return boolean True: Turned at least one note into a rest.
	 * 				   False: No musicians use string instruments or have notes.
	 */
    protected boolean applyBrokenString(String musicianName, int affectedPitch) {
    	Musician musician = findMusician(musicianName);
        if (musician.name == null) {
        	return false;
        }
    	BrokenString broke = new BrokenString(musician, affectedPitch);
    	broke.mutate(song);
        return true;
    }

    /**
	 * Applies the OutOfTune Mishap, modifying all notes' pitch for a specific musician.
	 * 
	 * @param musicianName 
	 * 			String of the unfortunate musician to be out of tune.
	 * @param affectedPitch 
	 * 			Int of change in pitch the musician experiences.
	 * 
	 * @return boolean 
	 * 			True: Modified at least one note for the musician. 
	 * 			False: No notes for specified musician.
	 */
    protected boolean applyOutOfTune(String musicianName, int pitchChange) {
    	Musician musician = findMusician(musicianName);
        if (musician.name == null) {
        	return false;
        }
    	OutOfTune tune = new OutOfTune(musician, pitchChange);
    	tune.mutate(song);
        return true;
    }

    /**
	 * Applies the Overslept Mishap, silencing all notes up to a certain beat.
	 * 
	 * @param musicianName 
 * 				String of the unfortunate musician miss the beginning of the show.
	 * @param affectedPitch 
	 * 			Int of the beat the musician will start playing on.
	 * 
	 * @return boolean 
	 * 			True: Turned at least one note into a rest. 
	 * 			False: Musician didn't miss any beats.
	 */
    protected boolean applyOverslept(String musicianName, int arrivalBeat) {
    	Musician musician = findMusician(musicianName);
    	if (musician.name == null) {
        	return false;
        }
    	Overslept overslept = new Overslept(musician, arrivalBeat);
        overslept.mutate(song);
        return true;
    }
    
    /**
	 * Searches the list of Parts for the specified musician.
	 * 
	 * @param musicianName 
	 * 			String of the musician to search for.
	 * 
	 * @return Musician 
	 * 			The Musician that was searched for, or throws IllegalArgument if not found.
	 * 
	 */
    
    private Musician findMusician(String musicianName) {
    	Iterator<Musician> iter = musicianList.iterator();
        while (iter.hasNext()) {
        	Musician temp = iter.next();  
        	if (musicianName.equals(temp.name)) {
        		return temp;
        	}
        }
        return null;
    }

    /**
	 * Creates a Musician.
	 * 
	 * @param name 
	 * 			String of musician's name.
	 * @param lowestPitch 
	 * 			Int of lowest pitch musician can play.
	 * @param highestPitch 
	 * 			Int of highest pitch musician can play.
	 * @param powerSource 
	 * 			String representation of power source (electricity, strings, lungs, etc)
	 * @param lungCapacity 
	 * 			Int if longest note musician can play in beats.
	 * 
	 * @throws IllegalArgumentException 
	 * 			If lowestPitch > highestPitch or musician's name is null.
	 * @throws IllegalArgumentException
	 * 			If musician is already playing a part.
	 */
    protected void createMusician(String name, int lowestPitch, int highestPitch, String powerSource, int lungCapacity) {
    	if (lowestPitch >highestPitch) {
        	throw new IllegalArgumentException();
        }
        if (findMusician(name) != null) {
        	throw new IllegalArgumentException();
        }
    	Musician newMusician = new Musician(name, lowestPitch, highestPitch, powerSource, lungCapacity);
        musicianList.add(newMusician);
    }

    /**
	 * Creates a Part
	 * 
	 * @param playerName 
	 * 			String of musician's name.
	 * @throws IllegalArgumentException 
	 * 			If lowestPitch > highestPitch or musician's name is null.
	 */
    protected void createPart(String playerName) {
        Part newPart = new Part();
        Musician addMusician = findMusician(playerName);
        if (addMusician.name != null) {
        	newPart.setPlayer(addMusician);
        	part = newPart;
            song.addPart(newPart);
        }
        else {
        	throw new IllegalArgumentException();
        } 
    }
    
    /**
	 * Returns Song, which is a list of parts.
	 * 
	 * @return AbstractSong 
	 * 			The list of parts.
	 */
    protected AbstractSong getCurrentSong() {
        return song;
    }
    
    /**
	 * Searches for adjacent rests, and combines them into one rest.
	 * 
	 * @return Boolean 
	 * 			If any notes were merged together.
	 */
    protected boolean mergeAdjacentRests() {
    	Iterator<AbstractPart> iter = song.iterator();
    	boolean merged = false;
    	while (iter.hasNext()) {
    		if(iter.next().mergeAdjacentRests()) {
    			merged = true;
    		}
    	}
    	return merged;
    }
    
    /**
	 * Performs current song, printing out the notes as they are played.
	 * 
	 * @throws BadMusicException 
	 * 			If any notes are size 0, or music cannot be played by assigned musician.
	 * 			Checked by ShellBase.
	 */
    protected void perform() throws BadMusicException {
        song.perform();
    }
}
