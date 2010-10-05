/*******************************************************************************
Author:        Josh Gachnang
CS Login:      gachnang@cs.wisc.edu

Credits:       

Course:         CS 368, Fall 2010
Assignment:     Programming Assignment 1 
*******************************************************************************/
#include <iostream>

using namespace std;

int main() {
    bool done = false;
    char choice;
    int studentID;
    double gpa;
    int credits;
    

    cout << "Enter your commands at the ? prompt:" << endl;
    while (!done) {
        cout << '?';
        cin >> choice;

        switch (choice) {

            case 'd':  // deletes the student with the given ID
                break;
		
	    case 'a':  
                cin >> studentID;  // adds in the student
                break;
		
	    case 'u':  // updates the student
                cin >> studentID;  // read in the integer ID
                break;
	    
	    case 'p':  // prints the student
                cin >> studentID;  // read in the integer ID
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
