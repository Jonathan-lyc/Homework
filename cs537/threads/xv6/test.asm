
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <ll_count>:
    i += n->data;
    n = n->next;
  }
  printf(1, "total = %d\n", i);
}
void ll_count() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  printf(1, "Count: %d\n", count); 
   6:	a1 d4 0a 00 00       	mov    0xad4,%eax
   b:	c7 44 24 04 2c 0a 00 	movl   $0xa2c,0x4(%esp)
  12:	00 
  13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  1e:	e8 3d 06 00 00       	call   660 <printf>
}
  23:	c9                   	leave  
  24:	c3                   	ret    
  25:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000030 <ll_coolj>:
  while(n != 0) {
    printf(1, "%d\n", n->data);
    n = n->next;
  }
}
void ll_coolj(){
  30:	55                   	push   %ebp
  struct node *n;
  n = head;
  int i = 0;
  while(n != 0) {
  31:	31 d2                	xor    %edx,%edx
  while(n != 0) {
    printf(1, "%d\n", n->data);
    n = n->next;
  }
}
void ll_coolj(){
  33:	89 e5                	mov    %esp,%ebp
  35:	83 ec 18             	sub    $0x18,%esp
  struct node *n;
  n = head;
  38:	a1 e8 0a 00 00       	mov    0xae8,%eax
  int i = 0;
  while(n != 0) {
  3d:	85 c0                	test   %eax,%eax
  3f:	74 10                	je     51 <ll_coolj+0x21>
  41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    i += n->data;
  48:	03 10                	add    (%eax),%edx
    n = n->next;
  4a:	8b 40 04             	mov    0x4(%eax),%eax
}
void ll_coolj(){
  struct node *n;
  n = head;
  int i = 0;
  while(n != 0) {
  4d:	85 c0                	test   %eax,%eax
  4f:	75 f7                	jne    48 <ll_coolj+0x18>
    i += n->data;
    n = n->next;
  }
  printf(1, "total = %d\n", i);
  51:	89 54 24 08          	mov    %edx,0x8(%esp)
  55:	c7 44 24 04 37 0a 00 	movl   $0xa37,0x4(%esp)
  5c:	00 
  5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  64:	e8 f7 05 00 00       	call   660 <printf>
}
  69:	c9                   	leave  
  6a:	c3                   	ret    
  6b:	90                   	nop
  6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000070 <ll_print>:
  }
  printf(1, "c:%d ", count + 1); 
  count++;
}

void ll_print(){
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	53                   	push   %ebx
  74:	83 ec 14             	sub    $0x14,%esp
  struct node *n;
  n = head;
  77:	8b 1d e8 0a 00 00    	mov    0xae8,%ebx
  while(n != 0) {
  7d:	85 db                	test   %ebx,%ebx
  7f:	74 28                	je     a9 <ll_print+0x39>
  81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    printf(1, "%d\n", n->data);
  88:	8b 03                	mov    (%ebx),%eax
  8a:	c7 44 24 04 33 0a 00 	movl   $0xa33,0x4(%esp)
  91:	00 
  92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  99:	89 44 24 08          	mov    %eax,0x8(%esp)
  9d:	e8 be 05 00 00       	call   660 <printf>
    n = n->next;
  a2:	8b 5b 04             	mov    0x4(%ebx),%ebx
}

void ll_print(){
  struct node *n;
  n = head;
  while(n != 0) {
  a5:	85 db                	test   %ebx,%ebx
  a7:	75 df                	jne    88 <ll_print+0x18>
    printf(1, "%d\n", n->data);
    n = n->next;
  }
}
  a9:	83 c4 14             	add    $0x14,%esp
  ac:	5b                   	pop    %ebx
  ad:	5d                   	pop    %ebp
  ae:	c3                   	ret    
  af:	90                   	nop

000000b0 <ll_add>:

struct node *head;
int count = 0;

void
ll_add(int i){
  b0:	55                   	push   %ebp
  b1:	89 e5                	mov    %esp,%ebp
  b3:	83 ec 18             	sub    $0x18,%esp
  struct node *n;
  n = (struct node *)malloc(sizeof(struct node));
  b6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  bd:	e8 3e 08 00 00       	call   900 <malloc>
  n->data = i;
  c2:	8b 55 08             	mov    0x8(%ebp),%edx
  n->next = 0;
  c5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

void
ll_add(int i){
  struct node *n;
  n = (struct node *)malloc(sizeof(struct node));
  n->data = i;
  cc:	89 10                	mov    %edx,(%eax)
  n->next = 0;
  if (head == 0) {
  ce:	8b 15 e8 0a 00 00    	mov    0xae8,%edx
  d4:	85 d2                	test   %edx,%edx
  d6:	74 38                	je     110 <ll_add+0x60>
    head = n;
  } else {
    struct node *curr = head;
/*    printf(1, "i = %d", i);*/
    while(curr->next != 0) {
  d8:	89 d1                	mov    %edx,%ecx
  da:	8b 52 04             	mov    0x4(%edx),%edx
  dd:	85 d2                	test   %edx,%edx
  df:	75 f7                	jne    d8 <ll_add+0x28>
/*      printf(1, "next! i = %d", i);*/
      curr = curr->next;
    }
    curr->next = n;
  e1:	89 41 04             	mov    %eax,0x4(%ecx)
/*    printf(1, "currnext = %d\n", curr->next);*/
	
  }
  printf(1, "c:%d ", count + 1); 
  e4:	a1 d4 0a 00 00       	mov    0xad4,%eax
  e9:	c7 44 24 04 43 0a 00 	movl   $0xa43,0x4(%esp)
  f0:	00 
  f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f8:	83 c0 01             	add    $0x1,%eax
  fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  ff:	e8 5c 05 00 00       	call   660 <printf>
  count++;
 104:	83 05 d4 0a 00 00 01 	addl   $0x1,0xad4
}
 10b:	c9                   	leave  
 10c:	c3                   	ret    
 10d:	8d 76 00             	lea    0x0(%esi),%esi
  struct node *n;
  n = (struct node *)malloc(sizeof(struct node));
  n->data = i;
  n->next = 0;
  if (head == 0) {
    head = n;
 110:	a3 e8 0a 00 00       	mov    %eax,0xae8
 115:	eb cd                	jmp    e4 <ll_add+0x34>
 117:	89 f6                	mov    %esi,%esi
 119:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000120 <thread_create>:
	lock_release(&t);
  }
}

void thread_create(void *(*start_routine)(void*), void *arg)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	83 ec 18             	sub    $0x18,%esp
 126:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 129:	8b 5d 08             	mov    0x8(%ebp),%ebx
 12c:	89 75 fc             	mov    %esi,-0x4(%ebp)
 12f:	8b 75 0c             	mov    0xc(%ebp),%esi
//   Possibly need to lock around creating the stack and calling clone
//   lock_acquire(&t);
  char* stack = malloc(4096);
 132:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
 139:	e8 c2 07 00 00       	call   900 <malloc>
  clone(stack, 4096);
 13e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
 145:	00 
 146:	89 04 24             	mov    %eax,(%esp)
 149:	e8 6a 04 00 00       	call   5b8 <clone>
//   lock_release(&t);
  (*start_routine)(arg);
 14e:	89 da                	mov    %ebx,%edx
  
  return;
}
 150:	8b 5d f8             	mov    -0x8(%ebp),%ebx
//   Possibly need to lock around creating the stack and calling clone
//   lock_acquire(&t);
  char* stack = malloc(4096);
  clone(stack, 4096);
//   lock_release(&t);
  (*start_routine)(arg);
 153:	89 75 08             	mov    %esi,0x8(%ebp)
  
  return;
}
 156:	8b 75 fc             	mov    -0x4(%ebp),%esi
 159:	89 ec                	mov    %ebp,%esp
 15b:	5d                   	pop    %ebp
//   Possibly need to lock around creating the stack and calling clone
//   lock_acquire(&t);
  char* stack = malloc(4096);
  clone(stack, 4096);
//   lock_release(&t);
  (*start_routine)(arg);
 15c:	ff e2                	jmp    *%edx
 15e:	66 90                	xchg   %ax,%ax

00000160 <main>:
  return;
}
/*  printf(1, "Clone returns = %d\n", rc);*/

int
main (int argc, char* argv[]) {
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	83 e4 f0             	and    $0xfffffff0,%esp
 166:	83 ec 30             	sub    $0x30,%esp
/*  printf(1, "Beginning Test\n");*/
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
  if (argc != 3 || atoi(argv[1]) < 1 || atoi(argv[2]) < 1) {
 169:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
  return;
}
/*  printf(1, "Clone returns = %d\n", rc);*/

int
main (int argc, char* argv[]) {
 16d:	89 5c 24 24          	mov    %ebx,0x24(%esp)
 171:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 174:	89 74 24 28          	mov    %esi,0x28(%esp)
 178:	89 7c 24 2c          	mov    %edi,0x2c(%esp)
/*  printf(1, "Beginning Test\n");*/
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
  if (argc != 3 || atoi(argv[1]) < 1 || atoi(argv[2]) < 1) {
 17c:	74 1a                	je     198 <main+0x38>
	printf(1, "Usage: test numberOfThreads numberOfRuns\n");
 17e:	c7 44 24 04 90 0a 00 	movl   $0xa90,0x4(%esp)
 185:	00 
 186:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18d:	e8 ce 04 00 00       	call   660 <printf>
	exit();
 192:	e8 81 03 00 00       	call   518 <exit>
 197:	90                   	nop
main (int argc, char* argv[]) {
/*  printf(1, "Beginning Test\n");*/
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
  if (argc != 3 || atoi(argv[1]) < 1 || atoi(argv[2]) < 1) {
 198:	8b 43 04             	mov    0x4(%ebx),%eax
 19b:	89 04 24             	mov    %eax,(%esp)
 19e:	e8 4d 02 00 00       	call   3f0 <atoi>
 1a3:	85 c0                	test   %eax,%eax
 1a5:	7e d7                	jle    17e <main+0x1e>
 1a7:	8b 43 08             	mov    0x8(%ebx),%eax
 1aa:	8d 7b 08             	lea    0x8(%ebx),%edi
 1ad:	89 04 24             	mov    %eax,(%esp)
 1b0:	e8 3b 02 00 00       	call   3f0 <atoi>
 1b5:	85 c0                	test   %eax,%eax
 1b7:	7e c5                	jle    17e <main+0x1e>
	printf(1, "Usage: test numberOfThreads numberOfRuns\n");
	exit();
  }
  int threads = atoi(argv[1]);
 1b9:	8b 43 04             	mov    0x4(%ebx),%eax
 1bc:	89 04 24             	mov    %eax,(%esp)
 1bf:	e8 2c 02 00 00       	call   3f0 <atoi>
  lock_init(&t);
 1c4:	c7 04 24 e4 0a 00 00 	movl   $0xae4,(%esp)
//   lock_acquire(&lock);
  if (argc != 3 || atoi(argv[1]) < 1 || atoi(argv[2]) < 1) {
	printf(1, "Usage: test numberOfThreads numberOfRuns\n");
	exit();
  }
  int threads = atoi(argv[1]);
 1cb:	89 c6                	mov    %eax,%esi
  lock_init(&t);
 1cd:	e8 0e 08 00 00       	call   9e0 <lock_init>
  int parent = getpid();
 1d2:	e8 c1 03 00 00       	call   598 <getpid>
/*  printf(1, "stack outside %d\n", stack[0]);*/
  void (*fnc)(int);
  fnc = &update;
  
  int i;
  for (i = 0; i < threads; i++) {
 1d7:	85 f6                	test   %esi,%esi
	printf(1, "Usage: test numberOfThreads numberOfRuns\n");
	exit();
  }
  int threads = atoi(argv[1]);
  lock_init(&t);
  int parent = getpid();
 1d9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
/*  printf(1, "stack outside %d\n", stack[0]);*/
  void (*fnc)(int);
  fnc = &update;
  
  int i;
  for (i = 0; i < threads; i++) {
 1dd:	7e 2a                	jle    209 <main+0xa9>
 1df:	31 db                	xor    %ebx,%ebx
 1e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
	thread_create((void*)fnc, (int*)atoi(argv[2]));
 1e8:	8b 07                	mov    (%edi),%eax
/*  printf(1, "stack outside %d\n", stack[0]);*/
  void (*fnc)(int);
  fnc = &update;
  
  int i;
  for (i = 0; i < threads; i++) {
 1ea:	83 c3 01             	add    $0x1,%ebx
	thread_create((void*)fnc, (int*)atoi(argv[2]));
 1ed:	89 04 24             	mov    %eax,(%esp)
 1f0:	e8 fb 01 00 00       	call   3f0 <atoi>
 1f5:	c7 04 24 70 02 00 00 	movl   $0x270,(%esp)
 1fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 200:	e8 1b ff ff ff       	call   120 <thread_create>
/*  printf(1, "stack outside %d\n", stack[0]);*/
  void (*fnc)(int);
  fnc = &update;
  
  int i;
  for (i = 0; i < threads; i++) {
 205:	39 de                	cmp    %ebx,%esi
 207:	7f df                	jg     1e8 <main+0x88>
	thread_create((void*)fnc, (int*)atoi(argv[2]));
  }
   
  int pid = getpid();
 209:	e8 8a 03 00 00       	call   598 <getpid>
  if (pid == parent) {
 20e:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  int i;
  for (i = 0; i < threads; i++) {
	thread_create((void*)fnc, (int*)atoi(argv[2]));
  }
   
  int pid = getpid();
 212:	89 c7                	mov    %eax,%edi
  if (pid == parent) {
 214:	74 22                	je     238 <main+0xd8>
	  printf(1, "wait returned %d\n", ret);
	}	
	ll_count();
  }

  printf(1, "pid: %d exiting\n", pid);
 216:	89 7c 24 08          	mov    %edi,0x8(%esp)
 21a:	c7 44 24 04 5b 0a 00 	movl   $0xa5b,0x4(%esp)
 221:	00 
 222:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 229:	e8 32 04 00 00       	call   660 <printf>
  
  //Prints out the final count
  exit();
 22e:	e8 e5 02 00 00       	call   518 <exit>
 233:	90                   	nop
 234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }
   
  int pid = getpid();
  if (pid == parent) {
	int ret = 0;
	for (i = 0; i < threads; i++) {
 238:	85 f6                	test   %esi,%esi
 23a:	7e 28                	jle    264 <main+0x104>
 23c:	31 db                	xor    %ebx,%ebx
 23e:	66 90                	xchg   %ax,%ax
	  ret = wait();
 240:	e8 db 02 00 00       	call   520 <wait>
  }
   
  int pid = getpid();
  if (pid == parent) {
	int ret = 0;
	for (i = 0; i < threads; i++) {
 245:	83 c3 01             	add    $0x1,%ebx
	  ret = wait();
	  printf(1, "wait returned %d\n", ret);
 248:	c7 44 24 04 49 0a 00 	movl   $0xa49,0x4(%esp)
 24f:	00 
 250:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 257:	89 44 24 08          	mov    %eax,0x8(%esp)
 25b:	e8 00 04 00 00       	call   660 <printf>
  }
   
  int pid = getpid();
  if (pid == parent) {
	int ret = 0;
	for (i = 0; i < threads; i++) {
 260:	39 de                	cmp    %ebx,%esi
 262:	7f dc                	jg     240 <main+0xe0>
	  ret = wait();
	  printf(1, "wait returned %d\n", ret);
	}	
	ll_count();
 264:	e8 97 fd ff ff       	call   0 <ll_count>
 269:	eb ab                	jmp    216 <main+0xb6>
 26b:	90                   	nop
 26c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000270 <update>:
#include "linkedlist.h"
#include "thread.h"

struct lock_t t;

void update(int runs) {
 270:	55                   	push   %ebp
 271:	89 e5                	mov    %esp,%ebp
 273:	56                   	push   %esi
 274:	53                   	push   %ebx
 275:	83 ec 10             	sub    $0x10,%esp
 278:	8b 5d 08             	mov    0x8(%ebp),%ebx
  printf(1, "runs = %d\n", runs);
 27b:	c7 44 24 04 6c 0a 00 	movl   $0xa6c,0x4(%esp)
 282:	00 
 283:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 28a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 28e:	e8 cd 03 00 00       	call   660 <printf>
  int pid = getpid();
 293:	e8 00 03 00 00       	call   598 <getpid>
  printf(1, "pid %d starting update\n", pid);
 298:	c7 44 24 04 77 0a 00 	movl   $0xa77,0x4(%esp)
 29f:	00 
 2a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2a7:	89 44 24 08          	mov    %eax,0x8(%esp)
 2ab:	e8 b0 03 00 00       	call   660 <printf>
  int i;
  for (i = 0; i < runs; i++) {
 2b0:	85 db                	test   %ebx,%ebx
 2b2:	7e 2b                	jle    2df <update+0x6f>
 2b4:	31 f6                	xor    %esi,%esi
 2b6:	66 90                	xchg   %ax,%ax
	lock_acquire(&t);
 2b8:	c7 04 24 e4 0a 00 00 	movl   $0xae4,(%esp)
 2bf:	e8 2c 07 00 00       	call   9f0 <lock_acquire>
    ll_add(i);
 2c4:	89 34 24             	mov    %esi,(%esp)
void update(int runs) {
  printf(1, "runs = %d\n", runs);
  int pid = getpid();
  printf(1, "pid %d starting update\n", pid);
  int i;
  for (i = 0; i < runs; i++) {
 2c7:	83 c6 01             	add    $0x1,%esi
	lock_acquire(&t);
    ll_add(i);
 2ca:	e8 e1 fd ff ff       	call   b0 <ll_add>
	lock_release(&t);
 2cf:	c7 04 24 e4 0a 00 00 	movl   $0xae4,(%esp)
 2d6:	e8 35 07 00 00       	call   a10 <lock_release>
void update(int runs) {
  printf(1, "runs = %d\n", runs);
  int pid = getpid();
  printf(1, "pid %d starting update\n", pid);
  int i;
  for (i = 0; i < runs; i++) {
 2db:	39 f3                	cmp    %esi,%ebx
 2dd:	7f d9                	jg     2b8 <update+0x48>
	lock_acquire(&t);
    ll_add(i);
	lock_release(&t);
  }
}
 2df:	83 c4 10             	add    $0x10,%esp
 2e2:	5b                   	pop    %ebx
 2e3:	5e                   	pop    %esi
 2e4:	5d                   	pop    %ebp
 2e5:	c3                   	ret    
 2e6:	90                   	nop
 2e7:	90                   	nop
 2e8:	90                   	nop
 2e9:	90                   	nop
 2ea:	90                   	nop
 2eb:	90                   	nop
 2ec:	90                   	nop
 2ed:	90                   	nop
 2ee:	90                   	nop
 2ef:	90                   	nop

000002f0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2f0:	55                   	push   %ebp
 2f1:	31 d2                	xor    %edx,%edx
 2f3:	89 e5                	mov    %esp,%ebp
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	53                   	push   %ebx
 2f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 300:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 304:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 307:	83 c2 01             	add    $0x1,%edx
 30a:	84 c9                	test   %cl,%cl
 30c:	75 f2                	jne    300 <strcpy+0x10>
    ;
  return os;
}
 30e:	5b                   	pop    %ebx
 30f:	5d                   	pop    %ebp
 310:	c3                   	ret    
 311:	eb 0d                	jmp    320 <strcmp>
 313:	90                   	nop
 314:	90                   	nop
 315:	90                   	nop
 316:	90                   	nop
 317:	90                   	nop
 318:	90                   	nop
 319:	90                   	nop
 31a:	90                   	nop
 31b:	90                   	nop
 31c:	90                   	nop
 31d:	90                   	nop
 31e:	90                   	nop
 31f:	90                   	nop

00000320 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	53                   	push   %ebx
 324:	8b 4d 08             	mov    0x8(%ebp),%ecx
 327:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 32a:	0f b6 01             	movzbl (%ecx),%eax
 32d:	84 c0                	test   %al,%al
 32f:	75 14                	jne    345 <strcmp+0x25>
 331:	eb 25                	jmp    358 <strcmp+0x38>
 333:	90                   	nop
 334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
 338:	83 c1 01             	add    $0x1,%ecx
 33b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 33e:	0f b6 01             	movzbl (%ecx),%eax
 341:	84 c0                	test   %al,%al
 343:	74 13                	je     358 <strcmp+0x38>
 345:	0f b6 1a             	movzbl (%edx),%ebx
 348:	38 d8                	cmp    %bl,%al
 34a:	74 ec                	je     338 <strcmp+0x18>
 34c:	0f b6 db             	movzbl %bl,%ebx
 34f:	0f b6 c0             	movzbl %al,%eax
 352:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 354:	5b                   	pop    %ebx
 355:	5d                   	pop    %ebp
 356:	c3                   	ret    
 357:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 358:	0f b6 1a             	movzbl (%edx),%ebx
 35b:	31 c0                	xor    %eax,%eax
 35d:	0f b6 db             	movzbl %bl,%ebx
 360:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 362:	5b                   	pop    %ebx
 363:	5d                   	pop    %ebp
 364:	c3                   	ret    
 365:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000370 <strlen>:

uint
strlen(char *s)
{
 370:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
 371:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 373:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
 375:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 377:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 37a:	80 39 00             	cmpb   $0x0,(%ecx)
 37d:	74 0c                	je     38b <strlen+0x1b>
 37f:	90                   	nop
 380:	83 c2 01             	add    $0x1,%edx
 383:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 387:	89 d0                	mov    %edx,%eax
 389:	75 f5                	jne    380 <strlen+0x10>
    ;
  return n;
}
 38b:	5d                   	pop    %ebp
 38c:	c3                   	ret    
 38d:	8d 76 00             	lea    0x0(%esi),%esi

00000390 <memset>:

void*
memset(void *dst, int c, uint n)
{
 390:	55                   	push   %ebp
 391:	89 e5                	mov    %esp,%ebp
 393:	8b 55 08             	mov    0x8(%ebp),%edx
 396:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 397:	8b 4d 10             	mov    0x10(%ebp),%ecx
 39a:	8b 45 0c             	mov    0xc(%ebp),%eax
 39d:	89 d7                	mov    %edx,%edi
 39f:	fc                   	cld    
 3a0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 3a2:	89 d0                	mov    %edx,%eax
 3a4:	5f                   	pop    %edi
 3a5:	5d                   	pop    %ebp
 3a6:	c3                   	ret    
 3a7:	89 f6                	mov    %esi,%esi
 3a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000003b0 <strchr>:

char*
strchr(const char *s, char c)
{
 3b0:	55                   	push   %ebp
 3b1:	89 e5                	mov    %esp,%ebp
 3b3:	8b 45 08             	mov    0x8(%ebp),%eax
 3b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 3ba:	0f b6 10             	movzbl (%eax),%edx
 3bd:	84 d2                	test   %dl,%dl
 3bf:	75 11                	jne    3d2 <strchr+0x22>
 3c1:	eb 15                	jmp    3d8 <strchr+0x28>
 3c3:	90                   	nop
 3c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 3c8:	83 c0 01             	add    $0x1,%eax
 3cb:	0f b6 10             	movzbl (%eax),%edx
 3ce:	84 d2                	test   %dl,%dl
 3d0:	74 06                	je     3d8 <strchr+0x28>
    if(*s == c)
 3d2:	38 ca                	cmp    %cl,%dl
 3d4:	75 f2                	jne    3c8 <strchr+0x18>
      return (char*)s;
  return 0;
}
 3d6:	5d                   	pop    %ebp
 3d7:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3d8:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 3da:	5d                   	pop    %ebp
 3db:	90                   	nop
 3dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 3e0:	c3                   	ret    
 3e1:	eb 0d                	jmp    3f0 <atoi>
 3e3:	90                   	nop
 3e4:	90                   	nop
 3e5:	90                   	nop
 3e6:	90                   	nop
 3e7:	90                   	nop
 3e8:	90                   	nop
 3e9:	90                   	nop
 3ea:	90                   	nop
 3eb:	90                   	nop
 3ec:	90                   	nop
 3ed:	90                   	nop
 3ee:	90                   	nop
 3ef:	90                   	nop

000003f0 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 3f0:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f1:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 3f3:	89 e5                	mov    %esp,%ebp
 3f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3f8:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f9:	0f b6 11             	movzbl (%ecx),%edx
 3fc:	8d 5a d0             	lea    -0x30(%edx),%ebx
 3ff:	80 fb 09             	cmp    $0x9,%bl
 402:	77 1c                	ja     420 <atoi+0x30>
 404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 408:	0f be d2             	movsbl %dl,%edx
 40b:	83 c1 01             	add    $0x1,%ecx
 40e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 411:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 415:	0f b6 11             	movzbl (%ecx),%edx
 418:	8d 5a d0             	lea    -0x30(%edx),%ebx
 41b:	80 fb 09             	cmp    $0x9,%bl
 41e:	76 e8                	jbe    408 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 420:	5b                   	pop    %ebx
 421:	5d                   	pop    %ebp
 422:	c3                   	ret    
 423:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 429:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000430 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 430:	55                   	push   %ebp
 431:	89 e5                	mov    %esp,%ebp
 433:	56                   	push   %esi
 434:	8b 45 08             	mov    0x8(%ebp),%eax
 437:	53                   	push   %ebx
 438:	8b 5d 10             	mov    0x10(%ebp),%ebx
 43b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 43e:	85 db                	test   %ebx,%ebx
 440:	7e 14                	jle    456 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
 442:	31 d2                	xor    %edx,%edx
 444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 448:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 44c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 44f:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 452:	39 da                	cmp    %ebx,%edx
 454:	75 f2                	jne    448 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 456:	5b                   	pop    %ebx
 457:	5e                   	pop    %esi
 458:	5d                   	pop    %ebp
 459:	c3                   	ret    
 45a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000460 <stat>:
  return buf;
}

int
stat(char *n, struct stat *st)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 466:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(char *n, struct stat *st)
{
 469:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 46c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 46f:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 474:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 47b:	00 
 47c:	89 04 24             	mov    %eax,(%esp)
 47f:	e8 d4 00 00 00       	call   558 <open>
  if(fd < 0)
 484:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 486:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 488:	78 19                	js     4a3 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 48a:	8b 45 0c             	mov    0xc(%ebp),%eax
 48d:	89 1c 24             	mov    %ebx,(%esp)
 490:	89 44 24 04          	mov    %eax,0x4(%esp)
 494:	e8 d7 00 00 00       	call   570 <fstat>
  close(fd);
 499:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 49c:	89 c6                	mov    %eax,%esi
  close(fd);
 49e:	e8 9d 00 00 00       	call   540 <close>
  return r;
}
 4a3:	89 f0                	mov    %esi,%eax
 4a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 4a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
 4ab:	89 ec                	mov    %ebp,%esp
 4ad:	5d                   	pop    %ebp
 4ae:	c3                   	ret    
 4af:	90                   	nop

000004b0 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	57                   	push   %edi
 4b4:	56                   	push   %esi
 4b5:	31 f6                	xor    %esi,%esi
 4b7:	53                   	push   %ebx
 4b8:	83 ec 2c             	sub    $0x2c,%esp
 4bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4be:	eb 06                	jmp    4c6 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 4c0:	3c 0a                	cmp    $0xa,%al
 4c2:	74 39                	je     4fd <gets+0x4d>
 4c4:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4c6:	8d 5e 01             	lea    0x1(%esi),%ebx
 4c9:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 4cc:	7d 31                	jge    4ff <gets+0x4f>
    cc = read(0, &c, 1);
 4ce:	8d 45 e7             	lea    -0x19(%ebp),%eax
 4d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4d8:	00 
 4d9:	89 44 24 04          	mov    %eax,0x4(%esp)
 4dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4e4:	e8 47 00 00 00       	call   530 <read>
    if(cc < 1)
 4e9:	85 c0                	test   %eax,%eax
 4eb:	7e 12                	jle    4ff <gets+0x4f>
      break;
    buf[i++] = c;
 4ed:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 4f1:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 4f5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 4f9:	3c 0d                	cmp    $0xd,%al
 4fb:	75 c3                	jne    4c0 <gets+0x10>
 4fd:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 4ff:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 503:	89 f8                	mov    %edi,%eax
 505:	83 c4 2c             	add    $0x2c,%esp
 508:	5b                   	pop    %ebx
 509:	5e                   	pop    %esi
 50a:	5f                   	pop    %edi
 50b:	5d                   	pop    %ebp
 50c:	c3                   	ret    
 50d:	90                   	nop
 50e:	90                   	nop
 50f:	90                   	nop

00000510 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 510:	b8 01 00 00 00       	mov    $0x1,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <exit>:
SYSCALL(exit)
 518:	b8 02 00 00 00       	mov    $0x2,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <wait>:
SYSCALL(wait)
 520:	b8 03 00 00 00       	mov    $0x3,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <pipe>:
SYSCALL(pipe)
 528:	b8 04 00 00 00       	mov    $0x4,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <read>:
SYSCALL(read)
 530:	b8 06 00 00 00       	mov    $0x6,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <write>:
SYSCALL(write)
 538:	b8 05 00 00 00       	mov    $0x5,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <close>:
SYSCALL(close)
 540:	b8 07 00 00 00       	mov    $0x7,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <kill>:
SYSCALL(kill)
 548:	b8 08 00 00 00       	mov    $0x8,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <exec>:
SYSCALL(exec)
 550:	b8 09 00 00 00       	mov    $0x9,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <open>:
SYSCALL(open)
 558:	b8 0a 00 00 00       	mov    $0xa,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <mknod>:
SYSCALL(mknod)
 560:	b8 0b 00 00 00       	mov    $0xb,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <unlink>:
SYSCALL(unlink)
 568:	b8 0c 00 00 00       	mov    $0xc,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <fstat>:
SYSCALL(fstat)
 570:	b8 0d 00 00 00       	mov    $0xd,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <link>:
SYSCALL(link)
 578:	b8 0e 00 00 00       	mov    $0xe,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <mkdir>:
SYSCALL(mkdir)
 580:	b8 0f 00 00 00       	mov    $0xf,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <chdir>:
SYSCALL(chdir)
 588:	b8 10 00 00 00       	mov    $0x10,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <dup>:
SYSCALL(dup)
 590:	b8 11 00 00 00       	mov    $0x11,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <getpid>:
SYSCALL(getpid)
 598:	b8 12 00 00 00       	mov    $0x12,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <sbrk>:
SYSCALL(sbrk)
 5a0:	b8 13 00 00 00       	mov    $0x13,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <sleep>:
SYSCALL(sleep)
 5a8:	b8 14 00 00 00       	mov    $0x14,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <uptime>:
SYSCALL(uptime)
 5b0:	b8 15 00 00 00       	mov    $0x15,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <clone>:
SYSCALL(clone)
 5b8:	b8 16 00 00 00       	mov    $0x16,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 5c0:	55                   	push   %ebp
 5c1:	89 e5                	mov    %esp,%ebp
 5c3:	57                   	push   %edi
 5c4:	89 cf                	mov    %ecx,%edi
 5c6:	56                   	push   %esi
 5c7:	89 c6                	mov    %eax,%esi
 5c9:	53                   	push   %ebx
 5ca:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5d0:	85 c9                	test   %ecx,%ecx
 5d2:	74 04                	je     5d8 <printint+0x18>
 5d4:	85 d2                	test   %edx,%edx
 5d6:	78 70                	js     648 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5d8:	89 d0                	mov    %edx,%eax
 5da:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 5e1:	31 c9                	xor    %ecx,%ecx
 5e3:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 5e6:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 5e8:	31 d2                	xor    %edx,%edx
 5ea:	f7 f7                	div    %edi
 5ec:	0f b6 92 c3 0a 00 00 	movzbl 0xac3(%edx),%edx
 5f3:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 5f6:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 5f9:	85 c0                	test   %eax,%eax
 5fb:	75 eb                	jne    5e8 <printint+0x28>
  if(neg)
 5fd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 600:	85 c0                	test   %eax,%eax
 602:	74 08                	je     60c <printint+0x4c>
    buf[i++] = '-';
 604:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 609:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 60c:	8d 79 ff             	lea    -0x1(%ecx),%edi
 60f:	01 fb                	add    %edi,%ebx
 611:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 618:	0f b6 03             	movzbl (%ebx),%eax
 61b:	83 ef 01             	sub    $0x1,%edi
 61e:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 621:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 628:	00 
 629:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 62c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 62f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 632:	89 44 24 04          	mov    %eax,0x4(%esp)
 636:	e8 fd fe ff ff       	call   538 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 63b:	83 ff ff             	cmp    $0xffffffff,%edi
 63e:	75 d8                	jne    618 <printint+0x58>
    putc(fd, buf[i]);
}
 640:	83 c4 4c             	add    $0x4c,%esp
 643:	5b                   	pop    %ebx
 644:	5e                   	pop    %esi
 645:	5f                   	pop    %edi
 646:	5d                   	pop    %ebp
 647:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 648:	89 d0                	mov    %edx,%eax
 64a:	f7 d8                	neg    %eax
 64c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 653:	eb 8c                	jmp    5e1 <printint+0x21>
 655:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 659:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000660 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 660:	55                   	push   %ebp
 661:	89 e5                	mov    %esp,%ebp
 663:	57                   	push   %edi
 664:	56                   	push   %esi
 665:	53                   	push   %ebx
 666:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 669:	8b 45 0c             	mov    0xc(%ebp),%eax
 66c:	0f b6 10             	movzbl (%eax),%edx
 66f:	84 d2                	test   %dl,%dl
 671:	0f 84 c9 00 00 00    	je     740 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 677:	8d 4d 10             	lea    0x10(%ebp),%ecx
 67a:	31 ff                	xor    %edi,%edi
 67c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 67f:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 681:	8d 75 e7             	lea    -0x19(%ebp),%esi
 684:	eb 1e                	jmp    6a4 <printf+0x44>
 686:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 688:	83 fa 25             	cmp    $0x25,%edx
 68b:	0f 85 b7 00 00 00    	jne    748 <printf+0xe8>
 691:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 695:	83 c3 01             	add    $0x1,%ebx
 698:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 69c:	84 d2                	test   %dl,%dl
 69e:	0f 84 9c 00 00 00    	je     740 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 6a4:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 6a6:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 6a9:	74 dd                	je     688 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6ab:	83 ff 25             	cmp    $0x25,%edi
 6ae:	75 e5                	jne    695 <printf+0x35>
      if(c == 'd'){
 6b0:	83 fa 64             	cmp    $0x64,%edx
 6b3:	0f 84 57 01 00 00    	je     810 <printf+0x1b0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 6b9:	83 fa 70             	cmp    $0x70,%edx
 6bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 6c0:	0f 84 aa 00 00 00    	je     770 <printf+0x110>
 6c6:	83 fa 78             	cmp    $0x78,%edx
 6c9:	0f 84 a1 00 00 00    	je     770 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 6cf:	83 fa 73             	cmp    $0x73,%edx
 6d2:	0f 84 c0 00 00 00    	je     798 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6d8:	83 fa 63             	cmp    $0x63,%edx
 6db:	90                   	nop
 6dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 6e0:	0f 84 52 01 00 00    	je     838 <printf+0x1d8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 6e6:	83 fa 25             	cmp    $0x25,%edx
 6e9:	0f 84 f9 00 00 00    	je     7e8 <printf+0x188>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6f2:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6f5:	31 ff                	xor    %edi,%edi
 6f7:	89 55 cc             	mov    %edx,-0x34(%ebp)
 6fa:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 6fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 705:	00 
 706:	89 0c 24             	mov    %ecx,(%esp)
 709:	89 74 24 04          	mov    %esi,0x4(%esp)
 70d:	e8 26 fe ff ff       	call   538 <write>
 712:	8b 55 cc             	mov    -0x34(%ebp),%edx
 715:	8b 45 08             	mov    0x8(%ebp),%eax
 718:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 71f:	00 
 720:	89 74 24 04          	mov    %esi,0x4(%esp)
 724:	88 55 e7             	mov    %dl,-0x19(%ebp)
 727:	89 04 24             	mov    %eax,(%esp)
 72a:	e8 09 fe ff ff       	call   538 <write>
 72f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 732:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 736:	84 d2                	test   %dl,%dl
 738:	0f 85 66 ff ff ff    	jne    6a4 <printf+0x44>
 73e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 740:	83 c4 3c             	add    $0x3c,%esp
 743:	5b                   	pop    %ebx
 744:	5e                   	pop    %esi
 745:	5f                   	pop    %edi
 746:	5d                   	pop    %ebp
 747:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 748:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 74b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 74e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 755:	00 
 756:	89 74 24 04          	mov    %esi,0x4(%esp)
 75a:	89 04 24             	mov    %eax,(%esp)
 75d:	e8 d6 fd ff ff       	call   538 <write>
 762:	8b 45 0c             	mov    0xc(%ebp),%eax
 765:	e9 2b ff ff ff       	jmp    695 <printf+0x35>
 76a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 770:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 773:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 778:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 77a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 781:	8b 10                	mov    (%eax),%edx
 783:	8b 45 08             	mov    0x8(%ebp),%eax
 786:	e8 35 fe ff ff       	call   5c0 <printint>
 78b:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 78e:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 792:	e9 fe fe ff ff       	jmp    695 <printf+0x35>
 797:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 798:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 79b:	8b 3a                	mov    (%edx),%edi
        ap++;
 79d:	83 c2 04             	add    $0x4,%edx
 7a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 7a3:	85 ff                	test   %edi,%edi
 7a5:	0f 84 ba 00 00 00    	je     865 <printf+0x205>
          s = "(null)";
        while(*s != 0){
 7ab:	0f b6 17             	movzbl (%edi),%edx
 7ae:	84 d2                	test   %dl,%dl
 7b0:	74 2d                	je     7df <printf+0x17f>
 7b2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 7b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
          putc(fd, *s);
          s++;
 7b8:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7bb:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 7be:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7c5:	00 
 7c6:	89 74 24 04          	mov    %esi,0x4(%esp)
 7ca:	89 1c 24             	mov    %ebx,(%esp)
 7cd:	e8 66 fd ff ff       	call   538 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7d2:	0f b6 17             	movzbl (%edi),%edx
 7d5:	84 d2                	test   %dl,%dl
 7d7:	75 df                	jne    7b8 <printf+0x158>
 7d9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 7dc:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 7df:	31 ff                	xor    %edi,%edi
 7e1:	e9 af fe ff ff       	jmp    695 <printf+0x35>
 7e6:	66 90                	xchg   %ax,%ax
 7e8:	8b 55 08             	mov    0x8(%ebp),%edx
 7eb:	31 ff                	xor    %edi,%edi
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 7ed:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 7f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7f8:	00 
 7f9:	89 74 24 04          	mov    %esi,0x4(%esp)
 7fd:	89 14 24             	mov    %edx,(%esp)
 800:	e8 33 fd ff ff       	call   538 <write>
 805:	8b 45 0c             	mov    0xc(%ebp),%eax
 808:	e9 88 fe ff ff       	jmp    695 <printf+0x35>
 80d:	8d 76 00             	lea    0x0(%esi),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 810:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 813:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 818:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 81b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 822:	8b 10                	mov    (%eax),%edx
 824:	8b 45 08             	mov    0x8(%ebp),%eax
 827:	e8 94 fd ff ff       	call   5c0 <printint>
 82c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 82f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 833:	e9 5d fe ff ff       	jmp    695 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 838:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
        putc(fd, *ap);
        ap++;
 83b:	31 ff                	xor    %edi,%edi
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 83d:	8b 01                	mov    (%ecx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 83f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 846:	00 
 847:	89 74 24 04          	mov    %esi,0x4(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 84b:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 84e:	8b 45 08             	mov    0x8(%ebp),%eax
 851:	89 04 24             	mov    %eax,(%esp)
 854:	e8 df fc ff ff       	call   538 <write>
 859:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 85c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 860:	e9 30 fe ff ff       	jmp    695 <printf+0x35>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
 865:	bf bc 0a 00 00       	mov    $0xabc,%edi
 86a:	e9 3c ff ff ff       	jmp    7ab <printf+0x14b>
 86f:	90                   	nop

00000870 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 870:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 871:	a1 e0 0a 00 00       	mov    0xae0,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 876:	89 e5                	mov    %esp,%ebp
 878:	57                   	push   %edi
 879:	56                   	push   %esi
 87a:	53                   	push   %ebx
 87b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 881:	39 c8                	cmp    %ecx,%eax
 883:	73 1d                	jae    8a2 <free+0x32>
 885:	8d 76 00             	lea    0x0(%esi),%esi
 888:	8b 10                	mov    (%eax),%edx
 88a:	39 d1                	cmp    %edx,%ecx
 88c:	72 1a                	jb     8a8 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88e:	39 d0                	cmp    %edx,%eax
 890:	72 08                	jb     89a <free+0x2a>
 892:	39 c8                	cmp    %ecx,%eax
 894:	72 12                	jb     8a8 <free+0x38>
 896:	39 d1                	cmp    %edx,%ecx
 898:	72 0e                	jb     8a8 <free+0x38>
 89a:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89c:	39 c8                	cmp    %ecx,%eax
 89e:	66 90                	xchg   %ax,%ax
 8a0:	72 e6                	jb     888 <free+0x18>
 8a2:	8b 10                	mov    (%eax),%edx
 8a4:	eb e8                	jmp    88e <free+0x1e>
 8a6:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8a8:	8b 71 04             	mov    0x4(%ecx),%esi
 8ab:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 8ae:	39 d7                	cmp    %edx,%edi
 8b0:	74 19                	je     8cb <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 8b2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 8b5:	8b 50 04             	mov    0x4(%eax),%edx
 8b8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 8bb:	39 ce                	cmp    %ecx,%esi
 8bd:	74 23                	je     8e2 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 8bf:	89 08                	mov    %ecx,(%eax)
  freep = p;
 8c1:	a3 e0 0a 00 00       	mov    %eax,0xae0
}
 8c6:	5b                   	pop    %ebx
 8c7:	5e                   	pop    %esi
 8c8:	5f                   	pop    %edi
 8c9:	5d                   	pop    %ebp
 8ca:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8cb:	03 72 04             	add    0x4(%edx),%esi
 8ce:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 8d1:	8b 10                	mov    (%eax),%edx
 8d3:	8b 12                	mov    (%edx),%edx
 8d5:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8d8:	8b 50 04             	mov    0x4(%eax),%edx
 8db:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 8de:	39 ce                	cmp    %ecx,%esi
 8e0:	75 dd                	jne    8bf <free+0x4f>
    p->s.size += bp->s.size;
 8e2:	03 51 04             	add    0x4(%ecx),%edx
 8e5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8e8:	8b 53 f8             	mov    -0x8(%ebx),%edx
 8eb:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 8ed:	a3 e0 0a 00 00       	mov    %eax,0xae0
}
 8f2:	5b                   	pop    %ebx
 8f3:	5e                   	pop    %esi
 8f4:	5f                   	pop    %edi
 8f5:	5d                   	pop    %ebp
 8f6:	c3                   	ret    
 8f7:	89 f6                	mov    %esi,%esi
 8f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000900 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 900:	55                   	push   %ebp
 901:	89 e5                	mov    %esp,%ebp
 903:	57                   	push   %edi
 904:	56                   	push   %esi
 905:	53                   	push   %ebx
 906:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 909:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 90c:	8b 0d e0 0a 00 00    	mov    0xae0,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 912:	83 c3 07             	add    $0x7,%ebx
 915:	c1 eb 03             	shr    $0x3,%ebx
 918:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 91b:	85 c9                	test   %ecx,%ecx
 91d:	0f 84 93 00 00 00    	je     9b6 <malloc+0xb6>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 923:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 925:	8b 50 04             	mov    0x4(%eax),%edx
 928:	39 d3                	cmp    %edx,%ebx
 92a:	76 1f                	jbe    94b <malloc+0x4b>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 92c:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 933:	90                   	nop
 934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
    if(p == freep)
 938:	3b 05 e0 0a 00 00    	cmp    0xae0,%eax
 93e:	74 30                	je     970 <malloc+0x70>
 940:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 942:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 944:	8b 50 04             	mov    0x4(%eax),%edx
 947:	39 d3                	cmp    %edx,%ebx
 949:	77 ed                	ja     938 <malloc+0x38>
      if(p->s.size == nunits)
 94b:	39 d3                	cmp    %edx,%ebx
 94d:	74 61                	je     9b0 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 94f:	29 da                	sub    %ebx,%edx
 951:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 954:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 957:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 95a:	89 0d e0 0a 00 00    	mov    %ecx,0xae0
      return (void*)(p + 1);
 960:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 963:	83 c4 1c             	add    $0x1c,%esp
 966:	5b                   	pop    %ebx
 967:	5e                   	pop    %esi
 968:	5f                   	pop    %edi
 969:	5d                   	pop    %ebp
 96a:	c3                   	ret    
 96b:	90                   	nop
 96c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 970:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 976:	b8 00 80 00 00       	mov    $0x8000,%eax
 97b:	bf 00 10 00 00       	mov    $0x1000,%edi
 980:	76 04                	jbe    986 <malloc+0x86>
 982:	89 f0                	mov    %esi,%eax
 984:	89 df                	mov    %ebx,%edi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 986:	89 04 24             	mov    %eax,(%esp)
 989:	e8 12 fc ff ff       	call   5a0 <sbrk>
  if(p == (char*)-1)
 98e:	83 f8 ff             	cmp    $0xffffffff,%eax
 991:	74 18                	je     9ab <malloc+0xab>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 993:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 996:	83 c0 08             	add    $0x8,%eax
 999:	89 04 24             	mov    %eax,(%esp)
 99c:	e8 cf fe ff ff       	call   870 <free>
  return freep;
 9a1:	8b 0d e0 0a 00 00    	mov    0xae0,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 9a7:	85 c9                	test   %ecx,%ecx
 9a9:	75 97                	jne    942 <malloc+0x42>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 9ab:	31 c0                	xor    %eax,%eax
 9ad:	eb b4                	jmp    963 <malloc+0x63>
 9af:	90                   	nop
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 9b0:	8b 10                	mov    (%eax),%edx
 9b2:	89 11                	mov    %edx,(%ecx)
 9b4:	eb a4                	jmp    95a <malloc+0x5a>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 9b6:	c7 05 e0 0a 00 00 d8 	movl   $0xad8,0xae0
 9bd:	0a 00 00 
    base.s.size = 0;
 9c0:	b9 d8 0a 00 00       	mov    $0xad8,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 9c5:	c7 05 d8 0a 00 00 d8 	movl   $0xad8,0xad8
 9cc:	0a 00 00 
    base.s.size = 0;
 9cf:	c7 05 dc 0a 00 00 00 	movl   $0x0,0xadc
 9d6:	00 00 00 
 9d9:	e9 45 ff ff ff       	jmp    923 <malloc+0x23>
 9de:	90                   	nop
 9df:	90                   	nop

000009e0 <lock_init>:
#include "thread.h"
#include "stat.h"

void
lock_init(struct lock_t *lock)
{
 9e0:	55                   	push   %ebp
 9e1:	89 e5                	mov    %esp,%ebp
  lock->locked = 0;
 9e3:	8b 45 08             	mov    0x8(%ebp),%eax
 9e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 9ec:	5d                   	pop    %ebp
 9ed:	c3                   	ret    
 9ee:	66 90                	xchg   %ax,%ax

000009f0 <lock_acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
lock_acquire(struct lock_t *lock)
{
 9f0:	55                   	push   %ebp
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
 9f1:	b9 01 00 00 00       	mov    $0x1,%ecx
 9f6:	89 e5                	mov    %esp,%ebp
 9f8:	8b 55 08             	mov    0x8(%ebp),%edx
 9fb:	90                   	nop
 9fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 a00:	89 c8                	mov    %ecx,%eax
 a02:	f0 87 02             	lock xchg %eax,(%edx)
//     panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lock->locked, 1) != 0)
 a05:	85 c0                	test   %eax,%eax
 a07:	75 f7                	jne    a00 <lock_acquire+0x10>
    ;

}
 a09:	5d                   	pop    %ebp
 a0a:	c3                   	ret    
 a0b:	90                   	nop
 a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000a10 <lock_release>:

// Release the lock.
void
lock_release(struct lock_t *lock)
{
 a10:	55                   	push   %ebp
 a11:	31 c0                	xor    %eax,%eax
 a13:	89 e5                	mov    %esp,%ebp
 a15:	8b 55 08             	mov    0x8(%ebp),%edx
 a18:	f0 87 02             	lock xchg %eax,(%edx)
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lock->locked, 0);

}
 a1b:	5d                   	pop    %ebp
 a1c:	c3                   	ret    
 a1d:	8d 76 00             	lea    0x0(%esi),%esi

00000a20 <lock_holding>:

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
 a20:	55                   	push   %ebp
 a21:	89 e5                	mov    %esp,%ebp
 a23:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked;
 a26:	5d                   	pop    %ebp
}

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
 a27:	8b 00                	mov    (%eax),%eax
  return lock->locked;
 a29:	c3                   	ret    
