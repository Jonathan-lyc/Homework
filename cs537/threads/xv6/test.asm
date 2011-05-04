
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <ll_add>:
};

struct node *head;

void
ll_add(int i){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  struct node *n;
  n = (struct node *)malloc(sizeof(struct node));
   6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
   d:	e8 2e 07 00 00       	call   740 <malloc>
  n->data = i;
  12:	8b 55 08             	mov    0x8(%ebp),%edx
  n->next = 0;
  15:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

void
ll_add(int i){
  struct node *n;
  n = (struct node *)malloc(sizeof(struct node));
  n->data = i;
  1c:	89 10                	mov    %edx,(%eax)
  n->next = 0;
  if (head == 0) {
  1e:	8b 15 dc 08 00 00    	mov    0x8dc,%edx
  24:	85 d2                	test   %edx,%edx
  26:	74 10                	je     38 <ll_add+0x38>
    head = n;
  } else {
    struct node *curr = head;
/*    printf(1, "i = %d", i);*/
    while(curr->next != 0) {
  28:	89 d1                	mov    %edx,%ecx
  2a:	8b 52 04             	mov    0x4(%edx),%edx
  2d:	85 d2                	test   %edx,%edx
  2f:	75 f7                	jne    28 <ll_add+0x28>
/*      printf(1, "next! i = %d", i);*/
      curr = curr->next;
    }
    curr->next = n;
  31:	89 41 04             	mov    %eax,0x4(%ecx)
/*    printf(1, "currnext = %d\n", curr->next);*/
  }
}
  34:	c9                   	leave  
  35:	c3                   	ret    
  36:	66 90                	xchg   %ax,%ax
  struct node *n;
  n = (struct node *)malloc(sizeof(struct node));
  n->data = i;
  n->next = 0;
  if (head == 0) {
    head = n;
  38:	a3 dc 08 00 00       	mov    %eax,0x8dc
      curr = curr->next;
    }
    curr->next = n;
/*    printf(1, "currnext = %d\n", curr->next);*/
  }
}
  3d:	c9                   	leave  
  3e:	c3                   	ret    
  3f:	90                   	nop

00000040 <ll_coolj>:
  while(n != 0) {
    printf(1, "%d\n", n->data);
    n = n->next;
  }
}
void ll_coolj(){
  40:	55                   	push   %ebp
  struct node *n;
  n = head;
  int i = 0;
  while(n != 0) {
  41:	31 d2                	xor    %edx,%edx
  while(n != 0) {
    printf(1, "%d\n", n->data);
    n = n->next;
  }
}
void ll_coolj(){
  43:	89 e5                	mov    %esp,%ebp
  45:	83 ec 18             	sub    $0x18,%esp
  struct node *n;
  n = head;
  48:	a1 dc 08 00 00       	mov    0x8dc,%eax
  int i = 0;
  while(n != 0) {
  4d:	85 c0                	test   %eax,%eax
  4f:	74 10                	je     61 <ll_coolj+0x21>
  51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    i += n->data;
  58:	03 10                	add    (%eax),%edx
    n = n->next;
  5a:	8b 40 04             	mov    0x4(%eax),%eax
}
void ll_coolj(){
  struct node *n;
  n = head;
  int i = 0;
  while(n != 0) {
  5d:	85 c0                	test   %eax,%eax
  5f:	75 f7                	jne    58 <ll_coolj+0x18>
    i += n->data;
    n = n->next;
  }
  printf(1, "total = %d", i);
  61:	89 54 24 08          	mov    %edx,0x8(%esp)
  65:	c7 44 24 04 87 08 00 	movl   $0x887,0x4(%esp)
  6c:	00 
  6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  74:	e8 37 04 00 00       	call   4b0 <printf>
  79:	c9                   	leave  
  7a:	c3                   	ret    
  7b:	90                   	nop
  7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000080 <ll_print>:
    curr->next = n;
/*    printf(1, "currnext = %d\n", curr->next);*/
  }
}

void ll_print(){
  80:	55                   	push   %ebp
  81:	89 e5                	mov    %esp,%ebp
  83:	53                   	push   %ebx
  84:	83 ec 14             	sub    $0x14,%esp
  struct node *n;
  n = head;
  87:	8b 1d dc 08 00 00    	mov    0x8dc,%ebx
  while(n != 0) {
  8d:	85 db                	test   %ebx,%ebx
  8f:	74 28                	je     b9 <ll_print+0x39>
  91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    printf(1, "%d\n", n->data);
  98:	8b 03                	mov    (%ebx),%eax
  9a:	c7 44 24 04 a0 08 00 	movl   $0x8a0,0x4(%esp)
  a1:	00 
  a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  ad:	e8 fe 03 00 00       	call   4b0 <printf>
    n = n->next;
  b2:	8b 5b 04             	mov    0x4(%ebx),%ebx
}

void ll_print(){
  struct node *n;
  n = head;
  while(n != 0) {
  b5:	85 db                	test   %ebx,%ebx
  b7:	75 df                	jne    98 <ll_print+0x18>
    printf(1, "%d\n", n->data);
    n = n->next;
  }
}
  b9:	83 c4 14             	add    $0x14,%esp
  bc:	5b                   	pop    %ebx
  bd:	5d                   	pop    %ebp
  be:	c3                   	ret    
  bf:	90                   	nop

000000c0 <main>:
#include "user.h"
#include "linkedlist.h"
#include "thread.h"

int
main (int argc, char* argv[]) {
  c0:	55                   	push   %ebp
  c1:	89 e5                	mov    %esp,%ebp
  c3:	83 e4 f0             	and    $0xfffffff0,%esp
  c6:	83 ec 20             	sub    $0x20,%esp
  c9:	89 5c 24 18          	mov    %ebx,0x18(%esp)
  cd:	89 74 24 1c          	mov    %esi,0x1c(%esp)
/*  printf(1, "Beginning Test\n");*/
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
  int parent = getpid();
  d1:	e8 12 03 00 00       	call   3e8 <getpid>
  char* stack = malloc(4096);
  d6:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
main (int argc, char* argv[]) {
/*  printf(1, "Beginning Test\n");*/
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
  int parent = getpid();
  dd:	89 c6                	mov    %eax,%esi
  char* stack = malloc(4096);
  df:	e8 5c 06 00 00       	call   740 <malloc>
/*  printf(1, "stack outside %d\n", stack[0]);*/
  clone(stack, 4096);
  e4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  eb:	00 
  ec:	89 04 24             	mov    %eax,(%esp)
  ef:	e8 14 03 00 00       	call   408 <clone>
//     ll_add(i);
//   }
//   ll_print();
//   ll_coolj();

  int pid = getpid();
  f4:	e8 ef 02 00 00       	call   3e8 <getpid>
    if (pid == parent) {
  f9:	39 c6                	cmp    %eax,%esi
//     ll_add(i);
//   }
//   ll_print();
//   ll_coolj();

  int pid = getpid();
  fb:	89 c3                	mov    %eax,%ebx
    if (pid == parent) {
  fd:	74 21                	je     120 <main+0x60>
        int ret = wait();
        printf(1, "wait returned %d\n", ret);
    }

  printf(1, "pid: %d exiting\n", pid);
  ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 103:	c7 44 24 04 a4 08 00 	movl   $0x8a4,0x4(%esp)
 10a:	00 
 10b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 112:	e8 99 03 00 00       	call   4b0 <printf>
  exit();
 117:	e8 4c 02 00 00       	call   368 <exit>
 11c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
//   ll_print();
//   ll_coolj();

  int pid = getpid();
    if (pid == parent) {
        int ret = wait();
 120:	e8 4b 02 00 00       	call   370 <wait>
        printf(1, "wait returned %d\n", ret);
 125:	c7 44 24 04 92 08 00 	movl   $0x892,0x4(%esp)
 12c:	00 
 12d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 134:	89 44 24 08          	mov    %eax,0x8(%esp)
 138:	e8 73 03 00 00       	call   4b0 <printf>
 13d:	eb c0                	jmp    ff <main+0x3f>
 13f:	90                   	nop

00000140 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 140:	55                   	push   %ebp
 141:	31 d2                	xor    %edx,%edx
 143:	89 e5                	mov    %esp,%ebp
 145:	8b 45 08             	mov    0x8(%ebp),%eax
 148:	53                   	push   %ebx
 149:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 14c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 150:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 154:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 157:	83 c2 01             	add    $0x1,%edx
 15a:	84 c9                	test   %cl,%cl
 15c:	75 f2                	jne    150 <strcpy+0x10>
    ;
  return os;
}
 15e:	5b                   	pop    %ebx
 15f:	5d                   	pop    %ebp
 160:	c3                   	ret    
 161:	eb 0d                	jmp    170 <strcmp>
 163:	90                   	nop
 164:	90                   	nop
 165:	90                   	nop
 166:	90                   	nop
 167:	90                   	nop
 168:	90                   	nop
 169:	90                   	nop
 16a:	90                   	nop
 16b:	90                   	nop
 16c:	90                   	nop
 16d:	90                   	nop
 16e:	90                   	nop
 16f:	90                   	nop

00000170 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	53                   	push   %ebx
 174:	8b 4d 08             	mov    0x8(%ebp),%ecx
 177:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 17a:	0f b6 01             	movzbl (%ecx),%eax
 17d:	84 c0                	test   %al,%al
 17f:	75 14                	jne    195 <strcmp+0x25>
 181:	eb 25                	jmp    1a8 <strcmp+0x38>
 183:	90                   	nop
 184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
 188:	83 c1 01             	add    $0x1,%ecx
 18b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 18e:	0f b6 01             	movzbl (%ecx),%eax
 191:	84 c0                	test   %al,%al
 193:	74 13                	je     1a8 <strcmp+0x38>
 195:	0f b6 1a             	movzbl (%edx),%ebx
 198:	38 d8                	cmp    %bl,%al
 19a:	74 ec                	je     188 <strcmp+0x18>
 19c:	0f b6 db             	movzbl %bl,%ebx
 19f:	0f b6 c0             	movzbl %al,%eax
 1a2:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 1a4:	5b                   	pop    %ebx
 1a5:	5d                   	pop    %ebp
 1a6:	c3                   	ret    
 1a7:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1a8:	0f b6 1a             	movzbl (%edx),%ebx
 1ab:	31 c0                	xor    %eax,%eax
 1ad:	0f b6 db             	movzbl %bl,%ebx
 1b0:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 1b2:	5b                   	pop    %ebx
 1b3:	5d                   	pop    %ebp
 1b4:	c3                   	ret    
 1b5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001c0 <strlen>:

uint
strlen(char *s)
{
 1c0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
 1c1:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 1c3:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
 1c5:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 1c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1ca:	80 39 00             	cmpb   $0x0,(%ecx)
 1cd:	74 0c                	je     1db <strlen+0x1b>
 1cf:	90                   	nop
 1d0:	83 c2 01             	add    $0x1,%edx
 1d3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1d7:	89 d0                	mov    %edx,%eax
 1d9:	75 f5                	jne    1d0 <strlen+0x10>
    ;
  return n;
}
 1db:	5d                   	pop    %ebp
 1dc:	c3                   	ret    
 1dd:	8d 76 00             	lea    0x0(%esi),%esi

000001e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	8b 55 08             	mov    0x8(%ebp),%edx
 1e6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ed:	89 d7                	mov    %edx,%edi
 1ef:	fc                   	cld    
 1f0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1f2:	89 d0                	mov    %edx,%eax
 1f4:	5f                   	pop    %edi
 1f5:	5d                   	pop    %ebp
 1f6:	c3                   	ret    
 1f7:	89 f6                	mov    %esi,%esi
 1f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
 203:	8b 45 08             	mov    0x8(%ebp),%eax
 206:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 20a:	0f b6 10             	movzbl (%eax),%edx
 20d:	84 d2                	test   %dl,%dl
 20f:	75 11                	jne    222 <strchr+0x22>
 211:	eb 15                	jmp    228 <strchr+0x28>
 213:	90                   	nop
 214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 218:	83 c0 01             	add    $0x1,%eax
 21b:	0f b6 10             	movzbl (%eax),%edx
 21e:	84 d2                	test   %dl,%dl
 220:	74 06                	je     228 <strchr+0x28>
    if(*s == c)
 222:	38 ca                	cmp    %cl,%dl
 224:	75 f2                	jne    218 <strchr+0x18>
      return (char*)s;
  return 0;
}
 226:	5d                   	pop    %ebp
 227:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 228:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 22a:	5d                   	pop    %ebp
 22b:	90                   	nop
 22c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 230:	c3                   	ret    
 231:	eb 0d                	jmp    240 <atoi>
 233:	90                   	nop
 234:	90                   	nop
 235:	90                   	nop
 236:	90                   	nop
 237:	90                   	nop
 238:	90                   	nop
 239:	90                   	nop
 23a:	90                   	nop
 23b:	90                   	nop
 23c:	90                   	nop
 23d:	90                   	nop
 23e:	90                   	nop
 23f:	90                   	nop

00000240 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 240:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 241:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 243:	89 e5                	mov    %esp,%ebp
 245:	8b 4d 08             	mov    0x8(%ebp),%ecx
 248:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 249:	0f b6 11             	movzbl (%ecx),%edx
 24c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 24f:	80 fb 09             	cmp    $0x9,%bl
 252:	77 1c                	ja     270 <atoi+0x30>
 254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 258:	0f be d2             	movsbl %dl,%edx
 25b:	83 c1 01             	add    $0x1,%ecx
 25e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 261:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 265:	0f b6 11             	movzbl (%ecx),%edx
 268:	8d 5a d0             	lea    -0x30(%edx),%ebx
 26b:	80 fb 09             	cmp    $0x9,%bl
 26e:	76 e8                	jbe    258 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 270:	5b                   	pop    %ebx
 271:	5d                   	pop    %ebp
 272:	c3                   	ret    
 273:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 279:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000280 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 280:	55                   	push   %ebp
 281:	89 e5                	mov    %esp,%ebp
 283:	56                   	push   %esi
 284:	8b 45 08             	mov    0x8(%ebp),%eax
 287:	53                   	push   %ebx
 288:	8b 5d 10             	mov    0x10(%ebp),%ebx
 28b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 28e:	85 db                	test   %ebx,%ebx
 290:	7e 14                	jle    2a6 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
 292:	31 d2                	xor    %edx,%edx
 294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 298:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 29c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 29f:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2a2:	39 da                	cmp    %ebx,%edx
 2a4:	75 f2                	jne    298 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 2a6:	5b                   	pop    %ebx
 2a7:	5e                   	pop    %esi
 2a8:	5d                   	pop    %ebp
 2a9:	c3                   	ret    
 2aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

000002b0 <stat>:
  return buf;
}

int
stat(char *n, struct stat *st)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(char *n, struct stat *st)
{
 2b9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 2bc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 2bf:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2cb:	00 
 2cc:	89 04 24             	mov    %eax,(%esp)
 2cf:	e8 d4 00 00 00       	call   3a8 <open>
  if(fd < 0)
 2d4:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d6:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 2d8:	78 19                	js     2f3 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 2da:	8b 45 0c             	mov    0xc(%ebp),%eax
 2dd:	89 1c 24             	mov    %ebx,(%esp)
 2e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e4:	e8 d7 00 00 00       	call   3c0 <fstat>
  close(fd);
 2e9:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 2ec:	89 c6                	mov    %eax,%esi
  close(fd);
 2ee:	e8 9d 00 00 00       	call   390 <close>
  return r;
}
 2f3:	89 f0                	mov    %esi,%eax
 2f5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 2f8:	8b 75 fc             	mov    -0x4(%ebp),%esi
 2fb:	89 ec                	mov    %ebp,%esp
 2fd:	5d                   	pop    %ebp
 2fe:	c3                   	ret    
 2ff:	90                   	nop

00000300 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	57                   	push   %edi
 304:	56                   	push   %esi
 305:	31 f6                	xor    %esi,%esi
 307:	53                   	push   %ebx
 308:	83 ec 2c             	sub    $0x2c,%esp
 30b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 30e:	eb 06                	jmp    316 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 310:	3c 0a                	cmp    $0xa,%al
 312:	74 39                	je     34d <gets+0x4d>
 314:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 316:	8d 5e 01             	lea    0x1(%esi),%ebx
 319:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 31c:	7d 31                	jge    34f <gets+0x4f>
    cc = read(0, &c, 1);
 31e:	8d 45 e7             	lea    -0x19(%ebp),%eax
 321:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 328:	00 
 329:	89 44 24 04          	mov    %eax,0x4(%esp)
 32d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 334:	e8 47 00 00 00       	call   380 <read>
    if(cc < 1)
 339:	85 c0                	test   %eax,%eax
 33b:	7e 12                	jle    34f <gets+0x4f>
      break;
    buf[i++] = c;
 33d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 341:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 345:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 349:	3c 0d                	cmp    $0xd,%al
 34b:	75 c3                	jne    310 <gets+0x10>
 34d:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 34f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 353:	89 f8                	mov    %edi,%eax
 355:	83 c4 2c             	add    $0x2c,%esp
 358:	5b                   	pop    %ebx
 359:	5e                   	pop    %esi
 35a:	5f                   	pop    %edi
 35b:	5d                   	pop    %ebp
 35c:	c3                   	ret    
 35d:	90                   	nop
 35e:	90                   	nop
 35f:	90                   	nop

00000360 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 360:	b8 01 00 00 00       	mov    $0x1,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <exit>:
SYSCALL(exit)
 368:	b8 02 00 00 00       	mov    $0x2,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <wait>:
SYSCALL(wait)
 370:	b8 03 00 00 00       	mov    $0x3,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <pipe>:
SYSCALL(pipe)
 378:	b8 04 00 00 00       	mov    $0x4,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <read>:
SYSCALL(read)
 380:	b8 06 00 00 00       	mov    $0x6,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <write>:
SYSCALL(write)
 388:	b8 05 00 00 00       	mov    $0x5,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <close>:
SYSCALL(close)
 390:	b8 07 00 00 00       	mov    $0x7,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <kill>:
SYSCALL(kill)
 398:	b8 08 00 00 00       	mov    $0x8,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <exec>:
SYSCALL(exec)
 3a0:	b8 09 00 00 00       	mov    $0x9,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <open>:
SYSCALL(open)
 3a8:	b8 0a 00 00 00       	mov    $0xa,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <mknod>:
SYSCALL(mknod)
 3b0:	b8 0b 00 00 00       	mov    $0xb,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <unlink>:
SYSCALL(unlink)
 3b8:	b8 0c 00 00 00       	mov    $0xc,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <fstat>:
SYSCALL(fstat)
 3c0:	b8 0d 00 00 00       	mov    $0xd,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <link>:
SYSCALL(link)
 3c8:	b8 0e 00 00 00       	mov    $0xe,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <mkdir>:
SYSCALL(mkdir)
 3d0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <chdir>:
SYSCALL(chdir)
 3d8:	b8 10 00 00 00       	mov    $0x10,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <dup>:
SYSCALL(dup)
 3e0:	b8 11 00 00 00       	mov    $0x11,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <getpid>:
SYSCALL(getpid)
 3e8:	b8 12 00 00 00       	mov    $0x12,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <sbrk>:
SYSCALL(sbrk)
 3f0:	b8 13 00 00 00       	mov    $0x13,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <sleep>:
SYSCALL(sleep)
 3f8:	b8 14 00 00 00       	mov    $0x14,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <uptime>:
SYSCALL(uptime)
 400:	b8 15 00 00 00       	mov    $0x15,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <clone>:
SYSCALL(clone)
 408:	b8 16 00 00 00       	mov    $0x16,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 410:	55                   	push   %ebp
 411:	89 e5                	mov    %esp,%ebp
 413:	57                   	push   %edi
 414:	89 cf                	mov    %ecx,%edi
 416:	56                   	push   %esi
 417:	89 c6                	mov    %eax,%esi
 419:	53                   	push   %ebx
 41a:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 41d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 420:	85 c9                	test   %ecx,%ecx
 422:	74 04                	je     428 <printint+0x18>
 424:	85 d2                	test   %edx,%edx
 426:	78 70                	js     498 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 428:	89 d0                	mov    %edx,%eax
 42a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 431:	31 c9                	xor    %ecx,%ecx
 433:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 436:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 438:	31 d2                	xor    %edx,%edx
 43a:	f7 f7                	div    %edi
 43c:	0f b6 92 bc 08 00 00 	movzbl 0x8bc(%edx),%edx
 443:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 446:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 449:	85 c0                	test   %eax,%eax
 44b:	75 eb                	jne    438 <printint+0x28>
  if(neg)
 44d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 450:	85 c0                	test   %eax,%eax
 452:	74 08                	je     45c <printint+0x4c>
    buf[i++] = '-';
 454:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 459:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 45c:	8d 79 ff             	lea    -0x1(%ecx),%edi
 45f:	01 fb                	add    %edi,%ebx
 461:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 468:	0f b6 03             	movzbl (%ebx),%eax
 46b:	83 ef 01             	sub    $0x1,%edi
 46e:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 471:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 478:	00 
 479:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 47c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 47f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 482:	89 44 24 04          	mov    %eax,0x4(%esp)
 486:	e8 fd fe ff ff       	call   388 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 48b:	83 ff ff             	cmp    $0xffffffff,%edi
 48e:	75 d8                	jne    468 <printint+0x58>
    putc(fd, buf[i]);
}
 490:	83 c4 4c             	add    $0x4c,%esp
 493:	5b                   	pop    %ebx
 494:	5e                   	pop    %esi
 495:	5f                   	pop    %edi
 496:	5d                   	pop    %ebp
 497:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 498:	89 d0                	mov    %edx,%eax
 49a:	f7 d8                	neg    %eax
 49c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 4a3:	eb 8c                	jmp    431 <printint+0x21>
 4a5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 4a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000004b0 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	57                   	push   %edi
 4b4:	56                   	push   %esi
 4b5:	53                   	push   %ebx
 4b6:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4bc:	0f b6 10             	movzbl (%eax),%edx
 4bf:	84 d2                	test   %dl,%dl
 4c1:	0f 84 c9 00 00 00    	je     590 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 4c7:	8d 4d 10             	lea    0x10(%ebp),%ecx
 4ca:	31 ff                	xor    %edi,%edi
 4cc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 4cf:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 4d1:	8d 75 e7             	lea    -0x19(%ebp),%esi
 4d4:	eb 1e                	jmp    4f4 <printf+0x44>
 4d6:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 4d8:	83 fa 25             	cmp    $0x25,%edx
 4db:	0f 85 b7 00 00 00    	jne    598 <printf+0xe8>
 4e1:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4e5:	83 c3 01             	add    $0x1,%ebx
 4e8:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 4ec:	84 d2                	test   %dl,%dl
 4ee:	0f 84 9c 00 00 00    	je     590 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 4f4:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 4f6:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 4f9:	74 dd                	je     4d8 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fb:	83 ff 25             	cmp    $0x25,%edi
 4fe:	75 e5                	jne    4e5 <printf+0x35>
      if(c == 'd'){
 500:	83 fa 64             	cmp    $0x64,%edx
 503:	0f 84 47 01 00 00    	je     650 <printf+0x1a0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 509:	83 fa 70             	cmp    $0x70,%edx
 50c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 510:	0f 84 aa 00 00 00    	je     5c0 <printf+0x110>
 516:	83 fa 78             	cmp    $0x78,%edx
 519:	0f 84 a1 00 00 00    	je     5c0 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 51f:	83 fa 73             	cmp    $0x73,%edx
 522:	0f 84 c0 00 00 00    	je     5e8 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 528:	83 fa 63             	cmp    $0x63,%edx
 52b:	90                   	nop
 52c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 530:	0f 84 42 01 00 00    	je     678 <printf+0x1c8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 536:	83 fa 25             	cmp    $0x25,%edx
 539:	0f 84 01 01 00 00    	je     640 <printf+0x190>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 53f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 542:	89 55 cc             	mov    %edx,-0x34(%ebp)
 545:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 549:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 550:	00 
 551:	89 74 24 04          	mov    %esi,0x4(%esp)
 555:	89 0c 24             	mov    %ecx,(%esp)
 558:	e8 2b fe ff ff       	call   388 <write>
 55d:	8b 55 cc             	mov    -0x34(%ebp),%edx
 560:	88 55 e7             	mov    %dl,-0x19(%ebp)
 563:	8b 45 08             	mov    0x8(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 566:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 569:	31 ff                	xor    %edi,%edi
 56b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 572:	00 
 573:	89 74 24 04          	mov    %esi,0x4(%esp)
 577:	89 04 24             	mov    %eax,(%esp)
 57a:	e8 09 fe ff ff       	call   388 <write>
 57f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 582:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 586:	84 d2                	test   %dl,%dl
 588:	0f 85 66 ff ff ff    	jne    4f4 <printf+0x44>
 58e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 590:	83 c4 3c             	add    $0x3c,%esp
 593:	5b                   	pop    %ebx
 594:	5e                   	pop    %esi
 595:	5f                   	pop    %edi
 596:	5d                   	pop    %ebp
 597:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 598:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 59b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 59e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5a5:	00 
 5a6:	89 74 24 04          	mov    %esi,0x4(%esp)
 5aa:	89 04 24             	mov    %eax,(%esp)
 5ad:	e8 d6 fd ff ff       	call   388 <write>
 5b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b5:	e9 2b ff ff ff       	jmp    4e5 <printf+0x35>
 5ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 5c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 5c3:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 5c8:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 5ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 5d1:	8b 10                	mov    (%eax),%edx
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
 5d6:	e8 35 fe ff ff       	call   410 <printint>
 5db:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 5de:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 5e2:	e9 fe fe ff ff       	jmp    4e5 <printf+0x35>
 5e7:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 5e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        ap++;
        if(s == 0)
 5eb:	b9 b5 08 00 00       	mov    $0x8b5,%ecx
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
 5f0:	8b 3a                	mov    (%edx),%edi
        ap++;
 5f2:	83 c2 04             	add    $0x4,%edx
 5f5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 5f8:	85 ff                	test   %edi,%edi
 5fa:	0f 44 f9             	cmove  %ecx,%edi
          s = "(null)";
        while(*s != 0){
 5fd:	0f b6 17             	movzbl (%edi),%edx
 600:	84 d2                	test   %dl,%dl
 602:	74 33                	je     637 <printf+0x187>
 604:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 607:	8b 5d 08             	mov    0x8(%ebp),%ebx
 60a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
          putc(fd, *s);
          s++;
 610:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 613:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 616:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 61d:	00 
 61e:	89 74 24 04          	mov    %esi,0x4(%esp)
 622:	89 1c 24             	mov    %ebx,(%esp)
 625:	e8 5e fd ff ff       	call   388 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 62a:	0f b6 17             	movzbl (%edi),%edx
 62d:	84 d2                	test   %dl,%dl
 62f:	75 df                	jne    610 <printf+0x160>
 631:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 634:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 637:	31 ff                	xor    %edi,%edi
 639:	e9 a7 fe ff ff       	jmp    4e5 <printf+0x35>
 63e:	66 90                	xchg   %ax,%ax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 640:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 644:	e9 1a ff ff ff       	jmp    563 <printf+0xb3>
 649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 650:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 653:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 658:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 65b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 662:	8b 10                	mov    (%eax),%edx
 664:	8b 45 08             	mov    0x8(%ebp),%eax
 667:	e8 a4 fd ff ff       	call   410 <printint>
 66c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 66f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 673:	e9 6d fe ff ff       	jmp    4e5 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 678:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        putc(fd, *ap);
        ap++;
 67b:	31 ff                	xor    %edi,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 67d:	8b 4d 08             	mov    0x8(%ebp),%ecx
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 680:	8b 02                	mov    (%edx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 682:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 689:	00 
 68a:	89 74 24 04          	mov    %esi,0x4(%esp)
 68e:	89 0c 24             	mov    %ecx,(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 691:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 694:	e8 ef fc ff ff       	call   388 <write>
 699:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 69c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 6a0:	e9 40 fe ff ff       	jmp    4e5 <printf+0x35>
 6a5:	90                   	nop
 6a6:	90                   	nop
 6a7:	90                   	nop
 6a8:	90                   	nop
 6a9:	90                   	nop
 6aa:	90                   	nop
 6ab:	90                   	nop
 6ac:	90                   	nop
 6ad:	90                   	nop
 6ae:	90                   	nop
 6af:	90                   	nop

000006b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b1:	a1 d8 08 00 00       	mov    0x8d8,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b6:	89 e5                	mov    %esp,%ebp
 6b8:	57                   	push   %edi
 6b9:	56                   	push   %esi
 6ba:	53                   	push   %ebx
 6bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6be:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c1:	39 c8                	cmp    %ecx,%eax
 6c3:	73 1d                	jae    6e2 <free+0x32>
 6c5:	8d 76 00             	lea    0x0(%esi),%esi
 6c8:	8b 10                	mov    (%eax),%edx
 6ca:	39 d1                	cmp    %edx,%ecx
 6cc:	72 1a                	jb     6e8 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ce:	39 d0                	cmp    %edx,%eax
 6d0:	72 08                	jb     6da <free+0x2a>
 6d2:	39 c8                	cmp    %ecx,%eax
 6d4:	72 12                	jb     6e8 <free+0x38>
 6d6:	39 d1                	cmp    %edx,%ecx
 6d8:	72 0e                	jb     6e8 <free+0x38>
 6da:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6dc:	39 c8                	cmp    %ecx,%eax
 6de:	66 90                	xchg   %ax,%ax
 6e0:	72 e6                	jb     6c8 <free+0x18>
 6e2:	8b 10                	mov    (%eax),%edx
 6e4:	eb e8                	jmp    6ce <free+0x1e>
 6e6:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6e8:	8b 71 04             	mov    0x4(%ecx),%esi
 6eb:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6ee:	39 d7                	cmp    %edx,%edi
 6f0:	74 19                	je     70b <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6f2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6f5:	8b 50 04             	mov    0x4(%eax),%edx
 6f8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6fb:	39 ce                	cmp    %ecx,%esi
 6fd:	74 23                	je     722 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 6ff:	89 08                	mov    %ecx,(%eax)
  freep = p;
 701:	a3 d8 08 00 00       	mov    %eax,0x8d8
}
 706:	5b                   	pop    %ebx
 707:	5e                   	pop    %esi
 708:	5f                   	pop    %edi
 709:	5d                   	pop    %ebp
 70a:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 70b:	03 72 04             	add    0x4(%edx),%esi
 70e:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 711:	8b 10                	mov    (%eax),%edx
 713:	8b 12                	mov    (%edx),%edx
 715:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 718:	8b 50 04             	mov    0x4(%eax),%edx
 71b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 71e:	39 ce                	cmp    %ecx,%esi
 720:	75 dd                	jne    6ff <free+0x4f>
    p->s.size += bp->s.size;
 722:	03 51 04             	add    0x4(%ecx),%edx
 725:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 728:	8b 53 f8             	mov    -0x8(%ebx),%edx
 72b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 72d:	a3 d8 08 00 00       	mov    %eax,0x8d8
}
 732:	5b                   	pop    %ebx
 733:	5e                   	pop    %esi
 734:	5f                   	pop    %edi
 735:	5d                   	pop    %ebp
 736:	c3                   	ret    
 737:	89 f6                	mov    %esi,%esi
 739:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000740 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 740:	55                   	push   %ebp
 741:	89 e5                	mov    %esp,%ebp
 743:	57                   	push   %edi
 744:	56                   	push   %esi
 745:	53                   	push   %ebx
 746:	83 ec 2c             	sub    $0x2c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 749:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 74c:	8b 0d d8 08 00 00    	mov    0x8d8,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 752:	83 c3 07             	add    $0x7,%ebx
 755:	c1 eb 03             	shr    $0x3,%ebx
 758:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 75b:	85 c9                	test   %ecx,%ecx
 75d:	0f 84 9b 00 00 00    	je     7fe <malloc+0xbe>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 763:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 765:	8b 50 04             	mov    0x4(%eax),%edx
 768:	39 d3                	cmp    %edx,%ebx
 76a:	76 27                	jbe    793 <malloc+0x53>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 76c:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 773:	be 00 80 00 00       	mov    $0x8000,%esi
 778:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 77b:	90                   	nop
 77c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 780:	3b 05 d8 08 00 00    	cmp    0x8d8,%eax
 786:	74 30                	je     7b8 <malloc+0x78>
 788:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 78c:	8b 50 04             	mov    0x4(%eax),%edx
 78f:	39 d3                	cmp    %edx,%ebx
 791:	77 ed                	ja     780 <malloc+0x40>
      if(p->s.size == nunits)
 793:	39 d3                	cmp    %edx,%ebx
 795:	74 61                	je     7f8 <malloc+0xb8>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 797:	29 da                	sub    %ebx,%edx
 799:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 79c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 79f:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 7a2:	89 0d d8 08 00 00    	mov    %ecx,0x8d8
      return (void*)(p + 1);
 7a8:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7ab:	83 c4 2c             	add    $0x2c,%esp
 7ae:	5b                   	pop    %ebx
 7af:	5e                   	pop    %esi
 7b0:	5f                   	pop    %edi
 7b1:	5d                   	pop    %ebp
 7b2:	c3                   	ret    
 7b3:	90                   	nop
 7b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 7b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7bb:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
 7c1:	bf 00 10 00 00       	mov    $0x1000,%edi
 7c6:	0f 43 fb             	cmovae %ebx,%edi
 7c9:	0f 42 c6             	cmovb  %esi,%eax
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 7cc:	89 04 24             	mov    %eax,(%esp)
 7cf:	e8 1c fc ff ff       	call   3f0 <sbrk>
  if(p == (char*)-1)
 7d4:	83 f8 ff             	cmp    $0xffffffff,%eax
 7d7:	74 18                	je     7f1 <malloc+0xb1>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 7d9:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 7dc:	83 c0 08             	add    $0x8,%eax
 7df:	89 04 24             	mov    %eax,(%esp)
 7e2:	e8 c9 fe ff ff       	call   6b0 <free>
  return freep;
 7e7:	8b 0d d8 08 00 00    	mov    0x8d8,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 7ed:	85 c9                	test   %ecx,%ecx
 7ef:	75 99                	jne    78a <malloc+0x4a>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 7f1:	31 c0                	xor    %eax,%eax
 7f3:	eb b6                	jmp    7ab <malloc+0x6b>
 7f5:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 7f8:	8b 10                	mov    (%eax),%edx
 7fa:	89 11                	mov    %edx,(%ecx)
 7fc:	eb a4                	jmp    7a2 <malloc+0x62>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 7fe:	c7 05 d8 08 00 00 d0 	movl   $0x8d0,0x8d8
 805:	08 00 00 
    base.s.size = 0;
 808:	b9 d0 08 00 00       	mov    $0x8d0,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 80d:	c7 05 d0 08 00 00 d0 	movl   $0x8d0,0x8d0
 814:	08 00 00 
    base.s.size = 0;
 817:	c7 05 d4 08 00 00 00 	movl   $0x0,0x8d4
 81e:	00 00 00 
 821:	e9 3d ff ff ff       	jmp    763 <malloc+0x23>
 826:	90                   	nop
 827:	90                   	nop
 828:	90                   	nop
 829:	90                   	nop
 82a:	90                   	nop
 82b:	90                   	nop
 82c:	90                   	nop
 82d:	90                   	nop
 82e:	90                   	nop
 82f:	90                   	nop

00000830 <lock_init>:
#include "proc.h"
#include "thread.h"

void
lock_init(struct lock_t *lock)
{
 830:	55                   	push   %ebp
 831:	89 e5                	mov    %esp,%ebp
  lock->locked = 0;
 833:	8b 45 08             	mov    0x8(%ebp),%eax
 836:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 83c:	5d                   	pop    %ebp
 83d:	c3                   	ret    
 83e:	66 90                	xchg   %ax,%ax

00000840 <lock_acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
lock_acquire(struct lock_t *lock)
{
 840:	55                   	push   %ebp
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
 841:	b9 01 00 00 00       	mov    $0x1,%ecx
 846:	89 e5                	mov    %esp,%ebp
 848:	8b 55 08             	mov    0x8(%ebp),%edx
 84b:	90                   	nop
 84c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 850:	89 c8                	mov    %ecx,%eax
 852:	f0 87 02             	lock xchg %eax,(%edx)
//     panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lock->locked, 1) != 0)
 855:	85 c0                	test   %eax,%eax
 857:	75 f7                	jne    850 <lock_acquire+0x10>
    ;

}
 859:	5d                   	pop    %ebp
 85a:	c3                   	ret    
 85b:	90                   	nop
 85c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000860 <lock_release>:

// Release the lock.
void
lock_release(struct lock_t *lock)
{
 860:	55                   	push   %ebp
 861:	31 c0                	xor    %eax,%eax
 863:	89 e5                	mov    %esp,%ebp
 865:	8b 55 08             	mov    0x8(%ebp),%edx
 868:	f0 87 02             	lock xchg %eax,(%edx)
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lock->locked, 0);

}
 86b:	5d                   	pop    %ebp
 86c:	c3                   	ret    
 86d:	8d 76 00             	lea    0x0(%esi),%esi

00000870 <lock_holding>:

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
 870:	55                   	push   %ebp
 871:	89 e5                	mov    %esp,%ebp
 873:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked;
}
 876:	5d                   	pop    %ebp
}

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
 877:	8b 00                	mov    (%eax),%eax
  return lock->locked;
}
 879:	c3                   	ret    
 87a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000880 <thread_create>:

int
thread_create(void *(*start_routine)(void*), void *arg) {
 880:	55                   	push   %ebp
  return 0;
}
 881:	31 c0                	xor    %eax,%eax
{
  return lock->locked;
}

int
thread_create(void *(*start_routine)(void*), void *arg) {
 883:	89 e5                	mov    %esp,%ebp
  return 0;
}
 885:	5d                   	pop    %ebp
 886:	c3                   	ret    
