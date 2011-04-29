
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
   7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   a:	eb 1c                	jmp    28 <cat+0x28>
   c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    write(1, buf, n);
  10:	89 44 24 08          	mov    %eax,0x8(%esp)
  14:	c7 44 24 04 60 08 00 	movl   $0x860,0x4(%esp)
  1b:	00 
  1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  23:	e8 30 03 00 00       	call   358 <write>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  28:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  2f:	00 
  30:	c7 44 24 04 60 08 00 	movl   $0x860,0x4(%esp)
  37:	00 
  38:	89 1c 24             	mov    %ebx,(%esp)
  3b:	e8 10 03 00 00       	call   350 <read>
  40:	83 f8 00             	cmp    $0x0,%eax
  43:	7f cb                	jg     10 <cat+0x10>
    write(1, buf, n);
  if(n < 0){
  45:	75 0a                	jne    51 <cat+0x51>
    printf(1, "cat: read error\n");
    exit();
  }
}
  47:	83 c4 14             	add    $0x14,%esp
  4a:	5b                   	pop    %ebx
  4b:	5d                   	pop    %ebp
  4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  50:	c3                   	ret    
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
    write(1, buf, n);
  if(n < 0){
    printf(1, "cat: read error\n");
  51:	c7 44 24 04 fe 07 00 	movl   $0x7fe,0x4(%esp)
  58:	00 
  59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  60:	e8 1b 04 00 00       	call   480 <printf>
    exit();
  65:	e8 ce 02 00 00       	call   338 <exit>
  6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000070 <main>:
  }
}

int
main(int argc, char *argv[])
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	83 e4 f0             	and    $0xfffffff0,%esp
  76:	57                   	push   %edi
  77:	56                   	push   %esi
  78:	53                   	push   %ebx
  79:	83 ec 24             	sub    $0x24,%esp
  7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  int fd, i;

  if(argc <= 1){
  7f:	83 ff 01             	cmp    $0x1,%edi
  82:	7e 6c                	jle    f0 <main+0x80>
    cat(0);
    exit();
  84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  87:	be 01 00 00 00       	mov    $0x1,%esi
  8c:	83 c3 04             	add    $0x4,%ebx
  8f:	90                   	nop
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  97:	00 
  98:	8b 03                	mov    (%ebx),%eax
  9a:	89 04 24             	mov    %eax,(%esp)
  9d:	e8 d6 02 00 00       	call   378 <open>
  a2:	85 c0                	test   %eax,%eax
  a4:	78 2a                	js     d0 <main+0x60>
      printf(1, "cat: cannot open %s\n", argv[i]);
      exit();
    }
    cat(fd);
  a6:	89 04 24             	mov    %eax,(%esp)
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
  a9:	83 c6 01             	add    $0x1,%esi
  ac:	83 c3 04             	add    $0x4,%ebx
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "cat: cannot open %s\n", argv[i]);
      exit();
    }
    cat(fd);
  af:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  b3:	e8 48 ff ff ff       	call   0 <cat>
    close(fd);
  b8:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  bc:	89 04 24             	mov    %eax,(%esp)
  bf:	e8 9c 02 00 00       	call   360 <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
  c4:	39 f7                	cmp    %esi,%edi
  c6:	7f c8                	jg     90 <main+0x20>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
  c8:	e8 6b 02 00 00       	call   338 <exit>
  cd:	8d 76 00             	lea    0x0(%esi),%esi
    exit();
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "cat: cannot open %s\n", argv[i]);
  d0:	8b 03                	mov    (%ebx),%eax
  d2:	c7 44 24 04 0f 08 00 	movl   $0x80f,0x4(%esp)
  d9:	00 
  da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  e5:	e8 96 03 00 00       	call   480 <printf>
      exit();
  ea:	e8 49 02 00 00       	call   338 <exit>
  ef:	90                   	nop
main(int argc, char *argv[])
{
  int fd, i;

  if(argc <= 1){
    cat(0);
  f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  f7:	e8 04 ff ff ff       	call   0 <cat>
    exit();
  fc:	e8 37 02 00 00       	call   338 <exit>
 101:	90                   	nop
 102:	90                   	nop
 103:	90                   	nop
 104:	90                   	nop
 105:	90                   	nop
 106:	90                   	nop
 107:	90                   	nop
 108:	90                   	nop
 109:	90                   	nop
 10a:	90                   	nop
 10b:	90                   	nop
 10c:	90                   	nop
 10d:	90                   	nop
 10e:	90                   	nop
 10f:	90                   	nop

00000110 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 110:	55                   	push   %ebp
 111:	31 d2                	xor    %edx,%edx
 113:	89 e5                	mov    %esp,%ebp
 115:	8b 45 08             	mov    0x8(%ebp),%eax
 118:	53                   	push   %ebx
 119:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 11c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 120:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 124:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 127:	83 c2 01             	add    $0x1,%edx
 12a:	84 c9                	test   %cl,%cl
 12c:	75 f2                	jne    120 <strcpy+0x10>
    ;
  return os;
}
 12e:	5b                   	pop    %ebx
 12f:	5d                   	pop    %ebp
 130:	c3                   	ret    
 131:	eb 0d                	jmp    140 <strcmp>
 133:	90                   	nop
 134:	90                   	nop
 135:	90                   	nop
 136:	90                   	nop
 137:	90                   	nop
 138:	90                   	nop
 139:	90                   	nop
 13a:	90                   	nop
 13b:	90                   	nop
 13c:	90                   	nop
 13d:	90                   	nop
 13e:	90                   	nop
 13f:	90                   	nop

00000140 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	53                   	push   %ebx
 144:	8b 4d 08             	mov    0x8(%ebp),%ecx
 147:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 14a:	0f b6 01             	movzbl (%ecx),%eax
 14d:	84 c0                	test   %al,%al
 14f:	75 14                	jne    165 <strcmp+0x25>
 151:	eb 25                	jmp    178 <strcmp+0x38>
 153:	90                   	nop
 154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
 158:	83 c1 01             	add    $0x1,%ecx
 15b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 15e:	0f b6 01             	movzbl (%ecx),%eax
 161:	84 c0                	test   %al,%al
 163:	74 13                	je     178 <strcmp+0x38>
 165:	0f b6 1a             	movzbl (%edx),%ebx
 168:	38 d8                	cmp    %bl,%al
 16a:	74 ec                	je     158 <strcmp+0x18>
 16c:	0f b6 db             	movzbl %bl,%ebx
 16f:	0f b6 c0             	movzbl %al,%eax
 172:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 174:	5b                   	pop    %ebx
 175:	5d                   	pop    %ebp
 176:	c3                   	ret    
 177:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 178:	0f b6 1a             	movzbl (%edx),%ebx
 17b:	31 c0                	xor    %eax,%eax
 17d:	0f b6 db             	movzbl %bl,%ebx
 180:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 182:	5b                   	pop    %ebx
 183:	5d                   	pop    %ebp
 184:	c3                   	ret    
 185:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 189:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000190 <strlen>:

uint
strlen(char *s)
{
 190:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
 191:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 193:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
 195:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 197:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 19a:	80 39 00             	cmpb   $0x0,(%ecx)
 19d:	74 0c                	je     1ab <strlen+0x1b>
 19f:	90                   	nop
 1a0:	83 c2 01             	add    $0x1,%edx
 1a3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1a7:	89 d0                	mov    %edx,%eax
 1a9:	75 f5                	jne    1a0 <strlen+0x10>
    ;
  return n;
}
 1ab:	5d                   	pop    %ebp
 1ac:	c3                   	ret    
 1ad:	8d 76 00             	lea    0x0(%esi),%esi

000001b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	8b 55 08             	mov    0x8(%ebp),%edx
 1b6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bd:	89 d7                	mov    %edx,%edi
 1bf:	fc                   	cld    
 1c0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1c2:	89 d0                	mov    %edx,%eax
 1c4:	5f                   	pop    %edi
 1c5:	5d                   	pop    %ebp
 1c6:	c3                   	ret    
 1c7:	89 f6                	mov    %esi,%esi
 1c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000001d0 <strchr>:

char*
strchr(const char *s, char c)
{
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
 1d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1da:	0f b6 10             	movzbl (%eax),%edx
 1dd:	84 d2                	test   %dl,%dl
 1df:	75 11                	jne    1f2 <strchr+0x22>
 1e1:	eb 15                	jmp    1f8 <strchr+0x28>
 1e3:	90                   	nop
 1e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 1e8:	83 c0 01             	add    $0x1,%eax
 1eb:	0f b6 10             	movzbl (%eax),%edx
 1ee:	84 d2                	test   %dl,%dl
 1f0:	74 06                	je     1f8 <strchr+0x28>
    if(*s == c)
 1f2:	38 ca                	cmp    %cl,%dl
 1f4:	75 f2                	jne    1e8 <strchr+0x18>
      return (char*)s;
  return 0;
}
 1f6:	5d                   	pop    %ebp
 1f7:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1f8:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 1fa:	5d                   	pop    %ebp
 1fb:	90                   	nop
 1fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 200:	c3                   	ret    
 201:	eb 0d                	jmp    210 <atoi>
 203:	90                   	nop
 204:	90                   	nop
 205:	90                   	nop
 206:	90                   	nop
 207:	90                   	nop
 208:	90                   	nop
 209:	90                   	nop
 20a:	90                   	nop
 20b:	90                   	nop
 20c:	90                   	nop
 20d:	90                   	nop
 20e:	90                   	nop
 20f:	90                   	nop

00000210 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 210:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 211:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 213:	89 e5                	mov    %esp,%ebp
 215:	8b 4d 08             	mov    0x8(%ebp),%ecx
 218:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 219:	0f b6 11             	movzbl (%ecx),%edx
 21c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 21f:	80 fb 09             	cmp    $0x9,%bl
 222:	77 1c                	ja     240 <atoi+0x30>
 224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 228:	0f be d2             	movsbl %dl,%edx
 22b:	83 c1 01             	add    $0x1,%ecx
 22e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 231:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 235:	0f b6 11             	movzbl (%ecx),%edx
 238:	8d 5a d0             	lea    -0x30(%edx),%ebx
 23b:	80 fb 09             	cmp    $0x9,%bl
 23e:	76 e8                	jbe    228 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 240:	5b                   	pop    %ebx
 241:	5d                   	pop    %ebp
 242:	c3                   	ret    
 243:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000250 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 250:	55                   	push   %ebp
 251:	89 e5                	mov    %esp,%ebp
 253:	56                   	push   %esi
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	53                   	push   %ebx
 258:	8b 5d 10             	mov    0x10(%ebp),%ebx
 25b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 25e:	85 db                	test   %ebx,%ebx
 260:	7e 14                	jle    276 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
 262:	31 d2                	xor    %edx,%edx
 264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 268:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 26c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 26f:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 272:	39 da                	cmp    %ebx,%edx
 274:	75 f2                	jne    268 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 276:	5b                   	pop    %ebx
 277:	5e                   	pop    %esi
 278:	5d                   	pop    %ebp
 279:	c3                   	ret    
 27a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000280 <stat>:
  return buf;
}

int
stat(char *n, struct stat *st)
{
 280:	55                   	push   %ebp
 281:	89 e5                	mov    %esp,%ebp
 283:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 286:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(char *n, struct stat *st)
{
 289:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 28c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 28f:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 294:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 29b:	00 
 29c:	89 04 24             	mov    %eax,(%esp)
 29f:	e8 d4 00 00 00       	call   378 <open>
  if(fd < 0)
 2a4:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a6:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 2a8:	78 19                	js     2c3 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 2aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ad:	89 1c 24             	mov    %ebx,(%esp)
 2b0:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b4:	e8 d7 00 00 00       	call   390 <fstat>
  close(fd);
 2b9:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 2bc:	89 c6                	mov    %eax,%esi
  close(fd);
 2be:	e8 9d 00 00 00       	call   360 <close>
  return r;
}
 2c3:	89 f0                	mov    %esi,%eax
 2c5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 2c8:	8b 75 fc             	mov    -0x4(%ebp),%esi
 2cb:	89 ec                	mov    %ebp,%esp
 2cd:	5d                   	pop    %ebp
 2ce:	c3                   	ret    
 2cf:	90                   	nop

000002d0 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 2d0:	55                   	push   %ebp
 2d1:	89 e5                	mov    %esp,%ebp
 2d3:	57                   	push   %edi
 2d4:	56                   	push   %esi
 2d5:	31 f6                	xor    %esi,%esi
 2d7:	53                   	push   %ebx
 2d8:	83 ec 2c             	sub    $0x2c,%esp
 2db:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2de:	eb 06                	jmp    2e6 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2e0:	3c 0a                	cmp    $0xa,%al
 2e2:	74 39                	je     31d <gets+0x4d>
 2e4:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e6:	8d 5e 01             	lea    0x1(%esi),%ebx
 2e9:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 2ec:	7d 31                	jge    31f <gets+0x4f>
    cc = read(0, &c, 1);
 2ee:	8d 45 e7             	lea    -0x19(%ebp),%eax
 2f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2f8:	00 
 2f9:	89 44 24 04          	mov    %eax,0x4(%esp)
 2fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 304:	e8 47 00 00 00       	call   350 <read>
    if(cc < 1)
 309:	85 c0                	test   %eax,%eax
 30b:	7e 12                	jle    31f <gets+0x4f>
      break;
    buf[i++] = c;
 30d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 311:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 315:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 319:	3c 0d                	cmp    $0xd,%al
 31b:	75 c3                	jne    2e0 <gets+0x10>
 31d:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 31f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 323:	89 f8                	mov    %edi,%eax
 325:	83 c4 2c             	add    $0x2c,%esp
 328:	5b                   	pop    %ebx
 329:	5e                   	pop    %esi
 32a:	5f                   	pop    %edi
 32b:	5d                   	pop    %ebp
 32c:	c3                   	ret    
 32d:	90                   	nop
 32e:	90                   	nop
 32f:	90                   	nop

00000330 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 330:	b8 01 00 00 00       	mov    $0x1,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <exit>:
SYSCALL(exit)
 338:	b8 02 00 00 00       	mov    $0x2,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <wait>:
SYSCALL(wait)
 340:	b8 03 00 00 00       	mov    $0x3,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <pipe>:
SYSCALL(pipe)
 348:	b8 04 00 00 00       	mov    $0x4,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <read>:
SYSCALL(read)
 350:	b8 06 00 00 00       	mov    $0x6,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <write>:
SYSCALL(write)
 358:	b8 05 00 00 00       	mov    $0x5,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <close>:
SYSCALL(close)
 360:	b8 07 00 00 00       	mov    $0x7,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <kill>:
SYSCALL(kill)
 368:	b8 08 00 00 00       	mov    $0x8,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <exec>:
SYSCALL(exec)
 370:	b8 09 00 00 00       	mov    $0x9,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <open>:
SYSCALL(open)
 378:	b8 0a 00 00 00       	mov    $0xa,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <mknod>:
SYSCALL(mknod)
 380:	b8 0b 00 00 00       	mov    $0xb,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <unlink>:
SYSCALL(unlink)
 388:	b8 0c 00 00 00       	mov    $0xc,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <fstat>:
SYSCALL(fstat)
 390:	b8 0d 00 00 00       	mov    $0xd,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <link>:
SYSCALL(link)
 398:	b8 0e 00 00 00       	mov    $0xe,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <mkdir>:
SYSCALL(mkdir)
 3a0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <chdir>:
SYSCALL(chdir)
 3a8:	b8 10 00 00 00       	mov    $0x10,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <dup>:
SYSCALL(dup)
 3b0:	b8 11 00 00 00       	mov    $0x11,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <getpid>:
SYSCALL(getpid)
 3b8:	b8 12 00 00 00       	mov    $0x12,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <sbrk>:
SYSCALL(sbrk)
 3c0:	b8 13 00 00 00       	mov    $0x13,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <sleep>:
SYSCALL(sleep)
 3c8:	b8 14 00 00 00       	mov    $0x14,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <uptime>:
SYSCALL(uptime)
 3d0:	b8 15 00 00 00       	mov    $0x15,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <getcount>:
SYSCALL(getcount)
 3d8:	b8 16 00 00 00       	mov    $0x16,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	57                   	push   %edi
 3e4:	89 cf                	mov    %ecx,%edi
 3e6:	56                   	push   %esi
 3e7:	89 c6                	mov    %eax,%esi
 3e9:	53                   	push   %ebx
 3ea:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3f0:	85 c9                	test   %ecx,%ecx
 3f2:	74 04                	je     3f8 <printint+0x18>
 3f4:	85 d2                	test   %edx,%edx
 3f6:	78 70                	js     468 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f8:	89 d0                	mov    %edx,%eax
 3fa:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 401:	31 c9                	xor    %ecx,%ecx
 403:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 406:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 408:	31 d2                	xor    %edx,%edx
 40a:	f7 f7                	div    %edi
 40c:	0f b6 92 2b 08 00 00 	movzbl 0x82b(%edx),%edx
 413:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 416:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 419:	85 c0                	test   %eax,%eax
 41b:	75 eb                	jne    408 <printint+0x28>
  if(neg)
 41d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 420:	85 c0                	test   %eax,%eax
 422:	74 08                	je     42c <printint+0x4c>
    buf[i++] = '-';
 424:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 429:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 42c:	8d 79 ff             	lea    -0x1(%ecx),%edi
 42f:	01 fb                	add    %edi,%ebx
 431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 438:	0f b6 03             	movzbl (%ebx),%eax
 43b:	83 ef 01             	sub    $0x1,%edi
 43e:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 441:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 448:	00 
 449:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 44c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 44f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 452:	89 44 24 04          	mov    %eax,0x4(%esp)
 456:	e8 fd fe ff ff       	call   358 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 45b:	83 ff ff             	cmp    $0xffffffff,%edi
 45e:	75 d8                	jne    438 <printint+0x58>
    putc(fd, buf[i]);
}
 460:	83 c4 4c             	add    $0x4c,%esp
 463:	5b                   	pop    %ebx
 464:	5e                   	pop    %esi
 465:	5f                   	pop    %edi
 466:	5d                   	pop    %ebp
 467:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 468:	89 d0                	mov    %edx,%eax
 46a:	f7 d8                	neg    %eax
 46c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 473:	eb 8c                	jmp    401 <printint+0x21>
 475:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000480 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 480:	55                   	push   %ebp
 481:	89 e5                	mov    %esp,%ebp
 483:	57                   	push   %edi
 484:	56                   	push   %esi
 485:	53                   	push   %ebx
 486:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 489:	8b 45 0c             	mov    0xc(%ebp),%eax
 48c:	0f b6 10             	movzbl (%eax),%edx
 48f:	84 d2                	test   %dl,%dl
 491:	0f 84 c9 00 00 00    	je     560 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 497:	8d 4d 10             	lea    0x10(%ebp),%ecx
 49a:	31 ff                	xor    %edi,%edi
 49c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 49f:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 4a1:	8d 75 e7             	lea    -0x19(%ebp),%esi
 4a4:	eb 1e                	jmp    4c4 <printf+0x44>
 4a6:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 4a8:	83 fa 25             	cmp    $0x25,%edx
 4ab:	0f 85 b7 00 00 00    	jne    568 <printf+0xe8>
 4b1:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4b5:	83 c3 01             	add    $0x1,%ebx
 4b8:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 4bc:	84 d2                	test   %dl,%dl
 4be:	0f 84 9c 00 00 00    	je     560 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 4c4:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 4c6:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 4c9:	74 dd                	je     4a8 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4cb:	83 ff 25             	cmp    $0x25,%edi
 4ce:	75 e5                	jne    4b5 <printf+0x35>
      if(c == 'd'){
 4d0:	83 fa 64             	cmp    $0x64,%edx
 4d3:	0f 84 57 01 00 00    	je     630 <printf+0x1b0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 4d9:	83 fa 70             	cmp    $0x70,%edx
 4dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 4e0:	0f 84 aa 00 00 00    	je     590 <printf+0x110>
 4e6:	83 fa 78             	cmp    $0x78,%edx
 4e9:	0f 84 a1 00 00 00    	je     590 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 4ef:	83 fa 73             	cmp    $0x73,%edx
 4f2:	0f 84 c0 00 00 00    	je     5b8 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4f8:	83 fa 63             	cmp    $0x63,%edx
 4fb:	90                   	nop
 4fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 500:	0f 84 52 01 00 00    	je     658 <printf+0x1d8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 506:	83 fa 25             	cmp    $0x25,%edx
 509:	0f 84 f9 00 00 00    	je     608 <printf+0x188>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 50f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 512:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 515:	31 ff                	xor    %edi,%edi
 517:	89 55 cc             	mov    %edx,-0x34(%ebp)
 51a:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 51e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 525:	00 
 526:	89 0c 24             	mov    %ecx,(%esp)
 529:	89 74 24 04          	mov    %esi,0x4(%esp)
 52d:	e8 26 fe ff ff       	call   358 <write>
 532:	8b 55 cc             	mov    -0x34(%ebp),%edx
 535:	8b 45 08             	mov    0x8(%ebp),%eax
 538:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 53f:	00 
 540:	89 74 24 04          	mov    %esi,0x4(%esp)
 544:	88 55 e7             	mov    %dl,-0x19(%ebp)
 547:	89 04 24             	mov    %eax,(%esp)
 54a:	e8 09 fe ff ff       	call   358 <write>
 54f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 552:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 556:	84 d2                	test   %dl,%dl
 558:	0f 85 66 ff ff ff    	jne    4c4 <printf+0x44>
 55e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 560:	83 c4 3c             	add    $0x3c,%esp
 563:	5b                   	pop    %ebx
 564:	5e                   	pop    %esi
 565:	5f                   	pop    %edi
 566:	5d                   	pop    %ebp
 567:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 568:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 56b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 56e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 575:	00 
 576:	89 74 24 04          	mov    %esi,0x4(%esp)
 57a:	89 04 24             	mov    %eax,(%esp)
 57d:	e8 d6 fd ff ff       	call   358 <write>
 582:	8b 45 0c             	mov    0xc(%ebp),%eax
 585:	e9 2b ff ff ff       	jmp    4b5 <printf+0x35>
 58a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 590:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 593:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 598:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 59a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 5a1:	8b 10                	mov    (%eax),%edx
 5a3:	8b 45 08             	mov    0x8(%ebp),%eax
 5a6:	e8 35 fe ff ff       	call   3e0 <printint>
 5ab:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 5ae:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 5b2:	e9 fe fe ff ff       	jmp    4b5 <printf+0x35>
 5b7:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 5b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 5bb:	8b 3a                	mov    (%edx),%edi
        ap++;
 5bd:	83 c2 04             	add    $0x4,%edx
 5c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 5c3:	85 ff                	test   %edi,%edi
 5c5:	0f 84 ba 00 00 00    	je     685 <printf+0x205>
          s = "(null)";
        while(*s != 0){
 5cb:	0f b6 17             	movzbl (%edi),%edx
 5ce:	84 d2                	test   %dl,%dl
 5d0:	74 2d                	je     5ff <printf+0x17f>
 5d2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 5d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
          putc(fd, *s);
          s++;
 5d8:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5db:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5de:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5e5:	00 
 5e6:	89 74 24 04          	mov    %esi,0x4(%esp)
 5ea:	89 1c 24             	mov    %ebx,(%esp)
 5ed:	e8 66 fd ff ff       	call   358 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5f2:	0f b6 17             	movzbl (%edi),%edx
 5f5:	84 d2                	test   %dl,%dl
 5f7:	75 df                	jne    5d8 <printf+0x158>
 5f9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 5fc:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5ff:	31 ff                	xor    %edi,%edi
 601:	e9 af fe ff ff       	jmp    4b5 <printf+0x35>
 606:	66 90                	xchg   %ax,%ax
 608:	8b 55 08             	mov    0x8(%ebp),%edx
 60b:	31 ff                	xor    %edi,%edi
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 60d:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 611:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 618:	00 
 619:	89 74 24 04          	mov    %esi,0x4(%esp)
 61d:	89 14 24             	mov    %edx,(%esp)
 620:	e8 33 fd ff ff       	call   358 <write>
 625:	8b 45 0c             	mov    0xc(%ebp),%eax
 628:	e9 88 fe ff ff       	jmp    4b5 <printf+0x35>
 62d:	8d 76 00             	lea    0x0(%esi),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 630:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 633:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 638:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 63b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 642:	8b 10                	mov    (%eax),%edx
 644:	8b 45 08             	mov    0x8(%ebp),%eax
 647:	e8 94 fd ff ff       	call   3e0 <printint>
 64c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 64f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 653:	e9 5d fe ff ff       	jmp    4b5 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 658:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
        putc(fd, *ap);
        ap++;
 65b:	31 ff                	xor    %edi,%edi
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 65d:	8b 01                	mov    (%ecx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 65f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 666:	00 
 667:	89 74 24 04          	mov    %esi,0x4(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 66b:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 66e:	8b 45 08             	mov    0x8(%ebp),%eax
 671:	89 04 24             	mov    %eax,(%esp)
 674:	e8 df fc ff ff       	call   358 <write>
 679:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 67c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 680:	e9 30 fe ff ff       	jmp    4b5 <printf+0x35>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
 685:	bf 24 08 00 00       	mov    $0x824,%edi
 68a:	e9 3c ff ff ff       	jmp    5cb <printf+0x14b>
 68f:	90                   	nop

00000690 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 690:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 691:	a1 48 08 00 00       	mov    0x848,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 696:	89 e5                	mov    %esp,%ebp
 698:	57                   	push   %edi
 699:	56                   	push   %esi
 69a:	53                   	push   %ebx
 69b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 69e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a1:	39 c8                	cmp    %ecx,%eax
 6a3:	73 1d                	jae    6c2 <free+0x32>
 6a5:	8d 76 00             	lea    0x0(%esi),%esi
 6a8:	8b 10                	mov    (%eax),%edx
 6aa:	39 d1                	cmp    %edx,%ecx
 6ac:	72 1a                	jb     6c8 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ae:	39 d0                	cmp    %edx,%eax
 6b0:	72 08                	jb     6ba <free+0x2a>
 6b2:	39 c8                	cmp    %ecx,%eax
 6b4:	72 12                	jb     6c8 <free+0x38>
 6b6:	39 d1                	cmp    %edx,%ecx
 6b8:	72 0e                	jb     6c8 <free+0x38>
 6ba:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bc:	39 c8                	cmp    %ecx,%eax
 6be:	66 90                	xchg   %ax,%ax
 6c0:	72 e6                	jb     6a8 <free+0x18>
 6c2:	8b 10                	mov    (%eax),%edx
 6c4:	eb e8                	jmp    6ae <free+0x1e>
 6c6:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6c8:	8b 71 04             	mov    0x4(%ecx),%esi
 6cb:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6ce:	39 d7                	cmp    %edx,%edi
 6d0:	74 19                	je     6eb <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6d2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6d5:	8b 50 04             	mov    0x4(%eax),%edx
 6d8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6db:	39 ce                	cmp    %ecx,%esi
 6dd:	74 23                	je     702 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 6df:	89 08                	mov    %ecx,(%eax)
  freep = p;
 6e1:	a3 48 08 00 00       	mov    %eax,0x848
}
 6e6:	5b                   	pop    %ebx
 6e7:	5e                   	pop    %esi
 6e8:	5f                   	pop    %edi
 6e9:	5d                   	pop    %ebp
 6ea:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6eb:	03 72 04             	add    0x4(%edx),%esi
 6ee:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f1:	8b 10                	mov    (%eax),%edx
 6f3:	8b 12                	mov    (%edx),%edx
 6f5:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 6f8:	8b 50 04             	mov    0x4(%eax),%edx
 6fb:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6fe:	39 ce                	cmp    %ecx,%esi
 700:	75 dd                	jne    6df <free+0x4f>
    p->s.size += bp->s.size;
 702:	03 51 04             	add    0x4(%ecx),%edx
 705:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 708:	8b 53 f8             	mov    -0x8(%ebx),%edx
 70b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 70d:	a3 48 08 00 00       	mov    %eax,0x848
}
 712:	5b                   	pop    %ebx
 713:	5e                   	pop    %esi
 714:	5f                   	pop    %edi
 715:	5d                   	pop    %ebp
 716:	c3                   	ret    
 717:	89 f6                	mov    %esi,%esi
 719:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000720 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 720:	55                   	push   %ebp
 721:	89 e5                	mov    %esp,%ebp
 723:	57                   	push   %edi
 724:	56                   	push   %esi
 725:	53                   	push   %ebx
 726:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 729:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 72c:	8b 0d 48 08 00 00    	mov    0x848,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 732:	83 c3 07             	add    $0x7,%ebx
 735:	c1 eb 03             	shr    $0x3,%ebx
 738:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 73b:	85 c9                	test   %ecx,%ecx
 73d:	0f 84 93 00 00 00    	je     7d6 <malloc+0xb6>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 743:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 745:	8b 50 04             	mov    0x4(%eax),%edx
 748:	39 d3                	cmp    %edx,%ebx
 74a:	76 1f                	jbe    76b <malloc+0x4b>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 74c:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 753:	90                   	nop
 754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
    if(p == freep)
 758:	3b 05 48 08 00 00    	cmp    0x848,%eax
 75e:	74 30                	je     790 <malloc+0x70>
 760:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 762:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 764:	8b 50 04             	mov    0x4(%eax),%edx
 767:	39 d3                	cmp    %edx,%ebx
 769:	77 ed                	ja     758 <malloc+0x38>
      if(p->s.size == nunits)
 76b:	39 d3                	cmp    %edx,%ebx
 76d:	74 61                	je     7d0 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 76f:	29 da                	sub    %ebx,%edx
 771:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 774:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 777:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 77a:	89 0d 48 08 00 00    	mov    %ecx,0x848
      return (void*)(p + 1);
 780:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 783:	83 c4 1c             	add    $0x1c,%esp
 786:	5b                   	pop    %ebx
 787:	5e                   	pop    %esi
 788:	5f                   	pop    %edi
 789:	5d                   	pop    %ebp
 78a:	c3                   	ret    
 78b:	90                   	nop
 78c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 790:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 796:	b8 00 80 00 00       	mov    $0x8000,%eax
 79b:	bf 00 10 00 00       	mov    $0x1000,%edi
 7a0:	76 04                	jbe    7a6 <malloc+0x86>
 7a2:	89 f0                	mov    %esi,%eax
 7a4:	89 df                	mov    %ebx,%edi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 7a6:	89 04 24             	mov    %eax,(%esp)
 7a9:	e8 12 fc ff ff       	call   3c0 <sbrk>
  if(p == (char*)-1)
 7ae:	83 f8 ff             	cmp    $0xffffffff,%eax
 7b1:	74 18                	je     7cb <malloc+0xab>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 7b3:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 7b6:	83 c0 08             	add    $0x8,%eax
 7b9:	89 04 24             	mov    %eax,(%esp)
 7bc:	e8 cf fe ff ff       	call   690 <free>
  return freep;
 7c1:	8b 0d 48 08 00 00    	mov    0x848,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 7c7:	85 c9                	test   %ecx,%ecx
 7c9:	75 97                	jne    762 <malloc+0x42>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 7cb:	31 c0                	xor    %eax,%eax
 7cd:	eb b4                	jmp    783 <malloc+0x63>
 7cf:	90                   	nop
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 7d0:	8b 10                	mov    (%eax),%edx
 7d2:	89 11                	mov    %edx,(%ecx)
 7d4:	eb a4                	jmp    77a <malloc+0x5a>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 7d6:	c7 05 48 08 00 00 40 	movl   $0x840,0x848
 7dd:	08 00 00 
    base.s.size = 0;
 7e0:	b9 40 08 00 00       	mov    $0x840,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 7e5:	c7 05 40 08 00 00 40 	movl   $0x840,0x840
 7ec:	08 00 00 
    base.s.size = 0;
 7ef:	c7 05 44 08 00 00 00 	movl   $0x0,0x844
 7f6:	00 00 00 
 7f9:	e9 45 ff ff ff       	jmp    743 <malloc+0x23>
