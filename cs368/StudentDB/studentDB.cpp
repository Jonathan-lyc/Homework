/*******************************************************************************
Author:        Josh Gachnang
CS Login:      gachnang@cs.wisc.edu

Credits:       None

Course:        CS 368, Fall 2010
Assignment:    Programming Assignment 1 
*******************************************************************************/

/**
  * The Student Database stores information about student's GPA
  * and how many credits they have taken.  They are identified by 
  * their 6 digit student ID. This console app allows the user to 
  * add, update and delete students.
  *
  * <p>Bugs: Doesn't properly update things in the database. 
  *
  * @author Josh Gachnang
  */
#include <iostream>

using namespace std;

/** The basic storage structure for the students. These are stored in the 
  * database array to form the database.
  *
  * @param id 6 digit student ID, unique identifier for studentID
  * @param credits Integer of the number of credits taken
  * @param gpa Floating point GPA
  */
struct Student {
    int id;
    int credits;
    double gpa;
} database[4000];  // Stores all the students.

int unused = 0; // Points to the next open spot in the database.
// This represents the max number of students, if none had been deleted.

  /** Searches the database for the student by the given student ID
    *
    * @param id Student id to search for
    * @return Either the spot in the database that the stuent is occupying
    */
int getStudent(int id) { //This should probably be a pointer
    Student tmp;
    for (int i = 0; i < unused; i++) {
	tmp = database[i];
	if (tmp.id == id) {
	    return i;
	}
    }
    return 4000;
}

void printStudent(Student s) {
    cout << s.id << ", " << s.credits << ", " << s.gpa << "\n";
}

void print() {
    for (int i = 0; i < unused; i++) {
	Student tmp = database[i];
	if (tmp.id != -1) { // If id = -1, disregard it as deleted
	    printStudent(tmp);
	}
    }
}

void addStudent(int id, int credits, double gpa) {
    Student student;
    student.id = id;
    student.credits = credits;
    student.gpa = gpa;
    database[unused] = student;
    unused++;
}

void deleteStudent(int id) {
    Student tmp = database[getStudent(id)];
    tmp.id = -1; // If id = -1, disregard it as deleted
}

void updateStudent(int id, char grade, int credits) {
    Student tmp = database[getStudent(id)];
    cout << tmp.id;
    int gradePts;
    switch (grade) {
	case 'A':
	    gradePts = 4.0;
	    break;
	case 'B':
	    gradePts = 3.0;
	    break;
	case 'C':
	    gradePts = 2.0;
	    break;
	case 'D':
	    gradePts = 1.0;
	    break;
	case 'F':
	    gradePts = 0.0;
	    break;
    }
    int gpaPts = ((tmp.gpa * tmp.credits) + (gradePts * credits)) / (credits + tmp.credits); //Not correct
    tmp.gpa = tmp.gpa + gpaPts;
    tmp.credits = tmp.credits + credits;
    cout << "Updated student record: ";
    printStudent(tmp);
}

int main() {
    bool done = false;
    char choice;
    int studentID;
    double gpa;
    int credits;
    char grade;
    
    cout << "Enter your commands at the ? prompt:" << endl;
    
    while (!done) {
        cout << '?';
        cin >> choice;
	
        switch (choice) {

            case 'd':  // deletes the student with the given ID
                break;
		
	    case 'a':  
                cin >> studentID;
                if (studentID < 100000 || studentID > 999999) {
		   cout << "Not a valid Student ID\n";
		   break;
		}
                cin >> credits; 
                if (credits < 0) {
		    cout << "Not a valid number of credits\n";
		    break;
		}
                cin >> gpa;  // adds in the student
                if (gpa < 0 || gpa > 4) {
		    cout << "Not a valid GPA";
		    break;
		}
		addStudent(studentID, credits, gpa);
                break;
		
	    case 'u':  // updates the student
                cin >> studentID; 
                if (studentID < 100000 || studentID > 999999) {
		   cout << "Not a valid Student ID\n";
		   break;
		}
		cin >> grade;
		if (grade != 'A' && grade != 'B' && grade != 'C' && \
		  grade != 'D' && grade != 'F') {
		    cout << "Not a valid letter grade\n";
		    break;
		}
                cin >> credits; 
                if (credits < 0) {
		    cout << "Not a valid number of credits\n";
		    break;
		}
		updateStudent(studentID, grade, credits);
                break;
	    
	    case 'p':  // prints the student
		cout << "Student database:\n";
		print();
                break;
		
            case 'q':  // exits the proram
                done = true;
                cout << "Quitting" << endl;
                break;

            // If the command is not one listed in the specification, for the 
            // purposes of this assignment, we will ignore it.  Note that you 
            // will see multiple ?'s printed out if there is additional 
            // information on the line (in addition to the unknown command 
            // character).  
            default: break;
        } // end switch

    } // end while

    return 0;
}
