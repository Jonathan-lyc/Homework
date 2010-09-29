/*******************************************************************************
Author:        <your name>
CS Login:      <your login name>

Pair Partner:  <name of your pair programming partner (if applicable)>
CS Login:      <your partner's login name>

Credits:       <name of anyone (other than your pair programming partner) who 
                helped you write your program>

Course:         CS 368, Fall 2010
Assignment:     Programming Assignment 1 
*******************************************************************************/
#include <iostream>

using namespace std;

int main() {
    bool done = false;
    char choice;
    int studentID;

    cout << "Enter your commands at the ? prompt:" << endl;
    while (!done) {
        cout << '?';
        cin >> choice;

        switch (choice) {

            case 'd':  
                cin >> studentID;  // read in the integer ID
                break;

            case 'q':  
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
