#To set LD LIBRARY PATH
#export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH

myprogram: clean libmem.so 
	gcc -m32 -lmem -L. -Wall -o myprogram mymain.c

libmem.so: mem.c mem.h
	gcc -m32 -c -fpic mem.c
	gcc -m32 -shared -o libmem.so mem.o

clean:
	rm -f myprogram libmem.so
