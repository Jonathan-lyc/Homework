/******************************************************************************
Author:        Josh Gachnang
CS Login:      gachnang@cs.wisc.edu

Credits:       None

Course:        CS 368, Fall 2010
Assignment:    Programming Assignment 2
******************************************************************************/

#include <cstddef>
#include "Student.h"
using namespace std;

  public:
    
    /* 
     * A no parameter constructor. Sets the head ptr to NULL. No dummy nodes
     */
    SortedList() {
      head = NULL;
    }
    
    /* If a student with the same ID is not already in the list, inserts 
     * the given student into the list in the appropriate place and returns
     * true.  If there is already a student in the list with the same ID
     * then the list is not changed and false is returned.
     * 
     * @params:
     *   Student s: A student to add as the data to the list.
     * @return:
     *   boolean complete: True if inserted, False if already exists.
     */
    bool insert(Student *s) {
    
      ListNode *currPtr = head;
      ListNode *nextPtr = NULL;
      ListNode newNode;
      
      //Check if the list is empty
      if ( currPtr == NULL ) { //Might not be working..
	newNode.student = s;
	return true;
      }
      //Check if it should be the first item in the list
      Student *curr = (*currPtr).student;
      Student *next = (*nextPtr).student;
      if ( (*s).getID() < (*curr).getID() ) {

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
>>>>>>> .merge_file_woyrh6
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

            nextPtr = (*nextPtr).next;
	    Student *curr = (*currPtr).student;
	    Student *next = (*nextPtr).student;
	}
      }
      (*currPtr).next = &newNode;
      return true;
    }
    
    /*
     * Searches the list for a student with the given student ID.  If the
     * student is found, it is returned; if it is not found, NULL is returned.
     *
     * @params:
     *  int studentID: The ID of the student to find
     * @return:
     *  Student s: The student with the matching ID, or NULL if not found
     */
    Student *find(int studentID) {
      ListNode currPtr = *head;
      Student *curr = currPtr.student;
      while ( currPtr.next != NULL ) {
	if ( (*curr).getID() == studentID ) {
	  return curr;
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
    
    /*
     * Searches the list for a student with the given student ID.  If the 
     * student is found, the student is removed from the list and returned;
     * if no student is found with the given ID, NULL is returned.
     *  Note that the Student is NOT deleted - it is returned - however,
     * the removed list node should be deleted. 
     *
     * @params:
     *   int studentID: Student to removed
     * @return:
     *   Student s: The student with the matching ID, or NULL if it doesn't 
     *   exist
     */
    Student *remove(int studentID) {
      ListNode *currPtr = head;                                                   
      ListNode* prevPtr = NULL;
      Student *curr = (*currPtr).student;
      Student *prev = (*prevPtr).student;
      while ( (*currPtr).next != NULL ) {
	  if ( (*curr).getID() == studentID ) {
	    //Student to be removed is first in list
	    if ( prevPtr = NULL ) {
	      delete currPtr;
	      head = (*currPtr).next;
	      return curr;
	    }
	    //Student is in middle of list
	    else {
	      (*prevPtr).next = (*currPtr).next;
	      delete currPtr;
	      return curr;
	    }
	  }
	  prevPtr = currPtr;
	  currPtr = (*currPtr).next;
	}
	return NULL;
    }
    /*
     * Prints out the list of students to standard output.  The students are
     * printed in order of student ID (from smallest to largest), one per line
     */
    void print() const {
    
      ListNode *currPtr = head;
      if ( currPtr == NULL ) {
	//No direction given, pass.
      }
      else {
	Student *curr = (*currPtr).student;
	while ( (*currPtr).next != NULL ) {
	  (*curr).print();
	  currPtr = (*currPtr).next;
	  Student *curr = (*currPtr).student;
	}
      }
    }
  private:
    // Since ListNodes will only be use ListNode within the SortedList class,
    // we make it private. Contains a student and pointer to next ListNode.
    struct ListNode {    
      Student *student;
      ListNode *next;
    } *head; // pointer to first node in the list;

};
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
