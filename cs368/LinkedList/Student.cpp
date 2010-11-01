/*
 * Student class
 *
 * A Student object contains a student ID, the number of credits, and an
 * overall GPA.
 */
class Student {
  
  public:
    Student() {
    // Constructs a default student with an ID of 0, 0 credits, and 0.0 GPA.
      studentID = 0;
      credits = 0;
      GPA = 0.0;
    }
      
    Student(int ID) {
    // Constructs a student with the given ID, 0 credits, and 0.0 GPA.
      studentID = ID;
      credits = 0;
      GPA = 0.0;
    }

    Student(int ID, int cr, double grPtAv) {
    // Constructs a student with the given ID, number of credits, and GPA.
      studentID = ID;
      credits = cr;
      GPA = grPtAv;
    }

    // Accessors
    int getID() const {
    // returns the student ID
      return studentID;
    }
    int getCredits() const {
    // returns the number of credits
      return credits;
    }
    double getGPA() const {
    // returns the GPA
      return GPA;
    }
    // Other methods

    void update(char grade, int cr) {
    // Updates the total credits and overall GPA to take into account the
    // additions of the given letter grade in a course with the given number
    // of credits.  The update is done by first converting the letter grade
    // into a numeric value (A = 4.0, B = 3.0, etc.).  The new GPA is 
    // calculated using the formula:
    //
    //            (oldGPA * old_total_credits) + (numeric_grade * cr)
    //   newGPA = ---------------------------------------------------
    //                        old_total_credits + cr
    //
    // Finally, the total credits is updated (to old_total_credits + cr)
      switch (grade) {
	case 'A':
	  numGrade = 4.0;
	  break;
	case 'B':
	  numGrade = 3.0;
	  break;
	case 'C':
	  numGrade = 2.0;
	  break;
	case 'D':
	  numGrade = 1.0;
	  break;
	case 'F':
	  numGrade = 0.0;
	  break;
      }
      GPA = ((GPA * credits) + (numGrade * cr))/(credits + cr)
    }
    void print() const {
    // Prints out the student to standard output in the format:
    //   ID, credits, GPA
    // Note: the end-of-line is NOT printed after the student information 
      cout << studentID << ", " << credits << ", " << GPA;
    }
    
  private:
    int studentID;
    int credits;
    double GPA;
}