
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

int
main (int argc, char* argv[]) {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	81 ec 88 00 00 00    	sub    $0x88,%esp
  13:	89 9c 24 84 00 00 00 	mov    %ebx,0x84(%esp)
	int n = 23;
	int counts[n];
  1a:	8d 5c 24 1b          	lea    0x1b(%esp),%ebx
  1e:	83 e3 f0             	and    $0xfffffff0,%ebx
#include "types.h"
#include "stat.h"
#include "user.h"

int
main (int argc, char* argv[]) {
  21:	89 8c 24 80 00 00 00 	mov    %ecx,0x80(%esp)
	int n = 23;
	int counts[n];
	printf(1, "Hello world!\n");
  28:	c7 44 24 04 56 07 00 	movl   $0x756,0x4(%esp)
  2f:	00 
  30:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  37:	e8 a4 03 00 00       	call   3e0 <printf>
	getcount(counts, n);
  3c:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  43:	00 
  44:	89 1c 24             	mov    %ebx,(%esp)
  47:	e8 ec 02 00 00       	call   338 <getcount>
	printf(1, "count 0: %d\n", counts[22]);
  4c:	8b 43 58             	mov    0x58(%ebx),%eax
  4f:	c7 44 24 04 64 07 00 	movl   $0x764,0x4(%esp)
  56:	00 
  57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  62:	e8 79 03 00 00       	call   3e0 <printf>
	exit();
  67:	e8 2c 02 00 00       	call   298 <exit>
  6c:	90                   	nop
  6d:	90                   	nop
  6e:	90                   	nop
  6f:	90                   	nop

00000070 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  70:	55                   	push   %ebp
  71:	31 d2                	xor    %edx,%edx
  73:	89 e5                	mov    %esp,%ebp
  75:	8b 45 08             	mov    0x8(%ebp),%eax
  78:	53                   	push   %ebx
  79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  80:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  84:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  87:	83 c2 01             	add    $0x1,%edx
  8a:	84 c9                	test   %cl,%cl
  8c:	75 f2                	jne    80 <strcpy+0x10>
    ;
  return os;
}
  8e:	5b                   	pop    %ebx
  8f:	5d                   	pop    %ebp
  90:	c3                   	ret    
  91:	eb 0d                	jmp    a0 <strcmp>
  93:	90                   	nop
  94:	90                   	nop
  95:	90                   	nop
  96:	90                   	nop
  97:	90                   	nop
  98:	90                   	nop
  99:	90                   	nop
  9a:	90                   	nop
  9b:	90                   	nop
  9c:	90                   	nop
  9d:	90                   	nop
  9e:	90                   	nop
  9f:	90                   	nop

000000a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a0:	55                   	push   %ebp
  a1:	89 e5                	mov    %esp,%ebp
  a3:	53                   	push   %ebx
  a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  aa:	0f b6 01             	movzbl (%ecx),%eax
  ad:	84 c0                	test   %al,%al
  af:	75 14                	jne    c5 <strcmp+0x25>
  b1:	eb 25                	jmp    d8 <strcmp+0x38>
  b3:	90                   	nop
  b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
  b8:	83 c1 01             	add    $0x1,%ecx
  bb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  be:	0f b6 01             	movzbl (%ecx),%eax
  c1:	84 c0                	test   %al,%al
  c3:	74 13                	je     d8 <strcmp+0x38>
  c5:	0f b6 1a             	movzbl (%edx),%ebx
  c8:	38 d8                	cmp    %bl,%al
  ca:	74 ec                	je     b8 <strcmp+0x18>
  cc:	0f b6 db             	movzbl %bl,%ebx
  cf:	0f b6 c0             	movzbl %al,%eax
  d2:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
  d4:	5b                   	pop    %ebx
  d5:	5d                   	pop    %ebp
  d6:	c3                   	ret    
  d7:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d8:	0f b6 1a             	movzbl (%edx),%ebx
  db:	31 c0                	xor    %eax,%eax
  dd:	0f b6 db             	movzbl %bl,%ebx
  e0:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
  e2:	5b                   	pop    %ebx
  e3:	5d                   	pop    %ebp
  e4:	c3                   	ret    
  e5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000000f0 <strlen>:

uint
strlen(char *s)
{
  f0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
  f1:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
  f3:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
  f5:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
  f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  fa:	80 39 00             	cmpb   $0x0,(%ecx)
  fd:	74 0c                	je     10b <strlen+0x1b>
  ff:	90                   	nop
 100:	83 c2 01             	add    $0x1,%edx
 103:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 107:	89 d0                	mov    %edx,%eax
 109:	75 f5                	jne    100 <strlen+0x10>
    ;
  return n;
}
 10b:	5d                   	pop    %ebp
 10c:	c3                   	ret    
 10d:	8d 76 00             	lea    0x0(%esi),%esi

00000110 <memset>:

void*
memset(void *dst, int c, uint n)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	8b 55 08             	mov    0x8(%ebp),%edx
 116:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 117:	8b 4d 10             	mov    0x10(%ebp),%ecx
 11a:	8b 45 0c             	mov    0xc(%ebp),%eax
 11d:	89 d7                	mov    %edx,%edi
 11f:	fc                   	cld    
 120:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 122:	89 d0                	mov    %edx,%eax
 124:	5f                   	pop    %edi
 125:	5d                   	pop    %ebp
 126:	c3                   	ret    
 127:	89 f6                	mov    %esi,%esi
 129:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000130 <strchr>:

char*
strchr(const char *s, char c)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 13a:	0f b6 10             	movzbl (%eax),%edx
 13d:	84 d2                	test   %dl,%dl
 13f:	75 11                	jne    152 <strchr+0x22>
 141:	eb 15                	jmp    158 <strchr+0x28>
 143:	90                   	nop
 144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 148:	83 c0 01             	add    $0x1,%eax
 14b:	0f b6 10             	movzbl (%eax),%edx
 14e:	84 d2                	test   %dl,%dl
 150:	74 06                	je     158 <strchr+0x28>
    if(*s == c)
 152:	38 ca                	cmp    %cl,%dl
 154:	75 f2                	jne    148 <strchr+0x18>
      return (char*)s;
  return 0;
}
 156:	5d                   	pop    %ebp
 157:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 158:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 15a:	5d                   	pop    %ebp
 15b:	90                   	nop
 15c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 160:	c3                   	ret    
 161:	eb 0d                	jmp    170 <atoi>
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

00000170 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 170:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 171:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 173:	89 e5                	mov    %esp,%ebp
 175:	8b 4d 08             	mov    0x8(%ebp),%ecx
 178:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 179:	0f b6 11             	movzbl (%ecx),%edx
 17c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 17f:	80 fb 09             	cmp    $0x9,%bl
 182:	77 1c                	ja     1a0 <atoi+0x30>
 184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 188:	0f be d2             	movsbl %dl,%edx
 18b:	83 c1 01             	add    $0x1,%ecx
 18e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 191:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 195:	0f b6 11             	movzbl (%ecx),%edx
 198:	8d 5a d0             	lea    -0x30(%edx),%ebx
 19b:	80 fb 09             	cmp    $0x9,%bl
 19e:	76 e8                	jbe    188 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 1a0:	5b                   	pop    %ebx
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    
 1a3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 1a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001b0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	56                   	push   %esi
 1b4:	8b 45 08             	mov    0x8(%ebp),%eax
 1b7:	53                   	push   %ebx
 1b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
 1bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 1be:	85 db                	test   %ebx,%ebx
 1c0:	7e 14                	jle    1d6 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
 1c2:	31 d2                	xor    %edx,%edx
 1c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 1c8:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 1cc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 1cf:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 1d2:	39 da                	cmp    %ebx,%edx
 1d4:	75 f2                	jne    1c8 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 1d6:	5b                   	pop    %ebx
 1d7:	5e                   	pop    %esi
 1d8:	5d                   	pop    %ebp
 1d9:	c3                   	ret    
 1da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

000001e0 <stat>:
  return buf;
}

int
stat(char *n, struct stat *st)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(char *n, struct stat *st)
{
 1e9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 1ec:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 1ef:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1fb:	00 
 1fc:	89 04 24             	mov    %eax,(%esp)
 1ff:	e8 d4 00 00 00       	call   2d8 <open>
  if(fd < 0)
 204:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 206:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 208:	78 19                	js     223 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 20a:	8b 45 0c             	mov    0xc(%ebp),%eax
 20d:	89 1c 24             	mov    %ebx,(%esp)
 210:	89 44 24 04          	mov    %eax,0x4(%esp)
 214:	e8 d7 00 00 00       	call   2f0 <fstat>
  close(fd);
 219:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 21c:	89 c6                	mov    %eax,%esi
  close(fd);
 21e:	e8 9d 00 00 00       	call   2c0 <close>
  return r;
}
 223:	89 f0                	mov    %esi,%eax
 225:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 228:	8b 75 fc             	mov    -0x4(%ebp),%esi
 22b:	89 ec                	mov    %ebp,%esp
 22d:	5d                   	pop    %ebp
 22e:	c3                   	ret    
 22f:	90                   	nop

00000230 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 230:	55                   	push   %ebp
 231:	89 e5                	mov    %esp,%ebp
 233:	57                   	push   %edi
 234:	56                   	push   %esi
 235:	31 f6                	xor    %esi,%esi
 237:	53                   	push   %ebx
 238:	83 ec 2c             	sub    $0x2c,%esp
 23b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	eb 06                	jmp    246 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 240:	3c 0a                	cmp    $0xa,%al
 242:	74 39                	je     27d <gets+0x4d>
 244:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 246:	8d 5e 01             	lea    0x1(%esi),%ebx
 249:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 24c:	7d 31                	jge    27f <gets+0x4f>
    cc = read(0, &c, 1);
 24e:	8d 45 e7             	lea    -0x19(%ebp),%eax
 251:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 258:	00 
 259:	89 44 24 04          	mov    %eax,0x4(%esp)
 25d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 264:	e8 47 00 00 00       	call   2b0 <read>
    if(cc < 1)
 269:	85 c0                	test   %eax,%eax
 26b:	7e 12                	jle    27f <gets+0x4f>
      break;
    buf[i++] = c;
 26d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 271:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 275:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 279:	3c 0d                	cmp    $0xd,%al
 27b:	75 c3                	jne    240 <gets+0x10>
 27d:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 27f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 283:	89 f8                	mov    %edi,%eax
 285:	83 c4 2c             	add    $0x2c,%esp
 288:	5b                   	pop    %ebx
 289:	5e                   	pop    %esi
 28a:	5f                   	pop    %edi
 28b:	5d                   	pop    %ebp
 28c:	c3                   	ret    
 28d:	90                   	nop
 28e:	90                   	nop
 28f:	90                   	nop

00000290 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 290:	b8 01 00 00 00       	mov    $0x1,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <exit>:
SYSCALL(exit)
 298:	b8 02 00 00 00       	mov    $0x2,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <wait>:
SYSCALL(wait)
 2a0:	b8 03 00 00 00       	mov    $0x3,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <pipe>:
SYSCALL(pipe)
 2a8:	b8 04 00 00 00       	mov    $0x4,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <read>:
SYSCALL(read)
 2b0:	b8 06 00 00 00       	mov    $0x6,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <write>:
SYSCALL(write)
 2b8:	b8 05 00 00 00       	mov    $0x5,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <close>:
SYSCALL(close)
 2c0:	b8 07 00 00 00       	mov    $0x7,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <kill>:
SYSCALL(kill)
 2c8:	b8 08 00 00 00       	mov    $0x8,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <exec>:
SYSCALL(exec)
 2d0:	b8 09 00 00 00       	mov    $0x9,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <open>:
SYSCALL(open)
 2d8:	b8 0a 00 00 00       	mov    $0xa,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <mknod>:
SYSCALL(mknod)
 2e0:	b8 0b 00 00 00       	mov    $0xb,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <unlink>:
SYSCALL(unlink)
 2e8:	b8 0c 00 00 00       	mov    $0xc,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <fstat>:
SYSCALL(fstat)
 2f0:	b8 0d 00 00 00       	mov    $0xd,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <link>:
SYSCALL(link)
 2f8:	b8 0e 00 00 00       	mov    $0xe,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <mkdir>:
SYSCALL(mkdir)
 300:	b8 0f 00 00 00       	mov    $0xf,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <chdir>:
SYSCALL(chdir)
 308:	b8 10 00 00 00       	mov    $0x10,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <dup>:
SYSCALL(dup)
 310:	b8 11 00 00 00       	mov    $0x11,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <getpid>:
SYSCALL(getpid)
 318:	b8 12 00 00 00       	mov    $0x12,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <sbrk>:
SYSCALL(sbrk)
 320:	b8 13 00 00 00       	mov    $0x13,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <sleep>:
SYSCALL(sleep)
 328:	b8 14 00 00 00       	mov    $0x14,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <uptime>:
SYSCALL(uptime)
 330:	b8 15 00 00 00       	mov    $0x15,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <getcount>:
SYSCALL(getcount)
 338:	b8 16 00 00 00       	mov    $0x16,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	57                   	push   %edi
 344:	89 cf                	mov    %ecx,%edi
 346:	56                   	push   %esi
 347:	89 c6                	mov    %eax,%esi
 349:	53                   	push   %ebx
 34a:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 34d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 350:	85 c9                	test   %ecx,%ecx
 352:	74 04                	je     358 <printint+0x18>
 354:	85 d2                	test   %edx,%edx
 356:	78 70                	js     3c8 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 358:	89 d0                	mov    %edx,%eax
 35a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 361:	31 c9                	xor    %ecx,%ecx
 363:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 366:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 368:	31 d2                	xor    %edx,%edx
 36a:	f7 f7                	div    %edi
 36c:	0f b6 92 78 07 00 00 	movzbl 0x778(%edx),%edx
 373:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 376:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 379:	85 c0                	test   %eax,%eax
 37b:	75 eb                	jne    368 <printint+0x28>
  if(neg)
 37d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 380:	85 c0                	test   %eax,%eax
 382:	74 08                	je     38c <printint+0x4c>
    buf[i++] = '-';
 384:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 389:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 38c:	8d 79 ff             	lea    -0x1(%ecx),%edi
 38f:	01 fb                	add    %edi,%ebx
 391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 398:	0f b6 03             	movzbl (%ebx),%eax
 39b:	83 ef 01             	sub    $0x1,%edi
 39e:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 3a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3a8:	00 
 3a9:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3ac:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 3af:	8d 45 e7             	lea    -0x19(%ebp),%eax
 3b2:	89 44 24 04          	mov    %eax,0x4(%esp)
 3b6:	e8 fd fe ff ff       	call   2b8 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3bb:	83 ff ff             	cmp    $0xffffffff,%edi
 3be:	75 d8                	jne    398 <printint+0x58>
    putc(fd, buf[i]);
}
 3c0:	83 c4 4c             	add    $0x4c,%esp
 3c3:	5b                   	pop    %ebx
 3c4:	5e                   	pop    %esi
 3c5:	5f                   	pop    %edi
 3c6:	5d                   	pop    %ebp
 3c7:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 3c8:	89 d0                	mov    %edx,%eax
 3ca:	f7 d8                	neg    %eax
 3cc:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 3d3:	eb 8c                	jmp    361 <printint+0x21>
 3d5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 3d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000003e0 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	57                   	push   %edi
 3e4:	56                   	push   %esi
 3e5:	53                   	push   %ebx
 3e6:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ec:	0f b6 10             	movzbl (%eax),%edx
 3ef:	84 d2                	test   %dl,%dl
 3f1:	0f 84 c9 00 00 00    	je     4c0 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3f7:	8d 4d 10             	lea    0x10(%ebp),%ecx
 3fa:	31 ff                	xor    %edi,%edi
 3fc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 3ff:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 401:	8d 75 e7             	lea    -0x19(%ebp),%esi
 404:	eb 1e                	jmp    424 <printf+0x44>
 406:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 408:	83 fa 25             	cmp    $0x25,%edx
 40b:	0f 85 b7 00 00 00    	jne    4c8 <printf+0xe8>
 411:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 415:	83 c3 01             	add    $0x1,%ebx
 418:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 41c:	84 d2                	test   %dl,%dl
 41e:	0f 84 9c 00 00 00    	je     4c0 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 424:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 426:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 429:	74 dd                	je     408 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 42b:	83 ff 25             	cmp    $0x25,%edi
 42e:	75 e5                	jne    415 <printf+0x35>
      if(c == 'd'){
 430:	83 fa 64             	cmp    $0x64,%edx
 433:	0f 84 47 01 00 00    	je     580 <printf+0x1a0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 439:	83 fa 70             	cmp    $0x70,%edx
 43c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 440:	0f 84 aa 00 00 00    	je     4f0 <printf+0x110>
 446:	83 fa 78             	cmp    $0x78,%edx
 449:	0f 84 a1 00 00 00    	je     4f0 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 44f:	83 fa 73             	cmp    $0x73,%edx
 452:	0f 84 c0 00 00 00    	je     518 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 458:	83 fa 63             	cmp    $0x63,%edx
 45b:	90                   	nop
 45c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 460:	0f 84 42 01 00 00    	je     5a8 <printf+0x1c8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 466:	83 fa 25             	cmp    $0x25,%edx
 469:	0f 84 01 01 00 00    	je     570 <printf+0x190>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 46f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 472:	89 55 cc             	mov    %edx,-0x34(%ebp)
 475:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 480:	00 
 481:	89 74 24 04          	mov    %esi,0x4(%esp)
 485:	89 0c 24             	mov    %ecx,(%esp)
 488:	e8 2b fe ff ff       	call   2b8 <write>
 48d:	8b 55 cc             	mov    -0x34(%ebp),%edx
 490:	88 55 e7             	mov    %dl,-0x19(%ebp)
 493:	8b 45 08             	mov    0x8(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 496:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 499:	31 ff                	xor    %edi,%edi
 49b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4a2:	00 
 4a3:	89 74 24 04          	mov    %esi,0x4(%esp)
 4a7:	89 04 24             	mov    %eax,(%esp)
 4aa:	e8 09 fe ff ff       	call   2b8 <write>
 4af:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4b2:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 4b6:	84 d2                	test   %dl,%dl
 4b8:	0f 85 66 ff ff ff    	jne    424 <printf+0x44>
 4be:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 4c0:	83 c4 3c             	add    $0x3c,%esp
 4c3:	5b                   	pop    %ebx
 4c4:	5e                   	pop    %esi
 4c5:	5f                   	pop    %edi
 4c6:	5d                   	pop    %ebp
 4c7:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 4c8:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 4cb:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 4ce:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4d5:	00 
 4d6:	89 74 24 04          	mov    %esi,0x4(%esp)
 4da:	89 04 24             	mov    %eax,(%esp)
 4dd:	e8 d6 fd ff ff       	call   2b8 <write>
 4e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e5:	e9 2b ff ff ff       	jmp    415 <printf+0x35>
 4ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 4f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 4f3:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 4f8:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 4fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 501:	8b 10                	mov    (%eax),%edx
 503:	8b 45 08             	mov    0x8(%ebp),%eax
 506:	e8 35 fe ff ff       	call   340 <printint>
 50b:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 50e:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 512:	e9 fe fe ff ff       	jmp    415 <printf+0x35>
 517:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 518:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        ap++;
        if(s == 0)
 51b:	b9 71 07 00 00       	mov    $0x771,%ecx
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
 520:	8b 3a                	mov    (%edx),%edi
        ap++;
 522:	83 c2 04             	add    $0x4,%edx
 525:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 528:	85 ff                	test   %edi,%edi
 52a:	0f 44 f9             	cmove  %ecx,%edi
          s = "(null)";
        while(*s != 0){
 52d:	0f b6 17             	movzbl (%edi),%edx
 530:	84 d2                	test   %dl,%dl
 532:	74 33                	je     567 <printf+0x187>
 534:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 537:	8b 5d 08             	mov    0x8(%ebp),%ebx
 53a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
          putc(fd, *s);
          s++;
 540:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 543:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 546:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 54d:	00 
 54e:	89 74 24 04          	mov    %esi,0x4(%esp)
 552:	89 1c 24             	mov    %ebx,(%esp)
 555:	e8 5e fd ff ff       	call   2b8 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 55a:	0f b6 17             	movzbl (%edi),%edx
 55d:	84 d2                	test   %dl,%dl
 55f:	75 df                	jne    540 <printf+0x160>
 561:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 564:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 567:	31 ff                	xor    %edi,%edi
 569:	e9 a7 fe ff ff       	jmp    415 <printf+0x35>
 56e:	66 90                	xchg   %ax,%ax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 570:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 574:	e9 1a ff ff ff       	jmp    493 <printf+0xb3>
 579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 580:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 583:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 588:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 58b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 592:	8b 10                	mov    (%eax),%edx
 594:	8b 45 08             	mov    0x8(%ebp),%eax
 597:	e8 a4 fd ff ff       	call   340 <printint>
 59c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 59f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 5a3:	e9 6d fe ff ff       	jmp    415 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        putc(fd, *ap);
        ap++;
 5ab:	31 ff                	xor    %edi,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5b0:	8b 02                	mov    (%edx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5b2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5b9:	00 
 5ba:	89 74 24 04          	mov    %esi,0x4(%esp)
 5be:	89 0c 24             	mov    %ecx,(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5c1:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5c4:	e8 ef fc ff ff       	call   2b8 <write>
 5c9:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 5cc:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 5d0:	e9 40 fe ff ff       	jmp    415 <printf+0x35>
 5d5:	90                   	nop
 5d6:	90                   	nop
 5d7:	90                   	nop
 5d8:	90                   	nop
 5d9:	90                   	nop
 5da:	90                   	nop
 5db:	90                   	nop
 5dc:	90                   	nop
 5dd:	90                   	nop
 5de:	90                   	nop
 5df:	90                   	nop

000005e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5e0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e1:	a1 94 07 00 00       	mov    0x794,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 5e6:	89 e5                	mov    %esp,%ebp
 5e8:	57                   	push   %edi
 5e9:	56                   	push   %esi
 5ea:	53                   	push   %ebx
 5eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5ee:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5f1:	39 c8                	cmp    %ecx,%eax
 5f3:	73 1d                	jae    612 <free+0x32>
 5f5:	8d 76 00             	lea    0x0(%esi),%esi
 5f8:	8b 10                	mov    (%eax),%edx
 5fa:	39 d1                	cmp    %edx,%ecx
 5fc:	72 1a                	jb     618 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5fe:	39 d0                	cmp    %edx,%eax
 600:	72 08                	jb     60a <free+0x2a>
 602:	39 c8                	cmp    %ecx,%eax
 604:	72 12                	jb     618 <free+0x38>
 606:	39 d1                	cmp    %edx,%ecx
 608:	72 0e                	jb     618 <free+0x38>
 60a:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60c:	39 c8                	cmp    %ecx,%eax
 60e:	66 90                	xchg   %ax,%ax
 610:	72 e6                	jb     5f8 <free+0x18>
 612:	8b 10                	mov    (%eax),%edx
 614:	eb e8                	jmp    5fe <free+0x1e>
 616:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 618:	8b 71 04             	mov    0x4(%ecx),%esi
 61b:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 61e:	39 d7                	cmp    %edx,%edi
 620:	74 19                	je     63b <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 622:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 625:	8b 50 04             	mov    0x4(%eax),%edx
 628:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 62b:	39 ce                	cmp    %ecx,%esi
 62d:	74 23                	je     652 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 62f:	89 08                	mov    %ecx,(%eax)
  freep = p;
 631:	a3 94 07 00 00       	mov    %eax,0x794
}
 636:	5b                   	pop    %ebx
 637:	5e                   	pop    %esi
 638:	5f                   	pop    %edi
 639:	5d                   	pop    %ebp
 63a:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 63b:	03 72 04             	add    0x4(%edx),%esi
 63e:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 641:	8b 10                	mov    (%eax),%edx
 643:	8b 12                	mov    (%edx),%edx
 645:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 648:	8b 50 04             	mov    0x4(%eax),%edx
 64b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 64e:	39 ce                	cmp    %ecx,%esi
 650:	75 dd                	jne    62f <free+0x4f>
    p->s.size += bp->s.size;
 652:	03 51 04             	add    0x4(%ecx),%edx
 655:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 658:	8b 53 f8             	mov    -0x8(%ebx),%edx
 65b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 65d:	a3 94 07 00 00       	mov    %eax,0x794
}
 662:	5b                   	pop    %ebx
 663:	5e                   	pop    %esi
 664:	5f                   	pop    %edi
 665:	5d                   	pop    %ebp
 666:	c3                   	ret    
 667:	89 f6                	mov    %esi,%esi
 669:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000670 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 670:	55                   	push   %ebp
 671:	89 e5                	mov    %esp,%ebp
 673:	57                   	push   %edi
 674:	56                   	push   %esi
 675:	53                   	push   %ebx
 676:	83 ec 2c             	sub    $0x2c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 679:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 67c:	8b 0d 94 07 00 00    	mov    0x794,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 682:	83 c3 07             	add    $0x7,%ebx
 685:	c1 eb 03             	shr    $0x3,%ebx
 688:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 68b:	85 c9                	test   %ecx,%ecx
 68d:	0f 84 9b 00 00 00    	je     72e <malloc+0xbe>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 693:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 695:	8b 50 04             	mov    0x4(%eax),%edx
 698:	39 d3                	cmp    %edx,%ebx
 69a:	76 27                	jbe    6c3 <malloc+0x53>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 69c:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 6a3:	be 00 80 00 00       	mov    $0x8000,%esi
 6a8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 6ab:	90                   	nop
 6ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6b0:	3b 05 94 07 00 00    	cmp    0x794,%eax
 6b6:	74 30                	je     6e8 <malloc+0x78>
 6b8:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6ba:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 6bc:	8b 50 04             	mov    0x4(%eax),%edx
 6bf:	39 d3                	cmp    %edx,%ebx
 6c1:	77 ed                	ja     6b0 <malloc+0x40>
      if(p->s.size == nunits)
 6c3:	39 d3                	cmp    %edx,%ebx
 6c5:	74 61                	je     728 <malloc+0xb8>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 6c7:	29 da                	sub    %ebx,%edx
 6c9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6cc:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6cf:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6d2:	89 0d 94 07 00 00    	mov    %ecx,0x794
      return (void*)(p + 1);
 6d8:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6db:	83 c4 2c             	add    $0x2c,%esp
 6de:	5b                   	pop    %ebx
 6df:	5e                   	pop    %esi
 6e0:	5f                   	pop    %edi
 6e1:	5d                   	pop    %ebp
 6e2:	c3                   	ret    
 6e3:	90                   	nop
 6e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 6e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6eb:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
 6f1:	bf 00 10 00 00       	mov    $0x1000,%edi
 6f6:	0f 43 fb             	cmovae %ebx,%edi
 6f9:	0f 42 c6             	cmovb  %esi,%eax
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 6fc:	89 04 24             	mov    %eax,(%esp)
 6ff:	e8 1c fc ff ff       	call   320 <sbrk>
  if(p == (char*)-1)
 704:	83 f8 ff             	cmp    $0xffffffff,%eax
 707:	74 18                	je     721 <malloc+0xb1>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 709:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 70c:	83 c0 08             	add    $0x8,%eax
 70f:	89 04 24             	mov    %eax,(%esp)
 712:	e8 c9 fe ff ff       	call   5e0 <free>
  return freep;
 717:	8b 0d 94 07 00 00    	mov    0x794,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 71d:	85 c9                	test   %ecx,%ecx
 71f:	75 99                	jne    6ba <malloc+0x4a>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 721:	31 c0                	xor    %eax,%eax
 723:	eb b6                	jmp    6db <malloc+0x6b>
 725:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 728:	8b 10                	mov    (%eax),%edx
 72a:	89 11                	mov    %edx,(%ecx)
 72c:	eb a4                	jmp    6d2 <malloc+0x62>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 72e:	c7 05 94 07 00 00 8c 	movl   $0x78c,0x794
 735:	07 00 00 
    base.s.size = 0;
 738:	b9 8c 07 00 00       	mov    $0x78c,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 73d:	c7 05 8c 07 00 00 8c 	movl   $0x78c,0x78c
 744:	07 00 00 
    base.s.size = 0;
 747:	c7 05 90 07 00 00 00 	movl   $0x0,0x790
 74e:	00 00 00 
 751:	e9 3d ff ff ff       	jmp    693 <malloc+0x23>
