
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	56                   	push   %esi
   7:	53                   	push   %ebx
  char path[] = "stressfs0";

  printf(1, "stressfs starting\n");

  for(i = 0; i < 4; i++)
    if(fork() > 0)
   8:	31 db                	xor    %ebx,%ebx
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   a:	83 ec 28             	sub    $0x28,%esp
  int fd, i;
  char path[] = "stressfs0";
   d:	c7 44 24 16 73 74 72 	movl   $0x65727473,0x16(%esp)
  14:	65 
  15:	c7 44 24 1a 73 73 66 	movl   $0x73667373,0x1a(%esp)
  1c:	73 
  1d:	66 c7 44 24 1e 30 00 	movw   $0x30,0x1e(%esp)

  printf(1, "stressfs starting\n");
  24:	c7 44 24 04 b6 07 00 	movl   $0x7b6,0x4(%esp)
  2b:	00 
  2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  33:	e8 08 04 00 00       	call   440 <printf>

  for(i = 0; i < 4; i++)
    if(fork() > 0)
  38:	e8 b3 02 00 00       	call   2f0 <fork>
  3d:	85 c0                	test   %eax,%eax
  3f:	7f 25                	jg     66 <main+0x66>
  41:	e8 aa 02 00 00       	call   2f0 <fork>
  46:	b3 01                	mov    $0x1,%bl
  48:	85 c0                	test   %eax,%eax
  4a:	7f 1a                	jg     66 <main+0x66>
  4c:	e8 9f 02 00 00       	call   2f0 <fork>
  51:	b3 02                	mov    $0x2,%bl
  53:	85 c0                	test   %eax,%eax
  55:	7f 0f                	jg     66 <main+0x66>
  57:	e8 94 02 00 00       	call   2f0 <fork>
  5c:	31 db                	xor    %ebx,%ebx
  5e:	85 c0                	test   %eax,%eax
  60:	0f 9e c3             	setle  %bl
  63:	83 c3 03             	add    $0x3,%ebx
      break;

  printf(1, "%d\n", i);
  66:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  6a:	c7 44 24 04 c9 07 00 	movl   $0x7c9,0x4(%esp)
  71:	00 
  72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  79:	e8 c2 03 00 00       	call   440 <printf>

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  7e:	8d 44 24 16          	lea    0x16(%esp),%eax
    if(fork() > 0)
      break;

  printf(1, "%d\n", i);

  path[8] += i;
  82:	00 5c 24 1e          	add    %bl,0x1e(%esp)
  fd = open(path, O_CREATE | O_RDWR);
  86:	31 db                	xor    %ebx,%ebx
  88:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  8f:	00 
  90:	89 04 24             	mov    %eax,(%esp)
  93:	e8 a0 02 00 00       	call   338 <open>
  98:	89 c6                	mov    %eax,%esi
  9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(i = 0; i < 100; i++)
    printf(fd, "%d\n", i);
  a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)

  printf(1, "%d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 100; i++)
  a4:	83 c3 01             	add    $0x1,%ebx
    printf(fd, "%d\n", i);
  a7:	c7 44 24 04 c9 07 00 	movl   $0x7c9,0x4(%esp)
  ae:	00 
  af:	89 34 24             	mov    %esi,(%esp)
  b2:	e8 89 03 00 00       	call   440 <printf>

  printf(1, "%d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 100; i++)
  b7:	83 fb 64             	cmp    $0x64,%ebx
  ba:	75 e4                	jne    a0 <main+0xa0>
    printf(fd, "%d\n", i);
  close(fd);
  bc:	89 34 24             	mov    %esi,(%esp)
  bf:	e8 5c 02 00 00       	call   320 <close>

  wait();
  c4:	e8 37 02 00 00       	call   300 <wait>
  
  exit();
  c9:	e8 2a 02 00 00       	call   2f8 <exit>
  ce:	90                   	nop
  cf:	90                   	nop

000000d0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  d0:	55                   	push   %ebp
  d1:	31 d2                	xor    %edx,%edx
  d3:	89 e5                	mov    %esp,%ebp
  d5:	8b 45 08             	mov    0x8(%ebp),%eax
  d8:	53                   	push   %ebx
  d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  e4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  e7:	83 c2 01             	add    $0x1,%edx
  ea:	84 c9                	test   %cl,%cl
  ec:	75 f2                	jne    e0 <strcpy+0x10>
    ;
  return os;
}
  ee:	5b                   	pop    %ebx
  ef:	5d                   	pop    %ebp
  f0:	c3                   	ret    
  f1:	eb 0d                	jmp    100 <strcmp>
  f3:	90                   	nop
  f4:	90                   	nop
  f5:	90                   	nop
  f6:	90                   	nop
  f7:	90                   	nop
  f8:	90                   	nop
  f9:	90                   	nop
  fa:	90                   	nop
  fb:	90                   	nop
  fc:	90                   	nop
  fd:	90                   	nop
  fe:	90                   	nop
  ff:	90                   	nop

00000100 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	53                   	push   %ebx
 104:	8b 4d 08             	mov    0x8(%ebp),%ecx
 107:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 10a:	0f b6 01             	movzbl (%ecx),%eax
 10d:	84 c0                	test   %al,%al
 10f:	75 14                	jne    125 <strcmp+0x25>
 111:	eb 25                	jmp    138 <strcmp+0x38>
 113:	90                   	nop
 114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
 118:	83 c1 01             	add    $0x1,%ecx
 11b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 11e:	0f b6 01             	movzbl (%ecx),%eax
 121:	84 c0                	test   %al,%al
 123:	74 13                	je     138 <strcmp+0x38>
 125:	0f b6 1a             	movzbl (%edx),%ebx
 128:	38 d8                	cmp    %bl,%al
 12a:	74 ec                	je     118 <strcmp+0x18>
 12c:	0f b6 db             	movzbl %bl,%ebx
 12f:	0f b6 c0             	movzbl %al,%eax
 132:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 134:	5b                   	pop    %ebx
 135:	5d                   	pop    %ebp
 136:	c3                   	ret    
 137:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 138:	0f b6 1a             	movzbl (%edx),%ebx
 13b:	31 c0                	xor    %eax,%eax
 13d:	0f b6 db             	movzbl %bl,%ebx
 140:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 142:	5b                   	pop    %ebx
 143:	5d                   	pop    %ebp
 144:	c3                   	ret    
 145:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 149:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000150 <strlen>:

uint
strlen(char *s)
{
 150:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
 151:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 153:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
 155:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 157:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 15a:	80 39 00             	cmpb   $0x0,(%ecx)
 15d:	74 0c                	je     16b <strlen+0x1b>
 15f:	90                   	nop
 160:	83 c2 01             	add    $0x1,%edx
 163:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 167:	89 d0                	mov    %edx,%eax
 169:	75 f5                	jne    160 <strlen+0x10>
    ;
  return n;
}
 16b:	5d                   	pop    %ebp
 16c:	c3                   	ret    
 16d:	8d 76 00             	lea    0x0(%esi),%esi

00000170 <memset>:

void*
memset(void *dst, int c, uint n)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	8b 55 08             	mov    0x8(%ebp),%edx
 176:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 177:	8b 4d 10             	mov    0x10(%ebp),%ecx
 17a:	8b 45 0c             	mov    0xc(%ebp),%eax
 17d:	89 d7                	mov    %edx,%edi
 17f:	fc                   	cld    
 180:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 182:	89 d0                	mov    %edx,%eax
 184:	5f                   	pop    %edi
 185:	5d                   	pop    %ebp
 186:	c3                   	ret    
 187:	89 f6                	mov    %esi,%esi
 189:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000190 <strchr>:

char*
strchr(const char *s, char c)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	8b 45 08             	mov    0x8(%ebp),%eax
 196:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 19a:	0f b6 10             	movzbl (%eax),%edx
 19d:	84 d2                	test   %dl,%dl
 19f:	75 11                	jne    1b2 <strchr+0x22>
 1a1:	eb 15                	jmp    1b8 <strchr+0x28>
 1a3:	90                   	nop
 1a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1a8:	83 c0 01             	add    $0x1,%eax
 1ab:	0f b6 10             	movzbl (%eax),%edx
 1ae:	84 d2                	test   %dl,%dl
 1b0:	74 06                	je     1b8 <strchr+0x28>
    if(*s == c)
 1b2:	38 ca                	cmp    %cl,%dl
 1b4:	75 f2                	jne    1a8 <strchr+0x18>
      return (char*)s;
  return 0;
}
 1b6:	5d                   	pop    %ebp
 1b7:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1b8:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 1ba:	5d                   	pop    %ebp
 1bb:	90                   	nop
 1bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1c0:	c3                   	ret    
 1c1:	eb 0d                	jmp    1d0 <atoi>
 1c3:	90                   	nop
 1c4:	90                   	nop
 1c5:	90                   	nop
 1c6:	90                   	nop
 1c7:	90                   	nop
 1c8:	90                   	nop
 1c9:	90                   	nop
 1ca:	90                   	nop
 1cb:	90                   	nop
 1cc:	90                   	nop
 1cd:	90                   	nop
 1ce:	90                   	nop
 1cf:	90                   	nop

000001d0 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1d0:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d1:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1d8:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d9:	0f b6 11             	movzbl (%ecx),%edx
 1dc:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1df:	80 fb 09             	cmp    $0x9,%bl
 1e2:	77 1c                	ja     200 <atoi+0x30>
 1e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 1e8:	0f be d2             	movsbl %dl,%edx
 1eb:	83 c1 01             	add    $0x1,%ecx
 1ee:	8d 04 80             	lea    (%eax,%eax,4),%eax
 1f1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f5:	0f b6 11             	movzbl (%ecx),%edx
 1f8:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1fb:	80 fb 09             	cmp    $0x9,%bl
 1fe:	76 e8                	jbe    1e8 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 200:	5b                   	pop    %ebx
 201:	5d                   	pop    %ebp
 202:	c3                   	ret    
 203:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 209:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000210 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	56                   	push   %esi
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	53                   	push   %ebx
 218:	8b 5d 10             	mov    0x10(%ebp),%ebx
 21b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 21e:	85 db                	test   %ebx,%ebx
 220:	7e 14                	jle    236 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
 222:	31 d2                	xor    %edx,%edx
 224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 228:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 22c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 22f:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 232:	39 da                	cmp    %ebx,%edx
 234:	75 f2                	jne    228 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 236:	5b                   	pop    %ebx
 237:	5e                   	pop    %esi
 238:	5d                   	pop    %ebp
 239:	c3                   	ret    
 23a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000240 <stat>:
  return buf;
}

int
stat(char *n, struct stat *st)
{
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 246:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(char *n, struct stat *st)
{
 249:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 24c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 24f:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 254:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 25b:	00 
 25c:	89 04 24             	mov    %eax,(%esp)
 25f:	e8 d4 00 00 00       	call   338 <open>
  if(fd < 0)
 264:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 266:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 268:	78 19                	js     283 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 26a:	8b 45 0c             	mov    0xc(%ebp),%eax
 26d:	89 1c 24             	mov    %ebx,(%esp)
 270:	89 44 24 04          	mov    %eax,0x4(%esp)
 274:	e8 d7 00 00 00       	call   350 <fstat>
  close(fd);
 279:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 27c:	89 c6                	mov    %eax,%esi
  close(fd);
 27e:	e8 9d 00 00 00       	call   320 <close>
  return r;
}
 283:	89 f0                	mov    %esi,%eax
 285:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 288:	8b 75 fc             	mov    -0x4(%ebp),%esi
 28b:	89 ec                	mov    %ebp,%esp
 28d:	5d                   	pop    %ebp
 28e:	c3                   	ret    
 28f:	90                   	nop

00000290 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 290:	55                   	push   %ebp
 291:	89 e5                	mov    %esp,%ebp
 293:	57                   	push   %edi
 294:	56                   	push   %esi
 295:	31 f6                	xor    %esi,%esi
 297:	53                   	push   %ebx
 298:	83 ec 2c             	sub    $0x2c,%esp
 29b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 29e:	eb 06                	jmp    2a6 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2a0:	3c 0a                	cmp    $0xa,%al
 2a2:	74 39                	je     2dd <gets+0x4d>
 2a4:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a6:	8d 5e 01             	lea    0x1(%esi),%ebx
 2a9:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 2ac:	7d 31                	jge    2df <gets+0x4f>
    cc = read(0, &c, 1);
 2ae:	8d 45 e7             	lea    -0x19(%ebp),%eax
 2b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2b8:	00 
 2b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 2bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2c4:	e8 47 00 00 00       	call   310 <read>
    if(cc < 1)
 2c9:	85 c0                	test   %eax,%eax
 2cb:	7e 12                	jle    2df <gets+0x4f>
      break;
    buf[i++] = c;
 2cd:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 2d1:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 2d5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 2d9:	3c 0d                	cmp    $0xd,%al
 2db:	75 c3                	jne    2a0 <gets+0x10>
 2dd:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 2df:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 2e3:	89 f8                	mov    %edi,%eax
 2e5:	83 c4 2c             	add    $0x2c,%esp
 2e8:	5b                   	pop    %ebx
 2e9:	5e                   	pop    %esi
 2ea:	5f                   	pop    %edi
 2eb:	5d                   	pop    %ebp
 2ec:	c3                   	ret    
 2ed:	90                   	nop
 2ee:	90                   	nop
 2ef:	90                   	nop

000002f0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2f0:	b8 01 00 00 00       	mov    $0x1,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <exit>:
SYSCALL(exit)
 2f8:	b8 02 00 00 00       	mov    $0x2,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <wait>:
SYSCALL(wait)
 300:	b8 03 00 00 00       	mov    $0x3,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <pipe>:
SYSCALL(pipe)
 308:	b8 04 00 00 00       	mov    $0x4,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <read>:
SYSCALL(read)
 310:	b8 06 00 00 00       	mov    $0x6,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <write>:
SYSCALL(write)
 318:	b8 05 00 00 00       	mov    $0x5,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <close>:
SYSCALL(close)
 320:	b8 07 00 00 00       	mov    $0x7,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <kill>:
SYSCALL(kill)
 328:	b8 08 00 00 00       	mov    $0x8,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <exec>:
SYSCALL(exec)
 330:	b8 09 00 00 00       	mov    $0x9,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <open>:
SYSCALL(open)
 338:	b8 0a 00 00 00       	mov    $0xa,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <mknod>:
SYSCALL(mknod)
 340:	b8 0b 00 00 00       	mov    $0xb,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <unlink>:
SYSCALL(unlink)
 348:	b8 0c 00 00 00       	mov    $0xc,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <fstat>:
SYSCALL(fstat)
 350:	b8 0d 00 00 00       	mov    $0xd,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <link>:
SYSCALL(link)
 358:	b8 0e 00 00 00       	mov    $0xe,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <mkdir>:
SYSCALL(mkdir)
 360:	b8 0f 00 00 00       	mov    $0xf,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <chdir>:
SYSCALL(chdir)
 368:	b8 10 00 00 00       	mov    $0x10,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <dup>:
SYSCALL(dup)
 370:	b8 11 00 00 00       	mov    $0x11,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <getpid>:
SYSCALL(getpid)
 378:	b8 12 00 00 00       	mov    $0x12,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <sbrk>:
SYSCALL(sbrk)
 380:	b8 13 00 00 00       	mov    $0x13,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <sleep>:
SYSCALL(sleep)
 388:	b8 14 00 00 00       	mov    $0x14,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <uptime>:
SYSCALL(uptime)
 390:	b8 15 00 00 00       	mov    $0x15,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    
 398:	90                   	nop
 399:	90                   	nop
 39a:	90                   	nop
 39b:	90                   	nop
 39c:	90                   	nop
 39d:	90                   	nop
 39e:	90                   	nop
 39f:	90                   	nop

000003a0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	57                   	push   %edi
 3a4:	89 cf                	mov    %ecx,%edi
 3a6:	56                   	push   %esi
 3a7:	89 c6                	mov    %eax,%esi
 3a9:	53                   	push   %ebx
 3aa:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3b0:	85 c9                	test   %ecx,%ecx
 3b2:	74 04                	je     3b8 <printint+0x18>
 3b4:	85 d2                	test   %edx,%edx
 3b6:	78 70                	js     428 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3b8:	89 d0                	mov    %edx,%eax
 3ba:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 3c1:	31 c9                	xor    %ecx,%ecx
 3c3:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 3c6:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 3c8:	31 d2                	xor    %edx,%edx
 3ca:	f7 f7                	div    %edi
 3cc:	0f b6 92 d4 07 00 00 	movzbl 0x7d4(%edx),%edx
 3d3:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 3d6:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 3d9:	85 c0                	test   %eax,%eax
 3db:	75 eb                	jne    3c8 <printint+0x28>
  if(neg)
 3dd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 3e0:	85 c0                	test   %eax,%eax
 3e2:	74 08                	je     3ec <printint+0x4c>
    buf[i++] = '-';
 3e4:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 3e9:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 3ec:	8d 79 ff             	lea    -0x1(%ecx),%edi
 3ef:	01 fb                	add    %edi,%ebx
 3f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 3f8:	0f b6 03             	movzbl (%ebx),%eax
 3fb:	83 ef 01             	sub    $0x1,%edi
 3fe:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 401:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 408:	00 
 409:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 40c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 40f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 412:	89 44 24 04          	mov    %eax,0x4(%esp)
 416:	e8 fd fe ff ff       	call   318 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 41b:	83 ff ff             	cmp    $0xffffffff,%edi
 41e:	75 d8                	jne    3f8 <printint+0x58>
    putc(fd, buf[i]);
}
 420:	83 c4 4c             	add    $0x4c,%esp
 423:	5b                   	pop    %ebx
 424:	5e                   	pop    %esi
 425:	5f                   	pop    %edi
 426:	5d                   	pop    %ebp
 427:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 428:	89 d0                	mov    %edx,%eax
 42a:	f7 d8                	neg    %eax
 42c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 433:	eb 8c                	jmp    3c1 <printint+0x21>
 435:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 439:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000440 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	57                   	push   %edi
 444:	56                   	push   %esi
 445:	53                   	push   %ebx
 446:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 449:	8b 45 0c             	mov    0xc(%ebp),%eax
 44c:	0f b6 10             	movzbl (%eax),%edx
 44f:	84 d2                	test   %dl,%dl
 451:	0f 84 c9 00 00 00    	je     520 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 457:	8d 4d 10             	lea    0x10(%ebp),%ecx
 45a:	31 ff                	xor    %edi,%edi
 45c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 45f:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 461:	8d 75 e7             	lea    -0x19(%ebp),%esi
 464:	eb 1e                	jmp    484 <printf+0x44>
 466:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 468:	83 fa 25             	cmp    $0x25,%edx
 46b:	0f 85 b7 00 00 00    	jne    528 <printf+0xe8>
 471:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 475:	83 c3 01             	add    $0x1,%ebx
 478:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 47c:	84 d2                	test   %dl,%dl
 47e:	0f 84 9c 00 00 00    	je     520 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 484:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 486:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 489:	74 dd                	je     468 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 48b:	83 ff 25             	cmp    $0x25,%edi
 48e:	75 e5                	jne    475 <printf+0x35>
      if(c == 'd'){
 490:	83 fa 64             	cmp    $0x64,%edx
 493:	0f 84 47 01 00 00    	je     5e0 <printf+0x1a0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 499:	83 fa 70             	cmp    $0x70,%edx
 49c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 4a0:	0f 84 aa 00 00 00    	je     550 <printf+0x110>
 4a6:	83 fa 78             	cmp    $0x78,%edx
 4a9:	0f 84 a1 00 00 00    	je     550 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 4af:	83 fa 73             	cmp    $0x73,%edx
 4b2:	0f 84 c0 00 00 00    	je     578 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4b8:	83 fa 63             	cmp    $0x63,%edx
 4bb:	90                   	nop
 4bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 4c0:	0f 84 42 01 00 00    	je     608 <printf+0x1c8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4c6:	83 fa 25             	cmp    $0x25,%edx
 4c9:	0f 84 01 01 00 00    	je     5d0 <printf+0x190>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 4cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4d2:	89 55 cc             	mov    %edx,-0x34(%ebp)
 4d5:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 4d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4e0:	00 
 4e1:	89 74 24 04          	mov    %esi,0x4(%esp)
 4e5:	89 0c 24             	mov    %ecx,(%esp)
 4e8:	e8 2b fe ff ff       	call   318 <write>
 4ed:	8b 55 cc             	mov    -0x34(%ebp),%edx
 4f0:	88 55 e7             	mov    %dl,-0x19(%ebp)
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4f6:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 4f9:	31 ff                	xor    %edi,%edi
 4fb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 502:	00 
 503:	89 74 24 04          	mov    %esi,0x4(%esp)
 507:	89 04 24             	mov    %eax,(%esp)
 50a:	e8 09 fe ff ff       	call   318 <write>
 50f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 512:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 516:	84 d2                	test   %dl,%dl
 518:	0f 85 66 ff ff ff    	jne    484 <printf+0x44>
 51e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 520:	83 c4 3c             	add    $0x3c,%esp
 523:	5b                   	pop    %ebx
 524:	5e                   	pop    %esi
 525:	5f                   	pop    %edi
 526:	5d                   	pop    %ebp
 527:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 528:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 52b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 52e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 535:	00 
 536:	89 74 24 04          	mov    %esi,0x4(%esp)
 53a:	89 04 24             	mov    %eax,(%esp)
 53d:	e8 d6 fd ff ff       	call   318 <write>
 542:	8b 45 0c             	mov    0xc(%ebp),%eax
 545:	e9 2b ff ff ff       	jmp    475 <printf+0x35>
 54a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 550:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 553:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 558:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 55a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 561:	8b 10                	mov    (%eax),%edx
 563:	8b 45 08             	mov    0x8(%ebp),%eax
 566:	e8 35 fe ff ff       	call   3a0 <printint>
 56b:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 56e:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 572:	e9 fe fe ff ff       	jmp    475 <printf+0x35>
 577:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 578:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        ap++;
        if(s == 0)
 57b:	b9 cd 07 00 00       	mov    $0x7cd,%ecx
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
 580:	8b 3a                	mov    (%edx),%edi
        ap++;
 582:	83 c2 04             	add    $0x4,%edx
 585:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 588:	85 ff                	test   %edi,%edi
 58a:	0f 44 f9             	cmove  %ecx,%edi
          s = "(null)";
        while(*s != 0){
 58d:	0f b6 17             	movzbl (%edi),%edx
 590:	84 d2                	test   %dl,%dl
 592:	74 33                	je     5c7 <printf+0x187>
 594:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 597:	8b 5d 08             	mov    0x8(%ebp),%ebx
 59a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
          putc(fd, *s);
          s++;
 5a0:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5a3:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5a6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5ad:	00 
 5ae:	89 74 24 04          	mov    %esi,0x4(%esp)
 5b2:	89 1c 24             	mov    %ebx,(%esp)
 5b5:	e8 5e fd ff ff       	call   318 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ba:	0f b6 17             	movzbl (%edi),%edx
 5bd:	84 d2                	test   %dl,%dl
 5bf:	75 df                	jne    5a0 <printf+0x160>
 5c1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 5c4:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5c7:	31 ff                	xor    %edi,%edi
 5c9:	e9 a7 fe ff ff       	jmp    475 <printf+0x35>
 5ce:	66 90                	xchg   %ax,%ax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 5d0:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 5d4:	e9 1a ff ff ff       	jmp    4f3 <printf+0xb3>
 5d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 5e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 5e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 5e8:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 5eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 5f2:	8b 10                	mov    (%eax),%edx
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	e8 a4 fd ff ff       	call   3a0 <printint>
 5fc:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 5ff:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 603:	e9 6d fe ff ff       	jmp    475 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 608:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        putc(fd, *ap);
        ap++;
 60b:	31 ff                	xor    %edi,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 60d:	8b 4d 08             	mov    0x8(%ebp),%ecx
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 610:	8b 02                	mov    (%edx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 612:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 619:	00 
 61a:	89 74 24 04          	mov    %esi,0x4(%esp)
 61e:	89 0c 24             	mov    %ecx,(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 621:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 624:	e8 ef fc ff ff       	call   318 <write>
 629:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 62c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 630:	e9 40 fe ff ff       	jmp    475 <printf+0x35>
 635:	90                   	nop
 636:	90                   	nop
 637:	90                   	nop
 638:	90                   	nop
 639:	90                   	nop
 63a:	90                   	nop
 63b:	90                   	nop
 63c:	90                   	nop
 63d:	90                   	nop
 63e:	90                   	nop
 63f:	90                   	nop

00000640 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 640:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 641:	a1 f0 07 00 00       	mov    0x7f0,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 646:	89 e5                	mov    %esp,%ebp
 648:	57                   	push   %edi
 649:	56                   	push   %esi
 64a:	53                   	push   %ebx
 64b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 64e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 651:	39 c8                	cmp    %ecx,%eax
 653:	73 1d                	jae    672 <free+0x32>
 655:	8d 76 00             	lea    0x0(%esi),%esi
 658:	8b 10                	mov    (%eax),%edx
 65a:	39 d1                	cmp    %edx,%ecx
 65c:	72 1a                	jb     678 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 65e:	39 d0                	cmp    %edx,%eax
 660:	72 08                	jb     66a <free+0x2a>
 662:	39 c8                	cmp    %ecx,%eax
 664:	72 12                	jb     678 <free+0x38>
 666:	39 d1                	cmp    %edx,%ecx
 668:	72 0e                	jb     678 <free+0x38>
 66a:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66c:	39 c8                	cmp    %ecx,%eax
 66e:	66 90                	xchg   %ax,%ax
 670:	72 e6                	jb     658 <free+0x18>
 672:	8b 10                	mov    (%eax),%edx
 674:	eb e8                	jmp    65e <free+0x1e>
 676:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 678:	8b 71 04             	mov    0x4(%ecx),%esi
 67b:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 67e:	39 d7                	cmp    %edx,%edi
 680:	74 19                	je     69b <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 682:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 685:	8b 50 04             	mov    0x4(%eax),%edx
 688:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 68b:	39 ce                	cmp    %ecx,%esi
 68d:	74 23                	je     6b2 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 68f:	89 08                	mov    %ecx,(%eax)
  freep = p;
 691:	a3 f0 07 00 00       	mov    %eax,0x7f0
}
 696:	5b                   	pop    %ebx
 697:	5e                   	pop    %esi
 698:	5f                   	pop    %edi
 699:	5d                   	pop    %ebp
 69a:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 69b:	03 72 04             	add    0x4(%edx),%esi
 69e:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a1:	8b 10                	mov    (%eax),%edx
 6a3:	8b 12                	mov    (%edx),%edx
 6a5:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 6a8:	8b 50 04             	mov    0x4(%eax),%edx
 6ab:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6ae:	39 ce                	cmp    %ecx,%esi
 6b0:	75 dd                	jne    68f <free+0x4f>
    p->s.size += bp->s.size;
 6b2:	03 51 04             	add    0x4(%ecx),%edx
 6b5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6b8:	8b 53 f8             	mov    -0x8(%ebx),%edx
 6bb:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 6bd:	a3 f0 07 00 00       	mov    %eax,0x7f0
}
 6c2:	5b                   	pop    %ebx
 6c3:	5e                   	pop    %esi
 6c4:	5f                   	pop    %edi
 6c5:	5d                   	pop    %ebp
 6c6:	c3                   	ret    
 6c7:	89 f6                	mov    %esi,%esi
 6c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000006d0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6d0:	55                   	push   %ebp
 6d1:	89 e5                	mov    %esp,%ebp
 6d3:	57                   	push   %edi
 6d4:	56                   	push   %esi
 6d5:	53                   	push   %ebx
 6d6:	83 ec 2c             	sub    $0x2c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 6dc:	8b 0d f0 07 00 00    	mov    0x7f0,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6e2:	83 c3 07             	add    $0x7,%ebx
 6e5:	c1 eb 03             	shr    $0x3,%ebx
 6e8:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 6eb:	85 c9                	test   %ecx,%ecx
 6ed:	0f 84 9b 00 00 00    	je     78e <malloc+0xbe>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6f3:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 6f5:	8b 50 04             	mov    0x4(%eax),%edx
 6f8:	39 d3                	cmp    %edx,%ebx
 6fa:	76 27                	jbe    723 <malloc+0x53>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 6fc:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 703:	be 00 80 00 00       	mov    $0x8000,%esi
 708:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 70b:	90                   	nop
 70c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 710:	3b 05 f0 07 00 00    	cmp    0x7f0,%eax
 716:	74 30                	je     748 <malloc+0x78>
 718:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 71a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 71c:	8b 50 04             	mov    0x4(%eax),%edx
 71f:	39 d3                	cmp    %edx,%ebx
 721:	77 ed                	ja     710 <malloc+0x40>
      if(p->s.size == nunits)
 723:	39 d3                	cmp    %edx,%ebx
 725:	74 61                	je     788 <malloc+0xb8>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 727:	29 da                	sub    %ebx,%edx
 729:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 72c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 72f:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 732:	89 0d f0 07 00 00    	mov    %ecx,0x7f0
      return (void*)(p + 1);
 738:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 73b:	83 c4 2c             	add    $0x2c,%esp
 73e:	5b                   	pop    %ebx
 73f:	5e                   	pop    %esi
 740:	5f                   	pop    %edi
 741:	5d                   	pop    %ebp
 742:	c3                   	ret    
 743:	90                   	nop
 744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 74b:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
 751:	bf 00 10 00 00       	mov    $0x1000,%edi
 756:	0f 43 fb             	cmovae %ebx,%edi
 759:	0f 42 c6             	cmovb  %esi,%eax
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 75c:	89 04 24             	mov    %eax,(%esp)
 75f:	e8 1c fc ff ff       	call   380 <sbrk>
  if(p == (char*)-1)
 764:	83 f8 ff             	cmp    $0xffffffff,%eax
 767:	74 18                	je     781 <malloc+0xb1>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 769:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 76c:	83 c0 08             	add    $0x8,%eax
 76f:	89 04 24             	mov    %eax,(%esp)
 772:	e8 c9 fe ff ff       	call   640 <free>
  return freep;
 777:	8b 0d f0 07 00 00    	mov    0x7f0,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 77d:	85 c9                	test   %ecx,%ecx
 77f:	75 99                	jne    71a <malloc+0x4a>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 781:	31 c0                	xor    %eax,%eax
 783:	eb b6                	jmp    73b <malloc+0x6b>
 785:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 788:	8b 10                	mov    (%eax),%edx
 78a:	89 11                	mov    %edx,(%ecx)
 78c:	eb a4                	jmp    732 <malloc+0x62>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 78e:	c7 05 f0 07 00 00 e8 	movl   $0x7e8,0x7f0
 795:	07 00 00 
    base.s.size = 0;
 798:	b9 e8 07 00 00       	mov    $0x7e8,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 79d:	c7 05 e8 07 00 00 e8 	movl   $0x7e8,0x7e8
 7a4:	07 00 00 
    base.s.size = 0;
 7a7:	c7 05 ec 07 00 00 00 	movl   $0x0,0x7ec
 7ae:	00 00 00 
 7b1:	e9 3d ff ff ff       	jmp    6f3 <malloc+0x23>
