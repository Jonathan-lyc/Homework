
kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <multiboot_header>:
  100000:	02 b0 ad 1b 01 00    	add    0x11bad(%eax),%dh
  100006:	01 00                	add    %eax,(%eax)
  100008:	fd                   	std    
  100009:	4f                   	dec    %edi
  10000a:	51                   	push   %ecx
  10000b:	e4 00                	in     $0x0,%al
  10000d:	00 10                	add    %dl,(%eax)
  10000f:	00 00                	add    %al,(%eax)
  100011:	00 10                	add    %dl,(%eax)
  100013:	00 06                	add    %al,(%esi)
  100015:	78 10                	js     100027 <multiboot_entry+0x7>
  100017:	00 a4 e8 10 00 20 00 	add    %ah,0x200010(%eax,%ebp,8)
  10001e:	10 00                	adc    %al,(%eax)

00100020 <multiboot_entry>:
# Multiboot entry point.  Machine is mostly set up.
# Configure the GDT to match the environment that our usual
# boot loader - bootasm.S - sets up.
.globl multiboot_entry
multiboot_entry:
  lgdt gdtdesc
  100020:	0f 01 15 64 00 10 00 	lgdtl  0x100064
  ljmp $(SEG_KCODE<<3), $mbstart32
  100027:	ea 2e 00 10 00 08 00 	ljmp   $0x8,$0x10002e

0010002e <mbstart32>:

mbstart32:
  # Set up the protected-mode data segment registers
  movw    $(SEG_KDATA<<3), %ax    # Our data segment selector
  10002e:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
  100032:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
  100034:	8e c0                	mov    %eax,%es
  movw    %ax, %ss                # -> SS: Stack Segment
  100036:	8e d0                	mov    %eax,%ss
  movw    $0, %ax                 # Zero segments not ready for use
  100038:	66 b8 00 00          	mov    $0x0,%ax
  movw    %ax, %fs                # -> FS
  10003c:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
  10003e:	8e e8                	mov    %eax,%gs

  # Set up the stack pointer and call into C.
  movl $(stack + STACK), %esp
  100040:	bc e0 88 10 00       	mov    $0x1088e0,%esp
  call main
  100045:	e8 76 28 00 00       	call   1028c0 <main>

0010004a <spin>:
spin:
  jmp spin
  10004a:	eb fe                	jmp    10004a <spin>

0010004c <gdt>:
	...
  100054:	ff                   	(bad)  
  100055:	ff 00                	incl   (%eax)
  100057:	00 00                	add    %al,(%eax)
  100059:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
  100060:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00100064 <gdtdesc>:
  100064:	17                   	pop    %ss
  100065:	00 4c 00 10          	add    %cl,0x10(%eax,%eax,1)
  100069:	00 90 90 90 90 90    	add    %dl,-0x6f6f6f70(%eax)
  10006f:	90                   	nop

00100070 <brelse>:
}

// Release the buffer b.
void
brelse(struct buf *b)
{
  100070:	55                   	push   %ebp
  100071:	89 e5                	mov    %esp,%ebp
  100073:	53                   	push   %ebx
  100074:	83 ec 14             	sub    $0x14,%esp
  100077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((b->flags & B_BUSY) == 0)
  10007a:	f6 03 01             	testb  $0x1,(%ebx)
  10007d:	74 57                	je     1000d6 <brelse+0x66>
    panic("brelse");

  acquire(&bcache.lock);
  10007f:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  100086:	e8 b5 3a 00 00       	call   103b40 <acquire>

  b->next->prev = b->prev;
  10008b:	8b 43 10             	mov    0x10(%ebx),%eax
  10008e:	8b 53 0c             	mov    0xc(%ebx),%edx
  100091:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
  100094:	8b 43 0c             	mov    0xc(%ebx),%eax
  100097:	8b 53 10             	mov    0x10(%ebx),%edx
  10009a:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
  10009d:	a1 14 9e 10 00       	mov    0x109e14,%eax
  b->prev = &bcache.head;
  1000a2:	c7 43 0c 04 9e 10 00 	movl   $0x109e04,0xc(%ebx)

  acquire(&bcache.lock);

  b->next->prev = b->prev;
  b->prev->next = b->next;
  b->next = bcache.head.next;
  1000a9:	89 43 10             	mov    %eax,0x10(%ebx)
  b->prev = &bcache.head;
  bcache.head.next->prev = b;
  1000ac:	a1 14 9e 10 00       	mov    0x109e14,%eax
  1000b1:	89 58 0c             	mov    %ebx,0xc(%eax)
  bcache.head.next = b;
  1000b4:	89 1d 14 9e 10 00    	mov    %ebx,0x109e14

  b->flags &= ~B_BUSY;
  1000ba:	83 23 fe             	andl   $0xfffffffe,(%ebx)
  wakeup(b);
  1000bd:	89 1c 24             	mov    %ebx,(%esp)
  1000c0:	e8 7b 30 00 00       	call   103140 <wakeup>

  release(&bcache.lock);
  1000c5:	c7 45 08 e0 88 10 00 	movl   $0x1088e0,0x8(%ebp)
}
  1000cc:	83 c4 14             	add    $0x14,%esp
  1000cf:	5b                   	pop    %ebx
  1000d0:	5d                   	pop    %ebp
  bcache.head.next = b;

  b->flags &= ~B_BUSY;
  wakeup(b);

  release(&bcache.lock);
  1000d1:	e9 1a 3a 00 00       	jmp    103af0 <release>
// Release the buffer b.
void
brelse(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("brelse");
  1000d6:	c7 04 24 c0 64 10 00 	movl   $0x1064c0,(%esp)
  1000dd:	e8 3e 08 00 00       	call   100920 <panic>
  1000e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1000e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001000f0 <bwrite>:
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  1000f0:	55                   	push   %ebp
  1000f1:	89 e5                	mov    %esp,%ebp
  1000f3:	83 ec 18             	sub    $0x18,%esp
  1000f6:	8b 45 08             	mov    0x8(%ebp),%eax
  if((b->flags & B_BUSY) == 0)
  1000f9:	8b 10                	mov    (%eax),%edx
  1000fb:	f6 c2 01             	test   $0x1,%dl
  1000fe:	74 0e                	je     10010e <bwrite+0x1e>
    panic("bwrite");
  b->flags |= B_DIRTY;
  100100:	83 ca 04             	or     $0x4,%edx
  100103:	89 10                	mov    %edx,(%eax)
  iderw(b);
  100105:	89 45 08             	mov    %eax,0x8(%ebp)
}
  100108:	c9                   	leave  
bwrite(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("bwrite");
  b->flags |= B_DIRTY;
  iderw(b);
  100109:	e9 42 1e 00 00       	jmp    101f50 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("bwrite");
  10010e:	c7 04 24 c7 64 10 00 	movl   $0x1064c7,(%esp)
  100115:	e8 06 08 00 00       	call   100920 <panic>
  10011a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00100120 <bread>:
}

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
  100120:	55                   	push   %ebp
  100121:	89 e5                	mov    %esp,%ebp
  100123:	57                   	push   %edi
  100124:	56                   	push   %esi
  100125:	53                   	push   %ebx
  100126:	83 ec 1c             	sub    $0x1c,%esp
  100129:	8b 75 08             	mov    0x8(%ebp),%esi
  10012c:	8b 7d 0c             	mov    0xc(%ebp),%edi
static struct buf*
bget(uint dev, uint sector)
{
  struct buf *b;

  acquire(&bcache.lock);
  10012f:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  100136:	e8 05 3a 00 00       	call   103b40 <acquire>

 loop:
  // Try for cached block.
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
  10013b:	8b 1d 14 9e 10 00    	mov    0x109e14,%ebx
  100141:	81 fb 04 9e 10 00    	cmp    $0x109e04,%ebx
  100147:	75 12                	jne    10015b <bread+0x3b>
  100149:	eb 35                	jmp    100180 <bread+0x60>
  10014b:	90                   	nop
  10014c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  100150:	8b 5b 10             	mov    0x10(%ebx),%ebx
  100153:	81 fb 04 9e 10 00    	cmp    $0x109e04,%ebx
  100159:	74 25                	je     100180 <bread+0x60>
    if(b->dev == dev && b->sector == sector){
  10015b:	3b 73 04             	cmp    0x4(%ebx),%esi
  10015e:	66 90                	xchg   %ax,%ax
  100160:	75 ee                	jne    100150 <bread+0x30>
  100162:	3b 7b 08             	cmp    0x8(%ebx),%edi
  100165:	75 e9                	jne    100150 <bread+0x30>
      if(!(b->flags & B_BUSY)){
  100167:	8b 03                	mov    (%ebx),%eax
  100169:	a8 01                	test   $0x1,%al
  10016b:	74 64                	je     1001d1 <bread+0xb1>
        b->flags |= B_BUSY;
        release(&bcache.lock);
        return b;
      }
      sleep(b, &bcache.lock);
  10016d:	c7 44 24 04 e0 88 10 	movl   $0x1088e0,0x4(%esp)
  100174:	00 
  100175:	89 1c 24             	mov    %ebx,(%esp)
  100178:	e8 e3 30 00 00       	call   103260 <sleep>
  10017d:	eb bc                	jmp    10013b <bread+0x1b>
  10017f:	90                   	nop
      goto loop;
    }
  }

  // Allocate fresh block.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
  100180:	8b 1d 10 9e 10 00    	mov    0x109e10,%ebx
  100186:	81 fb 04 9e 10 00    	cmp    $0x109e04,%ebx
  10018c:	75 0d                	jne    10019b <bread+0x7b>
  10018e:	eb 54                	jmp    1001e4 <bread+0xc4>
  100190:	8b 5b 0c             	mov    0xc(%ebx),%ebx
  100193:	81 fb 04 9e 10 00    	cmp    $0x109e04,%ebx
  100199:	74 49                	je     1001e4 <bread+0xc4>
    if((b->flags & B_BUSY) == 0){
  10019b:	f6 03 01             	testb  $0x1,(%ebx)
  10019e:	66 90                	xchg   %ax,%ax
  1001a0:	75 ee                	jne    100190 <bread+0x70>
      b->dev = dev;
  1001a2:	89 73 04             	mov    %esi,0x4(%ebx)
      b->sector = sector;
  1001a5:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = B_BUSY;
  1001a8:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
      release(&bcache.lock);
  1001ae:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  1001b5:	e8 36 39 00 00       	call   103af0 <release>
bread(uint dev, uint sector)
{
  struct buf *b;

  b = bget(dev, sector);
  if(!(b->flags & B_VALID))
  1001ba:	f6 03 02             	testb  $0x2,(%ebx)
  1001bd:	75 08                	jne    1001c7 <bread+0xa7>
    iderw(b);
  1001bf:	89 1c 24             	mov    %ebx,(%esp)
  1001c2:	e8 89 1d 00 00       	call   101f50 <iderw>
  return b;
}
  1001c7:	83 c4 1c             	add    $0x1c,%esp
  1001ca:	89 d8                	mov    %ebx,%eax
  1001cc:	5b                   	pop    %ebx
  1001cd:	5e                   	pop    %esi
  1001ce:	5f                   	pop    %edi
  1001cf:	5d                   	pop    %ebp
  1001d0:	c3                   	ret    
 loop:
  // Try for cached block.
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    if(b->dev == dev && b->sector == sector){
      if(!(b->flags & B_BUSY)){
        b->flags |= B_BUSY;
  1001d1:	83 c8 01             	or     $0x1,%eax
  1001d4:	89 03                	mov    %eax,(%ebx)
        release(&bcache.lock);
  1001d6:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  1001dd:	e8 0e 39 00 00       	call   103af0 <release>
  1001e2:	eb d6                	jmp    1001ba <bread+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
  1001e4:	c7 04 24 ce 64 10 00 	movl   $0x1064ce,(%esp)
  1001eb:	e8 30 07 00 00       	call   100920 <panic>

001001f0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
  1001f0:	55                   	push   %ebp
  1001f1:	89 e5                	mov    %esp,%ebp
  1001f3:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
  1001f6:	c7 44 24 04 df 64 10 	movl   $0x1064df,0x4(%esp)
  1001fd:	00 
  1001fe:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  100205:	e8 a6 37 00 00       	call   1039b0 <initlock>
  // head.next is most recently used.
  struct buf head;
} bcache;

void
binit(void)
  10020a:	ba 04 9e 10 00       	mov    $0x109e04,%edx
  10020f:	b8 14 89 10 00       	mov    $0x108914,%eax
  struct buf *b;

  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  100214:	c7 05 10 9e 10 00 04 	movl   $0x109e04,0x109e10
  10021b:	9e 10 00 
  bcache.head.next = &bcache.head;
  10021e:	c7 05 14 9e 10 00 04 	movl   $0x109e04,0x109e14
  100225:	9e 10 00 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
  100228:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
  10022b:	c7 40 0c 04 9e 10 00 	movl   $0x109e04,0xc(%eax)
    b->dev = -1;
  100232:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
  100239:	8b 15 14 9e 10 00    	mov    0x109e14,%edx
  10023f:	89 42 0c             	mov    %eax,0xc(%edx)
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
  100242:	89 c2                	mov    %eax,%edx
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  100244:	a3 14 9e 10 00       	mov    %eax,0x109e14
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
  100249:	05 18 02 00 00       	add    $0x218,%eax
  10024e:	3d 04 9e 10 00       	cmp    $0x109e04,%eax
  100253:	75 d3                	jne    100228 <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
  100255:	c9                   	leave  
  100256:	c3                   	ret    
  100257:	90                   	nop
  100258:	90                   	nop
  100259:	90                   	nop
  10025a:	90                   	nop
  10025b:	90                   	nop
  10025c:	90                   	nop
  10025d:	90                   	nop
  10025e:	90                   	nop
  10025f:	90                   	nop

00100260 <consoleinit>:
  return n;
}

void
consoleinit(void)
{
  100260:	55                   	push   %ebp
  100261:	89 e5                	mov    %esp,%ebp
  100263:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
  100266:	c7 44 24 04 e6 64 10 	movl   $0x1064e6,0x4(%esp)
  10026d:	00 
  10026e:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100275:	e8 36 37 00 00       	call   1039b0 <initlock>
  initlock(&input.lock, "input");
  10027a:	c7 44 24 04 ee 64 10 	movl   $0x1064ee,0x4(%esp)
  100281:	00 
  100282:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  100289:	e8 22 37 00 00       	call   1039b0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  picenable(IRQ_KBD);
  10028e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
consoleinit(void)
{
  initlock(&cons.lock, "console");
  initlock(&input.lock, "input");

  devsw[CONSOLE].write = consolewrite;
  100295:	c7 05 8c aa 10 00 40 	movl   $0x100440,0x10aa8c
  10029c:	04 10 00 
  devsw[CONSOLE].read = consoleread;
  10029f:	c7 05 88 aa 10 00 90 	movl   $0x100690,0x10aa88
  1002a6:	06 10 00 
  cons.locking = 1;
  1002a9:	c7 05 74 78 10 00 01 	movl   $0x1,0x107874
  1002b0:	00 00 00 

  picenable(IRQ_KBD);
  1002b3:	e8 e8 28 00 00       	call   102ba0 <picenable>
  ioapicenable(IRQ_KBD, 0);
  1002b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1002bf:	00 
  1002c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1002c7:	e8 84 1e 00 00       	call   102150 <ioapicenable>
}
  1002cc:	c9                   	leave  
  1002cd:	c3                   	ret    
  1002ce:	66 90                	xchg   %ax,%ax

001002d0 <consputc>:
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
{
  1002d0:	55                   	push   %ebp
  1002d1:	89 e5                	mov    %esp,%ebp
  1002d3:	57                   	push   %edi
  1002d4:	56                   	push   %esi
  1002d5:	89 c6                	mov    %eax,%esi
  1002d7:	53                   	push   %ebx
  1002d8:	83 ec 1c             	sub    $0x1c,%esp
  if(panicked){
  1002db:	83 3d 20 78 10 00 00 	cmpl   $0x0,0x107820
  1002e2:	74 03                	je     1002e7 <consputc+0x17>
}

static inline void
cli(void)
{
  asm volatile("cli");
  1002e4:	fa                   	cli    
  1002e5:	eb fe                	jmp    1002e5 <consputc+0x15>
    cli();
    for(;;)
      ;
  }

  if(c == BACKSPACE){
  1002e7:	3d 00 01 00 00       	cmp    $0x100,%eax
  1002ec:	0f 84 a0 00 00 00    	je     100392 <consputc+0xc2>
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  1002f2:	89 04 24             	mov    %eax,(%esp)
  1002f5:	e8 d6 4d 00 00       	call   1050d0 <uartputc>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1002fa:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
  1002ff:	b8 0e 00 00 00       	mov    $0xe,%eax
  100304:	89 ca                	mov    %ecx,%edx
  100306:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  100307:	bf d5 03 00 00       	mov    $0x3d5,%edi
  10030c:	89 fa                	mov    %edi,%edx
  10030e:	ec                   	in     (%dx),%al
{
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
  10030f:	0f b6 d8             	movzbl %al,%ebx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  100312:	89 ca                	mov    %ecx,%edx
  100314:	c1 e3 08             	shl    $0x8,%ebx
  100317:	b8 0f 00 00 00       	mov    $0xf,%eax
  10031c:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  10031d:	89 fa                	mov    %edi,%edx
  10031f:	ec                   	in     (%dx),%al
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);
  100320:	0f b6 c0             	movzbl %al,%eax
  100323:	09 c3                	or     %eax,%ebx

  if(c == '\n')
  100325:	83 fe 0a             	cmp    $0xa,%esi
  100328:	0f 84 ee 00 00 00    	je     10041c <consputc+0x14c>
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
  10032e:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  100334:	0f 84 cb 00 00 00    	je     100405 <consputc+0x135>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  10033a:	66 81 e6 ff 00       	and    $0xff,%si
  10033f:	66 81 ce 00 07       	or     $0x700,%si
  100344:	66 89 b4 1b 00 80 0b 	mov    %si,0xb8000(%ebx,%ebx,1)
  10034b:	00 
  10034c:	83 c3 01             	add    $0x1,%ebx
  
  if((pos/80) >= 24){  // Scroll up.
  10034f:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
  100355:	8d 8c 1b 00 80 0b 00 	lea    0xb8000(%ebx,%ebx,1),%ecx
  10035c:	7f 5d                	jg     1003bb <consputc+0xeb>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  10035e:	be d4 03 00 00       	mov    $0x3d4,%esi
  100363:	b8 0e 00 00 00       	mov    $0xe,%eax
  100368:	89 f2                	mov    %esi,%edx
  10036a:	ee                   	out    %al,(%dx)
  10036b:	bf d5 03 00 00       	mov    $0x3d5,%edi
  100370:	89 d8                	mov    %ebx,%eax
  100372:	c1 f8 08             	sar    $0x8,%eax
  100375:	89 fa                	mov    %edi,%edx
  100377:	ee                   	out    %al,(%dx)
  100378:	b8 0f 00 00 00       	mov    $0xf,%eax
  10037d:	89 f2                	mov    %esi,%edx
  10037f:	ee                   	out    %al,(%dx)
  100380:	89 d8                	mov    %ebx,%eax
  100382:	89 fa                	mov    %edi,%edx
  100384:	ee                   	out    %al,(%dx)
  
  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
  100385:	66 c7 01 20 07       	movw   $0x720,(%ecx)
  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  cgaputc(c);
}
  10038a:	83 c4 1c             	add    $0x1c,%esp
  10038d:	5b                   	pop    %ebx
  10038e:	5e                   	pop    %esi
  10038f:	5f                   	pop    %edi
  100390:	5d                   	pop    %ebp
  100391:	c3                   	ret    
    for(;;)
      ;
  }

  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  100392:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  100399:	e8 32 4d 00 00       	call   1050d0 <uartputc>
  10039e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1003a5:	e8 26 4d 00 00       	call   1050d0 <uartputc>
  1003aa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1003b1:	e8 1a 4d 00 00       	call   1050d0 <uartputc>
  1003b6:	e9 3f ff ff ff       	jmp    1002fa <consputc+0x2a>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
    pos -= 80;
  1003bb:	83 eb 50             	sub    $0x50,%ebx
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
  1003be:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
  1003c5:	00 
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  1003c6:	8d b4 1b 00 80 0b 00 	lea    0xb8000(%ebx,%ebx,1),%esi
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
  1003cd:	c7 44 24 04 a0 80 0b 	movl   $0xb80a0,0x4(%esp)
  1003d4:	00 
  1003d5:	c7 04 24 00 80 0b 00 	movl   $0xb8000,(%esp)
  1003dc:	e8 7f 38 00 00       	call   103c60 <memmove>
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  1003e1:	b8 80 07 00 00       	mov    $0x780,%eax
  1003e6:	29 d8                	sub    %ebx,%eax
  1003e8:	01 c0                	add    %eax,%eax
  1003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  1003ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1003f5:	00 
  1003f6:	89 34 24             	mov    %esi,(%esp)
  1003f9:	e8 e2 37 00 00       	call   103be0 <memset>
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
  1003fe:	89 f1                	mov    %esi,%ecx
  100400:	e9 59 ff ff ff       	jmp    10035e <consputc+0x8e>
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
    if(pos > 0) --pos;
  100405:	85 db                	test   %ebx,%ebx
  100407:	8d 8c 1b 00 80 0b 00 	lea    0xb8000(%ebx,%ebx,1),%ecx
  10040e:	0f 8e 4a ff ff ff    	jle    10035e <consputc+0x8e>
  100414:	83 eb 01             	sub    $0x1,%ebx
  100417:	e9 33 ff ff ff       	jmp    10034f <consputc+0x7f>
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  10041c:	89 da                	mov    %ebx,%edx
  10041e:	89 d8                	mov    %ebx,%eax
  100420:	b9 50 00 00 00       	mov    $0x50,%ecx
  100425:	83 c3 50             	add    $0x50,%ebx
  100428:	c1 fa 1f             	sar    $0x1f,%edx
  10042b:	f7 f9                	idiv   %ecx
  10042d:	29 d3                	sub    %edx,%ebx
  10042f:	e9 1b ff ff ff       	jmp    10034f <consputc+0x7f>
  100434:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10043a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00100440 <consolewrite>:
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
  100440:	55                   	push   %ebp
  100441:	89 e5                	mov    %esp,%ebp
  100443:	57                   	push   %edi
  100444:	56                   	push   %esi
  100445:	53                   	push   %ebx
  100446:	83 ec 1c             	sub    $0x1c,%esp
  int i;

  iunlock(ip);
  100449:	8b 45 08             	mov    0x8(%ebp),%eax
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
  10044c:	8b 75 10             	mov    0x10(%ebp),%esi
  10044f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  iunlock(ip);
  100452:	89 04 24             	mov    %eax,(%esp)
  100455:	e8 16 13 00 00       	call   101770 <iunlock>
  acquire(&cons.lock);
  10045a:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100461:	e8 da 36 00 00       	call   103b40 <acquire>
  for(i = 0; i < n; i++)
  100466:	85 f6                	test   %esi,%esi
  100468:	7e 16                	jle    100480 <consolewrite+0x40>
  10046a:	31 db                	xor    %ebx,%ebx
  10046c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    consputc(buf[i] & 0xff);
  100470:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
  100474:	83 c3 01             	add    $0x1,%ebx
    consputc(buf[i] & 0xff);
  100477:	e8 54 fe ff ff       	call   1002d0 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
  10047c:	39 de                	cmp    %ebx,%esi
  10047e:	7f f0                	jg     100470 <consolewrite+0x30>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
  100480:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100487:	e8 64 36 00 00       	call   103af0 <release>
  ilock(ip);
  10048c:	8b 45 08             	mov    0x8(%ebp),%eax
  10048f:	89 04 24             	mov    %eax,(%esp)
  100492:	e8 29 17 00 00       	call   101bc0 <ilock>

  return n;
}
  100497:	83 c4 1c             	add    $0x1c,%esp
  10049a:	89 f0                	mov    %esi,%eax
  10049c:	5b                   	pop    %ebx
  10049d:	5e                   	pop    %esi
  10049e:	5f                   	pop    %edi
  10049f:	5d                   	pop    %ebp
  1004a0:	c3                   	ret    
  1004a1:	eb 0d                	jmp    1004b0 <printint>
  1004a3:	90                   	nop
  1004a4:	90                   	nop
  1004a5:	90                   	nop
  1004a6:	90                   	nop
  1004a7:	90                   	nop
  1004a8:	90                   	nop
  1004a9:	90                   	nop
  1004aa:	90                   	nop
  1004ab:	90                   	nop
  1004ac:	90                   	nop
  1004ad:	90                   	nop
  1004ae:	90                   	nop
  1004af:	90                   	nop

001004b0 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
  1004b0:	55                   	push   %ebp
  1004b1:	89 e5                	mov    %esp,%ebp
  1004b3:	57                   	push   %edi
  1004b4:	56                   	push   %esi
  1004b5:	89 d6                	mov    %edx,%esi
  1004b7:	53                   	push   %ebx
  1004b8:	83 ec 1c             	sub    $0x1c,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
  1004bb:	85 c9                	test   %ecx,%ecx
  1004bd:	74 04                	je     1004c3 <printint+0x13>
  1004bf:	85 c0                	test   %eax,%eax
  1004c1:	78 55                	js     100518 <printint+0x68>
    x = -xx;
  else
    x = xx;
  1004c3:	31 ff                	xor    %edi,%edi
  1004c5:	31 c9                	xor    %ecx,%ecx
  1004c7:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  1004ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  i = 0;
  do{
    buf[i++] = digits[x % base];
  1004d0:	31 d2                	xor    %edx,%edx
  1004d2:	f7 f6                	div    %esi
  1004d4:	0f b6 92 0e 65 10 00 	movzbl 0x10650e(%edx),%edx
  1004db:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
  1004de:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
  1004e1:	85 c0                	test   %eax,%eax
  1004e3:	75 eb                	jne    1004d0 <printint+0x20>

  if(sign)
  1004e5:	85 ff                	test   %edi,%edi
  1004e7:	74 08                	je     1004f1 <printint+0x41>
    buf[i++] = '-';
  1004e9:	c6 44 0d d8 2d       	movb   $0x2d,-0x28(%ebp,%ecx,1)
  1004ee:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
  1004f1:	8d 71 ff             	lea    -0x1(%ecx),%esi
  1004f4:	01 f3                	add    %esi,%ebx
  1004f6:	66 90                	xchg   %ax,%ax
    consputc(buf[i]);
  1004f8:	0f be 03             	movsbl (%ebx),%eax
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
  1004fb:	83 ee 01             	sub    $0x1,%esi
  1004fe:	83 eb 01             	sub    $0x1,%ebx
    consputc(buf[i]);
  100501:	e8 ca fd ff ff       	call   1002d0 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
  100506:	83 fe ff             	cmp    $0xffffffff,%esi
  100509:	75 ed                	jne    1004f8 <printint+0x48>
    consputc(buf[i]);
}
  10050b:	83 c4 1c             	add    $0x1c,%esp
  10050e:	5b                   	pop    %ebx
  10050f:	5e                   	pop    %esi
  100510:	5f                   	pop    %edi
  100511:	5d                   	pop    %ebp
  100512:	c3                   	ret    
  100513:	90                   	nop
  100514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  100518:	f7 d8                	neg    %eax
  10051a:	bf 01 00 00 00       	mov    $0x1,%edi
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
  10051f:	eb a4                	jmp    1004c5 <printint+0x15>
  100521:	eb 0d                	jmp    100530 <cprintf>
  100523:	90                   	nop
  100524:	90                   	nop
  100525:	90                   	nop
  100526:	90                   	nop
  100527:	90                   	nop
  100528:	90                   	nop
  100529:	90                   	nop
  10052a:	90                   	nop
  10052b:	90                   	nop
  10052c:	90                   	nop
  10052d:	90                   	nop
  10052e:	90                   	nop
  10052f:	90                   	nop

00100530 <cprintf>:
}

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
  100530:	55                   	push   %ebp
  100531:	89 e5                	mov    %esp,%ebp
  100533:	57                   	push   %edi
  100534:	56                   	push   %esi
  100535:	53                   	push   %ebx
  100536:	83 ec 2c             	sub    $0x2c,%esp
  int i, c, state, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
  100539:	8b 3d 74 78 10 00    	mov    0x107874,%edi
  if(locking)
  10053f:	85 ff                	test   %edi,%edi
  100541:	0f 85 29 01 00 00    	jne    100670 <cprintf+0x140>
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  100547:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10054a:	0f b6 01             	movzbl (%ecx),%eax
  10054d:	85 c0                	test   %eax,%eax
  10054f:	0f 84 93 00 00 00    	je     1005e8 <cprintf+0xb8>

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  100555:	8d 75 0c             	lea    0xc(%ebp),%esi
  100558:	31 db                	xor    %ebx,%ebx
  10055a:	eb 3f                	jmp    10059b <cprintf+0x6b>
  10055c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
  100560:	83 fa 25             	cmp    $0x25,%edx
  100563:	0f 84 b7 00 00 00    	je     100620 <cprintf+0xf0>
  100569:	83 fa 64             	cmp    $0x64,%edx
  10056c:	0f 84 8e 00 00 00    	je     100600 <cprintf+0xd0>
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
  100572:	b8 25 00 00 00       	mov    $0x25,%eax
  100577:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10057a:	e8 51 fd ff ff       	call   1002d0 <consputc>
      consputc(c);
  10057f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100582:	89 d0                	mov    %edx,%eax
  100584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  100588:	e8 43 fd ff ff       	call   1002d0 <consputc>
  10058d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  100590:	83 c3 01             	add    $0x1,%ebx
  100593:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
  100597:	85 c0                	test   %eax,%eax
  100599:	74 4d                	je     1005e8 <cprintf+0xb8>
    if(c != '%'){
  10059b:	83 f8 25             	cmp    $0x25,%eax
  10059e:	75 e8                	jne    100588 <cprintf+0x58>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
  1005a0:	83 c3 01             	add    $0x1,%ebx
  1005a3:	0f b6 14 19          	movzbl (%ecx,%ebx,1),%edx
    if(c == 0)
  1005a7:	85 d2                	test   %edx,%edx
  1005a9:	74 3d                	je     1005e8 <cprintf+0xb8>
      break;
    switch(c){
  1005ab:	83 fa 70             	cmp    $0x70,%edx
  1005ae:	74 12                	je     1005c2 <cprintf+0x92>
  1005b0:	7e ae                	jle    100560 <cprintf+0x30>
  1005b2:	83 fa 73             	cmp    $0x73,%edx
  1005b5:	8d 76 00             	lea    0x0(%esi),%esi
  1005b8:	74 7e                	je     100638 <cprintf+0x108>
  1005ba:	83 fa 78             	cmp    $0x78,%edx
  1005bd:	8d 76 00             	lea    0x0(%esi),%esi
  1005c0:	75 b0                	jne    100572 <cprintf+0x42>
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
  1005c2:	8b 06                	mov    (%esi),%eax
  1005c4:	31 c9                	xor    %ecx,%ecx
  1005c6:	ba 10 00 00 00       	mov    $0x10,%edx
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  1005cb:	83 c3 01             	add    $0x1,%ebx
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
  1005ce:	83 c6 04             	add    $0x4,%esi
  1005d1:	e8 da fe ff ff       	call   1004b0 <printint>
  1005d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  1005d9:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
  1005dd:	85 c0                	test   %eax,%eax
  1005df:	75 ba                	jne    10059b <cprintf+0x6b>
  1005e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      consputc(c);
      break;
    }
  }

  if(locking)
  1005e8:	85 ff                	test   %edi,%edi
  1005ea:	74 0c                	je     1005f8 <cprintf+0xc8>
    release(&cons.lock);
  1005ec:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  1005f3:	e8 f8 34 00 00       	call   103af0 <release>
}
  1005f8:	83 c4 2c             	add    $0x2c,%esp
  1005fb:	5b                   	pop    %ebx
  1005fc:	5e                   	pop    %esi
  1005fd:	5f                   	pop    %edi
  1005fe:	5d                   	pop    %ebp
  1005ff:	c3                   	ret    
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      printint(*argp++, 10, 1);
  100600:	8b 06                	mov    (%esi),%eax
  100602:	b9 01 00 00 00       	mov    $0x1,%ecx
  100607:	ba 0a 00 00 00       	mov    $0xa,%edx
  10060c:	83 c6 04             	add    $0x4,%esi
  10060f:	e8 9c fe ff ff       	call   1004b0 <printint>
  100614:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
  100617:	e9 74 ff ff ff       	jmp    100590 <cprintf+0x60>
  10061c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
  100620:	b8 25 00 00 00       	mov    $0x25,%eax
  100625:	e8 a6 fc ff ff       	call   1002d0 <consputc>
  10062a:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
  10062d:	e9 5e ff ff ff       	jmp    100590 <cprintf+0x60>
  100632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
  100638:	8b 16                	mov    (%esi),%edx
  10063a:	83 c6 04             	add    $0x4,%esi
  10063d:	85 d2                	test   %edx,%edx
  10063f:	74 47                	je     100688 <cprintf+0x158>
        s = "(null)";
      for(; *s; s++)
  100641:	0f b6 02             	movzbl (%edx),%eax
  100644:	84 c0                	test   %al,%al
  100646:	0f 84 44 ff ff ff    	je     100590 <cprintf+0x60>
  10064c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        consputc(*s);
  100650:	0f be c0             	movsbl %al,%eax
  100653:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  100656:	e8 75 fc ff ff       	call   1002d0 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
  10065b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10065e:	83 c2 01             	add    $0x1,%edx
  100661:	0f b6 02             	movzbl (%edx),%eax
  100664:	84 c0                	test   %al,%al
  100666:	75 e8                	jne    100650 <cprintf+0x120>
  100668:	e9 20 ff ff ff       	jmp    10058d <cprintf+0x5d>
  10066d:	8d 76 00             	lea    0x0(%esi),%esi
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);
  100670:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100677:	e8 c4 34 00 00       	call   103b40 <acquire>
  10067c:	e9 c6 fe ff ff       	jmp    100547 <cprintf+0x17>
  100681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
  100688:	ba f4 64 10 00       	mov    $0x1064f4,%edx
  10068d:	eb b2                	jmp    100641 <cprintf+0x111>
  10068f:	90                   	nop

00100690 <consoleread>:
  release(&input.lock);
}

int
consoleread(struct inode *ip, char *dst, int n)
{
  100690:	55                   	push   %ebp
  100691:	89 e5                	mov    %esp,%ebp
  100693:	57                   	push   %edi
  100694:	56                   	push   %esi
  100695:	53                   	push   %ebx
  100696:	83 ec 3c             	sub    $0x3c,%esp
  100699:	8b 5d 10             	mov    0x10(%ebp),%ebx
  10069c:	8b 7d 08             	mov    0x8(%ebp),%edi
  10069f:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
  1006a2:	89 3c 24             	mov    %edi,(%esp)
  1006a5:	e8 c6 10 00 00       	call   101770 <iunlock>
  target = n;
  1006aa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&input.lock);
  1006ad:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  1006b4:	e8 87 34 00 00       	call   103b40 <acquire>
  while(n > 0){
  1006b9:	85 db                	test   %ebx,%ebx
  1006bb:	7f 2c                	jg     1006e9 <consoleread+0x59>
  1006bd:	e9 c0 00 00 00       	jmp    100782 <consoleread+0xf2>
  1006c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(input.r == input.w){
      if(proc->killed){
  1006c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1006ce:	8b 40 24             	mov    0x24(%eax),%eax
  1006d1:	85 c0                	test   %eax,%eax
  1006d3:	75 5b                	jne    100730 <consoleread+0xa0>
        release(&input.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
  1006d5:	c7 44 24 04 20 a0 10 	movl   $0x10a020,0x4(%esp)
  1006dc:	00 
  1006dd:	c7 04 24 d4 a0 10 00 	movl   $0x10a0d4,(%esp)
  1006e4:	e8 77 2b 00 00       	call   103260 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
  1006e9:	a1 d4 a0 10 00       	mov    0x10a0d4,%eax
  1006ee:	3b 05 d8 a0 10 00    	cmp    0x10a0d8,%eax
  1006f4:	74 d2                	je     1006c8 <consoleread+0x38>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
  1006f6:	89 c2                	mov    %eax,%edx
  1006f8:	83 e2 7f             	and    $0x7f,%edx
  1006fb:	0f b6 8a 54 a0 10 00 	movzbl 0x10a054(%edx),%ecx
  100702:	0f be d1             	movsbl %cl,%edx
  100705:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  100708:	8d 50 01             	lea    0x1(%eax),%edx
    if(c == C('D')){  // EOF
  10070b:	83 7d d4 04          	cmpl   $0x4,-0x2c(%ebp)
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
  10070f:	89 15 d4 a0 10 00    	mov    %edx,0x10a0d4
    if(c == C('D')){  // EOF
  100715:	74 3a                	je     100751 <consoleread+0xc1>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
  100717:	88 0e                	mov    %cl,(%esi)
    --n;
  100719:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
  10071c:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  100720:	74 39                	je     10075b <consoleread+0xcb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
  100722:	85 db                	test   %ebx,%ebx
  100724:	7e 35                	jle    10075b <consoleread+0xcb>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
  100726:	83 c6 01             	add    $0x1,%esi
  100729:	eb be                	jmp    1006e9 <consoleread+0x59>
  10072b:	90                   	nop
  10072c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
        release(&input.lock);
  100730:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  100737:	e8 b4 33 00 00       	call   103af0 <release>
        ilock(ip);
  10073c:	89 3c 24             	mov    %edi,(%esp)
  10073f:	e8 7c 14 00 00       	call   101bc0 <ilock>
  }
  release(&input.lock);
  ilock(ip);

  return target - n;
}
  100744:	83 c4 3c             	add    $0x3c,%esp
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
        release(&input.lock);
        ilock(ip);
  100747:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&input.lock);
  ilock(ip);

  return target - n;
}
  10074c:	5b                   	pop    %ebx
  10074d:	5e                   	pop    %esi
  10074e:	5f                   	pop    %edi
  10074f:	5d                   	pop    %ebp
  100750:	c3                   	ret    
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
  100751:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  100754:	76 05                	jbe    10075b <consoleread+0xcb>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
  100756:	a3 d4 a0 10 00       	mov    %eax,0x10a0d4
  10075b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10075e:	29 d8                	sub    %ebx,%eax
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
  100760:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  100767:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10076a:	e8 81 33 00 00       	call   103af0 <release>
  ilock(ip);
  10076f:	89 3c 24             	mov    %edi,(%esp)
  100772:	e8 49 14 00 00       	call   101bc0 <ilock>
  100777:	8b 45 e0             	mov    -0x20(%ebp),%eax

  return target - n;
}
  10077a:	83 c4 3c             	add    $0x3c,%esp
  10077d:	5b                   	pop    %ebx
  10077e:	5e                   	pop    %esi
  10077f:	5f                   	pop    %edi
  100780:	5d                   	pop    %ebp
  100781:	c3                   	ret    
  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
  100782:	31 c0                	xor    %eax,%eax
  100784:	eb da                	jmp    100760 <consoleread+0xd0>
  100786:	8d 76 00             	lea    0x0(%esi),%esi
  100789:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100790 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
  100790:	55                   	push   %ebp
  100791:	89 e5                	mov    %esp,%ebp
  100793:	57                   	push   %edi
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
  100794:	bf 50 a0 10 00       	mov    $0x10a050,%edi

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
  100799:	56                   	push   %esi
  10079a:	53                   	push   %ebx
  10079b:	83 ec 1c             	sub    $0x1c,%esp
  10079e:	8b 75 08             	mov    0x8(%ebp),%esi
  int c;

  acquire(&input.lock);
  1007a1:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  1007a8:	e8 93 33 00 00       	call   103b40 <acquire>
  1007ad:	8d 76 00             	lea    0x0(%esi),%esi
  while((c = getc()) >= 0){
  1007b0:	ff d6                	call   *%esi
  1007b2:	85 c0                	test   %eax,%eax
  1007b4:	89 c3                	mov    %eax,%ebx
  1007b6:	0f 88 9c 00 00 00    	js     100858 <consoleintr+0xc8>
    switch(c){
  1007bc:	83 fb 10             	cmp    $0x10,%ebx
  1007bf:	90                   	nop
  1007c0:	0f 84 1a 01 00 00    	je     1008e0 <consoleintr+0x150>
  1007c6:	0f 8f a4 00 00 00    	jg     100870 <consoleintr+0xe0>
  1007cc:	83 fb 08             	cmp    $0x8,%ebx
  1007cf:	90                   	nop
  1007d0:	0f 84 a8 00 00 00    	je     10087e <consoleintr+0xee>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
  1007d6:	85 db                	test   %ebx,%ebx
  1007d8:	74 d6                	je     1007b0 <consoleintr+0x20>
  1007da:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  1007df:	89 c2                	mov    %eax,%edx
  1007e1:	2b 15 d4 a0 10 00    	sub    0x10a0d4,%edx
  1007e7:	83 fa 7f             	cmp    $0x7f,%edx
  1007ea:	77 c4                	ja     1007b0 <consoleintr+0x20>
        c = (c == '\r') ? '\n' : c;
  1007ec:	83 fb 0d             	cmp    $0xd,%ebx
  1007ef:	0f 84 f8 00 00 00    	je     1008ed <consoleintr+0x15d>
        input.buf[input.e++ % INPUT_BUF] = c;
  1007f5:	89 c2                	mov    %eax,%edx
  1007f7:	83 c0 01             	add    $0x1,%eax
  1007fa:	83 e2 7f             	and    $0x7f,%edx
  1007fd:	88 5c 17 04          	mov    %bl,0x4(%edi,%edx,1)
  100801:	a3 dc a0 10 00       	mov    %eax,0x10a0dc
        consputc(c);
  100806:	89 d8                	mov    %ebx,%eax
  100808:	e8 c3 fa ff ff       	call   1002d0 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
  10080d:	83 fb 04             	cmp    $0x4,%ebx
  100810:	0f 84 f3 00 00 00    	je     100909 <consoleintr+0x179>
  100816:	83 fb 0a             	cmp    $0xa,%ebx
  100819:	0f 84 ea 00 00 00    	je     100909 <consoleintr+0x179>
  10081f:	8b 15 d4 a0 10 00    	mov    0x10a0d4,%edx
  100825:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  10082a:	83 ea 80             	sub    $0xffffff80,%edx
  10082d:	39 d0                	cmp    %edx,%eax
  10082f:	0f 85 7b ff ff ff    	jne    1007b0 <consoleintr+0x20>
          input.w = input.e;
  100835:	a3 d8 a0 10 00       	mov    %eax,0x10a0d8
          wakeup(&input.r);
  10083a:	c7 04 24 d4 a0 10 00 	movl   $0x10a0d4,(%esp)
  100841:	e8 fa 28 00 00       	call   103140 <wakeup>
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
  100846:	ff d6                	call   *%esi
  100848:	85 c0                	test   %eax,%eax
  10084a:	89 c3                	mov    %eax,%ebx
  10084c:	0f 89 6a ff ff ff    	jns    1007bc <consoleintr+0x2c>
  100852:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        }
      }
      break;
    }
  }
  release(&input.lock);
  100858:	c7 45 08 20 a0 10 00 	movl   $0x10a020,0x8(%ebp)
}
  10085f:	83 c4 1c             	add    $0x1c,%esp
  100862:	5b                   	pop    %ebx
  100863:	5e                   	pop    %esi
  100864:	5f                   	pop    %edi
  100865:	5d                   	pop    %ebp
        }
      }
      break;
    }
  }
  release(&input.lock);
  100866:	e9 85 32 00 00       	jmp    103af0 <release>
  10086b:	90                   	nop
  10086c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
    switch(c){
  100870:	83 fb 15             	cmp    $0x15,%ebx
  100873:	74 57                	je     1008cc <consoleintr+0x13c>
  100875:	83 fb 7f             	cmp    $0x7f,%ebx
  100878:	0f 85 58 ff ff ff    	jne    1007d6 <consoleintr+0x46>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
  10087e:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  100883:	3b 05 d8 a0 10 00    	cmp    0x10a0d8,%eax
  100889:	0f 84 21 ff ff ff    	je     1007b0 <consoleintr+0x20>
        input.e--;
  10088f:	83 e8 01             	sub    $0x1,%eax
  100892:	a3 dc a0 10 00       	mov    %eax,0x10a0dc
        consputc(BACKSPACE);
  100897:	b8 00 01 00 00       	mov    $0x100,%eax
  10089c:	e8 2f fa ff ff       	call   1002d0 <consputc>
  1008a1:	e9 0a ff ff ff       	jmp    1007b0 <consoleintr+0x20>
  1008a6:	66 90                	xchg   %ax,%ax
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
  1008a8:	83 e8 01             	sub    $0x1,%eax
  1008ab:	89 c2                	mov    %eax,%edx
  1008ad:	83 e2 7f             	and    $0x7f,%edx
  1008b0:	80 ba 54 a0 10 00 0a 	cmpb   $0xa,0x10a054(%edx)
  1008b7:	0f 84 f3 fe ff ff    	je     1007b0 <consoleintr+0x20>
        input.e--;
  1008bd:	a3 dc a0 10 00       	mov    %eax,0x10a0dc
        consputc(BACKSPACE);
  1008c2:	b8 00 01 00 00       	mov    $0x100,%eax
  1008c7:	e8 04 fa ff ff       	call   1002d0 <consputc>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
  1008cc:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  1008d1:	3b 05 d8 a0 10 00    	cmp    0x10a0d8,%eax
  1008d7:	75 cf                	jne    1008a8 <consoleintr+0x118>
  1008d9:	e9 d2 fe ff ff       	jmp    1007b0 <consoleintr+0x20>
  1008de:	66 90                	xchg   %ax,%ax

  acquire(&input.lock);
  while((c = getc()) >= 0){
    switch(c){
    case C('P'):  // Process listing.
      procdump();
  1008e0:	e8 fb 26 00 00       	call   102fe0 <procdump>
  1008e5:	8d 76 00             	lea    0x0(%esi),%esi
      break;
  1008e8:	e9 c3 fe ff ff       	jmp    1007b0 <consoleintr+0x20>
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
  1008ed:	89 c2                	mov    %eax,%edx
  1008ef:	83 c0 01             	add    $0x1,%eax
  1008f2:	83 e2 7f             	and    $0x7f,%edx
  1008f5:	c6 44 17 04 0a       	movb   $0xa,0x4(%edi,%edx,1)
  1008fa:	a3 dc a0 10 00       	mov    %eax,0x10a0dc
        consputc(c);
  1008ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  100904:	e8 c7 f9 ff ff       	call   1002d0 <consputc>
  100909:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  10090e:	e9 22 ff ff ff       	jmp    100835 <consoleintr+0xa5>
  100913:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100919:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100920 <panic>:
    release(&cons.lock);
}

void
panic(char *s)
{
  100920:	55                   	push   %ebp
  100921:	89 e5                	mov    %esp,%ebp
  100923:	56                   	push   %esi
  100924:	53                   	push   %ebx
  100925:	83 ec 40             	sub    $0x40,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
  100928:	fa                   	cli    
  int i;
  uint pcs[10];
  
  cli();
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  100929:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  10092f:	8d 75 d0             	lea    -0x30(%ebp),%esi
  100932:	31 db                	xor    %ebx,%ebx
{
  int i;
  uint pcs[10];
  
  cli();
  cons.locking = 0;
  100934:	c7 05 74 78 10 00 00 	movl   $0x0,0x107874
  10093b:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
  10093e:	0f b6 00             	movzbl (%eax),%eax
  100941:	c7 04 24 fb 64 10 00 	movl   $0x1064fb,(%esp)
  100948:	89 44 24 04          	mov    %eax,0x4(%esp)
  10094c:	e8 df fb ff ff       	call   100530 <cprintf>
  cprintf(s);
  100951:	8b 45 08             	mov    0x8(%ebp),%eax
  100954:	89 04 24             	mov    %eax,(%esp)
  100957:	e8 d4 fb ff ff       	call   100530 <cprintf>
  cprintf("\n");
  10095c:	c7 04 24 16 69 10 00 	movl   $0x106916,(%esp)
  100963:	e8 c8 fb ff ff       	call   100530 <cprintf>
  getcallerpcs(&s, pcs);
  100968:	8d 45 08             	lea    0x8(%ebp),%eax
  10096b:	89 74 24 04          	mov    %esi,0x4(%esp)
  10096f:	89 04 24             	mov    %eax,(%esp)
  100972:	e8 59 30 00 00       	call   1039d0 <getcallerpcs>
  100977:	90                   	nop
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
  100978:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
  10097b:	83 c3 01             	add    $0x1,%ebx
    cprintf(" %p", pcs[i]);
  10097e:	c7 04 24 0a 65 10 00 	movl   $0x10650a,(%esp)
  100985:	89 44 24 04          	mov    %eax,0x4(%esp)
  100989:	e8 a2 fb ff ff       	call   100530 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
  10098e:	83 fb 0a             	cmp    $0xa,%ebx
  100991:	75 e5                	jne    100978 <panic+0x58>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
  100993:	c7 05 20 78 10 00 01 	movl   $0x1,0x107820
  10099a:	00 00 00 
  10099d:	eb fe                	jmp    10099d <panic+0x7d>
  10099f:	90                   	nop

001009a0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
  1009a0:	55                   	push   %ebp
  1009a1:	89 e5                	mov    %esp,%ebp
  1009a3:	57                   	push   %edi
  1009a4:	56                   	push   %esi
  1009a5:	53                   	push   %ebx
  1009a6:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
  1009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1009af:	89 04 24             	mov    %eax,(%esp)
  1009b2:	e8 a9 14 00 00       	call   101e60 <namei>
  1009b7:	85 c0                	test   %eax,%eax
  1009b9:	89 c7                	mov    %eax,%edi
  1009bb:	0f 84 25 01 00 00    	je     100ae6 <exec+0x146>
    return -1;
  ilock(ip);
  1009c1:	89 04 24             	mov    %eax,(%esp)
  1009c4:	e8 f7 11 00 00       	call   101bc0 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
  1009c9:	8d 45 94             	lea    -0x6c(%ebp),%eax
  1009cc:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
  1009d3:	00 
  1009d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1009db:	00 
  1009dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009e0:	89 3c 24             	mov    %edi,(%esp)
  1009e3:	e8 88 09 00 00       	call   101370 <readi>
  1009e8:	83 f8 33             	cmp    $0x33,%eax
  1009eb:	0f 86 cf 01 00 00    	jbe    100bc0 <exec+0x220>
    goto bad;
  if(elf.magic != ELF_MAGIC)
  1009f1:	81 7d 94 7f 45 4c 46 	cmpl   $0x464c457f,-0x6c(%ebp)
  1009f8:	0f 85 c2 01 00 00    	jne    100bc0 <exec+0x220>
  1009fe:	66 90                	xchg   %ax,%ax
    goto bad;

  if((pgdir = setupkvm()) == 0)
  100a00:	e8 4b 54 00 00       	call   105e50 <setupkvm>
  100a05:	85 c0                	test   %eax,%eax
  100a07:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
  100a0d:	0f 84 ad 01 00 00    	je     100bc0 <exec+0x220>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100a13:	66 83 7d c0 00       	cmpw   $0x0,-0x40(%ebp)
  100a18:	8b 75 b0             	mov    -0x50(%ebp),%esi
  100a1b:	0f 84 c6 02 00 00    	je     100ce7 <exec+0x347>
  100a21:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  100a28:	00 00 00 
  100a2b:	31 db                	xor    %ebx,%ebx
  100a2d:	eb 13                	jmp    100a42 <exec+0xa2>
  100a2f:	90                   	nop
  100a30:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
  100a34:	83 c3 01             	add    $0x1,%ebx
  100a37:	39 d8                	cmp    %ebx,%eax
  100a39:	0f 8e b9 00 00 00    	jle    100af8 <exec+0x158>
  100a3f:	83 c6 20             	add    $0x20,%esi
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
  100a42:	8d 55 c8             	lea    -0x38(%ebp),%edx
  100a45:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
  100a4c:	00 
  100a4d:	89 74 24 08          	mov    %esi,0x8(%esp)
  100a51:	89 54 24 04          	mov    %edx,0x4(%esp)
  100a55:	89 3c 24             	mov    %edi,(%esp)
  100a58:	e8 13 09 00 00       	call   101370 <readi>
  100a5d:	83 f8 20             	cmp    $0x20,%eax
  100a60:	75 6e                	jne    100ad0 <exec+0x130>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
  100a62:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  100a66:	75 c8                	jne    100a30 <exec+0x90>
      continue;
    if(ph.memsz < ph.filesz)
  100a68:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a6b:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  100a6e:	66 90                	xchg   %ax,%ax
  100a70:	72 5e                	jb     100ad0 <exec+0x130>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.va + ph.memsz)) == 0)
  100a72:	03 45 d0             	add    -0x30(%ebp),%eax
  100a75:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  100a7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a7f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100a85:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100a89:	89 04 24             	mov    %eax,(%esp)
  100a8c:	e8 bf 56 00 00       	call   106150 <allocuvm>
  100a91:	85 c0                	test   %eax,%eax
  100a93:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
  100a99:	74 35                	je     100ad0 <exec+0x130>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.va, ip, ph.offset, ph.filesz) < 0)
  100a9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100a9e:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  100aa4:	89 7c 24 08          	mov    %edi,0x8(%esp)
  100aa8:	89 44 24 10          	mov    %eax,0x10(%esp)
  100aac:	8b 45 cc             	mov    -0x34(%ebp),%eax
  100aaf:	89 14 24             	mov    %edx,(%esp)
  100ab2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100ab6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
  100abd:	e8 5e 57 00 00       	call   106220 <loaduvm>
  100ac2:	85 c0                	test   %eax,%eax
  100ac4:	0f 89 66 ff ff ff    	jns    100a30 <exec+0x90>
  100aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  100ad0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100ad6:	89 04 24             	mov    %eax,(%esp)
  100ad9:	e8 32 55 00 00       	call   106010 <freevm>
  if(ip)
  100ade:	85 ff                	test   %edi,%edi
  100ae0:	0f 85 da 00 00 00    	jne    100bc0 <exec+0x220>
    iunlockput(ip);
  100ae6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
  100aeb:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  100af1:	5b                   	pop    %ebx
  100af2:	5e                   	pop    %esi
  100af3:	5f                   	pop    %edi
  100af4:	5d                   	pop    %ebp
  100af5:	c3                   	ret    
  100af6:	66 90                	xchg   %ax,%ax
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100af8:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100afe:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  100b04:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  100b0a:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
    if((sz = allocuvm(pgdir, sz, ph.va + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.va, ip, ph.offset, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  100b10:	89 3c 24             	mov    %edi,(%esp)
  100b13:	e8 b8 0f 00 00       	call   101ad0 <iunlockput>
  ip = 0;

  // Allocate a one-page stack at the next page boundary
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
  100b18:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
  100b1e:	89 74 24 08          	mov    %esi,0x8(%esp)
  100b22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100b26:	89 0c 24             	mov    %ecx,(%esp)
  100b29:	e8 22 56 00 00       	call   106150 <allocuvm>
  100b2e:	85 c0                	test   %eax,%eax
  100b30:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
  100b36:	74 7f                	je     100bb7 <exec+0x217>
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100b38:	8b 55 0c             	mov    0xc(%ebp),%edx
  100b3b:	8b 02                	mov    (%edx),%eax
  100b3d:	85 c0                	test   %eax,%eax
  100b3f:	0f 84 83 01 00 00    	je     100cc8 <exec+0x328>
  100b45:	8b 7d 0c             	mov    0xc(%ebp),%edi
  100b48:	31 f6                	xor    %esi,%esi
  100b4a:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100b50:	eb 28                	jmp    100b7a <exec+0x1da>
  100b52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  100b58:	89 9c b5 10 ff ff ff 	mov    %ebx,-0xf0(%ebp,%esi,4)
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
  100b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100b62:	83 c6 01             	add    $0x1,%esi
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  100b65:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
  100b6b:	8d 3c b0             	lea    (%eax,%esi,4),%edi
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100b6e:	8b 04 b0             	mov    (%eax,%esi,4),%eax
  100b71:	85 c0                	test   %eax,%eax
  100b73:	74 5d                	je     100bd2 <exec+0x232>
    if(argc >= MAXARG)
  100b75:	83 fe 20             	cmp    $0x20,%esi
  100b78:	74 3d                	je     100bb7 <exec+0x217>
      goto bad;
    sp -= strlen(argv[argc]) + 1;
  100b7a:	89 04 24             	mov    %eax,(%esp)
  100b7d:	e8 3e 32 00 00       	call   103dc0 <strlen>
  100b82:	f7 d0                	not    %eax
  100b84:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
  100b87:	8b 07                	mov    (%edi),%eax
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
  100b89:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
  100b8c:	89 04 24             	mov    %eax,(%esp)
  100b8f:	e8 2c 32 00 00       	call   103dc0 <strlen>
  100b94:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
  100b9a:	83 c0 01             	add    $0x1,%eax
  100b9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100ba1:	8b 07                	mov    (%edi),%eax
  100ba3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100ba7:	89 0c 24             	mov    %ecx,(%esp)
  100baa:	89 44 24 08          	mov    %eax,0x8(%esp)
  100bae:	e8 7d 51 00 00       	call   105d30 <copyout>
  100bb3:	85 c0                	test   %eax,%eax
  100bb5:	79 a1                	jns    100b58 <exec+0x1b8>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip)
    iunlockput(ip);
  100bb7:	31 ff                	xor    %edi,%edi
  100bb9:	e9 12 ff ff ff       	jmp    100ad0 <exec+0x130>
  100bbe:	66 90                	xchg   %ax,%ax
  100bc0:	89 3c 24             	mov    %edi,(%esp)
  100bc3:	e8 08 0f 00 00       	call   101ad0 <iunlockput>
  100bc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100bcd:	e9 19 ff ff ff       	jmp    100aeb <exec+0x14b>
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100bd2:	8d 4e 03             	lea    0x3(%esi),%ecx
  100bd5:	8d 3c b5 04 00 00 00 	lea    0x4(,%esi,4),%edi
  100bdc:	8d 04 b5 10 00 00 00 	lea    0x10(,%esi,4),%eax
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
  100be3:	c7 84 8d 04 ff ff ff 	movl   $0x0,-0xfc(%ebp,%ecx,4)
  100bea:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100bee:	89 d9                	mov    %ebx,%ecx

  sp -= (3+argc+1) * 4;
  100bf0:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
  100bf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100bf6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100bfc:	29 f9                	sub    %edi,%ecx
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  100bfe:	c7 85 04 ff ff ff ff 	movl   $0xffffffff,-0xfc(%ebp)
  100c05:	ff ff ff 
  ustack[1] = argc;
  100c08:	89 b5 08 ff ff ff    	mov    %esi,-0xf8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c0e:	89 8d 0c ff ff ff    	mov    %ecx,-0xf4(%ebp)

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
  100c14:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100c1c:	89 04 24             	mov    %eax,(%esp)
  100c1f:	e8 0c 51 00 00       	call   105d30 <copyout>
  100c24:	85 c0                	test   %eax,%eax
  100c26:	78 8f                	js     100bb7 <exec+0x217>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
  100c28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  100c2b:	0f b6 11             	movzbl (%ecx),%edx
  100c2e:	84 d2                	test   %dl,%dl
  100c30:	74 21                	je     100c53 <exec+0x2b3>
  100c32:	89 c8                	mov    %ecx,%eax
  100c34:	83 c0 01             	add    $0x1,%eax
  100c37:	eb 11                	jmp    100c4a <exec+0x2aa>
  100c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  100c40:	0f b6 10             	movzbl (%eax),%edx
  100c43:	83 c0 01             	add    $0x1,%eax
  100c46:	84 d2                	test   %dl,%dl
  100c48:	74 09                	je     100c53 <exec+0x2b3>
    if(*s == '/')
  100c4a:	80 fa 2f             	cmp    $0x2f,%dl
  100c4d:	75 f1                	jne    100c40 <exec+0x2a0>
  100c4f:	89 c1                	mov    %eax,%ecx
  100c51:	eb ed                	jmp    100c40 <exec+0x2a0>
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
  100c53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100c59:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c5d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  100c64:	00 
  100c65:	83 c0 6c             	add    $0x6c,%eax
  100c68:	89 04 24             	mov    %eax,(%esp)
  100c6b:	e8 10 31 00 00       	call   103d80 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  100c70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  proc->pgdir = pgdir;
  100c76:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  100c7c:	8b 70 04             	mov    0x4(%eax),%esi
  proc->pgdir = pgdir;
  100c7f:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
  100c82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100c88:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  100c8e:	89 08                	mov    %ecx,(%eax)
  proc->tf->eip = elf.entry;  // main
  100c90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100c96:	8b 55 ac             	mov    -0x54(%ebp),%edx
  100c99:	8b 40 18             	mov    0x18(%eax),%eax
  100c9c:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
  100c9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100ca5:	8b 40 18             	mov    0x18(%eax),%eax
  100ca8:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(proc);
  100cab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100cb1:	89 04 24             	mov    %eax,(%esp)
  100cb4:	e8 27 56 00 00       	call   1062e0 <switchuvm>
  freevm(oldpgdir);
  100cb9:	89 34 24             	mov    %esi,(%esp)
  100cbc:	e8 4f 53 00 00       	call   106010 <freevm>
  100cc1:	31 c0                	xor    %eax,%eax

  return 0;
  100cc3:	e9 23 fe ff ff       	jmp    100aeb <exec+0x14b>
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100cc8:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100cce:	b0 10                	mov    $0x10,%al
  100cd0:	bf 04 00 00 00       	mov    $0x4,%edi
  100cd5:	b9 03 00 00 00       	mov    $0x3,%ecx
  100cda:	31 f6                	xor    %esi,%esi
  100cdc:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
  100ce2:	e9 fc fe ff ff       	jmp    100be3 <exec+0x243>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100ce7:	be 00 10 00 00       	mov    $0x1000,%esi
  100cec:	31 db                	xor    %ebx,%ebx
  100cee:	e9 1d fe ff ff       	jmp    100b10 <exec+0x170>
  100cf3:	90                   	nop
  100cf4:	90                   	nop
  100cf5:	90                   	nop
  100cf6:	90                   	nop
  100cf7:	90                   	nop
  100cf8:	90                   	nop
  100cf9:	90                   	nop
  100cfa:	90                   	nop
  100cfb:	90                   	nop
  100cfc:	90                   	nop
  100cfd:	90                   	nop
  100cfe:	90                   	nop
  100cff:	90                   	nop

00100d00 <filewrite>:
}

// Write to file f.  Addr is kernel address.
int
filewrite(struct file *f, char *addr, int n)
{
  100d00:	55                   	push   %ebp
  100d01:	89 e5                	mov    %esp,%ebp
  100d03:	83 ec 38             	sub    $0x38,%esp
  100d06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100d09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100d0c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100d0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  100d12:	89 7d fc             	mov    %edi,-0x4(%ebp)
  100d15:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->writable == 0)
  100d18:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
  100d1c:	74 5a                	je     100d78 <filewrite+0x78>
    return -1;
  if(f->type == FD_PIPE)
  100d1e:	8b 03                	mov    (%ebx),%eax
  100d20:	83 f8 01             	cmp    $0x1,%eax
  100d23:	74 5b                	je     100d80 <filewrite+0x80>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
  100d25:	83 f8 02             	cmp    $0x2,%eax
  100d28:	75 6d                	jne    100d97 <filewrite+0x97>
    ilock(f->ip);
  100d2a:	8b 43 10             	mov    0x10(%ebx),%eax
  100d2d:	89 04 24             	mov    %eax,(%esp)
  100d30:	e8 8b 0e 00 00       	call   101bc0 <ilock>
    if((r = writei(f->ip, addr, f->off, n)) > 0)
  100d35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  100d39:	8b 43 14             	mov    0x14(%ebx),%eax
  100d3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  100d40:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d44:	8b 43 10             	mov    0x10(%ebx),%eax
  100d47:	89 04 24             	mov    %eax,(%esp)
  100d4a:	e8 b1 07 00 00       	call   101500 <writei>
  100d4f:	85 c0                	test   %eax,%eax
  100d51:	7e 03                	jle    100d56 <filewrite+0x56>
      f->off += r;
  100d53:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
  100d56:	8b 53 10             	mov    0x10(%ebx),%edx
  100d59:	89 14 24             	mov    %edx,(%esp)
  100d5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100d5f:	e8 0c 0a 00 00       	call   101770 <iunlock>
    return r;
  100d64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("filewrite");
}
  100d67:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100d6a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100d6d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100d70:	89 ec                	mov    %ebp,%esp
  100d72:	5d                   	pop    %ebp
  100d73:	c3                   	ret    
  100d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((r = writei(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
  100d78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100d7d:	eb e8                	jmp    100d67 <filewrite+0x67>
  100d7f:	90                   	nop
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100d80:	8b 43 0c             	mov    0xc(%ebx),%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
}
  100d83:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100d86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100d89:	8b 7d fc             	mov    -0x4(%ebp),%edi
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100d8c:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
}
  100d8f:	89 ec                	mov    %ebp,%esp
  100d91:	5d                   	pop    %ebp
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100d92:	e9 d9 1f 00 00       	jmp    102d70 <pipewrite>
    if((r = writei(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
  100d97:	c7 04 24 1f 65 10 00 	movl   $0x10651f,(%esp)
  100d9e:	e8 7d fb ff ff       	call   100920 <panic>
  100da3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100da9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100db0 <fileread>:
}

// Read from file f.  Addr is kernel address.
int
fileread(struct file *f, char *addr, int n)
{
  100db0:	55                   	push   %ebp
  100db1:	89 e5                	mov    %esp,%ebp
  100db3:	83 ec 38             	sub    $0x38,%esp
  100db6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100db9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100dbc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100dbf:	8b 75 0c             	mov    0xc(%ebp),%esi
  100dc2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  100dc5:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
  100dc8:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
  100dcc:	74 5a                	je     100e28 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
  100dce:	8b 03                	mov    (%ebx),%eax
  100dd0:	83 f8 01             	cmp    $0x1,%eax
  100dd3:	74 5b                	je     100e30 <fileread+0x80>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
  100dd5:	83 f8 02             	cmp    $0x2,%eax
  100dd8:	75 6d                	jne    100e47 <fileread+0x97>
    ilock(f->ip);
  100dda:	8b 43 10             	mov    0x10(%ebx),%eax
  100ddd:	89 04 24             	mov    %eax,(%esp)
  100de0:	e8 db 0d 00 00       	call   101bc0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
  100de5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  100de9:	8b 43 14             	mov    0x14(%ebx),%eax
  100dec:	89 74 24 04          	mov    %esi,0x4(%esp)
  100df0:	89 44 24 08          	mov    %eax,0x8(%esp)
  100df4:	8b 43 10             	mov    0x10(%ebx),%eax
  100df7:	89 04 24             	mov    %eax,(%esp)
  100dfa:	e8 71 05 00 00       	call   101370 <readi>
  100dff:	85 c0                	test   %eax,%eax
  100e01:	7e 03                	jle    100e06 <fileread+0x56>
      f->off += r;
  100e03:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
  100e06:	8b 53 10             	mov    0x10(%ebx),%edx
  100e09:	89 14 24             	mov    %edx,(%esp)
  100e0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100e0f:	e8 5c 09 00 00       	call   101770 <iunlock>
    return r;
  100e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("fileread");
}
  100e17:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100e1a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100e1d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100e20:	89 ec                	mov    %ebp,%esp
  100e22:	5d                   	pop    %ebp
  100e23:	c3                   	ret    
  100e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
  100e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100e2d:	eb e8                	jmp    100e17 <fileread+0x67>
  100e2f:	90                   	nop
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100e30:	8b 43 0c             	mov    0xc(%ebx),%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
  100e33:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100e36:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100e39:	8b 7d fc             	mov    -0x4(%ebp),%edi
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100e3c:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
  100e3f:	89 ec                	mov    %ebp,%esp
  100e41:	5d                   	pop    %ebp
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100e42:	e9 29 1e 00 00       	jmp    102c70 <piperead>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
  100e47:	c7 04 24 29 65 10 00 	movl   $0x106529,(%esp)
  100e4e:	e8 cd fa ff ff       	call   100920 <panic>
  100e53:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100e59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100e60 <filestat>:
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  100e60:	55                   	push   %ebp
  if(f->type == FD_INODE){
  100e61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  100e66:	89 e5                	mov    %esp,%ebp
  100e68:	53                   	push   %ebx
  100e69:	83 ec 14             	sub    $0x14,%esp
  100e6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
  100e6f:	83 3b 02             	cmpl   $0x2,(%ebx)
  100e72:	74 0c                	je     100e80 <filestat+0x20>
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
  }
  return -1;
}
  100e74:	83 c4 14             	add    $0x14,%esp
  100e77:	5b                   	pop    %ebx
  100e78:	5d                   	pop    %ebp
  100e79:	c3                   	ret    
  100e7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
  100e80:	8b 43 10             	mov    0x10(%ebx),%eax
  100e83:	89 04 24             	mov    %eax,(%esp)
  100e86:	e8 35 0d 00 00       	call   101bc0 <ilock>
    stati(f->ip, st);
  100e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  100e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100e92:	8b 43 10             	mov    0x10(%ebx),%eax
  100e95:	89 04 24             	mov    %eax,(%esp)
  100e98:	e8 e3 01 00 00       	call   101080 <stati>
    iunlock(f->ip);
  100e9d:	8b 43 10             	mov    0x10(%ebx),%eax
  100ea0:	89 04 24             	mov    %eax,(%esp)
  100ea3:	e8 c8 08 00 00       	call   101770 <iunlock>
    return 0;
  }
  return -1;
}
  100ea8:	83 c4 14             	add    $0x14,%esp
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
  100eab:	31 c0                	xor    %eax,%eax
    return 0;
  }
  return -1;
}
  100ead:	5b                   	pop    %ebx
  100eae:	5d                   	pop    %ebp
  100eaf:	c3                   	ret    

00100eb0 <filedup>:
}

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
  100eb0:	55                   	push   %ebp
  100eb1:	89 e5                	mov    %esp,%ebp
  100eb3:	53                   	push   %ebx
  100eb4:	83 ec 14             	sub    $0x14,%esp
  100eb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
  100eba:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100ec1:	e8 7a 2c 00 00       	call   103b40 <acquire>
  if(f->ref < 1)
  100ec6:	8b 43 04             	mov    0x4(%ebx),%eax
  100ec9:	85 c0                	test   %eax,%eax
  100ecb:	7e 1a                	jle    100ee7 <filedup+0x37>
    panic("filedup");
  f->ref++;
  100ecd:	83 c0 01             	add    $0x1,%eax
  100ed0:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
  100ed3:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100eda:	e8 11 2c 00 00       	call   103af0 <release>
  return f;
}
  100edf:	89 d8                	mov    %ebx,%eax
  100ee1:	83 c4 14             	add    $0x14,%esp
  100ee4:	5b                   	pop    %ebx
  100ee5:	5d                   	pop    %ebp
  100ee6:	c3                   	ret    
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
  100ee7:	c7 04 24 32 65 10 00 	movl   $0x106532,(%esp)
  100eee:	e8 2d fa ff ff       	call   100920 <panic>
  100ef3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100ef9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100f00 <filealloc>:
}

// Allocate a file structure.
struct file*
filealloc(void)
{
  100f00:	55                   	push   %ebp
  100f01:	89 e5                	mov    %esp,%ebp
  100f03:	53                   	push   %ebx
  initlock(&ftable.lock, "ftable");
}

// Allocate a file structure.
struct file*
filealloc(void)
  100f04:	bb 2c a1 10 00       	mov    $0x10a12c,%ebx
{
  100f09:	83 ec 14             	sub    $0x14,%esp
  struct file *f;

  acquire(&ftable.lock);
  100f0c:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f13:	e8 28 2c 00 00       	call   103b40 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
  100f18:	8b 15 18 a1 10 00    	mov    0x10a118,%edx
  100f1e:	85 d2                	test   %edx,%edx
  100f20:	75 11                	jne    100f33 <filealloc+0x33>
  100f22:	eb 4a                	jmp    100f6e <filealloc+0x6e>
  100f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
  100f28:	83 c3 18             	add    $0x18,%ebx
  100f2b:	81 fb 74 aa 10 00    	cmp    $0x10aa74,%ebx
  100f31:	74 25                	je     100f58 <filealloc+0x58>
    if(f->ref == 0){
  100f33:	8b 43 04             	mov    0x4(%ebx),%eax
  100f36:	85 c0                	test   %eax,%eax
  100f38:	75 ee                	jne    100f28 <filealloc+0x28>
      f->ref = 1;
  100f3a:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
  100f41:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f48:	e8 a3 2b 00 00       	call   103af0 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
  100f4d:	89 d8                	mov    %ebx,%eax
  100f4f:	83 c4 14             	add    $0x14,%esp
  100f52:	5b                   	pop    %ebx
  100f53:	5d                   	pop    %ebp
  100f54:	c3                   	ret    
  100f55:	8d 76 00             	lea    0x0(%esi),%esi
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
  100f58:	31 db                	xor    %ebx,%ebx
  100f5a:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f61:	e8 8a 2b 00 00       	call   103af0 <release>
  return 0;
}
  100f66:	89 d8                	mov    %ebx,%eax
  100f68:	83 c4 14             	add    $0x14,%esp
  100f6b:	5b                   	pop    %ebx
  100f6c:	5d                   	pop    %ebp
  100f6d:	c3                   	ret    
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
  100f6e:	bb 14 a1 10 00       	mov    $0x10a114,%ebx
  100f73:	eb c5                	jmp    100f3a <filealloc+0x3a>
  100f75:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  100f79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100f80 <fileclose>:
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
  100f80:	55                   	push   %ebp
  100f81:	89 e5                	mov    %esp,%ebp
  100f83:	83 ec 38             	sub    $0x38,%esp
  100f86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100f89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100f8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100f8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct file ff;

  acquire(&ftable.lock);
  100f92:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f99:	e8 a2 2b 00 00       	call   103b40 <acquire>
  if(f->ref < 1)
  100f9e:	8b 43 04             	mov    0x4(%ebx),%eax
  100fa1:	85 c0                	test   %eax,%eax
  100fa3:	0f 8e 9c 00 00 00    	jle    101045 <fileclose+0xc5>
    panic("fileclose");
  if(--f->ref > 0){
  100fa9:	83 e8 01             	sub    $0x1,%eax
  100fac:	85 c0                	test   %eax,%eax
  100fae:	89 43 04             	mov    %eax,0x4(%ebx)
  100fb1:	74 1d                	je     100fd0 <fileclose+0x50>
    release(&ftable.lock);
  100fb3:	c7 45 08 e0 a0 10 00 	movl   $0x10a0e0,0x8(%ebp)
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
}
  100fba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100fbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100fc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100fc3:	89 ec                	mov    %ebp,%esp
  100fc5:	5d                   	pop    %ebp

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
  100fc6:	e9 25 2b 00 00       	jmp    103af0 <release>
  100fcb:	90                   	nop
  100fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  }
  ff = *f;
  100fd0:	8b 43 0c             	mov    0xc(%ebx),%eax
  100fd3:	8b 7b 10             	mov    0x10(%ebx),%edi
  100fd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  100fd9:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  100fdd:	88 45 e7             	mov    %al,-0x19(%ebp)
  100fe0:	8b 33                	mov    (%ebx),%esi
  f->ref = 0;
  100fe2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
  100fe9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
  100fef:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100ff6:	e8 f5 2a 00 00       	call   103af0 <release>
  
  if(ff.type == FD_PIPE)
  100ffb:	83 fe 01             	cmp    $0x1,%esi
  100ffe:	74 30                	je     101030 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
  101000:	83 fe 02             	cmp    $0x2,%esi
  101003:	74 13                	je     101018 <fileclose+0x98>
    iput(ff.ip);
}
  101005:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  101008:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10100b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  10100e:	89 ec                	mov    %ebp,%esp
  101010:	5d                   	pop    %ebp
  101011:	c3                   	ret    
  101012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
  101018:	89 7d 08             	mov    %edi,0x8(%ebp)
}
  10101b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10101e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101021:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101024:	89 ec                	mov    %ebp,%esp
  101026:	5d                   	pop    %ebp
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
  101027:	e9 54 08 00 00       	jmp    101880 <iput>
  10102c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  101030:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101034:	89 44 24 04          	mov    %eax,0x4(%esp)
  101038:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10103b:	89 04 24             	mov    %eax,(%esp)
  10103e:	e8 1d 1e 00 00       	call   102e60 <pipeclose>
  101043:	eb c0                	jmp    101005 <fileclose+0x85>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  101045:	c7 04 24 3a 65 10 00 	movl   $0x10653a,(%esp)
  10104c:	e8 cf f8 ff ff       	call   100920 <panic>
  101051:	eb 0d                	jmp    101060 <fileinit>
  101053:	90                   	nop
  101054:	90                   	nop
  101055:	90                   	nop
  101056:	90                   	nop
  101057:	90                   	nop
  101058:	90                   	nop
  101059:	90                   	nop
  10105a:	90                   	nop
  10105b:	90                   	nop
  10105c:	90                   	nop
  10105d:	90                   	nop
  10105e:	90                   	nop
  10105f:	90                   	nop

00101060 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
  101060:	55                   	push   %ebp
  101061:	89 e5                	mov    %esp,%ebp
  101063:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
  101066:	c7 44 24 04 44 65 10 	movl   $0x106544,0x4(%esp)
  10106d:	00 
  10106e:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  101075:	e8 36 29 00 00       	call   1039b0 <initlock>
}
  10107a:	c9                   	leave  
  10107b:	c3                   	ret    
  10107c:	90                   	nop
  10107d:	90                   	nop
  10107e:	90                   	nop
  10107f:	90                   	nop

00101080 <stati>:
}

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
  101080:	55                   	push   %ebp
  101081:	89 e5                	mov    %esp,%ebp
  101083:	8b 55 08             	mov    0x8(%ebp),%edx
  101086:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
  101089:	8b 0a                	mov    (%edx),%ecx
  10108b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
  10108e:	8b 4a 04             	mov    0x4(%edx),%ecx
  101091:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
  101094:	0f b7 4a 10          	movzwl 0x10(%edx),%ecx
  101098:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
  10109b:	0f b7 4a 16          	movzwl 0x16(%edx),%ecx
  10109f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
  1010a3:	8b 52 18             	mov    0x18(%edx),%edx
  1010a6:	89 50 10             	mov    %edx,0x10(%eax)
}
  1010a9:	5d                   	pop    %ebp
  1010aa:	c3                   	ret    
  1010ab:	90                   	nop
  1010ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

001010b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
  1010b0:	55                   	push   %ebp
  1010b1:	89 e5                	mov    %esp,%ebp
  1010b3:	53                   	push   %ebx
  1010b4:	83 ec 14             	sub    $0x14,%esp
  1010b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
  1010ba:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1010c1:	e8 7a 2a 00 00       	call   103b40 <acquire>
  ip->ref++;
  1010c6:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
  1010ca:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1010d1:	e8 1a 2a 00 00       	call   103af0 <release>
  return ip;
}
  1010d6:	89 d8                	mov    %ebx,%eax
  1010d8:	83 c4 14             	add    $0x14,%esp
  1010db:	5b                   	pop    %ebx
  1010dc:	5d                   	pop    %ebp
  1010dd:	c3                   	ret    
  1010de:	66 90                	xchg   %ax,%ax

001010e0 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
{
  1010e0:	55                   	push   %ebp
  1010e1:	89 e5                	mov    %esp,%ebp
  1010e3:	57                   	push   %edi
  1010e4:	89 d7                	mov    %edx,%edi
  1010e6:	56                   	push   %esi
}

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
  1010e7:	31 f6                	xor    %esi,%esi
{
  1010e9:	53                   	push   %ebx
  1010ea:	89 c3                	mov    %eax,%ebx
  1010ec:	83 ec 2c             	sub    $0x2c,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
  1010ef:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1010f6:	e8 45 2a 00 00       	call   103b40 <acquire>
}

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
  1010fb:	b8 14 ab 10 00       	mov    $0x10ab14,%eax
  101100:	eb 14                	jmp    101116 <iget+0x36>
  101102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
  101108:	85 f6                	test   %esi,%esi
  10110a:	74 3c                	je     101148 <iget+0x68>

  acquire(&icache.lock);

  // Try for cached inode.
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
  10110c:	83 c0 50             	add    $0x50,%eax
  10110f:	3d b4 ba 10 00       	cmp    $0x10bab4,%eax
  101114:	74 42                	je     101158 <iget+0x78>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
  101116:	8b 48 08             	mov    0x8(%eax),%ecx
  101119:	85 c9                	test   %ecx,%ecx
  10111b:	7e eb                	jle    101108 <iget+0x28>
  10111d:	39 18                	cmp    %ebx,(%eax)
  10111f:	75 e7                	jne    101108 <iget+0x28>
  101121:	39 78 04             	cmp    %edi,0x4(%eax)
  101124:	75 e2                	jne    101108 <iget+0x28>
      ip->ref++;
  101126:	83 c1 01             	add    $0x1,%ecx
  101129:	89 48 08             	mov    %ecx,0x8(%eax)
      release(&icache.lock);
  10112c:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101133:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101136:	e8 b5 29 00 00       	call   103af0 <release>
      return ip;
  10113b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);

  return ip;
}
  10113e:	83 c4 2c             	add    $0x2c,%esp
  101141:	5b                   	pop    %ebx
  101142:	5e                   	pop    %esi
  101143:	5f                   	pop    %edi
  101144:	5d                   	pop    %ebp
  101145:	c3                   	ret    
  101146:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
  101148:	85 c9                	test   %ecx,%ecx
  10114a:	75 c0                	jne    10110c <iget+0x2c>
  10114c:	89 c6                	mov    %eax,%esi

  acquire(&icache.lock);

  // Try for cached inode.
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
  10114e:	83 c0 50             	add    $0x50,%eax
  101151:	3d b4 ba 10 00       	cmp    $0x10bab4,%eax
  101156:	75 be                	jne    101116 <iget+0x36>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Allocate fresh inode.
  if(empty == 0)
  101158:	85 f6                	test   %esi,%esi
  10115a:	74 29                	je     101185 <iget+0xa5>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
  10115c:	89 1e                	mov    %ebx,(%esi)
  ip->inum = inum;
  10115e:	89 7e 04             	mov    %edi,0x4(%esi)
  ip->ref = 1;
  101161:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->flags = 0;
  101168:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
  release(&icache.lock);
  10116f:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101176:	e8 75 29 00 00       	call   103af0 <release>

  return ip;
}
  10117b:	83 c4 2c             	add    $0x2c,%esp
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);
  10117e:	89 f0                	mov    %esi,%eax

  return ip;
}
  101180:	5b                   	pop    %ebx
  101181:	5e                   	pop    %esi
  101182:	5f                   	pop    %edi
  101183:	5d                   	pop    %ebp
  101184:	c3                   	ret    
      empty = ip;
  }

  // Allocate fresh inode.
  if(empty == 0)
    panic("iget: no inodes");
  101185:	c7 04 24 4b 65 10 00 	movl   $0x10654b,(%esp)
  10118c:	e8 8f f7 ff ff       	call   100920 <panic>
  101191:	eb 0d                	jmp    1011a0 <readsb>
  101193:	90                   	nop
  101194:	90                   	nop
  101195:	90                   	nop
  101196:	90                   	nop
  101197:	90                   	nop
  101198:	90                   	nop
  101199:	90                   	nop
  10119a:	90                   	nop
  10119b:	90                   	nop
  10119c:	90                   	nop
  10119d:	90                   	nop
  10119e:	90                   	nop
  10119f:	90                   	nop

001011a0 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
static void
readsb(int dev, struct superblock *sb)
{
  1011a0:	55                   	push   %ebp
  1011a1:	89 e5                	mov    %esp,%ebp
  1011a3:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
  1011a6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1011ad:	00 
static void itrunc(struct inode*);

// Read the super block.
static void
readsb(int dev, struct superblock *sb)
{
  1011ae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  1011b1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  1011b4:	89 d6                	mov    %edx,%esi
  struct buf *bp;
  
  bp = bread(dev, 1);
  1011b6:	89 04 24             	mov    %eax,(%esp)
  1011b9:	e8 62 ef ff ff       	call   100120 <bread>
  memmove(sb, bp->data, sizeof(*sb));
  1011be:	89 34 24             	mov    %esi,(%esp)
  1011c1:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
  1011c8:	00 
static void
readsb(int dev, struct superblock *sb)
{
  struct buf *bp;
  
  bp = bread(dev, 1);
  1011c9:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
  1011cb:	8d 40 18             	lea    0x18(%eax),%eax
  1011ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1011d2:	e8 89 2a 00 00       	call   103c60 <memmove>
  brelse(bp);
  1011d7:	89 1c 24             	mov    %ebx,(%esp)
  1011da:	e8 91 ee ff ff       	call   100070 <brelse>
}
  1011df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  1011e2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  1011e5:	89 ec                	mov    %ebp,%esp
  1011e7:	5d                   	pop    %ebp
  1011e8:	c3                   	ret    
  1011e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001011f0 <balloc>:
// Blocks. 

// Allocate a disk block.
static uint
balloc(uint dev)
{
  1011f0:	55                   	push   %ebp
  1011f1:	89 e5                	mov    %esp,%ebp
  1011f3:	57                   	push   %edi
  1011f4:	56                   	push   %esi
  1011f5:	53                   	push   %ebx
  1011f6:	83 ec 3c             	sub    $0x3c,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  1011f9:	8d 55 dc             	lea    -0x24(%ebp),%edx
// Blocks. 

// Allocate a disk block.
static uint
balloc(uint dev)
{
  1011fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  1011ff:	e8 9c ff ff ff       	call   1011a0 <readsb>
  for(b = 0; b < sb.size; b += BPB){
  101204:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101207:	85 c0                	test   %eax,%eax
  101209:	0f 84 9c 00 00 00    	je     1012ab <balloc+0xbb>
  10120f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    bp = bread(dev, BBLOCK(b, sb.ninodes));
  101216:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101219:	31 db                	xor    %ebx,%ebx
  10121b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10121e:	c1 e8 03             	shr    $0x3,%eax
  101221:	c1 fa 0c             	sar    $0xc,%edx
  101224:	8d 44 10 03          	lea    0x3(%eax,%edx,1),%eax
  101228:	89 44 24 04          	mov    %eax,0x4(%esp)
  10122c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10122f:	89 04 24             	mov    %eax,(%esp)
  101232:	e8 e9 ee ff ff       	call   100120 <bread>
  101237:	89 c6                	mov    %eax,%esi
  101239:	eb 10                	jmp    10124b <balloc+0x5b>
  10123b:	90                   	nop
  10123c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(bi = 0; bi < BPB; bi++){
  101240:	83 c3 01             	add    $0x1,%ebx
  101243:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  101249:	74 45                	je     101290 <balloc+0xa0>
      m = 1 << (bi % 8);
  10124b:	89 d9                	mov    %ebx,%ecx
  10124d:	ba 01 00 00 00       	mov    $0x1,%edx
  101252:	83 e1 07             	and    $0x7,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
  101255:	89 d8                	mov    %ebx,%eax
  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB; bi++){
      m = 1 << (bi % 8);
  101257:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
  101259:	c1 f8 03             	sar    $0x3,%eax
  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB; bi++){
      m = 1 << (bi % 8);
  10125c:	89 d1                	mov    %edx,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
  10125e:	0f b6 54 06 18       	movzbl 0x18(%esi,%eax,1),%edx
  101263:	0f b6 fa             	movzbl %dl,%edi
  101266:	85 cf                	test   %ecx,%edi
  101268:	75 d6                	jne    101240 <balloc+0x50>
        bp->data[bi/8] |= m;  // Mark block in use on disk.
  10126a:	09 d1                	or     %edx,%ecx
  10126c:	88 4c 06 18          	mov    %cl,0x18(%esi,%eax,1)
        bwrite(bp);
  101270:	89 34 24             	mov    %esi,(%esp)
  101273:	e8 78 ee ff ff       	call   1000f0 <bwrite>
        brelse(bp);
  101278:	89 34 24             	mov    %esi,(%esp)
  10127b:	e8 f0 ed ff ff       	call   100070 <brelse>
  101280:	8b 55 d4             	mov    -0x2c(%ebp),%edx
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
  101283:	83 c4 3c             	add    $0x3c,%esp
    for(bi = 0; bi < BPB; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use on disk.
        bwrite(bp);
        brelse(bp);
  101286:	8d 04 13             	lea    (%ebx,%edx,1),%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
  101289:	5b                   	pop    %ebx
  10128a:	5e                   	pop    %esi
  10128b:	5f                   	pop    %edi
  10128c:	5d                   	pop    %ebp
  10128d:	c3                   	ret    
  10128e:	66 90                	xchg   %ax,%ax
        bwrite(bp);
        brelse(bp);
        return b + bi;
      }
    }
    brelse(bp);
  101290:	89 34 24             	mov    %esi,(%esp)
  101293:	e8 d8 ed ff ff       	call   100070 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
  101298:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
  10129f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1012a2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1012a5:	0f 87 6b ff ff ff    	ja     101216 <balloc+0x26>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
  1012ab:	c7 04 24 5b 65 10 00 	movl   $0x10655b,(%esp)
  1012b2:	e8 69 f6 ff ff       	call   100920 <panic>
  1012b7:	89 f6                	mov    %esi,%esi
  1012b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001012c0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
  1012c0:	55                   	push   %ebp
  1012c1:	89 e5                	mov    %esp,%ebp
  1012c3:	83 ec 38             	sub    $0x38,%esp
  1012c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1012c9:	89 c3                	mov    %eax,%ebx
  1012cb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1012ce:	89 7d fc             	mov    %edi,-0x4(%ebp)
  uint addr, *a;
  struct buf *bp;

  if (ip->type == T_EXTENT) {
  1012d1:	66 83 78 10 04       	cmpw   $0x4,0x10(%eax)
  1012d6:	74 78                	je     101350 <bmap+0x90>
    // Deal with extent based shizzle
    return 0;
  }

  if(bn < NDIRECT){
  1012d8:	83 fa 0b             	cmp    $0xb,%edx
  1012db:	76 5b                	jbe    101338 <bmap+0x78>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
  1012dd:	8d 7a f4             	lea    -0xc(%edx),%edi

  if(bn < NINDIRECT){
  1012e0:	83 ff 7f             	cmp    $0x7f,%edi
  1012e3:	77 7f                	ja     101364 <bmap+0xa4>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
  1012e5:	8b 40 4c             	mov    0x4c(%eax),%eax
  1012e8:	85 c0                	test   %eax,%eax
  1012ea:	74 6c                	je     101358 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  1012ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  1012f0:	8b 03                	mov    (%ebx),%eax
  1012f2:	89 04 24             	mov    %eax,(%esp)
  1012f5:	e8 26 ee ff ff       	call   100120 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  1012fa:	8d 7c b8 18          	lea    0x18(%eax,%edi,4),%edi

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  1012fe:	89 c6                	mov    %eax,%esi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  101300:	8b 07                	mov    (%edi),%eax
  101302:	85 c0                	test   %eax,%eax
  101304:	75 17                	jne    10131d <bmap+0x5d>
      a[bn] = addr = balloc(ip->dev);
  101306:	8b 03                	mov    (%ebx),%eax
  101308:	e8 e3 fe ff ff       	call   1011f0 <balloc>
  10130d:	89 07                	mov    %eax,(%edi)
      bwrite(bp);
  10130f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101312:	89 34 24             	mov    %esi,(%esp)
  101315:	e8 d6 ed ff ff       	call   1000f0 <bwrite>
  10131a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    }
    brelse(bp);
  10131d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101320:	89 34 24             	mov    %esi,(%esp)
  101323:	e8 48 ed ff ff       	call   100070 <brelse>
    return addr;
  101328:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }

  panic("bmap: out of range");
}
  10132b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10132e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101331:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101334:	89 ec                	mov    %ebp,%esp
  101336:	5d                   	pop    %ebp
  101337:	c3                   	ret    
    // Deal with extent based shizzle
    return 0;
  }

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
  101338:	8d 7a 04             	lea    0x4(%edx),%edi
  10133b:	8b 44 b8 0c          	mov    0xc(%eax,%edi,4),%eax
  10133f:	85 c0                	test   %eax,%eax
  101341:	75 e8                	jne    10132b <bmap+0x6b>
      ip->addrs[bn] = addr = balloc(ip->dev);
  101343:	8b 03                	mov    (%ebx),%eax
  101345:	e8 a6 fe ff ff       	call   1011f0 <balloc>
  10134a:	89 44 bb 0c          	mov    %eax,0xc(%ebx,%edi,4)
  10134e:	eb db                	jmp    10132b <bmap+0x6b>
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
  101350:	31 c0                	xor    %eax,%eax
  101352:	eb d7                	jmp    10132b <bmap+0x6b>
  101354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
  101358:	8b 03                	mov    (%ebx),%eax
  10135a:	e8 91 fe ff ff       	call   1011f0 <balloc>
  10135f:	89 43 4c             	mov    %eax,0x4c(%ebx)
  101362:	eb 88                	jmp    1012ec <bmap+0x2c>
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
  101364:	c7 04 24 71 65 10 00 	movl   $0x106571,(%esp)
  10136b:	e8 b0 f5 ff ff       	call   100920 <panic>

00101370 <readi>:
}

// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
  101370:	55                   	push   %ebp
  101371:	89 e5                	mov    %esp,%ebp
  101373:	83 ec 38             	sub    $0x38,%esp
  101376:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  101379:	8b 5d 08             	mov    0x8(%ebp),%ebx
  10137c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10137f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  101382:	89 7d fc             	mov    %edi,-0x4(%ebp)
  101385:	8b 75 10             	mov    0x10(%ebp),%esi
  101388:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
  10138b:	66 83 7b 10 03       	cmpw   $0x3,0x10(%ebx)
  101390:	74 1e                	je     1013b0 <readi+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
  101392:	8b 43 18             	mov    0x18(%ebx),%eax
  101395:	39 f0                	cmp    %esi,%eax
  101397:	73 3f                	jae    1013d8 <readi+0x68>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
  101399:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10139e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1013a1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1013a4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1013a7:	89 ec                	mov    %ebp,%esp
  1013a9:	5d                   	pop    %ebp
  1013aa:	c3                   	ret    
  1013ab:	90                   	nop
  1013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
  1013b0:	0f b7 43 12          	movzwl 0x12(%ebx),%eax
  1013b4:	66 83 f8 09          	cmp    $0x9,%ax
  1013b8:	77 df                	ja     101399 <readi+0x29>
  1013ba:	98                   	cwtl   
  1013bb:	8b 04 c5 80 aa 10 00 	mov    0x10aa80(,%eax,8),%eax
  1013c2:	85 c0                	test   %eax,%eax
  1013c4:	74 d3                	je     101399 <readi+0x29>
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  1013c6:	89 4d 10             	mov    %ecx,0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}
  1013c9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1013cc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1013cf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1013d2:	89 ec                	mov    %ebp,%esp
  1013d4:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  1013d5:	ff e0                	jmp    *%eax
  1013d7:	90                   	nop
  }

  if(off > ip->size || off + n < off)
  1013d8:	89 ca                	mov    %ecx,%edx
  1013da:	01 f2                	add    %esi,%edx
  1013dc:	72 bb                	jb     101399 <readi+0x29>
    return -1;
  if(off + n > ip->size)
  1013de:	39 d0                	cmp    %edx,%eax
  1013e0:	73 04                	jae    1013e6 <readi+0x76>
    n = ip->size - off;
  1013e2:	89 c1                	mov    %eax,%ecx
  1013e4:	29 f1                	sub    %esi,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  1013e6:	85 c9                	test   %ecx,%ecx
  1013e8:	74 7c                	je     101466 <readi+0xf6>
  1013ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
  1013f1:	89 7d e0             	mov    %edi,-0x20(%ebp)
  1013f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  1013f7:	90                   	nop
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  1013f8:	89 f2                	mov    %esi,%edx
  1013fa:	89 d8                	mov    %ebx,%eax
  1013fc:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  1013ff:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  101404:	e8 b7 fe ff ff       	call   1012c0 <bmap>
  101409:	89 44 24 04          	mov    %eax,0x4(%esp)
  10140d:	8b 03                	mov    (%ebx),%eax
  10140f:	89 04 24             	mov    %eax,(%esp)
  101412:	e8 09 ed ff ff       	call   100120 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
  101417:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10141a:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  10141d:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  10141f:	89 f0                	mov    %esi,%eax
  101421:	25 ff 01 00 00       	and    $0x1ff,%eax
  101426:	29 c7                	sub    %eax,%edi
  101428:	39 cf                	cmp    %ecx,%edi
  10142a:	76 02                	jbe    10142e <readi+0xbe>
  10142c:	89 cf                	mov    %ecx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
  10142e:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  101432:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
  101434:	89 7c 24 08          	mov    %edi,0x8(%esp)
  101438:	89 44 24 04          	mov    %eax,0x4(%esp)
  10143c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10143f:	89 04 24             	mov    %eax,(%esp)
  101442:	89 55 d8             	mov    %edx,-0x28(%ebp)
  101445:	e8 16 28 00 00       	call   103c60 <memmove>
    brelse(bp);
  10144a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10144d:	89 14 24             	mov    %edx,(%esp)
  101450:	e8 1b ec ff ff       	call   100070 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  101455:	01 7d e4             	add    %edi,-0x1c(%ebp)
  101458:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10145b:	01 7d e0             	add    %edi,-0x20(%ebp)
  10145e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  101461:	77 95                	ja     1013f8 <readi+0x88>
  101463:	8b 4d dc             	mov    -0x24(%ebp),%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
  101466:	89 c8                	mov    %ecx,%eax
  101468:	e9 31 ff ff ff       	jmp    10139e <readi+0x2e>
  10146d:	8d 76 00             	lea    0x0(%esi),%esi

00101470 <iupdate>:
}

// Copy inode, which has changed, from memory to disk.
void
iupdate(struct inode *ip)
{
  101470:	55                   	push   %ebp
  101471:	89 e5                	mov    %esp,%ebp
  101473:	56                   	push   %esi
  101474:	53                   	push   %ebx
  101475:	83 ec 10             	sub    $0x10,%esp
  101478:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
  10147b:	8b 43 04             	mov    0x4(%ebx),%eax
  10147e:	c1 e8 03             	shr    $0x3,%eax
  101481:	83 c0 02             	add    $0x2,%eax
  101484:	89 44 24 04          	mov    %eax,0x4(%esp)
  101488:	8b 03                	mov    (%ebx),%eax
  10148a:	89 04 24             	mov    %eax,(%esp)
  10148d:	e8 8e ec ff ff       	call   100120 <bread>
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  101492:	0f b7 53 10          	movzwl 0x10(%ebx),%edx
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
  101496:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  101498:	8b 43 04             	mov    0x4(%ebx),%eax
  10149b:	83 e0 07             	and    $0x7,%eax
  10149e:	c1 e0 06             	shl    $0x6,%eax
  1014a1:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
  dip->type = ip->type;
  1014a5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
  1014a8:	0f b7 53 12          	movzwl 0x12(%ebx),%edx
  1014ac:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
  1014b0:	0f b7 53 14          	movzwl 0x14(%ebx),%edx
  1014b4:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
  1014b8:	0f b7 53 16          	movzwl 0x16(%ebx),%edx
  1014bc:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
  1014c0:	8b 53 18             	mov    0x18(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  1014c3:	83 c3 1c             	add    $0x1c,%ebx
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  1014c6:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  1014c9:	83 c0 0c             	add    $0xc,%eax
  1014cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1014d0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
  1014d7:	00 
  1014d8:	89 04 24             	mov    %eax,(%esp)
  1014db:	e8 80 27 00 00       	call   103c60 <memmove>
  bwrite(bp);
  1014e0:	89 34 24             	mov    %esi,(%esp)
  1014e3:	e8 08 ec ff ff       	call   1000f0 <bwrite>
  brelse(bp);
  1014e8:	89 75 08             	mov    %esi,0x8(%ebp)
}
  1014eb:	83 c4 10             	add    $0x10,%esp
  1014ee:	5b                   	pop    %ebx
  1014ef:	5e                   	pop    %esi
  1014f0:	5d                   	pop    %ebp
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  bwrite(bp);
  brelse(bp);
  1014f1:	e9 7a eb ff ff       	jmp    100070 <brelse>
  1014f6:	8d 76 00             	lea    0x0(%esi),%esi
  1014f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101500 <writei>:
}

// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
  101500:	55                   	push   %ebp
  101501:	89 e5                	mov    %esp,%ebp
  101503:	83 ec 38             	sub    $0x38,%esp
  101506:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  101509:	8b 5d 08             	mov    0x8(%ebp),%ebx
  10150c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10150f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  101512:	89 7d fc             	mov    %edi,-0x4(%ebp)
  101515:	8b 75 10             	mov    0x10(%ebp),%esi
  101518:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
  10151b:	66 83 7b 10 03       	cmpw   $0x3,0x10(%ebx)
  101520:	74 1e                	je     101540 <writei+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
  101522:	39 73 18             	cmp    %esi,0x18(%ebx)
  101525:	73 41                	jae    101568 <writei+0x68>

  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
  101527:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10152c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10152f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101532:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101535:	89 ec                	mov    %ebp,%esp
  101537:	5d                   	pop    %ebp
  101538:	c3                   	ret    
  101539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
  101540:	0f b7 43 12          	movzwl 0x12(%ebx),%eax
  101544:	66 83 f8 09          	cmp    $0x9,%ax
  101548:	77 dd                	ja     101527 <writei+0x27>
  10154a:	98                   	cwtl   
  10154b:	8b 04 c5 84 aa 10 00 	mov    0x10aa84(,%eax,8),%eax
  101552:	85 c0                	test   %eax,%eax
  101554:	74 d1                	je     101527 <writei+0x27>
      return -1;
    return devsw[ip->major].write(ip, src, n);
  101556:	89 4d 10             	mov    %ecx,0x10(%ebp)
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
  101559:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10155c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10155f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101562:	89 ec                	mov    %ebp,%esp
  101564:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  101565:	ff e0                	jmp    *%eax
  101567:	90                   	nop
  }

  if(off > ip->size || off + n < off)
  101568:	89 c8                	mov    %ecx,%eax
  10156a:	01 f0                	add    %esi,%eax
  10156c:	72 b9                	jb     101527 <writei+0x27>
    return -1;
  if(off + n > MAXFILE*BSIZE)
  10156e:	3d 00 18 01 00       	cmp    $0x11800,%eax
  101573:	76 07                	jbe    10157c <writei+0x7c>
    n = MAXFILE*BSIZE - off;
  101575:	b9 00 18 01 00       	mov    $0x11800,%ecx
  10157a:	29 f1                	sub    %esi,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  10157c:	85 c9                	test   %ecx,%ecx
  10157e:	0f 84 92 00 00 00    	je     101616 <writei+0x116>
  101584:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
  10158b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  10158e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  101591:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  101598:	89 f2                	mov    %esi,%edx
  10159a:	89 d8                	mov    %ebx,%eax
  10159c:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  10159f:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  1015a4:	e8 17 fd ff ff       	call   1012c0 <bmap>
  1015a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1015ad:	8b 03                	mov    (%ebx),%eax
  1015af:	89 04 24             	mov    %eax,(%esp)
  1015b2:	e8 69 eb ff ff       	call   100120 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
  1015b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1015ba:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  1015bd:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  1015bf:	89 f0                	mov    %esi,%eax
  1015c1:	25 ff 01 00 00       	and    $0x1ff,%eax
  1015c6:	29 c7                	sub    %eax,%edi
  1015c8:	39 cf                	cmp    %ecx,%edi
  1015ca:	76 02                	jbe    1015ce <writei+0xce>
  1015cc:	89 cf                	mov    %ecx,%edi
    memmove(bp->data + off%BSIZE, src, m);
  1015ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  1015d2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1015d5:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
  1015d9:	89 04 24             	mov    %eax,(%esp)
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  1015dc:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(bp->data + off%BSIZE, src, m);
  1015de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  1015e2:	89 55 d8             	mov    %edx,-0x28(%ebp)
  1015e5:	e8 76 26 00 00       	call   103c60 <memmove>
    bwrite(bp);
  1015ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1015ed:	89 14 24             	mov    %edx,(%esp)
  1015f0:	e8 fb ea ff ff       	call   1000f0 <bwrite>
    brelse(bp);
  1015f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1015f8:	89 14 24             	mov    %edx,(%esp)
  1015fb:	e8 70 ea ff ff       	call   100070 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  101600:	01 7d e4             	add    %edi,-0x1c(%ebp)
  101603:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101606:	01 7d e0             	add    %edi,-0x20(%ebp)
  101609:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10160c:	77 8a                	ja     101598 <writei+0x98>
    memmove(bp->data + off%BSIZE, src, m);
    bwrite(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
  10160e:	3b 73 18             	cmp    0x18(%ebx),%esi
  101611:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  101614:	77 07                	ja     10161d <writei+0x11d>
    ip->size = off;
    iupdate(ip);
  }
  return n;
  101616:	89 c8                	mov    %ecx,%eax
  101618:	e9 0f ff ff ff       	jmp    10152c <writei+0x2c>
    bwrite(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
    ip->size = off;
  10161d:	89 73 18             	mov    %esi,0x18(%ebx)
    iupdate(ip);
  101620:	89 1c 24             	mov    %ebx,(%esp)
  101623:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  101626:	e8 45 fe ff ff       	call   101470 <iupdate>
  10162b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  }
  return n;
  10162e:	89 c8                	mov    %ecx,%eax
  101630:	e9 f7 fe ff ff       	jmp    10152c <writei+0x2c>
  101635:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101639:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101640 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
  101640:	55                   	push   %ebp
  101641:	89 e5                	mov    %esp,%ebp
  101643:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
  101646:	8b 45 0c             	mov    0xc(%ebp),%eax
  101649:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101650:	00 
  101651:	89 44 24 04          	mov    %eax,0x4(%esp)
  101655:	8b 45 08             	mov    0x8(%ebp),%eax
  101658:	89 04 24             	mov    %eax,(%esp)
  10165b:	e8 70 26 00 00       	call   103cd0 <strncmp>
}
  101660:	c9                   	leave  
  101661:	c3                   	ret    
  101662:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  101669:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101670 <dirlookup>:
// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
  101670:	55                   	push   %ebp
  101671:	89 e5                	mov    %esp,%ebp
  101673:	57                   	push   %edi
  101674:	56                   	push   %esi
  101675:	53                   	push   %ebx
  101676:	83 ec 3c             	sub    $0x3c,%esp
  101679:	8b 45 08             	mov    0x8(%ebp),%eax
  10167c:	8b 55 10             	mov    0x10(%ebp),%edx
  10167f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  101682:	89 45 dc             	mov    %eax,-0x24(%ebp)
  101685:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  uint off, inum;
  struct buf *bp;
  struct dirent *de;

  if(dp->type != T_DIR)
  101688:	66 83 78 10 01       	cmpw   $0x1,0x10(%eax)
  10168d:	0f 85 d0 00 00 00    	jne    101763 <dirlookup+0xf3>
    panic("dirlookup not DIR");
  101693:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  for(off = 0; off < dp->size; off += BSIZE){
  10169a:	8b 48 18             	mov    0x18(%eax),%ecx
  10169d:	85 c9                	test   %ecx,%ecx
  10169f:	0f 84 b4 00 00 00    	je     101759 <dirlookup+0xe9>
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
  1016a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1016a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1016ab:	c1 ea 09             	shr    $0x9,%edx
  1016ae:	e8 0d fc ff ff       	call   1012c0 <bmap>
  1016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1016b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1016ba:	8b 01                	mov    (%ecx),%eax
  1016bc:	89 04 24             	mov    %eax,(%esp)
  1016bf:	e8 5c ea ff ff       	call   100120 <bread>
  1016c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
  1016c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
  1016ca:	83 c0 18             	add    $0x18,%eax
  1016cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1016d0:	89 c6                	mov    %eax,%esi

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
  1016d2:	81 c7 18 02 00 00    	add    $0x218,%edi
  1016d8:	eb 0d                	jmp    1016e7 <dirlookup+0x77>
  1016da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
        de < (struct dirent*)(bp->data + BSIZE);
        de++){
  1016e0:	83 c6 10             	add    $0x10,%esi
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
  1016e3:	39 fe                	cmp    %edi,%esi
  1016e5:	74 51                	je     101738 <dirlookup+0xc8>
        de < (struct dirent*)(bp->data + BSIZE);
        de++){
      if(de->inum == 0)
  1016e7:	66 83 3e 00          	cmpw   $0x0,(%esi)
  1016eb:	74 f3                	je     1016e0 <dirlookup+0x70>
        continue;
      if(namecmp(name, de->name) == 0){
  1016ed:	8d 46 02             	lea    0x2(%esi),%eax
  1016f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1016f4:	89 1c 24             	mov    %ebx,(%esp)
  1016f7:	e8 44 ff ff ff       	call   101640 <namecmp>
  1016fc:	85 c0                	test   %eax,%eax
  1016fe:	75 e0                	jne    1016e0 <dirlookup+0x70>
        // entry matches path element
        if(poff)
  101700:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  101703:	85 d2                	test   %edx,%edx
  101705:	74 0e                	je     101715 <dirlookup+0xa5>
          *poff = off + (uchar*)de - bp->data;
  101707:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10170a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10170d:	8d 04 16             	lea    (%esi,%edx,1),%eax
  101710:	2b 45 d8             	sub    -0x28(%ebp),%eax
  101713:	89 01                	mov    %eax,(%ecx)
        inum = de->inum;
        brelse(bp);
  101715:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        continue;
      if(namecmp(name, de->name) == 0){
        // entry matches path element
        if(poff)
          *poff = off + (uchar*)de - bp->data;
        inum = de->inum;
  101718:	0f b7 1e             	movzwl (%esi),%ebx
        brelse(bp);
  10171b:	89 04 24             	mov    %eax,(%esp)
  10171e:	e8 4d e9 ff ff       	call   100070 <brelse>
        return iget(dp->dev, inum);
  101723:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  101726:	89 da                	mov    %ebx,%edx
  101728:	8b 01                	mov    (%ecx),%eax
      }
    }
    brelse(bp);
  }
  return 0;
}
  10172a:	83 c4 3c             	add    $0x3c,%esp
  10172d:	5b                   	pop    %ebx
  10172e:	5e                   	pop    %esi
  10172f:	5f                   	pop    %edi
  101730:	5d                   	pop    %ebp
        // entry matches path element
        if(poff)
          *poff = off + (uchar*)de - bp->data;
        inum = de->inum;
        brelse(bp);
        return iget(dp->dev, inum);
  101731:	e9 aa f9 ff ff       	jmp    1010e0 <iget>
  101736:	66 90                	xchg   %ax,%ax
      }
    }
    brelse(bp);
  101738:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10173b:	89 04 24             	mov    %eax,(%esp)
  10173e:	e8 2d e9 ff ff       	call   100070 <brelse>
  struct dirent *de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
  101743:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101746:	81 45 e0 00 02 00 00 	addl   $0x200,-0x20(%ebp)
  10174d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  101750:	39 4a 18             	cmp    %ecx,0x18(%edx)
  101753:	0f 87 4c ff ff ff    	ja     1016a5 <dirlookup+0x35>
      }
    }
    brelse(bp);
  }
  return 0;
}
  101759:	83 c4 3c             	add    $0x3c,%esp
  10175c:	31 c0                	xor    %eax,%eax
  10175e:	5b                   	pop    %ebx
  10175f:	5e                   	pop    %esi
  101760:	5f                   	pop    %edi
  101761:	5d                   	pop    %ebp
  101762:	c3                   	ret    
  uint off, inum;
  struct buf *bp;
  struct dirent *de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
  101763:	c7 04 24 84 65 10 00 	movl   $0x106584,(%esp)
  10176a:	e8 b1 f1 ff ff       	call   100920 <panic>
  10176f:	90                   	nop

00101770 <iunlock>:
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  101770:	55                   	push   %ebp
  101771:	89 e5                	mov    %esp,%ebp
  101773:	53                   	push   %ebx
  101774:	83 ec 14             	sub    $0x14,%esp
  101777:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
  10177a:	85 db                	test   %ebx,%ebx
  10177c:	74 36                	je     1017b4 <iunlock+0x44>
  10177e:	f6 43 0c 01          	testb  $0x1,0xc(%ebx)
  101782:	74 30                	je     1017b4 <iunlock+0x44>
  101784:	8b 43 08             	mov    0x8(%ebx),%eax
  101787:	85 c0                	test   %eax,%eax
  101789:	7e 29                	jle    1017b4 <iunlock+0x44>
    panic("iunlock");

  acquire(&icache.lock);
  10178b:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101792:	e8 a9 23 00 00       	call   103b40 <acquire>
  ip->flags &= ~I_BUSY;
  101797:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
  10179b:	89 1c 24             	mov    %ebx,(%esp)
  10179e:	e8 9d 19 00 00       	call   103140 <wakeup>
  release(&icache.lock);
  1017a3:	c7 45 08 e0 aa 10 00 	movl   $0x10aae0,0x8(%ebp)
}
  1017aa:	83 c4 14             	add    $0x14,%esp
  1017ad:	5b                   	pop    %ebx
  1017ae:	5d                   	pop    %ebp
    panic("iunlock");

  acquire(&icache.lock);
  ip->flags &= ~I_BUSY;
  wakeup(ip);
  release(&icache.lock);
  1017af:	e9 3c 23 00 00       	jmp    103af0 <release>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
    panic("iunlock");
  1017b4:	c7 04 24 96 65 10 00 	movl   $0x106596,(%esp)
  1017bb:	e8 60 f1 ff ff       	call   100920 <panic>

001017c0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
  1017c0:	55                   	push   %ebp
  1017c1:	89 e5                	mov    %esp,%ebp
  1017c3:	57                   	push   %edi
  1017c4:	56                   	push   %esi
  1017c5:	89 c6                	mov    %eax,%esi
  1017c7:	53                   	push   %ebx
  1017c8:	89 d3                	mov    %edx,%ebx
  1017ca:	83 ec 2c             	sub    $0x2c,%esp
static void
bzero(int dev, int bno)
{
  struct buf *bp;
  
  bp = bread(dev, bno);
  1017cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  1017d1:	89 04 24             	mov    %eax,(%esp)
  1017d4:	e8 47 e9 ff ff       	call   100120 <bread>
  memset(bp->data, 0, BSIZE);
  1017d9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  1017e0:	00 
  1017e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1017e8:	00 
static void
bzero(int dev, int bno)
{
  struct buf *bp;
  
  bp = bread(dev, bno);
  1017e9:	89 c7                	mov    %eax,%edi
  memset(bp->data, 0, BSIZE);
  1017eb:	8d 40 18             	lea    0x18(%eax),%eax
  1017ee:	89 04 24             	mov    %eax,(%esp)
  1017f1:	e8 ea 23 00 00       	call   103be0 <memset>
  bwrite(bp);
  1017f6:	89 3c 24             	mov    %edi,(%esp)
  1017f9:	e8 f2 e8 ff ff       	call   1000f0 <bwrite>
  brelse(bp);
  1017fe:	89 3c 24             	mov    %edi,(%esp)
  101801:	e8 6a e8 ff ff       	call   100070 <brelse>
  struct superblock sb;
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  101806:	89 f0                	mov    %esi,%eax
  101808:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10180b:	e8 90 f9 ff ff       	call   1011a0 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  101810:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101813:	89 da                	mov    %ebx,%edx
  101815:	c1 ea 0c             	shr    $0xc,%edx
  101818:	89 34 24             	mov    %esi,(%esp)
  bi = b % BPB;
  m = 1 << (bi % 8);
  10181b:	be 01 00 00 00       	mov    $0x1,%esi
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  101820:	c1 e8 03             	shr    $0x3,%eax
  101823:	8d 44 10 03          	lea    0x3(%eax,%edx,1),%eax
  101827:	89 44 24 04          	mov    %eax,0x4(%esp)
  10182b:	e8 f0 e8 ff ff       	call   100120 <bread>
  bi = b % BPB;
  101830:	89 da                	mov    %ebx,%edx
  m = 1 << (bi % 8);
  101832:	89 d9                	mov    %ebx,%ecx

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  101834:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
  10183a:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
  10183d:	c1 fa 03             	sar    $0x3,%edx
  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  m = 1 << (bi % 8);
  101840:	d3 e6                	shl    %cl,%esi
  if((bp->data[bi/8] & m) == 0)
  101842:	0f b6 4c 10 18       	movzbl 0x18(%eax,%edx,1),%ecx
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  101847:	89 c7                	mov    %eax,%edi
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
  101849:	0f b6 c1             	movzbl %cl,%eax
  10184c:	85 f0                	test   %esi,%eax
  10184e:	74 22                	je     101872 <bfree+0xb2>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;  // Mark block free on disk.
  101850:	89 f0                	mov    %esi,%eax
  101852:	f7 d0                	not    %eax
  101854:	21 c8                	and    %ecx,%eax
  101856:	88 44 17 18          	mov    %al,0x18(%edi,%edx,1)
  bwrite(bp);
  10185a:	89 3c 24             	mov    %edi,(%esp)
  10185d:	e8 8e e8 ff ff       	call   1000f0 <bwrite>
  brelse(bp);
  101862:	89 3c 24             	mov    %edi,(%esp)
  101865:	e8 06 e8 ff ff       	call   100070 <brelse>
}
  10186a:	83 c4 2c             	add    $0x2c,%esp
  10186d:	5b                   	pop    %ebx
  10186e:	5e                   	pop    %esi
  10186f:	5f                   	pop    %edi
  101870:	5d                   	pop    %ebp
  101871:	c3                   	ret    
  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
  101872:	c7 04 24 9e 65 10 00 	movl   $0x10659e,(%esp)
  101879:	e8 a2 f0 ff ff       	call   100920 <panic>
  10187e:	66 90                	xchg   %ax,%ax

00101880 <iput>:
}

// Caller holds reference to unlocked ip.  Drop reference.
void
iput(struct inode *ip)
{
  101880:	55                   	push   %ebp
  101881:	89 e5                	mov    %esp,%ebp
  101883:	57                   	push   %edi
  101884:	56                   	push   %esi
  101885:	53                   	push   %ebx
  101886:	83 ec 2c             	sub    $0x2c,%esp
  101889:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&icache.lock);
  10188c:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101893:	e8 a8 22 00 00       	call   103b40 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
  101898:	8b 46 08             	mov    0x8(%esi),%eax
  10189b:	83 f8 01             	cmp    $0x1,%eax
  10189e:	0f 85 a9 00 00 00    	jne    10194d <iput+0xcd>
  1018a4:	8b 56 0c             	mov    0xc(%esi),%edx
  1018a7:	f6 c2 02             	test   $0x2,%dl
  1018aa:	0f 84 9d 00 00 00    	je     10194d <iput+0xcd>
  1018b0:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  1018b5:	0f 85 92 00 00 00    	jne    10194d <iput+0xcd>
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
  1018bb:	f6 c2 01             	test   $0x1,%dl
  1018be:	66 90                	xchg   %ax,%ax
  1018c0:	0f 85 00 01 00 00    	jne    1019c6 <iput+0x146>
      panic("iput busy");
    ip->flags |= I_BUSY;
  1018c6:	83 ca 01             	or     $0x1,%edx
  1018c9:	89 56 0c             	mov    %edx,0xc(%esi)
    release(&icache.lock);
  1018cc:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1018d3:	e8 18 22 00 00       	call   103af0 <release>
  int i, j;
  struct buf *bp;
  uint *a;

  //TODO: Add in for EXTENTS. Free every block from pointer to pointer + size, just like first half of code.
  if (ip->type == T_EXTENT) {
  1018d8:	66 83 7e 10 04       	cmpw   $0x4,0x10(%esi)
  1018dd:	74 42                	je     101921 <iput+0xa1>
  1018df:	89 f3                	mov    %esi,%ebx
  release(&icache.lock);
}

// Caller holds reference to unlocked ip.  Drop reference.
void
iput(struct inode *ip)
  1018e1:	8d 7e 30             	lea    0x30(%esi),%edi
  1018e4:	eb 09                	jmp    1018ef <iput+0x6f>
  1018e6:	66 90                	xchg   %ax,%ax
  }
  else {
	for(i = 0; i < NDIRECT; i++){
	  if(ip->addrs[i]){
		bfree(ip->dev, ip->addrs[i]);
		ip->addrs[i] = 0;
  1018e8:	83 c3 04             	add    $0x4,%ebx
  //TODO: Add in for EXTENTS. Free every block from pointer to pointer + size, just like first half of code.
  if (ip->type == T_EXTENT) {
	
  }
  else {
	for(i = 0; i < NDIRECT; i++){
  1018eb:	39 fb                	cmp    %edi,%ebx
  1018ed:	74 1c                	je     10190b <iput+0x8b>
	  if(ip->addrs[i]){
  1018ef:	8b 53 1c             	mov    0x1c(%ebx),%edx
  1018f2:	85 d2                	test   %edx,%edx
  1018f4:	74 f2                	je     1018e8 <iput+0x68>
		bfree(ip->dev, ip->addrs[i]);
  1018f6:	8b 06                	mov    (%esi),%eax
  1018f8:	e8 c3 fe ff ff       	call   1017c0 <bfree>
		ip->addrs[i] = 0;
  1018fd:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
  101904:	83 c3 04             	add    $0x4,%ebx
  //TODO: Add in for EXTENTS. Free every block from pointer to pointer + size, just like first half of code.
  if (ip->type == T_EXTENT) {
	
  }
  else {
	for(i = 0; i < NDIRECT; i++){
  101907:	39 fb                	cmp    %edi,%ebx
  101909:	75 e4                	jne    1018ef <iput+0x6f>
		bfree(ip->dev, ip->addrs[i]);
		ip->addrs[i] = 0;
	  }
	}
	
	if(ip->addrs[NDIRECT]){
  10190b:	8b 46 4c             	mov    0x4c(%esi),%eax
  10190e:	85 c0                	test   %eax,%eax
  101910:	75 56                	jne    101968 <iput+0xe8>
	  brelse(bp);
	  bfree(ip->dev, ip->addrs[NDIRECT]);
	  ip->addrs[NDIRECT] = 0;
	}

	ip->size = 0;
  101912:	c7 46 18 00 00 00 00 	movl   $0x0,0x18(%esi)
	iupdate(ip);
  101919:	89 34 24             	mov    %esi,(%esp)
  10191c:	e8 4f fb ff ff       	call   101470 <iupdate>
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
    itrunc(ip);
    ip->type = 0;
  101921:	66 c7 46 10 00 00    	movw   $0x0,0x10(%esi)
    iupdate(ip);
  101927:	89 34 24             	mov    %esi,(%esp)
  10192a:	e8 41 fb ff ff       	call   101470 <iupdate>
    acquire(&icache.lock);
  10192f:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101936:	e8 05 22 00 00       	call   103b40 <acquire>
    ip->flags = 0;
  10193b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
  101942:	89 34 24             	mov    %esi,(%esp)
  101945:	e8 f6 17 00 00       	call   103140 <wakeup>
  10194a:	8b 46 08             	mov    0x8(%esi),%eax
  }
  ip->ref--;
  10194d:	83 e8 01             	sub    $0x1,%eax
  101950:	89 46 08             	mov    %eax,0x8(%esi)
  release(&icache.lock);
  101953:	c7 45 08 e0 aa 10 00 	movl   $0x10aae0,0x8(%ebp)
}
  10195a:	83 c4 2c             	add    $0x2c,%esp
  10195d:	5b                   	pop    %ebx
  10195e:	5e                   	pop    %esi
  10195f:	5f                   	pop    %edi
  101960:	5d                   	pop    %ebp
    acquire(&icache.lock);
    ip->flags = 0;
    wakeup(ip);
  }
  ip->ref--;
  release(&icache.lock);
  101961:	e9 8a 21 00 00       	jmp    103af0 <release>
  101966:	66 90                	xchg   %ax,%ax
		ip->addrs[i] = 0;
	  }
	}
	
	if(ip->addrs[NDIRECT]){
	  bp = bread(ip->dev, ip->addrs[NDIRECT]);
  101968:	89 44 24 04          	mov    %eax,0x4(%esp)
  10196c:	8b 06                	mov    (%esi),%eax
	  a = (uint*)bp->data;
  10196e:	31 db                	xor    %ebx,%ebx
		ip->addrs[i] = 0;
	  }
	}
	
	if(ip->addrs[NDIRECT]){
	  bp = bread(ip->dev, ip->addrs[NDIRECT]);
  101970:	89 04 24             	mov    %eax,(%esp)
  101973:	e8 a8 e7 ff ff       	call   100120 <bread>
	  a = (uint*)bp->data;
  101978:	89 c7                	mov    %eax,%edi
		ip->addrs[i] = 0;
	  }
	}
	
	if(ip->addrs[NDIRECT]){
	  bp = bread(ip->dev, ip->addrs[NDIRECT]);
  10197a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	  a = (uint*)bp->data;
  10197d:	83 c7 18             	add    $0x18,%edi
  101980:	31 c0                	xor    %eax,%eax
  101982:	eb 11                	jmp    101995 <iput+0x115>
  101984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	  for(j = 0; j < NINDIRECT; j++){
  101988:	83 c3 01             	add    $0x1,%ebx
  10198b:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  101991:	89 d8                	mov    %ebx,%eax
  101993:	74 10                	je     1019a5 <iput+0x125>
		if(a[j])
  101995:	8b 14 87             	mov    (%edi,%eax,4),%edx
  101998:	85 d2                	test   %edx,%edx
  10199a:	74 ec                	je     101988 <iput+0x108>
		  bfree(ip->dev, a[j]);
  10199c:	8b 06                	mov    (%esi),%eax
  10199e:	e8 1d fe ff ff       	call   1017c0 <bfree>
  1019a3:	eb e3                	jmp    101988 <iput+0x108>
	  }
	  brelse(bp);
  1019a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1019a8:	89 04 24             	mov    %eax,(%esp)
  1019ab:	e8 c0 e6 ff ff       	call   100070 <brelse>
	  bfree(ip->dev, ip->addrs[NDIRECT]);
  1019b0:	8b 56 4c             	mov    0x4c(%esi),%edx
  1019b3:	8b 06                	mov    (%esi),%eax
  1019b5:	e8 06 fe ff ff       	call   1017c0 <bfree>
	  ip->addrs[NDIRECT] = 0;
  1019ba:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  1019c1:	e9 4c ff ff ff       	jmp    101912 <iput+0x92>
{
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
  1019c6:	c7 04 24 b1 65 10 00 	movl   $0x1065b1,(%esp)
  1019cd:	e8 4e ef ff ff       	call   100920 <panic>
  1019d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1019d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001019e0 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
  1019e0:	55                   	push   %ebp
  1019e1:	89 e5                	mov    %esp,%ebp
  1019e3:	57                   	push   %edi
  1019e4:	56                   	push   %esi
  1019e5:	53                   	push   %ebx
  1019e6:	83 ec 2c             	sub    $0x2c,%esp
  1019e9:	8b 75 08             	mov    0x8(%ebp),%esi
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
  1019ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  1019ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1019f6:	00 
  1019f7:	89 34 24             	mov    %esi,(%esp)
  1019fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019fe:	e8 6d fc ff ff       	call   101670 <dirlookup>
  101a03:	85 c0                	test   %eax,%eax
  101a05:	0f 85 89 00 00 00    	jne    101a94 <dirlink+0xb4>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101a0b:	8b 56 18             	mov    0x18(%esi),%edx
  101a0e:	85 d2                	test   %edx,%edx
  101a10:	0f 84 8d 00 00 00    	je     101aa3 <dirlink+0xc3>
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
    return -1;
  101a16:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101a19:	31 db                	xor    %ebx,%ebx
  101a1b:	eb 0b                	jmp    101a28 <dirlink+0x48>
  101a1d:	8d 76 00             	lea    0x0(%esi),%esi
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101a20:	83 c3 10             	add    $0x10,%ebx
  101a23:	39 5e 18             	cmp    %ebx,0x18(%esi)
  101a26:	76 24                	jbe    101a4c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a28:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101a2f:	00 
  101a30:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101a34:	89 7c 24 04          	mov    %edi,0x4(%esp)
  101a38:	89 34 24             	mov    %esi,(%esp)
  101a3b:	e8 30 f9 ff ff       	call   101370 <readi>
  101a40:	83 f8 10             	cmp    $0x10,%eax
  101a43:	75 65                	jne    101aaa <dirlink+0xca>
      panic("dirlink read");
    if(de.inum == 0)
  101a45:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
  101a4a:	75 d4                	jne    101a20 <dirlink+0x40>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  101a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  101a4f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101a56:	00 
  101a57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a5b:	8d 45 da             	lea    -0x26(%ebp),%eax
  101a5e:	89 04 24             	mov    %eax,(%esp)
  101a61:	e8 ca 22 00 00       	call   103d30 <strncpy>
  de.inum = inum;
  101a66:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a69:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101a70:	00 
  101a71:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101a75:	89 7c 24 04          	mov    %edi,0x4(%esp)
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  101a79:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a7d:	89 34 24             	mov    %esi,(%esp)
  101a80:	e8 7b fa ff ff       	call   101500 <writei>
  101a85:	83 f8 10             	cmp    $0x10,%eax
  101a88:	75 2c                	jne    101ab6 <dirlink+0xd6>
    panic("dirlink");
  101a8a:	31 c0                	xor    %eax,%eax
  
  return 0;
}
  101a8c:	83 c4 2c             	add    $0x2c,%esp
  101a8f:	5b                   	pop    %ebx
  101a90:	5e                   	pop    %esi
  101a91:	5f                   	pop    %edi
  101a92:	5d                   	pop    %ebp
  101a93:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
  101a94:	89 04 24             	mov    %eax,(%esp)
  101a97:	e8 e4 fd ff ff       	call   101880 <iput>
  101a9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  101aa1:	eb e9                	jmp    101a8c <dirlink+0xac>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101aa3:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101aa6:	31 db                	xor    %ebx,%ebx
  101aa8:	eb a2                	jmp    101a4c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
  101aaa:	c7 04 24 bb 65 10 00 	movl   $0x1065bb,(%esp)
  101ab1:	e8 6a ee ff ff       	call   100920 <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
  101ab6:	c7 04 24 5e 6b 10 00 	movl   $0x106b5e,(%esp)
  101abd:	e8 5e ee ff ff       	call   100920 <panic>
  101ac2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  101ac9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101ad0 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  101ad0:	55                   	push   %ebp
  101ad1:	89 e5                	mov    %esp,%ebp
  101ad3:	53                   	push   %ebx
  101ad4:	83 ec 14             	sub    $0x14,%esp
  101ad7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
  101ada:	89 1c 24             	mov    %ebx,(%esp)
  101add:	e8 8e fc ff ff       	call   101770 <iunlock>
  iput(ip);
  101ae2:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  101ae5:	83 c4 14             	add    $0x14,%esp
  101ae8:	5b                   	pop    %ebx
  101ae9:	5d                   	pop    %ebp
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
  101aea:	e9 91 fd ff ff       	jmp    101880 <iput>
  101aef:	90                   	nop

00101af0 <ialloc>:
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101af0:	55                   	push   %ebp
  101af1:	89 e5                	mov    %esp,%ebp
  101af3:	57                   	push   %edi
  101af4:	56                   	push   %esi
  101af5:	53                   	push   %ebx
  101af6:	83 ec 3c             	sub    $0x3c,%esp
  101af9:	0f b7 45 0c          	movzwl 0xc(%ebp),%eax
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101afd:	8d 55 dc             	lea    -0x24(%ebp),%edx
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101b00:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101b04:	8b 45 08             	mov    0x8(%ebp),%eax
  101b07:	e8 94 f6 ff ff       	call   1011a0 <readsb>
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b0c:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
  101b10:	0f 86 96 00 00 00    	jbe    101bac <ialloc+0xbc>
  101b16:	be 01 00 00 00       	mov    $0x1,%esi
  101b1b:	bb 01 00 00 00       	mov    $0x1,%ebx
  101b20:	eb 18                	jmp    101b3a <ialloc+0x4a>
  101b22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101b28:	83 c3 01             	add    $0x1,%ebx
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101b2b:	89 3c 24             	mov    %edi,(%esp)
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b2e:	89 de                	mov    %ebx,%esi
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101b30:	e8 3b e5 ff ff       	call   100070 <brelse>
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b35:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  101b38:	76 72                	jbe    101bac <ialloc+0xbc>
    bp = bread(dev, IBLOCK(inum));
  101b3a:	89 f0                	mov    %esi,%eax
  101b3c:	c1 e8 03             	shr    $0x3,%eax
  101b3f:	83 c0 02             	add    $0x2,%eax
  101b42:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b46:	8b 45 08             	mov    0x8(%ebp),%eax
  101b49:	89 04 24             	mov    %eax,(%esp)
  101b4c:	e8 cf e5 ff ff       	call   100120 <bread>
  101b51:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
  101b53:	89 f0                	mov    %esi,%eax
  101b55:	83 e0 07             	and    $0x7,%eax
  101b58:	c1 e0 06             	shl    $0x6,%eax
  101b5b:	8d 54 07 18          	lea    0x18(%edi,%eax,1),%edx
    if(dip->type == 0){  // a free inode
  101b5f:	66 83 3a 00          	cmpw   $0x0,(%edx)
  101b63:	75 c3                	jne    101b28 <ialloc+0x38>
      memset(dip, 0, sizeof(*dip));
  101b65:	89 14 24             	mov    %edx,(%esp)
  101b68:	89 55 d0             	mov    %edx,-0x30(%ebp)
  101b6b:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
  101b72:	00 
  101b73:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101b7a:	00 
  101b7b:	e8 60 20 00 00       	call   103be0 <memset>
      dip->type = type;
  101b80:	8b 55 d0             	mov    -0x30(%ebp),%edx
  101b83:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101b87:	66 89 02             	mov    %ax,(%edx)
      bwrite(bp);   // mark it allocated on the disk
  101b8a:	89 3c 24             	mov    %edi,(%esp)
  101b8d:	e8 5e e5 ff ff       	call   1000f0 <bwrite>
      brelse(bp);
  101b92:	89 3c 24             	mov    %edi,(%esp)
  101b95:	e8 d6 e4 ff ff       	call   100070 <brelse>
      return iget(dev, inum);
  101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9d:	89 f2                	mov    %esi,%edx
  101b9f:	e8 3c f5 ff ff       	call   1010e0 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
  101ba4:	83 c4 3c             	add    $0x3c,%esp
  101ba7:	5b                   	pop    %ebx
  101ba8:	5e                   	pop    %esi
  101ba9:	5f                   	pop    %edi
  101baa:	5d                   	pop    %ebp
  101bab:	c3                   	ret    
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
  101bac:	c7 04 24 c8 65 10 00 	movl   $0x1065c8,(%esp)
  101bb3:	e8 68 ed ff ff       	call   100920 <panic>
  101bb8:	90                   	nop
  101bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00101bc0 <ilock>:
}

// Lock the given inode.
void
ilock(struct inode *ip)
{
  101bc0:	55                   	push   %ebp
  101bc1:	89 e5                	mov    %esp,%ebp
  101bc3:	56                   	push   %esi
  101bc4:	53                   	push   %ebx
  101bc5:	83 ec 10             	sub    $0x10,%esp
  101bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
  101bcb:	85 db                	test   %ebx,%ebx
  101bcd:	0f 84 e5 00 00 00    	je     101cb8 <ilock+0xf8>
  101bd3:	8b 4b 08             	mov    0x8(%ebx),%ecx
  101bd6:	85 c9                	test   %ecx,%ecx
  101bd8:	0f 8e da 00 00 00    	jle    101cb8 <ilock+0xf8>
    panic("ilock");

  acquire(&icache.lock);
  101bde:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101be5:	e8 56 1f 00 00       	call   103b40 <acquire>
  while(ip->flags & I_BUSY)
  101bea:	8b 43 0c             	mov    0xc(%ebx),%eax
  101bed:	a8 01                	test   $0x1,%al
  101bef:	74 1e                	je     101c0f <ilock+0x4f>
  101bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sleep(ip, &icache.lock);
  101bf8:	c7 44 24 04 e0 aa 10 	movl   $0x10aae0,0x4(%esp)
  101bff:	00 
  101c00:	89 1c 24             	mov    %ebx,(%esp)
  101c03:	e8 58 16 00 00       	call   103260 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
  101c08:	8b 43 0c             	mov    0xc(%ebx),%eax
  101c0b:	a8 01                	test   $0x1,%al
  101c0d:	75 e9                	jne    101bf8 <ilock+0x38>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  101c0f:	83 c8 01             	or     $0x1,%eax
  101c12:	89 43 0c             	mov    %eax,0xc(%ebx)
  release(&icache.lock);
  101c15:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101c1c:	e8 cf 1e 00 00       	call   103af0 <release>

  if(!(ip->flags & I_VALID)){
  101c21:	f6 43 0c 02          	testb  $0x2,0xc(%ebx)
  101c25:	74 09                	je     101c30 <ilock+0x70>
    brelse(bp);
    ip->flags |= I_VALID;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
  101c27:	83 c4 10             	add    $0x10,%esp
  101c2a:	5b                   	pop    %ebx
  101c2b:	5e                   	pop    %esi
  101c2c:	5d                   	pop    %ebp
  101c2d:	c3                   	ret    
  101c2e:	66 90                	xchg   %ax,%ax
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  release(&icache.lock);

  if(!(ip->flags & I_VALID)){
    bp = bread(ip->dev, IBLOCK(ip->inum));
  101c30:	8b 43 04             	mov    0x4(%ebx),%eax
  101c33:	c1 e8 03             	shr    $0x3,%eax
  101c36:	83 c0 02             	add    $0x2,%eax
  101c39:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3d:	8b 03                	mov    (%ebx),%eax
  101c3f:	89 04 24             	mov    %eax,(%esp)
  101c42:	e8 d9 e4 ff ff       	call   100120 <bread>
  101c47:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
  101c49:	8b 43 04             	mov    0x4(%ebx),%eax
  101c4c:	83 e0 07             	and    $0x7,%eax
  101c4f:	c1 e0 06             	shl    $0x6,%eax
  101c52:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
    ip->type = dip->type;
  101c56:	0f b7 10             	movzwl (%eax),%edx
  101c59:	66 89 53 10          	mov    %dx,0x10(%ebx)
    ip->major = dip->major;
  101c5d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
  101c61:	66 89 53 12          	mov    %dx,0x12(%ebx)
    ip->minor = dip->minor;
  101c65:	0f b7 50 04          	movzwl 0x4(%eax),%edx
  101c69:	66 89 53 14          	mov    %dx,0x14(%ebx)
    ip->nlink = dip->nlink;
  101c6d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
  101c71:	66 89 53 16          	mov    %dx,0x16(%ebx)
    ip->size = dip->size;
  101c75:	8b 50 08             	mov    0x8(%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101c78:	83 c0 0c             	add    $0xc,%eax
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
  101c7b:	89 53 18             	mov    %edx,0x18(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c82:	8d 43 1c             	lea    0x1c(%ebx),%eax
  101c85:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
  101c8c:	00 
  101c8d:	89 04 24             	mov    %eax,(%esp)
  101c90:	e8 cb 1f 00 00       	call   103c60 <memmove>
    brelse(bp);
  101c95:	89 34 24             	mov    %esi,(%esp)
  101c98:	e8 d3 e3 ff ff       	call   100070 <brelse>
    ip->flags |= I_VALID;
  101c9d:	83 4b 0c 02          	orl    $0x2,0xc(%ebx)
    if(ip->type == 0)
  101ca1:	66 83 7b 10 00       	cmpw   $0x0,0x10(%ebx)
  101ca6:	0f 85 7b ff ff ff    	jne    101c27 <ilock+0x67>
      panic("ilock: no type");
  101cac:	c7 04 24 e0 65 10 00 	movl   $0x1065e0,(%esp)
  101cb3:	e8 68 ec ff ff       	call   100920 <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
  101cb8:	c7 04 24 da 65 10 00 	movl   $0x1065da,(%esp)
  101cbf:	e8 5c ec ff ff       	call   100920 <panic>
  101cc4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101cca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00101cd0 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
  101cd0:	55                   	push   %ebp
  101cd1:	89 e5                	mov    %esp,%ebp
  101cd3:	57                   	push   %edi
  101cd4:	56                   	push   %esi
  101cd5:	53                   	push   %ebx
  101cd6:	89 c3                	mov    %eax,%ebx
  101cd8:	83 ec 2c             	sub    $0x2c,%esp
  101cdb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  101cde:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
  101ce1:	80 38 2f             	cmpb   $0x2f,(%eax)
  101ce4:	0f 84 14 01 00 00    	je     101dfe <namex+0x12e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
  101cea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  101cf0:	8b 40 68             	mov    0x68(%eax),%eax
  101cf3:	89 04 24             	mov    %eax,(%esp)
  101cf6:	e8 b5 f3 ff ff       	call   1010b0 <idup>
  101cfb:	89 c7                	mov    %eax,%edi
  101cfd:	eb 04                	jmp    101d03 <namex+0x33>
  101cff:	90                   	nop
{
  char *s;
  int len;

  while(*path == '/')
    path++;
  101d00:	83 c3 01             	add    $0x1,%ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
  101d03:	0f b6 03             	movzbl (%ebx),%eax
  101d06:	3c 2f                	cmp    $0x2f,%al
  101d08:	74 f6                	je     101d00 <namex+0x30>
    path++;
  if(*path == 0)
  101d0a:	84 c0                	test   %al,%al
  101d0c:	75 1a                	jne    101d28 <namex+0x58>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
  101d0e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  101d11:	85 db                	test   %ebx,%ebx
  101d13:	0f 85 0d 01 00 00    	jne    101e26 <namex+0x156>
    iput(ip);
    return 0;
  }
  return ip;
}
  101d19:	83 c4 2c             	add    $0x2c,%esp
  101d1c:	89 f8                	mov    %edi,%eax
  101d1e:	5b                   	pop    %ebx
  101d1f:	5e                   	pop    %esi
  101d20:	5f                   	pop    %edi
  101d21:	5d                   	pop    %ebp
  101d22:	c3                   	ret    
  101d23:	90                   	nop
  101d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101d28:	3c 2f                	cmp    $0x2f,%al
  101d2a:	0f 84 94 00 00 00    	je     101dc4 <namex+0xf4>
  101d30:	89 de                	mov    %ebx,%esi
  101d32:	eb 08                	jmp    101d3c <namex+0x6c>
  101d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101d38:	3c 2f                	cmp    $0x2f,%al
  101d3a:	74 0a                	je     101d46 <namex+0x76>
    path++;
  101d3c:	83 c6 01             	add    $0x1,%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101d3f:	0f b6 06             	movzbl (%esi),%eax
  101d42:	84 c0                	test   %al,%al
  101d44:	75 f2                	jne    101d38 <namex+0x68>
  101d46:	89 f2                	mov    %esi,%edx
  101d48:	29 da                	sub    %ebx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
  101d4a:	83 fa 0d             	cmp    $0xd,%edx
  101d4d:	7e 79                	jle    101dc8 <namex+0xf8>
    memmove(name, s, DIRSIZ);
  101d4f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101d56:	00 
  101d57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101d5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101d5e:	89 04 24             	mov    %eax,(%esp)
  101d61:	e8 fa 1e 00 00       	call   103c60 <memmove>
  101d66:	eb 03                	jmp    101d6b <namex+0x9b>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
    path++;
  101d68:	83 c6 01             	add    $0x1,%esi
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101d6b:	80 3e 2f             	cmpb   $0x2f,(%esi)
  101d6e:	74 f8                	je     101d68 <namex+0x98>
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
  101d70:	85 f6                	test   %esi,%esi
  101d72:	74 9a                	je     101d0e <namex+0x3e>
    ilock(ip);
  101d74:	89 3c 24             	mov    %edi,(%esp)
  101d77:	e8 44 fe ff ff       	call   101bc0 <ilock>
    if(ip->type != T_DIR){
  101d7c:	66 83 7f 10 01       	cmpw   $0x1,0x10(%edi)
  101d81:	75 67                	jne    101dea <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
  101d83:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101d86:	85 c0                	test   %eax,%eax
  101d88:	74 0c                	je     101d96 <namex+0xc6>
  101d8a:	80 3e 00             	cmpb   $0x0,(%esi)
  101d8d:	8d 76 00             	lea    0x0(%esi),%esi
  101d90:	0f 84 7e 00 00 00    	je     101e14 <namex+0x144>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
  101d96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  101d9d:	00 
  101d9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101da1:	89 3c 24             	mov    %edi,(%esp)
  101da4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101da8:	e8 c3 f8 ff ff       	call   101670 <dirlookup>
  101dad:	85 c0                	test   %eax,%eax
  101daf:	89 c3                	mov    %eax,%ebx
  101db1:	74 37                	je     101dea <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
  101db3:	89 3c 24             	mov    %edi,(%esp)
  101db6:	89 df                	mov    %ebx,%edi
  101db8:	89 f3                	mov    %esi,%ebx
  101dba:	e8 11 fd ff ff       	call   101ad0 <iunlockput>
  101dbf:	e9 3f ff ff ff       	jmp    101d03 <namex+0x33>
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101dc4:	89 de                	mov    %ebx,%esi
  101dc6:	31 d2                	xor    %edx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
  101dc8:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dcc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101dd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101dd3:	89 04 24             	mov    %eax,(%esp)
  101dd6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  101dd9:	e8 82 1e 00 00       	call   103c60 <memmove>
    name[len] = 0;
  101dde:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101de4:	c6 04 10 00          	movb   $0x0,(%eax,%edx,1)
  101de8:	eb 81                	jmp    101d6b <namex+0x9b>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
  101dea:	89 3c 24             	mov    %edi,(%esp)
  101ded:	31 ff                	xor    %edi,%edi
  101def:	e8 dc fc ff ff       	call   101ad0 <iunlockput>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101df4:	83 c4 2c             	add    $0x2c,%esp
  101df7:	89 f8                	mov    %edi,%eax
  101df9:	5b                   	pop    %ebx
  101dfa:	5e                   	pop    %esi
  101dfb:	5f                   	pop    %edi
  101dfc:	5d                   	pop    %ebp
  101dfd:	c3                   	ret    
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  101dfe:	ba 01 00 00 00       	mov    $0x1,%edx
  101e03:	b8 01 00 00 00       	mov    $0x1,%eax
  101e08:	e8 d3 f2 ff ff       	call   1010e0 <iget>
  101e0d:	89 c7                	mov    %eax,%edi
  101e0f:	e9 ef fe ff ff       	jmp    101d03 <namex+0x33>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
  101e14:	89 3c 24             	mov    %edi,(%esp)
  101e17:	e8 54 f9 ff ff       	call   101770 <iunlock>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101e1c:	83 c4 2c             	add    $0x2c,%esp
  101e1f:	89 f8                	mov    %edi,%eax
  101e21:	5b                   	pop    %ebx
  101e22:	5e                   	pop    %esi
  101e23:	5f                   	pop    %edi
  101e24:	5d                   	pop    %ebp
  101e25:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
  101e26:	89 3c 24             	mov    %edi,(%esp)
  101e29:	31 ff                	xor    %edi,%edi
  101e2b:	e8 50 fa ff ff       	call   101880 <iput>
    return 0;
  101e30:	e9 e4 fe ff ff       	jmp    101d19 <namex+0x49>
  101e35:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101e40 <nameiparent>:
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101e40:	55                   	push   %ebp
  return namex(path, 1, name);
  101e41:	ba 01 00 00 00       	mov    $0x1,%edx
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101e46:	89 e5                	mov    %esp,%ebp
  101e48:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
  101e4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  101e51:	c9                   	leave  
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
  101e52:	e9 79 fe ff ff       	jmp    101cd0 <namex>
  101e57:	89 f6                	mov    %esi,%esi
  101e59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101e60 <namei>:
  return ip;
}

struct inode*
namei(char *path)
{
  101e60:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101e61:	31 d2                	xor    %edx,%edx
  return ip;
}

struct inode*
namei(char *path)
{
  101e63:	89 e5                	mov    %esp,%ebp
  101e65:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101e68:	8b 45 08             	mov    0x8(%ebp),%eax
  101e6b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
  101e6e:	e8 5d fe ff ff       	call   101cd0 <namex>
}
  101e73:	c9                   	leave  
  101e74:	c3                   	ret    
  101e75:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101e80 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
  101e80:	55                   	push   %ebp
  101e81:	89 e5                	mov    %esp,%ebp
  101e83:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
  101e86:	c7 44 24 04 ef 65 10 	movl   $0x1065ef,0x4(%esp)
  101e8d:	00 
  101e8e:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101e95:	e8 16 1b 00 00       	call   1039b0 <initlock>
}
  101e9a:	c9                   	leave  
  101e9b:	c3                   	ret    
  101e9c:	90                   	nop
  101e9d:	90                   	nop
  101e9e:	90                   	nop
  101e9f:	90                   	nop

00101ea0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  101ea0:	55                   	push   %ebp
  101ea1:	89 e5                	mov    %esp,%ebp
  101ea3:	56                   	push   %esi
  101ea4:	89 c6                	mov    %eax,%esi
  101ea6:	83 ec 14             	sub    $0x14,%esp
  if(b == 0)
  101ea9:	85 c0                	test   %eax,%eax
  101eab:	0f 84 8d 00 00 00    	je     101f3e <idestart+0x9e>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  101eb1:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101eb6:	66 90                	xchg   %ax,%ax
  101eb8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  101eb9:	25 c0 00 00 00       	and    $0xc0,%eax
  101ebe:	83 f8 40             	cmp    $0x40,%eax
  101ec1:	75 f5                	jne    101eb8 <idestart+0x18>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  101ec3:	ba f6 03 00 00       	mov    $0x3f6,%edx
  101ec8:	31 c0                	xor    %eax,%eax
  101eca:	ee                   	out    %al,(%dx)
  101ecb:	ba f2 01 00 00       	mov    $0x1f2,%edx
  101ed0:	b8 01 00 00 00       	mov    $0x1,%eax
  101ed5:	ee                   	out    %al,(%dx)
    panic("idestart");

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, 1);  // number of sectors
  outb(0x1f3, b->sector & 0xff);
  101ed6:	8b 4e 08             	mov    0x8(%esi),%ecx
  101ed9:	b2 f3                	mov    $0xf3,%dl
  101edb:	89 c8                	mov    %ecx,%eax
  101edd:	ee                   	out    %al,(%dx)
  101ede:	89 c8                	mov    %ecx,%eax
  101ee0:	b2 f4                	mov    $0xf4,%dl
  101ee2:	c1 e8 08             	shr    $0x8,%eax
  101ee5:	ee                   	out    %al,(%dx)
  101ee6:	89 c8                	mov    %ecx,%eax
  101ee8:	b2 f5                	mov    $0xf5,%dl
  101eea:	c1 e8 10             	shr    $0x10,%eax
  101eed:	ee                   	out    %al,(%dx)
  101eee:	8b 46 04             	mov    0x4(%esi),%eax
  101ef1:	c1 e9 18             	shr    $0x18,%ecx
  101ef4:	b2 f6                	mov    $0xf6,%dl
  101ef6:	83 e1 0f             	and    $0xf,%ecx
  101ef9:	83 e0 01             	and    $0x1,%eax
  101efc:	c1 e0 04             	shl    $0x4,%eax
  101eff:	09 c8                	or     %ecx,%eax
  101f01:	83 c8 e0             	or     $0xffffffe0,%eax
  101f04:	ee                   	out    %al,(%dx)
  outb(0x1f4, (b->sector >> 8) & 0xff);
  outb(0x1f5, (b->sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
  101f05:	f6 06 04             	testb  $0x4,(%esi)
  101f08:	75 16                	jne    101f20 <idestart+0x80>
  101f0a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101f0f:	b8 20 00 00 00       	mov    $0x20,%eax
  101f14:	ee                   	out    %al,(%dx)
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
  101f15:	83 c4 14             	add    $0x14,%esp
  101f18:	5e                   	pop    %esi
  101f19:	5d                   	pop    %ebp
  101f1a:	c3                   	ret    
  101f1b:	90                   	nop
  101f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101f20:	b2 f7                	mov    $0xf7,%dl
  101f22:	b8 30 00 00 00       	mov    $0x30,%eax
  101f27:	ee                   	out    %al,(%dx)
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
  101f28:	b9 80 00 00 00       	mov    $0x80,%ecx
  101f2d:	83 c6 18             	add    $0x18,%esi
  101f30:	ba f0 01 00 00       	mov    $0x1f0,%edx
  101f35:	fc                   	cld    
  101f36:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  101f38:	83 c4 14             	add    $0x14,%esp
  101f3b:	5e                   	pop    %esi
  101f3c:	5d                   	pop    %ebp
  101f3d:	c3                   	ret    
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  101f3e:	c7 04 24 f6 65 10 00 	movl   $0x1065f6,(%esp)
  101f45:	e8 d6 e9 ff ff       	call   100920 <panic>
  101f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00101f50 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
  101f50:	55                   	push   %ebp
  101f51:	89 e5                	mov    %esp,%ebp
  101f53:	53                   	push   %ebx
  101f54:	83 ec 14             	sub    $0x14,%esp
  101f57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!(b->flags & B_BUSY))
  101f5a:	8b 03                	mov    (%ebx),%eax
  101f5c:	a8 01                	test   $0x1,%al
  101f5e:	0f 84 90 00 00 00    	je     101ff4 <iderw+0xa4>
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
  101f64:	83 e0 06             	and    $0x6,%eax
  101f67:	83 f8 02             	cmp    $0x2,%eax
  101f6a:	0f 84 9c 00 00 00    	je     10200c <iderw+0xbc>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
  101f70:	8b 53 04             	mov    0x4(%ebx),%edx
  101f73:	85 d2                	test   %edx,%edx
  101f75:	74 0d                	je     101f84 <iderw+0x34>
  101f77:	a1 b8 78 10 00       	mov    0x1078b8,%eax
  101f7c:	85 c0                	test   %eax,%eax
  101f7e:	0f 84 7c 00 00 00    	je     102000 <iderw+0xb0>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);
  101f84:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  101f8b:	e8 b0 1b 00 00       	call   103b40 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  101f90:	ba b4 78 10 00       	mov    $0x1078b4,%edx
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);

  // Append b to idequeue.
  b->qnext = 0;
  101f95:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  101f9c:	a1 b4 78 10 00       	mov    0x1078b4,%eax
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  101fa1:	85 c0                	test   %eax,%eax
  101fa3:	74 0d                	je     101fb2 <iderw+0x62>
  101fa5:	8d 76 00             	lea    0x0(%esi),%esi
  101fa8:	8d 50 14             	lea    0x14(%eax),%edx
  101fab:	8b 40 14             	mov    0x14(%eax),%eax
  101fae:	85 c0                	test   %eax,%eax
  101fb0:	75 f6                	jne    101fa8 <iderw+0x58>
    ;
  *pp = b;
  101fb2:	89 1a                	mov    %ebx,(%edx)
  
  // Start disk if necessary.
  if(idequeue == b)
  101fb4:	39 1d b4 78 10 00    	cmp    %ebx,0x1078b4
  101fba:	75 14                	jne    101fd0 <iderw+0x80>
  101fbc:	eb 2d                	jmp    101feb <iderw+0x9b>
  101fbe:	66 90                	xchg   %ax,%ax
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  101fc0:	c7 44 24 04 80 78 10 	movl   $0x107880,0x4(%esp)
  101fc7:	00 
  101fc8:	89 1c 24             	mov    %ebx,(%esp)
  101fcb:	e8 90 12 00 00       	call   103260 <sleep>
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
  101fd0:	8b 03                	mov    (%ebx),%eax
  101fd2:	83 e0 06             	and    $0x6,%eax
  101fd5:	83 f8 02             	cmp    $0x2,%eax
  101fd8:	75 e6                	jne    101fc0 <iderw+0x70>
    sleep(b, &idelock);
  }

  release(&idelock);
  101fda:	c7 45 08 80 78 10 00 	movl   $0x107880,0x8(%ebp)
}
  101fe1:	83 c4 14             	add    $0x14,%esp
  101fe4:	5b                   	pop    %ebx
  101fe5:	5d                   	pop    %ebp
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }

  release(&idelock);
  101fe6:	e9 05 1b 00 00       	jmp    103af0 <release>
    ;
  *pp = b;
  
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  101feb:	89 d8                	mov    %ebx,%eax
  101fed:	e8 ae fe ff ff       	call   101ea0 <idestart>
  101ff2:	eb dc                	jmp    101fd0 <iderw+0x80>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  101ff4:	c7 04 24 ff 65 10 00 	movl   $0x1065ff,(%esp)
  101ffb:	e8 20 e9 ff ff       	call   100920 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
  102000:	c7 04 24 28 66 10 00 	movl   $0x106628,(%esp)
  102007:	e8 14 e9 ff ff       	call   100920 <panic>
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  10200c:	c7 04 24 13 66 10 00 	movl   $0x106613,(%esp)
  102013:	e8 08 e9 ff ff       	call   100920 <panic>
  102018:	90                   	nop
  102019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102020 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
  102020:	55                   	push   %ebp
  102021:	89 e5                	mov    %esp,%ebp
  102023:	57                   	push   %edi
  102024:	53                   	push   %ebx
  102025:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  // Take first buffer off queue.
  acquire(&idelock);
  102028:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  10202f:	e8 0c 1b 00 00       	call   103b40 <acquire>
  if((b = idequeue) == 0){
  102034:	8b 1d b4 78 10 00    	mov    0x1078b4,%ebx
  10203a:	85 db                	test   %ebx,%ebx
  10203c:	74 2d                	je     10206b <ideintr+0x4b>
    release(&idelock);
    // cprintf("spurious IDE interrupt\n");
    return;
  }
  idequeue = b->qnext;
  10203e:	8b 43 14             	mov    0x14(%ebx),%eax
  102041:	a3 b4 78 10 00       	mov    %eax,0x1078b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
  102046:	8b 0b                	mov    (%ebx),%ecx
  102048:	f6 c1 04             	test   $0x4,%cl
  10204b:	74 33                	je     102080 <ideintr+0x60>
    insl(0x1f0, b->data, 512/4);
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
  10204d:	83 c9 02             	or     $0x2,%ecx
  102050:	83 e1 fb             	and    $0xfffffffb,%ecx
  102053:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
  102055:	89 1c 24             	mov    %ebx,(%esp)
  102058:	e8 e3 10 00 00       	call   103140 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
  10205d:	a1 b4 78 10 00       	mov    0x1078b4,%eax
  102062:	85 c0                	test   %eax,%eax
  102064:	74 05                	je     10206b <ideintr+0x4b>
    idestart(idequeue);
  102066:	e8 35 fe ff ff       	call   101ea0 <idestart>

  release(&idelock);
  10206b:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  102072:	e8 79 1a 00 00       	call   103af0 <release>
}
  102077:	83 c4 10             	add    $0x10,%esp
  10207a:	5b                   	pop    %ebx
  10207b:	5f                   	pop    %edi
  10207c:	5d                   	pop    %ebp
  10207d:	c3                   	ret    
  10207e:	66 90                	xchg   %ax,%ax
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  102085:	8d 76 00             	lea    0x0(%esi),%esi
  102088:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  102089:	0f b6 c0             	movzbl %al,%eax
  10208c:	89 c7                	mov    %eax,%edi
  10208e:	81 e7 c0 00 00 00    	and    $0xc0,%edi
  102094:	83 ff 40             	cmp    $0x40,%edi
  102097:	75 ef                	jne    102088 <ideintr+0x68>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
  102099:	a8 21                	test   $0x21,%al
  10209b:	75 b0                	jne    10204d <ideintr+0x2d>
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
  10209d:	8d 7b 18             	lea    0x18(%ebx),%edi
  1020a0:	b9 80 00 00 00       	mov    $0x80,%ecx
  1020a5:	ba f0 01 00 00       	mov    $0x1f0,%edx
  1020aa:	fc                   	cld    
  1020ab:	f3 6d                	rep insl (%dx),%es:(%edi)
  1020ad:	8b 0b                	mov    (%ebx),%ecx
  1020af:	eb 9c                	jmp    10204d <ideintr+0x2d>
  1020b1:	eb 0d                	jmp    1020c0 <ideinit>
  1020b3:	90                   	nop
  1020b4:	90                   	nop
  1020b5:	90                   	nop
  1020b6:	90                   	nop
  1020b7:	90                   	nop
  1020b8:	90                   	nop
  1020b9:	90                   	nop
  1020ba:	90                   	nop
  1020bb:	90                   	nop
  1020bc:	90                   	nop
  1020bd:	90                   	nop
  1020be:	90                   	nop
  1020bf:	90                   	nop

001020c0 <ideinit>:
  return 0;
}

void
ideinit(void)
{
  1020c0:	55                   	push   %ebp
  1020c1:	89 e5                	mov    %esp,%ebp
  1020c3:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
  1020c6:	c7 44 24 04 46 66 10 	movl   $0x106646,0x4(%esp)
  1020cd:	00 
  1020ce:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  1020d5:	e8 d6 18 00 00       	call   1039b0 <initlock>
  picenable(IRQ_IDE);
  1020da:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  1020e1:	e8 ba 0a 00 00       	call   102ba0 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
  1020e6:	a1 00 c1 10 00       	mov    0x10c100,%eax
  1020eb:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  1020f2:	83 e8 01             	sub    $0x1,%eax
  1020f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1020f9:	e8 52 00 00 00       	call   102150 <ioapicenable>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  1020fe:	ba f7 01 00 00       	mov    $0x1f7,%edx
  102103:	90                   	nop
  102104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102108:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  102109:	25 c0 00 00 00       	and    $0xc0,%eax
  10210e:	83 f8 40             	cmp    $0x40,%eax
  102111:	75 f5                	jne    102108 <ideinit+0x48>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102113:	ba f6 01 00 00       	mov    $0x1f6,%edx
  102118:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  10211d:	ee                   	out    %al,(%dx)
  10211e:	31 c9                	xor    %ecx,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102120:	b2 f7                	mov    $0xf7,%dl
  102122:	eb 0f                	jmp    102133 <ideinit+0x73>
  102124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
  102128:	83 c1 01             	add    $0x1,%ecx
  10212b:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  102131:	74 0f                	je     102142 <ideinit+0x82>
  102133:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
  102134:	84 c0                	test   %al,%al
  102136:	74 f0                	je     102128 <ideinit+0x68>
      havedisk1 = 1;
  102138:	c7 05 b8 78 10 00 01 	movl   $0x1,0x1078b8
  10213f:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102142:	ba f6 01 00 00       	mov    $0x1f6,%edx
  102147:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  10214c:	ee                   	out    %al,(%dx)
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
  10214d:	c9                   	leave  
  10214e:	c3                   	ret    
  10214f:	90                   	nop

00102150 <ioapicenable>:
}

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
  102150:	8b 15 04 bb 10 00    	mov    0x10bb04,%edx
  }
}

void
ioapicenable(int irq, int cpunum)
{
  102156:	55                   	push   %ebp
  102157:	89 e5                	mov    %esp,%ebp
  102159:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!ismp)
  10215c:	85 d2                	test   %edx,%edx
  10215e:	74 31                	je     102191 <ioapicenable+0x41>
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102160:	8b 15 b4 ba 10 00    	mov    0x10bab4,%edx
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  102166:	8d 48 20             	lea    0x20(%eax),%ecx
  102169:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10216d:	89 02                	mov    %eax,(%edx)
  ioapic->data = data;
  10216f:	8b 15 b4 ba 10 00    	mov    0x10bab4,%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102175:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
  102178:	89 4a 10             	mov    %ecx,0x10(%edx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10217b:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  102181:	8b 55 0c             	mov    0xc(%ebp),%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102184:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
  102186:	a1 b4 ba 10 00       	mov    0x10bab4,%eax

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  10218b:	c1 e2 18             	shl    $0x18,%edx

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  10218e:	89 50 10             	mov    %edx,0x10(%eax)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
  102191:	5d                   	pop    %ebp
  102192:	c3                   	ret    
  102193:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  102199:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001021a0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
  1021a0:	55                   	push   %ebp
  1021a1:	89 e5                	mov    %esp,%ebp
  1021a3:	56                   	push   %esi
  1021a4:	53                   	push   %ebx
  1021a5:	83 ec 10             	sub    $0x10,%esp
  int i, id, maxintr;

  if(!ismp)
  1021a8:	8b 0d 04 bb 10 00    	mov    0x10bb04,%ecx
  1021ae:	85 c9                	test   %ecx,%ecx
  1021b0:	0f 84 9e 00 00 00    	je     102254 <ioapicinit+0xb4>
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  1021b6:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
  1021bd:	00 00 00 
  return ioapic->data;
  1021c0:	8b 35 10 00 c0 fe    	mov    0xfec00010,%esi
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021c6:	bb 00 00 c0 fe       	mov    $0xfec00000,%ebx
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  1021cb:	c7 05 00 00 c0 fe 00 	movl   $0x0,0xfec00000
  1021d2:	00 00 00 
  return ioapic->data;
  1021d5:	a1 10 00 c0 fe       	mov    0xfec00010,%eax
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021da:	0f b6 15 00 bb 10 00 	movzbl 0x10bb00,%edx
  int i, id, maxintr;

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  1021e1:	c7 05 b4 ba 10 00 00 	movl   $0xfec00000,0x10bab4
  1021e8:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  1021eb:	c1 ee 10             	shr    $0x10,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021ee:	c1 e8 18             	shr    $0x18,%eax

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  1021f1:	81 e6 ff 00 00 00    	and    $0xff,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021f7:	39 c2                	cmp    %eax,%edx
  1021f9:	74 12                	je     10220d <ioapicinit+0x6d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
  1021fb:	c7 04 24 4c 66 10 00 	movl   $0x10664c,(%esp)
  102202:	e8 29 e3 ff ff       	call   100530 <cprintf>
  102207:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
  10220d:	ba 10 00 00 00       	mov    $0x10,%edx
  102212:	31 c0                	xor    %eax,%eax
  102214:	eb 08                	jmp    10221e <ioapicinit+0x7e>
  102216:	66 90                	xchg   %ax,%ax

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  102218:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10221e:	89 13                	mov    %edx,(%ebx)
  ioapic->data = data;
  102220:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
  102226:	8d 48 20             	lea    0x20(%eax),%ecx
  102229:	81 c9 00 00 01 00    	or     $0x10000,%ecx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  10222f:	83 c0 01             	add    $0x1,%eax

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  102232:	89 4b 10             	mov    %ecx,0x10(%ebx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102235:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx
  10223b:	8d 5a 01             	lea    0x1(%edx),%ebx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  10223e:	83 c2 02             	add    $0x2,%edx
  102241:	39 c6                	cmp    %eax,%esi
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102243:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
  102245:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx
  10224b:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  102252:	7d c4                	jge    102218 <ioapicinit+0x78>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
  102254:	83 c4 10             	add    $0x10,%esp
  102257:	5b                   	pop    %ebx
  102258:	5e                   	pop    %esi
  102259:	5d                   	pop    %ebp
  10225a:	c3                   	ret    
  10225b:	90                   	nop
  10225c:	90                   	nop
  10225d:	90                   	nop
  10225e:	90                   	nop
  10225f:	90                   	nop

00102260 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  102260:	55                   	push   %ebp
  102261:	89 e5                	mov    %esp,%ebp
  102263:	53                   	push   %ebx
  102264:	83 ec 14             	sub    $0x14,%esp
  struct run *r;

  acquire(&kmem.lock);
  102267:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  10226e:	e8 cd 18 00 00       	call   103b40 <acquire>
  r = kmem.freelist;
  102273:	8b 1d f4 ba 10 00    	mov    0x10baf4,%ebx
  if(r)
  102279:	85 db                	test   %ebx,%ebx
  10227b:	74 07                	je     102284 <kalloc+0x24>
    kmem.freelist = r->next;
  10227d:	8b 03                	mov    (%ebx),%eax
  10227f:	a3 f4 ba 10 00       	mov    %eax,0x10baf4
  release(&kmem.lock);
  102284:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  10228b:	e8 60 18 00 00       	call   103af0 <release>
  return (char*)r;
}
  102290:	89 d8                	mov    %ebx,%eax
  102292:	83 c4 14             	add    $0x14,%esp
  102295:	5b                   	pop    %ebx
  102296:	5d                   	pop    %ebp
  102297:	c3                   	ret    
  102298:	90                   	nop
  102299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001022a0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
  1022a0:	55                   	push   %ebp
  1022a1:	89 e5                	mov    %esp,%ebp
  1022a3:	53                   	push   %ebx
  1022a4:	83 ec 14             	sub    $0x14,%esp
  1022a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
  1022aa:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  1022b0:	75 52                	jne    102304 <kfree+0x64>
  1022b2:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  1022b8:	77 4a                	ja     102304 <kfree+0x64>
  1022ba:	81 fb a4 e8 10 00    	cmp    $0x10e8a4,%ebx
  1022c0:	72 42                	jb     102304 <kfree+0x64>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
  1022c2:	89 1c 24             	mov    %ebx,(%esp)
  1022c5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1022cc:	00 
  1022cd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1022d4:	00 
  1022d5:	e8 06 19 00 00       	call   103be0 <memset>

  acquire(&kmem.lock);
  1022da:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  1022e1:	e8 5a 18 00 00       	call   103b40 <acquire>
  r = (struct run*)v;
  r->next = kmem.freelist;
  1022e6:	a1 f4 ba 10 00       	mov    0x10baf4,%eax
  1022eb:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  1022ed:	89 1d f4 ba 10 00    	mov    %ebx,0x10baf4
  release(&kmem.lock);
  1022f3:	c7 45 08 c0 ba 10 00 	movl   $0x10bac0,0x8(%ebp)
}
  1022fa:	83 c4 14             	add    $0x14,%esp
  1022fd:	5b                   	pop    %ebx
  1022fe:	5d                   	pop    %ebp

  acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
  1022ff:	e9 ec 17 00 00       	jmp    103af0 <release>
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
    panic("kfree");
  102304:	c7 04 24 7e 66 10 00 	movl   $0x10667e,(%esp)
  10230b:	e8 10 e6 ff ff       	call   100920 <panic>

00102310 <kinit>:
extern char end[]; // first address after kernel loaded from ELF file

// Initialize free list of physical pages.
void
kinit(void)
{
  102310:	55                   	push   %ebp
  102311:	89 e5                	mov    %esp,%ebp
  102313:	53                   	push   %ebx
  102314:	83 ec 14             	sub    $0x14,%esp
  char *p;

  initlock(&kmem.lock, "kmem");
  102317:	c7 44 24 04 84 66 10 	movl   $0x106684,0x4(%esp)
  10231e:	00 
  10231f:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  102326:	e8 85 16 00 00       	call   1039b0 <initlock>
  p = (char*)PGROUNDUP((uint)end);
  10232b:	ba a3 f8 10 00       	mov    $0x10f8a3,%edx
  102330:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  102336:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
  10233c:	81 fb 00 00 00 01    	cmp    $0x1000000,%ebx
  102342:	76 08                	jbe    10234c <kinit+0x3c>
  102344:	eb 1b                	jmp    102361 <kinit+0x51>
  102346:	66 90                	xchg   %ax,%ax
  102348:	89 da                	mov    %ebx,%edx
  10234a:	89 c3                	mov    %eax,%ebx
    kfree(p);
  10234c:	89 14 24             	mov    %edx,(%esp)
  10234f:	e8 4c ff ff ff       	call   1022a0 <kfree>
{
  char *p;

  initlock(&kmem.lock, "kmem");
  p = (char*)PGROUNDUP((uint)end);
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  102354:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  10235a:	3d 00 00 00 01       	cmp    $0x1000000,%eax
  10235f:	76 e7                	jbe    102348 <kinit+0x38>
    kfree(p);
}
  102361:	83 c4 14             	add    $0x14,%esp
  102364:	5b                   	pop    %ebx
  102365:	5d                   	pop    %ebp
  102366:	c3                   	ret    
  102367:	90                   	nop
  102368:	90                   	nop
  102369:	90                   	nop
  10236a:	90                   	nop
  10236b:	90                   	nop
  10236c:	90                   	nop
  10236d:	90                   	nop
  10236e:	90                   	nop
  10236f:	90                   	nop

00102370 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
  102370:	55                   	push   %ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102371:	ba 64 00 00 00       	mov    $0x64,%edx
  102376:	89 e5                	mov    %esp,%ebp
  102378:	ec                   	in     (%dx),%al
  102379:	89 c2                	mov    %eax,%edx
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
  10237b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102380:	83 e2 01             	and    $0x1,%edx
  102383:	74 3e                	je     1023c3 <kbdgetc+0x53>
  102385:	ba 60 00 00 00       	mov    $0x60,%edx
  10238a:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
  10238b:	0f b6 c0             	movzbl %al,%eax

  if(data == 0xE0){
  10238e:	3d e0 00 00 00       	cmp    $0xe0,%eax
  102393:	0f 84 7f 00 00 00    	je     102418 <kbdgetc+0xa8>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
  102399:	84 c0                	test   %al,%al
  10239b:	79 2b                	jns    1023c8 <kbdgetc+0x58>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
  10239d:	8b 15 bc 78 10 00    	mov    0x1078bc,%edx
  1023a3:	f6 c2 40             	test   $0x40,%dl
  1023a6:	75 03                	jne    1023ab <kbdgetc+0x3b>
  1023a8:	83 e0 7f             	and    $0x7f,%eax
    shift &= ~(shiftcode[data] | E0ESC);
  1023ab:	0f b6 80 a0 66 10 00 	movzbl 0x1066a0(%eax),%eax
  1023b2:	83 c8 40             	or     $0x40,%eax
  1023b5:	0f b6 c0             	movzbl %al,%eax
  1023b8:	f7 d0                	not    %eax
  1023ba:	21 d0                	and    %edx,%eax
  1023bc:	a3 bc 78 10 00       	mov    %eax,0x1078bc
  1023c1:	31 c0                	xor    %eax,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  1023c3:	5d                   	pop    %ebp
  1023c4:	c3                   	ret    
  1023c5:	8d 76 00             	lea    0x0(%esi),%esi
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
  1023c8:	8b 0d bc 78 10 00    	mov    0x1078bc,%ecx
  1023ce:	f6 c1 40             	test   $0x40,%cl
  1023d1:	74 05                	je     1023d8 <kbdgetc+0x68>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
  1023d3:	0c 80                	or     $0x80,%al
    shift &= ~E0ESC;
  1023d5:	83 e1 bf             	and    $0xffffffbf,%ecx
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  1023d8:	0f b6 90 a0 66 10 00 	movzbl 0x1066a0(%eax),%edx
  1023df:	09 ca                	or     %ecx,%edx
  1023e1:	0f b6 88 a0 67 10 00 	movzbl 0x1067a0(%eax),%ecx
  1023e8:	31 ca                	xor    %ecx,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
  1023ea:	89 d1                	mov    %edx,%ecx
  1023ec:	83 e1 03             	and    $0x3,%ecx
  1023ef:	8b 0c 8d a0 68 10 00 	mov    0x1068a0(,%ecx,4),%ecx
    data |= 0x80;
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  1023f6:	89 15 bc 78 10 00    	mov    %edx,0x1078bc
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
  1023fc:	83 e2 08             	and    $0x8,%edx
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  1023ff:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
  if(shift & CAPSLOCK){
  102403:	74 be                	je     1023c3 <kbdgetc+0x53>
    if('a' <= c && c <= 'z')
  102405:	8d 50 9f             	lea    -0x61(%eax),%edx
  102408:	83 fa 19             	cmp    $0x19,%edx
  10240b:	77 1b                	ja     102428 <kbdgetc+0xb8>
      c += 'A' - 'a';
  10240d:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102410:	5d                   	pop    %ebp
  102411:	c3                   	ret    
  102412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if((st & KBS_DIB) == 0)
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
  102418:	30 c0                	xor    %al,%al
  10241a:	83 0d bc 78 10 00 40 	orl    $0x40,0x1078bc
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102421:	5d                   	pop    %ebp
  102422:	c3                   	ret    
  102423:	90                   	nop
  102424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
  102428:	8d 50 bf             	lea    -0x41(%eax),%edx
  10242b:	83 fa 19             	cmp    $0x19,%edx
  10242e:	77 93                	ja     1023c3 <kbdgetc+0x53>
      c += 'a' - 'A';
  102430:	83 c0 20             	add    $0x20,%eax
  }
  return c;
}
  102433:	5d                   	pop    %ebp
  102434:	c3                   	ret    
  102435:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102439:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102440 <kbdintr>:

void
kbdintr(void)
{
  102440:	55                   	push   %ebp
  102441:	89 e5                	mov    %esp,%ebp
  102443:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
  102446:	c7 04 24 70 23 10 00 	movl   $0x102370,(%esp)
  10244d:	e8 3e e3 ff ff       	call   100790 <consoleintr>
}
  102452:	c9                   	leave  
  102453:	c3                   	ret    
  102454:	90                   	nop
  102455:	90                   	nop
  102456:	90                   	nop
  102457:	90                   	nop
  102458:	90                   	nop
  102459:	90                   	nop
  10245a:	90                   	nop
  10245b:	90                   	nop
  10245c:	90                   	nop
  10245d:	90                   	nop
  10245e:	90                   	nop
  10245f:	90                   	nop

00102460 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
  102460:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
}

// Acknowledge interrupt.
void
lapiceoi(void)
{
  102465:	55                   	push   %ebp
  102466:	89 e5                	mov    %esp,%ebp
  if(lapic)
  102468:	85 c0                	test   %eax,%eax
  10246a:	74 12                	je     10247e <lapiceoi+0x1e>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10246c:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  102473:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102476:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10247b:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
  10247e:	5d                   	pop    %ebp
  10247f:	c3                   	ret    

00102480 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
  102480:	55                   	push   %ebp
  102481:	89 e5                	mov    %esp,%ebp
}
  102483:	5d                   	pop    %ebp
  102484:	c3                   	ret    
  102485:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102489:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102490 <lapicstartap>:

// Start additional processor running bootstrap code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
  102490:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102491:	ba 70 00 00 00       	mov    $0x70,%edx
  102496:	89 e5                	mov    %esp,%ebp
  102498:	b8 0f 00 00 00       	mov    $0xf,%eax
  10249d:	53                   	push   %ebx
  10249e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1024a1:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
  1024a5:	ee                   	out    %al,(%dx)
  1024a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  1024ab:	b2 71                	mov    $0x71,%dl
  1024ad:	ee                   	out    %al,(%dx)
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  wrv[1] = addr >> 4;
  1024ae:	89 c8                	mov    %ecx,%eax
  1024b0:	c1 e8 04             	shr    $0x4,%eax
  1024b3:	66 a3 69 04 00 00    	mov    %ax,0x469
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024b9:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024be:	c1 e3 18             	shl    $0x18,%ebx
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  1024c1:	66 c7 05 67 04 00 00 	movw   $0x0,0x467
  1024c8:	00 00 

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  1024ca:	c1 e9 0c             	shr    $0xc,%ecx
  1024cd:	80 cd 06             	or     $0x6,%ch
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024d0:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  1024d6:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024db:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024de:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
  1024e5:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1024e8:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024ed:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024f0:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
  1024f7:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1024fa:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024ff:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102502:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102508:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10250d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102510:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102516:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10251b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10251e:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102524:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102529:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10252c:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102532:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  102537:	5b                   	pop    %ebx
  102538:	5d                   	pop    %ebp

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  102539:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  10253c:	c3                   	ret    
  10253d:	8d 76 00             	lea    0x0(%esi),%esi

00102540 <cpunum>:
  lapicw(TPR, 0);
}

int
cpunum(void)
{
  102540:	55                   	push   %ebp
  102541:	89 e5                	mov    %esp,%ebp
  102543:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  102546:	9c                   	pushf  
  102547:	58                   	pop    %eax
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
  102548:	f6 c4 02             	test   $0x2,%ah
  10254b:	74 12                	je     10255f <cpunum+0x1f>
    static int n;
    if(n++ == 0)
  10254d:	a1 c0 78 10 00       	mov    0x1078c0,%eax
  102552:	8d 50 01             	lea    0x1(%eax),%edx
  102555:	85 c0                	test   %eax,%eax
  102557:	89 15 c0 78 10 00    	mov    %edx,0x1078c0
  10255d:	74 19                	je     102578 <cpunum+0x38>
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if(lapic)
  10255f:	8b 15 f8 ba 10 00    	mov    0x10baf8,%edx
  102565:	31 c0                	xor    %eax,%eax
  102567:	85 d2                	test   %edx,%edx
  102569:	74 06                	je     102571 <cpunum+0x31>
    return lapic[ID]>>24;
  10256b:	8b 42 20             	mov    0x20(%edx),%eax
  10256e:	c1 e8 18             	shr    $0x18,%eax
  return 0;
}
  102571:	c9                   	leave  
  102572:	c3                   	ret    
  102573:	90                   	nop
  102574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
    static int n;
    if(n++ == 0)
      cprintf("cpu called from %x with interrupts enabled\n",
  102578:	8b 45 04             	mov    0x4(%ebp),%eax
  10257b:	c7 04 24 b0 68 10 00 	movl   $0x1068b0,(%esp)
  102582:	89 44 24 04          	mov    %eax,0x4(%esp)
  102586:	e8 a5 df ff ff       	call   100530 <cprintf>
  10258b:	eb d2                	jmp    10255f <cpunum+0x1f>
  10258d:	8d 76 00             	lea    0x0(%esi),%esi

00102590 <lapicinit>:
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(int c)
{
  102590:	55                   	push   %ebp
  102591:	89 e5                	mov    %esp,%ebp
  102593:	83 ec 18             	sub    $0x18,%esp
  cprintf("lapicinit: %d 0x%x\n", c, lapic);
  102596:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10259b:	c7 04 24 dc 68 10 00 	movl   $0x1068dc,(%esp)
  1025a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1025a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1025a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1025ad:	e8 7e df ff ff       	call   100530 <cprintf>
  if(!lapic) 
  1025b2:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025b7:	85 c0                	test   %eax,%eax
  1025b9:	0f 84 0a 01 00 00    	je     1026c9 <lapicinit+0x139>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025bf:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
  1025c6:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1025c9:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025ce:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025d1:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
  1025d8:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1025db:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025e0:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025e3:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
  1025ea:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
  1025ed:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025f2:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025f5:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
  1025fc:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
  1025ff:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102604:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102607:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
  10260e:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  102611:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102616:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102619:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
  102620:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  102623:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102628:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
  10262b:	8b 50 30             	mov    0x30(%eax),%edx
  10262e:	c1 ea 10             	shr    $0x10,%edx
  102631:	80 fa 03             	cmp    $0x3,%dl
  102634:	0f 87 96 00 00 00    	ja     1026d0 <lapicinit+0x140>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10263a:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
  102641:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102644:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102649:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10264c:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  102653:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102656:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10265b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10265e:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  102665:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102668:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10266d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102670:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  102677:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10267a:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10267f:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102682:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
  102689:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10268c:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102691:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102694:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
  10269b:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
  10269e:	8b 0d f8 ba 10 00    	mov    0x10baf8,%ecx
  1026a4:	8b 41 20             	mov    0x20(%ecx),%eax
  1026a7:	8d 91 00 03 00 00    	lea    0x300(%ecx),%edx
  1026ad:	8d 76 00             	lea    0x0(%esi),%esi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
  1026b0:	8b 02                	mov    (%edx),%eax
  1026b2:	f6 c4 10             	test   $0x10,%ah
  1026b5:	75 f9                	jne    1026b0 <lapicinit+0x120>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026b7:	c7 81 80 00 00 00 00 	movl   $0x0,0x80(%ecx)
  1026be:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026c1:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026c6:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
  1026c9:	c9                   	leave  
  1026ca:	c3                   	ret    
  1026cb:	90                   	nop
  1026cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026d0:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
  1026d7:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  1026da:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026df:	8b 50 20             	mov    0x20(%eax),%edx
  1026e2:	e9 53 ff ff ff       	jmp    10263a <lapicinit+0xaa>
  1026e7:	90                   	nop
  1026e8:	90                   	nop
  1026e9:	90                   	nop
  1026ea:	90                   	nop
  1026eb:	90                   	nop
  1026ec:	90                   	nop
  1026ed:	90                   	nop
  1026ee:	90                   	nop
  1026ef:	90                   	nop

001026f0 <mpmain>:
// Common CPU setup code.
// Bootstrap CPU comes here from mainc().
// Other CPUs jump here from bootother.S.
static void
mpmain(void)
{
  1026f0:	55                   	push   %ebp
  1026f1:	89 e5                	mov    %esp,%ebp
  1026f3:	53                   	push   %ebx
  1026f4:	83 ec 14             	sub    $0x14,%esp
  if(cpunum() != mpbcpu()){
  1026f7:	e8 44 fe ff ff       	call   102540 <cpunum>
  1026fc:	89 c3                	mov    %eax,%ebx
  1026fe:	e8 ed 01 00 00       	call   1028f0 <mpbcpu>
  102703:	39 c3                	cmp    %eax,%ebx
  102705:	74 16                	je     10271d <mpmain+0x2d>
    seginit();
  102707:	e8 84 3c 00 00       	call   106390 <seginit>
  10270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    lapicinit(cpunum());
  102710:	e8 2b fe ff ff       	call   102540 <cpunum>
  102715:	89 04 24             	mov    %eax,(%esp)
  102718:	e8 73 fe ff ff       	call   102590 <lapicinit>
  }
  vmenable();        // turn on paging
  10271d:	e8 2e 35 00 00       	call   105c50 <vmenable>
  cprintf("cpu%d: starting\n", cpu->id);
  102722:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  102728:	0f b6 00             	movzbl (%eax),%eax
  10272b:	c7 04 24 f0 68 10 00 	movl   $0x1068f0,(%esp)
  102732:	89 44 24 04          	mov    %eax,0x4(%esp)
  102736:	e8 f5 dd ff ff       	call   100530 <cprintf>
  idtinit();       // load idt register
  10273b:	e8 20 26 00 00       	call   104d60 <idtinit>
  xchg(&cpu->booted, 1); // tell bootothers() we're up
  102740:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  102747:	b8 01 00 00 00       	mov    $0x1,%eax
  10274c:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler();     // start running processes
  102753:	e8 18 0c 00 00       	call   103370 <scheduler>
  102758:	90                   	nop
  102759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102760 <mainc>:

// Set up hardware and software.
// Runs only on the boostrap processor.
void
mainc(void)
{
  102760:	55                   	push   %ebp
  102761:	89 e5                	mov    %esp,%ebp
  102763:	53                   	push   %ebx
  102764:	83 ec 14             	sub    $0x14,%esp
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  102767:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10276d:	0f b6 00             	movzbl (%eax),%eax
  102770:	c7 04 24 01 69 10 00 	movl   $0x106901,(%esp)
  102777:	89 44 24 04          	mov    %eax,0x4(%esp)
  10277b:	e8 b0 dd ff ff       	call   100530 <cprintf>
  picinit();       // interrupt controller
  102780:	e8 4b 04 00 00       	call   102bd0 <picinit>
  ioapicinit();    // another interrupt controller
  102785:	e8 16 fa ff ff       	call   1021a0 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
  10278a:	e8 d1 da ff ff       	call   100260 <consoleinit>
  10278f:	90                   	nop
  uartinit();      // serial port
  102790:	e8 8b 29 00 00       	call   105120 <uartinit>
  kvmalloc();      // initialize the kernel page table
  102795:	e8 36 37 00 00       	call   105ed0 <kvmalloc>
  pinit();         // process table
  10279a:	e8 f1 11 00 00       	call   103990 <pinit>
  10279f:	90                   	nop
  tvinit();        // trap vectors
  1027a0:	e8 4b 28 00 00       	call   104ff0 <tvinit>
  binit();         // buffer cache
  1027a5:	e8 46 da ff ff       	call   1001f0 <binit>
  fileinit();      // file table
  1027aa:	e8 b1 e8 ff ff       	call   101060 <fileinit>
  1027af:	90                   	nop
  iinit();         // inode cache
  1027b0:	e8 cb f6 ff ff       	call   101e80 <iinit>
  ideinit();       // disk
  1027b5:	e8 06 f9 ff ff       	call   1020c0 <ideinit>
  if(!ismp)
  1027ba:	a1 04 bb 10 00       	mov    0x10bb04,%eax
  1027bf:	85 c0                	test   %eax,%eax
  1027c1:	0f 84 ae 00 00 00    	je     102875 <mainc+0x115>
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  1027c7:	e8 d4 10 00 00       	call   1038a0 <userinit>

  // Write bootstrap code to unused memory at 0x7000.
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);
  1027cc:	c7 44 24 08 6a 00 00 	movl   $0x6a,0x8(%esp)
  1027d3:	00 
  1027d4:	c7 44 24 04 9c 77 10 	movl   $0x10779c,0x4(%esp)
  1027db:	00 
  1027dc:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
  1027e3:	e8 78 14 00 00       	call   103c60 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
  1027e8:	69 05 00 c1 10 00 bc 	imul   $0xbc,0x10c100,%eax
  1027ef:	00 00 00 
  1027f2:	05 20 bb 10 00       	add    $0x10bb20,%eax
  1027f7:	3d 20 bb 10 00       	cmp    $0x10bb20,%eax
  1027fc:	76 6d                	jbe    10286b <mainc+0x10b>
  1027fe:	bb 20 bb 10 00       	mov    $0x10bb20,%ebx
  102803:	90                   	nop
  102804:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(c == cpus+cpunum())  // We've started already.
  102808:	e8 33 fd ff ff       	call   102540 <cpunum>
  10280d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  102813:	05 20 bb 10 00       	add    $0x10bb20,%eax
  102818:	39 c3                	cmp    %eax,%ebx
  10281a:	74 36                	je     102852 <mainc+0xf2>
      continue;

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
  10281c:	e8 3f fa ff ff       	call   102260 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpmain;
  102821:	c7 05 f8 6f 00 00 f0 	movl   $0x1026f0,0x6ff8
  102828:	26 10 00 

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
    *(void**)(code-4) = stack + KSTACKSIZE;
  10282b:	05 00 10 00 00       	add    $0x1000,%eax
  102830:	a3 fc 6f 00 00       	mov    %eax,0x6ffc
    *(void**)(code-8) = mpmain;

    lapicstartap(c->id, (uint)code);
  102835:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
  10283c:	00 
  10283d:	0f b6 03             	movzbl (%ebx),%eax
  102840:	89 04 24             	mov    %eax,(%esp)
  102843:	e8 48 fc ff ff       	call   102490 <lapicstartap>

    // Wait for cpu to finish mpmain()
    while(c->booted == 0)
  102848:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
  10284e:	85 c0                	test   %eax,%eax
  102850:	74 f6                	je     102848 <mainc+0xe8>
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);

  for(c = cpus; c < cpus+ncpu; c++){
  102852:	69 05 00 c1 10 00 bc 	imul   $0xbc,0x10c100,%eax
  102859:	00 00 00 
  10285c:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
  102862:	05 20 bb 10 00       	add    $0x10bb20,%eax
  102867:	39 c3                	cmp    %eax,%ebx
  102869:	72 9d                	jb     102808 <mainc+0xa8>
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
}
  10286b:	83 c4 14             	add    $0x14,%esp
  10286e:	5b                   	pop    %ebx
  10286f:	5d                   	pop    %ebp
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
  102870:	e9 7b fe ff ff       	jmp    1026f0 <mpmain>
  binit();         // buffer cache
  fileinit();      // file table
  iinit();         // inode cache
  ideinit();       // disk
  if(!ismp)
    timerinit();   // uniprocessor timer
  102875:	e8 86 24 00 00       	call   104d00 <timerinit>
  10287a:	e9 48 ff ff ff       	jmp    1027c7 <mainc+0x67>
  10287f:	90                   	nop

00102880 <jmpkstack>:
  jmpkstack();       // call mainc() on a properly-allocated stack 
}

void
jmpkstack(void)
{
  102880:	55                   	push   %ebp
  102881:	89 e5                	mov    %esp,%ebp
  102883:	83 ec 18             	sub    $0x18,%esp
  char *kstack, *top;
  
  kstack = kalloc();
  102886:	e8 d5 f9 ff ff       	call   102260 <kalloc>
  if(kstack == 0)
  10288b:	85 c0                	test   %eax,%eax
  10288d:	74 19                	je     1028a8 <jmpkstack+0x28>
    panic("jmpkstack kalloc");
  top = kstack + PGSIZE;
  asm volatile("movl %0,%%esp; call mainc" : : "r" (top));
  10288f:	05 00 10 00 00       	add    $0x1000,%eax
  102894:	89 c4                	mov    %eax,%esp
  102896:	e8 c5 fe ff ff       	call   102760 <mainc>
  panic("jmpkstack");
  10289b:	c7 04 24 29 69 10 00 	movl   $0x106929,(%esp)
  1028a2:	e8 79 e0 ff ff       	call   100920 <panic>
  1028a7:	90                   	nop
{
  char *kstack, *top;
  
  kstack = kalloc();
  if(kstack == 0)
    panic("jmpkstack kalloc");
  1028a8:	c7 04 24 18 69 10 00 	movl   $0x106918,(%esp)
  1028af:	e8 6c e0 ff ff       	call   100920 <panic>
  1028b4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1028ba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001028c0 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
  1028c0:	55                   	push   %ebp
  1028c1:	89 e5                	mov    %esp,%ebp
  1028c3:	83 e4 f0             	and    $0xfffffff0,%esp
  1028c6:	83 ec 10             	sub    $0x10,%esp
  mpinit();        // collect info about this machine
  1028c9:	e8 b2 00 00 00       	call   102980 <mpinit>
  lapicinit(mpbcpu());
  1028ce:	e8 1d 00 00 00       	call   1028f0 <mpbcpu>
  1028d3:	89 04 24             	mov    %eax,(%esp)
  1028d6:	e8 b5 fc ff ff       	call   102590 <lapicinit>
  seginit();       // set up segments
  1028db:	e8 b0 3a 00 00       	call   106390 <seginit>
  kinit();         // initialize memory allocator
  1028e0:	e8 2b fa ff ff       	call   102310 <kinit>
  jmpkstack();       // call mainc() on a properly-allocated stack 
  1028e5:	e8 96 ff ff ff       	call   102880 <jmpkstack>
  1028ea:	90                   	nop
  1028eb:	90                   	nop
  1028ec:	90                   	nop
  1028ed:	90                   	nop
  1028ee:	90                   	nop
  1028ef:	90                   	nop

001028f0 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  1028f0:	a1 c4 78 10 00       	mov    0x1078c4,%eax
  1028f5:	55                   	push   %ebp
  1028f6:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
}
  1028f8:	5d                   	pop    %ebp
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  1028f9:	2d 20 bb 10 00       	sub    $0x10bb20,%eax
  1028fe:	c1 f8 02             	sar    $0x2,%eax
  102901:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
  return bcpu-cpus;
}
  102907:	c3                   	ret    
  102908:	90                   	nop
  102909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102910 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102910:	55                   	push   %ebp
  102911:	89 e5                	mov    %esp,%ebp
  102913:	56                   	push   %esi
  102914:	53                   	push   %ebx
  uchar *e, *p;

  e = addr+len;
  102915:	8d 34 10             	lea    (%eax,%edx,1),%esi
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102918:	83 ec 10             	sub    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  10291b:	39 f0                	cmp    %esi,%eax
  10291d:	73 42                	jae    102961 <mpsearch1+0x51>
  10291f:	89 c3                	mov    %eax,%ebx
  102921:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  102928:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  10292f:	00 
  102930:	c7 44 24 04 33 69 10 	movl   $0x106933,0x4(%esp)
  102937:	00 
  102938:	89 1c 24             	mov    %ebx,(%esp)
  10293b:	e8 c0 12 00 00       	call   103c00 <memcmp>
  102940:	85 c0                	test   %eax,%eax
  102942:	75 16                	jne    10295a <mpsearch1+0x4a>
  102944:	31 d2                	xor    %edx,%edx
  102946:	66 90                	xchg   %ax,%ax
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
  102948:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  10294c:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  10294f:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102951:	83 f8 10             	cmp    $0x10,%eax
  102954:	75 f2                	jne    102948 <mpsearch1+0x38>
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  102956:	84 d2                	test   %dl,%dl
  102958:	74 10                	je     10296a <mpsearch1+0x5a>
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  10295a:	83 c3 10             	add    $0x10,%ebx
  10295d:	39 de                	cmp    %ebx,%esi
  10295f:	77 c7                	ja     102928 <mpsearch1+0x18>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  102961:	83 c4 10             	add    $0x10,%esp
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  102964:	31 c0                	xor    %eax,%eax
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  102966:	5b                   	pop    %ebx
  102967:	5e                   	pop    %esi
  102968:	5d                   	pop    %ebp
  102969:	c3                   	ret    
  10296a:	83 c4 10             	add    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  10296d:	89 d8                	mov    %ebx,%eax
  return 0;
}
  10296f:	5b                   	pop    %ebx
  102970:	5e                   	pop    %esi
  102971:	5d                   	pop    %ebp
  102972:	c3                   	ret    
  102973:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  102979:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102980 <mpinit>:
  return conf;
}

void
mpinit(void)
{
  102980:	55                   	push   %ebp
  102981:	89 e5                	mov    %esp,%ebp
  102983:	57                   	push   %edi
  102984:	56                   	push   %esi
  102985:	53                   	push   %ebx
  102986:	83 ec 1c             	sub    $0x1c,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  102989:	0f b6 05 0f 04 00 00 	movzbl 0x40f,%eax
  102990:	0f b6 15 0e 04 00 00 	movzbl 0x40e,%edx
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  102997:	c7 05 c4 78 10 00 20 	movl   $0x10bb20,0x1078c4
  10299e:	bb 10 00 
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  1029a1:	c1 e0 08             	shl    $0x8,%eax
  1029a4:	09 d0                	or     %edx,%eax
  1029a6:	c1 e0 04             	shl    $0x4,%eax
  1029a9:	85 c0                	test   %eax,%eax
  1029ab:	75 1b                	jne    1029c8 <mpinit+0x48>
    if((mp = mpsearch1((uchar*)p, 1024)))
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
  1029ad:	0f b6 05 14 04 00 00 	movzbl 0x414,%eax
  1029b4:	0f b6 15 13 04 00 00 	movzbl 0x413,%edx
  1029bb:	c1 e0 08             	shl    $0x8,%eax
  1029be:	09 d0                	or     %edx,%eax
  1029c0:	c1 e0 0a             	shl    $0xa,%eax
  1029c3:	2d 00 04 00 00       	sub    $0x400,%eax
  1029c8:	ba 00 04 00 00       	mov    $0x400,%edx
  1029cd:	e8 3e ff ff ff       	call   102910 <mpsearch1>
  1029d2:	85 c0                	test   %eax,%eax
  1029d4:	89 c6                	mov    %eax,%esi
  1029d6:	0f 84 94 01 00 00    	je     102b70 <mpinit+0x1f0>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  1029dc:	8b 5e 04             	mov    0x4(%esi),%ebx
  1029df:	85 db                	test   %ebx,%ebx
  1029e1:	74 1c                	je     1029ff <mpinit+0x7f>
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
  1029e3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  1029ea:	00 
  1029eb:	c7 44 24 04 38 69 10 	movl   $0x106938,0x4(%esp)
  1029f2:	00 
  1029f3:	89 1c 24             	mov    %ebx,(%esp)
  1029f6:	e8 05 12 00 00       	call   103c00 <memcmp>
  1029fb:	85 c0                	test   %eax,%eax
  1029fd:	74 09                	je     102a08 <mpinit+0x88>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  1029ff:	83 c4 1c             	add    $0x1c,%esp
  102a02:	5b                   	pop    %ebx
  102a03:	5e                   	pop    %esi
  102a04:	5f                   	pop    %edi
  102a05:	5d                   	pop    %ebp
  102a06:	c3                   	ret    
  102a07:	90                   	nop
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
  102a08:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
  102a0c:	3c 04                	cmp    $0x4,%al
  102a0e:	74 04                	je     102a14 <mpinit+0x94>
  102a10:	3c 01                	cmp    $0x1,%al
  102a12:	75 eb                	jne    1029ff <mpinit+0x7f>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102a14:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a18:	85 ff                	test   %edi,%edi
  102a1a:	74 15                	je     102a31 <mpinit+0xb1>
  102a1c:	31 d2                	xor    %edx,%edx
  102a1e:	31 c0                	xor    %eax,%eax
    sum += addr[i];
  102a20:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a24:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  102a27:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a29:	39 c7                	cmp    %eax,%edi
  102a2b:	7f f3                	jg     102a20 <mpinit+0xa0>
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102a2d:	84 d2                	test   %dl,%dl
  102a2f:	75 ce                	jne    1029ff <mpinit+0x7f>
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  102a31:	c7 05 04 bb 10 00 01 	movl   $0x1,0x10bb04
  102a38:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
  102a3b:	8b 43 24             	mov    0x24(%ebx),%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a3e:	8d 7b 2c             	lea    0x2c(%ebx),%edi

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  102a41:	a3 f8 ba 10 00       	mov    %eax,0x10baf8
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a46:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
  102a4a:	01 c3                	add    %eax,%ebx
  102a4c:	39 df                	cmp    %ebx,%edi
  102a4e:	72 29                	jb     102a79 <mpinit+0xf9>
  102a50:	eb 52                	jmp    102aa4 <mpinit+0x124>
  102a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case MPIOINTR:
    case MPLINTR:
      p += 8;
      continue;
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
  102a58:	0f b6 c0             	movzbl %al,%eax
  102a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102a5f:	c7 04 24 58 69 10 00 	movl   $0x106958,(%esp)
  102a66:	e8 c5 da ff ff       	call   100530 <cprintf>
      ismp = 0;
  102a6b:	c7 05 04 bb 10 00 00 	movl   $0x0,0x10bb04
  102a72:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a75:	39 fb                	cmp    %edi,%ebx
  102a77:	76 1e                	jbe    102a97 <mpinit+0x117>
    switch(*p){
  102a79:	0f b6 07             	movzbl (%edi),%eax
  102a7c:	3c 04                	cmp    $0x4,%al
  102a7e:	77 d8                	ja     102a58 <mpinit+0xd8>
  102a80:	0f b6 c0             	movzbl %al,%eax
  102a83:	ff 24 85 78 69 10 00 	jmp    *0x106978(,%eax,4)
  102a8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
  102a90:	83 c7 08             	add    $0x8,%edi
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a93:	39 fb                	cmp    %edi,%ebx
  102a95:	77 e2                	ja     102a79 <mpinit+0xf9>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
  102a97:	a1 04 bb 10 00       	mov    0x10bb04,%eax
  102a9c:	85 c0                	test   %eax,%eax
  102a9e:	0f 84 a4 00 00 00    	je     102b48 <mpinit+0x1c8>
    lapic = 0;
    ioapicid = 0;
    return;
  }

  if(mp->imcrp){
  102aa4:	80 7e 0c 00          	cmpb   $0x0,0xc(%esi)
  102aa8:	0f 84 51 ff ff ff    	je     1029ff <mpinit+0x7f>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102aae:	ba 22 00 00 00       	mov    $0x22,%edx
  102ab3:	b8 70 00 00 00       	mov    $0x70,%eax
  102ab8:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102ab9:	b2 23                	mov    $0x23,%dl
  102abb:	ec                   	in     (%dx),%al
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102abc:	83 c8 01             	or     $0x1,%eax
  102abf:	ee                   	out    %al,(%dx)
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102ac0:	83 c4 1c             	add    $0x1c,%esp
  102ac3:	5b                   	pop    %ebx
  102ac4:	5e                   	pop    %esi
  102ac5:	5f                   	pop    %edi
  102ac6:	5d                   	pop    %ebp
  102ac7:	c3                   	ret    
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu != proc->apicid){
  102ac8:	0f b6 57 01          	movzbl 0x1(%edi),%edx
  102acc:	a1 00 c1 10 00       	mov    0x10c100,%eax
  102ad1:	39 c2                	cmp    %eax,%edx
  102ad3:	74 23                	je     102af8 <mpinit+0x178>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
  102ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ad9:	89 54 24 08          	mov    %edx,0x8(%esp)
  102add:	c7 04 24 3d 69 10 00 	movl   $0x10693d,(%esp)
  102ae4:	e8 47 da ff ff       	call   100530 <cprintf>
        ismp = 0;
  102ae9:	a1 00 c1 10 00       	mov    0x10c100,%eax
  102aee:	c7 05 04 bb 10 00 00 	movl   $0x0,0x10bb04
  102af5:	00 00 00 
      }
      if(proc->flags & MPBOOT)
  102af8:	f6 47 03 02          	testb  $0x2,0x3(%edi)
  102afc:	74 12                	je     102b10 <mpinit+0x190>
        bcpu = &cpus[ncpu];
  102afe:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
  102b04:	81 c2 20 bb 10 00    	add    $0x10bb20,%edx
  102b0a:	89 15 c4 78 10 00    	mov    %edx,0x1078c4
      cpus[ncpu].id = ncpu;
  102b10:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
      ncpu++;
      p += sizeof(struct mpproc);
  102b16:	83 c7 14             	add    $0x14,%edi
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
        ismp = 0;
      }
      if(proc->flags & MPBOOT)
        bcpu = &cpus[ncpu];
      cpus[ncpu].id = ncpu;
  102b19:	88 82 20 bb 10 00    	mov    %al,0x10bb20(%edx)
      ncpu++;
  102b1f:	83 c0 01             	add    $0x1,%eax
  102b22:	a3 00 c1 10 00       	mov    %eax,0x10c100
      p += sizeof(struct mpproc);
      continue;
  102b27:	e9 49 ff ff ff       	jmp    102a75 <mpinit+0xf5>
  102b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102b30:	0f b6 47 01          	movzbl 0x1(%edi),%eax
      p += sizeof(struct mpioapic);
  102b34:	83 c7 08             	add    $0x8,%edi
      ncpu++;
      p += sizeof(struct mpproc);
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102b37:	a2 00 bb 10 00       	mov    %al,0x10bb00
      p += sizeof(struct mpioapic);
      continue;
  102b3c:	e9 34 ff ff ff       	jmp    102a75 <mpinit+0xf5>
  102b41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ismp = 0;
    }
  }
  if(!ismp){
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
  102b48:	c7 05 00 c1 10 00 01 	movl   $0x1,0x10c100
  102b4f:	00 00 00 
    lapic = 0;
  102b52:	c7 05 f8 ba 10 00 00 	movl   $0x0,0x10baf8
  102b59:	00 00 00 
    ioapicid = 0;
  102b5c:	c6 05 00 bb 10 00 00 	movb   $0x0,0x10bb00
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102b63:	83 c4 1c             	add    $0x1c,%esp
  102b66:	5b                   	pop    %ebx
  102b67:	5e                   	pop    %esi
  102b68:	5f                   	pop    %edi
  102b69:	5d                   	pop    %ebp
  102b6a:	c3                   	ret    
  102b6b:	90                   	nop
  102b6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102b70:	ba 00 00 01 00       	mov    $0x10000,%edx
  102b75:	b8 00 00 0f 00       	mov    $0xf0000,%eax
  102b7a:	e8 91 fd ff ff       	call   102910 <mpsearch1>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102b7f:	85 c0                	test   %eax,%eax
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102b81:	89 c6                	mov    %eax,%esi
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102b83:	0f 85 53 fe ff ff    	jne    1029dc <mpinit+0x5c>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102b89:	83 c4 1c             	add    $0x1c,%esp
  102b8c:	5b                   	pop    %ebx
  102b8d:	5e                   	pop    %esi
  102b8e:	5f                   	pop    %edi
  102b8f:	5d                   	pop    %ebp
  102b90:	c3                   	ret    
  102b91:	90                   	nop
  102b92:	90                   	nop
  102b93:	90                   	nop
  102b94:	90                   	nop
  102b95:	90                   	nop
  102b96:	90                   	nop
  102b97:	90                   	nop
  102b98:	90                   	nop
  102b99:	90                   	nop
  102b9a:	90                   	nop
  102b9b:	90                   	nop
  102b9c:	90                   	nop
  102b9d:	90                   	nop
  102b9e:	90                   	nop
  102b9f:	90                   	nop

00102ba0 <picenable>:
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102ba0:	55                   	push   %ebp
  picsetmask(irqmask & ~(1<<irq));
  102ba1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102ba6:	89 e5                	mov    %esp,%ebp
  102ba8:	ba 21 00 00 00       	mov    $0x21,%edx
  picsetmask(irqmask & ~(1<<irq));
  102bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102bb0:	d3 c0                	rol    %cl,%eax
  102bb2:	66 23 05 20 73 10 00 	and    0x107320,%ax
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
  irqmask = mask;
  102bb9:	66 a3 20 73 10 00    	mov    %ax,0x107320
  102bbf:	ee                   	out    %al,(%dx)
  102bc0:	66 c1 e8 08          	shr    $0x8,%ax
  102bc4:	b2 a1                	mov    $0xa1,%dl
  102bc6:	ee                   	out    %al,(%dx)

void
picenable(int irq)
{
  picsetmask(irqmask & ~(1<<irq));
}
  102bc7:	5d                   	pop    %ebp
  102bc8:	c3                   	ret    
  102bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102bd0 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
  102bd0:	55                   	push   %ebp
  102bd1:	b9 21 00 00 00       	mov    $0x21,%ecx
  102bd6:	89 e5                	mov    %esp,%ebp
  102bd8:	83 ec 0c             	sub    $0xc,%esp
  102bdb:	89 1c 24             	mov    %ebx,(%esp)
  102bde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102be3:	89 ca                	mov    %ecx,%edx
  102be5:	89 74 24 04          	mov    %esi,0x4(%esp)
  102be9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  102bed:	ee                   	out    %al,(%dx)
  102bee:	bb a1 00 00 00       	mov    $0xa1,%ebx
  102bf3:	89 da                	mov    %ebx,%edx
  102bf5:	ee                   	out    %al,(%dx)
  102bf6:	be 11 00 00 00       	mov    $0x11,%esi
  102bfb:	b2 20                	mov    $0x20,%dl
  102bfd:	89 f0                	mov    %esi,%eax
  102bff:	ee                   	out    %al,(%dx)
  102c00:	b8 20 00 00 00       	mov    $0x20,%eax
  102c05:	89 ca                	mov    %ecx,%edx
  102c07:	ee                   	out    %al,(%dx)
  102c08:	b8 04 00 00 00       	mov    $0x4,%eax
  102c0d:	ee                   	out    %al,(%dx)
  102c0e:	bf 03 00 00 00       	mov    $0x3,%edi
  102c13:	89 f8                	mov    %edi,%eax
  102c15:	ee                   	out    %al,(%dx)
  102c16:	b1 a0                	mov    $0xa0,%cl
  102c18:	89 f0                	mov    %esi,%eax
  102c1a:	89 ca                	mov    %ecx,%edx
  102c1c:	ee                   	out    %al,(%dx)
  102c1d:	b8 28 00 00 00       	mov    $0x28,%eax
  102c22:	89 da                	mov    %ebx,%edx
  102c24:	ee                   	out    %al,(%dx)
  102c25:	b8 02 00 00 00       	mov    $0x2,%eax
  102c2a:	ee                   	out    %al,(%dx)
  102c2b:	89 f8                	mov    %edi,%eax
  102c2d:	ee                   	out    %al,(%dx)
  102c2e:	be 68 00 00 00       	mov    $0x68,%esi
  102c33:	b2 20                	mov    $0x20,%dl
  102c35:	89 f0                	mov    %esi,%eax
  102c37:	ee                   	out    %al,(%dx)
  102c38:	bb 0a 00 00 00       	mov    $0xa,%ebx
  102c3d:	89 d8                	mov    %ebx,%eax
  102c3f:	ee                   	out    %al,(%dx)
  102c40:	89 f0                	mov    %esi,%eax
  102c42:	89 ca                	mov    %ecx,%edx
  102c44:	ee                   	out    %al,(%dx)
  102c45:	89 d8                	mov    %ebx,%eax
  102c47:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);             // read IRR by default

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
  102c48:	0f b7 05 20 73 10 00 	movzwl 0x107320,%eax
  102c4f:	66 83 f8 ff          	cmp    $0xffffffff,%ax
  102c53:	74 0a                	je     102c5f <picinit+0x8f>
  102c55:	b2 21                	mov    $0x21,%dl
  102c57:	ee                   	out    %al,(%dx)
  102c58:	66 c1 e8 08          	shr    $0x8,%ax
  102c5c:	b2 a1                	mov    $0xa1,%dl
  102c5e:	ee                   	out    %al,(%dx)
    picsetmask(irqmask);
}
  102c5f:	8b 1c 24             	mov    (%esp),%ebx
  102c62:	8b 74 24 04          	mov    0x4(%esp),%esi
  102c66:	8b 7c 24 08          	mov    0x8(%esp),%edi
  102c6a:	89 ec                	mov    %ebp,%esp
  102c6c:	5d                   	pop    %ebp
  102c6d:	c3                   	ret    
  102c6e:	90                   	nop
  102c6f:	90                   	nop

00102c70 <piperead>:
  return n;
}

int
piperead(struct pipe *p, char *addr, int n)
{
  102c70:	55                   	push   %ebp
  102c71:	89 e5                	mov    %esp,%ebp
  102c73:	57                   	push   %edi
  102c74:	56                   	push   %esi
  102c75:	53                   	push   %ebx
  102c76:	83 ec 1c             	sub    $0x1c,%esp
  102c79:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102c7c:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  acquire(&p->lock);
  102c7f:	89 1c 24             	mov    %ebx,(%esp)
  102c82:	e8 b9 0e 00 00       	call   103b40 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102c87:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102c8d:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102c93:	75 58                	jne    102ced <piperead+0x7d>
  102c95:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102c9b:	85 f6                	test   %esi,%esi
  102c9d:	74 4e                	je     102ced <piperead+0x7d>
    if(proc->killed){
  102c9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102ca5:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
  102cab:	8b 48 24             	mov    0x24(%eax),%ecx
  102cae:	85 c9                	test   %ecx,%ecx
  102cb0:	74 21                	je     102cd3 <piperead+0x63>
  102cb2:	e9 99 00 00 00       	jmp    102d50 <piperead+0xe0>
  102cb7:	90                   	nop
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102cb8:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
  102cbe:	85 c0                	test   %eax,%eax
  102cc0:	74 2b                	je     102ced <piperead+0x7d>
    if(proc->killed){
  102cc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102cc8:	8b 50 24             	mov    0x24(%eax),%edx
  102ccb:	85 d2                	test   %edx,%edx
  102ccd:	0f 85 7d 00 00 00    	jne    102d50 <piperead+0xe0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102cd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102cd7:	89 34 24             	mov    %esi,(%esp)
  102cda:	e8 81 05 00 00       	call   103260 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102cdf:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102ce5:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102ceb:	74 cb                	je     102cb8 <piperead+0x48>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102ced:	85 ff                	test   %edi,%edi
  102cef:	7e 76                	jle    102d67 <piperead+0xf7>
    if(p->nread == p->nwrite)
  102cf1:	31 f6                	xor    %esi,%esi
  102cf3:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102cf9:	75 0d                	jne    102d08 <piperead+0x98>
  102cfb:	eb 6a                	jmp    102d67 <piperead+0xf7>
  102cfd:	8d 76 00             	lea    0x0(%esi),%esi
  102d00:	39 93 38 02 00 00    	cmp    %edx,0x238(%ebx)
  102d06:	74 22                	je     102d2a <piperead+0xba>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102d08:	89 d0                	mov    %edx,%eax
  102d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  102d0d:	83 c2 01             	add    $0x1,%edx
  102d10:	25 ff 01 00 00       	and    $0x1ff,%eax
  102d15:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
  102d1a:	88 04 31             	mov    %al,(%ecx,%esi,1)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d1d:	83 c6 01             	add    $0x1,%esi
  102d20:	39 f7                	cmp    %esi,%edi
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102d22:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d28:	7f d6                	jg     102d00 <piperead+0x90>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  102d2a:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  102d30:	89 04 24             	mov    %eax,(%esp)
  102d33:	e8 08 04 00 00       	call   103140 <wakeup>
  release(&p->lock);
  102d38:	89 1c 24             	mov    %ebx,(%esp)
  102d3b:	e8 b0 0d 00 00       	call   103af0 <release>
  return i;
}
  102d40:	83 c4 1c             	add    $0x1c,%esp
  102d43:	89 f0                	mov    %esi,%eax
  102d45:	5b                   	pop    %ebx
  102d46:	5e                   	pop    %esi
  102d47:	5f                   	pop    %edi
  102d48:	5d                   	pop    %ebp
  102d49:	c3                   	ret    
  102d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
      release(&p->lock);
  102d50:	be ff ff ff ff       	mov    $0xffffffff,%esi
  102d55:	89 1c 24             	mov    %ebx,(%esp)
  102d58:	e8 93 0d 00 00       	call   103af0 <release>
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
  102d5d:	83 c4 1c             	add    $0x1c,%esp
  102d60:	89 f0                	mov    %esi,%eax
  102d62:	5b                   	pop    %ebx
  102d63:	5e                   	pop    %esi
  102d64:	5f                   	pop    %edi
  102d65:	5d                   	pop    %ebp
  102d66:	c3                   	ret    
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d67:	31 f6                	xor    %esi,%esi
  102d69:	eb bf                	jmp    102d2a <piperead+0xba>
  102d6b:	90                   	nop
  102d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00102d70 <pipewrite>:
    release(&p->lock);
}

int
pipewrite(struct pipe *p, char *addr, int n)
{
  102d70:	55                   	push   %ebp
  102d71:	89 e5                	mov    %esp,%ebp
  102d73:	57                   	push   %edi
  102d74:	56                   	push   %esi
  102d75:	53                   	push   %ebx
  102d76:	83 ec 3c             	sub    $0x3c,%esp
  102d79:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
  102d7c:	89 1c 24             	mov    %ebx,(%esp)
  102d7f:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
  102d85:	e8 b6 0d 00 00       	call   103b40 <acquire>
  for(i = 0; i < n; i++){
  102d8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  102d8d:	85 c9                	test   %ecx,%ecx
  102d8f:	0f 8e 8d 00 00 00    	jle    102e22 <pipewrite+0xb2>
  102d95:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102d9b:	8d bb 38 02 00 00    	lea    0x238(%ebx),%edi
  102da1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  102da8:	eb 37                	jmp    102de1 <pipewrite+0x71>
  102daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
  102db0:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102db6:	85 c0                	test   %eax,%eax
  102db8:	74 7e                	je     102e38 <pipewrite+0xc8>
  102dba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102dc0:	8b 50 24             	mov    0x24(%eax),%edx
  102dc3:	85 d2                	test   %edx,%edx
  102dc5:	75 71                	jne    102e38 <pipewrite+0xc8>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
  102dc7:	89 34 24             	mov    %esi,(%esp)
  102dca:	e8 71 03 00 00       	call   103140 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102dcf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102dd3:	89 3c 24             	mov    %edi,(%esp)
  102dd6:	e8 85 04 00 00       	call   103260 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
  102ddb:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
  102de1:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102de7:	81 c2 00 02 00 00    	add    $0x200,%edx
  102ded:	39 d0                	cmp    %edx,%eax
  102def:	74 bf                	je     102db0 <pipewrite+0x40>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  102df1:	89 c2                	mov    %eax,%edx
  102df3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102df6:	83 c0 01             	add    $0x1,%eax
  102df9:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  102dff:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e02:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e05:	0f b6 0c 0a          	movzbl (%edx,%ecx,1),%ecx
  102e09:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e0c:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
  102e10:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
  102e16:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  102e1a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102e1d:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  102e20:	7f bf                	jg     102de1 <pipewrite+0x71>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  102e22:	89 34 24             	mov    %esi,(%esp)
  102e25:	e8 16 03 00 00       	call   103140 <wakeup>
  release(&p->lock);
  102e2a:	89 1c 24             	mov    %ebx,(%esp)
  102e2d:	e8 be 0c 00 00       	call   103af0 <release>
  return n;
  102e32:	eb 13                	jmp    102e47 <pipewrite+0xd7>
  102e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
  102e38:	89 1c 24             	mov    %ebx,(%esp)
  102e3b:	e8 b0 0c 00 00       	call   103af0 <release>
  102e40:	c7 45 10 ff ff ff ff 	movl   $0xffffffff,0x10(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
  102e47:	8b 45 10             	mov    0x10(%ebp),%eax
  102e4a:	83 c4 3c             	add    $0x3c,%esp
  102e4d:	5b                   	pop    %ebx
  102e4e:	5e                   	pop    %esi
  102e4f:	5f                   	pop    %edi
  102e50:	5d                   	pop    %ebp
  102e51:	c3                   	ret    
  102e52:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  102e59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102e60 <pipeclose>:
  return -1;
}

void
pipeclose(struct pipe *p, int writable)
{
  102e60:	55                   	push   %ebp
  102e61:	89 e5                	mov    %esp,%ebp
  102e63:	83 ec 18             	sub    $0x18,%esp
  102e66:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  102e69:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102e6c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  102e6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
  102e72:	89 1c 24             	mov    %ebx,(%esp)
  102e75:	e8 c6 0c 00 00       	call   103b40 <acquire>
  if(writable){
  102e7a:	85 f6                	test   %esi,%esi
  102e7c:	74 42                	je     102ec0 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
  102e7e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
void
pipeclose(struct pipe *p, int writable)
{
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
  102e84:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
  102e8b:	00 00 00 
    wakeup(&p->nread);
  102e8e:	89 04 24             	mov    %eax,(%esp)
  102e91:	e8 aa 02 00 00       	call   103140 <wakeup>
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
  102e96:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102e9c:	85 c0                	test   %eax,%eax
  102e9e:	75 0a                	jne    102eaa <pipeclose+0x4a>
  102ea0:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102ea6:	85 f6                	test   %esi,%esi
  102ea8:	74 36                	je     102ee0 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102eaa:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  102ead:	8b 75 fc             	mov    -0x4(%ebp),%esi
  102eb0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102eb3:	89 ec                	mov    %ebp,%esp
  102eb5:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102eb6:	e9 35 0c 00 00       	jmp    103af0 <release>
  102ebb:	90                   	nop
  102ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  102ec0:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
  102ec6:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
  102ecd:	00 00 00 
    wakeup(&p->nwrite);
  102ed0:	89 04 24             	mov    %eax,(%esp)
  102ed3:	e8 68 02 00 00       	call   103140 <wakeup>
  102ed8:	eb bc                	jmp    102e96 <pipeclose+0x36>
  102eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
  102ee0:	89 1c 24             	mov    %ebx,(%esp)
  102ee3:	e8 08 0c 00 00       	call   103af0 <release>
    kfree((char*)p);
  } else
    release(&p->lock);
}
  102ee8:	8b 75 fc             	mov    -0x4(%ebp),%esi
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102eeb:	89 5d 08             	mov    %ebx,0x8(%ebp)
  } else
    release(&p->lock);
}
  102eee:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102ef1:	89 ec                	mov    %ebp,%esp
  102ef3:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102ef4:	e9 a7 f3 ff ff       	jmp    1022a0 <kfree>
  102ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102f00 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
  102f00:	55                   	push   %ebp
  102f01:	89 e5                	mov    %esp,%ebp
  102f03:	57                   	push   %edi
  102f04:	56                   	push   %esi
  102f05:	53                   	push   %ebx
  102f06:	83 ec 1c             	sub    $0x1c,%esp
  102f09:	8b 75 08             	mov    0x8(%ebp),%esi
  102f0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
  102f0f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  102f15:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
  102f1b:	e8 e0 df ff ff       	call   100f00 <filealloc>
  102f20:	85 c0                	test   %eax,%eax
  102f22:	89 06                	mov    %eax,(%esi)
  102f24:	0f 84 9c 00 00 00    	je     102fc6 <pipealloc+0xc6>
  102f2a:	e8 d1 df ff ff       	call   100f00 <filealloc>
  102f2f:	85 c0                	test   %eax,%eax
  102f31:	89 03                	mov    %eax,(%ebx)
  102f33:	0f 84 7f 00 00 00    	je     102fb8 <pipealloc+0xb8>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
  102f39:	e8 22 f3 ff ff       	call   102260 <kalloc>
  102f3e:	85 c0                	test   %eax,%eax
  102f40:	89 c7                	mov    %eax,%edi
  102f42:	74 74                	je     102fb8 <pipealloc+0xb8>
    goto bad;
  p->readopen = 1;
  102f44:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
  102f4b:	00 00 00 
  p->writeopen = 1;
  102f4e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
  102f55:	00 00 00 
  p->nwrite = 0;
  102f58:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
  102f5f:	00 00 00 
  p->nread = 0;
  102f62:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
  102f69:	00 00 00 
  initlock(&p->lock, "pipe");
  102f6c:	89 04 24             	mov    %eax,(%esp)
  102f6f:	c7 44 24 04 8c 69 10 	movl   $0x10698c,0x4(%esp)
  102f76:	00 
  102f77:	e8 34 0a 00 00       	call   1039b0 <initlock>
  (*f0)->type = FD_PIPE;
  102f7c:	8b 06                	mov    (%esi),%eax
  102f7e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
  102f84:	8b 06                	mov    (%esi),%eax
  102f86:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
  102f8a:	8b 06                	mov    (%esi),%eax
  102f8c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
  102f90:	8b 06                	mov    (%esi),%eax
  102f92:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
  102f95:	8b 03                	mov    (%ebx),%eax
  102f97:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
  102f9d:	8b 03                	mov    (%ebx),%eax
  102f9f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
  102fa3:	8b 03                	mov    (%ebx),%eax
  102fa5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
  102fa9:	8b 03                	mov    (%ebx),%eax
  102fab:	89 78 0c             	mov    %edi,0xc(%eax)
  102fae:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
  102fb0:	83 c4 1c             	add    $0x1c,%esp
  102fb3:	5b                   	pop    %ebx
  102fb4:	5e                   	pop    %esi
  102fb5:	5f                   	pop    %edi
  102fb6:	5d                   	pop    %ebp
  102fb7:	c3                   	ret    
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
  102fb8:	8b 06                	mov    (%esi),%eax
  102fba:	85 c0                	test   %eax,%eax
  102fbc:	74 08                	je     102fc6 <pipealloc+0xc6>
    fileclose(*f0);
  102fbe:	89 04 24             	mov    %eax,(%esp)
  102fc1:	e8 ba df ff ff       	call   100f80 <fileclose>
  if(*f1)
  102fc6:	8b 13                	mov    (%ebx),%edx
  102fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102fcd:	85 d2                	test   %edx,%edx
  102fcf:	74 df                	je     102fb0 <pipealloc+0xb0>
    fileclose(*f1);
  102fd1:	89 14 24             	mov    %edx,(%esp)
  102fd4:	e8 a7 df ff ff       	call   100f80 <fileclose>
  102fd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102fde:	eb d0                	jmp    102fb0 <pipealloc+0xb0>

00102fe0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  102fe0:	55                   	push   %ebp
  102fe1:	89 e5                	mov    %esp,%ebp
  102fe3:	57                   	push   %edi
  102fe4:	56                   	push   %esi
  102fe5:	53                   	push   %ebx

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
  102fe6:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
{
  102feb:	83 ec 4c             	sub    $0x4c,%esp
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  102fee:	8d 7d c0             	lea    -0x40(%ebp),%edi
  102ff1:	eb 4b                	jmp    10303e <procdump+0x5e>
  102ff3:	90                   	nop
  102ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  102ff8:	8b 04 85 64 6a 10 00 	mov    0x106a64(,%eax,4),%eax
  102fff:	85 c0                	test   %eax,%eax
  103001:	74 47                	je     10304a <procdump+0x6a>
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
  103003:	8b 53 10             	mov    0x10(%ebx),%edx
  103006:	8d 4b 6c             	lea    0x6c(%ebx),%ecx
  103009:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10300d:	89 44 24 08          	mov    %eax,0x8(%esp)
  103011:	c7 04 24 95 69 10 00 	movl   $0x106995,(%esp)
  103018:	89 54 24 04          	mov    %edx,0x4(%esp)
  10301c:	e8 0f d5 ff ff       	call   100530 <cprintf>
    if(p->state == SLEEPING){
  103021:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
  103025:	74 31                	je     103058 <procdump+0x78>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  103027:	c7 04 24 16 69 10 00 	movl   $0x106916,(%esp)
  10302e:	e8 fd d4 ff ff       	call   100530 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103033:	83 c3 7c             	add    $0x7c,%ebx
  103036:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  10303c:	74 5a                	je     103098 <procdump+0xb8>
    if(p->state == UNUSED)
  10303e:	8b 43 0c             	mov    0xc(%ebx),%eax
  103041:	85 c0                	test   %eax,%eax
  103043:	74 ee                	je     103033 <procdump+0x53>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  103045:	83 f8 05             	cmp    $0x5,%eax
  103048:	76 ae                	jbe    102ff8 <procdump+0x18>
  10304a:	b8 91 69 10 00       	mov    $0x106991,%eax
  10304f:	eb b2                	jmp    103003 <procdump+0x23>
  103051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  103058:	8b 43 1c             	mov    0x1c(%ebx),%eax
  10305b:	31 f6                	xor    %esi,%esi
  10305d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  103061:	8b 40 0c             	mov    0xc(%eax),%eax
  103064:	83 c0 08             	add    $0x8,%eax
  103067:	89 04 24             	mov    %eax,(%esp)
  10306a:	e8 61 09 00 00       	call   1039d0 <getcallerpcs>
  10306f:	90                   	nop
      for(i=0; i<10 && pc[i] != 0; i++)
  103070:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  103073:	85 c0                	test   %eax,%eax
  103075:	74 b0                	je     103027 <procdump+0x47>
  103077:	83 c6 01             	add    $0x1,%esi
        cprintf(" %p", pc[i]);
  10307a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10307e:	c7 04 24 0a 65 10 00 	movl   $0x10650a,(%esp)
  103085:	e8 a6 d4 ff ff       	call   100530 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
  10308a:	83 fe 0a             	cmp    $0xa,%esi
  10308d:	75 e1                	jne    103070 <procdump+0x90>
  10308f:	eb 96                	jmp    103027 <procdump+0x47>
  103091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
  103098:	83 c4 4c             	add    $0x4c,%esp
  10309b:	5b                   	pop    %ebx
  10309c:	5e                   	pop    %esi
  10309d:	5f                   	pop    %edi
  10309e:	5d                   	pop    %ebp
  10309f:	90                   	nop
  1030a0:	c3                   	ret    
  1030a1:	eb 0d                	jmp    1030b0 <kill>
  1030a3:	90                   	nop
  1030a4:	90                   	nop
  1030a5:	90                   	nop
  1030a6:	90                   	nop
  1030a7:	90                   	nop
  1030a8:	90                   	nop
  1030a9:	90                   	nop
  1030aa:	90                   	nop
  1030ab:	90                   	nop
  1030ac:	90                   	nop
  1030ad:	90                   	nop
  1030ae:	90                   	nop
  1030af:	90                   	nop

001030b0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  1030b0:	55                   	push   %ebp
  1030b1:	89 e5                	mov    %esp,%ebp
  1030b3:	53                   	push   %ebx
  1030b4:	83 ec 14             	sub    $0x14,%esp
  1030b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
  1030ba:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1030c1:	e8 7a 0a 00 00       	call   103b40 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  1030c6:	8b 15 64 c1 10 00    	mov    0x10c164,%edx

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
  1030cc:	b8 d0 c1 10 00       	mov    $0x10c1d0,%eax
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  1030d1:	39 da                	cmp    %ebx,%edx
  1030d3:	75 0d                	jne    1030e2 <kill+0x32>
  1030d5:	eb 60                	jmp    103137 <kill+0x87>
  1030d7:	90                   	nop
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1030d8:	83 c0 7c             	add    $0x7c,%eax
  1030db:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  1030e0:	74 3e                	je     103120 <kill+0x70>
    if(p->pid == pid){
  1030e2:	8b 50 10             	mov    0x10(%eax),%edx
  1030e5:	39 da                	cmp    %ebx,%edx
  1030e7:	75 ef                	jne    1030d8 <kill+0x28>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  1030e9:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
  1030ed:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  1030f4:	74 1a                	je     103110 <kill+0x60>
        p->state = RUNNABLE;
      release(&ptable.lock);
  1030f6:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1030fd:	e8 ee 09 00 00       	call   103af0 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  103102:	83 c4 14             	add    $0x14,%esp
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
  103105:	31 c0                	xor    %eax,%eax
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  103107:	5b                   	pop    %ebx
  103108:	5d                   	pop    %ebp
  103109:	c3                   	ret    
  10310a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
  103110:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  103117:	eb dd                	jmp    1030f6 <kill+0x46>
  103119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  103120:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103127:	e8 c4 09 00 00       	call   103af0 <release>
  return -1;
}
  10312c:	83 c4 14             	add    $0x14,%esp
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  10312f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
  103134:	5b                   	pop    %ebx
  103135:	5d                   	pop    %ebp
  103136:	c3                   	ret    
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  103137:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  10313c:	eb ab                	jmp    1030e9 <kill+0x39>
  10313e:	66 90                	xchg   %ax,%ax

00103140 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  103140:	55                   	push   %ebp
  103141:	89 e5                	mov    %esp,%ebp
  103143:	53                   	push   %ebx
  103144:	83 ec 14             	sub    $0x14,%esp
  103147:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
  10314a:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103151:	e8 ea 09 00 00       	call   103b40 <acquire>
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
  103156:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  10315b:	eb 0d                	jmp    10316a <wakeup+0x2a>
  10315d:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103160:	83 c0 7c             	add    $0x7c,%eax
  103163:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  103168:	74 1e                	je     103188 <wakeup+0x48>
    if(p->state == SLEEPING && p->chan == chan)
  10316a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  10316e:	75 f0                	jne    103160 <wakeup+0x20>
  103170:	3b 58 20             	cmp    0x20(%eax),%ebx
  103173:	75 eb                	jne    103160 <wakeup+0x20>
      p->state = RUNNABLE;
  103175:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  10317c:	83 c0 7c             	add    $0x7c,%eax
  10317f:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  103184:	75 e4                	jne    10316a <wakeup+0x2a>
  103186:	66 90                	xchg   %ax,%ax
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  103188:	c7 45 08 20 c1 10 00 	movl   $0x10c120,0x8(%ebp)
}
  10318f:	83 c4 14             	add    $0x14,%esp
  103192:	5b                   	pop    %ebx
  103193:	5d                   	pop    %ebp
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  103194:	e9 57 09 00 00       	jmp    103af0 <release>
  103199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001031a0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  1031a0:	55                   	push   %ebp
  1031a1:	89 e5                	mov    %esp,%ebp
  1031a3:	83 ec 18             	sub    $0x18,%esp
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
  1031a6:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1031ad:	e8 3e 09 00 00       	call   103af0 <release>
  
  // Return to "caller", actually trapret (see allocproc).
}
  1031b2:	c9                   	leave  
  1031b3:	c3                   	ret    
  1031b4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1031ba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001031c0 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  1031c0:	55                   	push   %ebp
  1031c1:	89 e5                	mov    %esp,%ebp
  1031c3:	53                   	push   %ebx
  1031c4:	83 ec 14             	sub    $0x14,%esp
  int intena;

  if(!holding(&ptable.lock))
  1031c7:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1031ce:	e8 5d 08 00 00       	call   103a30 <holding>
  1031d3:	85 c0                	test   %eax,%eax
  1031d5:	74 4d                	je     103224 <sched+0x64>
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
  1031d7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1031dd:	83 b8 ac 00 00 00 01 	cmpl   $0x1,0xac(%eax)
  1031e4:	75 62                	jne    103248 <sched+0x88>
    panic("sched locks");
  if(proc->state == RUNNING)
  1031e6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  1031ed:	83 7a 0c 04          	cmpl   $0x4,0xc(%edx)
  1031f1:	74 49                	je     10323c <sched+0x7c>

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  1031f3:	9c                   	pushf  
  1031f4:	59                   	pop    %ecx
    panic("sched running");
  if(readeflags()&FL_IF)
  1031f5:	80 e5 02             	and    $0x2,%ch
  1031f8:	75 36                	jne    103230 <sched+0x70>
    panic("sched interruptible");
  intena = cpu->intena;
  1031fa:	8b 98 b0 00 00 00    	mov    0xb0(%eax),%ebx
  swtch(&proc->context, cpu->scheduler);
  103200:	83 c2 1c             	add    $0x1c,%edx
  103203:	8b 40 04             	mov    0x4(%eax),%eax
  103206:	89 14 24             	mov    %edx,(%esp)
  103209:	89 44 24 04          	mov    %eax,0x4(%esp)
  10320d:	e8 ca 0b 00 00       	call   103ddc <swtch>
  cpu->intena = intena;
  103212:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103218:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  10321e:	83 c4 14             	add    $0x14,%esp
  103221:	5b                   	pop    %ebx
  103222:	5d                   	pop    %ebp
  103223:	c3                   	ret    
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  103224:	c7 04 24 9e 69 10 00 	movl   $0x10699e,(%esp)
  10322b:	e8 f0 d6 ff ff       	call   100920 <panic>
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  103230:	c7 04 24 ca 69 10 00 	movl   $0x1069ca,(%esp)
  103237:	e8 e4 d6 ff ff       	call   100920 <panic>
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  10323c:	c7 04 24 bc 69 10 00 	movl   $0x1069bc,(%esp)
  103243:	e8 d8 d6 ff ff       	call   100920 <panic>
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  103248:	c7 04 24 b0 69 10 00 	movl   $0x1069b0,(%esp)
  10324f:	e8 cc d6 ff ff       	call   100920 <panic>
  103254:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10325a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103260 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  103260:	55                   	push   %ebp
  103261:	89 e5                	mov    %esp,%ebp
  103263:	56                   	push   %esi
  103264:	53                   	push   %ebx
  103265:	83 ec 10             	sub    $0x10,%esp
  if(proc == 0)
  103268:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  10326e:	8b 75 08             	mov    0x8(%ebp),%esi
  103271:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
  103274:	85 c0                	test   %eax,%eax
  103276:	0f 84 a1 00 00 00    	je     10331d <sleep+0xbd>
    panic("sleep");

  if(lk == 0)
  10327c:	85 db                	test   %ebx,%ebx
  10327e:	0f 84 8d 00 00 00    	je     103311 <sleep+0xb1>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
  103284:	81 fb 20 c1 10 00    	cmp    $0x10c120,%ebx
  10328a:	74 5c                	je     1032e8 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
  10328c:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103293:	e8 a8 08 00 00       	call   103b40 <acquire>
    release(lk);
  103298:	89 1c 24             	mov    %ebx,(%esp)
  10329b:	e8 50 08 00 00       	call   103af0 <release>
  }

  // Go to sleep.
  proc->chan = chan;
  1032a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032a6:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  1032a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032af:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  1032b6:	e8 05 ff ff ff       	call   1031c0 <sched>

  // Tidy up.
  proc->chan = 0;
  1032bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032c1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
  1032c8:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1032cf:	e8 1c 08 00 00       	call   103af0 <release>
    acquire(lk);
  1032d4:	89 5d 08             	mov    %ebx,0x8(%ebp)
  }
}
  1032d7:	83 c4 10             	add    $0x10,%esp
  1032da:	5b                   	pop    %ebx
  1032db:	5e                   	pop    %esi
  1032dc:	5d                   	pop    %ebp
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  1032dd:	e9 5e 08 00 00       	jmp    103b40 <acquire>
  1032e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  1032e8:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  1032eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032f1:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  1032f8:	e8 c3 fe ff ff       	call   1031c0 <sched>

  // Tidy up.
  proc->chan = 0;
  1032fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103303:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}
  10330a:	83 c4 10             	add    $0x10,%esp
  10330d:	5b                   	pop    %ebx
  10330e:	5e                   	pop    %esi
  10330f:	5d                   	pop    %ebp
  103310:	c3                   	ret    
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");
  103311:	c7 04 24 e4 69 10 00 	movl   $0x1069e4,(%esp)
  103318:	e8 03 d6 ff ff       	call   100920 <panic>
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");
  10331d:	c7 04 24 de 69 10 00 	movl   $0x1069de,(%esp)
  103324:	e8 f7 d5 ff ff       	call   100920 <panic>
  103329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103330 <yield>:
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  103330:	55                   	push   %ebp
  103331:	89 e5                	mov    %esp,%ebp
  103333:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
  103336:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10333d:	e8 fe 07 00 00       	call   103b40 <acquire>
  proc->state = RUNNABLE;
  103342:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103348:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
  10334f:	e8 6c fe ff ff       	call   1031c0 <sched>
  release(&ptable.lock);
  103354:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10335b:	e8 90 07 00 00       	call   103af0 <release>
}
  103360:	c9                   	leave  
  103361:	c3                   	ret    
  103362:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  103369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103370 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  103370:	55                   	push   %ebp
  103371:	89 e5                	mov    %esp,%ebp
  103373:	53                   	push   %ebx
  103374:	83 ec 14             	sub    $0x14,%esp
  103377:	90                   	nop
}

static inline void
sti(void)
{
  asm volatile("sti");
  103378:	fb                   	sti    
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
  103379:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
  10337e:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103385:	e8 b6 07 00 00       	call   103b40 <acquire>
  10338a:	eb 0f                	jmp    10339b <scheduler+0x2b>
  10338c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103390:	83 c3 7c             	add    $0x7c,%ebx
  103393:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103399:	74 5d                	je     1033f8 <scheduler+0x88>
      if(p->state != RUNNABLE)
  10339b:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
  10339f:	90                   	nop
  1033a0:	75 ee                	jne    103390 <scheduler+0x20>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
  1033a2:	65 89 1d 04 00 00 00 	mov    %ebx,%gs:0x4
      switchuvm(p);
  1033a9:	89 1c 24             	mov    %ebx,(%esp)
  1033ac:	e8 2f 2f 00 00       	call   1062e0 <switchuvm>
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  1033b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
  1033b7:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1033be:	83 c3 7c             	add    $0x7c,%ebx
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  1033c1:	8b 40 1c             	mov    0x1c(%eax),%eax
  1033c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033c8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1033ce:	83 c0 04             	add    $0x4,%eax
  1033d1:	89 04 24             	mov    %eax,(%esp)
  1033d4:	e8 03 0a 00 00       	call   103ddc <swtch>
      switchkvm();
  1033d9:	e8 92 28 00 00       	call   105c70 <switchkvm>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1033de:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
  1033e4:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  1033eb:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1033ef:	75 aa                	jne    10339b <scheduler+0x2b>
  1033f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
  1033f8:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1033ff:	e8 ec 06 00 00       	call   103af0 <release>

  }
  103404:	e9 6f ff ff ff       	jmp    103378 <scheduler+0x8>
  103409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103410 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103410:	55                   	push   %ebp
  103411:	89 e5                	mov    %esp,%ebp
  103413:	53                   	push   %ebx
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  103414:	bb 54 c1 10 00       	mov    $0x10c154,%ebx

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103419:	83 ec 24             	sub    $0x24,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  10341c:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103423:	e8 18 07 00 00       	call   103b40 <acquire>
  103428:	31 c0                	xor    %eax,%eax
  10342a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103430:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103436:	72 30                	jb     103468 <wait+0x58>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
  103438:	85 c0                	test   %eax,%eax
  10343a:	74 5c                	je     103498 <wait+0x88>
  10343c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103442:	8b 50 24             	mov    0x24(%eax),%edx
  103445:	85 d2                	test   %edx,%edx
  103447:	75 4f                	jne    103498 <wait+0x88>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  103449:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  10344e:	89 04 24             	mov    %eax,(%esp)
  103451:	c7 44 24 04 20 c1 10 	movl   $0x10c120,0x4(%esp)
  103458:	00 
  103459:	e8 02 fe ff ff       	call   103260 <sleep>
  10345e:	31 c0                	xor    %eax,%eax

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103460:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103466:	73 d0                	jae    103438 <wait+0x28>
      if(p->parent != proc)
  103468:	8b 53 14             	mov    0x14(%ebx),%edx
  10346b:	65 3b 15 04 00 00 00 	cmp    %gs:0x4,%edx
  103472:	74 0c                	je     103480 <wait+0x70>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103474:	83 c3 7c             	add    $0x7c,%ebx
  103477:	eb b7                	jmp    103430 <wait+0x20>
  103479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
  103480:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
  103484:	74 29                	je     1034af <wait+0x9f>
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
  103486:	b8 01 00 00 00       	mov    $0x1,%eax
  10348b:	90                   	nop
  10348c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103490:	eb e2                	jmp    103474 <wait+0x64>
  103492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
  103498:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10349f:	e8 4c 06 00 00       	call   103af0 <release>
  1034a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
  1034a9:	83 c4 24             	add    $0x24,%esp
  1034ac:	5b                   	pop    %ebx
  1034ad:	5d                   	pop    %ebp
  1034ae:	c3                   	ret    
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
  1034af:	8b 43 10             	mov    0x10(%ebx),%eax
        kfree(p->kstack);
  1034b2:	8b 53 08             	mov    0x8(%ebx),%edx
  1034b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1034b8:	89 14 24             	mov    %edx,(%esp)
  1034bb:	e8 e0 ed ff ff       	call   1022a0 <kfree>
        p->kstack = 0;
        freevm(p->pgdir);
  1034c0:	8b 53 04             	mov    0x4(%ebx),%edx
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
  1034c3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
  1034ca:	89 14 24             	mov    %edx,(%esp)
  1034cd:	e8 3e 2b 00 00       	call   106010 <freevm>
        p->state = UNUSED;
  1034d2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->pid = 0;
  1034d9:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
  1034e0:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
  1034e7:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
  1034eb:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        release(&ptable.lock);
  1034f2:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1034f9:	e8 f2 05 00 00       	call   103af0 <release>
        return pid;
  1034fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103501:	eb a6                	jmp    1034a9 <wait+0x99>
  103503:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103509:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103510 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  103510:	55                   	push   %ebp
  103511:	89 e5                	mov    %esp,%ebp
  103513:	56                   	push   %esi
  103514:	53                   	push   %ebx
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  103515:	31 db                	xor    %ebx,%ebx
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  103517:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
  10351a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103521:	3b 15 c8 78 10 00    	cmp    0x1078c8,%edx
  103527:	0f 84 fd 00 00 00    	je     10362a <exit+0x11a>
  10352d:	8d 76 00             	lea    0x0(%esi),%esi
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
  103530:	8d 73 08             	lea    0x8(%ebx),%esi
  103533:	8b 44 b2 08          	mov    0x8(%edx,%esi,4),%eax
  103537:	85 c0                	test   %eax,%eax
  103539:	74 1d                	je     103558 <exit+0x48>
      fileclose(proc->ofile[fd]);
  10353b:	89 04 24             	mov    %eax,(%esp)
  10353e:	e8 3d da ff ff       	call   100f80 <fileclose>
      proc->ofile[fd] = 0;
  103543:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103549:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
  103550:	00 
  103551:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
  103558:	83 c3 01             	add    $0x1,%ebx
  10355b:	83 fb 10             	cmp    $0x10,%ebx
  10355e:	75 d0                	jne    103530 <exit+0x20>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
  103560:	8b 42 68             	mov    0x68(%edx),%eax
  103563:	89 04 24             	mov    %eax,(%esp)
  103566:	e8 15 e3 ff ff       	call   101880 <iput>
  proc->cwd = 0;
  10356b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103571:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
  103578:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10357f:	e8 bc 05 00 00       	call   103b40 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  103584:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
  10358b:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  103590:	8b 51 14             	mov    0x14(%ecx),%edx
  103593:	eb 0d                	jmp    1035a2 <exit+0x92>
  103595:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103598:	83 c0 7c             	add    $0x7c,%eax
  10359b:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  1035a0:	74 1c                	je     1035be <exit+0xae>
    if(p->state == SLEEPING && p->chan == chan)
  1035a2:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  1035a6:	75 f0                	jne    103598 <exit+0x88>
  1035a8:	3b 50 20             	cmp    0x20(%eax),%edx
  1035ab:	75 eb                	jne    103598 <exit+0x88>
      p->state = RUNNABLE;
  1035ad:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1035b4:	83 c0 7c             	add    $0x7c,%eax
  1035b7:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  1035bc:	75 e4                	jne    1035a2 <exit+0x92>
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  1035be:	8b 1d c8 78 10 00    	mov    0x1078c8,%ebx
  1035c4:	ba 54 c1 10 00       	mov    $0x10c154,%edx
  1035c9:	eb 10                	jmp    1035db <exit+0xcb>
  1035cb:	90                   	nop
  1035cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1035d0:	83 c2 7c             	add    $0x7c,%edx
  1035d3:	81 fa 54 e0 10 00    	cmp    $0x10e054,%edx
  1035d9:	74 37                	je     103612 <exit+0x102>
    if(p->parent == proc){
  1035db:	3b 4a 14             	cmp    0x14(%edx),%ecx
  1035de:	75 f0                	jne    1035d0 <exit+0xc0>
      p->parent = initproc;
      if(p->state == ZOMBIE)
  1035e0:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  1035e4:	89 5a 14             	mov    %ebx,0x14(%edx)
      if(p->state == ZOMBIE)
  1035e7:	75 e7                	jne    1035d0 <exit+0xc0>
  1035e9:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  1035ee:	eb 0a                	jmp    1035fa <exit+0xea>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1035f0:	83 c0 7c             	add    $0x7c,%eax
  1035f3:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  1035f8:	74 d6                	je     1035d0 <exit+0xc0>
    if(p->state == SLEEPING && p->chan == chan)
  1035fa:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  1035fe:	75 f0                	jne    1035f0 <exit+0xe0>
  103600:	3b 58 20             	cmp    0x20(%eax),%ebx
  103603:	75 eb                	jne    1035f0 <exit+0xe0>
      p->state = RUNNABLE;
  103605:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  10360c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103610:	eb de                	jmp    1035f0 <exit+0xe0>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  103612:	c7 41 0c 05 00 00 00 	movl   $0x5,0xc(%ecx)
  sched();
  103619:	e8 a2 fb ff ff       	call   1031c0 <sched>
  panic("zombie exit");
  10361e:	c7 04 24 02 6a 10 00 	movl   $0x106a02,(%esp)
  103625:	e8 f6 d2 ff ff       	call   100920 <panic>
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  10362a:	c7 04 24 f5 69 10 00 	movl   $0x1069f5,(%esp)
  103631:	e8 ea d2 ff ff       	call   100920 <panic>
  103636:	8d 76 00             	lea    0x0(%esi),%esi
  103639:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103640 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  103640:	55                   	push   %ebp
  103641:	89 e5                	mov    %esp,%ebp
  103643:	53                   	push   %ebx
  103644:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  103647:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10364e:	e8 ed 04 00 00       	call   103b40 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
  103653:	8b 1d 60 c1 10 00    	mov    0x10c160,%ebx
  103659:	85 db                	test   %ebx,%ebx
  10365b:	0f 84 a5 00 00 00    	je     103706 <allocproc+0xc6>
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
  103661:	bb d0 c1 10 00       	mov    $0x10c1d0,%ebx
  103666:	eb 0b                	jmp    103673 <allocproc+0x33>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103668:	83 c3 7c             	add    $0x7c,%ebx
  10366b:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103671:	74 7d                	je     1036f0 <allocproc+0xb0>
    if(p->state == UNUSED)
  103673:	8b 4b 0c             	mov    0xc(%ebx),%ecx
  103676:	85 c9                	test   %ecx,%ecx
  103678:	75 ee                	jne    103668 <allocproc+0x28>
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  10367a:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
  103681:	a1 24 73 10 00       	mov    0x107324,%eax
  103686:	89 43 10             	mov    %eax,0x10(%ebx)
  103689:	83 c0 01             	add    $0x1,%eax
  10368c:	a3 24 73 10 00       	mov    %eax,0x107324
  release(&ptable.lock);
  103691:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103698:	e8 53 04 00 00       	call   103af0 <release>

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
  10369d:	e8 be eb ff ff       	call   102260 <kalloc>
  1036a2:	85 c0                	test   %eax,%eax
  1036a4:	89 43 08             	mov    %eax,0x8(%ebx)
  1036a7:	74 67                	je     103710 <allocproc+0xd0>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  1036a9:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
  1036af:	89 53 18             	mov    %edx,0x18(%ebx)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
  1036b2:	c7 80 b0 0f 00 00 50 	movl   $0x104d50,0xfb0(%eax)
  1036b9:	4d 10 00 

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  1036bc:	05 9c 0f 00 00       	add    $0xf9c,%eax
  1036c1:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
  1036c4:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  1036cb:	00 
  1036cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1036d3:	00 
  1036d4:	89 04 24             	mov    %eax,(%esp)
  1036d7:	e8 04 05 00 00       	call   103be0 <memset>
  p->context->eip = (uint)forkret;
  1036dc:	8b 43 1c             	mov    0x1c(%ebx),%eax
  1036df:	c7 40 10 a0 31 10 00 	movl   $0x1031a0,0x10(%eax)

  return p;
}
  1036e6:	89 d8                	mov    %ebx,%eax
  1036e8:	83 c4 14             	add    $0x14,%esp
  1036eb:	5b                   	pop    %ebx
  1036ec:	5d                   	pop    %ebp
  1036ed:	c3                   	ret    
  1036ee:	66 90                	xchg   %ax,%ax

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  1036f0:	31 db                	xor    %ebx,%ebx
  1036f2:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1036f9:	e8 f2 03 00 00       	call   103af0 <release>
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}
  1036fe:	89 d8                	mov    %ebx,%eax
  103700:	83 c4 14             	add    $0x14,%esp
  103703:	5b                   	pop    %ebx
  103704:	5d                   	pop    %ebp
  103705:	c3                   	ret    
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;
  103706:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  10370b:	e9 6a ff ff ff       	jmp    10367a <allocproc+0x3a>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
  103710:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  103717:	31 db                	xor    %ebx,%ebx
    return 0;
  103719:	eb cb                	jmp    1036e6 <allocproc+0xa6>
  10371b:	90                   	nop
  10371c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103720 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  103720:	55                   	push   %ebp
  103721:	89 e5                	mov    %esp,%ebp
  103723:	57                   	push   %edi
  103724:	56                   	push   %esi
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  103725:	be ff ff ff ff       	mov    $0xffffffff,%esi
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  10372a:	53                   	push   %ebx
  10372b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  10372e:	e8 0d ff ff ff       	call   103640 <allocproc>
  103733:	85 c0                	test   %eax,%eax
  103735:	89 c3                	mov    %eax,%ebx
  103737:	0f 84 be 00 00 00    	je     1037fb <fork+0xdb>
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
  10373d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103743:	8b 10                	mov    (%eax),%edx
  103745:	89 54 24 04          	mov    %edx,0x4(%esp)
  103749:	8b 40 04             	mov    0x4(%eax),%eax
  10374c:	89 04 24             	mov    %eax,(%esp)
  10374f:	e8 3c 29 00 00       	call   106090 <copyuvm>
  103754:	85 c0                	test   %eax,%eax
  103756:	89 43 04             	mov    %eax,0x4(%ebx)
  103759:	0f 84 a6 00 00 00    	je     103805 <fork+0xe5>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  10375f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  np->parent = proc;
  *np->tf = *proc->tf;
  103765:	b9 13 00 00 00       	mov    $0x13,%ecx
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  10376a:	8b 00                	mov    (%eax),%eax
  10376c:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
  10376e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103774:	89 43 14             	mov    %eax,0x14(%ebx)
  *np->tf = *proc->tf;
  103777:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10377e:	8b 43 18             	mov    0x18(%ebx),%eax
  103781:	8b 72 18             	mov    0x18(%edx),%esi
  103784:	89 c7                	mov    %eax,%edi
  103786:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
  103788:	31 f6                	xor    %esi,%esi
  10378a:	8b 43 18             	mov    0x18(%ebx),%eax
  10378d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  103794:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10379b:	90                   	nop
  10379c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
  1037a0:	8b 44 b2 28          	mov    0x28(%edx,%esi,4),%eax
  1037a4:	85 c0                	test   %eax,%eax
  1037a6:	74 13                	je     1037bb <fork+0x9b>
      np->ofile[i] = filedup(proc->ofile[i]);
  1037a8:	89 04 24             	mov    %eax,(%esp)
  1037ab:	e8 00 d7 ff ff       	call   100eb0 <filedup>
  1037b0:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
  1037b4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
  1037bb:	83 c6 01             	add    $0x1,%esi
  1037be:	83 fe 10             	cmp    $0x10,%esi
  1037c1:	75 dd                	jne    1037a0 <fork+0x80>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1037c3:	8b 42 68             	mov    0x68(%edx),%eax
  1037c6:	89 04 24             	mov    %eax,(%esp)
  1037c9:	e8 e2 d8 ff ff       	call   1010b0 <idup>
 
  pid = np->pid;
  1037ce:	8b 73 10             	mov    0x10(%ebx),%esi
  np->state = RUNNABLE;
  1037d1:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1037d8:	89 43 68             	mov    %eax,0x68(%ebx)
 
  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  1037db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1037e1:	83 c3 6c             	add    $0x6c,%ebx
  1037e4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  1037eb:	00 
  1037ec:	89 1c 24             	mov    %ebx,(%esp)
  1037ef:	83 c0 6c             	add    $0x6c,%eax
  1037f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1037f6:	e8 85 05 00 00       	call   103d80 <safestrcpy>
  return pid;
}
  1037fb:	83 c4 1c             	add    $0x1c,%esp
  1037fe:	89 f0                	mov    %esi,%eax
  103800:	5b                   	pop    %ebx
  103801:	5e                   	pop    %esi
  103802:	5f                   	pop    %edi
  103803:	5d                   	pop    %ebp
  103804:	c3                   	ret    
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
  103805:	8b 43 08             	mov    0x8(%ebx),%eax
  103808:	89 04 24             	mov    %eax,(%esp)
  10380b:	e8 90 ea ff ff       	call   1022a0 <kfree>
    np->kstack = 0;
  103810:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
  103817:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
  10381e:	eb db                	jmp    1037fb <fork+0xdb>

00103820 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  103820:	55                   	push   %ebp
  103821:	89 e5                	mov    %esp,%ebp
  103823:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
  103826:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  10382d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  uint sz;
  
  sz = proc->sz;
  103830:	8b 02                	mov    (%edx),%eax
  if(n > 0){
  103832:	83 f9 00             	cmp    $0x0,%ecx
  103835:	7f 19                	jg     103850 <growproc+0x30>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
  103837:	75 39                	jne    103872 <growproc+0x52>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  103839:	89 02                	mov    %eax,(%edx)
  switchuvm(proc);
  10383b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103841:	89 04 24             	mov    %eax,(%esp)
  103844:	e8 97 2a 00 00       	call   1062e0 <switchuvm>
  103849:	31 c0                	xor    %eax,%eax
  return 0;
}
  10384b:	c9                   	leave  
  10384c:	c3                   	ret    
  10384d:	8d 76 00             	lea    0x0(%esi),%esi
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
  103850:	01 c1                	add    %eax,%ecx
  103852:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103856:	89 44 24 04          	mov    %eax,0x4(%esp)
  10385a:	8b 42 04             	mov    0x4(%edx),%eax
  10385d:	89 04 24             	mov    %eax,(%esp)
  103860:	e8 eb 28 00 00       	call   106150 <allocuvm>
  103865:	85 c0                	test   %eax,%eax
  103867:	74 27                	je     103890 <growproc+0x70>
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
  103869:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103870:	eb c7                	jmp    103839 <growproc+0x19>
  103872:	01 c1                	add    %eax,%ecx
  103874:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103878:	89 44 24 04          	mov    %eax,0x4(%esp)
  10387c:	8b 42 04             	mov    0x4(%edx),%eax
  10387f:	89 04 24             	mov    %eax,(%esp)
  103882:	e8 f9 26 00 00       	call   105f80 <deallocuvm>
  103887:	85 c0                	test   %eax,%eax
  103889:	75 de                	jne    103869 <growproc+0x49>
  10388b:	90                   	nop
  10388c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
  103890:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  103895:	c9                   	leave  
  103896:	c3                   	ret    
  103897:	89 f6                	mov    %esi,%esi
  103899:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001038a0 <userinit>:
}

// Set up first user process.
void
userinit(void)
{
  1038a0:	55                   	push   %ebp
  1038a1:	89 e5                	mov    %esp,%ebp
  1038a3:	53                   	push   %ebx
  1038a4:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  1038a7:	e8 94 fd ff ff       	call   103640 <allocproc>
  1038ac:	89 c3                	mov    %eax,%ebx
  initproc = p;
  1038ae:	a3 c8 78 10 00       	mov    %eax,0x1078c8
  if((p->pgdir = setupkvm()) == 0)
  1038b3:	e8 98 25 00 00       	call   105e50 <setupkvm>
  1038b8:	85 c0                	test   %eax,%eax
  1038ba:	89 43 04             	mov    %eax,0x4(%ebx)
  1038bd:	0f 84 b6 00 00 00    	je     103979 <userinit+0xd9>
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  1038c3:	89 04 24             	mov    %eax,(%esp)
  1038c6:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
  1038cd:	00 
  1038ce:	c7 44 24 04 70 77 10 	movl   $0x107770,0x4(%esp)
  1038d5:	00 
  1038d6:	e8 15 26 00 00       	call   105ef0 <inituvm>
  p->sz = PGSIZE;
  1038db:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
  1038e1:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
  1038e8:	00 
  1038e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1038f0:	00 
  1038f1:	8b 43 18             	mov    0x18(%ebx),%eax
  1038f4:	89 04 24             	mov    %eax,(%esp)
  1038f7:	e8 e4 02 00 00       	call   103be0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  1038fc:	8b 43 18             	mov    0x18(%ebx),%eax
  1038ff:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  103905:	8b 43 18             	mov    0x18(%ebx),%eax
  103908:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
  10390e:	8b 43 18             	mov    0x18(%ebx),%eax
  103911:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103915:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
  103919:	8b 43 18             	mov    0x18(%ebx),%eax
  10391c:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103920:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
  103924:	8b 43 18             	mov    0x18(%ebx),%eax
  103927:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
  10392e:	8b 43 18             	mov    0x18(%ebx),%eax
  103931:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
  103938:	8b 43 18             	mov    0x18(%ebx),%eax
  10393b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
  103942:	8d 43 6c             	lea    0x6c(%ebx),%eax
  103945:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  10394c:	00 
  10394d:	c7 44 24 04 27 6a 10 	movl   $0x106a27,0x4(%esp)
  103954:	00 
  103955:	89 04 24             	mov    %eax,(%esp)
  103958:	e8 23 04 00 00       	call   103d80 <safestrcpy>
  p->cwd = namei("/");
  10395d:	c7 04 24 30 6a 10 00 	movl   $0x106a30,(%esp)
  103964:	e8 f7 e4 ff ff       	call   101e60 <namei>

  p->state = RUNNABLE;
  103969:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");
  103970:	89 43 68             	mov    %eax,0x68(%ebx)

  p->state = RUNNABLE;
}
  103973:	83 c4 14             	add    $0x14,%esp
  103976:	5b                   	pop    %ebx
  103977:	5d                   	pop    %ebp
  103978:	c3                   	ret    
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  103979:	c7 04 24 0e 6a 10 00 	movl   $0x106a0e,(%esp)
  103980:	e8 9b cf ff ff       	call   100920 <panic>
  103985:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103989:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103990 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
  103990:	55                   	push   %ebp
  103991:	89 e5                	mov    %esp,%ebp
  103993:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
  103996:	c7 44 24 04 32 6a 10 	movl   $0x106a32,0x4(%esp)
  10399d:	00 
  10399e:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1039a5:	e8 06 00 00 00       	call   1039b0 <initlock>
}
  1039aa:	c9                   	leave  
  1039ab:	c3                   	ret    
  1039ac:	90                   	nop
  1039ad:	90                   	nop
  1039ae:	90                   	nop
  1039af:	90                   	nop

001039b0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  1039b0:	55                   	push   %ebp
  1039b1:	89 e5                	mov    %esp,%ebp
  1039b3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
  1039b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
  1039b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
  1039bf:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
  lk->cpu = 0;
  1039c2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
  1039c9:	5d                   	pop    %ebp
  1039ca:	c3                   	ret    
  1039cb:	90                   	nop
  1039cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

001039d0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  1039d0:	55                   	push   %ebp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  1039d1:	31 c0                	xor    %eax,%eax
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  1039d3:	89 e5                	mov    %esp,%ebp
  1039d5:	53                   	push   %ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  1039d6:	8b 55 08             	mov    0x8(%ebp),%edx
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  1039d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  1039dc:	83 ea 08             	sub    $0x8,%edx
  1039df:	90                   	nop
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
  1039e0:	8d 8a 00 00 f0 ff    	lea    -0x100000(%edx),%ecx
  1039e6:	81 f9 fe ff ef ff    	cmp    $0xffeffffe,%ecx
  1039ec:	77 1a                	ja     103a08 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
  1039ee:	8b 4a 04             	mov    0x4(%edx),%ecx
  1039f1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  1039f4:	83 c0 01             	add    $0x1,%eax
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  1039f7:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  1039f9:	83 f8 0a             	cmp    $0xa,%eax
  1039fc:	75 e2                	jne    1039e0 <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
  1039fe:	5b                   	pop    %ebx
  1039ff:	5d                   	pop    %ebp
  103a00:	c3                   	ret    
  103a01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  103a08:	83 f8 09             	cmp    $0x9,%eax
  103a0b:	7f f1                	jg     1039fe <getcallerpcs+0x2e>
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  103a0d:	8d 14 83             	lea    (%ebx,%eax,4),%edx
  }
  for(; i < 10; i++)
  103a10:	83 c0 01             	add    $0x1,%eax
    pcs[i] = 0;
  103a13:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  103a19:	83 c2 04             	add    $0x4,%edx
  103a1c:	83 f8 0a             	cmp    $0xa,%eax
  103a1f:	75 ef                	jne    103a10 <getcallerpcs+0x40>
    pcs[i] = 0;
}
  103a21:	5b                   	pop    %ebx
  103a22:	5d                   	pop    %ebp
  103a23:	c3                   	ret    
  103a24:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103a2a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103a30 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103a30:	55                   	push   %ebp
  return lock->locked && lock->cpu == cpu;
  103a31:	31 c0                	xor    %eax,%eax
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103a33:	89 e5                	mov    %esp,%ebp
  103a35:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
  103a38:	8b 0a                	mov    (%edx),%ecx
  103a3a:	85 c9                	test   %ecx,%ecx
  103a3c:	74 10                	je     103a4e <holding+0x1e>
  103a3e:	8b 42 08             	mov    0x8(%edx),%eax
  103a41:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103a48:	0f 94 c0             	sete   %al
  103a4b:	0f b6 c0             	movzbl %al,%eax
}
  103a4e:	5d                   	pop    %ebp
  103a4f:	c3                   	ret    

00103a50 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
  103a50:	55                   	push   %ebp
  103a51:	89 e5                	mov    %esp,%ebp
  103a53:	53                   	push   %ebx

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103a54:	9c                   	pushf  
  103a55:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103a56:	fa                   	cli    
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103a57:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103a5e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103a64:	8d 48 01             	lea    0x1(%eax),%ecx
  103a67:	85 c0                	test   %eax,%eax
  103a69:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103a6f:	75 12                	jne    103a83 <pushcli+0x33>
    cpu->intena = eflags & FL_IF;
  103a71:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103a77:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103a7d:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  103a83:	5b                   	pop    %ebx
  103a84:	5d                   	pop    %ebp
  103a85:	c3                   	ret    
  103a86:	8d 76 00             	lea    0x0(%esi),%esi
  103a89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103a90 <popcli>:

void
popcli(void)
{
  103a90:	55                   	push   %ebp
  103a91:	89 e5                	mov    %esp,%ebp
  103a93:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103a96:	9c                   	pushf  
  103a97:	58                   	pop    %eax
  if(readeflags()&FL_IF)
  103a98:	f6 c4 02             	test   $0x2,%ah
  103a9b:	75 43                	jne    103ae0 <popcli+0x50>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
  103a9d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103aa4:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103aaa:	83 e8 01             	sub    $0x1,%eax
  103aad:	85 c0                	test   %eax,%eax
  103aaf:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
  103ab5:	78 1d                	js     103ad4 <popcli+0x44>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
  103ab7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103abd:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
  103ac3:	85 d2                	test   %edx,%edx
  103ac5:	75 0b                	jne    103ad2 <popcli+0x42>
  103ac7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  103acd:	85 c0                	test   %eax,%eax
  103acf:	74 01                	je     103ad2 <popcli+0x42>
}

static inline void
sti(void)
{
  asm volatile("sti");
  103ad1:	fb                   	sti    
    sti();
}
  103ad2:	c9                   	leave  
  103ad3:	c3                   	ret    
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
    panic("popcli");
  103ad4:	c7 04 24 93 6a 10 00 	movl   $0x106a93,(%esp)
  103adb:	e8 40 ce ff ff       	call   100920 <panic>

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  103ae0:	c7 04 24 7c 6a 10 00 	movl   $0x106a7c,(%esp)
  103ae7:	e8 34 ce ff ff       	call   100920 <panic>
  103aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103af0 <release>:
}

// Release the lock.
void
release(struct spinlock *lk)
{
  103af0:	55                   	push   %ebp
  103af1:	89 e5                	mov    %esp,%ebp
  103af3:	83 ec 18             	sub    $0x18,%esp
  103af6:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103af9:	8b 0a                	mov    (%edx),%ecx
  103afb:	85 c9                	test   %ecx,%ecx
  103afd:	74 0c                	je     103b0b <release+0x1b>
  103aff:	8b 42 08             	mov    0x8(%edx),%eax
  103b02:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103b09:	74 0d                	je     103b18 <release+0x28>
// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");
  103b0b:	c7 04 24 9a 6a 10 00 	movl   $0x106a9a,(%esp)
  103b12:	e8 09 ce ff ff       	call   100920 <panic>
  103b17:	90                   	nop

  lk->pcs[0] = 0;
  103b18:	c7 42 0c 00 00 00 00 	movl   $0x0,0xc(%edx)
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103b1f:	31 c0                	xor    %eax,%eax
  lk->cpu = 0;
  103b21:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
  103b28:	f0 87 02             	lock xchg %eax,(%edx)
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
}
  103b2b:	c9                   	leave  
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
  103b2c:	e9 5f ff ff ff       	jmp    103a90 <popcli>
  103b31:	eb 0d                	jmp    103b40 <acquire>
  103b33:	90                   	nop
  103b34:	90                   	nop
  103b35:	90                   	nop
  103b36:	90                   	nop
  103b37:	90                   	nop
  103b38:	90                   	nop
  103b39:	90                   	nop
  103b3a:	90                   	nop
  103b3b:	90                   	nop
  103b3c:	90                   	nop
  103b3d:	90                   	nop
  103b3e:	90                   	nop
  103b3f:	90                   	nop

00103b40 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  103b40:	55                   	push   %ebp
  103b41:	89 e5                	mov    %esp,%ebp
  103b43:	53                   	push   %ebx
  103b44:	83 ec 14             	sub    $0x14,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103b47:	9c                   	pushf  
  103b48:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103b49:	fa                   	cli    
{
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103b4a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103b51:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103b57:	8d 48 01             	lea    0x1(%eax),%ecx
  103b5a:	85 c0                	test   %eax,%eax
  103b5c:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103b62:	75 12                	jne    103b76 <acquire+0x36>
    cpu->intena = eflags & FL_IF;
  103b64:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103b6a:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103b70:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
  103b76:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103b79:	8b 1a                	mov    (%edx),%ebx
  103b7b:	85 db                	test   %ebx,%ebx
  103b7d:	74 0c                	je     103b8b <acquire+0x4b>
  103b7f:	8b 42 08             	mov    0x8(%edx),%eax
  103b82:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103b89:	74 45                	je     103bd0 <acquire+0x90>
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103b8b:	b9 01 00 00 00       	mov    $0x1,%ecx
  103b90:	eb 09                	jmp    103b9b <acquire+0x5b>
  103b92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
  103b98:	8b 55 08             	mov    0x8(%ebp),%edx
  103b9b:	89 c8                	mov    %ecx,%eax
  103b9d:	f0 87 02             	lock xchg %eax,(%edx)
  103ba0:	85 c0                	test   %eax,%eax
  103ba2:	75 f4                	jne    103b98 <acquire+0x58>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
  103ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  103ba7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103bae:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
  103bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  103bb4:	83 c0 0c             	add    $0xc,%eax
  103bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  103bbb:	8d 45 08             	lea    0x8(%ebp),%eax
  103bbe:	89 04 24             	mov    %eax,(%esp)
  103bc1:	e8 0a fe ff ff       	call   1039d0 <getcallerpcs>
}
  103bc6:	83 c4 14             	add    $0x14,%esp
  103bc9:	5b                   	pop    %ebx
  103bca:	5d                   	pop    %ebp
  103bcb:	c3                   	ret    
  103bcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");
  103bd0:	c7 04 24 a2 6a 10 00 	movl   $0x106aa2,(%esp)
  103bd7:	e8 44 cd ff ff       	call   100920 <panic>
  103bdc:	90                   	nop
  103bdd:	90                   	nop
  103bde:	90                   	nop
  103bdf:	90                   	nop

00103be0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
  103be0:	55                   	push   %ebp
  103be1:	89 e5                	mov    %esp,%ebp
  103be3:	8b 55 08             	mov    0x8(%ebp),%edx
  103be6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  103be7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  103bed:	89 d7                	mov    %edx,%edi
  103bef:	fc                   	cld    
  103bf0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  103bf2:	89 d0                	mov    %edx,%eax
  103bf4:	5f                   	pop    %edi
  103bf5:	5d                   	pop    %ebp
  103bf6:	c3                   	ret    
  103bf7:	89 f6                	mov    %esi,%esi
  103bf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103c00 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
  103c00:	55                   	push   %ebp
  103c01:	89 e5                	mov    %esp,%ebp
  103c03:	57                   	push   %edi
  103c04:	56                   	push   %esi
  103c05:	53                   	push   %ebx
  103c06:	8b 55 10             	mov    0x10(%ebp),%edx
  103c09:	8b 75 08             	mov    0x8(%ebp),%esi
  103c0c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103c0f:	85 d2                	test   %edx,%edx
  103c11:	74 2d                	je     103c40 <memcmp+0x40>
    if(*s1 != *s2)
  103c13:	0f b6 1e             	movzbl (%esi),%ebx
  103c16:	0f b6 0f             	movzbl (%edi),%ecx
  103c19:	38 cb                	cmp    %cl,%bl
  103c1b:	75 2b                	jne    103c48 <memcmp+0x48>
      return *s1 - *s2;
  103c1d:	83 ea 01             	sub    $0x1,%edx
  103c20:	31 c0                	xor    %eax,%eax
  103c22:	eb 18                	jmp    103c3c <memcmp+0x3c>
  103c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
  103c28:	0f b6 5c 06 01       	movzbl 0x1(%esi,%eax,1),%ebx
  103c2d:	83 ea 01             	sub    $0x1,%edx
  103c30:	0f b6 4c 07 01       	movzbl 0x1(%edi,%eax,1),%ecx
  103c35:	83 c0 01             	add    $0x1,%eax
  103c38:	38 cb                	cmp    %cl,%bl
  103c3a:	75 0c                	jne    103c48 <memcmp+0x48>
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103c3c:	85 d2                	test   %edx,%edx
  103c3e:	75 e8                	jne    103c28 <memcmp+0x28>
  103c40:	31 c0                	xor    %eax,%eax
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
  103c42:	5b                   	pop    %ebx
  103c43:	5e                   	pop    %esi
  103c44:	5f                   	pop    %edi
  103c45:	5d                   	pop    %ebp
  103c46:	c3                   	ret    
  103c47:	90                   	nop
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
  103c48:	0f b6 c3             	movzbl %bl,%eax
  103c4b:	0f b6 c9             	movzbl %cl,%ecx
  103c4e:	29 c8                	sub    %ecx,%eax
    s1++, s2++;
  }

  return 0;
}
  103c50:	5b                   	pop    %ebx
  103c51:	5e                   	pop    %esi
  103c52:	5f                   	pop    %edi
  103c53:	5d                   	pop    %ebp
  103c54:	c3                   	ret    
  103c55:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103c60 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
  103c60:	55                   	push   %ebp
  103c61:	89 e5                	mov    %esp,%ebp
  103c63:	57                   	push   %edi
  103c64:	56                   	push   %esi
  103c65:	53                   	push   %ebx
  103c66:	8b 45 08             	mov    0x8(%ebp),%eax
  103c69:	8b 75 0c             	mov    0xc(%ebp),%esi
  103c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
  103c6f:	39 c6                	cmp    %eax,%esi
  103c71:	73 2d                	jae    103ca0 <memmove+0x40>
  103c73:	8d 3c 1e             	lea    (%esi,%ebx,1),%edi
  103c76:	39 f8                	cmp    %edi,%eax
  103c78:	73 26                	jae    103ca0 <memmove+0x40>
    s += n;
    d += n;
    while(n-- > 0)
  103c7a:	85 db                	test   %ebx,%ebx
  103c7c:	74 1d                	je     103c9b <memmove+0x3b>

  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
  103c7e:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  103c81:	31 d2                	xor    %edx,%edx
  103c83:	90                   	nop
  103c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
      *--d = *--s;
  103c88:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  103c8d:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  103c91:	83 ea 01             	sub    $0x1,%edx
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103c94:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  103c97:	85 c9                	test   %ecx,%ecx
  103c99:	75 ed                	jne    103c88 <memmove+0x28>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
  103c9b:	5b                   	pop    %ebx
  103c9c:	5e                   	pop    %esi
  103c9d:	5f                   	pop    %edi
  103c9e:	5d                   	pop    %ebp
  103c9f:	c3                   	ret    
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103ca0:	31 d2                	xor    %edx,%edx
      *--d = *--s;
  } else
    while(n-- > 0)
  103ca2:	85 db                	test   %ebx,%ebx
  103ca4:	74 f5                	je     103c9b <memmove+0x3b>
  103ca6:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
  103ca8:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  103cac:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  103caf:	83 c2 01             	add    $0x1,%edx
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
  103cb2:	39 d3                	cmp    %edx,%ebx
  103cb4:	75 f2                	jne    103ca8 <memmove+0x48>
      *d++ = *s++;

  return dst;
}
  103cb6:	5b                   	pop    %ebx
  103cb7:	5e                   	pop    %esi
  103cb8:	5f                   	pop    %edi
  103cb9:	5d                   	pop    %ebp
  103cba:	c3                   	ret    
  103cbb:	90                   	nop
  103cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103cc0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  103cc0:	55                   	push   %ebp
  103cc1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
  103cc3:	5d                   	pop    %ebp

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
  103cc4:	e9 97 ff ff ff       	jmp    103c60 <memmove>
  103cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103cd0 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
  103cd0:	55                   	push   %ebp
  103cd1:	89 e5                	mov    %esp,%ebp
  103cd3:	57                   	push   %edi
  103cd4:	56                   	push   %esi
  103cd5:	53                   	push   %ebx
  103cd6:	8b 7d 10             	mov    0x10(%ebp),%edi
  103cd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103cdc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  while(n > 0 && *p && *p == *q)
  103cdf:	85 ff                	test   %edi,%edi
  103ce1:	74 3d                	je     103d20 <strncmp+0x50>
  103ce3:	0f b6 01             	movzbl (%ecx),%eax
  103ce6:	84 c0                	test   %al,%al
  103ce8:	75 18                	jne    103d02 <strncmp+0x32>
  103cea:	eb 3c                	jmp    103d28 <strncmp+0x58>
  103cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103cf0:	83 ef 01             	sub    $0x1,%edi
  103cf3:	74 2b                	je     103d20 <strncmp+0x50>
    n--, p++, q++;
  103cf5:	83 c1 01             	add    $0x1,%ecx
  103cf8:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103cfb:	0f b6 01             	movzbl (%ecx),%eax
  103cfe:	84 c0                	test   %al,%al
  103d00:	74 26                	je     103d28 <strncmp+0x58>
  103d02:	0f b6 33             	movzbl (%ebx),%esi
  103d05:	89 f2                	mov    %esi,%edx
  103d07:	38 d0                	cmp    %dl,%al
  103d09:	74 e5                	je     103cf0 <strncmp+0x20>
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
  103d0b:	81 e6 ff 00 00 00    	and    $0xff,%esi
  103d11:	0f b6 c0             	movzbl %al,%eax
  103d14:	29 f0                	sub    %esi,%eax
}
  103d16:	5b                   	pop    %ebx
  103d17:	5e                   	pop    %esi
  103d18:	5f                   	pop    %edi
  103d19:	5d                   	pop    %ebp
  103d1a:	c3                   	ret    
  103d1b:	90                   	nop
  103d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103d20:	31 c0                	xor    %eax,%eax
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
  103d22:	5b                   	pop    %ebx
  103d23:	5e                   	pop    %esi
  103d24:	5f                   	pop    %edi
  103d25:	5d                   	pop    %ebp
  103d26:	c3                   	ret    
  103d27:	90                   	nop
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103d28:	0f b6 33             	movzbl (%ebx),%esi
  103d2b:	eb de                	jmp    103d0b <strncmp+0x3b>
  103d2d:	8d 76 00             	lea    0x0(%esi),%esi

00103d30 <strncpy>:
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
{
  103d30:	55                   	push   %ebp
  103d31:	89 e5                	mov    %esp,%ebp
  103d33:	8b 45 08             	mov    0x8(%ebp),%eax
  103d36:	56                   	push   %esi
  103d37:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103d3a:	53                   	push   %ebx
  103d3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  103d3e:	89 c3                	mov    %eax,%ebx
  103d40:	eb 09                	jmp    103d4b <strncpy+0x1b>
  103d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  103d48:	83 c6 01             	add    $0x1,%esi
  103d4b:	83 e9 01             	sub    $0x1,%ecx
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  103d4e:	8d 51 01             	lea    0x1(%ecx),%edx
{
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  103d51:	85 d2                	test   %edx,%edx
  103d53:	7e 0c                	jle    103d61 <strncpy+0x31>
  103d55:	0f b6 16             	movzbl (%esi),%edx
  103d58:	88 13                	mov    %dl,(%ebx)
  103d5a:	83 c3 01             	add    $0x1,%ebx
  103d5d:	84 d2                	test   %dl,%dl
  103d5f:	75 e7                	jne    103d48 <strncpy+0x18>
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  103d61:	31 d2                	xor    %edx,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  103d63:	85 c9                	test   %ecx,%ecx
  103d65:	7e 0c                	jle    103d73 <strncpy+0x43>
  103d67:	90                   	nop
    *s++ = 0;
  103d68:	c6 04 13 00          	movb   $0x0,(%ebx,%edx,1)
  103d6c:	83 c2 01             	add    $0x1,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  103d6f:	39 ca                	cmp    %ecx,%edx
  103d71:	75 f5                	jne    103d68 <strncpy+0x38>
    *s++ = 0;
  return os;
}
  103d73:	5b                   	pop    %ebx
  103d74:	5e                   	pop    %esi
  103d75:	5d                   	pop    %ebp
  103d76:	c3                   	ret    
  103d77:	89 f6                	mov    %esi,%esi
  103d79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103d80 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
  103d80:	55                   	push   %ebp
  103d81:	89 e5                	mov    %esp,%ebp
  103d83:	8b 55 10             	mov    0x10(%ebp),%edx
  103d86:	56                   	push   %esi
  103d87:	8b 45 08             	mov    0x8(%ebp),%eax
  103d8a:	53                   	push   %ebx
  103d8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *os;
  
  os = s;
  if(n <= 0)
  103d8e:	85 d2                	test   %edx,%edx
  103d90:	7e 1f                	jle    103db1 <safestrcpy+0x31>
  103d92:	89 c1                	mov    %eax,%ecx
  103d94:	eb 05                	jmp    103d9b <safestrcpy+0x1b>
  103d96:	66 90                	xchg   %ax,%ax
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
  103d98:	83 c6 01             	add    $0x1,%esi
  103d9b:	83 ea 01             	sub    $0x1,%edx
  103d9e:	85 d2                	test   %edx,%edx
  103da0:	7e 0c                	jle    103dae <safestrcpy+0x2e>
  103da2:	0f b6 1e             	movzbl (%esi),%ebx
  103da5:	88 19                	mov    %bl,(%ecx)
  103da7:	83 c1 01             	add    $0x1,%ecx
  103daa:	84 db                	test   %bl,%bl
  103dac:	75 ea                	jne    103d98 <safestrcpy+0x18>
    ;
  *s = 0;
  103dae:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
  103db1:	5b                   	pop    %ebx
  103db2:	5e                   	pop    %esi
  103db3:	5d                   	pop    %ebp
  103db4:	c3                   	ret    
  103db5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103dc0 <strlen>:

int
strlen(const char *s)
{
  103dc0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
  103dc1:	31 c0                	xor    %eax,%eax
  return os;
}

int
strlen(const char *s)
{
  103dc3:	89 e5                	mov    %esp,%ebp
  103dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
  103dc8:	80 3a 00             	cmpb   $0x0,(%edx)
  103dcb:	74 0c                	je     103dd9 <strlen+0x19>
  103dcd:	8d 76 00             	lea    0x0(%esi),%esi
  103dd0:	83 c0 01             	add    $0x1,%eax
  103dd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  103dd7:	75 f7                	jne    103dd0 <strlen+0x10>
    ;
  return n;
}
  103dd9:	5d                   	pop    %ebp
  103dda:	c3                   	ret    
  103ddb:	90                   	nop

00103ddc <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
  103ddc:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
  103de0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
  103de4:	55                   	push   %ebp
  pushl %ebx
  103de5:	53                   	push   %ebx
  pushl %esi
  103de6:	56                   	push   %esi
  pushl %edi
  103de7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
  103de8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
  103dea:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
  103dec:	5f                   	pop    %edi
  popl %esi
  103ded:	5e                   	pop    %esi
  popl %ebx
  103dee:	5b                   	pop    %ebx
  popl %ebp
  103def:	5d                   	pop    %ebp
  ret
  103df0:	c3                   	ret    
  103df1:	90                   	nop
  103df2:	90                   	nop
  103df3:	90                   	nop
  103df4:	90                   	nop
  103df5:	90                   	nop
  103df6:	90                   	nop
  103df7:	90                   	nop
  103df8:	90                   	nop
  103df9:	90                   	nop
  103dfa:	90                   	nop
  103dfb:	90                   	nop
  103dfc:	90                   	nop
  103dfd:	90                   	nop
  103dfe:	90                   	nop
  103dff:	90                   	nop

00103e00 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  103e00:	55                   	push   %ebp
  103e01:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
  103e03:	8b 55 08             	mov    0x8(%ebp),%edx
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  103e06:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(addr >= p->sz || addr+4 > p->sz)
  103e09:	8b 12                	mov    (%edx),%edx
  103e0b:	39 c2                	cmp    %eax,%edx
  103e0d:	77 09                	ja     103e18 <fetchint+0x18>
    return -1;
  *ip = *(int*)(addr);
  return 0;
  103e0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  103e14:	5d                   	pop    %ebp
  103e15:	c3                   	ret    
  103e16:	66 90                	xchg   %ax,%ax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103e18:	8d 48 04             	lea    0x4(%eax),%ecx
  103e1b:	39 ca                	cmp    %ecx,%edx
  103e1d:	72 f0                	jb     103e0f <fetchint+0xf>
    return -1;
  *ip = *(int*)(addr);
  103e1f:	8b 10                	mov    (%eax),%edx
  103e21:	8b 45 10             	mov    0x10(%ebp),%eax
  103e24:	89 10                	mov    %edx,(%eax)
  103e26:	31 c0                	xor    %eax,%eax
  return 0;
}
  103e28:	5d                   	pop    %ebp
  103e29:	c3                   	ret    
  103e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00103e30 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  103e30:	55                   	push   %ebp
  103e31:	89 e5                	mov    %esp,%ebp
  103e33:	8b 45 08             	mov    0x8(%ebp),%eax
  103e36:	8b 55 0c             	mov    0xc(%ebp),%edx
  103e39:	53                   	push   %ebx
  char *s, *ep;

  if(addr >= p->sz)
  103e3a:	39 10                	cmp    %edx,(%eax)
  103e3c:	77 0a                	ja     103e48 <fetchstr+0x18>
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  103e3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    if(*s == 0)
      return s - *pp;
  return -1;
}
  103e43:	5b                   	pop    %ebx
  103e44:	5d                   	pop    %ebp
  103e45:	c3                   	ret    
  103e46:	66 90                	xchg   %ax,%ax
{
  char *s, *ep;

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  103e48:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103e4b:	89 11                	mov    %edx,(%ecx)
  ep = (char*)p->sz;
  103e4d:	8b 18                	mov    (%eax),%ebx
  for(s = *pp; s < ep; s++)
  103e4f:	39 da                	cmp    %ebx,%edx
  103e51:	73 eb                	jae    103e3e <fetchstr+0xe>
    if(*s == 0)
  103e53:	31 c0                	xor    %eax,%eax
  103e55:	89 d1                	mov    %edx,%ecx
  103e57:	80 3a 00             	cmpb   $0x0,(%edx)
  103e5a:	74 e7                	je     103e43 <fetchstr+0x13>
  103e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  103e60:	83 c1 01             	add    $0x1,%ecx
  103e63:	39 cb                	cmp    %ecx,%ebx
  103e65:	76 d7                	jbe    103e3e <fetchstr+0xe>
    if(*s == 0)
  103e67:	80 39 00             	cmpb   $0x0,(%ecx)
  103e6a:	75 f4                	jne    103e60 <fetchstr+0x30>
  103e6c:	89 c8                	mov    %ecx,%eax
  103e6e:	29 d0                	sub    %edx,%eax
  103e70:	eb d1                	jmp    103e43 <fetchstr+0x13>
  103e72:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  103e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103e80 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103e80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  103e86:	55                   	push   %ebp
  103e87:	89 e5                	mov    %esp,%ebp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103e89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103e8c:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103e8f:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103e91:	8b 52 44             	mov    0x44(%edx),%edx
  103e94:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103e98:	39 c2                	cmp    %eax,%edx
  103e9a:	72 0c                	jb     103ea8 <argint+0x28>
    return -1;
  *ip = *(int*)(addr);
  103e9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  103ea1:	5d                   	pop    %ebp
  103ea2:	c3                   	ret    
  103ea3:	90                   	nop
  103ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103ea8:	8d 4a 04             	lea    0x4(%edx),%ecx
  103eab:	39 c8                	cmp    %ecx,%eax
  103ead:	72 ed                	jb     103e9c <argint+0x1c>
    return -1;
  *ip = *(int*)(addr);
  103eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  103eb2:	8b 12                	mov    (%edx),%edx
  103eb4:	89 10                	mov    %edx,(%eax)
  103eb6:	31 c0                	xor    %eax,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  103eb8:	5d                   	pop    %ebp
  103eb9:	c3                   	ret    
  103eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00103ec0 <argptr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103ec0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
  103ec6:	55                   	push   %ebp
  103ec7:	89 e5                	mov    %esp,%ebp

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103ec9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103ecc:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103ecf:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103ed1:	8b 52 44             	mov    0x44(%edx),%edx
  103ed4:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103ed8:	39 c2                	cmp    %eax,%edx
  103eda:	73 07                	jae    103ee3 <argptr+0x23>
  103edc:	8d 4a 04             	lea    0x4(%edx),%ecx
  103edf:	39 c8                	cmp    %ecx,%eax
  103ee1:	73 0d                	jae    103ef0 <argptr+0x30>
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
    return -1;
  *pp = (char*)i;
  return 0;
  103ee3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  103ee8:	5d                   	pop    %ebp
  103ee9:	c3                   	ret    
  103eea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  103ef0:	8b 12                	mov    (%edx),%edx
{
  int i;
  
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
  103ef2:	39 c2                	cmp    %eax,%edx
  103ef4:	73 ed                	jae    103ee3 <argptr+0x23>
  103ef6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103ef9:	01 d1                	add    %edx,%ecx
  103efb:	39 c1                	cmp    %eax,%ecx
  103efd:	77 e4                	ja     103ee3 <argptr+0x23>
    return -1;
  *pp = (char*)i;
  103eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  103f02:	89 10                	mov    %edx,(%eax)
  103f04:	31 c0                	xor    %eax,%eax
  return 0;
}
  103f06:	5d                   	pop    %ebp
  103f07:	c3                   	ret    
  103f08:	90                   	nop
  103f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103f10 <argstr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103f10:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
  103f17:	55                   	push   %ebp
  103f18:	89 e5                	mov    %esp,%ebp
  103f1a:	53                   	push   %ebx

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103f1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103f1e:	8b 42 18             	mov    0x18(%edx),%eax
  103f21:	8b 40 44             	mov    0x44(%eax),%eax
  103f24:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103f28:	8b 0a                	mov    (%edx),%ecx
  103f2a:	39 c8                	cmp    %ecx,%eax
  103f2c:	73 07                	jae    103f35 <argstr+0x25>
  103f2e:	8d 58 04             	lea    0x4(%eax),%ebx
  103f31:	39 d9                	cmp    %ebx,%ecx
  103f33:	73 0b                	jae    103f40 <argstr+0x30>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  103f35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  103f3a:	5b                   	pop    %ebx
  103f3b:	5d                   	pop    %ebp
  103f3c:	c3                   	ret    
  103f3d:	8d 76 00             	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  103f40:	8b 18                	mov    (%eax),%ebx
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  char *s, *ep;

  if(addr >= p->sz)
  103f42:	39 cb                	cmp    %ecx,%ebx
  103f44:	73 ef                	jae    103f35 <argstr+0x25>
    return -1;
  *pp = (char*)addr;
  103f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  103f49:	89 d8                	mov    %ebx,%eax
  103f4b:	89 19                	mov    %ebx,(%ecx)
  ep = (char*)p->sz;
  103f4d:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
  103f4f:	39 d3                	cmp    %edx,%ebx
  103f51:	73 e2                	jae    103f35 <argstr+0x25>
    if(*s == 0)
  103f53:	80 3b 00             	cmpb   $0x0,(%ebx)
  103f56:	75 12                	jne    103f6a <argstr+0x5a>
  103f58:	eb 1e                	jmp    103f78 <argstr+0x68>
  103f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103f60:	80 38 00             	cmpb   $0x0,(%eax)
  103f63:	90                   	nop
  103f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103f68:	74 0e                	je     103f78 <argstr+0x68>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  103f6a:	83 c0 01             	add    $0x1,%eax
  103f6d:	39 c2                	cmp    %eax,%edx
  103f6f:	90                   	nop
  103f70:	77 ee                	ja     103f60 <argstr+0x50>
  103f72:	eb c1                	jmp    103f35 <argstr+0x25>
  103f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
      return s - *pp;
  103f78:	29 d8                	sub    %ebx,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  103f7a:	5b                   	pop    %ebx
  103f7b:	5d                   	pop    %ebp
  103f7c:	c3                   	ret    
  103f7d:	8d 76 00             	lea    0x0(%esi),%esi

00103f80 <syscall>:
[SYS_uptime]  sys_uptime,
};

void
syscall(void)
{
  103f80:	55                   	push   %ebp
  103f81:	89 e5                	mov    %esp,%ebp
  103f83:	53                   	push   %ebx
  103f84:	83 ec 14             	sub    $0x14,%esp
  int num;
  
  num = proc->tf->eax;
  103f87:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103f8e:	8b 5a 18             	mov    0x18(%edx),%ebx
  103f91:	8b 43 1c             	mov    0x1c(%ebx),%eax
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
  103f94:	83 f8 15             	cmp    $0x15,%eax
  103f97:	77 17                	ja     103fb0 <syscall+0x30>
  103f99:	8b 0c 85 e0 6a 10 00 	mov    0x106ae0(,%eax,4),%ecx
  103fa0:	85 c9                	test   %ecx,%ecx
  103fa2:	74 0c                	je     103fb0 <syscall+0x30>
    proc->tf->eax = syscalls[num]();
  103fa4:	ff d1                	call   *%ecx
  103fa6:	89 43 1c             	mov    %eax,0x1c(%ebx)
  else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
  103fa9:	83 c4 14             	add    $0x14,%esp
  103fac:	5b                   	pop    %ebx
  103fad:	5d                   	pop    %ebp
  103fae:	c3                   	ret    
  103faf:	90                   	nop
  
  num = proc->tf->eax;
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
    proc->tf->eax = syscalls[num]();
  else {
    cprintf("%d %s: unknown sys call %d\n",
  103fb0:	8b 4a 10             	mov    0x10(%edx),%ecx
  103fb3:	83 c2 6c             	add    $0x6c,%edx
  103fb6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103fba:	89 54 24 08          	mov    %edx,0x8(%esp)
  103fbe:	c7 04 24 aa 6a 10 00 	movl   $0x106aaa,(%esp)
  103fc5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103fc9:	e8 62 c5 ff ff       	call   100530 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  103fce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103fd4:	8b 40 18             	mov    0x18(%eax),%eax
  103fd7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
  103fde:	83 c4 14             	add    $0x14,%esp
  103fe1:	5b                   	pop    %ebx
  103fe2:	5d                   	pop    %ebp
  103fe3:	c3                   	ret    
  103fe4:	90                   	nop
  103fe5:	90                   	nop
  103fe6:	90                   	nop
  103fe7:	90                   	nop
  103fe8:	90                   	nop
  103fe9:	90                   	nop
  103fea:	90                   	nop
  103feb:	90                   	nop
  103fec:	90                   	nop
  103fed:	90                   	nop
  103fee:	90                   	nop
  103fef:	90                   	nop

00103ff0 <sys_pipe>:
  return exec(path, argv);
}

int
sys_pipe(void)
{
  103ff0:	55                   	push   %ebp
  103ff1:	89 e5                	mov    %esp,%ebp
  103ff3:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  103ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return exec(path, argv);
}

int
sys_pipe(void)
{
  103ff9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  103ffc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  103fff:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  104006:	00 
  104007:	89 44 24 04          	mov    %eax,0x4(%esp)
  10400b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104012:	e8 a9 fe ff ff       	call   103ec0 <argptr>
  104017:	85 c0                	test   %eax,%eax
  104019:	79 15                	jns    104030 <sys_pipe+0x40>
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  10401b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
}
  104020:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  104023:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104026:	89 ec                	mov    %ebp,%esp
  104028:	5d                   	pop    %ebp
  104029:	c3                   	ret    
  10402a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
  104030:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104033:	89 44 24 04          	mov    %eax,0x4(%esp)
  104037:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10403a:	89 04 24             	mov    %eax,(%esp)
  10403d:	e8 be ee ff ff       	call   102f00 <pipealloc>
  104042:	85 c0                	test   %eax,%eax
  104044:	78 d5                	js     10401b <sys_pipe+0x2b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  104046:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  104049:	31 c0                	xor    %eax,%eax
  10404b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104058:	8b 5c 82 28          	mov    0x28(%edx,%eax,4),%ebx
  10405c:	85 db                	test   %ebx,%ebx
  10405e:	74 28                	je     104088 <sys_pipe+0x98>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104060:	83 c0 01             	add    $0x1,%eax
  104063:	83 f8 10             	cmp    $0x10,%eax
  104066:	75 f0                	jne    104058 <sys_pipe+0x68>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
  104068:	89 0c 24             	mov    %ecx,(%esp)
  10406b:	e8 10 cf ff ff       	call   100f80 <fileclose>
    fileclose(wf);
  104070:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104073:	89 04 24             	mov    %eax,(%esp)
  104076:	e8 05 cf ff ff       	call   100f80 <fileclose>
  10407b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104080:	eb 9e                	jmp    104020 <sys_pipe+0x30>
  104082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  104088:	8d 58 08             	lea    0x8(%eax),%ebx
  10408b:	89 4c 9a 08          	mov    %ecx,0x8(%edx,%ebx,4)
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  10408f:	8b 75 ec             	mov    -0x14(%ebp),%esi
  104092:	31 d2                	xor    %edx,%edx
  104094:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  10409b:	90                   	nop
  10409c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  1040a0:	83 7c 91 28 00       	cmpl   $0x0,0x28(%ecx,%edx,4)
  1040a5:	74 19                	je     1040c0 <sys_pipe+0xd0>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  1040a7:	83 c2 01             	add    $0x1,%edx
  1040aa:	83 fa 10             	cmp    $0x10,%edx
  1040ad:	75 f1                	jne    1040a0 <sys_pipe+0xb0>
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
  1040af:	c7 44 99 08 00 00 00 	movl   $0x0,0x8(%ecx,%ebx,4)
  1040b6:	00 
  1040b7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1040ba:	eb ac                	jmp    104068 <sys_pipe+0x78>
  1040bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1040c0:	89 74 91 28          	mov    %esi,0x28(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
  1040c4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1040c7:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
  1040c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1040cc:	89 50 04             	mov    %edx,0x4(%eax)
  1040cf:	31 c0                	xor    %eax,%eax
  return 0;
  1040d1:	e9 4a ff ff ff       	jmp    104020 <sys_pipe+0x30>
  1040d6:	8d 76 00             	lea    0x0(%esi),%esi
  1040d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001040e0 <sys_exec>:
  return 0;
}

int
sys_exec(void)
{
  1040e0:	55                   	push   %ebp
  1040e1:	89 e5                	mov    %esp,%ebp
  1040e3:	81 ec b8 00 00 00    	sub    $0xb8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  1040e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 0;
}

int
sys_exec(void)
{
  1040ec:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1040ef:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1040f2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  1040f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1040f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104100:	e8 0b fe ff ff       	call   103f10 <argstr>
  104105:	85 c0                	test   %eax,%eax
  104107:	79 17                	jns    104120 <sys_exec+0x40>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv))
  104109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
}
  10410e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  104111:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104114:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104117:	89 ec                	mov    %ebp,%esp
  104119:	5d                   	pop    %ebp
  10411a:	c3                   	ret    
  10411b:	90                   	nop
  10411c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  104120:	8d 45 e0             	lea    -0x20(%ebp),%eax
  104123:	89 44 24 04          	mov    %eax,0x4(%esp)
  104127:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10412e:	e8 4d fd ff ff       	call   103e80 <argint>
  104133:	85 c0                	test   %eax,%eax
  104135:	78 d2                	js     104109 <sys_exec+0x29>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  104137:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  10413d:	31 f6                	xor    %esi,%esi
  10413f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  104146:	00 
  104147:	31 db                	xor    %ebx,%ebx
  104149:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104150:	00 
  104151:	89 3c 24             	mov    %edi,(%esp)
  104154:	e8 87 fa ff ff       	call   103be0 <memset>
  104159:	eb 2c                	jmp    104187 <sys_exec+0xa7>
  10415b:	90                   	nop
  10415c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
  104160:	89 44 24 04          	mov    %eax,0x4(%esp)
  104164:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10416a:	8d 14 b7             	lea    (%edi,%esi,4),%edx
  10416d:	89 54 24 08          	mov    %edx,0x8(%esp)
  104171:	89 04 24             	mov    %eax,(%esp)
  104174:	e8 b7 fc ff ff       	call   103e30 <fetchstr>
  104179:	85 c0                	test   %eax,%eax
  10417b:	78 8c                	js     104109 <sys_exec+0x29>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  10417d:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
  104180:	83 fb 20             	cmp    $0x20,%ebx

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  104183:	89 de                	mov    %ebx,%esi
    if(i >= NELEM(argv))
  104185:	74 82                	je     104109 <sys_exec+0x29>
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
  104187:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10418a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10418e:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  104195:	03 45 e0             	add    -0x20(%ebp),%eax
  104198:	89 44 24 04          	mov    %eax,0x4(%esp)
  10419c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1041a2:	89 04 24             	mov    %eax,(%esp)
  1041a5:	e8 56 fc ff ff       	call   103e00 <fetchint>
  1041aa:	85 c0                	test   %eax,%eax
  1041ac:	0f 88 57 ff ff ff    	js     104109 <sys_exec+0x29>
      return -1;
    if(uarg == 0){
  1041b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1041b5:	85 c0                	test   %eax,%eax
  1041b7:	75 a7                	jne    104160 <sys_exec+0x80>
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  1041b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
  1041bc:	c7 84 9d 5c ff ff ff 	movl   $0x0,-0xa4(%ebp,%ebx,4)
  1041c3:	00 00 00 00 
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  1041c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1041cb:	89 04 24             	mov    %eax,(%esp)
  1041ce:	e8 cd c7 ff ff       	call   1009a0 <exec>
  1041d3:	e9 36 ff ff ff       	jmp    10410e <sys_exec+0x2e>
  1041d8:	90                   	nop
  1041d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001041e0 <sys_chdir>:
  return 0;
}

int
sys_chdir(void)
{
  1041e0:	55                   	push   %ebp
  1041e1:	89 e5                	mov    %esp,%ebp
  1041e3:	53                   	push   %ebx
  1041e4:	83 ec 24             	sub    $0x24,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  1041e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1041ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  1041ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1041f5:	e8 16 fd ff ff       	call   103f10 <argstr>
  1041fa:	85 c0                	test   %eax,%eax
  1041fc:	79 12                	jns    104210 <sys_chdir+0x30>
    return -1;
  }
  iunlock(ip);
  iput(proc->cwd);
  proc->cwd = ip;
  return 0;
  1041fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104203:	83 c4 24             	add    $0x24,%esp
  104206:	5b                   	pop    %ebx
  104207:	5d                   	pop    %ebp
  104208:	c3                   	ret    
  104209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
sys_chdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  104210:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104213:	89 04 24             	mov    %eax,(%esp)
  104216:	e8 45 dc ff ff       	call   101e60 <namei>
  10421b:	85 c0                	test   %eax,%eax
  10421d:	89 c3                	mov    %eax,%ebx
  10421f:	74 dd                	je     1041fe <sys_chdir+0x1e>
    return -1;
  ilock(ip);
  104221:	89 04 24             	mov    %eax,(%esp)
  104224:	e8 97 d9 ff ff       	call   101bc0 <ilock>
  if(ip->type != T_DIR){
  104229:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10422e:	75 26                	jne    104256 <sys_chdir+0x76>
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  104230:	89 1c 24             	mov    %ebx,(%esp)
  104233:	e8 38 d5 ff ff       	call   101770 <iunlock>
  iput(proc->cwd);
  104238:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10423e:	8b 40 68             	mov    0x68(%eax),%eax
  104241:	89 04 24             	mov    %eax,(%esp)
  104244:	e8 37 d6 ff ff       	call   101880 <iput>
  proc->cwd = ip;
  104249:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10424f:	89 58 68             	mov    %ebx,0x68(%eax)
  104252:	31 c0                	xor    %eax,%eax
  return 0;
  104254:	eb ad                	jmp    104203 <sys_chdir+0x23>

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
    return -1;
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
  104256:	89 1c 24             	mov    %ebx,(%esp)
  104259:	e8 72 d8 ff ff       	call   101ad0 <iunlockput>
  10425e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104263:	eb 9e                	jmp    104203 <sys_chdir+0x23>
  104265:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104269:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104270 <create>:
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104270:	55                   	push   %ebp
  104271:	89 e5                	mov    %esp,%ebp
  104273:	83 ec 58             	sub    $0x58,%esp
  104276:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  104279:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10427c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  10427f:	8d 75 d6             	lea    -0x2a(%ebp),%esi
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104282:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  104285:	31 db                	xor    %ebx,%ebx
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104287:	89 7d fc             	mov    %edi,-0x4(%ebp)
  10428a:	89 d7                	mov    %edx,%edi
  10428c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  10428f:	89 74 24 04          	mov    %esi,0x4(%esp)
  104293:	89 04 24             	mov    %eax,(%esp)
  104296:	e8 a5 db ff ff       	call   101e40 <nameiparent>
  10429b:	85 c0                	test   %eax,%eax
  10429d:	74 4d                	je     1042ec <create+0x7c>
    return 0;
  ilock(dp);
  10429f:	89 04 24             	mov    %eax,(%esp)
  1042a2:	89 45 bc             	mov    %eax,-0x44(%ebp)
  1042a5:	e8 16 d9 ff ff       	call   101bc0 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
  1042aa:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1042ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1042b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1042b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  1042b8:	89 14 24             	mov    %edx,(%esp)
  1042bb:	e8 b0 d3 ff ff       	call   101670 <dirlookup>
  1042c0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1042c3:	85 c0                	test   %eax,%eax
  1042c5:	89 c3                	mov    %eax,%ebx
  1042c7:	74 4f                	je     104318 <create+0xa8>
    iunlockput(dp);
  1042c9:	89 14 24             	mov    %edx,(%esp)
  1042cc:	e8 ff d7 ff ff       	call   101ad0 <iunlockput>
    ilock(ip);
  1042d1:	89 1c 24             	mov    %ebx,(%esp)
  1042d4:	e8 e7 d8 ff ff       	call   101bc0 <ilock>
    if((type == T_FILE && ip->type == T_FILE) || (type == T_EXTENT && ip->type == T_EXTENT))
  1042d9:	66 83 ff 02          	cmp    $0x2,%di
  1042dd:	74 21                	je     104300 <create+0x90>
  1042df:	66 83 ff 04          	cmp    $0x4,%di
  1042e3:	75 22                	jne    104307 <create+0x97>
  1042e5:	66 83 7b 10 04       	cmpw   $0x4,0x10(%ebx)
  1042ea:	75 1b                	jne    104307 <create+0x97>
  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);
  return ip;
}
  1042ec:	89 d8                	mov    %ebx,%eax
  1042ee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1042f1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1042f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1042f7:	89 ec                	mov    %ebp,%esp
  1042f9:	5d                   	pop    %ebp
  1042fa:	c3                   	ret    
  1042fb:	90                   	nop
  1042fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ilock(dp);

  if((ip = dirlookup(dp, name, &off)) != 0){
    iunlockput(dp);
    ilock(ip);
    if((type == T_FILE && ip->type == T_FILE) || (type == T_EXTENT && ip->type == T_EXTENT))
  104300:	66 83 7b 10 02       	cmpw   $0x2,0x10(%ebx)
  104305:	74 e5                	je     1042ec <create+0x7c>
      return ip;
    iunlockput(ip);
  104307:	89 1c 24             	mov    %ebx,(%esp)
  10430a:	31 db                	xor    %ebx,%ebx
  10430c:	e8 bf d7 ff ff       	call   101ad0 <iunlockput>
    return 0;
  104311:	eb d9                	jmp    1042ec <create+0x7c>
  104313:	90                   	nop
  104314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

  if((ip = ialloc(dp->dev, type)) == 0)
  104318:	0f bf c7             	movswl %di,%eax
  10431b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10431f:	8b 02                	mov    (%edx),%eax
  104321:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104324:	89 04 24             	mov    %eax,(%esp)
  104327:	e8 c4 d7 ff ff       	call   101af0 <ialloc>
  10432c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10432f:	85 c0                	test   %eax,%eax
  104331:	89 c3                	mov    %eax,%ebx
  104333:	0f 84 b7 00 00 00    	je     1043f0 <create+0x180>
    panic("create: ialloc");

  ilock(ip);
  104339:	89 55 bc             	mov    %edx,-0x44(%ebp)
  10433c:	89 04 24             	mov    %eax,(%esp)
  10433f:	e8 7c d8 ff ff       	call   101bc0 <ilock>
  ip->major = major;
  104344:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
  104348:	66 89 43 12          	mov    %ax,0x12(%ebx)
  ip->minor = minor;
  10434c:	0f b7 4d c0          	movzwl -0x40(%ebp),%ecx
  ip->nlink = 1;
  104350:	66 c7 43 16 01 00    	movw   $0x1,0x16(%ebx)
  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");

  ilock(ip);
  ip->major = major;
  ip->minor = minor;
  104356:	66 89 4b 14          	mov    %cx,0x14(%ebx)
  ip->nlink = 1;
  iupdate(ip);
  10435a:	89 1c 24             	mov    %ebx,(%esp)
  10435d:	e8 0e d1 ff ff       	call   101470 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
  104362:	66 83 ff 01          	cmp    $0x1,%di
  104366:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104369:	74 2d                	je     104398 <create+0x128>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
  10436b:	8b 43 04             	mov    0x4(%ebx),%eax
  10436e:	89 14 24             	mov    %edx,(%esp)
  104371:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104374:	89 74 24 04          	mov    %esi,0x4(%esp)
  104378:	89 44 24 08          	mov    %eax,0x8(%esp)
  10437c:	e8 5f d6 ff ff       	call   1019e0 <dirlink>
  104381:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104384:	85 c0                	test   %eax,%eax
  104386:	78 74                	js     1043fc <create+0x18c>
    panic("create: dirlink");

  iunlockput(dp);
  104388:	89 14 24             	mov    %edx,(%esp)
  10438b:	e8 40 d7 ff ff       	call   101ad0 <iunlockput>
  return ip;
  104390:	e9 57 ff ff ff       	jmp    1042ec <create+0x7c>
  104395:	8d 76 00             	lea    0x0(%esi),%esi
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
  104398:	66 83 42 16 01       	addw   $0x1,0x16(%edx)
    iupdate(dp);
  10439d:	89 14 24             	mov    %edx,(%esp)
  1043a0:	89 55 bc             	mov    %edx,-0x44(%ebp)
  1043a3:	e8 c8 d0 ff ff       	call   101470 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
  1043a8:	8b 43 04             	mov    0x4(%ebx),%eax
  1043ab:	c7 44 24 04 48 6b 10 	movl   $0x106b48,0x4(%esp)
  1043b2:	00 
  1043b3:	89 1c 24             	mov    %ebx,(%esp)
  1043b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1043ba:	e8 21 d6 ff ff       	call   1019e0 <dirlink>
  1043bf:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1043c2:	85 c0                	test   %eax,%eax
  1043c4:	78 1e                	js     1043e4 <create+0x174>
  1043c6:	8b 42 04             	mov    0x4(%edx),%eax
  1043c9:	c7 44 24 04 47 6b 10 	movl   $0x106b47,0x4(%esp)
  1043d0:	00 
  1043d1:	89 1c 24             	mov    %ebx,(%esp)
  1043d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1043d8:	e8 03 d6 ff ff       	call   1019e0 <dirlink>
  1043dd:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1043e0:	85 c0                	test   %eax,%eax
  1043e2:	79 87                	jns    10436b <create+0xfb>
      panic("create dots");
  1043e4:	c7 04 24 4a 6b 10 00 	movl   $0x106b4a,(%esp)
  1043eb:	e8 30 c5 ff ff       	call   100920 <panic>
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");
  1043f0:	c7 04 24 38 6b 10 00 	movl   $0x106b38,(%esp)
  1043f7:	e8 24 c5 ff ff       	call   100920 <panic>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");
  1043fc:	c7 04 24 56 6b 10 00 	movl   $0x106b56,(%esp)
  104403:	e8 18 c5 ff ff       	call   100920 <panic>
  104408:	90                   	nop
  104409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104410 <sys_mknod>:
  return 0;
}

int
sys_mknod(void)
{
  104410:	55                   	push   %ebp
  104411:	89 e5                	mov    %esp,%ebp
  104413:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  104416:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104419:	89 44 24 04          	mov    %eax,0x4(%esp)
  10441d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104424:	e8 e7 fa ff ff       	call   103f10 <argstr>
  104429:	85 c0                	test   %eax,%eax
  10442b:	79 0b                	jns    104438 <sys_mknod+0x28>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  return 0;
  10442d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104432:	c9                   	leave  
  104433:	c3                   	ret    
  104434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
  104438:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10443b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10443f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104446:	e8 35 fa ff ff       	call   103e80 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10444b:	85 c0                	test   %eax,%eax
  10444d:	78 de                	js     10442d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
  10444f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104452:	89 44 24 04          	mov    %eax,0x4(%esp)
  104456:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10445d:	e8 1e fa ff ff       	call   103e80 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  104462:	85 c0                	test   %eax,%eax
  104464:	78 c7                	js     10442d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
  104466:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
  10446a:	ba 03 00 00 00       	mov    $0x3,%edx
  10446f:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
  104473:	89 04 24             	mov    %eax,(%esp)
  104476:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104479:	e8 f2 fd ff ff       	call   104270 <create>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10447e:	85 c0                	test   %eax,%eax
  104480:	74 ab                	je     10442d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  104482:	89 04 24             	mov    %eax,(%esp)
  104485:	e8 46 d6 ff ff       	call   101ad0 <iunlockput>
  10448a:	31 c0                	xor    %eax,%eax
  return 0;
}
  10448c:	c9                   	leave  
  10448d:	c3                   	ret    
  10448e:	66 90                	xchg   %ax,%ax

00104490 <sys_mkdir>:
  return fd;
}

int
sys_mkdir(void)
{
  104490:	55                   	push   %ebp
  104491:	89 e5                	mov    %esp,%ebp
  104493:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  104496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104499:	89 44 24 04          	mov    %eax,0x4(%esp)
  10449d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1044a4:	e8 67 fa ff ff       	call   103f10 <argstr>
  1044a9:	85 c0                	test   %eax,%eax
  1044ab:	79 0b                	jns    1044b8 <sys_mkdir+0x28>
    return -1;
  iunlockput(ip);
  return 0;
  1044ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1044b2:	c9                   	leave  
  1044b3:	c3                   	ret    
  1044b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_mkdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  1044b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1044bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044c2:	31 c9                	xor    %ecx,%ecx
  1044c4:	ba 01 00 00 00       	mov    $0x1,%edx
  1044c9:	e8 a2 fd ff ff       	call   104270 <create>
  1044ce:	85 c0                	test   %eax,%eax
  1044d0:	74 db                	je     1044ad <sys_mkdir+0x1d>
    return -1;
  iunlockput(ip);
  1044d2:	89 04 24             	mov    %eax,(%esp)
  1044d5:	e8 f6 d5 ff ff       	call   101ad0 <iunlockput>
  1044da:	31 c0                	xor    %eax,%eax
  return 0;
}
  1044dc:	c9                   	leave  
  1044dd:	c3                   	ret    
  1044de:	66 90                	xchg   %ax,%ax

001044e0 <sys_link>:
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1044e0:	55                   	push   %ebp
  1044e1:	89 e5                	mov    %esp,%ebp
  1044e3:	83 ec 48             	sub    $0x48,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1044e6:	8d 45 e0             	lea    -0x20(%ebp),%eax
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1044e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1044ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1044ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1044f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1044f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1044fd:	e8 0e fa ff ff       	call   103f10 <argstr>
  104502:	85 c0                	test   %eax,%eax
  104504:	79 12                	jns    104518 <sys_link+0x38>
bad:
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return -1;
  104506:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10450b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10450e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104511:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104514:	89 ec                	mov    %ebp,%esp
  104516:	5d                   	pop    %ebp
  104517:	c3                   	ret    
sys_link(void)
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  104518:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  10451b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10451f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104526:	e8 e5 f9 ff ff       	call   103f10 <argstr>
  10452b:	85 c0                	test   %eax,%eax
  10452d:	78 d7                	js     104506 <sys_link+0x26>
    return -1;
  if((ip = namei(old)) == 0)
  10452f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104532:	89 04 24             	mov    %eax,(%esp)
  104535:	e8 26 d9 ff ff       	call   101e60 <namei>
  10453a:	85 c0                	test   %eax,%eax
  10453c:	89 c3                	mov    %eax,%ebx
  10453e:	74 c6                	je     104506 <sys_link+0x26>
    return -1;
  ilock(ip);
  104540:	89 04 24             	mov    %eax,(%esp)
  104543:	e8 78 d6 ff ff       	call   101bc0 <ilock>
  if(ip->type == T_DIR){
  104548:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10454d:	0f 84 86 00 00 00    	je     1045d9 <sys_link+0xf9>
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  104553:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
  104558:	8d 7d d2             	lea    -0x2e(%ebp),%edi
  if(ip->type == T_DIR){
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  iupdate(ip);
  10455b:	89 1c 24             	mov    %ebx,(%esp)
  10455e:	e8 0d cf ff ff       	call   101470 <iupdate>
  iunlock(ip);
  104563:	89 1c 24             	mov    %ebx,(%esp)
  104566:	e8 05 d2 ff ff       	call   101770 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
  10456b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10456e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104572:	89 04 24             	mov    %eax,(%esp)
  104575:	e8 c6 d8 ff ff       	call   101e40 <nameiparent>
  10457a:	85 c0                	test   %eax,%eax
  10457c:	89 c6                	mov    %eax,%esi
  10457e:	74 44                	je     1045c4 <sys_link+0xe4>
    goto bad;
  ilock(dp);
  104580:	89 04 24             	mov    %eax,(%esp)
  104583:	e8 38 d6 ff ff       	call   101bc0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
  104588:	8b 06                	mov    (%esi),%eax
  10458a:	3b 03                	cmp    (%ebx),%eax
  10458c:	75 2e                	jne    1045bc <sys_link+0xdc>
  10458e:	8b 43 04             	mov    0x4(%ebx),%eax
  104591:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104595:	89 34 24             	mov    %esi,(%esp)
  104598:	89 44 24 08          	mov    %eax,0x8(%esp)
  10459c:	e8 3f d4 ff ff       	call   1019e0 <dirlink>
  1045a1:	85 c0                	test   %eax,%eax
  1045a3:	78 17                	js     1045bc <sys_link+0xdc>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
  1045a5:	89 34 24             	mov    %esi,(%esp)
  1045a8:	e8 23 d5 ff ff       	call   101ad0 <iunlockput>
  iput(ip);
  1045ad:	89 1c 24             	mov    %ebx,(%esp)
  1045b0:	e8 cb d2 ff ff       	call   101880 <iput>
  1045b5:	31 c0                	xor    %eax,%eax
  return 0;
  1045b7:	e9 4f ff ff ff       	jmp    10450b <sys_link+0x2b>

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
  1045bc:	89 34 24             	mov    %esi,(%esp)
  1045bf:	e8 0c d5 ff ff       	call   101ad0 <iunlockput>
  iunlockput(dp);
  iput(ip);
  return 0;

bad:
  ilock(ip);
  1045c4:	89 1c 24             	mov    %ebx,(%esp)
  1045c7:	e8 f4 d5 ff ff       	call   101bc0 <ilock>
  ip->nlink--;
  1045cc:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
  1045d1:	89 1c 24             	mov    %ebx,(%esp)
  1045d4:	e8 97 ce ff ff       	call   101470 <iupdate>
  iunlockput(ip);
  1045d9:	89 1c 24             	mov    %ebx,(%esp)
  1045dc:	e8 ef d4 ff ff       	call   101ad0 <iunlockput>
  1045e1:	83 c8 ff             	or     $0xffffffff,%eax
  return -1;
  1045e4:	e9 22 ff ff ff       	jmp    10450b <sys_link+0x2b>
  1045e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001045f0 <sys_open>:
  return ip;
}

int
sys_open(void)
{
  1045f0:	55                   	push   %ebp
  1045f1:	89 e5                	mov    %esp,%ebp
  1045f3:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  1045f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return ip;
}

int
sys_open(void)
{
  1045f9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  1045fc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  1045ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  104603:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10460a:	e8 01 f9 ff ff       	call   103f10 <argstr>
  10460f:	85 c0                	test   %eax,%eax
  104611:	79 15                	jns    104628 <sys_open+0x38>

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  104613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
}
  104618:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  10461b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  10461e:	89 ec                	mov    %ebp,%esp
  104620:	5d                   	pop    %ebp
  104621:	c3                   	ret    
  104622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  104628:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10462b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10462f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104636:	e8 45 f8 ff ff       	call   103e80 <argint>
  10463b:	85 c0                	test   %eax,%eax
  10463d:	78 d4                	js     104613 <sys_open+0x23>
    return -1;
  if(omode & O_CREATE){
  10463f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104642:	f6 c4 02             	test   $0x2,%ah
  104645:	0f 84 b8 00 00 00    	je     104703 <sys_open+0x113>
    if (omode & O_EXTENT) {
  10464b:	f6 c4 03             	test   $0x3,%ah
  10464e:	66 90                	xchg   %ax,%ax
  104650:	74 66                	je     1046b8 <sys_open+0xc8>
      if((ip = create(path, T_EXTENT, 0, 0)) == 0)
  104652:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104659:	31 c9                	xor    %ecx,%ecx
  10465b:	ba 04 00 00 00       	mov    $0x4,%edx
        return -1;
    }
    else {
      if((ip = create(path, T_FILE, 0, 0)) == 0)
  104660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104663:	e8 08 fc ff ff       	call   104270 <create>
  104668:	85 c0                	test   %eax,%eax
  10466a:	89 c3                	mov    %eax,%ebx
  10466c:	74 a5                	je     104613 <sys_open+0x23>
      iunlockput(ip);
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
  10466e:	e8 8d c8 ff ff       	call   100f00 <filealloc>
  104673:	85 c0                	test   %eax,%eax
  104675:	89 c6                	mov    %eax,%esi
  104677:	74 27                	je     1046a0 <sys_open+0xb0>
  104679:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104680:	31 c0                	xor    %eax,%eax
  104682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104688:	8b 4c 82 28          	mov    0x28(%edx,%eax,4),%ecx
  10468c:	85 c9                	test   %ecx,%ecx
  10468e:	74 38                	je     1046c8 <sys_open+0xd8>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104690:	83 c0 01             	add    $0x1,%eax
  104693:	83 f8 10             	cmp    $0x10,%eax
  104696:	75 f0                	jne    104688 <sys_open+0x98>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
  104698:	89 34 24             	mov    %esi,(%esp)
  10469b:	e8 e0 c8 ff ff       	call   100f80 <fileclose>
    iunlockput(ip);
  1046a0:	89 1c 24             	mov    %ebx,(%esp)
  1046a3:	e8 28 d4 ff ff       	call   101ad0 <iunlockput>
  1046a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  1046ad:	e9 66 ff ff ff       	jmp    104618 <sys_open+0x28>
  1046b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if (omode & O_EXTENT) {
      if((ip = create(path, T_EXTENT, 0, 0)) == 0)
        return -1;
    }
    else {
      if((ip = create(path, T_FILE, 0, 0)) == 0)
  1046b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1046bf:	31 c9                	xor    %ecx,%ecx
  1046c1:	ba 02 00 00 00       	mov    $0x2,%edx
  1046c6:	eb 98                	jmp    104660 <sys_open+0x70>
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1046c8:	89 74 82 28          	mov    %esi,0x28(%edx,%eax,4)
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  1046cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1046cf:	89 1c 24             	mov    %ebx,(%esp)
  1046d2:	e8 99 d0 ff ff       	call   101770 <iunlock>

  f->type = FD_INODE;
  1046d7:	c7 06 02 00 00 00    	movl   $0x2,(%esi)
  f->ip = ip;
  1046dd:	89 5e 10             	mov    %ebx,0x10(%esi)
  f->off = 0;
  1046e0:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)
  f->readable = !(omode & O_WRONLY);
  1046e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1046ea:	83 f2 01             	xor    $0x1,%edx
  1046ed:	83 e2 01             	and    $0x1,%edx
  1046f0:	88 56 08             	mov    %dl,0x8(%esi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  1046f3:	f6 45 f0 03          	testb  $0x3,-0x10(%ebp)
  1046f7:	0f 95 46 09          	setne  0x9(%esi)
  return fd;
  1046fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1046fe:	e9 15 ff ff ff       	jmp    104618 <sys_open+0x28>
    else {
      if((ip = create(path, T_FILE, 0, 0)) == 0)
        return -1;
    }
  } else {
    if((ip = namei(path)) == 0)
  104703:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104706:	89 04 24             	mov    %eax,(%esp)
  104709:	e8 52 d7 ff ff       	call   101e60 <namei>
  10470e:	85 c0                	test   %eax,%eax
  104710:	89 c3                	mov    %eax,%ebx
  104712:	0f 84 fb fe ff ff    	je     104613 <sys_open+0x23>
      return -1;
    ilock(ip);
  104718:	89 04 24             	mov    %eax,(%esp)
  10471b:	e8 a0 d4 ff ff       	call   101bc0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
  104720:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  104725:	0f 85 43 ff ff ff    	jne    10466e <sys_open+0x7e>
  10472b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10472f:	90                   	nop
  104730:	0f 84 38 ff ff ff    	je     10466e <sys_open+0x7e>
  104736:	66 90                	xchg   %ax,%ax
  104738:	e9 63 ff ff ff       	jmp    1046a0 <sys_open+0xb0>
  10473d:	8d 76 00             	lea    0x0(%esi),%esi

00104740 <sys_unlink>:
  return 1;
}

int
sys_unlink(void)
{
  104740:	55                   	push   %ebp
  104741:	89 e5                	mov    %esp,%ebp
  104743:	83 ec 78             	sub    $0x78,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  104746:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 1;
}

int
sys_unlink(void)
{
  104749:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  10474c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10474f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  104752:	89 44 24 04          	mov    %eax,0x4(%esp)
  104756:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10475d:	e8 ae f7 ff ff       	call   103f10 <argstr>
  104762:	85 c0                	test   %eax,%eax
  104764:	79 12                	jns    104778 <sys_unlink+0x38>
  iunlockput(dp);

  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return 0;
  104766:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10476b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10476e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104771:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104774:	89 ec                	mov    %ebp,%esp
  104776:	5d                   	pop    %ebp
  104777:	c3                   	ret    
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
    return -1;
  if((dp = nameiparent(path, name)) == 0)
  104778:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10477b:	8d 5d d2             	lea    -0x2e(%ebp),%ebx
  10477e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104782:	89 04 24             	mov    %eax,(%esp)
  104785:	e8 b6 d6 ff ff       	call   101e40 <nameiparent>
  10478a:	85 c0                	test   %eax,%eax
  10478c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  10478f:	74 d5                	je     104766 <sys_unlink+0x26>
    return -1;
  ilock(dp);
  104791:	89 04 24             	mov    %eax,(%esp)
  104794:	e8 27 d4 ff ff       	call   101bc0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0){
  104799:	c7 44 24 04 48 6b 10 	movl   $0x106b48,0x4(%esp)
  1047a0:	00 
  1047a1:	89 1c 24             	mov    %ebx,(%esp)
  1047a4:	e8 97 ce ff ff       	call   101640 <namecmp>
  1047a9:	85 c0                	test   %eax,%eax
  1047ab:	0f 84 a4 00 00 00    	je     104855 <sys_unlink+0x115>
  1047b1:	c7 44 24 04 47 6b 10 	movl   $0x106b47,0x4(%esp)
  1047b8:	00 
  1047b9:	89 1c 24             	mov    %ebx,(%esp)
  1047bc:	e8 7f ce ff ff       	call   101640 <namecmp>
  1047c1:	85 c0                	test   %eax,%eax
  1047c3:	0f 84 8c 00 00 00    	je     104855 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }

  if((ip = dirlookup(dp, name, &off)) == 0){
  1047c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1047cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  1047d0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1047d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1047d7:	89 04 24             	mov    %eax,(%esp)
  1047da:	e8 91 ce ff ff       	call   101670 <dirlookup>
  1047df:	85 c0                	test   %eax,%eax
  1047e1:	89 c6                	mov    %eax,%esi
  1047e3:	74 70                	je     104855 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }
  ilock(ip);
  1047e5:	89 04 24             	mov    %eax,(%esp)
  1047e8:	e8 d3 d3 ff ff       	call   101bc0 <ilock>

  if(ip->nlink < 1)
  1047ed:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  1047f2:	0f 8e 0e 01 00 00    	jle    104906 <sys_unlink+0x1c6>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
  1047f8:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  1047fd:	75 71                	jne    104870 <sys_unlink+0x130>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
  1047ff:	83 7e 18 20          	cmpl   $0x20,0x18(%esi)
  104803:	76 6b                	jbe    104870 <sys_unlink+0x130>
  104805:	8d 7d b2             	lea    -0x4e(%ebp),%edi
  104808:	bb 20 00 00 00       	mov    $0x20,%ebx
  10480d:	8d 76 00             	lea    0x0(%esi),%esi
  104810:	eb 0e                	jmp    104820 <sys_unlink+0xe0>
  104812:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104818:	83 c3 10             	add    $0x10,%ebx
  10481b:	3b 5e 18             	cmp    0x18(%esi),%ebx
  10481e:	73 50                	jae    104870 <sys_unlink+0x130>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  104820:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  104827:	00 
  104828:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  10482c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104830:	89 34 24             	mov    %esi,(%esp)
  104833:	e8 38 cb ff ff       	call   101370 <readi>
  104838:	83 f8 10             	cmp    $0x10,%eax
  10483b:	0f 85 ad 00 00 00    	jne    1048ee <sys_unlink+0x1ae>
      panic("isdirempty: readi");
    if(de.inum != 0)
  104841:	66 83 7d b2 00       	cmpw   $0x0,-0x4e(%ebp)
  104846:	74 d0                	je     104818 <sys_unlink+0xd8>
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
  104848:	89 34 24             	mov    %esi,(%esp)
  10484b:	90                   	nop
  10484c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104850:	e8 7b d2 ff ff       	call   101ad0 <iunlockput>
    iunlockput(dp);
  104855:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104858:	89 04 24             	mov    %eax,(%esp)
  10485b:	e8 70 d2 ff ff       	call   101ad0 <iunlockput>
  104860:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104865:	e9 01 ff ff ff       	jmp    10476b <sys_unlink+0x2b>
  10486a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  memset(&de, 0, sizeof(de));
  104870:	8d 5d c2             	lea    -0x3e(%ebp),%ebx
  104873:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  10487a:	00 
  10487b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104882:	00 
  104883:	89 1c 24             	mov    %ebx,(%esp)
  104886:	e8 55 f3 ff ff       	call   103be0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  10488b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10488e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  104895:	00 
  104896:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10489a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10489e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1048a1:	89 04 24             	mov    %eax,(%esp)
  1048a4:	e8 57 cc ff ff       	call   101500 <writei>
  1048a9:	83 f8 10             	cmp    $0x10,%eax
  1048ac:	75 4c                	jne    1048fa <sys_unlink+0x1ba>
    panic("unlink: writei");
  if(ip->type == T_DIR){
  1048ae:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  1048b3:	74 27                	je     1048dc <sys_unlink+0x19c>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
  1048b5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1048b8:	89 04 24             	mov    %eax,(%esp)
  1048bb:	e8 10 d2 ff ff       	call   101ad0 <iunlockput>

  ip->nlink--;
  1048c0:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
  iupdate(ip);
  1048c5:	89 34 24             	mov    %esi,(%esp)
  1048c8:	e8 a3 cb ff ff       	call   101470 <iupdate>
  iunlockput(ip);
  1048cd:	89 34 24             	mov    %esi,(%esp)
  1048d0:	e8 fb d1 ff ff       	call   101ad0 <iunlockput>
  1048d5:	31 c0                	xor    %eax,%eax
  return 0;
  1048d7:	e9 8f fe ff ff       	jmp    10476b <sys_unlink+0x2b>

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
  1048dc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1048df:	66 83 68 16 01       	subw   $0x1,0x16(%eax)
    iupdate(dp);
  1048e4:	89 04 24             	mov    %eax,(%esp)
  1048e7:	e8 84 cb ff ff       	call   101470 <iupdate>
  1048ec:	eb c7                	jmp    1048b5 <sys_unlink+0x175>
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
  1048ee:	c7 04 24 78 6b 10 00 	movl   $0x106b78,(%esp)
  1048f5:	e8 26 c0 ff ff       	call   100920 <panic>
    return -1;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  1048fa:	c7 04 24 8a 6b 10 00 	movl   $0x106b8a,(%esp)
  104901:	e8 1a c0 ff ff       	call   100920 <panic>
    return -1;
  }
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  104906:	c7 04 24 66 6b 10 00 	movl   $0x106b66,(%esp)
  10490d:	e8 0e c0 ff ff       	call   100920 <panic>
  104912:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  104919:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104920 <T.68>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  104920:	55                   	push   %ebp
  104921:	89 e5                	mov    %esp,%ebp
  104923:	83 ec 28             	sub    $0x28,%esp
  104926:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  104929:	89 c3                	mov    %eax,%ebx
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  10492b:	8d 45 f4             	lea    -0xc(%ebp),%eax
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  10492e:	89 75 fc             	mov    %esi,-0x4(%ebp)
  104931:	89 d6                	mov    %edx,%esi
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  104933:	89 44 24 04          	mov    %eax,0x4(%esp)
  104937:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10493e:	e8 3d f5 ff ff       	call   103e80 <argint>
  104943:	85 c0                	test   %eax,%eax
  104945:	79 11                	jns    104958 <T.68+0x38>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  104947:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  10494c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  10494f:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104952:	89 ec                	mov    %ebp,%esp
  104954:	5d                   	pop    %ebp
  104955:	c3                   	ret    
  104956:	66 90                	xchg   %ax,%ax
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
  104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10495b:	83 f8 0f             	cmp    $0xf,%eax
  10495e:	77 e7                	ja     104947 <T.68+0x27>
  104960:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104967:	8b 54 82 28          	mov    0x28(%edx,%eax,4),%edx
  10496b:	85 d2                	test   %edx,%edx
  10496d:	74 d8                	je     104947 <T.68+0x27>
    return -1;
  if(pfd)
  10496f:	85 db                	test   %ebx,%ebx
  104971:	74 02                	je     104975 <T.68+0x55>
    *pfd = fd;
  104973:	89 03                	mov    %eax,(%ebx)
  if(pf)
  104975:	31 c0                	xor    %eax,%eax
  104977:	85 f6                	test   %esi,%esi
  104979:	74 d1                	je     10494c <T.68+0x2c>
    *pf = f;
  10497b:	89 16                	mov    %edx,(%esi)
  10497d:	eb cd                	jmp    10494c <T.68+0x2c>
  10497f:	90                   	nop

00104980 <sys_dup>:
  return -1;
}

int
sys_dup(void)
{
  104980:	55                   	push   %ebp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104981:	31 c0                	xor    %eax,%eax
  return -1;
}

int
sys_dup(void)
{
  104983:	89 e5                	mov    %esp,%ebp
  104985:	53                   	push   %ebx
  104986:	83 ec 24             	sub    $0x24,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104989:	8d 55 f4             	lea    -0xc(%ebp),%edx
  10498c:	e8 8f ff ff ff       	call   104920 <T.68>
  104991:	85 c0                	test   %eax,%eax
  104993:	79 13                	jns    1049a8 <sys_dup+0x28>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104995:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
}
  10499a:	89 d8                	mov    %ebx,%eax
  10499c:	83 c4 24             	add    $0x24,%esp
  10499f:	5b                   	pop    %ebx
  1049a0:	5d                   	pop    %ebp
  1049a1:	c3                   	ret    
  1049a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
  1049a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1049ab:	31 db                	xor    %ebx,%ebx
  1049ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1049b3:	eb 0b                	jmp    1049c0 <sys_dup+0x40>
  1049b5:	8d 76 00             	lea    0x0(%esi),%esi
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  1049b8:	83 c3 01             	add    $0x1,%ebx
  1049bb:	83 fb 10             	cmp    $0x10,%ebx
  1049be:	74 d5                	je     104995 <sys_dup+0x15>
    if(proc->ofile[fd] == 0){
  1049c0:	8b 4c 98 28          	mov    0x28(%eax,%ebx,4),%ecx
  1049c4:	85 c9                	test   %ecx,%ecx
  1049c6:	75 f0                	jne    1049b8 <sys_dup+0x38>
      proc->ofile[fd] = f;
  1049c8:	89 54 98 28          	mov    %edx,0x28(%eax,%ebx,4)
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  1049cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049cf:	89 04 24             	mov    %eax,(%esp)
  1049d2:	e8 d9 c4 ff ff       	call   100eb0 <filedup>
  return fd;
  1049d7:	eb c1                	jmp    10499a <sys_dup+0x1a>
  1049d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001049e0 <sys_read>:
}

int
sys_read(void)
{
  1049e0:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  1049e1:	31 c0                	xor    %eax,%eax
  return fd;
}

int
sys_read(void)
{
  1049e3:	89 e5                	mov    %esp,%ebp
  1049e5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  1049e8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  1049eb:	e8 30 ff ff ff       	call   104920 <T.68>
  1049f0:	85 c0                	test   %eax,%eax
  1049f2:	79 0c                	jns    104a00 <sys_read+0x20>
    return -1;
  return fileread(f, p, n);
  1049f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1049f9:	c9                   	leave  
  1049fa:	c3                   	ret    
  1049fb:	90                   	nop
  1049fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104a00:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104a03:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a07:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104a0e:	e8 6d f4 ff ff       	call   103e80 <argint>
  104a13:	85 c0                	test   %eax,%eax
  104a15:	78 dd                	js     1049f4 <sys_read+0x14>
  104a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a21:	89 44 24 08          	mov    %eax,0x8(%esp)
  104a25:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104a28:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a2c:	e8 8f f4 ff ff       	call   103ec0 <argptr>
  104a31:	85 c0                	test   %eax,%eax
  104a33:	78 bf                	js     1049f4 <sys_read+0x14>
    return -1;
  return fileread(f, p, n);
  104a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a38:	89 44 24 08          	mov    %eax,0x8(%esp)
  104a3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a46:	89 04 24             	mov    %eax,(%esp)
  104a49:	e8 62 c3 ff ff       	call   100db0 <fileread>
}
  104a4e:	c9                   	leave  
  104a4f:	c3                   	ret    

00104a50 <sys_write>:

int
sys_write(void)
{
  104a50:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104a51:	31 c0                	xor    %eax,%eax
  return fileread(f, p, n);
}

int
sys_write(void)
{
  104a53:	89 e5                	mov    %esp,%ebp
  104a55:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104a58:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104a5b:	e8 c0 fe ff ff       	call   104920 <T.68>
  104a60:	85 c0                	test   %eax,%eax
  104a62:	79 0c                	jns    104a70 <sys_write+0x20>
    return -1;
  return filewrite(f, p, n);
  104a64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104a69:	c9                   	leave  
  104a6a:	c3                   	ret    
  104a6b:	90                   	nop
  104a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104a70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a77:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104a7e:	e8 fd f3 ff ff       	call   103e80 <argint>
  104a83:	85 c0                	test   %eax,%eax
  104a85:	78 dd                	js     104a64 <sys_write+0x14>
  104a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a91:	89 44 24 08          	mov    %eax,0x8(%esp)
  104a95:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a9c:	e8 1f f4 ff ff       	call   103ec0 <argptr>
  104aa1:	85 c0                	test   %eax,%eax
  104aa3:	78 bf                	js     104a64 <sys_write+0x14>
    return -1;
  return filewrite(f, p, n);
  104aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104aa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  104aac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  104ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ab6:	89 04 24             	mov    %eax,(%esp)
  104ab9:	e8 42 c2 ff ff       	call   100d00 <filewrite>
}
  104abe:	c9                   	leave  
  104abf:	c3                   	ret    

00104ac0 <sys_fstat>:
  return 0;
}

int
sys_fstat(void)
{
  104ac0:	55                   	push   %ebp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104ac1:	31 c0                	xor    %eax,%eax
  return 0;
}

int
sys_fstat(void)
{
  104ac3:	89 e5                	mov    %esp,%ebp
  104ac5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104ac8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104acb:	e8 50 fe ff ff       	call   104920 <T.68>
  104ad0:	85 c0                	test   %eax,%eax
  104ad2:	79 0c                	jns    104ae0 <sys_fstat+0x20>
    return -1;
  return filestat(f, st);
  104ad4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104ad9:	c9                   	leave  
  104ada:	c3                   	ret    
  104adb:	90                   	nop
  104adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_fstat(void)
{
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104ae0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104ae3:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
  104aea:	00 
  104aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  104aef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104af6:	e8 c5 f3 ff ff       	call   103ec0 <argptr>
  104afb:	85 c0                	test   %eax,%eax
  104afd:	78 d5                	js     104ad4 <sys_fstat+0x14>
    return -1;
  return filestat(f, st);
  104aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  104b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b09:	89 04 24             	mov    %eax,(%esp)
  104b0c:	e8 4f c3 ff ff       	call   100e60 <filestat>
}
  104b11:	c9                   	leave  
  104b12:	c3                   	ret    
  104b13:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104b19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104b20 <sys_close>:
  return filewrite(f, p, n);
}

int
sys_close(void)
{
  104b20:	55                   	push   %ebp
  104b21:	89 e5                	mov    %esp,%ebp
  104b23:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
  104b26:	8d 55 f0             	lea    -0x10(%ebp),%edx
  104b29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104b2c:	e8 ef fd ff ff       	call   104920 <T.68>
  104b31:	89 c2                	mov    %eax,%edx
  104b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104b38:	85 d2                	test   %edx,%edx
  104b3a:	78 1e                	js     104b5a <sys_close+0x3a>
    return -1;
  proc->ofile[fd] = 0;
  104b3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104b42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104b45:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
  104b4c:	00 
  fileclose(f);
  104b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b50:	89 04 24             	mov    %eax,(%esp)
  104b53:	e8 28 c4 ff ff       	call   100f80 <fileclose>
  104b58:	31 c0                	xor    %eax,%eax
  return 0;
}
  104b5a:	c9                   	leave  
  104b5b:	c3                   	ret    
  104b5c:	90                   	nop
  104b5d:	90                   	nop
  104b5e:	90                   	nop
  104b5f:	90                   	nop

00104b60 <sys_getpid>:
}

int
sys_getpid(void)
{
  return proc->pid;
  104b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return kill(pid);
}

int
sys_getpid(void)
{
  104b66:	55                   	push   %ebp
  104b67:	89 e5                	mov    %esp,%ebp
  return proc->pid;
}
  104b69:	5d                   	pop    %ebp
}

int
sys_getpid(void)
{
  return proc->pid;
  104b6a:	8b 40 10             	mov    0x10(%eax),%eax
}
  104b6d:	c3                   	ret    
  104b6e:	66 90                	xchg   %ax,%ax

00104b70 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since boot.
int
sys_uptime(void)
{
  104b70:	55                   	push   %ebp
  104b71:	89 e5                	mov    %esp,%ebp
  104b73:	53                   	push   %ebx
  104b74:	83 ec 14             	sub    $0x14,%esp
  uint xticks;
  
  acquire(&tickslock);
  104b77:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104b7e:	e8 bd ef ff ff       	call   103b40 <acquire>
  xticks = ticks;
  104b83:	8b 1d a0 e8 10 00    	mov    0x10e8a0,%ebx
  release(&tickslock);
  104b89:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104b90:	e8 5b ef ff ff       	call   103af0 <release>
  return xticks;
}
  104b95:	83 c4 14             	add    $0x14,%esp
  104b98:	89 d8                	mov    %ebx,%eax
  104b9a:	5b                   	pop    %ebx
  104b9b:	5d                   	pop    %ebp
  104b9c:	c3                   	ret    
  104b9d:	8d 76 00             	lea    0x0(%esi),%esi

00104ba0 <sys_sleep>:
  return addr;
}

int
sys_sleep(void)
{
  104ba0:	55                   	push   %ebp
  104ba1:	89 e5                	mov    %esp,%ebp
  104ba3:	53                   	push   %ebx
  104ba4:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
  104ba7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  104bae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104bb5:	e8 c6 f2 ff ff       	call   103e80 <argint>
  104bba:	89 c2                	mov    %eax,%edx
  104bbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104bc1:	85 d2                	test   %edx,%edx
  104bc3:	78 59                	js     104c1e <sys_sleep+0x7e>
    return -1;
  acquire(&tickslock);
  104bc5:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104bcc:	e8 6f ef ff ff       	call   103b40 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104bd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  104bd4:	8b 1d a0 e8 10 00    	mov    0x10e8a0,%ebx
  while(ticks - ticks0 < n){
  104bda:	85 d2                	test   %edx,%edx
  104bdc:	75 22                	jne    104c00 <sys_sleep+0x60>
  104bde:	eb 48                	jmp    104c28 <sys_sleep+0x88>
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  104be0:	c7 44 24 04 60 e0 10 	movl   $0x10e060,0x4(%esp)
  104be7:	00 
  104be8:	c7 04 24 a0 e8 10 00 	movl   $0x10e8a0,(%esp)
  104bef:	e8 6c e6 ff ff       	call   103260 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104bf4:	a1 a0 e8 10 00       	mov    0x10e8a0,%eax
  104bf9:	29 d8                	sub    %ebx,%eax
  104bfb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104bfe:	73 28                	jae    104c28 <sys_sleep+0x88>
    if(proc->killed){
  104c00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104c06:	8b 40 24             	mov    0x24(%eax),%eax
  104c09:	85 c0                	test   %eax,%eax
  104c0b:	74 d3                	je     104be0 <sys_sleep+0x40>
      release(&tickslock);
  104c0d:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104c14:	e8 d7 ee ff ff       	call   103af0 <release>
  104c19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
  104c1e:	83 c4 24             	add    $0x24,%esp
  104c21:	5b                   	pop    %ebx
  104c22:	5d                   	pop    %ebp
  104c23:	c3                   	ret    
  104c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104c28:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104c2f:	e8 bc ee ff ff       	call   103af0 <release>
  return 0;
}
  104c34:	83 c4 24             	add    $0x24,%esp
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104c37:	31 c0                	xor    %eax,%eax
  return 0;
}
  104c39:	5b                   	pop    %ebx
  104c3a:	5d                   	pop    %ebp
  104c3b:	c3                   	ret    
  104c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104c40 <sys_sbrk>:
  return proc->pid;
}

int
sys_sbrk(void)
{
  104c40:	55                   	push   %ebp
  104c41:	89 e5                	mov    %esp,%ebp
  104c43:	53                   	push   %ebx
  104c44:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
  104c47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104c55:	e8 26 f2 ff ff       	call   103e80 <argint>
  104c5a:	85 c0                	test   %eax,%eax
  104c5c:	79 12                	jns    104c70 <sys_sbrk+0x30>
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
  104c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104c63:	83 c4 24             	add    $0x24,%esp
  104c66:	5b                   	pop    %ebx
  104c67:	5d                   	pop    %ebp
  104c68:	c3                   	ret    
  104c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104c70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104c76:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
  104c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c7b:	89 04 24             	mov    %eax,(%esp)
  104c7e:	e8 9d eb ff ff       	call   103820 <growproc>
  104c83:	89 c2                	mov    %eax,%edx
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104c85:	89 d8                	mov    %ebx,%eax
  if(growproc(n) < 0)
  104c87:	85 d2                	test   %edx,%edx
  104c89:	79 d8                	jns    104c63 <sys_sbrk+0x23>
  104c8b:	eb d1                	jmp    104c5e <sys_sbrk+0x1e>
  104c8d:	8d 76 00             	lea    0x0(%esi),%esi

00104c90 <sys_kill>:
  return wait();
}

int
sys_kill(void)
{
  104c90:	55                   	push   %ebp
  104c91:	89 e5                	mov    %esp,%ebp
  104c93:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
  104c96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104ca4:	e8 d7 f1 ff ff       	call   103e80 <argint>
  104ca9:	89 c2                	mov    %eax,%edx
  104cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104cb0:	85 d2                	test   %edx,%edx
  104cb2:	78 0b                	js     104cbf <sys_kill+0x2f>
    return -1;
  return kill(pid);
  104cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104cb7:	89 04 24             	mov    %eax,(%esp)
  104cba:	e8 f1 e3 ff ff       	call   1030b0 <kill>
}
  104cbf:	c9                   	leave  
  104cc0:	c3                   	ret    
  104cc1:	eb 0d                	jmp    104cd0 <sys_wait>
  104cc3:	90                   	nop
  104cc4:	90                   	nop
  104cc5:	90                   	nop
  104cc6:	90                   	nop
  104cc7:	90                   	nop
  104cc8:	90                   	nop
  104cc9:	90                   	nop
  104cca:	90                   	nop
  104ccb:	90                   	nop
  104ccc:	90                   	nop
  104ccd:	90                   	nop
  104cce:	90                   	nop
  104ccf:	90                   	nop

00104cd0 <sys_wait>:
  return 0;  // not reached
}

int
sys_wait(void)
{
  104cd0:	55                   	push   %ebp
  104cd1:	89 e5                	mov    %esp,%ebp
  104cd3:	83 ec 08             	sub    $0x8,%esp
  return wait();
}
  104cd6:	c9                   	leave  
}

int
sys_wait(void)
{
  return wait();
  104cd7:	e9 34 e7 ff ff       	jmp    103410 <wait>
  104cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104ce0 <sys_exit>:
  return fork();
}

int
sys_exit(void)
{
  104ce0:	55                   	push   %ebp
  104ce1:	89 e5                	mov    %esp,%ebp
  104ce3:	83 ec 08             	sub    $0x8,%esp
  exit();
  104ce6:	e8 25 e8 ff ff       	call   103510 <exit>
  return 0;  // not reached
}
  104ceb:	31 c0                	xor    %eax,%eax
  104ced:	c9                   	leave  
  104cee:	c3                   	ret    
  104cef:	90                   	nop

00104cf0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  104cf0:	55                   	push   %ebp
  104cf1:	89 e5                	mov    %esp,%ebp
  104cf3:	83 ec 08             	sub    $0x8,%esp
  return fork();
}
  104cf6:	c9                   	leave  
#include "proc.h"

int
sys_fork(void)
{
  return fork();
  104cf7:	e9 24 ea ff ff       	jmp    103720 <fork>
  104cfc:	90                   	nop
  104cfd:	90                   	nop
  104cfe:	90                   	nop
  104cff:	90                   	nop

00104d00 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
  104d00:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  104d01:	ba 43 00 00 00       	mov    $0x43,%edx
  104d06:	89 e5                	mov    %esp,%ebp
  104d08:	83 ec 18             	sub    $0x18,%esp
  104d0b:	b8 34 00 00 00       	mov    $0x34,%eax
  104d10:	ee                   	out    %al,(%dx)
  104d11:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
  104d16:	b2 40                	mov    $0x40,%dl
  104d18:	ee                   	out    %al,(%dx)
  104d19:	b8 2e 00 00 00       	mov    $0x2e,%eax
  104d1e:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
  104d1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104d26:	e8 75 de ff ff       	call   102ba0 <picenable>
}
  104d2b:	c9                   	leave  
  104d2c:	c3                   	ret    
  104d2d:	90                   	nop
  104d2e:	90                   	nop
  104d2f:	90                   	nop

00104d30 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
  104d30:	1e                   	push   %ds
  pushl %es
  104d31:	06                   	push   %es
  pushl %fs
  104d32:	0f a0                	push   %fs
  pushl %gs
  104d34:	0f a8                	push   %gs
  pushal
  104d36:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
  104d37:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
  104d3b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
  104d3d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
  104d3f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
  104d43:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
  104d45:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
  104d47:	54                   	push   %esp
  call trap
  104d48:	e8 43 00 00 00       	call   104d90 <trap>
  addl $4, %esp
  104d4d:	83 c4 04             	add    $0x4,%esp

00104d50 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
  104d50:	61                   	popa   
  popl %gs
  104d51:	0f a9                	pop    %gs
  popl %fs
  104d53:	0f a1                	pop    %fs
  popl %es
  104d55:	07                   	pop    %es
  popl %ds
  104d56:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
  104d57:	83 c4 08             	add    $0x8,%esp
  iret
  104d5a:	cf                   	iret   
  104d5b:	90                   	nop
  104d5c:	90                   	nop
  104d5d:	90                   	nop
  104d5e:	90                   	nop
  104d5f:	90                   	nop

00104d60 <idtinit>:
  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  104d60:	55                   	push   %ebp
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  pd[1] = (uint)p;
  104d61:	b8 a0 e0 10 00       	mov    $0x10e0a0,%eax
  104d66:	89 e5                	mov    %esp,%ebp
  104d68:	83 ec 10             	sub    $0x10,%esp
static inline void
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  104d6b:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
  104d71:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
  104d75:	c1 e8 10             	shr    $0x10,%eax
  104d78:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
  104d7c:	8d 45 fa             	lea    -0x6(%ebp),%eax
  104d7f:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
  104d82:	c9                   	leave  
  104d83:	c3                   	ret    
  104d84:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104d8a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00104d90 <trap>:

void
trap(struct trapframe *tf)
{
  104d90:	55                   	push   %ebp
  104d91:	89 e5                	mov    %esp,%ebp
  104d93:	56                   	push   %esi
  104d94:	53                   	push   %ebx
  104d95:	83 ec 20             	sub    $0x20,%esp
  104d98:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
  104d9b:	8b 43 30             	mov    0x30(%ebx),%eax
  104d9e:	83 f8 40             	cmp    $0x40,%eax
  104da1:	0f 84 c9 00 00 00    	je     104e70 <trap+0xe0>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  104da7:	8d 50 e0             	lea    -0x20(%eax),%edx
  104daa:	83 fa 1f             	cmp    $0x1f,%edx
  104dad:	0f 86 b5 00 00 00    	jbe    104e68 <trap+0xd8>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
  104db3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104dba:	85 d2                	test   %edx,%edx
  104dbc:	0f 84 f6 01 00 00    	je     104fb8 <trap+0x228>
  104dc2:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
  104dc6:	0f 84 ec 01 00 00    	je     104fb8 <trap+0x228>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
  104dcc:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
  104dcf:	8b 4a 10             	mov    0x10(%edx),%ecx
  104dd2:	83 c2 6c             	add    $0x6c,%edx
  104dd5:	89 74 24 1c          	mov    %esi,0x1c(%esp)
  104dd9:	8b 73 38             	mov    0x38(%ebx),%esi
  104ddc:	89 74 24 18          	mov    %esi,0x18(%esp)
  104de0:	65 8b 35 00 00 00 00 	mov    %gs:0x0,%esi
  104de7:	0f b6 36             	movzbl (%esi),%esi
  104dea:	89 74 24 14          	mov    %esi,0x14(%esp)
  104dee:	8b 73 34             	mov    0x34(%ebx),%esi
  104df1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104df5:	89 54 24 08          	mov    %edx,0x8(%esp)
  104df9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104dfd:	89 74 24 10          	mov    %esi,0x10(%esp)
  104e01:	c7 04 24 f4 6b 10 00 	movl   $0x106bf4,(%esp)
  104e08:	e8 23 b7 ff ff       	call   100530 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
  104e0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104e13:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  104e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  104e20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104e26:	85 c0                	test   %eax,%eax
  104e28:	74 34                	je     104e5e <trap+0xce>
  104e2a:	8b 50 24             	mov    0x24(%eax),%edx
  104e2d:	85 d2                	test   %edx,%edx
  104e2f:	74 10                	je     104e41 <trap+0xb1>
  104e31:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
  104e35:	83 e2 03             	and    $0x3,%edx
  104e38:	83 fa 03             	cmp    $0x3,%edx
  104e3b:	0f 84 5f 01 00 00    	je     104fa0 <trap+0x210>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  104e41:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
  104e45:	0f 84 2d 01 00 00    	je     104f78 <trap+0x1e8>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  104e4b:	8b 40 24             	mov    0x24(%eax),%eax
  104e4e:	85 c0                	test   %eax,%eax
  104e50:	74 0c                	je     104e5e <trap+0xce>
  104e52:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  104e56:	83 e0 03             	and    $0x3,%eax
  104e59:	83 f8 03             	cmp    $0x3,%eax
  104e5c:	74 34                	je     104e92 <trap+0x102>
    exit();
}
  104e5e:	83 c4 20             	add    $0x20,%esp
  104e61:	5b                   	pop    %ebx
  104e62:	5e                   	pop    %esi
  104e63:	5d                   	pop    %ebp
  104e64:	c3                   	ret    
  104e65:	8d 76 00             	lea    0x0(%esi),%esi
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  104e68:	ff 24 95 44 6c 10 00 	jmp    *0x106c44(,%edx,4)
  104e6f:	90                   	nop

void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
  104e70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104e76:	8b 70 24             	mov    0x24(%eax),%esi
  104e79:	85 f6                	test   %esi,%esi
  104e7b:	75 23                	jne    104ea0 <trap+0x110>
      exit();
    proc->tf = tf;
  104e7d:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
  104e80:	e8 fb f0 ff ff       	call   103f80 <syscall>
    if(proc->killed)
  104e85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104e8b:	8b 48 24             	mov    0x24(%eax),%ecx
  104e8e:	85 c9                	test   %ecx,%ecx
  104e90:	74 cc                	je     104e5e <trap+0xce>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
  104e92:	83 c4 20             	add    $0x20,%esp
  104e95:	5b                   	pop    %ebx
  104e96:	5e                   	pop    %esi
  104e97:	5d                   	pop    %ebp
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  104e98:	e9 73 e6 ff ff       	jmp    103510 <exit>
  104e9d:	8d 76 00             	lea    0x0(%esi),%esi
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
      exit();
  104ea0:	e8 6b e6 ff ff       	call   103510 <exit>
  104ea5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104eab:	eb d0                	jmp    104e7d <trap+0xed>
  104ead:	8d 76 00             	lea    0x0(%esi),%esi
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
  104eb0:	e8 6b d1 ff ff       	call   102020 <ideintr>
    lapiceoi();
  104eb5:	e8 a6 d5 ff ff       	call   102460 <lapiceoi>
    break;
  104eba:	e9 61 ff ff ff       	jmp    104e20 <trap+0x90>
  104ebf:	90                   	nop
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
  104ec0:	8b 43 38             	mov    0x38(%ebx),%eax
  104ec3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104ec7:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  104ecb:	89 44 24 08          	mov    %eax,0x8(%esp)
  104ecf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  104ed5:	0f b6 00             	movzbl (%eax),%eax
  104ed8:	c7 04 24 9c 6b 10 00 	movl   $0x106b9c,(%esp)
  104edf:	89 44 24 04          	mov    %eax,0x4(%esp)
  104ee3:	e8 48 b6 ff ff       	call   100530 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
  104ee8:	e8 73 d5 ff ff       	call   102460 <lapiceoi>
    break;
  104eed:	e9 2e ff ff ff       	jmp    104e20 <trap+0x90>
  104ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104ef8:	90                   	nop
  104ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
  104f00:	e8 ab 01 00 00       	call   1050b0 <uartintr>
  104f05:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  104f08:	e8 53 d5 ff ff       	call   102460 <lapiceoi>
  104f0d:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  104f10:	e9 0b ff ff ff       	jmp    104e20 <trap+0x90>
  104f15:	8d 76 00             	lea    0x0(%esi),%esi
  104f18:	90                   	nop
  104f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
  104f20:	e8 1b d5 ff ff       	call   102440 <kbdintr>
  104f25:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  104f28:	e8 33 d5 ff ff       	call   102460 <lapiceoi>
  104f2d:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  104f30:	e9 eb fe ff ff       	jmp    104e20 <trap+0x90>
  104f35:	8d 76 00             	lea    0x0(%esi),%esi
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
  104f38:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  104f3e:	80 38 00             	cmpb   $0x0,(%eax)
  104f41:	0f 85 6e ff ff ff    	jne    104eb5 <trap+0x125>
      acquire(&tickslock);
  104f47:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104f4e:	e8 ed eb ff ff       	call   103b40 <acquire>
      ticks++;
  104f53:	83 05 a0 e8 10 00 01 	addl   $0x1,0x10e8a0
      wakeup(&ticks);
  104f5a:	c7 04 24 a0 e8 10 00 	movl   $0x10e8a0,(%esp)
  104f61:	e8 da e1 ff ff       	call   103140 <wakeup>
      release(&tickslock);
  104f66:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104f6d:	e8 7e eb ff ff       	call   103af0 <release>
  104f72:	e9 3e ff ff ff       	jmp    104eb5 <trap+0x125>
  104f77:	90                   	nop
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  104f78:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
  104f7c:	0f 85 c9 fe ff ff    	jne    104e4b <trap+0xbb>
  104f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    yield();
  104f88:	e8 a3 e3 ff ff       	call   103330 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  104f8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104f93:	85 c0                	test   %eax,%eax
  104f95:	0f 85 b0 fe ff ff    	jne    104e4b <trap+0xbb>
  104f9b:	e9 be fe ff ff       	jmp    104e5e <trap+0xce>

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  104fa0:	e8 6b e5 ff ff       	call   103510 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  104fa5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104fab:	85 c0                	test   %eax,%eax
  104fad:	0f 85 8e fe ff ff    	jne    104e41 <trap+0xb1>
  104fb3:	e9 a6 fe ff ff       	jmp    104e5e <trap+0xce>
  104fb8:	0f 20 d2             	mov    %cr2,%edx
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
  104fbb:	89 54 24 10          	mov    %edx,0x10(%esp)
  104fbf:	8b 53 38             	mov    0x38(%ebx),%edx
  104fc2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  104fc6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  104fcd:	0f b6 12             	movzbl (%edx),%edx
  104fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  104fd4:	c7 04 24 c0 6b 10 00 	movl   $0x106bc0,(%esp)
  104fdb:	89 54 24 08          	mov    %edx,0x8(%esp)
  104fdf:	e8 4c b5 ff ff       	call   100530 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
  104fe4:	c7 04 24 37 6c 10 00 	movl   $0x106c37,(%esp)
  104feb:	e8 30 b9 ff ff       	call   100920 <panic>

00104ff0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  104ff0:	55                   	push   %ebp
  104ff1:	31 c0                	xor    %eax,%eax
  104ff3:	89 e5                	mov    %esp,%ebp
  104ff5:	ba a0 e0 10 00       	mov    $0x10e0a0,%edx
  104ffa:	83 ec 18             	sub    $0x18,%esp
  104ffd:	8d 76 00             	lea    0x0(%esi),%esi
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  105000:	8b 0c 85 28 73 10 00 	mov    0x107328(,%eax,4),%ecx
  105007:	66 89 0c c5 a0 e0 10 	mov    %cx,0x10e0a0(,%eax,8)
  10500e:	00 
  10500f:	c1 e9 10             	shr    $0x10,%ecx
  105012:	66 c7 44 c2 02 08 00 	movw   $0x8,0x2(%edx,%eax,8)
  105019:	c6 44 c2 04 00       	movb   $0x0,0x4(%edx,%eax,8)
  10501e:	c6 44 c2 05 8e       	movb   $0x8e,0x5(%edx,%eax,8)
  105023:	66 89 4c c2 06       	mov    %cx,0x6(%edx,%eax,8)
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
  105028:	83 c0 01             	add    $0x1,%eax
  10502b:	3d 00 01 00 00       	cmp    $0x100,%eax
  105030:	75 ce                	jne    105000 <tvinit+0x10>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  105032:	a1 28 74 10 00       	mov    0x107428,%eax
  
  initlock(&tickslock, "time");
  105037:	c7 44 24 04 3c 6c 10 	movl   $0x106c3c,0x4(%esp)
  10503e:	00 
  10503f:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  105046:	66 c7 05 a2 e2 10 00 	movw   $0x8,0x10e2a2
  10504d:	08 00 
  10504f:	66 a3 a0 e2 10 00    	mov    %ax,0x10e2a0
  105055:	c1 e8 10             	shr    $0x10,%eax
  105058:	c6 05 a4 e2 10 00 00 	movb   $0x0,0x10e2a4
  10505f:	c6 05 a5 e2 10 00 ef 	movb   $0xef,0x10e2a5
  105066:	66 a3 a6 e2 10 00    	mov    %ax,0x10e2a6
  
  initlock(&tickslock, "time");
  10506c:	e8 3f e9 ff ff       	call   1039b0 <initlock>
}
  105071:	c9                   	leave  
  105072:	c3                   	ret    
  105073:	90                   	nop
  105074:	90                   	nop
  105075:	90                   	nop
  105076:	90                   	nop
  105077:	90                   	nop
  105078:	90                   	nop
  105079:	90                   	nop
  10507a:	90                   	nop
  10507b:	90                   	nop
  10507c:	90                   	nop
  10507d:	90                   	nop
  10507e:	90                   	nop
  10507f:	90                   	nop

00105080 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
  105080:	a1 cc 78 10 00       	mov    0x1078cc,%eax
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
  105085:	55                   	push   %ebp
  105086:	89 e5                	mov    %esp,%ebp
  if(!uart)
  105088:	85 c0                	test   %eax,%eax
  10508a:	75 0c                	jne    105098 <uartgetc+0x18>
    return -1;
  if(!(inb(COM1+5) & 0x01))
    return -1;
  return inb(COM1+0);
  10508c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  105091:	5d                   	pop    %ebp
  105092:	c3                   	ret    
  105093:	90                   	nop
  105094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105098:	ba fd 03 00 00       	mov    $0x3fd,%edx
  10509d:	ec                   	in     (%dx),%al
static int
uartgetc(void)
{
  if(!uart)
    return -1;
  if(!(inb(COM1+5) & 0x01))
  10509e:	a8 01                	test   $0x1,%al
  1050a0:	74 ea                	je     10508c <uartgetc+0xc>
  1050a2:	b2 f8                	mov    $0xf8,%dl
  1050a4:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
  1050a5:	0f b6 c0             	movzbl %al,%eax
}
  1050a8:	5d                   	pop    %ebp
  1050a9:	c3                   	ret    
  1050aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001050b0 <uartintr>:

void
uartintr(void)
{
  1050b0:	55                   	push   %ebp
  1050b1:	89 e5                	mov    %esp,%ebp
  1050b3:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
  1050b6:	c7 04 24 80 50 10 00 	movl   $0x105080,(%esp)
  1050bd:	e8 ce b6 ff ff       	call   100790 <consoleintr>
}
  1050c2:	c9                   	leave  
  1050c3:	c3                   	ret    
  1050c4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1050ca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001050d0 <uartputc>:
    uartputc(*p);
}

void
uartputc(int c)
{
  1050d0:	55                   	push   %ebp
  1050d1:	89 e5                	mov    %esp,%ebp
  1050d3:	56                   	push   %esi
  1050d4:	be fd 03 00 00       	mov    $0x3fd,%esi
  1050d9:	53                   	push   %ebx
  int i;

  if(!uart)
  1050da:	31 db                	xor    %ebx,%ebx
    uartputc(*p);
}

void
uartputc(int c)
{
  1050dc:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(!uart)
  1050df:	8b 15 cc 78 10 00    	mov    0x1078cc,%edx
  1050e5:	85 d2                	test   %edx,%edx
  1050e7:	75 1e                	jne    105107 <uartputc+0x37>
  1050e9:	eb 2c                	jmp    105117 <uartputc+0x47>
  1050eb:	90                   	nop
  1050ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1050f0:	83 c3 01             	add    $0x1,%ebx
    microdelay(10);
  1050f3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1050fa:	e8 81 d3 ff ff       	call   102480 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1050ff:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  105105:	74 07                	je     10510e <uartputc+0x3e>
  105107:	89 f2                	mov    %esi,%edx
  105109:	ec                   	in     (%dx),%al
  10510a:	a8 20                	test   $0x20,%al
  10510c:	74 e2                	je     1050f0 <uartputc+0x20>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  10510e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  105113:	8b 45 08             	mov    0x8(%ebp),%eax
  105116:	ee                   	out    %al,(%dx)
    microdelay(10);
  outb(COM1+0, c);
}
  105117:	83 c4 10             	add    $0x10,%esp
  10511a:	5b                   	pop    %ebx
  10511b:	5e                   	pop    %esi
  10511c:	5d                   	pop    %ebp
  10511d:	c3                   	ret    
  10511e:	66 90                	xchg   %ax,%ax

00105120 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
  105120:	55                   	push   %ebp
  105121:	31 c9                	xor    %ecx,%ecx
  105123:	89 e5                	mov    %esp,%ebp
  105125:	89 c8                	mov    %ecx,%eax
  105127:	57                   	push   %edi
  105128:	bf fa 03 00 00       	mov    $0x3fa,%edi
  10512d:	56                   	push   %esi
  10512e:	89 fa                	mov    %edi,%edx
  105130:	53                   	push   %ebx
  105131:	83 ec 1c             	sub    $0x1c,%esp
  105134:	ee                   	out    %al,(%dx)
  105135:	bb fb 03 00 00       	mov    $0x3fb,%ebx
  10513a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  10513f:	89 da                	mov    %ebx,%edx
  105141:	ee                   	out    %al,(%dx)
  105142:	b8 0c 00 00 00       	mov    $0xc,%eax
  105147:	b2 f8                	mov    $0xf8,%dl
  105149:	ee                   	out    %al,(%dx)
  10514a:	be f9 03 00 00       	mov    $0x3f9,%esi
  10514f:	89 c8                	mov    %ecx,%eax
  105151:	89 f2                	mov    %esi,%edx
  105153:	ee                   	out    %al,(%dx)
  105154:	b8 03 00 00 00       	mov    $0x3,%eax
  105159:	89 da                	mov    %ebx,%edx
  10515b:	ee                   	out    %al,(%dx)
  10515c:	b2 fc                	mov    $0xfc,%dl
  10515e:	89 c8                	mov    %ecx,%eax
  105160:	ee                   	out    %al,(%dx)
  105161:	b8 01 00 00 00       	mov    $0x1,%eax
  105166:	89 f2                	mov    %esi,%edx
  105168:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105169:	b2 fd                	mov    $0xfd,%dl
  10516b:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
  10516c:	3c ff                	cmp    $0xff,%al
  10516e:	74 55                	je     1051c5 <uartinit+0xa5>
    return;
  uart = 1;
  105170:	c7 05 cc 78 10 00 01 	movl   $0x1,0x1078cc
  105177:	00 00 00 
  10517a:	89 fa                	mov    %edi,%edx
  10517c:	ec                   	in     (%dx),%al
  10517d:	b2 f8                	mov    $0xf8,%dl
  10517f:	ec                   	in     (%dx),%al
  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  105180:	bb c4 6c 10 00       	mov    $0x106cc4,%ebx

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  105185:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10518c:	e8 0f da ff ff       	call   102ba0 <picenable>
  ioapicenable(IRQ_COM1, 0);
  105191:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105198:	00 
  105199:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1051a0:	e8 ab cf ff ff       	call   102150 <ioapicenable>
  1051a5:	b8 78 00 00 00       	mov    $0x78,%eax
  1051aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
  1051b0:	0f be c0             	movsbl %al,%eax
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  1051b3:	83 c3 01             	add    $0x1,%ebx
    uartputc(*p);
  1051b6:	89 04 24             	mov    %eax,(%esp)
  1051b9:	e8 12 ff ff ff       	call   1050d0 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  1051be:	0f b6 03             	movzbl (%ebx),%eax
  1051c1:	84 c0                	test   %al,%al
  1051c3:	75 eb                	jne    1051b0 <uartinit+0x90>
    uartputc(*p);
}
  1051c5:	83 c4 1c             	add    $0x1c,%esp
  1051c8:	5b                   	pop    %ebx
  1051c9:	5e                   	pop    %esi
  1051ca:	5f                   	pop    %edi
  1051cb:	5d                   	pop    %ebp
  1051cc:	c3                   	ret    
  1051cd:	90                   	nop
  1051ce:	90                   	nop
  1051cf:	90                   	nop

001051d0 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
  1051d0:	6a 00                	push   $0x0
  pushl $0
  1051d2:	6a 00                	push   $0x0
  jmp alltraps
  1051d4:	e9 57 fb ff ff       	jmp    104d30 <alltraps>

001051d9 <vector1>:
.globl vector1
vector1:
  pushl $0
  1051d9:	6a 00                	push   $0x0
  pushl $1
  1051db:	6a 01                	push   $0x1
  jmp alltraps
  1051dd:	e9 4e fb ff ff       	jmp    104d30 <alltraps>

001051e2 <vector2>:
.globl vector2
vector2:
  pushl $0
  1051e2:	6a 00                	push   $0x0
  pushl $2
  1051e4:	6a 02                	push   $0x2
  jmp alltraps
  1051e6:	e9 45 fb ff ff       	jmp    104d30 <alltraps>

001051eb <vector3>:
.globl vector3
vector3:
  pushl $0
  1051eb:	6a 00                	push   $0x0
  pushl $3
  1051ed:	6a 03                	push   $0x3
  jmp alltraps
  1051ef:	e9 3c fb ff ff       	jmp    104d30 <alltraps>

001051f4 <vector4>:
.globl vector4
vector4:
  pushl $0
  1051f4:	6a 00                	push   $0x0
  pushl $4
  1051f6:	6a 04                	push   $0x4
  jmp alltraps
  1051f8:	e9 33 fb ff ff       	jmp    104d30 <alltraps>

001051fd <vector5>:
.globl vector5
vector5:
  pushl $0
  1051fd:	6a 00                	push   $0x0
  pushl $5
  1051ff:	6a 05                	push   $0x5
  jmp alltraps
  105201:	e9 2a fb ff ff       	jmp    104d30 <alltraps>

00105206 <vector6>:
.globl vector6
vector6:
  pushl $0
  105206:	6a 00                	push   $0x0
  pushl $6
  105208:	6a 06                	push   $0x6
  jmp alltraps
  10520a:	e9 21 fb ff ff       	jmp    104d30 <alltraps>

0010520f <vector7>:
.globl vector7
vector7:
  pushl $0
  10520f:	6a 00                	push   $0x0
  pushl $7
  105211:	6a 07                	push   $0x7
  jmp alltraps
  105213:	e9 18 fb ff ff       	jmp    104d30 <alltraps>

00105218 <vector8>:
.globl vector8
vector8:
  pushl $8
  105218:	6a 08                	push   $0x8
  jmp alltraps
  10521a:	e9 11 fb ff ff       	jmp    104d30 <alltraps>

0010521f <vector9>:
.globl vector9
vector9:
  pushl $0
  10521f:	6a 00                	push   $0x0
  pushl $9
  105221:	6a 09                	push   $0x9
  jmp alltraps
  105223:	e9 08 fb ff ff       	jmp    104d30 <alltraps>

00105228 <vector10>:
.globl vector10
vector10:
  pushl $10
  105228:	6a 0a                	push   $0xa
  jmp alltraps
  10522a:	e9 01 fb ff ff       	jmp    104d30 <alltraps>

0010522f <vector11>:
.globl vector11
vector11:
  pushl $11
  10522f:	6a 0b                	push   $0xb
  jmp alltraps
  105231:	e9 fa fa ff ff       	jmp    104d30 <alltraps>

00105236 <vector12>:
.globl vector12
vector12:
  pushl $12
  105236:	6a 0c                	push   $0xc
  jmp alltraps
  105238:	e9 f3 fa ff ff       	jmp    104d30 <alltraps>

0010523d <vector13>:
.globl vector13
vector13:
  pushl $13
  10523d:	6a 0d                	push   $0xd
  jmp alltraps
  10523f:	e9 ec fa ff ff       	jmp    104d30 <alltraps>

00105244 <vector14>:
.globl vector14
vector14:
  pushl $14
  105244:	6a 0e                	push   $0xe
  jmp alltraps
  105246:	e9 e5 fa ff ff       	jmp    104d30 <alltraps>

0010524b <vector15>:
.globl vector15
vector15:
  pushl $0
  10524b:	6a 00                	push   $0x0
  pushl $15
  10524d:	6a 0f                	push   $0xf
  jmp alltraps
  10524f:	e9 dc fa ff ff       	jmp    104d30 <alltraps>

00105254 <vector16>:
.globl vector16
vector16:
  pushl $0
  105254:	6a 00                	push   $0x0
  pushl $16
  105256:	6a 10                	push   $0x10
  jmp alltraps
  105258:	e9 d3 fa ff ff       	jmp    104d30 <alltraps>

0010525d <vector17>:
.globl vector17
vector17:
  pushl $17
  10525d:	6a 11                	push   $0x11
  jmp alltraps
  10525f:	e9 cc fa ff ff       	jmp    104d30 <alltraps>

00105264 <vector18>:
.globl vector18
vector18:
  pushl $0
  105264:	6a 00                	push   $0x0
  pushl $18
  105266:	6a 12                	push   $0x12
  jmp alltraps
  105268:	e9 c3 fa ff ff       	jmp    104d30 <alltraps>

0010526d <vector19>:
.globl vector19
vector19:
  pushl $0
  10526d:	6a 00                	push   $0x0
  pushl $19
  10526f:	6a 13                	push   $0x13
  jmp alltraps
  105271:	e9 ba fa ff ff       	jmp    104d30 <alltraps>

00105276 <vector20>:
.globl vector20
vector20:
  pushl $0
  105276:	6a 00                	push   $0x0
  pushl $20
  105278:	6a 14                	push   $0x14
  jmp alltraps
  10527a:	e9 b1 fa ff ff       	jmp    104d30 <alltraps>

0010527f <vector21>:
.globl vector21
vector21:
  pushl $0
  10527f:	6a 00                	push   $0x0
  pushl $21
  105281:	6a 15                	push   $0x15
  jmp alltraps
  105283:	e9 a8 fa ff ff       	jmp    104d30 <alltraps>

00105288 <vector22>:
.globl vector22
vector22:
  pushl $0
  105288:	6a 00                	push   $0x0
  pushl $22
  10528a:	6a 16                	push   $0x16
  jmp alltraps
  10528c:	e9 9f fa ff ff       	jmp    104d30 <alltraps>

00105291 <vector23>:
.globl vector23
vector23:
  pushl $0
  105291:	6a 00                	push   $0x0
  pushl $23
  105293:	6a 17                	push   $0x17
  jmp alltraps
  105295:	e9 96 fa ff ff       	jmp    104d30 <alltraps>

0010529a <vector24>:
.globl vector24
vector24:
  pushl $0
  10529a:	6a 00                	push   $0x0
  pushl $24
  10529c:	6a 18                	push   $0x18
  jmp alltraps
  10529e:	e9 8d fa ff ff       	jmp    104d30 <alltraps>

001052a3 <vector25>:
.globl vector25
vector25:
  pushl $0
  1052a3:	6a 00                	push   $0x0
  pushl $25
  1052a5:	6a 19                	push   $0x19
  jmp alltraps
  1052a7:	e9 84 fa ff ff       	jmp    104d30 <alltraps>

001052ac <vector26>:
.globl vector26
vector26:
  pushl $0
  1052ac:	6a 00                	push   $0x0
  pushl $26
  1052ae:	6a 1a                	push   $0x1a
  jmp alltraps
  1052b0:	e9 7b fa ff ff       	jmp    104d30 <alltraps>

001052b5 <vector27>:
.globl vector27
vector27:
  pushl $0
  1052b5:	6a 00                	push   $0x0
  pushl $27
  1052b7:	6a 1b                	push   $0x1b
  jmp alltraps
  1052b9:	e9 72 fa ff ff       	jmp    104d30 <alltraps>

001052be <vector28>:
.globl vector28
vector28:
  pushl $0
  1052be:	6a 00                	push   $0x0
  pushl $28
  1052c0:	6a 1c                	push   $0x1c
  jmp alltraps
  1052c2:	e9 69 fa ff ff       	jmp    104d30 <alltraps>

001052c7 <vector29>:
.globl vector29
vector29:
  pushl $0
  1052c7:	6a 00                	push   $0x0
  pushl $29
  1052c9:	6a 1d                	push   $0x1d
  jmp alltraps
  1052cb:	e9 60 fa ff ff       	jmp    104d30 <alltraps>

001052d0 <vector30>:
.globl vector30
vector30:
  pushl $0
  1052d0:	6a 00                	push   $0x0
  pushl $30
  1052d2:	6a 1e                	push   $0x1e
  jmp alltraps
  1052d4:	e9 57 fa ff ff       	jmp    104d30 <alltraps>

001052d9 <vector31>:
.globl vector31
vector31:
  pushl $0
  1052d9:	6a 00                	push   $0x0
  pushl $31
  1052db:	6a 1f                	push   $0x1f
  jmp alltraps
  1052dd:	e9 4e fa ff ff       	jmp    104d30 <alltraps>

001052e2 <vector32>:
.globl vector32
vector32:
  pushl $0
  1052e2:	6a 00                	push   $0x0
  pushl $32
  1052e4:	6a 20                	push   $0x20
  jmp alltraps
  1052e6:	e9 45 fa ff ff       	jmp    104d30 <alltraps>

001052eb <vector33>:
.globl vector33
vector33:
  pushl $0
  1052eb:	6a 00                	push   $0x0
  pushl $33
  1052ed:	6a 21                	push   $0x21
  jmp alltraps
  1052ef:	e9 3c fa ff ff       	jmp    104d30 <alltraps>

001052f4 <vector34>:
.globl vector34
vector34:
  pushl $0
  1052f4:	6a 00                	push   $0x0
  pushl $34
  1052f6:	6a 22                	push   $0x22
  jmp alltraps
  1052f8:	e9 33 fa ff ff       	jmp    104d30 <alltraps>

001052fd <vector35>:
.globl vector35
vector35:
  pushl $0
  1052fd:	6a 00                	push   $0x0
  pushl $35
  1052ff:	6a 23                	push   $0x23
  jmp alltraps
  105301:	e9 2a fa ff ff       	jmp    104d30 <alltraps>

00105306 <vector36>:
.globl vector36
vector36:
  pushl $0
  105306:	6a 00                	push   $0x0
  pushl $36
  105308:	6a 24                	push   $0x24
  jmp alltraps
  10530a:	e9 21 fa ff ff       	jmp    104d30 <alltraps>

0010530f <vector37>:
.globl vector37
vector37:
  pushl $0
  10530f:	6a 00                	push   $0x0
  pushl $37
  105311:	6a 25                	push   $0x25
  jmp alltraps
  105313:	e9 18 fa ff ff       	jmp    104d30 <alltraps>

00105318 <vector38>:
.globl vector38
vector38:
  pushl $0
  105318:	6a 00                	push   $0x0
  pushl $38
  10531a:	6a 26                	push   $0x26
  jmp alltraps
  10531c:	e9 0f fa ff ff       	jmp    104d30 <alltraps>

00105321 <vector39>:
.globl vector39
vector39:
  pushl $0
  105321:	6a 00                	push   $0x0
  pushl $39
  105323:	6a 27                	push   $0x27
  jmp alltraps
  105325:	e9 06 fa ff ff       	jmp    104d30 <alltraps>

0010532a <vector40>:
.globl vector40
vector40:
  pushl $0
  10532a:	6a 00                	push   $0x0
  pushl $40
  10532c:	6a 28                	push   $0x28
  jmp alltraps
  10532e:	e9 fd f9 ff ff       	jmp    104d30 <alltraps>

00105333 <vector41>:
.globl vector41
vector41:
  pushl $0
  105333:	6a 00                	push   $0x0
  pushl $41
  105335:	6a 29                	push   $0x29
  jmp alltraps
  105337:	e9 f4 f9 ff ff       	jmp    104d30 <alltraps>

0010533c <vector42>:
.globl vector42
vector42:
  pushl $0
  10533c:	6a 00                	push   $0x0
  pushl $42
  10533e:	6a 2a                	push   $0x2a
  jmp alltraps
  105340:	e9 eb f9 ff ff       	jmp    104d30 <alltraps>

00105345 <vector43>:
.globl vector43
vector43:
  pushl $0
  105345:	6a 00                	push   $0x0
  pushl $43
  105347:	6a 2b                	push   $0x2b
  jmp alltraps
  105349:	e9 e2 f9 ff ff       	jmp    104d30 <alltraps>

0010534e <vector44>:
.globl vector44
vector44:
  pushl $0
  10534e:	6a 00                	push   $0x0
  pushl $44
  105350:	6a 2c                	push   $0x2c
  jmp alltraps
  105352:	e9 d9 f9 ff ff       	jmp    104d30 <alltraps>

00105357 <vector45>:
.globl vector45
vector45:
  pushl $0
  105357:	6a 00                	push   $0x0
  pushl $45
  105359:	6a 2d                	push   $0x2d
  jmp alltraps
  10535b:	e9 d0 f9 ff ff       	jmp    104d30 <alltraps>

00105360 <vector46>:
.globl vector46
vector46:
  pushl $0
  105360:	6a 00                	push   $0x0
  pushl $46
  105362:	6a 2e                	push   $0x2e
  jmp alltraps
  105364:	e9 c7 f9 ff ff       	jmp    104d30 <alltraps>

00105369 <vector47>:
.globl vector47
vector47:
  pushl $0
  105369:	6a 00                	push   $0x0
  pushl $47
  10536b:	6a 2f                	push   $0x2f
  jmp alltraps
  10536d:	e9 be f9 ff ff       	jmp    104d30 <alltraps>

00105372 <vector48>:
.globl vector48
vector48:
  pushl $0
  105372:	6a 00                	push   $0x0
  pushl $48
  105374:	6a 30                	push   $0x30
  jmp alltraps
  105376:	e9 b5 f9 ff ff       	jmp    104d30 <alltraps>

0010537b <vector49>:
.globl vector49
vector49:
  pushl $0
  10537b:	6a 00                	push   $0x0
  pushl $49
  10537d:	6a 31                	push   $0x31
  jmp alltraps
  10537f:	e9 ac f9 ff ff       	jmp    104d30 <alltraps>

00105384 <vector50>:
.globl vector50
vector50:
  pushl $0
  105384:	6a 00                	push   $0x0
  pushl $50
  105386:	6a 32                	push   $0x32
  jmp alltraps
  105388:	e9 a3 f9 ff ff       	jmp    104d30 <alltraps>

0010538d <vector51>:
.globl vector51
vector51:
  pushl $0
  10538d:	6a 00                	push   $0x0
  pushl $51
  10538f:	6a 33                	push   $0x33
  jmp alltraps
  105391:	e9 9a f9 ff ff       	jmp    104d30 <alltraps>

00105396 <vector52>:
.globl vector52
vector52:
  pushl $0
  105396:	6a 00                	push   $0x0
  pushl $52
  105398:	6a 34                	push   $0x34
  jmp alltraps
  10539a:	e9 91 f9 ff ff       	jmp    104d30 <alltraps>

0010539f <vector53>:
.globl vector53
vector53:
  pushl $0
  10539f:	6a 00                	push   $0x0
  pushl $53
  1053a1:	6a 35                	push   $0x35
  jmp alltraps
  1053a3:	e9 88 f9 ff ff       	jmp    104d30 <alltraps>

001053a8 <vector54>:
.globl vector54
vector54:
  pushl $0
  1053a8:	6a 00                	push   $0x0
  pushl $54
  1053aa:	6a 36                	push   $0x36
  jmp alltraps
  1053ac:	e9 7f f9 ff ff       	jmp    104d30 <alltraps>

001053b1 <vector55>:
.globl vector55
vector55:
  pushl $0
  1053b1:	6a 00                	push   $0x0
  pushl $55
  1053b3:	6a 37                	push   $0x37
  jmp alltraps
  1053b5:	e9 76 f9 ff ff       	jmp    104d30 <alltraps>

001053ba <vector56>:
.globl vector56
vector56:
  pushl $0
  1053ba:	6a 00                	push   $0x0
  pushl $56
  1053bc:	6a 38                	push   $0x38
  jmp alltraps
  1053be:	e9 6d f9 ff ff       	jmp    104d30 <alltraps>

001053c3 <vector57>:
.globl vector57
vector57:
  pushl $0
  1053c3:	6a 00                	push   $0x0
  pushl $57
  1053c5:	6a 39                	push   $0x39
  jmp alltraps
  1053c7:	e9 64 f9 ff ff       	jmp    104d30 <alltraps>

001053cc <vector58>:
.globl vector58
vector58:
  pushl $0
  1053cc:	6a 00                	push   $0x0
  pushl $58
  1053ce:	6a 3a                	push   $0x3a
  jmp alltraps
  1053d0:	e9 5b f9 ff ff       	jmp    104d30 <alltraps>

001053d5 <vector59>:
.globl vector59
vector59:
  pushl $0
  1053d5:	6a 00                	push   $0x0
  pushl $59
  1053d7:	6a 3b                	push   $0x3b
  jmp alltraps
  1053d9:	e9 52 f9 ff ff       	jmp    104d30 <alltraps>

001053de <vector60>:
.globl vector60
vector60:
  pushl $0
  1053de:	6a 00                	push   $0x0
  pushl $60
  1053e0:	6a 3c                	push   $0x3c
  jmp alltraps
  1053e2:	e9 49 f9 ff ff       	jmp    104d30 <alltraps>

001053e7 <vector61>:
.globl vector61
vector61:
  pushl $0
  1053e7:	6a 00                	push   $0x0
  pushl $61
  1053e9:	6a 3d                	push   $0x3d
  jmp alltraps
  1053eb:	e9 40 f9 ff ff       	jmp    104d30 <alltraps>

001053f0 <vector62>:
.globl vector62
vector62:
  pushl $0
  1053f0:	6a 00                	push   $0x0
  pushl $62
  1053f2:	6a 3e                	push   $0x3e
  jmp alltraps
  1053f4:	e9 37 f9 ff ff       	jmp    104d30 <alltraps>

001053f9 <vector63>:
.globl vector63
vector63:
  pushl $0
  1053f9:	6a 00                	push   $0x0
  pushl $63
  1053fb:	6a 3f                	push   $0x3f
  jmp alltraps
  1053fd:	e9 2e f9 ff ff       	jmp    104d30 <alltraps>

00105402 <vector64>:
.globl vector64
vector64:
  pushl $0
  105402:	6a 00                	push   $0x0
  pushl $64
  105404:	6a 40                	push   $0x40
  jmp alltraps
  105406:	e9 25 f9 ff ff       	jmp    104d30 <alltraps>

0010540b <vector65>:
.globl vector65
vector65:
  pushl $0
  10540b:	6a 00                	push   $0x0
  pushl $65
  10540d:	6a 41                	push   $0x41
  jmp alltraps
  10540f:	e9 1c f9 ff ff       	jmp    104d30 <alltraps>

00105414 <vector66>:
.globl vector66
vector66:
  pushl $0
  105414:	6a 00                	push   $0x0
  pushl $66
  105416:	6a 42                	push   $0x42
  jmp alltraps
  105418:	e9 13 f9 ff ff       	jmp    104d30 <alltraps>

0010541d <vector67>:
.globl vector67
vector67:
  pushl $0
  10541d:	6a 00                	push   $0x0
  pushl $67
  10541f:	6a 43                	push   $0x43
  jmp alltraps
  105421:	e9 0a f9 ff ff       	jmp    104d30 <alltraps>

00105426 <vector68>:
.globl vector68
vector68:
  pushl $0
  105426:	6a 00                	push   $0x0
  pushl $68
  105428:	6a 44                	push   $0x44
  jmp alltraps
  10542a:	e9 01 f9 ff ff       	jmp    104d30 <alltraps>

0010542f <vector69>:
.globl vector69
vector69:
  pushl $0
  10542f:	6a 00                	push   $0x0
  pushl $69
  105431:	6a 45                	push   $0x45
  jmp alltraps
  105433:	e9 f8 f8 ff ff       	jmp    104d30 <alltraps>

00105438 <vector70>:
.globl vector70
vector70:
  pushl $0
  105438:	6a 00                	push   $0x0
  pushl $70
  10543a:	6a 46                	push   $0x46
  jmp alltraps
  10543c:	e9 ef f8 ff ff       	jmp    104d30 <alltraps>

00105441 <vector71>:
.globl vector71
vector71:
  pushl $0
  105441:	6a 00                	push   $0x0
  pushl $71
  105443:	6a 47                	push   $0x47
  jmp alltraps
  105445:	e9 e6 f8 ff ff       	jmp    104d30 <alltraps>

0010544a <vector72>:
.globl vector72
vector72:
  pushl $0
  10544a:	6a 00                	push   $0x0
  pushl $72
  10544c:	6a 48                	push   $0x48
  jmp alltraps
  10544e:	e9 dd f8 ff ff       	jmp    104d30 <alltraps>

00105453 <vector73>:
.globl vector73
vector73:
  pushl $0
  105453:	6a 00                	push   $0x0
  pushl $73
  105455:	6a 49                	push   $0x49
  jmp alltraps
  105457:	e9 d4 f8 ff ff       	jmp    104d30 <alltraps>

0010545c <vector74>:
.globl vector74
vector74:
  pushl $0
  10545c:	6a 00                	push   $0x0
  pushl $74
  10545e:	6a 4a                	push   $0x4a
  jmp alltraps
  105460:	e9 cb f8 ff ff       	jmp    104d30 <alltraps>

00105465 <vector75>:
.globl vector75
vector75:
  pushl $0
  105465:	6a 00                	push   $0x0
  pushl $75
  105467:	6a 4b                	push   $0x4b
  jmp alltraps
  105469:	e9 c2 f8 ff ff       	jmp    104d30 <alltraps>

0010546e <vector76>:
.globl vector76
vector76:
  pushl $0
  10546e:	6a 00                	push   $0x0
  pushl $76
  105470:	6a 4c                	push   $0x4c
  jmp alltraps
  105472:	e9 b9 f8 ff ff       	jmp    104d30 <alltraps>

00105477 <vector77>:
.globl vector77
vector77:
  pushl $0
  105477:	6a 00                	push   $0x0
  pushl $77
  105479:	6a 4d                	push   $0x4d
  jmp alltraps
  10547b:	e9 b0 f8 ff ff       	jmp    104d30 <alltraps>

00105480 <vector78>:
.globl vector78
vector78:
  pushl $0
  105480:	6a 00                	push   $0x0
  pushl $78
  105482:	6a 4e                	push   $0x4e
  jmp alltraps
  105484:	e9 a7 f8 ff ff       	jmp    104d30 <alltraps>

00105489 <vector79>:
.globl vector79
vector79:
  pushl $0
  105489:	6a 00                	push   $0x0
  pushl $79
  10548b:	6a 4f                	push   $0x4f
  jmp alltraps
  10548d:	e9 9e f8 ff ff       	jmp    104d30 <alltraps>

00105492 <vector80>:
.globl vector80
vector80:
  pushl $0
  105492:	6a 00                	push   $0x0
  pushl $80
  105494:	6a 50                	push   $0x50
  jmp alltraps
  105496:	e9 95 f8 ff ff       	jmp    104d30 <alltraps>

0010549b <vector81>:
.globl vector81
vector81:
  pushl $0
  10549b:	6a 00                	push   $0x0
  pushl $81
  10549d:	6a 51                	push   $0x51
  jmp alltraps
  10549f:	e9 8c f8 ff ff       	jmp    104d30 <alltraps>

001054a4 <vector82>:
.globl vector82
vector82:
  pushl $0
  1054a4:	6a 00                	push   $0x0
  pushl $82
  1054a6:	6a 52                	push   $0x52
  jmp alltraps
  1054a8:	e9 83 f8 ff ff       	jmp    104d30 <alltraps>

001054ad <vector83>:
.globl vector83
vector83:
  pushl $0
  1054ad:	6a 00                	push   $0x0
  pushl $83
  1054af:	6a 53                	push   $0x53
  jmp alltraps
  1054b1:	e9 7a f8 ff ff       	jmp    104d30 <alltraps>

001054b6 <vector84>:
.globl vector84
vector84:
  pushl $0
  1054b6:	6a 00                	push   $0x0
  pushl $84
  1054b8:	6a 54                	push   $0x54
  jmp alltraps
  1054ba:	e9 71 f8 ff ff       	jmp    104d30 <alltraps>

001054bf <vector85>:
.globl vector85
vector85:
  pushl $0
  1054bf:	6a 00                	push   $0x0
  pushl $85
  1054c1:	6a 55                	push   $0x55
  jmp alltraps
  1054c3:	e9 68 f8 ff ff       	jmp    104d30 <alltraps>

001054c8 <vector86>:
.globl vector86
vector86:
  pushl $0
  1054c8:	6a 00                	push   $0x0
  pushl $86
  1054ca:	6a 56                	push   $0x56
  jmp alltraps
  1054cc:	e9 5f f8 ff ff       	jmp    104d30 <alltraps>

001054d1 <vector87>:
.globl vector87
vector87:
  pushl $0
  1054d1:	6a 00                	push   $0x0
  pushl $87
  1054d3:	6a 57                	push   $0x57
  jmp alltraps
  1054d5:	e9 56 f8 ff ff       	jmp    104d30 <alltraps>

001054da <vector88>:
.globl vector88
vector88:
  pushl $0
  1054da:	6a 00                	push   $0x0
  pushl $88
  1054dc:	6a 58                	push   $0x58
  jmp alltraps
  1054de:	e9 4d f8 ff ff       	jmp    104d30 <alltraps>

001054e3 <vector89>:
.globl vector89
vector89:
  pushl $0
  1054e3:	6a 00                	push   $0x0
  pushl $89
  1054e5:	6a 59                	push   $0x59
  jmp alltraps
  1054e7:	e9 44 f8 ff ff       	jmp    104d30 <alltraps>

001054ec <vector90>:
.globl vector90
vector90:
  pushl $0
  1054ec:	6a 00                	push   $0x0
  pushl $90
  1054ee:	6a 5a                	push   $0x5a
  jmp alltraps
  1054f0:	e9 3b f8 ff ff       	jmp    104d30 <alltraps>

001054f5 <vector91>:
.globl vector91
vector91:
  pushl $0
  1054f5:	6a 00                	push   $0x0
  pushl $91
  1054f7:	6a 5b                	push   $0x5b
  jmp alltraps
  1054f9:	e9 32 f8 ff ff       	jmp    104d30 <alltraps>

001054fe <vector92>:
.globl vector92
vector92:
  pushl $0
  1054fe:	6a 00                	push   $0x0
  pushl $92
  105500:	6a 5c                	push   $0x5c
  jmp alltraps
  105502:	e9 29 f8 ff ff       	jmp    104d30 <alltraps>

00105507 <vector93>:
.globl vector93
vector93:
  pushl $0
  105507:	6a 00                	push   $0x0
  pushl $93
  105509:	6a 5d                	push   $0x5d
  jmp alltraps
  10550b:	e9 20 f8 ff ff       	jmp    104d30 <alltraps>

00105510 <vector94>:
.globl vector94
vector94:
  pushl $0
  105510:	6a 00                	push   $0x0
  pushl $94
  105512:	6a 5e                	push   $0x5e
  jmp alltraps
  105514:	e9 17 f8 ff ff       	jmp    104d30 <alltraps>

00105519 <vector95>:
.globl vector95
vector95:
  pushl $0
  105519:	6a 00                	push   $0x0
  pushl $95
  10551b:	6a 5f                	push   $0x5f
  jmp alltraps
  10551d:	e9 0e f8 ff ff       	jmp    104d30 <alltraps>

00105522 <vector96>:
.globl vector96
vector96:
  pushl $0
  105522:	6a 00                	push   $0x0
  pushl $96
  105524:	6a 60                	push   $0x60
  jmp alltraps
  105526:	e9 05 f8 ff ff       	jmp    104d30 <alltraps>

0010552b <vector97>:
.globl vector97
vector97:
  pushl $0
  10552b:	6a 00                	push   $0x0
  pushl $97
  10552d:	6a 61                	push   $0x61
  jmp alltraps
  10552f:	e9 fc f7 ff ff       	jmp    104d30 <alltraps>

00105534 <vector98>:
.globl vector98
vector98:
  pushl $0
  105534:	6a 00                	push   $0x0
  pushl $98
  105536:	6a 62                	push   $0x62
  jmp alltraps
  105538:	e9 f3 f7 ff ff       	jmp    104d30 <alltraps>

0010553d <vector99>:
.globl vector99
vector99:
  pushl $0
  10553d:	6a 00                	push   $0x0
  pushl $99
  10553f:	6a 63                	push   $0x63
  jmp alltraps
  105541:	e9 ea f7 ff ff       	jmp    104d30 <alltraps>

00105546 <vector100>:
.globl vector100
vector100:
  pushl $0
  105546:	6a 00                	push   $0x0
  pushl $100
  105548:	6a 64                	push   $0x64
  jmp alltraps
  10554a:	e9 e1 f7 ff ff       	jmp    104d30 <alltraps>

0010554f <vector101>:
.globl vector101
vector101:
  pushl $0
  10554f:	6a 00                	push   $0x0
  pushl $101
  105551:	6a 65                	push   $0x65
  jmp alltraps
  105553:	e9 d8 f7 ff ff       	jmp    104d30 <alltraps>

00105558 <vector102>:
.globl vector102
vector102:
  pushl $0
  105558:	6a 00                	push   $0x0
  pushl $102
  10555a:	6a 66                	push   $0x66
  jmp alltraps
  10555c:	e9 cf f7 ff ff       	jmp    104d30 <alltraps>

00105561 <vector103>:
.globl vector103
vector103:
  pushl $0
  105561:	6a 00                	push   $0x0
  pushl $103
  105563:	6a 67                	push   $0x67
  jmp alltraps
  105565:	e9 c6 f7 ff ff       	jmp    104d30 <alltraps>

0010556a <vector104>:
.globl vector104
vector104:
  pushl $0
  10556a:	6a 00                	push   $0x0
  pushl $104
  10556c:	6a 68                	push   $0x68
  jmp alltraps
  10556e:	e9 bd f7 ff ff       	jmp    104d30 <alltraps>

00105573 <vector105>:
.globl vector105
vector105:
  pushl $0
  105573:	6a 00                	push   $0x0
  pushl $105
  105575:	6a 69                	push   $0x69
  jmp alltraps
  105577:	e9 b4 f7 ff ff       	jmp    104d30 <alltraps>

0010557c <vector106>:
.globl vector106
vector106:
  pushl $0
  10557c:	6a 00                	push   $0x0
  pushl $106
  10557e:	6a 6a                	push   $0x6a
  jmp alltraps
  105580:	e9 ab f7 ff ff       	jmp    104d30 <alltraps>

00105585 <vector107>:
.globl vector107
vector107:
  pushl $0
  105585:	6a 00                	push   $0x0
  pushl $107
  105587:	6a 6b                	push   $0x6b
  jmp alltraps
  105589:	e9 a2 f7 ff ff       	jmp    104d30 <alltraps>

0010558e <vector108>:
.globl vector108
vector108:
  pushl $0
  10558e:	6a 00                	push   $0x0
  pushl $108
  105590:	6a 6c                	push   $0x6c
  jmp alltraps
  105592:	e9 99 f7 ff ff       	jmp    104d30 <alltraps>

00105597 <vector109>:
.globl vector109
vector109:
  pushl $0
  105597:	6a 00                	push   $0x0
  pushl $109
  105599:	6a 6d                	push   $0x6d
  jmp alltraps
  10559b:	e9 90 f7 ff ff       	jmp    104d30 <alltraps>

001055a0 <vector110>:
.globl vector110
vector110:
  pushl $0
  1055a0:	6a 00                	push   $0x0
  pushl $110
  1055a2:	6a 6e                	push   $0x6e
  jmp alltraps
  1055a4:	e9 87 f7 ff ff       	jmp    104d30 <alltraps>

001055a9 <vector111>:
.globl vector111
vector111:
  pushl $0
  1055a9:	6a 00                	push   $0x0
  pushl $111
  1055ab:	6a 6f                	push   $0x6f
  jmp alltraps
  1055ad:	e9 7e f7 ff ff       	jmp    104d30 <alltraps>

001055b2 <vector112>:
.globl vector112
vector112:
  pushl $0
  1055b2:	6a 00                	push   $0x0
  pushl $112
  1055b4:	6a 70                	push   $0x70
  jmp alltraps
  1055b6:	e9 75 f7 ff ff       	jmp    104d30 <alltraps>

001055bb <vector113>:
.globl vector113
vector113:
  pushl $0
  1055bb:	6a 00                	push   $0x0
  pushl $113
  1055bd:	6a 71                	push   $0x71
  jmp alltraps
  1055bf:	e9 6c f7 ff ff       	jmp    104d30 <alltraps>

001055c4 <vector114>:
.globl vector114
vector114:
  pushl $0
  1055c4:	6a 00                	push   $0x0
  pushl $114
  1055c6:	6a 72                	push   $0x72
  jmp alltraps
  1055c8:	e9 63 f7 ff ff       	jmp    104d30 <alltraps>

001055cd <vector115>:
.globl vector115
vector115:
  pushl $0
  1055cd:	6a 00                	push   $0x0
  pushl $115
  1055cf:	6a 73                	push   $0x73
  jmp alltraps
  1055d1:	e9 5a f7 ff ff       	jmp    104d30 <alltraps>

001055d6 <vector116>:
.globl vector116
vector116:
  pushl $0
  1055d6:	6a 00                	push   $0x0
  pushl $116
  1055d8:	6a 74                	push   $0x74
  jmp alltraps
  1055da:	e9 51 f7 ff ff       	jmp    104d30 <alltraps>

001055df <vector117>:
.globl vector117
vector117:
  pushl $0
  1055df:	6a 00                	push   $0x0
  pushl $117
  1055e1:	6a 75                	push   $0x75
  jmp alltraps
  1055e3:	e9 48 f7 ff ff       	jmp    104d30 <alltraps>

001055e8 <vector118>:
.globl vector118
vector118:
  pushl $0
  1055e8:	6a 00                	push   $0x0
  pushl $118
  1055ea:	6a 76                	push   $0x76
  jmp alltraps
  1055ec:	e9 3f f7 ff ff       	jmp    104d30 <alltraps>

001055f1 <vector119>:
.globl vector119
vector119:
  pushl $0
  1055f1:	6a 00                	push   $0x0
  pushl $119
  1055f3:	6a 77                	push   $0x77
  jmp alltraps
  1055f5:	e9 36 f7 ff ff       	jmp    104d30 <alltraps>

001055fa <vector120>:
.globl vector120
vector120:
  pushl $0
  1055fa:	6a 00                	push   $0x0
  pushl $120
  1055fc:	6a 78                	push   $0x78
  jmp alltraps
  1055fe:	e9 2d f7 ff ff       	jmp    104d30 <alltraps>

00105603 <vector121>:
.globl vector121
vector121:
  pushl $0
  105603:	6a 00                	push   $0x0
  pushl $121
  105605:	6a 79                	push   $0x79
  jmp alltraps
  105607:	e9 24 f7 ff ff       	jmp    104d30 <alltraps>

0010560c <vector122>:
.globl vector122
vector122:
  pushl $0
  10560c:	6a 00                	push   $0x0
  pushl $122
  10560e:	6a 7a                	push   $0x7a
  jmp alltraps
  105610:	e9 1b f7 ff ff       	jmp    104d30 <alltraps>

00105615 <vector123>:
.globl vector123
vector123:
  pushl $0
  105615:	6a 00                	push   $0x0
  pushl $123
  105617:	6a 7b                	push   $0x7b
  jmp alltraps
  105619:	e9 12 f7 ff ff       	jmp    104d30 <alltraps>

0010561e <vector124>:
.globl vector124
vector124:
  pushl $0
  10561e:	6a 00                	push   $0x0
  pushl $124
  105620:	6a 7c                	push   $0x7c
  jmp alltraps
  105622:	e9 09 f7 ff ff       	jmp    104d30 <alltraps>

00105627 <vector125>:
.globl vector125
vector125:
  pushl $0
  105627:	6a 00                	push   $0x0
  pushl $125
  105629:	6a 7d                	push   $0x7d
  jmp alltraps
  10562b:	e9 00 f7 ff ff       	jmp    104d30 <alltraps>

00105630 <vector126>:
.globl vector126
vector126:
  pushl $0
  105630:	6a 00                	push   $0x0
  pushl $126
  105632:	6a 7e                	push   $0x7e
  jmp alltraps
  105634:	e9 f7 f6 ff ff       	jmp    104d30 <alltraps>

00105639 <vector127>:
.globl vector127
vector127:
  pushl $0
  105639:	6a 00                	push   $0x0
  pushl $127
  10563b:	6a 7f                	push   $0x7f
  jmp alltraps
  10563d:	e9 ee f6 ff ff       	jmp    104d30 <alltraps>

00105642 <vector128>:
.globl vector128
vector128:
  pushl $0
  105642:	6a 00                	push   $0x0
  pushl $128
  105644:	68 80 00 00 00       	push   $0x80
  jmp alltraps
  105649:	e9 e2 f6 ff ff       	jmp    104d30 <alltraps>

0010564e <vector129>:
.globl vector129
vector129:
  pushl $0
  10564e:	6a 00                	push   $0x0
  pushl $129
  105650:	68 81 00 00 00       	push   $0x81
  jmp alltraps
  105655:	e9 d6 f6 ff ff       	jmp    104d30 <alltraps>

0010565a <vector130>:
.globl vector130
vector130:
  pushl $0
  10565a:	6a 00                	push   $0x0
  pushl $130
  10565c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
  105661:	e9 ca f6 ff ff       	jmp    104d30 <alltraps>

00105666 <vector131>:
.globl vector131
vector131:
  pushl $0
  105666:	6a 00                	push   $0x0
  pushl $131
  105668:	68 83 00 00 00       	push   $0x83
  jmp alltraps
  10566d:	e9 be f6 ff ff       	jmp    104d30 <alltraps>

00105672 <vector132>:
.globl vector132
vector132:
  pushl $0
  105672:	6a 00                	push   $0x0
  pushl $132
  105674:	68 84 00 00 00       	push   $0x84
  jmp alltraps
  105679:	e9 b2 f6 ff ff       	jmp    104d30 <alltraps>

0010567e <vector133>:
.globl vector133
vector133:
  pushl $0
  10567e:	6a 00                	push   $0x0
  pushl $133
  105680:	68 85 00 00 00       	push   $0x85
  jmp alltraps
  105685:	e9 a6 f6 ff ff       	jmp    104d30 <alltraps>

0010568a <vector134>:
.globl vector134
vector134:
  pushl $0
  10568a:	6a 00                	push   $0x0
  pushl $134
  10568c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
  105691:	e9 9a f6 ff ff       	jmp    104d30 <alltraps>

00105696 <vector135>:
.globl vector135
vector135:
  pushl $0
  105696:	6a 00                	push   $0x0
  pushl $135
  105698:	68 87 00 00 00       	push   $0x87
  jmp alltraps
  10569d:	e9 8e f6 ff ff       	jmp    104d30 <alltraps>

001056a2 <vector136>:
.globl vector136
vector136:
  pushl $0
  1056a2:	6a 00                	push   $0x0
  pushl $136
  1056a4:	68 88 00 00 00       	push   $0x88
  jmp alltraps
  1056a9:	e9 82 f6 ff ff       	jmp    104d30 <alltraps>

001056ae <vector137>:
.globl vector137
vector137:
  pushl $0
  1056ae:	6a 00                	push   $0x0
  pushl $137
  1056b0:	68 89 00 00 00       	push   $0x89
  jmp alltraps
  1056b5:	e9 76 f6 ff ff       	jmp    104d30 <alltraps>

001056ba <vector138>:
.globl vector138
vector138:
  pushl $0
  1056ba:	6a 00                	push   $0x0
  pushl $138
  1056bc:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
  1056c1:	e9 6a f6 ff ff       	jmp    104d30 <alltraps>

001056c6 <vector139>:
.globl vector139
vector139:
  pushl $0
  1056c6:	6a 00                	push   $0x0
  pushl $139
  1056c8:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
  1056cd:	e9 5e f6 ff ff       	jmp    104d30 <alltraps>

001056d2 <vector140>:
.globl vector140
vector140:
  pushl $0
  1056d2:	6a 00                	push   $0x0
  pushl $140
  1056d4:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
  1056d9:	e9 52 f6 ff ff       	jmp    104d30 <alltraps>

001056de <vector141>:
.globl vector141
vector141:
  pushl $0
  1056de:	6a 00                	push   $0x0
  pushl $141
  1056e0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
  1056e5:	e9 46 f6 ff ff       	jmp    104d30 <alltraps>

001056ea <vector142>:
.globl vector142
vector142:
  pushl $0
  1056ea:	6a 00                	push   $0x0
  pushl $142
  1056ec:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
  1056f1:	e9 3a f6 ff ff       	jmp    104d30 <alltraps>

001056f6 <vector143>:
.globl vector143
vector143:
  pushl $0
  1056f6:	6a 00                	push   $0x0
  pushl $143
  1056f8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
  1056fd:	e9 2e f6 ff ff       	jmp    104d30 <alltraps>

00105702 <vector144>:
.globl vector144
vector144:
  pushl $0
  105702:	6a 00                	push   $0x0
  pushl $144
  105704:	68 90 00 00 00       	push   $0x90
  jmp alltraps
  105709:	e9 22 f6 ff ff       	jmp    104d30 <alltraps>

0010570e <vector145>:
.globl vector145
vector145:
  pushl $0
  10570e:	6a 00                	push   $0x0
  pushl $145
  105710:	68 91 00 00 00       	push   $0x91
  jmp alltraps
  105715:	e9 16 f6 ff ff       	jmp    104d30 <alltraps>

0010571a <vector146>:
.globl vector146
vector146:
  pushl $0
  10571a:	6a 00                	push   $0x0
  pushl $146
  10571c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
  105721:	e9 0a f6 ff ff       	jmp    104d30 <alltraps>

00105726 <vector147>:
.globl vector147
vector147:
  pushl $0
  105726:	6a 00                	push   $0x0
  pushl $147
  105728:	68 93 00 00 00       	push   $0x93
  jmp alltraps
  10572d:	e9 fe f5 ff ff       	jmp    104d30 <alltraps>

00105732 <vector148>:
.globl vector148
vector148:
  pushl $0
  105732:	6a 00                	push   $0x0
  pushl $148
  105734:	68 94 00 00 00       	push   $0x94
  jmp alltraps
  105739:	e9 f2 f5 ff ff       	jmp    104d30 <alltraps>

0010573e <vector149>:
.globl vector149
vector149:
  pushl $0
  10573e:	6a 00                	push   $0x0
  pushl $149
  105740:	68 95 00 00 00       	push   $0x95
  jmp alltraps
  105745:	e9 e6 f5 ff ff       	jmp    104d30 <alltraps>

0010574a <vector150>:
.globl vector150
vector150:
  pushl $0
  10574a:	6a 00                	push   $0x0
  pushl $150
  10574c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
  105751:	e9 da f5 ff ff       	jmp    104d30 <alltraps>

00105756 <vector151>:
.globl vector151
vector151:
  pushl $0
  105756:	6a 00                	push   $0x0
  pushl $151
  105758:	68 97 00 00 00       	push   $0x97
  jmp alltraps
  10575d:	e9 ce f5 ff ff       	jmp    104d30 <alltraps>

00105762 <vector152>:
.globl vector152
vector152:
  pushl $0
  105762:	6a 00                	push   $0x0
  pushl $152
  105764:	68 98 00 00 00       	push   $0x98
  jmp alltraps
  105769:	e9 c2 f5 ff ff       	jmp    104d30 <alltraps>

0010576e <vector153>:
.globl vector153
vector153:
  pushl $0
  10576e:	6a 00                	push   $0x0
  pushl $153
  105770:	68 99 00 00 00       	push   $0x99
  jmp alltraps
  105775:	e9 b6 f5 ff ff       	jmp    104d30 <alltraps>

0010577a <vector154>:
.globl vector154
vector154:
  pushl $0
  10577a:	6a 00                	push   $0x0
  pushl $154
  10577c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
  105781:	e9 aa f5 ff ff       	jmp    104d30 <alltraps>

00105786 <vector155>:
.globl vector155
vector155:
  pushl $0
  105786:	6a 00                	push   $0x0
  pushl $155
  105788:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
  10578d:	e9 9e f5 ff ff       	jmp    104d30 <alltraps>

00105792 <vector156>:
.globl vector156
vector156:
  pushl $0
  105792:	6a 00                	push   $0x0
  pushl $156
  105794:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
  105799:	e9 92 f5 ff ff       	jmp    104d30 <alltraps>

0010579e <vector157>:
.globl vector157
vector157:
  pushl $0
  10579e:	6a 00                	push   $0x0
  pushl $157
  1057a0:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
  1057a5:	e9 86 f5 ff ff       	jmp    104d30 <alltraps>

001057aa <vector158>:
.globl vector158
vector158:
  pushl $0
  1057aa:	6a 00                	push   $0x0
  pushl $158
  1057ac:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
  1057b1:	e9 7a f5 ff ff       	jmp    104d30 <alltraps>

001057b6 <vector159>:
.globl vector159
vector159:
  pushl $0
  1057b6:	6a 00                	push   $0x0
  pushl $159
  1057b8:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
  1057bd:	e9 6e f5 ff ff       	jmp    104d30 <alltraps>

001057c2 <vector160>:
.globl vector160
vector160:
  pushl $0
  1057c2:	6a 00                	push   $0x0
  pushl $160
  1057c4:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
  1057c9:	e9 62 f5 ff ff       	jmp    104d30 <alltraps>

001057ce <vector161>:
.globl vector161
vector161:
  pushl $0
  1057ce:	6a 00                	push   $0x0
  pushl $161
  1057d0:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
  1057d5:	e9 56 f5 ff ff       	jmp    104d30 <alltraps>

001057da <vector162>:
.globl vector162
vector162:
  pushl $0
  1057da:	6a 00                	push   $0x0
  pushl $162
  1057dc:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
  1057e1:	e9 4a f5 ff ff       	jmp    104d30 <alltraps>

001057e6 <vector163>:
.globl vector163
vector163:
  pushl $0
  1057e6:	6a 00                	push   $0x0
  pushl $163
  1057e8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
  1057ed:	e9 3e f5 ff ff       	jmp    104d30 <alltraps>

001057f2 <vector164>:
.globl vector164
vector164:
  pushl $0
  1057f2:	6a 00                	push   $0x0
  pushl $164
  1057f4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
  1057f9:	e9 32 f5 ff ff       	jmp    104d30 <alltraps>

001057fe <vector165>:
.globl vector165
vector165:
  pushl $0
  1057fe:	6a 00                	push   $0x0
  pushl $165
  105800:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
  105805:	e9 26 f5 ff ff       	jmp    104d30 <alltraps>

0010580a <vector166>:
.globl vector166
vector166:
  pushl $0
  10580a:	6a 00                	push   $0x0
  pushl $166
  10580c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
  105811:	e9 1a f5 ff ff       	jmp    104d30 <alltraps>

00105816 <vector167>:
.globl vector167
vector167:
  pushl $0
  105816:	6a 00                	push   $0x0
  pushl $167
  105818:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
  10581d:	e9 0e f5 ff ff       	jmp    104d30 <alltraps>

00105822 <vector168>:
.globl vector168
vector168:
  pushl $0
  105822:	6a 00                	push   $0x0
  pushl $168
  105824:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
  105829:	e9 02 f5 ff ff       	jmp    104d30 <alltraps>

0010582e <vector169>:
.globl vector169
vector169:
  pushl $0
  10582e:	6a 00                	push   $0x0
  pushl $169
  105830:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
  105835:	e9 f6 f4 ff ff       	jmp    104d30 <alltraps>

0010583a <vector170>:
.globl vector170
vector170:
  pushl $0
  10583a:	6a 00                	push   $0x0
  pushl $170
  10583c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
  105841:	e9 ea f4 ff ff       	jmp    104d30 <alltraps>

00105846 <vector171>:
.globl vector171
vector171:
  pushl $0
  105846:	6a 00                	push   $0x0
  pushl $171
  105848:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
  10584d:	e9 de f4 ff ff       	jmp    104d30 <alltraps>

00105852 <vector172>:
.globl vector172
vector172:
  pushl $0
  105852:	6a 00                	push   $0x0
  pushl $172
  105854:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
  105859:	e9 d2 f4 ff ff       	jmp    104d30 <alltraps>

0010585e <vector173>:
.globl vector173
vector173:
  pushl $0
  10585e:	6a 00                	push   $0x0
  pushl $173
  105860:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
  105865:	e9 c6 f4 ff ff       	jmp    104d30 <alltraps>

0010586a <vector174>:
.globl vector174
vector174:
  pushl $0
  10586a:	6a 00                	push   $0x0
  pushl $174
  10586c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
  105871:	e9 ba f4 ff ff       	jmp    104d30 <alltraps>

00105876 <vector175>:
.globl vector175
vector175:
  pushl $0
  105876:	6a 00                	push   $0x0
  pushl $175
  105878:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
  10587d:	e9 ae f4 ff ff       	jmp    104d30 <alltraps>

00105882 <vector176>:
.globl vector176
vector176:
  pushl $0
  105882:	6a 00                	push   $0x0
  pushl $176
  105884:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
  105889:	e9 a2 f4 ff ff       	jmp    104d30 <alltraps>

0010588e <vector177>:
.globl vector177
vector177:
  pushl $0
  10588e:	6a 00                	push   $0x0
  pushl $177
  105890:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
  105895:	e9 96 f4 ff ff       	jmp    104d30 <alltraps>

0010589a <vector178>:
.globl vector178
vector178:
  pushl $0
  10589a:	6a 00                	push   $0x0
  pushl $178
  10589c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
  1058a1:	e9 8a f4 ff ff       	jmp    104d30 <alltraps>

001058a6 <vector179>:
.globl vector179
vector179:
  pushl $0
  1058a6:	6a 00                	push   $0x0
  pushl $179
  1058a8:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
  1058ad:	e9 7e f4 ff ff       	jmp    104d30 <alltraps>

001058b2 <vector180>:
.globl vector180
vector180:
  pushl $0
  1058b2:	6a 00                	push   $0x0
  pushl $180
  1058b4:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
  1058b9:	e9 72 f4 ff ff       	jmp    104d30 <alltraps>

001058be <vector181>:
.globl vector181
vector181:
  pushl $0
  1058be:	6a 00                	push   $0x0
  pushl $181
  1058c0:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
  1058c5:	e9 66 f4 ff ff       	jmp    104d30 <alltraps>

001058ca <vector182>:
.globl vector182
vector182:
  pushl $0
  1058ca:	6a 00                	push   $0x0
  pushl $182
  1058cc:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
  1058d1:	e9 5a f4 ff ff       	jmp    104d30 <alltraps>

001058d6 <vector183>:
.globl vector183
vector183:
  pushl $0
  1058d6:	6a 00                	push   $0x0
  pushl $183
  1058d8:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
  1058dd:	e9 4e f4 ff ff       	jmp    104d30 <alltraps>

001058e2 <vector184>:
.globl vector184
vector184:
  pushl $0
  1058e2:	6a 00                	push   $0x0
  pushl $184
  1058e4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
  1058e9:	e9 42 f4 ff ff       	jmp    104d30 <alltraps>

001058ee <vector185>:
.globl vector185
vector185:
  pushl $0
  1058ee:	6a 00                	push   $0x0
  pushl $185
  1058f0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
  1058f5:	e9 36 f4 ff ff       	jmp    104d30 <alltraps>

001058fa <vector186>:
.globl vector186
vector186:
  pushl $0
  1058fa:	6a 00                	push   $0x0
  pushl $186
  1058fc:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
  105901:	e9 2a f4 ff ff       	jmp    104d30 <alltraps>

00105906 <vector187>:
.globl vector187
vector187:
  pushl $0
  105906:	6a 00                	push   $0x0
  pushl $187
  105908:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
  10590d:	e9 1e f4 ff ff       	jmp    104d30 <alltraps>

00105912 <vector188>:
.globl vector188
vector188:
  pushl $0
  105912:	6a 00                	push   $0x0
  pushl $188
  105914:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
  105919:	e9 12 f4 ff ff       	jmp    104d30 <alltraps>

0010591e <vector189>:
.globl vector189
vector189:
  pushl $0
  10591e:	6a 00                	push   $0x0
  pushl $189
  105920:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
  105925:	e9 06 f4 ff ff       	jmp    104d30 <alltraps>

0010592a <vector190>:
.globl vector190
vector190:
  pushl $0
  10592a:	6a 00                	push   $0x0
  pushl $190
  10592c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
  105931:	e9 fa f3 ff ff       	jmp    104d30 <alltraps>

00105936 <vector191>:
.globl vector191
vector191:
  pushl $0
  105936:	6a 00                	push   $0x0
  pushl $191
  105938:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
  10593d:	e9 ee f3 ff ff       	jmp    104d30 <alltraps>

00105942 <vector192>:
.globl vector192
vector192:
  pushl $0
  105942:	6a 00                	push   $0x0
  pushl $192
  105944:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
  105949:	e9 e2 f3 ff ff       	jmp    104d30 <alltraps>

0010594e <vector193>:
.globl vector193
vector193:
  pushl $0
  10594e:	6a 00                	push   $0x0
  pushl $193
  105950:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
  105955:	e9 d6 f3 ff ff       	jmp    104d30 <alltraps>

0010595a <vector194>:
.globl vector194
vector194:
  pushl $0
  10595a:	6a 00                	push   $0x0
  pushl $194
  10595c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
  105961:	e9 ca f3 ff ff       	jmp    104d30 <alltraps>

00105966 <vector195>:
.globl vector195
vector195:
  pushl $0
  105966:	6a 00                	push   $0x0
  pushl $195
  105968:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
  10596d:	e9 be f3 ff ff       	jmp    104d30 <alltraps>

00105972 <vector196>:
.globl vector196
vector196:
  pushl $0
  105972:	6a 00                	push   $0x0
  pushl $196
  105974:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
  105979:	e9 b2 f3 ff ff       	jmp    104d30 <alltraps>

0010597e <vector197>:
.globl vector197
vector197:
  pushl $0
  10597e:	6a 00                	push   $0x0
  pushl $197
  105980:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
  105985:	e9 a6 f3 ff ff       	jmp    104d30 <alltraps>

0010598a <vector198>:
.globl vector198
vector198:
  pushl $0
  10598a:	6a 00                	push   $0x0
  pushl $198
  10598c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
  105991:	e9 9a f3 ff ff       	jmp    104d30 <alltraps>

00105996 <vector199>:
.globl vector199
vector199:
  pushl $0
  105996:	6a 00                	push   $0x0
  pushl $199
  105998:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
  10599d:	e9 8e f3 ff ff       	jmp    104d30 <alltraps>

001059a2 <vector200>:
.globl vector200
vector200:
  pushl $0
  1059a2:	6a 00                	push   $0x0
  pushl $200
  1059a4:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
  1059a9:	e9 82 f3 ff ff       	jmp    104d30 <alltraps>

001059ae <vector201>:
.globl vector201
vector201:
  pushl $0
  1059ae:	6a 00                	push   $0x0
  pushl $201
  1059b0:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
  1059b5:	e9 76 f3 ff ff       	jmp    104d30 <alltraps>

001059ba <vector202>:
.globl vector202
vector202:
  pushl $0
  1059ba:	6a 00                	push   $0x0
  pushl $202
  1059bc:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
  1059c1:	e9 6a f3 ff ff       	jmp    104d30 <alltraps>

001059c6 <vector203>:
.globl vector203
vector203:
  pushl $0
  1059c6:	6a 00                	push   $0x0
  pushl $203
  1059c8:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
  1059cd:	e9 5e f3 ff ff       	jmp    104d30 <alltraps>

001059d2 <vector204>:
.globl vector204
vector204:
  pushl $0
  1059d2:	6a 00                	push   $0x0
  pushl $204
  1059d4:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
  1059d9:	e9 52 f3 ff ff       	jmp    104d30 <alltraps>

001059de <vector205>:
.globl vector205
vector205:
  pushl $0
  1059de:	6a 00                	push   $0x0
  pushl $205
  1059e0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
  1059e5:	e9 46 f3 ff ff       	jmp    104d30 <alltraps>

001059ea <vector206>:
.globl vector206
vector206:
  pushl $0
  1059ea:	6a 00                	push   $0x0
  pushl $206
  1059ec:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
  1059f1:	e9 3a f3 ff ff       	jmp    104d30 <alltraps>

001059f6 <vector207>:
.globl vector207
vector207:
  pushl $0
  1059f6:	6a 00                	push   $0x0
  pushl $207
  1059f8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
  1059fd:	e9 2e f3 ff ff       	jmp    104d30 <alltraps>

00105a02 <vector208>:
.globl vector208
vector208:
  pushl $0
  105a02:	6a 00                	push   $0x0
  pushl $208
  105a04:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
  105a09:	e9 22 f3 ff ff       	jmp    104d30 <alltraps>

00105a0e <vector209>:
.globl vector209
vector209:
  pushl $0
  105a0e:	6a 00                	push   $0x0
  pushl $209
  105a10:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
  105a15:	e9 16 f3 ff ff       	jmp    104d30 <alltraps>

00105a1a <vector210>:
.globl vector210
vector210:
  pushl $0
  105a1a:	6a 00                	push   $0x0
  pushl $210
  105a1c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
  105a21:	e9 0a f3 ff ff       	jmp    104d30 <alltraps>

00105a26 <vector211>:
.globl vector211
vector211:
  pushl $0
  105a26:	6a 00                	push   $0x0
  pushl $211
  105a28:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
  105a2d:	e9 fe f2 ff ff       	jmp    104d30 <alltraps>

00105a32 <vector212>:
.globl vector212
vector212:
  pushl $0
  105a32:	6a 00                	push   $0x0
  pushl $212
  105a34:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
  105a39:	e9 f2 f2 ff ff       	jmp    104d30 <alltraps>

00105a3e <vector213>:
.globl vector213
vector213:
  pushl $0
  105a3e:	6a 00                	push   $0x0
  pushl $213
  105a40:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
  105a45:	e9 e6 f2 ff ff       	jmp    104d30 <alltraps>

00105a4a <vector214>:
.globl vector214
vector214:
  pushl $0
  105a4a:	6a 00                	push   $0x0
  pushl $214
  105a4c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
  105a51:	e9 da f2 ff ff       	jmp    104d30 <alltraps>

00105a56 <vector215>:
.globl vector215
vector215:
  pushl $0
  105a56:	6a 00                	push   $0x0
  pushl $215
  105a58:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
  105a5d:	e9 ce f2 ff ff       	jmp    104d30 <alltraps>

00105a62 <vector216>:
.globl vector216
vector216:
  pushl $0
  105a62:	6a 00                	push   $0x0
  pushl $216
  105a64:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
  105a69:	e9 c2 f2 ff ff       	jmp    104d30 <alltraps>

00105a6e <vector217>:
.globl vector217
vector217:
  pushl $0
  105a6e:	6a 00                	push   $0x0
  pushl $217
  105a70:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
  105a75:	e9 b6 f2 ff ff       	jmp    104d30 <alltraps>

00105a7a <vector218>:
.globl vector218
vector218:
  pushl $0
  105a7a:	6a 00                	push   $0x0
  pushl $218
  105a7c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
  105a81:	e9 aa f2 ff ff       	jmp    104d30 <alltraps>

00105a86 <vector219>:
.globl vector219
vector219:
  pushl $0
  105a86:	6a 00                	push   $0x0
  pushl $219
  105a88:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
  105a8d:	e9 9e f2 ff ff       	jmp    104d30 <alltraps>

00105a92 <vector220>:
.globl vector220
vector220:
  pushl $0
  105a92:	6a 00                	push   $0x0
  pushl $220
  105a94:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
  105a99:	e9 92 f2 ff ff       	jmp    104d30 <alltraps>

00105a9e <vector221>:
.globl vector221
vector221:
  pushl $0
  105a9e:	6a 00                	push   $0x0
  pushl $221
  105aa0:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
  105aa5:	e9 86 f2 ff ff       	jmp    104d30 <alltraps>

00105aaa <vector222>:
.globl vector222
vector222:
  pushl $0
  105aaa:	6a 00                	push   $0x0
  pushl $222
  105aac:	68 de 00 00 00       	push   $0xde
  jmp alltraps
  105ab1:	e9 7a f2 ff ff       	jmp    104d30 <alltraps>

00105ab6 <vector223>:
.globl vector223
vector223:
  pushl $0
  105ab6:	6a 00                	push   $0x0
  pushl $223
  105ab8:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
  105abd:	e9 6e f2 ff ff       	jmp    104d30 <alltraps>

00105ac2 <vector224>:
.globl vector224
vector224:
  pushl $0
  105ac2:	6a 00                	push   $0x0
  pushl $224
  105ac4:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
  105ac9:	e9 62 f2 ff ff       	jmp    104d30 <alltraps>

00105ace <vector225>:
.globl vector225
vector225:
  pushl $0
  105ace:	6a 00                	push   $0x0
  pushl $225
  105ad0:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
  105ad5:	e9 56 f2 ff ff       	jmp    104d30 <alltraps>

00105ada <vector226>:
.globl vector226
vector226:
  pushl $0
  105ada:	6a 00                	push   $0x0
  pushl $226
  105adc:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
  105ae1:	e9 4a f2 ff ff       	jmp    104d30 <alltraps>

00105ae6 <vector227>:
.globl vector227
vector227:
  pushl $0
  105ae6:	6a 00                	push   $0x0
  pushl $227
  105ae8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
  105aed:	e9 3e f2 ff ff       	jmp    104d30 <alltraps>

00105af2 <vector228>:
.globl vector228
vector228:
  pushl $0
  105af2:	6a 00                	push   $0x0
  pushl $228
  105af4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
  105af9:	e9 32 f2 ff ff       	jmp    104d30 <alltraps>

00105afe <vector229>:
.globl vector229
vector229:
  pushl $0
  105afe:	6a 00                	push   $0x0
  pushl $229
  105b00:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
  105b05:	e9 26 f2 ff ff       	jmp    104d30 <alltraps>

00105b0a <vector230>:
.globl vector230
vector230:
  pushl $0
  105b0a:	6a 00                	push   $0x0
  pushl $230
  105b0c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
  105b11:	e9 1a f2 ff ff       	jmp    104d30 <alltraps>

00105b16 <vector231>:
.globl vector231
vector231:
  pushl $0
  105b16:	6a 00                	push   $0x0
  pushl $231
  105b18:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
  105b1d:	e9 0e f2 ff ff       	jmp    104d30 <alltraps>

00105b22 <vector232>:
.globl vector232
vector232:
  pushl $0
  105b22:	6a 00                	push   $0x0
  pushl $232
  105b24:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
  105b29:	e9 02 f2 ff ff       	jmp    104d30 <alltraps>

00105b2e <vector233>:
.globl vector233
vector233:
  pushl $0
  105b2e:	6a 00                	push   $0x0
  pushl $233
  105b30:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
  105b35:	e9 f6 f1 ff ff       	jmp    104d30 <alltraps>

00105b3a <vector234>:
.globl vector234
vector234:
  pushl $0
  105b3a:	6a 00                	push   $0x0
  pushl $234
  105b3c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
  105b41:	e9 ea f1 ff ff       	jmp    104d30 <alltraps>

00105b46 <vector235>:
.globl vector235
vector235:
  pushl $0
  105b46:	6a 00                	push   $0x0
  pushl $235
  105b48:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
  105b4d:	e9 de f1 ff ff       	jmp    104d30 <alltraps>

00105b52 <vector236>:
.globl vector236
vector236:
  pushl $0
  105b52:	6a 00                	push   $0x0
  pushl $236
  105b54:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
  105b59:	e9 d2 f1 ff ff       	jmp    104d30 <alltraps>

00105b5e <vector237>:
.globl vector237
vector237:
  pushl $0
  105b5e:	6a 00                	push   $0x0
  pushl $237
  105b60:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
  105b65:	e9 c6 f1 ff ff       	jmp    104d30 <alltraps>

00105b6a <vector238>:
.globl vector238
vector238:
  pushl $0
  105b6a:	6a 00                	push   $0x0
  pushl $238
  105b6c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
  105b71:	e9 ba f1 ff ff       	jmp    104d30 <alltraps>

00105b76 <vector239>:
.globl vector239
vector239:
  pushl $0
  105b76:	6a 00                	push   $0x0
  pushl $239
  105b78:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
  105b7d:	e9 ae f1 ff ff       	jmp    104d30 <alltraps>

00105b82 <vector240>:
.globl vector240
vector240:
  pushl $0
  105b82:	6a 00                	push   $0x0
  pushl $240
  105b84:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
  105b89:	e9 a2 f1 ff ff       	jmp    104d30 <alltraps>

00105b8e <vector241>:
.globl vector241
vector241:
  pushl $0
  105b8e:	6a 00                	push   $0x0
  pushl $241
  105b90:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
  105b95:	e9 96 f1 ff ff       	jmp    104d30 <alltraps>

00105b9a <vector242>:
.globl vector242
vector242:
  pushl $0
  105b9a:	6a 00                	push   $0x0
  pushl $242
  105b9c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
  105ba1:	e9 8a f1 ff ff       	jmp    104d30 <alltraps>

00105ba6 <vector243>:
.globl vector243
vector243:
  pushl $0
  105ba6:	6a 00                	push   $0x0
  pushl $243
  105ba8:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
  105bad:	e9 7e f1 ff ff       	jmp    104d30 <alltraps>

00105bb2 <vector244>:
.globl vector244
vector244:
  pushl $0
  105bb2:	6a 00                	push   $0x0
  pushl $244
  105bb4:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
  105bb9:	e9 72 f1 ff ff       	jmp    104d30 <alltraps>

00105bbe <vector245>:
.globl vector245
vector245:
  pushl $0
  105bbe:	6a 00                	push   $0x0
  pushl $245
  105bc0:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
  105bc5:	e9 66 f1 ff ff       	jmp    104d30 <alltraps>

00105bca <vector246>:
.globl vector246
vector246:
  pushl $0
  105bca:	6a 00                	push   $0x0
  pushl $246
  105bcc:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
  105bd1:	e9 5a f1 ff ff       	jmp    104d30 <alltraps>

00105bd6 <vector247>:
.globl vector247
vector247:
  pushl $0
  105bd6:	6a 00                	push   $0x0
  pushl $247
  105bd8:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
  105bdd:	e9 4e f1 ff ff       	jmp    104d30 <alltraps>

00105be2 <vector248>:
.globl vector248
vector248:
  pushl $0
  105be2:	6a 00                	push   $0x0
  pushl $248
  105be4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
  105be9:	e9 42 f1 ff ff       	jmp    104d30 <alltraps>

00105bee <vector249>:
.globl vector249
vector249:
  pushl $0
  105bee:	6a 00                	push   $0x0
  pushl $249
  105bf0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
  105bf5:	e9 36 f1 ff ff       	jmp    104d30 <alltraps>

00105bfa <vector250>:
.globl vector250
vector250:
  pushl $0
  105bfa:	6a 00                	push   $0x0
  pushl $250
  105bfc:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
  105c01:	e9 2a f1 ff ff       	jmp    104d30 <alltraps>

00105c06 <vector251>:
.globl vector251
vector251:
  pushl $0
  105c06:	6a 00                	push   $0x0
  pushl $251
  105c08:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
  105c0d:	e9 1e f1 ff ff       	jmp    104d30 <alltraps>

00105c12 <vector252>:
.globl vector252
vector252:
  pushl $0
  105c12:	6a 00                	push   $0x0
  pushl $252
  105c14:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
  105c19:	e9 12 f1 ff ff       	jmp    104d30 <alltraps>

00105c1e <vector253>:
.globl vector253
vector253:
  pushl $0
  105c1e:	6a 00                	push   $0x0
  pushl $253
  105c20:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
  105c25:	e9 06 f1 ff ff       	jmp    104d30 <alltraps>

00105c2a <vector254>:
.globl vector254
vector254:
  pushl $0
  105c2a:	6a 00                	push   $0x0
  pushl $254
  105c2c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
  105c31:	e9 fa f0 ff ff       	jmp    104d30 <alltraps>

00105c36 <vector255>:
.globl vector255
vector255:
  pushl $0
  105c36:	6a 00                	push   $0x0
  pushl $255
  105c38:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
  105c3d:	e9 ee f0 ff ff       	jmp    104d30 <alltraps>
  105c42:	90                   	nop
  105c43:	90                   	nop
  105c44:	90                   	nop
  105c45:	90                   	nop
  105c46:	90                   	nop
  105c47:	90                   	nop
  105c48:	90                   	nop
  105c49:	90                   	nop
  105c4a:	90                   	nop
  105c4b:	90                   	nop
  105c4c:	90                   	nop
  105c4d:	90                   	nop
  105c4e:	90                   	nop
  105c4f:	90                   	nop

00105c50 <vmenable>:
}

// Turn on paging.
void
vmenable(void)
{
  105c50:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105c51:	a1 d0 78 10 00       	mov    0x1078d0,%eax
  105c56:	89 e5                	mov    %esp,%ebp
  105c58:	0f 22 d8             	mov    %eax,%cr3

static inline uint
rcr0(void)
{
  uint val;
  asm volatile("movl %%cr0,%0" : "=r" (val));
  105c5b:	0f 20 c0             	mov    %cr0,%eax
}

static inline void
lcr0(uint val)
{
  asm volatile("movl %0,%%cr0" : : "r" (val));
  105c5e:	0d 00 00 00 80       	or     $0x80000000,%eax
  105c63:	0f 22 c0             	mov    %eax,%cr0

  switchkvm(); // load kpgdir into cr3
  cr0 = rcr0();
  cr0 |= CR0_PG;
  lcr0(cr0);
}
  105c66:	5d                   	pop    %ebp
  105c67:	c3                   	ret    
  105c68:	90                   	nop
  105c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00105c70 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  105c70:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105c71:	a1 d0 78 10 00       	mov    0x1078d0,%eax
  105c76:	89 e5                	mov    %esp,%ebp
  105c78:	0f 22 d8             	mov    %eax,%cr3
  lcr3(PADDR(kpgdir));   // switch to the kernel page table
}
  105c7b:	5d                   	pop    %ebp
  105c7c:	c3                   	ret    
  105c7d:	8d 76 00             	lea    0x0(%esi),%esi

00105c80 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105c80:	55                   	push   %ebp
  105c81:	89 e5                	mov    %esp,%ebp
  105c83:	83 ec 28             	sub    $0x28,%esp
  105c86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  105c89:	89 d3                	mov    %edx,%ebx
  105c8b:	c1 eb 16             	shr    $0x16,%ebx
  105c8e:	8d 1c 98             	lea    (%eax,%ebx,4),%ebx
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105c91:	89 75 fc             	mov    %esi,-0x4(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
  105c94:	8b 33                	mov    (%ebx),%esi
  105c96:	f7 c6 01 00 00 00    	test   $0x1,%esi
  105c9c:	74 22                	je     105cc0 <walkpgdir+0x40>
    pgtab = (pte_t*)PTE_ADDR(*pde);
  105c9e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105ca4:	c1 ea 0a             	shr    $0xa,%edx
  105ca7:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  105cad:	8d 04 16             	lea    (%esi,%edx,1),%eax
}
  105cb0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  105cb3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  105cb6:	89 ec                	mov    %ebp,%esp
  105cb8:	5d                   	pop    %ebp
  105cb9:	c3                   	ret    
  105cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105cc0:	85 c9                	test   %ecx,%ecx
  105cc2:	75 04                	jne    105cc8 <walkpgdir+0x48>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105cc4:	31 c0                	xor    %eax,%eax
  105cc6:	eb e8                	jmp    105cb0 <walkpgdir+0x30>

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105cc8:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105ccb:	90                   	nop
  105ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105cd0:	e8 8b c5 ff ff       	call   102260 <kalloc>
  105cd5:	85 c0                	test   %eax,%eax
  105cd7:	89 c6                	mov    %eax,%esi
  105cd9:	74 e9                	je     105cc4 <walkpgdir+0x44>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
  105cdb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105ce2:	00 
  105ce3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105cea:	00 
  105ceb:	89 04 24             	mov    %eax,(%esp)
  105cee:	e8 ed de ff ff       	call   103be0 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  105cf3:	89 f0                	mov    %esi,%eax
  105cf5:	83 c8 07             	or     $0x7,%eax
  105cf8:	89 03                	mov    %eax,(%ebx)
  105cfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105cfd:	eb a5                	jmp    105ca4 <walkpgdir+0x24>
  105cff:	90                   	nop

00105d00 <uva2ka>:
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105d00:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105d01:	31 c9                	xor    %ecx,%ecx
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105d03:	89 e5                	mov    %esp,%ebp
  105d05:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105d08:	8b 55 0c             	mov    0xc(%ebp),%edx
  105d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d0e:	e8 6d ff ff ff       	call   105c80 <walkpgdir>
  if((*pte & PTE_P) == 0)
  105d13:	8b 00                	mov    (%eax),%eax
  105d15:	a8 01                	test   $0x1,%al
  105d17:	75 07                	jne    105d20 <uva2ka+0x20>
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)PTE_ADDR(*pte);
  105d19:	31 c0                	xor    %eax,%eax
}
  105d1b:	c9                   	leave  
  105d1c:	c3                   	ret    
  105d1d:	8d 76 00             	lea    0x0(%esi),%esi
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
  105d20:	a8 04                	test   $0x4,%al
  105d22:	74 f5                	je     105d19 <uva2ka+0x19>
    return 0;
  return (char*)PTE_ADDR(*pte);
  105d24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
  105d29:	c9                   	leave  
  105d2a:	c3                   	ret    
  105d2b:	90                   	nop
  105d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00105d30 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  105d30:	55                   	push   %ebp
  105d31:	89 e5                	mov    %esp,%ebp
  105d33:	57                   	push   %edi
  105d34:	56                   	push   %esi
  105d35:	53                   	push   %ebx
  105d36:	83 ec 2c             	sub    $0x2c,%esp
  105d39:	8b 7d 14             	mov    0x14(%ebp),%edi
  105d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  105d3f:	85 ff                	test   %edi,%edi
  105d41:	74 75                	je     105db8 <copyout+0x88>
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  105d43:	8b 45 10             	mov    0x10(%ebp),%eax
  105d46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105d49:	eb 3a                	jmp    105d85 <copyout+0x55>
  105d4b:	90                   	nop
  105d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
  105d50:	89 f3                	mov    %esi,%ebx
  105d52:	29 d3                	sub    %edx,%ebx
  105d54:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  105d5a:	39 fb                	cmp    %edi,%ebx
  105d5c:	76 02                	jbe    105d60 <copyout+0x30>
  105d5e:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
  105d60:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  105d64:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  105d67:	29 f2                	sub    %esi,%edx
  105d69:	8d 14 10             	lea    (%eax,%edx,1),%edx
  105d6c:	89 14 24             	mov    %edx,(%esp)
  105d6f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  105d73:	e8 e8 de ff ff       	call   103c60 <memmove>
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  105d78:	29 df                	sub    %ebx,%edi
  105d7a:	74 3c                	je     105db8 <copyout+0x88>
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
  105d7c:	01 5d e4             	add    %ebx,-0x1c(%ebp)
    va = va0 + PGSIZE;
  105d7f:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
  105d85:	89 d6                	mov    %edx,%esi
  105d87:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
  105d8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  105d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  105d94:	89 0c 24             	mov    %ecx,(%esp)
  105d97:	89 55 e0             	mov    %edx,-0x20(%ebp)
  105d9a:	e8 61 ff ff ff       	call   105d00 <uva2ka>
    if(pa0 == 0)
  105d9f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105da2:	85 c0                	test   %eax,%eax
  105da4:	75 aa                	jne    105d50 <copyout+0x20>
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
  105da6:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  105da9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
  105dae:	5b                   	pop    %ebx
  105daf:	5e                   	pop    %esi
  105db0:	5f                   	pop    %edi
  105db1:	5d                   	pop    %ebp
  105db2:	c3                   	ret    
  105db3:	90                   	nop
  105db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105db8:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  105dbb:	31 c0                	xor    %eax,%eax
  }
  return 0;
}
  105dbd:	5b                   	pop    %ebx
  105dbe:	5e                   	pop    %esi
  105dbf:	5f                   	pop    %edi
  105dc0:	5d                   	pop    %ebp
  105dc1:	c3                   	ret    
  105dc2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  105dc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00105dd0 <mappages>:
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  105dd0:	55                   	push   %ebp
  105dd1:	89 e5                	mov    %esp,%ebp
  105dd3:	57                   	push   %edi
  105dd4:	56                   	push   %esi
  105dd5:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  105dd6:	89 d3                	mov    %edx,%ebx
  last = PGROUNDDOWN(la + size - 1);
  105dd8:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  105ddc:	83 ec 2c             	sub    $0x2c,%esp
  105ddf:	8b 75 08             	mov    0x8(%ebp),%esi
  105de2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  105de5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = PGROUNDDOWN(la + size - 1);
  105deb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  105df1:	83 4d 0c 01          	orl    $0x1,0xc(%ebp)
  105df5:	eb 1d                	jmp    105e14 <mappages+0x44>
  105df7:	90                   	nop
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
  105df8:	f6 00 01             	testb  $0x1,(%eax)
  105dfb:	75 45                	jne    105e42 <mappages+0x72>
      panic("remap");
    *pte = pa | perm | PTE_P;
  105dfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  105e00:	09 f2                	or     %esi,%edx
    if(a == last)
  105e02:	39 fb                	cmp    %edi,%ebx
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  105e04:	89 10                	mov    %edx,(%eax)
    if(a == last)
  105e06:	74 30                	je     105e38 <mappages+0x68>
      break;
    a += PGSIZE;
  105e08:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
  105e0e:	81 c6 00 10 00 00    	add    $0x1000,%esi
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
  105e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105e17:	b9 01 00 00 00       	mov    $0x1,%ecx
  105e1c:	89 da                	mov    %ebx,%edx
  105e1e:	e8 5d fe ff ff       	call   105c80 <walkpgdir>
    if(pte == 0)
  105e23:	85 c0                	test   %eax,%eax
  105e25:	75 d1                	jne    105df8 <mappages+0x28>
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  105e27:	83 c4 2c             	add    $0x2c,%esp
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  105e2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  105e2f:	5b                   	pop    %ebx
  105e30:	5e                   	pop    %esi
  105e31:	5f                   	pop    %edi
  105e32:	5d                   	pop    %ebp
  105e33:	c3                   	ret    
  105e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105e38:	83 c4 2c             	add    $0x2c,%esp
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
  105e3b:	31 c0                	xor    %eax,%eax
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  105e3d:	5b                   	pop    %ebx
  105e3e:	5e                   	pop    %esi
  105e3f:	5f                   	pop    %edi
  105e40:	5d                   	pop    %ebp
  105e41:	c3                   	ret    
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
  105e42:	c7 04 24 cc 6c 10 00 	movl   $0x106ccc,(%esp)
  105e49:	e8 d2 aa ff ff       	call   100920 <panic>
  105e4e:	66 90                	xchg   %ax,%ax

00105e50 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
  105e50:	55                   	push   %ebp
  105e51:	89 e5                	mov    %esp,%ebp
  105e53:	56                   	push   %esi
  105e54:	53                   	push   %ebx
  105e55:	83 ec 10             	sub    $0x10,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
  105e58:	e8 03 c4 ff ff       	call   102260 <kalloc>
  105e5d:	85 c0                	test   %eax,%eax
  105e5f:	89 c6                	mov    %eax,%esi
  105e61:	74 50                	je     105eb3 <setupkvm+0x63>
    return 0;
  memset(pgdir, 0, PGSIZE);
  105e63:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105e6a:	00 
  105e6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105e72:	00 
  105e73:	89 04 24             	mov    %eax,(%esp)
  105e76:	e8 65 dd ff ff       	call   103be0 <memset>
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  105e7b:	b8 70 77 10 00       	mov    $0x107770,%eax
  105e80:	3d 40 77 10 00       	cmp    $0x107740,%eax
  105e85:	76 2c                	jbe    105eb3 <setupkvm+0x63>
  {(void*)0xFE000000, 0,               PTE_W},  // device mappings
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
  105e87:	bb 40 77 10 00       	mov    $0x107740,%ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  105e8c:	8b 13                	mov    (%ebx),%edx
  105e8e:	8b 4b 04             	mov    0x4(%ebx),%ecx
  105e91:	8b 43 08             	mov    0x8(%ebx),%eax
  105e94:	89 14 24             	mov    %edx,(%esp)
  105e97:	29 d1                	sub    %edx,%ecx
  105e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e9d:	89 f0                	mov    %esi,%eax
  105e9f:	e8 2c ff ff ff       	call   105dd0 <mappages>
  105ea4:	85 c0                	test   %eax,%eax
  105ea6:	78 18                	js     105ec0 <setupkvm+0x70>

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  105ea8:	83 c3 0c             	add    $0xc,%ebx
  105eab:	81 fb 70 77 10 00    	cmp    $0x107770,%ebx
  105eb1:	75 d9                	jne    105e8c <setupkvm+0x3c>
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
      return 0;

  return pgdir;
}
  105eb3:	83 c4 10             	add    $0x10,%esp
  105eb6:	89 f0                	mov    %esi,%eax
  105eb8:	5b                   	pop    %ebx
  105eb9:	5e                   	pop    %esi
  105eba:	5d                   	pop    %ebp
  105ebb:	c3                   	ret    
  105ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  105ec0:	31 f6                	xor    %esi,%esi
      return 0;

  return pgdir;
}
  105ec2:	83 c4 10             	add    $0x10,%esp
  105ec5:	89 f0                	mov    %esi,%eax
  105ec7:	5b                   	pop    %ebx
  105ec8:	5e                   	pop    %esi
  105ec9:	5d                   	pop    %ebp
  105eca:	c3                   	ret    
  105ecb:	90                   	nop
  105ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00105ed0 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
  105ed0:	55                   	push   %ebp
  105ed1:	89 e5                	mov    %esp,%ebp
  105ed3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
  105ed6:	e8 75 ff ff ff       	call   105e50 <setupkvm>
  105edb:	a3 d0 78 10 00       	mov    %eax,0x1078d0
}
  105ee0:	c9                   	leave  
  105ee1:	c3                   	ret    
  105ee2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  105ee9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00105ef0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  105ef0:	55                   	push   %ebp
  105ef1:	89 e5                	mov    %esp,%ebp
  105ef3:	83 ec 38             	sub    $0x38,%esp
  105ef6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  105ef9:	8b 75 10             	mov    0x10(%ebp),%esi
  105efc:	8b 45 08             	mov    0x8(%ebp),%eax
  105eff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  105f02:	8b 7d 0c             	mov    0xc(%ebp),%edi
  105f05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  105f08:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  105f0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  105f11:	77 53                	ja     105f66 <inituvm+0x76>
    panic("inituvm: more than a page");
  mem = kalloc();
  105f13:	e8 48 c3 ff ff       	call   102260 <kalloc>
  memset(mem, 0, PGSIZE);
  105f18:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105f1f:	00 
  105f20:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105f27:	00 
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  105f28:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
  105f2a:	89 04 24             	mov    %eax,(%esp)
  105f2d:	e8 ae dc ff ff       	call   103be0 <memset>
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  105f32:	b9 00 10 00 00       	mov    $0x1000,%ecx
  105f37:	31 d2                	xor    %edx,%edx
  105f39:	89 1c 24             	mov    %ebx,(%esp)
  105f3c:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  105f43:	00 
  105f44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105f47:	e8 84 fe ff ff       	call   105dd0 <mappages>
  memmove(mem, init, sz);
  105f4c:	89 75 10             	mov    %esi,0x10(%ebp)
}
  105f4f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  105f52:	89 7d 0c             	mov    %edi,0xc(%ebp)
}
  105f55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  105f58:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  105f5b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  105f5e:	89 ec                	mov    %ebp,%esp
  105f60:	5d                   	pop    %ebp
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  105f61:	e9 fa dc ff ff       	jmp    103c60 <memmove>
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  105f66:	c7 04 24 d2 6c 10 00 	movl   $0x106cd2,(%esp)
  105f6d:	e8 ae a9 ff ff       	call   100920 <panic>
  105f72:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  105f79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00105f80 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  105f80:	55                   	push   %ebp
  105f81:	89 e5                	mov    %esp,%ebp
  105f83:	57                   	push   %edi
  105f84:	56                   	push   %esi
  105f85:	53                   	push   %ebx
  105f86:	83 ec 2c             	sub    $0x2c,%esp
  105f89:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  105f8c:	39 75 10             	cmp    %esi,0x10(%ebp)
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  105f8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;
  105f92:	89 f0                	mov    %esi,%eax
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  105f94:	73 59                	jae    105fef <deallocuvm+0x6f>
    return oldsz;

  a = PGROUNDUP(newsz);
  105f96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  105f99:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  105f9f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
  105fa5:	39 de                	cmp    %ebx,%esi
  105fa7:	76 43                	jbe    105fec <deallocuvm+0x6c>
  105fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
  105fb0:	31 c9                	xor    %ecx,%ecx
  105fb2:	89 da                	mov    %ebx,%edx
  105fb4:	89 f8                	mov    %edi,%eax
  105fb6:	e8 c5 fc ff ff       	call   105c80 <walkpgdir>
    if(pte && (*pte & PTE_P) != 0){
  105fbb:	85 c0                	test   %eax,%eax
  105fbd:	74 23                	je     105fe2 <deallocuvm+0x62>
  105fbf:	8b 10                	mov    (%eax),%edx
  105fc1:	f6 c2 01             	test   $0x1,%dl
  105fc4:	74 1c                	je     105fe2 <deallocuvm+0x62>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
  105fc6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  105fcc:	74 29                	je     105ff7 <deallocuvm+0x77>
        panic("kfree");
      kfree((char*)pa);
  105fce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105fd1:	89 14 24             	mov    %edx,(%esp)
  105fd4:	e8 c7 c2 ff ff       	call   1022a0 <kfree>
      *pte = 0;
  105fd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105fdc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
  105fe2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  105fe8:	39 de                	cmp    %ebx,%esi
  105fea:	77 c4                	ja     105fb0 <deallocuvm+0x30>
        panic("kfree");
      kfree((char*)pa);
      *pte = 0;
    }
  }
  return newsz;
  105fec:	8b 45 10             	mov    0x10(%ebp),%eax
}
  105fef:	83 c4 2c             	add    $0x2c,%esp
  105ff2:	5b                   	pop    %ebx
  105ff3:	5e                   	pop    %esi
  105ff4:	5f                   	pop    %edi
  105ff5:	5d                   	pop    %ebp
  105ff6:	c3                   	ret    
  for(; a  < oldsz; a += PGSIZE){
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(pte && (*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
  105ff7:	c7 04 24 7e 66 10 00 	movl   $0x10667e,(%esp)
  105ffe:	e8 1d a9 ff ff       	call   100920 <panic>
  106003:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  106009:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106010 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
  106010:	55                   	push   %ebp
  106011:	89 e5                	mov    %esp,%ebp
  106013:	56                   	push   %esi
  106014:	53                   	push   %ebx
  106015:	83 ec 10             	sub    $0x10,%esp
  106018:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint i;

  if(pgdir == 0)
  10601b:	85 db                	test   %ebx,%ebx
  10601d:	74 59                	je     106078 <freevm+0x68>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  10601f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  106026:	00 
  106027:	31 f6                	xor    %esi,%esi
  106029:	c7 44 24 04 00 00 0a 	movl   $0xa0000,0x4(%esp)
  106030:	00 
  106031:	89 1c 24             	mov    %ebx,(%esp)
  106034:	e8 47 ff ff ff       	call   105f80 <deallocuvm>
  106039:	eb 10                	jmp    10604b <freevm+0x3b>
  10603b:	90                   	nop
  10603c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(i = 0; i < NPDENTRIES; i++){
  106040:	83 c6 01             	add    $0x1,%esi
  106043:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106049:	74 1f                	je     10606a <freevm+0x5a>
    if(pgdir[i] & PTE_P)
  10604b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  10604e:	a8 01                	test   $0x1,%al
  106050:	74 ee                	je     106040 <freevm+0x30>
      kfree((char*)PTE_ADDR(pgdir[i]));
  106052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106057:	83 c6 01             	add    $0x1,%esi
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  10605a:	89 04 24             	mov    %eax,(%esp)
  10605d:	e8 3e c2 ff ff       	call   1022a0 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106062:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106068:	75 e1                	jne    10604b <freevm+0x3b>
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  10606a:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  10606d:	83 c4 10             	add    $0x10,%esp
  106070:	5b                   	pop    %ebx
  106071:	5e                   	pop    %esi
  106072:	5d                   	pop    %ebp
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  106073:	e9 28 c2 ff ff       	jmp    1022a0 <kfree>
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  106078:	c7 04 24 ec 6c 10 00 	movl   $0x106cec,(%esp)
  10607f:	e8 9c a8 ff ff       	call   100920 <panic>
  106084:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10608a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00106090 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
  106090:	55                   	push   %ebp
  106091:	89 e5                	mov    %esp,%ebp
  106093:	57                   	push   %edi
  106094:	56                   	push   %esi
  106095:	53                   	push   %ebx
  106096:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
  106099:	e8 b2 fd ff ff       	call   105e50 <setupkvm>
  10609e:	85 c0                	test   %eax,%eax
  1060a0:	89 c6                	mov    %eax,%esi
  1060a2:	0f 84 84 00 00 00    	je     10612c <copyuvm+0x9c>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  1060a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060ab:	85 c0                	test   %eax,%eax
  1060ad:	74 7d                	je     10612c <copyuvm+0x9c>
  1060af:	31 db                	xor    %ebx,%ebx
  1060b1:	eb 47                	jmp    1060fa <copyuvm+0x6a>
  1060b3:	90                   	nop
  1060b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)pa, PGSIZE);
  1060b8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  1060be:	89 54 24 04          	mov    %edx,0x4(%esp)
  1060c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1060c9:	00 
  1060ca:	89 04 24             	mov    %eax,(%esp)
  1060cd:	e8 8e db ff ff       	call   103c60 <memmove>
    if(mappages(d, (void*)i, PGSIZE, PADDR(mem), PTE_W|PTE_U) < 0)
  1060d2:	b9 00 10 00 00       	mov    $0x1000,%ecx
  1060d7:	89 da                	mov    %ebx,%edx
  1060d9:	89 f0                	mov    %esi,%eax
  1060db:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  1060e2:	00 
  1060e3:	89 3c 24             	mov    %edi,(%esp)
  1060e6:	e8 e5 fc ff ff       	call   105dd0 <mappages>
  1060eb:	85 c0                	test   %eax,%eax
  1060ed:	78 33                	js     106122 <copyuvm+0x92>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  1060ef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  1060f5:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
  1060f8:	76 32                	jbe    10612c <copyuvm+0x9c>
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
  1060fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1060fd:	31 c9                	xor    %ecx,%ecx
  1060ff:	89 da                	mov    %ebx,%edx
  106101:	e8 7a fb ff ff       	call   105c80 <walkpgdir>
  106106:	85 c0                	test   %eax,%eax
  106108:	74 2c                	je     106136 <copyuvm+0xa6>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
  10610a:	8b 10                	mov    (%eax),%edx
  10610c:	f6 c2 01             	test   $0x1,%dl
  10610f:	74 31                	je     106142 <copyuvm+0xb2>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
  106111:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  106114:	e8 47 c1 ff ff       	call   102260 <kalloc>
  106119:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10611c:	85 c0                	test   %eax,%eax
  10611e:	89 c7                	mov    %eax,%edi
  106120:	75 96                	jne    1060b8 <copyuvm+0x28>
      goto bad;
  }
  return d;

bad:
  freevm(d);
  106122:	89 34 24             	mov    %esi,(%esp)
  106125:	31 f6                	xor    %esi,%esi
  106127:	e8 e4 fe ff ff       	call   106010 <freevm>
  return 0;
}
  10612c:	83 c4 2c             	add    $0x2c,%esp
  10612f:	89 f0                	mov    %esi,%eax
  106131:	5b                   	pop    %ebx
  106132:	5e                   	pop    %esi
  106133:	5f                   	pop    %edi
  106134:	5d                   	pop    %ebp
  106135:	c3                   	ret    

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
      panic("copyuvm: pte should exist");
  106136:	c7 04 24 fd 6c 10 00 	movl   $0x106cfd,(%esp)
  10613d:	e8 de a7 ff ff       	call   100920 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
  106142:	c7 04 24 17 6d 10 00 	movl   $0x106d17,(%esp)
  106149:	e8 d2 a7 ff ff       	call   100920 <panic>
  10614e:	66 90                	xchg   %ax,%ax

00106150 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106150:	55                   	push   %ebp
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106151:	31 c0                	xor    %eax,%eax

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106153:	89 e5                	mov    %esp,%ebp
  106155:	57                   	push   %edi
  106156:	56                   	push   %esi
  106157:	53                   	push   %ebx
  106158:	83 ec 2c             	sub    $0x2c,%esp
  10615b:	8b 75 10             	mov    0x10(%ebp),%esi
  10615e:	8b 7d 08             	mov    0x8(%ebp),%edi
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106161:	81 fe 00 00 0a 00    	cmp    $0xa0000,%esi
  106167:	0f 87 8e 00 00 00    	ja     1061fb <allocuvm+0xab>
    return 0;
  if(newsz < oldsz)
    return oldsz;
  10616d:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *mem;
  uint a;

  if(newsz > USERTOP)
    return 0;
  if(newsz < oldsz)
  106170:	39 c6                	cmp    %eax,%esi
  106172:	0f 82 83 00 00 00    	jb     1061fb <allocuvm+0xab>
    return oldsz;

  a = PGROUNDUP(oldsz);
  106178:	89 c3                	mov    %eax,%ebx
  10617a:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  106180:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
  106186:	39 de                	cmp    %ebx,%esi
  106188:	77 47                	ja     1061d1 <allocuvm+0x81>
  10618a:	eb 7c                	jmp    106208 <allocuvm+0xb8>
  10618c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
  106190:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  106197:	00 
  106198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10619f:	00 
  1061a0:	89 04 24             	mov    %eax,(%esp)
  1061a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1061a6:	e8 35 da ff ff       	call   103be0 <memset>
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  1061ab:	b9 00 10 00 00       	mov    $0x1000,%ecx
  1061b0:	89 f8                	mov    %edi,%eax
  1061b2:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  1061b9:	00 
  1061ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1061bd:	89 14 24             	mov    %edx,(%esp)
  1061c0:	89 da                	mov    %ebx,%edx
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  1061c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  1061c8:	e8 03 fc ff ff       	call   105dd0 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  1061cd:	39 de                	cmp    %ebx,%esi
  1061cf:	76 37                	jbe    106208 <allocuvm+0xb8>
    mem = kalloc();
  1061d1:	e8 8a c0 ff ff       	call   102260 <kalloc>
    if(mem == 0){
  1061d6:	85 c0                	test   %eax,%eax
  1061d8:	75 b6                	jne    106190 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
  1061da:	c7 04 24 31 6d 10 00 	movl   $0x106d31,(%esp)
  1061e1:	e8 4a a3 ff ff       	call   100530 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
  1061e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  1061ed:	89 3c 24             	mov    %edi,(%esp)
  1061f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1061f4:	e8 87 fd ff ff       	call   105f80 <deallocuvm>
  1061f9:	31 c0                	xor    %eax,%eax
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
}
  1061fb:	83 c4 2c             	add    $0x2c,%esp
  1061fe:	5b                   	pop    %ebx
  1061ff:	5e                   	pop    %esi
  106200:	5f                   	pop    %edi
  106201:	5d                   	pop    %ebp
  106202:	c3                   	ret    
  106203:	90                   	nop
  106204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  106208:	83 c4 2c             	add    $0x2c,%esp
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
  10620b:	89 f0                	mov    %esi,%eax
}
  10620d:	5b                   	pop    %ebx
  10620e:	5e                   	pop    %esi
  10620f:	5f                   	pop    %edi
  106210:	5d                   	pop    %ebp
  106211:	c3                   	ret    
  106212:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  106219:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106220 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
  106220:	55                   	push   %ebp
  106221:	89 e5                	mov    %esp,%ebp
  106223:	57                   	push   %edi
  106224:	56                   	push   %esi
  106225:	53                   	push   %ebx
  106226:	83 ec 3c             	sub    $0x3c,%esp
  106229:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
  10622c:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
  106232:	0f 85 96 00 00 00    	jne    1062ce <loaduvm+0xae>
    panic("loaduvm: addr must be page aligned");
  106238:	8b 75 18             	mov    0x18(%ebp),%esi
  10623b:	31 db                	xor    %ebx,%ebx
  for(i = 0; i < sz; i += PGSIZE){
  10623d:	85 f6                	test   %esi,%esi
  10623f:	74 77                	je     1062b8 <loaduvm+0x98>
  106241:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  106244:	eb 13                	jmp    106259 <loaduvm+0x39>
  106246:	66 90                	xchg   %ax,%ax
  106248:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  10624e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  106254:	39 5d 18             	cmp    %ebx,0x18(%ebp)
  106257:	76 5f                	jbe    1062b8 <loaduvm+0x98>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
  106259:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10625c:	31 c9                	xor    %ecx,%ecx
  10625e:	8b 45 08             	mov    0x8(%ebp),%eax
  106261:	01 da                	add    %ebx,%edx
  106263:	e8 18 fa ff ff       	call   105c80 <walkpgdir>
  106268:	85 c0                	test   %eax,%eax
  10626a:	74 56                	je     1062c2 <loaduvm+0xa2>
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
  10626c:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
  106272:	8b 00                	mov    (%eax),%eax
    if(sz - i < PGSIZE)
  106274:	ba 00 10 00 00       	mov    $0x1000,%edx
  106279:	77 02                	ja     10627d <loaduvm+0x5d>
  10627b:	89 f2                	mov    %esi,%edx
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  10627d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106281:	8b 7d 14             	mov    0x14(%ebp),%edi
  106284:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  106289:	89 44 24 04          	mov    %eax,0x4(%esp)
  10628d:	8d 0c 3b             	lea    (%ebx,%edi,1),%ecx
  106290:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  106294:	8b 45 10             	mov    0x10(%ebp),%eax
  106297:	89 04 24             	mov    %eax,(%esp)
  10629a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10629d:	e8 ce b0 ff ff       	call   101370 <readi>
  1062a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1062a5:	39 d0                	cmp    %edx,%eax
  1062a7:	74 9f                	je     106248 <loaduvm+0x28>
      return -1;
  }
  return 0;
}
  1062a9:	83 c4 3c             	add    $0x3c,%esp
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  1062ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return -1;
  }
  return 0;
}
  1062b1:	5b                   	pop    %ebx
  1062b2:	5e                   	pop    %esi
  1062b3:	5f                   	pop    %edi
  1062b4:	5d                   	pop    %ebp
  1062b5:	c3                   	ret    
  1062b6:	66 90                	xchg   %ax,%ax
  1062b8:	83 c4 3c             	add    $0x3c,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
  1062bb:	31 c0                	xor    %eax,%eax
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
      return -1;
  }
  return 0;
}
  1062bd:	5b                   	pop    %ebx
  1062be:	5e                   	pop    %esi
  1062bf:	5f                   	pop    %edi
  1062c0:	5d                   	pop    %ebp
  1062c1:	c3                   	ret    

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
  1062c2:	c7 04 24 49 6d 10 00 	movl   $0x106d49,(%esp)
  1062c9:	e8 52 a6 ff ff       	call   100920 <panic>
{
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  1062ce:	c7 04 24 7c 6d 10 00 	movl   $0x106d7c,(%esp)
  1062d5:	e8 46 a6 ff ff       	call   100920 <panic>
  1062da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001062e0 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  1062e0:	55                   	push   %ebp
  1062e1:	89 e5                	mov    %esp,%ebp
  1062e3:	53                   	push   %ebx
  1062e4:	83 ec 14             	sub    $0x14,%esp
  1062e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
  1062ea:	e8 61 d7 ff ff       	call   103a50 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
  1062ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1062f5:	8d 50 08             	lea    0x8(%eax),%edx
  1062f8:	89 d1                	mov    %edx,%ecx
  1062fa:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
  106301:	c1 e9 10             	shr    $0x10,%ecx
  106304:	c1 ea 18             	shr    $0x18,%edx
  106307:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  10630d:	c6 80 a5 00 00 00 99 	movb   $0x99,0xa5(%eax)
  106314:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  10631a:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
  106321:	67 00 
  106323:	c6 80 a6 00 00 00 40 	movb   $0x40,0xa6(%eax)
  cpu->gdt[SEG_TSS].s = 0;
  10632a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  106330:	80 a0 a5 00 00 00 ef 	andb   $0xef,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
  106337:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10633d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  106343:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  106349:	8b 50 08             	mov    0x8(%eax),%edx
  10634c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  106352:	81 c2 00 10 00 00    	add    $0x1000,%edx
  106358:	89 50 0c             	mov    %edx,0xc(%eax)
}

static inline void
ltr(ushort sel)
{
  asm volatile("ltr %0" : : "r" (sel));
  10635b:	b8 30 00 00 00       	mov    $0x30,%eax
  106360:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
  106363:	8b 43 04             	mov    0x4(%ebx),%eax
  106366:	85 c0                	test   %eax,%eax
  106368:	74 0d                	je     106377 <switchuvm+0x97>
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  10636a:	0f 22 d8             	mov    %eax,%cr3
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
}
  10636d:	83 c4 14             	add    $0x14,%esp
  106370:	5b                   	pop    %ebx
  106371:	5d                   	pop    %ebp
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
  106372:	e9 19 d7 ff ff       	jmp    103a90 <popcli>
  cpu->gdt[SEG_TSS].s = 0;
  cpu->ts.ss0 = SEG_KDATA << 3;
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  106377:	c7 04 24 67 6d 10 00 	movl   $0x106d67,(%esp)
  10637e:	e8 9d a5 ff ff       	call   100920 <panic>
  106383:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  106389:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106390 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once at boot time on each CPU.
void
seginit(void)
{
  106390:	55                   	push   %ebp
  106391:	89 e5                	mov    %esp,%ebp
  106393:	83 ec 18             	sub    $0x18,%esp

  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  106396:	e8 a5 c1 ff ff       	call   102540 <cpunum>
  10639b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  1063a1:	05 20 bb 10 00       	add    $0x10bb20,%eax
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  1063a6:	8d 90 b4 00 00 00    	lea    0xb4(%eax),%edx
  1063ac:	66 89 90 8a 00 00 00 	mov    %dx,0x8a(%eax)
  1063b3:	89 d1                	mov    %edx,%ecx
  1063b5:	c1 ea 18             	shr    $0x18,%edx
  1063b8:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)
  1063be:	c1 e9 10             	shr    $0x10,%ecx

  lgdt(c->gdt, sizeof(c->gdt));
  1063c1:	8d 50 70             	lea    0x70(%eax),%edx
  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  1063c4:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
  1063ca:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
  1063d0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
  1063d4:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
  1063d8:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
  1063dc:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  1063e0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
  1063e7:	ff ff 
  1063e9:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
  1063f0:	00 00 
  1063f2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
  1063f9:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
  106400:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
  106407:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  10640e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
  106415:	ff ff 
  106417:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
  10641e:	00 00 
  106420:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
  106427:	c6 80 95 00 00 00 fa 	movb   $0xfa,0x95(%eax)
  10642e:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
  106435:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
  10643c:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
  106443:	ff ff 
  106445:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
  10644c:	00 00 
  10644e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
  106455:	c6 80 9d 00 00 00 f2 	movb   $0xf2,0x9d(%eax)
  10645c:	c6 80 9e 00 00 00 cf 	movb   $0xcf,0x9e(%eax)
  106463:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  10646a:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
  106471:	00 00 
  106473:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
  106479:	c6 80 8d 00 00 00 92 	movb   $0x92,0x8d(%eax)
  106480:	c6 80 8e 00 00 00 c0 	movb   $0xc0,0x8e(%eax)
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  106487:	66 c7 45 f2 37 00    	movw   $0x37,-0xe(%ebp)
  pd[1] = (uint)p;
  10648d:	66 89 55 f4          	mov    %dx,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
  106491:	c1 ea 10             	shr    $0x10,%edx
  106494:	66 89 55 f6          	mov    %dx,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
  106498:	8d 55 f2             	lea    -0xe(%ebp),%edx
  10649b:	0f 01 12             	lgdtl  (%edx)
}

static inline void
loadgs(ushort v)
{
  asm volatile("movw %0, %%gs" : : "r" (v));
  10649e:	ba 18 00 00 00       	mov    $0x18,%edx
  1064a3:	8e ea                	mov    %edx,%gs

  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);
  
  // Initialize cpu-local storage.
  cpu = c;
  1064a5:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
  1064ab:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  1064b2:	00 00 00 00 
}
  1064b6:	c9                   	leave  
  1064b7:	c3                   	ret    
