/* Assignment1 Convert
 * by Josh Gachnang
 *
 * This program takes up to 6 hexcadecimal numbers and converts them to
 * binary and decimal notation, while checking for errors. It then prints
 * out everything in a readable format. The max size hex number it can 
 * handle is a 32 bit, 2s-compliment number.
 */

#include "stdio.h"

#define ARRAYSIZE 6
#define DEBUG 1


int parseHex(char hex[]);
void printOutput(int array[], char *copyOfArgv[], int numOfInts);
void printInt(int intToPrint, int radix);


int parseHex(char hex[]) {
  if (hex[0] != '0' || hex[1] != 'x') {
    return -1;
  }
  int pos = 2;
  char curr;  
  curr = hex[pos];
  int count = 0;
  
  /* Checks all the values after 0x to make sure they are valid, and
   * counts the number of values to make conversions easier. Count + 1
   * will be the last index of array (other than \0)
   */
  while ( curr != '\0' ) {
    pos++;
    int ascii = curr;
    
    /* Acceptable ASCII values are 48-57, and 97 to 102, inclusive. */
    if (ascii < 48 || (ascii > 57 && ascii < 97) || ascii > 102) {
      return -1; 
    }
    curr = hex[pos];
    count++;
  }
    /* Converts to integer, based on the value/offset of each place. */
    int offset = 0;
    int j;
    int total = 0;
    for ( j = count + 1; j > 1; j-- ) {
      int i;
      if ( hex[j] >= 48 && hex[j] <= 57 ) {
	i = hex[j] - '0';
      }
      else {
	i = hex[j] - 'a' + 10;
      }
      total = total + ( i * powerOf(16, offset));
      offset++;
    }
  return total;
    
}

/* Power of is a power function, since C doesn't include one.
 * 
 * Parameters:
 *   int a: base of the power function (a^b)
 *   int b: exponent of the power function (a^b)
 * Return:
 *   total: what the equation equals (a^b)
 */
int powerOf(int a, int b) {
  int count = 0;
  int i = 0;
  int total = a;
  if ( b == 0 ) {
    return 1;
  }
  if ( b == 1 ) {
    return a;  
  }
  for ( i = 1; i < b; i++ ) {
    total = total * a;
    count++;
  }
  return total;
}

/* printOutput takes the arrays of integers and argv and prints them to
 * 	stdout. It makes calls to printInt to accomplis this.
 * Parameters:
 *   int array[]: Array of hex values converted to integers
 *   char *copyofArgv[]: the stdin arguments passed to the program
 *   int numOfInts: size of array[]
 */
void printOutput(int array[], char *copyOfArgv[], int numOfInts) {
  int i;
  for ( i = 1; i < numOfInts; i++ ) {
    printf("%d\n", *copyOfArgv[i]);
    printf("Decimal: ");
    printInt(array[i - 1], 10);
    printf("Binary: ");
    printInt(array[i - 1], 2);
  }
}

void printInt(int intToPrint, int radix) {
  int arraySize = 15;
  int intArray[arraySize];
  int total = 0;
  int i;
  int temp;
  /* initialize with 0's, to cut out leading 0's and garbage */
  for ( i = 0; i < arraySize; i++ ) {
    intArray[i] = 0; 
  }
  for ( i = 1; i < arraySize; i++ ) {
    intArray[arraySize - i] = intToPrint % radix;
    temp = intToPrint / radix;
    if (temp == 0) {
      break; 
    }
    else {
      intToPrint = temp;
    }
  }
  int j;
  int leadingZeroes = 0;
  for ( j = 0; j < arraySize; j++) {
    if ( leadingZeroes == 0 ) {
      if ( intArray[j] != 0 ) {
	leadingZeroes = 1;
      }
    }
    if ( leadingZeroes == 1) {
      printf("%d", intArray[j]); 
    }
  }
  printf("\n");
}

/* Main checks that the number of arguments is correct, then calls the to
 * 	the other functions to parse the hexidecimal values to integers
 * 	then print them out to stdout. It will quit on incorrect input with
 * 	an appro
 * 
 * Parameters:
 *   argc: the number of arguments (including the original program)
 *   argv: an array of the arguments (including the original program name)
 * 
 * Exit codes:
 *   0: Completed successfully
 *   1: More than 6 values to convert. Failed.
 *   2: Bad input in one of the hex numbers. Failed.
 */
int main (int argc, char *argv[]){
  if (argc == 1) {
    /* no arguements, do nothing */ 
    return 0;
  }  
  if (argc > 7) {
    printf("Maximum of 6 values accepted.  Quitting.\n");
    return 1;
  } 
  printf("Values to convert: %d\n", argc - 1);
  
  char *copyOfArgv[argc];
  int j;
  for ( j = 0; j < argc; j++ ) {
    copyOfArgv[j] = argv[j]; 
  }
    
  int intarray[argc];
  int i;
  for ( i = 1; i < argc; i++ ) {
    int decimal; /*contains the decimal value of the hex input*/

    decimal = parseHex(copyOfArgv[i]);
    if (decimal == -1) {
      printf("Bad input encountered.  Quitting.\n");
      return 2;
    }
    else {
      intarray[i - 1] = decimal;
    }
  }
  printOutput(intarray, argv ,argc);
  return 0;
}