
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
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
	names[17] = "dup";
	names[18] = "getpid";
	names[19] = "sbrk";
	names[20] = "sleep";
	names[21] = "uptime";
	names[22] = "getcount";
  10:	31 db                	xor    %ebx,%ebx
#include "types.h"
#include "stat.h"
#include "user.h"

int
main (int argc, char* argv[]) {
  12:	51                   	push   %ecx
  13:	81 ec 88 00 00 00    	sub    $0x88,%esp
	int n = 23;
	char* names[n];
  19:	8d 74 24 1f          	lea    0x1f(%esp),%esi
	int counts[n];
  1d:	83 ec 70             	sub    $0x70,%esp
#include "user.h"

int
main (int argc, char* argv[]) {
	int n = 23;
	char* names[n];
  20:	83 e6 f0             	and    $0xfffffff0,%esi
	int counts[n];
  23:	8d 7c 24 1f          	lea    0x1f(%esp),%edi
  27:	83 e7 f0             	and    $0xfffffff0,%edi
	names[1] = "fork";
  2a:	c7 46 04 40 08 00 00 	movl   $0x840,0x4(%esi)
	names[2] = "exit";
  31:	c7 46 08 45 08 00 00 	movl   $0x845,0x8(%esi)
	names[3] = "wait";
  38:	c7 46 0c 4a 08 00 00 	movl   $0x84a,0xc(%esi)
	names[4] = "pipe";
  3f:	c7 46 10 4f 08 00 00 	movl   $0x84f,0x10(%esi)
	names[5] = "write";
  46:	c7 46 14 54 08 00 00 	movl   $0x854,0x14(%esi)
	names[6] = "read";
  4d:	c7 46 18 5a 08 00 00 	movl   $0x85a,0x18(%esi)
	names[7] = "close";
  54:	c7 46 1c 5f 08 00 00 	movl   $0x85f,0x1c(%esi)
	names[8] = "kill";
  5b:	c7 46 20 65 08 00 00 	movl   $0x865,0x20(%esi)
	names[9] = "exec";
  62:	c7 46 24 6a 08 00 00 	movl   $0x86a,0x24(%esi)
	names[10] = "open";
  69:	c7 46 28 6f 08 00 00 	movl   $0x86f,0x28(%esi)
	names[11] = "mknod";
  70:	c7 46 2c 74 08 00 00 	movl   $0x874,0x2c(%esi)
	names[12] = "unlink";
  77:	c7 46 30 7a 08 00 00 	movl   $0x87a,0x30(%esi)
	names[13] = "fstat";
  7e:	c7 46 34 81 08 00 00 	movl   $0x881,0x34(%esi)
	names[14] = "link";
  85:	c7 46 38 7c 08 00 00 	movl   $0x87c,0x38(%esi)
	names[15] = "mkdir";
  8c:	c7 46 3c 87 08 00 00 	movl   $0x887,0x3c(%esi)
	names[16] = "chdir";
  93:	c7 46 40 8d 08 00 00 	movl   $0x88d,0x40(%esi)
	names[17] = "dup";
  9a:	c7 46 44 93 08 00 00 	movl   $0x893,0x44(%esi)
	names[18] = "getpid";
  a1:	c7 46 48 97 08 00 00 	movl   $0x897,0x48(%esi)
	names[19] = "sbrk";
  a8:	c7 46 4c 9e 08 00 00 	movl   $0x89e,0x4c(%esi)
	names[20] = "sleep";
  af:	c7 46 50 a3 08 00 00 	movl   $0x8a3,0x50(%esi)
	names[21] = "uptime";
  b6:	c7 46 54 a9 08 00 00 	movl   $0x8a9,0x54(%esi)
	names[22] = "getcount";
  bd:	c7 46 58 b0 08 00 00 	movl   $0x8b0,0x58(%esi)
  c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

	int i;
	for (i = 0; i < 20; i++) {
  c8:	83 c3 01             	add    $0x1,%ebx
		getcount(counts, n);
  cb:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  d2:	00 
  d3:	89 3c 24             	mov    %edi,(%esp)
  d6:	e8 3d 03 00 00       	call   418 <getcount>
	names[20] = "sleep";
	names[21] = "uptime";
	names[22] = "getcount";

	int i;
	for (i = 0; i < 20; i++) {
  db:	83 fb 14             	cmp    $0x14,%ebx
  de:	75 e8                	jne    c8 <main+0xc8>
  e0:	b3 01                	mov    $0x1,%bl
  e2:	eb 2b                	jmp    10f <main+0x10f>
  e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

	for (i = 1; i < n; i++) {
		if (counts[i] < 0) {
			printf(1, "Count %s has a negative count of %d!\n", names[i], counts[i]);
		}
		printf(1, "Count %s: %d\n", names[i], counts[i]);
  e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  ec:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
	int i;
	for (i = 0; i < 20; i++) {
		getcount(counts, n);
	}

	for (i = 1; i < n; i++) {
  ef:	83 c3 01             	add    $0x1,%ebx
		if (counts[i] < 0) {
			printf(1, "Count %s has a negative count of %d!\n", names[i], counts[i]);
		}
		printf(1, "Count %s: %d\n", names[i], counts[i]);
  f2:	c7 44 24 04 b9 08 00 	movl   $0x8b9,0x4(%esp)
  f9:	00 
  fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 101:	89 44 24 08          	mov    %eax,0x8(%esp)
 105:	e8 b6 03 00 00       	call   4c0 <printf>
	int i;
	for (i = 0; i < 20; i++) {
		getcount(counts, n);
	}

	for (i = 1; i < n; i++) {
 10a:	83 fb 17             	cmp    $0x17,%ebx
 10d:	74 31                	je     140 <main+0x140>
		if (counts[i] < 0) {
 10f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
 112:	85 c0                	test   %eax,%eax
 114:	79 d2                	jns    e8 <main+0xe8>
			printf(1, "Count %s has a negative count of %d!\n", names[i], counts[i]);
 116:	89 44 24 0c          	mov    %eax,0xc(%esp)
 11a:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
 11d:	c7 44 24 04 c8 08 00 	movl   $0x8c8,0x4(%esp)
 124:	00 
 125:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 12c:	89 44 24 08          	mov    %eax,0x8(%esp)
 130:	e8 8b 03 00 00       	call   4c0 <printf>
 135:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
 138:	eb ae                	jmp    e8 <main+0xe8>
 13a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
		}
		printf(1, "Count %s: %d\n", names[i], counts[i]);
	}

	exit();
 140:	e8 33 02 00 00       	call   378 <exit>
 145:	90                   	nop
 146:	90                   	nop
 147:	90                   	nop
 148:	90                   	nop
 149:	90                   	nop
 14a:	90                   	nop
 14b:	90                   	nop
 14c:	90                   	nop
 14d:	90                   	nop
 14e:	90                   	nop
 14f:	90                   	nop

00000150 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 150:	55                   	push   %ebp
 151:	31 d2                	xor    %edx,%edx
 153:	89 e5                	mov    %esp,%ebp
 155:	8b 45 08             	mov    0x8(%ebp),%eax
 158:	53                   	push   %ebx
 159:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 15c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 160:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 164:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 167:	83 c2 01             	add    $0x1,%edx
 16a:	84 c9                	test   %cl,%cl
 16c:	75 f2                	jne    160 <strcpy+0x10>
    ;
  return os;
}
 16e:	5b                   	pop    %ebx
 16f:	5d                   	pop    %ebp
 170:	c3                   	ret    
 171:	eb 0d                	jmp    180 <strcmp>
 173:	90                   	nop
 174:	90                   	nop
 175:	90                   	nop
 176:	90                   	nop
 177:	90                   	nop
 178:	90                   	nop
 179:	90                   	nop
 17a:	90                   	nop
 17b:	90                   	nop
 17c:	90                   	nop
 17d:	90                   	nop
 17e:	90                   	nop
 17f:	90                   	nop

00000180 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	53                   	push   %ebx
 184:	8b 4d 08             	mov    0x8(%ebp),%ecx
 187:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 18a:	0f b6 01             	movzbl (%ecx),%eax
 18d:	84 c0                	test   %al,%al
 18f:	75 14                	jne    1a5 <strcmp+0x25>
 191:	eb 25                	jmp    1b8 <strcmp+0x38>
 193:	90                   	nop
 194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
 198:	83 c1 01             	add    $0x1,%ecx
 19b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 19e:	0f b6 01             	movzbl (%ecx),%eax
 1a1:	84 c0                	test   %al,%al
 1a3:	74 13                	je     1b8 <strcmp+0x38>
 1a5:	0f b6 1a             	movzbl (%edx),%ebx
 1a8:	38 d8                	cmp    %bl,%al
 1aa:	74 ec                	je     198 <strcmp+0x18>
 1ac:	0f b6 db             	movzbl %bl,%ebx
 1af:	0f b6 c0             	movzbl %al,%eax
 1b2:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 1b4:	5b                   	pop    %ebx
 1b5:	5d                   	pop    %ebp
 1b6:	c3                   	ret    
 1b7:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1b8:	0f b6 1a             	movzbl (%edx),%ebx
 1bb:	31 c0                	xor    %eax,%eax
 1bd:	0f b6 db             	movzbl %bl,%ebx
 1c0:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 1c2:	5b                   	pop    %ebx
 1c3:	5d                   	pop    %ebp
 1c4:	c3                   	ret    
 1c5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001d0 <strlen>:

uint
strlen(char *s)
{
 1d0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
 1d1:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 1d3:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
 1d5:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 1d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1da:	80 39 00             	cmpb   $0x0,(%ecx)
 1dd:	74 0c                	je     1eb <strlen+0x1b>
 1df:	90                   	nop
 1e0:	83 c2 01             	add    $0x1,%edx
 1e3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1e7:	89 d0                	mov    %edx,%eax
 1e9:	75 f5                	jne    1e0 <strlen+0x10>
    ;
  return n;
}
 1eb:	5d                   	pop    %ebp
 1ec:	c3                   	ret    
 1ed:	8d 76 00             	lea    0x0(%esi),%esi

000001f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f0:	55                   	push   %ebp
 1f1:	89 e5                	mov    %esp,%ebp
 1f3:	8b 55 08             	mov    0x8(%ebp),%edx
 1f6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fd:	89 d7                	mov    %edx,%edi
 1ff:	fc                   	cld    
 200:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 202:	89 d0                	mov    %edx,%eax
 204:	5f                   	pop    %edi
 205:	5d                   	pop    %ebp
 206:	c3                   	ret    
 207:	89 f6                	mov    %esi,%esi
 209:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000210 <strchr>:

char*
strchr(const char *s, char c)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 21a:	0f b6 10             	movzbl (%eax),%edx
 21d:	84 d2                	test   %dl,%dl
 21f:	75 11                	jne    232 <strchr+0x22>
 221:	eb 15                	jmp    238 <strchr+0x28>
 223:	90                   	nop
 224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 228:	83 c0 01             	add    $0x1,%eax
 22b:	0f b6 10             	movzbl (%eax),%edx
 22e:	84 d2                	test   %dl,%dl
 230:	74 06                	je     238 <strchr+0x28>
    if(*s == c)
 232:	38 ca                	cmp    %cl,%dl
 234:	75 f2                	jne    228 <strchr+0x18>
      return (char*)s;
  return 0;
}
 236:	5d                   	pop    %ebp
 237:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 238:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 23a:	5d                   	pop    %ebp
 23b:	90                   	nop
 23c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 240:	c3                   	ret    
 241:	eb 0d                	jmp    250 <atoi>
 243:	90                   	nop
 244:	90                   	nop
 245:	90                   	nop
 246:	90                   	nop
 247:	90                   	nop
 248:	90                   	nop
 249:	90                   	nop
 24a:	90                   	nop
 24b:	90                   	nop
 24c:	90                   	nop
 24d:	90                   	nop
 24e:	90                   	nop
 24f:	90                   	nop

00000250 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 250:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 251:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 253:	89 e5                	mov    %esp,%ebp
 255:	8b 4d 08             	mov    0x8(%ebp),%ecx
 258:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 259:	0f b6 11             	movzbl (%ecx),%edx
 25c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 25f:	80 fb 09             	cmp    $0x9,%bl
 262:	77 1c                	ja     280 <atoi+0x30>
 264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 268:	0f be d2             	movsbl %dl,%edx
 26b:	83 c1 01             	add    $0x1,%ecx
 26e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 271:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 275:	0f b6 11             	movzbl (%ecx),%edx
 278:	8d 5a d0             	lea    -0x30(%edx),%ebx
 27b:	80 fb 09             	cmp    $0x9,%bl
 27e:	76 e8                	jbe    268 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 280:	5b                   	pop    %ebx
 281:	5d                   	pop    %ebp
 282:	c3                   	ret    
 283:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000290 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 290:	55                   	push   %ebp
 291:	89 e5                	mov    %esp,%ebp
 293:	56                   	push   %esi
 294:	8b 45 08             	mov    0x8(%ebp),%eax
 297:	53                   	push   %ebx
 298:	8b 5d 10             	mov    0x10(%ebp),%ebx
 29b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 29e:	85 db                	test   %ebx,%ebx
 2a0:	7e 14                	jle    2b6 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
 2a2:	31 d2                	xor    %edx,%edx
 2a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 2a8:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 2ac:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 2af:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b2:	39 da                	cmp    %ebx,%edx
 2b4:	75 f2                	jne    2a8 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 2b6:	5b                   	pop    %ebx
 2b7:	5e                   	pop    %esi
 2b8:	5d                   	pop    %ebp
 2b9:	c3                   	ret    
 2ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

000002c0 <stat>:
  return buf;
}

int
stat(char *n, struct stat *st)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(char *n, struct stat *st)
{
 2c9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 2cc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 2cf:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2db:	00 
 2dc:	89 04 24             	mov    %eax,(%esp)
 2df:	e8 d4 00 00 00       	call   3b8 <open>
  if(fd < 0)
 2e4:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e6:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 2e8:	78 19                	js     303 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 2ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ed:	89 1c 24             	mov    %ebx,(%esp)
 2f0:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f4:	e8 d7 00 00 00       	call   3d0 <fstat>
  close(fd);
 2f9:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 2fc:	89 c6                	mov    %eax,%esi
  close(fd);
 2fe:	e8 9d 00 00 00       	call   3a0 <close>
  return r;
}
 303:	89 f0                	mov    %esi,%eax
 305:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 308:	8b 75 fc             	mov    -0x4(%ebp),%esi
 30b:	89 ec                	mov    %ebp,%esp
 30d:	5d                   	pop    %ebp
 30e:	c3                   	ret    
 30f:	90                   	nop

00000310 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 310:	55                   	push   %ebp
 311:	89 e5                	mov    %esp,%ebp
 313:	57                   	push   %edi
 314:	56                   	push   %esi
 315:	31 f6                	xor    %esi,%esi
 317:	53                   	push   %ebx
 318:	83 ec 2c             	sub    $0x2c,%esp
 31b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 31e:	eb 06                	jmp    326 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 320:	3c 0a                	cmp    $0xa,%al
 322:	74 39                	je     35d <gets+0x4d>
 324:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 326:	8d 5e 01             	lea    0x1(%esi),%ebx
 329:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 32c:	7d 31                	jge    35f <gets+0x4f>
    cc = read(0, &c, 1);
 32e:	8d 45 e7             	lea    -0x19(%ebp),%eax
 331:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 338:	00 
 339:	89 44 24 04          	mov    %eax,0x4(%esp)
 33d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 344:	e8 47 00 00 00       	call   390 <read>
    if(cc < 1)
 349:	85 c0                	test   %eax,%eax
 34b:	7e 12                	jle    35f <gets+0x4f>
      break;
    buf[i++] = c;
 34d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 351:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 355:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 359:	3c 0d                	cmp    $0xd,%al
 35b:	75 c3                	jne    320 <gets+0x10>
 35d:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 35f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 363:	89 f8                	mov    %edi,%eax
 365:	83 c4 2c             	add    $0x2c,%esp
 368:	5b                   	pop    %ebx
 369:	5e                   	pop    %esi
 36a:	5f                   	pop    %edi
 36b:	5d                   	pop    %ebp
 36c:	c3                   	ret    
 36d:	90                   	nop
 36e:	90                   	nop
 36f:	90                   	nop

00000370 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 370:	b8 01 00 00 00       	mov    $0x1,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <exit>:
SYSCALL(exit)
 378:	b8 02 00 00 00       	mov    $0x2,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <wait>:
SYSCALL(wait)
 380:	b8 03 00 00 00       	mov    $0x3,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <pipe>:
SYSCALL(pipe)
 388:	b8 04 00 00 00       	mov    $0x4,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <read>:
SYSCALL(read)
 390:	b8 06 00 00 00       	mov    $0x6,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <write>:
SYSCALL(write)
 398:	b8 05 00 00 00       	mov    $0x5,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <close>:
SYSCALL(close)
 3a0:	b8 07 00 00 00       	mov    $0x7,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <kill>:
SYSCALL(kill)
 3a8:	b8 08 00 00 00       	mov    $0x8,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <exec>:
SYSCALL(exec)
 3b0:	b8 09 00 00 00       	mov    $0x9,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <open>:
SYSCALL(open)
 3b8:	b8 0a 00 00 00       	mov    $0xa,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <mknod>:
SYSCALL(mknod)
 3c0:	b8 0b 00 00 00       	mov    $0xb,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <unlink>:
SYSCALL(unlink)
 3c8:	b8 0c 00 00 00       	mov    $0xc,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <fstat>:
SYSCALL(fstat)
 3d0:	b8 0d 00 00 00       	mov    $0xd,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <link>:
SYSCALL(link)
 3d8:	b8 0e 00 00 00       	mov    $0xe,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <mkdir>:
SYSCALL(mkdir)
 3e0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <chdir>:
SYSCALL(chdir)
 3e8:	b8 10 00 00 00       	mov    $0x10,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <dup>:
SYSCALL(dup)
 3f0:	b8 11 00 00 00       	mov    $0x11,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <getpid>:
SYSCALL(getpid)
 3f8:	b8 12 00 00 00       	mov    $0x12,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <sbrk>:
SYSCALL(sbrk)
 400:	b8 13 00 00 00       	mov    $0x13,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <sleep>:
SYSCALL(sleep)
 408:	b8 14 00 00 00       	mov    $0x14,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <uptime>:
SYSCALL(uptime)
 410:	b8 15 00 00 00       	mov    $0x15,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <getcount>:
SYSCALL(getcount)
 418:	b8 16 00 00 00       	mov    $0x16,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 420:	55                   	push   %ebp
 421:	89 e5                	mov    %esp,%ebp
 423:	57                   	push   %edi
 424:	89 cf                	mov    %ecx,%edi
 426:	56                   	push   %esi
 427:	89 c6                	mov    %eax,%esi
 429:	53                   	push   %ebx
 42a:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 42d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 430:	85 c9                	test   %ecx,%ecx
 432:	74 04                	je     438 <printint+0x18>
 434:	85 d2                	test   %edx,%edx
 436:	78 70                	js     4a8 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 438:	89 d0                	mov    %edx,%eax
 43a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 441:	31 c9                	xor    %ecx,%ecx
 443:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 446:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 448:	31 d2                	xor    %edx,%edx
 44a:	f7 f7                	div    %edi
 44c:	0f b6 92 f7 08 00 00 	movzbl 0x8f7(%edx),%edx
 453:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 456:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 459:	85 c0                	test   %eax,%eax
 45b:	75 eb                	jne    448 <printint+0x28>
  if(neg)
 45d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 460:	85 c0                	test   %eax,%eax
 462:	74 08                	je     46c <printint+0x4c>
    buf[i++] = '-';
 464:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 469:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 46c:	8d 79 ff             	lea    -0x1(%ecx),%edi
 46f:	01 fb                	add    %edi,%ebx
 471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 478:	0f b6 03             	movzbl (%ebx),%eax
 47b:	83 ef 01             	sub    $0x1,%edi
 47e:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 481:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 488:	00 
 489:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 48c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 48f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 492:	89 44 24 04          	mov    %eax,0x4(%esp)
 496:	e8 fd fe ff ff       	call   398 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 49b:	83 ff ff             	cmp    $0xffffffff,%edi
 49e:	75 d8                	jne    478 <printint+0x58>
    putc(fd, buf[i]);
}
 4a0:	83 c4 4c             	add    $0x4c,%esp
 4a3:	5b                   	pop    %ebx
 4a4:	5e                   	pop    %esi
 4a5:	5f                   	pop    %edi
 4a6:	5d                   	pop    %ebp
 4a7:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 4a8:	89 d0                	mov    %edx,%eax
 4aa:	f7 d8                	neg    %eax
 4ac:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 4b3:	eb 8c                	jmp    441 <printint+0x21>
 4b5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 4b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000004c0 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4c0:	55                   	push   %ebp
 4c1:	89 e5                	mov    %esp,%ebp
 4c3:	57                   	push   %edi
 4c4:	56                   	push   %esi
 4c5:	53                   	push   %ebx
 4c6:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4cc:	0f b6 10             	movzbl (%eax),%edx
 4cf:	84 d2                	test   %dl,%dl
 4d1:	0f 84 c9 00 00 00    	je     5a0 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 4d7:	8d 4d 10             	lea    0x10(%ebp),%ecx
 4da:	31 ff                	xor    %edi,%edi
 4dc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 4df:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 4e1:	8d 75 e7             	lea    -0x19(%ebp),%esi
 4e4:	eb 1e                	jmp    504 <printf+0x44>
 4e6:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 4e8:	83 fa 25             	cmp    $0x25,%edx
 4eb:	0f 85 b7 00 00 00    	jne    5a8 <printf+0xe8>
 4f1:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4f5:	83 c3 01             	add    $0x1,%ebx
 4f8:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 4fc:	84 d2                	test   %dl,%dl
 4fe:	0f 84 9c 00 00 00    	je     5a0 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 504:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 506:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 509:	74 dd                	je     4e8 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 50b:	83 ff 25             	cmp    $0x25,%edi
 50e:	75 e5                	jne    4f5 <printf+0x35>
      if(c == 'd'){
 510:	83 fa 64             	cmp    $0x64,%edx
 513:	0f 84 57 01 00 00    	je     670 <printf+0x1b0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 519:	83 fa 70             	cmp    $0x70,%edx
 51c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 520:	0f 84 aa 00 00 00    	je     5d0 <printf+0x110>
 526:	83 fa 78             	cmp    $0x78,%edx
 529:	0f 84 a1 00 00 00    	je     5d0 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 52f:	83 fa 73             	cmp    $0x73,%edx
 532:	0f 84 c0 00 00 00    	je     5f8 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 538:	83 fa 63             	cmp    $0x63,%edx
 53b:	90                   	nop
 53c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 540:	0f 84 52 01 00 00    	je     698 <printf+0x1d8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 546:	83 fa 25             	cmp    $0x25,%edx
 549:	0f 84 f9 00 00 00    	je     648 <printf+0x188>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 54f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 552:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 555:	31 ff                	xor    %edi,%edi
 557:	89 55 cc             	mov    %edx,-0x34(%ebp)
 55a:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 55e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 565:	00 
 566:	89 0c 24             	mov    %ecx,(%esp)
 569:	89 74 24 04          	mov    %esi,0x4(%esp)
 56d:	e8 26 fe ff ff       	call   398 <write>
 572:	8b 55 cc             	mov    -0x34(%ebp),%edx
 575:	8b 45 08             	mov    0x8(%ebp),%eax
 578:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 57f:	00 
 580:	89 74 24 04          	mov    %esi,0x4(%esp)
 584:	88 55 e7             	mov    %dl,-0x19(%ebp)
 587:	89 04 24             	mov    %eax,(%esp)
 58a:	e8 09 fe ff ff       	call   398 <write>
 58f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 592:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 596:	84 d2                	test   %dl,%dl
 598:	0f 85 66 ff ff ff    	jne    504 <printf+0x44>
 59e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5a0:	83 c4 3c             	add    $0x3c,%esp
 5a3:	5b                   	pop    %ebx
 5a4:	5e                   	pop    %esi
 5a5:	5f                   	pop    %edi
 5a6:	5d                   	pop    %ebp
 5a7:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5a8:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 5ab:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5ae:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5b5:	00 
 5b6:	89 74 24 04          	mov    %esi,0x4(%esp)
 5ba:	89 04 24             	mov    %eax,(%esp)
 5bd:	e8 d6 fd ff ff       	call   398 <write>
 5c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c5:	e9 2b ff ff ff       	jmp    4f5 <printf+0x35>
 5ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 5d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 5d3:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 5d8:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 5da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 5e1:	8b 10                	mov    (%eax),%edx
 5e3:	8b 45 08             	mov    0x8(%ebp),%eax
 5e6:	e8 35 fe ff ff       	call   420 <printint>
 5eb:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 5ee:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 5f2:	e9 fe fe ff ff       	jmp    4f5 <printf+0x35>
 5f7:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 5f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 5fb:	8b 3a                	mov    (%edx),%edi
        ap++;
 5fd:	83 c2 04             	add    $0x4,%edx
 600:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 603:	85 ff                	test   %edi,%edi
 605:	0f 84 ba 00 00 00    	je     6c5 <printf+0x205>
          s = "(null)";
        while(*s != 0){
 60b:	0f b6 17             	movzbl (%edi),%edx
 60e:	84 d2                	test   %dl,%dl
 610:	74 2d                	je     63f <printf+0x17f>
 612:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 615:	8b 5d 08             	mov    0x8(%ebp),%ebx
          putc(fd, *s);
          s++;
 618:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 61b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 61e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 625:	00 
 626:	89 74 24 04          	mov    %esi,0x4(%esp)
 62a:	89 1c 24             	mov    %ebx,(%esp)
 62d:	e8 66 fd ff ff       	call   398 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 632:	0f b6 17             	movzbl (%edi),%edx
 635:	84 d2                	test   %dl,%dl
 637:	75 df                	jne    618 <printf+0x158>
 639:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 63c:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 63f:	31 ff                	xor    %edi,%edi
 641:	e9 af fe ff ff       	jmp    4f5 <printf+0x35>
 646:	66 90                	xchg   %ax,%ax
 648:	8b 55 08             	mov    0x8(%ebp),%edx
 64b:	31 ff                	xor    %edi,%edi
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 64d:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 651:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 658:	00 
 659:	89 74 24 04          	mov    %esi,0x4(%esp)
 65d:	89 14 24             	mov    %edx,(%esp)
 660:	e8 33 fd ff ff       	call   398 <write>
 665:	8b 45 0c             	mov    0xc(%ebp),%eax
 668:	e9 88 fe ff ff       	jmp    4f5 <printf+0x35>
 66d:	8d 76 00             	lea    0x0(%esi),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 670:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 673:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 678:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 67b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 682:	8b 10                	mov    (%eax),%edx
 684:	8b 45 08             	mov    0x8(%ebp),%eax
 687:	e8 94 fd ff ff       	call   420 <printint>
 68c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 68f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 693:	e9 5d fe ff ff       	jmp    4f5 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 698:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
        putc(fd, *ap);
        ap++;
 69b:	31 ff                	xor    %edi,%edi
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 69d:	8b 01                	mov    (%ecx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 69f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6a6:	00 
 6a7:	89 74 24 04          	mov    %esi,0x4(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ab:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6ae:	8b 45 08             	mov    0x8(%ebp),%eax
 6b1:	89 04 24             	mov    %eax,(%esp)
 6b4:	e8 df fc ff ff       	call   398 <write>
 6b9:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 6bc:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 6c0:	e9 30 fe ff ff       	jmp    4f5 <printf+0x35>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
 6c5:	bf f0 08 00 00       	mov    $0x8f0,%edi
 6ca:	e9 3c ff ff ff       	jmp    60b <printf+0x14b>
 6cf:	90                   	nop

000006d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d1:	a1 10 09 00 00       	mov    0x910,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d6:	89 e5                	mov    %esp,%ebp
 6d8:	57                   	push   %edi
 6d9:	56                   	push   %esi
 6da:	53                   	push   %ebx
 6db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6de:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e1:	39 c8                	cmp    %ecx,%eax
 6e3:	73 1d                	jae    702 <free+0x32>
 6e5:	8d 76 00             	lea    0x0(%esi),%esi
 6e8:	8b 10                	mov    (%eax),%edx
 6ea:	39 d1                	cmp    %edx,%ecx
 6ec:	72 1a                	jb     708 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ee:	39 d0                	cmp    %edx,%eax
 6f0:	72 08                	jb     6fa <free+0x2a>
 6f2:	39 c8                	cmp    %ecx,%eax
 6f4:	72 12                	jb     708 <free+0x38>
 6f6:	39 d1                	cmp    %edx,%ecx
 6f8:	72 0e                	jb     708 <free+0x38>
 6fa:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fc:	39 c8                	cmp    %ecx,%eax
 6fe:	66 90                	xchg   %ax,%ax
 700:	72 e6                	jb     6e8 <free+0x18>
 702:	8b 10                	mov    (%eax),%edx
 704:	eb e8                	jmp    6ee <free+0x1e>
 706:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 708:	8b 71 04             	mov    0x4(%ecx),%esi
 70b:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 70e:	39 d7                	cmp    %edx,%edi
 710:	74 19                	je     72b <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 712:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 715:	8b 50 04             	mov    0x4(%eax),%edx
 718:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 71b:	39 ce                	cmp    %ecx,%esi
 71d:	74 23                	je     742 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 71f:	89 08                	mov    %ecx,(%eax)
  freep = p;
 721:	a3 10 09 00 00       	mov    %eax,0x910
}
 726:	5b                   	pop    %ebx
 727:	5e                   	pop    %esi
 728:	5f                   	pop    %edi
 729:	5d                   	pop    %ebp
 72a:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 72b:	03 72 04             	add    0x4(%edx),%esi
 72e:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 731:	8b 10                	mov    (%eax),%edx
 733:	8b 12                	mov    (%edx),%edx
 735:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 738:	8b 50 04             	mov    0x4(%eax),%edx
 73b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 73e:	39 ce                	cmp    %ecx,%esi
 740:	75 dd                	jne    71f <free+0x4f>
    p->s.size += bp->s.size;
 742:	03 51 04             	add    0x4(%ecx),%edx
 745:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 748:	8b 53 f8             	mov    -0x8(%ebx),%edx
 74b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 74d:	a3 10 09 00 00       	mov    %eax,0x910
}
 752:	5b                   	pop    %ebx
 753:	5e                   	pop    %esi
 754:	5f                   	pop    %edi
 755:	5d                   	pop    %ebp
 756:	c3                   	ret    
 757:	89 f6                	mov    %esi,%esi
 759:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000760 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 760:	55                   	push   %ebp
 761:	89 e5                	mov    %esp,%ebp
 763:	57                   	push   %edi
 764:	56                   	push   %esi
 765:	53                   	push   %ebx
 766:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 769:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 76c:	8b 0d 10 09 00 00    	mov    0x910,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 772:	83 c3 07             	add    $0x7,%ebx
 775:	c1 eb 03             	shr    $0x3,%ebx
 778:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 77b:	85 c9                	test   %ecx,%ecx
 77d:	0f 84 93 00 00 00    	je     816 <malloc+0xb6>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 783:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 785:	8b 50 04             	mov    0x4(%eax),%edx
 788:	39 d3                	cmp    %edx,%ebx
 78a:	76 1f                	jbe    7ab <malloc+0x4b>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 78c:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 793:	90                   	nop
 794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
    if(p == freep)
 798:	3b 05 10 09 00 00    	cmp    0x910,%eax
 79e:	74 30                	je     7d0 <malloc+0x70>
 7a0:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a2:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 7a4:	8b 50 04             	mov    0x4(%eax),%edx
 7a7:	39 d3                	cmp    %edx,%ebx
 7a9:	77 ed                	ja     798 <malloc+0x38>
      if(p->s.size == nunits)
 7ab:	39 d3                	cmp    %edx,%ebx
 7ad:	74 61                	je     810 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 7af:	29 da                	sub    %ebx,%edx
 7b1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7b4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 7b7:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 7ba:	89 0d 10 09 00 00    	mov    %ecx,0x910
      return (void*)(p + 1);
 7c0:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7c3:	83 c4 1c             	add    $0x1c,%esp
 7c6:	5b                   	pop    %ebx
 7c7:	5e                   	pop    %esi
 7c8:	5f                   	pop    %edi
 7c9:	5d                   	pop    %ebp
 7ca:	c3                   	ret    
 7cb:	90                   	nop
 7cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 7d0:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 7d6:	b8 00 80 00 00       	mov    $0x8000,%eax
 7db:	bf 00 10 00 00       	mov    $0x1000,%edi
 7e0:	76 04                	jbe    7e6 <malloc+0x86>
 7e2:	89 f0                	mov    %esi,%eax
 7e4:	89 df                	mov    %ebx,%edi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 7e6:	89 04 24             	mov    %eax,(%esp)
 7e9:	e8 12 fc ff ff       	call   400 <sbrk>
  if(p == (char*)-1)
 7ee:	83 f8 ff             	cmp    $0xffffffff,%eax
 7f1:	74 18                	je     80b <malloc+0xab>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 7f3:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 7f6:	83 c0 08             	add    $0x8,%eax
 7f9:	89 04 24             	mov    %eax,(%esp)
 7fc:	e8 cf fe ff ff       	call   6d0 <free>
  return freep;
 801:	8b 0d 10 09 00 00    	mov    0x910,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 807:	85 c9                	test   %ecx,%ecx
 809:	75 97                	jne    7a2 <malloc+0x42>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 80b:	31 c0                	xor    %eax,%eax
 80d:	eb b4                	jmp    7c3 <malloc+0x63>
 80f:	90                   	nop
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 810:	8b 10                	mov    (%eax),%edx
 812:	89 11                	mov    %edx,(%ecx)
 814:	eb a4                	jmp    7ba <malloc+0x5a>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 816:	c7 05 10 09 00 00 08 	movl   $0x908,0x910
 81d:	09 00 00 
    base.s.size = 0;
 820:	b9 08 09 00 00       	mov    $0x908,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 825:	c7 05 08 09 00 00 08 	movl   $0x908,0x908
 82c:	09 00 00 
    base.s.size = 0;
 82f:	c7 05 0c 09 00 00 00 	movl   $0x0,0x90c
 836:	00 00 00 
 839:	e9 45 ff ff ff       	jmp    783 <malloc+0x23>
