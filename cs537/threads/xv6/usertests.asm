
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <validateint>:
  printf(stdout, "sbrk test OK\n");
}

void
validateint(int *p)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
       3:	5d                   	pop    %ebp
       4:	c3                   	ret    
       5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
       9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000010 <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
      10:	55                   	push   %ebp
      11:	89 e5                	mov    %esp,%ebp
      13:	83 ec 18             	sub    $0x18,%esp
  int i;

  printf(stdout, "bss test\n");
      16:	a1 60 4e 00 00       	mov    0x4e60,%eax
      1b:	c7 44 24 04 0c 39 00 	movl   $0x390c,0x4(%esp)
      22:	00 
      23:	89 04 24             	mov    %eax,(%esp)
      26:	e8 15 35 00 00       	call   3540 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    if(uninit[i] != '\0'){
      2b:	80 3d a0 4e 00 00 00 	cmpb   $0x0,0x4ea0
      32:	75 36                	jne    6a <bsstest+0x5a>
      34:	b8 01 00 00 00       	mov    $0x1,%eax
      39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      40:	80 b8 a0 4e 00 00 00 	cmpb   $0x0,0x4ea0(%eax)
      47:	75 21                	jne    6a <bsstest+0x5a>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
      49:	83 c0 01             	add    $0x1,%eax
      4c:	3d 10 27 00 00       	cmp    $0x2710,%eax
      51:	75 ed                	jne    40 <bsstest+0x30>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit();
    }
  }
  printf(stdout, "bss test ok\n");
      53:	a1 60 4e 00 00       	mov    0x4e60,%eax
      58:	c7 44 24 04 27 39 00 	movl   $0x3927,0x4(%esp)
      5f:	00 
      60:	89 04 24             	mov    %eax,(%esp)
      63:	e8 d8 34 00 00       	call   3540 <printf>
}
      68:	c9                   	leave  
      69:	c3                   	ret    
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      6a:	a1 60 4e 00 00       	mov    0x4e60,%eax
      6f:	c7 44 24 04 16 39 00 	movl   $0x3916,0x4(%esp)
      76:	00 
      77:	89 04 24             	mov    %eax,(%esp)
      7a:	e8 c1 34 00 00       	call   3540 <printf>
      exit();
      7f:	e8 74 33 00 00       	call   33f8 <exit>
      84:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      8a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00000090 <opentest>:

// simple file system tests

void
opentest(void)
{
      90:	55                   	push   %ebp
      91:	89 e5                	mov    %esp,%ebp
      93:	83 ec 18             	sub    $0x18,%esp
  int fd;

  printf(stdout, "open test\n");
      96:	a1 60 4e 00 00       	mov    0x4e60,%eax
      9b:	c7 44 24 04 34 39 00 	movl   $0x3934,0x4(%esp)
      a2:	00 
      a3:	89 04 24             	mov    %eax,(%esp)
      a6:	e8 95 34 00 00       	call   3540 <printf>
  fd = open("echo", 0);
      ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      b2:	00 
      b3:	c7 04 24 3f 39 00 00 	movl   $0x393f,(%esp)
      ba:	e8 79 33 00 00       	call   3438 <open>
  if(fd < 0){
      bf:	85 c0                	test   %eax,%eax
      c1:	78 37                	js     fa <opentest+0x6a>
    printf(stdout, "open echo failed!\n");
    exit();
  }
  close(fd);
      c3:	89 04 24             	mov    %eax,(%esp)
      c6:	e8 55 33 00 00       	call   3420 <close>
  fd = open("doesnotexist", 0);
      cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      d2:	00 
      d3:	c7 04 24 57 39 00 00 	movl   $0x3957,(%esp)
      da:	e8 59 33 00 00       	call   3438 <open>
  if(fd >= 0){
      df:	85 c0                	test   %eax,%eax
      e1:	79 31                	jns    114 <opentest+0x84>
    printf(stdout, "open doesnotexist succeeded!\n");
    exit();
  }
  printf(stdout, "open test ok\n");
      e3:	a1 60 4e 00 00       	mov    0x4e60,%eax
      e8:	c7 44 24 04 82 39 00 	movl   $0x3982,0x4(%esp)
      ef:	00 
      f0:	89 04 24             	mov    %eax,(%esp)
      f3:	e8 48 34 00 00       	call   3540 <printf>
}
      f8:	c9                   	leave  
      f9:	c3                   	ret    
  int fd;

  printf(stdout, "open test\n");
  fd = open("echo", 0);
  if(fd < 0){
    printf(stdout, "open echo failed!\n");
      fa:	a1 60 4e 00 00       	mov    0x4e60,%eax
      ff:	c7 44 24 04 44 39 00 	movl   $0x3944,0x4(%esp)
     106:	00 
     107:	89 04 24             	mov    %eax,(%esp)
     10a:	e8 31 34 00 00       	call   3540 <printf>
    exit();
     10f:	e8 e4 32 00 00       	call   33f8 <exit>
  }
  close(fd);
  fd = open("doesnotexist", 0);
  if(fd >= 0){
    printf(stdout, "open doesnotexist succeeded!\n");
     114:	a1 60 4e 00 00       	mov    0x4e60,%eax
     119:	c7 44 24 04 64 39 00 	movl   $0x3964,0x4(%esp)
     120:	00 
     121:	89 04 24             	mov    %eax,(%esp)
     124:	e8 17 34 00 00       	call   3540 <printf>
    exit();
     129:	e8 ca 32 00 00       	call   33f8 <exit>
     12e:	66 90                	xchg   %ax,%ax

00000130 <exectest>:
  printf(stdout, "mkdir test\n");
}

void
exectest(void)
{
     130:	55                   	push   %ebp
     131:	89 e5                	mov    %esp,%ebp
     133:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     136:	a1 60 4e 00 00       	mov    0x4e60,%eax
     13b:	c7 44 24 04 90 39 00 	movl   $0x3990,0x4(%esp)
     142:	00 
     143:	89 04 24             	mov    %eax,(%esp)
     146:	e8 f5 33 00 00       	call   3540 <printf>
  if(exec("echo", echoargv) < 0){
     14b:	c7 44 24 04 4c 4e 00 	movl   $0x4e4c,0x4(%esp)
     152:	00 
     153:	c7 04 24 3f 39 00 00 	movl   $0x393f,(%esp)
     15a:	e8 d1 32 00 00       	call   3430 <exec>
     15f:	85 c0                	test   %eax,%eax
     161:	78 02                	js     165 <exectest+0x35>
    printf(stdout, "exec echo failed\n");
    exit();
  }
}
     163:	c9                   	leave  
     164:	c3                   	ret    
void
exectest(void)
{
  printf(stdout, "exec test\n");
  if(exec("echo", echoargv) < 0){
    printf(stdout, "exec echo failed\n");
     165:	a1 60 4e 00 00       	mov    0x4e60,%eax
     16a:	c7 44 24 04 9b 39 00 	movl   $0x399b,0x4(%esp)
     171:	00 
     172:	89 04 24             	mov    %eax,(%esp)
     175:	e8 c6 33 00 00       	call   3540 <printf>
    exit();
     17a:	e8 79 32 00 00       	call   33f8 <exit>
     17f:	90                   	nop

00000180 <bigargtest>:

// does exec do something sensible if the arguments
// are larger than a page?
void
bigargtest(void)
{
     180:	55                   	push   %ebp
     181:	89 e5                	mov    %esp,%ebp
     183:	53                   	push   %ebx
     184:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  int pid, ppid;

  ppid = getpid();
     18a:	e8 e9 32 00 00       	call   3478 <getpid>
  pid = fork();
     18f:	e8 5c 32 00 00       	call   33f0 <fork>
  if(pid == 0){
     194:	83 f8 00             	cmp    $0x0,%eax
     197:	74 18                	je     1b1 <bigargtest+0x31>
    args[32] = 0;
    printf(stdout, "bigarg test\n");
    exec("echo", args);
    printf(stdout, "bigarg test ok\n");
    exit();
  } else if(pid < 0){
     199:	7c 72                	jl     20d <bigargtest+0x8d>
     19b:	90                   	nop
     19c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    printf(stdout, "bigargtest: fork failed\n");
    exit();
  }
  wait();
     1a0:	e8 5b 32 00 00       	call   3400 <wait>
}
     1a5:	81 c4 a4 00 00 00    	add    $0xa4,%esp
     1ab:	5b                   	pop    %ebx
     1ac:	5d                   	pop    %ebp
     1ad:	8d 76 00             	lea    0x0(%esi),%esi
     1b0:	c3                   	ret    
     1b1:	8d 9d 74 ff ff ff    	lea    -0x8c(%ebp),%ebx
     1b7:	90                   	nop
  pid = fork();
  if(pid == 0){
    char *args[32+1];
    int i;
    for(i = 0; i < 32; i++)
      args[i] = "bigargs test: failed\n                                                                                                                     ";
     1b8:	c7 04 83 40 47 00 00 	movl   $0x4740,(%ebx,%eax,4)
  ppid = getpid();
  pid = fork();
  if(pid == 0){
    char *args[32+1];
    int i;
    for(i = 0; i < 32; i++)
     1bf:	83 c0 01             	add    $0x1,%eax
     1c2:	83 f8 20             	cmp    $0x20,%eax
     1c5:	75 f1                	jne    1b8 <bigargtest+0x38>
      args[i] = "bigargs test: failed\n                                                                                                                     ";
    args[32] = 0;
    printf(stdout, "bigarg test\n");
     1c7:	a1 60 4e 00 00       	mov    0x4e60,%eax
  if(pid == 0){
    char *args[32+1];
    int i;
    for(i = 0; i < 32; i++)
      args[i] = "bigargs test: failed\n                                                                                                                     ";
    args[32] = 0;
     1cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    printf(stdout, "bigarg test\n");
     1d3:	c7 44 24 04 ad 39 00 	movl   $0x39ad,0x4(%esp)
     1da:	00 
     1db:	89 04 24             	mov    %eax,(%esp)
     1de:	e8 5d 33 00 00       	call   3540 <printf>
    exec("echo", args);
     1e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     1e7:	c7 04 24 3f 39 00 00 	movl   $0x393f,(%esp)
     1ee:	e8 3d 32 00 00       	call   3430 <exec>
    printf(stdout, "bigarg test ok\n");
     1f3:	a1 60 4e 00 00       	mov    0x4e60,%eax
     1f8:	c7 44 24 04 ba 39 00 	movl   $0x39ba,0x4(%esp)
     1ff:	00 
     200:	89 04 24             	mov    %eax,(%esp)
     203:	e8 38 33 00 00       	call   3540 <printf>
    exit();
     208:	e8 eb 31 00 00       	call   33f8 <exit>
  } else if(pid < 0){
    printf(stdout, "bigargtest: fork failed\n");
     20d:	a1 60 4e 00 00       	mov    0x4e60,%eax
     212:	c7 44 24 04 ca 39 00 	movl   $0x39ca,0x4(%esp)
     219:	00 
     21a:	89 04 24             	mov    %eax,(%esp)
     21d:	e8 1e 33 00 00       	call   3540 <printf>
    exit();
     222:	e8 d1 31 00 00       	call   33f8 <exit>
     227:	89 f6                	mov    %esi,%esi
     229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000230 <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
     230:	55                   	push   %ebp
     231:	89 e5                	mov    %esp,%ebp
     233:	53                   	push   %ebx
  int n, pid;

  printf(1, "fork test\n");
     234:	31 db                	xor    %ebx,%ebx
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
     236:	83 ec 14             	sub    $0x14,%esp
  int n, pid;

  printf(1, "fork test\n");
     239:	c7 44 24 04 e3 39 00 	movl   $0x39e3,0x4(%esp)
     240:	00 
     241:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     248:	e8 f3 32 00 00       	call   3540 <printf>
     24d:	eb 13                	jmp    262 <forktest+0x32>
     24f:	90                   	nop

  for(n=0; n<1000; n++){
    pid = fork();
    if(pid < 0)
      break;
    if(pid == 0)
     250:	74 72                	je     2c4 <forktest+0x94>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
     252:	83 c3 01             	add    $0x1,%ebx
     255:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
     25b:	90                   	nop
     25c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
     260:	74 4e                	je     2b0 <forktest+0x80>
     262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pid = fork();
     268:	e8 83 31 00 00       	call   33f0 <fork>
    if(pid < 0)
     26d:	83 f8 00             	cmp    $0x0,%eax
     270:	7d de                	jge    250 <forktest+0x20>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }
  
  for(; n > 0; n--){
     272:	85 db                	test   %ebx,%ebx
     274:	74 11                	je     287 <forktest+0x57>
     276:	66 90                	xchg   %ax,%ax
    if(wait() < 0){
     278:	e8 83 31 00 00       	call   3400 <wait>
     27d:	85 c0                	test   %eax,%eax
     27f:	90                   	nop
     280:	78 47                	js     2c9 <forktest+0x99>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }
  
  for(; n > 0; n--){
     282:	83 eb 01             	sub    $0x1,%ebx
     285:	75 f1                	jne    278 <forktest+0x48>
     287:	90                   	nop
      printf(1, "wait stopped early\n");
      exit();
    }
  }
  
  if(wait() != -1){
     288:	e8 73 31 00 00       	call   3400 <wait>
     28d:	83 f8 ff             	cmp    $0xffffffff,%eax
     290:	75 50                	jne    2e2 <forktest+0xb2>
    printf(1, "wait got too many\n");
    exit();
  }
  
  printf(1, "fork test OK\n");
     292:	c7 44 24 04 15 3a 00 	movl   $0x3a15,0x4(%esp)
     299:	00 
     29a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     2a1:	e8 9a 32 00 00       	call   3540 <printf>
}
     2a6:	83 c4 14             	add    $0x14,%esp
     2a9:	5b                   	pop    %ebx
     2aa:	5d                   	pop    %ebp
     2ab:	c3                   	ret    
     2ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(pid == 0)
      exit();
  }
  
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
     2b0:	c7 44 24 04 cc 47 00 	movl   $0x47cc,0x4(%esp)
     2b7:	00 
     2b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     2bf:	e8 7c 32 00 00       	call   3540 <printf>
    exit();
     2c4:	e8 2f 31 00 00       	call   33f8 <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
      printf(1, "wait stopped early\n");
     2c9:	c7 44 24 04 ee 39 00 	movl   $0x39ee,0x4(%esp)
     2d0:	00 
     2d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     2d8:	e8 63 32 00 00       	call   3540 <printf>
      exit();
     2dd:	e8 16 31 00 00       	call   33f8 <exit>
    }
  }
  
  if(wait() != -1){
    printf(1, "wait got too many\n");
     2e2:	c7 44 24 04 02 3a 00 	movl   $0x3a02,0x4(%esp)
     2e9:	00 
     2ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     2f1:	e8 4a 32 00 00       	call   3540 <printf>
    exit();
     2f6:	e8 fd 30 00 00       	call   33f8 <exit>
     2fb:	90                   	nop
     2fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000300 <exitwait>:
}

// try to find any races between exit and wait
void
exitwait(void)
{
     300:	55                   	push   %ebp
     301:	89 e5                	mov    %esp,%ebp
     303:	56                   	push   %esi
     304:	31 f6                	xor    %esi,%esi
     306:	53                   	push   %ebx
     307:	83 ec 10             	sub    $0x10,%esp
     30a:	eb 17                	jmp    323 <exitwait+0x23>
     30c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      return;
    }
    if(pid){
     310:	74 79                	je     38b <exitwait+0x8b>
      if(wait() != pid){
     312:	e8 e9 30 00 00       	call   3400 <wait>
     317:	39 c3                	cmp    %eax,%ebx
     319:	75 35                	jne    350 <exitwait+0x50>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
     31b:	83 c6 01             	add    $0x1,%esi
     31e:	83 fe 64             	cmp    $0x64,%esi
     321:	74 4d                	je     370 <exitwait+0x70>
    pid = fork();
     323:	e8 c8 30 00 00       	call   33f0 <fork>
    if(pid < 0){
     328:	83 f8 00             	cmp    $0x0,%eax
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
    pid = fork();
     32b:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
     32d:	7d e1                	jge    310 <exitwait+0x10>
      printf(1, "fork failed\n");
     32f:	c7 44 24 04 d6 39 00 	movl   $0x39d6,0x4(%esp)
     336:	00 
     337:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     33e:	e8 fd 31 00 00       	call   3540 <printf>
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
}
     343:	83 c4 10             	add    $0x10,%esp
     346:	5b                   	pop    %ebx
     347:	5e                   	pop    %esi
     348:	5d                   	pop    %ebp
     349:	c3                   	ret    
     34a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      printf(1, "fork failed\n");
      return;
    }
    if(pid){
      if(wait() != pid){
        printf(1, "wait wrong pid\n");
     350:	c7 44 24 04 23 3a 00 	movl   $0x3a23,0x4(%esp)
     357:	00 
     358:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     35f:	e8 dc 31 00 00       	call   3540 <printf>
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
}
     364:	83 c4 10             	add    $0x10,%esp
     367:	5b                   	pop    %ebx
     368:	5e                   	pop    %esi
     369:	5d                   	pop    %ebp
     36a:	c3                   	ret    
     36b:	90                   	nop
     36c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      }
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
     370:	c7 44 24 04 33 3a 00 	movl   $0x3a33,0x4(%esp)
     377:	00 
     378:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     37f:	e8 bc 31 00 00       	call   3540 <printf>
}
     384:	83 c4 10             	add    $0x10,%esp
     387:	5b                   	pop    %ebx
     388:	5e                   	pop    %esi
     389:	5d                   	pop    %ebp
     38a:	c3                   	ret    
      if(wait() != pid){
        printf(1, "wait wrong pid\n");
        return;
      }
    } else {
      exit();
     38b:	e8 68 30 00 00       	call   33f8 <exit>

00000390 <validatetest>:
      "ebx");
}

void
validatetest(void)
{
     390:	55                   	push   %ebp
     391:	89 e5                	mov    %esp,%ebp
     393:	56                   	push   %esi
     394:	53                   	push   %ebx
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
     395:	31 db                	xor    %ebx,%ebx
      "ebx");
}

void
validatetest(void)
{
     397:	83 ec 10             	sub    $0x10,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
     39a:	a1 60 4e 00 00       	mov    0x4e60,%eax
     39f:	c7 44 24 04 40 3a 00 	movl   $0x3a40,0x4(%esp)
     3a6:	00 
     3a7:	89 04 24             	mov    %eax,(%esp)
     3aa:	e8 91 31 00 00       	call   3540 <printf>
     3af:	90                   	nop
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    if((pid = fork()) == 0){
     3b0:	e8 3b 30 00 00       	call   33f0 <fork>
     3b5:	85 c0                	test   %eax,%eax
     3b7:	89 c6                	mov    %eax,%esi
     3b9:	74 79                	je     434 <validatetest+0xa4>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
      exit();
    }
    sleep(0);
     3bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     3c2:	e8 c1 30 00 00       	call   3488 <sleep>
    sleep(0);
     3c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     3ce:	e8 b5 30 00 00       	call   3488 <sleep>
    kill(pid);
     3d3:	89 34 24             	mov    %esi,(%esp)
     3d6:	e8 4d 30 00 00       	call   3428 <kill>
    wait();
     3db:	e8 20 30 00 00       	call   3400 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
     3e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     3e4:	c7 04 24 4f 3a 00 00 	movl   $0x3a4f,(%esp)
     3eb:	e8 68 30 00 00       	call   3458 <link>
     3f0:	83 f8 ff             	cmp    $0xffffffff,%eax
     3f3:	75 2a                	jne    41f <validatetest+0x8f>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
     3f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
     3fb:	81 fb 00 40 11 00    	cmp    $0x114000,%ebx
     401:	75 ad                	jne    3b0 <validatetest+0x20>
      printf(stdout, "link should not succeed\n");
      exit();
    }
  }

  printf(stdout, "validate ok\n");
     403:	a1 60 4e 00 00       	mov    0x4e60,%eax
     408:	c7 44 24 04 73 3a 00 	movl   $0x3a73,0x4(%esp)
     40f:	00 
     410:	89 04 24             	mov    %eax,(%esp)
     413:	e8 28 31 00 00       	call   3540 <printf>
}
     418:	83 c4 10             	add    $0x10,%esp
     41b:	5b                   	pop    %ebx
     41c:	5e                   	pop    %esi
     41d:	5d                   	pop    %ebp
     41e:	c3                   	ret    
    kill(pid);
    wait();

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
      printf(stdout, "link should not succeed\n");
     41f:	a1 60 4e 00 00       	mov    0x4e60,%eax
     424:	c7 44 24 04 5a 3a 00 	movl   $0x3a5a,0x4(%esp)
     42b:	00 
     42c:	89 04 24             	mov    %eax,(%esp)
     42f:	e8 0c 31 00 00       	call   3540 <printf>
      exit();
     434:	e8 bf 2f 00 00       	call   33f8 <exit>
     439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000440 <sbrktest>:
  printf(1, "fork test OK\n");
}

void
sbrktest(void)
{
     440:	55                   	push   %ebp
     441:	89 e5                	mov    %esp,%ebp
     443:	57                   	push   %edi
     444:	56                   	push   %esi

  printf(stdout, "sbrk test\n");
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
     445:	31 f6                	xor    %esi,%esi
  printf(1, "fork test OK\n");
}

void
sbrktest(void)
{
     447:	53                   	push   %ebx
     448:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  int fds[2], pid, pids[32], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
     44e:	a1 60 4e 00 00       	mov    0x4e60,%eax
     453:	c7 44 24 04 80 3a 00 	movl   $0x3a80,0x4(%esp)
     45a:	00 
     45b:	89 04 24             	mov    %eax,(%esp)
     45e:	e8 dd 30 00 00       	call   3540 <printf>
  oldbrk = sbrk(0);
     463:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     46a:	e8 11 30 00 00       	call   3480 <sbrk>

  // can one sbrk() less than a page?
  a = sbrk(0);
     46f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  int fds[2], pid, pids[32], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
  oldbrk = sbrk(0);
     476:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
     47c:	e8 ff 2f 00 00       	call   3480 <sbrk>
     481:	89 c3                	mov    %eax,%ebx
     483:	90                   	nop
     484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  int i;
  for(i = 0; i < 5000; i++){
    b = sbrk(1);
     488:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     48f:	e8 ec 2f 00 00       	call   3480 <sbrk>
    if(b != a){
     494:	39 c3                	cmp    %eax,%ebx
     496:	0f 85 8a 02 00 00    	jne    726 <sbrktest+0x2e6>
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){
     49c:	83 c6 01             	add    $0x1,%esi
    b = sbrk(1);
    if(b != a){
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
      exit();
    }
    *b = 1;
     49f:	c6 03 01             	movb   $0x1,(%ebx)
    a = b + 1;
     4a2:	83 c3 01             	add    $0x1,%ebx
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){
     4a5:	81 fe 88 13 00 00    	cmp    $0x1388,%esi
     4ab:	75 db                	jne    488 <sbrktest+0x48>
      exit();
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
     4ad:	e8 3e 2f 00 00       	call   33f0 <fork>
  if(pid < 0){
     4b2:	85 c0                	test   %eax,%eax
      exit();
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
     4b4:	89 c6                	mov    %eax,%esi
  if(pid < 0){
     4b6:	0f 88 18 04 00 00    	js     8d4 <sbrktest+0x494>
    printf(stdout, "sbrk test fork failed\n");
    exit();
  }
  c = sbrk(1);
     4bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c = sbrk(1);
  if(c != a + 1){
     4c3:	83 c3 01             	add    $0x1,%ebx
  pid = fork();
  if(pid < 0){
    printf(stdout, "sbrk test fork failed\n");
    exit();
  }
  c = sbrk(1);
     4c6:	e8 b5 2f 00 00       	call   3480 <sbrk>
  c = sbrk(1);
     4cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     4d2:	e8 a9 2f 00 00       	call   3480 <sbrk>
  if(c != a + 1){
     4d7:	39 d8                	cmp    %ebx,%eax
     4d9:	0f 85 db 03 00 00    	jne    8ba <sbrktest+0x47a>
    printf(stdout, "sbrk test failed post-fork\n");
    exit();
  }
  if(pid == 0)
     4df:	85 f6                	test   %esi,%esi
     4e1:	0f 84 ce 03 00 00    	je     8b5 <sbrktest+0x475>
     4e7:	90                   	nop
    exit();
  wait();
     4e8:	e8 13 2f 00 00       	call   3400 <wait>

  // can one allocate the full 640K?
  a = sbrk(0);
     4ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     4f4:	e8 87 2f 00 00       	call   3480 <sbrk>
     4f9:	89 c3                	mov    %eax,%ebx
  amt = (640 * 1024) - (uint)a;
  p = sbrk(amt);
     4fb:	b8 00 00 0a 00       	mov    $0xa0000,%eax
     500:	29 d8                	sub    %ebx,%eax
     502:	89 04 24             	mov    %eax,(%esp)
     505:	e8 76 2f 00 00       	call   3480 <sbrk>
  if(p != a){
     50a:	39 c3                	cmp    %eax,%ebx
     50c:	0f 85 86 03 00 00    	jne    898 <sbrktest+0x458>
    printf(stdout, "sbrk test failed 640K test, p %x a %x\n", p, a);
    exit();
  }
  lastaddr = (char*)(640 * 1024 - 1);
  *lastaddr = 99;
     512:	c6 05 ff ff 09 00 63 	movb   $0x63,0x9ffff

  // is one forbidden from allocating more than 640K?
  c = sbrk(4096);
     519:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
     520:	e8 5b 2f 00 00       	call   3480 <sbrk>
  if(c != (char*)0xffffffff){
     525:	83 f8 ff             	cmp    $0xffffffff,%eax
     528:	0f 85 4c 03 00 00    	jne    87a <sbrktest+0x43a>
    printf(stdout, "sbrk allocated more than 640K, c %x\n", c);
    exit();
  }

  // can one de-allocate?
  a = sbrk(0);
     52e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     535:	e8 46 2f 00 00       	call   3480 <sbrk>
  c = sbrk(-4096);
     53a:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    printf(stdout, "sbrk allocated more than 640K, c %x\n", c);
    exit();
  }

  // can one de-allocate?
  a = sbrk(0);
     541:	89 c3                	mov    %eax,%ebx
  c = sbrk(-4096);
     543:	e8 38 2f 00 00       	call   3480 <sbrk>
  if(c == (char*)0xffffffff){
     548:	83 f8 ff             	cmp    $0xffffffff,%eax
     54b:	0f 84 0f 03 00 00    	je     860 <sbrktest+0x420>
    printf(stdout, "sbrk could not deallocate\n");
    exit();
  }
  c = sbrk(0);
     551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     558:	e8 23 2f 00 00       	call   3480 <sbrk>
  if(c != a - 4096){
     55d:	8d 93 00 f0 ff ff    	lea    -0x1000(%ebx),%edx
     563:	39 d0                	cmp    %edx,%eax
     565:	0f 85 d3 02 00 00    	jne    83e <sbrktest+0x3fe>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    exit();
  }

  // can one re-allocate that page?
  a = sbrk(0);
     56b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     572:	e8 09 2f 00 00       	call   3480 <sbrk>
  c = sbrk(4096);
     577:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    exit();
  }

  // can one re-allocate that page?
  a = sbrk(0);
     57e:	89 c3                	mov    %eax,%ebx
  c = sbrk(4096);
     580:	e8 fb 2e 00 00       	call   3480 <sbrk>
  if(c != a || sbrk(0) != a + 4096){
     585:	39 c3                	cmp    %eax,%ebx
    exit();
  }

  // can one re-allocate that page?
  a = sbrk(0);
  c = sbrk(4096);
     587:	89 c6                	mov    %eax,%esi
  if(c != a || sbrk(0) != a + 4096){
     589:	0f 85 8d 02 00 00    	jne    81c <sbrktest+0x3dc>
     58f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     596:	e8 e5 2e 00 00       	call   3480 <sbrk>
     59b:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
     5a1:	39 d0                	cmp    %edx,%eax
     5a3:	0f 85 73 02 00 00    	jne    81c <sbrktest+0x3dc>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    exit();
  }
  if(*lastaddr == 99){
     5a9:	80 3d ff ff 09 00 63 	cmpb   $0x63,0x9ffff
     5b0:	0f 84 4c 02 00 00    	je     802 <sbrktest+0x3c2>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    exit();
  }

  c = sbrk(4096);
     5b6:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  if(c != (char*)0xffffffff){
    printf(stdout, "sbrk was able to re-allocate beyond 640K, c %x\n", c);
    exit();
     5bd:	bb 00 00 0a 00       	mov    $0xa0000,%ebx
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    exit();
  }

  c = sbrk(4096);
     5c2:	e8 b9 2e 00 00       	call   3480 <sbrk>
  if(c != (char*)0xffffffff){
     5c7:	83 f8 ff             	cmp    $0xffffffff,%eax
     5ca:	0f 85 14 02 00 00    	jne    7e4 <sbrktest+0x3a4>
    exit();
  }

  // can we read the kernel's memory?
  for(a = (char*)(640*1024); a < (char*)2000000; a += 50000){
    ppid = getpid();
     5d0:	e8 a3 2e 00 00       	call   3478 <getpid>
     5d5:	89 c6                	mov    %eax,%esi
    pid = fork();
     5d7:	e8 14 2e 00 00       	call   33f0 <fork>
    if(pid < 0){
     5dc:	83 f8 00             	cmp    $0x0,%eax
     5df:	0f 8c e5 01 00 00    	jl     7ca <sbrktest+0x38a>
      printf(stdout, "fork failed\n");
      exit();
    }
    if(pid == 0){
     5e5:	0f 84 b2 01 00 00    	je     79d <sbrktest+0x35d>
    printf(stdout, "sbrk was able to re-allocate beyond 640K, c %x\n", c);
    exit();
  }

  // can we read the kernel's memory?
  for(a = (char*)(640*1024); a < (char*)2000000; a += 50000){
     5eb:	81 c3 50 c3 00 00    	add    $0xc350,%ebx
     5f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(pid == 0){
      printf(stdout, "oops could read %x = %x\n", a, *a);
      kill(ppid);
      exit();
    }
    wait();
     5f8:	e8 03 2e 00 00       	call   3400 <wait>
    printf(stdout, "sbrk was able to re-allocate beyond 640K, c %x\n", c);
    exit();
  }

  // can we read the kernel's memory?
  for(a = (char*)(640*1024); a < (char*)2000000; a += 50000){
     5fd:	81 fb 70 99 1e 00    	cmp    $0x1e9970,%ebx
     603:	75 cb                	jne    5d0 <sbrktest+0x190>
    wait();
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  sbrk(-(sbrk(0) - oldbrk));
     605:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     60c:	e8 6f 2e 00 00       	call   3480 <sbrk>
     611:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
     617:	29 c2                	sub    %eax,%edx
     619:	89 14 24             	mov    %edx,(%esp)
     61c:	e8 5f 2e 00 00       	call   3480 <sbrk>
  if(pipe(fds) != 0){
     621:	8d 45 dc             	lea    -0x24(%ebp),%eax
     624:	89 04 24             	mov    %eax,(%esp)
     627:	e8 dc 2d 00 00       	call   3408 <pipe>
     62c:	85 c0                	test   %eax,%eax
     62e:	0f 85 50 01 00 00    	jne    784 <sbrktest+0x344>
    printf(1, "pipe() failed\n");
    exit();
     634:	31 db                	xor    %ebx,%ebx
     636:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
     63c:	eb 2a                	jmp    668 <sbrktest+0x228>
      sbrk((640 * 1024) - (uint)sbrk(0));
      write(fds[1], "x", 1);
      // sit around until killed
      for(;;) sleep(1000);
    }
    if(pids[i] != -1)
     63e:	83 f8 ff             	cmp    $0xffffffff,%eax
     641:	74 1a                	je     65d <sbrktest+0x21d>
      read(fds[0], &scratch, 1);
     643:	8d 45 e7             	lea    -0x19(%ebp),%eax
     646:	89 44 24 04          	mov    %eax,0x4(%esp)
     64a:	8b 45 dc             	mov    -0x24(%ebp),%eax
     64d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     654:	00 
     655:	89 04 24             	mov    %eax,(%esp)
     658:	e8 b3 2d 00 00       	call   3410 <read>
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if((pids[i] = fork()) == 0){
     65d:	89 34 9f             	mov    %esi,(%edi,%ebx,4)
  sbrk(-(sbrk(0) - oldbrk));
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
     660:	83 c3 01             	add    $0x1,%ebx
     663:	83 fb 20             	cmp    $0x20,%ebx
     666:	74 56                	je     6be <sbrktest+0x27e>
    if((pids[i] = fork()) == 0){
     668:	e8 83 2d 00 00       	call   33f0 <fork>
     66d:	85 c0                	test   %eax,%eax
     66f:	89 c6                	mov    %eax,%esi
     671:	75 cb                	jne    63e <sbrktest+0x1fe>
      // allocate the full 640K
      sbrk((640 * 1024) - (uint)sbrk(0));
     673:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     67a:	e8 01 2e 00 00       	call   3480 <sbrk>
     67f:	ba 00 00 0a 00       	mov    $0xa0000,%edx
     684:	29 c2                	sub    %eax,%edx
     686:	89 14 24             	mov    %edx,(%esp)
     689:	e8 f2 2d 00 00       	call   3480 <sbrk>
      write(fds[1], "x", 1);
     68e:	8b 45 e0             	mov    -0x20(%ebp),%eax
     691:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     698:	00 
     699:	c7 44 24 04 49 40 00 	movl   $0x4049,0x4(%esp)
     6a0:	00 
     6a1:	89 04 24             	mov    %eax,(%esp)
     6a4:	e8 6f 2d 00 00       	call   3418 <write>
     6a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      // sit around until killed
      for(;;) sleep(1000);
     6b0:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
     6b7:	e8 cc 2d 00 00       	call   3488 <sleep>
     6bc:	eb f2                	jmp    6b0 <sbrktest+0x270>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
     6be:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
     6c5:	30 db                	xor    %bl,%bl
     6c7:	e8 b4 2d 00 00       	call   3480 <sbrk>
     6cc:	89 c6                	mov    %eax,%esi
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if(pids[i] == -1)
     6ce:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
     6d1:	83 f8 ff             	cmp    $0xffffffff,%eax
     6d4:	74 0d                	je     6e3 <sbrktest+0x2a3>
      continue;
    kill(pids[i]);
     6d6:	89 04 24             	mov    %eax,(%esp)
     6d9:	e8 4a 2d 00 00       	call   3428 <kill>
    wait();
     6de:	e8 1d 2d 00 00       	call   3400 <wait>
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
     6e3:	83 c3 01             	add    $0x1,%ebx
     6e6:	83 fb 20             	cmp    $0x20,%ebx
     6e9:	75 e3                	jne    6ce <sbrktest+0x28e>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
     6eb:	83 fe ff             	cmp    $0xffffffff,%esi
     6ee:	66 90                	xchg   %ax,%ax
     6f0:	74 78                	je     76a <sbrktest+0x32a>
    printf(stdout, "failed sbrk leaked memory\n");
    exit();
  }

  if(sbrk(0) > oldbrk)
     6f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     6f9:	e8 82 2d 00 00       	call   3480 <sbrk>
     6fe:	39 85 54 ff ff ff    	cmp    %eax,-0xac(%ebp)
     704:	72 46                	jb     74c <sbrktest+0x30c>
    sbrk(-(sbrk(0) - oldbrk));

  printf(stdout, "sbrk test OK\n");
     706:	a1 60 4e 00 00       	mov    0x4e60,%eax
     70b:	c7 44 24 04 37 3b 00 	movl   $0x3b37,0x4(%esp)
     712:	00 
     713:	89 04 24             	mov    %eax,(%esp)
     716:	e8 25 2e 00 00       	call   3540 <printf>
}
     71b:	81 c4 cc 00 00 00    	add    $0xcc,%esp
     721:	5b                   	pop    %ebx
     722:	5e                   	pop    %esi
     723:	5f                   	pop    %edi
     724:	5d                   	pop    %ebp
     725:	c3                   	ret    
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){
    b = sbrk(1);
    if(b != a){
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
     726:	89 44 24 10          	mov    %eax,0x10(%esp)
     72a:	a1 60 4e 00 00       	mov    0x4e60,%eax
     72f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
     733:	89 74 24 08          	mov    %esi,0x8(%esp)
     737:	c7 44 24 04 8b 3a 00 	movl   $0x3a8b,0x4(%esp)
     73e:	00 
     73f:	89 04 24             	mov    %eax,(%esp)
     742:	e8 f9 2d 00 00       	call   3540 <printf>
      exit();
     747:	e8 ac 2c 00 00       	call   33f8 <exit>
    printf(stdout, "failed sbrk leaked memory\n");
    exit();
  }

  if(sbrk(0) > oldbrk)
    sbrk(-(sbrk(0) - oldbrk));
     74c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     753:	e8 28 2d 00 00       	call   3480 <sbrk>
     758:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
     75e:	29 c2                	sub    %eax,%edx
     760:	89 14 24             	mov    %edx,(%esp)
     763:	e8 18 2d 00 00       	call   3480 <sbrk>
     768:	eb 9c                	jmp    706 <sbrktest+0x2c6>
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    printf(stdout, "failed sbrk leaked memory\n");
     76a:	a1 60 4e 00 00       	mov    0x4e60,%eax
     76f:	c7 44 24 04 1c 3b 00 	movl   $0x3b1c,0x4(%esp)
     776:	00 
     777:	89 04 24             	mov    %eax,(%esp)
     77a:	e8 c1 2d 00 00       	call   3540 <printf>
    exit();
     77f:	e8 74 2c 00 00       	call   33f8 <exit>

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  sbrk(-(sbrk(0) - oldbrk));
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
     784:	c7 44 24 04 0d 3b 00 	movl   $0x3b0d,0x4(%esp)
     78b:	00 
     78c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     793:	e8 a8 2d 00 00       	call   3540 <printf>
    exit();
     798:	e8 5b 2c 00 00       	call   33f8 <exit>
    if(pid < 0){
      printf(stdout, "fork failed\n");
      exit();
    }
    if(pid == 0){
      printf(stdout, "oops could read %x = %x\n", a, *a);
     79d:	0f be 03             	movsbl (%ebx),%eax
     7a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     7a4:	c7 44 24 04 f4 3a 00 	movl   $0x3af4,0x4(%esp)
     7ab:	00 
     7ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
     7b0:	a1 60 4e 00 00       	mov    0x4e60,%eax
     7b5:	89 04 24             	mov    %eax,(%esp)
     7b8:	e8 83 2d 00 00       	call   3540 <printf>
      kill(ppid);
     7bd:	89 34 24             	mov    %esi,(%esp)
     7c0:	e8 63 2c 00 00       	call   3428 <kill>
      exit();
     7c5:	e8 2e 2c 00 00       	call   33f8 <exit>
  // can we read the kernel's memory?
  for(a = (char*)(640*1024); a < (char*)2000000; a += 50000){
    ppid = getpid();
    pid = fork();
    if(pid < 0){
      printf(stdout, "fork failed\n");
     7ca:	a1 60 4e 00 00       	mov    0x4e60,%eax
     7cf:	c7 44 24 04 d6 39 00 	movl   $0x39d6,0x4(%esp)
     7d6:	00 
     7d7:	89 04 24             	mov    %eax,(%esp)
     7da:	e8 61 2d 00 00       	call   3540 <printf>
      exit();
     7df:	e8 14 2c 00 00       	call   33f8 <exit>
    exit();
  }

  c = sbrk(4096);
  if(c != (char*)0xffffffff){
    printf(stdout, "sbrk was able to re-allocate beyond 640K, c %x\n", c);
     7e4:	89 44 24 08          	mov    %eax,0x8(%esp)
     7e8:	a1 60 4e 00 00       	mov    0x4e60,%eax
     7ed:	c7 44 24 04 d0 48 00 	movl   $0x48d0,0x4(%esp)
     7f4:	00 
     7f5:	89 04 24             	mov    %eax,(%esp)
     7f8:	e8 43 2d 00 00       	call   3540 <printf>
    exit();
     7fd:	e8 f6 2b 00 00       	call   33f8 <exit>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    exit();
  }
  if(*lastaddr == 99){
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
     802:	a1 60 4e 00 00       	mov    0x4e60,%eax
     807:	c7 44 24 04 a0 48 00 	movl   $0x48a0,0x4(%esp)
     80e:	00 
     80f:	89 04 24             	mov    %eax,(%esp)
     812:	e8 29 2d 00 00       	call   3540 <printf>
    exit();
     817:	e8 dc 2b 00 00       	call   33f8 <exit>

  // can one re-allocate that page?
  a = sbrk(0);
  c = sbrk(4096);
  if(c != a || sbrk(0) != a + 4096){
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
     81c:	a1 60 4e 00 00       	mov    0x4e60,%eax
     821:	89 74 24 0c          	mov    %esi,0xc(%esp)
     825:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     829:	c7 44 24 04 78 48 00 	movl   $0x4878,0x4(%esp)
     830:	00 
     831:	89 04 24             	mov    %eax,(%esp)
     834:	e8 07 2d 00 00       	call   3540 <printf>
    exit();
     839:	e8 ba 2b 00 00       	call   33f8 <exit>
    printf(stdout, "sbrk could not deallocate\n");
    exit();
  }
  c = sbrk(0);
  if(c != a - 4096){
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
     83e:	89 44 24 0c          	mov    %eax,0xc(%esp)
     842:	a1 60 4e 00 00       	mov    0x4e60,%eax
     847:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     84b:	c7 44 24 04 40 48 00 	movl   $0x4840,0x4(%esp)
     852:	00 
     853:	89 04 24             	mov    %eax,(%esp)
     856:	e8 e5 2c 00 00       	call   3540 <printf>
    exit();
     85b:	e8 98 2b 00 00       	call   33f8 <exit>

  // can one de-allocate?
  a = sbrk(0);
  c = sbrk(-4096);
  if(c == (char*)0xffffffff){
    printf(stdout, "sbrk could not deallocate\n");
     860:	a1 60 4e 00 00       	mov    0x4e60,%eax
     865:	c7 44 24 04 d9 3a 00 	movl   $0x3ad9,0x4(%esp)
     86c:	00 
     86d:	89 04 24             	mov    %eax,(%esp)
     870:	e8 cb 2c 00 00       	call   3540 <printf>
    exit();
     875:	e8 7e 2b 00 00       	call   33f8 <exit>
  *lastaddr = 99;

  // is one forbidden from allocating more than 640K?
  c = sbrk(4096);
  if(c != (char*)0xffffffff){
    printf(stdout, "sbrk allocated more than 640K, c %x\n", c);
     87a:	89 44 24 08          	mov    %eax,0x8(%esp)
     87e:	a1 60 4e 00 00       	mov    0x4e60,%eax
     883:	c7 44 24 04 18 48 00 	movl   $0x4818,0x4(%esp)
     88a:	00 
     88b:	89 04 24             	mov    %eax,(%esp)
     88e:	e8 ad 2c 00 00       	call   3540 <printf>
    exit();
     893:	e8 60 2b 00 00       	call   33f8 <exit>
  // can one allocate the full 640K?
  a = sbrk(0);
  amt = (640 * 1024) - (uint)a;
  p = sbrk(amt);
  if(p != a){
    printf(stdout, "sbrk test failed 640K test, p %x a %x\n", p, a);
     898:	89 44 24 08          	mov    %eax,0x8(%esp)
     89c:	a1 60 4e 00 00       	mov    0x4e60,%eax
     8a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
     8a5:	c7 44 24 04 f0 47 00 	movl   $0x47f0,0x4(%esp)
     8ac:	00 
     8ad:	89 04 24             	mov    %eax,(%esp)
     8b0:	e8 8b 2c 00 00       	call   3540 <printf>
    exit();
     8b5:	e8 3e 2b 00 00       	call   33f8 <exit>
    exit();
  }
  c = sbrk(1);
  c = sbrk(1);
  if(c != a + 1){
    printf(stdout, "sbrk test failed post-fork\n");
     8ba:	a1 60 4e 00 00       	mov    0x4e60,%eax
     8bf:	c7 44 24 04 bd 3a 00 	movl   $0x3abd,0x4(%esp)
     8c6:	00 
     8c7:	89 04 24             	mov    %eax,(%esp)
     8ca:	e8 71 2c 00 00       	call   3540 <printf>
    exit();
     8cf:	e8 24 2b 00 00       	call   33f8 <exit>
    *b = 1;
    a = b + 1;
  }
  pid = fork();
  if(pid < 0){
    printf(stdout, "sbrk test fork failed\n");
     8d4:	a1 60 4e 00 00       	mov    0x4e60,%eax
     8d9:	c7 44 24 04 a6 3a 00 	movl   $0x3aa6,0x4(%esp)
     8e0:	00 
     8e1:	89 04 24             	mov    %eax,(%esp)
     8e4:	e8 57 2c 00 00       	call   3540 <printf>
    exit();
     8e9:	e8 0a 2b 00 00       	call   33f8 <exit>
     8ee:	66 90                	xchg   %ax,%ax

000008f0 <preempt>:
}

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     8f0:	55                   	push   %ebp
     8f1:	89 e5                	mov    %esp,%ebp
     8f3:	57                   	push   %edi
     8f4:	56                   	push   %esi
     8f5:	53                   	push   %ebx
     8f6:	83 ec 2c             	sub    $0x2c,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     8f9:	c7 44 24 04 45 3b 00 	movl   $0x3b45,0x4(%esp)
     900:	00 
     901:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     908:	e8 33 2c 00 00       	call   3540 <printf>
  pid1 = fork();
     90d:	e8 de 2a 00 00       	call   33f0 <fork>
  if(pid1 == 0)
     912:	85 c0                	test   %eax,%eax
{
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
  pid1 = fork();
     914:	89 c7                	mov    %eax,%edi
  if(pid1 == 0)
     916:	75 02                	jne    91a <preempt+0x2a>
     918:	eb fe                	jmp    918 <preempt+0x28>
     91a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    for(;;)
      ;

  pid2 = fork();
     920:	e8 cb 2a 00 00       	call   33f0 <fork>
  if(pid2 == 0)
     925:	85 c0                	test   %eax,%eax
  pid1 = fork();
  if(pid1 == 0)
    for(;;)
      ;

  pid2 = fork();
     927:	89 c6                	mov    %eax,%esi
  if(pid2 == 0)
     929:	75 02                	jne    92d <preempt+0x3d>
     92b:	eb fe                	jmp    92b <preempt+0x3b>
    for(;;)
      ;

  pipe(pfds);
     92d:	8d 45 e0             	lea    -0x20(%ebp),%eax
     930:	89 04 24             	mov    %eax,(%esp)
     933:	e8 d0 2a 00 00       	call   3408 <pipe>
  pid3 = fork();
     938:	e8 b3 2a 00 00       	call   33f0 <fork>
  if(pid3 == 0){
     93d:	85 c0                	test   %eax,%eax
  if(pid2 == 0)
    for(;;)
      ;

  pipe(pfds);
  pid3 = fork();
     93f:	89 c3                	mov    %eax,%ebx
  if(pid3 == 0){
     941:	75 4c                	jne    98f <preempt+0x9f>
    close(pfds[0]);
     943:	8b 45 e0             	mov    -0x20(%ebp),%eax
     946:	89 04 24             	mov    %eax,(%esp)
     949:	e8 d2 2a 00 00       	call   3420 <close>
    if(write(pfds[1], "x", 1) != 1)
     94e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     951:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     958:	00 
     959:	c7 44 24 04 49 40 00 	movl   $0x4049,0x4(%esp)
     960:	00 
     961:	89 04 24             	mov    %eax,(%esp)
     964:	e8 af 2a 00 00       	call   3418 <write>
     969:	83 f8 01             	cmp    $0x1,%eax
     96c:	74 14                	je     982 <preempt+0x92>
      printf(1, "preempt write error");
     96e:	c7 44 24 04 4f 3b 00 	movl   $0x3b4f,0x4(%esp)
     975:	00 
     976:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     97d:	e8 be 2b 00 00       	call   3540 <printf>
    close(pfds[1]);
     982:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     985:	89 04 24             	mov    %eax,(%esp)
     988:	e8 93 2a 00 00       	call   3420 <close>
     98d:	eb fe                	jmp    98d <preempt+0x9d>
    for(;;)
      ;
  }

  close(pfds[1]);
     98f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     992:	89 04 24             	mov    %eax,(%esp)
     995:	e8 86 2a 00 00       	call   3420 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     99a:	8b 45 e0             	mov    -0x20(%ebp),%eax
     99d:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
     9a4:	00 
     9a5:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
     9ac:	00 
     9ad:	89 04 24             	mov    %eax,(%esp)
     9b0:	e8 5b 2a 00 00       	call   3410 <read>
     9b5:	83 f8 01             	cmp    $0x1,%eax
     9b8:	74 1c                	je     9d6 <preempt+0xe6>
    printf(1, "preempt read error");
     9ba:	c7 44 24 04 63 3b 00 	movl   $0x3b63,0x4(%esp)
     9c1:	00 
     9c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     9c9:	e8 72 2b 00 00       	call   3540 <printf>
  printf(1, "wait... ");
  wait();
  wait();
  wait();
  printf(1, "preempt ok\n");
}
     9ce:	83 c4 2c             	add    $0x2c,%esp
     9d1:	5b                   	pop    %ebx
     9d2:	5e                   	pop    %esi
     9d3:	5f                   	pop    %edi
     9d4:	5d                   	pop    %ebp
     9d5:	c3                   	ret    
  close(pfds[1]);
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    printf(1, "preempt read error");
    return;
  }
  close(pfds[0]);
     9d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
     9d9:	89 04 24             	mov    %eax,(%esp)
     9dc:	e8 3f 2a 00 00       	call   3420 <close>
  printf(1, "kill... ");
     9e1:	c7 44 24 04 76 3b 00 	movl   $0x3b76,0x4(%esp)
     9e8:	00 
     9e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     9f0:	e8 4b 2b 00 00       	call   3540 <printf>
  kill(pid1);
     9f5:	89 3c 24             	mov    %edi,(%esp)
     9f8:	e8 2b 2a 00 00       	call   3428 <kill>
  kill(pid2);
     9fd:	89 34 24             	mov    %esi,(%esp)
     a00:	e8 23 2a 00 00       	call   3428 <kill>
  kill(pid3);
     a05:	89 1c 24             	mov    %ebx,(%esp)
     a08:	e8 1b 2a 00 00       	call   3428 <kill>
  printf(1, "wait... ");
     a0d:	c7 44 24 04 7f 3b 00 	movl   $0x3b7f,0x4(%esp)
     a14:	00 
     a15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a1c:	e8 1f 2b 00 00       	call   3540 <printf>
  wait();
     a21:	e8 da 29 00 00       	call   3400 <wait>
  wait();
     a26:	e8 d5 29 00 00       	call   3400 <wait>
     a2b:	90                   	nop
     a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  wait();
     a30:	e8 cb 29 00 00       	call   3400 <wait>
  printf(1, "preempt ok\n");
     a35:	c7 44 24 04 88 3b 00 	movl   $0x3b88,0x4(%esp)
     a3c:	00 
     a3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a44:	e8 f7 2a 00 00       	call   3540 <printf>
     a49:	eb 83                	jmp    9ce <preempt+0xde>
     a4b:	90                   	nop
     a4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000a50 <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     a50:	55                   	push   %ebp
     a51:	89 e5                	mov    %esp,%ebp
     a53:	57                   	push   %edi
     a54:	56                   	push   %esi
     a55:	53                   	push   %ebx
     a56:	83 ec 2c             	sub    $0x2c,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     a59:	8d 45 e0             	lea    -0x20(%ebp),%eax
     a5c:	89 04 24             	mov    %eax,(%esp)
     a5f:	e8 a4 29 00 00       	call   3408 <pipe>
     a64:	85 c0                	test   %eax,%eax
     a66:	0f 85 53 01 00 00    	jne    bbf <pipe1+0x16f>
    printf(1, "pipe() failed\n");
    exit();
  }
  pid = fork();
     a6c:	e8 7f 29 00 00       	call   33f0 <fork>
  seq = 0;
  if(pid == 0){
     a71:	83 f8 00             	cmp    $0x0,%eax
     a74:	0f 84 87 00 00 00    	je     b01 <pipe1+0xb1>
     a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
  } else if(pid > 0){
     a80:	0f 8e 52 01 00 00    	jle    bd8 <pipe1+0x188>
    close(fds[1]);
     a86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     a89:	31 ff                	xor    %edi,%edi
     a8b:	be 01 00 00 00       	mov    $0x1,%esi
     a90:	31 db                	xor    %ebx,%ebx
     a92:	89 04 24             	mov    %eax,(%esp)
     a95:	e8 86 29 00 00       	call   3420 <close>
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     a9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
     a9d:	89 74 24 08          	mov    %esi,0x8(%esp)
     aa1:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
     aa8:	00 
     aa9:	89 04 24             	mov    %eax,(%esp)
     aac:	e8 5f 29 00 00       	call   3410 <read>
     ab1:	85 c0                	test   %eax,%eax
     ab3:	0f 8e a4 00 00 00    	jle    b5d <pipe1+0x10d>
     ab9:	31 d2                	xor    %edx,%edx
     abb:	90                   	nop
     abc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      for(i = 0; i < n; i++){
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     ac0:	38 9a c0 75 00 00    	cmp    %bl,0x75c0(%edx)
     ac6:	75 1d                	jne    ae5 <pipe1+0x95>
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     ac8:	83 c2 01             	add    $0x1,%edx
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     acb:	83 c3 01             	add    $0x1,%ebx
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     ace:	39 d0                	cmp    %edx,%eax
     ad0:	7f ee                	jg     ac0 <pipe1+0x70>
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
      cc = cc * 2;
     ad2:	01 f6                	add    %esi,%esi
      if(cc > sizeof(buf))
     ad4:	81 fe 00 08 00 00    	cmp    $0x800,%esi
     ada:	76 05                	jbe    ae1 <pipe1+0x91>
     adc:	be 00 08 00 00       	mov    $0x800,%esi
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
     ae1:	01 c7                	add    %eax,%edi
     ae3:	eb b5                	jmp    a9a <pipe1+0x4a>
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
     ae5:	c7 44 24 04 a2 3b 00 	movl   $0x3ba2,0x4(%esp)
     aec:	00 
     aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     af4:	e8 47 2a 00 00       	call   3540 <printf>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
}
     af9:	83 c4 2c             	add    $0x2c,%esp
     afc:	5b                   	pop    %ebx
     afd:	5e                   	pop    %esi
     afe:	5f                   	pop    %edi
     aff:	5d                   	pop    %ebp
     b00:	c3                   	ret    
    exit();
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
     b01:	8b 45 e0             	mov    -0x20(%ebp),%eax
     b04:	31 db                	xor    %ebx,%ebx
     b06:	89 04 24             	mov    %eax,(%esp)
     b09:	e8 12 29 00 00       	call   3420 <close>
    for(n = 0; n < 5; n++){
     b0e:	31 c0                	xor    %eax,%eax
      for(i = 0; i < 1033; i++)
        buf[i] = seq++;
     b10:	8d 14 18             	lea    (%eax,%ebx,1),%edx
     b13:	88 90 c0 75 00 00    	mov    %dl,0x75c0(%eax)
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     b19:	83 c0 01             	add    $0x1,%eax
     b1c:	3d 09 04 00 00       	cmp    $0x409,%eax
     b21:	75 ed                	jne    b10 <pipe1+0xc0>
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     b23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     b26:	81 c3 09 04 00 00    	add    $0x409,%ebx
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     b2c:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     b33:	00 
     b34:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
     b3b:	00 
     b3c:	89 04 24             	mov    %eax,(%esp)
     b3f:	e8 d4 28 00 00       	call   3418 <write>
     b44:	3d 09 04 00 00       	cmp    $0x409,%eax
     b49:	75 5b                	jne    ba6 <pipe1+0x156>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
     b4b:	81 fb 2d 14 00 00    	cmp    $0x142d,%ebx
     b51:	75 bb                	jne    b0e <pipe1+0xbe>
     b53:	90                   	nop
     b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      printf(1, "pipe1 oops 3 total %d\n", total);
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
    exit();
     b58:	e8 9b 28 00 00       	call   33f8 <exit>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033)
     b5d:	81 ff 2d 14 00 00    	cmp    $0x142d,%edi
     b63:	74 18                	je     b7d <pipe1+0x12d>
      printf(1, "pipe1 oops 3 total %d\n", total);
     b65:	89 7c 24 08          	mov    %edi,0x8(%esp)
     b69:	c7 44 24 04 b0 3b 00 	movl   $0x3bb0,0x4(%esp)
     b70:	00 
     b71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b78:	e8 c3 29 00 00       	call   3540 <printf>
    close(fds[0]);
     b7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
     b80:	89 04 24             	mov    %eax,(%esp)
     b83:	e8 98 28 00 00       	call   3420 <close>
    wait();
     b88:	e8 73 28 00 00       	call   3400 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
     b8d:	c7 44 24 04 c7 3b 00 	movl   $0x3bc7,0x4(%esp)
     b94:	00 
     b95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b9c:	e8 9f 29 00 00       	call   3540 <printf>
     ba1:	e9 53 ff ff ff       	jmp    af9 <pipe1+0xa9>
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
     ba6:	c7 44 24 04 94 3b 00 	movl   $0x3b94,0x4(%esp)
     bad:	00 
     bae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     bb5:	e8 86 29 00 00       	call   3540 <printf>
        exit();
     bba:	e8 39 28 00 00       	call   33f8 <exit>
{
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
     bbf:	c7 44 24 04 0d 3b 00 	movl   $0x3b0d,0x4(%esp)
     bc6:	00 
     bc7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     bce:	e8 6d 29 00 00       	call   3540 <printf>
    exit();
     bd3:	e8 20 28 00 00       	call   33f8 <exit>
    if(total != 5 * 1033)
      printf(1, "pipe1 oops 3 total %d\n", total);
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
     bd8:	c7 44 24 04 d1 3b 00 	movl   $0x3bd1,0x4(%esp)
     bdf:	00 
     be0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     be7:	e8 54 29 00 00       	call   3540 <printf>
     bec:	e9 62 ff ff ff       	jmp    b53 <pipe1+0x103>
     bf1:	eb 0d                	jmp    c00 <fourteen>
     bf3:	90                   	nop
     bf4:	90                   	nop
     bf5:	90                   	nop
     bf6:	90                   	nop
     bf7:	90                   	nop
     bf8:	90                   	nop
     bf9:	90                   	nop
     bfa:	90                   	nop
     bfb:	90                   	nop
     bfc:	90                   	nop
     bfd:	90                   	nop
     bfe:	90                   	nop
     bff:	90                   	nop

00000c00 <fourteen>:
  printf(1, "bigfile test ok\n");
}

void
fourteen(void)
{
     c00:	55                   	push   %ebp
     c01:	89 e5                	mov    %esp,%ebp
     c03:	83 ec 18             	sub    $0x18,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
     c06:	c7 44 24 04 e0 3b 00 	movl   $0x3be0,0x4(%esp)
     c0d:	00 
     c0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c15:	e8 26 29 00 00       	call   3540 <printf>

  if(mkdir("12345678901234") != 0){
     c1a:	c7 04 24 1b 3c 00 00 	movl   $0x3c1b,(%esp)
     c21:	e8 3a 28 00 00       	call   3460 <mkdir>
     c26:	85 c0                	test   %eax,%eax
     c28:	0f 85 92 00 00 00    	jne    cc0 <fourteen+0xc0>
    printf(1, "mkdir 12345678901234 failed\n");
    exit();
  }
  if(mkdir("12345678901234/123456789012345") != 0){
     c2e:	c7 04 24 00 49 00 00 	movl   $0x4900,(%esp)
     c35:	e8 26 28 00 00       	call   3460 <mkdir>
     c3a:	85 c0                	test   %eax,%eax
     c3c:	0f 85 fb 00 00 00    	jne    d3d <fourteen+0x13d>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    exit();
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
     c42:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
     c49:	00 
     c4a:	c7 04 24 50 49 00 00 	movl   $0x4950,(%esp)
     c51:	e8 e2 27 00 00       	call   3438 <open>
  if(fd < 0){
     c56:	85 c0                	test   %eax,%eax
     c58:	0f 88 c6 00 00 00    	js     d24 <fourteen+0x124>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    exit();
  }
  close(fd);
     c5e:	89 04 24             	mov    %eax,(%esp)
     c61:	e8 ba 27 00 00       	call   3420 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
     c66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     c6d:	00 
     c6e:	c7 04 24 c0 49 00 00 	movl   $0x49c0,(%esp)
     c75:	e8 be 27 00 00       	call   3438 <open>
  if(fd < 0){
     c7a:	85 c0                	test   %eax,%eax
     c7c:	0f 88 89 00 00 00    	js     d0b <fourteen+0x10b>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    exit();
  }
  close(fd);
     c82:	89 04 24             	mov    %eax,(%esp)
     c85:	e8 96 27 00 00       	call   3420 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
     c8a:	c7 04 24 0c 3c 00 00 	movl   $0x3c0c,(%esp)
     c91:	e8 ca 27 00 00       	call   3460 <mkdir>
     c96:	85 c0                	test   %eax,%eax
     c98:	74 58                	je     cf2 <fourteen+0xf2>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    exit();
  }
  if(mkdir("123456789012345/12345678901234") == 0){
     c9a:	c7 04 24 5c 4a 00 00 	movl   $0x4a5c,(%esp)
     ca1:	e8 ba 27 00 00       	call   3460 <mkdir>
     ca6:	85 c0                	test   %eax,%eax
     ca8:	74 2f                	je     cd9 <fourteen+0xd9>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    exit();
  }

  printf(1, "fourteen ok\n");
     caa:	c7 44 24 04 2a 3c 00 	movl   $0x3c2a,0x4(%esp)
     cb1:	00 
     cb2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cb9:	e8 82 28 00 00       	call   3540 <printf>
}
     cbe:	c9                   	leave  
     cbf:	c3                   	ret    

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");

  if(mkdir("12345678901234") != 0){
    printf(1, "mkdir 12345678901234 failed\n");
     cc0:	c7 44 24 04 ef 3b 00 	movl   $0x3bef,0x4(%esp)
     cc7:	00 
     cc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ccf:	e8 6c 28 00 00       	call   3540 <printf>
    exit();
     cd4:	e8 1f 27 00 00       	call   33f8 <exit>
  if(mkdir("12345678901234/12345678901234") == 0){
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    exit();
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
     cd9:	c7 44 24 04 7c 4a 00 	movl   $0x4a7c,0x4(%esp)
     ce0:	00 
     ce1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ce8:	e8 53 28 00 00       	call   3540 <printf>
    exit();
     ced:	e8 06 27 00 00       	call   33f8 <exit>
    exit();
  }
  close(fd);

  if(mkdir("12345678901234/12345678901234") == 0){
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
     cf2:	c7 44 24 04 2c 4a 00 	movl   $0x4a2c,0x4(%esp)
     cf9:	00 
     cfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d01:	e8 3a 28 00 00       	call   3540 <printf>
    exit();
     d06:	e8 ed 26 00 00       	call   33f8 <exit>
    exit();
  }
  close(fd);
  fd = open("12345678901234/12345678901234/12345678901234", 0);
  if(fd < 0){
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
     d0b:	c7 44 24 04 f0 49 00 	movl   $0x49f0,0x4(%esp)
     d12:	00 
     d13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d1a:	e8 21 28 00 00       	call   3540 <printf>
    exit();
     d1f:	e8 d4 26 00 00       	call   33f8 <exit>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    exit();
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
  if(fd < 0){
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
     d24:	c7 44 24 04 80 49 00 	movl   $0x4980,0x4(%esp)
     d2b:	00 
     d2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d33:	e8 08 28 00 00       	call   3540 <printf>
    exit();
     d38:	e8 bb 26 00 00       	call   33f8 <exit>
  if(mkdir("12345678901234") != 0){
    printf(1, "mkdir 12345678901234 failed\n");
    exit();
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
     d3d:	c7 44 24 04 20 49 00 	movl   $0x4920,0x4(%esp)
     d44:	00 
     d45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d4c:	e8 ef 27 00 00       	call   3540 <printf>
    exit();
     d51:	e8 a2 26 00 00       	call   33f8 <exit>
     d56:	8d 76 00             	lea    0x0(%esi),%esi
     d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000d60 <iref>:
}

// test that iput() is called at the end of _namei()
void
iref(void)
{
     d60:	55                   	push   %ebp
     d61:	89 e5                	mov    %esp,%ebp
     d63:	53                   	push   %ebx
  int i, fd;

  printf(1, "empty file name\n");
     d64:	31 db                	xor    %ebx,%ebx
}

// test that iput() is called at the end of _namei()
void
iref(void)
{
     d66:	83 ec 14             	sub    $0x14,%esp
  int i, fd;

  printf(1, "empty file name\n");
     d69:	c7 44 24 04 37 3c 00 	movl   $0x3c37,0x4(%esp)
     d70:	00 
     d71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d78:	e8 c3 27 00 00       	call   3540 <printf>
     d7d:	8d 76 00             	lea    0x0(%esi),%esi

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    if(mkdir("irefd") != 0){
     d80:	c7 04 24 48 3c 00 00 	movl   $0x3c48,(%esp)
     d87:	e8 d4 26 00 00       	call   3460 <mkdir>
     d8c:	85 c0                	test   %eax,%eax
     d8e:	0f 85 b2 00 00 00    	jne    e46 <iref+0xe6>
      printf(1, "mkdir irefd failed\n");
      exit();
    }
    if(chdir("irefd") != 0){
     d94:	c7 04 24 48 3c 00 00 	movl   $0x3c48,(%esp)
     d9b:	e8 c8 26 00 00       	call   3468 <chdir>
     da0:	85 c0                	test   %eax,%eax
     da2:	0f 85 b7 00 00 00    	jne    e5f <iref+0xff>
      printf(1, "chdir irefd failed\n");
      exit();
    }

    mkdir("");
     da8:	c7 04 24 03 47 00 00 	movl   $0x4703,(%esp)
     daf:	e8 ac 26 00 00       	call   3460 <mkdir>
    link("README", "");
     db4:	c7 44 24 04 03 47 00 	movl   $0x4703,0x4(%esp)
     dbb:	00 
     dbc:	c7 04 24 76 3c 00 00 	movl   $0x3c76,(%esp)
     dc3:	e8 90 26 00 00       	call   3458 <link>
    fd = open("", O_CREATE);
     dc8:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
     dcf:	00 
     dd0:	c7 04 24 03 47 00 00 	movl   $0x4703,(%esp)
     dd7:	e8 5c 26 00 00       	call   3438 <open>
    if(fd >= 0)
     ddc:	85 c0                	test   %eax,%eax
     dde:	78 08                	js     de8 <iref+0x88>
      close(fd);
     de0:	89 04 24             	mov    %eax,(%esp)
     de3:	e8 38 26 00 00       	call   3420 <close>
    fd = open("xx", O_CREATE);
     de8:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
     def:	00 
     df0:	c7 04 24 48 40 00 00 	movl   $0x4048,(%esp)
     df7:	e8 3c 26 00 00       	call   3438 <open>
    if(fd >= 0)
     dfc:	85 c0                	test   %eax,%eax
     dfe:	78 08                	js     e08 <iref+0xa8>
      close(fd);
     e00:	89 04 24             	mov    %eax,(%esp)
     e03:	e8 18 26 00 00       	call   3420 <close>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
     e08:	83 c3 01             	add    $0x1,%ebx
    if(fd >= 0)
      close(fd);
    fd = open("xx", O_CREATE);
    if(fd >= 0)
      close(fd);
    unlink("xx");
     e0b:	c7 04 24 48 40 00 00 	movl   $0x4048,(%esp)
     e12:	e8 31 26 00 00       	call   3448 <unlink>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
     e17:	83 fb 33             	cmp    $0x33,%ebx
     e1a:	0f 85 60 ff ff ff    	jne    d80 <iref+0x20>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
     e20:	c7 04 24 7d 3c 00 00 	movl   $0x3c7d,(%esp)
     e27:	e8 3c 26 00 00       	call   3468 <chdir>
  printf(1, "empty file name OK\n");
     e2c:	c7 44 24 04 7f 3c 00 	movl   $0x3c7f,0x4(%esp)
     e33:	00 
     e34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e3b:	e8 00 27 00 00       	call   3540 <printf>
}
     e40:	83 c4 14             	add    $0x14,%esp
     e43:	5b                   	pop    %ebx
     e44:	5d                   	pop    %ebp
     e45:	c3                   	ret    
  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    if(mkdir("irefd") != 0){
      printf(1, "mkdir irefd failed\n");
     e46:	c7 44 24 04 4e 3c 00 	movl   $0x3c4e,0x4(%esp)
     e4d:	00 
     e4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e55:	e8 e6 26 00 00       	call   3540 <printf>
      exit();
     e5a:	e8 99 25 00 00       	call   33f8 <exit>
    }
    if(chdir("irefd") != 0){
      printf(1, "chdir irefd failed\n");
     e5f:	c7 44 24 04 62 3c 00 	movl   $0x3c62,0x4(%esp)
     e66:	00 
     e67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e6e:	e8 cd 26 00 00       	call   3540 <printf>
      exit();
     e73:	e8 80 25 00 00       	call   33f8 <exit>
     e78:	90                   	nop
     e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00000e80 <dirfile>:
  printf(1, "rmdot ok\n");
}

void
dirfile(void)
{
     e80:	55                   	push   %ebp
     e81:	89 e5                	mov    %esp,%ebp
     e83:	53                   	push   %ebx
     e84:	83 ec 14             	sub    $0x14,%esp
  int fd;

  printf(1, "dir vs file\n");
     e87:	c7 44 24 04 93 3c 00 	movl   $0x3c93,0x4(%esp)
     e8e:	00 
     e8f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e96:	e8 a5 26 00 00       	call   3540 <printf>

  fd = open("dirfile", O_CREATE);
     e9b:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
     ea2:	00 
     ea3:	c7 04 24 a0 3c 00 00 	movl   $0x3ca0,(%esp)
     eaa:	e8 89 25 00 00       	call   3438 <open>
  if(fd < 0){
     eaf:	85 c0                	test   %eax,%eax
     eb1:	0f 88 4e 01 00 00    	js     1005 <dirfile+0x185>
    printf(1, "create dirfile failed\n");
    exit();
  }
  close(fd);
     eb7:	89 04 24             	mov    %eax,(%esp)
     eba:	e8 61 25 00 00       	call   3420 <close>
  if(chdir("dirfile") == 0){
     ebf:	c7 04 24 a0 3c 00 00 	movl   $0x3ca0,(%esp)
     ec6:	e8 9d 25 00 00       	call   3468 <chdir>
     ecb:	85 c0                	test   %eax,%eax
     ecd:	0f 84 19 01 00 00    	je     fec <dirfile+0x16c>
    printf(1, "chdir dirfile succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", 0);
     ed3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     eda:	00 
     edb:	c7 04 24 d9 3c 00 00 	movl   $0x3cd9,(%esp)
     ee2:	e8 51 25 00 00       	call   3438 <open>
  if(fd >= 0){
     ee7:	85 c0                	test   %eax,%eax
     ee9:	0f 89 e4 00 00 00    	jns    fd3 <dirfile+0x153>
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", O_CREATE);
     eef:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
     ef6:	00 
     ef7:	c7 04 24 d9 3c 00 00 	movl   $0x3cd9,(%esp)
     efe:	e8 35 25 00 00       	call   3438 <open>
  if(fd >= 0){
     f03:	85 c0                	test   %eax,%eax
     f05:	0f 89 c8 00 00 00    	jns    fd3 <dirfile+0x153>
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  if(mkdir("dirfile/xx") == 0){
     f0b:	c7 04 24 d9 3c 00 00 	movl   $0x3cd9,(%esp)
     f12:	e8 49 25 00 00       	call   3460 <mkdir>
     f17:	85 c0                	test   %eax,%eax
     f19:	0f 84 7c 01 00 00    	je     109b <dirfile+0x21b>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile/xx") == 0){
     f1f:	c7 04 24 d9 3c 00 00 	movl   $0x3cd9,(%esp)
     f26:	e8 1d 25 00 00       	call   3448 <unlink>
     f2b:	85 c0                	test   %eax,%eax
     f2d:	0f 84 4f 01 00 00    	je     1082 <dirfile+0x202>
    printf(1, "unlink dirfile/xx succeeded!\n");
    exit();
  }
  if(link("README", "dirfile/xx") == 0){
     f33:	c7 44 24 04 d9 3c 00 	movl   $0x3cd9,0x4(%esp)
     f3a:	00 
     f3b:	c7 04 24 76 3c 00 00 	movl   $0x3c76,(%esp)
     f42:	e8 11 25 00 00       	call   3458 <link>
     f47:	85 c0                	test   %eax,%eax
     f49:	0f 84 1a 01 00 00    	je     1069 <dirfile+0x1e9>
    printf(1, "link to dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile") != 0){
     f4f:	c7 04 24 a0 3c 00 00 	movl   $0x3ca0,(%esp)
     f56:	e8 ed 24 00 00       	call   3448 <unlink>
     f5b:	85 c0                	test   %eax,%eax
     f5d:	0f 85 ed 00 00 00    	jne    1050 <dirfile+0x1d0>
    printf(1, "unlink dirfile failed!\n");
    exit();
  }

  fd = open(".", O_RDWR);
     f63:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     f6a:	00 
     f6b:	c7 04 24 66 3f 00 00 	movl   $0x3f66,(%esp)
     f72:	e8 c1 24 00 00       	call   3438 <open>
  if(fd >= 0){
     f77:	85 c0                	test   %eax,%eax
     f79:	0f 89 b8 00 00 00    	jns    1037 <dirfile+0x1b7>
    printf(1, "open . for writing succeeded!\n");
    exit();
  }
  fd = open(".", 0);
     f7f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     f86:	00 
     f87:	c7 04 24 66 3f 00 00 	movl   $0x3f66,(%esp)
     f8e:	e8 a5 24 00 00       	call   3438 <open>
  if(write(fd, "x", 1) > 0){
     f93:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     f9a:	00 
     f9b:	c7 44 24 04 49 40 00 	movl   $0x4049,0x4(%esp)
     fa2:	00 
  fd = open(".", O_RDWR);
  if(fd >= 0){
    printf(1, "open . for writing succeeded!\n");
    exit();
  }
  fd = open(".", 0);
     fa3:	89 c3                	mov    %eax,%ebx
  if(write(fd, "x", 1) > 0){
     fa5:	89 04 24             	mov    %eax,(%esp)
     fa8:	e8 6b 24 00 00       	call   3418 <write>
     fad:	85 c0                	test   %eax,%eax
     faf:	7f 6d                	jg     101e <dirfile+0x19e>
    printf(1, "write . succeeded!\n");
    exit();
  }
  close(fd);
     fb1:	89 1c 24             	mov    %ebx,(%esp)
     fb4:	e8 67 24 00 00       	call   3420 <close>

  printf(1, "dir vs file OK\n");
     fb9:	c7 44 24 04 69 3d 00 	movl   $0x3d69,0x4(%esp)
     fc0:	00 
     fc1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fc8:	e8 73 25 00 00       	call   3540 <printf>
}
     fcd:	83 c4 14             	add    $0x14,%esp
     fd0:	5b                   	pop    %ebx
     fd1:	5d                   	pop    %ebp
     fd2:	c3                   	ret    
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", O_CREATE);
  if(fd >= 0){
    printf(1, "create dirfile/xx succeeded!\n");
     fd3:	c7 44 24 04 e4 3c 00 	movl   $0x3ce4,0x4(%esp)
     fda:	00 
     fdb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fe2:	e8 59 25 00 00       	call   3540 <printf>
    exit();
     fe7:	e8 0c 24 00 00       	call   33f8 <exit>
    printf(1, "create dirfile failed\n");
    exit();
  }
  close(fd);
  if(chdir("dirfile") == 0){
    printf(1, "chdir dirfile succeeded!\n");
     fec:	c7 44 24 04 bf 3c 00 	movl   $0x3cbf,0x4(%esp)
     ff3:	00 
     ff4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ffb:	e8 40 25 00 00       	call   3540 <printf>
    exit();
    1000:	e8 f3 23 00 00       	call   33f8 <exit>

  printf(1, "dir vs file\n");

  fd = open("dirfile", O_CREATE);
  if(fd < 0){
    printf(1, "create dirfile failed\n");
    1005:	c7 44 24 04 a8 3c 00 	movl   $0x3ca8,0x4(%esp)
    100c:	00 
    100d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1014:	e8 27 25 00 00       	call   3540 <printf>
    exit();
    1019:	e8 da 23 00 00       	call   33f8 <exit>
    printf(1, "open . for writing succeeded!\n");
    exit();
  }
  fd = open(".", 0);
  if(write(fd, "x", 1) > 0){
    printf(1, "write . succeeded!\n");
    101e:	c7 44 24 04 55 3d 00 	movl   $0x3d55,0x4(%esp)
    1025:	00 
    1026:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    102d:	e8 0e 25 00 00       	call   3540 <printf>
    exit();
    1032:	e8 c1 23 00 00       	call   33f8 <exit>
    exit();
  }

  fd = open(".", O_RDWR);
  if(fd >= 0){
    printf(1, "open . for writing succeeded!\n");
    1037:	c7 44 24 04 d0 4a 00 	movl   $0x4ad0,0x4(%esp)
    103e:	00 
    103f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1046:	e8 f5 24 00 00       	call   3540 <printf>
    exit();
    104b:	e8 a8 23 00 00       	call   33f8 <exit>
  if(link("README", "dirfile/xx") == 0){
    printf(1, "link to dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile") != 0){
    printf(1, "unlink dirfile failed!\n");
    1050:	c7 44 24 04 3d 3d 00 	movl   $0x3d3d,0x4(%esp)
    1057:	00 
    1058:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    105f:	e8 dc 24 00 00       	call   3540 <printf>
    exit();
    1064:	e8 8f 23 00 00       	call   33f8 <exit>
  if(unlink("dirfile/xx") == 0){
    printf(1, "unlink dirfile/xx succeeded!\n");
    exit();
  }
  if(link("README", "dirfile/xx") == 0){
    printf(1, "link to dirfile/xx succeeded!\n");
    1069:	c7 44 24 04 b0 4a 00 	movl   $0x4ab0,0x4(%esp)
    1070:	00 
    1071:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1078:	e8 c3 24 00 00       	call   3540 <printf>
    exit();
    107d:	e8 76 23 00 00       	call   33f8 <exit>
  if(mkdir("dirfile/xx") == 0){
    printf(1, "mkdir dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile/xx") == 0){
    printf(1, "unlink dirfile/xx succeeded!\n");
    1082:	c7 44 24 04 1f 3d 00 	movl   $0x3d1f,0x4(%esp)
    1089:	00 
    108a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1091:	e8 aa 24 00 00       	call   3540 <printf>
    exit();
    1096:	e8 5d 23 00 00       	call   33f8 <exit>
  if(fd >= 0){
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  if(mkdir("dirfile/xx") == 0){
    printf(1, "mkdir dirfile/xx succeeded!\n");
    109b:	c7 44 24 04 02 3d 00 	movl   $0x3d02,0x4(%esp)
    10a2:	00 
    10a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10aa:	e8 91 24 00 00       	call   3540 <printf>
    exit();
    10af:	e8 44 23 00 00       	call   33f8 <exit>
    10b4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    10ba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

000010c0 <rmdot>:
  printf(1, "fourteen ok\n");
}

void
rmdot(void)
{
    10c0:	55                   	push   %ebp
    10c1:	89 e5                	mov    %esp,%ebp
    10c3:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    10c6:	c7 44 24 04 79 3d 00 	movl   $0x3d79,0x4(%esp)
    10cd:	00 
    10ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10d5:	e8 66 24 00 00       	call   3540 <printf>
  if(mkdir("dots") != 0){
    10da:	c7 04 24 85 3d 00 00 	movl   $0x3d85,(%esp)
    10e1:	e8 7a 23 00 00       	call   3460 <mkdir>
    10e6:	85 c0                	test   %eax,%eax
    10e8:	0f 85 9a 00 00 00    	jne    1188 <rmdot+0xc8>
    printf(1, "mkdir dots failed\n");
    exit();
  }
  if(chdir("dots") != 0){
    10ee:	c7 04 24 85 3d 00 00 	movl   $0x3d85,(%esp)
    10f5:	e8 6e 23 00 00       	call   3468 <chdir>
    10fa:	85 c0                	test   %eax,%eax
    10fc:	0f 85 35 01 00 00    	jne    1237 <rmdot+0x177>
    printf(1, "chdir dots failed\n");
    exit();
  }
  if(unlink(".") == 0){
    1102:	c7 04 24 66 3f 00 00 	movl   $0x3f66,(%esp)
    1109:	e8 3a 23 00 00       	call   3448 <unlink>
    110e:	85 c0                	test   %eax,%eax
    1110:	0f 84 08 01 00 00    	je     121e <rmdot+0x15e>
    printf(1, "rm . worked!\n");
    exit();
  }
  if(unlink("..") == 0){
    1116:	c7 04 24 65 3f 00 00 	movl   $0x3f65,(%esp)
    111d:	e8 26 23 00 00       	call   3448 <unlink>
    1122:	85 c0                	test   %eax,%eax
    1124:	0f 84 db 00 00 00    	je     1205 <rmdot+0x145>
    printf(1, "rm .. worked!\n");
    exit();
  }
  if(chdir("/") != 0){
    112a:	c7 04 24 7d 3c 00 00 	movl   $0x3c7d,(%esp)
    1131:	e8 32 23 00 00       	call   3468 <chdir>
    1136:	85 c0                	test   %eax,%eax
    1138:	0f 85 ae 00 00 00    	jne    11ec <rmdot+0x12c>
    printf(1, "chdir / failed\n");
    exit();
  }
  if(unlink("dots/.") == 0){
    113e:	c7 04 24 dd 3d 00 00 	movl   $0x3ddd,(%esp)
    1145:	e8 fe 22 00 00       	call   3448 <unlink>
    114a:	85 c0                	test   %eax,%eax
    114c:	0f 84 81 00 00 00    	je     11d3 <rmdot+0x113>
    printf(1, "unlink dots/. worked!\n");
    exit();
  }
  if(unlink("dots/..") == 0){
    1152:	c7 04 24 fb 3d 00 00 	movl   $0x3dfb,(%esp)
    1159:	e8 ea 22 00 00       	call   3448 <unlink>
    115e:	85 c0                	test   %eax,%eax
    1160:	74 58                	je     11ba <rmdot+0xfa>
    printf(1, "unlink dots/.. worked!\n");
    exit();
  }
  if(unlink("dots") != 0){
    1162:	c7 04 24 85 3d 00 00 	movl   $0x3d85,(%esp)
    1169:	e8 da 22 00 00       	call   3448 <unlink>
    116e:	85 c0                	test   %eax,%eax
    1170:	75 2f                	jne    11a1 <rmdot+0xe1>
    printf(1, "unlink dots failed!\n");
    exit();
  }
  printf(1, "rmdot ok\n");
    1172:	c7 44 24 04 30 3e 00 	movl   $0x3e30,0x4(%esp)
    1179:	00 
    117a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1181:	e8 ba 23 00 00       	call   3540 <printf>
}
    1186:	c9                   	leave  
    1187:	c3                   	ret    
void
rmdot(void)
{
  printf(1, "rmdot test\n");
  if(mkdir("dots") != 0){
    printf(1, "mkdir dots failed\n");
    1188:	c7 44 24 04 8a 3d 00 	movl   $0x3d8a,0x4(%esp)
    118f:	00 
    1190:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1197:	e8 a4 23 00 00       	call   3540 <printf>
    exit();
    119c:	e8 57 22 00 00       	call   33f8 <exit>
  if(unlink("dots/..") == 0){
    printf(1, "unlink dots/.. worked!\n");
    exit();
  }
  if(unlink("dots") != 0){
    printf(1, "unlink dots failed!\n");
    11a1:	c7 44 24 04 1b 3e 00 	movl   $0x3e1b,0x4(%esp)
    11a8:	00 
    11a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11b0:	e8 8b 23 00 00       	call   3540 <printf>
    exit();
    11b5:	e8 3e 22 00 00       	call   33f8 <exit>
  if(unlink("dots/.") == 0){
    printf(1, "unlink dots/. worked!\n");
    exit();
  }
  if(unlink("dots/..") == 0){
    printf(1, "unlink dots/.. worked!\n");
    11ba:	c7 44 24 04 03 3e 00 	movl   $0x3e03,0x4(%esp)
    11c1:	00 
    11c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11c9:	e8 72 23 00 00       	call   3540 <printf>
    exit();
    11ce:	e8 25 22 00 00       	call   33f8 <exit>
  if(chdir("/") != 0){
    printf(1, "chdir / failed\n");
    exit();
  }
  if(unlink("dots/.") == 0){
    printf(1, "unlink dots/. worked!\n");
    11d3:	c7 44 24 04 e4 3d 00 	movl   $0x3de4,0x4(%esp)
    11da:	00 
    11db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11e2:	e8 59 23 00 00       	call   3540 <printf>
    exit();
    11e7:	e8 0c 22 00 00       	call   33f8 <exit>
  if(unlink("..") == 0){
    printf(1, "rm .. worked!\n");
    exit();
  }
  if(chdir("/") != 0){
    printf(1, "chdir / failed\n");
    11ec:	c7 44 24 04 cd 3d 00 	movl   $0x3dcd,0x4(%esp)
    11f3:	00 
    11f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11fb:	e8 40 23 00 00       	call   3540 <printf>
    exit();
    1200:	e8 f3 21 00 00       	call   33f8 <exit>
  if(unlink(".") == 0){
    printf(1, "rm . worked!\n");
    exit();
  }
  if(unlink("..") == 0){
    printf(1, "rm .. worked!\n");
    1205:	c7 44 24 04 be 3d 00 	movl   $0x3dbe,0x4(%esp)
    120c:	00 
    120d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1214:	e8 27 23 00 00       	call   3540 <printf>
    exit();
    1219:	e8 da 21 00 00       	call   33f8 <exit>
  if(chdir("dots") != 0){
    printf(1, "chdir dots failed\n");
    exit();
  }
  if(unlink(".") == 0){
    printf(1, "rm . worked!\n");
    121e:	c7 44 24 04 b0 3d 00 	movl   $0x3db0,0x4(%esp)
    1225:	00 
    1226:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    122d:	e8 0e 23 00 00       	call   3540 <printf>
    exit();
    1232:	e8 c1 21 00 00       	call   33f8 <exit>
  if(mkdir("dots") != 0){
    printf(1, "mkdir dots failed\n");
    exit();
  }
  if(chdir("dots") != 0){
    printf(1, "chdir dots failed\n");
    1237:	c7 44 24 04 9d 3d 00 	movl   $0x3d9d,0x4(%esp)
    123e:	00 
    123f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1246:	e8 f5 22 00 00       	call   3540 <printf>
    exit();
    124b:	e8 a8 21 00 00       	call   33f8 <exit>

00001250 <subdir>:
  printf(1, "bigdir ok\n");
}

void
subdir(void)
{
    1250:	55                   	push   %ebp
    1251:	89 e5                	mov    %esp,%ebp
    1253:	53                   	push   %ebx
    1254:	83 ec 14             	sub    $0x14,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    1257:	c7 44 24 04 3a 3e 00 	movl   $0x3e3a,0x4(%esp)
    125e:	00 
    125f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1266:	e8 d5 22 00 00       	call   3540 <printf>

  unlink("ff");
    126b:	c7 04 24 c3 3e 00 00 	movl   $0x3ec3,(%esp)
    1272:	e8 d1 21 00 00       	call   3448 <unlink>
  if(mkdir("dd") != 0){
    1277:	c7 04 24 60 3f 00 00 	movl   $0x3f60,(%esp)
    127e:	e8 dd 21 00 00       	call   3460 <mkdir>
    1283:	85 c0                	test   %eax,%eax
    1285:	0f 85 07 06 00 00    	jne    1892 <subdir+0x642>
    printf(1, "subdir mkdir dd failed\n");
    exit();
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    128b:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1292:	00 
    1293:	c7 04 24 99 3e 00 00 	movl   $0x3e99,(%esp)
    129a:	e8 99 21 00 00       	call   3438 <open>
  if(fd < 0){
    129f:	85 c0                	test   %eax,%eax
  if(mkdir("dd") != 0){
    printf(1, "subdir mkdir dd failed\n");
    exit();
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    12a1:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    12a3:	0f 88 d0 05 00 00    	js     1879 <subdir+0x629>
    printf(1, "create dd/ff failed\n");
    exit();
  }
  write(fd, "ff", 2);
    12a9:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    12b0:	00 
    12b1:	c7 44 24 04 c3 3e 00 	movl   $0x3ec3,0x4(%esp)
    12b8:	00 
    12b9:	89 04 24             	mov    %eax,(%esp)
    12bc:	e8 57 21 00 00       	call   3418 <write>
  close(fd);
    12c1:	89 1c 24             	mov    %ebx,(%esp)
    12c4:	e8 57 21 00 00       	call   3420 <close>
  
  if(unlink("dd") >= 0){
    12c9:	c7 04 24 60 3f 00 00 	movl   $0x3f60,(%esp)
    12d0:	e8 73 21 00 00       	call   3448 <unlink>
    12d5:	85 c0                	test   %eax,%eax
    12d7:	0f 89 83 05 00 00    	jns    1860 <subdir+0x610>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    exit();
  }

  if(mkdir("/dd/dd") != 0){
    12dd:	c7 04 24 74 3e 00 00 	movl   $0x3e74,(%esp)
    12e4:	e8 77 21 00 00       	call   3460 <mkdir>
    12e9:	85 c0                	test   %eax,%eax
    12eb:	0f 85 56 05 00 00    	jne    1847 <subdir+0x5f7>
    printf(1, "subdir mkdir dd/dd failed\n");
    exit();
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    12f1:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    12f8:	00 
    12f9:	c7 04 24 96 3e 00 00 	movl   $0x3e96,(%esp)
    1300:	e8 33 21 00 00       	call   3438 <open>
  if(fd < 0){
    1305:	85 c0                	test   %eax,%eax
  if(mkdir("/dd/dd") != 0){
    printf(1, "subdir mkdir dd/dd failed\n");
    exit();
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    1307:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1309:	0f 88 25 04 00 00    	js     1734 <subdir+0x4e4>
    printf(1, "create dd/dd/ff failed\n");
    exit();
  }
  write(fd, "FF", 2);
    130f:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1316:	00 
    1317:	c7 44 24 04 b7 3e 00 	movl   $0x3eb7,0x4(%esp)
    131e:	00 
    131f:	89 04 24             	mov    %eax,(%esp)
    1322:	e8 f1 20 00 00       	call   3418 <write>
  close(fd);
    1327:	89 1c 24             	mov    %ebx,(%esp)
    132a:	e8 f1 20 00 00       	call   3420 <close>

  fd = open("dd/dd/../ff", 0);
    132f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1336:	00 
    1337:	c7 04 24 ba 3e 00 00 	movl   $0x3eba,(%esp)
    133e:	e8 f5 20 00 00       	call   3438 <open>
  if(fd < 0){
    1343:	85 c0                	test   %eax,%eax
    exit();
  }
  write(fd, "FF", 2);
  close(fd);

  fd = open("dd/dd/../ff", 0);
    1345:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1347:	0f 88 ce 03 00 00    	js     171b <subdir+0x4cb>
    printf(1, "open dd/dd/../ff failed\n");
    exit();
  }
  cc = read(fd, buf, sizeof(buf));
    134d:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
    1354:	00 
    1355:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    135c:	00 
    135d:	89 04 24             	mov    %eax,(%esp)
    1360:	e8 ab 20 00 00       	call   3410 <read>
  if(cc != 2 || buf[0] != 'f'){
    1365:	83 f8 02             	cmp    $0x2,%eax
    1368:	0f 85 fe 02 00 00    	jne    166c <subdir+0x41c>
    136e:	80 3d c0 75 00 00 66 	cmpb   $0x66,0x75c0
    1375:	0f 85 f1 02 00 00    	jne    166c <subdir+0x41c>
    printf(1, "dd/dd/../ff wrong content\n");
    exit();
  }
  close(fd);
    137b:	89 1c 24             	mov    %ebx,(%esp)
    137e:	e8 9d 20 00 00       	call   3420 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    1383:	c7 44 24 04 fa 3e 00 	movl   $0x3efa,0x4(%esp)
    138a:	00 
    138b:	c7 04 24 96 3e 00 00 	movl   $0x3e96,(%esp)
    1392:	e8 c1 20 00 00       	call   3458 <link>
    1397:	85 c0                	test   %eax,%eax
    1399:	0f 85 c7 03 00 00    	jne    1766 <subdir+0x516>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    exit();
  }

  if(unlink("dd/dd/ff") != 0){
    139f:	c7 04 24 96 3e 00 00 	movl   $0x3e96,(%esp)
    13a6:	e8 9d 20 00 00       	call   3448 <unlink>
    13ab:	85 c0                	test   %eax,%eax
    13ad:	0f 85 eb 02 00 00    	jne    169e <subdir+0x44e>
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    13b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    13ba:	00 
    13bb:	c7 04 24 96 3e 00 00 	movl   $0x3e96,(%esp)
    13c2:	e8 71 20 00 00       	call   3438 <open>
    13c7:	85 c0                	test   %eax,%eax
    13c9:	0f 89 5f 04 00 00    	jns    182e <subdir+0x5de>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    exit();
  }

  if(chdir("dd") != 0){
    13cf:	c7 04 24 60 3f 00 00 	movl   $0x3f60,(%esp)
    13d6:	e8 8d 20 00 00       	call   3468 <chdir>
    13db:	85 c0                	test   %eax,%eax
    13dd:	0f 85 32 04 00 00    	jne    1815 <subdir+0x5c5>
    printf(1, "chdir dd failed\n");
    exit();
  }
  if(chdir("dd/../../dd") != 0){
    13e3:	c7 04 24 2e 3f 00 00 	movl   $0x3f2e,(%esp)
    13ea:	e8 79 20 00 00       	call   3468 <chdir>
    13ef:	85 c0                	test   %eax,%eax
    13f1:	0f 85 8e 02 00 00    	jne    1685 <subdir+0x435>
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("dd/../../../dd") != 0){
    13f7:	c7 04 24 54 3f 00 00 	movl   $0x3f54,(%esp)
    13fe:	e8 65 20 00 00       	call   3468 <chdir>
    1403:	85 c0                	test   %eax,%eax
    1405:	0f 85 7a 02 00 00    	jne    1685 <subdir+0x435>
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("./..") != 0){
    140b:	c7 04 24 63 3f 00 00 	movl   $0x3f63,(%esp)
    1412:	e8 51 20 00 00       	call   3468 <chdir>
    1417:	85 c0                	test   %eax,%eax
    1419:	0f 85 2e 03 00 00    	jne    174d <subdir+0x4fd>
    printf(1, "chdir ./.. failed\n");
    exit();
  }

  fd = open("dd/dd/ffff", 0);
    141f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1426:	00 
    1427:	c7 04 24 fa 3e 00 00 	movl   $0x3efa,(%esp)
    142e:	e8 05 20 00 00       	call   3438 <open>
  if(fd < 0){
    1433:	85 c0                	test   %eax,%eax
  if(chdir("./..") != 0){
    printf(1, "chdir ./.. failed\n");
    exit();
  }

  fd = open("dd/dd/ffff", 0);
    1435:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1437:	0f 88 81 05 00 00    	js     19be <subdir+0x76e>
    printf(1, "open dd/dd/ffff failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    143d:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
    1444:	00 
    1445:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    144c:	00 
    144d:	89 04 24             	mov    %eax,(%esp)
    1450:	e8 bb 1f 00 00       	call   3410 <read>
    1455:	83 f8 02             	cmp    $0x2,%eax
    1458:	0f 85 47 05 00 00    	jne    19a5 <subdir+0x755>
    printf(1, "read dd/dd/ffff wrong len\n");
    exit();
  }
  close(fd);
    145e:	89 1c 24             	mov    %ebx,(%esp)
    1461:	e8 ba 1f 00 00       	call   3420 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1466:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    146d:	00 
    146e:	c7 04 24 96 3e 00 00 	movl   $0x3e96,(%esp)
    1475:	e8 be 1f 00 00       	call   3438 <open>
    147a:	85 c0                	test   %eax,%eax
    147c:	0f 89 4e 02 00 00    	jns    16d0 <subdir+0x480>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    exit();
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    1482:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1489:	00 
    148a:	c7 04 24 ae 3f 00 00 	movl   $0x3fae,(%esp)
    1491:	e8 a2 1f 00 00       	call   3438 <open>
    1496:	85 c0                	test   %eax,%eax
    1498:	0f 89 19 02 00 00    	jns    16b7 <subdir+0x467>
    printf(1, "create dd/ff/ff succeeded!\n");
    exit();
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    149e:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    14a5:	00 
    14a6:	c7 04 24 d3 3f 00 00 	movl   $0x3fd3,(%esp)
    14ad:	e8 86 1f 00 00       	call   3438 <open>
    14b2:	85 c0                	test   %eax,%eax
    14b4:	0f 89 42 03 00 00    	jns    17fc <subdir+0x5ac>
    printf(1, "create dd/xx/ff succeeded!\n");
    exit();
  }
  if(open("dd", O_CREATE) >= 0){
    14ba:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    14c1:	00 
    14c2:	c7 04 24 60 3f 00 00 	movl   $0x3f60,(%esp)
    14c9:	e8 6a 1f 00 00       	call   3438 <open>
    14ce:	85 c0                	test   %eax,%eax
    14d0:	0f 89 0d 03 00 00    	jns    17e3 <subdir+0x593>
    printf(1, "create dd succeeded!\n");
    exit();
  }
  if(open("dd", O_RDWR) >= 0){
    14d6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    14dd:	00 
    14de:	c7 04 24 60 3f 00 00 	movl   $0x3f60,(%esp)
    14e5:	e8 4e 1f 00 00       	call   3438 <open>
    14ea:	85 c0                	test   %eax,%eax
    14ec:	0f 89 d8 02 00 00    	jns    17ca <subdir+0x57a>
    printf(1, "open dd rdwr succeeded!\n");
    exit();
  }
  if(open("dd", O_WRONLY) >= 0){
    14f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    14f9:	00 
    14fa:	c7 04 24 60 3f 00 00 	movl   $0x3f60,(%esp)
    1501:	e8 32 1f 00 00       	call   3438 <open>
    1506:	85 c0                	test   %eax,%eax
    1508:	0f 89 a3 02 00 00    	jns    17b1 <subdir+0x561>
    printf(1, "open dd wronly succeeded!\n");
    exit();
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    150e:	c7 44 24 04 42 40 00 	movl   $0x4042,0x4(%esp)
    1515:	00 
    1516:	c7 04 24 ae 3f 00 00 	movl   $0x3fae,(%esp)
    151d:	e8 36 1f 00 00       	call   3458 <link>
    1522:	85 c0                	test   %eax,%eax
    1524:	0f 84 6e 02 00 00    	je     1798 <subdir+0x548>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    152a:	c7 44 24 04 42 40 00 	movl   $0x4042,0x4(%esp)
    1531:	00 
    1532:	c7 04 24 d3 3f 00 00 	movl   $0x3fd3,(%esp)
    1539:	e8 1a 1f 00 00       	call   3458 <link>
    153e:	85 c0                	test   %eax,%eax
    1540:	0f 84 39 02 00 00    	je     177f <subdir+0x52f>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    1546:	c7 44 24 04 fa 3e 00 	movl   $0x3efa,0x4(%esp)
    154d:	00 
    154e:	c7 04 24 99 3e 00 00 	movl   $0x3e99,(%esp)
    1555:	e8 fe 1e 00 00       	call   3458 <link>
    155a:	85 c0                	test   %eax,%eax
    155c:	0f 84 a0 01 00 00    	je     1702 <subdir+0x4b2>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    exit();
  }
  if(mkdir("dd/ff/ff") == 0){
    1562:	c7 04 24 ae 3f 00 00 	movl   $0x3fae,(%esp)
    1569:	e8 f2 1e 00 00       	call   3460 <mkdir>
    156e:	85 c0                	test   %eax,%eax
    1570:	0f 84 73 01 00 00    	je     16e9 <subdir+0x499>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/xx/ff") == 0){
    1576:	c7 04 24 d3 3f 00 00 	movl   $0x3fd3,(%esp)
    157d:	e8 de 1e 00 00       	call   3460 <mkdir>
    1582:	85 c0                	test   %eax,%eax
    1584:	0f 84 02 04 00 00    	je     198c <subdir+0x73c>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/dd/ffff") == 0){
    158a:	c7 04 24 fa 3e 00 00 	movl   $0x3efa,(%esp)
    1591:	e8 ca 1e 00 00       	call   3460 <mkdir>
    1596:	85 c0                	test   %eax,%eax
    1598:	0f 84 d5 03 00 00    	je     1973 <subdir+0x723>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    exit();
  }
  if(unlink("dd/xx/ff") == 0){
    159e:	c7 04 24 d3 3f 00 00 	movl   $0x3fd3,(%esp)
    15a5:	e8 9e 1e 00 00       	call   3448 <unlink>
    15aa:	85 c0                	test   %eax,%eax
    15ac:	0f 84 a8 03 00 00    	je     195a <subdir+0x70a>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    exit();
  }
  if(unlink("dd/ff/ff") == 0){
    15b2:	c7 04 24 ae 3f 00 00 	movl   $0x3fae,(%esp)
    15b9:	e8 8a 1e 00 00       	call   3448 <unlink>
    15be:	85 c0                	test   %eax,%eax
    15c0:	0f 84 7b 03 00 00    	je     1941 <subdir+0x6f1>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/ff") == 0){
    15c6:	c7 04 24 99 3e 00 00 	movl   $0x3e99,(%esp)
    15cd:	e8 96 1e 00 00       	call   3468 <chdir>
    15d2:	85 c0                	test   %eax,%eax
    15d4:	0f 84 4e 03 00 00    	je     1928 <subdir+0x6d8>
    printf(1, "chdir dd/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/xx") == 0){
    15da:	c7 04 24 45 40 00 00 	movl   $0x4045,(%esp)
    15e1:	e8 82 1e 00 00       	call   3468 <chdir>
    15e6:	85 c0                	test   %eax,%eax
    15e8:	0f 84 21 03 00 00    	je     190f <subdir+0x6bf>
    printf(1, "chdir dd/xx succeeded!\n");
    exit();
  }

  if(unlink("dd/dd/ffff") != 0){
    15ee:	c7 04 24 fa 3e 00 00 	movl   $0x3efa,(%esp)
    15f5:	e8 4e 1e 00 00       	call   3448 <unlink>
    15fa:	85 c0                	test   %eax,%eax
    15fc:	0f 85 9c 00 00 00    	jne    169e <subdir+0x44e>
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(unlink("dd/ff") != 0){
    1602:	c7 04 24 99 3e 00 00 	movl   $0x3e99,(%esp)
    1609:	e8 3a 1e 00 00       	call   3448 <unlink>
    160e:	85 c0                	test   %eax,%eax
    1610:	0f 85 e0 02 00 00    	jne    18f6 <subdir+0x6a6>
    printf(1, "unlink dd/ff failed\n");
    exit();
  }
  if(unlink("dd") == 0){
    1616:	c7 04 24 60 3f 00 00 	movl   $0x3f60,(%esp)
    161d:	e8 26 1e 00 00       	call   3448 <unlink>
    1622:	85 c0                	test   %eax,%eax
    1624:	0f 84 b3 02 00 00    	je     18dd <subdir+0x68d>
    printf(1, "unlink non-empty dd succeeded!\n");
    exit();
  }
  if(unlink("dd/dd") < 0){
    162a:	c7 04 24 75 3e 00 00 	movl   $0x3e75,(%esp)
    1631:	e8 12 1e 00 00       	call   3448 <unlink>
    1636:	85 c0                	test   %eax,%eax
    1638:	0f 88 86 02 00 00    	js     18c4 <subdir+0x674>
    printf(1, "unlink dd/dd failed\n");
    exit();
  }
  if(unlink("dd") < 0){
    163e:	c7 04 24 60 3f 00 00 	movl   $0x3f60,(%esp)
    1645:	e8 fe 1d 00 00       	call   3448 <unlink>
    164a:	85 c0                	test   %eax,%eax
    164c:	0f 88 59 02 00 00    	js     18ab <subdir+0x65b>
    printf(1, "unlink dd failed\n");
    exit();
  }

  printf(1, "subdir ok\n");
    1652:	c7 44 24 04 42 41 00 	movl   $0x4142,0x4(%esp)
    1659:	00 
    165a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1661:	e8 da 1e 00 00       	call   3540 <printf>
}
    1666:	83 c4 14             	add    $0x14,%esp
    1669:	5b                   	pop    %ebx
    166a:	5d                   	pop    %ebp
    166b:	c3                   	ret    
    printf(1, "open dd/dd/../ff failed\n");
    exit();
  }
  cc = read(fd, buf, sizeof(buf));
  if(cc != 2 || buf[0] != 'f'){
    printf(1, "dd/dd/../ff wrong content\n");
    166c:	c7 44 24 04 df 3e 00 	movl   $0x3edf,0x4(%esp)
    1673:	00 
    1674:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    167b:	e8 c0 1e 00 00       	call   3540 <printf>
    exit();
    1680:	e8 73 1d 00 00       	call   33f8 <exit>
  if(chdir("dd/../../dd") != 0){
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("dd/../../../dd") != 0){
    printf(1, "chdir dd/../../dd failed\n");
    1685:	c7 44 24 04 3a 3f 00 	movl   $0x3f3a,0x4(%esp)
    168c:	00 
    168d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1694:	e8 a7 1e 00 00       	call   3540 <printf>
    exit();
    1699:	e8 5a 1d 00 00       	call   33f8 <exit>
    printf(1, "chdir dd/xx succeeded!\n");
    exit();
  }

  if(unlink("dd/dd/ffff") != 0){
    printf(1, "unlink dd/dd/ff failed\n");
    169e:	c7 44 24 04 05 3f 00 	movl   $0x3f05,0x4(%esp)
    16a5:	00 
    16a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16ad:	e8 8e 1e 00 00       	call   3540 <printf>
    exit();
    16b2:	e8 41 1d 00 00       	call   33f8 <exit>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    exit();
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    printf(1, "create dd/ff/ff succeeded!\n");
    16b7:	c7 44 24 04 b7 3f 00 	movl   $0x3fb7,0x4(%esp)
    16be:	00 
    16bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16c6:	e8 75 1e 00 00       	call   3540 <printf>
    exit();
    16cb:	e8 28 1d 00 00       	call   33f8 <exit>
    exit();
  }
  close(fd);

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    16d0:	c7 44 24 04 60 4b 00 	movl   $0x4b60,0x4(%esp)
    16d7:	00 
    16d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16df:	e8 5c 1e 00 00       	call   3540 <printf>
    exit();
    16e4:	e8 0f 1d 00 00       	call   33f8 <exit>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    exit();
  }
  if(mkdir("dd/ff/ff") == 0){
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    16e9:	c7 44 24 04 4b 40 00 	movl   $0x404b,0x4(%esp)
    16f0:	00 
    16f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16f8:	e8 43 1e 00 00       	call   3540 <printf>
    exit();
    16fd:	e8 f6 1c 00 00       	call   33f8 <exit>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    1702:	c7 44 24 04 d0 4b 00 	movl   $0x4bd0,0x4(%esp)
    1709:	00 
    170a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1711:	e8 2a 1e 00 00       	call   3540 <printf>
    exit();
    1716:	e8 dd 1c 00 00       	call   33f8 <exit>
  write(fd, "FF", 2);
  close(fd);

  fd = open("dd/dd/../ff", 0);
  if(fd < 0){
    printf(1, "open dd/dd/../ff failed\n");
    171b:	c7 44 24 04 c6 3e 00 	movl   $0x3ec6,0x4(%esp)
    1722:	00 
    1723:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    172a:	e8 11 1e 00 00       	call   3540 <printf>
    exit();
    172f:	e8 c4 1c 00 00       	call   33f8 <exit>
    exit();
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "create dd/dd/ff failed\n");
    1734:	c7 44 24 04 9f 3e 00 	movl   $0x3e9f,0x4(%esp)
    173b:	00 
    173c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1743:	e8 f8 1d 00 00       	call   3540 <printf>
    exit();
    1748:	e8 ab 1c 00 00       	call   33f8 <exit>
  if(chdir("dd/../../../dd") != 0){
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("./..") != 0){
    printf(1, "chdir ./.. failed\n");
    174d:	c7 44 24 04 68 3f 00 	movl   $0x3f68,0x4(%esp)
    1754:	00 
    1755:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    175c:	e8 df 1d 00 00       	call   3540 <printf>
    exit();
    1761:	e8 92 1c 00 00       	call   33f8 <exit>
    exit();
  }
  close(fd);

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    1766:	c7 44 24 04 18 4b 00 	movl   $0x4b18,0x4(%esp)
    176d:	00 
    176e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1775:	e8 c6 1d 00 00       	call   3540 <printf>
    exit();
    177a:	e8 79 1c 00 00       	call   33f8 <exit>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    177f:	c7 44 24 04 ac 4b 00 	movl   $0x4bac,0x4(%esp)
    1786:	00 
    1787:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    178e:	e8 ad 1d 00 00       	call   3540 <printf>
    exit();
    1793:	e8 60 1c 00 00       	call   33f8 <exit>
  if(open("dd", O_WRONLY) >= 0){
    printf(1, "open dd wronly succeeded!\n");
    exit();
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    1798:	c7 44 24 04 88 4b 00 	movl   $0x4b88,0x4(%esp)
    179f:	00 
    17a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17a7:	e8 94 1d 00 00       	call   3540 <printf>
    exit();
    17ac:	e8 47 1c 00 00       	call   33f8 <exit>
  if(open("dd", O_RDWR) >= 0){
    printf(1, "open dd rdwr succeeded!\n");
    exit();
  }
  if(open("dd", O_WRONLY) >= 0){
    printf(1, "open dd wronly succeeded!\n");
    17b1:	c7 44 24 04 27 40 00 	movl   $0x4027,0x4(%esp)
    17b8:	00 
    17b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17c0:	e8 7b 1d 00 00       	call   3540 <printf>
    exit();
    17c5:	e8 2e 1c 00 00       	call   33f8 <exit>
  if(open("dd", O_CREATE) >= 0){
    printf(1, "create dd succeeded!\n");
    exit();
  }
  if(open("dd", O_RDWR) >= 0){
    printf(1, "open dd rdwr succeeded!\n");
    17ca:	c7 44 24 04 0e 40 00 	movl   $0x400e,0x4(%esp)
    17d1:	00 
    17d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17d9:	e8 62 1d 00 00       	call   3540 <printf>
    exit();
    17de:	e8 15 1c 00 00       	call   33f8 <exit>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    printf(1, "create dd/xx/ff succeeded!\n");
    exit();
  }
  if(open("dd", O_CREATE) >= 0){
    printf(1, "create dd succeeded!\n");
    17e3:	c7 44 24 04 f8 3f 00 	movl   $0x3ff8,0x4(%esp)
    17ea:	00 
    17eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17f2:	e8 49 1d 00 00       	call   3540 <printf>
    exit();
    17f7:	e8 fc 1b 00 00       	call   33f8 <exit>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    printf(1, "create dd/ff/ff succeeded!\n");
    exit();
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    printf(1, "create dd/xx/ff succeeded!\n");
    17fc:	c7 44 24 04 dc 3f 00 	movl   $0x3fdc,0x4(%esp)
    1803:	00 
    1804:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    180b:	e8 30 1d 00 00       	call   3540 <printf>
    exit();
    1810:	e8 e3 1b 00 00       	call   33f8 <exit>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    exit();
  }

  if(chdir("dd") != 0){
    printf(1, "chdir dd failed\n");
    1815:	c7 44 24 04 1d 3f 00 	movl   $0x3f1d,0x4(%esp)
    181c:	00 
    181d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1824:	e8 17 1d 00 00       	call   3540 <printf>
    exit();
    1829:	e8 ca 1b 00 00       	call   33f8 <exit>
  if(unlink("dd/dd/ff") != 0){
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    182e:	c7 44 24 04 3c 4b 00 	movl   $0x4b3c,0x4(%esp)
    1835:	00 
    1836:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    183d:	e8 fe 1c 00 00       	call   3540 <printf>
    exit();
    1842:	e8 b1 1b 00 00       	call   33f8 <exit>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    exit();
  }

  if(mkdir("/dd/dd") != 0){
    printf(1, "subdir mkdir dd/dd failed\n");
    1847:	c7 44 24 04 7b 3e 00 	movl   $0x3e7b,0x4(%esp)
    184e:	00 
    184f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1856:	e8 e5 1c 00 00       	call   3540 <printf>
    exit();
    185b:	e8 98 1b 00 00       	call   33f8 <exit>
  }
  write(fd, "ff", 2);
  close(fd);
  
  if(unlink("dd") >= 0){
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    1860:	c7 44 24 04 f0 4a 00 	movl   $0x4af0,0x4(%esp)
    1867:	00 
    1868:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    186f:	e8 cc 1c 00 00       	call   3540 <printf>
    exit();
    1874:	e8 7f 1b 00 00       	call   33f8 <exit>
    exit();
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "create dd/ff failed\n");
    1879:	c7 44 24 04 5f 3e 00 	movl   $0x3e5f,0x4(%esp)
    1880:	00 
    1881:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1888:	e8 b3 1c 00 00       	call   3540 <printf>
    exit();
    188d:	e8 66 1b 00 00       	call   33f8 <exit>

  printf(1, "subdir test\n");

  unlink("ff");
  if(mkdir("dd") != 0){
    printf(1, "subdir mkdir dd failed\n");
    1892:	c7 44 24 04 47 3e 00 	movl   $0x3e47,0x4(%esp)
    1899:	00 
    189a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18a1:	e8 9a 1c 00 00       	call   3540 <printf>
    exit();
    18a6:	e8 4d 1b 00 00       	call   33f8 <exit>
  if(unlink("dd/dd") < 0){
    printf(1, "unlink dd/dd failed\n");
    exit();
  }
  if(unlink("dd") < 0){
    printf(1, "unlink dd failed\n");
    18ab:	c7 44 24 04 30 41 00 	movl   $0x4130,0x4(%esp)
    18b2:	00 
    18b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18ba:	e8 81 1c 00 00       	call   3540 <printf>
    exit();
    18bf:	e8 34 1b 00 00       	call   33f8 <exit>
  if(unlink("dd") == 0){
    printf(1, "unlink non-empty dd succeeded!\n");
    exit();
  }
  if(unlink("dd/dd") < 0){
    printf(1, "unlink dd/dd failed\n");
    18c4:	c7 44 24 04 1b 41 00 	movl   $0x411b,0x4(%esp)
    18cb:	00 
    18cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18d3:	e8 68 1c 00 00       	call   3540 <printf>
    exit();
    18d8:	e8 1b 1b 00 00       	call   33f8 <exit>
  if(unlink("dd/ff") != 0){
    printf(1, "unlink dd/ff failed\n");
    exit();
  }
  if(unlink("dd") == 0){
    printf(1, "unlink non-empty dd succeeded!\n");
    18dd:	c7 44 24 04 f4 4b 00 	movl   $0x4bf4,0x4(%esp)
    18e4:	00 
    18e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18ec:	e8 4f 1c 00 00       	call   3540 <printf>
    exit();
    18f1:	e8 02 1b 00 00       	call   33f8 <exit>
  if(unlink("dd/dd/ffff") != 0){
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(unlink("dd/ff") != 0){
    printf(1, "unlink dd/ff failed\n");
    18f6:	c7 44 24 04 06 41 00 	movl   $0x4106,0x4(%esp)
    18fd:	00 
    18fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1905:	e8 36 1c 00 00       	call   3540 <printf>
    exit();
    190a:	e8 e9 1a 00 00       	call   33f8 <exit>
  if(chdir("dd/ff") == 0){
    printf(1, "chdir dd/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/xx") == 0){
    printf(1, "chdir dd/xx succeeded!\n");
    190f:	c7 44 24 04 ee 40 00 	movl   $0x40ee,0x4(%esp)
    1916:	00 
    1917:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    191e:	e8 1d 1c 00 00       	call   3540 <printf>
    exit();
    1923:	e8 d0 1a 00 00       	call   33f8 <exit>
  if(unlink("dd/ff/ff") == 0){
    printf(1, "unlink dd/ff/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/ff") == 0){
    printf(1, "chdir dd/ff succeeded!\n");
    1928:	c7 44 24 04 d6 40 00 	movl   $0x40d6,0x4(%esp)
    192f:	00 
    1930:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1937:	e8 04 1c 00 00       	call   3540 <printf>
    exit();
    193c:	e8 b7 1a 00 00       	call   33f8 <exit>
  if(unlink("dd/xx/ff") == 0){
    printf(1, "unlink dd/xx/ff succeeded!\n");
    exit();
  }
  if(unlink("dd/ff/ff") == 0){
    printf(1, "unlink dd/ff/ff succeeded!\n");
    1941:	c7 44 24 04 ba 40 00 	movl   $0x40ba,0x4(%esp)
    1948:	00 
    1949:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1950:	e8 eb 1b 00 00       	call   3540 <printf>
    exit();
    1955:	e8 9e 1a 00 00       	call   33f8 <exit>
  if(mkdir("dd/dd/ffff") == 0){
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    exit();
  }
  if(unlink("dd/xx/ff") == 0){
    printf(1, "unlink dd/xx/ff succeeded!\n");
    195a:	c7 44 24 04 9e 40 00 	movl   $0x409e,0x4(%esp)
    1961:	00 
    1962:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1969:	e8 d2 1b 00 00       	call   3540 <printf>
    exit();
    196e:	e8 85 1a 00 00       	call   33f8 <exit>
  if(mkdir("dd/xx/ff") == 0){
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/dd/ffff") == 0){
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    1973:	c7 44 24 04 81 40 00 	movl   $0x4081,0x4(%esp)
    197a:	00 
    197b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1982:	e8 b9 1b 00 00       	call   3540 <printf>
    exit();
    1987:	e8 6c 1a 00 00       	call   33f8 <exit>
  if(mkdir("dd/ff/ff") == 0){
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/xx/ff") == 0){
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    198c:	c7 44 24 04 66 40 00 	movl   $0x4066,0x4(%esp)
    1993:	00 
    1994:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    199b:	e8 a0 1b 00 00       	call   3540 <printf>
    exit();
    19a0:	e8 53 1a 00 00       	call   33f8 <exit>
  if(fd < 0){
    printf(1, "open dd/dd/ffff failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    printf(1, "read dd/dd/ffff wrong len\n");
    19a5:	c7 44 24 04 93 3f 00 	movl   $0x3f93,0x4(%esp)
    19ac:	00 
    19ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19b4:	e8 87 1b 00 00       	call   3540 <printf>
    exit();
    19b9:	e8 3a 1a 00 00       	call   33f8 <exit>
    exit();
  }

  fd = open("dd/dd/ffff", 0);
  if(fd < 0){
    printf(1, "open dd/dd/ffff failed\n");
    19be:	c7 44 24 04 7b 3f 00 	movl   $0x3f7b,0x4(%esp)
    19c5:	00 
    19c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19cd:	e8 6e 1b 00 00       	call   3540 <printf>
    exit();
    19d2:	e8 21 1a 00 00       	call   33f8 <exit>
    19d7:	89 f6                	mov    %esi,%esi
    19d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000019e0 <bigdir>:
}

// directory that uses indirect blocks
void
bigdir(void)
{
    19e0:	55                   	push   %ebp
    19e1:	89 e5                	mov    %esp,%ebp
    19e3:	56                   	push   %esi
    19e4:	53                   	push   %ebx
    19e5:	83 ec 20             	sub    $0x20,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    19e8:	c7 44 24 04 4d 41 00 	movl   $0x414d,0x4(%esp)
    19ef:	00 
    19f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19f7:	e8 44 1b 00 00       	call   3540 <printf>
  unlink("bd");
    19fc:	c7 04 24 5a 41 00 00 	movl   $0x415a,(%esp)
    1a03:	e8 40 1a 00 00       	call   3448 <unlink>

  fd = open("bd", O_CREATE);
    1a08:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    1a0f:	00 
    1a10:	c7 04 24 5a 41 00 00 	movl   $0x415a,(%esp)
    1a17:	e8 1c 1a 00 00       	call   3438 <open>
  if(fd < 0){
    1a1c:	85 c0                	test   %eax,%eax
    1a1e:	0f 88 e6 00 00 00    	js     1b0a <bigdir+0x12a>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);
    1a24:	89 04 24             	mov    %eax,(%esp)
    1a27:	31 db                	xor    %ebx,%ebx
    1a29:	e8 f2 19 00 00       	call   3420 <close>
    1a2e:	8d 75 ee             	lea    -0x12(%ebp),%esi
    1a31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

  for(i = 0; i < 500; i++){
    name[0] = 'x';
    name[1] = '0' + (i / 64);
    1a38:	89 d8                	mov    %ebx,%eax
    1a3a:	c1 f8 06             	sar    $0x6,%eax
    1a3d:	83 c0 30             	add    $0x30,%eax
    1a40:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1a43:	89 d8                	mov    %ebx,%eax
    1a45:	83 e0 3f             	and    $0x3f,%eax
    1a48:	83 c0 30             	add    $0x30,%eax
    exit();
  }
  close(fd);

  for(i = 0; i < 500; i++){
    name[0] = 'x';
    1a4b:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    name[2] = '0' + (i % 64);
    1a4f:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1a52:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(link("bd", name) != 0){
    1a56:	89 74 24 04          	mov    %esi,0x4(%esp)
    1a5a:	c7 04 24 5a 41 00 00 	movl   $0x415a,(%esp)
    1a61:	e8 f2 19 00 00       	call   3458 <link>
    1a66:	85 c0                	test   %eax,%eax
    1a68:	75 6e                	jne    1ad8 <bigdir+0xf8>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);

  for(i = 0; i < 500; i++){
    1a6a:	83 c3 01             	add    $0x1,%ebx
    1a6d:	81 fb f4 01 00 00    	cmp    $0x1f4,%ebx
    1a73:	75 c3                	jne    1a38 <bigdir+0x58>
      printf(1, "bigdir link failed\n");
      exit();
    }
  }

  unlink("bd");
    1a75:	c7 04 24 5a 41 00 00 	movl   $0x415a,(%esp)
    1a7c:	66 31 db             	xor    %bx,%bx
    1a7f:	e8 c4 19 00 00       	call   3448 <unlink>
    1a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(i = 0; i < 500; i++){
    name[0] = 'x';
    name[1] = '0' + (i / 64);
    1a88:	89 d8                	mov    %ebx,%eax
    1a8a:	c1 f8 06             	sar    $0x6,%eax
    1a8d:	83 c0 30             	add    $0x30,%eax
    1a90:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1a93:	89 d8                	mov    %ebx,%eax
    1a95:	83 e0 3f             	and    $0x3f,%eax
    1a98:	83 c0 30             	add    $0x30,%eax
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    name[0] = 'x';
    1a9b:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    name[2] = '0' + (i % 64);
    1a9f:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1aa2:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(unlink(name) != 0){
    1aa6:	89 34 24             	mov    %esi,(%esp)
    1aa9:	e8 9a 19 00 00       	call   3448 <unlink>
    1aae:	85 c0                	test   %eax,%eax
    1ab0:	75 3f                	jne    1af1 <bigdir+0x111>
      exit();
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    1ab2:	83 c3 01             	add    $0x1,%ebx
    1ab5:	81 fb f4 01 00 00    	cmp    $0x1f4,%ebx
    1abb:	75 cb                	jne    1a88 <bigdir+0xa8>
      printf(1, "bigdir unlink failed");
      exit();
    }
  }

  printf(1, "bigdir ok\n");
    1abd:	c7 44 24 04 9c 41 00 	movl   $0x419c,0x4(%esp)
    1ac4:	00 
    1ac5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1acc:	e8 6f 1a 00 00       	call   3540 <printf>
}
    1ad1:	83 c4 20             	add    $0x20,%esp
    1ad4:	5b                   	pop    %ebx
    1ad5:	5e                   	pop    %esi
    1ad6:	5d                   	pop    %ebp
    1ad7:	c3                   	ret    
    name[0] = 'x';
    name[1] = '0' + (i / 64);
    name[2] = '0' + (i % 64);
    name[3] = '\0';
    if(link("bd", name) != 0){
      printf(1, "bigdir link failed\n");
    1ad8:	c7 44 24 04 73 41 00 	movl   $0x4173,0x4(%esp)
    1adf:	00 
    1ae0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ae7:	e8 54 1a 00 00       	call   3540 <printf>
      exit();
    1aec:	e8 07 19 00 00       	call   33f8 <exit>
    name[0] = 'x';
    name[1] = '0' + (i / 64);
    name[2] = '0' + (i % 64);
    name[3] = '\0';
    if(unlink(name) != 0){
      printf(1, "bigdir unlink failed");
    1af1:	c7 44 24 04 87 41 00 	movl   $0x4187,0x4(%esp)
    1af8:	00 
    1af9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b00:	e8 3b 1a 00 00       	call   3540 <printf>
      exit();
    1b05:	e8 ee 18 00 00       	call   33f8 <exit>
  printf(1, "bigdir test\n");
  unlink("bd");

  fd = open("bd", O_CREATE);
  if(fd < 0){
    printf(1, "bigdir create failed\n");
    1b0a:	c7 44 24 04 5d 41 00 	movl   $0x415d,0x4(%esp)
    1b11:	00 
    1b12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b19:	e8 22 1a 00 00       	call   3540 <printf>
    exit();
    1b1e:	e8 d5 18 00 00       	call   33f8 <exit>
    1b23:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    1b29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00001b30 <linktest>:
  printf(1, "unlinkread ok\n");
}

void
linktest(void)
{
    1b30:	55                   	push   %ebp
    1b31:	89 e5                	mov    %esp,%ebp
    1b33:	53                   	push   %ebx
    1b34:	83 ec 14             	sub    $0x14,%esp
  int fd;

  printf(1, "linktest\n");
    1b37:	c7 44 24 04 a7 41 00 	movl   $0x41a7,0x4(%esp)
    1b3e:	00 
    1b3f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b46:	e8 f5 19 00 00       	call   3540 <printf>

  unlink("lf1");
    1b4b:	c7 04 24 b1 41 00 00 	movl   $0x41b1,(%esp)
    1b52:	e8 f1 18 00 00       	call   3448 <unlink>
  unlink("lf2");
    1b57:	c7 04 24 b5 41 00 00 	movl   $0x41b5,(%esp)
    1b5e:	e8 e5 18 00 00       	call   3448 <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    1b63:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1b6a:	00 
    1b6b:	c7 04 24 b1 41 00 00 	movl   $0x41b1,(%esp)
    1b72:	e8 c1 18 00 00       	call   3438 <open>
  if(fd < 0){
    1b77:	85 c0                	test   %eax,%eax
  printf(1, "linktest\n");

  unlink("lf1");
  unlink("lf2");

  fd = open("lf1", O_CREATE|O_RDWR);
    1b79:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1b7b:	0f 88 26 01 00 00    	js     1ca7 <linktest+0x177>
    printf(1, "create lf1 failed\n");
    exit();
  }
  if(write(fd, "hello", 5) != 5){
    1b81:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1b88:	00 
    1b89:	c7 44 24 04 cc 41 00 	movl   $0x41cc,0x4(%esp)
    1b90:	00 
    1b91:	89 04 24             	mov    %eax,(%esp)
    1b94:	e8 7f 18 00 00       	call   3418 <write>
    1b99:	83 f8 05             	cmp    $0x5,%eax
    1b9c:	0f 85 cd 01 00 00    	jne    1d6f <linktest+0x23f>
    printf(1, "write lf1 failed\n");
    exit();
  }
  close(fd);
    1ba2:	89 1c 24             	mov    %ebx,(%esp)
    1ba5:	e8 76 18 00 00       	call   3420 <close>

  if(link("lf1", "lf2") < 0){
    1baa:	c7 44 24 04 b5 41 00 	movl   $0x41b5,0x4(%esp)
    1bb1:	00 
    1bb2:	c7 04 24 b1 41 00 00 	movl   $0x41b1,(%esp)
    1bb9:	e8 9a 18 00 00       	call   3458 <link>
    1bbe:	85 c0                	test   %eax,%eax
    1bc0:	0f 88 90 01 00 00    	js     1d56 <linktest+0x226>
    printf(1, "link lf1 lf2 failed\n");
    exit();
  }
  unlink("lf1");
    1bc6:	c7 04 24 b1 41 00 00 	movl   $0x41b1,(%esp)
    1bcd:	e8 76 18 00 00       	call   3448 <unlink>

  if(open("lf1", 0) >= 0){
    1bd2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1bd9:	00 
    1bda:	c7 04 24 b1 41 00 00 	movl   $0x41b1,(%esp)
    1be1:	e8 52 18 00 00       	call   3438 <open>
    1be6:	85 c0                	test   %eax,%eax
    1be8:	0f 89 4f 01 00 00    	jns    1d3d <linktest+0x20d>
    printf(1, "unlinked lf1 but it is still there!\n");
    exit();
  }

  fd = open("lf2", 0);
    1bee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1bf5:	00 
    1bf6:	c7 04 24 b5 41 00 00 	movl   $0x41b5,(%esp)
    1bfd:	e8 36 18 00 00       	call   3438 <open>
  if(fd < 0){
    1c02:	85 c0                	test   %eax,%eax
  if(open("lf1", 0) >= 0){
    printf(1, "unlinked lf1 but it is still there!\n");
    exit();
  }

  fd = open("lf2", 0);
    1c04:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1c06:	0f 88 18 01 00 00    	js     1d24 <linktest+0x1f4>
    printf(1, "open lf2 failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    1c0c:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
    1c13:	00 
    1c14:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    1c1b:	00 
    1c1c:	89 04 24             	mov    %eax,(%esp)
    1c1f:	e8 ec 17 00 00       	call   3410 <read>
    1c24:	83 f8 05             	cmp    $0x5,%eax
    1c27:	0f 85 de 00 00 00    	jne    1d0b <linktest+0x1db>
    printf(1, "read lf2 failed\n");
    exit();
  }
  close(fd);
    1c2d:	89 1c 24             	mov    %ebx,(%esp)
    1c30:	e8 eb 17 00 00       	call   3420 <close>

  if(link("lf2", "lf2") >= 0){
    1c35:	c7 44 24 04 b5 41 00 	movl   $0x41b5,0x4(%esp)
    1c3c:	00 
    1c3d:	c7 04 24 b5 41 00 00 	movl   $0x41b5,(%esp)
    1c44:	e8 0f 18 00 00       	call   3458 <link>
    1c49:	85 c0                	test   %eax,%eax
    1c4b:	0f 89 a1 00 00 00    	jns    1cf2 <linktest+0x1c2>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    exit();
  }

  unlink("lf2");
    1c51:	c7 04 24 b5 41 00 00 	movl   $0x41b5,(%esp)
    1c58:	e8 eb 17 00 00       	call   3448 <unlink>
  if(link("lf2", "lf1") >= 0){
    1c5d:	c7 44 24 04 b1 41 00 	movl   $0x41b1,0x4(%esp)
    1c64:	00 
    1c65:	c7 04 24 b5 41 00 00 	movl   $0x41b5,(%esp)
    1c6c:	e8 e7 17 00 00       	call   3458 <link>
    1c71:	85 c0                	test   %eax,%eax
    1c73:	79 64                	jns    1cd9 <linktest+0x1a9>
    printf(1, "link non-existant succeeded! oops\n");
    exit();
  }

  if(link(".", "lf1") >= 0){
    1c75:	c7 44 24 04 b1 41 00 	movl   $0x41b1,0x4(%esp)
    1c7c:	00 
    1c7d:	c7 04 24 66 3f 00 00 	movl   $0x3f66,(%esp)
    1c84:	e8 cf 17 00 00       	call   3458 <link>
    1c89:	85 c0                	test   %eax,%eax
    1c8b:	79 33                	jns    1cc0 <linktest+0x190>
    printf(1, "link . lf1 succeeded! oops\n");
    exit();
  }

  printf(1, "linktest ok\n");
    1c8d:	c7 44 24 04 55 42 00 	movl   $0x4255,0x4(%esp)
    1c94:	00 
    1c95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c9c:	e8 9f 18 00 00       	call   3540 <printf>
}
    1ca1:	83 c4 14             	add    $0x14,%esp
    1ca4:	5b                   	pop    %ebx
    1ca5:	5d                   	pop    %ebp
    1ca6:	c3                   	ret    
  unlink("lf1");
  unlink("lf2");

  fd = open("lf1", O_CREATE|O_RDWR);
  if(fd < 0){
    printf(1, "create lf1 failed\n");
    1ca7:	c7 44 24 04 b9 41 00 	movl   $0x41b9,0x4(%esp)
    1cae:	00 
    1caf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cb6:	e8 85 18 00 00       	call   3540 <printf>
    exit();
    1cbb:	e8 38 17 00 00       	call   33f8 <exit>
    printf(1, "link non-existant succeeded! oops\n");
    exit();
  }

  if(link(".", "lf1") >= 0){
    printf(1, "link . lf1 succeeded! oops\n");
    1cc0:	c7 44 24 04 39 42 00 	movl   $0x4239,0x4(%esp)
    1cc7:	00 
    1cc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ccf:	e8 6c 18 00 00       	call   3540 <printf>
    exit();
    1cd4:	e8 1f 17 00 00       	call   33f8 <exit>
    exit();
  }

  unlink("lf2");
  if(link("lf2", "lf1") >= 0){
    printf(1, "link non-existant succeeded! oops\n");
    1cd9:	c7 44 24 04 3c 4c 00 	movl   $0x4c3c,0x4(%esp)
    1ce0:	00 
    1ce1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ce8:	e8 53 18 00 00       	call   3540 <printf>
    exit();
    1ced:	e8 06 17 00 00       	call   33f8 <exit>
    exit();
  }
  close(fd);

  if(link("lf2", "lf2") >= 0){
    printf(1, "link lf2 lf2 succeeded! oops\n");
    1cf2:	c7 44 24 04 1b 42 00 	movl   $0x421b,0x4(%esp)
    1cf9:	00 
    1cfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d01:	e8 3a 18 00 00       	call   3540 <printf>
    exit();
    1d06:	e8 ed 16 00 00       	call   33f8 <exit>
  if(fd < 0){
    printf(1, "open lf2 failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    printf(1, "read lf2 failed\n");
    1d0b:	c7 44 24 04 0a 42 00 	movl   $0x420a,0x4(%esp)
    1d12:	00 
    1d13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d1a:	e8 21 18 00 00       	call   3540 <printf>
    exit();
    1d1f:	e8 d4 16 00 00       	call   33f8 <exit>
    exit();
  }

  fd = open("lf2", 0);
  if(fd < 0){
    printf(1, "open lf2 failed\n");
    1d24:	c7 44 24 04 f9 41 00 	movl   $0x41f9,0x4(%esp)
    1d2b:	00 
    1d2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d33:	e8 08 18 00 00       	call   3540 <printf>
    exit();
    1d38:	e8 bb 16 00 00       	call   33f8 <exit>
    exit();
  }
  unlink("lf1");

  if(open("lf1", 0) >= 0){
    printf(1, "unlinked lf1 but it is still there!\n");
    1d3d:	c7 44 24 04 14 4c 00 	movl   $0x4c14,0x4(%esp)
    1d44:	00 
    1d45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d4c:	e8 ef 17 00 00       	call   3540 <printf>
    exit();
    1d51:	e8 a2 16 00 00       	call   33f8 <exit>
    exit();
  }
  close(fd);

  if(link("lf1", "lf2") < 0){
    printf(1, "link lf1 lf2 failed\n");
    1d56:	c7 44 24 04 e4 41 00 	movl   $0x41e4,0x4(%esp)
    1d5d:	00 
    1d5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d65:	e8 d6 17 00 00       	call   3540 <printf>
    exit();
    1d6a:	e8 89 16 00 00       	call   33f8 <exit>
  if(fd < 0){
    printf(1, "create lf1 failed\n");
    exit();
  }
  if(write(fd, "hello", 5) != 5){
    printf(1, "write lf1 failed\n");
    1d6f:	c7 44 24 04 d2 41 00 	movl   $0x41d2,0x4(%esp)
    1d76:	00 
    1d77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d7e:	e8 bd 17 00 00       	call   3540 <printf>
    exit();
    1d83:	e8 70 16 00 00       	call   33f8 <exit>
    1d88:	90                   	nop
    1d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00001d90 <unlinkread>:
}

// can I unlink a file and still read it?
void
unlinkread(void)
{
    1d90:	55                   	push   %ebp
    1d91:	89 e5                	mov    %esp,%ebp
    1d93:	56                   	push   %esi
    1d94:	53                   	push   %ebx
    1d95:	83 ec 10             	sub    $0x10,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    1d98:	c7 44 24 04 62 42 00 	movl   $0x4262,0x4(%esp)
    1d9f:	00 
    1da0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1da7:	e8 94 17 00 00       	call   3540 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1dac:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1db3:	00 
    1db4:	c7 04 24 73 42 00 00 	movl   $0x4273,(%esp)
    1dbb:	e8 78 16 00 00       	call   3438 <open>
  if(fd < 0){
    1dc0:	85 c0                	test   %eax,%eax
unlinkread(void)
{
  int fd, fd1;

  printf(1, "unlinkread test\n");
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1dc2:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1dc4:	0f 88 fe 00 00 00    	js     1ec8 <unlinkread+0x138>
    printf(1, "create unlinkread failed\n");
    exit();
  }
  write(fd, "hello", 5);
    1dca:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1dd1:	00 
    1dd2:	c7 44 24 04 cc 41 00 	movl   $0x41cc,0x4(%esp)
    1dd9:	00 
    1dda:	89 04 24             	mov    %eax,(%esp)
    1ddd:	e8 36 16 00 00       	call   3418 <write>
  close(fd);
    1de2:	89 1c 24             	mov    %ebx,(%esp)
    1de5:	e8 36 16 00 00       	call   3420 <close>

  fd = open("unlinkread", O_RDWR);
    1dea:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1df1:	00 
    1df2:	c7 04 24 73 42 00 00 	movl   $0x4273,(%esp)
    1df9:	e8 3a 16 00 00       	call   3438 <open>
  if(fd < 0){
    1dfe:	85 c0                	test   %eax,%eax
    exit();
  }
  write(fd, "hello", 5);
  close(fd);

  fd = open("unlinkread", O_RDWR);
    1e00:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1e02:	0f 88 3d 01 00 00    	js     1f45 <unlinkread+0x1b5>
    printf(1, "open unlinkread failed\n");
    exit();
  }
  if(unlink("unlinkread") != 0){
    1e08:	c7 04 24 73 42 00 00 	movl   $0x4273,(%esp)
    1e0f:	e8 34 16 00 00       	call   3448 <unlink>
    1e14:	85 c0                	test   %eax,%eax
    1e16:	0f 85 10 01 00 00    	jne    1f2c <unlinkread+0x19c>
    printf(1, "unlink unlinkread failed\n");
    exit();
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    1e1c:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1e23:	00 
    1e24:	c7 04 24 73 42 00 00 	movl   $0x4273,(%esp)
    1e2b:	e8 08 16 00 00       	call   3438 <open>
  write(fd1, "yyy", 3);
    1e30:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    1e37:	00 
    1e38:	c7 44 24 04 ca 42 00 	movl   $0x42ca,0x4(%esp)
    1e3f:	00 
  if(unlink("unlinkread") != 0){
    printf(1, "unlink unlinkread failed\n");
    exit();
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    1e40:	89 c6                	mov    %eax,%esi
  write(fd1, "yyy", 3);
    1e42:	89 04 24             	mov    %eax,(%esp)
    1e45:	e8 ce 15 00 00       	call   3418 <write>
  close(fd1);
    1e4a:	89 34 24             	mov    %esi,(%esp)
    1e4d:	e8 ce 15 00 00       	call   3420 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    1e52:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
    1e59:	00 
    1e5a:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    1e61:	00 
    1e62:	89 1c 24             	mov    %ebx,(%esp)
    1e65:	e8 a6 15 00 00       	call   3410 <read>
    1e6a:	83 f8 05             	cmp    $0x5,%eax
    1e6d:	0f 85 a0 00 00 00    	jne    1f13 <unlinkread+0x183>
    printf(1, "unlinkread read failed");
    exit();
  }
  if(buf[0] != 'h'){
    1e73:	80 3d c0 75 00 00 68 	cmpb   $0x68,0x75c0
    1e7a:	75 7e                	jne    1efa <unlinkread+0x16a>
    printf(1, "unlinkread wrong data\n");
    exit();
  }
  if(write(fd, buf, 10) != 10){
    1e7c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1e83:	00 
    1e84:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    1e8b:	00 
    1e8c:	89 1c 24             	mov    %ebx,(%esp)
    1e8f:	e8 84 15 00 00       	call   3418 <write>
    1e94:	83 f8 0a             	cmp    $0xa,%eax
    1e97:	75 48                	jne    1ee1 <unlinkread+0x151>
    printf(1, "unlinkread write failed\n");
    exit();
  }
  close(fd);
    1e99:	89 1c 24             	mov    %ebx,(%esp)
    1e9c:	e8 7f 15 00 00       	call   3420 <close>
  unlink("unlinkread");
    1ea1:	c7 04 24 73 42 00 00 	movl   $0x4273,(%esp)
    1ea8:	e8 9b 15 00 00       	call   3448 <unlink>
  printf(1, "unlinkread ok\n");
    1ead:	c7 44 24 04 15 43 00 	movl   $0x4315,0x4(%esp)
    1eb4:	00 
    1eb5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ebc:	e8 7f 16 00 00       	call   3540 <printf>
}
    1ec1:	83 c4 10             	add    $0x10,%esp
    1ec4:	5b                   	pop    %ebx
    1ec5:	5e                   	pop    %esi
    1ec6:	5d                   	pop    %ebp
    1ec7:	c3                   	ret    
  int fd, fd1;

  printf(1, "unlinkread test\n");
  fd = open("unlinkread", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "create unlinkread failed\n");
    1ec8:	c7 44 24 04 7e 42 00 	movl   $0x427e,0x4(%esp)
    1ecf:	00 
    1ed0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ed7:	e8 64 16 00 00       	call   3540 <printf>
    exit();
    1edc:	e8 17 15 00 00       	call   33f8 <exit>
  if(buf[0] != 'h'){
    printf(1, "unlinkread wrong data\n");
    exit();
  }
  if(write(fd, buf, 10) != 10){
    printf(1, "unlinkread write failed\n");
    1ee1:	c7 44 24 04 fc 42 00 	movl   $0x42fc,0x4(%esp)
    1ee8:	00 
    1ee9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ef0:	e8 4b 16 00 00       	call   3540 <printf>
    exit();
    1ef5:	e8 fe 14 00 00       	call   33f8 <exit>
  if(read(fd, buf, sizeof(buf)) != 5){
    printf(1, "unlinkread read failed");
    exit();
  }
  if(buf[0] != 'h'){
    printf(1, "unlinkread wrong data\n");
    1efa:	c7 44 24 04 e5 42 00 	movl   $0x42e5,0x4(%esp)
    1f01:	00 
    1f02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f09:	e8 32 16 00 00       	call   3540 <printf>
    exit();
    1f0e:	e8 e5 14 00 00       	call   33f8 <exit>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
  write(fd1, "yyy", 3);
  close(fd1);

  if(read(fd, buf, sizeof(buf)) != 5){
    printf(1, "unlinkread read failed");
    1f13:	c7 44 24 04 ce 42 00 	movl   $0x42ce,0x4(%esp)
    1f1a:	00 
    1f1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f22:	e8 19 16 00 00       	call   3540 <printf>
    exit();
    1f27:	e8 cc 14 00 00       	call   33f8 <exit>
  if(fd < 0){
    printf(1, "open unlinkread failed\n");
    exit();
  }
  if(unlink("unlinkread") != 0){
    printf(1, "unlink unlinkread failed\n");
    1f2c:	c7 44 24 04 b0 42 00 	movl   $0x42b0,0x4(%esp)
    1f33:	00 
    1f34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f3b:	e8 00 16 00 00       	call   3540 <printf>
    exit();
    1f40:	e8 b3 14 00 00       	call   33f8 <exit>
  write(fd, "hello", 5);
  close(fd);

  fd = open("unlinkread", O_RDWR);
  if(fd < 0){
    printf(1, "open unlinkread failed\n");
    1f45:	c7 44 24 04 98 42 00 	movl   $0x4298,0x4(%esp)
    1f4c:	00 
    1f4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f54:	e8 e7 15 00 00       	call   3540 <printf>
    exit();
    1f59:	e8 9a 14 00 00       	call   33f8 <exit>
    1f5e:	66 90                	xchg   %ax,%ax

00001f60 <createdelete>:
}

// two processes create and delete different files in same directory
void
createdelete(void)
{
    1f60:	55                   	push   %ebp
    1f61:	89 e5                	mov    %esp,%ebp
    1f63:	57                   	push   %edi
    1f64:	56                   	push   %esi
    1f65:	53                   	push   %ebx
    1f66:	83 ec 4c             	sub    $0x4c,%esp
  enum { N = 20 };
  int pid, i, fd;
  char name[32];

  printf(1, "createdelete test\n");
    1f69:	c7 44 24 04 24 43 00 	movl   $0x4324,0x4(%esp)
    1f70:	00 
    1f71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f78:	e8 c3 15 00 00       	call   3540 <printf>
  pid = fork();
    1f7d:	e8 6e 14 00 00       	call   33f0 <fork>
  if(pid < 0){
    1f82:	85 c0                	test   %eax,%eax
  enum { N = 20 };
  int pid, i, fd;
  char name[32];

  printf(1, "createdelete test\n");
  pid = fork();
    1f84:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  if(pid < 0){
    1f87:	0f 88 14 02 00 00    	js     21a1 <createdelete+0x241>
    printf(1, "fork failed\n");
    exit();
  }

  name[0] = pid ? 'p' : 'c';
    1f8d:	83 7d c4 01          	cmpl   $0x1,-0x3c(%ebp)
  name[2] = '\0';
    1f91:	bf 01 00 00 00       	mov    $0x1,%edi
    1f96:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
    1f9a:	8d 75 c8             	lea    -0x38(%ebp),%esi
  if(pid < 0){
    printf(1, "fork failed\n");
    exit();
  }

  name[0] = pid ? 'p' : 'c';
    1f9d:	19 c0                	sbb    %eax,%eax
  name[2] = '\0';
    1f9f:	31 db                	xor    %ebx,%ebx
  if(pid < 0){
    printf(1, "fork failed\n");
    exit();
  }

  name[0] = pid ? 'p' : 'c';
    1fa1:	83 e0 f3             	and    $0xfffffff3,%eax
    1fa4:	83 c0 70             	add    $0x70,%eax
    1fa7:	88 45 c8             	mov    %al,-0x38(%ebp)
    1faa:	eb 0f                	jmp    1fbb <createdelete+0x5b>
    1fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  name[2] = '\0';
  for(i = 0; i < N; i++){
    1fb0:	83 ff 13             	cmp    $0x13,%edi
    1fb3:	7f 6b                	jg     2020 <createdelete+0xc0>
    printf(1, "fork failed\n");
    exit();
  }

  name[0] = pid ? 'p' : 'c';
  name[2] = '\0';
    1fb5:	83 c3 01             	add    $0x1,%ebx
    1fb8:	83 c7 01             	add    $0x1,%edi
  for(i = 0; i < N; i++){
    name[1] = '0' + i;
    1fbb:	8d 43 30             	lea    0x30(%ebx),%eax
    1fbe:	88 45 c9             	mov    %al,-0x37(%ebp)
    fd = open(name, O_CREATE | O_RDWR);
    1fc1:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1fc8:	00 
    1fc9:	89 34 24             	mov    %esi,(%esp)
    1fcc:	e8 67 14 00 00       	call   3438 <open>
    if(fd < 0){
    1fd1:	85 c0                	test   %eax,%eax
    1fd3:	0f 88 3e 01 00 00    	js     2117 <createdelete+0x1b7>
      printf(1, "create failed\n");
      exit();
    }
    close(fd);
    1fd9:	89 04 24             	mov    %eax,(%esp)
    1fdc:	e8 3f 14 00 00       	call   3420 <close>
    if(i > 0 && (i % 2 ) == 0){
    1fe1:	85 db                	test   %ebx,%ebx
    1fe3:	74 d0                	je     1fb5 <createdelete+0x55>
    1fe5:	f6 c3 01             	test   $0x1,%bl
    1fe8:	75 c6                	jne    1fb0 <createdelete+0x50>
      name[1] = '0' + (i / 2);
    1fea:	89 d8                	mov    %ebx,%eax
    1fec:	d1 f8                	sar    %eax
    1fee:	83 c0 30             	add    $0x30,%eax
    1ff1:	88 45 c9             	mov    %al,-0x37(%ebp)
      if(unlink(name) < 0){
    1ff4:	89 34 24             	mov    %esi,(%esp)
    1ff7:	e8 4c 14 00 00       	call   3448 <unlink>
    1ffc:	85 c0                	test   %eax,%eax
    1ffe:	79 b0                	jns    1fb0 <createdelete+0x50>
        printf(1, "unlink failed\n");
    2000:	c7 44 24 04 37 43 00 	movl   $0x4337,0x4(%esp)
    2007:	00 
    2008:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    200f:	e8 2c 15 00 00       	call   3540 <printf>
        exit();
    2014:	e8 df 13 00 00       	call   33f8 <exit>
    2019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      }
    }
  }

  if(pid==0)
    2020:	8b 45 c4             	mov    -0x3c(%ebp),%eax
    2023:	85 c0                	test   %eax,%eax
    2025:	0f 84 71 01 00 00    	je     219c <createdelete+0x23c>
    exit();
  else
    wait();
    202b:	e8 d0 13 00 00       	call   3400 <wait>
    2030:	31 db                	xor    %ebx,%ebx
    2032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  for(i = 0; i < N; i++){
    name[0] = 'p';
    2038:	8d 7b 30             	lea    0x30(%ebx),%edi
    name[1] = '0' + i;
    203b:	89 f8                	mov    %edi,%eax
    exit();
  else
    wait();

  for(i = 0; i < N; i++){
    name[0] = 'p';
    203d:	c6 45 c8 70          	movb   $0x70,-0x38(%ebp)
    name[1] = '0' + i;
    2041:	88 45 c9             	mov    %al,-0x37(%ebp)
    fd = open(name, 0);
    2044:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    204b:	00 
    204c:	89 34 24             	mov    %esi,(%esp)
    204f:	e8 e4 13 00 00       	call   3438 <open>
    if((i == 0 || i >= N/2) && fd < 0){
    2054:	83 fb 09             	cmp    $0x9,%ebx
    2057:	0f 9f c1             	setg   %cl
    205a:	85 db                	test   %ebx,%ebx
    205c:	0f 94 c2             	sete   %dl
    205f:	08 d1                	or     %dl,%cl
    2061:	88 4d c3             	mov    %cl,-0x3d(%ebp)
    2064:	74 08                	je     206e <createdelete+0x10e>
    2066:	85 c0                	test   %eax,%eax
    2068:	0f 88 16 01 00 00    	js     2184 <createdelete+0x224>
      printf(1, "oops createdelete %s didn't exist\n", name);
      exit();
    } else if((i >= 1 && i < N/2) && fd >= 0){
    206e:	8d 53 ff             	lea    -0x1(%ebx),%edx
    2071:	83 fa 08             	cmp    $0x8,%edx
    2074:	89 c2                	mov    %eax,%edx
    2076:	f7 d2                	not    %edx
    2078:	0f 96 45 c4          	setbe  -0x3c(%ebp)
    207c:	c1 ea 1f             	shr    $0x1f,%edx
    207f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
    2083:	0f 85 b9 00 00 00    	jne    2142 <createdelete+0x1e2>
      printf(1, "oops createdelete %s did exist\n", name);
      exit();
    }
    if(fd >= 0)
    2089:	84 d2                	test   %dl,%dl
    208b:	74 08                	je     2095 <createdelete+0x135>
      close(fd);
    208d:	89 04 24             	mov    %eax,(%esp)
    2090:	e8 8b 13 00 00       	call   3420 <close>

    name[0] = 'c';
    name[1] = '0' + i;
    2095:	89 f8                	mov    %edi,%eax
      exit();
    }
    if(fd >= 0)
      close(fd);

    name[0] = 'c';
    2097:	c6 45 c8 63          	movb   $0x63,-0x38(%ebp)
    name[1] = '0' + i;
    209b:	88 45 c9             	mov    %al,-0x37(%ebp)
    fd = open(name, 0);
    209e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    20a5:	00 
    20a6:	89 34 24             	mov    %esi,(%esp)
    20a9:	e8 8a 13 00 00       	call   3438 <open>
    if((i == 0 || i >= N/2) && fd < 0){
    20ae:	80 7d c3 00          	cmpb   $0x0,-0x3d(%ebp)
    20b2:	74 08                	je     20bc <createdelete+0x15c>
    20b4:	85 c0                	test   %eax,%eax
    20b6:	0f 88 ab 00 00 00    	js     2167 <createdelete+0x207>
      printf(1, "oops createdelete %s didn't exist\n", name);
      exit();
    } else if((i >= 1 && i < N/2) && fd >= 0){
    20bc:	85 c0                	test   %eax,%eax
    20be:	66 90                	xchg   %ax,%ax
    20c0:	79 6e                	jns    2130 <createdelete+0x1d0>
  if(pid==0)
    exit();
  else
    wait();

  for(i = 0; i < N; i++){
    20c2:	83 c3 01             	add    $0x1,%ebx
    20c5:	83 fb 14             	cmp    $0x14,%ebx
    20c8:	0f 85 6a ff ff ff    	jne    2038 <createdelete+0xd8>
    20ce:	bb 30 00 00 00       	mov    $0x30,%ebx
    20d3:	90                   	nop
    20d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      close(fd);
  }

  for(i = 0; i < N; i++){
    name[0] = 'p';
    name[1] = '0' + i;
    20d8:	88 5d c9             	mov    %bl,-0x37(%ebp)
    unlink(name);
    name[0] = 'c';
    unlink(name);
    20db:	83 c3 01             	add    $0x1,%ebx
    if(fd >= 0)
      close(fd);
  }

  for(i = 0; i < N; i++){
    name[0] = 'p';
    20de:	c6 45 c8 70          	movb   $0x70,-0x38(%ebp)
    name[1] = '0' + i;
    unlink(name);
    20e2:	89 34 24             	mov    %esi,(%esp)
    20e5:	e8 5e 13 00 00       	call   3448 <unlink>
    name[0] = 'c';
    20ea:	c6 45 c8 63          	movb   $0x63,-0x38(%ebp)
    unlink(name);
    20ee:	89 34 24             	mov    %esi,(%esp)
    20f1:	e8 52 13 00 00       	call   3448 <unlink>
    }
    if(fd >= 0)
      close(fd);
  }

  for(i = 0; i < N; i++){
    20f6:	80 fb 44             	cmp    $0x44,%bl
    20f9:	75 dd                	jne    20d8 <createdelete+0x178>
    unlink(name);
    name[0] = 'c';
    unlink(name);
  }

  printf(1, "createdelete ok\n");
    20fb:	c7 44 24 04 46 43 00 	movl   $0x4346,0x4(%esp)
    2102:	00 
    2103:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    210a:	e8 31 14 00 00       	call   3540 <printf>
}
    210f:	83 c4 4c             	add    $0x4c,%esp
    2112:	5b                   	pop    %ebx
    2113:	5e                   	pop    %esi
    2114:	5f                   	pop    %edi
    2115:	5d                   	pop    %ebp
    2116:	c3                   	ret    
  name[2] = '\0';
  for(i = 0; i < N; i++){
    name[1] = '0' + i;
    fd = open(name, O_CREATE | O_RDWR);
    if(fd < 0){
      printf(1, "create failed\n");
    2117:	c7 44 24 04 64 41 00 	movl   $0x4164,0x4(%esp)
    211e:	00 
    211f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2126:	e8 15 14 00 00       	call   3540 <printf>
      exit();
    212b:	e8 c8 12 00 00       	call   33f8 <exit>
    name[1] = '0' + i;
    fd = open(name, 0);
    if((i == 0 || i >= N/2) && fd < 0){
      printf(1, "oops createdelete %s didn't exist\n", name);
      exit();
    } else if((i >= 1 && i < N/2) && fd >= 0){
    2130:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
    2134:	75 14                	jne    214a <createdelete+0x1ea>
      printf(1, "oops createdelete %s did exist\n", name);
      exit();
    }
    if(fd >= 0)
      close(fd);
    2136:	89 04 24             	mov    %eax,(%esp)
    2139:	e8 e2 12 00 00       	call   3420 <close>
    213e:	66 90                	xchg   %ax,%ax
    2140:	eb 80                	jmp    20c2 <createdelete+0x162>
    name[1] = '0' + i;
    fd = open(name, 0);
    if((i == 0 || i >= N/2) && fd < 0){
      printf(1, "oops createdelete %s didn't exist\n", name);
      exit();
    } else if((i >= 1 && i < N/2) && fd >= 0){
    2142:	84 d2                	test   %dl,%dl
    2144:	0f 84 4b ff ff ff    	je     2095 <createdelete+0x135>
    fd = open(name, 0);
    if((i == 0 || i >= N/2) && fd < 0){
      printf(1, "oops createdelete %s didn't exist\n", name);
      exit();
    } else if((i >= 1 && i < N/2) && fd >= 0){
      printf(1, "oops createdelete %s did exist\n", name);
    214a:	89 74 24 08          	mov    %esi,0x8(%esp)
    214e:	c7 44 24 04 84 4c 00 	movl   $0x4c84,0x4(%esp)
    2155:	00 
    2156:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    215d:	e8 de 13 00 00       	call   3540 <printf>
      exit();
    2162:	e8 91 12 00 00       	call   33f8 <exit>

    name[0] = 'c';
    name[1] = '0' + i;
    fd = open(name, 0);
    if((i == 0 || i >= N/2) && fd < 0){
      printf(1, "oops createdelete %s didn't exist\n", name);
    2167:	89 74 24 08          	mov    %esi,0x8(%esp)
    216b:	c7 44 24 04 60 4c 00 	movl   $0x4c60,0x4(%esp)
    2172:	00 
    2173:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    217a:	e8 c1 13 00 00       	call   3540 <printf>
      exit();
    217f:	e8 74 12 00 00       	call   33f8 <exit>
  for(i = 0; i < N; i++){
    name[0] = 'p';
    name[1] = '0' + i;
    fd = open(name, 0);
    if((i == 0 || i >= N/2) && fd < 0){
      printf(1, "oops createdelete %s didn't exist\n", name);
    2184:	89 74 24 08          	mov    %esi,0x8(%esp)
    2188:	c7 44 24 04 60 4c 00 	movl   $0x4c60,0x4(%esp)
    218f:	00 
    2190:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2197:	e8 a4 13 00 00       	call   3540 <printf>
      exit();
    219c:	e8 57 12 00 00       	call   33f8 <exit>
  char name[32];

  printf(1, "createdelete test\n");
  pid = fork();
  if(pid < 0){
    printf(1, "fork failed\n");
    21a1:	c7 44 24 04 d6 39 00 	movl   $0x39d6,0x4(%esp)
    21a8:	00 
    21a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21b0:	e8 8b 13 00 00       	call   3540 <printf>
    exit();
    21b5:	e8 3e 12 00 00       	call   33f8 <exit>
    21ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

000021c0 <dirtest>:
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
}

void dirtest(void)
{
    21c0:	55                   	push   %ebp
    21c1:	89 e5                	mov    %esp,%ebp
    21c3:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
    21c6:	a1 60 4e 00 00       	mov    0x4e60,%eax
    21cb:	c7 44 24 04 57 43 00 	movl   $0x4357,0x4(%esp)
    21d2:	00 
    21d3:	89 04 24             	mov    %eax,(%esp)
    21d6:	e8 65 13 00 00       	call   3540 <printf>

  if(mkdir("dir0") < 0){
    21db:	c7 04 24 63 43 00 00 	movl   $0x4363,(%esp)
    21e2:	e8 79 12 00 00       	call   3460 <mkdir>
    21e7:	85 c0                	test   %eax,%eax
    21e9:	78 4b                	js     2236 <dirtest+0x76>
    printf(stdout, "mkdir failed\n");
    exit();
  }

  if(chdir("dir0") < 0){
    21eb:	c7 04 24 63 43 00 00 	movl   $0x4363,(%esp)
    21f2:	e8 71 12 00 00       	call   3468 <chdir>
    21f7:	85 c0                	test   %eax,%eax
    21f9:	0f 88 85 00 00 00    	js     2284 <dirtest+0xc4>
    printf(stdout, "chdir dir0 failed\n");
    exit();
  }

  if(chdir("..") < 0){
    21ff:	c7 04 24 65 3f 00 00 	movl   $0x3f65,(%esp)
    2206:	e8 5d 12 00 00       	call   3468 <chdir>
    220b:	85 c0                	test   %eax,%eax
    220d:	78 5b                	js     226a <dirtest+0xaa>
    printf(stdout, "chdir .. failed\n");
    exit();
  }

  if(unlink("dir0") < 0){
    220f:	c7 04 24 63 43 00 00 	movl   $0x4363,(%esp)
    2216:	e8 2d 12 00 00       	call   3448 <unlink>
    221b:	85 c0                	test   %eax,%eax
    221d:	78 31                	js     2250 <dirtest+0x90>
    printf(stdout, "unlink dir0 failed\n");
    exit();
  }
  printf(stdout, "mkdir test\n");
    221f:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2224:	c7 44 24 04 57 43 00 	movl   $0x4357,0x4(%esp)
    222b:	00 
    222c:	89 04 24             	mov    %eax,(%esp)
    222f:	e8 0c 13 00 00       	call   3540 <printf>
}
    2234:	c9                   	leave  
    2235:	c3                   	ret    
void dirtest(void)
{
  printf(stdout, "mkdir test\n");

  if(mkdir("dir0") < 0){
    printf(stdout, "mkdir failed\n");
    2236:	a1 60 4e 00 00       	mov    0x4e60,%eax
    223b:	c7 44 24 04 68 43 00 	movl   $0x4368,0x4(%esp)
    2242:	00 
    2243:	89 04 24             	mov    %eax,(%esp)
    2246:	e8 f5 12 00 00       	call   3540 <printf>
    exit();
    224b:	e8 a8 11 00 00       	call   33f8 <exit>
    printf(stdout, "chdir .. failed\n");
    exit();
  }

  if(unlink("dir0") < 0){
    printf(stdout, "unlink dir0 failed\n");
    2250:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2255:	c7 44 24 04 9a 43 00 	movl   $0x439a,0x4(%esp)
    225c:	00 
    225d:	89 04 24             	mov    %eax,(%esp)
    2260:	e8 db 12 00 00       	call   3540 <printf>
    exit();
    2265:	e8 8e 11 00 00       	call   33f8 <exit>
    printf(stdout, "chdir dir0 failed\n");
    exit();
  }

  if(chdir("..") < 0){
    printf(stdout, "chdir .. failed\n");
    226a:	a1 60 4e 00 00       	mov    0x4e60,%eax
    226f:	c7 44 24 04 89 43 00 	movl   $0x4389,0x4(%esp)
    2276:	00 
    2277:	89 04 24             	mov    %eax,(%esp)
    227a:	e8 c1 12 00 00       	call   3540 <printf>
    exit();
    227f:	e8 74 11 00 00       	call   33f8 <exit>
    printf(stdout, "mkdir failed\n");
    exit();
  }

  if(chdir("dir0") < 0){
    printf(stdout, "chdir dir0 failed\n");
    2284:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2289:	c7 44 24 04 76 43 00 	movl   $0x4376,0x4(%esp)
    2290:	00 
    2291:	89 04 24             	mov    %eax,(%esp)
    2294:	e8 a7 12 00 00       	call   3540 <printf>
    exit();
    2299:	e8 5a 11 00 00       	call   33f8 <exit>
    229e:	66 90                	xchg   %ax,%ax

000022a0 <createtest>:
  printf(stdout, "big files ok\n");
}

void
createtest(void)
{
    22a0:	55                   	push   %ebp
    22a1:	89 e5                	mov    %esp,%ebp
    22a3:	53                   	push   %ebx
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
    22a4:	bb 30 00 00 00       	mov    $0x30,%ebx
  printf(stdout, "big files ok\n");
}

void
createtest(void)
{
    22a9:	83 ec 14             	sub    $0x14,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
    22ac:	a1 60 4e 00 00       	mov    0x4e60,%eax
    22b1:	c7 44 24 04 a4 4c 00 	movl   $0x4ca4,0x4(%esp)
    22b8:	00 
    22b9:	89 04 24             	mov    %eax,(%esp)
    22bc:	e8 7f 12 00 00       	call   3540 <printf>

  name[0] = 'a';
    22c1:	c6 05 c0 7d 00 00 61 	movb   $0x61,0x7dc0
  name[2] = '\0';
    22c8:	c6 05 c2 7d 00 00 00 	movb   $0x0,0x7dc2
    22cf:	90                   	nop
  for(i = 0; i < 52; i++){
    name[1] = '0' + i;
    22d0:	88 1d c1 7d 00 00    	mov    %bl,0x7dc1
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
    22d6:	83 c3 01             	add    $0x1,%ebx

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    22d9:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    22e0:	00 
    22e1:	c7 04 24 c0 7d 00 00 	movl   $0x7dc0,(%esp)
    22e8:	e8 4b 11 00 00       	call   3438 <open>
    close(fd);
    22ed:	89 04 24             	mov    %eax,(%esp)
    22f0:	e8 2b 11 00 00       	call   3420 <close>

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
    22f5:	80 fb 64             	cmp    $0x64,%bl
    22f8:	75 d6                	jne    22d0 <createtest+0x30>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
    22fa:	c6 05 c0 7d 00 00 61 	movb   $0x61,0x7dc0
  name[2] = '\0';
    2301:	bb 30 00 00 00       	mov    $0x30,%ebx
    2306:	c6 05 c2 7d 00 00 00 	movb   $0x0,0x7dc2
    230d:	8d 76 00             	lea    0x0(%esi),%esi
  for(i = 0; i < 52; i++){
    name[1] = '0' + i;
    2310:	88 1d c1 7d 00 00    	mov    %bl,0x7dc1
    unlink(name);
    2316:	83 c3 01             	add    $0x1,%ebx
    2319:	c7 04 24 c0 7d 00 00 	movl   $0x7dc0,(%esp)
    2320:	e8 23 11 00 00       	call   3448 <unlink>
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
    2325:	80 fb 64             	cmp    $0x64,%bl
    2328:	75 e6                	jne    2310 <createtest+0x70>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
    232a:	a1 60 4e 00 00       	mov    0x4e60,%eax
    232f:	c7 44 24 04 cc 4c 00 	movl   $0x4ccc,0x4(%esp)
    2336:	00 
    2337:	89 04 24             	mov    %eax,(%esp)
    233a:	e8 01 12 00 00       	call   3540 <printf>
}
    233f:	83 c4 14             	add    $0x14,%esp
    2342:	5b                   	pop    %ebx
    2343:	5d                   	pop    %ebp
    2344:	c3                   	ret    
    2345:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    2349:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00002350 <writetest1>:
  printf(stdout, "small file test ok\n");
}

void
writetest1(void)
{
    2350:	55                   	push   %ebp
    2351:	89 e5                	mov    %esp,%ebp
    2353:	56                   	push   %esi
    2354:	53                   	push   %ebx
    2355:	83 ec 10             	sub    $0x10,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
    2358:	a1 60 4e 00 00       	mov    0x4e60,%eax
    235d:	c7 44 24 04 ae 43 00 	movl   $0x43ae,0x4(%esp)
    2364:	00 
    2365:	89 04 24             	mov    %eax,(%esp)
    2368:	e8 d3 11 00 00       	call   3540 <printf>

  fd = open("big", O_CREATE|O_RDWR);
    236d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2374:	00 
    2375:	c7 04 24 28 44 00 00 	movl   $0x4428,(%esp)
    237c:	e8 b7 10 00 00       	call   3438 <open>
  if(fd < 0){
    2381:	85 c0                	test   %eax,%eax
{
  int i, fd, n;

  printf(stdout, "big files test\n");

  fd = open("big", O_CREATE|O_RDWR);
    2383:	89 c6                	mov    %eax,%esi
  if(fd < 0){
    2385:	0f 88 7a 01 00 00    	js     2505 <writetest1+0x1b5>
    printf(stdout, "error: creat big failed!\n");
    exit();
    238b:	31 db                	xor    %ebx,%ebx
    238d:	8d 76 00             	lea    0x0(%esi),%esi
  }

  for(i = 0; i < MAXFILE; i++){
    ((int*)buf)[0] = i;
    2390:	89 1d c0 75 00 00    	mov    %ebx,0x75c0
    if(write(fd, buf, 512) != 512){
    2396:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    239d:	00 
    239e:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    23a5:	00 
    23a6:	89 34 24             	mov    %esi,(%esp)
    23a9:	e8 6a 10 00 00       	call   3418 <write>
    23ae:	3d 00 02 00 00       	cmp    $0x200,%eax
    23b3:	0f 85 b2 00 00 00    	jne    246b <writetest1+0x11b>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
    23b9:	83 c3 01             	add    $0x1,%ebx
    23bc:	81 fb 8c 00 00 00    	cmp    $0x8c,%ebx
    23c2:	75 cc                	jne    2390 <writetest1+0x40>
      printf(stdout, "error: write big file failed\n", i);
      exit();
    }
  }

  close(fd);
    23c4:	89 34 24             	mov    %esi,(%esp)
    23c7:	e8 54 10 00 00       	call   3420 <close>

  fd = open("big", O_RDONLY);
    23cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    23d3:	00 
    23d4:	c7 04 24 28 44 00 00 	movl   $0x4428,(%esp)
    23db:	e8 58 10 00 00       	call   3438 <open>
  if(fd < 0){
    23e0:	85 c0                	test   %eax,%eax
    }
  }

  close(fd);

  fd = open("big", O_RDONLY);
    23e2:	89 c6                	mov    %eax,%esi
  if(fd < 0){
    23e4:	0f 88 01 01 00 00    	js     24eb <writetest1+0x19b>
    printf(stdout, "error: open big failed!\n");
    exit();
    23ea:	31 db                	xor    %ebx,%ebx
    23ec:	eb 1d                	jmp    240b <writetest1+0xbb>
    23ee:	66 90                	xchg   %ax,%ax
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
    23f0:	3d 00 02 00 00       	cmp    $0x200,%eax
    23f5:	0f 85 b0 00 00 00    	jne    24ab <writetest1+0x15b>
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
    23fb:	a1 c0 75 00 00       	mov    0x75c0,%eax
    2400:	39 d8                	cmp    %ebx,%eax
    2402:	0f 85 81 00 00 00    	jne    2489 <writetest1+0x139>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
    2408:	83 c3 01             	add    $0x1,%ebx
    exit();
  }

  n = 0;
  for(;;){
    i = read(fd, buf, 512);
    240b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    2412:	00 
    2413:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    241a:	00 
    241b:	89 34 24             	mov    %esi,(%esp)
    241e:	e8 ed 0f 00 00       	call   3410 <read>
    if(i == 0){
    2423:	85 c0                	test   %eax,%eax
    2425:	75 c9                	jne    23f0 <writetest1+0xa0>
      if(n == MAXFILE - 1){
    2427:	81 fb 8b 00 00 00    	cmp    $0x8b,%ebx
    242d:	0f 84 96 00 00 00    	je     24c9 <writetest1+0x179>
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
  }
  close(fd);
    2433:	89 34 24             	mov    %esi,(%esp)
    2436:	e8 e5 0f 00 00       	call   3420 <close>
  if(unlink("big") < 0){
    243b:	c7 04 24 28 44 00 00 	movl   $0x4428,(%esp)
    2442:	e8 01 10 00 00       	call   3448 <unlink>
    2447:	85 c0                	test   %eax,%eax
    2449:	0f 88 d0 00 00 00    	js     251f <writetest1+0x1cf>
    printf(stdout, "unlink big failed\n");
    exit();
  }
  printf(stdout, "big files ok\n");
    244f:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2454:	c7 44 24 04 4f 44 00 	movl   $0x444f,0x4(%esp)
    245b:	00 
    245c:	89 04 24             	mov    %eax,(%esp)
    245f:	e8 dc 10 00 00       	call   3540 <printf>
}
    2464:	83 c4 10             	add    $0x10,%esp
    2467:	5b                   	pop    %ebx
    2468:	5e                   	pop    %esi
    2469:	5d                   	pop    %ebp
    246a:	c3                   	ret    
  }

  for(i = 0; i < MAXFILE; i++){
    ((int*)buf)[0] = i;
    if(write(fd, buf, 512) != 512){
      printf(stdout, "error: write big file failed\n", i);
    246b:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2470:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    2474:	c7 44 24 04 d8 43 00 	movl   $0x43d8,0x4(%esp)
    247b:	00 
    247c:	89 04 24             	mov    %eax,(%esp)
    247f:	e8 bc 10 00 00       	call   3540 <printf>
      exit();
    2484:	e8 6f 0f 00 00       	call   33f8 <exit>
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
    2489:	89 44 24 0c          	mov    %eax,0xc(%esp)
    248d:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2492:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    2496:	c7 44 24 04 f4 4c 00 	movl   $0x4cf4,0x4(%esp)
    249d:	00 
    249e:	89 04 24             	mov    %eax,(%esp)
    24a1:	e8 9a 10 00 00       	call   3540 <printf>
             n, ((int*)buf)[0]);
      exit();
    24a6:	e8 4d 0f 00 00       	call   33f8 <exit>
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
    24ab:	89 44 24 08          	mov    %eax,0x8(%esp)
    24af:	a1 60 4e 00 00       	mov    0x4e60,%eax
    24b4:	c7 44 24 04 2c 44 00 	movl   $0x442c,0x4(%esp)
    24bb:	00 
    24bc:	89 04 24             	mov    %eax,(%esp)
    24bf:	e8 7c 10 00 00       	call   3540 <printf>
      exit();
    24c4:	e8 2f 0f 00 00       	call   33f8 <exit>
  n = 0;
  for(;;){
    i = read(fd, buf, 512);
    if(i == 0){
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
    24c9:	a1 60 4e 00 00       	mov    0x4e60,%eax
    24ce:	c7 44 24 08 8b 00 00 	movl   $0x8b,0x8(%esp)
    24d5:	00 
    24d6:	c7 44 24 04 0f 44 00 	movl   $0x440f,0x4(%esp)
    24dd:	00 
    24de:	89 04 24             	mov    %eax,(%esp)
    24e1:	e8 5a 10 00 00       	call   3540 <printf>
        exit();
    24e6:	e8 0d 0f 00 00       	call   33f8 <exit>

  close(fd);

  fd = open("big", O_RDONLY);
  if(fd < 0){
    printf(stdout, "error: open big failed!\n");
    24eb:	a1 60 4e 00 00       	mov    0x4e60,%eax
    24f0:	c7 44 24 04 f6 43 00 	movl   $0x43f6,0x4(%esp)
    24f7:	00 
    24f8:	89 04 24             	mov    %eax,(%esp)
    24fb:	e8 40 10 00 00       	call   3540 <printf>
    exit();
    2500:	e8 f3 0e 00 00       	call   33f8 <exit>

  printf(stdout, "big files test\n");

  fd = open("big", O_CREATE|O_RDWR);
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    2505:	a1 60 4e 00 00       	mov    0x4e60,%eax
    250a:	c7 44 24 04 be 43 00 	movl   $0x43be,0x4(%esp)
    2511:	00 
    2512:	89 04 24             	mov    %eax,(%esp)
    2515:	e8 26 10 00 00       	call   3540 <printf>
    exit();
    251a:	e8 d9 0e 00 00       	call   33f8 <exit>
    }
    n++;
  }
  close(fd);
  if(unlink("big") < 0){
    printf(stdout, "unlink big failed\n");
    251f:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2524:	c7 44 24 04 3c 44 00 	movl   $0x443c,0x4(%esp)
    252b:	00 
    252c:	89 04 24             	mov    %eax,(%esp)
    252f:	e8 0c 10 00 00       	call   3540 <printf>
    exit();
    2534:	e8 bf 0e 00 00       	call   33f8 <exit>
    2539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00002540 <writetest>:
  printf(stdout, "open test ok\n");
}

void
writetest(void)
{
    2540:	55                   	push   %ebp
    2541:	89 e5                	mov    %esp,%ebp
    2543:	56                   	push   %esi
    2544:	53                   	push   %ebx
    2545:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
    2548:	a1 60 4e 00 00       	mov    0x4e60,%eax
    254d:	c7 44 24 04 5d 44 00 	movl   $0x445d,0x4(%esp)
    2554:	00 
    2555:	89 04 24             	mov    %eax,(%esp)
    2558:	e8 e3 0f 00 00       	call   3540 <printf>
  fd = open("small", O_CREATE|O_RDWR);
    255d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2564:	00 
    2565:	c7 04 24 6e 44 00 00 	movl   $0x446e,(%esp)
    256c:	e8 c7 0e 00 00       	call   3438 <open>
  if(fd >= 0){
    2571:	85 c0                	test   %eax,%eax
{
  int fd;
  int i;

  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
    2573:	89 c6                	mov    %eax,%esi
  if(fd >= 0){
    2575:	0f 88 b1 01 00 00    	js     272c <writetest+0x1ec>
    printf(stdout, "creat small succeeded; ok\n");
    257b:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2580:	31 db                	xor    %ebx,%ebx
    2582:	c7 44 24 04 74 44 00 	movl   $0x4474,0x4(%esp)
    2589:	00 
    258a:	89 04 24             	mov    %eax,(%esp)
    258d:	e8 ae 0f 00 00       	call   3540 <printf>
    2592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
    2598:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    259f:	00 
    25a0:	c7 44 24 04 ab 44 00 	movl   $0x44ab,0x4(%esp)
    25a7:	00 
    25a8:	89 34 24             	mov    %esi,(%esp)
    25ab:	e8 68 0e 00 00       	call   3418 <write>
    25b0:	83 f8 0a             	cmp    $0xa,%eax
    25b3:	0f 85 e9 00 00 00    	jne    26a2 <writetest+0x162>
      printf(stdout, "error: write aa %d new file failed\n", i);
      exit();
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
    25b9:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    25c0:	00 
    25c1:	c7 44 24 04 b6 44 00 	movl   $0x44b6,0x4(%esp)
    25c8:	00 
    25c9:	89 34 24             	mov    %esi,(%esp)
    25cc:	e8 47 0e 00 00       	call   3418 <write>
    25d1:	83 f8 0a             	cmp    $0xa,%eax
    25d4:	0f 85 e6 00 00 00    	jne    26c0 <writetest+0x180>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
    25da:	83 c3 01             	add    $0x1,%ebx
    25dd:	83 fb 64             	cmp    $0x64,%ebx
    25e0:	75 b6                	jne    2598 <writetest+0x58>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit();
    }
  }
  printf(stdout, "writes ok\n");
    25e2:	a1 60 4e 00 00       	mov    0x4e60,%eax
    25e7:	c7 44 24 04 c1 44 00 	movl   $0x44c1,0x4(%esp)
    25ee:	00 
    25ef:	89 04 24             	mov    %eax,(%esp)
    25f2:	e8 49 0f 00 00       	call   3540 <printf>
  close(fd);
    25f7:	89 34 24             	mov    %esi,(%esp)
    25fa:	e8 21 0e 00 00       	call   3420 <close>
  fd = open("small", O_RDONLY);
    25ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2606:	00 
    2607:	c7 04 24 6e 44 00 00 	movl   $0x446e,(%esp)
    260e:	e8 25 0e 00 00       	call   3438 <open>
  if(fd >= 0){
    2613:	85 c0                	test   %eax,%eax
      exit();
    }
  }
  printf(stdout, "writes ok\n");
  close(fd);
  fd = open("small", O_RDONLY);
    2615:	89 c3                	mov    %eax,%ebx
  if(fd >= 0){
    2617:	0f 88 c1 00 00 00    	js     26de <writetest+0x19e>
    printf(stdout, "open small succeeded ok\n");
    261d:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2622:	c7 44 24 04 cc 44 00 	movl   $0x44cc,0x4(%esp)
    2629:	00 
    262a:	89 04 24             	mov    %eax,(%esp)
    262d:	e8 0e 0f 00 00       	call   3540 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
    2632:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
    2639:	00 
    263a:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    2641:	00 
    2642:	89 1c 24             	mov    %ebx,(%esp)
    2645:	e8 c6 0d 00 00       	call   3410 <read>
  if(i == 2000){
    264a:	3d d0 07 00 00       	cmp    $0x7d0,%eax
    264f:	0f 85 a3 00 00 00    	jne    26f8 <writetest+0x1b8>
    printf(stdout, "read succeeded ok\n");
    2655:	a1 60 4e 00 00       	mov    0x4e60,%eax
    265a:	c7 44 24 04 00 45 00 	movl   $0x4500,0x4(%esp)
    2661:	00 
    2662:	89 04 24             	mov    %eax,(%esp)
    2665:	e8 d6 0e 00 00       	call   3540 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
    266a:	89 1c 24             	mov    %ebx,(%esp)
    266d:	e8 ae 0d 00 00       	call   3420 <close>

  if(unlink("small") < 0){
    2672:	c7 04 24 6e 44 00 00 	movl   $0x446e,(%esp)
    2679:	e8 ca 0d 00 00       	call   3448 <unlink>
    267e:	85 c0                	test   %eax,%eax
    2680:	0f 88 8c 00 00 00    	js     2712 <writetest+0x1d2>
    printf(stdout, "unlink small failed\n");
    exit();
  }
  printf(stdout, "small file test ok\n");
    2686:	a1 60 4e 00 00       	mov    0x4e60,%eax
    268b:	c7 44 24 04 28 45 00 	movl   $0x4528,0x4(%esp)
    2692:	00 
    2693:	89 04 24             	mov    %eax,(%esp)
    2696:	e8 a5 0e 00 00       	call   3540 <printf>
}
    269b:	83 c4 10             	add    $0x10,%esp
    269e:	5b                   	pop    %ebx
    269f:	5e                   	pop    %esi
    26a0:	5d                   	pop    %ebp
    26a1:	c3                   	ret    
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
      printf(stdout, "error: write aa %d new file failed\n", i);
    26a2:	a1 60 4e 00 00       	mov    0x4e60,%eax
    26a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    26ab:	c7 44 24 04 14 4d 00 	movl   $0x4d14,0x4(%esp)
    26b2:	00 
    26b3:	89 04 24             	mov    %eax,(%esp)
    26b6:	e8 85 0e 00 00       	call   3540 <printf>
      exit();
    26bb:	e8 38 0d 00 00       	call   33f8 <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
    26c0:	a1 60 4e 00 00       	mov    0x4e60,%eax
    26c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    26c9:	c7 44 24 04 38 4d 00 	movl   $0x4d38,0x4(%esp)
    26d0:	00 
    26d1:	89 04 24             	mov    %eax,(%esp)
    26d4:	e8 67 0e 00 00       	call   3540 <printf>
      exit();
    26d9:	e8 1a 0d 00 00       	call   33f8 <exit>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
    26de:	a1 60 4e 00 00       	mov    0x4e60,%eax
    26e3:	c7 44 24 04 e5 44 00 	movl   $0x44e5,0x4(%esp)
    26ea:	00 
    26eb:	89 04 24             	mov    %eax,(%esp)
    26ee:	e8 4d 0e 00 00       	call   3540 <printf>
    exit();
    26f3:	e8 00 0d 00 00       	call   33f8 <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
    26f8:	a1 60 4e 00 00       	mov    0x4e60,%eax
    26fd:	c7 44 24 04 8b 42 00 	movl   $0x428b,0x4(%esp)
    2704:	00 
    2705:	89 04 24             	mov    %eax,(%esp)
    2708:	e8 33 0e 00 00       	call   3540 <printf>
    exit();
    270d:	e8 e6 0c 00 00       	call   33f8 <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
    2712:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2717:	c7 44 24 04 13 45 00 	movl   $0x4513,0x4(%esp)
    271e:	00 
    271f:	89 04 24             	mov    %eax,(%esp)
    2722:	e8 19 0e 00 00       	call   3540 <printf>
    exit();
    2727:	e8 cc 0c 00 00       	call   33f8 <exit>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    272c:	a1 60 4e 00 00       	mov    0x4e60,%eax
    2731:	c7 44 24 04 8f 44 00 	movl   $0x448f,0x4(%esp)
    2738:	00 
    2739:	89 04 24             	mov    %eax,(%esp)
    273c:	e8 ff 0d 00 00       	call   3540 <printf>
    exit();
    2741:	e8 b2 0c 00 00       	call   33f8 <exit>
    2746:	8d 76 00             	lea    0x0(%esi),%esi
    2749:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00002750 <bigfile>:
  printf(1, "subdir ok\n");
}

void
bigfile(void)
{
    2750:	55                   	push   %ebp
    2751:	89 e5                	mov    %esp,%ebp
    2753:	57                   	push   %edi
    2754:	56                   	push   %esi
    2755:	53                   	push   %ebx
    2756:	83 ec 1c             	sub    $0x1c,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    2759:	c7 44 24 04 3c 45 00 	movl   $0x453c,0x4(%esp)
    2760:	00 
    2761:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2768:	e8 d3 0d 00 00       	call   3540 <printf>

  unlink("bigfile");
    276d:	c7 04 24 58 45 00 00 	movl   $0x4558,(%esp)
    2774:	e8 cf 0c 00 00       	call   3448 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    2779:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2780:	00 
    2781:	c7 04 24 58 45 00 00 	movl   $0x4558,(%esp)
    2788:	e8 ab 0c 00 00       	call   3438 <open>
  if(fd < 0){
    278d:	85 c0                	test   %eax,%eax
  int fd, i, total, cc;

  printf(1, "bigfile test\n");

  unlink("bigfile");
  fd = open("bigfile", O_CREATE | O_RDWR);
    278f:	89 c6                	mov    %eax,%esi
  if(fd < 0){
    2791:	0f 88 7f 01 00 00    	js     2916 <bigfile+0x1c6>
    printf(1, "cannot create bigfile");
    exit();
    2797:	31 db                	xor    %ebx,%ebx
    2799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  for(i = 0; i < 20; i++){
    memset(buf, i, 600);
    27a0:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    27a7:	00 
    27a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    27ac:	c7 04 24 c0 75 00 00 	movl   $0x75c0,(%esp)
    27b3:	e8 b8 0a 00 00       	call   3270 <memset>
    if(write(fd, buf, 600) != 600){
    27b8:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    27bf:	00 
    27c0:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    27c7:	00 
    27c8:	89 34 24             	mov    %esi,(%esp)
    27cb:	e8 48 0c 00 00       	call   3418 <write>
    27d0:	3d 58 02 00 00       	cmp    $0x258,%eax
    27d5:	0f 85 09 01 00 00    	jne    28e4 <bigfile+0x194>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    27db:	83 c3 01             	add    $0x1,%ebx
    27de:	83 fb 14             	cmp    $0x14,%ebx
    27e1:	75 bd                	jne    27a0 <bigfile+0x50>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit();
    }
  }
  close(fd);
    27e3:	89 34 24             	mov    %esi,(%esp)
    27e6:	e8 35 0c 00 00       	call   3420 <close>

  fd = open("bigfile", 0);
    27eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    27f2:	00 
    27f3:	c7 04 24 58 45 00 00 	movl   $0x4558,(%esp)
    27fa:	e8 39 0c 00 00       	call   3438 <open>
  if(fd < 0){
    27ff:	85 c0                	test   %eax,%eax
      exit();
    }
  }
  close(fd);

  fd = open("bigfile", 0);
    2801:	89 c7                	mov    %eax,%edi
  if(fd < 0){
    2803:	0f 88 f4 00 00 00    	js     28fd <bigfile+0x1ad>
    printf(1, "cannot open bigfile\n");
    exit();
    2809:	31 f6                	xor    %esi,%esi
    280b:	31 db                	xor    %ebx,%ebx
    280d:	eb 2f                	jmp    283e <bigfile+0xee>
    280f:	90                   	nop
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
      break;
    if(cc != 300){
    2810:	3d 2c 01 00 00       	cmp    $0x12c,%eax
    2815:	0f 85 97 00 00 00    	jne    28b2 <bigfile+0x162>
      printf(1, "short read bigfile\n");
      exit();
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    281b:	0f be 05 c0 75 00 00 	movsbl 0x75c0,%eax
    2822:	89 da                	mov    %ebx,%edx
    2824:	d1 fa                	sar    %edx
    2826:	39 d0                	cmp    %edx,%eax
    2828:	75 6f                	jne    2899 <bigfile+0x149>
    282a:	0f be 15 eb 76 00 00 	movsbl 0x76eb,%edx
    2831:	39 d0                	cmp    %edx,%eax
    2833:	75 64                	jne    2899 <bigfile+0x149>
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
    2835:	81 c6 2c 01 00 00    	add    $0x12c,%esi
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
  for(i = 0; ; i++){
    283b:	83 c3 01             	add    $0x1,%ebx
    cc = read(fd, buf, 300);
    283e:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    2845:	00 
    2846:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    284d:	00 
    284e:	89 3c 24             	mov    %edi,(%esp)
    2851:	e8 ba 0b 00 00       	call   3410 <read>
    if(cc < 0){
    2856:	83 f8 00             	cmp    $0x0,%eax
    2859:	7c 70                	jl     28cb <bigfile+0x17b>
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
    285b:	75 b3                	jne    2810 <bigfile+0xc0>
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
  close(fd);
    285d:	89 3c 24             	mov    %edi,(%esp)
    2860:	e8 bb 0b 00 00       	call   3420 <close>
  if(total != 20*600){
    2865:	81 fe e0 2e 00 00    	cmp    $0x2ee0,%esi
    286b:	0f 85 be 00 00 00    	jne    292f <bigfile+0x1df>
    printf(1, "read bigfile wrong total\n");
    exit();
  }
  unlink("bigfile");
    2871:	c7 04 24 58 45 00 00 	movl   $0x4558,(%esp)
    2878:	e8 cb 0b 00 00       	call   3448 <unlink>

  printf(1, "bigfile test ok\n");
    287d:	c7 44 24 04 e7 45 00 	movl   $0x45e7,0x4(%esp)
    2884:	00 
    2885:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    288c:	e8 af 0c 00 00       	call   3540 <printf>
}
    2891:	83 c4 1c             	add    $0x1c,%esp
    2894:	5b                   	pop    %ebx
    2895:	5e                   	pop    %esi
    2896:	5f                   	pop    %edi
    2897:	5d                   	pop    %ebp
    2898:	c3                   	ret    
    if(cc != 300){
      printf(1, "short read bigfile\n");
      exit();
    }
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
    2899:	c7 44 24 04 b4 45 00 	movl   $0x45b4,0x4(%esp)
    28a0:	00 
    28a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28a8:	e8 93 0c 00 00       	call   3540 <printf>
      exit();
    28ad:	e8 46 0b 00 00       	call   33f8 <exit>
      exit();
    }
    if(cc == 0)
      break;
    if(cc != 300){
      printf(1, "short read bigfile\n");
    28b2:	c7 44 24 04 a0 45 00 	movl   $0x45a0,0x4(%esp)
    28b9:	00 
    28ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28c1:	e8 7a 0c 00 00       	call   3540 <printf>
      exit();
    28c6:	e8 2d 0b 00 00       	call   33f8 <exit>
  }
  total = 0;
  for(i = 0; ; i++){
    cc = read(fd, buf, 300);
    if(cc < 0){
      printf(1, "read bigfile failed\n");
    28cb:	c7 44 24 04 8b 45 00 	movl   $0x458b,0x4(%esp)
    28d2:	00 
    28d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28da:	e8 61 0c 00 00       	call   3540 <printf>
      exit();
    28df:	e8 14 0b 00 00       	call   33f8 <exit>
    exit();
  }
  for(i = 0; i < 20; i++){
    memset(buf, i, 600);
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
    28e4:	c7 44 24 04 60 45 00 	movl   $0x4560,0x4(%esp)
    28eb:	00 
    28ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28f3:	e8 48 0c 00 00       	call   3540 <printf>
      exit();
    28f8:	e8 fb 0a 00 00       	call   33f8 <exit>
  }
  close(fd);

  fd = open("bigfile", 0);
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    28fd:	c7 44 24 04 76 45 00 	movl   $0x4576,0x4(%esp)
    2904:	00 
    2905:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    290c:	e8 2f 0c 00 00       	call   3540 <printf>
    exit();
    2911:	e8 e2 0a 00 00       	call   33f8 <exit>
  printf(1, "bigfile test\n");

  unlink("bigfile");
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    2916:	c7 44 24 04 4a 45 00 	movl   $0x454a,0x4(%esp)
    291d:	00 
    291e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2925:	e8 16 0c 00 00       	call   3540 <printf>
    exit();
    292a:	e8 c9 0a 00 00       	call   33f8 <exit>
    }
    total += cc;
  }
  close(fd);
  if(total != 20*600){
    printf(1, "read bigfile wrong total\n");
    292f:	c7 44 24 04 cd 45 00 	movl   $0x45cd,0x4(%esp)
    2936:	00 
    2937:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    293e:	e8 fd 0b 00 00       	call   3540 <printf>
    exit();
    2943:	e8 b0 0a 00 00       	call   33f8 <exit>
    2948:	90                   	nop
    2949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00002950 <concreate>:
}

// test concurrent create and unlink of the same file
void
concreate(void)
{
    2950:	55                   	push   %ebp
    2951:	89 e5                	mov    %esp,%ebp
    2953:	57                   	push   %edi
    2954:	56                   	push   %esi
    2955:	53                   	push   %ebx
    char name[14];
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
    2956:	31 db                	xor    %ebx,%ebx
}

// test concurrent create and unlink of the same file
void
concreate(void)
{
    2958:	83 ec 6c             	sub    $0x6c,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    295b:	c7 44 24 04 f8 45 00 	movl   $0x45f8,0x4(%esp)
    2962:	00 
    2963:	8d 7d e5             	lea    -0x1b(%ebp),%edi
    2966:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    296d:	e8 ce 0b 00 00       	call   3540 <printf>
  file[0] = 'C';
    2972:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    2976:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
    297a:	eb 4f                	jmp    29cb <concreate+0x7b>
    297c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(i = 0; i < 40; i++){
    file[1] = '0' + i;
    unlink(file);
    pid = fork();
    if(pid && (i % 3) == 1){
    2980:	b8 56 55 55 55       	mov    $0x55555556,%eax
    2985:	f7 eb                	imul   %ebx
    2987:	89 d8                	mov    %ebx,%eax
    2989:	c1 f8 1f             	sar    $0x1f,%eax
    298c:	29 c2                	sub    %eax,%edx
    298e:	8d 04 52             	lea    (%edx,%edx,2),%eax
    2991:	89 da                	mov    %ebx,%edx
    2993:	29 c2                	sub    %eax,%edx
    2995:	83 fa 01             	cmp    $0x1,%edx
    2998:	74 7e                	je     2a18 <concreate+0xc8>
      link("C0", file);
    } else if(pid == 0 && (i % 5) == 1){
      link("C0", file);
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    299a:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    29a1:	00 
    29a2:	89 3c 24             	mov    %edi,(%esp)
    29a5:	e8 8e 0a 00 00       	call   3438 <open>
      if(fd < 0){
    29aa:	85 c0                	test   %eax,%eax
    29ac:	0f 88 e3 01 00 00    	js     2b95 <concreate+0x245>
        printf(1, "concreate create %s failed\n", file);
        exit();
      }
      close(fd);
    29b2:	89 04 24             	mov    %eax,(%esp)
    29b5:	e8 66 0a 00 00       	call   3420 <close>
    }
    if(pid == 0)
    29ba:	85 f6                	test   %esi,%esi
    29bc:	74 52                	je     2a10 <concreate+0xc0>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    29be:	83 c3 01             	add    $0x1,%ebx
      close(fd);
    }
    if(pid == 0)
      exit();
    else
      wait();
    29c1:	e8 3a 0a 00 00       	call   3400 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    29c6:	83 fb 28             	cmp    $0x28,%ebx
    29c9:	74 6d                	je     2a38 <concreate+0xe8>
    file[1] = '0' + i;
    29cb:	8d 43 30             	lea    0x30(%ebx),%eax
    29ce:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    29d1:	89 3c 24             	mov    %edi,(%esp)
    29d4:	e8 6f 0a 00 00       	call   3448 <unlink>
    pid = fork();
    29d9:	e8 12 0a 00 00       	call   33f0 <fork>
    if(pid && (i % 3) == 1){
    29de:	85 c0                	test   %eax,%eax
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    file[1] = '0' + i;
    unlink(file);
    pid = fork();
    29e0:	89 c6                	mov    %eax,%esi
    if(pid && (i % 3) == 1){
    29e2:	75 9c                	jne    2980 <concreate+0x30>
      link("C0", file);
    } else if(pid == 0 && (i % 5) == 1){
    29e4:	b8 67 66 66 66       	mov    $0x66666667,%eax
    29e9:	f7 eb                	imul   %ebx
    29eb:	89 d8                	mov    %ebx,%eax
    29ed:	c1 f8 1f             	sar    $0x1f,%eax
    29f0:	d1 fa                	sar    %edx
    29f2:	29 c2                	sub    %eax,%edx
    29f4:	8d 04 92             	lea    (%edx,%edx,4),%eax
    29f7:	89 da                	mov    %ebx,%edx
    29f9:	29 c2                	sub    %eax,%edx
    29fb:	83 fa 01             	cmp    $0x1,%edx
    29fe:	75 9a                	jne    299a <concreate+0x4a>
      link("C0", file);
    2a00:	89 7c 24 04          	mov    %edi,0x4(%esp)
    2a04:	c7 04 24 08 46 00 00 	movl   $0x4608,(%esp)
    2a0b:	e8 48 0a 00 00       	call   3458 <link>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
      i = de.name[1] - '0';
      if(i < 0 || i >= sizeof(fa)){
        printf(1, "concreate weird file %s\n", de.name);
        exit();
    2a10:	e8 e3 09 00 00       	call   33f8 <exit>
    2a15:	8d 76 00             	lea    0x0(%esi),%esi
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    2a18:	83 c3 01             	add    $0x1,%ebx
    file[1] = '0' + i;
    unlink(file);
    pid = fork();
    if(pid && (i % 3) == 1){
      link("C0", file);
    2a1b:	89 7c 24 04          	mov    %edi,0x4(%esp)
    2a1f:	c7 04 24 08 46 00 00 	movl   $0x4608,(%esp)
    2a26:	e8 2d 0a 00 00       	call   3458 <link>
      close(fd);
    }
    if(pid == 0)
      exit();
    else
      wait();
    2a2b:	e8 d0 09 00 00       	call   3400 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    2a30:	83 fb 28             	cmp    $0x28,%ebx
    2a33:	75 96                	jne    29cb <concreate+0x7b>
    2a35:	8d 76 00             	lea    0x0(%esi),%esi
      exit();
    else
      wait();
  }

  memset(fa, 0, sizeof(fa));
    2a38:	8d 45 ac             	lea    -0x54(%ebp),%eax
    2a3b:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    2a42:	00 
    2a43:	8d 75 d4             	lea    -0x2c(%ebp),%esi
    2a46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2a4d:	00 
    2a4e:	89 04 24             	mov    %eax,(%esp)
    2a51:	e8 1a 08 00 00       	call   3270 <memset>
  fd = open(".", 0);
    2a56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2a5d:	00 
    2a5e:	c7 04 24 66 3f 00 00 	movl   $0x3f66,(%esp)
    2a65:	e8 ce 09 00 00       	call   3438 <open>
    2a6a:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
    2a71:	89 c3                	mov    %eax,%ebx
    2a73:	90                   	nop
    2a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    2a78:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    2a7f:	00 
    2a80:	89 74 24 04          	mov    %esi,0x4(%esp)
    2a84:	89 1c 24             	mov    %ebx,(%esp)
    2a87:	e8 84 09 00 00       	call   3410 <read>
    2a8c:	85 c0                	test   %eax,%eax
    2a8e:	7e 40                	jle    2ad0 <concreate+0x180>
    if(de.inum == 0)
    2a90:	66 83 7d d4 00       	cmpw   $0x0,-0x2c(%ebp)
    2a95:	74 e1                	je     2a78 <concreate+0x128>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    2a97:	80 7d d6 43          	cmpb   $0x43,-0x2a(%ebp)
    2a9b:	90                   	nop
    2a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    2aa0:	75 d6                	jne    2a78 <concreate+0x128>
    2aa2:	80 7d d8 00          	cmpb   $0x0,-0x28(%ebp)
    2aa6:	75 d0                	jne    2a78 <concreate+0x128>
      i = de.name[1] - '0';
    2aa8:	0f be 45 d7          	movsbl -0x29(%ebp),%eax
    2aac:	83 e8 30             	sub    $0x30,%eax
      if(i < 0 || i >= sizeof(fa)){
    2aaf:	83 f8 27             	cmp    $0x27,%eax
    2ab2:	0f 87 fa 00 00 00    	ja     2bb2 <concreate+0x262>
        printf(1, "concreate weird file %s\n", de.name);
        exit();
      }
      if(fa[i]){
    2ab8:	80 7c 05 ac 00       	cmpb   $0x0,-0x54(%ebp,%eax,1)
    2abd:	0f 85 28 01 00 00    	jne    2beb <concreate+0x29b>
        printf(1, "concreate duplicate file %s\n", de.name);
        exit();
      }
      fa[i] = 1;
    2ac3:	c6 44 05 ac 01       	movb   $0x1,-0x54(%ebp,%eax,1)
      n++;
    2ac8:	83 45 a4 01          	addl   $0x1,-0x5c(%ebp)
    2acc:	eb aa                	jmp    2a78 <concreate+0x128>
    2ace:	66 90                	xchg   %ax,%ax
    }
  }
  close(fd);
    2ad0:	89 1c 24             	mov    %ebx,(%esp)
    2ad3:	e8 48 09 00 00       	call   3420 <close>

  if(n != 40){
    2ad8:	83 7d a4 28          	cmpl   $0x28,-0x5c(%ebp)
    2adc:	0f 85 f0 00 00 00    	jne    2bd2 <concreate+0x282>
    printf(1, "concreate not enough files in directory listing\n");
    exit();
    2ae2:	31 db                	xor    %ebx,%ebx
    2ae4:	eb 3d                	jmp    2b23 <concreate+0x1d3>
    2ae6:	66 90                	xchg   %ax,%ax
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    2ae8:	83 f8 01             	cmp    $0x1,%eax
    2aeb:	90                   	nop
    2aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    2af0:	75 5d                	jne    2b4f <concreate+0x1ff>
    2af2:	85 f6                	test   %esi,%esi
    2af4:	74 59                	je     2b4f <concreate+0x1ff>
       ((i % 3) == 1 && pid != 0)){
      fd = open(file, 0);
    2af6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2afd:	00 
    2afe:	89 3c 24             	mov    %edi,(%esp)
    2b01:	e8 32 09 00 00       	call   3438 <open>
      close(fd);
    2b06:	89 04 24             	mov    %eax,(%esp)
    2b09:	e8 12 09 00 00       	call   3420 <close>
    } else {
      unlink(file);
    }
    if(pid == 0)
    2b0e:	85 f6                	test   %esi,%esi
    2b10:	0f 84 fa fe ff ff    	je     2a10 <concreate+0xc0>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    2b16:	83 c3 01             	add    $0x1,%ebx
      unlink(file);
    }
    if(pid == 0)
      exit();
    else
      wait();
    2b19:	e8 e2 08 00 00       	call   3400 <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    2b1e:	83 fb 28             	cmp    $0x28,%ebx
    2b21:	74 3d                	je     2b60 <concreate+0x210>
    file[1] = '0' + i;
    2b23:	8d 43 30             	lea    0x30(%ebx),%eax
    2b26:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    2b29:	e8 c2 08 00 00       	call   33f0 <fork>
    if(pid < 0){
    2b2e:	85 c0                	test   %eax,%eax
    exit();
  }

  for(i = 0; i < 40; i++){
    file[1] = '0' + i;
    pid = fork();
    2b30:	89 c6                	mov    %eax,%esi
    if(pid < 0){
    2b32:	78 48                	js     2b7c <concreate+0x22c>
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    2b34:	b8 56 55 55 55       	mov    $0x55555556,%eax
    2b39:	f7 eb                	imul   %ebx
    2b3b:	89 d8                	mov    %ebx,%eax
    2b3d:	c1 f8 1f             	sar    $0x1f,%eax
    2b40:	29 c2                	sub    %eax,%edx
    2b42:	89 d8                	mov    %ebx,%eax
    2b44:	8d 14 52             	lea    (%edx,%edx,2),%edx
    2b47:	29 d0                	sub    %edx,%eax
    2b49:	75 9d                	jne    2ae8 <concreate+0x198>
    2b4b:	85 f6                	test   %esi,%esi
    2b4d:	74 a7                	je     2af6 <concreate+0x1a6>
       ((i % 3) == 1 && pid != 0)){
      fd = open(file, 0);
      close(fd);
    } else {
      unlink(file);
    2b4f:	89 3c 24             	mov    %edi,(%esp)
    2b52:	e8 f1 08 00 00       	call   3448 <unlink>
    2b57:	eb b5                	jmp    2b0e <concreate+0x1be>
    2b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      exit();
    else
      wait();
  }

  printf(1, "concreate ok\n");
    2b60:	c7 44 24 04 5d 46 00 	movl   $0x465d,0x4(%esp)
    2b67:	00 
    2b68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b6f:	e8 cc 09 00 00       	call   3540 <printf>
}
    2b74:	83 c4 6c             	add    $0x6c,%esp
    2b77:	5b                   	pop    %ebx
    2b78:	5e                   	pop    %esi
    2b79:	5f                   	pop    %edi
    2b7a:	5d                   	pop    %ebp
    2b7b:	c3                   	ret    

  for(i = 0; i < 40; i++){
    file[1] = '0' + i;
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
    2b7c:	c7 44 24 04 d6 39 00 	movl   $0x39d6,0x4(%esp)
    2b83:	00 
    2b84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b8b:	e8 b0 09 00 00       	call   3540 <printf>
      exit();
    2b90:	e8 63 08 00 00       	call   33f8 <exit>
    } else if(pid == 0 && (i % 5) == 1){
      link("C0", file);
    } else {
      fd = open(file, O_CREATE | O_RDWR);
      if(fd < 0){
        printf(1, "concreate create %s failed\n", file);
    2b95:	89 7c 24 08          	mov    %edi,0x8(%esp)
    2b99:	c7 44 24 04 0b 46 00 	movl   $0x460b,0x4(%esp)
    2ba0:	00 
    2ba1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ba8:	e8 93 09 00 00       	call   3540 <printf>
        exit();
    2bad:	e8 46 08 00 00       	call   33f8 <exit>
    if(de.inum == 0)
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
      i = de.name[1] - '0';
      if(i < 0 || i >= sizeof(fa)){
        printf(1, "concreate weird file %s\n", de.name);
    2bb2:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    2bb5:	89 44 24 08          	mov    %eax,0x8(%esp)
    2bb9:	c7 44 24 04 27 46 00 	movl   $0x4627,0x4(%esp)
    2bc0:	00 
    2bc1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bc8:	e8 73 09 00 00       	call   3540 <printf>
    2bcd:	e9 3e fe ff ff       	jmp    2a10 <concreate+0xc0>
    }
  }
  close(fd);

  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    2bd2:	c7 44 24 04 5c 4d 00 	movl   $0x4d5c,0x4(%esp)
    2bd9:	00 
    2bda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2be1:	e8 5a 09 00 00       	call   3540 <printf>
    exit();
    2be6:	e8 0d 08 00 00       	call   33f8 <exit>
      if(i < 0 || i >= sizeof(fa)){
        printf(1, "concreate weird file %s\n", de.name);
        exit();
      }
      if(fa[i]){
        printf(1, "concreate duplicate file %s\n", de.name);
    2beb:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    2bee:	89 44 24 08          	mov    %eax,0x8(%esp)
    2bf2:	c7 44 24 04 40 46 00 	movl   $0x4640,0x4(%esp)
    2bf9:	00 
    2bfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c01:	e8 3a 09 00 00       	call   3540 <printf>
        exit();
    2c06:	e8 ed 07 00 00       	call   33f8 <exit>
    2c0b:	90                   	nop
    2c0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00002c10 <twofiles>:

// two processes write two different files at the same
// time, to test block allocation.
void
twofiles(void)
{
    2c10:	55                   	push   %ebp
    2c11:	89 e5                	mov    %esp,%ebp
    2c13:	57                   	push   %edi
    2c14:	56                   	push   %esi
    2c15:	53                   	push   %ebx
    2c16:	83 ec 2c             	sub    $0x2c,%esp
  int fd, pid, i, j, n, total;
  char *fname;

  printf(1, "twofiles test\n");
    2c19:	c7 44 24 04 6b 46 00 	movl   $0x466b,0x4(%esp)
    2c20:	00 
    2c21:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c28:	e8 13 09 00 00       	call   3540 <printf>

  unlink("f1");
    2c2d:	c7 04 24 b2 41 00 00 	movl   $0x41b2,(%esp)
    2c34:	e8 0f 08 00 00       	call   3448 <unlink>
  unlink("f2");
    2c39:	c7 04 24 b6 41 00 00 	movl   $0x41b6,(%esp)
    2c40:	e8 03 08 00 00       	call   3448 <unlink>

  pid = fork();
    2c45:	e8 a6 07 00 00       	call   33f0 <fork>
  if(pid < 0){
    2c4a:	83 f8 00             	cmp    $0x0,%eax
  printf(1, "twofiles test\n");

  unlink("f1");
  unlink("f2");

  pid = fork();
    2c4d:	89 c7                	mov    %eax,%edi
  if(pid < 0){
    2c4f:	0f 8c 64 01 00 00    	jl     2db9 <twofiles+0x1a9>
    printf(1, "fork failed\n");
    return;
  }

  fname = pid ? "f1" : "f2";
    2c55:	b8 b2 41 00 00       	mov    $0x41b2,%eax
    2c5a:	75 05                	jne    2c61 <twofiles+0x51>
    2c5c:	b8 b6 41 00 00       	mov    $0x41b6,%eax
  fd = open(fname, O_CREATE | O_RDWR);
    2c61:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2c68:	00 
    2c69:	89 04 24             	mov    %eax,(%esp)
    2c6c:	e8 c7 07 00 00       	call   3438 <open>
  if(fd < 0){
    2c71:	85 c0                	test   %eax,%eax
    printf(1, "fork failed\n");
    return;
  }

  fname = pid ? "f1" : "f2";
  fd = open(fname, O_CREATE | O_RDWR);
    2c73:	89 c6                	mov    %eax,%esi
  if(fd < 0){
    2c75:	0f 88 8e 01 00 00    	js     2e09 <twofiles+0x1f9>
    printf(1, "create failed\n");
    exit();
  }

  memset(buf, pid?'p':'c', 512);
    2c7b:	83 ff 01             	cmp    $0x1,%edi
    2c7e:	19 c0                	sbb    %eax,%eax
    2c80:	31 db                	xor    %ebx,%ebx
    2c82:	83 e0 f3             	and    $0xfffffff3,%eax
    2c85:	83 c0 70             	add    $0x70,%eax
    2c88:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    2c8f:	00 
    2c90:	89 44 24 04          	mov    %eax,0x4(%esp)
    2c94:	c7 04 24 c0 75 00 00 	movl   $0x75c0,(%esp)
    2c9b:	e8 d0 05 00 00       	call   3270 <memset>
  for(i = 0; i < 12; i++){
    if((n = write(fd, buf, 500)) != 500){
    2ca0:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
    2ca7:	00 
    2ca8:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    2caf:	00 
    2cb0:	89 34 24             	mov    %esi,(%esp)
    2cb3:	e8 60 07 00 00       	call   3418 <write>
    2cb8:	3d f4 01 00 00       	cmp    $0x1f4,%eax
    2cbd:	0f 85 29 01 00 00    	jne    2dec <twofiles+0x1dc>
    printf(1, "create failed\n");
    exit();
  }

  memset(buf, pid?'p':'c', 512);
  for(i = 0; i < 12; i++){
    2cc3:	83 c3 01             	add    $0x1,%ebx
    2cc6:	83 fb 0c             	cmp    $0xc,%ebx
    2cc9:	75 d5                	jne    2ca0 <twofiles+0x90>
    if((n = write(fd, buf, 500)) != 500){
      printf(1, "write failed %d\n", n);
      exit();
    }
  }
  close(fd);
    2ccb:	89 34 24             	mov    %esi,(%esp)
    2cce:	e8 4d 07 00 00       	call   3420 <close>
  if(pid)
    2cd3:	85 ff                	test   %edi,%edi
    2cd5:	0f 84 d9 00 00 00    	je     2db4 <twofiles+0x1a4>
    wait();
    2cdb:	e8 20 07 00 00       	call   3400 <wait>
    2ce0:	30 db                	xor    %bl,%bl
    2ce2:	b8 b6 41 00 00       	mov    $0x41b6,%eax
  else
    exit();

  for(i = 0; i < 2; i++){
    fd = open(i?"f1":"f2", 0);
    2ce7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2cee:	00 
    2cef:	31 f6                	xor    %esi,%esi
    2cf1:	89 04 24             	mov    %eax,(%esp)
    2cf4:	e8 3f 07 00 00       	call   3438 <open>
    2cf9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    2cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2d00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    2d03:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
    2d0a:	00 
    2d0b:	c7 44 24 04 c0 75 00 	movl   $0x75c0,0x4(%esp)
    2d12:	00 
    2d13:	89 04 24             	mov    %eax,(%esp)
    2d16:	e8 f5 06 00 00       	call   3410 <read>
    2d1b:	85 c0                	test   %eax,%eax
    2d1d:	7e 2a                	jle    2d49 <twofiles+0x139>
    2d1f:	31 c9                	xor    %ecx,%ecx
    2d21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      for(j = 0; j < n; j++){
        if(buf[j] != (i?'p':'c')){
    2d28:	83 fb 01             	cmp    $0x1,%ebx
    2d2b:	0f be b9 c0 75 00 00 	movsbl 0x75c0(%ecx),%edi
    2d32:	19 d2                	sbb    %edx,%edx
    2d34:	83 e2 f3             	and    $0xfffffff3,%edx
    2d37:	83 c2 70             	add    $0x70,%edx
    2d3a:	39 d7                	cmp    %edx,%edi
    2d3c:	75 62                	jne    2da0 <twofiles+0x190>

  for(i = 0; i < 2; i++){
    fd = open(i?"f1":"f2", 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
    2d3e:	83 c1 01             	add    $0x1,%ecx
    2d41:	39 c8                	cmp    %ecx,%eax
    2d43:	7f e3                	jg     2d28 <twofiles+0x118>
        if(buf[j] != (i?'p':'c')){
          printf(1, "wrong char\n");
          exit();
        }
      }
      total += n;
    2d45:	01 c6                	add    %eax,%esi
    2d47:	eb b7                	jmp    2d00 <twofiles+0xf0>
    }
    close(fd);
    2d49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    2d4c:	89 04 24             	mov    %eax,(%esp)
    2d4f:	e8 cc 06 00 00       	call   3420 <close>
    if(total != 12*500){
    2d54:	81 fe 70 17 00 00    	cmp    $0x1770,%esi
    2d5a:	75 73                	jne    2dcf <twofiles+0x1bf>
  if(pid)
    wait();
  else
    exit();

  for(i = 0; i < 2; i++){
    2d5c:	83 fb 01             	cmp    $0x1,%ebx
      total += n;
    }
    close(fd);
    if(total != 12*500){
      printf(1, "wrong length %d\n", total);
      exit();
    2d5f:	b8 b2 41 00 00       	mov    $0x41b2,%eax
  if(pid)
    wait();
  else
    exit();

  for(i = 0; i < 2; i++){
    2d64:	75 30                	jne    2d96 <twofiles+0x186>
      printf(1, "wrong length %d\n", total);
      exit();
    }
  }

  unlink("f1");
    2d66:	89 04 24             	mov    %eax,(%esp)
    2d69:	e8 da 06 00 00       	call   3448 <unlink>
  unlink("f2");
    2d6e:	c7 04 24 b6 41 00 00 	movl   $0x41b6,(%esp)
    2d75:	e8 ce 06 00 00       	call   3448 <unlink>

  printf(1, "twofiles ok\n");
    2d7a:	c7 44 24 04 a8 46 00 	movl   $0x46a8,0x4(%esp)
    2d81:	00 
    2d82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d89:	e8 b2 07 00 00       	call   3540 <printf>
}
    2d8e:	83 c4 2c             	add    $0x2c,%esp
    2d91:	5b                   	pop    %ebx
    2d92:	5e                   	pop    %esi
    2d93:	5f                   	pop    %edi
    2d94:	5d                   	pop    %ebp
    2d95:	c3                   	ret    
  }
  close(fd);
  if(pid)
    wait();
  else
    exit();
    2d96:	bb 01 00 00 00       	mov    $0x1,%ebx
    2d9b:	e9 47 ff ff ff       	jmp    2ce7 <twofiles+0xd7>
    fd = open(i?"f1":"f2", 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
        if(buf[j] != (i?'p':'c')){
          printf(1, "wrong char\n");
    2da0:	c7 44 24 04 8b 46 00 	movl   $0x468b,0x4(%esp)
    2da7:	00 
    2da8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2daf:	e8 8c 07 00 00       	call   3540 <printf>
          exit();
    2db4:	e8 3f 06 00 00       	call   33f8 <exit>
  unlink("f1");
  unlink("f2");

  pid = fork();
  if(pid < 0){
    printf(1, "fork failed\n");
    2db9:	c7 44 24 04 d6 39 00 	movl   $0x39d6,0x4(%esp)
    2dc0:	00 
    2dc1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dc8:	e8 73 07 00 00       	call   3540 <printf>
    return;
    2dcd:	eb bf                	jmp    2d8e <twofiles+0x17e>
      }
      total += n;
    }
    close(fd);
    if(total != 12*500){
      printf(1, "wrong length %d\n", total);
    2dcf:	89 74 24 08          	mov    %esi,0x8(%esp)
    2dd3:	c7 44 24 04 97 46 00 	movl   $0x4697,0x4(%esp)
    2dda:	00 
    2ddb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2de2:	e8 59 07 00 00       	call   3540 <printf>
      exit();
    2de7:	e8 0c 06 00 00       	call   33f8 <exit>
  }

  memset(buf, pid?'p':'c', 512);
  for(i = 0; i < 12; i++){
    if((n = write(fd, buf, 500)) != 500){
      printf(1, "write failed %d\n", n);
    2dec:	89 44 24 08          	mov    %eax,0x8(%esp)
    2df0:	c7 44 24 04 7a 46 00 	movl   $0x467a,0x4(%esp)
    2df7:	00 
    2df8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dff:	e8 3c 07 00 00       	call   3540 <printf>
      exit();
    2e04:	e8 ef 05 00 00       	call   33f8 <exit>
  }

  fname = pid ? "f1" : "f2";
  fd = open(fname, O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "create failed\n");
    2e09:	c7 44 24 04 64 41 00 	movl   $0x4164,0x4(%esp)
    2e10:	00 
    2e11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e18:	e8 23 07 00 00       	call   3540 <printf>
    exit();
    2e1d:	e8 d6 05 00 00       	call   33f8 <exit>
    2e22:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    2e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00002e30 <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
    2e30:	55                   	push   %ebp
    2e31:	89 e5                	mov    %esp,%ebp
    2e33:	57                   	push   %edi
    2e34:	56                   	push   %esi
    2e35:	53                   	push   %ebx
    2e36:	83 ec 3c             	sub    $0x3c,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  unlink("sharedfd");
    2e39:	c7 04 24 b5 46 00 00 	movl   $0x46b5,(%esp)
    2e40:	e8 03 06 00 00       	call   3448 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    2e45:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2e4c:	00 
    2e4d:	c7 04 24 b5 46 00 00 	movl   $0x46b5,(%esp)
    2e54:	e8 df 05 00 00       	call   3438 <open>
  if(fd < 0){
    2e59:	85 c0                	test   %eax,%eax
{
  int fd, pid, i, n, nc, np;
  char buf[10];

  unlink("sharedfd");
  fd = open("sharedfd", O_CREATE|O_RDWR);
    2e5b:	89 c7                	mov    %eax,%edi
  if(fd < 0){
    2e5d:	0f 88 55 01 00 00    	js     2fb8 <sharedfd+0x188>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
    2e63:	e8 88 05 00 00       	call   33f0 <fork>
  memset(buf, pid==0?'c':'p', sizeof(buf));
    2e68:	8d 75 de             	lea    -0x22(%ebp),%esi
    2e6b:	83 f8 01             	cmp    $0x1,%eax
  fd = open("sharedfd", O_CREATE|O_RDWR);
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
    2e6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
    2e71:	19 c0                	sbb    %eax,%eax
    2e73:	31 db                	xor    %ebx,%ebx
    2e75:	83 e0 f3             	and    $0xfffffff3,%eax
    2e78:	83 c0 70             	add    $0x70,%eax
    2e7b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    2e82:	00 
    2e83:	89 44 24 04          	mov    %eax,0x4(%esp)
    2e87:	89 34 24             	mov    %esi,(%esp)
    2e8a:	e8 e1 03 00 00       	call   3270 <memset>
    2e8f:	eb 12                	jmp    2ea3 <sharedfd+0x73>
    2e91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(i = 0; i < 1000; i++){
    2e98:	83 c3 01             	add    $0x1,%ebx
    2e9b:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
    2ea1:	74 2d                	je     2ed0 <sharedfd+0xa0>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    2ea3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    2eaa:	00 
    2eab:	89 74 24 04          	mov    %esi,0x4(%esp)
    2eaf:	89 3c 24             	mov    %edi,(%esp)
    2eb2:	e8 61 05 00 00       	call   3418 <write>
    2eb7:	83 f8 0a             	cmp    $0xa,%eax
    2eba:	74 dc                	je     2e98 <sharedfd+0x68>
      printf(1, "fstests: write sharedfd failed\n");
    2ebc:	c7 44 24 04 bc 4d 00 	movl   $0x4dbc,0x4(%esp)
    2ec3:	00 
    2ec4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ecb:	e8 70 06 00 00       	call   3540 <printf>
      break;
    }
  }
  if(pid == 0)
    2ed0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
    2ed3:	85 d2                	test   %edx,%edx
    2ed5:	0f 84 0f 01 00 00    	je     2fea <sharedfd+0x1ba>
    exit();
  else
    wait();
    2edb:	e8 20 05 00 00       	call   3400 <wait>
  close(fd);
  fd = open("sharedfd", 0);
  if(fd < 0){
    2ee0:	31 db                	xor    %ebx,%ebx
  }
  if(pid == 0)
    exit();
  else
    wait();
  close(fd);
    2ee2:	89 3c 24             	mov    %edi,(%esp)
  fd = open("sharedfd", 0);
  if(fd < 0){
    2ee5:	31 ff                	xor    %edi,%edi
  }
  if(pid == 0)
    exit();
  else
    wait();
  close(fd);
    2ee7:	e8 34 05 00 00       	call   3420 <close>
  fd = open("sharedfd", 0);
    2eec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2ef3:	00 
    2ef4:	c7 04 24 b5 46 00 00 	movl   $0x46b5,(%esp)
    2efb:	e8 38 05 00 00       	call   3438 <open>
  if(fd < 0){
    2f00:	85 c0                	test   %eax,%eax
  if(pid == 0)
    exit();
  else
    wait();
  close(fd);
  fd = open("sharedfd", 0);
    2f02:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  if(fd < 0){
    2f05:	0f 88 c9 00 00 00    	js     2fd4 <sharedfd+0x1a4>
    2f0b:	90                   	nop
    2f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    2f10:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    2f17:	00 
    2f18:	89 74 24 04          	mov    %esi,0x4(%esp)
    2f1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    2f1f:	89 04 24             	mov    %eax,(%esp)
    2f22:	e8 e9 04 00 00       	call   3410 <read>
    2f27:	85 c0                	test   %eax,%eax
    2f29:	7e 26                	jle    2f51 <sharedfd+0x121>
    wait();
  close(fd);
  fd = open("sharedfd", 0);
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
    2f2b:	31 c0                	xor    %eax,%eax
    2f2d:	eb 14                	jmp    2f43 <sharedfd+0x113>
    2f2f:	90                   	nop
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
      if(buf[i] == 'c')
        nc++;
      if(buf[i] == 'p')
        np++;
    2f30:	80 fa 70             	cmp    $0x70,%dl
    2f33:	0f 94 c2             	sete   %dl
    2f36:	0f b6 d2             	movzbl %dl,%edx
    2f39:	01 d3                	add    %edx,%ebx
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
    2f3b:	83 c0 01             	add    $0x1,%eax
    2f3e:	83 f8 0a             	cmp    $0xa,%eax
    2f41:	74 cd                	je     2f10 <sharedfd+0xe0>
      if(buf[i] == 'c')
    2f43:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
    2f47:	80 fa 63             	cmp    $0x63,%dl
    2f4a:	75 e4                	jne    2f30 <sharedfd+0x100>
        nc++;
    2f4c:	83 c7 01             	add    $0x1,%edi
    2f4f:	eb ea                	jmp    2f3b <sharedfd+0x10b>
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
    2f51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    2f54:	89 04 24             	mov    %eax,(%esp)
    2f57:	e8 c4 04 00 00       	call   3420 <close>
  unlink("sharedfd");
    2f5c:	c7 04 24 b5 46 00 00 	movl   $0x46b5,(%esp)
    2f63:	e8 e0 04 00 00       	call   3448 <unlink>
  if(nc == 10000 && np == 10000)
    2f68:	81 fb 10 27 00 00    	cmp    $0x2710,%ebx
    2f6e:	74 24                	je     2f94 <sharedfd+0x164>
    printf(1, "sharedfd ok\n");
  else
    printf(1, "sharedfd oops %d %d\n", nc, np);
    2f70:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
    2f74:	89 7c 24 08          	mov    %edi,0x8(%esp)
    2f78:	c7 44 24 04 cb 46 00 	movl   $0x46cb,0x4(%esp)
    2f7f:	00 
    2f80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f87:	e8 b4 05 00 00       	call   3540 <printf>
}
    2f8c:	83 c4 3c             	add    $0x3c,%esp
    2f8f:	5b                   	pop    %ebx
    2f90:	5e                   	pop    %esi
    2f91:	5f                   	pop    %edi
    2f92:	5d                   	pop    %ebp
    2f93:	c3                   	ret    
        np++;
    }
  }
  close(fd);
  unlink("sharedfd");
  if(nc == 10000 && np == 10000)
    2f94:	81 ff 10 27 00 00    	cmp    $0x2710,%edi
    2f9a:	75 d4                	jne    2f70 <sharedfd+0x140>
    printf(1, "sharedfd ok\n");
    2f9c:	c7 44 24 04 be 46 00 	movl   $0x46be,0x4(%esp)
    2fa3:	00 
    2fa4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fab:	e8 90 05 00 00       	call   3540 <printf>
  else
    printf(1, "sharedfd oops %d %d\n", nc, np);
}
    2fb0:	83 c4 3c             	add    $0x3c,%esp
    2fb3:	5b                   	pop    %ebx
    2fb4:	5e                   	pop    %esi
    2fb5:	5f                   	pop    %edi
    2fb6:	5d                   	pop    %ebp
    2fb7:	c3                   	ret    
  char buf[10];

  unlink("sharedfd");
  fd = open("sharedfd", O_CREATE|O_RDWR);
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for writing");
    2fb8:	c7 44 24 04 90 4d 00 	movl   $0x4d90,0x4(%esp)
    2fbf:	00 
    2fc0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fc7:	e8 74 05 00 00       	call   3540 <printf>
  unlink("sharedfd");
  if(nc == 10000 && np == 10000)
    printf(1, "sharedfd ok\n");
  else
    printf(1, "sharedfd oops %d %d\n", nc, np);
}
    2fcc:	83 c4 3c             	add    $0x3c,%esp
    2fcf:	5b                   	pop    %ebx
    2fd0:	5e                   	pop    %esi
    2fd1:	5f                   	pop    %edi
    2fd2:	5d                   	pop    %ebp
    2fd3:	c3                   	ret    
  else
    wait();
  close(fd);
  fd = open("sharedfd", 0);
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    2fd4:	c7 44 24 04 dc 4d 00 	movl   $0x4ddc,0x4(%esp)
    2fdb:	00 
    2fdc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fe3:	e8 58 05 00 00       	call   3540 <printf>
    return;
    2fe8:	eb a2                	jmp    2f8c <sharedfd+0x15c>
      printf(1, "fstests: write sharedfd failed\n");
      break;
    }
  }
  if(pid == 0)
    exit();
    2fea:	e8 09 04 00 00       	call   33f8 <exit>
    2fef:	90                   	nop

00002ff0 <mem>:
  printf(1, "exitwait ok\n");
}

void
mem(void)
{
    2ff0:	55                   	push   %ebp
    2ff1:	89 e5                	mov    %esp,%ebp
    2ff3:	57                   	push   %edi
    2ff4:	56                   	push   %esi
    2ff5:	53                   	push   %ebx
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    2ff6:	31 db                	xor    %ebx,%ebx
  printf(1, "exitwait ok\n");
}

void
mem(void)
{
    2ff8:	83 ec 1c             	sub    $0x1c,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
    2ffb:	c7 44 24 04 e0 46 00 	movl   $0x46e0,0x4(%esp)
    3002:	00 
    3003:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    300a:	e8 31 05 00 00       	call   3540 <printf>
  ppid = getpid();
    300f:	e8 64 04 00 00       	call   3478 <getpid>
    3014:	89 c6                	mov    %eax,%esi
  if((pid = fork()) == 0){
    3016:	e8 d5 03 00 00       	call   33f0 <fork>
    301b:	85 c0                	test   %eax,%eax
    301d:	74 0d                	je     302c <mem+0x3c>
    301f:	90                   	nop
    3020:	eb 5f                	jmp    3081 <mem+0x91>
    3022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
    3028:	89 18                	mov    %ebx,(%eax)
    302a:	89 c3                	mov    %eax,%ebx

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
    302c:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
    3033:	e8 a8 07 00 00       	call   37e0 <malloc>
    3038:	85 c0                	test   %eax,%eax
    303a:	75 ec                	jne    3028 <mem+0x38>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
    303c:	85 db                	test   %ebx,%ebx
    303e:	74 10                	je     3050 <mem+0x60>
      m2 = *(char**)m1;
    3040:	8b 3b                	mov    (%ebx),%edi
      free(m1);
    3042:	89 1c 24             	mov    %ebx,(%esp)
    3045:	e8 06 07 00 00       	call   3750 <free>
    304a:	89 fb                	mov    %edi,%ebx
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
    304c:	85 db                	test   %ebx,%ebx
    304e:	75 f0                	jne    3040 <mem+0x50>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
    3050:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
    3057:	e8 84 07 00 00       	call   37e0 <malloc>
    if(m1 == 0){
    305c:	85 c0                	test   %eax,%eax
    305e:	74 30                	je     3090 <mem+0xa0>
      printf(1, "couldn't allocate mem?!!\n");
      kill(ppid);
      exit();
    }
    free(m1);
    3060:	89 04 24             	mov    %eax,(%esp)
    3063:	e8 e8 06 00 00       	call   3750 <free>
    printf(1, "mem ok\n");
    3068:	c7 44 24 04 04 47 00 	movl   $0x4704,0x4(%esp)
    306f:	00 
    3070:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3077:	e8 c4 04 00 00       	call   3540 <printf>
    exit();
    307c:	e8 77 03 00 00       	call   33f8 <exit>
  } else {
    wait();
  }
}
    3081:	83 c4 1c             	add    $0x1c,%esp
    3084:	5b                   	pop    %ebx
    3085:	5e                   	pop    %esi
    3086:	5f                   	pop    %edi
    3087:	5d                   	pop    %ebp
    }
    free(m1);
    printf(1, "mem ok\n");
    exit();
  } else {
    wait();
    3088:	e9 73 03 00 00       	jmp    3400 <wait>
    308d:	8d 76 00             	lea    0x0(%esi),%esi
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
    if(m1 == 0){
      printf(1, "couldn't allocate mem?!!\n");
    3090:	c7 44 24 04 ea 46 00 	movl   $0x46ea,0x4(%esp)
    3097:	00 
    3098:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    309f:	e8 9c 04 00 00       	call   3540 <printf>
      kill(ppid);
    30a4:	89 34 24             	mov    %esi,(%esp)
    30a7:	e8 7c 03 00 00       	call   3428 <kill>
      exit();
    30ac:	e8 47 03 00 00       	call   33f8 <exit>
    30b1:	eb 0d                	jmp    30c0 <main>
    30b3:	90                   	nop
    30b4:	90                   	nop
    30b5:	90                   	nop
    30b6:	90                   	nop
    30b7:	90                   	nop
    30b8:	90                   	nop
    30b9:	90                   	nop
    30ba:	90                   	nop
    30bb:	90                   	nop
    30bc:	90                   	nop
    30bd:	90                   	nop
    30be:	90                   	nop
    30bf:	90                   	nop

000030c0 <main>:
  wait();
}

int
main(int argc, char *argv[])
{
    30c0:	55                   	push   %ebp
    30c1:	89 e5                	mov    %esp,%ebp
    30c3:	83 e4 f0             	and    $0xfffffff0,%esp
    30c6:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
    30c9:	c7 44 24 04 0c 47 00 	movl   $0x470c,0x4(%esp)
    30d0:	00 
    30d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30d8:	e8 63 04 00 00       	call   3540 <printf>

  if(open("usertests.ran", 0) >= 0){
    30dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    30e4:	00 
    30e5:	c7 04 24 20 47 00 00 	movl   $0x4720,(%esp)
    30ec:	e8 47 03 00 00       	call   3438 <open>
    30f1:	85 c0                	test   %eax,%eax
    30f3:	78 1b                	js     3110 <main+0x50>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    30f5:	c7 44 24 04 08 4e 00 	movl   $0x4e08,0x4(%esp)
    30fc:	00 
    30fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3104:	e8 37 04 00 00       	call   3540 <printf>
    exit();
    3109:	e8 ea 02 00 00       	call   33f8 <exit>
    310e:	66 90                	xchg   %ax,%ax
  }
  close(open("usertests.ran", O_CREATE));
    3110:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3117:	00 
    3118:	c7 04 24 20 47 00 00 	movl   $0x4720,(%esp)
    311f:	e8 14 03 00 00       	call   3438 <open>
    3124:	89 04 24             	mov    %eax,(%esp)
    3127:	e8 f4 02 00 00       	call   3420 <close>

  bigargtest();
    312c:	e8 4f d0 ff ff       	call   180 <bigargtest>
  bsstest();
    3131:	e8 da ce ff ff       	call   10 <bsstest>
  sbrktest();
    3136:	e8 05 d3 ff ff       	call   440 <sbrktest>
    313b:	90                   	nop
    313c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  validatetest();
    3140:	e8 4b d2 ff ff       	call   390 <validatetest>

  opentest();
    3145:	e8 46 cf ff ff       	call   90 <opentest>
  writetest();
    314a:	e8 f1 f3 ff ff       	call   2540 <writetest>
    314f:	90                   	nop
  writetest1();
    3150:	e8 fb f1 ff ff       	call   2350 <writetest1>
  createtest();
    3155:	e8 46 f1 ff ff       	call   22a0 <createtest>

  mem();
    315a:	e8 91 fe ff ff       	call   2ff0 <mem>
    315f:	90                   	nop
  pipe1();
    3160:	e8 eb d8 ff ff       	call   a50 <pipe1>
  preempt();
    3165:	e8 86 d7 ff ff       	call   8f0 <preempt>
  exitwait();
    316a:	e8 91 d1 ff ff       	call   300 <exitwait>
    316f:	90                   	nop

  rmdot();
    3170:	e8 4b df ff ff       	call   10c0 <rmdot>
  fourteen();
    3175:	e8 86 da ff ff       	call   c00 <fourteen>
  bigfile();
    317a:	e8 d1 f5 ff ff       	call   2750 <bigfile>
    317f:	90                   	nop
  subdir();
    3180:	e8 cb e0 ff ff       	call   1250 <subdir>
  concreate();
    3185:	e8 c6 f7 ff ff       	call   2950 <concreate>
  linktest();
    318a:	e8 a1 e9 ff ff       	call   1b30 <linktest>
    318f:	90                   	nop
  unlinkread();
    3190:	e8 fb eb ff ff       	call   1d90 <unlinkread>
  createdelete();
    3195:	e8 c6 ed ff ff       	call   1f60 <createdelete>
  twofiles();
    319a:	e8 71 fa ff ff       	call   2c10 <twofiles>
    319f:	90                   	nop
  sharedfd();
    31a0:	e8 8b fc ff ff       	call   2e30 <sharedfd>
  dirfile();
    31a5:	e8 d6 dc ff ff       	call   e80 <dirfile>
  iref();
    31aa:	e8 b1 db ff ff       	call   d60 <iref>
    31af:	90                   	nop
  forktest();
    31b0:	e8 7b d0 ff ff       	call   230 <forktest>
  bigdir(); // slow
    31b5:	e8 26 e8 ff ff       	call   19e0 <bigdir>

  exectest();
    31ba:	e8 71 cf ff ff       	call   130 <exectest>
    31bf:	90                   	nop

  exit();
    31c0:	e8 33 02 00 00       	call   33f8 <exit>
    31c5:	90                   	nop
    31c6:	90                   	nop
    31c7:	90                   	nop
    31c8:	90                   	nop
    31c9:	90                   	nop
    31ca:	90                   	nop
    31cb:	90                   	nop
    31cc:	90                   	nop
    31cd:	90                   	nop
    31ce:	90                   	nop
    31cf:	90                   	nop

000031d0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    31d0:	55                   	push   %ebp
    31d1:	31 d2                	xor    %edx,%edx
    31d3:	89 e5                	mov    %esp,%ebp
    31d5:	8b 45 08             	mov    0x8(%ebp),%eax
    31d8:	53                   	push   %ebx
    31d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    31dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    31e0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
    31e4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    31e7:	83 c2 01             	add    $0x1,%edx
    31ea:	84 c9                	test   %cl,%cl
    31ec:	75 f2                	jne    31e0 <strcpy+0x10>
    ;
  return os;
}
    31ee:	5b                   	pop    %ebx
    31ef:	5d                   	pop    %ebp
    31f0:	c3                   	ret    
    31f1:	eb 0d                	jmp    3200 <strcmp>
    31f3:	90                   	nop
    31f4:	90                   	nop
    31f5:	90                   	nop
    31f6:	90                   	nop
    31f7:	90                   	nop
    31f8:	90                   	nop
    31f9:	90                   	nop
    31fa:	90                   	nop
    31fb:	90                   	nop
    31fc:	90                   	nop
    31fd:	90                   	nop
    31fe:	90                   	nop
    31ff:	90                   	nop

00003200 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    3200:	55                   	push   %ebp
    3201:	89 e5                	mov    %esp,%ebp
    3203:	53                   	push   %ebx
    3204:	8b 4d 08             	mov    0x8(%ebp),%ecx
    3207:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
    320a:	0f b6 01             	movzbl (%ecx),%eax
    320d:	84 c0                	test   %al,%al
    320f:	75 14                	jne    3225 <strcmp+0x25>
    3211:	eb 25                	jmp    3238 <strcmp+0x38>
    3213:	90                   	nop
    3214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
    3218:	83 c1 01             	add    $0x1,%ecx
    321b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    321e:	0f b6 01             	movzbl (%ecx),%eax
    3221:	84 c0                	test   %al,%al
    3223:	74 13                	je     3238 <strcmp+0x38>
    3225:	0f b6 1a             	movzbl (%edx),%ebx
    3228:	38 d8                	cmp    %bl,%al
    322a:	74 ec                	je     3218 <strcmp+0x18>
    322c:	0f b6 db             	movzbl %bl,%ebx
    322f:	0f b6 c0             	movzbl %al,%eax
    3232:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
    3234:	5b                   	pop    %ebx
    3235:	5d                   	pop    %ebp
    3236:	c3                   	ret    
    3237:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    3238:	0f b6 1a             	movzbl (%edx),%ebx
    323b:	31 c0                	xor    %eax,%eax
    323d:	0f b6 db             	movzbl %bl,%ebx
    3240:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
    3242:	5b                   	pop    %ebx
    3243:	5d                   	pop    %ebp
    3244:	c3                   	ret    
    3245:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    3249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00003250 <strlen>:

uint
strlen(char *s)
{
    3250:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
    3251:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
    3253:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
    3255:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
    3257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
    325a:	80 39 00             	cmpb   $0x0,(%ecx)
    325d:	74 0c                	je     326b <strlen+0x1b>
    325f:	90                   	nop
    3260:	83 c2 01             	add    $0x1,%edx
    3263:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
    3267:	89 d0                	mov    %edx,%eax
    3269:	75 f5                	jne    3260 <strlen+0x10>
    ;
  return n;
}
    326b:	5d                   	pop    %ebp
    326c:	c3                   	ret    
    326d:	8d 76 00             	lea    0x0(%esi),%esi

00003270 <memset>:

void*
memset(void *dst, int c, uint n)
{
    3270:	55                   	push   %ebp
    3271:	89 e5                	mov    %esp,%ebp
    3273:	8b 55 08             	mov    0x8(%ebp),%edx
    3276:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    3277:	8b 4d 10             	mov    0x10(%ebp),%ecx
    327a:	8b 45 0c             	mov    0xc(%ebp),%eax
    327d:	89 d7                	mov    %edx,%edi
    327f:	fc                   	cld    
    3280:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
    3282:	89 d0                	mov    %edx,%eax
    3284:	5f                   	pop    %edi
    3285:	5d                   	pop    %ebp
    3286:	c3                   	ret    
    3287:	89 f6                	mov    %esi,%esi
    3289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00003290 <strchr>:

char*
strchr(const char *s, char c)
{
    3290:	55                   	push   %ebp
    3291:	89 e5                	mov    %esp,%ebp
    3293:	8b 45 08             	mov    0x8(%ebp),%eax
    3296:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
    329a:	0f b6 10             	movzbl (%eax),%edx
    329d:	84 d2                	test   %dl,%dl
    329f:	75 11                	jne    32b2 <strchr+0x22>
    32a1:	eb 15                	jmp    32b8 <strchr+0x28>
    32a3:	90                   	nop
    32a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    32a8:	83 c0 01             	add    $0x1,%eax
    32ab:	0f b6 10             	movzbl (%eax),%edx
    32ae:	84 d2                	test   %dl,%dl
    32b0:	74 06                	je     32b8 <strchr+0x28>
    if(*s == c)
    32b2:	38 ca                	cmp    %cl,%dl
    32b4:	75 f2                	jne    32a8 <strchr+0x18>
      return (char*)s;
  return 0;
}
    32b6:	5d                   	pop    %ebp
    32b7:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    32b8:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
    32ba:	5d                   	pop    %ebp
    32bb:	90                   	nop
    32bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    32c0:	c3                   	ret    
    32c1:	eb 0d                	jmp    32d0 <atoi>
    32c3:	90                   	nop
    32c4:	90                   	nop
    32c5:	90                   	nop
    32c6:	90                   	nop
    32c7:	90                   	nop
    32c8:	90                   	nop
    32c9:	90                   	nop
    32ca:	90                   	nop
    32cb:	90                   	nop
    32cc:	90                   	nop
    32cd:	90                   	nop
    32ce:	90                   	nop
    32cf:	90                   	nop

000032d0 <atoi>:
  return r;
}

int
atoi(const char *s)
{
    32d0:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    32d1:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
    32d3:	89 e5                	mov    %esp,%ebp
    32d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
    32d8:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    32d9:	0f b6 11             	movzbl (%ecx),%edx
    32dc:	8d 5a d0             	lea    -0x30(%edx),%ebx
    32df:	80 fb 09             	cmp    $0x9,%bl
    32e2:	77 1c                	ja     3300 <atoi+0x30>
    32e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
    32e8:	0f be d2             	movsbl %dl,%edx
    32eb:	83 c1 01             	add    $0x1,%ecx
    32ee:	8d 04 80             	lea    (%eax,%eax,4),%eax
    32f1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    32f5:	0f b6 11             	movzbl (%ecx),%edx
    32f8:	8d 5a d0             	lea    -0x30(%edx),%ebx
    32fb:	80 fb 09             	cmp    $0x9,%bl
    32fe:	76 e8                	jbe    32e8 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
    3300:	5b                   	pop    %ebx
    3301:	5d                   	pop    %ebp
    3302:	c3                   	ret    
    3303:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    3309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00003310 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    3310:	55                   	push   %ebp
    3311:	89 e5                	mov    %esp,%ebp
    3313:	56                   	push   %esi
    3314:	8b 45 08             	mov    0x8(%ebp),%eax
    3317:	53                   	push   %ebx
    3318:	8b 5d 10             	mov    0x10(%ebp),%ebx
    331b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    331e:	85 db                	test   %ebx,%ebx
    3320:	7e 14                	jle    3336 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
    3322:	31 d2                	xor    %edx,%edx
    3324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
    3328:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
    332c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    332f:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    3332:	39 da                	cmp    %ebx,%edx
    3334:	75 f2                	jne    3328 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
    3336:	5b                   	pop    %ebx
    3337:	5e                   	pop    %esi
    3338:	5d                   	pop    %ebp
    3339:	c3                   	ret    
    333a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00003340 <stat>:
  return buf;
}

int
stat(char *n, struct stat *st)
{
    3340:	55                   	push   %ebp
    3341:	89 e5                	mov    %esp,%ebp
    3343:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3346:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(char *n, struct stat *st)
{
    3349:	89 5d f8             	mov    %ebx,-0x8(%ebp)
    334c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    334f:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3354:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    335b:	00 
    335c:	89 04 24             	mov    %eax,(%esp)
    335f:	e8 d4 00 00 00       	call   3438 <open>
  if(fd < 0)
    3364:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3366:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
    3368:	78 19                	js     3383 <stat+0x43>
    return -1;
  r = fstat(fd, st);
    336a:	8b 45 0c             	mov    0xc(%ebp),%eax
    336d:	89 1c 24             	mov    %ebx,(%esp)
    3370:	89 44 24 04          	mov    %eax,0x4(%esp)
    3374:	e8 d7 00 00 00       	call   3450 <fstat>
  close(fd);
    3379:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
    337c:	89 c6                	mov    %eax,%esi
  close(fd);
    337e:	e8 9d 00 00 00       	call   3420 <close>
  return r;
}
    3383:	89 f0                	mov    %esi,%eax
    3385:	8b 5d f8             	mov    -0x8(%ebp),%ebx
    3388:	8b 75 fc             	mov    -0x4(%ebp),%esi
    338b:	89 ec                	mov    %ebp,%esp
    338d:	5d                   	pop    %ebp
    338e:	c3                   	ret    
    338f:	90                   	nop

00003390 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
    3390:	55                   	push   %ebp
    3391:	89 e5                	mov    %esp,%ebp
    3393:	57                   	push   %edi
    3394:	56                   	push   %esi
    3395:	31 f6                	xor    %esi,%esi
    3397:	53                   	push   %ebx
    3398:	83 ec 2c             	sub    $0x2c,%esp
    339b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    339e:	eb 06                	jmp    33a6 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    33a0:	3c 0a                	cmp    $0xa,%al
    33a2:	74 39                	je     33dd <gets+0x4d>
    33a4:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    33a6:	8d 5e 01             	lea    0x1(%esi),%ebx
    33a9:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
    33ac:	7d 31                	jge    33df <gets+0x4f>
    cc = read(0, &c, 1);
    33ae:	8d 45 e7             	lea    -0x19(%ebp),%eax
    33b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    33b8:	00 
    33b9:	89 44 24 04          	mov    %eax,0x4(%esp)
    33bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    33c4:	e8 47 00 00 00       	call   3410 <read>
    if(cc < 1)
    33c9:	85 c0                	test   %eax,%eax
    33cb:	7e 12                	jle    33df <gets+0x4f>
      break;
    buf[i++] = c;
    33cd:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
    33d1:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
    33d5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
    33d9:	3c 0d                	cmp    $0xd,%al
    33db:	75 c3                	jne    33a0 <gets+0x10>
    33dd:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
    33df:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
    33e3:	89 f8                	mov    %edi,%eax
    33e5:	83 c4 2c             	add    $0x2c,%esp
    33e8:	5b                   	pop    %ebx
    33e9:	5e                   	pop    %esi
    33ea:	5f                   	pop    %edi
    33eb:	5d                   	pop    %ebp
    33ec:	c3                   	ret    
    33ed:	90                   	nop
    33ee:	90                   	nop
    33ef:	90                   	nop

000033f0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    33f0:	b8 01 00 00 00       	mov    $0x1,%eax
    33f5:	cd 40                	int    $0x40
    33f7:	c3                   	ret    

000033f8 <exit>:
SYSCALL(exit)
    33f8:	b8 02 00 00 00       	mov    $0x2,%eax
    33fd:	cd 40                	int    $0x40
    33ff:	c3                   	ret    

00003400 <wait>:
SYSCALL(wait)
    3400:	b8 03 00 00 00       	mov    $0x3,%eax
    3405:	cd 40                	int    $0x40
    3407:	c3                   	ret    

00003408 <pipe>:
SYSCALL(pipe)
    3408:	b8 04 00 00 00       	mov    $0x4,%eax
    340d:	cd 40                	int    $0x40
    340f:	c3                   	ret    

00003410 <read>:
SYSCALL(read)
    3410:	b8 06 00 00 00       	mov    $0x6,%eax
    3415:	cd 40                	int    $0x40
    3417:	c3                   	ret    

00003418 <write>:
SYSCALL(write)
    3418:	b8 05 00 00 00       	mov    $0x5,%eax
    341d:	cd 40                	int    $0x40
    341f:	c3                   	ret    

00003420 <close>:
SYSCALL(close)
    3420:	b8 07 00 00 00       	mov    $0x7,%eax
    3425:	cd 40                	int    $0x40
    3427:	c3                   	ret    

00003428 <kill>:
SYSCALL(kill)
    3428:	b8 08 00 00 00       	mov    $0x8,%eax
    342d:	cd 40                	int    $0x40
    342f:	c3                   	ret    

00003430 <exec>:
SYSCALL(exec)
    3430:	b8 09 00 00 00       	mov    $0x9,%eax
    3435:	cd 40                	int    $0x40
    3437:	c3                   	ret    

00003438 <open>:
SYSCALL(open)
    3438:	b8 0a 00 00 00       	mov    $0xa,%eax
    343d:	cd 40                	int    $0x40
    343f:	c3                   	ret    

00003440 <mknod>:
SYSCALL(mknod)
    3440:	b8 0b 00 00 00       	mov    $0xb,%eax
    3445:	cd 40                	int    $0x40
    3447:	c3                   	ret    

00003448 <unlink>:
SYSCALL(unlink)
    3448:	b8 0c 00 00 00       	mov    $0xc,%eax
    344d:	cd 40                	int    $0x40
    344f:	c3                   	ret    

00003450 <fstat>:
SYSCALL(fstat)
    3450:	b8 0d 00 00 00       	mov    $0xd,%eax
    3455:	cd 40                	int    $0x40
    3457:	c3                   	ret    

00003458 <link>:
SYSCALL(link)
    3458:	b8 0e 00 00 00       	mov    $0xe,%eax
    345d:	cd 40                	int    $0x40
    345f:	c3                   	ret    

00003460 <mkdir>:
SYSCALL(mkdir)
    3460:	b8 0f 00 00 00       	mov    $0xf,%eax
    3465:	cd 40                	int    $0x40
    3467:	c3                   	ret    

00003468 <chdir>:
SYSCALL(chdir)
    3468:	b8 10 00 00 00       	mov    $0x10,%eax
    346d:	cd 40                	int    $0x40
    346f:	c3                   	ret    

00003470 <dup>:
SYSCALL(dup)
    3470:	b8 11 00 00 00       	mov    $0x11,%eax
    3475:	cd 40                	int    $0x40
    3477:	c3                   	ret    

00003478 <getpid>:
SYSCALL(getpid)
    3478:	b8 12 00 00 00       	mov    $0x12,%eax
    347d:	cd 40                	int    $0x40
    347f:	c3                   	ret    

00003480 <sbrk>:
SYSCALL(sbrk)
    3480:	b8 13 00 00 00       	mov    $0x13,%eax
    3485:	cd 40                	int    $0x40
    3487:	c3                   	ret    

00003488 <sleep>:
SYSCALL(sleep)
    3488:	b8 14 00 00 00       	mov    $0x14,%eax
    348d:	cd 40                	int    $0x40
    348f:	c3                   	ret    

00003490 <uptime>:
SYSCALL(uptime)
    3490:	b8 15 00 00 00       	mov    $0x15,%eax
    3495:	cd 40                	int    $0x40
    3497:	c3                   	ret    

00003498 <clone>:
SYSCALL(clone)
    3498:	b8 16 00 00 00       	mov    $0x16,%eax
    349d:	cd 40                	int    $0x40
    349f:	c3                   	ret    

000034a0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
    34a0:	55                   	push   %ebp
    34a1:	89 e5                	mov    %esp,%ebp
    34a3:	57                   	push   %edi
    34a4:	89 cf                	mov    %ecx,%edi
    34a6:	56                   	push   %esi
    34a7:	89 c6                	mov    %eax,%esi
    34a9:	53                   	push   %ebx
    34aa:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    34ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
    34b0:	85 c9                	test   %ecx,%ecx
    34b2:	74 04                	je     34b8 <printint+0x18>
    34b4:	85 d2                	test   %edx,%edx
    34b6:	78 70                	js     3528 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    34b8:	89 d0                	mov    %edx,%eax
    34ba:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
    34c1:	31 c9                	xor    %ecx,%ecx
    34c3:	8d 5d d7             	lea    -0x29(%ebp),%ebx
    34c6:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
    34c8:	31 d2                	xor    %edx,%edx
    34ca:	f7 f7                	div    %edi
    34cc:	0f b6 92 3b 4e 00 00 	movzbl 0x4e3b(%edx),%edx
    34d3:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
    34d6:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
    34d9:	85 c0                	test   %eax,%eax
    34db:	75 eb                	jne    34c8 <printint+0x28>
  if(neg)
    34dd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
    34e0:	85 c0                	test   %eax,%eax
    34e2:	74 08                	je     34ec <printint+0x4c>
    buf[i++] = '-';
    34e4:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
    34e9:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
    34ec:	8d 79 ff             	lea    -0x1(%ecx),%edi
    34ef:	01 fb                	add    %edi,%ebx
    34f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    34f8:	0f b6 03             	movzbl (%ebx),%eax
    34fb:	83 ef 01             	sub    $0x1,%edi
    34fe:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    3501:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3508:	00 
    3509:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    350c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    350f:	8d 45 e7             	lea    -0x19(%ebp),%eax
    3512:	89 44 24 04          	mov    %eax,0x4(%esp)
    3516:	e8 fd fe ff ff       	call   3418 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    351b:	83 ff ff             	cmp    $0xffffffff,%edi
    351e:	75 d8                	jne    34f8 <printint+0x58>
    putc(fd, buf[i]);
}
    3520:	83 c4 4c             	add    $0x4c,%esp
    3523:	5b                   	pop    %ebx
    3524:	5e                   	pop    %esi
    3525:	5f                   	pop    %edi
    3526:	5d                   	pop    %ebp
    3527:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
    3528:	89 d0                	mov    %edx,%eax
    352a:	f7 d8                	neg    %eax
    352c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
    3533:	eb 8c                	jmp    34c1 <printint+0x21>
    3535:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    3539:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00003540 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    3540:	55                   	push   %ebp
    3541:	89 e5                	mov    %esp,%ebp
    3543:	57                   	push   %edi
    3544:	56                   	push   %esi
    3545:	53                   	push   %ebx
    3546:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    3549:	8b 45 0c             	mov    0xc(%ebp),%eax
    354c:	0f b6 10             	movzbl (%eax),%edx
    354f:	84 d2                	test   %dl,%dl
    3551:	0f 84 c9 00 00 00    	je     3620 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
    3557:	8d 4d 10             	lea    0x10(%ebp),%ecx
    355a:	31 ff                	xor    %edi,%edi
    355c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
    355f:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    3561:	8d 75 e7             	lea    -0x19(%ebp),%esi
    3564:	eb 1e                	jmp    3584 <printf+0x44>
    3566:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
    3568:	83 fa 25             	cmp    $0x25,%edx
    356b:	0f 85 b7 00 00 00    	jne    3628 <printf+0xe8>
    3571:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    3575:	83 c3 01             	add    $0x1,%ebx
    3578:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
    357c:	84 d2                	test   %dl,%dl
    357e:	0f 84 9c 00 00 00    	je     3620 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
    3584:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    3586:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
    3589:	74 dd                	je     3568 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    358b:	83 ff 25             	cmp    $0x25,%edi
    358e:	75 e5                	jne    3575 <printf+0x35>
      if(c == 'd'){
    3590:	83 fa 64             	cmp    $0x64,%edx
    3593:	0f 84 57 01 00 00    	je     36f0 <printf+0x1b0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
    3599:	83 fa 70             	cmp    $0x70,%edx
    359c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    35a0:	0f 84 aa 00 00 00    	je     3650 <printf+0x110>
    35a6:	83 fa 78             	cmp    $0x78,%edx
    35a9:	0f 84 a1 00 00 00    	je     3650 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
    35af:	83 fa 73             	cmp    $0x73,%edx
    35b2:	0f 84 c0 00 00 00    	je     3678 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    35b8:	83 fa 63             	cmp    $0x63,%edx
    35bb:	90                   	nop
    35bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    35c0:	0f 84 52 01 00 00    	je     3718 <printf+0x1d8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
    35c6:	83 fa 25             	cmp    $0x25,%edx
    35c9:	0f 84 f9 00 00 00    	je     36c8 <printf+0x188>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    35cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    35d2:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    35d5:	31 ff                	xor    %edi,%edi
    35d7:	89 55 cc             	mov    %edx,-0x34(%ebp)
    35da:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
    35de:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    35e5:	00 
    35e6:	89 0c 24             	mov    %ecx,(%esp)
    35e9:	89 74 24 04          	mov    %esi,0x4(%esp)
    35ed:	e8 26 fe ff ff       	call   3418 <write>
    35f2:	8b 55 cc             	mov    -0x34(%ebp),%edx
    35f5:	8b 45 08             	mov    0x8(%ebp),%eax
    35f8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    35ff:	00 
    3600:	89 74 24 04          	mov    %esi,0x4(%esp)
    3604:	88 55 e7             	mov    %dl,-0x19(%ebp)
    3607:	89 04 24             	mov    %eax,(%esp)
    360a:	e8 09 fe ff ff       	call   3418 <write>
    360f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    3612:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
    3616:	84 d2                	test   %dl,%dl
    3618:	0f 85 66 ff ff ff    	jne    3584 <printf+0x44>
    361e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    3620:	83 c4 3c             	add    $0x3c,%esp
    3623:	5b                   	pop    %ebx
    3624:	5e                   	pop    %esi
    3625:	5f                   	pop    %edi
    3626:	5d                   	pop    %ebp
    3627:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    3628:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
    362b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    362e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3635:	00 
    3636:	89 74 24 04          	mov    %esi,0x4(%esp)
    363a:	89 04 24             	mov    %eax,(%esp)
    363d:	e8 d6 fd ff ff       	call   3418 <write>
    3642:	8b 45 0c             	mov    0xc(%ebp),%eax
    3645:	e9 2b ff ff ff       	jmp    3575 <printf+0x35>
    364a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
    3650:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    3653:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
    3658:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
    365a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3661:	8b 10                	mov    (%eax),%edx
    3663:	8b 45 08             	mov    0x8(%ebp),%eax
    3666:	e8 35 fe ff ff       	call   34a0 <printint>
    366b:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
    366e:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
    3672:	e9 fe fe ff ff       	jmp    3575 <printf+0x35>
    3677:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
    3678:	8b 55 d4             	mov    -0x2c(%ebp),%edx
    367b:	8b 3a                	mov    (%edx),%edi
        ap++;
    367d:	83 c2 04             	add    $0x4,%edx
    3680:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
    3683:	85 ff                	test   %edi,%edi
    3685:	0f 84 ba 00 00 00    	je     3745 <printf+0x205>
          s = "(null)";
        while(*s != 0){
    368b:	0f b6 17             	movzbl (%edi),%edx
    368e:	84 d2                	test   %dl,%dl
    3690:	74 2d                	je     36bf <printf+0x17f>
    3692:	89 5d d0             	mov    %ebx,-0x30(%ebp)
    3695:	8b 5d 08             	mov    0x8(%ebp),%ebx
          putc(fd, *s);
          s++;
    3698:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    369b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    369e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    36a5:	00 
    36a6:	89 74 24 04          	mov    %esi,0x4(%esp)
    36aa:	89 1c 24             	mov    %ebx,(%esp)
    36ad:	e8 66 fd ff ff       	call   3418 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    36b2:	0f b6 17             	movzbl (%edi),%edx
    36b5:	84 d2                	test   %dl,%dl
    36b7:	75 df                	jne    3698 <printf+0x158>
    36b9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
    36bc:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    36bf:	31 ff                	xor    %edi,%edi
    36c1:	e9 af fe ff ff       	jmp    3575 <printf+0x35>
    36c6:	66 90                	xchg   %ax,%ax
    36c8:	8b 55 08             	mov    0x8(%ebp),%edx
    36cb:	31 ff                	xor    %edi,%edi
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
    36cd:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    36d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    36d8:	00 
    36d9:	89 74 24 04          	mov    %esi,0x4(%esp)
    36dd:	89 14 24             	mov    %edx,(%esp)
    36e0:	e8 33 fd ff ff       	call   3418 <write>
    36e5:	8b 45 0c             	mov    0xc(%ebp),%eax
    36e8:	e9 88 fe ff ff       	jmp    3575 <printf+0x35>
    36ed:	8d 76 00             	lea    0x0(%esi),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
    36f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    36f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
    36f8:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
    36fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3702:	8b 10                	mov    (%eax),%edx
    3704:	8b 45 08             	mov    0x8(%ebp),%eax
    3707:	e8 94 fd ff ff       	call   34a0 <printint>
    370c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
    370f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
    3713:	e9 5d fe ff ff       	jmp    3575 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    3718:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
        putc(fd, *ap);
        ap++;
    371b:	31 ff                	xor    %edi,%edi
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    371d:	8b 01                	mov    (%ecx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    371f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3726:	00 
    3727:	89 74 24 04          	mov    %esi,0x4(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    372b:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    372e:	8b 45 08             	mov    0x8(%ebp),%eax
    3731:	89 04 24             	mov    %eax,(%esp)
    3734:	e8 df fc ff ff       	call   3418 <write>
    3739:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
    373c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
    3740:	e9 30 fe ff ff       	jmp    3575 <printf+0x35>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
    3745:	bf 34 4e 00 00       	mov    $0x4e34,%edi
    374a:	e9 3c ff ff ff       	jmp    368b <printf+0x14b>
    374f:	90                   	nop

00003750 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    3750:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    3751:	a1 88 4e 00 00       	mov    0x4e88,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
    3756:	89 e5                	mov    %esp,%ebp
    3758:	57                   	push   %edi
    3759:	56                   	push   %esi
    375a:	53                   	push   %ebx
    375b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
    375e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    3761:	39 c8                	cmp    %ecx,%eax
    3763:	73 1d                	jae    3782 <free+0x32>
    3765:	8d 76 00             	lea    0x0(%esi),%esi
    3768:	8b 10                	mov    (%eax),%edx
    376a:	39 d1                	cmp    %edx,%ecx
    376c:	72 1a                	jb     3788 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    376e:	39 d0                	cmp    %edx,%eax
    3770:	72 08                	jb     377a <free+0x2a>
    3772:	39 c8                	cmp    %ecx,%eax
    3774:	72 12                	jb     3788 <free+0x38>
    3776:	39 d1                	cmp    %edx,%ecx
    3778:	72 0e                	jb     3788 <free+0x38>
    377a:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    377c:	39 c8                	cmp    %ecx,%eax
    377e:	66 90                	xchg   %ax,%ax
    3780:	72 e6                	jb     3768 <free+0x18>
    3782:	8b 10                	mov    (%eax),%edx
    3784:	eb e8                	jmp    376e <free+0x1e>
    3786:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    3788:	8b 71 04             	mov    0x4(%ecx),%esi
    378b:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
    378e:	39 d7                	cmp    %edx,%edi
    3790:	74 19                	je     37ab <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
    3792:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
    3795:	8b 50 04             	mov    0x4(%eax),%edx
    3798:	8d 34 d0             	lea    (%eax,%edx,8),%esi
    379b:	39 ce                	cmp    %ecx,%esi
    379d:	74 23                	je     37c2 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
    379f:	89 08                	mov    %ecx,(%eax)
  freep = p;
    37a1:	a3 88 4e 00 00       	mov    %eax,0x4e88
}
    37a6:	5b                   	pop    %ebx
    37a7:	5e                   	pop    %esi
    37a8:	5f                   	pop    %edi
    37a9:	5d                   	pop    %ebp
    37aa:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    37ab:	03 72 04             	add    0x4(%edx),%esi
    37ae:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
    37b1:	8b 10                	mov    (%eax),%edx
    37b3:	8b 12                	mov    (%edx),%edx
    37b5:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    37b8:	8b 50 04             	mov    0x4(%eax),%edx
    37bb:	8d 34 d0             	lea    (%eax,%edx,8),%esi
    37be:	39 ce                	cmp    %ecx,%esi
    37c0:	75 dd                	jne    379f <free+0x4f>
    p->s.size += bp->s.size;
    37c2:	03 51 04             	add    0x4(%ecx),%edx
    37c5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    37c8:	8b 53 f8             	mov    -0x8(%ebx),%edx
    37cb:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
    37cd:	a3 88 4e 00 00       	mov    %eax,0x4e88
}
    37d2:	5b                   	pop    %ebx
    37d3:	5e                   	pop    %esi
    37d4:	5f                   	pop    %edi
    37d5:	5d                   	pop    %ebp
    37d6:	c3                   	ret    
    37d7:	89 f6                	mov    %esi,%esi
    37d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000037e0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    37e0:	55                   	push   %ebp
    37e1:	89 e5                	mov    %esp,%ebp
    37e3:	57                   	push   %edi
    37e4:	56                   	push   %esi
    37e5:	53                   	push   %ebx
    37e6:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    37e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
    37ec:	8b 0d 88 4e 00 00    	mov    0x4e88,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    37f2:	83 c3 07             	add    $0x7,%ebx
    37f5:	c1 eb 03             	shr    $0x3,%ebx
    37f8:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
    37fb:	85 c9                	test   %ecx,%ecx
    37fd:	0f 84 93 00 00 00    	je     3896 <malloc+0xb6>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    3803:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
    3805:	8b 50 04             	mov    0x4(%eax),%edx
    3808:	39 d3                	cmp    %edx,%ebx
    380a:	76 1f                	jbe    382b <malloc+0x4b>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    380c:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
    3813:	90                   	nop
    3814:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
    if(p == freep)
    3818:	3b 05 88 4e 00 00    	cmp    0x4e88,%eax
    381e:	74 30                	je     3850 <malloc+0x70>
    3820:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    3822:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
    3824:	8b 50 04             	mov    0x4(%eax),%edx
    3827:	39 d3                	cmp    %edx,%ebx
    3829:	77 ed                	ja     3818 <malloc+0x38>
      if(p->s.size == nunits)
    382b:	39 d3                	cmp    %edx,%ebx
    382d:	74 61                	je     3890 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
    382f:	29 da                	sub    %ebx,%edx
    3831:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    3834:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
    3837:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
    383a:	89 0d 88 4e 00 00    	mov    %ecx,0x4e88
      return (void*)(p + 1);
    3840:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    3843:	83 c4 1c             	add    $0x1c,%esp
    3846:	5b                   	pop    %ebx
    3847:	5e                   	pop    %esi
    3848:	5f                   	pop    %edi
    3849:	5d                   	pop    %ebp
    384a:	c3                   	ret    
    384b:	90                   	nop
    384c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
    3850:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
    3856:	b8 00 80 00 00       	mov    $0x8000,%eax
    385b:	bf 00 10 00 00       	mov    $0x1000,%edi
    3860:	76 04                	jbe    3866 <malloc+0x86>
    3862:	89 f0                	mov    %esi,%eax
    3864:	89 df                	mov    %ebx,%edi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
    3866:	89 04 24             	mov    %eax,(%esp)
    3869:	e8 12 fc ff ff       	call   3480 <sbrk>
  if(p == (char*)-1)
    386e:	83 f8 ff             	cmp    $0xffffffff,%eax
    3871:	74 18                	je     388b <malloc+0xab>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
    3873:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
    3876:	83 c0 08             	add    $0x8,%eax
    3879:	89 04 24             	mov    %eax,(%esp)
    387c:	e8 cf fe ff ff       	call   3750 <free>
  return freep;
    3881:	8b 0d 88 4e 00 00    	mov    0x4e88,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
    3887:	85 c9                	test   %ecx,%ecx
    3889:	75 97                	jne    3822 <malloc+0x42>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
    388b:	31 c0                	xor    %eax,%eax
    388d:	eb b4                	jmp    3843 <malloc+0x63>
    388f:	90                   	nop
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
    3890:	8b 10                	mov    (%eax),%edx
    3892:	89 11                	mov    %edx,(%ecx)
    3894:	eb a4                	jmp    383a <malloc+0x5a>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    3896:	c7 05 88 4e 00 00 80 	movl   $0x4e80,0x4e88
    389d:	4e 00 00 
    base.s.size = 0;
    38a0:	b9 80 4e 00 00       	mov    $0x4e80,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    38a5:	c7 05 80 4e 00 00 80 	movl   $0x4e80,0x4e80
    38ac:	4e 00 00 
    base.s.size = 0;
    38af:	c7 05 84 4e 00 00 00 	movl   $0x0,0x4e84
    38b6:	00 00 00 
    38b9:	e9 45 ff ff ff       	jmp    3803 <malloc+0x23>
    38be:	90                   	nop
    38bf:	90                   	nop

000038c0 <lock_init>:
#include "thread.h"
#include "stat.h"

void
lock_init(struct lock_t *lock)
{
    38c0:	55                   	push   %ebp
    38c1:	89 e5                	mov    %esp,%ebp
  lock->locked = 0;
    38c3:	8b 45 08             	mov    0x8(%ebp),%eax
    38c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    38cc:	5d                   	pop    %ebp
    38cd:	c3                   	ret    
    38ce:	66 90                	xchg   %ax,%ax

000038d0 <lock_acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
lock_acquire(struct lock_t *lock)
{
    38d0:	55                   	push   %ebp
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    38d1:	b9 01 00 00 00       	mov    $0x1,%ecx
    38d6:	89 e5                	mov    %esp,%ebp
    38d8:	8b 55 08             	mov    0x8(%ebp),%edx
    38db:	90                   	nop
    38dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    38e0:	89 c8                	mov    %ecx,%eax
    38e2:	f0 87 02             	lock xchg %eax,(%edx)
//     panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lock->locked, 1) != 0)
    38e5:	85 c0                	test   %eax,%eax
    38e7:	75 f7                	jne    38e0 <lock_acquire+0x10>
    ;

}
    38e9:	5d                   	pop    %ebp
    38ea:	c3                   	ret    
    38eb:	90                   	nop
    38ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

000038f0 <lock_release>:

// Release the lock.
void
lock_release(struct lock_t *lock)
{
    38f0:	55                   	push   %ebp
    38f1:	31 c0                	xor    %eax,%eax
    38f3:	89 e5                	mov    %esp,%ebp
    38f5:	8b 55 08             	mov    0x8(%ebp),%edx
    38f8:	f0 87 02             	lock xchg %eax,(%edx)
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lock->locked, 0);

}
    38fb:	5d                   	pop    %ebp
    38fc:	c3                   	ret    
    38fd:	8d 76 00             	lea    0x0(%esi),%esi

00003900 <lock_holding>:

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
    3900:	55                   	push   %ebp
    3901:	89 e5                	mov    %esp,%ebp
    3903:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked;
    3906:	5d                   	pop    %ebp
}

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
    3907:	8b 00                	mov    (%eax),%eax
  return lock->locked;
    3909:	c3                   	ret    
