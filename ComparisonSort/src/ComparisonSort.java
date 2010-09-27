/**
 * This class implements seven different comparison sorts: 
 * <ul>
 *   <li>selection sort</li>
 *   <li>insertion sort</li>
 *   <li>merge sort</li> 
 *   <li>quick sort</li>
 *   <li>heap sort</li>
 *   <li>two-way selection sort</li>
 *   <li>two-way insertion sort</li>
 * </ul>
 * It also has a method that runs all the sorts on the same input array and 
 * prints out statistics.
 */
public class ComparisonSort {
    
	static int end = 1;
	
    /**
     * Sorts the given array using the selection sort algorithm.  You may use
     * either the algorithm discussed in the on-line reading or the algorithm 
     * discussed in lecture (which does fewer data moves than the one from the
     * on-line reading).
     * Note: after this method finishes the array is in sorted order.
     *
     * @param A the array to sort
     **/
    public static <E extends Comparable<E>> void selectionSort(E[] A) {
    	long timeStart = System.currentTimeMillis();
    	long moves = 0;
    	int j, k, minIndex;
        E min;
        int N = A.length -1;
        for (k = 0; k < N; k++) {
            min = A[k];
            minIndex = k;
            for (j = k+1; j < N; j++) {
                if (A[j].compareTo(min) < 0) {
                    min = A[j];
                    moves++;
                    minIndex = j;
                }
            }
            A[minIndex] = A[k];
            A[k] = min;
        }
        long timeStop = System.currentTimeMillis();
        long compares = 0;
        SortObject temp = (SortObject) A[0];
        compares = temp.getCompares();
        for (int i = 0; i < A.length; i++){
        	temp = (SortObject) A[i];
        	compares = compares + temp.getCompares();
        }     
        
        inOrder(A, 1);
        
        printFormatted("selection", compares, moves, (timeStop - timeStart));    
    }

    /**
     * Sorts the given array using the insertion sort algorithm.
     * Note: after this method finishes the array is in sorted order.
     *
     * @param A the array to sort
     **/
    public static <E extends Comparable<E>> void insertionSort(E[] A) {
    	long timeStart = System.currentTimeMillis();
    	int k, j;
        E tmp;
        int N = A.length;
        long moves = 0;
          
        for (k = 1; k < N; k++) {
            tmp = A[k];
            j = k - 1;
            while ((j >= 0) && (A[j].compareTo(tmp) > 0)) {
            	moves++;
                A[j+1] = A[j]; // move one value over one place to the right
                j--;
            }
            moves++;
            A[j+1] = tmp;    // insert kth value in correct place relative 
                               // to previous values
        }
        if (A.length > 3) {
	        long timeStop = System.currentTimeMillis();
	        long compares = 0;
	        SortObject temp = (SortObject) A[0];
	        compares = temp.getCompares();
	        for (int i = 0; i < A.length; i++){
	        	temp = (SortObject) A[i];
	        	compares = compares + temp.getCompares();
	        }     
	        inOrder(A, 2);
	        
        	printFormatted("insertion", moves, compares, (timeStop - timeStart));
        }
     }
    
    /**
     * Sorts the given array using the merge sort algorithm.
     * Note: after this method finishes the array is in sorted order.
     *
     * @param A the array to sort
     **/
    public static <E extends Comparable<E>> void mergeSort(E[] A) {
    	long timeStart = System.currentTimeMillis();
    	mergeAux(A, 0, A.length - 1); // call the aux. function to do all the work
    	long timeStop = System.currentTimeMillis();
    	printFormatted("Merge", 0, 0, (timeStop - timeStart));
    	inOrder(A, 3);
    }
     
    private static <E extends Comparable<E>> void mergeAux(E[] A, int low, int high) {
        // base case
        if (low == high) return;
     
        // recursive case
        
     // Step 1: Find the middle of the array (conceptually, divide it in half)
        int mid = (low + high) / 2;
         
     // Steps 2 and 3: Sort the 2 halves of A
        mergeAux(A, low, mid);
        mergeAux(A, mid+1, high);
     
     // Step 4: Merge sorted halves into an auxiliary array
        E[] tmp = (E[])(new Comparable[high-low+1]);
        int left = low;    // index into left half
        int right = mid+1; // index into right half
        int pos = 0;       // index into tmp
         
        while ((left <= mid) && (right <= high)) {
        // choose the smaller of the two values "pointed to" by left, right
        // copy that value into tmp[pos]
        // increment either left or right as appropriate
        // increment pos
        	try {
	        	//System.out.println("Tmp Len " + tmp.length + " Len. " + A.length + " Left: " + left + " Right: " +  right);
	        	//System.out.println("Left " + A[left] + " Right " + A[right]);
	        	if (A[left].compareTo(A[right]) < 0) {
	        		tmp[pos] = A[left];
	        		left++;
	        	}
	        	else {
	        		tmp[pos] = A[right];
	        		right++;
	        	}
	        	pos++;
        	} catch (NullPointerException e) {
        		inOrder(A, 3);
        	}
        }
        
        // when one of the two sorted halves has "run out" of values, but
        // there are still some in the other half, copy all the remaining 
        // values to tmp
        // Note: only 1 of the next 2 loops will actually execute
        
        while (left <= mid) {
        	tmp[pos++] = A[left++];
        }
        while (right <= high) {
        	tmp[pos++] = A[right++];
        }
        // all values are in tmp; copy them back into A
        System.arraycopy(tmp, 0, A, low, tmp.length);
    }
    

    /**
     * Sorts the given array using the quick sort algorithm.
     * Note: after this method finishes the array is in sorted order.
     *
     * @param A the array to sort
     **/
    public static <E extends Comparable<E>> void quickSort(E[] A) {
        long start = System.currentTimeMillis();
    	quickAux(A, 0, A.length-1);
        long stop = System.currentTimeMillis();
        
        inOrder(A, 4);
        
        printFormatted("quick", 0, 0, (stop - start));
    }
     
    private static <E extends Comparable<E>> void quickAux(E[] A, int low, int high) {
    	if (high == low) {
    		return;
    	}
    	else if (high-low <= 1) {
        	if (A[high].compareTo(A[low]) < 0) {
        		swap(A, low, high);
        	}
        }
        else {
            int right = partition(A, low, high);
            quickAux(A, low, right);
            quickAux(A, right+2, high);
        }
    }
    
    private static <E extends Comparable<E>> int partition(E[] A, int low, int high) {
    	// precondition: A.length > 3

    	    E pivot = medianOfThree(A, low, high); // this does step 1
    	    int left = low+1; 
    	    int right = high-2;
    	    while ( left <= right ) {
    	        while (A[left].compareTo(pivot) < 0) left++;
    	        while (A[right].compareTo(pivot) > 0) right--;
    	        if (left <= right) {
    	            swap(A, left, right);
    	            left++;
    	            right--;
    	        }
    	    }
    	    swap(A, left, high-1); // step 4
    	    return right;
	}
    private static void swap(Comparable[] A, int first, int second) {
    	//Tested working
    	Comparable tmp = A[first];
    	A[first] = A[second];
    	A[second] = tmp;
    }
    
    private static <E extends Comparable<E>> E medianOfThree(E[] A, int low, int high) {
    	//Tested working
    	E[] pivot = (E[])(new Comparable[3]);
    	int mid = ((high + low) / 2);
    	pivot[0] = A[low];
    	pivot[1] = A[mid];
    	pivot[2] = A[high];
    	insertionSort(pivot);
    	A[low] = pivot[0];
    	A[high] = pivot[2];
    	A[high-1] = pivot[1];
    	return pivot[1];
    }
    
    /**
     * Sorts the given array using the heap sort algorithm outlined below.
     * Note: after this method finishes the array is in sorted order.
     * 
     *<p>The heap sort algorithm is:
<pre>
for each i from 1 to the end of the array
    insert A[i] into the heap (contained in A[0]...A[i-1])
    
for each i from the end of the array up to 1
    remove the max element from the heap and put it in A[i]
</pre>
     *
     * @param A the array to sort
     **/
    public static <E extends Comparable<E>> void heapSort(E[] A) {
    	E[] heap = (E[])(new Comparable[A.length + 1]);    	
    	//populate heap 
    	for (int i = 0; i < A.length; i++) {
    		heapInsert(heap, A[i]);
    	}
    	heapRemove(heap, A);
    }
    
    private static <E extends Comparable<E>> void heapInsert(E[] heap, E value) {
    	//heap with max as root
    	heap[end] = value;
    	int parent = end / 2;
    	int curr = end;
    	while (parent > 0 && heap[parent].compareTo(heap[curr]) <= 0) { 
    		swap(heap, curr, parent);
    		curr = parent;
    		parent = curr / 2;
    	}
    	end++;   	
    }
    
    private static <E extends Comparable<E>> void heapRemove(E[] heap, E[] A) {
    	//heap with max as root
    	//n = len, w = left
    	
    	int len = heap.length - 2;
    	int count = 0;
    	while (len > 1) {
    		len--;
    		swap(heap, 1, len);
    		
    		//Order Property
    		int parent = 1;
    		int left = 2;    //left child
    		boolean inPlace = true;
            while (left < len || !inPlace)
            {
                if (left + 1 < len)    // right child
                    if (heap[len+1].compareTo(heap[len]) > 0) len++;
                // w is the descendant of v with maximum label
                
                if (heap[parent].compareTo(heap[left]) >= 0) inPlace = false; // v has heap property
                
                swap(heap, parent, len);  // exchange labels of v and w
                parent = left;
                left = 2 * parent;
            }
    	}
    	for (int a = 0; a < heap.length; a++) {
    		System.out.println(heap[a]);
    	}
    }
    
    private static <E extends Comparable<E>> void orderProp(E[] heap, int index) {
    	
    	
    	
    	
    	/**
    	int end = heap.length - 1;
    	
    	for (int j = heap.length - 2; j > 0; j--) {
    		int parent = 1;
    		A[j] = heap[1]; //Max is always at heap[1]
    		heap[1] = heap[end]; //Put last item into max spot
    		end--; //Shrink pointer that is end of sub-array (keep shape property)
    		int curr = 1;
    		
    		//Restore order property
    		boolean inPlace = false;
    		while (!inPlace && curr > 5000	) {
    			int largest = 0;
    			System.out.println(curr);
    			if (curr * 2 <= end && heap[curr * 2].compareTo(heap[curr * 2 + 1]) >= 0) {
    				largest = curr * 2;
    			}
    			else if (curr * 2 + 1<= end && heap[curr * 2].compareTo(heap[curr * 2 + 1]) < 0){
    				largest = (curr * 2) + 1;
    			}
    			else {
    				inPlace = true;
    			}
    			swap(heap, curr, largest);
    			curr = largest;
    			end--;
    			
    			
    			/**if (heap[parent].compareTo(heap[parent * 2]) >= 0) {
    				swap(heap, parent, parent * 2);
    				parent = parent * 2;
    			}
    			else if (heap[parent].compareTo(heap[(parent * 2) + 1]) >=0 && parent * 2 + 1 != end) {
    				swap(heap, parent, (parent * 2) + 1);
    				parent = (parent * 2) + 1;
    			}
    			else {
    				inPlace = true;
    			}**/
    }
    /**
     * Sorts the given array using the two-way selection sort algorithm 

     * outlined below.
     * Note: after this method finishes the array is in sorted order.
     * <p>
     * The two-way selection sort is a bi-directional selection sort that sorts
     * the array from the two ends towards the center.  The 
     * two-way selection sort algorithm is:
     * </p>
<pre>
begin = 0, end = A.length-1

// At the beginning of every iteration of this loop, we know that the 
// elements in A are in their final sorted positions from A[0] to A[begin-1]
// and from A[end+1] to the end of A.  That means that A[begin] to A[end] are
// still to be sorted.
do
    use the MinMax algorithm (described below) to find the minimum and maximum 
    values between A[begin] and A[end]
    
    swap the maximum value and A[end]
    swap the minimum value and A[begin]
    
    begin++, end--
until the middle of the array is reached 
</pre>
     * <p>
     * The MinMax algorithm allows you to find the minimum and maximum of N
     * elements in 3N/2 comparisons (instead of 2N comparisons).  The way to
     * do this is to keep the current min and max; then 
     * </p>
     * <ul>
     * <li>take two more elements and compare them against each other</li>
     * <li>compare the current max and the larger of the two elements</li>
     * <li>compare the current min and the smaller of the two elements</li>
     * </ul>
     *
     * @param A the array to sort
     **/    
    public static <E extends Comparable<E>> void twoWaySelectSort(E[] A) { 
    	//Totally wrong!!!
    	long start = System.currentTimeMillis();
    	int begin = 0; 
    	int end = A.length - 1;
    	int max = 0;
    	int min = 0;
    	
    	while (begin <= end) {
    		int left = begin;
    		int right = end;
    		while (left <= right) {
    			if (A[left].compareTo(A[right]) > 0) {
    				//left is larger than right
    				//See if left is the new max
    				if (A[left].compareTo(A[max]) > 0) {
    					max = left;
    				}
    				//See if right is the new min
    				if (A[right].compareTo(A[min]) < 0) {
    					min = right;
    				}
    			}
    			else {
    				//Right is larger than left
    				//See if right is the new max
    				if (A[right].compareTo(A[max]) > 0) {
    					max = right;
    				}
    				//See if left is the new min
    				if (A[left].compareTo(A[min]) < 0) {
    					min = left;
    				}
    			}
    			//increment counters
    			left++; right--;
    		}
    		if (begin != min) {
				//System.out.println("Begin: " + begin + " Min: " + min);
				swap(A, begin, min);
			}
			if (end != max) {
				//System.out.println("End: " + end + " Max: " + max);
				swap(A, end, max);
			}
    		//increment pointers
    		begin++; end--;
    	}
    	long stop = System.currentTimeMillis();
    	
    	inOrder(A, 6);
    	
    	printFormatted("2-way selection", 0, 0, (stop - start));
    }
    
    /**
     * Sorts the given array using the two-way insertion sort algorithm 
     * outlined below.
     * Note: after this method finishes the array is in sorted order.
     * <p>
     * The two-way selection sort is a bi-directional insertion sort that 
     * sorts the array from the center out towards the ends.  The 
     * two-way insertion sort algorithm is:
     * </p>
<pre>
precondition: A has an even length
left = element immediately to the left of the center of A
right = element immediately to the right of the center of A
if A[left] > A[right]
    swap A[left] and A[right]
left--, right++ 

// At the beginning of every iteration of this loop, we know that the elements
// in A from A[left+1] to A[right-1] are in relative sorted order.
do
    if (A[left] > A[right])
        swap A[left] and A[right]
    
    starting with with A[right] and moving to the left, use insertion sort 
    algorithm to insert the element at A[right] into the correct location 
    between A[left+1] and A[right-1]
    
    starting with A[left] and moving to the right, use the insertion sort 
    algorithm to insert the element at A[left] into the correct location 
    between A[left+1] and A[right-1]
    
    left--, right++
until left has gone off the left edge of A and right has gone off the right 
      edge of A
</pre>
     * <p>
     * This sorting algorithm described above only works on arrays of even 
     * length.  If the array passed in as a parameter is not even, the method 
     * throws an IllegalArgumentException
     * </p>
     *
     * @param A the array to sort
     * @throws IllegalArgumentException if the length or A is not even
     **/    
     public static <E extends Comparable<E>> void twoWayInsertSort(E[] A) { 
    	 int moves = 0;
    	 long start = System.currentTimeMillis();
    	 if (A.length % 2 != 0) {
    		 throw new IllegalArgumentException();
    	 }
    	 int right = A.length / 2;
    	 int left = (A.length / 2) - 1;
    	 while (left >= 0 && right < A.length) {
	    	 //Spread pointers out from center.
	    	 //Middle of array is sorted array. Do insertion sort into sorted area (A[left+1] and A[right-1])
	    	 if (A[left].compareTo(A[right]) > 0) {
	    		 for (int k = left; k < right; k++) {
	    	            E tmp = A[k];
	    	            int j = k - 1;
	    	            while ((j >= 0) && (A[j].compareTo(tmp) > 0)) {
	    	            	moves++;
	    	                A[j+1] = A[j]; // move one value over one place to the right
	    	                j--;
	    	            }
	    	            moves++;
	    	            A[j+1] = tmp;    // insert kth value in correct place relative 
	    		 }                          // to previous values
	    	 }
	    	 left--; right++;
    	 }
    	 long end = System.currentTimeMillis();
    	 inOrder(A, 7);
    	 
         
    	 printFormatted("2-way insertion", 0, moves, (end - start));
    }
     private static <E extends Comparable<E>> void inOrder(E[] A, int sort) {
    	 boolean debug = true; //Prints errors to console with useful info to help debug
    	 int print = 0; //0 for no printing, numbers in order for sort to print.
    	 boolean inOrder = true;
    	 
         int outoforder = 0;

         for (int i = 1; i<A.length-1; i++) {
        	if (print == sort) {
        		System.out.println(A[i]);
        	}
         	if (A[i].compareTo(A[i-1]) < 0) {
         		inOrder = false;
         		outoforder++;
         	}
         }
         if (!inOrder && debug) { 
         	System.out.println("Not in order");
         	System.out.println(outoforder);
         }    	 
     }
    
    /**
     * Sorts the given array using the seven different sorting algorithms
     * and prints out statistics.  The sorts performed are: 
     * <ul>
     *   <li>selection sort</li>
     *   <li>insertion sort</li>
     *   <li>merge sort</li> 
     *   <li>quick sort</li>
     *   <li>heap sort</li>
     *   <li>two-way selection sort</li>
     *   <li>two-way insertion sort</li>
     * </ul>
     * <p>
     * The statistics displayed for each sort are: number of comparisons,
     * number of data moves, and time (in milliseconds).
     * </p>
     * <p>
     * Note: each sort is given the same array (i.e., in the original order)
     * and the input array A is not changed by this method.
     * </p>
     * 
     * @param A the array to sort
     **/
     static private void printFormatted(String sort, long compares, long moves, long time) {
    	 System.out.println(Format.leftAlign(19, sort) + Format.rightAlign(8, compares) + Format.rightAlign(12, moves) + Format.rightAlign(12, time));
     }
     
     static private <E extends Comparable<E>> Comparable[] copyArray(E[] A) {
    	 Comparable[] B = new Comparable[A.length];
    	 System.arraycopy(A, 0, B, 0, A.length);
    	 return B; 
    	 
     }
     static public void runAllSorts(SortObject[] A) {
    	 System.out.println(Format.leftAlign(19, "Sort") + Format.rightAlign(8, "compares") + Format.rightAlign(12, "data moves") + Format.rightAlign(12, "millisecs"));
    	 selectionSort(copyArray(A));
    	 insertionSort(copyArray(A));
    	 mergeSort(copyArray(A));
    	 heapSort(copyArray(A));
    	 quickSort(copyArray(A));
    	 twoWaySelectSort(copyArray(A));
    	 twoWayInsertSort(copyArray(A));
    }
}