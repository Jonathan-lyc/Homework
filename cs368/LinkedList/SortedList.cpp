/*
 * SortedList class
 *
 * A SortedList is an ordered collection of Students.  The Students are ordered
 * from lowest numbered student ID to highest numbered student ID.
 */
class SortedList {

  public:
    
    SortedList() {
    // Constructs an empty list.
      *head = NULL;
    }

    bool insert(Student *s) {
    // If a student with the same ID is not already in the list, inserts 
    // the given student into the list in the appropriate place and returns
    // true.  If there is already a student in the list with the same ID
    // then the list is not changed and false is returned.
      currPtr = &head;
      nextPtr = NULL;
      
      //Check if the list is empty
      if ( *currPtr == NULL ) {
	
	newNode = new ListNode;
	newNode.student = *s;
	return true;
      }
      //Check if it should be the first item in the list
      if ( *s.getID < *currPtr.student.getID ) {
	newNode.next = currPtr;
	head = &newNode;
      }
      
      //Traverse list, looking for correct spot, or add to end
      while ( *nextPtr != NULL ) {
	//Make sure it doesn't already exist
	if ( *s.getID == *currPtr.student.getID ) {
	  return false; 
	}
	if ( *s.getID > *currPtr.student.getID ) {
	  if ( *s.getID < *nextPtr.student.getID || *nextPtr == NULL ) {
	    *currPtr.next = &newNode;
	    newNode.next = nextPtr;
	    
	  }
	}
	else {
	  //Increment
	  currPtr = nextPtr;
	  nextPtr = *nextPtr.next;
	}
      }
      *currPtr.next = newNode;
      return true;
    }
    
    Student *find(int studentID) {
    // Searches the list for a student with the given student ID.  If the
    // student is found, it is returned; if it is not found, NULL is returned.
      currPtr = head;
      while ( *currPtr.next != NULL ) {
	if ( *currPtr.student.getID == studentID ) {
	  return *currPtr.student;
	}
	currPtr = *currPtr.next;
      }
      return NULL;
    }
    Student *remove(int studentID) {
    // Searches the list for a student with the given student ID.  If the 
    // student is found, the student is removed from the list and returned;
    // if no student is found with the given ID, NULL is returned.
    // Note that the Student is NOT deleted - it is returned - however,
    // the removed list node should be deleted.
      currPtr = head;
      prevPtr = NULL;
      while ( *currPtr.next != NULL ) {
	  if ( *currPtr.student.getID == studentID ) {
	    //Student to be removed is first in list
	    if ( prevPtr = NULL ) {
	      ListNode ret = 
	      head = &currPtr.next;
	      
	    }
	  }
	  currPtr = *currPtr.next;
	}
	return NULL;
    }
    void print() const {
    // Prints out the list of students to standard output.  The students are
    // printed in order of student ID (from smallest to largest), one per line
    }
    
  private:
    // Since ListNodes will only be used within the SortedList class,
    // we make it private.
    struct ListNode {    
      Student *student;
      ListNode *next;
    };

    ListNode *head; // pointer to first node in the list
};