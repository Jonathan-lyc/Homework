
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
   6:	a1 b0 0a 00 00       	mov    0xab0,%eax
   b:	c7 44 24 04 0c 0a 00 	movl   $0xa0c,0x4(%esp)
  12:	00 
  13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  1e:	e8 1d 06 00 00       	call   640 <printf>
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
  38:	a1 c4 0a 00 00       	mov    0xac4,%eax
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
  55:	c7 44 24 04 17 0a 00 	movl   $0xa17,0x4(%esp)
  5c:	00 
  5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  64:	e8 d7 05 00 00       	call   640 <printf>
}
  69:	c9                   	leave  
  6a:	c3                   	ret    
  6b:	90                   	nop
  6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000070 <ll_print>:
	
  }
  count++;
}

void ll_print(){
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	53                   	push   %ebx
  74:	83 ec 14             	sub    $0x14,%esp
  struct node *n;
  n = head;
  77:	8b 1d c4 0a 00 00    	mov    0xac4,%ebx
  while(n != 0) {
  7d:	85 db                	test   %ebx,%ebx
  7f:	74 28                	je     a9 <ll_print+0x39>
  81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    printf(1, "%d\n", n->data);
  88:	8b 03                	mov    (%ebx),%eax
  8a:	c7 44 24 04 13 0a 00 	movl   $0xa13,0x4(%esp)
  91:	00 
  92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  99:	89 44 24 08          	mov    %eax,0x8(%esp)
  9d:	e8 9e 05 00 00       	call   640 <printf>
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
  bd:	e8 1e 08 00 00       	call   8e0 <malloc>
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
  ce:	8b 15 c4 0a 00 00    	mov    0xac4,%edx
  d4:	85 d2                	test   %edx,%edx
  d6:	74 18                	je     f0 <ll_add+0x40>
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
  count++;
  e4:	83 05 b0 0a 00 00 01 	addl   $0x1,0xab0
}
  eb:	c9                   	leave  
  ec:	c3                   	ret    
  ed:	8d 76 00             	lea    0x0(%esi),%esi
    }
    curr->next = n;
/*    printf(1, "currnext = %d\n", curr->next);*/
	
  }
  count++;
  f0:	83 05 b0 0a 00 00 01 	addl   $0x1,0xab0
  struct node *n;
  n = (struct node *)malloc(sizeof(struct node));
  n->data = i;
  n->next = 0;
  if (head == 0) {
    head = n;
  f7:	a3 c4 0a 00 00       	mov    %eax,0xac4
    curr->next = n;
/*    printf(1, "currnext = %d\n", curr->next);*/
	
  }
  count++;
}
  fc:	c9                   	leave  
  fd:	c3                   	ret    
  fe:	66 90                	xchg   %ax,%ax

00000100 <thread_create>:
	lock_release(&t);
  }
}

void thread_create(void *(*start_routine)(void*), void *arg)
{
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	83 ec 18             	sub    $0x18,%esp
 106:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 109:	8b 5d 08             	mov    0x8(%ebp),%ebx
 10c:	89 75 fc             	mov    %esi,-0x4(%ebp)
 10f:	8b 75 0c             	mov    0xc(%ebp),%esi
  char* stack = malloc(4096);
 112:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
 119:	e8 c2 07 00 00       	call   8e0 <malloc>
  clone(stack, 4096);
 11e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
 125:	00 
 126:	89 04 24             	mov    %eax,(%esp)
 129:	e8 6a 04 00 00       	call   598 <clone>
  (*start_routine)(arg);
 12e:	89 da                	mov    %ebx,%edx
  return;
}
 130:	8b 5d f8             	mov    -0x8(%ebp),%ebx

void thread_create(void *(*start_routine)(void*), void *arg)
{
  char* stack = malloc(4096);
  clone(stack, 4096);
  (*start_routine)(arg);
 133:	89 75 08             	mov    %esi,0x8(%ebp)
  return;
}
 136:	8b 75 fc             	mov    -0x4(%ebp),%esi
 139:	89 ec                	mov    %ebp,%esp
 13b:	5d                   	pop    %ebp

void thread_create(void *(*start_routine)(void*), void *arg)
{
  char* stack = malloc(4096);
  clone(stack, 4096);
  (*start_routine)(arg);
 13c:	ff e2                	jmp    *%edx
 13e:	66 90                	xchg   %ax,%ax

00000140 <main>:
  return;
}
/*  printf(1, "Clone returns = %d\n", rc);*/

int
main (int argc, char* argv[]) {
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	83 e4 f0             	and    $0xfffffff0,%esp
 146:	83 ec 30             	sub    $0x30,%esp
/*  printf(1, "Beginning Test\n");*/
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
  if (argc != 3 || atoi(argv[1]) < 1 || atoi(argv[2]) < 1) {
 149:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
  return;
}
/*  printf(1, "Clone returns = %d\n", rc);*/

int
main (int argc, char* argv[]) {
 14d:	89 5c 24 24          	mov    %ebx,0x24(%esp)
 151:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 154:	89 74 24 28          	mov    %esi,0x28(%esp)
 158:	89 7c 24 2c          	mov    %edi,0x2c(%esp)
/*  printf(1, "Beginning Test\n");*/
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
  if (argc != 3 || atoi(argv[1]) < 1 || atoi(argv[2]) < 1) {
 15c:	74 1a                	je     178 <main+0x38>
	printf(1, "Usage: test numberOfThreads numberOfRuns\n");
 15e:	c7 44 24 04 6c 0a 00 	movl   $0xa6c,0x4(%esp)
 165:	00 
 166:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 16d:	e8 ce 04 00 00       	call   640 <printf>
	exit();
 172:	e8 81 03 00 00       	call   4f8 <exit>
 177:	90                   	nop
main (int argc, char* argv[]) {
/*  printf(1, "Beginning Test\n");*/
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
  if (argc != 3 || atoi(argv[1]) < 1 || atoi(argv[2]) < 1) {
 178:	8b 43 04             	mov    0x4(%ebx),%eax
 17b:	89 04 24             	mov    %eax,(%esp)
 17e:	e8 4d 02 00 00       	call   3d0 <atoi>
 183:	85 c0                	test   %eax,%eax
 185:	7e d7                	jle    15e <main+0x1e>
 187:	8b 43 08             	mov    0x8(%ebx),%eax
 18a:	8d 7b 08             	lea    0x8(%ebx),%edi
 18d:	89 04 24             	mov    %eax,(%esp)
 190:	e8 3b 02 00 00       	call   3d0 <atoi>
 195:	85 c0                	test   %eax,%eax
 197:	7e c5                	jle    15e <main+0x1e>
	printf(1, "Usage: test numberOfThreads numberOfRuns\n");
	exit();
  }
  int threads = atoi(argv[1]);
 199:	8b 43 04             	mov    0x4(%ebx),%eax
 19c:	89 04 24             	mov    %eax,(%esp)
 19f:	e8 2c 02 00 00       	call   3d0 <atoi>
  lock_init(&t);
 1a4:	c7 04 24 c0 0a 00 00 	movl   $0xac0,(%esp)
//   lock_acquire(&lock);
  if (argc != 3 || atoi(argv[1]) < 1 || atoi(argv[2]) < 1) {
	printf(1, "Usage: test numberOfThreads numberOfRuns\n");
	exit();
  }
  int threads = atoi(argv[1]);
 1ab:	89 c6                	mov    %eax,%esi
  lock_init(&t);
 1ad:	e8 0e 08 00 00       	call   9c0 <lock_init>
  int parent = getpid();
 1b2:	e8 c1 03 00 00       	call   578 <getpid>
/*  printf(1, "stack outside %d\n", stack[0]);*/
  void (*fnc)(int);
  fnc = &update;
  
  int i;
  for (i = 0; i < threads; i++) {
 1b7:	85 f6                	test   %esi,%esi
	printf(1, "Usage: test numberOfThreads numberOfRuns\n");
	exit();
  }
  int threads = atoi(argv[1]);
  lock_init(&t);
  int parent = getpid();
 1b9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
/*  printf(1, "stack outside %d\n", stack[0]);*/
  void (*fnc)(int);
  fnc = &update;
  
  int i;
  for (i = 0; i < threads; i++) {
 1bd:	7e 2a                	jle    1e9 <main+0xa9>
 1bf:	31 db                	xor    %ebx,%ebx
 1c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
	thread_create((void*)fnc, (int*)atoi(argv[2]));
 1c8:	8b 07                	mov    (%edi),%eax
/*  printf(1, "stack outside %d\n", stack[0]);*/
  void (*fnc)(int);
  fnc = &update;
  
  int i;
  for (i = 0; i < threads; i++) {
 1ca:	83 c3 01             	add    $0x1,%ebx
	thread_create((void*)fnc, (int*)atoi(argv[2]));
 1cd:	89 04 24             	mov    %eax,(%esp)
 1d0:	e8 fb 01 00 00       	call   3d0 <atoi>
 1d5:	c7 04 24 50 02 00 00 	movl   $0x250,(%esp)
 1dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e0:	e8 1b ff ff ff       	call   100 <thread_create>
/*  printf(1, "stack outside %d\n", stack[0]);*/
  void (*fnc)(int);
  fnc = &update;
  
  int i;
  for (i = 0; i < threads; i++) {
 1e5:	39 de                	cmp    %ebx,%esi
 1e7:	7f df                	jg     1c8 <main+0x88>
	thread_create((void*)fnc, (int*)atoi(argv[2]));
  }
   
  int pid = getpid();
 1e9:	e8 8a 03 00 00       	call   578 <getpid>
  if (pid == parent) {
 1ee:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  int i;
  for (i = 0; i < threads; i++) {
	thread_create((void*)fnc, (int*)atoi(argv[2]));
  }
   
  int pid = getpid();
 1f2:	89 c7                	mov    %eax,%edi
  if (pid == parent) {
 1f4:	74 22                	je     218 <main+0xd8>
	  printf(1, "wait returned %d\n", ret);
	}	
	ll_count();
  }

  printf(1, "pid: %d exiting\n", pid);
 1f6:	89 7c 24 08          	mov    %edi,0x8(%esp)
 1fa:	c7 44 24 04 35 0a 00 	movl   $0xa35,0x4(%esp)
 201:	00 
 202:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 209:	e8 32 04 00 00       	call   640 <printf>
  
  //Prints out the final count
  exit();
 20e:	e8 e5 02 00 00       	call   4f8 <exit>
 213:	90                   	nop
 214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }
   
  int pid = getpid();
  if (pid == parent) {
	int ret = 0;
	for (i = 0; i < threads; i++) {
 218:	85 f6                	test   %esi,%esi
 21a:	7e 28                	jle    244 <main+0x104>
 21c:	31 db                	xor    %ebx,%ebx
 21e:	66 90                	xchg   %ax,%ax
	  ret = wait();
 220:	e8 db 02 00 00       	call   500 <wait>
  }
   
  int pid = getpid();
  if (pid == parent) {
	int ret = 0;
	for (i = 0; i < threads; i++) {
 225:	83 c3 01             	add    $0x1,%ebx
	  ret = wait();
	  printf(1, "wait returned %d\n", ret);
 228:	c7 44 24 04 23 0a 00 	movl   $0xa23,0x4(%esp)
 22f:	00 
 230:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 237:	89 44 24 08          	mov    %eax,0x8(%esp)
 23b:	e8 00 04 00 00       	call   640 <printf>
  }
   
  int pid = getpid();
  if (pid == parent) {
	int ret = 0;
	for (i = 0; i < threads; i++) {
 240:	39 de                	cmp    %ebx,%esi
 242:	7f dc                	jg     220 <main+0xe0>
	  ret = wait();
	  printf(1, "wait returned %d\n", ret);
	}	
	ll_count();
 244:	e8 b7 fd ff ff       	call   0 <ll_count>
 249:	eb ab                	jmp    1f6 <main+0xb6>
 24b:	90                   	nop
 24c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000250 <update>:
#include "linkedlist.h"
#include "thread.h"

struct lock_t t;

void update(int runs) {
 250:	55                   	push   %ebp
 251:	89 e5                	mov    %esp,%ebp
 253:	56                   	push   %esi
 254:	53                   	push   %ebx
 255:	83 ec 10             	sub    $0x10,%esp
 258:	8b 5d 08             	mov    0x8(%ebp),%ebx
  printf(1, "runs = %d\n", runs);
 25b:	c7 44 24 04 46 0a 00 	movl   $0xa46,0x4(%esp)
 262:	00 
 263:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 26a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 26e:	e8 cd 03 00 00       	call   640 <printf>
  int pid = getpid();
 273:	e8 00 03 00 00       	call   578 <getpid>
  printf(1, "pid %d starting update\n", pid);
 278:	c7 44 24 04 51 0a 00 	movl   $0xa51,0x4(%esp)
 27f:	00 
 280:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 287:	89 44 24 08          	mov    %eax,0x8(%esp)
 28b:	e8 b0 03 00 00       	call   640 <printf>
  int i;
  for (i = 0; i < runs; i++) {
 290:	85 db                	test   %ebx,%ebx
 292:	7e 2b                	jle    2bf <update+0x6f>
 294:	31 f6                	xor    %esi,%esi
 296:	66 90                	xchg   %ax,%ax
	lock_acquire(&t);
 298:	c7 04 24 c0 0a 00 00 	movl   $0xac0,(%esp)
 29f:	e8 2c 07 00 00       	call   9d0 <lock_acquire>
    ll_add(i);
 2a4:	89 34 24             	mov    %esi,(%esp)
void update(int runs) {
  printf(1, "runs = %d\n", runs);
  int pid = getpid();
  printf(1, "pid %d starting update\n", pid);
  int i;
  for (i = 0; i < runs; i++) {
 2a7:	83 c6 01             	add    $0x1,%esi
	lock_acquire(&t);
    ll_add(i);
 2aa:	e8 01 fe ff ff       	call   b0 <ll_add>
	lock_release(&t);
 2af:	c7 04 24 c0 0a 00 00 	movl   $0xac0,(%esp)
 2b6:	e8 35 07 00 00       	call   9f0 <lock_release>
void update(int runs) {
  printf(1, "runs = %d\n", runs);
  int pid = getpid();
  printf(1, "pid %d starting update\n", pid);
  int i;
  for (i = 0; i < runs; i++) {
 2bb:	39 f3                	cmp    %esi,%ebx
 2bd:	7f d9                	jg     298 <update+0x48>
	lock_acquire(&t);
    ll_add(i);
	lock_release(&t);
  }
}
 2bf:	83 c4 10             	add    $0x10,%esp
 2c2:	5b                   	pop    %ebx
 2c3:	5e                   	pop    %esi
 2c4:	5d                   	pop    %ebp
 2c5:	c3                   	ret    
 2c6:	90                   	nop
 2c7:	90                   	nop
 2c8:	90                   	nop
 2c9:	90                   	nop
 2ca:	90                   	nop
 2cb:	90                   	nop
 2cc:	90                   	nop
 2cd:	90                   	nop
 2ce:	90                   	nop
 2cf:	90                   	nop

000002d0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2d0:	55                   	push   %ebp
 2d1:	31 d2                	xor    %edx,%edx
 2d3:	89 e5                	mov    %esp,%ebp
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
 2d8:	53                   	push   %ebx
 2d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2e0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 2e4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 2e7:	83 c2 01             	add    $0x1,%edx
 2ea:	84 c9                	test   %cl,%cl
 2ec:	75 f2                	jne    2e0 <strcpy+0x10>
    ;
  return os;
}
 2ee:	5b                   	pop    %ebx
 2ef:	5d                   	pop    %ebp
 2f0:	c3                   	ret    
 2f1:	eb 0d                	jmp    300 <strcmp>
 2f3:	90                   	nop
 2f4:	90                   	nop
 2f5:	90                   	nop
 2f6:	90                   	nop
 2f7:	90                   	nop
 2f8:	90                   	nop
 2f9:	90                   	nop
 2fa:	90                   	nop
 2fb:	90                   	nop
 2fc:	90                   	nop
 2fd:	90                   	nop
 2fe:	90                   	nop
 2ff:	90                   	nop

00000300 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	53                   	push   %ebx
 304:	8b 4d 08             	mov    0x8(%ebp),%ecx
 307:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 30a:	0f b6 01             	movzbl (%ecx),%eax
 30d:	84 c0                	test   %al,%al
 30f:	75 14                	jne    325 <strcmp+0x25>
 311:	eb 25                	jmp    338 <strcmp+0x38>
 313:	90                   	nop
 314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
 318:	83 c1 01             	add    $0x1,%ecx
 31b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 31e:	0f b6 01             	movzbl (%ecx),%eax
 321:	84 c0                	test   %al,%al
 323:	74 13                	je     338 <strcmp+0x38>
 325:	0f b6 1a             	movzbl (%edx),%ebx
 328:	38 d8                	cmp    %bl,%al
 32a:	74 ec                	je     318 <strcmp+0x18>
 32c:	0f b6 db             	movzbl %bl,%ebx
 32f:	0f b6 c0             	movzbl %al,%eax
 332:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 334:	5b                   	pop    %ebx
 335:	5d                   	pop    %ebp
 336:	c3                   	ret    
 337:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 338:	0f b6 1a             	movzbl (%edx),%ebx
 33b:	31 c0                	xor    %eax,%eax
 33d:	0f b6 db             	movzbl %bl,%ebx
 340:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 342:	5b                   	pop    %ebx
 343:	5d                   	pop    %ebp
 344:	c3                   	ret    
 345:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 349:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000350 <strlen>:

uint
strlen(char *s)
{
 350:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
 351:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 353:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
 355:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 357:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 35a:	80 39 00             	cmpb   $0x0,(%ecx)
 35d:	74 0c                	je     36b <strlen+0x1b>
 35f:	90                   	nop
 360:	83 c2 01             	add    $0x1,%edx
 363:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 367:	89 d0                	mov    %edx,%eax
 369:	75 f5                	jne    360 <strlen+0x10>
    ;
  return n;
}
 36b:	5d                   	pop    %ebp
 36c:	c3                   	ret    
 36d:	8d 76 00             	lea    0x0(%esi),%esi

00000370 <memset>:

void*
memset(void *dst, int c, uint n)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	8b 55 08             	mov    0x8(%ebp),%edx
 376:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 377:	8b 4d 10             	mov    0x10(%ebp),%ecx
 37a:	8b 45 0c             	mov    0xc(%ebp),%eax
 37d:	89 d7                	mov    %edx,%edi
 37f:	fc                   	cld    
 380:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 382:	89 d0                	mov    %edx,%eax
 384:	5f                   	pop    %edi
 385:	5d                   	pop    %ebp
 386:	c3                   	ret    
 387:	89 f6                	mov    %esi,%esi
 389:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000390 <strchr>:

char*
strchr(const char *s, char c)
{
 390:	55                   	push   %ebp
 391:	89 e5                	mov    %esp,%ebp
 393:	8b 45 08             	mov    0x8(%ebp),%eax
 396:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 39a:	0f b6 10             	movzbl (%eax),%edx
 39d:	84 d2                	test   %dl,%dl
 39f:	75 11                	jne    3b2 <strchr+0x22>
 3a1:	eb 15                	jmp    3b8 <strchr+0x28>
 3a3:	90                   	nop
 3a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 3a8:	83 c0 01             	add    $0x1,%eax
 3ab:	0f b6 10             	movzbl (%eax),%edx
 3ae:	84 d2                	test   %dl,%dl
 3b0:	74 06                	je     3b8 <strchr+0x28>
    if(*s == c)
 3b2:	38 ca                	cmp    %cl,%dl
 3b4:	75 f2                	jne    3a8 <strchr+0x18>
      return (char*)s;
  return 0;
}
 3b6:	5d                   	pop    %ebp
 3b7:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3b8:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 3ba:	5d                   	pop    %ebp
 3bb:	90                   	nop
 3bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 3c0:	c3                   	ret    
 3c1:	eb 0d                	jmp    3d0 <atoi>
 3c3:	90                   	nop
 3c4:	90                   	nop
 3c5:	90                   	nop
 3c6:	90                   	nop
 3c7:	90                   	nop
 3c8:	90                   	nop
 3c9:	90                   	nop
 3ca:	90                   	nop
 3cb:	90                   	nop
 3cc:	90                   	nop
 3cd:	90                   	nop
 3ce:	90                   	nop
 3cf:	90                   	nop

000003d0 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 3d0:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3d1:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 3d3:	89 e5                	mov    %esp,%ebp
 3d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3d8:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3d9:	0f b6 11             	movzbl (%ecx),%edx
 3dc:	8d 5a d0             	lea    -0x30(%edx),%ebx
 3df:	80 fb 09             	cmp    $0x9,%bl
 3e2:	77 1c                	ja     400 <atoi+0x30>
 3e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 3e8:	0f be d2             	movsbl %dl,%edx
 3eb:	83 c1 01             	add    $0x1,%ecx
 3ee:	8d 04 80             	lea    (%eax,%eax,4),%eax
 3f1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f5:	0f b6 11             	movzbl (%ecx),%edx
 3f8:	8d 5a d0             	lea    -0x30(%edx),%ebx
 3fb:	80 fb 09             	cmp    $0x9,%bl
 3fe:	76 e8                	jbe    3e8 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 400:	5b                   	pop    %ebx
 401:	5d                   	pop    %ebp
 402:	c3                   	ret    
 403:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 409:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000410 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 410:	55                   	push   %ebp
 411:	89 e5                	mov    %esp,%ebp
 413:	56                   	push   %esi
 414:	8b 45 08             	mov    0x8(%ebp),%eax
 417:	53                   	push   %ebx
 418:	8b 5d 10             	mov    0x10(%ebp),%ebx
 41b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 41e:	85 db                	test   %ebx,%ebx
 420:	7e 14                	jle    436 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
 422:	31 d2                	xor    %edx,%edx
 424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 428:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 42c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 42f:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 432:	39 da                	cmp    %ebx,%edx
 434:	75 f2                	jne    428 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 436:	5b                   	pop    %ebx
 437:	5e                   	pop    %esi
 438:	5d                   	pop    %ebp
 439:	c3                   	ret    
 43a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000440 <stat>:
  return buf;
}

int
stat(char *n, struct stat *st)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 446:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(char *n, struct stat *st)
{
 449:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 44c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 44f:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 454:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 45b:	00 
 45c:	89 04 24             	mov    %eax,(%esp)
 45f:	e8 d4 00 00 00       	call   538 <open>
  if(fd < 0)
 464:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 466:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 468:	78 19                	js     483 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 46a:	8b 45 0c             	mov    0xc(%ebp),%eax
 46d:	89 1c 24             	mov    %ebx,(%esp)
 470:	89 44 24 04          	mov    %eax,0x4(%esp)
 474:	e8 d7 00 00 00       	call   550 <fstat>
  close(fd);
 479:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 47c:	89 c6                	mov    %eax,%esi
  close(fd);
 47e:	e8 9d 00 00 00       	call   520 <close>
  return r;
}
 483:	89 f0                	mov    %esi,%eax
 485:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 488:	8b 75 fc             	mov    -0x4(%ebp),%esi
 48b:	89 ec                	mov    %ebp,%esp
 48d:	5d                   	pop    %ebp
 48e:	c3                   	ret    
 48f:	90                   	nop

00000490 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 490:	55                   	push   %ebp
 491:	89 e5                	mov    %esp,%ebp
 493:	57                   	push   %edi
 494:	56                   	push   %esi
 495:	31 f6                	xor    %esi,%esi
 497:	53                   	push   %ebx
 498:	83 ec 2c             	sub    $0x2c,%esp
 49b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 49e:	eb 06                	jmp    4a6 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 4a0:	3c 0a                	cmp    $0xa,%al
 4a2:	74 39                	je     4dd <gets+0x4d>
 4a4:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4a6:	8d 5e 01             	lea    0x1(%esi),%ebx
 4a9:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 4ac:	7d 31                	jge    4df <gets+0x4f>
    cc = read(0, &c, 1);
 4ae:	8d 45 e7             	lea    -0x19(%ebp),%eax
 4b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4b8:	00 
 4b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 4bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4c4:	e8 47 00 00 00       	call   510 <read>
    if(cc < 1)
 4c9:	85 c0                	test   %eax,%eax
 4cb:	7e 12                	jle    4df <gets+0x4f>
      break;
    buf[i++] = c;
 4cd:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 4d1:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 4d5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 4d9:	3c 0d                	cmp    $0xd,%al
 4db:	75 c3                	jne    4a0 <gets+0x10>
 4dd:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 4df:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 4e3:	89 f8                	mov    %edi,%eax
 4e5:	83 c4 2c             	add    $0x2c,%esp
 4e8:	5b                   	pop    %ebx
 4e9:	5e                   	pop    %esi
 4ea:	5f                   	pop    %edi
 4eb:	5d                   	pop    %ebp
 4ec:	c3                   	ret    
 4ed:	90                   	nop
 4ee:	90                   	nop
 4ef:	90                   	nop

000004f0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4f0:	b8 01 00 00 00       	mov    $0x1,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <exit>:
SYSCALL(exit)
 4f8:	b8 02 00 00 00       	mov    $0x2,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <wait>:
SYSCALL(wait)
 500:	b8 03 00 00 00       	mov    $0x3,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <pipe>:
SYSCALL(pipe)
 508:	b8 04 00 00 00       	mov    $0x4,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <read>:
SYSCALL(read)
 510:	b8 06 00 00 00       	mov    $0x6,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <write>:
SYSCALL(write)
 518:	b8 05 00 00 00       	mov    $0x5,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <close>:
SYSCALL(close)
 520:	b8 07 00 00 00       	mov    $0x7,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <kill>:
SYSCALL(kill)
 528:	b8 08 00 00 00       	mov    $0x8,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <exec>:
SYSCALL(exec)
 530:	b8 09 00 00 00       	mov    $0x9,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <open>:
SYSCALL(open)
 538:	b8 0a 00 00 00       	mov    $0xa,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <mknod>:
SYSCALL(mknod)
 540:	b8 0b 00 00 00       	mov    $0xb,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <unlink>:
SYSCALL(unlink)
 548:	b8 0c 00 00 00       	mov    $0xc,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <fstat>:
SYSCALL(fstat)
 550:	b8 0d 00 00 00       	mov    $0xd,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <link>:
SYSCALL(link)
 558:	b8 0e 00 00 00       	mov    $0xe,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <mkdir>:
SYSCALL(mkdir)
 560:	b8 0f 00 00 00       	mov    $0xf,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <chdir>:
SYSCALL(chdir)
 568:	b8 10 00 00 00       	mov    $0x10,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <dup>:
SYSCALL(dup)
 570:	b8 11 00 00 00       	mov    $0x11,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <getpid>:
SYSCALL(getpid)
 578:	b8 12 00 00 00       	mov    $0x12,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <sbrk>:
SYSCALL(sbrk)
 580:	b8 13 00 00 00       	mov    $0x13,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <sleep>:
SYSCALL(sleep)
 588:	b8 14 00 00 00       	mov    $0x14,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <uptime>:
SYSCALL(uptime)
 590:	b8 15 00 00 00       	mov    $0x15,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <clone>:
SYSCALL(clone)
 598:	b8 16 00 00 00       	mov    $0x16,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 5a0:	55                   	push   %ebp
 5a1:	89 e5                	mov    %esp,%ebp
 5a3:	57                   	push   %edi
 5a4:	89 cf                	mov    %ecx,%edi
 5a6:	56                   	push   %esi
 5a7:	89 c6                	mov    %eax,%esi
 5a9:	53                   	push   %ebx
 5aa:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5b0:	85 c9                	test   %ecx,%ecx
 5b2:	74 04                	je     5b8 <printint+0x18>
 5b4:	85 d2                	test   %edx,%edx
 5b6:	78 70                	js     628 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5b8:	89 d0                	mov    %edx,%eax
 5ba:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 5c1:	31 c9                	xor    %ecx,%ecx
 5c3:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 5c6:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 5c8:	31 d2                	xor    %edx,%edx
 5ca:	f7 f7                	div    %edi
 5cc:	0f b6 92 9f 0a 00 00 	movzbl 0xa9f(%edx),%edx
 5d3:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 5d6:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 5d9:	85 c0                	test   %eax,%eax
 5db:	75 eb                	jne    5c8 <printint+0x28>
  if(neg)
 5dd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 5e0:	85 c0                	test   %eax,%eax
 5e2:	74 08                	je     5ec <printint+0x4c>
    buf[i++] = '-';
 5e4:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 5e9:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 5ec:	8d 79 ff             	lea    -0x1(%ecx),%edi
 5ef:	01 fb                	add    %edi,%ebx
 5f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 5f8:	0f b6 03             	movzbl (%ebx),%eax
 5fb:	83 ef 01             	sub    $0x1,%edi
 5fe:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 601:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 608:	00 
 609:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 60c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 60f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 612:	89 44 24 04          	mov    %eax,0x4(%esp)
 616:	e8 fd fe ff ff       	call   518 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 61b:	83 ff ff             	cmp    $0xffffffff,%edi
 61e:	75 d8                	jne    5f8 <printint+0x58>
    putc(fd, buf[i]);
}
 620:	83 c4 4c             	add    $0x4c,%esp
 623:	5b                   	pop    %ebx
 624:	5e                   	pop    %esi
 625:	5f                   	pop    %edi
 626:	5d                   	pop    %ebp
 627:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 628:	89 d0                	mov    %edx,%eax
 62a:	f7 d8                	neg    %eax
 62c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 633:	eb 8c                	jmp    5c1 <printint+0x21>
 635:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 639:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000640 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 640:	55                   	push   %ebp
 641:	89 e5                	mov    %esp,%ebp
 643:	57                   	push   %edi
 644:	56                   	push   %esi
 645:	53                   	push   %ebx
 646:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 649:	8b 45 0c             	mov    0xc(%ebp),%eax
 64c:	0f b6 10             	movzbl (%eax),%edx
 64f:	84 d2                	test   %dl,%dl
 651:	0f 84 c9 00 00 00    	je     720 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 657:	8d 4d 10             	lea    0x10(%ebp),%ecx
 65a:	31 ff                	xor    %edi,%edi
 65c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 65f:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 661:	8d 75 e7             	lea    -0x19(%ebp),%esi
 664:	eb 1e                	jmp    684 <printf+0x44>
 666:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 668:	83 fa 25             	cmp    $0x25,%edx
 66b:	0f 85 b7 00 00 00    	jne    728 <printf+0xe8>
 671:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 675:	83 c3 01             	add    $0x1,%ebx
 678:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 67c:	84 d2                	test   %dl,%dl
 67e:	0f 84 9c 00 00 00    	je     720 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 684:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 686:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 689:	74 dd                	je     668 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 68b:	83 ff 25             	cmp    $0x25,%edi
 68e:	75 e5                	jne    675 <printf+0x35>
      if(c == 'd'){
 690:	83 fa 64             	cmp    $0x64,%edx
 693:	0f 84 57 01 00 00    	je     7f0 <printf+0x1b0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 699:	83 fa 70             	cmp    $0x70,%edx
 69c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 6a0:	0f 84 aa 00 00 00    	je     750 <printf+0x110>
 6a6:	83 fa 78             	cmp    $0x78,%edx
 6a9:	0f 84 a1 00 00 00    	je     750 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 6af:	83 fa 73             	cmp    $0x73,%edx
 6b2:	0f 84 c0 00 00 00    	je     778 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6b8:	83 fa 63             	cmp    $0x63,%edx
 6bb:	90                   	nop
 6bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 6c0:	0f 84 52 01 00 00    	je     818 <printf+0x1d8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 6c6:	83 fa 25             	cmp    $0x25,%edx
 6c9:	0f 84 f9 00 00 00    	je     7c8 <printf+0x188>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6d2:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6d5:	31 ff                	xor    %edi,%edi
 6d7:	89 55 cc             	mov    %edx,-0x34(%ebp)
 6da:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 6de:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6e5:	00 
 6e6:	89 0c 24             	mov    %ecx,(%esp)
 6e9:	89 74 24 04          	mov    %esi,0x4(%esp)
 6ed:	e8 26 fe ff ff       	call   518 <write>
 6f2:	8b 55 cc             	mov    -0x34(%ebp),%edx
 6f5:	8b 45 08             	mov    0x8(%ebp),%eax
 6f8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6ff:	00 
 700:	89 74 24 04          	mov    %esi,0x4(%esp)
 704:	88 55 e7             	mov    %dl,-0x19(%ebp)
 707:	89 04 24             	mov    %eax,(%esp)
 70a:	e8 09 fe ff ff       	call   518 <write>
 70f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 712:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 716:	84 d2                	test   %dl,%dl
 718:	0f 85 66 ff ff ff    	jne    684 <printf+0x44>
 71e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 720:	83 c4 3c             	add    $0x3c,%esp
 723:	5b                   	pop    %ebx
 724:	5e                   	pop    %esi
 725:	5f                   	pop    %edi
 726:	5d                   	pop    %ebp
 727:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 728:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 72b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 72e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 735:	00 
 736:	89 74 24 04          	mov    %esi,0x4(%esp)
 73a:	89 04 24             	mov    %eax,(%esp)
 73d:	e8 d6 fd ff ff       	call   518 <write>
 742:	8b 45 0c             	mov    0xc(%ebp),%eax
 745:	e9 2b ff ff ff       	jmp    675 <printf+0x35>
 74a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 750:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 753:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 758:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 75a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 761:	8b 10                	mov    (%eax),%edx
 763:	8b 45 08             	mov    0x8(%ebp),%eax
 766:	e8 35 fe ff ff       	call   5a0 <printint>
 76b:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 76e:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 772:	e9 fe fe ff ff       	jmp    675 <printf+0x35>
 777:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 778:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 77b:	8b 3a                	mov    (%edx),%edi
        ap++;
 77d:	83 c2 04             	add    $0x4,%edx
 780:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 783:	85 ff                	test   %edi,%edi
 785:	0f 84 ba 00 00 00    	je     845 <printf+0x205>
          s = "(null)";
        while(*s != 0){
 78b:	0f b6 17             	movzbl (%edi),%edx
 78e:	84 d2                	test   %dl,%dl
 790:	74 2d                	je     7bf <printf+0x17f>
 792:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 795:	8b 5d 08             	mov    0x8(%ebp),%ebx
          putc(fd, *s);
          s++;
 798:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 79b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 79e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7a5:	00 
 7a6:	89 74 24 04          	mov    %esi,0x4(%esp)
 7aa:	89 1c 24             	mov    %ebx,(%esp)
 7ad:	e8 66 fd ff ff       	call   518 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7b2:	0f b6 17             	movzbl (%edi),%edx
 7b5:	84 d2                	test   %dl,%dl
 7b7:	75 df                	jne    798 <printf+0x158>
 7b9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 7bc:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 7bf:	31 ff                	xor    %edi,%edi
 7c1:	e9 af fe ff ff       	jmp    675 <printf+0x35>
 7c6:	66 90                	xchg   %ax,%ax
 7c8:	8b 55 08             	mov    0x8(%ebp),%edx
 7cb:	31 ff                	xor    %edi,%edi
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 7cd:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 7d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7d8:	00 
 7d9:	89 74 24 04          	mov    %esi,0x4(%esp)
 7dd:	89 14 24             	mov    %edx,(%esp)
 7e0:	e8 33 fd ff ff       	call   518 <write>
 7e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 7e8:	e9 88 fe ff ff       	jmp    675 <printf+0x35>
 7ed:	8d 76 00             	lea    0x0(%esi),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 7f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 7f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 7f8:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 7fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 802:	8b 10                	mov    (%eax),%edx
 804:	8b 45 08             	mov    0x8(%ebp),%eax
 807:	e8 94 fd ff ff       	call   5a0 <printint>
 80c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 80f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 813:	e9 5d fe ff ff       	jmp    675 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 818:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
        putc(fd, *ap);
        ap++;
 81b:	31 ff                	xor    %edi,%edi
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 81d:	8b 01                	mov    (%ecx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 81f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 826:	00 
 827:	89 74 24 04          	mov    %esi,0x4(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 82b:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 82e:	8b 45 08             	mov    0x8(%ebp),%eax
 831:	89 04 24             	mov    %eax,(%esp)
 834:	e8 df fc ff ff       	call   518 <write>
 839:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 83c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 840:	e9 30 fe ff ff       	jmp    675 <printf+0x35>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
 845:	bf 98 0a 00 00       	mov    $0xa98,%edi
 84a:	e9 3c ff ff ff       	jmp    78b <printf+0x14b>
 84f:	90                   	nop

00000850 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 850:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 851:	a1 bc 0a 00 00       	mov    0xabc,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 856:	89 e5                	mov    %esp,%ebp
 858:	57                   	push   %edi
 859:	56                   	push   %esi
 85a:	53                   	push   %ebx
 85b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 85e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 861:	39 c8                	cmp    %ecx,%eax
 863:	73 1d                	jae    882 <free+0x32>
 865:	8d 76 00             	lea    0x0(%esi),%esi
 868:	8b 10                	mov    (%eax),%edx
 86a:	39 d1                	cmp    %edx,%ecx
 86c:	72 1a                	jb     888 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86e:	39 d0                	cmp    %edx,%eax
 870:	72 08                	jb     87a <free+0x2a>
 872:	39 c8                	cmp    %ecx,%eax
 874:	72 12                	jb     888 <free+0x38>
 876:	39 d1                	cmp    %edx,%ecx
 878:	72 0e                	jb     888 <free+0x38>
 87a:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87c:	39 c8                	cmp    %ecx,%eax
 87e:	66 90                	xchg   %ax,%ax
 880:	72 e6                	jb     868 <free+0x18>
 882:	8b 10                	mov    (%eax),%edx
 884:	eb e8                	jmp    86e <free+0x1e>
 886:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 888:	8b 71 04             	mov    0x4(%ecx),%esi
 88b:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 88e:	39 d7                	cmp    %edx,%edi
 890:	74 19                	je     8ab <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 892:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 895:	8b 50 04             	mov    0x4(%eax),%edx
 898:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 89b:	39 ce                	cmp    %ecx,%esi
 89d:	74 23                	je     8c2 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 89f:	89 08                	mov    %ecx,(%eax)
  freep = p;
 8a1:	a3 bc 0a 00 00       	mov    %eax,0xabc
}
 8a6:	5b                   	pop    %ebx
 8a7:	5e                   	pop    %esi
 8a8:	5f                   	pop    %edi
 8a9:	5d                   	pop    %ebp
 8aa:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8ab:	03 72 04             	add    0x4(%edx),%esi
 8ae:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 8b1:	8b 10                	mov    (%eax),%edx
 8b3:	8b 12                	mov    (%edx),%edx
 8b5:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8b8:	8b 50 04             	mov    0x4(%eax),%edx
 8bb:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 8be:	39 ce                	cmp    %ecx,%esi
 8c0:	75 dd                	jne    89f <free+0x4f>
    p->s.size += bp->s.size;
 8c2:	03 51 04             	add    0x4(%ecx),%edx
 8c5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8c8:	8b 53 f8             	mov    -0x8(%ebx),%edx
 8cb:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 8cd:	a3 bc 0a 00 00       	mov    %eax,0xabc
}
 8d2:	5b                   	pop    %ebx
 8d3:	5e                   	pop    %esi
 8d4:	5f                   	pop    %edi
 8d5:	5d                   	pop    %ebp
 8d6:	c3                   	ret    
 8d7:	89 f6                	mov    %esi,%esi
 8d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000008e0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e0:	55                   	push   %ebp
 8e1:	89 e5                	mov    %esp,%ebp
 8e3:	57                   	push   %edi
 8e4:	56                   	push   %esi
 8e5:	53                   	push   %ebx
 8e6:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 8ec:	8b 0d bc 0a 00 00    	mov    0xabc,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f2:	83 c3 07             	add    $0x7,%ebx
 8f5:	c1 eb 03             	shr    $0x3,%ebx
 8f8:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 8fb:	85 c9                	test   %ecx,%ecx
 8fd:	0f 84 93 00 00 00    	je     996 <malloc+0xb6>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 903:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 905:	8b 50 04             	mov    0x4(%eax),%edx
 908:	39 d3                	cmp    %edx,%ebx
 90a:	76 1f                	jbe    92b <malloc+0x4b>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 90c:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 913:	90                   	nop
 914:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
    if(p == freep)
 918:	3b 05 bc 0a 00 00    	cmp    0xabc,%eax
 91e:	74 30                	je     950 <malloc+0x70>
 920:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 922:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 924:	8b 50 04             	mov    0x4(%eax),%edx
 927:	39 d3                	cmp    %edx,%ebx
 929:	77 ed                	ja     918 <malloc+0x38>
      if(p->s.size == nunits)
 92b:	39 d3                	cmp    %edx,%ebx
 92d:	74 61                	je     990 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 92f:	29 da                	sub    %ebx,%edx
 931:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 934:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 937:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 93a:	89 0d bc 0a 00 00    	mov    %ecx,0xabc
      return (void*)(p + 1);
 940:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 943:	83 c4 1c             	add    $0x1c,%esp
 946:	5b                   	pop    %ebx
 947:	5e                   	pop    %esi
 948:	5f                   	pop    %edi
 949:	5d                   	pop    %ebp
 94a:	c3                   	ret    
 94b:	90                   	nop
 94c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 950:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 956:	b8 00 80 00 00       	mov    $0x8000,%eax
 95b:	bf 00 10 00 00       	mov    $0x1000,%edi
 960:	76 04                	jbe    966 <malloc+0x86>
 962:	89 f0                	mov    %esi,%eax
 964:	89 df                	mov    %ebx,%edi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 966:	89 04 24             	mov    %eax,(%esp)
 969:	e8 12 fc ff ff       	call   580 <sbrk>
  if(p == (char*)-1)
 96e:	83 f8 ff             	cmp    $0xffffffff,%eax
 971:	74 18                	je     98b <malloc+0xab>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 973:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 976:	83 c0 08             	add    $0x8,%eax
 979:	89 04 24             	mov    %eax,(%esp)
 97c:	e8 cf fe ff ff       	call   850 <free>
  return freep;
 981:	8b 0d bc 0a 00 00    	mov    0xabc,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 987:	85 c9                	test   %ecx,%ecx
 989:	75 97                	jne    922 <malloc+0x42>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 98b:	31 c0                	xor    %eax,%eax
 98d:	eb b4                	jmp    943 <malloc+0x63>
 98f:	90                   	nop
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 990:	8b 10                	mov    (%eax),%edx
 992:	89 11                	mov    %edx,(%ecx)
 994:	eb a4                	jmp    93a <malloc+0x5a>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 996:	c7 05 bc 0a 00 00 b4 	movl   $0xab4,0xabc
 99d:	0a 00 00 
    base.s.size = 0;
 9a0:	b9 b4 0a 00 00       	mov    $0xab4,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 9a5:	c7 05 b4 0a 00 00 b4 	movl   $0xab4,0xab4
 9ac:	0a 00 00 
    base.s.size = 0;
 9af:	c7 05 b8 0a 00 00 00 	movl   $0x0,0xab8
 9b6:	00 00 00 
 9b9:	e9 45 ff ff ff       	jmp    903 <malloc+0x23>
 9be:	90                   	nop
 9bf:	90                   	nop

000009c0 <lock_init>:
#include "thread.h"
#include "stat.h"

void
lock_init(struct lock_t *lock)
{
 9c0:	55                   	push   %ebp
 9c1:	89 e5                	mov    %esp,%ebp
  lock->locked = 0;
 9c3:	8b 45 08             	mov    0x8(%ebp),%eax
 9c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 9cc:	5d                   	pop    %ebp
 9cd:	c3                   	ret    
 9ce:	66 90                	xchg   %ax,%ax

000009d0 <lock_acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
lock_acquire(struct lock_t *lock)
{
 9d0:	55                   	push   %ebp
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
 9d1:	b9 01 00 00 00       	mov    $0x1,%ecx
 9d6:	89 e5                	mov    %esp,%ebp
 9d8:	8b 55 08             	mov    0x8(%ebp),%edx
 9db:	90                   	nop
 9dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 9e0:	89 c8                	mov    %ecx,%eax
 9e2:	f0 87 02             	lock xchg %eax,(%edx)
//     panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lock->locked, 1) != 0)
 9e5:	85 c0                	test   %eax,%eax
 9e7:	75 f7                	jne    9e0 <lock_acquire+0x10>
    ;

}
 9e9:	5d                   	pop    %ebp
 9ea:	c3                   	ret    
 9eb:	90                   	nop
 9ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000009f0 <lock_release>:

// Release the lock.
void
lock_release(struct lock_t *lock)
{
 9f0:	55                   	push   %ebp
 9f1:	31 c0                	xor    %eax,%eax
 9f3:	89 e5                	mov    %esp,%ebp
 9f5:	8b 55 08             	mov    0x8(%ebp),%edx
 9f8:	f0 87 02             	lock xchg %eax,(%edx)
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lock->locked, 0);

}
 9fb:	5d                   	pop    %ebp
 9fc:	c3                   	ret    
 9fd:	8d 76 00             	lea    0x0(%esi),%esi

00000a00 <lock_holding>:

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
 a00:	55                   	push   %ebp
 a01:	89 e5                	mov    %esp,%ebp
 a03:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked;
 a06:	5d                   	pop    %ebp
}

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
 a07:	8b 00                	mov    (%eax),%eax
  return lock->locked;
 a09:	c3                   	ret    
