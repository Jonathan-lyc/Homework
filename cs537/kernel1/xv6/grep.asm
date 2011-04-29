
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 1c             	sub    $0x1c,%esp
   9:	8b 75 08             	mov    0x8(%ebp),%esi
   c:	8b 7d 0c             	mov    0xc(%ebp),%edi
   f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
  18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1c:	89 3c 24             	mov    %edi,(%esp)
  1f:	e8 3c 00 00 00       	call   60 <matchhere>
  24:	85 c0                	test   %eax,%eax
  26:	75 20                	jne    48 <matchstar+0x48>
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0f b6 03             	movzbl (%ebx),%eax
  2b:	84 c0                	test   %al,%al
  2d:	74 0f                	je     3e <matchstar+0x3e>
  2f:	0f be c0             	movsbl %al,%eax
  32:	83 c3 01             	add    $0x1,%ebx
  35:	39 f0                	cmp    %esi,%eax
  37:	74 df                	je     18 <matchstar+0x18>
  39:	83 fe 2e             	cmp    $0x2e,%esi
  3c:	74 da                	je     18 <matchstar+0x18>
  return 0;
}
  3e:	83 c4 1c             	add    $0x1c,%esp
int matchstar(int c, char *re, char *text)
{
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  41:	31 c0                	xor    %eax,%eax
  return 0;
}
  43:	5b                   	pop    %ebx
  44:	5e                   	pop    %esi
  45:	5f                   	pop    %edi
  46:	5d                   	pop    %ebp
  47:	c3                   	ret    
  48:	83 c4 1c             	add    $0x1c,%esp

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
  4b:	b8 01 00 00 00       	mov    $0x1,%eax
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  return 0;
}
  50:	5b                   	pop    %ebx
  51:	5e                   	pop    %esi
  52:	5f                   	pop    %edi
  53:	5d                   	pop    %ebp
  54:	c3                   	ret    
  55:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000060 <matchhere>:
  return 0;
}

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  60:	55                   	push   %ebp
  61:	89 e5                	mov    %esp,%ebp
  63:	56                   	push   %esi
  64:	53                   	push   %ebx
  65:	83 ec 10             	sub    $0x10,%esp
  68:	8b 55 08             	mov    0x8(%ebp),%edx
  6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  if(re[0] == '\0')
  6e:	0f b6 02             	movzbl (%edx),%eax
  71:	84 c0                	test   %al,%al
  73:	75 1c                	jne    91 <matchhere+0x31>
  75:	eb 51                	jmp    c8 <matchhere+0x68>
  77:	90                   	nop
    return 1;
  if(re[1] == '*')
    return matchstar(re[0], re+2, text);
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	0f b6 19             	movzbl (%ecx),%ebx
  7b:	84 db                	test   %bl,%bl
  7d:	74 39                	je     b8 <matchhere+0x58>
  7f:	3c 2e                	cmp    $0x2e,%al
  81:	74 04                	je     87 <matchhere+0x27>
  83:	38 d8                	cmp    %bl,%al
  85:	75 31                	jne    b8 <matchhere+0x58>
}

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
  87:	0f b6 02             	movzbl (%edx),%eax
  8a:	84 c0                	test   %al,%al
  8c:	74 3a                	je     c8 <matchhere+0x68>
  if(re[1] == '*')
    return matchstar(re[0], re+2, text);
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
    return matchhere(re+1, text+1);
  8e:	83 c1 01             	add    $0x1,%ecx
// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
    return 1;
  if(re[1] == '*')
  91:	0f b6 5a 01          	movzbl 0x1(%edx),%ebx
  95:	8d 72 01             	lea    0x1(%edx),%esi
  98:	80 fb 2a             	cmp    $0x2a,%bl
  9b:	74 3b                	je     d8 <matchhere+0x78>
    return matchstar(re[0], re+2, text);
  if(re[0] == '$' && re[1] == '\0')
  9d:	3c 24                	cmp    $0x24,%al
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
    return 1;
  if(re[1] == '*')
    return matchstar(re[0], re+2, text);
  9f:	89 f2                	mov    %esi,%edx
  if(re[0] == '$' && re[1] == '\0')
  a1:	75 d5                	jne    78 <matchhere+0x18>
  a3:	84 db                	test   %bl,%bl
  a5:	75 d1                	jne    78 <matchhere+0x18>
    return *text == '\0';
  a7:	31 c0                	xor    %eax,%eax
  a9:	80 39 00             	cmpb   $0x0,(%ecx)
  ac:	0f 94 c0             	sete   %al
  af:	eb 09                	jmp    ba <matchhere+0x5a>
  b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
  b8:	31 c0                	xor    %eax,%eax
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
    return matchhere(re+1, text+1);
  return 0;
}
  ba:	83 c4 10             	add    $0x10,%esp
  bd:	5b                   	pop    %ebx
  be:	5e                   	pop    %esi
  bf:	5d                   	pop    %ebp
  c0:	c3                   	ret    
  c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  c8:	83 c4 10             	add    $0x10,%esp
}

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
  cb:	b8 01 00 00 00       	mov    $0x1,%eax
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
    return matchhere(re+1, text+1);
  return 0;
}
  d0:	5b                   	pop    %ebx
  d1:	5e                   	pop    %esi
  d2:	5d                   	pop    %ebp
  d3:	c3                   	ret    
  d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
    return 1;
  if(re[1] == '*')
    return matchstar(re[0], re+2, text);
  d8:	83 c2 02             	add    $0x2,%edx
  db:	0f be c0             	movsbl %al,%eax
  de:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  e6:	89 04 24             	mov    %eax,(%esp)
  e9:	e8 12 ff ff ff       	call   0 <matchstar>
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
    return matchhere(re+1, text+1);
  return 0;
}
  ee:	83 c4 10             	add    $0x10,%esp
  f1:	5b                   	pop    %ebx
  f2:	5e                   	pop    %esi
  f3:	5d                   	pop    %ebp
  f4:	c3                   	ret    
  f5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000100 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	56                   	push   %esi
 104:	53                   	push   %ebx
 105:	83 ec 10             	sub    $0x10,%esp
 108:	8b 75 08             	mov    0x8(%ebp),%esi
 10b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(re[0] == '^')
 10e:	80 3e 5e             	cmpb   $0x5e,(%esi)
 111:	75 08                	jne    11b <match+0x1b>
 113:	eb 2f                	jmp    144 <match+0x44>
 115:	8d 76 00             	lea    0x0(%esi),%esi
    return matchhere(re+1, text);
  do{  // must look at empty string
    if(matchhere(re, text))
      return 1;
  }while(*text++ != '\0');
 118:	83 c3 01             	add    $0x1,%ebx
match(char *re, char *text)
{
  if(re[0] == '^')
    return matchhere(re+1, text);
  do{  // must look at empty string
    if(matchhere(re, text))
 11b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 11f:	89 34 24             	mov    %esi,(%esp)
 122:	e8 39 ff ff ff       	call   60 <matchhere>
 127:	85 c0                	test   %eax,%eax
 129:	75 0d                	jne    138 <match+0x38>
      return 1;
  }while(*text++ != '\0');
 12b:	80 3b 00             	cmpb   $0x0,(%ebx)
 12e:	75 e8                	jne    118 <match+0x18>
  return 0;
}
 130:	83 c4 10             	add    $0x10,%esp
 133:	5b                   	pop    %ebx
 134:	5e                   	pop    %esi
 135:	5d                   	pop    %ebp
 136:	c3                   	ret    
 137:	90                   	nop
 138:	83 c4 10             	add    $0x10,%esp
  if(re[0] == '^')
    return matchhere(re+1, text);
  do{  // must look at empty string
    if(matchhere(re, text))
      return 1;
  }while(*text++ != '\0');
 13b:	b8 01 00 00 00       	mov    $0x1,%eax
  return 0;
}
 140:	5b                   	pop    %ebx
 141:	5e                   	pop    %esi
 142:	5d                   	pop    %ebp
 143:	c3                   	ret    

int
match(char *re, char *text)
{
  if(re[0] == '^')
    return matchhere(re+1, text);
 144:	83 c6 01             	add    $0x1,%esi
 147:	89 75 08             	mov    %esi,0x8(%ebp)
  do{  // must look at empty string
    if(matchhere(re, text))
      return 1;
  }while(*text++ != '\0');
  return 0;
}
 14a:	83 c4 10             	add    $0x10,%esp
 14d:	5b                   	pop    %ebx
 14e:	5e                   	pop    %esi
 14f:	5d                   	pop    %ebp

int
match(char *re, char *text)
{
  if(re[0] == '^')
    return matchhere(re+1, text);
 150:	e9 0b ff ff ff       	jmp    60 <matchhere>
 155:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 159:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000160 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	57                   	push   %edi
 164:	56                   	push   %esi
 165:	53                   	push   %ebx
 166:	83 ec 2c             	sub    $0x2c,%esp
 169:	8b 7d 08             	mov    0x8(%ebp),%edi
 16c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 173:	90                   	nop
 174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
 178:	b8 00 04 00 00       	mov    $0x400,%eax
 17d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
 180:	89 44 24 08          	mov    %eax,0x8(%esp)
 184:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 187:	05 a0 0a 00 00       	add    $0xaa0,%eax
 18c:	89 44 24 04          	mov    %eax,0x4(%esp)
 190:	8b 45 0c             	mov    0xc(%ebp),%eax
 193:	89 04 24             	mov    %eax,(%esp)
 196:	e8 d5 03 00 00       	call   570 <read>
 19b:	85 c0                	test   %eax,%eax
 19d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 1a0:	0f 8e ae 00 00 00    	jle    254 <grep+0xf4>
 1a6:	be a0 0a 00 00       	mov    $0xaa0,%esi
 1ab:	90                   	nop
 1ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    m += n;
    p = buf;
    while((q = strchr(p, '\n')) != 0){
 1b0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
 1b7:	00 
 1b8:	89 34 24             	mov    %esi,(%esp)
 1bb:	e8 30 02 00 00       	call   3f0 <strchr>
 1c0:	85 c0                	test   %eax,%eax
 1c2:	89 c3                	mov    %eax,%ebx
 1c4:	74 42                	je     208 <grep+0xa8>
      *q = 0;
 1c6:	c6 03 00             	movb   $0x0,(%ebx)
      if(match(pattern, p)){
 1c9:	89 74 24 04          	mov    %esi,0x4(%esp)
 1cd:	89 3c 24             	mov    %edi,(%esp)
 1d0:	e8 2b ff ff ff       	call   100 <match>
 1d5:	85 c0                	test   %eax,%eax
 1d7:	75 07                	jne    1e0 <grep+0x80>
 1d9:	83 c3 01             	add    $0x1,%ebx
        *q = '\n';
        write(1, p, q+1 - p);
 1dc:	89 de                	mov    %ebx,%esi
 1de:	eb d0                	jmp    1b0 <grep+0x50>
    m += n;
    p = buf;
    while((q = strchr(p, '\n')) != 0){
      *q = 0;
      if(match(pattern, p)){
        *q = '\n';
 1e0:	c6 03 0a             	movb   $0xa,(%ebx)
        write(1, p, q+1 - p);
 1e3:	83 c3 01             	add    $0x1,%ebx
 1e6:	89 d8                	mov    %ebx,%eax
 1e8:	29 f0                	sub    %esi,%eax
 1ea:	89 74 24 04          	mov    %esi,0x4(%esp)
 1ee:	89 de                	mov    %ebx,%esi
 1f0:	89 44 24 08          	mov    %eax,0x8(%esp)
 1f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1fb:	e8 78 03 00 00       	call   578 <write>
 200:	eb ae                	jmp    1b0 <grep+0x50>
 202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      }
      p = q+1;
    }
    if(p == buf)
 208:	81 fe a0 0a 00 00    	cmp    $0xaa0,%esi
 20e:	74 38                	je     248 <grep+0xe8>
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
    m += n;
 210:	8b 45 e0             	mov    -0x20(%ebp),%eax
 213:	01 45 e4             	add    %eax,-0x1c(%ebp)
      }
      p = q+1;
    }
    if(p == buf)
      m = 0;
    if(m > 0){
 216:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 219:	85 c0                	test   %eax,%eax
 21b:	0f 8e 57 ff ff ff    	jle    178 <grep+0x18>
      m -= p - buf;
 221:	81 45 e4 a0 0a 00 00 	addl   $0xaa0,-0x1c(%ebp)
 228:	29 75 e4             	sub    %esi,-0x1c(%ebp)
      memmove(buf, p, m);
 22b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 22e:	89 74 24 04          	mov    %esi,0x4(%esp)
 232:	c7 04 24 a0 0a 00 00 	movl   $0xaa0,(%esp)
 239:	89 44 24 08          	mov    %eax,0x8(%esp)
 23d:	e8 2e 02 00 00       	call   470 <memmove>
 242:	e9 31 ff ff ff       	jmp    178 <grep+0x18>
 247:	90                   	nop
 248:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 24f:	e9 24 ff ff ff       	jmp    178 <grep+0x18>
    }
  }
}
 254:	83 c4 2c             	add    $0x2c,%esp
 257:	5b                   	pop    %ebx
 258:	5e                   	pop    %esi
 259:	5f                   	pop    %edi
 25a:	5d                   	pop    %ebp
 25b:	c3                   	ret    
 25c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000260 <main>:

int
main(int argc, char *argv[])
{
 260:	55                   	push   %ebp
 261:	89 e5                	mov    %esp,%ebp
 263:	83 e4 f0             	and    $0xfffffff0,%esp
 266:	57                   	push   %edi
 267:	56                   	push   %esi
 268:	53                   	push   %ebx
 269:	83 ec 24             	sub    $0x24,%esp
 26c:	8b 7d 08             	mov    0x8(%ebp),%edi
 26f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 272:	83 ff 01             	cmp    $0x1,%edi
 275:	0f 8e 95 00 00 00    	jle    310 <main+0xb0>
    printf(2, "usage: grep pattern [file ...]\n");
    exit();
  }
  pattern = argv[1];
 27b:	8b 43 04             	mov    0x4(%ebx),%eax
  
  if(argc <= 2){
 27e:	83 ff 02             	cmp    $0x2,%edi
  
  if(argc <= 1){
    printf(2, "usage: grep pattern [file ...]\n");
    exit();
  }
  pattern = argv[1];
 281:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  
  if(argc <= 2){
 285:	74 71                	je     2f8 <main+0x98>
    grep(pattern, 0);
    exit();
 287:	83 c3 08             	add    $0x8,%ebx
 28a:	be 02 00 00 00       	mov    $0x2,%esi
 28f:	90                   	nop
  }

  for(i = 2; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 290:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 297:	00 
 298:	8b 03                	mov    (%ebx),%eax
 29a:	89 04 24             	mov    %eax,(%esp)
 29d:	e8 f6 02 00 00       	call   598 <open>
 2a2:	85 c0                	test   %eax,%eax
 2a4:	78 32                	js     2d8 <main+0x78>
      printf(1, "grep: cannot open %s\n", argv[i]);
      exit();
    }
    grep(pattern, fd);
 2a6:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 2aa:	83 c6 01             	add    $0x1,%esi
 2ad:	83 c3 04             	add    $0x4,%ebx
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "grep: cannot open %s\n", argv[i]);
      exit();
    }
    grep(pattern, fd);
 2b0:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b4:	89 44 24 18          	mov    %eax,0x18(%esp)
 2b8:	89 14 24             	mov    %edx,(%esp)
 2bb:	e8 a0 fe ff ff       	call   160 <grep>
    close(fd);
 2c0:	8b 44 24 18          	mov    0x18(%esp),%eax
 2c4:	89 04 24             	mov    %eax,(%esp)
 2c7:	e8 b4 02 00 00       	call   580 <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 2cc:	39 f7                	cmp    %esi,%edi
 2ce:	7f c0                	jg     290 <main+0x30>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 2d0:	e8 83 02 00 00       	call   558 <exit>
 2d5:	8d 76 00             	lea    0x0(%esi),%esi
    exit();
  }

  for(i = 2; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "grep: cannot open %s\n", argv[i]);
 2d8:	8b 03                	mov    (%ebx),%eax
 2da:	c7 44 24 04 40 0a 00 	movl   $0xa40,0x4(%esp)
 2e1:	00 
 2e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2e9:	89 44 24 08          	mov    %eax,0x8(%esp)
 2ed:	e8 ae 03 00 00       	call   6a0 <printf>
      exit();
 2f2:	e8 61 02 00 00       	call   558 <exit>
 2f7:	90                   	nop
    exit();
  }
  pattern = argv[1];
  
  if(argc <= 2){
    grep(pattern, 0);
 2f8:	89 04 24             	mov    %eax,(%esp)
 2fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 302:	00 
 303:	e8 58 fe ff ff       	call   160 <grep>
    exit();
 308:	e8 4b 02 00 00       	call   558 <exit>
 30d:	8d 76 00             	lea    0x0(%esi),%esi
{
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
    printf(2, "usage: grep pattern [file ...]\n");
 310:	c7 44 24 04 20 0a 00 	movl   $0xa20,0x4(%esp)
 317:	00 
 318:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 31f:	e8 7c 03 00 00       	call   6a0 <printf>
    exit();
 324:	e8 2f 02 00 00       	call   558 <exit>
 329:	90                   	nop
 32a:	90                   	nop
 32b:	90                   	nop
 32c:	90                   	nop
 32d:	90                   	nop
 32e:	90                   	nop
 32f:	90                   	nop

00000330 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 330:	55                   	push   %ebp
 331:	31 d2                	xor    %edx,%edx
 333:	89 e5                	mov    %esp,%ebp
 335:	8b 45 08             	mov    0x8(%ebp),%eax
 338:	53                   	push   %ebx
 339:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 33c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 340:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 344:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 347:	83 c2 01             	add    $0x1,%edx
 34a:	84 c9                	test   %cl,%cl
 34c:	75 f2                	jne    340 <strcpy+0x10>
    ;
  return os;
}
 34e:	5b                   	pop    %ebx
 34f:	5d                   	pop    %ebp
 350:	c3                   	ret    
 351:	eb 0d                	jmp    360 <strcmp>
 353:	90                   	nop
 354:	90                   	nop
 355:	90                   	nop
 356:	90                   	nop
 357:	90                   	nop
 358:	90                   	nop
 359:	90                   	nop
 35a:	90                   	nop
 35b:	90                   	nop
 35c:	90                   	nop
 35d:	90                   	nop
 35e:	90                   	nop
 35f:	90                   	nop

00000360 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 360:	55                   	push   %ebp
 361:	89 e5                	mov    %esp,%ebp
 363:	53                   	push   %ebx
 364:	8b 4d 08             	mov    0x8(%ebp),%ecx
 367:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 36a:	0f b6 01             	movzbl (%ecx),%eax
 36d:	84 c0                	test   %al,%al
 36f:	75 14                	jne    385 <strcmp+0x25>
 371:	eb 25                	jmp    398 <strcmp+0x38>
 373:	90                   	nop
 374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
 378:	83 c1 01             	add    $0x1,%ecx
 37b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 37e:	0f b6 01             	movzbl (%ecx),%eax
 381:	84 c0                	test   %al,%al
 383:	74 13                	je     398 <strcmp+0x38>
 385:	0f b6 1a             	movzbl (%edx),%ebx
 388:	38 d8                	cmp    %bl,%al
 38a:	74 ec                	je     378 <strcmp+0x18>
 38c:	0f b6 db             	movzbl %bl,%ebx
 38f:	0f b6 c0             	movzbl %al,%eax
 392:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 394:	5b                   	pop    %ebx
 395:	5d                   	pop    %ebp
 396:	c3                   	ret    
 397:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 398:	0f b6 1a             	movzbl (%edx),%ebx
 39b:	31 c0                	xor    %eax,%eax
 39d:	0f b6 db             	movzbl %bl,%ebx
 3a0:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 3a2:	5b                   	pop    %ebx
 3a3:	5d                   	pop    %ebp
 3a4:	c3                   	ret    
 3a5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 3a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000003b0 <strlen>:

uint
strlen(char *s)
{
 3b0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
 3b1:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 3b3:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
 3b5:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
 3b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 3ba:	80 39 00             	cmpb   $0x0,(%ecx)
 3bd:	74 0c                	je     3cb <strlen+0x1b>
 3bf:	90                   	nop
 3c0:	83 c2 01             	add    $0x1,%edx
 3c3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 3c7:	89 d0                	mov    %edx,%eax
 3c9:	75 f5                	jne    3c0 <strlen+0x10>
    ;
  return n;
}
 3cb:	5d                   	pop    %ebp
 3cc:	c3                   	ret    
 3cd:	8d 76 00             	lea    0x0(%esi),%esi

000003d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	8b 55 08             	mov    0x8(%ebp),%edx
 3d6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 3d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3da:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dd:	89 d7                	mov    %edx,%edi
 3df:	fc                   	cld    
 3e0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 3e2:	89 d0                	mov    %edx,%eax
 3e4:	5f                   	pop    %edi
 3e5:	5d                   	pop    %ebp
 3e6:	c3                   	ret    
 3e7:	89 f6                	mov    %esi,%esi
 3e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000003f0 <strchr>:

char*
strchr(const char *s, char c)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 3fa:	0f b6 10             	movzbl (%eax),%edx
 3fd:	84 d2                	test   %dl,%dl
 3ff:	75 11                	jne    412 <strchr+0x22>
 401:	eb 15                	jmp    418 <strchr+0x28>
 403:	90                   	nop
 404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 408:	83 c0 01             	add    $0x1,%eax
 40b:	0f b6 10             	movzbl (%eax),%edx
 40e:	84 d2                	test   %dl,%dl
 410:	74 06                	je     418 <strchr+0x28>
    if(*s == c)
 412:	38 ca                	cmp    %cl,%dl
 414:	75 f2                	jne    408 <strchr+0x18>
      return (char*)s;
  return 0;
}
 416:	5d                   	pop    %ebp
 417:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 418:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 41a:	5d                   	pop    %ebp
 41b:	90                   	nop
 41c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 420:	c3                   	ret    
 421:	eb 0d                	jmp    430 <atoi>
 423:	90                   	nop
 424:	90                   	nop
 425:	90                   	nop
 426:	90                   	nop
 427:	90                   	nop
 428:	90                   	nop
 429:	90                   	nop
 42a:	90                   	nop
 42b:	90                   	nop
 42c:	90                   	nop
 42d:	90                   	nop
 42e:	90                   	nop
 42f:	90                   	nop

00000430 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 430:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 431:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 433:	89 e5                	mov    %esp,%ebp
 435:	8b 4d 08             	mov    0x8(%ebp),%ecx
 438:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 439:	0f b6 11             	movzbl (%ecx),%edx
 43c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 43f:	80 fb 09             	cmp    $0x9,%bl
 442:	77 1c                	ja     460 <atoi+0x30>
 444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 448:	0f be d2             	movsbl %dl,%edx
 44b:	83 c1 01             	add    $0x1,%ecx
 44e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 451:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 455:	0f b6 11             	movzbl (%ecx),%edx
 458:	8d 5a d0             	lea    -0x30(%edx),%ebx
 45b:	80 fb 09             	cmp    $0x9,%bl
 45e:	76 e8                	jbe    448 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 460:	5b                   	pop    %ebx
 461:	5d                   	pop    %ebp
 462:	c3                   	ret    
 463:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 469:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000470 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 470:	55                   	push   %ebp
 471:	89 e5                	mov    %esp,%ebp
 473:	56                   	push   %esi
 474:	8b 45 08             	mov    0x8(%ebp),%eax
 477:	53                   	push   %ebx
 478:	8b 5d 10             	mov    0x10(%ebp),%ebx
 47b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 47e:	85 db                	test   %ebx,%ebx
 480:	7e 14                	jle    496 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
 482:	31 d2                	xor    %edx,%edx
 484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 488:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 48c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 48f:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 492:	39 da                	cmp    %ebx,%edx
 494:	75 f2                	jne    488 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 496:	5b                   	pop    %ebx
 497:	5e                   	pop    %esi
 498:	5d                   	pop    %ebp
 499:	c3                   	ret    
 49a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

000004a0 <stat>:
  return buf;
}

int
stat(char *n, struct stat *st)
{
 4a0:	55                   	push   %ebp
 4a1:	89 e5                	mov    %esp,%ebp
 4a3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4a6:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(char *n, struct stat *st)
{
 4a9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 4ac:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 4af:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4bb:	00 
 4bc:	89 04 24             	mov    %eax,(%esp)
 4bf:	e8 d4 00 00 00       	call   598 <open>
  if(fd < 0)
 4c4:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4c6:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 4c8:	78 19                	js     4e3 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 4ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 4cd:	89 1c 24             	mov    %ebx,(%esp)
 4d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d4:	e8 d7 00 00 00       	call   5b0 <fstat>
  close(fd);
 4d9:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 4dc:	89 c6                	mov    %eax,%esi
  close(fd);
 4de:	e8 9d 00 00 00       	call   580 <close>
  return r;
}
 4e3:	89 f0                	mov    %esi,%eax
 4e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 4e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
 4eb:	89 ec                	mov    %ebp,%esp
 4ed:	5d                   	pop    %ebp
 4ee:	c3                   	ret    
 4ef:	90                   	nop

000004f0 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 4f0:	55                   	push   %ebp
 4f1:	89 e5                	mov    %esp,%ebp
 4f3:	57                   	push   %edi
 4f4:	56                   	push   %esi
 4f5:	31 f6                	xor    %esi,%esi
 4f7:	53                   	push   %ebx
 4f8:	83 ec 2c             	sub    $0x2c,%esp
 4fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4fe:	eb 06                	jmp    506 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 500:	3c 0a                	cmp    $0xa,%al
 502:	74 39                	je     53d <gets+0x4d>
 504:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 506:	8d 5e 01             	lea    0x1(%esi),%ebx
 509:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 50c:	7d 31                	jge    53f <gets+0x4f>
    cc = read(0, &c, 1);
 50e:	8d 45 e7             	lea    -0x19(%ebp),%eax
 511:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 518:	00 
 519:	89 44 24 04          	mov    %eax,0x4(%esp)
 51d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 524:	e8 47 00 00 00       	call   570 <read>
    if(cc < 1)
 529:	85 c0                	test   %eax,%eax
 52b:	7e 12                	jle    53f <gets+0x4f>
      break;
    buf[i++] = c;
 52d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 531:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 535:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 539:	3c 0d                	cmp    $0xd,%al
 53b:	75 c3                	jne    500 <gets+0x10>
 53d:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 53f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 543:	89 f8                	mov    %edi,%eax
 545:	83 c4 2c             	add    $0x2c,%esp
 548:	5b                   	pop    %ebx
 549:	5e                   	pop    %esi
 54a:	5f                   	pop    %edi
 54b:	5d                   	pop    %ebp
 54c:	c3                   	ret    
 54d:	90                   	nop
 54e:	90                   	nop
 54f:	90                   	nop

00000550 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 550:	b8 01 00 00 00       	mov    $0x1,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <exit>:
SYSCALL(exit)
 558:	b8 02 00 00 00       	mov    $0x2,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <wait>:
SYSCALL(wait)
 560:	b8 03 00 00 00       	mov    $0x3,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <pipe>:
SYSCALL(pipe)
 568:	b8 04 00 00 00       	mov    $0x4,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <read>:
SYSCALL(read)
 570:	b8 06 00 00 00       	mov    $0x6,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <write>:
SYSCALL(write)
 578:	b8 05 00 00 00       	mov    $0x5,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <close>:
SYSCALL(close)
 580:	b8 07 00 00 00       	mov    $0x7,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <kill>:
SYSCALL(kill)
 588:	b8 08 00 00 00       	mov    $0x8,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <exec>:
SYSCALL(exec)
 590:	b8 09 00 00 00       	mov    $0x9,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <open>:
SYSCALL(open)
 598:	b8 0a 00 00 00       	mov    $0xa,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <mknod>:
SYSCALL(mknod)
 5a0:	b8 0b 00 00 00       	mov    $0xb,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <unlink>:
SYSCALL(unlink)
 5a8:	b8 0c 00 00 00       	mov    $0xc,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <fstat>:
SYSCALL(fstat)
 5b0:	b8 0d 00 00 00       	mov    $0xd,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <link>:
SYSCALL(link)
 5b8:	b8 0e 00 00 00       	mov    $0xe,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <mkdir>:
SYSCALL(mkdir)
 5c0:	b8 0f 00 00 00       	mov    $0xf,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <chdir>:
SYSCALL(chdir)
 5c8:	b8 10 00 00 00       	mov    $0x10,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <dup>:
SYSCALL(dup)
 5d0:	b8 11 00 00 00       	mov    $0x11,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <getpid>:
SYSCALL(getpid)
 5d8:	b8 12 00 00 00       	mov    $0x12,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <sbrk>:
SYSCALL(sbrk)
 5e0:	b8 13 00 00 00       	mov    $0x13,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <sleep>:
SYSCALL(sleep)
 5e8:	b8 14 00 00 00       	mov    $0x14,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <uptime>:
SYSCALL(uptime)
 5f0:	b8 15 00 00 00       	mov    $0x15,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <getcount>:
SYSCALL(getcount)
 5f8:	b8 16 00 00 00       	mov    $0x16,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 600:	55                   	push   %ebp
 601:	89 e5                	mov    %esp,%ebp
 603:	57                   	push   %edi
 604:	89 cf                	mov    %ecx,%edi
 606:	56                   	push   %esi
 607:	89 c6                	mov    %eax,%esi
 609:	53                   	push   %ebx
 60a:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 60d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 610:	85 c9                	test   %ecx,%ecx
 612:	74 04                	je     618 <printint+0x18>
 614:	85 d2                	test   %edx,%edx
 616:	78 70                	js     688 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 618:	89 d0                	mov    %edx,%eax
 61a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 621:	31 c9                	xor    %ecx,%ecx
 623:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 626:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 628:	31 d2                	xor    %edx,%edx
 62a:	f7 f7                	div    %edi
 62c:	0f b6 92 5d 0a 00 00 	movzbl 0xa5d(%edx),%edx
 633:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 636:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 639:	85 c0                	test   %eax,%eax
 63b:	75 eb                	jne    628 <printint+0x28>
  if(neg)
 63d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 640:	85 c0                	test   %eax,%eax
 642:	74 08                	je     64c <printint+0x4c>
    buf[i++] = '-';
 644:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 649:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 64c:	8d 79 ff             	lea    -0x1(%ecx),%edi
 64f:	01 fb                	add    %edi,%ebx
 651:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 658:	0f b6 03             	movzbl (%ebx),%eax
 65b:	83 ef 01             	sub    $0x1,%edi
 65e:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 661:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 668:	00 
 669:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 66c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 66f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 672:	89 44 24 04          	mov    %eax,0x4(%esp)
 676:	e8 fd fe ff ff       	call   578 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 67b:	83 ff ff             	cmp    $0xffffffff,%edi
 67e:	75 d8                	jne    658 <printint+0x58>
    putc(fd, buf[i]);
}
 680:	83 c4 4c             	add    $0x4c,%esp
 683:	5b                   	pop    %ebx
 684:	5e                   	pop    %esi
 685:	5f                   	pop    %edi
 686:	5d                   	pop    %ebp
 687:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 688:	89 d0                	mov    %edx,%eax
 68a:	f7 d8                	neg    %eax
 68c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 693:	eb 8c                	jmp    621 <printint+0x21>
 695:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 699:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000006a0 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6a0:	55                   	push   %ebp
 6a1:	89 e5                	mov    %esp,%ebp
 6a3:	57                   	push   %edi
 6a4:	56                   	push   %esi
 6a5:	53                   	push   %ebx
 6a6:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ac:	0f b6 10             	movzbl (%eax),%edx
 6af:	84 d2                	test   %dl,%dl
 6b1:	0f 84 c9 00 00 00    	je     780 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 6b7:	8d 4d 10             	lea    0x10(%ebp),%ecx
 6ba:	31 ff                	xor    %edi,%edi
 6bc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 6bf:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6c1:	8d 75 e7             	lea    -0x19(%ebp),%esi
 6c4:	eb 1e                	jmp    6e4 <printf+0x44>
 6c6:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 6c8:	83 fa 25             	cmp    $0x25,%edx
 6cb:	0f 85 b7 00 00 00    	jne    788 <printf+0xe8>
 6d1:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6d5:	83 c3 01             	add    $0x1,%ebx
 6d8:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 6dc:	84 d2                	test   %dl,%dl
 6de:	0f 84 9c 00 00 00    	je     780 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 6e4:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 6e6:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 6e9:	74 dd                	je     6c8 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6eb:	83 ff 25             	cmp    $0x25,%edi
 6ee:	75 e5                	jne    6d5 <printf+0x35>
      if(c == 'd'){
 6f0:	83 fa 64             	cmp    $0x64,%edx
 6f3:	0f 84 57 01 00 00    	je     850 <printf+0x1b0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 6f9:	83 fa 70             	cmp    $0x70,%edx
 6fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 700:	0f 84 aa 00 00 00    	je     7b0 <printf+0x110>
 706:	83 fa 78             	cmp    $0x78,%edx
 709:	0f 84 a1 00 00 00    	je     7b0 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 70f:	83 fa 73             	cmp    $0x73,%edx
 712:	0f 84 c0 00 00 00    	je     7d8 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 718:	83 fa 63             	cmp    $0x63,%edx
 71b:	90                   	nop
 71c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 720:	0f 84 52 01 00 00    	je     878 <printf+0x1d8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 726:	83 fa 25             	cmp    $0x25,%edx
 729:	0f 84 f9 00 00 00    	je     828 <printf+0x188>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 72f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 732:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 735:	31 ff                	xor    %edi,%edi
 737:	89 55 cc             	mov    %edx,-0x34(%ebp)
 73a:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 73e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 745:	00 
 746:	89 0c 24             	mov    %ecx,(%esp)
 749:	89 74 24 04          	mov    %esi,0x4(%esp)
 74d:	e8 26 fe ff ff       	call   578 <write>
 752:	8b 55 cc             	mov    -0x34(%ebp),%edx
 755:	8b 45 08             	mov    0x8(%ebp),%eax
 758:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 75f:	00 
 760:	89 74 24 04          	mov    %esi,0x4(%esp)
 764:	88 55 e7             	mov    %dl,-0x19(%ebp)
 767:	89 04 24             	mov    %eax,(%esp)
 76a:	e8 09 fe ff ff       	call   578 <write>
 76f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 772:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 776:	84 d2                	test   %dl,%dl
 778:	0f 85 66 ff ff ff    	jne    6e4 <printf+0x44>
 77e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 780:	83 c4 3c             	add    $0x3c,%esp
 783:	5b                   	pop    %ebx
 784:	5e                   	pop    %esi
 785:	5f                   	pop    %edi
 786:	5d                   	pop    %ebp
 787:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 788:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 78b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 78e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 795:	00 
 796:	89 74 24 04          	mov    %esi,0x4(%esp)
 79a:	89 04 24             	mov    %eax,(%esp)
 79d:	e8 d6 fd ff ff       	call   578 <write>
 7a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 7a5:	e9 2b ff ff ff       	jmp    6d5 <printf+0x35>
 7aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 7b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 7b3:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 7b8:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 7ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 7c1:	8b 10                	mov    (%eax),%edx
 7c3:	8b 45 08             	mov    0x8(%ebp),%eax
 7c6:	e8 35 fe ff ff       	call   600 <printint>
 7cb:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 7ce:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 7d2:	e9 fe fe ff ff       	jmp    6d5 <printf+0x35>
 7d7:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 7d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 7db:	8b 3a                	mov    (%edx),%edi
        ap++;
 7dd:	83 c2 04             	add    $0x4,%edx
 7e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 7e3:	85 ff                	test   %edi,%edi
 7e5:	0f 84 ba 00 00 00    	je     8a5 <printf+0x205>
          s = "(null)";
        while(*s != 0){
 7eb:	0f b6 17             	movzbl (%edi),%edx
 7ee:	84 d2                	test   %dl,%dl
 7f0:	74 2d                	je     81f <printf+0x17f>
 7f2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 7f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
          putc(fd, *s);
          s++;
 7f8:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7fb:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 7fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 805:	00 
 806:	89 74 24 04          	mov    %esi,0x4(%esp)
 80a:	89 1c 24             	mov    %ebx,(%esp)
 80d:	e8 66 fd ff ff       	call   578 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 812:	0f b6 17             	movzbl (%edi),%edx
 815:	84 d2                	test   %dl,%dl
 817:	75 df                	jne    7f8 <printf+0x158>
 819:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 81c:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 81f:	31 ff                	xor    %edi,%edi
 821:	e9 af fe ff ff       	jmp    6d5 <printf+0x35>
 826:	66 90                	xchg   %ax,%ax
 828:	8b 55 08             	mov    0x8(%ebp),%edx
 82b:	31 ff                	xor    %edi,%edi
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 82d:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 831:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 838:	00 
 839:	89 74 24 04          	mov    %esi,0x4(%esp)
 83d:	89 14 24             	mov    %edx,(%esp)
 840:	e8 33 fd ff ff       	call   578 <write>
 845:	8b 45 0c             	mov    0xc(%ebp),%eax
 848:	e9 88 fe ff ff       	jmp    6d5 <printf+0x35>
 84d:	8d 76 00             	lea    0x0(%esi),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 850:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 853:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 858:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 85b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 862:	8b 10                	mov    (%eax),%edx
 864:	8b 45 08             	mov    0x8(%ebp),%eax
 867:	e8 94 fd ff ff       	call   600 <printint>
 86c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 86f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 873:	e9 5d fe ff ff       	jmp    6d5 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 878:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
        putc(fd, *ap);
        ap++;
 87b:	31 ff                	xor    %edi,%edi
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 87d:	8b 01                	mov    (%ecx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 87f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 886:	00 
 887:	89 74 24 04          	mov    %esi,0x4(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 88b:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 88e:	8b 45 08             	mov    0x8(%ebp),%eax
 891:	89 04 24             	mov    %eax,(%esp)
 894:	e8 df fc ff ff       	call   578 <write>
 899:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 89c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 8a0:	e9 30 fe ff ff       	jmp    6d5 <printf+0x35>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
 8a5:	bf 56 0a 00 00       	mov    $0xa56,%edi
 8aa:	e9 3c ff ff ff       	jmp    7eb <printf+0x14b>
 8af:	90                   	nop

000008b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b1:	a1 88 0a 00 00       	mov    0xa88,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b6:	89 e5                	mov    %esp,%ebp
 8b8:	57                   	push   %edi
 8b9:	56                   	push   %esi
 8ba:	53                   	push   %ebx
 8bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8be:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c1:	39 c8                	cmp    %ecx,%eax
 8c3:	73 1d                	jae    8e2 <free+0x32>
 8c5:	8d 76 00             	lea    0x0(%esi),%esi
 8c8:	8b 10                	mov    (%eax),%edx
 8ca:	39 d1                	cmp    %edx,%ecx
 8cc:	72 1a                	jb     8e8 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ce:	39 d0                	cmp    %edx,%eax
 8d0:	72 08                	jb     8da <free+0x2a>
 8d2:	39 c8                	cmp    %ecx,%eax
 8d4:	72 12                	jb     8e8 <free+0x38>
 8d6:	39 d1                	cmp    %edx,%ecx
 8d8:	72 0e                	jb     8e8 <free+0x38>
 8da:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8dc:	39 c8                	cmp    %ecx,%eax
 8de:	66 90                	xchg   %ax,%ax
 8e0:	72 e6                	jb     8c8 <free+0x18>
 8e2:	8b 10                	mov    (%eax),%edx
 8e4:	eb e8                	jmp    8ce <free+0x1e>
 8e6:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8e8:	8b 71 04             	mov    0x4(%ecx),%esi
 8eb:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 8ee:	39 d7                	cmp    %edx,%edi
 8f0:	74 19                	je     90b <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 8f2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 8f5:	8b 50 04             	mov    0x4(%eax),%edx
 8f8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 8fb:	39 ce                	cmp    %ecx,%esi
 8fd:	74 23                	je     922 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 8ff:	89 08                	mov    %ecx,(%eax)
  freep = p;
 901:	a3 88 0a 00 00       	mov    %eax,0xa88
}
 906:	5b                   	pop    %ebx
 907:	5e                   	pop    %esi
 908:	5f                   	pop    %edi
 909:	5d                   	pop    %ebp
 90a:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 90b:	03 72 04             	add    0x4(%edx),%esi
 90e:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 911:	8b 10                	mov    (%eax),%edx
 913:	8b 12                	mov    (%edx),%edx
 915:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 918:	8b 50 04             	mov    0x4(%eax),%edx
 91b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 91e:	39 ce                	cmp    %ecx,%esi
 920:	75 dd                	jne    8ff <free+0x4f>
    p->s.size += bp->s.size;
 922:	03 51 04             	add    0x4(%ecx),%edx
 925:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 928:	8b 53 f8             	mov    -0x8(%ebx),%edx
 92b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 92d:	a3 88 0a 00 00       	mov    %eax,0xa88
}
 932:	5b                   	pop    %ebx
 933:	5e                   	pop    %esi
 934:	5f                   	pop    %edi
 935:	5d                   	pop    %ebp
 936:	c3                   	ret    
 937:	89 f6                	mov    %esi,%esi
 939:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000940 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 940:	55                   	push   %ebp
 941:	89 e5                	mov    %esp,%ebp
 943:	57                   	push   %edi
 944:	56                   	push   %esi
 945:	53                   	push   %ebx
 946:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 949:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 94c:	8b 0d 88 0a 00 00    	mov    0xa88,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 952:	83 c3 07             	add    $0x7,%ebx
 955:	c1 eb 03             	shr    $0x3,%ebx
 958:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 95b:	85 c9                	test   %ecx,%ecx
 95d:	0f 84 93 00 00 00    	je     9f6 <malloc+0xb6>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 963:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 965:	8b 50 04             	mov    0x4(%eax),%edx
 968:	39 d3                	cmp    %edx,%ebx
 96a:	76 1f                	jbe    98b <malloc+0x4b>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 96c:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
 973:	90                   	nop
 974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
    if(p == freep)
 978:	3b 05 88 0a 00 00    	cmp    0xa88,%eax
 97e:	74 30                	je     9b0 <malloc+0x70>
 980:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 982:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 984:	8b 50 04             	mov    0x4(%eax),%edx
 987:	39 d3                	cmp    %edx,%ebx
 989:	77 ed                	ja     978 <malloc+0x38>
      if(p->s.size == nunits)
 98b:	39 d3                	cmp    %edx,%ebx
 98d:	74 61                	je     9f0 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 98f:	29 da                	sub    %ebx,%edx
 991:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 994:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 997:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 99a:	89 0d 88 0a 00 00    	mov    %ecx,0xa88
      return (void*)(p + 1);
 9a0:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9a3:	83 c4 1c             	add    $0x1c,%esp
 9a6:	5b                   	pop    %ebx
 9a7:	5e                   	pop    %esi
 9a8:	5f                   	pop    %edi
 9a9:	5d                   	pop    %ebp
 9aa:	c3                   	ret    
 9ab:	90                   	nop
 9ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 9b0:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 9b6:	b8 00 80 00 00       	mov    $0x8000,%eax
 9bb:	bf 00 10 00 00       	mov    $0x1000,%edi
 9c0:	76 04                	jbe    9c6 <malloc+0x86>
 9c2:	89 f0                	mov    %esi,%eax
 9c4:	89 df                	mov    %ebx,%edi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 9c6:	89 04 24             	mov    %eax,(%esp)
 9c9:	e8 12 fc ff ff       	call   5e0 <sbrk>
  if(p == (char*)-1)
 9ce:	83 f8 ff             	cmp    $0xffffffff,%eax
 9d1:	74 18                	je     9eb <malloc+0xab>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 9d3:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 9d6:	83 c0 08             	add    $0x8,%eax
 9d9:	89 04 24             	mov    %eax,(%esp)
 9dc:	e8 cf fe ff ff       	call   8b0 <free>
  return freep;
 9e1:	8b 0d 88 0a 00 00    	mov    0xa88,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 9e7:	85 c9                	test   %ecx,%ecx
 9e9:	75 97                	jne    982 <malloc+0x42>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 9eb:	31 c0                	xor    %eax,%eax
 9ed:	eb b4                	jmp    9a3 <malloc+0x63>
 9ef:	90                   	nop
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 9f0:	8b 10                	mov    (%eax),%edx
 9f2:	89 11                	mov    %edx,(%ecx)
 9f4:	eb a4                	jmp    99a <malloc+0x5a>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 9f6:	c7 05 88 0a 00 00 80 	movl   $0xa80,0xa88
 9fd:	0a 00 00 
    base.s.size = 0;
 a00:	b9 80 0a 00 00       	mov    $0xa80,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 a05:	c7 05 80 0a 00 00 80 	movl   $0xa80,0xa80
 a0c:	0a 00 00 
    base.s.size = 0;
 a0f:	c7 05 84 0a 00 00 00 	movl   $0x0,0xa84
 a16:	00 00 00 
 a19:	e9 45 ff ff ff       	jmp    963 <malloc+0x23>
