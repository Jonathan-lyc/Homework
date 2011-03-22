#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <fcntl.h>
#include "mem.h"

#define DEADBEEF (0xDEADBEEF)
#define ABCDDCBA (0xABCDDCBA)
#define HEADSIZE (16)

int dbg = -1; //Debuging enabled/disabled/super mode and tracks init
int mapsize; //Size of the mapped region
int m_error; //Returns error codes
int init = 0; //0 = not inited, 1=init occured.

typedef struct __list_t {
  int size;
  void *next;
  void *prev;
  int free; //0 = free, 1 = used
} list_t;

//Head is the beginning of the mmap
list_t *head;

//Ask OS for chunk of memory, then create single header containing all
//free space. Point head to that node. Make sure head is always pointed
//to first node. Just check if prev == NULL, if so, node is first.
int Mem_Init(int sizeOfRegion, int debug) {
  
  dbg = debug; //Debug mode
  mapsize = sizeOfRegion;
  if (init != 0) {
	m_error = E_BAD_ARGS;
	return -1;
  }
  init = 1; //Initialized
  if (dbg == -1 || sizeOfRegion < 1) {
    m_error = E_BAD_ARGS;
    return -1;
  }

  //Open /dev/zero for mmap
  int fd = open("/dev/zero", O_RDWR);

  void *ptr = mmap(NULL, sizeOfRegion, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, fd, 0);
  if (ptr == MAP_FAILED) {
    perror("mmap");
    return -1;
  }
  head = ptr;
  list_t *freespace;
  freespace = (list_t *) ptr;
//   list_t freespace = {sizeOfRegion - sizeof(list_t), NULL, NULL, 0};
  freespace->size = sizeOfRegion - sizeof(list_t);
  freespace->next = NULL;
  freespace->prev = NULL;
  freespace->free = 0;
  
  close(fd);
  return 0;
}

void *Mem_Alloc(int size) {
  
  //Grab largest free, split up, add a new node, move largest ptr.
  
  //Align to 8 bytes for best performance
  if (size % 8 != 0) {
	size = size + (size % 8);
  }
  //Should check dbg between 0 & 2..Above 2 considered same as 0 I guess.
  if (dbg == 3) {
    printf("size:%d\n", size);
  }
  
  //Find largest free space (could be sped up, but this is easiest right now  
  list_t *largest = head;
  list_t *tmp = head;
  while (tmp) {
	if (tmp->free == 0 && tmp->size > head->size) {
	  largest = tmp;
	}
	tmp = tmp->next;
  }
  if (largest->size < size + 32) {
	m_error = E_NO_SPACE;
	return NULL;
  }
  
  list_t *smaller = (list_t *) largest + HEADSIZE + size;
  
  smaller->size = largest->size - HEADSIZE - size;
  smaller->next = largest->next;
  smaller->prev = largest;
  smaller->free = 0;
  
  largest->size = size;
  largest->next = smaller;
  largest->free = 1;
  
  //If ever a weird pointer issue getting moved via malloc, this may fix.
//   if (largest->prev == NULL) {
// 	head = largest;
// 	printf("%p\n", head);
//   }
  
  return largest + HEADSIZE;
}

int Mem_Free(void *ptr) {
  if (ptr == NULL) {
	return 0;
  }
  list_t *tofree = (list_t *) ptr - HEADSIZE;
  if (tofree->size == 0 || tofree->free == 0) {
	//Not a correct pointer
	m_error = E_BAD_POINTER;
	return -1;
  }
  tofree->free = 0;
  //Coalesce
  if (tofree->next != NULL) {
	list_t *after = tofree->next;
	if (after->free == 0) {
	  //Block after tofree is free also. Coalesce.
	  if (after->next != NULL) {
		list_t *afterafter = after->next;
		afterafter->prev = tofree;
	  }
	  tofree->size = tofree->size + HEADSIZE + after->size;
	  tofree->next = after->next;
	  
	  
// 	  list_t* before = tofree->prev;
// 	  after->size = after->size + tofree->size + HEADSIZE;
// 	  after->free = 0;
// 	  after->prev = before;
// 	  before->next = after;
	}
  }
  if (tofree->prev != NULL) {
	list_t *before = tofree->prev;
	if (before->free == 0) {
	  //Block before tofree is free also. Coalesce.
	  list_t* after = tofree->next;
	  before->size = before->size + tofree->size + HEADSIZE;
	  before->free = 0;
	  before->next = after;
	  after->prev = before;
	}
  }
  
  return 0;
}

void Mem_Dump() {
  printf("List:\n");
  list_t *tmp = head;
  while (tmp) {
    printf("  size:%d free:%d\n", tmp->size, tmp->free);
    tmp = tmp->next;
  }
  tmp = head;
  printf("Memory:\n");
  
//   int* i;   
//   for(i = (int*) (head + 1); i < (int*) (head + 1) + mapsize / 8; i++) { 
//     printf("%08x\n", (*i));
//   }
//   while (tmp < tmp + mapsize) {
// 	printf("%d\n", *tmp);
// 	tmp = tmp + 1;
//   }
  return;
}
