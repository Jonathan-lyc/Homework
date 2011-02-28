#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "mem.h"

int dbg = -1;
int merror;

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
  
  if (dbg == -1 || sizeOfRegion < 1) {
    merror = E_BAD_ARGS;
    return -1;
  }

  //Open /dev/zero for mmap
  int fd = open("/dev/zero", O_RDWR);

  void *ptr = mmap(NULL, sizeOfRegion, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, fd, 0);
  if (ptr == MAP_FAILED) {
    perror("mmap");
    return -1;
  }
  
  list_t *freespace;
  freespace = (list_t *) ptr;
//   list_t freespace = {sizeOfRegion - sizeof(list_t), NULL, NULL, 0};
  freespace->size = sizeOfRegion - sizeof(list_t);
  freespace->next = NULL;
  freespace->prev = NULL;
  freespace->free = 0;
  head = freespace;
  
  printf("head:%p\n", head);
  return 0;
}

void *Mem_Alloc(int size) {
  //Grab largest free, split up, add a new node, move largest ptr.
  
  //Align to 8 bytes for best performance
  if (size % 8 != 0) {
	size = size + (size % 8);
  }
  
  printf("size:%d\n", size);
  //Find largest free space (could be sped up, but this is easiest right now  
  list_t *largest = head;
  list_t *tmp = head;
  while (tmp) {
	if (tmp->free == 0 && tmp->size > head->size) {
	  largest = tmp;
	}
	tmp = tmp->next;
  }
  
  list_t *smaller = (list_t *) largest + 16 + size;
  
  smaller->size = largest->size - 16 - size;
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
  
  return largest + 16;
}

int Mem_Free(void *ptr) {
  return 0;
}

void Mem_Dump() {
  printf("dump:\n");
  list_t *tmp = head;
  while (tmp) {
    printf("  size:%d\n", tmp->size);
    tmp = tmp->next;
  }
  return;
}
