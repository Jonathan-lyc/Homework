
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
  100017:	00 a4 ea 10 00 20 00 	add    %ah,0x200010(%edx,%ebp,8)
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
  100045:	e8 96 28 00 00       	call   1028e0 <main>

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
  100086:	e8 a5 3c 00 00       	call   103d30 <acquire>

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
  1000c0:	e8 9b 30 00 00       	call   103160 <wakeup>

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
  1000d1:	e9 0a 3c 00 00       	jmp    103ce0 <release>
// Release the buffer b.
void
brelse(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("brelse");
  1000d6:	c7 04 24 a0 66 10 00 	movl   $0x1066a0,(%esp)
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
  100109:	e9 62 1e 00 00       	jmp    101f70 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("bwrite");
  10010e:	c7 04 24 a7 66 10 00 	movl   $0x1066a7,(%esp)
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
  100136:	e8 f5 3b 00 00       	call   103d30 <acquire>

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
  100178:	e8 13 31 00 00       	call   103290 <sleep>
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
  1001b5:	e8 26 3b 00 00       	call   103ce0 <release>
bread(uint dev, uint sector)
{
  struct buf *b;

  b = bget(dev, sector);
  if(!(b->flags & B_VALID))
  1001ba:	f6 03 02             	testb  $0x2,(%ebx)
  1001bd:	75 08                	jne    1001c7 <bread+0xa7>
    iderw(b);
  1001bf:	89 1c 24             	mov    %ebx,(%esp)
  1001c2:	e8 a9 1d 00 00       	call   101f70 <iderw>
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
  1001dd:	e8 fe 3a 00 00       	call   103ce0 <release>
  1001e2:	eb d6                	jmp    1001ba <bread+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
  1001e4:	c7 04 24 ae 66 10 00 	movl   $0x1066ae,(%esp)
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
  1001f6:	c7 44 24 04 bf 66 10 	movl   $0x1066bf,0x4(%esp)
  1001fd:	00 
  1001fe:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  100205:	e8 96 39 00 00       	call   103ba0 <initlock>
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
  100266:	c7 44 24 04 c6 66 10 	movl   $0x1066c6,0x4(%esp)
  10026d:	00 
  10026e:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100275:	e8 26 39 00 00       	call   103ba0 <initlock>
  initlock(&input.lock, "input");
  10027a:	c7 44 24 04 ce 66 10 	movl   $0x1066ce,0x4(%esp)
  100281:	00 
  100282:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  100289:	e8 12 39 00 00       	call   103ba0 <initlock>

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
  1002b3:	e8 08 29 00 00       	call   102bc0 <picenable>
  ioapicenable(IRQ_KBD, 0);
  1002b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1002bf:	00 
  1002c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1002c7:	e8 a4 1e 00 00       	call   102170 <ioapicenable>
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
  1002f5:	e8 a6 4f 00 00       	call   1052a0 <uartputc>
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
  100399:	e8 02 4f 00 00       	call   1052a0 <uartputc>
  10039e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1003a5:	e8 f6 4e 00 00       	call   1052a0 <uartputc>
  1003aa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1003b1:	e8 ea 4e 00 00       	call   1052a0 <uartputc>
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
  1003dc:	e8 6f 3a 00 00       	call   103e50 <memmove>
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  1003e1:	b8 80 07 00 00       	mov    $0x780,%eax
  1003e6:	29 d8                	sub    %ebx,%eax
  1003e8:	01 c0                	add    %eax,%eax
  1003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  1003ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1003f5:	00 
  1003f6:	89 34 24             	mov    %esi,(%esp)
  1003f9:	e8 d2 39 00 00       	call   103dd0 <memset>
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
  100455:	e8 46 13 00 00       	call   1017a0 <iunlock>
  acquire(&cons.lock);
  10045a:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100461:	e8 ca 38 00 00       	call   103d30 <acquire>
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
  100487:	e8 54 38 00 00       	call   103ce0 <release>
  ilock(ip);
  10048c:	8b 45 08             	mov    0x8(%ebp),%eax
  10048f:	89 04 24             	mov    %eax,(%esp)
  100492:	e8 49 17 00 00       	call   101be0 <ilock>

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
  1004d4:	0f b6 92 ee 66 10 00 	movzbl 0x1066ee(%edx),%edx
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
  100541:	0f 85 31 01 00 00    	jne    100678 <cprintf+0x148>
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
  100577:	89 55 e0             	mov    %edx,-0x20(%ebp)
  10057a:	e8 51 fd ff ff       	call   1002d0 <consputc>
      consputc(c);
  10057f:	8b 55 e0             	mov    -0x20(%ebp),%edx
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
  1005f3:	e8 e8 36 00 00       	call   103ce0 <release>
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
  10063a:	b8 d4 66 10 00       	mov    $0x1066d4,%eax
  10063f:	83 c6 04             	add    $0x4,%esi
  100642:	85 d2                	test   %edx,%edx
  100644:	0f 44 d0             	cmove  %eax,%edx
        s = "(null)";
      for(; *s; s++)
  100647:	0f b6 02             	movzbl (%edx),%eax
  10064a:	84 c0                	test   %al,%al
  10064c:	0f 84 3e ff ff ff    	je     100590 <cprintf+0x60>
  100652:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  100655:	89 d3                	mov    %edx,%ebx
  100657:	90                   	nop
        consputc(*s);
  100658:	0f be c0             	movsbl %al,%eax
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
  10065b:	83 c3 01             	add    $0x1,%ebx
        consputc(*s);
  10065e:	e8 6d fc ff ff       	call   1002d0 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
  100663:	0f b6 03             	movzbl (%ebx),%eax
  100666:	84 c0                	test   %al,%al
  100668:	75 ee                	jne    100658 <cprintf+0x128>
  10066a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  10066d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  100670:	e9 1b ff ff ff       	jmp    100590 <cprintf+0x60>
  100675:	8d 76 00             	lea    0x0(%esi),%esi
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);
  100678:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  10067f:	e8 ac 36 00 00       	call   103d30 <acquire>
  100684:	e9 be fe ff ff       	jmp    100547 <cprintf+0x17>
  100689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

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
  1006a5:	e8 f6 10 00 00       	call   1017a0 <iunlock>
  target = n;
  1006aa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&input.lock);
  1006ad:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  1006b4:	e8 77 36 00 00       	call   103d30 <acquire>
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
  1006e4:	e8 a7 2b 00 00       	call   103290 <sleep>

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
  100737:	e8 a4 35 00 00       	call   103ce0 <release>
        ilock(ip);
  10073c:	89 3c 24             	mov    %edi,(%esp)
  10073f:	e8 9c 14 00 00       	call   101be0 <ilock>
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
  10076a:	e8 71 35 00 00       	call   103ce0 <release>
  ilock(ip);
  10076f:	89 3c 24             	mov    %edi,(%esp)
  100772:	e8 69 14 00 00       	call   101be0 <ilock>
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
  1007a8:	e8 83 35 00 00       	call   103d30 <acquire>
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
  1007fd:	88 5c 3a 04          	mov    %bl,0x4(%edx,%edi,1)
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
  100841:	e8 1a 29 00 00       	call   103160 <wakeup>
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
  100866:	e9 75 34 00 00       	jmp    103ce0 <release>
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
  1008e0:	e8 1b 27 00 00       	call   103000 <procdump>
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
  1008f5:	c6 44 3a 04 0a       	movb   $0xa,0x4(%edx,%edi,1)
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
  100941:	c7 04 24 db 66 10 00 	movl   $0x1066db,(%esp)
  100948:	89 44 24 04          	mov    %eax,0x4(%esp)
  10094c:	e8 df fb ff ff       	call   100530 <cprintf>
  cprintf(s);
  100951:	8b 45 08             	mov    0x8(%ebp),%eax
  100954:	89 04 24             	mov    %eax,(%esp)
  100957:	e8 d4 fb ff ff       	call   100530 <cprintf>
  cprintf("\n");
  10095c:	c7 04 24 f6 6a 10 00 	movl   $0x106af6,(%esp)
  100963:	e8 c8 fb ff ff       	call   100530 <cprintf>
  getcallerpcs(&s, pcs);
  100968:	8d 45 08             	lea    0x8(%ebp),%eax
  10096b:	89 74 24 04          	mov    %esi,0x4(%esp)
  10096f:	89 04 24             	mov    %eax,(%esp)
  100972:	e8 49 32 00 00       	call   103bc0 <getcallerpcs>
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
  10097e:	c7 04 24 ea 66 10 00 	movl   $0x1066ea,(%esp)
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
  1009b2:	e8 c9 14 00 00       	call   101e80 <namei>
  1009b7:	85 c0                	test   %eax,%eax
  1009b9:	89 c7                	mov    %eax,%edi
  1009bb:	0f 84 25 01 00 00    	je     100ae6 <exec+0x146>
    return -1;
  ilock(ip);
  1009c1:	89 04 24             	mov    %eax,(%esp)
  1009c4:	e8 17 12 00 00       	call   101be0 <ilock>
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
  1009e3:	e8 a8 09 00 00       	call   101390 <readi>
  1009e8:	83 f8 33             	cmp    $0x33,%eax
  1009eb:	0f 86 f7 01 00 00    	jbe    100be8 <exec+0x248>
    goto bad;
  if(elf.magic != ELF_MAGIC)
  1009f1:	81 7d 94 7f 45 4c 46 	cmpl   $0x464c457f,-0x6c(%ebp)
  1009f8:	0f 85 ea 01 00 00    	jne    100be8 <exec+0x248>
  1009fe:	66 90                	xchg   %ax,%ax
    goto bad;

  if((pgdir = setupkvm()) == 0)
  100a00:	e8 1b 56 00 00       	call   106020 <setupkvm>
  100a05:	85 c0                	test   %eax,%eax
  100a07:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
  100a0d:	0f 84 d5 01 00 00    	je     100be8 <exec+0x248>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100a13:	66 83 7d c0 00       	cmpw   $0x0,-0x40(%ebp)
  100a18:	8b 75 b0             	mov    -0x50(%ebp),%esi
  100a1b:	0f 84 eb 02 00 00    	je     100d0c <exec+0x36c>
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
  100a58:	e8 33 09 00 00       	call   101390 <readi>
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
  100a8c:	e8 8f 58 00 00       	call   106320 <allocuvm>
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
  100abd:	e8 2e 59 00 00       	call   1063f0 <loaduvm>
  100ac2:	85 c0                	test   %eax,%eax
  100ac4:	0f 89 66 ff ff ff    	jns    100a30 <exec+0x90>
  100aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  100ad0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100ad6:	89 04 24             	mov    %eax,(%esp)
  100ad9:	e8 02 57 00 00       	call   1061e0 <freevm>
  if(ip)
  100ade:	85 ff                	test   %edi,%edi
  100ae0:	0f 85 02 01 00 00    	jne    100be8 <exec+0x248>
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
  100b13:	e8 d8 0f 00 00       	call   101af0 <iunlockput>

  // Allocate a one-page stack at the next page boundary
  
  sz = PGROUNDUP(sz);
  
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
  100b18:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
  100b1e:	89 74 24 08          	mov    %esi,0x8(%esp)
  100b22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100b26:	89 0c 24             	mov    %ecx,(%esp)
  100b29:	e8 f2 57 00 00       	call   106320 <allocuvm>
  100b2e:	85 c0                	test   %eax,%eax
  100b30:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
  100b36:	0f 84 a3 00 00 00    	je     100bdf <exec+0x23f>
    goto bad;
/*  cprintf("sz = %x\n", sz);*/
  proc->pstack = (uint *)sz;
  100b3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100b42:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
  100b48:	89 50 7c             	mov    %edx,0x7c(%eax)
  proc->pstack2 = (uint *)sz + PGSIZE;
  100b4b:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
  100b51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100b57:	81 c2 00 40 00 00    	add    $0x4000,%edx
  100b5d:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100b66:	8b 01                	mov    (%ecx),%eax
  100b68:	85 c0                	test   %eax,%eax
  100b6a:	0f 84 7d 01 00 00    	je     100ced <exec+0x34d>
  100b70:	8b 7d 0c             	mov    0xc(%ebp),%edi
  100b73:	31 f6                	xor    %esi,%esi
  100b75:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100b7b:	eb 25                	jmp    100ba2 <exec+0x202>
  100b7d:	8d 76 00             	lea    0x0(%esi),%esi
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  100b80:	89 9c b5 10 ff ff ff 	mov    %ebx,-0xf0(%ebp,%esi,4)
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
  100b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
/*  cprintf("sz = %x\n", sz);*/
  proc->pstack = (uint *)sz;
  proc->pstack2 = (uint *)sz + PGSIZE;
  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100b8a:	83 c6 01             	add    $0x1,%esi
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  100b8d:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
/*  cprintf("sz = %x\n", sz);*/
  proc->pstack = (uint *)sz;
  proc->pstack2 = (uint *)sz + PGSIZE;
  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100b93:	8b 04 b1             	mov    (%ecx,%esi,4),%eax
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
  100b96:	8d 3c b1             	lea    (%ecx,%esi,4),%edi
/*  cprintf("sz = %x\n", sz);*/
  proc->pstack = (uint *)sz;
  proc->pstack2 = (uint *)sz + PGSIZE;
  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100b99:	85 c0                	test   %eax,%eax
  100b9b:	74 62                	je     100bff <exec+0x25f>
    if(argc >= MAXARG)
  100b9d:	83 fe 20             	cmp    $0x20,%esi
  100ba0:	74 3d                	je     100bdf <exec+0x23f>
      goto bad;
    sp -= strlen(argv[argc]) + 1;
  100ba2:	89 04 24             	mov    %eax,(%esp)
  100ba5:	e8 06 34 00 00       	call   103fb0 <strlen>
  100baa:	f7 d0                	not    %eax
  100bac:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
  100baf:	8b 07                	mov    (%edi),%eax
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
  100bb1:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
  100bb4:	89 04 24             	mov    %eax,(%esp)
  100bb7:	e8 f4 33 00 00       	call   103fb0 <strlen>
  100bbc:	83 c0 01             	add    $0x1,%eax
  100bbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100bc3:	8b 07                	mov    (%edi),%eax
  100bc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100bc9:	89 44 24 08          	mov    %eax,0x8(%esp)
  100bcd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100bd3:	89 04 24             	mov    %eax,(%esp)
  100bd6:	e8 25 53 00 00       	call   105f00 <copyout>
  100bdb:	85 c0                	test   %eax,%eax
  100bdd:	79 a1                	jns    100b80 <exec+0x1e0>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip)
    iunlockput(ip);
  100bdf:	31 ff                	xor    %edi,%edi
  100be1:	e9 ea fe ff ff       	jmp    100ad0 <exec+0x130>
  100be6:	66 90                	xchg   %ax,%ax
  100be8:	89 3c 24             	mov    %edi,(%esp)
  100beb:	90                   	nop
  100bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  100bf0:	e8 fb 0e 00 00       	call   101af0 <iunlockput>
  100bf5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100bfa:	e9 ec fe ff ff       	jmp    100aeb <exec+0x14b>
/*  cprintf("sz = %x\n", sz);*/
  proc->pstack = (uint *)sz;
  proc->pstack2 = (uint *)sz + PGSIZE;
  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100bff:	8d 4e 03             	lea    0x3(%esi),%ecx
  100c02:	8d 3c b5 04 00 00 00 	lea    0x4(,%esi,4),%edi
  100c09:	8d 04 b5 10 00 00 00 	lea    0x10(,%esi,4),%eax
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
  100c10:	c7 84 8d 04 ff ff ff 	movl   $0x0,-0xfc(%ebp,%ecx,4)
  100c17:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c1b:	89 d9                	mov    %ebx,%ecx

  sp -= (3+argc+1) * 4;
  100c1d:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
  100c1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100c23:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c29:	29 f9                	sub    %edi,%ecx
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  100c2b:	c7 85 04 ff ff ff ff 	movl   $0xffffffff,-0xfc(%ebp)
  100c32:	ff ff ff 
  ustack[1] = argc;
  100c35:	89 b5 08 ff ff ff    	mov    %esi,-0xf8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c3b:	89 8d 0c ff ff ff    	mov    %ecx,-0xf4(%ebp)

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
  100c41:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100c49:	89 04 24             	mov    %eax,(%esp)
  100c4c:	e8 af 52 00 00       	call   105f00 <copyout>
  100c51:	85 c0                	test   %eax,%eax
  100c53:	78 8a                	js     100bdf <exec+0x23f>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
  100c55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  100c58:	0f b6 11             	movzbl (%ecx),%edx
  100c5b:	84 d2                	test   %dl,%dl
  100c5d:	74 19                	je     100c78 <exec+0x2d8>
  100c5f:	89 c8                	mov    %ecx,%eax
  100c61:	83 c0 01             	add    $0x1,%eax
  100c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == '/')
  100c68:	80 fa 2f             	cmp    $0x2f,%dl
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
  100c6b:	0f b6 10             	movzbl (%eax),%edx
    if(*s == '/')
  100c6e:	0f 44 c8             	cmove  %eax,%ecx
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
  100c71:	83 c0 01             	add    $0x1,%eax
  100c74:	84 d2                	test   %dl,%dl
  100c76:	75 f0                	jne    100c68 <exec+0x2c8>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
  100c78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100c7e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c82:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  100c89:	00 
  100c8a:	83 c0 6c             	add    $0x6c,%eax
  100c8d:	89 04 24             	mov    %eax,(%esp)
  100c90:	e8 db 32 00 00       	call   103f70 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  100c95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  proc->pgdir = pgdir;
  100c9b:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  100ca1:	8b 70 04             	mov    0x4(%eax),%esi
  proc->pgdir = pgdir;
  100ca4:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
  100ca7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100cad:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  100cb3:	89 08                	mov    %ecx,(%eax)
  proc->tf->eip = elf.entry;  // main
  100cb5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100cbb:	8b 55 ac             	mov    -0x54(%ebp),%edx
  100cbe:	8b 40 18             	mov    0x18(%eax),%eax
  100cc1:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
  100cc4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100cca:	8b 40 18             	mov    0x18(%eax),%eax
  100ccd:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(proc);
  100cd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100cd6:	89 04 24             	mov    %eax,(%esp)
  100cd9:	e8 d2 57 00 00       	call   1064b0 <switchuvm>
  freevm(oldpgdir);
  100cde:	89 34 24             	mov    %esi,(%esp)
  100ce1:	e8 fa 54 00 00       	call   1061e0 <freevm>
  100ce6:	31 c0                	xor    %eax,%eax

  return 0;
  100ce8:	e9 fe fd ff ff       	jmp    100aeb <exec+0x14b>
/*  cprintf("sz = %x\n", sz);*/
  proc->pstack = (uint *)sz;
  proc->pstack2 = (uint *)sz + PGSIZE;
  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100ced:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100cf3:	b0 10                	mov    $0x10,%al
  100cf5:	bf 04 00 00 00       	mov    $0x4,%edi
  100cfa:	b9 03 00 00 00       	mov    $0x3,%ecx
  100cff:	31 f6                	xor    %esi,%esi
  100d01:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
  100d07:	e9 04 ff ff ff       	jmp    100c10 <exec+0x270>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100d0c:	be 00 10 00 00       	mov    $0x1000,%esi
  100d11:	31 db                	xor    %ebx,%ebx
  100d13:	e9 f8 fd ff ff       	jmp    100b10 <exec+0x170>
  100d18:	90                   	nop
  100d19:	90                   	nop
  100d1a:	90                   	nop
  100d1b:	90                   	nop
  100d1c:	90                   	nop
  100d1d:	90                   	nop
  100d1e:	90                   	nop
  100d1f:	90                   	nop

00100d20 <filewrite>:
}

// Write to file f.  Addr is kernel address.
int
filewrite(struct file *f, char *addr, int n)
{
  100d20:	55                   	push   %ebp
  100d21:	89 e5                	mov    %esp,%ebp
  100d23:	83 ec 38             	sub    $0x38,%esp
  100d26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100d29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100d2c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100d2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  100d32:	89 7d fc             	mov    %edi,-0x4(%ebp)
  100d35:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->writable == 0)
  100d38:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
  100d3c:	74 5a                	je     100d98 <filewrite+0x78>
    return -1;
  if(f->type == FD_PIPE)
  100d3e:	8b 03                	mov    (%ebx),%eax
  100d40:	83 f8 01             	cmp    $0x1,%eax
  100d43:	74 5b                	je     100da0 <filewrite+0x80>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
  100d45:	83 f8 02             	cmp    $0x2,%eax
  100d48:	75 6d                	jne    100db7 <filewrite+0x97>
    ilock(f->ip);
  100d4a:	8b 43 10             	mov    0x10(%ebx),%eax
  100d4d:	89 04 24             	mov    %eax,(%esp)
  100d50:	e8 8b 0e 00 00       	call   101be0 <ilock>
    if((r = writei(f->ip, addr, f->off, n)) > 0)
  100d55:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  100d59:	8b 43 14             	mov    0x14(%ebx),%eax
  100d5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  100d60:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d64:	8b 43 10             	mov    0x10(%ebx),%eax
  100d67:	89 04 24             	mov    %eax,(%esp)
  100d6a:	e8 c1 07 00 00       	call   101530 <writei>
  100d6f:	85 c0                	test   %eax,%eax
  100d71:	7e 03                	jle    100d76 <filewrite+0x56>
      f->off += r;
  100d73:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
  100d76:	8b 53 10             	mov    0x10(%ebx),%edx
  100d79:	89 14 24             	mov    %edx,(%esp)
  100d7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100d7f:	e8 1c 0a 00 00       	call   1017a0 <iunlock>
    return r;
  100d84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("filewrite");
}
  100d87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100d8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100d8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100d90:	89 ec                	mov    %ebp,%esp
  100d92:	5d                   	pop    %ebp
  100d93:	c3                   	ret    
  100d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((r = writei(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
  100d98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100d9d:	eb e8                	jmp    100d87 <filewrite+0x67>
  100d9f:	90                   	nop
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100da0:	8b 43 0c             	mov    0xc(%ebx),%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
}
  100da3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100da6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100da9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100dac:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
}
  100daf:	89 ec                	mov    %ebp,%esp
  100db1:	5d                   	pop    %ebp
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100db2:	e9 d9 1f 00 00       	jmp    102d90 <pipewrite>
    if((r = writei(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
  100db7:	c7 04 24 ff 66 10 00 	movl   $0x1066ff,(%esp)
  100dbe:	e8 5d fb ff ff       	call   100920 <panic>
  100dc3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100dc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100dd0 <fileread>:
}

// Read from file f.  Addr is kernel address.
int
fileread(struct file *f, char *addr, int n)
{
  100dd0:	55                   	push   %ebp
  100dd1:	89 e5                	mov    %esp,%ebp
  100dd3:	83 ec 38             	sub    $0x38,%esp
  100dd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100dd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100ddc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100ddf:	8b 75 0c             	mov    0xc(%ebp),%esi
  100de2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  100de5:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
  100de8:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
  100dec:	74 5a                	je     100e48 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
  100dee:	8b 03                	mov    (%ebx),%eax
  100df0:	83 f8 01             	cmp    $0x1,%eax
  100df3:	74 5b                	je     100e50 <fileread+0x80>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
  100df5:	83 f8 02             	cmp    $0x2,%eax
  100df8:	75 6d                	jne    100e67 <fileread+0x97>
    ilock(f->ip);
  100dfa:	8b 43 10             	mov    0x10(%ebx),%eax
  100dfd:	89 04 24             	mov    %eax,(%esp)
  100e00:	e8 db 0d 00 00       	call   101be0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
  100e05:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  100e09:	8b 43 14             	mov    0x14(%ebx),%eax
  100e0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  100e10:	89 44 24 08          	mov    %eax,0x8(%esp)
  100e14:	8b 43 10             	mov    0x10(%ebx),%eax
  100e17:	89 04 24             	mov    %eax,(%esp)
  100e1a:	e8 71 05 00 00       	call   101390 <readi>
  100e1f:	85 c0                	test   %eax,%eax
  100e21:	7e 03                	jle    100e26 <fileread+0x56>
      f->off += r;
  100e23:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
  100e26:	8b 53 10             	mov    0x10(%ebx),%edx
  100e29:	89 14 24             	mov    %edx,(%esp)
  100e2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100e2f:	e8 6c 09 00 00       	call   1017a0 <iunlock>
    return r;
  100e34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("fileread");
}
  100e37:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100e3a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100e3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100e40:	89 ec                	mov    %ebp,%esp
  100e42:	5d                   	pop    %ebp
  100e43:	c3                   	ret    
  100e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
  100e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100e4d:	eb e8                	jmp    100e37 <fileread+0x67>
  100e4f:	90                   	nop
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100e50:	8b 43 0c             	mov    0xc(%ebx),%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
  100e53:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100e56:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100e59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100e5c:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
  100e5f:	89 ec                	mov    %ebp,%esp
  100e61:	5d                   	pop    %ebp
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100e62:	e9 29 1e 00 00       	jmp    102c90 <piperead>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
  100e67:	c7 04 24 09 67 10 00 	movl   $0x106709,(%esp)
  100e6e:	e8 ad fa ff ff       	call   100920 <panic>
  100e73:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100e80 <filestat>:
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  100e80:	55                   	push   %ebp
  if(f->type == FD_INODE){
  100e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  100e86:	89 e5                	mov    %esp,%ebp
  100e88:	53                   	push   %ebx
  100e89:	83 ec 14             	sub    $0x14,%esp
  100e8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
  100e8f:	83 3b 02             	cmpl   $0x2,(%ebx)
  100e92:	74 0c                	je     100ea0 <filestat+0x20>
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
  }
  return -1;
}
  100e94:	83 c4 14             	add    $0x14,%esp
  100e97:	5b                   	pop    %ebx
  100e98:	5d                   	pop    %ebp
  100e99:	c3                   	ret    
  100e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
  100ea0:	8b 43 10             	mov    0x10(%ebx),%eax
  100ea3:	89 04 24             	mov    %eax,(%esp)
  100ea6:	e8 35 0d 00 00       	call   101be0 <ilock>
    stati(f->ip, st);
  100eab:	8b 45 0c             	mov    0xc(%ebp),%eax
  100eae:	89 44 24 04          	mov    %eax,0x4(%esp)
  100eb2:	8b 43 10             	mov    0x10(%ebx),%eax
  100eb5:	89 04 24             	mov    %eax,(%esp)
  100eb8:	e8 e3 01 00 00       	call   1010a0 <stati>
    iunlock(f->ip);
  100ebd:	8b 43 10             	mov    0x10(%ebx),%eax
  100ec0:	89 04 24             	mov    %eax,(%esp)
  100ec3:	e8 d8 08 00 00       	call   1017a0 <iunlock>
    return 0;
  }
  return -1;
}
  100ec8:	83 c4 14             	add    $0x14,%esp
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
  100ecb:	31 c0                	xor    %eax,%eax
    return 0;
  }
  return -1;
}
  100ecd:	5b                   	pop    %ebx
  100ece:	5d                   	pop    %ebp
  100ecf:	c3                   	ret    

00100ed0 <filedup>:
}

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
  100ed0:	55                   	push   %ebp
  100ed1:	89 e5                	mov    %esp,%ebp
  100ed3:	53                   	push   %ebx
  100ed4:	83 ec 14             	sub    $0x14,%esp
  100ed7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
  100eda:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100ee1:	e8 4a 2e 00 00       	call   103d30 <acquire>
  if(f->ref < 1)
  100ee6:	8b 43 04             	mov    0x4(%ebx),%eax
  100ee9:	85 c0                	test   %eax,%eax
  100eeb:	7e 1a                	jle    100f07 <filedup+0x37>
    panic("filedup");
  f->ref++;
  100eed:	83 c0 01             	add    $0x1,%eax
  100ef0:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
  100ef3:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100efa:	e8 e1 2d 00 00       	call   103ce0 <release>
  return f;
}
  100eff:	89 d8                	mov    %ebx,%eax
  100f01:	83 c4 14             	add    $0x14,%esp
  100f04:	5b                   	pop    %ebx
  100f05:	5d                   	pop    %ebp
  100f06:	c3                   	ret    
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
  100f07:	c7 04 24 12 67 10 00 	movl   $0x106712,(%esp)
  100f0e:	e8 0d fa ff ff       	call   100920 <panic>
  100f13:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100f19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100f20 <filealloc>:
}

// Allocate a file structure.
struct file*
filealloc(void)
{
  100f20:	55                   	push   %ebp
  100f21:	89 e5                	mov    %esp,%ebp
  100f23:	53                   	push   %ebx
  initlock(&ftable.lock, "ftable");
}

// Allocate a file structure.
struct file*
filealloc(void)
  100f24:	bb 2c a1 10 00       	mov    $0x10a12c,%ebx
{
  100f29:	83 ec 14             	sub    $0x14,%esp
  struct file *f;

  acquire(&ftable.lock);
  100f2c:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f33:	e8 f8 2d 00 00       	call   103d30 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
  100f38:	8b 15 18 a1 10 00    	mov    0x10a118,%edx
  100f3e:	85 d2                	test   %edx,%edx
  100f40:	75 11                	jne    100f53 <filealloc+0x33>
  100f42:	eb 4a                	jmp    100f8e <filealloc+0x6e>
  100f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
  100f48:	83 c3 18             	add    $0x18,%ebx
  100f4b:	81 fb 74 aa 10 00    	cmp    $0x10aa74,%ebx
  100f51:	74 25                	je     100f78 <filealloc+0x58>
    if(f->ref == 0){
  100f53:	8b 43 04             	mov    0x4(%ebx),%eax
  100f56:	85 c0                	test   %eax,%eax
  100f58:	75 ee                	jne    100f48 <filealloc+0x28>
      f->ref = 1;
  100f5a:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
  100f61:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f68:	e8 73 2d 00 00       	call   103ce0 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
  100f6d:	89 d8                	mov    %ebx,%eax
  100f6f:	83 c4 14             	add    $0x14,%esp
  100f72:	5b                   	pop    %ebx
  100f73:	5d                   	pop    %ebp
  100f74:	c3                   	ret    
  100f75:	8d 76 00             	lea    0x0(%esi),%esi
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
  100f78:	31 db                	xor    %ebx,%ebx
  100f7a:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f81:	e8 5a 2d 00 00       	call   103ce0 <release>
  return 0;
}
  100f86:	89 d8                	mov    %ebx,%eax
  100f88:	83 c4 14             	add    $0x14,%esp
  100f8b:	5b                   	pop    %ebx
  100f8c:	5d                   	pop    %ebp
  100f8d:	c3                   	ret    
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
  100f8e:	bb 14 a1 10 00       	mov    $0x10a114,%ebx
  100f93:	eb c5                	jmp    100f5a <filealloc+0x3a>
  100f95:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  100f99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100fa0 <fileclose>:
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
  100fa0:	55                   	push   %ebp
  100fa1:	89 e5                	mov    %esp,%ebp
  100fa3:	83 ec 38             	sub    $0x38,%esp
  100fa6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100fa9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100fac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100faf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct file ff;

  acquire(&ftable.lock);
  100fb2:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100fb9:	e8 72 2d 00 00       	call   103d30 <acquire>
  if(f->ref < 1)
  100fbe:	8b 43 04             	mov    0x4(%ebx),%eax
  100fc1:	85 c0                	test   %eax,%eax
  100fc3:	0f 8e 9c 00 00 00    	jle    101065 <fileclose+0xc5>
    panic("fileclose");
  if(--f->ref > 0){
  100fc9:	83 e8 01             	sub    $0x1,%eax
  100fcc:	85 c0                	test   %eax,%eax
  100fce:	89 43 04             	mov    %eax,0x4(%ebx)
  100fd1:	74 1d                	je     100ff0 <fileclose+0x50>
    release(&ftable.lock);
  100fd3:	c7 45 08 e0 a0 10 00 	movl   $0x10a0e0,0x8(%ebp)
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
}
  100fda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100fdd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100fe0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100fe3:	89 ec                	mov    %ebp,%esp
  100fe5:	5d                   	pop    %ebp

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
  100fe6:	e9 f5 2c 00 00       	jmp    103ce0 <release>
  100feb:	90                   	nop
  100fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  }
  ff = *f;
  100ff0:	8b 43 0c             	mov    0xc(%ebx),%eax
  100ff3:	8b 7b 10             	mov    0x10(%ebx),%edi
  100ff6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  100ff9:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  100ffd:	88 45 e7             	mov    %al,-0x19(%ebp)
  101000:	8b 33                	mov    (%ebx),%esi
  f->ref = 0;
  101002:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
  101009:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
  10100f:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  101016:	e8 c5 2c 00 00       	call   103ce0 <release>
  
  if(ff.type == FD_PIPE)
  10101b:	83 fe 01             	cmp    $0x1,%esi
  10101e:	74 30                	je     101050 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
  101020:	83 fe 02             	cmp    $0x2,%esi
  101023:	74 13                	je     101038 <fileclose+0x98>
    iput(ff.ip);
}
  101025:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  101028:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10102b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  10102e:	89 ec                	mov    %ebp,%esp
  101030:	5d                   	pop    %ebp
  101031:	c3                   	ret    
  101032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
  101038:	89 7d 08             	mov    %edi,0x8(%ebp)
}
  10103b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10103e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101041:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101044:	89 ec                	mov    %ebp,%esp
  101046:	5d                   	pop    %ebp
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
  101047:	e9 64 08 00 00       	jmp    1018b0 <iput>
  10104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  101050:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101054:	89 44 24 04          	mov    %eax,0x4(%esp)
  101058:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10105b:	89 04 24             	mov    %eax,(%esp)
  10105e:	e8 1d 1e 00 00       	call   102e80 <pipeclose>
  101063:	eb c0                	jmp    101025 <fileclose+0x85>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  101065:	c7 04 24 1a 67 10 00 	movl   $0x10671a,(%esp)
  10106c:	e8 af f8 ff ff       	call   100920 <panic>
  101071:	eb 0d                	jmp    101080 <fileinit>
  101073:	90                   	nop
  101074:	90                   	nop
  101075:	90                   	nop
  101076:	90                   	nop
  101077:	90                   	nop
  101078:	90                   	nop
  101079:	90                   	nop
  10107a:	90                   	nop
  10107b:	90                   	nop
  10107c:	90                   	nop
  10107d:	90                   	nop
  10107e:	90                   	nop
  10107f:	90                   	nop

00101080 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
  101080:	55                   	push   %ebp
  101081:	89 e5                	mov    %esp,%ebp
  101083:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
  101086:	c7 44 24 04 24 67 10 	movl   $0x106724,0x4(%esp)
  10108d:	00 
  10108e:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  101095:	e8 06 2b 00 00       	call   103ba0 <initlock>
}
  10109a:	c9                   	leave  
  10109b:	c3                   	ret    
  10109c:	90                   	nop
  10109d:	90                   	nop
  10109e:	90                   	nop
  10109f:	90                   	nop

001010a0 <stati>:
}

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
  1010a0:	55                   	push   %ebp
  1010a1:	89 e5                	mov    %esp,%ebp
  1010a3:	8b 55 08             	mov    0x8(%ebp),%edx
  1010a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
  1010a9:	8b 0a                	mov    (%edx),%ecx
  1010ab:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
  1010ae:	8b 4a 04             	mov    0x4(%edx),%ecx
  1010b1:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
  1010b4:	0f b7 4a 10          	movzwl 0x10(%edx),%ecx
  1010b8:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
  1010bb:	0f b7 4a 16          	movzwl 0x16(%edx),%ecx
  1010bf:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
  1010c3:	8b 52 18             	mov    0x18(%edx),%edx
  1010c6:	89 50 10             	mov    %edx,0x10(%eax)
}
  1010c9:	5d                   	pop    %ebp
  1010ca:	c3                   	ret    
  1010cb:	90                   	nop
  1010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

001010d0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
  1010d0:	55                   	push   %ebp
  1010d1:	89 e5                	mov    %esp,%ebp
  1010d3:	53                   	push   %ebx
  1010d4:	83 ec 14             	sub    $0x14,%esp
  1010d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
  1010da:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1010e1:	e8 4a 2c 00 00       	call   103d30 <acquire>
  ip->ref++;
  1010e6:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
  1010ea:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1010f1:	e8 ea 2b 00 00       	call   103ce0 <release>
  return ip;
}
  1010f6:	89 d8                	mov    %ebx,%eax
  1010f8:	83 c4 14             	add    $0x14,%esp
  1010fb:	5b                   	pop    %ebx
  1010fc:	5d                   	pop    %ebp
  1010fd:	c3                   	ret    
  1010fe:	66 90                	xchg   %ax,%ax

00101100 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
{
  101100:	55                   	push   %ebp
  101101:	89 e5                	mov    %esp,%ebp
  101103:	57                   	push   %edi
  101104:	89 d7                	mov    %edx,%edi
  101106:	56                   	push   %esi
}

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
  101107:	31 f6                	xor    %esi,%esi
{
  101109:	53                   	push   %ebx
  10110a:	89 c3                	mov    %eax,%ebx
  10110c:	83 ec 2c             	sub    $0x2c,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
  10110f:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101116:	e8 15 2c 00 00       	call   103d30 <acquire>
}

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
  10111b:	b8 14 ab 10 00       	mov    $0x10ab14,%eax
  101120:	eb 14                	jmp    101136 <iget+0x36>
  101122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
  101128:	85 f6                	test   %esi,%esi
  10112a:	74 3c                	je     101168 <iget+0x68>

  acquire(&icache.lock);

  // Try for cached inode.
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
  10112c:	83 c0 50             	add    $0x50,%eax
  10112f:	3d b4 ba 10 00       	cmp    $0x10bab4,%eax
  101134:	74 42                	je     101178 <iget+0x78>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
  101136:	8b 48 08             	mov    0x8(%eax),%ecx
  101139:	85 c9                	test   %ecx,%ecx
  10113b:	7e eb                	jle    101128 <iget+0x28>
  10113d:	39 18                	cmp    %ebx,(%eax)
  10113f:	75 e7                	jne    101128 <iget+0x28>
  101141:	39 78 04             	cmp    %edi,0x4(%eax)
  101144:	75 e2                	jne    101128 <iget+0x28>
      ip->ref++;
  101146:	83 c1 01             	add    $0x1,%ecx
  101149:	89 48 08             	mov    %ecx,0x8(%eax)
      release(&icache.lock);
  10114c:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101153:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101156:	e8 85 2b 00 00       	call   103ce0 <release>
      return ip;
  10115b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);

  return ip;
}
  10115e:	83 c4 2c             	add    $0x2c,%esp
  101161:	5b                   	pop    %ebx
  101162:	5e                   	pop    %esi
  101163:	5f                   	pop    %edi
  101164:	5d                   	pop    %ebp
  101165:	c3                   	ret    
  101166:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
  101168:	85 c9                	test   %ecx,%ecx
  10116a:	0f 44 f0             	cmove  %eax,%esi

  acquire(&icache.lock);

  // Try for cached inode.
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
  10116d:	83 c0 50             	add    $0x50,%eax
  101170:	3d b4 ba 10 00       	cmp    $0x10bab4,%eax
  101175:	75 bf                	jne    101136 <iget+0x36>
  101177:	90                   	nop
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Allocate fresh inode.
  if(empty == 0)
  101178:	85 f6                	test   %esi,%esi
  10117a:	74 29                	je     1011a5 <iget+0xa5>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
  10117c:	89 1e                	mov    %ebx,(%esi)
  ip->inum = inum;
  10117e:	89 7e 04             	mov    %edi,0x4(%esi)
  ip->ref = 1;
  101181:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->flags = 0;
  101188:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
  release(&icache.lock);
  10118f:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101196:	e8 45 2b 00 00       	call   103ce0 <release>

  return ip;
}
  10119b:	83 c4 2c             	add    $0x2c,%esp
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);
  10119e:	89 f0                	mov    %esi,%eax

  return ip;
}
  1011a0:	5b                   	pop    %ebx
  1011a1:	5e                   	pop    %esi
  1011a2:	5f                   	pop    %edi
  1011a3:	5d                   	pop    %ebp
  1011a4:	c3                   	ret    
      empty = ip;
  }

  // Allocate fresh inode.
  if(empty == 0)
    panic("iget: no inodes");
  1011a5:	c7 04 24 2b 67 10 00 	movl   $0x10672b,(%esp)
  1011ac:	e8 6f f7 ff ff       	call   100920 <panic>
  1011b1:	eb 0d                	jmp    1011c0 <readsb>
  1011b3:	90                   	nop
  1011b4:	90                   	nop
  1011b5:	90                   	nop
  1011b6:	90                   	nop
  1011b7:	90                   	nop
  1011b8:	90                   	nop
  1011b9:	90                   	nop
  1011ba:	90                   	nop
  1011bb:	90                   	nop
  1011bc:	90                   	nop
  1011bd:	90                   	nop
  1011be:	90                   	nop
  1011bf:	90                   	nop

001011c0 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
static void
readsb(int dev, struct superblock *sb)
{
  1011c0:	55                   	push   %ebp
  1011c1:	89 e5                	mov    %esp,%ebp
  1011c3:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
  1011c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1011cd:	00 
static void itrunc(struct inode*);

// Read the super block.
static void
readsb(int dev, struct superblock *sb)
{
  1011ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  1011d1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  1011d4:	89 d6                	mov    %edx,%esi
  struct buf *bp;
  
  bp = bread(dev, 1);
  1011d6:	89 04 24             	mov    %eax,(%esp)
  1011d9:	e8 42 ef ff ff       	call   100120 <bread>
  memmove(sb, bp->data, sizeof(*sb));
  1011de:	89 34 24             	mov    %esi,(%esp)
  1011e1:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
  1011e8:	00 
static void
readsb(int dev, struct superblock *sb)
{
  struct buf *bp;
  
  bp = bread(dev, 1);
  1011e9:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
  1011eb:	83 c0 18             	add    $0x18,%eax
  1011ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  1011f2:	e8 59 2c 00 00       	call   103e50 <memmove>
  brelse(bp);
  1011f7:	89 1c 24             	mov    %ebx,(%esp)
  1011fa:	e8 71 ee ff ff       	call   100070 <brelse>
}
  1011ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  101202:	8b 75 fc             	mov    -0x4(%ebp),%esi
  101205:	89 ec                	mov    %ebp,%esp
  101207:	5d                   	pop    %ebp
  101208:	c3                   	ret    
  101209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00101210 <balloc>:
// Blocks. 

// Allocate a disk block.
static uint
balloc(uint dev)
{
  101210:	55                   	push   %ebp
  101211:	89 e5                	mov    %esp,%ebp
  101213:	57                   	push   %edi
  101214:	56                   	push   %esi
  101215:	53                   	push   %ebx
  101216:	83 ec 3c             	sub    $0x3c,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  101219:	8d 55 dc             	lea    -0x24(%ebp),%edx
// Blocks. 

// Allocate a disk block.
static uint
balloc(uint dev)
{
  10121c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  10121f:	e8 9c ff ff ff       	call   1011c0 <readsb>
  for(b = 0; b < sb.size; b += BPB){
  101224:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101227:	85 c0                	test   %eax,%eax
  101229:	0f 84 9c 00 00 00    	je     1012cb <balloc+0xbb>
  10122f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    bp = bread(dev, BBLOCK(b, sb.ninodes));
  101236:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101239:	31 db                	xor    %ebx,%ebx
  10123b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10123e:	c1 e8 03             	shr    $0x3,%eax
  101241:	c1 fa 0c             	sar    $0xc,%edx
  101244:	8d 44 10 03          	lea    0x3(%eax,%edx,1),%eax
  101248:	89 44 24 04          	mov    %eax,0x4(%esp)
  10124c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10124f:	89 04 24             	mov    %eax,(%esp)
  101252:	e8 c9 ee ff ff       	call   100120 <bread>
  101257:	89 c6                	mov    %eax,%esi
  101259:	eb 10                	jmp    10126b <balloc+0x5b>
  10125b:	90                   	nop
  10125c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(bi = 0; bi < BPB; bi++){
  101260:	83 c3 01             	add    $0x1,%ebx
  101263:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  101269:	74 45                	je     1012b0 <balloc+0xa0>
      m = 1 << (bi % 8);
  10126b:	89 d9                	mov    %ebx,%ecx
  10126d:	b8 01 00 00 00       	mov    $0x1,%eax
  101272:	83 e1 07             	and    $0x7,%ecx
  101275:	d3 e0                	shl    %cl,%eax
  101277:	89 c1                	mov    %eax,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
  101279:	89 d8                	mov    %ebx,%eax
  10127b:	c1 f8 03             	sar    $0x3,%eax
  10127e:	0f b6 54 06 18       	movzbl 0x18(%esi,%eax,1),%edx
  101283:	0f b6 fa             	movzbl %dl,%edi
  101286:	85 cf                	test   %ecx,%edi
  101288:	75 d6                	jne    101260 <balloc+0x50>
        bp->data[bi/8] |= m;  // Mark block in use on disk.
  10128a:	09 d1                	or     %edx,%ecx
  10128c:	88 4c 06 18          	mov    %cl,0x18(%esi,%eax,1)
        bwrite(bp);
  101290:	89 34 24             	mov    %esi,(%esp)
  101293:	e8 58 ee ff ff       	call   1000f0 <bwrite>
        brelse(bp);
  101298:	89 34 24             	mov    %esi,(%esp)
  10129b:	e8 d0 ed ff ff       	call   100070 <brelse>
  1012a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
  1012a3:	83 c4 3c             	add    $0x3c,%esp
    for(bi = 0; bi < BPB; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use on disk.
        bwrite(bp);
        brelse(bp);
  1012a6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
  1012a9:	5b                   	pop    %ebx
  1012aa:	5e                   	pop    %esi
  1012ab:	5f                   	pop    %edi
  1012ac:	5d                   	pop    %ebp
  1012ad:	c3                   	ret    
  1012ae:	66 90                	xchg   %ax,%ax
        bwrite(bp);
        brelse(bp);
        return b + bi;
      }
    }
    brelse(bp);
  1012b0:	89 34 24             	mov    %esi,(%esp)
  1012b3:	e8 b8 ed ff ff       	call   100070 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
  1012b8:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
  1012bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1012c2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1012c5:	0f 87 6b ff ff ff    	ja     101236 <balloc+0x26>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
  1012cb:	c7 04 24 3b 67 10 00 	movl   $0x10673b,(%esp)
  1012d2:	e8 49 f6 ff ff       	call   100920 <panic>
  1012d7:	89 f6                	mov    %esi,%esi
  1012d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001012e0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
  1012e0:	55                   	push   %ebp
  1012e1:	89 e5                	mov    %esp,%ebp
  1012e3:	83 ec 38             	sub    $0x38,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
  1012e6:	83 fa 0b             	cmp    $0xb,%edx

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
  1012e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1012ec:	89 c3                	mov    %eax,%ebx
  1012ee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1012f1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
  1012f4:	77 1a                	ja     101310 <bmap+0x30>
    if((addr = ip->addrs[bn]) == 0)
  1012f6:	8d 7a 04             	lea    0x4(%edx),%edi
  1012f9:	8b 44 b8 0c          	mov    0xc(%eax,%edi,4),%eax
  1012fd:	85 c0                	test   %eax,%eax
  1012ff:	74 5f                	je     101360 <bmap+0x80>
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
  101301:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  101304:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101307:	8b 7d fc             	mov    -0x4(%ebp),%edi
  10130a:	89 ec                	mov    %ebp,%esp
  10130c:	5d                   	pop    %ebp
  10130d:	c3                   	ret    
  10130e:	66 90                	xchg   %ax,%ax
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
  101310:	8d 7a f4             	lea    -0xc(%edx),%edi

  if(bn < NINDIRECT){
  101313:	83 ff 7f             	cmp    $0x7f,%edi
  101316:	77 64                	ja     10137c <bmap+0x9c>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
  101318:	8b 40 4c             	mov    0x4c(%eax),%eax
  10131b:	85 c0                	test   %eax,%eax
  10131d:	74 51                	je     101370 <bmap+0x90>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  10131f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101323:	8b 03                	mov    (%ebx),%eax
  101325:	89 04 24             	mov    %eax,(%esp)
  101328:	e8 f3 ed ff ff       	call   100120 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  10132d:	8d 7c b8 18          	lea    0x18(%eax,%edi,4),%edi

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  101331:	89 c6                	mov    %eax,%esi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  101333:	8b 07                	mov    (%edi),%eax
  101335:	85 c0                	test   %eax,%eax
  101337:	75 17                	jne    101350 <bmap+0x70>
      a[bn] = addr = balloc(ip->dev);
  101339:	8b 03                	mov    (%ebx),%eax
  10133b:	e8 d0 fe ff ff       	call   101210 <balloc>
  101340:	89 07                	mov    %eax,(%edi)
      bwrite(bp);
  101342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101345:	89 34 24             	mov    %esi,(%esp)
  101348:	e8 a3 ed ff ff       	call   1000f0 <bwrite>
  10134d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    }
    brelse(bp);
  101350:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101353:	89 34 24             	mov    %esi,(%esp)
  101356:	e8 15 ed ff ff       	call   100070 <brelse>
    return addr;
  10135b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10135e:	eb a1                	jmp    101301 <bmap+0x21>
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
  101360:	8b 03                	mov    (%ebx),%eax
  101362:	e8 a9 fe ff ff       	call   101210 <balloc>
  101367:	89 44 bb 0c          	mov    %eax,0xc(%ebx,%edi,4)
  10136b:	eb 94                	jmp    101301 <bmap+0x21>
  10136d:	8d 76 00             	lea    0x0(%esi),%esi
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
  101370:	8b 03                	mov    (%ebx),%eax
  101372:	e8 99 fe ff ff       	call   101210 <balloc>
  101377:	89 43 4c             	mov    %eax,0x4c(%ebx)
  10137a:	eb a3                	jmp    10131f <bmap+0x3f>
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
  10137c:	c7 04 24 51 67 10 00 	movl   $0x106751,(%esp)
  101383:	e8 98 f5 ff ff       	call   100920 <panic>
  101388:	90                   	nop
  101389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00101390 <readi>:
}

// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
  101390:	55                   	push   %ebp
  101391:	89 e5                	mov    %esp,%ebp
  101393:	83 ec 38             	sub    $0x38,%esp
  101396:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  101399:	8b 5d 08             	mov    0x8(%ebp),%ebx
  10139c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10139f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  1013a2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  1013a5:	8b 75 10             	mov    0x10(%ebp),%esi
  1013a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
  1013ab:	66 83 7b 10 03       	cmpw   $0x3,0x10(%ebx)
  1013b0:	74 1e                	je     1013d0 <readi+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
  1013b2:	8b 43 18             	mov    0x18(%ebx),%eax
  1013b5:	39 f0                	cmp    %esi,%eax
  1013b7:	73 3f                	jae    1013f8 <readi+0x68>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
  1013b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1013be:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1013c1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1013c4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1013c7:	89 ec                	mov    %ebp,%esp
  1013c9:	5d                   	pop    %ebp
  1013ca:	c3                   	ret    
  1013cb:	90                   	nop
  1013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
  1013d0:	0f b7 43 12          	movzwl 0x12(%ebx),%eax
  1013d4:	66 83 f8 09          	cmp    $0x9,%ax
  1013d8:	77 df                	ja     1013b9 <readi+0x29>
  1013da:	98                   	cwtl   
  1013db:	8b 04 c5 80 aa 10 00 	mov    0x10aa80(,%eax,8),%eax
  1013e2:	85 c0                	test   %eax,%eax
  1013e4:	74 d3                	je     1013b9 <readi+0x29>
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  1013e6:	89 4d 10             	mov    %ecx,0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}
  1013e9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1013ec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1013ef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1013f2:	89 ec                	mov    %ebp,%esp
  1013f4:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  1013f5:	ff e0                	jmp    *%eax
  1013f7:	90                   	nop
  }

  if(off > ip->size || off + n < off)
  1013f8:	89 ca                	mov    %ecx,%edx
  1013fa:	01 f2                	add    %esi,%edx
  1013fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  1013ff:	72 b8                	jb     1013b9 <readi+0x29>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
  101401:	89 c2                	mov    %eax,%edx
  101403:	29 f2                	sub    %esi,%edx
  101405:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  101408:	0f 42 ca             	cmovb  %edx,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  10140b:	85 c9                	test   %ecx,%ecx
  10140d:	74 7e                	je     10148d <readi+0xfd>
  10140f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
  101416:	89 7d e0             	mov    %edi,-0x20(%ebp)
  101419:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  10141c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  101420:	89 f2                	mov    %esi,%edx
  101422:	89 d8                	mov    %ebx,%eax
  101424:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  101427:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  10142c:	e8 af fe ff ff       	call   1012e0 <bmap>
  101431:	89 44 24 04          	mov    %eax,0x4(%esp)
  101435:	8b 03                	mov    (%ebx),%eax
  101437:	89 04 24             	mov    %eax,(%esp)
  10143a:	e8 e1 ec ff ff       	call   100120 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
  10143f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  101442:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  101445:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  101447:	89 f0                	mov    %esi,%eax
  101449:	25 ff 01 00 00       	and    $0x1ff,%eax
  10144e:	29 c7                	sub    %eax,%edi
  101450:	39 cf                	cmp    %ecx,%edi
  101452:	0f 47 f9             	cmova  %ecx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
  101455:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  101459:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
  10145b:	89 7c 24 08          	mov    %edi,0x8(%esp)
  10145f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101463:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101466:	89 04 24             	mov    %eax,(%esp)
  101469:	89 55 d8             	mov    %edx,-0x28(%ebp)
  10146c:	e8 df 29 00 00       	call   103e50 <memmove>
    brelse(bp);
  101471:	8b 55 d8             	mov    -0x28(%ebp),%edx
  101474:	89 14 24             	mov    %edx,(%esp)
  101477:	e8 f4 eb ff ff       	call   100070 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  10147c:	01 7d e4             	add    %edi,-0x1c(%ebp)
  10147f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  101482:	01 7d e0             	add    %edi,-0x20(%ebp)
  101485:	39 55 dc             	cmp    %edx,-0x24(%ebp)
  101488:	77 96                	ja     101420 <readi+0x90>
  10148a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
  10148d:	89 c8                	mov    %ecx,%eax
  10148f:	e9 2a ff ff ff       	jmp    1013be <readi+0x2e>
  101494:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10149a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001014a0 <iupdate>:
}

// Copy inode, which has changed, from memory to disk.
void
iupdate(struct inode *ip)
{
  1014a0:	55                   	push   %ebp
  1014a1:	89 e5                	mov    %esp,%ebp
  1014a3:	56                   	push   %esi
  1014a4:	53                   	push   %ebx
  1014a5:	83 ec 10             	sub    $0x10,%esp
  1014a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
  1014ab:	8b 43 04             	mov    0x4(%ebx),%eax
  1014ae:	c1 e8 03             	shr    $0x3,%eax
  1014b1:	83 c0 02             	add    $0x2,%eax
  1014b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1014b8:	8b 03                	mov    (%ebx),%eax
  1014ba:	89 04 24             	mov    %eax,(%esp)
  1014bd:	e8 5e ec ff ff       	call   100120 <bread>
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  1014c2:	0f b7 53 10          	movzwl 0x10(%ebx),%edx
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
  1014c6:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  1014c8:	8b 43 04             	mov    0x4(%ebx),%eax
  1014cb:	83 e0 07             	and    $0x7,%eax
  1014ce:	c1 e0 06             	shl    $0x6,%eax
  1014d1:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
  dip->type = ip->type;
  1014d5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
  1014d8:	0f b7 53 12          	movzwl 0x12(%ebx),%edx
  1014dc:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
  1014e0:	0f b7 53 14          	movzwl 0x14(%ebx),%edx
  1014e4:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
  1014e8:	0f b7 53 16          	movzwl 0x16(%ebx),%edx
  1014ec:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
  1014f0:	8b 53 18             	mov    0x18(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  1014f3:	83 c3 1c             	add    $0x1c,%ebx
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  1014f6:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  1014f9:	83 c0 0c             	add    $0xc,%eax
  1014fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101500:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
  101507:	00 
  101508:	89 04 24             	mov    %eax,(%esp)
  10150b:	e8 40 29 00 00       	call   103e50 <memmove>
  bwrite(bp);
  101510:	89 34 24             	mov    %esi,(%esp)
  101513:	e8 d8 eb ff ff       	call   1000f0 <bwrite>
  brelse(bp);
  101518:	89 75 08             	mov    %esi,0x8(%ebp)
}
  10151b:	83 c4 10             	add    $0x10,%esp
  10151e:	5b                   	pop    %ebx
  10151f:	5e                   	pop    %esi
  101520:	5d                   	pop    %ebp
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  bwrite(bp);
  brelse(bp);
  101521:	e9 4a eb ff ff       	jmp    100070 <brelse>
  101526:	8d 76 00             	lea    0x0(%esi),%esi
  101529:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101530 <writei>:
}

// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
  101530:	55                   	push   %ebp
  101531:	89 e5                	mov    %esp,%ebp
  101533:	83 ec 38             	sub    $0x38,%esp
  101536:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  101539:	8b 5d 08             	mov    0x8(%ebp),%ebx
  10153c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10153f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  101542:	89 7d fc             	mov    %edi,-0x4(%ebp)
  101545:	8b 75 10             	mov    0x10(%ebp),%esi
  101548:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
  10154b:	66 83 7b 10 03       	cmpw   $0x3,0x10(%ebx)
  101550:	74 1e                	je     101570 <writei+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
  101552:	39 73 18             	cmp    %esi,0x18(%ebx)
  101555:	73 41                	jae    101598 <writei+0x68>

  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
  101557:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10155c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10155f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101562:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101565:	89 ec                	mov    %ebp,%esp
  101567:	5d                   	pop    %ebp
  101568:	c3                   	ret    
  101569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
  101570:	0f b7 43 12          	movzwl 0x12(%ebx),%eax
  101574:	66 83 f8 09          	cmp    $0x9,%ax
  101578:	77 dd                	ja     101557 <writei+0x27>
  10157a:	98                   	cwtl   
  10157b:	8b 04 c5 84 aa 10 00 	mov    0x10aa84(,%eax,8),%eax
  101582:	85 c0                	test   %eax,%eax
  101584:	74 d1                	je     101557 <writei+0x27>
      return -1;
    return devsw[ip->major].write(ip, src, n);
  101586:	89 4d 10             	mov    %ecx,0x10(%ebp)
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
  101589:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10158c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10158f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101592:	89 ec                	mov    %ebp,%esp
  101594:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  101595:	ff e0                	jmp    *%eax
  101597:	90                   	nop
  }

  if(off > ip->size || off + n < off)
  101598:	89 c8                	mov    %ecx,%eax
  10159a:	01 f0                	add    %esi,%eax
  10159c:	72 b9                	jb     101557 <writei+0x27>
    return -1;
  if(off + n > MAXFILE*BSIZE)
  10159e:	3d 00 18 01 00       	cmp    $0x11800,%eax
  1015a3:	76 07                	jbe    1015ac <writei+0x7c>
    n = MAXFILE*BSIZE - off;
  1015a5:	b9 00 18 01 00       	mov    $0x11800,%ecx
  1015aa:	29 f1                	sub    %esi,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  1015ac:	85 c9                	test   %ecx,%ecx
  1015ae:	0f 84 91 00 00 00    	je     101645 <writei+0x115>
  1015b4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
  1015bb:	89 7d e0             	mov    %edi,-0x20(%ebp)
  1015be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  1015c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  1015c8:	89 f2                	mov    %esi,%edx
  1015ca:	89 d8                	mov    %ebx,%eax
  1015cc:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  1015cf:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  1015d4:	e8 07 fd ff ff       	call   1012e0 <bmap>
  1015d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1015dd:	8b 03                	mov    (%ebx),%eax
  1015df:	89 04 24             	mov    %eax,(%esp)
  1015e2:	e8 39 eb ff ff       	call   100120 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
  1015e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1015ea:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  1015ed:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  1015ef:	89 f0                	mov    %esi,%eax
  1015f1:	25 ff 01 00 00       	and    $0x1ff,%eax
  1015f6:	29 c7                	sub    %eax,%edi
  1015f8:	39 cf                	cmp    %ecx,%edi
  1015fa:	0f 47 f9             	cmova  %ecx,%edi
    memmove(bp->data + off%BSIZE, src, m);
  1015fd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  101601:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  101604:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
  101608:	89 04 24             	mov    %eax,(%esp)
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  10160b:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(bp->data + off%BSIZE, src, m);
  10160d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  101611:	89 55 d8             	mov    %edx,-0x28(%ebp)
  101614:	e8 37 28 00 00       	call   103e50 <memmove>
    bwrite(bp);
  101619:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10161c:	89 14 24             	mov    %edx,(%esp)
  10161f:	e8 cc ea ff ff       	call   1000f0 <bwrite>
    brelse(bp);
  101624:	8b 55 d8             	mov    -0x28(%ebp),%edx
  101627:	89 14 24             	mov    %edx,(%esp)
  10162a:	e8 41 ea ff ff       	call   100070 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  10162f:	01 7d e4             	add    %edi,-0x1c(%ebp)
  101632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101635:	01 7d e0             	add    %edi,-0x20(%ebp)
  101638:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10163b:	77 8b                	ja     1015c8 <writei+0x98>
    memmove(bp->data + off%BSIZE, src, m);
    bwrite(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
  10163d:	3b 73 18             	cmp    0x18(%ebx),%esi
  101640:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  101643:	77 07                	ja     10164c <writei+0x11c>
    ip->size = off;
    iupdate(ip);
  }
  return n;
  101645:	89 c8                	mov    %ecx,%eax
  101647:	e9 10 ff ff ff       	jmp    10155c <writei+0x2c>
    bwrite(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
    ip->size = off;
  10164c:	89 73 18             	mov    %esi,0x18(%ebx)
    iupdate(ip);
  10164f:	89 1c 24             	mov    %ebx,(%esp)
  101652:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  101655:	e8 46 fe ff ff       	call   1014a0 <iupdate>
  10165a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  }
  return n;
  10165d:	89 c8                	mov    %ecx,%eax
  10165f:	e9 f8 fe ff ff       	jmp    10155c <writei+0x2c>
  101664:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10166a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00101670 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
  101670:	55                   	push   %ebp
  101671:	89 e5                	mov    %esp,%ebp
  101673:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
  101676:	8b 45 0c             	mov    0xc(%ebp),%eax
  101679:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101680:	00 
  101681:	89 44 24 04          	mov    %eax,0x4(%esp)
  101685:	8b 45 08             	mov    0x8(%ebp),%eax
  101688:	89 04 24             	mov    %eax,(%esp)
  10168b:	e8 30 28 00 00       	call   103ec0 <strncmp>
}
  101690:	c9                   	leave  
  101691:	c3                   	ret    
  101692:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  101699:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001016a0 <dirlookup>:
// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
  1016a0:	55                   	push   %ebp
  1016a1:	89 e5                	mov    %esp,%ebp
  1016a3:	57                   	push   %edi
  1016a4:	56                   	push   %esi
  1016a5:	53                   	push   %ebx
  1016a6:	83 ec 3c             	sub    $0x3c,%esp
  1016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1016ac:	8b 55 10             	mov    0x10(%ebp),%edx
  1016af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  1016b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1016b5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  uint off, inum;
  struct buf *bp;
  struct dirent *de;

  if(dp->type != T_DIR)
  1016b8:	66 83 78 10 01       	cmpw   $0x1,0x10(%eax)
  1016bd:	0f 85 d0 00 00 00    	jne    101793 <dirlookup+0xf3>
    panic("dirlookup not DIR");
  1016c3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  for(off = 0; off < dp->size; off += BSIZE){
  1016ca:	8b 48 18             	mov    0x18(%eax),%ecx
  1016cd:	85 c9                	test   %ecx,%ecx
  1016cf:	0f 84 b4 00 00 00    	je     101789 <dirlookup+0xe9>
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
  1016d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1016d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1016db:	c1 ea 09             	shr    $0x9,%edx
  1016de:	e8 fd fb ff ff       	call   1012e0 <bmap>
  1016e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1016e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1016ea:	8b 01                	mov    (%ecx),%eax
  1016ec:	89 04 24             	mov    %eax,(%esp)
  1016ef:	e8 2c ea ff ff       	call   100120 <bread>
  1016f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
  1016f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
  1016fa:	83 c0 18             	add    $0x18,%eax
  1016fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  101700:	89 c6                	mov    %eax,%esi

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
  101702:	81 c7 18 02 00 00    	add    $0x218,%edi
  101708:	eb 0d                	jmp    101717 <dirlookup+0x77>
  10170a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
        de < (struct dirent*)(bp->data + BSIZE);
        de++){
  101710:	83 c6 10             	add    $0x10,%esi
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
  101713:	39 fe                	cmp    %edi,%esi
  101715:	74 51                	je     101768 <dirlookup+0xc8>
        de < (struct dirent*)(bp->data + BSIZE);
        de++){
      if(de->inum == 0)
  101717:	66 83 3e 00          	cmpw   $0x0,(%esi)
  10171b:	74 f3                	je     101710 <dirlookup+0x70>
        continue;
      if(namecmp(name, de->name) == 0){
  10171d:	8d 46 02             	lea    0x2(%esi),%eax
  101720:	89 44 24 04          	mov    %eax,0x4(%esp)
  101724:	89 1c 24             	mov    %ebx,(%esp)
  101727:	e8 44 ff ff ff       	call   101670 <namecmp>
  10172c:	85 c0                	test   %eax,%eax
  10172e:	75 e0                	jne    101710 <dirlookup+0x70>
        // entry matches path element
        if(poff)
  101730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  101733:	85 d2                	test   %edx,%edx
  101735:	74 0e                	je     101745 <dirlookup+0xa5>
          *poff = off + (uchar*)de - bp->data;
  101737:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10173a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10173d:	8d 04 06             	lea    (%esi,%eax,1),%eax
  101740:	2b 45 d8             	sub    -0x28(%ebp),%eax
  101743:	89 02                	mov    %eax,(%edx)
        inum = de->inum;
        brelse(bp);
  101745:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
        continue;
      if(namecmp(name, de->name) == 0){
        // entry matches path element
        if(poff)
          *poff = off + (uchar*)de - bp->data;
        inum = de->inum;
  101748:	0f b7 1e             	movzwl (%esi),%ebx
        brelse(bp);
  10174b:	89 0c 24             	mov    %ecx,(%esp)
  10174e:	e8 1d e9 ff ff       	call   100070 <brelse>
        return iget(dp->dev, inum);
  101753:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  101756:	89 da                	mov    %ebx,%edx
  101758:	8b 01                	mov    (%ecx),%eax
      }
    }
    brelse(bp);
  }
  return 0;
}
  10175a:	83 c4 3c             	add    $0x3c,%esp
  10175d:	5b                   	pop    %ebx
  10175e:	5e                   	pop    %esi
  10175f:	5f                   	pop    %edi
  101760:	5d                   	pop    %ebp
        // entry matches path element
        if(poff)
          *poff = off + (uchar*)de - bp->data;
        inum = de->inum;
        brelse(bp);
        return iget(dp->dev, inum);
  101761:	e9 9a f9 ff ff       	jmp    101100 <iget>
  101766:	66 90                	xchg   %ax,%ax
      }
    }
    brelse(bp);
  101768:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10176b:	89 04 24             	mov    %eax,(%esp)
  10176e:	e8 fd e8 ff ff       	call   100070 <brelse>
  struct dirent *de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
  101773:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101776:	81 45 e0 00 02 00 00 	addl   $0x200,-0x20(%ebp)
  10177d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  101780:	39 4a 18             	cmp    %ecx,0x18(%edx)
  101783:	0f 87 4c ff ff ff    	ja     1016d5 <dirlookup+0x35>
      }
    }
    brelse(bp);
  }
  return 0;
}
  101789:	83 c4 3c             	add    $0x3c,%esp
  10178c:	31 c0                	xor    %eax,%eax
  10178e:	5b                   	pop    %ebx
  10178f:	5e                   	pop    %esi
  101790:	5f                   	pop    %edi
  101791:	5d                   	pop    %ebp
  101792:	c3                   	ret    
  uint off, inum;
  struct buf *bp;
  struct dirent *de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
  101793:	c7 04 24 64 67 10 00 	movl   $0x106764,(%esp)
  10179a:	e8 81 f1 ff ff       	call   100920 <panic>
  10179f:	90                   	nop

001017a0 <iunlock>:
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  1017a0:	55                   	push   %ebp
  1017a1:	89 e5                	mov    %esp,%ebp
  1017a3:	53                   	push   %ebx
  1017a4:	83 ec 14             	sub    $0x14,%esp
  1017a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
  1017aa:	85 db                	test   %ebx,%ebx
  1017ac:	74 36                	je     1017e4 <iunlock+0x44>
  1017ae:	f6 43 0c 01          	testb  $0x1,0xc(%ebx)
  1017b2:	74 30                	je     1017e4 <iunlock+0x44>
  1017b4:	8b 43 08             	mov    0x8(%ebx),%eax
  1017b7:	85 c0                	test   %eax,%eax
  1017b9:	7e 29                	jle    1017e4 <iunlock+0x44>
    panic("iunlock");

  acquire(&icache.lock);
  1017bb:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1017c2:	e8 69 25 00 00       	call   103d30 <acquire>
  ip->flags &= ~I_BUSY;
  1017c7:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
  1017cb:	89 1c 24             	mov    %ebx,(%esp)
  1017ce:	e8 8d 19 00 00       	call   103160 <wakeup>
  release(&icache.lock);
  1017d3:	c7 45 08 e0 aa 10 00 	movl   $0x10aae0,0x8(%ebp)
}
  1017da:	83 c4 14             	add    $0x14,%esp
  1017dd:	5b                   	pop    %ebx
  1017de:	5d                   	pop    %ebp
    panic("iunlock");

  acquire(&icache.lock);
  ip->flags &= ~I_BUSY;
  wakeup(ip);
  release(&icache.lock);
  1017df:	e9 fc 24 00 00       	jmp    103ce0 <release>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
    panic("iunlock");
  1017e4:	c7 04 24 76 67 10 00 	movl   $0x106776,(%esp)
  1017eb:	e8 30 f1 ff ff       	call   100920 <panic>

001017f0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
  1017f0:	55                   	push   %ebp
  1017f1:	89 e5                	mov    %esp,%ebp
  1017f3:	57                   	push   %edi
  1017f4:	56                   	push   %esi
  1017f5:	89 c6                	mov    %eax,%esi
  1017f7:	53                   	push   %ebx
  1017f8:	89 d3                	mov    %edx,%ebx
  1017fa:	83 ec 2c             	sub    $0x2c,%esp
static void
bzero(int dev, int bno)
{
  struct buf *bp;
  
  bp = bread(dev, bno);
  1017fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  101801:	89 04 24             	mov    %eax,(%esp)
  101804:	e8 17 e9 ff ff       	call   100120 <bread>
  memset(bp->data, 0, BSIZE);
  101809:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  101810:	00 
  101811:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101818:	00 
static void
bzero(int dev, int bno)
{
  struct buf *bp;
  
  bp = bread(dev, bno);
  101819:	89 c7                	mov    %eax,%edi
  memset(bp->data, 0, BSIZE);
  10181b:	83 c0 18             	add    $0x18,%eax
  10181e:	89 04 24             	mov    %eax,(%esp)
  101821:	e8 aa 25 00 00       	call   103dd0 <memset>
  bwrite(bp);
  101826:	89 3c 24             	mov    %edi,(%esp)
  101829:	e8 c2 e8 ff ff       	call   1000f0 <bwrite>
  brelse(bp);
  10182e:	89 3c 24             	mov    %edi,(%esp)
  101831:	e8 3a e8 ff ff       	call   100070 <brelse>
  struct superblock sb;
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  101836:	89 f0                	mov    %esi,%eax
  101838:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10183b:	e8 80 f9 ff ff       	call   1011c0 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  101840:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101843:	89 da                	mov    %ebx,%edx
  101845:	c1 ea 0c             	shr    $0xc,%edx
  101848:	89 34 24             	mov    %esi,(%esp)
  bi = b % BPB;
  m = 1 << (bi % 8);
  10184b:	be 01 00 00 00       	mov    $0x1,%esi
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  101850:	c1 e8 03             	shr    $0x3,%eax
  101853:	8d 44 10 03          	lea    0x3(%eax,%edx,1),%eax
  101857:	89 44 24 04          	mov    %eax,0x4(%esp)
  10185b:	e8 c0 e8 ff ff       	call   100120 <bread>
  bi = b % BPB;
  101860:	89 da                	mov    %ebx,%edx
  m = 1 << (bi % 8);
  101862:	89 d9                	mov    %ebx,%ecx

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  101864:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
  10186a:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
  10186d:	c1 fa 03             	sar    $0x3,%edx
  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  m = 1 << (bi % 8);
  101870:	d3 e6                	shl    %cl,%esi
  if((bp->data[bi/8] & m) == 0)
  101872:	0f b6 4c 10 18       	movzbl 0x18(%eax,%edx,1),%ecx
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  101877:	89 c7                	mov    %eax,%edi
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
  101879:	0f b6 c1             	movzbl %cl,%eax
  10187c:	85 f0                	test   %esi,%eax
  10187e:	74 22                	je     1018a2 <bfree+0xb2>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;  // Mark block free on disk.
  101880:	89 f0                	mov    %esi,%eax
  101882:	f7 d0                	not    %eax
  101884:	21 c8                	and    %ecx,%eax
  101886:	88 44 17 18          	mov    %al,0x18(%edi,%edx,1)
  bwrite(bp);
  10188a:	89 3c 24             	mov    %edi,(%esp)
  10188d:	e8 5e e8 ff ff       	call   1000f0 <bwrite>
  brelse(bp);
  101892:	89 3c 24             	mov    %edi,(%esp)
  101895:	e8 d6 e7 ff ff       	call   100070 <brelse>
}
  10189a:	83 c4 2c             	add    $0x2c,%esp
  10189d:	5b                   	pop    %ebx
  10189e:	5e                   	pop    %esi
  10189f:	5f                   	pop    %edi
  1018a0:	5d                   	pop    %ebp
  1018a1:	c3                   	ret    
  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
  1018a2:	c7 04 24 7e 67 10 00 	movl   $0x10677e,(%esp)
  1018a9:	e8 72 f0 ff ff       	call   100920 <panic>
  1018ae:	66 90                	xchg   %ax,%ax

001018b0 <iput>:
}

// Caller holds reference to unlocked ip.  Drop reference.
void
iput(struct inode *ip)
{
  1018b0:	55                   	push   %ebp
  1018b1:	89 e5                	mov    %esp,%ebp
  1018b3:	57                   	push   %edi
  1018b4:	56                   	push   %esi
  1018b5:	53                   	push   %ebx
  1018b6:	83 ec 2c             	sub    $0x2c,%esp
  1018b9:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&icache.lock);
  1018bc:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1018c3:	e8 68 24 00 00       	call   103d30 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
  1018c8:	8b 46 08             	mov    0x8(%esi),%eax
  1018cb:	83 f8 01             	cmp    $0x1,%eax
  1018ce:	0f 85 a1 00 00 00    	jne    101975 <iput+0xc5>
  1018d4:	8b 56 0c             	mov    0xc(%esi),%edx
  1018d7:	f6 c2 02             	test   $0x2,%dl
  1018da:	0f 84 95 00 00 00    	je     101975 <iput+0xc5>
  1018e0:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  1018e5:	0f 85 8a 00 00 00    	jne    101975 <iput+0xc5>
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
  1018eb:	f6 c2 01             	test   $0x1,%dl
  1018ee:	66 90                	xchg   %ax,%ax
  1018f0:	0f 85 f8 00 00 00    	jne    1019ee <iput+0x13e>
      panic("iput busy");
    ip->flags |= I_BUSY;
  1018f6:	83 ca 01             	or     $0x1,%edx
    release(&icache.lock);
  1018f9:	89 f3                	mov    %esi,%ebx
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
  1018fb:	89 56 0c             	mov    %edx,0xc(%esi)
  release(&icache.lock);
}

// Caller holds reference to unlocked ip.  Drop reference.
void
iput(struct inode *ip)
  1018fe:	8d 7e 30             	lea    0x30(%esi),%edi
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
  101901:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101908:	e8 d3 23 00 00       	call   103ce0 <release>
  10190d:	eb 08                	jmp    101917 <iput+0x67>
  10190f:	90                   	nop
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
  101910:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
  101913:	39 fb                	cmp    %edi,%ebx
  101915:	74 1c                	je     101933 <iput+0x83>
    if(ip->addrs[i]){
  101917:	8b 53 1c             	mov    0x1c(%ebx),%edx
  10191a:	85 d2                	test   %edx,%edx
  10191c:	74 f2                	je     101910 <iput+0x60>
      bfree(ip->dev, ip->addrs[i]);
  10191e:	8b 06                	mov    (%esi),%eax
  101920:	e8 cb fe ff ff       	call   1017f0 <bfree>
      ip->addrs[i] = 0;
  101925:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
  10192c:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
  10192f:	39 fb                	cmp    %edi,%ebx
  101931:	75 e4                	jne    101917 <iput+0x67>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
  101933:	8b 46 4c             	mov    0x4c(%esi),%eax
  101936:	85 c0                	test   %eax,%eax
  101938:	75 56                	jne    101990 <iput+0xe0>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  10193a:	c7 46 18 00 00 00 00 	movl   $0x0,0x18(%esi)
  iupdate(ip);
  101941:	89 34 24             	mov    %esi,(%esp)
  101944:	e8 57 fb ff ff       	call   1014a0 <iupdate>
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
    itrunc(ip);
    ip->type = 0;
  101949:	66 c7 46 10 00 00    	movw   $0x0,0x10(%esi)
    iupdate(ip);
  10194f:	89 34 24             	mov    %esi,(%esp)
  101952:	e8 49 fb ff ff       	call   1014a0 <iupdate>
    acquire(&icache.lock);
  101957:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  10195e:	e8 cd 23 00 00       	call   103d30 <acquire>
    ip->flags = 0;
  101963:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
  10196a:	89 34 24             	mov    %esi,(%esp)
  10196d:	e8 ee 17 00 00       	call   103160 <wakeup>
  101972:	8b 46 08             	mov    0x8(%esi),%eax
  }
  ip->ref--;
  101975:	83 e8 01             	sub    $0x1,%eax
  101978:	89 46 08             	mov    %eax,0x8(%esi)
  release(&icache.lock);
  10197b:	c7 45 08 e0 aa 10 00 	movl   $0x10aae0,0x8(%ebp)
}
  101982:	83 c4 2c             	add    $0x2c,%esp
  101985:	5b                   	pop    %ebx
  101986:	5e                   	pop    %esi
  101987:	5f                   	pop    %edi
  101988:	5d                   	pop    %ebp
    acquire(&icache.lock);
    ip->flags = 0;
    wakeup(ip);
  }
  ip->ref--;
  release(&icache.lock);
  101989:	e9 52 23 00 00       	jmp    103ce0 <release>
  10198e:	66 90                	xchg   %ax,%ax
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  101990:	89 44 24 04          	mov    %eax,0x4(%esp)
  101994:	8b 06                	mov    (%esi),%eax
    a = (uint*)bp->data;
  101996:	31 db                	xor    %ebx,%ebx
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  101998:	89 04 24             	mov    %eax,(%esp)
  10199b:	e8 80 e7 ff ff       	call   100120 <bread>
    a = (uint*)bp->data;
  1019a0:	89 c7                	mov    %eax,%edi
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  1019a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
  1019a5:	83 c7 18             	add    $0x18,%edi
  1019a8:	31 c0                	xor    %eax,%eax
  1019aa:	eb 11                	jmp    1019bd <iput+0x10d>
  1019ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(j = 0; j < NINDIRECT; j++){
  1019b0:	83 c3 01             	add    $0x1,%ebx
  1019b3:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  1019b9:	89 d8                	mov    %ebx,%eax
  1019bb:	74 10                	je     1019cd <iput+0x11d>
      if(a[j])
  1019bd:	8b 14 87             	mov    (%edi,%eax,4),%edx
  1019c0:	85 d2                	test   %edx,%edx
  1019c2:	74 ec                	je     1019b0 <iput+0x100>
        bfree(ip->dev, a[j]);
  1019c4:	8b 06                	mov    (%esi),%eax
  1019c6:	e8 25 fe ff ff       	call   1017f0 <bfree>
  1019cb:	eb e3                	jmp    1019b0 <iput+0x100>
    }
    brelse(bp);
  1019cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1019d0:	89 04 24             	mov    %eax,(%esp)
  1019d3:	e8 98 e6 ff ff       	call   100070 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
  1019d8:	8b 56 4c             	mov    0x4c(%esi),%edx
  1019db:	8b 06                	mov    (%esi),%eax
  1019dd:	e8 0e fe ff ff       	call   1017f0 <bfree>
    ip->addrs[NDIRECT] = 0;
  1019e2:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  1019e9:	e9 4c ff ff ff       	jmp    10193a <iput+0x8a>
{
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
  1019ee:	c7 04 24 91 67 10 00 	movl   $0x106791,(%esp)
  1019f5:	e8 26 ef ff ff       	call   100920 <panic>
  1019fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00101a00 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
  101a00:	55                   	push   %ebp
  101a01:	89 e5                	mov    %esp,%ebp
  101a03:	57                   	push   %edi
  101a04:	56                   	push   %esi
  101a05:	53                   	push   %ebx
  101a06:	83 ec 2c             	sub    $0x2c,%esp
  101a09:	8b 75 08             	mov    0x8(%ebp),%esi
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
  101a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  101a0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  101a16:	00 
  101a17:	89 34 24             	mov    %esi,(%esp)
  101a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a1e:	e8 7d fc ff ff       	call   1016a0 <dirlookup>
  101a23:	85 c0                	test   %eax,%eax
  101a25:	0f 85 89 00 00 00    	jne    101ab4 <dirlink+0xb4>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101a2b:	8b 56 18             	mov    0x18(%esi),%edx
  101a2e:	85 d2                	test   %edx,%edx
  101a30:	0f 84 8d 00 00 00    	je     101ac3 <dirlink+0xc3>
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
    return -1;
  101a36:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101a39:	31 db                	xor    %ebx,%ebx
  101a3b:	eb 0b                	jmp    101a48 <dirlink+0x48>
  101a3d:	8d 76 00             	lea    0x0(%esi),%esi
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101a40:	83 c3 10             	add    $0x10,%ebx
  101a43:	39 5e 18             	cmp    %ebx,0x18(%esi)
  101a46:	76 24                	jbe    101a6c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a48:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101a4f:	00 
  101a50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101a54:	89 7c 24 04          	mov    %edi,0x4(%esp)
  101a58:	89 34 24             	mov    %esi,(%esp)
  101a5b:	e8 30 f9 ff ff       	call   101390 <readi>
  101a60:	83 f8 10             	cmp    $0x10,%eax
  101a63:	75 65                	jne    101aca <dirlink+0xca>
      panic("dirlink read");
    if(de.inum == 0)
  101a65:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
  101a6a:	75 d4                	jne    101a40 <dirlink+0x40>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  101a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  101a6f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101a76:	00 
  101a77:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a7b:	8d 45 da             	lea    -0x26(%ebp),%eax
  101a7e:	89 04 24             	mov    %eax,(%esp)
  101a81:	e8 9a 24 00 00       	call   103f20 <strncpy>
  de.inum = inum;
  101a86:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a89:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101a90:	00 
  101a91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101a95:	89 7c 24 04          	mov    %edi,0x4(%esp)
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  101a99:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a9d:	89 34 24             	mov    %esi,(%esp)
  101aa0:	e8 8b fa ff ff       	call   101530 <writei>
  101aa5:	83 f8 10             	cmp    $0x10,%eax
  101aa8:	75 2c                	jne    101ad6 <dirlink+0xd6>
    panic("dirlink");
  101aaa:	31 c0                	xor    %eax,%eax
  
  return 0;
}
  101aac:	83 c4 2c             	add    $0x2c,%esp
  101aaf:	5b                   	pop    %ebx
  101ab0:	5e                   	pop    %esi
  101ab1:	5f                   	pop    %edi
  101ab2:	5d                   	pop    %ebp
  101ab3:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
  101ab4:	89 04 24             	mov    %eax,(%esp)
  101ab7:	e8 f4 fd ff ff       	call   1018b0 <iput>
  101abc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  101ac1:	eb e9                	jmp    101aac <dirlink+0xac>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101ac3:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101ac6:	31 db                	xor    %ebx,%ebx
  101ac8:	eb a2                	jmp    101a6c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
  101aca:	c7 04 24 9b 67 10 00 	movl   $0x10679b,(%esp)
  101ad1:	e8 4a ee ff ff       	call   100920 <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
  101ad6:	c7 04 24 42 6d 10 00 	movl   $0x106d42,(%esp)
  101add:	e8 3e ee ff ff       	call   100920 <panic>
  101ae2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  101ae9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101af0 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  101af0:	55                   	push   %ebp
  101af1:	89 e5                	mov    %esp,%ebp
  101af3:	53                   	push   %ebx
  101af4:	83 ec 14             	sub    $0x14,%esp
  101af7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
  101afa:	89 1c 24             	mov    %ebx,(%esp)
  101afd:	e8 9e fc ff ff       	call   1017a0 <iunlock>
  iput(ip);
  101b02:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  101b05:	83 c4 14             	add    $0x14,%esp
  101b08:	5b                   	pop    %ebx
  101b09:	5d                   	pop    %ebp
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
  101b0a:	e9 a1 fd ff ff       	jmp    1018b0 <iput>
  101b0f:	90                   	nop

00101b10 <ialloc>:
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101b10:	55                   	push   %ebp
  101b11:	89 e5                	mov    %esp,%ebp
  101b13:	57                   	push   %edi
  101b14:	56                   	push   %esi
  101b15:	53                   	push   %ebx
  101b16:	83 ec 3c             	sub    $0x3c,%esp
  101b19:	0f b7 45 0c          	movzwl 0xc(%ebp),%eax
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101b1d:	8d 55 dc             	lea    -0x24(%ebp),%edx
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101b20:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101b24:	8b 45 08             	mov    0x8(%ebp),%eax
  101b27:	e8 94 f6 ff ff       	call   1011c0 <readsb>
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b2c:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
  101b30:	0f 86 96 00 00 00    	jbe    101bcc <ialloc+0xbc>
  101b36:	be 01 00 00 00       	mov    $0x1,%esi
  101b3b:	bb 01 00 00 00       	mov    $0x1,%ebx
  101b40:	eb 18                	jmp    101b5a <ialloc+0x4a>
  101b42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101b48:	83 c3 01             	add    $0x1,%ebx
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101b4b:	89 3c 24             	mov    %edi,(%esp)
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b4e:	89 de                	mov    %ebx,%esi
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101b50:	e8 1b e5 ff ff       	call   100070 <brelse>
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b55:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  101b58:	76 72                	jbe    101bcc <ialloc+0xbc>
    bp = bread(dev, IBLOCK(inum));
  101b5a:	89 f0                	mov    %esi,%eax
  101b5c:	c1 e8 03             	shr    $0x3,%eax
  101b5f:	83 c0 02             	add    $0x2,%eax
  101b62:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b66:	8b 45 08             	mov    0x8(%ebp),%eax
  101b69:	89 04 24             	mov    %eax,(%esp)
  101b6c:	e8 af e5 ff ff       	call   100120 <bread>
  101b71:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
  101b73:	89 f0                	mov    %esi,%eax
  101b75:	83 e0 07             	and    $0x7,%eax
  101b78:	c1 e0 06             	shl    $0x6,%eax
  101b7b:	8d 54 07 18          	lea    0x18(%edi,%eax,1),%edx
    if(dip->type == 0){  // a free inode
  101b7f:	66 83 3a 00          	cmpw   $0x0,(%edx)
  101b83:	75 c3                	jne    101b48 <ialloc+0x38>
      memset(dip, 0, sizeof(*dip));
  101b85:	89 14 24             	mov    %edx,(%esp)
  101b88:	89 55 d0             	mov    %edx,-0x30(%ebp)
  101b8b:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
  101b92:	00 
  101b93:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101b9a:	00 
  101b9b:	e8 30 22 00 00       	call   103dd0 <memset>
      dip->type = type;
  101ba0:	8b 55 d0             	mov    -0x30(%ebp),%edx
  101ba3:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101ba7:	66 89 02             	mov    %ax,(%edx)
      bwrite(bp);   // mark it allocated on the disk
  101baa:	89 3c 24             	mov    %edi,(%esp)
  101bad:	e8 3e e5 ff ff       	call   1000f0 <bwrite>
      brelse(bp);
  101bb2:	89 3c 24             	mov    %edi,(%esp)
  101bb5:	e8 b6 e4 ff ff       	call   100070 <brelse>
      return iget(dev, inum);
  101bba:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbd:	89 f2                	mov    %esi,%edx
  101bbf:	e8 3c f5 ff ff       	call   101100 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
  101bc4:	83 c4 3c             	add    $0x3c,%esp
  101bc7:	5b                   	pop    %ebx
  101bc8:	5e                   	pop    %esi
  101bc9:	5f                   	pop    %edi
  101bca:	5d                   	pop    %ebp
  101bcb:	c3                   	ret    
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
  101bcc:	c7 04 24 a8 67 10 00 	movl   $0x1067a8,(%esp)
  101bd3:	e8 48 ed ff ff       	call   100920 <panic>
  101bd8:	90                   	nop
  101bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00101be0 <ilock>:
}

// Lock the given inode.
void
ilock(struct inode *ip)
{
  101be0:	55                   	push   %ebp
  101be1:	89 e5                	mov    %esp,%ebp
  101be3:	56                   	push   %esi
  101be4:	53                   	push   %ebx
  101be5:	83 ec 10             	sub    $0x10,%esp
  101be8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
  101beb:	85 db                	test   %ebx,%ebx
  101bed:	0f 84 e5 00 00 00    	je     101cd8 <ilock+0xf8>
  101bf3:	8b 4b 08             	mov    0x8(%ebx),%ecx
  101bf6:	85 c9                	test   %ecx,%ecx
  101bf8:	0f 8e da 00 00 00    	jle    101cd8 <ilock+0xf8>
    panic("ilock");

  acquire(&icache.lock);
  101bfe:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101c05:	e8 26 21 00 00       	call   103d30 <acquire>
  while(ip->flags & I_BUSY)
  101c0a:	8b 43 0c             	mov    0xc(%ebx),%eax
  101c0d:	a8 01                	test   $0x1,%al
  101c0f:	74 1e                	je     101c2f <ilock+0x4f>
  101c11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sleep(ip, &icache.lock);
  101c18:	c7 44 24 04 e0 aa 10 	movl   $0x10aae0,0x4(%esp)
  101c1f:	00 
  101c20:	89 1c 24             	mov    %ebx,(%esp)
  101c23:	e8 68 16 00 00       	call   103290 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
  101c28:	8b 43 0c             	mov    0xc(%ebx),%eax
  101c2b:	a8 01                	test   $0x1,%al
  101c2d:	75 e9                	jne    101c18 <ilock+0x38>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  101c2f:	83 c8 01             	or     $0x1,%eax
  101c32:	89 43 0c             	mov    %eax,0xc(%ebx)
  release(&icache.lock);
  101c35:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101c3c:	e8 9f 20 00 00       	call   103ce0 <release>

  if(!(ip->flags & I_VALID)){
  101c41:	f6 43 0c 02          	testb  $0x2,0xc(%ebx)
  101c45:	74 09                	je     101c50 <ilock+0x70>
    brelse(bp);
    ip->flags |= I_VALID;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
  101c47:	83 c4 10             	add    $0x10,%esp
  101c4a:	5b                   	pop    %ebx
  101c4b:	5e                   	pop    %esi
  101c4c:	5d                   	pop    %ebp
  101c4d:	c3                   	ret    
  101c4e:	66 90                	xchg   %ax,%ax
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  release(&icache.lock);

  if(!(ip->flags & I_VALID)){
    bp = bread(ip->dev, IBLOCK(ip->inum));
  101c50:	8b 43 04             	mov    0x4(%ebx),%eax
  101c53:	c1 e8 03             	shr    $0x3,%eax
  101c56:	83 c0 02             	add    $0x2,%eax
  101c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5d:	8b 03                	mov    (%ebx),%eax
  101c5f:	89 04 24             	mov    %eax,(%esp)
  101c62:	e8 b9 e4 ff ff       	call   100120 <bread>
  101c67:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
  101c69:	8b 43 04             	mov    0x4(%ebx),%eax
  101c6c:	83 e0 07             	and    $0x7,%eax
  101c6f:	c1 e0 06             	shl    $0x6,%eax
  101c72:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
    ip->type = dip->type;
  101c76:	0f b7 10             	movzwl (%eax),%edx
  101c79:	66 89 53 10          	mov    %dx,0x10(%ebx)
    ip->major = dip->major;
  101c7d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
  101c81:	66 89 53 12          	mov    %dx,0x12(%ebx)
    ip->minor = dip->minor;
  101c85:	0f b7 50 04          	movzwl 0x4(%eax),%edx
  101c89:	66 89 53 14          	mov    %dx,0x14(%ebx)
    ip->nlink = dip->nlink;
  101c8d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
  101c91:	66 89 53 16          	mov    %dx,0x16(%ebx)
    ip->size = dip->size;
  101c95:	8b 50 08             	mov    0x8(%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101c98:	83 c0 0c             	add    $0xc,%eax
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
  101c9b:	89 53 18             	mov    %edx,0x18(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca2:	8d 43 1c             	lea    0x1c(%ebx),%eax
  101ca5:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
  101cac:	00 
  101cad:	89 04 24             	mov    %eax,(%esp)
  101cb0:	e8 9b 21 00 00       	call   103e50 <memmove>
    brelse(bp);
  101cb5:	89 34 24             	mov    %esi,(%esp)
  101cb8:	e8 b3 e3 ff ff       	call   100070 <brelse>
    ip->flags |= I_VALID;
  101cbd:	83 4b 0c 02          	orl    $0x2,0xc(%ebx)
    if(ip->type == 0)
  101cc1:	66 83 7b 10 00       	cmpw   $0x0,0x10(%ebx)
  101cc6:	0f 85 7b ff ff ff    	jne    101c47 <ilock+0x67>
      panic("ilock: no type");
  101ccc:	c7 04 24 c0 67 10 00 	movl   $0x1067c0,(%esp)
  101cd3:	e8 48 ec ff ff       	call   100920 <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
  101cd8:	c7 04 24 ba 67 10 00 	movl   $0x1067ba,(%esp)
  101cdf:	e8 3c ec ff ff       	call   100920 <panic>
  101ce4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101cea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00101cf0 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
  101cf0:	55                   	push   %ebp
  101cf1:	89 e5                	mov    %esp,%ebp
  101cf3:	57                   	push   %edi
  101cf4:	56                   	push   %esi
  101cf5:	53                   	push   %ebx
  101cf6:	89 c3                	mov    %eax,%ebx
  101cf8:	83 ec 2c             	sub    $0x2c,%esp
  101cfb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  101cfe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
  101d01:	80 38 2f             	cmpb   $0x2f,(%eax)
  101d04:	0f 84 14 01 00 00    	je     101e1e <namex+0x12e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
  101d0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  101d10:	8b 40 68             	mov    0x68(%eax),%eax
  101d13:	89 04 24             	mov    %eax,(%esp)
  101d16:	e8 b5 f3 ff ff       	call   1010d0 <idup>
  101d1b:	89 c7                	mov    %eax,%edi
  101d1d:	eb 04                	jmp    101d23 <namex+0x33>
  101d1f:	90                   	nop
{
  char *s;
  int len;

  while(*path == '/')
    path++;
  101d20:	83 c3 01             	add    $0x1,%ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
  101d23:	0f b6 03             	movzbl (%ebx),%eax
  101d26:	3c 2f                	cmp    $0x2f,%al
  101d28:	74 f6                	je     101d20 <namex+0x30>
    path++;
  if(*path == 0)
  101d2a:	84 c0                	test   %al,%al
  101d2c:	75 1a                	jne    101d48 <namex+0x58>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
  101d2e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  101d31:	85 db                	test   %ebx,%ebx
  101d33:	0f 85 0d 01 00 00    	jne    101e46 <namex+0x156>
    iput(ip);
    return 0;
  }
  return ip;
}
  101d39:	83 c4 2c             	add    $0x2c,%esp
  101d3c:	89 f8                	mov    %edi,%eax
  101d3e:	5b                   	pop    %ebx
  101d3f:	5e                   	pop    %esi
  101d40:	5f                   	pop    %edi
  101d41:	5d                   	pop    %ebp
  101d42:	c3                   	ret    
  101d43:	90                   	nop
  101d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101d48:	3c 2f                	cmp    $0x2f,%al
  101d4a:	0f 84 94 00 00 00    	je     101de4 <namex+0xf4>
  101d50:	89 de                	mov    %ebx,%esi
  101d52:	eb 08                	jmp    101d5c <namex+0x6c>
  101d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101d58:	3c 2f                	cmp    $0x2f,%al
  101d5a:	74 0a                	je     101d66 <namex+0x76>
    path++;
  101d5c:	83 c6 01             	add    $0x1,%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101d5f:	0f b6 06             	movzbl (%esi),%eax
  101d62:	84 c0                	test   %al,%al
  101d64:	75 f2                	jne    101d58 <namex+0x68>
  101d66:	89 f2                	mov    %esi,%edx
  101d68:	29 da                	sub    %ebx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
  101d6a:	83 fa 0d             	cmp    $0xd,%edx
  101d6d:	7e 79                	jle    101de8 <namex+0xf8>
    memmove(name, s, DIRSIZ);
  101d6f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101d76:	00 
  101d77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101d7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101d7e:	89 04 24             	mov    %eax,(%esp)
  101d81:	e8 ca 20 00 00       	call   103e50 <memmove>
  101d86:	eb 03                	jmp    101d8b <namex+0x9b>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
    path++;
  101d88:	83 c6 01             	add    $0x1,%esi
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101d8b:	80 3e 2f             	cmpb   $0x2f,(%esi)
  101d8e:	74 f8                	je     101d88 <namex+0x98>
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
  101d90:	85 f6                	test   %esi,%esi
  101d92:	74 9a                	je     101d2e <namex+0x3e>
    ilock(ip);
  101d94:	89 3c 24             	mov    %edi,(%esp)
  101d97:	e8 44 fe ff ff       	call   101be0 <ilock>
    if(ip->type != T_DIR){
  101d9c:	66 83 7f 10 01       	cmpw   $0x1,0x10(%edi)
  101da1:	75 67                	jne    101e0a <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
  101da3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101da6:	85 c0                	test   %eax,%eax
  101da8:	74 0c                	je     101db6 <namex+0xc6>
  101daa:	80 3e 00             	cmpb   $0x0,(%esi)
  101dad:	8d 76 00             	lea    0x0(%esi),%esi
  101db0:	0f 84 7e 00 00 00    	je     101e34 <namex+0x144>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
  101db6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  101dbd:	00 
  101dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101dc1:	89 3c 24             	mov    %edi,(%esp)
  101dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dc8:	e8 d3 f8 ff ff       	call   1016a0 <dirlookup>
  101dcd:	85 c0                	test   %eax,%eax
  101dcf:	89 c3                	mov    %eax,%ebx
  101dd1:	74 37                	je     101e0a <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
  101dd3:	89 3c 24             	mov    %edi,(%esp)
  101dd6:	89 df                	mov    %ebx,%edi
  101dd8:	89 f3                	mov    %esi,%ebx
  101dda:	e8 11 fd ff ff       	call   101af0 <iunlockput>
  101ddf:	e9 3f ff ff ff       	jmp    101d23 <namex+0x33>
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101de4:	89 de                	mov    %ebx,%esi
  101de6:	31 d2                	xor    %edx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
  101de8:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101df3:	89 04 24             	mov    %eax,(%esp)
  101df6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  101df9:	e8 52 20 00 00       	call   103e50 <memmove>
    name[len] = 0;
  101dfe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101e01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101e04:	c6 04 10 00          	movb   $0x0,(%eax,%edx,1)
  101e08:	eb 81                	jmp    101d8b <namex+0x9b>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
  101e0a:	89 3c 24             	mov    %edi,(%esp)
  101e0d:	31 ff                	xor    %edi,%edi
  101e0f:	e8 dc fc ff ff       	call   101af0 <iunlockput>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101e14:	83 c4 2c             	add    $0x2c,%esp
  101e17:	89 f8                	mov    %edi,%eax
  101e19:	5b                   	pop    %ebx
  101e1a:	5e                   	pop    %esi
  101e1b:	5f                   	pop    %edi
  101e1c:	5d                   	pop    %ebp
  101e1d:	c3                   	ret    
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  101e1e:	ba 01 00 00 00       	mov    $0x1,%edx
  101e23:	b8 01 00 00 00       	mov    $0x1,%eax
  101e28:	e8 d3 f2 ff ff       	call   101100 <iget>
  101e2d:	89 c7                	mov    %eax,%edi
  101e2f:	e9 ef fe ff ff       	jmp    101d23 <namex+0x33>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
  101e34:	89 3c 24             	mov    %edi,(%esp)
  101e37:	e8 64 f9 ff ff       	call   1017a0 <iunlock>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101e3c:	83 c4 2c             	add    $0x2c,%esp
  101e3f:	89 f8                	mov    %edi,%eax
  101e41:	5b                   	pop    %ebx
  101e42:	5e                   	pop    %esi
  101e43:	5f                   	pop    %edi
  101e44:	5d                   	pop    %ebp
  101e45:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
  101e46:	89 3c 24             	mov    %edi,(%esp)
  101e49:	31 ff                	xor    %edi,%edi
  101e4b:	e8 60 fa ff ff       	call   1018b0 <iput>
    return 0;
  101e50:	e9 e4 fe ff ff       	jmp    101d39 <namex+0x49>
  101e55:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101e59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101e60 <nameiparent>:
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101e60:	55                   	push   %ebp
  return namex(path, 1, name);
  101e61:	ba 01 00 00 00       	mov    $0x1,%edx
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101e66:	89 e5                	mov    %esp,%ebp
  101e68:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
  101e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  101e6e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  101e71:	c9                   	leave  
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
  101e72:	e9 79 fe ff ff       	jmp    101cf0 <namex>
  101e77:	89 f6                	mov    %esi,%esi
  101e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101e80 <namei>:
  return ip;
}

struct inode*
namei(char *path)
{
  101e80:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101e81:	31 d2                	xor    %edx,%edx
  return ip;
}

struct inode*
namei(char *path)
{
  101e83:	89 e5                	mov    %esp,%ebp
  101e85:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101e88:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
  101e8e:	e8 5d fe ff ff       	call   101cf0 <namex>
}
  101e93:	c9                   	leave  
  101e94:	c3                   	ret    
  101e95:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101e99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101ea0 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
  101ea0:	55                   	push   %ebp
  101ea1:	89 e5                	mov    %esp,%ebp
  101ea3:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
  101ea6:	c7 44 24 04 cf 67 10 	movl   $0x1067cf,0x4(%esp)
  101ead:	00 
  101eae:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101eb5:	e8 e6 1c 00 00       	call   103ba0 <initlock>
}
  101eba:	c9                   	leave  
  101ebb:	c3                   	ret    
  101ebc:	90                   	nop
  101ebd:	90                   	nop
  101ebe:	90                   	nop
  101ebf:	90                   	nop

00101ec0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  101ec0:	55                   	push   %ebp
  101ec1:	89 e5                	mov    %esp,%ebp
  101ec3:	56                   	push   %esi
  101ec4:	89 c6                	mov    %eax,%esi
  101ec6:	83 ec 14             	sub    $0x14,%esp
  if(b == 0)
  101ec9:	85 c0                	test   %eax,%eax
  101ecb:	0f 84 8d 00 00 00    	je     101f5e <idestart+0x9e>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  101ed1:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101ed6:	66 90                	xchg   %ax,%ax
  101ed8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  101ed9:	25 c0 00 00 00       	and    $0xc0,%eax
  101ede:	83 f8 40             	cmp    $0x40,%eax
  101ee1:	75 f5                	jne    101ed8 <idestart+0x18>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  101ee3:	ba f6 03 00 00       	mov    $0x3f6,%edx
  101ee8:	31 c0                	xor    %eax,%eax
  101eea:	ee                   	out    %al,(%dx)
  101eeb:	ba f2 01 00 00       	mov    $0x1f2,%edx
  101ef0:	b8 01 00 00 00       	mov    $0x1,%eax
  101ef5:	ee                   	out    %al,(%dx)
    panic("idestart");

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, 1);  // number of sectors
  outb(0x1f3, b->sector & 0xff);
  101ef6:	8b 4e 08             	mov    0x8(%esi),%ecx
  101ef9:	b2 f3                	mov    $0xf3,%dl
  101efb:	89 c8                	mov    %ecx,%eax
  101efd:	ee                   	out    %al,(%dx)
  101efe:	89 c8                	mov    %ecx,%eax
  101f00:	b2 f4                	mov    $0xf4,%dl
  101f02:	c1 e8 08             	shr    $0x8,%eax
  101f05:	ee                   	out    %al,(%dx)
  101f06:	89 c8                	mov    %ecx,%eax
  101f08:	b2 f5                	mov    $0xf5,%dl
  101f0a:	c1 e8 10             	shr    $0x10,%eax
  101f0d:	ee                   	out    %al,(%dx)
  101f0e:	8b 46 04             	mov    0x4(%esi),%eax
  101f11:	c1 e9 18             	shr    $0x18,%ecx
  101f14:	b2 f6                	mov    $0xf6,%dl
  101f16:	83 e1 0f             	and    $0xf,%ecx
  101f19:	83 e0 01             	and    $0x1,%eax
  101f1c:	c1 e0 04             	shl    $0x4,%eax
  101f1f:	09 c8                	or     %ecx,%eax
  101f21:	83 c8 e0             	or     $0xffffffe0,%eax
  101f24:	ee                   	out    %al,(%dx)
  outb(0x1f4, (b->sector >> 8) & 0xff);
  outb(0x1f5, (b->sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
  101f25:	f6 06 04             	testb  $0x4,(%esi)
  101f28:	75 16                	jne    101f40 <idestart+0x80>
  101f2a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101f2f:	b8 20 00 00 00       	mov    $0x20,%eax
  101f34:	ee                   	out    %al,(%dx)
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
  101f35:	83 c4 14             	add    $0x14,%esp
  101f38:	5e                   	pop    %esi
  101f39:	5d                   	pop    %ebp
  101f3a:	c3                   	ret    
  101f3b:	90                   	nop
  101f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101f40:	b2 f7                	mov    $0xf7,%dl
  101f42:	b8 30 00 00 00       	mov    $0x30,%eax
  101f47:	ee                   	out    %al,(%dx)
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
  101f48:	b9 80 00 00 00       	mov    $0x80,%ecx
  101f4d:	83 c6 18             	add    $0x18,%esi
  101f50:	ba f0 01 00 00       	mov    $0x1f0,%edx
  101f55:	fc                   	cld    
  101f56:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  101f58:	83 c4 14             	add    $0x14,%esp
  101f5b:	5e                   	pop    %esi
  101f5c:	5d                   	pop    %ebp
  101f5d:	c3                   	ret    
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  101f5e:	c7 04 24 d6 67 10 00 	movl   $0x1067d6,(%esp)
  101f65:	e8 b6 e9 ff ff       	call   100920 <panic>
  101f6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00101f70 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
  101f70:	55                   	push   %ebp
  101f71:	89 e5                	mov    %esp,%ebp
  101f73:	53                   	push   %ebx
  101f74:	83 ec 14             	sub    $0x14,%esp
  101f77:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!(b->flags & B_BUSY))
  101f7a:	8b 03                	mov    (%ebx),%eax
  101f7c:	a8 01                	test   $0x1,%al
  101f7e:	0f 84 90 00 00 00    	je     102014 <iderw+0xa4>
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
  101f84:	83 e0 06             	and    $0x6,%eax
  101f87:	83 f8 02             	cmp    $0x2,%eax
  101f8a:	0f 84 9c 00 00 00    	je     10202c <iderw+0xbc>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
  101f90:	8b 53 04             	mov    0x4(%ebx),%edx
  101f93:	85 d2                	test   %edx,%edx
  101f95:	74 0d                	je     101fa4 <iderw+0x34>
  101f97:	a1 b8 78 10 00       	mov    0x1078b8,%eax
  101f9c:	85 c0                	test   %eax,%eax
  101f9e:	0f 84 7c 00 00 00    	je     102020 <iderw+0xb0>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);
  101fa4:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  101fab:	e8 80 1d 00 00       	call   103d30 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  101fb0:	ba b4 78 10 00       	mov    $0x1078b4,%edx
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);

  // Append b to idequeue.
  b->qnext = 0;
  101fb5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  101fbc:	a1 b4 78 10 00       	mov    0x1078b4,%eax
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  101fc1:	85 c0                	test   %eax,%eax
  101fc3:	74 0d                	je     101fd2 <iderw+0x62>
  101fc5:	8d 76 00             	lea    0x0(%esi),%esi
  101fc8:	8d 50 14             	lea    0x14(%eax),%edx
  101fcb:	8b 40 14             	mov    0x14(%eax),%eax
  101fce:	85 c0                	test   %eax,%eax
  101fd0:	75 f6                	jne    101fc8 <iderw+0x58>
    ;
  *pp = b;
  101fd2:	89 1a                	mov    %ebx,(%edx)
  
  // Start disk if necessary.
  if(idequeue == b)
  101fd4:	39 1d b4 78 10 00    	cmp    %ebx,0x1078b4
  101fda:	75 14                	jne    101ff0 <iderw+0x80>
  101fdc:	eb 2d                	jmp    10200b <iderw+0x9b>
  101fde:	66 90                	xchg   %ax,%ax
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  101fe0:	c7 44 24 04 80 78 10 	movl   $0x107880,0x4(%esp)
  101fe7:	00 
  101fe8:	89 1c 24             	mov    %ebx,(%esp)
  101feb:	e8 a0 12 00 00       	call   103290 <sleep>
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
  101ff0:	8b 03                	mov    (%ebx),%eax
  101ff2:	83 e0 06             	and    $0x6,%eax
  101ff5:	83 f8 02             	cmp    $0x2,%eax
  101ff8:	75 e6                	jne    101fe0 <iderw+0x70>
    sleep(b, &idelock);
  }

  release(&idelock);
  101ffa:	c7 45 08 80 78 10 00 	movl   $0x107880,0x8(%ebp)
}
  102001:	83 c4 14             	add    $0x14,%esp
  102004:	5b                   	pop    %ebx
  102005:	5d                   	pop    %ebp
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }

  release(&idelock);
  102006:	e9 d5 1c 00 00       	jmp    103ce0 <release>
    ;
  *pp = b;
  
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  10200b:	89 d8                	mov    %ebx,%eax
  10200d:	e8 ae fe ff ff       	call   101ec0 <idestart>
  102012:	eb dc                	jmp    101ff0 <iderw+0x80>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  102014:	c7 04 24 df 67 10 00 	movl   $0x1067df,(%esp)
  10201b:	e8 00 e9 ff ff       	call   100920 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
  102020:	c7 04 24 08 68 10 00 	movl   $0x106808,(%esp)
  102027:	e8 f4 e8 ff ff       	call   100920 <panic>
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  10202c:	c7 04 24 f3 67 10 00 	movl   $0x1067f3,(%esp)
  102033:	e8 e8 e8 ff ff       	call   100920 <panic>
  102038:	90                   	nop
  102039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102040 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
  102040:	55                   	push   %ebp
  102041:	89 e5                	mov    %esp,%ebp
  102043:	57                   	push   %edi
  102044:	53                   	push   %ebx
  102045:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  // Take first buffer off queue.
  acquire(&idelock);
  102048:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  10204f:	e8 dc 1c 00 00       	call   103d30 <acquire>
  if((b = idequeue) == 0){
  102054:	8b 1d b4 78 10 00    	mov    0x1078b4,%ebx
  10205a:	85 db                	test   %ebx,%ebx
  10205c:	74 2d                	je     10208b <ideintr+0x4b>
    release(&idelock);
    // cprintf("spurious IDE interrupt\n");
    return;
  }
  idequeue = b->qnext;
  10205e:	8b 43 14             	mov    0x14(%ebx),%eax
  102061:	a3 b4 78 10 00       	mov    %eax,0x1078b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
  102066:	8b 0b                	mov    (%ebx),%ecx
  102068:	f6 c1 04             	test   $0x4,%cl
  10206b:	74 33                	je     1020a0 <ideintr+0x60>
    insl(0x1f0, b->data, 512/4);
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
  10206d:	83 c9 02             	or     $0x2,%ecx
  102070:	83 e1 fb             	and    $0xfffffffb,%ecx
  102073:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
  102075:	89 1c 24             	mov    %ebx,(%esp)
  102078:	e8 e3 10 00 00       	call   103160 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
  10207d:	a1 b4 78 10 00       	mov    0x1078b4,%eax
  102082:	85 c0                	test   %eax,%eax
  102084:	74 05                	je     10208b <ideintr+0x4b>
    idestart(idequeue);
  102086:	e8 35 fe ff ff       	call   101ec0 <idestart>

  release(&idelock);
  10208b:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  102092:	e8 49 1c 00 00       	call   103ce0 <release>
}
  102097:	83 c4 10             	add    $0x10,%esp
  10209a:	5b                   	pop    %ebx
  10209b:	5f                   	pop    %edi
  10209c:	5d                   	pop    %ebp
  10209d:	c3                   	ret    
  10209e:	66 90                	xchg   %ax,%ax
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  1020a0:	ba f7 01 00 00       	mov    $0x1f7,%edx
  1020a5:	8d 76 00             	lea    0x0(%esi),%esi
  1020a8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  1020a9:	0f b6 c0             	movzbl %al,%eax
  1020ac:	89 c7                	mov    %eax,%edi
  1020ae:	81 e7 c0 00 00 00    	and    $0xc0,%edi
  1020b4:	83 ff 40             	cmp    $0x40,%edi
  1020b7:	75 ef                	jne    1020a8 <ideintr+0x68>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
  1020b9:	a8 21                	test   $0x21,%al
  1020bb:	75 b0                	jne    10206d <ideintr+0x2d>
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
  1020bd:	8d 7b 18             	lea    0x18(%ebx),%edi
  1020c0:	b9 80 00 00 00       	mov    $0x80,%ecx
  1020c5:	ba f0 01 00 00       	mov    $0x1f0,%edx
  1020ca:	fc                   	cld    
  1020cb:	f3 6d                	rep insl (%dx),%es:(%edi)
  1020cd:	8b 0b                	mov    (%ebx),%ecx
  1020cf:	eb 9c                	jmp    10206d <ideintr+0x2d>
  1020d1:	eb 0d                	jmp    1020e0 <ideinit>
  1020d3:	90                   	nop
  1020d4:	90                   	nop
  1020d5:	90                   	nop
  1020d6:	90                   	nop
  1020d7:	90                   	nop
  1020d8:	90                   	nop
  1020d9:	90                   	nop
  1020da:	90                   	nop
  1020db:	90                   	nop
  1020dc:	90                   	nop
  1020dd:	90                   	nop
  1020de:	90                   	nop
  1020df:	90                   	nop

001020e0 <ideinit>:
  return 0;
}

void
ideinit(void)
{
  1020e0:	55                   	push   %ebp
  1020e1:	89 e5                	mov    %esp,%ebp
  1020e3:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
  1020e6:	c7 44 24 04 26 68 10 	movl   $0x106826,0x4(%esp)
  1020ed:	00 
  1020ee:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  1020f5:	e8 a6 1a 00 00       	call   103ba0 <initlock>
  picenable(IRQ_IDE);
  1020fa:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  102101:	e8 ba 0a 00 00       	call   102bc0 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
  102106:	a1 00 c1 10 00       	mov    0x10c100,%eax
  10210b:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  102112:	83 e8 01             	sub    $0x1,%eax
  102115:	89 44 24 04          	mov    %eax,0x4(%esp)
  102119:	e8 52 00 00 00       	call   102170 <ioapicenable>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  10211e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  102123:	90                   	nop
  102124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102128:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  102129:	25 c0 00 00 00       	and    $0xc0,%eax
  10212e:	83 f8 40             	cmp    $0x40,%eax
  102131:	75 f5                	jne    102128 <ideinit+0x48>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102133:	ba f6 01 00 00       	mov    $0x1f6,%edx
  102138:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  10213d:	ee                   	out    %al,(%dx)
  10213e:	31 c9                	xor    %ecx,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102140:	b2 f7                	mov    $0xf7,%dl
  102142:	eb 0f                	jmp    102153 <ideinit+0x73>
  102144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
  102148:	83 c1 01             	add    $0x1,%ecx
  10214b:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  102151:	74 0f                	je     102162 <ideinit+0x82>
  102153:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
  102154:	84 c0                	test   %al,%al
  102156:	74 f0                	je     102148 <ideinit+0x68>
      havedisk1 = 1;
  102158:	c7 05 b8 78 10 00 01 	movl   $0x1,0x1078b8
  10215f:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102162:	ba f6 01 00 00       	mov    $0x1f6,%edx
  102167:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  10216c:	ee                   	out    %al,(%dx)
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
  10216d:	c9                   	leave  
  10216e:	c3                   	ret    
  10216f:	90                   	nop

00102170 <ioapicenable>:
}

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
  102170:	8b 15 04 bb 10 00    	mov    0x10bb04,%edx
  }
}

void
ioapicenable(int irq, int cpunum)
{
  102176:	55                   	push   %ebp
  102177:	89 e5                	mov    %esp,%ebp
  102179:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!ismp)
  10217c:	85 d2                	test   %edx,%edx
  10217e:	74 31                	je     1021b1 <ioapicenable+0x41>
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102180:	8b 15 b4 ba 10 00    	mov    0x10bab4,%edx
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  102186:	8d 48 20             	lea    0x20(%eax),%ecx
  102189:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10218d:	89 02                	mov    %eax,(%edx)
  ioapic->data = data;
  10218f:	8b 15 b4 ba 10 00    	mov    0x10bab4,%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102195:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
  102198:	89 4a 10             	mov    %ecx,0x10(%edx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10219b:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  1021a1:	8b 55 0c             	mov    0xc(%ebp),%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021a4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
  1021a6:	a1 b4 ba 10 00       	mov    0x10bab4,%eax

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  1021ab:	c1 e2 18             	shl    $0x18,%edx

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  1021ae:	89 50 10             	mov    %edx,0x10(%eax)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
  1021b1:	5d                   	pop    %ebp
  1021b2:	c3                   	ret    
  1021b3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1021b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001021c0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
  1021c0:	55                   	push   %ebp
  1021c1:	89 e5                	mov    %esp,%ebp
  1021c3:	56                   	push   %esi
  1021c4:	53                   	push   %ebx
  1021c5:	83 ec 10             	sub    $0x10,%esp
  int i, id, maxintr;

  if(!ismp)
  1021c8:	8b 0d 04 bb 10 00    	mov    0x10bb04,%ecx
  1021ce:	85 c9                	test   %ecx,%ecx
  1021d0:	0f 84 9e 00 00 00    	je     102274 <ioapicinit+0xb4>
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  1021d6:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
  1021dd:	00 00 00 
  return ioapic->data;
  1021e0:	8b 35 10 00 c0 fe    	mov    0xfec00010,%esi
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021e6:	bb 00 00 c0 fe       	mov    $0xfec00000,%ebx
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  1021eb:	c7 05 00 00 c0 fe 00 	movl   $0x0,0xfec00000
  1021f2:	00 00 00 
  return ioapic->data;
  1021f5:	a1 10 00 c0 fe       	mov    0xfec00010,%eax
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021fa:	0f b6 15 00 bb 10 00 	movzbl 0x10bb00,%edx
  int i, id, maxintr;

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  102201:	c7 05 b4 ba 10 00 00 	movl   $0xfec00000,0x10bab4
  102208:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  10220b:	c1 ee 10             	shr    $0x10,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  10220e:	c1 e8 18             	shr    $0x18,%eax

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  102211:	81 e6 ff 00 00 00    	and    $0xff,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  102217:	39 c2                	cmp    %eax,%edx
  102219:	74 12                	je     10222d <ioapicinit+0x6d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
  10221b:	c7 04 24 2c 68 10 00 	movl   $0x10682c,(%esp)
  102222:	e8 09 e3 ff ff       	call   100530 <cprintf>
  102227:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
  10222d:	ba 10 00 00 00       	mov    $0x10,%edx
  102232:	31 c0                	xor    %eax,%eax
  102234:	eb 08                	jmp    10223e <ioapicinit+0x7e>
  102236:	66 90                	xchg   %ax,%ax

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  102238:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10223e:	89 13                	mov    %edx,(%ebx)
  ioapic->data = data;
  102240:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
  102246:	8d 48 20             	lea    0x20(%eax),%ecx
  102249:	81 c9 00 00 01 00    	or     $0x10000,%ecx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  10224f:	83 c0 01             	add    $0x1,%eax

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  102252:	89 4b 10             	mov    %ecx,0x10(%ebx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102255:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx
  10225b:	8d 5a 01             	lea    0x1(%edx),%ebx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  10225e:	83 c2 02             	add    $0x2,%edx
  102261:	39 c6                	cmp    %eax,%esi
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102263:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
  102265:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx
  10226b:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  102272:	7d c4                	jge    102238 <ioapicinit+0x78>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
  102274:	83 c4 10             	add    $0x10,%esp
  102277:	5b                   	pop    %ebx
  102278:	5e                   	pop    %esi
  102279:	5d                   	pop    %ebp
  10227a:	c3                   	ret    
  10227b:	90                   	nop
  10227c:	90                   	nop
  10227d:	90                   	nop
  10227e:	90                   	nop
  10227f:	90                   	nop

00102280 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  102280:	55                   	push   %ebp
  102281:	89 e5                	mov    %esp,%ebp
  102283:	53                   	push   %ebx
  102284:	83 ec 14             	sub    $0x14,%esp
  struct run *r;

  acquire(&kmem.lock);
  102287:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  10228e:	e8 9d 1a 00 00       	call   103d30 <acquire>
  r = kmem.freelist;
  102293:	8b 1d f4 ba 10 00    	mov    0x10baf4,%ebx
  if(r)
  102299:	85 db                	test   %ebx,%ebx
  10229b:	74 07                	je     1022a4 <kalloc+0x24>
    kmem.freelist = r->next;
  10229d:	8b 03                	mov    (%ebx),%eax
  10229f:	a3 f4 ba 10 00       	mov    %eax,0x10baf4
  release(&kmem.lock);
  1022a4:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  1022ab:	e8 30 1a 00 00       	call   103ce0 <release>
  return (char*)r;
}
  1022b0:	89 d8                	mov    %ebx,%eax
  1022b2:	83 c4 14             	add    $0x14,%esp
  1022b5:	5b                   	pop    %ebx
  1022b6:	5d                   	pop    %ebp
  1022b7:	c3                   	ret    
  1022b8:	90                   	nop
  1022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001022c0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
  1022c0:	55                   	push   %ebp
  1022c1:	89 e5                	mov    %esp,%ebp
  1022c3:	53                   	push   %ebx
  1022c4:	83 ec 14             	sub    $0x14,%esp
  1022c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
  1022ca:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  1022d0:	75 52                	jne    102324 <kfree+0x64>
  1022d2:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  1022d8:	77 4a                	ja     102324 <kfree+0x64>
  1022da:	81 fb a4 ea 10 00    	cmp    $0x10eaa4,%ebx
  1022e0:	72 42                	jb     102324 <kfree+0x64>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
  1022e2:	89 1c 24             	mov    %ebx,(%esp)
  1022e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1022ec:	00 
  1022ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1022f4:	00 
  1022f5:	e8 d6 1a 00 00       	call   103dd0 <memset>

  acquire(&kmem.lock);
  1022fa:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  102301:	e8 2a 1a 00 00       	call   103d30 <acquire>
  r = (struct run*)v;
  r->next = kmem.freelist;
  102306:	a1 f4 ba 10 00       	mov    0x10baf4,%eax
  10230b:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  10230d:	89 1d f4 ba 10 00    	mov    %ebx,0x10baf4
  release(&kmem.lock);
  102313:	c7 45 08 c0 ba 10 00 	movl   $0x10bac0,0x8(%ebp)
}
  10231a:	83 c4 14             	add    $0x14,%esp
  10231d:	5b                   	pop    %ebx
  10231e:	5d                   	pop    %ebp

  acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
  10231f:	e9 bc 19 00 00       	jmp    103ce0 <release>
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
    panic("kfree");
  102324:	c7 04 24 5e 68 10 00 	movl   $0x10685e,(%esp)
  10232b:	e8 f0 e5 ff ff       	call   100920 <panic>

00102330 <kinit>:
extern char end[]; // first address after kernel loaded from ELF file

// Initialize free list of physical pages.
void
kinit(void)
{
  102330:	55                   	push   %ebp
  102331:	89 e5                	mov    %esp,%ebp
  102333:	53                   	push   %ebx
  102334:	83 ec 14             	sub    $0x14,%esp
  char *p;

  initlock(&kmem.lock, "kmem");
  102337:	c7 44 24 04 64 68 10 	movl   $0x106864,0x4(%esp)
  10233e:	00 
  10233f:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  102346:	e8 55 18 00 00       	call   103ba0 <initlock>
  p = (char*)PGROUNDUP((uint)end);
  10234b:	ba a3 fa 10 00       	mov    $0x10faa3,%edx
  102350:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  102356:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
  10235c:	81 fb 00 00 00 01    	cmp    $0x1000000,%ebx
  102362:	76 08                	jbe    10236c <kinit+0x3c>
  102364:	eb 1b                	jmp    102381 <kinit+0x51>
  102366:	66 90                	xchg   %ax,%ax
  102368:	89 da                	mov    %ebx,%edx
  10236a:	89 c3                	mov    %eax,%ebx
    kfree(p);
  10236c:	89 14 24             	mov    %edx,(%esp)
  10236f:	e8 4c ff ff ff       	call   1022c0 <kfree>
{
  char *p;

  initlock(&kmem.lock, "kmem");
  p = (char*)PGROUNDUP((uint)end);
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  102374:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  10237a:	3d 00 00 00 01       	cmp    $0x1000000,%eax
  10237f:	76 e7                	jbe    102368 <kinit+0x38>
    kfree(p);
}
  102381:	83 c4 14             	add    $0x14,%esp
  102384:	5b                   	pop    %ebx
  102385:	5d                   	pop    %ebp
  102386:	c3                   	ret    
  102387:	90                   	nop
  102388:	90                   	nop
  102389:	90                   	nop
  10238a:	90                   	nop
  10238b:	90                   	nop
  10238c:	90                   	nop
  10238d:	90                   	nop
  10238e:	90                   	nop
  10238f:	90                   	nop

00102390 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
  102390:	55                   	push   %ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102391:	ba 64 00 00 00       	mov    $0x64,%edx
  102396:	89 e5                	mov    %esp,%ebp
  102398:	ec                   	in     (%dx),%al
  102399:	89 c2                	mov    %eax,%edx
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
  10239b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1023a0:	83 e2 01             	and    $0x1,%edx
  1023a3:	74 41                	je     1023e6 <kbdgetc+0x56>
  1023a5:	ba 60 00 00 00       	mov    $0x60,%edx
  1023aa:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
  1023ab:	0f b6 c0             	movzbl %al,%eax

  if(data == 0xE0){
  1023ae:	3d e0 00 00 00       	cmp    $0xe0,%eax
  1023b3:	0f 84 7f 00 00 00    	je     102438 <kbdgetc+0xa8>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
  1023b9:	84 c0                	test   %al,%al
  1023bb:	79 2b                	jns    1023e8 <kbdgetc+0x58>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
  1023bd:	8b 15 bc 78 10 00    	mov    0x1078bc,%edx
  1023c3:	89 c1                	mov    %eax,%ecx
  1023c5:	83 e1 7f             	and    $0x7f,%ecx
  1023c8:	f6 c2 40             	test   $0x40,%dl
  1023cb:	0f 44 c1             	cmove  %ecx,%eax
    shift &= ~(shiftcode[data] | E0ESC);
  1023ce:	0f b6 80 80 68 10 00 	movzbl 0x106880(%eax),%eax
  1023d5:	83 c8 40             	or     $0x40,%eax
  1023d8:	0f b6 c0             	movzbl %al,%eax
  1023db:	f7 d0                	not    %eax
  1023dd:	21 d0                	and    %edx,%eax
  1023df:	a3 bc 78 10 00       	mov    %eax,0x1078bc
  1023e4:	31 c0                	xor    %eax,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  1023e6:	5d                   	pop    %ebp
  1023e7:	c3                   	ret    
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
  1023e8:	8b 0d bc 78 10 00    	mov    0x1078bc,%ecx
  1023ee:	f6 c1 40             	test   $0x40,%cl
  1023f1:	74 05                	je     1023f8 <kbdgetc+0x68>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
  1023f3:	0c 80                	or     $0x80,%al
    shift &= ~E0ESC;
  1023f5:	83 e1 bf             	and    $0xffffffbf,%ecx
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  1023f8:	0f b6 90 80 68 10 00 	movzbl 0x106880(%eax),%edx
  1023ff:	09 ca                	or     %ecx,%edx
  102401:	0f b6 88 80 69 10 00 	movzbl 0x106980(%eax),%ecx
  102408:	31 ca                	xor    %ecx,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
  10240a:	89 d1                	mov    %edx,%ecx
  10240c:	83 e1 03             	and    $0x3,%ecx
  10240f:	8b 0c 8d 80 6a 10 00 	mov    0x106a80(,%ecx,4),%ecx
    data |= 0x80;
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  102416:	89 15 bc 78 10 00    	mov    %edx,0x1078bc
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
  10241c:	83 e2 08             	and    $0x8,%edx
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  10241f:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
  if(shift & CAPSLOCK){
  102423:	74 c1                	je     1023e6 <kbdgetc+0x56>
    if('a' <= c && c <= 'z')
  102425:	8d 50 9f             	lea    -0x61(%eax),%edx
  102428:	83 fa 19             	cmp    $0x19,%edx
  10242b:	77 1b                	ja     102448 <kbdgetc+0xb8>
      c += 'A' - 'a';
  10242d:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102430:	5d                   	pop    %ebp
  102431:	c3                   	ret    
  102432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if((st & KBS_DIB) == 0)
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
  102438:	30 c0                	xor    %al,%al
  10243a:	83 0d bc 78 10 00 40 	orl    $0x40,0x1078bc
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102441:	5d                   	pop    %ebp
  102442:	c3                   	ret    
  102443:	90                   	nop
  102444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
  102448:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
  10244b:	8d 50 20             	lea    0x20(%eax),%edx
  10244e:	83 f9 19             	cmp    $0x19,%ecx
  102451:	0f 46 c2             	cmovbe %edx,%eax
  }
  return c;
}
  102454:	5d                   	pop    %ebp
  102455:	c3                   	ret    
  102456:	8d 76 00             	lea    0x0(%esi),%esi
  102459:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102460 <kbdintr>:

void
kbdintr(void)
{
  102460:	55                   	push   %ebp
  102461:	89 e5                	mov    %esp,%ebp
  102463:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
  102466:	c7 04 24 90 23 10 00 	movl   $0x102390,(%esp)
  10246d:	e8 1e e3 ff ff       	call   100790 <consoleintr>
}
  102472:	c9                   	leave  
  102473:	c3                   	ret    
  102474:	90                   	nop
  102475:	90                   	nop
  102476:	90                   	nop
  102477:	90                   	nop
  102478:	90                   	nop
  102479:	90                   	nop
  10247a:	90                   	nop
  10247b:	90                   	nop
  10247c:	90                   	nop
  10247d:	90                   	nop
  10247e:	90                   	nop
  10247f:	90                   	nop

00102480 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
  102480:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
}

// Acknowledge interrupt.
void
lapiceoi(void)
{
  102485:	55                   	push   %ebp
  102486:	89 e5                	mov    %esp,%ebp
  if(lapic)
  102488:	85 c0                	test   %eax,%eax
  10248a:	74 12                	je     10249e <lapiceoi+0x1e>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10248c:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  102493:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102496:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10249b:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
  10249e:	5d                   	pop    %ebp
  10249f:	c3                   	ret    

001024a0 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
  1024a0:	55                   	push   %ebp
  1024a1:	89 e5                	mov    %esp,%ebp
}
  1024a3:	5d                   	pop    %ebp
  1024a4:	c3                   	ret    
  1024a5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1024a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001024b0 <lapicstartap>:

// Start additional processor running bootstrap code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
  1024b0:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1024b1:	ba 70 00 00 00       	mov    $0x70,%edx
  1024b6:	89 e5                	mov    %esp,%ebp
  1024b8:	b8 0f 00 00 00       	mov    $0xf,%eax
  1024bd:	53                   	push   %ebx
  1024be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1024c1:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
  1024c5:	ee                   	out    %al,(%dx)
  1024c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  1024cb:	b2 71                	mov    $0x71,%dl
  1024cd:	ee                   	out    %al,(%dx)
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  wrv[1] = addr >> 4;
  1024ce:	89 c8                	mov    %ecx,%eax
  1024d0:	c1 e8 04             	shr    $0x4,%eax
  1024d3:	66 a3 69 04 00 00    	mov    %ax,0x469
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024d9:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024de:	c1 e3 18             	shl    $0x18,%ebx
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  1024e1:	66 c7 05 67 04 00 00 	movw   $0x0,0x467
  1024e8:	00 00 

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  1024ea:	c1 e9 0c             	shr    $0xc,%ecx
  1024ed:	80 cd 06             	or     $0x6,%ch
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024f0:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  1024f6:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024fb:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024fe:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
  102505:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102508:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10250d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102510:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
  102517:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10251a:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10251f:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102522:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102528:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10252d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102530:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102536:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10253b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10253e:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102544:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102549:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10254c:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102552:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  102557:	5b                   	pop    %ebx
  102558:	5d                   	pop    %ebp

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  102559:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  10255c:	c3                   	ret    
  10255d:	8d 76 00             	lea    0x0(%esi),%esi

00102560 <cpunum>:
  lapicw(TPR, 0);
}

int
cpunum(void)
{
  102560:	55                   	push   %ebp
  102561:	89 e5                	mov    %esp,%ebp
  102563:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  102566:	9c                   	pushf  
  102567:	58                   	pop    %eax
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
  102568:	f6 c4 02             	test   $0x2,%ah
  10256b:	74 12                	je     10257f <cpunum+0x1f>
    static int n;
    if(n++ == 0)
  10256d:	a1 c0 78 10 00       	mov    0x1078c0,%eax
  102572:	8d 50 01             	lea    0x1(%eax),%edx
  102575:	85 c0                	test   %eax,%eax
  102577:	89 15 c0 78 10 00    	mov    %edx,0x1078c0
  10257d:	74 19                	je     102598 <cpunum+0x38>
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if(lapic)
  10257f:	8b 15 f8 ba 10 00    	mov    0x10baf8,%edx
  102585:	31 c0                	xor    %eax,%eax
  102587:	85 d2                	test   %edx,%edx
  102589:	74 06                	je     102591 <cpunum+0x31>
    return lapic[ID]>>24;
  10258b:	8b 42 20             	mov    0x20(%edx),%eax
  10258e:	c1 e8 18             	shr    $0x18,%eax
  return 0;
}
  102591:	c9                   	leave  
  102592:	c3                   	ret    
  102593:	90                   	nop
  102594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
    static int n;
    if(n++ == 0)
      cprintf("cpu called from %x with interrupts enabled\n",
  102598:	8b 45 04             	mov    0x4(%ebp),%eax
  10259b:	c7 04 24 90 6a 10 00 	movl   $0x106a90,(%esp)
  1025a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1025a6:	e8 85 df ff ff       	call   100530 <cprintf>
  1025ab:	eb d2                	jmp    10257f <cpunum+0x1f>
  1025ad:	8d 76 00             	lea    0x0(%esi),%esi

001025b0 <lapicinit>:
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(int c)
{
  1025b0:	55                   	push   %ebp
  1025b1:	89 e5                	mov    %esp,%ebp
  1025b3:	83 ec 18             	sub    $0x18,%esp
  cprintf("lapicinit: %d 0x%x\n", c, lapic);
  1025b6:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025bb:	c7 04 24 bc 6a 10 00 	movl   $0x106abc,(%esp)
  1025c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1025c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1025c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1025cd:	e8 5e df ff ff       	call   100530 <cprintf>
  if(!lapic) 
  1025d2:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025d7:	85 c0                	test   %eax,%eax
  1025d9:	0f 84 0a 01 00 00    	je     1026e9 <lapicinit+0x139>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025df:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
  1025e6:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1025e9:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025ee:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025f1:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
  1025f8:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1025fb:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102600:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102603:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
  10260a:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
  10260d:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102612:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102615:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
  10261c:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
  10261f:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102624:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102627:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
  10262e:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  102631:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102636:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102639:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
  102640:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  102643:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102648:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
  10264b:	8b 50 30             	mov    0x30(%eax),%edx
  10264e:	c1 ea 10             	shr    $0x10,%edx
  102651:	80 fa 03             	cmp    $0x3,%dl
  102654:	0f 87 96 00 00 00    	ja     1026f0 <lapicinit+0x140>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10265a:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
  102661:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102664:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102669:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10266c:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  102673:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102676:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10267b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10267e:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  102685:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102688:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10268d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102690:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  102697:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10269a:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10269f:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026a2:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
  1026a9:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026ac:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026b1:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026b4:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
  1026bb:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
  1026be:	8b 0d f8 ba 10 00    	mov    0x10baf8,%ecx
  1026c4:	8b 41 20             	mov    0x20(%ecx),%eax
  1026c7:	8d 91 00 03 00 00    	lea    0x300(%ecx),%edx
  1026cd:	8d 76 00             	lea    0x0(%esi),%esi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
  1026d0:	8b 02                	mov    (%edx),%eax
  1026d2:	f6 c4 10             	test   $0x10,%ah
  1026d5:	75 f9                	jne    1026d0 <lapicinit+0x120>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026d7:	c7 81 80 00 00 00 00 	movl   $0x0,0x80(%ecx)
  1026de:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026e1:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026e6:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
  1026e9:	c9                   	leave  
  1026ea:	c3                   	ret    
  1026eb:	90                   	nop
  1026ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026f0:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
  1026f7:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  1026fa:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026ff:	8b 50 20             	mov    0x20(%eax),%edx
  102702:	e9 53 ff ff ff       	jmp    10265a <lapicinit+0xaa>
  102707:	90                   	nop
  102708:	90                   	nop
  102709:	90                   	nop
  10270a:	90                   	nop
  10270b:	90                   	nop
  10270c:	90                   	nop
  10270d:	90                   	nop
  10270e:	90                   	nop
  10270f:	90                   	nop

00102710 <mpmain>:
// Common CPU setup code.
// Bootstrap CPU comes here from mainc().
// Other CPUs jump here from bootother.S.
static void
mpmain(void)
{
  102710:	55                   	push   %ebp
  102711:	89 e5                	mov    %esp,%ebp
  102713:	53                   	push   %ebx
  102714:	83 ec 14             	sub    $0x14,%esp
  if(cpunum() != mpbcpu()){
  102717:	e8 44 fe ff ff       	call   102560 <cpunum>
  10271c:	89 c3                	mov    %eax,%ebx
  10271e:	e8 ed 01 00 00       	call   102910 <mpbcpu>
  102723:	39 c3                	cmp    %eax,%ebx
  102725:	74 16                	je     10273d <mpmain+0x2d>
    seginit();
  102727:	e8 34 3e 00 00       	call   106560 <seginit>
  10272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    lapicinit(cpunum());
  102730:	e8 2b fe ff ff       	call   102560 <cpunum>
  102735:	89 04 24             	mov    %eax,(%esp)
  102738:	e8 73 fe ff ff       	call   1025b0 <lapicinit>
  }
  vmenable();        // turn on paging
  10273d:	e8 de 36 00 00       	call   105e20 <vmenable>
  cprintf("cpu%d: starting\n", cpu->id);
  102742:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  102748:	0f b6 00             	movzbl (%eax),%eax
  10274b:	c7 04 24 d0 6a 10 00 	movl   $0x106ad0,(%esp)
  102752:	89 44 24 04          	mov    %eax,0x4(%esp)
  102756:	e8 d5 dd ff ff       	call   100530 <cprintf>
  idtinit();       // load idt register
  10275b:	e8 d0 27 00 00       	call   104f30 <idtinit>
  xchg(&cpu->booted, 1); // tell bootothers() we're up
  102760:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  102767:	b8 01 00 00 00       	mov    $0x1,%eax
  10276c:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler();     // start running processes
  102773:	e8 28 0c 00 00       	call   1033a0 <scheduler>
  102778:	90                   	nop
  102779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102780 <mainc>:

// Set up hardware and software.
// Runs only on the boostrap processor.
void
mainc(void)
{
  102780:	55                   	push   %ebp
  102781:	89 e5                	mov    %esp,%ebp
  102783:	53                   	push   %ebx
  102784:	83 ec 14             	sub    $0x14,%esp
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  102787:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10278d:	0f b6 00             	movzbl (%eax),%eax
  102790:	c7 04 24 e1 6a 10 00 	movl   $0x106ae1,(%esp)
  102797:	89 44 24 04          	mov    %eax,0x4(%esp)
  10279b:	e8 90 dd ff ff       	call   100530 <cprintf>
  picinit();       // interrupt controller
  1027a0:	e8 4b 04 00 00       	call   102bf0 <picinit>
  ioapicinit();    // another interrupt controller
  1027a5:	e8 16 fa ff ff       	call   1021c0 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
  1027aa:	e8 b1 da ff ff       	call   100260 <consoleinit>
  1027af:	90                   	nop
  uartinit();      // serial port
  1027b0:	e8 3b 2b 00 00       	call   1052f0 <uartinit>
  kvmalloc();      // initialize the kernel page table
  1027b5:	e8 e6 38 00 00       	call   1060a0 <kvmalloc>
  pinit();         // process table
  1027ba:	e8 c1 13 00 00       	call   103b80 <pinit>
  1027bf:	90                   	nop
  tvinit();        // trap vectors
  1027c0:	e8 fb 29 00 00       	call   1051c0 <tvinit>
  binit();         // buffer cache
  1027c5:	e8 26 da ff ff       	call   1001f0 <binit>
  fileinit();      // file table
  1027ca:	e8 b1 e8 ff ff       	call   101080 <fileinit>
  1027cf:	90                   	nop
  iinit();         // inode cache
  1027d0:	e8 cb f6 ff ff       	call   101ea0 <iinit>
  ideinit();       // disk
  1027d5:	e8 06 f9 ff ff       	call   1020e0 <ideinit>
  if(!ismp)
  1027da:	a1 04 bb 10 00       	mov    0x10bb04,%eax
  1027df:	85 c0                	test   %eax,%eax
  1027e1:	0f 84 ae 00 00 00    	je     102895 <mainc+0x115>
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  1027e7:	e8 a4 12 00 00       	call   103a90 <userinit>

  // Write bootstrap code to unused memory at 0x7000.
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);
  1027ec:	c7 44 24 08 6a 00 00 	movl   $0x6a,0x8(%esp)
  1027f3:	00 
  1027f4:	c7 44 24 04 9c 77 10 	movl   $0x10779c,0x4(%esp)
  1027fb:	00 
  1027fc:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
  102803:	e8 48 16 00 00       	call   103e50 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
  102808:	69 05 00 c1 10 00 bc 	imul   $0xbc,0x10c100,%eax
  10280f:	00 00 00 
  102812:	05 20 bb 10 00       	add    $0x10bb20,%eax
  102817:	3d 20 bb 10 00       	cmp    $0x10bb20,%eax
  10281c:	76 6d                	jbe    10288b <mainc+0x10b>
  10281e:	bb 20 bb 10 00       	mov    $0x10bb20,%ebx
  102823:	90                   	nop
  102824:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(c == cpus+cpunum())  // We've started already.
  102828:	e8 33 fd ff ff       	call   102560 <cpunum>
  10282d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  102833:	05 20 bb 10 00       	add    $0x10bb20,%eax
  102838:	39 d8                	cmp    %ebx,%eax
  10283a:	74 36                	je     102872 <mainc+0xf2>
      continue;

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
  10283c:	e8 3f fa ff ff       	call   102280 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpmain;
  102841:	c7 05 f8 6f 00 00 10 	movl   $0x102710,0x6ff8
  102848:	27 10 00 

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
    *(void**)(code-4) = stack + KSTACKSIZE;
  10284b:	05 00 10 00 00       	add    $0x1000,%eax
  102850:	a3 fc 6f 00 00       	mov    %eax,0x6ffc
    *(void**)(code-8) = mpmain;

    lapicstartap(c->id, (uint)code);
  102855:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
  10285c:	00 
  10285d:	0f b6 03             	movzbl (%ebx),%eax
  102860:	89 04 24             	mov    %eax,(%esp)
  102863:	e8 48 fc ff ff       	call   1024b0 <lapicstartap>

    // Wait for cpu to finish mpmain()
    while(c->booted == 0)
  102868:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
  10286e:	85 c0                	test   %eax,%eax
  102870:	74 f6                	je     102868 <mainc+0xe8>
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);

  for(c = cpus; c < cpus+ncpu; c++){
  102872:	69 05 00 c1 10 00 bc 	imul   $0xbc,0x10c100,%eax
  102879:	00 00 00 
  10287c:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
  102882:	05 20 bb 10 00       	add    $0x10bb20,%eax
  102887:	39 c3                	cmp    %eax,%ebx
  102889:	72 9d                	jb     102828 <mainc+0xa8>
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
}
  10288b:	83 c4 14             	add    $0x14,%esp
  10288e:	5b                   	pop    %ebx
  10288f:	5d                   	pop    %ebp
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
  102890:	e9 7b fe ff ff       	jmp    102710 <mpmain>
  binit();         // buffer cache
  fileinit();      // file table
  iinit();         // inode cache
  ideinit();       // disk
  if(!ismp)
    timerinit();   // uniprocessor timer
  102895:	e8 36 26 00 00       	call   104ed0 <timerinit>
  10289a:	e9 48 ff ff ff       	jmp    1027e7 <mainc+0x67>
  10289f:	90                   	nop

001028a0 <jmpkstack>:
  jmpkstack();       // call mainc() on a properly-allocated stack 
}

void
jmpkstack(void)
{
  1028a0:	55                   	push   %ebp
  1028a1:	89 e5                	mov    %esp,%ebp
  1028a3:	83 ec 18             	sub    $0x18,%esp
  char *kstack, *top;
  
  kstack = kalloc();
  1028a6:	e8 d5 f9 ff ff       	call   102280 <kalloc>
  if(kstack == 0)
  1028ab:	85 c0                	test   %eax,%eax
  1028ad:	74 19                	je     1028c8 <jmpkstack+0x28>
    panic("jmpkstack kalloc");
  top = kstack + PGSIZE;
  asm volatile("movl %0,%%esp; call mainc" : : "r" (top));
  1028af:	05 00 10 00 00       	add    $0x1000,%eax
  1028b4:	89 c4                	mov    %eax,%esp
  1028b6:	e8 c5 fe ff ff       	call   102780 <mainc>
  panic("jmpkstack");
  1028bb:	c7 04 24 09 6b 10 00 	movl   $0x106b09,(%esp)
  1028c2:	e8 59 e0 ff ff       	call   100920 <panic>
  1028c7:	90                   	nop
{
  char *kstack, *top;
  
  kstack = kalloc();
  if(kstack == 0)
    panic("jmpkstack kalloc");
  1028c8:	c7 04 24 f8 6a 10 00 	movl   $0x106af8,(%esp)
  1028cf:	e8 4c e0 ff ff       	call   100920 <panic>
  1028d4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1028da:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001028e0 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
  1028e0:	55                   	push   %ebp
  1028e1:	89 e5                	mov    %esp,%ebp
  1028e3:	83 e4 f0             	and    $0xfffffff0,%esp
  1028e6:	83 ec 10             	sub    $0x10,%esp
  mpinit();        // collect info about this machine
  1028e9:	e8 b2 00 00 00       	call   1029a0 <mpinit>
  lapicinit(mpbcpu());
  1028ee:	e8 1d 00 00 00       	call   102910 <mpbcpu>
  1028f3:	89 04 24             	mov    %eax,(%esp)
  1028f6:	e8 b5 fc ff ff       	call   1025b0 <lapicinit>
  seginit();       // set up segments
  1028fb:	e8 60 3c 00 00       	call   106560 <seginit>
  kinit();         // initialize memory allocator
  102900:	e8 2b fa ff ff       	call   102330 <kinit>
  jmpkstack();       // call mainc() on a properly-allocated stack 
  102905:	e8 96 ff ff ff       	call   1028a0 <jmpkstack>
  10290a:	90                   	nop
  10290b:	90                   	nop
  10290c:	90                   	nop
  10290d:	90                   	nop
  10290e:	90                   	nop
  10290f:	90                   	nop

00102910 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  102910:	a1 c4 78 10 00       	mov    0x1078c4,%eax
  102915:	55                   	push   %ebp
  102916:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
}
  102918:	5d                   	pop    %ebp
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  102919:	2d 20 bb 10 00       	sub    $0x10bb20,%eax
  10291e:	c1 f8 02             	sar    $0x2,%eax
  102921:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
  return bcpu-cpus;
}
  102927:	c3                   	ret    
  102928:	90                   	nop
  102929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102930 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102930:	55                   	push   %ebp
  102931:	89 e5                	mov    %esp,%ebp
  102933:	56                   	push   %esi
  102934:	53                   	push   %ebx
  uchar *e, *p;

  e = addr+len;
  102935:	8d 34 10             	lea    (%eax,%edx,1),%esi
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102938:	83 ec 10             	sub    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  10293b:	39 f0                	cmp    %esi,%eax
  10293d:	73 42                	jae    102981 <mpsearch1+0x51>
  10293f:	89 c3                	mov    %eax,%ebx
  102941:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  102948:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  10294f:	00 
  102950:	c7 44 24 04 13 6b 10 	movl   $0x106b13,0x4(%esp)
  102957:	00 
  102958:	89 1c 24             	mov    %ebx,(%esp)
  10295b:	e8 90 14 00 00       	call   103df0 <memcmp>
  102960:	85 c0                	test   %eax,%eax
  102962:	75 16                	jne    10297a <mpsearch1+0x4a>
  102964:	31 d2                	xor    %edx,%edx
  102966:	66 90                	xchg   %ax,%ax
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
  102968:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  10296c:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  10296f:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102971:	83 f8 10             	cmp    $0x10,%eax
  102974:	75 f2                	jne    102968 <mpsearch1+0x38>
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  102976:	84 d2                	test   %dl,%dl
  102978:	74 10                	je     10298a <mpsearch1+0x5a>
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  10297a:	83 c3 10             	add    $0x10,%ebx
  10297d:	39 de                	cmp    %ebx,%esi
  10297f:	77 c7                	ja     102948 <mpsearch1+0x18>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  102981:	83 c4 10             	add    $0x10,%esp
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  102984:	31 c0                	xor    %eax,%eax
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  102986:	5b                   	pop    %ebx
  102987:	5e                   	pop    %esi
  102988:	5d                   	pop    %ebp
  102989:	c3                   	ret    
  10298a:	83 c4 10             	add    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  10298d:	89 d8                	mov    %ebx,%eax
  return 0;
}
  10298f:	5b                   	pop    %ebx
  102990:	5e                   	pop    %esi
  102991:	5d                   	pop    %ebp
  102992:	c3                   	ret    
  102993:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  102999:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001029a0 <mpinit>:
  return conf;
}

void
mpinit(void)
{
  1029a0:	55                   	push   %ebp
  1029a1:	89 e5                	mov    %esp,%ebp
  1029a3:	57                   	push   %edi
  1029a4:	56                   	push   %esi
  1029a5:	53                   	push   %ebx
  1029a6:	83 ec 1c             	sub    $0x1c,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  1029a9:	0f b6 05 0f 04 00 00 	movzbl 0x40f,%eax
  1029b0:	0f b6 15 0e 04 00 00 	movzbl 0x40e,%edx
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  1029b7:	c7 05 c4 78 10 00 20 	movl   $0x10bb20,0x1078c4
  1029be:	bb 10 00 
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  1029c1:	c1 e0 08             	shl    $0x8,%eax
  1029c4:	09 d0                	or     %edx,%eax
  1029c6:	c1 e0 04             	shl    $0x4,%eax
  1029c9:	85 c0                	test   %eax,%eax
  1029cb:	75 1b                	jne    1029e8 <mpinit+0x48>
    if((mp = mpsearch1((uchar*)p, 1024)))
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
  1029cd:	0f b6 05 14 04 00 00 	movzbl 0x414,%eax
  1029d4:	0f b6 15 13 04 00 00 	movzbl 0x413,%edx
  1029db:	c1 e0 08             	shl    $0x8,%eax
  1029de:	09 d0                	or     %edx,%eax
  1029e0:	c1 e0 0a             	shl    $0xa,%eax
  1029e3:	2d 00 04 00 00       	sub    $0x400,%eax
  1029e8:	ba 00 04 00 00       	mov    $0x400,%edx
  1029ed:	e8 3e ff ff ff       	call   102930 <mpsearch1>
  1029f2:	85 c0                	test   %eax,%eax
  1029f4:	89 c6                	mov    %eax,%esi
  1029f6:	0f 84 94 01 00 00    	je     102b90 <mpinit+0x1f0>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  1029fc:	8b 5e 04             	mov    0x4(%esi),%ebx
  1029ff:	85 db                	test   %ebx,%ebx
  102a01:	74 1c                	je     102a1f <mpinit+0x7f>
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
  102a03:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  102a0a:	00 
  102a0b:	c7 44 24 04 18 6b 10 	movl   $0x106b18,0x4(%esp)
  102a12:	00 
  102a13:	89 1c 24             	mov    %ebx,(%esp)
  102a16:	e8 d5 13 00 00       	call   103df0 <memcmp>
  102a1b:	85 c0                	test   %eax,%eax
  102a1d:	74 09                	je     102a28 <mpinit+0x88>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102a1f:	83 c4 1c             	add    $0x1c,%esp
  102a22:	5b                   	pop    %ebx
  102a23:	5e                   	pop    %esi
  102a24:	5f                   	pop    %edi
  102a25:	5d                   	pop    %ebp
  102a26:	c3                   	ret    
  102a27:	90                   	nop
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
  102a28:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
  102a2c:	3c 04                	cmp    $0x4,%al
  102a2e:	74 04                	je     102a34 <mpinit+0x94>
  102a30:	3c 01                	cmp    $0x1,%al
  102a32:	75 eb                	jne    102a1f <mpinit+0x7f>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102a34:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a38:	85 ff                	test   %edi,%edi
  102a3a:	74 15                	je     102a51 <mpinit+0xb1>
  102a3c:	31 d2                	xor    %edx,%edx
  102a3e:	31 c0                	xor    %eax,%eax
    sum += addr[i];
  102a40:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a44:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  102a47:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a49:	39 c7                	cmp    %eax,%edi
  102a4b:	7f f3                	jg     102a40 <mpinit+0xa0>
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102a4d:	84 d2                	test   %dl,%dl
  102a4f:	75 ce                	jne    102a1f <mpinit+0x7f>
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  102a51:	c7 05 04 bb 10 00 01 	movl   $0x1,0x10bb04
  102a58:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
  102a5b:	8b 43 24             	mov    0x24(%ebx),%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a5e:	8d 7b 2c             	lea    0x2c(%ebx),%edi

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  102a61:	a3 f8 ba 10 00       	mov    %eax,0x10baf8
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a66:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
  102a6a:	01 c3                	add    %eax,%ebx
  102a6c:	39 df                	cmp    %ebx,%edi
  102a6e:	72 29                	jb     102a99 <mpinit+0xf9>
  102a70:	eb 52                	jmp    102ac4 <mpinit+0x124>
  102a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case MPIOINTR:
    case MPLINTR:
      p += 8;
      continue;
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
  102a78:	0f b6 c0             	movzbl %al,%eax
  102a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102a7f:	c7 04 24 38 6b 10 00 	movl   $0x106b38,(%esp)
  102a86:	e8 a5 da ff ff       	call   100530 <cprintf>
      ismp = 0;
  102a8b:	c7 05 04 bb 10 00 00 	movl   $0x0,0x10bb04
  102a92:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a95:	39 fb                	cmp    %edi,%ebx
  102a97:	76 1e                	jbe    102ab7 <mpinit+0x117>
    switch(*p){
  102a99:	0f b6 07             	movzbl (%edi),%eax
  102a9c:	3c 04                	cmp    $0x4,%al
  102a9e:	77 d8                	ja     102a78 <mpinit+0xd8>
  102aa0:	0f b6 c0             	movzbl %al,%eax
  102aa3:	ff 24 85 58 6b 10 00 	jmp    *0x106b58(,%eax,4)
  102aaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
  102ab0:	83 c7 08             	add    $0x8,%edi
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102ab3:	39 fb                	cmp    %edi,%ebx
  102ab5:	77 e2                	ja     102a99 <mpinit+0xf9>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
  102ab7:	a1 04 bb 10 00       	mov    0x10bb04,%eax
  102abc:	85 c0                	test   %eax,%eax
  102abe:	0f 84 a4 00 00 00    	je     102b68 <mpinit+0x1c8>
    lapic = 0;
    ioapicid = 0;
    return;
  }

  if(mp->imcrp){
  102ac4:	80 7e 0c 00          	cmpb   $0x0,0xc(%esi)
  102ac8:	0f 84 51 ff ff ff    	je     102a1f <mpinit+0x7f>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102ace:	ba 22 00 00 00       	mov    $0x22,%edx
  102ad3:	b8 70 00 00 00       	mov    $0x70,%eax
  102ad8:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102ad9:	b2 23                	mov    $0x23,%dl
  102adb:	ec                   	in     (%dx),%al
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102adc:	83 c8 01             	or     $0x1,%eax
  102adf:	ee                   	out    %al,(%dx)
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102ae0:	83 c4 1c             	add    $0x1c,%esp
  102ae3:	5b                   	pop    %ebx
  102ae4:	5e                   	pop    %esi
  102ae5:	5f                   	pop    %edi
  102ae6:	5d                   	pop    %ebp
  102ae7:	c3                   	ret    
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu != proc->apicid){
  102ae8:	0f b6 57 01          	movzbl 0x1(%edi),%edx
  102aec:	a1 00 c1 10 00       	mov    0x10c100,%eax
  102af1:	39 c2                	cmp    %eax,%edx
  102af3:	74 23                	je     102b18 <mpinit+0x178>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
  102af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  102af9:	89 54 24 08          	mov    %edx,0x8(%esp)
  102afd:	c7 04 24 1d 6b 10 00 	movl   $0x106b1d,(%esp)
  102b04:	e8 27 da ff ff       	call   100530 <cprintf>
        ismp = 0;
  102b09:	a1 00 c1 10 00       	mov    0x10c100,%eax
  102b0e:	c7 05 04 bb 10 00 00 	movl   $0x0,0x10bb04
  102b15:	00 00 00 
      }
      if(proc->flags & MPBOOT)
  102b18:	f6 47 03 02          	testb  $0x2,0x3(%edi)
  102b1c:	74 12                	je     102b30 <mpinit+0x190>
        bcpu = &cpus[ncpu];
  102b1e:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
  102b24:	81 c2 20 bb 10 00    	add    $0x10bb20,%edx
  102b2a:	89 15 c4 78 10 00    	mov    %edx,0x1078c4
      cpus[ncpu].id = ncpu;
  102b30:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
      ncpu++;
      p += sizeof(struct mpproc);
  102b36:	83 c7 14             	add    $0x14,%edi
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
        ismp = 0;
      }
      if(proc->flags & MPBOOT)
        bcpu = &cpus[ncpu];
      cpus[ncpu].id = ncpu;
  102b39:	88 82 20 bb 10 00    	mov    %al,0x10bb20(%edx)
      ncpu++;
  102b3f:	83 c0 01             	add    $0x1,%eax
  102b42:	a3 00 c1 10 00       	mov    %eax,0x10c100
      p += sizeof(struct mpproc);
      continue;
  102b47:	e9 49 ff ff ff       	jmp    102a95 <mpinit+0xf5>
  102b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102b50:	0f b6 47 01          	movzbl 0x1(%edi),%eax
      p += sizeof(struct mpioapic);
  102b54:	83 c7 08             	add    $0x8,%edi
      ncpu++;
      p += sizeof(struct mpproc);
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102b57:	a2 00 bb 10 00       	mov    %al,0x10bb00
      p += sizeof(struct mpioapic);
      continue;
  102b5c:	e9 34 ff ff ff       	jmp    102a95 <mpinit+0xf5>
  102b61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ismp = 0;
    }
  }
  if(!ismp){
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
  102b68:	c7 05 00 c1 10 00 01 	movl   $0x1,0x10c100
  102b6f:	00 00 00 
    lapic = 0;
  102b72:	c7 05 f8 ba 10 00 00 	movl   $0x0,0x10baf8
  102b79:	00 00 00 
    ioapicid = 0;
  102b7c:	c6 05 00 bb 10 00 00 	movb   $0x0,0x10bb00
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102b83:	83 c4 1c             	add    $0x1c,%esp
  102b86:	5b                   	pop    %ebx
  102b87:	5e                   	pop    %esi
  102b88:	5f                   	pop    %edi
  102b89:	5d                   	pop    %ebp
  102b8a:	c3                   	ret    
  102b8b:	90                   	nop
  102b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102b90:	ba 00 00 01 00       	mov    $0x10000,%edx
  102b95:	b8 00 00 0f 00       	mov    $0xf0000,%eax
  102b9a:	e8 91 fd ff ff       	call   102930 <mpsearch1>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102b9f:	85 c0                	test   %eax,%eax
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102ba1:	89 c6                	mov    %eax,%esi
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102ba3:	0f 85 53 fe ff ff    	jne    1029fc <mpinit+0x5c>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102ba9:	83 c4 1c             	add    $0x1c,%esp
  102bac:	5b                   	pop    %ebx
  102bad:	5e                   	pop    %esi
  102bae:	5f                   	pop    %edi
  102baf:	5d                   	pop    %ebp
  102bb0:	c3                   	ret    
  102bb1:	90                   	nop
  102bb2:	90                   	nop
  102bb3:	90                   	nop
  102bb4:	90                   	nop
  102bb5:	90                   	nop
  102bb6:	90                   	nop
  102bb7:	90                   	nop
  102bb8:	90                   	nop
  102bb9:	90                   	nop
  102bba:	90                   	nop
  102bbb:	90                   	nop
  102bbc:	90                   	nop
  102bbd:	90                   	nop
  102bbe:	90                   	nop
  102bbf:	90                   	nop

00102bc0 <picenable>:
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102bc0:	55                   	push   %ebp
  picsetmask(irqmask & ~(1<<irq));
  102bc1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102bc6:	89 e5                	mov    %esp,%ebp
  102bc8:	ba 21 00 00 00       	mov    $0x21,%edx
  picsetmask(irqmask & ~(1<<irq));
  102bcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102bd0:	d3 c0                	rol    %cl,%eax
  102bd2:	66 23 05 20 73 10 00 	and    0x107320,%ax
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
  irqmask = mask;
  102bd9:	66 a3 20 73 10 00    	mov    %ax,0x107320
  102bdf:	ee                   	out    %al,(%dx)
  102be0:	66 c1 e8 08          	shr    $0x8,%ax
  102be4:	b2 a1                	mov    $0xa1,%dl
  102be6:	ee                   	out    %al,(%dx)

void
picenable(int irq)
{
  picsetmask(irqmask & ~(1<<irq));
}
  102be7:	5d                   	pop    %ebp
  102be8:	c3                   	ret    
  102be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102bf0 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
  102bf0:	55                   	push   %ebp
  102bf1:	b9 21 00 00 00       	mov    $0x21,%ecx
  102bf6:	89 e5                	mov    %esp,%ebp
  102bf8:	83 ec 0c             	sub    $0xc,%esp
  102bfb:	89 1c 24             	mov    %ebx,(%esp)
  102bfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102c03:	89 ca                	mov    %ecx,%edx
  102c05:	89 74 24 04          	mov    %esi,0x4(%esp)
  102c09:	89 7c 24 08          	mov    %edi,0x8(%esp)
  102c0d:	ee                   	out    %al,(%dx)
  102c0e:	bb a1 00 00 00       	mov    $0xa1,%ebx
  102c13:	89 da                	mov    %ebx,%edx
  102c15:	ee                   	out    %al,(%dx)
  102c16:	be 11 00 00 00       	mov    $0x11,%esi
  102c1b:	b2 20                	mov    $0x20,%dl
  102c1d:	89 f0                	mov    %esi,%eax
  102c1f:	ee                   	out    %al,(%dx)
  102c20:	b8 20 00 00 00       	mov    $0x20,%eax
  102c25:	89 ca                	mov    %ecx,%edx
  102c27:	ee                   	out    %al,(%dx)
  102c28:	b8 04 00 00 00       	mov    $0x4,%eax
  102c2d:	ee                   	out    %al,(%dx)
  102c2e:	bf 03 00 00 00       	mov    $0x3,%edi
  102c33:	89 f8                	mov    %edi,%eax
  102c35:	ee                   	out    %al,(%dx)
  102c36:	b1 a0                	mov    $0xa0,%cl
  102c38:	89 f0                	mov    %esi,%eax
  102c3a:	89 ca                	mov    %ecx,%edx
  102c3c:	ee                   	out    %al,(%dx)
  102c3d:	b8 28 00 00 00       	mov    $0x28,%eax
  102c42:	89 da                	mov    %ebx,%edx
  102c44:	ee                   	out    %al,(%dx)
  102c45:	b8 02 00 00 00       	mov    $0x2,%eax
  102c4a:	ee                   	out    %al,(%dx)
  102c4b:	89 f8                	mov    %edi,%eax
  102c4d:	ee                   	out    %al,(%dx)
  102c4e:	be 68 00 00 00       	mov    $0x68,%esi
  102c53:	b2 20                	mov    $0x20,%dl
  102c55:	89 f0                	mov    %esi,%eax
  102c57:	ee                   	out    %al,(%dx)
  102c58:	bb 0a 00 00 00       	mov    $0xa,%ebx
  102c5d:	89 d8                	mov    %ebx,%eax
  102c5f:	ee                   	out    %al,(%dx)
  102c60:	89 f0                	mov    %esi,%eax
  102c62:	89 ca                	mov    %ecx,%edx
  102c64:	ee                   	out    %al,(%dx)
  102c65:	89 d8                	mov    %ebx,%eax
  102c67:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);             // read IRR by default

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
  102c68:	0f b7 05 20 73 10 00 	movzwl 0x107320,%eax
  102c6f:	66 83 f8 ff          	cmp    $0xffffffff,%ax
  102c73:	74 0a                	je     102c7f <picinit+0x8f>
  102c75:	b2 21                	mov    $0x21,%dl
  102c77:	ee                   	out    %al,(%dx)
  102c78:	66 c1 e8 08          	shr    $0x8,%ax
  102c7c:	b2 a1                	mov    $0xa1,%dl
  102c7e:	ee                   	out    %al,(%dx)
    picsetmask(irqmask);
}
  102c7f:	8b 1c 24             	mov    (%esp),%ebx
  102c82:	8b 74 24 04          	mov    0x4(%esp),%esi
  102c86:	8b 7c 24 08          	mov    0x8(%esp),%edi
  102c8a:	89 ec                	mov    %ebp,%esp
  102c8c:	5d                   	pop    %ebp
  102c8d:	c3                   	ret    
  102c8e:	90                   	nop
  102c8f:	90                   	nop

00102c90 <piperead>:
  return n;
}

int
piperead(struct pipe *p, char *addr, int n)
{
  102c90:	55                   	push   %ebp
  102c91:	89 e5                	mov    %esp,%ebp
  102c93:	57                   	push   %edi
  102c94:	56                   	push   %esi
  102c95:	53                   	push   %ebx
  102c96:	83 ec 1c             	sub    $0x1c,%esp
  102c99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102c9c:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  acquire(&p->lock);
  102c9f:	89 1c 24             	mov    %ebx,(%esp)
  102ca2:	e8 89 10 00 00       	call   103d30 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102ca7:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102cad:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102cb3:	75 58                	jne    102d0d <piperead+0x7d>
  102cb5:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102cbb:	85 f6                	test   %esi,%esi
  102cbd:	74 4e                	je     102d0d <piperead+0x7d>
    if(proc->killed){
  102cbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102cc5:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
  102ccb:	8b 48 24             	mov    0x24(%eax),%ecx
  102cce:	85 c9                	test   %ecx,%ecx
  102cd0:	74 21                	je     102cf3 <piperead+0x63>
  102cd2:	e9 99 00 00 00       	jmp    102d70 <piperead+0xe0>
  102cd7:	90                   	nop
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102cd8:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
  102cde:	85 c0                	test   %eax,%eax
  102ce0:	74 2b                	je     102d0d <piperead+0x7d>
    if(proc->killed){
  102ce2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102ce8:	8b 50 24             	mov    0x24(%eax),%edx
  102ceb:	85 d2                	test   %edx,%edx
  102ced:	0f 85 7d 00 00 00    	jne    102d70 <piperead+0xe0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102cf3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102cf7:	89 34 24             	mov    %esi,(%esp)
  102cfa:	e8 91 05 00 00       	call   103290 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102cff:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102d05:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102d0b:	74 cb                	je     102cd8 <piperead+0x48>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d0d:	85 ff                	test   %edi,%edi
  102d0f:	7e 76                	jle    102d87 <piperead+0xf7>
    if(p->nread == p->nwrite)
  102d11:	31 f6                	xor    %esi,%esi
  102d13:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102d19:	75 0d                	jne    102d28 <piperead+0x98>
  102d1b:	eb 6a                	jmp    102d87 <piperead+0xf7>
  102d1d:	8d 76 00             	lea    0x0(%esi),%esi
  102d20:	39 93 38 02 00 00    	cmp    %edx,0x238(%ebx)
  102d26:	74 22                	je     102d4a <piperead+0xba>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102d28:	89 d0                	mov    %edx,%eax
  102d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  102d2d:	83 c2 01             	add    $0x1,%edx
  102d30:	25 ff 01 00 00       	and    $0x1ff,%eax
  102d35:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
  102d3a:	88 04 31             	mov    %al,(%ecx,%esi,1)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d3d:	83 c6 01             	add    $0x1,%esi
  102d40:	39 f7                	cmp    %esi,%edi
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102d42:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d48:	7f d6                	jg     102d20 <piperead+0x90>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  102d4a:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  102d50:	89 04 24             	mov    %eax,(%esp)
  102d53:	e8 08 04 00 00       	call   103160 <wakeup>
  release(&p->lock);
  102d58:	89 1c 24             	mov    %ebx,(%esp)
  102d5b:	e8 80 0f 00 00       	call   103ce0 <release>
  return i;
}
  102d60:	83 c4 1c             	add    $0x1c,%esp
  102d63:	89 f0                	mov    %esi,%eax
  102d65:	5b                   	pop    %ebx
  102d66:	5e                   	pop    %esi
  102d67:	5f                   	pop    %edi
  102d68:	5d                   	pop    %ebp
  102d69:	c3                   	ret    
  102d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
      release(&p->lock);
  102d70:	be ff ff ff ff       	mov    $0xffffffff,%esi
  102d75:	89 1c 24             	mov    %ebx,(%esp)
  102d78:	e8 63 0f 00 00       	call   103ce0 <release>
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
  102d7d:	83 c4 1c             	add    $0x1c,%esp
  102d80:	89 f0                	mov    %esi,%eax
  102d82:	5b                   	pop    %ebx
  102d83:	5e                   	pop    %esi
  102d84:	5f                   	pop    %edi
  102d85:	5d                   	pop    %ebp
  102d86:	c3                   	ret    
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d87:	31 f6                	xor    %esi,%esi
  102d89:	eb bf                	jmp    102d4a <piperead+0xba>
  102d8b:	90                   	nop
  102d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00102d90 <pipewrite>:
    release(&p->lock);
}

int
pipewrite(struct pipe *p, char *addr, int n)
{
  102d90:	55                   	push   %ebp
  102d91:	89 e5                	mov    %esp,%ebp
  102d93:	57                   	push   %edi
  102d94:	56                   	push   %esi
  102d95:	53                   	push   %ebx
  102d96:	83 ec 3c             	sub    $0x3c,%esp
  102d99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
  102d9c:	89 1c 24             	mov    %ebx,(%esp)
  102d9f:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
  102da5:	e8 86 0f 00 00       	call   103d30 <acquire>
  for(i = 0; i < n; i++){
  102daa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  102dad:	85 c9                	test   %ecx,%ecx
  102daf:	0f 8e 8d 00 00 00    	jle    102e42 <pipewrite+0xb2>
  102db5:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102dbb:	8d bb 38 02 00 00    	lea    0x238(%ebx),%edi
  102dc1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  102dc8:	eb 37                	jmp    102e01 <pipewrite+0x71>
  102dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
  102dd0:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102dd6:	85 c0                	test   %eax,%eax
  102dd8:	74 7e                	je     102e58 <pipewrite+0xc8>
  102dda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102de0:	8b 50 24             	mov    0x24(%eax),%edx
  102de3:	85 d2                	test   %edx,%edx
  102de5:	75 71                	jne    102e58 <pipewrite+0xc8>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
  102de7:	89 34 24             	mov    %esi,(%esp)
  102dea:	e8 71 03 00 00       	call   103160 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102def:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102df3:	89 3c 24             	mov    %edi,(%esp)
  102df6:	e8 95 04 00 00       	call   103290 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
  102dfb:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
  102e01:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102e07:	81 c2 00 02 00 00    	add    $0x200,%edx
  102e0d:	39 d0                	cmp    %edx,%eax
  102e0f:	74 bf                	je     102dd0 <pipewrite+0x40>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  102e11:	89 c2                	mov    %eax,%edx
  102e13:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102e16:	83 c0 01             	add    $0x1,%eax
  102e19:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  102e1f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e22:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e25:	0f b6 0c 0a          	movzbl (%edx,%ecx,1),%ecx
  102e29:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e2c:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
  102e30:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
  102e36:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  102e3a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102e3d:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  102e40:	7f bf                	jg     102e01 <pipewrite+0x71>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  102e42:	89 34 24             	mov    %esi,(%esp)
  102e45:	e8 16 03 00 00       	call   103160 <wakeup>
  release(&p->lock);
  102e4a:	89 1c 24             	mov    %ebx,(%esp)
  102e4d:	e8 8e 0e 00 00       	call   103ce0 <release>
  return n;
  102e52:	eb 13                	jmp    102e67 <pipewrite+0xd7>
  102e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
  102e58:	89 1c 24             	mov    %ebx,(%esp)
  102e5b:	e8 80 0e 00 00       	call   103ce0 <release>
  102e60:	c7 45 10 ff ff ff ff 	movl   $0xffffffff,0x10(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
  102e67:	8b 45 10             	mov    0x10(%ebp),%eax
  102e6a:	83 c4 3c             	add    $0x3c,%esp
  102e6d:	5b                   	pop    %ebx
  102e6e:	5e                   	pop    %esi
  102e6f:	5f                   	pop    %edi
  102e70:	5d                   	pop    %ebp
  102e71:	c3                   	ret    
  102e72:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  102e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102e80 <pipeclose>:
  return -1;
}

void
pipeclose(struct pipe *p, int writable)
{
  102e80:	55                   	push   %ebp
  102e81:	89 e5                	mov    %esp,%ebp
  102e83:	83 ec 18             	sub    $0x18,%esp
  102e86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  102e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102e8c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  102e8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
  102e92:	89 1c 24             	mov    %ebx,(%esp)
  102e95:	e8 96 0e 00 00       	call   103d30 <acquire>
  if(writable){
  102e9a:	85 f6                	test   %esi,%esi
  102e9c:	74 42                	je     102ee0 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
  102e9e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
void
pipeclose(struct pipe *p, int writable)
{
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
  102ea4:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
  102eab:	00 00 00 
    wakeup(&p->nread);
  102eae:	89 04 24             	mov    %eax,(%esp)
  102eb1:	e8 aa 02 00 00       	call   103160 <wakeup>
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
  102eb6:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102ebc:	85 c0                	test   %eax,%eax
  102ebe:	75 0a                	jne    102eca <pipeclose+0x4a>
  102ec0:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102ec6:	85 f6                	test   %esi,%esi
  102ec8:	74 36                	je     102f00 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102eca:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  102ecd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  102ed0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102ed3:	89 ec                	mov    %ebp,%esp
  102ed5:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102ed6:	e9 05 0e 00 00       	jmp    103ce0 <release>
  102edb:	90                   	nop
  102edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  102ee0:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
  102ee6:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
  102eed:	00 00 00 
    wakeup(&p->nwrite);
  102ef0:	89 04 24             	mov    %eax,(%esp)
  102ef3:	e8 68 02 00 00       	call   103160 <wakeup>
  102ef8:	eb bc                	jmp    102eb6 <pipeclose+0x36>
  102efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
  102f00:	89 1c 24             	mov    %ebx,(%esp)
  102f03:	e8 d8 0d 00 00       	call   103ce0 <release>
    kfree((char*)p);
  } else
    release(&p->lock);
}
  102f08:	8b 75 fc             	mov    -0x4(%ebp),%esi
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102f0b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  } else
    release(&p->lock);
}
  102f0e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102f11:	89 ec                	mov    %ebp,%esp
  102f13:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102f14:	e9 a7 f3 ff ff       	jmp    1022c0 <kfree>
  102f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102f20 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
  102f20:	55                   	push   %ebp
  102f21:	89 e5                	mov    %esp,%ebp
  102f23:	57                   	push   %edi
  102f24:	56                   	push   %esi
  102f25:	53                   	push   %ebx
  102f26:	83 ec 1c             	sub    $0x1c,%esp
  102f29:	8b 75 08             	mov    0x8(%ebp),%esi
  102f2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
  102f2f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  102f35:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
  102f3b:	e8 e0 df ff ff       	call   100f20 <filealloc>
  102f40:	85 c0                	test   %eax,%eax
  102f42:	89 06                	mov    %eax,(%esi)
  102f44:	0f 84 9c 00 00 00    	je     102fe6 <pipealloc+0xc6>
  102f4a:	e8 d1 df ff ff       	call   100f20 <filealloc>
  102f4f:	85 c0                	test   %eax,%eax
  102f51:	89 03                	mov    %eax,(%ebx)
  102f53:	0f 84 7f 00 00 00    	je     102fd8 <pipealloc+0xb8>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
  102f59:	e8 22 f3 ff ff       	call   102280 <kalloc>
  102f5e:	85 c0                	test   %eax,%eax
  102f60:	89 c7                	mov    %eax,%edi
  102f62:	74 74                	je     102fd8 <pipealloc+0xb8>
    goto bad;
  p->readopen = 1;
  102f64:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
  102f6b:	00 00 00 
  p->writeopen = 1;
  102f6e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
  102f75:	00 00 00 
  p->nwrite = 0;
  102f78:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
  102f7f:	00 00 00 
  p->nread = 0;
  102f82:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
  102f89:	00 00 00 
  initlock(&p->lock, "pipe");
  102f8c:	89 04 24             	mov    %eax,(%esp)
  102f8f:	c7 44 24 04 6c 6b 10 	movl   $0x106b6c,0x4(%esp)
  102f96:	00 
  102f97:	e8 04 0c 00 00       	call   103ba0 <initlock>
  (*f0)->type = FD_PIPE;
  102f9c:	8b 06                	mov    (%esi),%eax
  102f9e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
  102fa4:	8b 06                	mov    (%esi),%eax
  102fa6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
  102faa:	8b 06                	mov    (%esi),%eax
  102fac:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
  102fb0:	8b 06                	mov    (%esi),%eax
  102fb2:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
  102fb5:	8b 03                	mov    (%ebx),%eax
  102fb7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
  102fbd:	8b 03                	mov    (%ebx),%eax
  102fbf:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
  102fc3:	8b 03                	mov    (%ebx),%eax
  102fc5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
  102fc9:	8b 03                	mov    (%ebx),%eax
  102fcb:	89 78 0c             	mov    %edi,0xc(%eax)
  102fce:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
  102fd0:	83 c4 1c             	add    $0x1c,%esp
  102fd3:	5b                   	pop    %ebx
  102fd4:	5e                   	pop    %esi
  102fd5:	5f                   	pop    %edi
  102fd6:	5d                   	pop    %ebp
  102fd7:	c3                   	ret    
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
  102fd8:	8b 06                	mov    (%esi),%eax
  102fda:	85 c0                	test   %eax,%eax
  102fdc:	74 08                	je     102fe6 <pipealloc+0xc6>
    fileclose(*f0);
  102fde:	89 04 24             	mov    %eax,(%esp)
  102fe1:	e8 ba df ff ff       	call   100fa0 <fileclose>
  if(*f1)
  102fe6:	8b 13                	mov    (%ebx),%edx
  102fe8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102fed:	85 d2                	test   %edx,%edx
  102fef:	74 df                	je     102fd0 <pipealloc+0xb0>
    fileclose(*f1);
  102ff1:	89 14 24             	mov    %edx,(%esp)
  102ff4:	e8 a7 df ff ff       	call   100fa0 <fileclose>
  102ff9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102ffe:	eb d0                	jmp    102fd0 <pipealloc+0xb0>

00103000 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  103000:	55                   	push   %ebp
  103001:	89 e5                	mov    %esp,%ebp
  103003:	57                   	push   %edi
  103004:	56                   	push   %esi
  103005:	53                   	push   %ebx

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
  103006:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
{
  10300b:	83 ec 4c             	sub    $0x4c,%esp
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  10300e:	8d 7d c0             	lea    -0x40(%ebp),%edi
  103011:	eb 4e                	jmp    103061 <procdump+0x61>
  103013:	90                   	nop
  103014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  103018:	8b 04 85 50 6c 10 00 	mov    0x106c50(,%eax,4),%eax
  10301f:	85 c0                	test   %eax,%eax
  103021:	74 4a                	je     10306d <procdump+0x6d>
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
  103023:	8b 53 10             	mov    0x10(%ebx),%edx
  103026:	8d 4b 6c             	lea    0x6c(%ebx),%ecx
  103029:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10302d:	89 44 24 08          	mov    %eax,0x8(%esp)
  103031:	c7 04 24 75 6b 10 00 	movl   $0x106b75,(%esp)
  103038:	89 54 24 04          	mov    %edx,0x4(%esp)
  10303c:	e8 ef d4 ff ff       	call   100530 <cprintf>
    if(p->state == SLEEPING){
  103041:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
  103045:	74 31                	je     103078 <procdump+0x78>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  103047:	c7 04 24 f6 6a 10 00 	movl   $0x106af6,(%esp)
  10304e:	e8 dd d4 ff ff       	call   100530 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103053:	81 c3 84 00 00 00    	add    $0x84,%ebx
  103059:	81 fb 54 e2 10 00    	cmp    $0x10e254,%ebx
  10305f:	74 57                	je     1030b8 <procdump+0xb8>
    if(p->state == UNUSED)
  103061:	8b 43 0c             	mov    0xc(%ebx),%eax
  103064:	85 c0                	test   %eax,%eax
  103066:	74 eb                	je     103053 <procdump+0x53>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  103068:	83 f8 05             	cmp    $0x5,%eax
  10306b:	76 ab                	jbe    103018 <procdump+0x18>
  10306d:	b8 71 6b 10 00       	mov    $0x106b71,%eax
  103072:	eb af                	jmp    103023 <procdump+0x23>
  103074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  103078:	8b 43 1c             	mov    0x1c(%ebx),%eax
  10307b:	31 f6                	xor    %esi,%esi
  10307d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  103081:	8b 40 0c             	mov    0xc(%eax),%eax
  103084:	83 c0 08             	add    $0x8,%eax
  103087:	89 04 24             	mov    %eax,(%esp)
  10308a:	e8 31 0b 00 00       	call   103bc0 <getcallerpcs>
  10308f:	90                   	nop
      for(i=0; i<10 && pc[i] != 0; i++)
  103090:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  103093:	85 c0                	test   %eax,%eax
  103095:	74 b0                	je     103047 <procdump+0x47>
  103097:	83 c6 01             	add    $0x1,%esi
        cprintf(" %p", pc[i]);
  10309a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10309e:	c7 04 24 ea 66 10 00 	movl   $0x1066ea,(%esp)
  1030a5:	e8 86 d4 ff ff       	call   100530 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
  1030aa:	83 fe 0a             	cmp    $0xa,%esi
  1030ad:	75 e1                	jne    103090 <procdump+0x90>
  1030af:	eb 96                	jmp    103047 <procdump+0x47>
  1030b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
  1030b8:	83 c4 4c             	add    $0x4c,%esp
  1030bb:	5b                   	pop    %ebx
  1030bc:	5e                   	pop    %esi
  1030bd:	5f                   	pop    %edi
  1030be:	5d                   	pop    %ebp
  1030bf:	90                   	nop
  1030c0:	c3                   	ret    
  1030c1:	eb 0d                	jmp    1030d0 <kill>
  1030c3:	90                   	nop
  1030c4:	90                   	nop
  1030c5:	90                   	nop
  1030c6:	90                   	nop
  1030c7:	90                   	nop
  1030c8:	90                   	nop
  1030c9:	90                   	nop
  1030ca:	90                   	nop
  1030cb:	90                   	nop
  1030cc:	90                   	nop
  1030cd:	90                   	nop
  1030ce:	90                   	nop
  1030cf:	90                   	nop

001030d0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  1030d0:	55                   	push   %ebp
  1030d1:	89 e5                	mov    %esp,%ebp
  1030d3:	53                   	push   %ebx
  1030d4:	83 ec 14             	sub    $0x14,%esp
  1030d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
  1030da:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1030e1:	e8 4a 0c 00 00       	call   103d30 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  1030e6:	8b 15 64 c1 10 00    	mov    0x10c164,%edx

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
  1030ec:	b8 d8 c1 10 00       	mov    $0x10c1d8,%eax
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  1030f1:	39 da                	cmp    %ebx,%edx
  1030f3:	75 0f                	jne    103104 <kill+0x34>
  1030f5:	eb 60                	jmp    103157 <kill+0x87>
  1030f7:	90                   	nop
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1030f8:	05 84 00 00 00       	add    $0x84,%eax
  1030fd:	3d 54 e2 10 00       	cmp    $0x10e254,%eax
  103102:	74 3c                	je     103140 <kill+0x70>
    if(p->pid == pid){
  103104:	8b 50 10             	mov    0x10(%eax),%edx
  103107:	39 da                	cmp    %ebx,%edx
  103109:	75 ed                	jne    1030f8 <kill+0x28>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  10310b:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
  10310f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  103116:	74 18                	je     103130 <kill+0x60>
        p->state = RUNNABLE;
      release(&ptable.lock);
  103118:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10311f:	e8 bc 0b 00 00       	call   103ce0 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  103124:	83 c4 14             	add    $0x14,%esp
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
  103127:	31 c0                	xor    %eax,%eax
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  103129:	5b                   	pop    %ebx
  10312a:	5d                   	pop    %ebp
  10312b:	c3                   	ret    
  10312c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
  103130:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  103137:	eb df                	jmp    103118 <kill+0x48>
  103139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  103140:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103147:	e8 94 0b 00 00       	call   103ce0 <release>
  return -1;
}
  10314c:	83 c4 14             	add    $0x14,%esp
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  10314f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
  103154:	5b                   	pop    %ebx
  103155:	5d                   	pop    %ebp
  103156:	c3                   	ret    
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  103157:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  10315c:	eb ad                	jmp    10310b <kill+0x3b>
  10315e:	66 90                	xchg   %ax,%ax

00103160 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  103160:	55                   	push   %ebp
  103161:	89 e5                	mov    %esp,%ebp
  103163:	53                   	push   %ebx
  103164:	83 ec 14             	sub    $0x14,%esp
  103167:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
  10316a:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103171:	e8 ba 0b 00 00       	call   103d30 <acquire>
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
  103176:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  10317b:	eb 0f                	jmp    10318c <wakeup+0x2c>
  10317d:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103180:	05 84 00 00 00       	add    $0x84,%eax
  103185:	3d 54 e2 10 00       	cmp    $0x10e254,%eax
  10318a:	74 24                	je     1031b0 <wakeup+0x50>
    if(p->state == SLEEPING && p->chan == chan)
  10318c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  103190:	75 ee                	jne    103180 <wakeup+0x20>
  103192:	3b 58 20             	cmp    0x20(%eax),%ebx
  103195:	75 e9                	jne    103180 <wakeup+0x20>
      p->state = RUNNABLE;
  103197:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  10319e:	05 84 00 00 00       	add    $0x84,%eax
  1031a3:	3d 54 e2 10 00       	cmp    $0x10e254,%eax
  1031a8:	75 e2                	jne    10318c <wakeup+0x2c>
  1031aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  1031b0:	c7 45 08 20 c1 10 00 	movl   $0x10c120,0x8(%ebp)
}
  1031b7:	83 c4 14             	add    $0x14,%esp
  1031ba:	5b                   	pop    %ebx
  1031bb:	5d                   	pop    %ebp
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  1031bc:	e9 1f 0b 00 00       	jmp    103ce0 <release>
  1031c1:	eb 0d                	jmp    1031d0 <forkret>
  1031c3:	90                   	nop
  1031c4:	90                   	nop
  1031c5:	90                   	nop
  1031c6:	90                   	nop
  1031c7:	90                   	nop
  1031c8:	90                   	nop
  1031c9:	90                   	nop
  1031ca:	90                   	nop
  1031cb:	90                   	nop
  1031cc:	90                   	nop
  1031cd:	90                   	nop
  1031ce:	90                   	nop
  1031cf:	90                   	nop

001031d0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  1031d0:	55                   	push   %ebp
  1031d1:	89 e5                	mov    %esp,%ebp
  1031d3:	83 ec 18             	sub    $0x18,%esp
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
  1031d6:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1031dd:	e8 fe 0a 00 00       	call   103ce0 <release>
  
  // Return to "caller", actually trapret (see allocproc).
}
  1031e2:	c9                   	leave  
  1031e3:	c3                   	ret    
  1031e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1031ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001031f0 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  1031f0:	55                   	push   %ebp
  1031f1:	89 e5                	mov    %esp,%ebp
  1031f3:	53                   	push   %ebx
  1031f4:	83 ec 14             	sub    $0x14,%esp
  int intena;

  if(!holding(&ptable.lock))
  1031f7:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1031fe:	e8 1d 0a 00 00       	call   103c20 <holding>
  103203:	85 c0                	test   %eax,%eax
  103205:	74 4d                	je     103254 <sched+0x64>
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
  103207:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10320d:	83 b8 ac 00 00 00 01 	cmpl   $0x1,0xac(%eax)
  103214:	75 62                	jne    103278 <sched+0x88>
    panic("sched locks");
  if(proc->state == RUNNING)
  103216:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10321d:	83 7a 0c 04          	cmpl   $0x4,0xc(%edx)
  103221:	74 49                	je     10326c <sched+0x7c>

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103223:	9c                   	pushf  
  103224:	59                   	pop    %ecx
    panic("sched running");
  if(readeflags()&FL_IF)
  103225:	80 e5 02             	and    $0x2,%ch
  103228:	75 36                	jne    103260 <sched+0x70>
    panic("sched interruptible");
  intena = cpu->intena;
  10322a:	8b 98 b0 00 00 00    	mov    0xb0(%eax),%ebx
  swtch(&proc->context, cpu->scheduler);
  103230:	83 c2 1c             	add    $0x1c,%edx
  103233:	8b 40 04             	mov    0x4(%eax),%eax
  103236:	89 14 24             	mov    %edx,(%esp)
  103239:	89 44 24 04          	mov    %eax,0x4(%esp)
  10323d:	e8 8a 0d 00 00       	call   103fcc <swtch>
  cpu->intena = intena;
  103242:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103248:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  10324e:	83 c4 14             	add    $0x14,%esp
  103251:	5b                   	pop    %ebx
  103252:	5d                   	pop    %ebp
  103253:	c3                   	ret    
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  103254:	c7 04 24 7e 6b 10 00 	movl   $0x106b7e,(%esp)
  10325b:	e8 c0 d6 ff ff       	call   100920 <panic>
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  103260:	c7 04 24 aa 6b 10 00 	movl   $0x106baa,(%esp)
  103267:	e8 b4 d6 ff ff       	call   100920 <panic>
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  10326c:	c7 04 24 9c 6b 10 00 	movl   $0x106b9c,(%esp)
  103273:	e8 a8 d6 ff ff       	call   100920 <panic>
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  103278:	c7 04 24 90 6b 10 00 	movl   $0x106b90,(%esp)
  10327f:	e8 9c d6 ff ff       	call   100920 <panic>
  103284:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10328a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103290 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  103290:	55                   	push   %ebp
  103291:	89 e5                	mov    %esp,%ebp
  103293:	56                   	push   %esi
  103294:	53                   	push   %ebx
  103295:	83 ec 10             	sub    $0x10,%esp
  if(proc == 0)
  103298:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  10329e:	8b 75 08             	mov    0x8(%ebp),%esi
  1032a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
  1032a4:	85 c0                	test   %eax,%eax
  1032a6:	0f 84 a1 00 00 00    	je     10334d <sleep+0xbd>
    panic("sleep");

  if(lk == 0)
  1032ac:	85 db                	test   %ebx,%ebx
  1032ae:	0f 84 8d 00 00 00    	je     103341 <sleep+0xb1>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
  1032b4:	81 fb 20 c1 10 00    	cmp    $0x10c120,%ebx
  1032ba:	74 5c                	je     103318 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
  1032bc:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1032c3:	e8 68 0a 00 00       	call   103d30 <acquire>
    release(lk);
  1032c8:	89 1c 24             	mov    %ebx,(%esp)
  1032cb:	e8 10 0a 00 00       	call   103ce0 <release>
  }

  // Go to sleep.
  proc->chan = chan;
  1032d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032d6:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  1032d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032df:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  1032e6:	e8 05 ff ff ff       	call   1031f0 <sched>

  // Tidy up.
  proc->chan = 0;
  1032eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032f1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
  1032f8:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1032ff:	e8 dc 09 00 00       	call   103ce0 <release>
    acquire(lk);
  103304:	89 5d 08             	mov    %ebx,0x8(%ebp)
  }
}
  103307:	83 c4 10             	add    $0x10,%esp
  10330a:	5b                   	pop    %ebx
  10330b:	5e                   	pop    %esi
  10330c:	5d                   	pop    %ebp
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  10330d:	e9 1e 0a 00 00       	jmp    103d30 <acquire>
  103312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  103318:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  10331b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103321:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  103328:	e8 c3 fe ff ff       	call   1031f0 <sched>

  // Tidy up.
  proc->chan = 0;
  10332d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103333:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}
  10333a:	83 c4 10             	add    $0x10,%esp
  10333d:	5b                   	pop    %ebx
  10333e:	5e                   	pop    %esi
  10333f:	5d                   	pop    %ebp
  103340:	c3                   	ret    
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");
  103341:	c7 04 24 c4 6b 10 00 	movl   $0x106bc4,(%esp)
  103348:	e8 d3 d5 ff ff       	call   100920 <panic>
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");
  10334d:	c7 04 24 be 6b 10 00 	movl   $0x106bbe,(%esp)
  103354:	e8 c7 d5 ff ff       	call   100920 <panic>
  103359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103360 <yield>:
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  103360:	55                   	push   %ebp
  103361:	89 e5                	mov    %esp,%ebp
  103363:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
  103366:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10336d:	e8 be 09 00 00       	call   103d30 <acquire>
  proc->state = RUNNABLE;
  103372:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103378:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
  10337f:	e8 6c fe ff ff       	call   1031f0 <sched>
  release(&ptable.lock);
  103384:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10338b:	e8 50 09 00 00       	call   103ce0 <release>
}
  103390:	c9                   	leave  
  103391:	c3                   	ret    
  103392:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  103399:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001033a0 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  1033a0:	55                   	push   %ebp
  1033a1:	89 e5                	mov    %esp,%ebp
  1033a3:	53                   	push   %ebx
  1033a4:	83 ec 14             	sub    $0x14,%esp
  1033a7:	90                   	nop
}

static inline void
sti(void)
{
  asm volatile("sti");
  1033a8:	fb                   	sti    
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
  1033a9:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
  1033ae:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1033b5:	e8 76 09 00 00       	call   103d30 <acquire>
  1033ba:	eb 12                	jmp    1033ce <scheduler+0x2e>
  1033bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1033c0:	81 c3 84 00 00 00    	add    $0x84,%ebx
  1033c6:	81 fb 54 e2 10 00    	cmp    $0x10e254,%ebx
  1033cc:	74 5a                	je     103428 <scheduler+0x88>
      if(p->state != RUNNABLE)
  1033ce:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
  1033d2:	75 ec                	jne    1033c0 <scheduler+0x20>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
  1033d4:	65 89 1d 04 00 00 00 	mov    %ebx,%gs:0x4
      switchuvm(p);
  1033db:	89 1c 24             	mov    %ebx,(%esp)
  1033de:	e8 cd 30 00 00       	call   1064b0 <switchuvm>
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  1033e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
  1033e9:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1033f0:	81 c3 84 00 00 00    	add    $0x84,%ebx
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  1033f6:	8b 40 1c             	mov    0x1c(%eax),%eax
  1033f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033fd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103403:	83 c0 04             	add    $0x4,%eax
  103406:	89 04 24             	mov    %eax,(%esp)
  103409:	e8 be 0b 00 00       	call   103fcc <swtch>
      switchkvm();
  10340e:	e8 2d 2a 00 00       	call   105e40 <switchkvm>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103413:	81 fb 54 e2 10 00    	cmp    $0x10e254,%ebx
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
  103419:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  103420:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103424:	75 a8                	jne    1033ce <scheduler+0x2e>
  103426:	66 90                	xchg   %ax,%ax

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
  103428:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10342f:	e8 ac 08 00 00       	call   103ce0 <release>

  }
  103434:	e9 6f ff ff ff       	jmp    1033a8 <scheduler+0x8>
  103439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103440 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103440:	55                   	push   %ebp
  103441:	89 e5                	mov    %esp,%ebp
  103443:	53                   	push   %ebx
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  103444:	bb 54 c1 10 00       	mov    $0x10c154,%ebx

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103449:	83 ec 24             	sub    $0x24,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  10344c:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103453:	e8 d8 08 00 00       	call   103d30 <acquire>
  103458:	31 c0                	xor    %eax,%eax
  10345a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103460:	81 fb 54 e2 10 00    	cmp    $0x10e254,%ebx
  103466:	72 30                	jb     103498 <wait+0x58>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
  103468:	85 c0                	test   %eax,%eax
  10346a:	74 5c                	je     1034c8 <wait+0x88>
  10346c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103472:	8b 50 24             	mov    0x24(%eax),%edx
  103475:	85 d2                	test   %edx,%edx
  103477:	75 4f                	jne    1034c8 <wait+0x88>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  103479:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  10347e:	89 04 24             	mov    %eax,(%esp)
  103481:	c7 44 24 04 20 c1 10 	movl   $0x10c120,0x4(%esp)
  103488:	00 
  103489:	e8 02 fe ff ff       	call   103290 <sleep>
  10348e:	31 c0                	xor    %eax,%eax

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103490:	81 fb 54 e2 10 00    	cmp    $0x10e254,%ebx
  103496:	73 d0                	jae    103468 <wait+0x28>
      if(p->parent != proc)
  103498:	8b 53 14             	mov    0x14(%ebx),%edx
  10349b:	65 3b 15 04 00 00 00 	cmp    %gs:0x4,%edx
  1034a2:	74 0c                	je     1034b0 <wait+0x70>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1034a4:	81 c3 84 00 00 00    	add    $0x84,%ebx
  1034aa:	eb b4                	jmp    103460 <wait+0x20>
  1034ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
  1034b0:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
  1034b4:	74 29                	je     1034df <wait+0x9f>
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
  1034b6:	b8 01 00 00 00       	mov    $0x1,%eax
  1034bb:	90                   	nop
  1034bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1034c0:	eb e2                	jmp    1034a4 <wait+0x64>
  1034c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
  1034c8:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1034cf:	e8 0c 08 00 00       	call   103ce0 <release>
  1034d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
  1034d9:	83 c4 24             	add    $0x24,%esp
  1034dc:	5b                   	pop    %ebx
  1034dd:	5d                   	pop    %ebp
  1034de:	c3                   	ret    
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
  1034df:	8b 43 10             	mov    0x10(%ebx),%eax
        kfree(p->kstack);
  1034e2:	8b 53 08             	mov    0x8(%ebx),%edx
  1034e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1034e8:	89 14 24             	mov    %edx,(%esp)
  1034eb:	e8 d0 ed ff ff       	call   1022c0 <kfree>
        p->kstack = 0;
        if (p->pgdir != p->parent->pgdir) {
  1034f0:	8b 4b 14             	mov    0x14(%ebx),%ecx
  1034f3:	8b 53 04             	mov    0x4(%ebx),%edx
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
  1034f6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        if (p->pgdir != p->parent->pgdir) {
  1034fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103500:	3b 51 04             	cmp    0x4(%ecx),%edx
  103503:	74 0b                	je     103510 <wait+0xd0>
          freevm(p->pgdir);
  103505:	89 14 24             	mov    %edx,(%esp)
  103508:	e8 d3 2c 00 00       	call   1061e0 <freevm>
  10350d:	8b 45 f4             	mov    -0xc(%ebp),%eax
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
  103510:	89 45 f4             	mov    %eax,-0xc(%ebp)
        kfree(p->kstack);
        p->kstack = 0;
        if (p->pgdir != p->parent->pgdir) {
          freevm(p->pgdir);
        }
        p->state = UNUSED;
  103513:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->pid = 0;
  10351a:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
  103521:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
  103528:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
  10352c:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        release(&ptable.lock);
  103533:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10353a:	e8 a1 07 00 00       	call   103ce0 <release>
        return pid;
  10353f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103542:	eb 95                	jmp    1034d9 <wait+0x99>
  103544:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10354a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103550 <exit>:
  return pid;
}

void
exit(void)
{
  103550:	55                   	push   %ebp
  103551:	89 e5                	mov    %esp,%ebp
  103553:	56                   	push   %esi
  103554:	53                   	push   %ebx
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  103555:	31 db                	xor    %ebx,%ebx
  return pid;
}

void
exit(void)
{
  103557:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
  10355a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103561:	3b 15 c8 78 10 00    	cmp    0x1078c8,%edx
  103567:	0f 84 0d 01 00 00    	je     10367a <exit+0x12a>
  10356d:	8d 76 00             	lea    0x0(%esi),%esi
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
  103570:	8d 73 08             	lea    0x8(%ebx),%esi
  103573:	8b 44 b2 08          	mov    0x8(%edx,%esi,4),%eax
  103577:	85 c0                	test   %eax,%eax
  103579:	74 1d                	je     103598 <exit+0x48>
      fileclose(proc->ofile[fd]);
  10357b:	89 04 24             	mov    %eax,(%esp)
  10357e:	e8 1d da ff ff       	call   100fa0 <fileclose>
      proc->ofile[fd] = 0;
  103583:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103589:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
  103590:	00 
  103591:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
  103598:	83 c3 01             	add    $0x1,%ebx
  10359b:	83 fb 10             	cmp    $0x10,%ebx
  10359e:	75 d0                	jne    103570 <exit+0x20>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
  1035a0:	8b 42 68             	mov    0x68(%edx),%eax
  1035a3:	89 04 24             	mov    %eax,(%esp)
  1035a6:	e8 05 e3 ff ff       	call   1018b0 <iput>
  proc->cwd = 0;
  1035ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1035b1:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
  1035b8:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1035bf:	e8 6c 07 00 00       	call   103d30 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  1035c4:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  return pid;
}

void
exit(void)
  1035cb:	b9 54 e2 10 00       	mov    $0x10e254,%ecx
  1035d0:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  1035d5:	8b 53 14             	mov    0x14(%ebx),%edx
  1035d8:	eb 12                	jmp    1035ec <exit+0x9c>
  1035da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1035e0:	05 84 00 00 00       	add    $0x84,%eax
  1035e5:	3d 54 e2 10 00       	cmp    $0x10e254,%eax
  1035ea:	74 1e                	je     10360a <exit+0xba>
    if(p->state == SLEEPING && p->chan == chan)
  1035ec:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  1035f0:	75 ee                	jne    1035e0 <exit+0x90>
  1035f2:	3b 50 20             	cmp    0x20(%eax),%edx
  1035f5:	75 e9                	jne    1035e0 <exit+0x90>
      p->state = RUNNABLE;
  1035f7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1035fe:	05 84 00 00 00       	add    $0x84,%eax
  103603:	3d 54 e2 10 00       	cmp    $0x10e254,%eax
  103608:	75 e2                	jne    1035ec <exit+0x9c>
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  10360a:	8b 35 c8 78 10 00    	mov    0x1078c8,%esi
  103610:	ba 54 c1 10 00       	mov    $0x10c154,%edx
  103615:	eb 0f                	jmp    103626 <exit+0xd6>
  103617:	90                   	nop

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103618:	81 c2 84 00 00 00    	add    $0x84,%edx
  10361e:	81 fa 54 e2 10 00    	cmp    $0x10e254,%edx
  103624:	74 3c                	je     103662 <exit+0x112>
    if(p->parent == proc){
  103626:	3b 5a 14             	cmp    0x14(%edx),%ebx
  103629:	75 ed                	jne    103618 <exit+0xc8>
      p->parent = initproc;
      if(p->state == ZOMBIE)
  10362b:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  10362f:	89 72 14             	mov    %esi,0x14(%edx)
      if(p->state == ZOMBIE)
  103632:	75 e4                	jne    103618 <exit+0xc8>
  103634:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  103639:	eb 0e                	jmp    103649 <exit+0xf9>
  10363b:	90                   	nop
  10363c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103640:	05 84 00 00 00       	add    $0x84,%eax
  103645:	39 c1                	cmp    %eax,%ecx
  103647:	74 cf                	je     103618 <exit+0xc8>
    if(p->state == SLEEPING && p->chan == chan)
  103649:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  10364d:	75 f1                	jne    103640 <exit+0xf0>
  10364f:	3b 70 20             	cmp    0x20(%eax),%esi
  103652:	75 ec                	jne    103640 <exit+0xf0>
      p->state = RUNNABLE;
  103654:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  10365b:	90                   	nop
  10365c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103660:	eb de                	jmp    103640 <exit+0xf0>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  103662:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
  103669:	e8 82 fb ff ff       	call   1031f0 <sched>
  panic("zombie exit");
  10366e:	c7 04 24 e2 6b 10 00 	movl   $0x106be2,(%esp)
  103675:	e8 a6 d2 ff ff       	call   100920 <panic>
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  10367a:	c7 04 24 d5 6b 10 00 	movl   $0x106bd5,(%esp)
  103681:	e8 9a d2 ff ff       	call   100920 <panic>
  103686:	8d 76 00             	lea    0x0(%esi),%esi
  103689:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103690 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  103690:	55                   	push   %ebp
  103691:	89 e5                	mov    %esp,%ebp
  103693:	53                   	push   %ebx
  103694:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  103697:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10369e:	e8 8d 06 00 00       	call   103d30 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
  1036a3:	8b 1d 60 c1 10 00    	mov    0x10c160,%ebx
  1036a9:	85 db                	test   %ebx,%ebx
  1036ab:	0f 84 ad 00 00 00    	je     10375e <allocproc+0xce>
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
  1036b1:	bb d8 c1 10 00       	mov    $0x10c1d8,%ebx
  1036b6:	eb 12                	jmp    1036ca <allocproc+0x3a>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1036b8:	81 c3 84 00 00 00    	add    $0x84,%ebx
  1036be:	81 fb 54 e2 10 00    	cmp    $0x10e254,%ebx
  1036c4:	0f 84 7e 00 00 00    	je     103748 <allocproc+0xb8>
    if(p->state == UNUSED)
  1036ca:	8b 4b 0c             	mov    0xc(%ebx),%ecx
  1036cd:	85 c9                	test   %ecx,%ecx
  1036cf:	75 e7                	jne    1036b8 <allocproc+0x28>
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  1036d1:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
  1036d8:	a1 24 73 10 00       	mov    0x107324,%eax
  1036dd:	89 43 10             	mov    %eax,0x10(%ebx)
  1036e0:	83 c0 01             	add    $0x1,%eax
  1036e3:	a3 24 73 10 00       	mov    %eax,0x107324
  release(&ptable.lock);
  1036e8:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1036ef:	e8 ec 05 00 00       	call   103ce0 <release>

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
  1036f4:	e8 87 eb ff ff       	call   102280 <kalloc>
  1036f9:	85 c0                	test   %eax,%eax
  1036fb:	89 43 08             	mov    %eax,0x8(%ebx)
  1036fe:	74 68                	je     103768 <allocproc+0xd8>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  103700:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
  103706:	89 53 18             	mov    %edx,0x18(%ebx)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
  103709:	c7 80 b0 0f 00 00 20 	movl   $0x104f20,0xfb0(%eax)
  103710:	4f 10 00 

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  103713:	05 9c 0f 00 00       	add    $0xf9c,%eax
  103718:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
  10371b:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  103722:	00 
  103723:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10372a:	00 
  10372b:	89 04 24             	mov    %eax,(%esp)
  10372e:	e8 9d 06 00 00       	call   103dd0 <memset>
  p->context->eip = (uint)forkret;
  103733:	8b 43 1c             	mov    0x1c(%ebx),%eax
  103736:	c7 40 10 d0 31 10 00 	movl   $0x1031d0,0x10(%eax)

  return p;
}
  10373d:	89 d8                	mov    %ebx,%eax
  10373f:	83 c4 14             	add    $0x14,%esp
  103742:	5b                   	pop    %ebx
  103743:	5d                   	pop    %ebp
  103744:	c3                   	ret    
  103745:	8d 76 00             	lea    0x0(%esi),%esi

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  103748:	31 db                	xor    %ebx,%ebx
  10374a:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103751:	e8 8a 05 00 00       	call   103ce0 <release>
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}
  103756:	89 d8                	mov    %ebx,%eax
  103758:	83 c4 14             	add    $0x14,%esp
  10375b:	5b                   	pop    %ebx
  10375c:	5d                   	pop    %ebp
  10375d:	c3                   	ret    
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;
  10375e:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  103763:	e9 69 ff ff ff       	jmp    1036d1 <allocproc+0x41>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
  103768:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  10376f:	31 db                	xor    %ebx,%ebx
    return 0;
  103771:	eb ca                	jmp    10373d <allocproc+0xad>
  103773:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103779:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103780 <clone>:
  return pid;
}

int
clone(void)
{
  103780:	55                   	push   %ebp
  103781:	89 e5                	mov    %esp,%ebp
  103783:	57                   	push   %edi
  103784:	56                   	push   %esi
  char* stack;
  int i, pid, size;
  struct proc *np;
  cprintf("a\n");
  // Allocate process.
  if((np = allocproc()) == 0)
  103785:	be ff ff ff ff       	mov    $0xffffffff,%esi
  return pid;
}

int
clone(void)
{
  10378a:	53                   	push   %ebx
  10378b:	83 ec 2c             	sub    $0x2c,%esp
  char* stack;
  int i, pid, size;
  struct proc *np;
  cprintf("a\n");
  10378e:	c7 04 24 ee 6b 10 00 	movl   $0x106bee,(%esp)
  103795:	e8 96 cd ff ff       	call   100530 <cprintf>
  // Allocate process.
  if((np = allocproc()) == 0)
  10379a:	e8 f1 fe ff ff       	call   103690 <allocproc>
  10379f:	85 c0                	test   %eax,%eax
  1037a1:	89 c3                	mov    %eax,%ebx
  1037a3:	0f 84 3a 01 00 00    	je     1038e3 <clone+0x163>
    return -1;

  // Point page dir at parent's page dir (shared memory)
  np->pgdir = proc->pgdir;
  1037a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  // This might be an issue later.
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  1037af:	b9 13 00 00 00       	mov    $0x13,%ecx
  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Point page dir at parent's page dir (shared memory)
  np->pgdir = proc->pgdir;
  1037b4:	8b 40 04             	mov    0x4(%eax),%eax
  1037b7:	89 43 04             	mov    %eax,0x4(%ebx)
  // This might be an issue later.
  np->sz = proc->sz;
  1037ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1037c0:	8b 00                	mov    (%eax),%eax
  1037c2:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
  1037c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1037ca:	89 43 14             	mov    %eax,0x14(%ebx)
  *np->tf = *proc->tf;
  1037cd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  1037d4:	8b 43 18             	mov    0x18(%ebx),%eax
  1037d7:	8b 72 18             	mov    0x18(%edx),%esi
  1037da:	89 c7                	mov    %eax,%edi
  1037dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  
  if(argint(1, &size) < 0 || size <= 0 || argptr(0, &stack, size) < 0) {
  1037de:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1037e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1037e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037ec:	e8 7f 08 00 00       	call   104070 <argint>
  1037f1:	85 c0                	test   %eax,%eax
  1037f3:	0f 88 f4 00 00 00    	js     1038ed <clone+0x16d>
  1037f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1037fc:	85 c0                	test   %eax,%eax
  1037fe:	0f 8e e9 00 00 00    	jle    1038ed <clone+0x16d>
  103804:	89 44 24 08          	mov    %eax,0x8(%esp)
  103808:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  10380b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10380f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  103816:	e8 95 08 00 00       	call   1040b0 <argptr>
  10381b:	85 c0                	test   %eax,%eax
  10381d:	0f 88 ca 00 00 00    	js     1038ed <clone+0x16d>
    np->state = UNUSED;
    return -1;
  }

  // Clear %eax so that clone returns 0 in the child.
  np->tf->eax = 0;
  103823:	8b 43 18             	mov    0x18(%ebx),%eax
    cprintf("%x\n" , *j);
  }*/
/*  cprintf("%x + 1000 - %x - ( %x - %x)\n", (uint)stack, (uint)proc->pstack, (uint)proc->pstack, (uint)proc->tf->esp);*/
//   np->tf->esp = (uint)stack + PGSIZE - (uint)proc->pstack - ((uint)proc->pstack - (uint)proc->tf->esp);
  np->tf->esp = 0xafbc;
  cprintf("b: %x\n", *(uint *)np->tf->esp);
  103826:	31 f6                	xor    %esi,%esi
    np->state = UNUSED;
    return -1;
  }

  // Clear %eax so that clone returns 0 in the child.
  np->tf->eax = 0;
  103828:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

//   cprintf("pstack: %x\n", proc->pstack);
// /*  cprintf("pstack2: %x\n", proc->pstack2);*/
//   cprintf("esp: %x\n", proc->tf->esp);
  memmove(stack, proc->pstack - size + 1, size - 1);
  10382f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103832:	8d 42 ff             	lea    -0x1(%edx),%eax
  103835:	89 44 24 08          	mov    %eax,0x8(%esp)
  103839:	b8 01 00 00 00       	mov    $0x1,%eax
  10383e:	29 d0                	sub    %edx,%eax
  103840:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103847:	c1 e0 02             	shl    $0x2,%eax
  10384a:	03 42 7c             	add    0x7c(%edx),%eax
  10384d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103851:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103854:	89 04 24             	mov    %eax,(%esp)
  103857:	e8 f4 05 00 00       	call   103e50 <memmove>
  for (j = (uint *)stack, k =0; k < size/10 - 1; j++, k++) {
    cprintf("%x\n" , *j);
  }*/
/*  cprintf("%x + 1000 - %x - ( %x - %x)\n", (uint)stack, (uint)proc->pstack, (uint)proc->pstack, (uint)proc->tf->esp);*/
//   np->tf->esp = (uint)stack + PGSIZE - (uint)proc->pstack - ((uint)proc->pstack - (uint)proc->tf->esp);
  np->tf->esp = 0xafbc;
  10385c:	8b 43 18             	mov    0x18(%ebx),%eax
  10385f:	c7 40 44 bc af 00 00 	movl   $0xafbc,0x44(%eax)
  cprintf("b: %x\n", *(uint *)np->tf->esp);
  103866:	8b 43 18             	mov    0x18(%ebx),%eax
  103869:	8b 40 44             	mov    0x44(%eax),%eax
  10386c:	8b 00                	mov    (%eax),%eax
  10386e:	c7 04 24 f1 6b 10 00 	movl   $0x106bf1,(%esp)
  103875:	89 44 24 04          	mov    %eax,0x4(%esp)
  103879:	e8 b2 cc ff ff       	call   100530 <cprintf>
  10387e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103885:	8d 76 00             	lea    0x0(%esi),%esi

  
// esp needs to point at the same relative spot in it's own copy of the stack.

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
  103888:	8b 44 b2 28          	mov    0x28(%edx,%esi,4),%eax
  10388c:	85 c0                	test   %eax,%eax
  10388e:	74 13                	je     1038a3 <clone+0x123>
      np->ofile[i] = filedup(proc->ofile[i]);
  103890:	89 04 24             	mov    %eax,(%esp)
  103893:	e8 38 d6 ff ff       	call   100ed0 <filedup>
  103898:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
  10389c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
//   cprintf("childstack: %x\n", stack);

  
// esp needs to point at the same relative spot in it's own copy of the stack.

  for(i = 0; i < NOFILE; i++)
  1038a3:	83 c6 01             	add    $0x1,%esi
  1038a6:	83 fe 10             	cmp    $0x10,%esi
  1038a9:	75 dd                	jne    103888 <clone+0x108>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1038ab:	8b 42 68             	mov    0x68(%edx),%eax
  1038ae:	89 04 24             	mov    %eax,(%esp)
  1038b1:	e8 1a d8 ff ff       	call   1010d0 <idup>

  pid = np->pid;
  1038b6:	8b 73 10             	mov    0x10(%ebx),%esi
  np->state = RUNNABLE;
  1038b9:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
// esp needs to point at the same relative spot in it's own copy of the stack.

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1038c0:	89 43 68             	mov    %eax,0x68(%ebx)

  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  1038c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1038c9:	83 c3 6c             	add    $0x6c,%ebx
  1038cc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  1038d3:	00 
  1038d4:	89 1c 24             	mov    %ebx,(%esp)
  1038d7:	83 c0 6c             	add    $0x6c,%eax
  1038da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1038de:	e8 8d 06 00 00       	call   103f70 <safestrcpy>
  return pid;
}
  1038e3:	83 c4 2c             	add    $0x2c,%esp
  1038e6:	89 f0                	mov    %esi,%eax
  1038e8:	5b                   	pop    %ebx
  1038e9:	5e                   	pop    %esi
  1038ea:	5f                   	pop    %edi
  1038eb:	5d                   	pop    %ebp
  1038ec:	c3                   	ret    
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  
  if(argint(1, &size) < 0 || size <= 0 || argptr(0, &stack, size) < 0) {
    kfree(np->kstack);
  1038ed:	8b 43 08             	mov    0x8(%ebx),%eax
    np->kstack = 0;
    np->state = UNUSED;
  1038f0:	be ff ff ff ff       	mov    $0xffffffff,%esi
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  
  if(argint(1, &size) < 0 || size <= 0 || argptr(0, &stack, size) < 0) {
    kfree(np->kstack);
  1038f5:	89 04 24             	mov    %eax,(%esp)
  1038f8:	e8 c3 e9 ff ff       	call   1022c0 <kfree>
    np->kstack = 0;
  1038fd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
  103904:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
  10390b:	eb d6                	jmp    1038e3 <clone+0x163>
  10390d:	8d 76 00             	lea    0x0(%esi),%esi

00103910 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  103910:	55                   	push   %ebp
  103911:	89 e5                	mov    %esp,%ebp
  103913:	57                   	push   %edi
  103914:	56                   	push   %esi
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  103915:	be ff ff ff ff       	mov    $0xffffffff,%esi
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  10391a:	53                   	push   %ebx
  10391b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  10391e:	e8 6d fd ff ff       	call   103690 <allocproc>
  103923:	85 c0                	test   %eax,%eax
  103925:	89 c3                	mov    %eax,%ebx
  103927:	0f 84 be 00 00 00    	je     1039eb <fork+0xdb>
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
  10392d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103933:	8b 10                	mov    (%eax),%edx
  103935:	89 54 24 04          	mov    %edx,0x4(%esp)
  103939:	8b 40 04             	mov    0x4(%eax),%eax
  10393c:	89 04 24             	mov    %eax,(%esp)
  10393f:	e8 1c 29 00 00       	call   106260 <copyuvm>
  103944:	85 c0                	test   %eax,%eax
  103946:	89 43 04             	mov    %eax,0x4(%ebx)
  103949:	0f 84 a6 00 00 00    	je     1039f5 <fork+0xe5>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  10394f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  np->parent = proc;
  *np->tf = *proc->tf;
  103955:	b9 13 00 00 00       	mov    $0x13,%ecx
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  10395a:	8b 00                	mov    (%eax),%eax
  10395c:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
  10395e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103964:	89 43 14             	mov    %eax,0x14(%ebx)
  *np->tf = *proc->tf;
  103967:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10396e:	8b 43 18             	mov    0x18(%ebx),%eax
  103971:	8b 72 18             	mov    0x18(%edx),%esi
  103974:	89 c7                	mov    %eax,%edi
  103976:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
  103978:	31 f6                	xor    %esi,%esi
  10397a:	8b 43 18             	mov    0x18(%ebx),%eax
  10397d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  103984:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10398b:	90                   	nop
  10398c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
  103990:	8b 44 b2 28          	mov    0x28(%edx,%esi,4),%eax
  103994:	85 c0                	test   %eax,%eax
  103996:	74 13                	je     1039ab <fork+0x9b>
      np->ofile[i] = filedup(proc->ofile[i]);
  103998:	89 04 24             	mov    %eax,(%esp)
  10399b:	e8 30 d5 ff ff       	call   100ed0 <filedup>
  1039a0:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
  1039a4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
  1039ab:	83 c6 01             	add    $0x1,%esi
  1039ae:	83 fe 10             	cmp    $0x10,%esi
  1039b1:	75 dd                	jne    103990 <fork+0x80>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1039b3:	8b 42 68             	mov    0x68(%edx),%eax
  1039b6:	89 04 24             	mov    %eax,(%esp)
  1039b9:	e8 12 d7 ff ff       	call   1010d0 <idup>
 
  pid = np->pid;
  1039be:	8b 73 10             	mov    0x10(%ebx),%esi
  np->state = RUNNABLE;
  1039c1:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1039c8:	89 43 68             	mov    %eax,0x68(%ebx)
 
  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  1039cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1039d1:	83 c3 6c             	add    $0x6c,%ebx
  1039d4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  1039db:	00 
  1039dc:	89 1c 24             	mov    %ebx,(%esp)
  1039df:	83 c0 6c             	add    $0x6c,%eax
  1039e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1039e6:	e8 85 05 00 00       	call   103f70 <safestrcpy>
  return pid;
}
  1039eb:	83 c4 1c             	add    $0x1c,%esp
  1039ee:	89 f0                	mov    %esi,%eax
  1039f0:	5b                   	pop    %ebx
  1039f1:	5e                   	pop    %esi
  1039f2:	5f                   	pop    %edi
  1039f3:	5d                   	pop    %ebp
  1039f4:	c3                   	ret    
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
  1039f5:	8b 43 08             	mov    0x8(%ebx),%eax
  1039f8:	89 04 24             	mov    %eax,(%esp)
  1039fb:	e8 c0 e8 ff ff       	call   1022c0 <kfree>
    np->kstack = 0;
  103a00:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
  103a07:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
  103a0e:	eb db                	jmp    1039eb <fork+0xdb>

00103a10 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  103a10:	55                   	push   %ebp
  103a11:	89 e5                	mov    %esp,%ebp
  103a13:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
  103a16:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  103a1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  uint sz;
  
  sz = proc->sz;
  103a20:	8b 02                	mov    (%edx),%eax
  if(n > 0){
  103a22:	83 f9 00             	cmp    $0x0,%ecx
  103a25:	7f 19                	jg     103a40 <growproc+0x30>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
  103a27:	75 39                	jne    103a62 <growproc+0x52>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  103a29:	89 02                	mov    %eax,(%edx)
  switchuvm(proc);
  103a2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103a31:	89 04 24             	mov    %eax,(%esp)
  103a34:	e8 77 2a 00 00       	call   1064b0 <switchuvm>
  103a39:	31 c0                	xor    %eax,%eax
  return 0;
}
  103a3b:	c9                   	leave  
  103a3c:	c3                   	ret    
  103a3d:	8d 76 00             	lea    0x0(%esi),%esi
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
  103a40:	01 c1                	add    %eax,%ecx
  103a42:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103a46:	89 44 24 04          	mov    %eax,0x4(%esp)
  103a4a:	8b 42 04             	mov    0x4(%edx),%eax
  103a4d:	89 04 24             	mov    %eax,(%esp)
  103a50:	e8 cb 28 00 00       	call   106320 <allocuvm>
  103a55:	85 c0                	test   %eax,%eax
  103a57:	74 27                	je     103a80 <growproc+0x70>
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
  103a59:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103a60:	eb c7                	jmp    103a29 <growproc+0x19>
  103a62:	01 c1                	add    %eax,%ecx
  103a64:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103a68:	89 44 24 04          	mov    %eax,0x4(%esp)
  103a6c:	8b 42 04             	mov    0x4(%edx),%eax
  103a6f:	89 04 24             	mov    %eax,(%esp)
  103a72:	e8 d9 26 00 00       	call   106150 <deallocuvm>
  103a77:	85 c0                	test   %eax,%eax
  103a79:	75 de                	jne    103a59 <growproc+0x49>
  103a7b:	90                   	nop
  103a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
  103a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  103a85:	c9                   	leave  
  103a86:	c3                   	ret    
  103a87:	89 f6                	mov    %esi,%esi
  103a89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103a90 <userinit>:
}

// Set up first user process.
void
userinit(void)
{
  103a90:	55                   	push   %ebp
  103a91:	89 e5                	mov    %esp,%ebp
  103a93:	53                   	push   %ebx
  103a94:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  103a97:	e8 f4 fb ff ff       	call   103690 <allocproc>
  103a9c:	89 c3                	mov    %eax,%ebx
  initproc = p;
  103a9e:	a3 c8 78 10 00       	mov    %eax,0x1078c8
  if((p->pgdir = setupkvm()) == 0)
  103aa3:	e8 78 25 00 00       	call   106020 <setupkvm>
  103aa8:	85 c0                	test   %eax,%eax
  103aaa:	89 43 04             	mov    %eax,0x4(%ebx)
  103aad:	0f 84 b6 00 00 00    	je     103b69 <userinit+0xd9>
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  103ab3:	89 04 24             	mov    %eax,(%esp)
  103ab6:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
  103abd:	00 
  103abe:	c7 44 24 04 70 77 10 	movl   $0x107770,0x4(%esp)
  103ac5:	00 
  103ac6:	e8 f5 25 00 00       	call   1060c0 <inituvm>
  p->sz = PGSIZE;
  103acb:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
  103ad1:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
  103ad8:	00 
  103ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103ae0:	00 
  103ae1:	8b 43 18             	mov    0x18(%ebx),%eax
  103ae4:	89 04 24             	mov    %eax,(%esp)
  103ae7:	e8 e4 02 00 00       	call   103dd0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  103aec:	8b 43 18             	mov    0x18(%ebx),%eax
  103aef:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  103af5:	8b 43 18             	mov    0x18(%ebx),%eax
  103af8:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
  103afe:	8b 43 18             	mov    0x18(%ebx),%eax
  103b01:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103b05:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
  103b09:	8b 43 18             	mov    0x18(%ebx),%eax
  103b0c:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103b10:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
  103b14:	8b 43 18             	mov    0x18(%ebx),%eax
  103b17:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
  103b1e:	8b 43 18             	mov    0x18(%ebx),%eax
  103b21:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
  103b28:	8b 43 18             	mov    0x18(%ebx),%eax
  103b2b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
  103b32:	8d 43 6c             	lea    0x6c(%ebx),%eax
  103b35:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  103b3c:	00 
  103b3d:	c7 44 24 04 11 6c 10 	movl   $0x106c11,0x4(%esp)
  103b44:	00 
  103b45:	89 04 24             	mov    %eax,(%esp)
  103b48:	e8 23 04 00 00       	call   103f70 <safestrcpy>
  p->cwd = namei("/");
  103b4d:	c7 04 24 1a 6c 10 00 	movl   $0x106c1a,(%esp)
  103b54:	e8 27 e3 ff ff       	call   101e80 <namei>

  p->state = RUNNABLE;
  103b59:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");
  103b60:	89 43 68             	mov    %eax,0x68(%ebx)

  p->state = RUNNABLE;
}
  103b63:	83 c4 14             	add    $0x14,%esp
  103b66:	5b                   	pop    %ebx
  103b67:	5d                   	pop    %ebp
  103b68:	c3                   	ret    
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  103b69:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  103b70:	e8 ab cd ff ff       	call   100920 <panic>
  103b75:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103b79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103b80 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
  103b80:	55                   	push   %ebp
  103b81:	89 e5                	mov    %esp,%ebp
  103b83:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
  103b86:	c7 44 24 04 1c 6c 10 	movl   $0x106c1c,0x4(%esp)
  103b8d:	00 
  103b8e:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103b95:	e8 06 00 00 00       	call   103ba0 <initlock>
}
  103b9a:	c9                   	leave  
  103b9b:	c3                   	ret    
  103b9c:	90                   	nop
  103b9d:	90                   	nop
  103b9e:	90                   	nop
  103b9f:	90                   	nop

00103ba0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  103ba0:	55                   	push   %ebp
  103ba1:	89 e5                	mov    %esp,%ebp
  103ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
  103ba6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
  103ba9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
  103baf:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
  lk->cpu = 0;
  103bb2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
  103bb9:	5d                   	pop    %ebp
  103bba:	c3                   	ret    
  103bbb:	90                   	nop
  103bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103bc0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  103bc0:	55                   	push   %ebp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  103bc1:	31 c0                	xor    %eax,%eax
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  103bc3:	89 e5                	mov    %esp,%ebp
  103bc5:	53                   	push   %ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  103bc6:	8b 55 08             	mov    0x8(%ebp),%edx
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  103bc9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  103bcc:	83 ea 08             	sub    $0x8,%edx
  103bcf:	90                   	nop
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
  103bd0:	8d 8a 00 00 f0 ff    	lea    -0x100000(%edx),%ecx
  103bd6:	81 f9 fe ff ef ff    	cmp    $0xffeffffe,%ecx
  103bdc:	77 1a                	ja     103bf8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
  103bde:	8b 4a 04             	mov    0x4(%edx),%ecx
  103be1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  103be4:	83 c0 01             	add    $0x1,%eax
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  103be7:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  103be9:	83 f8 0a             	cmp    $0xa,%eax
  103bec:	75 e2                	jne    103bd0 <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
  103bee:	5b                   	pop    %ebx
  103bef:	5d                   	pop    %ebp
  103bf0:	c3                   	ret    
  103bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  103bf8:	83 f8 09             	cmp    $0x9,%eax
  103bfb:	7f f1                	jg     103bee <getcallerpcs+0x2e>
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  103bfd:	8d 14 83             	lea    (%ebx,%eax,4),%edx
  }
  for(; i < 10; i++)
  103c00:	83 c0 01             	add    $0x1,%eax
    pcs[i] = 0;
  103c03:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  103c09:	83 c2 04             	add    $0x4,%edx
  103c0c:	83 f8 0a             	cmp    $0xa,%eax
  103c0f:	75 ef                	jne    103c00 <getcallerpcs+0x40>
    pcs[i] = 0;
}
  103c11:	5b                   	pop    %ebx
  103c12:	5d                   	pop    %ebp
  103c13:	c3                   	ret    
  103c14:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103c1a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103c20 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103c20:	55                   	push   %ebp
  return lock->locked && lock->cpu == cpu;
  103c21:	31 c0                	xor    %eax,%eax
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103c23:	89 e5                	mov    %esp,%ebp
  103c25:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
  103c28:	8b 0a                	mov    (%edx),%ecx
  103c2a:	85 c9                	test   %ecx,%ecx
  103c2c:	74 10                	je     103c3e <holding+0x1e>
  103c2e:	8b 42 08             	mov    0x8(%edx),%eax
  103c31:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103c38:	0f 94 c0             	sete   %al
  103c3b:	0f b6 c0             	movzbl %al,%eax
}
  103c3e:	5d                   	pop    %ebp
  103c3f:	c3                   	ret    

00103c40 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
  103c40:	55                   	push   %ebp
  103c41:	89 e5                	mov    %esp,%ebp
  103c43:	53                   	push   %ebx

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103c44:	9c                   	pushf  
  103c45:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103c46:	fa                   	cli    
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103c47:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103c4e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103c54:	8d 48 01             	lea    0x1(%eax),%ecx
  103c57:	85 c0                	test   %eax,%eax
  103c59:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103c5f:	75 12                	jne    103c73 <pushcli+0x33>
    cpu->intena = eflags & FL_IF;
  103c61:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103c67:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103c6d:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  103c73:	5b                   	pop    %ebx
  103c74:	5d                   	pop    %ebp
  103c75:	c3                   	ret    
  103c76:	8d 76 00             	lea    0x0(%esi),%esi
  103c79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103c80 <popcli>:

void
popcli(void)
{
  103c80:	55                   	push   %ebp
  103c81:	89 e5                	mov    %esp,%ebp
  103c83:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103c86:	9c                   	pushf  
  103c87:	58                   	pop    %eax
  if(readeflags()&FL_IF)
  103c88:	f6 c4 02             	test   $0x2,%ah
  103c8b:	75 43                	jne    103cd0 <popcli+0x50>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
  103c8d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103c94:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103c9a:	83 e8 01             	sub    $0x1,%eax
  103c9d:	85 c0                	test   %eax,%eax
  103c9f:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
  103ca5:	78 1d                	js     103cc4 <popcli+0x44>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
  103ca7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103cad:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
  103cb3:	85 d2                	test   %edx,%edx
  103cb5:	75 0b                	jne    103cc2 <popcli+0x42>
  103cb7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  103cbd:	85 c0                	test   %eax,%eax
  103cbf:	74 01                	je     103cc2 <popcli+0x42>
}

static inline void
sti(void)
{
  asm volatile("sti");
  103cc1:	fb                   	sti    
    sti();
}
  103cc2:	c9                   	leave  
  103cc3:	c3                   	ret    
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
    panic("popcli");
  103cc4:	c7 04 24 7f 6c 10 00 	movl   $0x106c7f,(%esp)
  103ccb:	e8 50 cc ff ff       	call   100920 <panic>

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  103cd0:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103cd7:	e8 44 cc ff ff       	call   100920 <panic>
  103cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103ce0 <release>:
}

// Release the lock.
void
release(struct spinlock *lk)
{
  103ce0:	55                   	push   %ebp
  103ce1:	89 e5                	mov    %esp,%ebp
  103ce3:	83 ec 18             	sub    $0x18,%esp
  103ce6:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103ce9:	8b 0a                	mov    (%edx),%ecx
  103ceb:	85 c9                	test   %ecx,%ecx
  103ced:	74 0c                	je     103cfb <release+0x1b>
  103cef:	8b 42 08             	mov    0x8(%edx),%eax
  103cf2:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103cf9:	74 0d                	je     103d08 <release+0x28>
// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");
  103cfb:	c7 04 24 86 6c 10 00 	movl   $0x106c86,(%esp)
  103d02:	e8 19 cc ff ff       	call   100920 <panic>
  103d07:	90                   	nop

  lk->pcs[0] = 0;
  103d08:	c7 42 0c 00 00 00 00 	movl   $0x0,0xc(%edx)
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103d0f:	31 c0                	xor    %eax,%eax
  lk->cpu = 0;
  103d11:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
  103d18:	f0 87 02             	lock xchg %eax,(%edx)
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
}
  103d1b:	c9                   	leave  
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
  103d1c:	e9 5f ff ff ff       	jmp    103c80 <popcli>
  103d21:	eb 0d                	jmp    103d30 <acquire>
  103d23:	90                   	nop
  103d24:	90                   	nop
  103d25:	90                   	nop
  103d26:	90                   	nop
  103d27:	90                   	nop
  103d28:	90                   	nop
  103d29:	90                   	nop
  103d2a:	90                   	nop
  103d2b:	90                   	nop
  103d2c:	90                   	nop
  103d2d:	90                   	nop
  103d2e:	90                   	nop
  103d2f:	90                   	nop

00103d30 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  103d30:	55                   	push   %ebp
  103d31:	89 e5                	mov    %esp,%ebp
  103d33:	53                   	push   %ebx
  103d34:	83 ec 14             	sub    $0x14,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103d37:	9c                   	pushf  
  103d38:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103d39:	fa                   	cli    
{
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103d3a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103d41:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103d47:	8d 48 01             	lea    0x1(%eax),%ecx
  103d4a:	85 c0                	test   %eax,%eax
  103d4c:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103d52:	75 12                	jne    103d66 <acquire+0x36>
    cpu->intena = eflags & FL_IF;
  103d54:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103d5a:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103d60:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
  103d66:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103d69:	8b 1a                	mov    (%edx),%ebx
  103d6b:	85 db                	test   %ebx,%ebx
  103d6d:	74 0c                	je     103d7b <acquire+0x4b>
  103d6f:	8b 42 08             	mov    0x8(%edx),%eax
  103d72:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103d79:	74 45                	je     103dc0 <acquire+0x90>
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103d7b:	b9 01 00 00 00       	mov    $0x1,%ecx
  103d80:	eb 09                	jmp    103d8b <acquire+0x5b>
  103d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
  103d88:	8b 55 08             	mov    0x8(%ebp),%edx
  103d8b:	89 c8                	mov    %ecx,%eax
  103d8d:	f0 87 02             	lock xchg %eax,(%edx)
  103d90:	85 c0                	test   %eax,%eax
  103d92:	75 f4                	jne    103d88 <acquire+0x58>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
  103d94:	8b 45 08             	mov    0x8(%ebp),%eax
  103d97:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103d9e:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
  103da1:	8b 45 08             	mov    0x8(%ebp),%eax
  103da4:	83 c0 0c             	add    $0xc,%eax
  103da7:	89 44 24 04          	mov    %eax,0x4(%esp)
  103dab:	8d 45 08             	lea    0x8(%ebp),%eax
  103dae:	89 04 24             	mov    %eax,(%esp)
  103db1:	e8 0a fe ff ff       	call   103bc0 <getcallerpcs>
}
  103db6:	83 c4 14             	add    $0x14,%esp
  103db9:	5b                   	pop    %ebx
  103dba:	5d                   	pop    %ebp
  103dbb:	c3                   	ret    
  103dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");
  103dc0:	c7 04 24 8e 6c 10 00 	movl   $0x106c8e,(%esp)
  103dc7:	e8 54 cb ff ff       	call   100920 <panic>
  103dcc:	90                   	nop
  103dcd:	90                   	nop
  103dce:	90                   	nop
  103dcf:	90                   	nop

00103dd0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
  103dd0:	55                   	push   %ebp
  103dd1:	89 e5                	mov    %esp,%ebp
  103dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  103dd6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  103dd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  103ddd:	89 d7                	mov    %edx,%edi
  103ddf:	fc                   	cld    
  103de0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  103de2:	89 d0                	mov    %edx,%eax
  103de4:	5f                   	pop    %edi
  103de5:	5d                   	pop    %ebp
  103de6:	c3                   	ret    
  103de7:	89 f6                	mov    %esi,%esi
  103de9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103df0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
  103df0:	55                   	push   %ebp
  103df1:	89 e5                	mov    %esp,%ebp
  103df3:	57                   	push   %edi
  103df4:	56                   	push   %esi
  103df5:	53                   	push   %ebx
  103df6:	8b 55 10             	mov    0x10(%ebp),%edx
  103df9:	8b 75 08             	mov    0x8(%ebp),%esi
  103dfc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103dff:	85 d2                	test   %edx,%edx
  103e01:	74 2d                	je     103e30 <memcmp+0x40>
    if(*s1 != *s2)
  103e03:	0f b6 1e             	movzbl (%esi),%ebx
  103e06:	0f b6 0f             	movzbl (%edi),%ecx
  103e09:	38 cb                	cmp    %cl,%bl
  103e0b:	75 2b                	jne    103e38 <memcmp+0x48>
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103e0d:	83 ea 01             	sub    $0x1,%edx
  103e10:	31 c0                	xor    %eax,%eax
  103e12:	eb 18                	jmp    103e2c <memcmp+0x3c>
  103e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s1 != *s2)
  103e18:	0f b6 5c 06 01       	movzbl 0x1(%esi,%eax,1),%ebx
  103e1d:	83 ea 01             	sub    $0x1,%edx
  103e20:	0f b6 4c 07 01       	movzbl 0x1(%edi,%eax,1),%ecx
  103e25:	83 c0 01             	add    $0x1,%eax
  103e28:	38 cb                	cmp    %cl,%bl
  103e2a:	75 0c                	jne    103e38 <memcmp+0x48>
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103e2c:	85 d2                	test   %edx,%edx
  103e2e:	75 e8                	jne    103e18 <memcmp+0x28>
  103e30:	31 c0                	xor    %eax,%eax
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
  103e32:	5b                   	pop    %ebx
  103e33:	5e                   	pop    %esi
  103e34:	5f                   	pop    %edi
  103e35:	5d                   	pop    %ebp
  103e36:	c3                   	ret    
  103e37:	90                   	nop
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
  103e38:	0f b6 c3             	movzbl %bl,%eax
  103e3b:	0f b6 c9             	movzbl %cl,%ecx
  103e3e:	29 c8                	sub    %ecx,%eax
    s1++, s2++;
  }

  return 0;
}
  103e40:	5b                   	pop    %ebx
  103e41:	5e                   	pop    %esi
  103e42:	5f                   	pop    %edi
  103e43:	5d                   	pop    %ebp
  103e44:	c3                   	ret    
  103e45:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103e49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103e50 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
  103e50:	55                   	push   %ebp
  103e51:	89 e5                	mov    %esp,%ebp
  103e53:	57                   	push   %edi
  103e54:	56                   	push   %esi
  103e55:	53                   	push   %ebx
  103e56:	8b 45 08             	mov    0x8(%ebp),%eax
  103e59:	8b 75 0c             	mov    0xc(%ebp),%esi
  103e5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
  103e5f:	39 c6                	cmp    %eax,%esi
  103e61:	73 2d                	jae    103e90 <memmove+0x40>
  103e63:	8d 3c 1e             	lea    (%esi,%ebx,1),%edi
  103e66:	39 f8                	cmp    %edi,%eax
  103e68:	73 26                	jae    103e90 <memmove+0x40>
    s += n;
    d += n;
    while(n-- > 0)
  103e6a:	85 db                	test   %ebx,%ebx
  103e6c:	74 1d                	je     103e8b <memmove+0x3b>

  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
  103e6e:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  103e71:	31 d2                	xor    %edx,%edx
  103e73:	90                   	nop
  103e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
      *--d = *--s;
  103e78:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  103e7d:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  103e81:	83 ea 01             	sub    $0x1,%edx
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103e84:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  103e87:	85 c9                	test   %ecx,%ecx
  103e89:	75 ed                	jne    103e78 <memmove+0x28>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
  103e8b:	5b                   	pop    %ebx
  103e8c:	5e                   	pop    %esi
  103e8d:	5f                   	pop    %edi
  103e8e:	5d                   	pop    %ebp
  103e8f:	c3                   	ret    
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103e90:	31 d2                	xor    %edx,%edx
      *--d = *--s;
  } else
    while(n-- > 0)
  103e92:	85 db                	test   %ebx,%ebx
  103e94:	74 f5                	je     103e8b <memmove+0x3b>
  103e96:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
  103e98:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  103e9c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  103e9f:	83 c2 01             	add    $0x1,%edx
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
  103ea2:	39 d3                	cmp    %edx,%ebx
  103ea4:	75 f2                	jne    103e98 <memmove+0x48>
      *d++ = *s++;

  return dst;
}
  103ea6:	5b                   	pop    %ebx
  103ea7:	5e                   	pop    %esi
  103ea8:	5f                   	pop    %edi
  103ea9:	5d                   	pop    %ebp
  103eaa:	c3                   	ret    
  103eab:	90                   	nop
  103eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103eb0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  103eb0:	55                   	push   %ebp
  103eb1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
  103eb3:	5d                   	pop    %ebp

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
  103eb4:	e9 97 ff ff ff       	jmp    103e50 <memmove>
  103eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103ec0 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
  103ec0:	55                   	push   %ebp
  103ec1:	89 e5                	mov    %esp,%ebp
  103ec3:	57                   	push   %edi
  103ec4:	56                   	push   %esi
  103ec5:	53                   	push   %ebx
  103ec6:	8b 7d 10             	mov    0x10(%ebp),%edi
  103ec9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103ecc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  while(n > 0 && *p && *p == *q)
  103ecf:	85 ff                	test   %edi,%edi
  103ed1:	74 3d                	je     103f10 <strncmp+0x50>
  103ed3:	0f b6 01             	movzbl (%ecx),%eax
  103ed6:	84 c0                	test   %al,%al
  103ed8:	75 18                	jne    103ef2 <strncmp+0x32>
  103eda:	eb 3c                	jmp    103f18 <strncmp+0x58>
  103edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103ee0:	83 ef 01             	sub    $0x1,%edi
  103ee3:	74 2b                	je     103f10 <strncmp+0x50>
    n--, p++, q++;
  103ee5:	83 c1 01             	add    $0x1,%ecx
  103ee8:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103eeb:	0f b6 01             	movzbl (%ecx),%eax
  103eee:	84 c0                	test   %al,%al
  103ef0:	74 26                	je     103f18 <strncmp+0x58>
  103ef2:	0f b6 33             	movzbl (%ebx),%esi
  103ef5:	89 f2                	mov    %esi,%edx
  103ef7:	38 d0                	cmp    %dl,%al
  103ef9:	74 e5                	je     103ee0 <strncmp+0x20>
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
  103efb:	81 e6 ff 00 00 00    	and    $0xff,%esi
  103f01:	0f b6 c0             	movzbl %al,%eax
  103f04:	29 f0                	sub    %esi,%eax
}
  103f06:	5b                   	pop    %ebx
  103f07:	5e                   	pop    %esi
  103f08:	5f                   	pop    %edi
  103f09:	5d                   	pop    %ebp
  103f0a:	c3                   	ret    
  103f0b:	90                   	nop
  103f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103f10:	31 c0                	xor    %eax,%eax
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
  103f12:	5b                   	pop    %ebx
  103f13:	5e                   	pop    %esi
  103f14:	5f                   	pop    %edi
  103f15:	5d                   	pop    %ebp
  103f16:	c3                   	ret    
  103f17:	90                   	nop
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103f18:	0f b6 33             	movzbl (%ebx),%esi
  103f1b:	eb de                	jmp    103efb <strncmp+0x3b>
  103f1d:	8d 76 00             	lea    0x0(%esi),%esi

00103f20 <strncpy>:
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
{
  103f20:	55                   	push   %ebp
  103f21:	89 e5                	mov    %esp,%ebp
  103f23:	8b 45 08             	mov    0x8(%ebp),%eax
  103f26:	56                   	push   %esi
  103f27:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103f2a:	53                   	push   %ebx
  103f2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  103f2e:	89 c3                	mov    %eax,%ebx
  103f30:	eb 09                	jmp    103f3b <strncpy+0x1b>
  103f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  103f38:	83 c6 01             	add    $0x1,%esi
  103f3b:	83 e9 01             	sub    $0x1,%ecx
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  103f3e:	8d 51 01             	lea    0x1(%ecx),%edx
{
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  103f41:	85 d2                	test   %edx,%edx
  103f43:	7e 0c                	jle    103f51 <strncpy+0x31>
  103f45:	0f b6 16             	movzbl (%esi),%edx
  103f48:	88 13                	mov    %dl,(%ebx)
  103f4a:	83 c3 01             	add    $0x1,%ebx
  103f4d:	84 d2                	test   %dl,%dl
  103f4f:	75 e7                	jne    103f38 <strncpy+0x18>
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  103f51:	31 d2                	xor    %edx,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  103f53:	85 c9                	test   %ecx,%ecx
  103f55:	7e 0c                	jle    103f63 <strncpy+0x43>
  103f57:	90                   	nop
    *s++ = 0;
  103f58:	c6 04 13 00          	movb   $0x0,(%ebx,%edx,1)
  103f5c:	83 c2 01             	add    $0x1,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  103f5f:	39 ca                	cmp    %ecx,%edx
  103f61:	75 f5                	jne    103f58 <strncpy+0x38>
    *s++ = 0;
  return os;
}
  103f63:	5b                   	pop    %ebx
  103f64:	5e                   	pop    %esi
  103f65:	5d                   	pop    %ebp
  103f66:	c3                   	ret    
  103f67:	89 f6                	mov    %esi,%esi
  103f69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103f70 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
  103f70:	55                   	push   %ebp
  103f71:	89 e5                	mov    %esp,%ebp
  103f73:	8b 55 10             	mov    0x10(%ebp),%edx
  103f76:	56                   	push   %esi
  103f77:	8b 45 08             	mov    0x8(%ebp),%eax
  103f7a:	53                   	push   %ebx
  103f7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *os;
  
  os = s;
  if(n <= 0)
  103f7e:	85 d2                	test   %edx,%edx
  103f80:	7e 1f                	jle    103fa1 <safestrcpy+0x31>
  103f82:	89 c1                	mov    %eax,%ecx
  103f84:	eb 05                	jmp    103f8b <safestrcpy+0x1b>
  103f86:	66 90                	xchg   %ax,%ax
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
  103f88:	83 c6 01             	add    $0x1,%esi
  103f8b:	83 ea 01             	sub    $0x1,%edx
  103f8e:	85 d2                	test   %edx,%edx
  103f90:	7e 0c                	jle    103f9e <safestrcpy+0x2e>
  103f92:	0f b6 1e             	movzbl (%esi),%ebx
  103f95:	88 19                	mov    %bl,(%ecx)
  103f97:	83 c1 01             	add    $0x1,%ecx
  103f9a:	84 db                	test   %bl,%bl
  103f9c:	75 ea                	jne    103f88 <safestrcpy+0x18>
    ;
  *s = 0;
  103f9e:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
  103fa1:	5b                   	pop    %ebx
  103fa2:	5e                   	pop    %esi
  103fa3:	5d                   	pop    %ebp
  103fa4:	c3                   	ret    
  103fa5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103fa9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103fb0 <strlen>:

int
strlen(const char *s)
{
  103fb0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
  103fb1:	31 c0                	xor    %eax,%eax
  return os;
}

int
strlen(const char *s)
{
  103fb3:	89 e5                	mov    %esp,%ebp
  103fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
  103fb8:	80 3a 00             	cmpb   $0x0,(%edx)
  103fbb:	74 0c                	je     103fc9 <strlen+0x19>
  103fbd:	8d 76 00             	lea    0x0(%esi),%esi
  103fc0:	83 c0 01             	add    $0x1,%eax
  103fc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  103fc7:	75 f7                	jne    103fc0 <strlen+0x10>
    ;
  return n;
}
  103fc9:	5d                   	pop    %ebp
  103fca:	c3                   	ret    
  103fcb:	90                   	nop

00103fcc <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
  103fcc:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
  103fd0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
  103fd4:	55                   	push   %ebp
  pushl %ebx
  103fd5:	53                   	push   %ebx
  pushl %esi
  103fd6:	56                   	push   %esi
  pushl %edi
  103fd7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
  103fd8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
  103fda:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
  103fdc:	5f                   	pop    %edi
  popl %esi
  103fdd:	5e                   	pop    %esi
  popl %ebx
  103fde:	5b                   	pop    %ebx
  popl %ebp
  103fdf:	5d                   	pop    %ebp
  ret
  103fe0:	c3                   	ret    
  103fe1:	90                   	nop
  103fe2:	90                   	nop
  103fe3:	90                   	nop
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

00103ff0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  103ff0:	55                   	push   %ebp
  103ff1:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
  103ff3:	8b 55 08             	mov    0x8(%ebp),%edx
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  103ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(addr >= p->sz || addr+4 > p->sz)
  103ff9:	8b 12                	mov    (%edx),%edx
  103ffb:	39 c2                	cmp    %eax,%edx
  103ffd:	77 09                	ja     104008 <fetchint+0x18>
    return -1;
  *ip = *(int*)(addr);
  return 0;
  103fff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104004:	5d                   	pop    %ebp
  104005:	c3                   	ret    
  104006:	66 90                	xchg   %ax,%ax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  104008:	8d 48 04             	lea    0x4(%eax),%ecx
  10400b:	39 ca                	cmp    %ecx,%edx
  10400d:	72 f0                	jb     103fff <fetchint+0xf>
    return -1;
  *ip = *(int*)(addr);
  10400f:	8b 10                	mov    (%eax),%edx
  104011:	8b 45 10             	mov    0x10(%ebp),%eax
  104014:	89 10                	mov    %edx,(%eax)
  104016:	31 c0                	xor    %eax,%eax
  return 0;
}
  104018:	5d                   	pop    %ebp
  104019:	c3                   	ret    
  10401a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00104020 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  104020:	55                   	push   %ebp
  104021:	89 e5                	mov    %esp,%ebp
  104023:	8b 45 08             	mov    0x8(%ebp),%eax
  104026:	8b 55 0c             	mov    0xc(%ebp),%edx
  104029:	53                   	push   %ebx
  char *s, *ep;

  if(addr >= p->sz)
  10402a:	39 10                	cmp    %edx,(%eax)
  10402c:	77 0a                	ja     104038 <fetchstr+0x18>
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  10402e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    if(*s == 0)
      return s - *pp;
  return -1;
}
  104033:	5b                   	pop    %ebx
  104034:	5d                   	pop    %ebp
  104035:	c3                   	ret    
  104036:	66 90                	xchg   %ax,%ax
{
  char *s, *ep;

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  104038:	8b 4d 10             	mov    0x10(%ebp),%ecx
  10403b:	89 11                	mov    %edx,(%ecx)
  ep = (char*)p->sz;
  10403d:	8b 18                	mov    (%eax),%ebx
  for(s = *pp; s < ep; s++)
  10403f:	39 da                	cmp    %ebx,%edx
  104041:	73 eb                	jae    10402e <fetchstr+0xe>
    if(*s == 0)
  104043:	31 c0                	xor    %eax,%eax
  104045:	89 d1                	mov    %edx,%ecx
  104047:	80 3a 00             	cmpb   $0x0,(%edx)
  10404a:	74 e7                	je     104033 <fetchstr+0x13>
  10404c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  104050:	83 c1 01             	add    $0x1,%ecx
  104053:	39 cb                	cmp    %ecx,%ebx
  104055:	76 d7                	jbe    10402e <fetchstr+0xe>
    if(*s == 0)
  104057:	80 39 00             	cmpb   $0x0,(%ecx)
  10405a:	75 f4                	jne    104050 <fetchstr+0x30>
  10405c:	89 c8                	mov    %ecx,%eax
  10405e:	29 d0                	sub    %edx,%eax
  104060:	eb d1                	jmp    104033 <fetchstr+0x13>
  104062:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  104069:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104070 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  104070:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  104076:	55                   	push   %ebp
  104077:	89 e5                	mov    %esp,%ebp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  104079:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10407c:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  10407f:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  104081:	8b 52 44             	mov    0x44(%edx),%edx
  104084:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  104088:	39 c2                	cmp    %eax,%edx
  10408a:	72 0c                	jb     104098 <argint+0x28>
    return -1;
  *ip = *(int*)(addr);
  10408c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  104091:	5d                   	pop    %ebp
  104092:	c3                   	ret    
  104093:	90                   	nop
  104094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  104098:	8d 4a 04             	lea    0x4(%edx),%ecx
  10409b:	39 c8                	cmp    %ecx,%eax
  10409d:	72 ed                	jb     10408c <argint+0x1c>
    return -1;
  *ip = *(int*)(addr);
  10409f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1040a2:	8b 12                	mov    (%edx),%edx
  1040a4:	89 10                	mov    %edx,(%eax)
  1040a6:	31 c0                	xor    %eax,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  1040a8:	5d                   	pop    %ebp
  1040a9:	c3                   	ret    
  1040aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001040b0 <argptr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1040b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
  1040b6:	55                   	push   %ebp
  1040b7:	89 e5                	mov    %esp,%ebp

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1040b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1040bc:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1040bf:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1040c1:	8b 52 44             	mov    0x44(%edx),%edx
  1040c4:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1040c8:	39 c2                	cmp    %eax,%edx
  1040ca:	73 07                	jae    1040d3 <argptr+0x23>
  1040cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  1040cf:	39 c8                	cmp    %ecx,%eax
  1040d1:	73 0d                	jae    1040e0 <argptr+0x30>
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
    return -1;
  *pp = (char*)i;
  return 0;
  1040d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1040d8:	5d                   	pop    %ebp
  1040d9:	c3                   	ret    
  1040da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  1040e0:	8b 12                	mov    (%edx),%edx
{
  int i;
  
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
  1040e2:	39 c2                	cmp    %eax,%edx
  1040e4:	73 ed                	jae    1040d3 <argptr+0x23>
  1040e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  1040e9:	01 d1                	add    %edx,%ecx
  1040eb:	39 c1                	cmp    %eax,%ecx
  1040ed:	77 e4                	ja     1040d3 <argptr+0x23>
    return -1;
  *pp = (char*)i;
  1040ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1040f2:	89 10                	mov    %edx,(%eax)
  1040f4:	31 c0                	xor    %eax,%eax
  return 0;
}
  1040f6:	5d                   	pop    %ebp
  1040f7:	c3                   	ret    
  1040f8:	90                   	nop
  1040f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104100 <argstr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  104100:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
  104107:	55                   	push   %ebp
  104108:	89 e5                	mov    %esp,%ebp
  10410a:	53                   	push   %ebx

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  10410b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10410e:	8b 42 18             	mov    0x18(%edx),%eax
  104111:	8b 40 44             	mov    0x44(%eax),%eax
  104114:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  104118:	8b 0a                	mov    (%edx),%ecx
  10411a:	39 c8                	cmp    %ecx,%eax
  10411c:	73 07                	jae    104125 <argstr+0x25>
  10411e:	8d 58 04             	lea    0x4(%eax),%ebx
  104121:	39 d9                	cmp    %ebx,%ecx
  104123:	73 0b                	jae    104130 <argstr+0x30>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  104125:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  10412a:	5b                   	pop    %ebx
  10412b:	5d                   	pop    %ebp
  10412c:	c3                   	ret    
  10412d:	8d 76 00             	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  104130:	8b 18                	mov    (%eax),%ebx
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  char *s, *ep;

  if(addr >= p->sz)
  104132:	39 cb                	cmp    %ecx,%ebx
  104134:	73 ef                	jae    104125 <argstr+0x25>
    return -1;
  *pp = (char*)addr;
  104136:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  104139:	89 d8                	mov    %ebx,%eax
  10413b:	89 19                	mov    %ebx,(%ecx)
  ep = (char*)p->sz;
  10413d:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
  10413f:	39 d3                	cmp    %edx,%ebx
  104141:	73 e2                	jae    104125 <argstr+0x25>
    if(*s == 0)
  104143:	80 3b 00             	cmpb   $0x0,(%ebx)
  104146:	75 12                	jne    10415a <argstr+0x5a>
  104148:	eb 1e                	jmp    104168 <argstr+0x68>
  10414a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104150:	80 38 00             	cmpb   $0x0,(%eax)
  104153:	90                   	nop
  104154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104158:	74 0e                	je     104168 <argstr+0x68>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  10415a:	83 c0 01             	add    $0x1,%eax
  10415d:	39 c2                	cmp    %eax,%edx
  10415f:	90                   	nop
  104160:	77 ee                	ja     104150 <argstr+0x50>
  104162:	eb c1                	jmp    104125 <argstr+0x25>
  104164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
      return s - *pp;
  104168:	29 d8                	sub    %ebx,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  10416a:	5b                   	pop    %ebx
  10416b:	5d                   	pop    %ebp
  10416c:	c3                   	ret    
  10416d:	8d 76 00             	lea    0x0(%esi),%esi

00104170 <syscall>:
[SYS_clone]   sys_clone,
};

void
syscall(void)
{
  104170:	55                   	push   %ebp
  104171:	89 e5                	mov    %esp,%ebp
  104173:	53                   	push   %ebx
  104174:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
  104177:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10417e:	8b 5a 18             	mov    0x18(%edx),%ebx
  104181:	8b 43 1c             	mov    0x1c(%ebx),%eax
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
  104184:	83 f8 16             	cmp    $0x16,%eax
  104187:	77 17                	ja     1041a0 <syscall+0x30>
  104189:	8b 0c 85 c0 6c 10 00 	mov    0x106cc0(,%eax,4),%ecx
  104190:	85 c9                	test   %ecx,%ecx
  104192:	74 0c                	je     1041a0 <syscall+0x30>
    proc->tf->eax = syscalls[num]();
  104194:	ff d1                	call   *%ecx
  104196:	89 43 1c             	mov    %eax,0x1c(%ebx)
  else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
  104199:	83 c4 14             	add    $0x14,%esp
  10419c:	5b                   	pop    %ebx
  10419d:	5d                   	pop    %ebp
  10419e:	c3                   	ret    
  10419f:	90                   	nop

  num = proc->tf->eax;
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
    proc->tf->eax = syscalls[num]();
  else {
    cprintf("%d %s: unknown sys call %d\n",
  1041a0:	8b 4a 10             	mov    0x10(%edx),%ecx
  1041a3:	83 c2 6c             	add    $0x6c,%edx
  1041a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1041aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  1041ae:	c7 04 24 96 6c 10 00 	movl   $0x106c96,(%esp)
  1041b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  1041b9:	e8 72 c3 ff ff       	call   100530 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  1041be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1041c4:	8b 40 18             	mov    0x18(%eax),%eax
  1041c7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
  1041ce:	83 c4 14             	add    $0x14,%esp
  1041d1:	5b                   	pop    %ebx
  1041d2:	5d                   	pop    %ebp
  1041d3:	c3                   	ret    
  1041d4:	90                   	nop
  1041d5:	90                   	nop
  1041d6:	90                   	nop
  1041d7:	90                   	nop
  1041d8:	90                   	nop
  1041d9:	90                   	nop
  1041da:	90                   	nop
  1041db:	90                   	nop
  1041dc:	90                   	nop
  1041dd:	90                   	nop
  1041de:	90                   	nop
  1041df:	90                   	nop

001041e0 <sys_pipe>:
  return exec(path, argv);
}

int
sys_pipe(void)
{
  1041e0:	55                   	push   %ebp
  1041e1:	89 e5                	mov    %esp,%ebp
  1041e3:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  1041e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return exec(path, argv);
}

int
sys_pipe(void)
{
  1041e9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  1041ec:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  1041ef:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  1041f6:	00 
  1041f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1041fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104202:	e8 a9 fe ff ff       	call   1040b0 <argptr>
  104207:	85 c0                	test   %eax,%eax
  104209:	79 15                	jns    104220 <sys_pipe+0x40>
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  10420b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
}
  104210:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  104213:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104216:	89 ec                	mov    %ebp,%esp
  104218:	5d                   	pop    %ebp
  104219:	c3                   	ret    
  10421a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
  104220:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104223:	89 44 24 04          	mov    %eax,0x4(%esp)
  104227:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10422a:	89 04 24             	mov    %eax,(%esp)
  10422d:	e8 ee ec ff ff       	call   102f20 <pipealloc>
  104232:	85 c0                	test   %eax,%eax
  104234:	78 d5                	js     10420b <sys_pipe+0x2b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  104236:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  104239:	31 c0                	xor    %eax,%eax
  10423b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104248:	8b 5c 82 28          	mov    0x28(%edx,%eax,4),%ebx
  10424c:	85 db                	test   %ebx,%ebx
  10424e:	74 28                	je     104278 <sys_pipe+0x98>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104250:	83 c0 01             	add    $0x1,%eax
  104253:	83 f8 10             	cmp    $0x10,%eax
  104256:	75 f0                	jne    104248 <sys_pipe+0x68>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
  104258:	89 0c 24             	mov    %ecx,(%esp)
  10425b:	e8 40 cd ff ff       	call   100fa0 <fileclose>
    fileclose(wf);
  104260:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104263:	89 04 24             	mov    %eax,(%esp)
  104266:	e8 35 cd ff ff       	call   100fa0 <fileclose>
  10426b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104270:	eb 9e                	jmp    104210 <sys_pipe+0x30>
  104272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  104278:	8d 58 08             	lea    0x8(%eax),%ebx
  10427b:	89 4c 9a 08          	mov    %ecx,0x8(%edx,%ebx,4)
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  10427f:	8b 75 ec             	mov    -0x14(%ebp),%esi
  104282:	31 d2                	xor    %edx,%edx
  104284:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  10428b:	90                   	nop
  10428c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104290:	83 7c 91 28 00       	cmpl   $0x0,0x28(%ecx,%edx,4)
  104295:	74 19                	je     1042b0 <sys_pipe+0xd0>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104297:	83 c2 01             	add    $0x1,%edx
  10429a:	83 fa 10             	cmp    $0x10,%edx
  10429d:	75 f1                	jne    104290 <sys_pipe+0xb0>
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
  10429f:	c7 44 99 08 00 00 00 	movl   $0x0,0x8(%ecx,%ebx,4)
  1042a6:	00 
  1042a7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1042aa:	eb ac                	jmp    104258 <sys_pipe+0x78>
  1042ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1042b0:	89 74 91 28          	mov    %esi,0x28(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
  1042b4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1042b7:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
  1042b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042bc:	89 50 04             	mov    %edx,0x4(%eax)
  1042bf:	31 c0                	xor    %eax,%eax
  return 0;
  1042c1:	e9 4a ff ff ff       	jmp    104210 <sys_pipe+0x30>
  1042c6:	8d 76 00             	lea    0x0(%esi),%esi
  1042c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001042d0 <sys_exec>:
  return 0;
}

int
sys_exec(void)
{
  1042d0:	55                   	push   %ebp
  1042d1:	89 e5                	mov    %esp,%ebp
  1042d3:	81 ec b8 00 00 00    	sub    $0xb8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  1042d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 0;
}

int
sys_exec(void)
{
  1042dc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1042df:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1042e2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  1042e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1042e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1042f0:	e8 0b fe ff ff       	call   104100 <argstr>
  1042f5:	85 c0                	test   %eax,%eax
  1042f7:	79 17                	jns    104310 <sys_exec+0x40>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv))
  1042f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
}
  1042fe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  104301:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104304:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104307:	89 ec                	mov    %ebp,%esp
  104309:	5d                   	pop    %ebp
  10430a:	c3                   	ret    
  10430b:	90                   	nop
  10430c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  104310:	8d 45 e0             	lea    -0x20(%ebp),%eax
  104313:	89 44 24 04          	mov    %eax,0x4(%esp)
  104317:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10431e:	e8 4d fd ff ff       	call   104070 <argint>
  104323:	85 c0                	test   %eax,%eax
  104325:	78 d2                	js     1042f9 <sys_exec+0x29>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  104327:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  10432d:	31 f6                	xor    %esi,%esi
  10432f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  104336:	00 
  104337:	31 db                	xor    %ebx,%ebx
  104339:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104340:	00 
  104341:	89 3c 24             	mov    %edi,(%esp)
  104344:	e8 87 fa ff ff       	call   103dd0 <memset>
  104349:	eb 2c                	jmp    104377 <sys_exec+0xa7>
  10434b:	90                   	nop
  10434c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
  104350:	89 44 24 04          	mov    %eax,0x4(%esp)
  104354:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10435a:	8d 14 b7             	lea    (%edi,%esi,4),%edx
  10435d:	89 54 24 08          	mov    %edx,0x8(%esp)
  104361:	89 04 24             	mov    %eax,(%esp)
  104364:	e8 b7 fc ff ff       	call   104020 <fetchstr>
  104369:	85 c0                	test   %eax,%eax
  10436b:	78 8c                	js     1042f9 <sys_exec+0x29>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  10436d:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
  104370:	83 fb 20             	cmp    $0x20,%ebx

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  104373:	89 de                	mov    %ebx,%esi
    if(i >= NELEM(argv))
  104375:	74 82                	je     1042f9 <sys_exec+0x29>
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
  104377:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10437a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10437e:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  104385:	03 45 e0             	add    -0x20(%ebp),%eax
  104388:	89 44 24 04          	mov    %eax,0x4(%esp)
  10438c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104392:	89 04 24             	mov    %eax,(%esp)
  104395:	e8 56 fc ff ff       	call   103ff0 <fetchint>
  10439a:	85 c0                	test   %eax,%eax
  10439c:	0f 88 57 ff ff ff    	js     1042f9 <sys_exec+0x29>
      return -1;
    if(uarg == 0){
  1043a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043a5:	85 c0                	test   %eax,%eax
  1043a7:	75 a7                	jne    104350 <sys_exec+0x80>
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  1043a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
  1043ac:	c7 84 9d 5c ff ff ff 	movl   $0x0,-0xa4(%ebp,%ebx,4)
  1043b3:	00 00 00 00 
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  1043b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1043bb:	89 04 24             	mov    %eax,(%esp)
  1043be:	e8 dd c5 ff ff       	call   1009a0 <exec>
  1043c3:	e9 36 ff ff ff       	jmp    1042fe <sys_exec+0x2e>
  1043c8:	90                   	nop
  1043c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001043d0 <sys_chdir>:
  return 0;
}

int
sys_chdir(void)
{
  1043d0:	55                   	push   %ebp
  1043d1:	89 e5                	mov    %esp,%ebp
  1043d3:	53                   	push   %ebx
  1043d4:	83 ec 24             	sub    $0x24,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  1043d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1043da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1043de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1043e5:	e8 16 fd ff ff       	call   104100 <argstr>
  1043ea:	85 c0                	test   %eax,%eax
  1043ec:	79 12                	jns    104400 <sys_chdir+0x30>
    return -1;
  }
  iunlock(ip);
  iput(proc->cwd);
  proc->cwd = ip;
  return 0;
  1043ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1043f3:	83 c4 24             	add    $0x24,%esp
  1043f6:	5b                   	pop    %ebx
  1043f7:	5d                   	pop    %ebp
  1043f8:	c3                   	ret    
  1043f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
sys_chdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  104400:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104403:	89 04 24             	mov    %eax,(%esp)
  104406:	e8 75 da ff ff       	call   101e80 <namei>
  10440b:	85 c0                	test   %eax,%eax
  10440d:	89 c3                	mov    %eax,%ebx
  10440f:	74 dd                	je     1043ee <sys_chdir+0x1e>
    return -1;
  ilock(ip);
  104411:	89 04 24             	mov    %eax,(%esp)
  104414:	e8 c7 d7 ff ff       	call   101be0 <ilock>
  if(ip->type != T_DIR){
  104419:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10441e:	75 26                	jne    104446 <sys_chdir+0x76>
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  104420:	89 1c 24             	mov    %ebx,(%esp)
  104423:	e8 78 d3 ff ff       	call   1017a0 <iunlock>
  iput(proc->cwd);
  104428:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10442e:	8b 40 68             	mov    0x68(%eax),%eax
  104431:	89 04 24             	mov    %eax,(%esp)
  104434:	e8 77 d4 ff ff       	call   1018b0 <iput>
  proc->cwd = ip;
  104439:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10443f:	89 58 68             	mov    %ebx,0x68(%eax)
  104442:	31 c0                	xor    %eax,%eax
  return 0;
  104444:	eb ad                	jmp    1043f3 <sys_chdir+0x23>

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
    return -1;
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
  104446:	89 1c 24             	mov    %ebx,(%esp)
  104449:	e8 a2 d6 ff ff       	call   101af0 <iunlockput>
  10444e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104453:	eb 9e                	jmp    1043f3 <sys_chdir+0x23>
  104455:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104459:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104460 <create>:
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104460:	55                   	push   %ebp
  104461:	89 e5                	mov    %esp,%ebp
  104463:	83 ec 58             	sub    $0x58,%esp
  104466:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  104469:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10446c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  10446f:	8d 75 d6             	lea    -0x2a(%ebp),%esi
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104472:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  104475:	31 db                	xor    %ebx,%ebx
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104477:	89 7d fc             	mov    %edi,-0x4(%ebp)
  10447a:	89 d7                	mov    %edx,%edi
  10447c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  10447f:	89 74 24 04          	mov    %esi,0x4(%esp)
  104483:	89 04 24             	mov    %eax,(%esp)
  104486:	e8 d5 d9 ff ff       	call   101e60 <nameiparent>
  10448b:	85 c0                	test   %eax,%eax
  10448d:	74 47                	je     1044d6 <create+0x76>
    return 0;
  ilock(dp);
  10448f:	89 04 24             	mov    %eax,(%esp)
  104492:	89 45 bc             	mov    %eax,-0x44(%ebp)
  104495:	e8 46 d7 ff ff       	call   101be0 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
  10449a:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10449d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1044a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1044a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  1044a8:	89 14 24             	mov    %edx,(%esp)
  1044ab:	e8 f0 d1 ff ff       	call   1016a0 <dirlookup>
  1044b0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1044b3:	85 c0                	test   %eax,%eax
  1044b5:	89 c3                	mov    %eax,%ebx
  1044b7:	74 3f                	je     1044f8 <create+0x98>
    iunlockput(dp);
  1044b9:	89 14 24             	mov    %edx,(%esp)
  1044bc:	e8 2f d6 ff ff       	call   101af0 <iunlockput>
    ilock(ip);
  1044c1:	89 1c 24             	mov    %ebx,(%esp)
  1044c4:	e8 17 d7 ff ff       	call   101be0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
  1044c9:	66 83 ff 02          	cmp    $0x2,%di
  1044cd:	75 19                	jne    1044e8 <create+0x88>
  1044cf:	66 83 7b 10 02       	cmpw   $0x2,0x10(%ebx)
  1044d4:	75 12                	jne    1044e8 <create+0x88>
  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);
  return ip;
}
  1044d6:	89 d8                	mov    %ebx,%eax
  1044d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1044db:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1044de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1044e1:	89 ec                	mov    %ebp,%esp
  1044e3:	5d                   	pop    %ebp
  1044e4:	c3                   	ret    
  1044e5:	8d 76 00             	lea    0x0(%esi),%esi
  if((ip = dirlookup(dp, name, &off)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
  1044e8:	89 1c 24             	mov    %ebx,(%esp)
  1044eb:	31 db                	xor    %ebx,%ebx
  1044ed:	e8 fe d5 ff ff       	call   101af0 <iunlockput>
    return 0;
  1044f2:	eb e2                	jmp    1044d6 <create+0x76>
  1044f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

  if((ip = ialloc(dp->dev, type)) == 0)
  1044f8:	0f bf c7             	movswl %di,%eax
  1044fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1044ff:	8b 02                	mov    (%edx),%eax
  104501:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104504:	89 04 24             	mov    %eax,(%esp)
  104507:	e8 04 d6 ff ff       	call   101b10 <ialloc>
  10450c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10450f:	85 c0                	test   %eax,%eax
  104511:	89 c3                	mov    %eax,%ebx
  104513:	0f 84 b7 00 00 00    	je     1045d0 <create+0x170>
    panic("create: ialloc");

  ilock(ip);
  104519:	89 55 bc             	mov    %edx,-0x44(%ebp)
  10451c:	89 04 24             	mov    %eax,(%esp)
  10451f:	e8 bc d6 ff ff       	call   101be0 <ilock>
  ip->major = major;
  104524:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
  104528:	66 89 43 12          	mov    %ax,0x12(%ebx)
  ip->minor = minor;
  10452c:	0f b7 4d c0          	movzwl -0x40(%ebp),%ecx
  ip->nlink = 1;
  104530:	66 c7 43 16 01 00    	movw   $0x1,0x16(%ebx)
  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");

  ilock(ip);
  ip->major = major;
  ip->minor = minor;
  104536:	66 89 4b 14          	mov    %cx,0x14(%ebx)
  ip->nlink = 1;
  iupdate(ip);
  10453a:	89 1c 24             	mov    %ebx,(%esp)
  10453d:	e8 5e cf ff ff       	call   1014a0 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
  104542:	66 83 ff 01          	cmp    $0x1,%di
  104546:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104549:	74 2d                	je     104578 <create+0x118>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
  10454b:	8b 43 04             	mov    0x4(%ebx),%eax
  10454e:	89 14 24             	mov    %edx,(%esp)
  104551:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104554:	89 74 24 04          	mov    %esi,0x4(%esp)
  104558:	89 44 24 08          	mov    %eax,0x8(%esp)
  10455c:	e8 9f d4 ff ff       	call   101a00 <dirlink>
  104561:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104564:	85 c0                	test   %eax,%eax
  104566:	78 74                	js     1045dc <create+0x17c>
    panic("create: dirlink");

  iunlockput(dp);
  104568:	89 14 24             	mov    %edx,(%esp)
  10456b:	e8 80 d5 ff ff       	call   101af0 <iunlockput>
  return ip;
  104570:	e9 61 ff ff ff       	jmp    1044d6 <create+0x76>
  104575:	8d 76 00             	lea    0x0(%esi),%esi
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
  104578:	66 83 42 16 01       	addw   $0x1,0x16(%edx)
    iupdate(dp);
  10457d:	89 14 24             	mov    %edx,(%esp)
  104580:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104583:	e8 18 cf ff ff       	call   1014a0 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
  104588:	8b 43 04             	mov    0x4(%ebx),%eax
  10458b:	c7 44 24 04 2c 6d 10 	movl   $0x106d2c,0x4(%esp)
  104592:	00 
  104593:	89 1c 24             	mov    %ebx,(%esp)
  104596:	89 44 24 08          	mov    %eax,0x8(%esp)
  10459a:	e8 61 d4 ff ff       	call   101a00 <dirlink>
  10459f:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1045a2:	85 c0                	test   %eax,%eax
  1045a4:	78 1e                	js     1045c4 <create+0x164>
  1045a6:	8b 42 04             	mov    0x4(%edx),%eax
  1045a9:	c7 44 24 04 2b 6d 10 	movl   $0x106d2b,0x4(%esp)
  1045b0:	00 
  1045b1:	89 1c 24             	mov    %ebx,(%esp)
  1045b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1045b8:	e8 43 d4 ff ff       	call   101a00 <dirlink>
  1045bd:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1045c0:	85 c0                	test   %eax,%eax
  1045c2:	79 87                	jns    10454b <create+0xeb>
      panic("create dots");
  1045c4:	c7 04 24 2e 6d 10 00 	movl   $0x106d2e,(%esp)
  1045cb:	e8 50 c3 ff ff       	call   100920 <panic>
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");
  1045d0:	c7 04 24 1c 6d 10 00 	movl   $0x106d1c,(%esp)
  1045d7:	e8 44 c3 ff ff       	call   100920 <panic>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");
  1045dc:	c7 04 24 3a 6d 10 00 	movl   $0x106d3a,(%esp)
  1045e3:	e8 38 c3 ff ff       	call   100920 <panic>
  1045e8:	90                   	nop
  1045e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001045f0 <sys_mknod>:
  return 0;
}

int
sys_mknod(void)
{
  1045f0:	55                   	push   %ebp
  1045f1:	89 e5                	mov    %esp,%ebp
  1045f3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  1045f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1045f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1045fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104604:	e8 f7 fa ff ff       	call   104100 <argstr>
  104609:	85 c0                	test   %eax,%eax
  10460b:	79 0b                	jns    104618 <sys_mknod+0x28>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  return 0;
  10460d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104612:	c9                   	leave  
  104613:	c3                   	ret    
  104614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
  104618:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10461b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10461f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104626:	e8 45 fa ff ff       	call   104070 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10462b:	85 c0                	test   %eax,%eax
  10462d:	78 de                	js     10460d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
  10462f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104632:	89 44 24 04          	mov    %eax,0x4(%esp)
  104636:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10463d:	e8 2e fa ff ff       	call   104070 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  104642:	85 c0                	test   %eax,%eax
  104644:	78 c7                	js     10460d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
  104646:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
  10464a:	ba 03 00 00 00       	mov    $0x3,%edx
  10464f:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
  104653:	89 04 24             	mov    %eax,(%esp)
  104656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104659:	e8 02 fe ff ff       	call   104460 <create>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10465e:	85 c0                	test   %eax,%eax
  104660:	74 ab                	je     10460d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  104662:	89 04 24             	mov    %eax,(%esp)
  104665:	e8 86 d4 ff ff       	call   101af0 <iunlockput>
  10466a:	31 c0                	xor    %eax,%eax
  return 0;
}
  10466c:	c9                   	leave  
  10466d:	c3                   	ret    
  10466e:	66 90                	xchg   %ax,%ax

00104670 <sys_mkdir>:
  return fd;
}

int
sys_mkdir(void)
{
  104670:	55                   	push   %ebp
  104671:	89 e5                	mov    %esp,%ebp
  104673:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  104676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104679:	89 44 24 04          	mov    %eax,0x4(%esp)
  10467d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104684:	e8 77 fa ff ff       	call   104100 <argstr>
  104689:	85 c0                	test   %eax,%eax
  10468b:	79 0b                	jns    104698 <sys_mkdir+0x28>
    return -1;
  iunlockput(ip);
  return 0;
  10468d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104692:	c9                   	leave  
  104693:	c3                   	ret    
  104694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_mkdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  104698:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10469f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046a2:	31 c9                	xor    %ecx,%ecx
  1046a4:	ba 01 00 00 00       	mov    $0x1,%edx
  1046a9:	e8 b2 fd ff ff       	call   104460 <create>
  1046ae:	85 c0                	test   %eax,%eax
  1046b0:	74 db                	je     10468d <sys_mkdir+0x1d>
    return -1;
  iunlockput(ip);
  1046b2:	89 04 24             	mov    %eax,(%esp)
  1046b5:	e8 36 d4 ff ff       	call   101af0 <iunlockput>
  1046ba:	31 c0                	xor    %eax,%eax
  return 0;
}
  1046bc:	c9                   	leave  
  1046bd:	c3                   	ret    
  1046be:	66 90                	xchg   %ax,%ax

001046c0 <sys_link>:
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1046c0:	55                   	push   %ebp
  1046c1:	89 e5                	mov    %esp,%ebp
  1046c3:	83 ec 48             	sub    $0x48,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1046c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1046c9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1046cc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1046cf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1046d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1046dd:	e8 1e fa ff ff       	call   104100 <argstr>
  1046e2:	85 c0                	test   %eax,%eax
  1046e4:	79 12                	jns    1046f8 <sys_link+0x38>
bad:
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return -1;
  1046e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1046eb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1046ee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1046f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1046f4:	89 ec                	mov    %ebp,%esp
  1046f6:	5d                   	pop    %ebp
  1046f7:	c3                   	ret    
sys_link(void)
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1046f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1046fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104706:	e8 f5 f9 ff ff       	call   104100 <argstr>
  10470b:	85 c0                	test   %eax,%eax
  10470d:	78 d7                	js     1046e6 <sys_link+0x26>
    return -1;
  if((ip = namei(old)) == 0)
  10470f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104712:	89 04 24             	mov    %eax,(%esp)
  104715:	e8 66 d7 ff ff       	call   101e80 <namei>
  10471a:	85 c0                	test   %eax,%eax
  10471c:	89 c3                	mov    %eax,%ebx
  10471e:	74 c6                	je     1046e6 <sys_link+0x26>
    return -1;
  ilock(ip);
  104720:	89 04 24             	mov    %eax,(%esp)
  104723:	e8 b8 d4 ff ff       	call   101be0 <ilock>
  if(ip->type == T_DIR){
  104728:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10472d:	0f 84 86 00 00 00    	je     1047b9 <sys_link+0xf9>
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  104733:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
  104738:	8d 7d d2             	lea    -0x2e(%ebp),%edi
  if(ip->type == T_DIR){
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  iupdate(ip);
  10473b:	89 1c 24             	mov    %ebx,(%esp)
  10473e:	e8 5d cd ff ff       	call   1014a0 <iupdate>
  iunlock(ip);
  104743:	89 1c 24             	mov    %ebx,(%esp)
  104746:	e8 55 d0 ff ff       	call   1017a0 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
  10474b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10474e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104752:	89 04 24             	mov    %eax,(%esp)
  104755:	e8 06 d7 ff ff       	call   101e60 <nameiparent>
  10475a:	85 c0                	test   %eax,%eax
  10475c:	89 c6                	mov    %eax,%esi
  10475e:	74 44                	je     1047a4 <sys_link+0xe4>
    goto bad;
  ilock(dp);
  104760:	89 04 24             	mov    %eax,(%esp)
  104763:	e8 78 d4 ff ff       	call   101be0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
  104768:	8b 06                	mov    (%esi),%eax
  10476a:	3b 03                	cmp    (%ebx),%eax
  10476c:	75 2e                	jne    10479c <sys_link+0xdc>
  10476e:	8b 43 04             	mov    0x4(%ebx),%eax
  104771:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104775:	89 34 24             	mov    %esi,(%esp)
  104778:	89 44 24 08          	mov    %eax,0x8(%esp)
  10477c:	e8 7f d2 ff ff       	call   101a00 <dirlink>
  104781:	85 c0                	test   %eax,%eax
  104783:	78 17                	js     10479c <sys_link+0xdc>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
  104785:	89 34 24             	mov    %esi,(%esp)
  104788:	e8 63 d3 ff ff       	call   101af0 <iunlockput>
  iput(ip);
  10478d:	89 1c 24             	mov    %ebx,(%esp)
  104790:	e8 1b d1 ff ff       	call   1018b0 <iput>
  104795:	31 c0                	xor    %eax,%eax
  return 0;
  104797:	e9 4f ff ff ff       	jmp    1046eb <sys_link+0x2b>

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
  10479c:	89 34 24             	mov    %esi,(%esp)
  10479f:	e8 4c d3 ff ff       	call   101af0 <iunlockput>
  iunlockput(dp);
  iput(ip);
  return 0;

bad:
  ilock(ip);
  1047a4:	89 1c 24             	mov    %ebx,(%esp)
  1047a7:	e8 34 d4 ff ff       	call   101be0 <ilock>
  ip->nlink--;
  1047ac:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
  1047b1:	89 1c 24             	mov    %ebx,(%esp)
  1047b4:	e8 e7 cc ff ff       	call   1014a0 <iupdate>
  iunlockput(ip);
  1047b9:	89 1c 24             	mov    %ebx,(%esp)
  1047bc:	e8 2f d3 ff ff       	call   101af0 <iunlockput>
  1047c1:	83 c8 ff             	or     $0xffffffff,%eax
  return -1;
  1047c4:	e9 22 ff ff ff       	jmp    1046eb <sys_link+0x2b>
  1047c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001047d0 <sys_open>:
  return ip;
}

int
sys_open(void)
{
  1047d0:	55                   	push   %ebp
  1047d1:	89 e5                	mov    %esp,%ebp
  1047d3:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  1047d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return ip;
}

int
sys_open(void)
{
  1047d9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  1047dc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  1047df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1047e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1047ea:	e8 11 f9 ff ff       	call   104100 <argstr>
  1047ef:	85 c0                	test   %eax,%eax
  1047f1:	79 15                	jns    104808 <sys_open+0x38>

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  1047f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
}
  1047f8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  1047fb:	8b 75 fc             	mov    -0x4(%ebp),%esi
  1047fe:	89 ec                	mov    %ebp,%esp
  104800:	5d                   	pop    %ebp
  104801:	c3                   	ret    
  104802:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  104808:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10480b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10480f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104816:	e8 55 f8 ff ff       	call   104070 <argint>
  10481b:	85 c0                	test   %eax,%eax
  10481d:	78 d4                	js     1047f3 <sys_open+0x23>
    return -1;
  if(omode & O_CREATE){
  10481f:	f6 45 f1 02          	testb  $0x2,-0xf(%ebp)
  104823:	74 63                	je     104888 <sys_open+0xb8>
    if((ip = create(path, T_FILE, 0, 0)) == 0)
  104825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104828:	31 c9                	xor    %ecx,%ecx
  10482a:	ba 02 00 00 00       	mov    $0x2,%edx
  10482f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104836:	e8 25 fc ff ff       	call   104460 <create>
  10483b:	85 c0                	test   %eax,%eax
  10483d:	89 c3                	mov    %eax,%ebx
  10483f:	74 b2                	je     1047f3 <sys_open+0x23>
      iunlockput(ip);
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
  104841:	e8 da c6 ff ff       	call   100f20 <filealloc>
  104846:	85 c0                	test   %eax,%eax
  104848:	89 c6                	mov    %eax,%esi
  10484a:	74 24                	je     104870 <sys_open+0xa0>
  10484c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104853:	31 c0                	xor    %eax,%eax
  104855:	8d 76 00             	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104858:	8b 4c 82 28          	mov    0x28(%edx,%eax,4),%ecx
  10485c:	85 c9                	test   %ecx,%ecx
  10485e:	74 58                	je     1048b8 <sys_open+0xe8>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104860:	83 c0 01             	add    $0x1,%eax
  104863:	83 f8 10             	cmp    $0x10,%eax
  104866:	75 f0                	jne    104858 <sys_open+0x88>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
  104868:	89 34 24             	mov    %esi,(%esp)
  10486b:	e8 30 c7 ff ff       	call   100fa0 <fileclose>
    iunlockput(ip);
  104870:	89 1c 24             	mov    %ebx,(%esp)
  104873:	e8 78 d2 ff ff       	call   101af0 <iunlockput>
  104878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  10487d:	e9 76 ff ff ff       	jmp    1047f8 <sys_open+0x28>
  104882:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
  if(omode & O_CREATE){
    if((ip = create(path, T_FILE, 0, 0)) == 0)
      return -1;
  } else {
    if((ip = namei(path)) == 0)
  104888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10488b:	89 04 24             	mov    %eax,(%esp)
  10488e:	e8 ed d5 ff ff       	call   101e80 <namei>
  104893:	85 c0                	test   %eax,%eax
  104895:	89 c3                	mov    %eax,%ebx
  104897:	0f 84 56 ff ff ff    	je     1047f3 <sys_open+0x23>
      return -1;
    ilock(ip);
  10489d:	89 04 24             	mov    %eax,(%esp)
  1048a0:	e8 3b d3 ff ff       	call   101be0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
  1048a5:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  1048aa:	75 95                	jne    104841 <sys_open+0x71>
  1048ac:	8b 75 f0             	mov    -0x10(%ebp),%esi
  1048af:	85 f6                	test   %esi,%esi
  1048b1:	74 8e                	je     104841 <sys_open+0x71>
  1048b3:	eb bb                	jmp    104870 <sys_open+0xa0>
  1048b5:	8d 76 00             	lea    0x0(%esi),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1048b8:	89 74 82 28          	mov    %esi,0x28(%edx,%eax,4)
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  1048bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1048bf:	89 1c 24             	mov    %ebx,(%esp)
  1048c2:	e8 d9 ce ff ff       	call   1017a0 <iunlock>

  f->type = FD_INODE;
  1048c7:	c7 06 02 00 00 00    	movl   $0x2,(%esi)
  f->ip = ip;
  1048cd:	89 5e 10             	mov    %ebx,0x10(%esi)
  f->off = 0;
  1048d0:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)
  f->readable = !(omode & O_WRONLY);
  1048d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1048da:	83 f2 01             	xor    $0x1,%edx
  1048dd:	83 e2 01             	and    $0x1,%edx
  1048e0:	88 56 08             	mov    %dl,0x8(%esi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  1048e3:	f6 45 f0 03          	testb  $0x3,-0x10(%ebp)
  1048e7:	0f 95 46 09          	setne  0x9(%esi)
  return fd;
  1048eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1048ee:	e9 05 ff ff ff       	jmp    1047f8 <sys_open+0x28>
  1048f3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1048f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104900 <sys_unlink>:
  return 1;
}

int
sys_unlink(void)
{
  104900:	55                   	push   %ebp
  104901:	89 e5                	mov    %esp,%ebp
  104903:	83 ec 78             	sub    $0x78,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  104906:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 1;
}

int
sys_unlink(void)
{
  104909:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  10490c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10490f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  104912:	89 44 24 04          	mov    %eax,0x4(%esp)
  104916:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10491d:	e8 de f7 ff ff       	call   104100 <argstr>
  104922:	85 c0                	test   %eax,%eax
  104924:	79 12                	jns    104938 <sys_unlink+0x38>
  iunlockput(dp);

  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return 0;
  104926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10492b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10492e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104931:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104934:	89 ec                	mov    %ebp,%esp
  104936:	5d                   	pop    %ebp
  104937:	c3                   	ret    
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
    return -1;
  if((dp = nameiparent(path, name)) == 0)
  104938:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10493b:	8d 5d d2             	lea    -0x2e(%ebp),%ebx
  10493e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104942:	89 04 24             	mov    %eax,(%esp)
  104945:	e8 16 d5 ff ff       	call   101e60 <nameiparent>
  10494a:	85 c0                	test   %eax,%eax
  10494c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  10494f:	74 d5                	je     104926 <sys_unlink+0x26>
    return -1;
  ilock(dp);
  104951:	89 04 24             	mov    %eax,(%esp)
  104954:	e8 87 d2 ff ff       	call   101be0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0){
  104959:	c7 44 24 04 2c 6d 10 	movl   $0x106d2c,0x4(%esp)
  104960:	00 
  104961:	89 1c 24             	mov    %ebx,(%esp)
  104964:	e8 07 cd ff ff       	call   101670 <namecmp>
  104969:	85 c0                	test   %eax,%eax
  10496b:	0f 84 a4 00 00 00    	je     104a15 <sys_unlink+0x115>
  104971:	c7 44 24 04 2b 6d 10 	movl   $0x106d2b,0x4(%esp)
  104978:	00 
  104979:	89 1c 24             	mov    %ebx,(%esp)
  10497c:	e8 ef cc ff ff       	call   101670 <namecmp>
  104981:	85 c0                	test   %eax,%eax
  104983:	0f 84 8c 00 00 00    	je     104a15 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }

  if((ip = dirlookup(dp, name, &off)) == 0){
  104989:	8d 45 e0             	lea    -0x20(%ebp),%eax
  10498c:	89 44 24 08          	mov    %eax,0x8(%esp)
  104990:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104993:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104997:	89 04 24             	mov    %eax,(%esp)
  10499a:	e8 01 cd ff ff       	call   1016a0 <dirlookup>
  10499f:	85 c0                	test   %eax,%eax
  1049a1:	89 c6                	mov    %eax,%esi
  1049a3:	74 70                	je     104a15 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }
  ilock(ip);
  1049a5:	89 04 24             	mov    %eax,(%esp)
  1049a8:	e8 33 d2 ff ff       	call   101be0 <ilock>

  if(ip->nlink < 1)
  1049ad:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  1049b2:	0f 8e 0e 01 00 00    	jle    104ac6 <sys_unlink+0x1c6>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
  1049b8:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  1049bd:	75 71                	jne    104a30 <sys_unlink+0x130>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
  1049bf:	83 7e 18 20          	cmpl   $0x20,0x18(%esi)
  1049c3:	76 6b                	jbe    104a30 <sys_unlink+0x130>
  1049c5:	8d 7d b2             	lea    -0x4e(%ebp),%edi
  1049c8:	bb 20 00 00 00       	mov    $0x20,%ebx
  1049cd:	8d 76 00             	lea    0x0(%esi),%esi
  1049d0:	eb 0e                	jmp    1049e0 <sys_unlink+0xe0>
  1049d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1049d8:	83 c3 10             	add    $0x10,%ebx
  1049db:	3b 5e 18             	cmp    0x18(%esi),%ebx
  1049de:	73 50                	jae    104a30 <sys_unlink+0x130>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  1049e0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  1049e7:	00 
  1049e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  1049ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1049f0:	89 34 24             	mov    %esi,(%esp)
  1049f3:	e8 98 c9 ff ff       	call   101390 <readi>
  1049f8:	83 f8 10             	cmp    $0x10,%eax
  1049fb:	0f 85 ad 00 00 00    	jne    104aae <sys_unlink+0x1ae>
      panic("isdirempty: readi");
    if(de.inum != 0)
  104a01:	66 83 7d b2 00       	cmpw   $0x0,-0x4e(%ebp)
  104a06:	74 d0                	je     1049d8 <sys_unlink+0xd8>
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
  104a08:	89 34 24             	mov    %esi,(%esp)
  104a0b:	90                   	nop
  104a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104a10:	e8 db d0 ff ff       	call   101af0 <iunlockput>
    iunlockput(dp);
  104a15:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104a18:	89 04 24             	mov    %eax,(%esp)
  104a1b:	e8 d0 d0 ff ff       	call   101af0 <iunlockput>
  104a20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104a25:	e9 01 ff ff ff       	jmp    10492b <sys_unlink+0x2b>
  104a2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  memset(&de, 0, sizeof(de));
  104a30:	8d 5d c2             	lea    -0x3e(%ebp),%ebx
  104a33:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  104a3a:	00 
  104a3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104a42:	00 
  104a43:	89 1c 24             	mov    %ebx,(%esp)
  104a46:	e8 85 f3 ff ff       	call   103dd0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  104a4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a4e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  104a55:	00 
  104a56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104a5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  104a5e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104a61:	89 04 24             	mov    %eax,(%esp)
  104a64:	e8 c7 ca ff ff       	call   101530 <writei>
  104a69:	83 f8 10             	cmp    $0x10,%eax
  104a6c:	75 4c                	jne    104aba <sys_unlink+0x1ba>
    panic("unlink: writei");
  if(ip->type == T_DIR){
  104a6e:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  104a73:	74 27                	je     104a9c <sys_unlink+0x19c>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
  104a75:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104a78:	89 04 24             	mov    %eax,(%esp)
  104a7b:	e8 70 d0 ff ff       	call   101af0 <iunlockput>

  ip->nlink--;
  104a80:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
  iupdate(ip);
  104a85:	89 34 24             	mov    %esi,(%esp)
  104a88:	e8 13 ca ff ff       	call   1014a0 <iupdate>
  iunlockput(ip);
  104a8d:	89 34 24             	mov    %esi,(%esp)
  104a90:	e8 5b d0 ff ff       	call   101af0 <iunlockput>
  104a95:	31 c0                	xor    %eax,%eax
  return 0;
  104a97:	e9 8f fe ff ff       	jmp    10492b <sys_unlink+0x2b>

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
  104a9c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104a9f:	66 83 68 16 01       	subw   $0x1,0x16(%eax)
    iupdate(dp);
  104aa4:	89 04 24             	mov    %eax,(%esp)
  104aa7:	e8 f4 c9 ff ff       	call   1014a0 <iupdate>
  104aac:	eb c7                	jmp    104a75 <sys_unlink+0x175>
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
  104aae:	c7 04 24 5c 6d 10 00 	movl   $0x106d5c,(%esp)
  104ab5:	e8 66 be ff ff       	call   100920 <panic>
    return -1;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  104aba:	c7 04 24 6e 6d 10 00 	movl   $0x106d6e,(%esp)
  104ac1:	e8 5a be ff ff       	call   100920 <panic>
    return -1;
  }
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  104ac6:	c7 04 24 4a 6d 10 00 	movl   $0x106d4a,(%esp)
  104acd:	e8 4e be ff ff       	call   100920 <panic>
  104ad2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  104ad9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104ae0 <T.67>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  104ae0:	55                   	push   %ebp
  104ae1:	89 e5                	mov    %esp,%ebp
  104ae3:	83 ec 28             	sub    $0x28,%esp
  104ae6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  104ae9:	89 c3                	mov    %eax,%ebx
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  104aeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  104aee:	89 75 fc             	mov    %esi,-0x4(%ebp)
  104af1:	89 d6                	mov    %edx,%esi
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  104af3:	89 44 24 04          	mov    %eax,0x4(%esp)
  104af7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104afe:	e8 6d f5 ff ff       	call   104070 <argint>
  104b03:	85 c0                	test   %eax,%eax
  104b05:	79 11                	jns    104b18 <T.67+0x38>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  104b07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  104b0c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  104b0f:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104b12:	89 ec                	mov    %ebp,%esp
  104b14:	5d                   	pop    %ebp
  104b15:	c3                   	ret    
  104b16:	66 90                	xchg   %ax,%ax
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
  104b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b1b:	83 f8 0f             	cmp    $0xf,%eax
  104b1e:	77 e7                	ja     104b07 <T.67+0x27>
  104b20:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104b27:	8b 54 82 28          	mov    0x28(%edx,%eax,4),%edx
  104b2b:	85 d2                	test   %edx,%edx
  104b2d:	74 d8                	je     104b07 <T.67+0x27>
    return -1;
  if(pfd)
  104b2f:	85 db                	test   %ebx,%ebx
  104b31:	74 02                	je     104b35 <T.67+0x55>
    *pfd = fd;
  104b33:	89 03                	mov    %eax,(%ebx)
  if(pf)
  104b35:	31 c0                	xor    %eax,%eax
  104b37:	85 f6                	test   %esi,%esi
  104b39:	74 d1                	je     104b0c <T.67+0x2c>
    *pf = f;
  104b3b:	89 16                	mov    %edx,(%esi)
  104b3d:	eb cd                	jmp    104b0c <T.67+0x2c>
  104b3f:	90                   	nop

00104b40 <sys_dup>:
  return -1;
}

int
sys_dup(void)
{
  104b40:	55                   	push   %ebp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104b41:	31 c0                	xor    %eax,%eax
  return -1;
}

int
sys_dup(void)
{
  104b43:	89 e5                	mov    %esp,%ebp
  104b45:	53                   	push   %ebx
  104b46:	83 ec 24             	sub    $0x24,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104b49:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104b4c:	e8 8f ff ff ff       	call   104ae0 <T.67>
  104b51:	85 c0                	test   %eax,%eax
  104b53:	79 13                	jns    104b68 <sys_dup+0x28>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104b55:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
}
  104b5a:	89 d8                	mov    %ebx,%eax
  104b5c:	83 c4 24             	add    $0x24,%esp
  104b5f:	5b                   	pop    %ebx
  104b60:	5d                   	pop    %ebp
  104b61:	c3                   	ret    
  104b62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
  104b68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104b6b:	31 db                	xor    %ebx,%ebx
  104b6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104b73:	eb 0b                	jmp    104b80 <sys_dup+0x40>
  104b75:	8d 76 00             	lea    0x0(%esi),%esi
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104b78:	83 c3 01             	add    $0x1,%ebx
  104b7b:	83 fb 10             	cmp    $0x10,%ebx
  104b7e:	74 d5                	je     104b55 <sys_dup+0x15>
    if(proc->ofile[fd] == 0){
  104b80:	8b 4c 98 28          	mov    0x28(%eax,%ebx,4),%ecx
  104b84:	85 c9                	test   %ecx,%ecx
  104b86:	75 f0                	jne    104b78 <sys_dup+0x38>
      proc->ofile[fd] = f;
  104b88:	89 54 98 28          	mov    %edx,0x28(%eax,%ebx,4)
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  104b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b8f:	89 04 24             	mov    %eax,(%esp)
  104b92:	e8 39 c3 ff ff       	call   100ed0 <filedup>
  return fd;
  104b97:	eb c1                	jmp    104b5a <sys_dup+0x1a>
  104b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104ba0 <sys_read>:
}

int
sys_read(void)
{
  104ba0:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104ba1:	31 c0                	xor    %eax,%eax
  return fd;
}

int
sys_read(void)
{
  104ba3:	89 e5                	mov    %esp,%ebp
  104ba5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104ba8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104bab:	e8 30 ff ff ff       	call   104ae0 <T.67>
  104bb0:	85 c0                	test   %eax,%eax
  104bb2:	79 0c                	jns    104bc0 <sys_read+0x20>
    return -1;
  return fileread(f, p, n);
  104bb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104bb9:	c9                   	leave  
  104bba:	c3                   	ret    
  104bbb:	90                   	nop
  104bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104bc0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  104bc7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104bce:	e8 9d f4 ff ff       	call   104070 <argint>
  104bd3:	85 c0                	test   %eax,%eax
  104bd5:	78 dd                	js     104bb4 <sys_read+0x14>
  104bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104be1:	89 44 24 08          	mov    %eax,0x8(%esp)
  104be5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  104bec:	e8 bf f4 ff ff       	call   1040b0 <argptr>
  104bf1:	85 c0                	test   %eax,%eax
  104bf3:	78 bf                	js     104bb4 <sys_read+0x14>
    return -1;
  return fileread(f, p, n);
  104bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bf8:	89 44 24 08          	mov    %eax,0x8(%esp)
  104bfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bff:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c06:	89 04 24             	mov    %eax,(%esp)
  104c09:	e8 c2 c1 ff ff       	call   100dd0 <fileread>
}
  104c0e:	c9                   	leave  
  104c0f:	c3                   	ret    

00104c10 <sys_write>:

int
sys_write(void)
{
  104c10:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104c11:	31 c0                	xor    %eax,%eax
  return fileread(f, p, n);
}

int
sys_write(void)
{
  104c13:	89 e5                	mov    %esp,%ebp
  104c15:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104c18:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104c1b:	e8 c0 fe ff ff       	call   104ae0 <T.67>
  104c20:	85 c0                	test   %eax,%eax
  104c22:	79 0c                	jns    104c30 <sys_write+0x20>
    return -1;
  return filewrite(f, p, n);
  104c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104c29:	c9                   	leave  
  104c2a:	c3                   	ret    
  104c2b:	90                   	nop
  104c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104c30:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c37:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104c3e:	e8 2d f4 ff ff       	call   104070 <argint>
  104c43:	85 c0                	test   %eax,%eax
  104c45:	78 dd                	js     104c24 <sys_write+0x14>
  104c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c4a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c51:	89 44 24 08          	mov    %eax,0x8(%esp)
  104c55:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c5c:	e8 4f f4 ff ff       	call   1040b0 <argptr>
  104c61:	85 c0                	test   %eax,%eax
  104c63:	78 bf                	js     104c24 <sys_write+0x14>
    return -1;
  return filewrite(f, p, n);
  104c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c68:	89 44 24 08          	mov    %eax,0x8(%esp)
  104c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c76:	89 04 24             	mov    %eax,(%esp)
  104c79:	e8 a2 c0 ff ff       	call   100d20 <filewrite>
}
  104c7e:	c9                   	leave  
  104c7f:	c3                   	ret    

00104c80 <sys_fstat>:
  return 0;
}

int
sys_fstat(void)
{
  104c80:	55                   	push   %ebp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104c81:	31 c0                	xor    %eax,%eax
  return 0;
}

int
sys_fstat(void)
{
  104c83:	89 e5                	mov    %esp,%ebp
  104c85:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104c88:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104c8b:	e8 50 fe ff ff       	call   104ae0 <T.67>
  104c90:	85 c0                	test   %eax,%eax
  104c92:	79 0c                	jns    104ca0 <sys_fstat+0x20>
    return -1;
  return filestat(f, st);
  104c94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104c99:	c9                   	leave  
  104c9a:	c3                   	ret    
  104c9b:	90                   	nop
  104c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_fstat(void)
{
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104ca0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104ca3:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  104caa:	00 
  104cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  104caf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cb6:	e8 f5 f3 ff ff       	call   1040b0 <argptr>
  104cbb:	85 c0                	test   %eax,%eax
  104cbd:	78 d5                	js     104c94 <sys_fstat+0x14>
    return -1;
  return filestat(f, st);
  104cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  104cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104cc9:	89 04 24             	mov    %eax,(%esp)
  104ccc:	e8 af c1 ff ff       	call   100e80 <filestat>
}
  104cd1:	c9                   	leave  
  104cd2:	c3                   	ret    
  104cd3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104ce0 <sys_close>:
  return filewrite(f, p, n);
}

int
sys_close(void)
{
  104ce0:	55                   	push   %ebp
  104ce1:	89 e5                	mov    %esp,%ebp
  104ce3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
  104ce6:	8d 55 f0             	lea    -0x10(%ebp),%edx
  104ce9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104cec:	e8 ef fd ff ff       	call   104ae0 <T.67>
  104cf1:	89 c2                	mov    %eax,%edx
  104cf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104cf8:	85 d2                	test   %edx,%edx
  104cfa:	78 1e                	js     104d1a <sys_close+0x3a>
    return -1;
  proc->ofile[fd] = 0;
  104cfc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104d02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104d05:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
  104d0c:	00 
  fileclose(f);
  104d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d10:	89 04 24             	mov    %eax,(%esp)
  104d13:	e8 88 c2 ff ff       	call   100fa0 <fileclose>
  104d18:	31 c0                	xor    %eax,%eax
  return 0;
}
  104d1a:	c9                   	leave  
  104d1b:	c3                   	ret    
  104d1c:	90                   	nop
  104d1d:	90                   	nop
  104d1e:	90                   	nop
  104d1f:	90                   	nop

00104d20 <sys_getpid>:
}

int
sys_getpid(void)
{
  return proc->pid;
  104d20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return kill(pid);
}

int
sys_getpid(void)
{
  104d26:	55                   	push   %ebp
  104d27:	89 e5                	mov    %esp,%ebp
  return proc->pid;
}
  104d29:	5d                   	pop    %ebp
}

int
sys_getpid(void)
{
  return proc->pid;
  104d2a:	8b 40 10             	mov    0x10(%eax),%eax
}
  104d2d:	c3                   	ret    
  104d2e:	66 90                	xchg   %ax,%ax

00104d30 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since boot.
int
sys_uptime(void)
{
  104d30:	55                   	push   %ebp
  104d31:	89 e5                	mov    %esp,%ebp
  104d33:	53                   	push   %ebx
  104d34:	83 ec 14             	sub    $0x14,%esp
  uint xticks;
  
  acquire(&tickslock);
  104d37:	c7 04 24 60 e2 10 00 	movl   $0x10e260,(%esp)
  104d3e:	e8 ed ef ff ff       	call   103d30 <acquire>
  xticks = ticks;
  104d43:	8b 1d a0 ea 10 00    	mov    0x10eaa0,%ebx
  release(&tickslock);
  104d49:	c7 04 24 60 e2 10 00 	movl   $0x10e260,(%esp)
  104d50:	e8 8b ef ff ff       	call   103ce0 <release>
  return xticks;
}
  104d55:	83 c4 14             	add    $0x14,%esp
  104d58:	89 d8                	mov    %ebx,%eax
  104d5a:	5b                   	pop    %ebx
  104d5b:	5d                   	pop    %ebp
  104d5c:	c3                   	ret    
  104d5d:	8d 76 00             	lea    0x0(%esi),%esi

00104d60 <sys_sleep>:
  return addr;
}

int
sys_sleep(void)
{
  104d60:	55                   	push   %ebp
  104d61:	89 e5                	mov    %esp,%ebp
  104d63:	53                   	push   %ebx
  104d64:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
  104d67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104d75:	e8 f6 f2 ff ff       	call   104070 <argint>
  104d7a:	89 c2                	mov    %eax,%edx
  104d7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104d81:	85 d2                	test   %edx,%edx
  104d83:	78 59                	js     104dde <sys_sleep+0x7e>
    return -1;
  acquire(&tickslock);
  104d85:	c7 04 24 60 e2 10 00 	movl   $0x10e260,(%esp)
  104d8c:	e8 9f ef ff ff       	call   103d30 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  104d94:	8b 1d a0 ea 10 00    	mov    0x10eaa0,%ebx
  while(ticks - ticks0 < n){
  104d9a:	85 d2                	test   %edx,%edx
  104d9c:	75 22                	jne    104dc0 <sys_sleep+0x60>
  104d9e:	eb 48                	jmp    104de8 <sys_sleep+0x88>
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  104da0:	c7 44 24 04 60 e2 10 	movl   $0x10e260,0x4(%esp)
  104da7:	00 
  104da8:	c7 04 24 a0 ea 10 00 	movl   $0x10eaa0,(%esp)
  104daf:	e8 dc e4 ff ff       	call   103290 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104db4:	a1 a0 ea 10 00       	mov    0x10eaa0,%eax
  104db9:	29 d8                	sub    %ebx,%eax
  104dbb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104dbe:	73 28                	jae    104de8 <sys_sleep+0x88>
    if(proc->killed){
  104dc0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104dc6:	8b 40 24             	mov    0x24(%eax),%eax
  104dc9:	85 c0                	test   %eax,%eax
  104dcb:	74 d3                	je     104da0 <sys_sleep+0x40>
      release(&tickslock);
  104dcd:	c7 04 24 60 e2 10 00 	movl   $0x10e260,(%esp)
  104dd4:	e8 07 ef ff ff       	call   103ce0 <release>
  104dd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
  104dde:	83 c4 24             	add    $0x24,%esp
  104de1:	5b                   	pop    %ebx
  104de2:	5d                   	pop    %ebp
  104de3:	c3                   	ret    
  104de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104de8:	c7 04 24 60 e2 10 00 	movl   $0x10e260,(%esp)
  104def:	e8 ec ee ff ff       	call   103ce0 <release>
  return 0;
}
  104df4:	83 c4 24             	add    $0x24,%esp
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104df7:	31 c0                	xor    %eax,%eax
  return 0;
}
  104df9:	5b                   	pop    %ebx
  104dfa:	5d                   	pop    %ebp
  104dfb:	c3                   	ret    
  104dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104e00 <sys_sbrk>:
  return proc->pid;
}

int
sys_sbrk(void)
{
  104e00:	55                   	push   %ebp
  104e01:	89 e5                	mov    %esp,%ebp
  104e03:	53                   	push   %ebx
  104e04:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
  104e07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104e0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  104e0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104e15:	e8 56 f2 ff ff       	call   104070 <argint>
  104e1a:	85 c0                	test   %eax,%eax
  104e1c:	79 12                	jns    104e30 <sys_sbrk+0x30>
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
  104e1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104e23:	83 c4 24             	add    $0x24,%esp
  104e26:	5b                   	pop    %ebx
  104e27:	5d                   	pop    %ebp
  104e28:	c3                   	ret    
  104e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104e30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104e36:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
  104e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e3b:	89 04 24             	mov    %eax,(%esp)
  104e3e:	e8 cd eb ff ff       	call   103a10 <growproc>
  104e43:	89 c2                	mov    %eax,%edx
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104e45:	89 d8                	mov    %ebx,%eax
  if(growproc(n) < 0)
  104e47:	85 d2                	test   %edx,%edx
  104e49:	79 d8                	jns    104e23 <sys_sbrk+0x23>
  104e4b:	eb d1                	jmp    104e1e <sys_sbrk+0x1e>
  104e4d:	8d 76 00             	lea    0x0(%esi),%esi

00104e50 <sys_kill>:
  return wait();
}

int
sys_kill(void)
{
  104e50:	55                   	push   %ebp
  104e51:	89 e5                	mov    %esp,%ebp
  104e53:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
  104e56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104e59:	89 44 24 04          	mov    %eax,0x4(%esp)
  104e5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104e64:	e8 07 f2 ff ff       	call   104070 <argint>
  104e69:	89 c2                	mov    %eax,%edx
  104e6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104e70:	85 d2                	test   %edx,%edx
  104e72:	78 0b                	js     104e7f <sys_kill+0x2f>
    return -1;
  return kill(pid);
  104e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e77:	89 04 24             	mov    %eax,(%esp)
  104e7a:	e8 51 e2 ff ff       	call   1030d0 <kill>
}
  104e7f:	c9                   	leave  
  104e80:	c3                   	ret    
  104e81:	eb 0d                	jmp    104e90 <sys_wait>
  104e83:	90                   	nop
  104e84:	90                   	nop
  104e85:	90                   	nop
  104e86:	90                   	nop
  104e87:	90                   	nop
  104e88:	90                   	nop
  104e89:	90                   	nop
  104e8a:	90                   	nop
  104e8b:	90                   	nop
  104e8c:	90                   	nop
  104e8d:	90                   	nop
  104e8e:	90                   	nop
  104e8f:	90                   	nop

00104e90 <sys_wait>:
  return 0;  // not reached
}

int
sys_wait(void)
{
  104e90:	55                   	push   %ebp
  104e91:	89 e5                	mov    %esp,%ebp
  104e93:	83 ec 08             	sub    $0x8,%esp
  return wait();
}
  104e96:	c9                   	leave  
}

int
sys_wait(void)
{
  return wait();
  104e97:	e9 a4 e5 ff ff       	jmp    103440 <wait>
  104e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104ea0 <sys_exit>:
  return clone();
}

int
sys_exit(void)
{
  104ea0:	55                   	push   %ebp
  104ea1:	89 e5                	mov    %esp,%ebp
  104ea3:	83 ec 08             	sub    $0x8,%esp
  exit();
  104ea6:	e8 a5 e6 ff ff       	call   103550 <exit>
  return 0;  // not reached
}
  104eab:	31 c0                	xor    %eax,%eax
  104ead:	c9                   	leave  
  104eae:	c3                   	ret    
  104eaf:	90                   	nop

00104eb0 <sys_clone>:
  return fork();
}

int
sys_clone(void)
{
  104eb0:	55                   	push   %ebp
  104eb1:	89 e5                	mov    %esp,%ebp
  104eb3:	83 ec 08             	sub    $0x8,%esp
  return clone();
}
  104eb6:	c9                   	leave  
}

int
sys_clone(void)
{
  return clone();
  104eb7:	e9 c4 e8 ff ff       	jmp    103780 <clone>
  104ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104ec0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  104ec0:	55                   	push   %ebp
  104ec1:	89 e5                	mov    %esp,%ebp
  104ec3:	83 ec 08             	sub    $0x8,%esp
  return fork();
}
  104ec6:	c9                   	leave  
#include "proc.h"

int
sys_fork(void)
{
  return fork();
  104ec7:	e9 44 ea ff ff       	jmp    103910 <fork>
  104ecc:	90                   	nop
  104ecd:	90                   	nop
  104ece:	90                   	nop
  104ecf:	90                   	nop

00104ed0 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
  104ed0:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  104ed1:	ba 43 00 00 00       	mov    $0x43,%edx
  104ed6:	89 e5                	mov    %esp,%ebp
  104ed8:	83 ec 18             	sub    $0x18,%esp
  104edb:	b8 34 00 00 00       	mov    $0x34,%eax
  104ee0:	ee                   	out    %al,(%dx)
  104ee1:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
  104ee6:	b2 40                	mov    $0x40,%dl
  104ee8:	ee                   	out    %al,(%dx)
  104ee9:	b8 2e 00 00 00       	mov    $0x2e,%eax
  104eee:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
  104eef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104ef6:	e8 c5 dc ff ff       	call   102bc0 <picenable>
}
  104efb:	c9                   	leave  
  104efc:	c3                   	ret    
  104efd:	90                   	nop
  104efe:	90                   	nop
  104eff:	90                   	nop

00104f00 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
  104f00:	1e                   	push   %ds
  pushl %es
  104f01:	06                   	push   %es
  pushl %fs
  104f02:	0f a0                	push   %fs
  pushl %gs
  104f04:	0f a8                	push   %gs
  pushal
  104f06:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
  104f07:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
  104f0b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
  104f0d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
  104f0f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
  104f13:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
  104f15:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
  104f17:	54                   	push   %esp
  call trap
  104f18:	e8 43 00 00 00       	call   104f60 <trap>
  addl $4, %esp
  104f1d:	83 c4 04             	add    $0x4,%esp

00104f20 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
  104f20:	61                   	popa   
  popl %gs
  104f21:	0f a9                	pop    %gs
  popl %fs
  104f23:	0f a1                	pop    %fs
  popl %es
  104f25:	07                   	pop    %es
  popl %ds
  104f26:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
  104f27:	83 c4 08             	add    $0x8,%esp
  iret
  104f2a:	cf                   	iret   
  104f2b:	90                   	nop
  104f2c:	90                   	nop
  104f2d:	90                   	nop
  104f2e:	90                   	nop
  104f2f:	90                   	nop

00104f30 <idtinit>:
  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  104f30:	55                   	push   %ebp
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  pd[1] = (uint)p;
  104f31:	b8 a0 e2 10 00       	mov    $0x10e2a0,%eax
  104f36:	89 e5                	mov    %esp,%ebp
  104f38:	83 ec 10             	sub    $0x10,%esp
static inline void
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  104f3b:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
  104f41:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
  104f45:	c1 e8 10             	shr    $0x10,%eax
  104f48:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
  104f4c:	8d 45 fa             	lea    -0x6(%ebp),%eax
  104f4f:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
  104f52:	c9                   	leave  
  104f53:	c3                   	ret    
  104f54:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104f5a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00104f60 <trap>:

void
trap(struct trapframe *tf)
{
  104f60:	55                   	push   %ebp
  104f61:	89 e5                	mov    %esp,%ebp
  104f63:	56                   	push   %esi
  104f64:	53                   	push   %ebx
  104f65:	83 ec 20             	sub    $0x20,%esp
  104f68:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
  104f6b:	8b 43 30             	mov    0x30(%ebx),%eax
  104f6e:	83 f8 40             	cmp    $0x40,%eax
  104f71:	0f 84 c9 00 00 00    	je     105040 <trap+0xe0>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  104f77:	8d 50 e0             	lea    -0x20(%eax),%edx
  104f7a:	83 fa 1f             	cmp    $0x1f,%edx
  104f7d:	0f 86 b5 00 00 00    	jbe    105038 <trap+0xd8>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
  104f83:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104f8a:	85 d2                	test   %edx,%edx
  104f8c:	0f 84 f6 01 00 00    	je     105188 <trap+0x228>
  104f92:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
  104f96:	0f 84 ec 01 00 00    	je     105188 <trap+0x228>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
  104f9c:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
  104f9f:	8b 4a 10             	mov    0x10(%edx),%ecx
  104fa2:	83 c2 6c             	add    $0x6c,%edx
  104fa5:	89 74 24 1c          	mov    %esi,0x1c(%esp)
  104fa9:	8b 73 38             	mov    0x38(%ebx),%esi
  104fac:	89 74 24 18          	mov    %esi,0x18(%esp)
  104fb0:	65 8b 35 00 00 00 00 	mov    %gs:0x0,%esi
  104fb7:	0f b6 36             	movzbl (%esi),%esi
  104fba:	89 74 24 14          	mov    %esi,0x14(%esp)
  104fbe:	8b 73 34             	mov    0x34(%ebx),%esi
  104fc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104fc5:	89 54 24 08          	mov    %edx,0x8(%esp)
  104fc9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104fcd:	89 74 24 10          	mov    %esi,0x10(%esp)
  104fd1:	c7 04 24 d8 6d 10 00 	movl   $0x106dd8,(%esp)
  104fd8:	e8 53 b5 ff ff       	call   100530 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
  104fdd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104fe3:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  104fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  104ff0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104ff6:	85 c0                	test   %eax,%eax
  104ff8:	74 34                	je     10502e <trap+0xce>
  104ffa:	8b 50 24             	mov    0x24(%eax),%edx
  104ffd:	85 d2                	test   %edx,%edx
  104fff:	74 10                	je     105011 <trap+0xb1>
  105001:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
  105005:	83 e2 03             	and    $0x3,%edx
  105008:	83 fa 03             	cmp    $0x3,%edx
  10500b:	0f 84 5f 01 00 00    	je     105170 <trap+0x210>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105011:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
  105015:	0f 84 2d 01 00 00    	je     105148 <trap+0x1e8>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  10501b:	8b 40 24             	mov    0x24(%eax),%eax
  10501e:	85 c0                	test   %eax,%eax
  105020:	74 0c                	je     10502e <trap+0xce>
  105022:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  105026:	83 e0 03             	and    $0x3,%eax
  105029:	83 f8 03             	cmp    $0x3,%eax
  10502c:	74 34                	je     105062 <trap+0x102>
    exit();
}
  10502e:	83 c4 20             	add    $0x20,%esp
  105031:	5b                   	pop    %ebx
  105032:	5e                   	pop    %esi
  105033:	5d                   	pop    %ebp
  105034:	c3                   	ret    
  105035:	8d 76 00             	lea    0x0(%esi),%esi
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  105038:	ff 24 95 28 6e 10 00 	jmp    *0x106e28(,%edx,4)
  10503f:	90                   	nop

void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
  105040:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  105046:	8b 70 24             	mov    0x24(%eax),%esi
  105049:	85 f6                	test   %esi,%esi
  10504b:	75 23                	jne    105070 <trap+0x110>
      exit();
    proc->tf = tf;
  10504d:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
  105050:	e8 1b f1 ff ff       	call   104170 <syscall>
    if(proc->killed)
  105055:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10505b:	8b 48 24             	mov    0x24(%eax),%ecx
  10505e:	85 c9                	test   %ecx,%ecx
  105060:	74 cc                	je     10502e <trap+0xce>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
  105062:	83 c4 20             	add    $0x20,%esp
  105065:	5b                   	pop    %ebx
  105066:	5e                   	pop    %esi
  105067:	5d                   	pop    %ebp
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  105068:	e9 e3 e4 ff ff       	jmp    103550 <exit>
  10506d:	8d 76 00             	lea    0x0(%esi),%esi
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
      exit();
  105070:	e8 db e4 ff ff       	call   103550 <exit>
  105075:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10507b:	eb d0                	jmp    10504d <trap+0xed>
  10507d:	8d 76 00             	lea    0x0(%esi),%esi
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
  105080:	e8 bb cf ff ff       	call   102040 <ideintr>
    lapiceoi();
  105085:	e8 f6 d3 ff ff       	call   102480 <lapiceoi>
    break;
  10508a:	e9 61 ff ff ff       	jmp    104ff0 <trap+0x90>
  10508f:	90                   	nop
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
  105090:	8b 43 38             	mov    0x38(%ebx),%eax
  105093:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105097:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  10509b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10509f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1050a5:	0f b6 00             	movzbl (%eax),%eax
  1050a8:	c7 04 24 80 6d 10 00 	movl   $0x106d80,(%esp)
  1050af:	89 44 24 04          	mov    %eax,0x4(%esp)
  1050b3:	e8 78 b4 ff ff       	call   100530 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
  1050b8:	e8 c3 d3 ff ff       	call   102480 <lapiceoi>
    break;
  1050bd:	e9 2e ff ff ff       	jmp    104ff0 <trap+0x90>
  1050c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1050c8:	90                   	nop
  1050c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
  1050d0:	e8 ab 01 00 00       	call   105280 <uartintr>
  1050d5:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  1050d8:	e8 a3 d3 ff ff       	call   102480 <lapiceoi>
  1050dd:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  1050e0:	e9 0b ff ff ff       	jmp    104ff0 <trap+0x90>
  1050e5:	8d 76 00             	lea    0x0(%esi),%esi
  1050e8:	90                   	nop
  1050e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
  1050f0:	e8 6b d3 ff ff       	call   102460 <kbdintr>
  1050f5:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  1050f8:	e8 83 d3 ff ff       	call   102480 <lapiceoi>
  1050fd:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  105100:	e9 eb fe ff ff       	jmp    104ff0 <trap+0x90>
  105105:	8d 76 00             	lea    0x0(%esi),%esi
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
  105108:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10510e:	80 38 00             	cmpb   $0x0,(%eax)
  105111:	0f 85 6e ff ff ff    	jne    105085 <trap+0x125>
      acquire(&tickslock);
  105117:	c7 04 24 60 e2 10 00 	movl   $0x10e260,(%esp)
  10511e:	e8 0d ec ff ff       	call   103d30 <acquire>
      ticks++;
  105123:	83 05 a0 ea 10 00 01 	addl   $0x1,0x10eaa0
      wakeup(&ticks);
  10512a:	c7 04 24 a0 ea 10 00 	movl   $0x10eaa0,(%esp)
  105131:	e8 2a e0 ff ff       	call   103160 <wakeup>
      release(&tickslock);
  105136:	c7 04 24 60 e2 10 00 	movl   $0x10e260,(%esp)
  10513d:	e8 9e eb ff ff       	call   103ce0 <release>
  105142:	e9 3e ff ff ff       	jmp    105085 <trap+0x125>
  105147:	90                   	nop
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105148:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
  10514c:	0f 85 c9 fe ff ff    	jne    10501b <trap+0xbb>
  105152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    yield();
  105158:	e8 03 e2 ff ff       	call   103360 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  10515d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  105163:	85 c0                	test   %eax,%eax
  105165:	0f 85 b0 fe ff ff    	jne    10501b <trap+0xbb>
  10516b:	e9 be fe ff ff       	jmp    10502e <trap+0xce>

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  105170:	e8 db e3 ff ff       	call   103550 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105175:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10517b:	85 c0                	test   %eax,%eax
  10517d:	0f 85 8e fe ff ff    	jne    105011 <trap+0xb1>
  105183:	e9 a6 fe ff ff       	jmp    10502e <trap+0xce>
  105188:	0f 20 d2             	mov    %cr2,%edx
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
  10518b:	89 54 24 10          	mov    %edx,0x10(%esp)
  10518f:	8b 53 38             	mov    0x38(%ebx),%edx
  105192:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105196:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  10519d:	0f b6 12             	movzbl (%edx),%edx
  1051a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1051a4:	c7 04 24 a4 6d 10 00 	movl   $0x106da4,(%esp)
  1051ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  1051af:	e8 7c b3 ff ff       	call   100530 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
  1051b4:	c7 04 24 1b 6e 10 00 	movl   $0x106e1b,(%esp)
  1051bb:	e8 60 b7 ff ff       	call   100920 <panic>

001051c0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  1051c0:	55                   	push   %ebp
  1051c1:	31 c0                	xor    %eax,%eax
  1051c3:	89 e5                	mov    %esp,%ebp
  1051c5:	ba a0 e2 10 00       	mov    $0x10e2a0,%edx
  1051ca:	83 ec 18             	sub    $0x18,%esp
  1051cd:	8d 76 00             	lea    0x0(%esi),%esi
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  1051d0:	8b 0c 85 28 73 10 00 	mov    0x107328(,%eax,4),%ecx
  1051d7:	66 89 0c c5 a0 e2 10 	mov    %cx,0x10e2a0(,%eax,8)
  1051de:	00 
  1051df:	c1 e9 10             	shr    $0x10,%ecx
  1051e2:	66 c7 44 c2 02 08 00 	movw   $0x8,0x2(%edx,%eax,8)
  1051e9:	c6 44 c2 04 00       	movb   $0x0,0x4(%edx,%eax,8)
  1051ee:	c6 44 c2 05 8e       	movb   $0x8e,0x5(%edx,%eax,8)
  1051f3:	66 89 4c c2 06       	mov    %cx,0x6(%edx,%eax,8)
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
  1051f8:	83 c0 01             	add    $0x1,%eax
  1051fb:	3d 00 01 00 00       	cmp    $0x100,%eax
  105200:	75 ce                	jne    1051d0 <tvinit+0x10>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  105202:	a1 28 74 10 00       	mov    0x107428,%eax
  
  initlock(&tickslock, "time");
  105207:	c7 44 24 04 20 6e 10 	movl   $0x106e20,0x4(%esp)
  10520e:	00 
  10520f:	c7 04 24 60 e2 10 00 	movl   $0x10e260,(%esp)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  105216:	66 c7 05 a2 e4 10 00 	movw   $0x8,0x10e4a2
  10521d:	08 00 
  10521f:	66 a3 a0 e4 10 00    	mov    %ax,0x10e4a0
  105225:	c1 e8 10             	shr    $0x10,%eax
  105228:	c6 05 a4 e4 10 00 00 	movb   $0x0,0x10e4a4
  10522f:	c6 05 a5 e4 10 00 ef 	movb   $0xef,0x10e4a5
  105236:	66 a3 a6 e4 10 00    	mov    %ax,0x10e4a6
  
  initlock(&tickslock, "time");
  10523c:	e8 5f e9 ff ff       	call   103ba0 <initlock>
}
  105241:	c9                   	leave  
  105242:	c3                   	ret    
  105243:	90                   	nop
  105244:	90                   	nop
  105245:	90                   	nop
  105246:	90                   	nop
  105247:	90                   	nop
  105248:	90                   	nop
  105249:	90                   	nop
  10524a:	90                   	nop
  10524b:	90                   	nop
  10524c:	90                   	nop
  10524d:	90                   	nop
  10524e:	90                   	nop
  10524f:	90                   	nop

00105250 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
  105250:	a1 cc 78 10 00       	mov    0x1078cc,%eax
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
  105255:	55                   	push   %ebp
  105256:	89 e5                	mov    %esp,%ebp
  if(!uart)
  105258:	85 c0                	test   %eax,%eax
  10525a:	75 0c                	jne    105268 <uartgetc+0x18>
    return -1;
  if(!(inb(COM1+5) & 0x01))
    return -1;
  return inb(COM1+0);
  10525c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  105261:	5d                   	pop    %ebp
  105262:	c3                   	ret    
  105263:	90                   	nop
  105264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105268:	ba fd 03 00 00       	mov    $0x3fd,%edx
  10526d:	ec                   	in     (%dx),%al
static int
uartgetc(void)
{
  if(!uart)
    return -1;
  if(!(inb(COM1+5) & 0x01))
  10526e:	a8 01                	test   $0x1,%al
  105270:	74 ea                	je     10525c <uartgetc+0xc>
  105272:	b2 f8                	mov    $0xf8,%dl
  105274:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
  105275:	0f b6 c0             	movzbl %al,%eax
}
  105278:	5d                   	pop    %ebp
  105279:	c3                   	ret    
  10527a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00105280 <uartintr>:

void
uartintr(void)
{
  105280:	55                   	push   %ebp
  105281:	89 e5                	mov    %esp,%ebp
  105283:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
  105286:	c7 04 24 50 52 10 00 	movl   $0x105250,(%esp)
  10528d:	e8 fe b4 ff ff       	call   100790 <consoleintr>
}
  105292:	c9                   	leave  
  105293:	c3                   	ret    
  105294:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10529a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001052a0 <uartputc>:
    uartputc(*p);
}

void
uartputc(int c)
{
  1052a0:	55                   	push   %ebp
  1052a1:	89 e5                	mov    %esp,%ebp
  1052a3:	56                   	push   %esi
  1052a4:	be fd 03 00 00       	mov    $0x3fd,%esi
  1052a9:	53                   	push   %ebx
  int i;

  if(!uart)
  1052aa:	31 db                	xor    %ebx,%ebx
    uartputc(*p);
}

void
uartputc(int c)
{
  1052ac:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(!uart)
  1052af:	8b 15 cc 78 10 00    	mov    0x1078cc,%edx
  1052b5:	85 d2                	test   %edx,%edx
  1052b7:	75 1e                	jne    1052d7 <uartputc+0x37>
  1052b9:	eb 2c                	jmp    1052e7 <uartputc+0x47>
  1052bb:	90                   	nop
  1052bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1052c0:	83 c3 01             	add    $0x1,%ebx
    microdelay(10);
  1052c3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1052ca:	e8 d1 d1 ff ff       	call   1024a0 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1052cf:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  1052d5:	74 07                	je     1052de <uartputc+0x3e>
  1052d7:	89 f2                	mov    %esi,%edx
  1052d9:	ec                   	in     (%dx),%al
  1052da:	a8 20                	test   $0x20,%al
  1052dc:	74 e2                	je     1052c0 <uartputc+0x20>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1052de:	ba f8 03 00 00       	mov    $0x3f8,%edx
  1052e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1052e6:	ee                   	out    %al,(%dx)
    microdelay(10);
  outb(COM1+0, c);
}
  1052e7:	83 c4 10             	add    $0x10,%esp
  1052ea:	5b                   	pop    %ebx
  1052eb:	5e                   	pop    %esi
  1052ec:	5d                   	pop    %ebp
  1052ed:	c3                   	ret    
  1052ee:	66 90                	xchg   %ax,%ax

001052f0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
  1052f0:	55                   	push   %ebp
  1052f1:	31 c9                	xor    %ecx,%ecx
  1052f3:	89 e5                	mov    %esp,%ebp
  1052f5:	89 c8                	mov    %ecx,%eax
  1052f7:	57                   	push   %edi
  1052f8:	bf fa 03 00 00       	mov    $0x3fa,%edi
  1052fd:	56                   	push   %esi
  1052fe:	89 fa                	mov    %edi,%edx
  105300:	53                   	push   %ebx
  105301:	83 ec 1c             	sub    $0x1c,%esp
  105304:	ee                   	out    %al,(%dx)
  105305:	bb fb 03 00 00       	mov    $0x3fb,%ebx
  10530a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  10530f:	89 da                	mov    %ebx,%edx
  105311:	ee                   	out    %al,(%dx)
  105312:	b8 0c 00 00 00       	mov    $0xc,%eax
  105317:	b2 f8                	mov    $0xf8,%dl
  105319:	ee                   	out    %al,(%dx)
  10531a:	be f9 03 00 00       	mov    $0x3f9,%esi
  10531f:	89 c8                	mov    %ecx,%eax
  105321:	89 f2                	mov    %esi,%edx
  105323:	ee                   	out    %al,(%dx)
  105324:	b8 03 00 00 00       	mov    $0x3,%eax
  105329:	89 da                	mov    %ebx,%edx
  10532b:	ee                   	out    %al,(%dx)
  10532c:	b2 fc                	mov    $0xfc,%dl
  10532e:	89 c8                	mov    %ecx,%eax
  105330:	ee                   	out    %al,(%dx)
  105331:	b8 01 00 00 00       	mov    $0x1,%eax
  105336:	89 f2                	mov    %esi,%edx
  105338:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105339:	b2 fd                	mov    $0xfd,%dl
  10533b:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
  10533c:	3c ff                	cmp    $0xff,%al
  10533e:	74 55                	je     105395 <uartinit+0xa5>
    return;
  uart = 1;
  105340:	c7 05 cc 78 10 00 01 	movl   $0x1,0x1078cc
  105347:	00 00 00 
  10534a:	89 fa                	mov    %edi,%edx
  10534c:	ec                   	in     (%dx),%al
  10534d:	b2 f8                	mov    $0xf8,%dl
  10534f:	ec                   	in     (%dx),%al
  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  105350:	bb a8 6e 10 00       	mov    $0x106ea8,%ebx

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  105355:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10535c:	e8 5f d8 ff ff       	call   102bc0 <picenable>
  ioapicenable(IRQ_COM1, 0);
  105361:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105368:	00 
  105369:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  105370:	e8 fb cd ff ff       	call   102170 <ioapicenable>
  105375:	b8 78 00 00 00       	mov    $0x78,%eax
  10537a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
  105380:	0f be c0             	movsbl %al,%eax
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  105383:	83 c3 01             	add    $0x1,%ebx
    uartputc(*p);
  105386:	89 04 24             	mov    %eax,(%esp)
  105389:	e8 12 ff ff ff       	call   1052a0 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  10538e:	0f b6 03             	movzbl (%ebx),%eax
  105391:	84 c0                	test   %al,%al
  105393:	75 eb                	jne    105380 <uartinit+0x90>
    uartputc(*p);
}
  105395:	83 c4 1c             	add    $0x1c,%esp
  105398:	5b                   	pop    %ebx
  105399:	5e                   	pop    %esi
  10539a:	5f                   	pop    %edi
  10539b:	5d                   	pop    %ebp
  10539c:	c3                   	ret    
  10539d:	90                   	nop
  10539e:	90                   	nop
  10539f:	90                   	nop

001053a0 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
  1053a0:	6a 00                	push   $0x0
  pushl $0
  1053a2:	6a 00                	push   $0x0
  jmp alltraps
  1053a4:	e9 57 fb ff ff       	jmp    104f00 <alltraps>

001053a9 <vector1>:
.globl vector1
vector1:
  pushl $0
  1053a9:	6a 00                	push   $0x0
  pushl $1
  1053ab:	6a 01                	push   $0x1
  jmp alltraps
  1053ad:	e9 4e fb ff ff       	jmp    104f00 <alltraps>

001053b2 <vector2>:
.globl vector2
vector2:
  pushl $0
  1053b2:	6a 00                	push   $0x0
  pushl $2
  1053b4:	6a 02                	push   $0x2
  jmp alltraps
  1053b6:	e9 45 fb ff ff       	jmp    104f00 <alltraps>

001053bb <vector3>:
.globl vector3
vector3:
  pushl $0
  1053bb:	6a 00                	push   $0x0
  pushl $3
  1053bd:	6a 03                	push   $0x3
  jmp alltraps
  1053bf:	e9 3c fb ff ff       	jmp    104f00 <alltraps>

001053c4 <vector4>:
.globl vector4
vector4:
  pushl $0
  1053c4:	6a 00                	push   $0x0
  pushl $4
  1053c6:	6a 04                	push   $0x4
  jmp alltraps
  1053c8:	e9 33 fb ff ff       	jmp    104f00 <alltraps>

001053cd <vector5>:
.globl vector5
vector5:
  pushl $0
  1053cd:	6a 00                	push   $0x0
  pushl $5
  1053cf:	6a 05                	push   $0x5
  jmp alltraps
  1053d1:	e9 2a fb ff ff       	jmp    104f00 <alltraps>

001053d6 <vector6>:
.globl vector6
vector6:
  pushl $0
  1053d6:	6a 00                	push   $0x0
  pushl $6
  1053d8:	6a 06                	push   $0x6
  jmp alltraps
  1053da:	e9 21 fb ff ff       	jmp    104f00 <alltraps>

001053df <vector7>:
.globl vector7
vector7:
  pushl $0
  1053df:	6a 00                	push   $0x0
  pushl $7
  1053e1:	6a 07                	push   $0x7
  jmp alltraps
  1053e3:	e9 18 fb ff ff       	jmp    104f00 <alltraps>

001053e8 <vector8>:
.globl vector8
vector8:
  pushl $8
  1053e8:	6a 08                	push   $0x8
  jmp alltraps
  1053ea:	e9 11 fb ff ff       	jmp    104f00 <alltraps>

001053ef <vector9>:
.globl vector9
vector9:
  pushl $0
  1053ef:	6a 00                	push   $0x0
  pushl $9
  1053f1:	6a 09                	push   $0x9
  jmp alltraps
  1053f3:	e9 08 fb ff ff       	jmp    104f00 <alltraps>

001053f8 <vector10>:
.globl vector10
vector10:
  pushl $10
  1053f8:	6a 0a                	push   $0xa
  jmp alltraps
  1053fa:	e9 01 fb ff ff       	jmp    104f00 <alltraps>

001053ff <vector11>:
.globl vector11
vector11:
  pushl $11
  1053ff:	6a 0b                	push   $0xb
  jmp alltraps
  105401:	e9 fa fa ff ff       	jmp    104f00 <alltraps>

00105406 <vector12>:
.globl vector12
vector12:
  pushl $12
  105406:	6a 0c                	push   $0xc
  jmp alltraps
  105408:	e9 f3 fa ff ff       	jmp    104f00 <alltraps>

0010540d <vector13>:
.globl vector13
vector13:
  pushl $13
  10540d:	6a 0d                	push   $0xd
  jmp alltraps
  10540f:	e9 ec fa ff ff       	jmp    104f00 <alltraps>

00105414 <vector14>:
.globl vector14
vector14:
  pushl $14
  105414:	6a 0e                	push   $0xe
  jmp alltraps
  105416:	e9 e5 fa ff ff       	jmp    104f00 <alltraps>

0010541b <vector15>:
.globl vector15
vector15:
  pushl $0
  10541b:	6a 00                	push   $0x0
  pushl $15
  10541d:	6a 0f                	push   $0xf
  jmp alltraps
  10541f:	e9 dc fa ff ff       	jmp    104f00 <alltraps>

00105424 <vector16>:
.globl vector16
vector16:
  pushl $0
  105424:	6a 00                	push   $0x0
  pushl $16
  105426:	6a 10                	push   $0x10
  jmp alltraps
  105428:	e9 d3 fa ff ff       	jmp    104f00 <alltraps>

0010542d <vector17>:
.globl vector17
vector17:
  pushl $17
  10542d:	6a 11                	push   $0x11
  jmp alltraps
  10542f:	e9 cc fa ff ff       	jmp    104f00 <alltraps>

00105434 <vector18>:
.globl vector18
vector18:
  pushl $0
  105434:	6a 00                	push   $0x0
  pushl $18
  105436:	6a 12                	push   $0x12
  jmp alltraps
  105438:	e9 c3 fa ff ff       	jmp    104f00 <alltraps>

0010543d <vector19>:
.globl vector19
vector19:
  pushl $0
  10543d:	6a 00                	push   $0x0
  pushl $19
  10543f:	6a 13                	push   $0x13
  jmp alltraps
  105441:	e9 ba fa ff ff       	jmp    104f00 <alltraps>

00105446 <vector20>:
.globl vector20
vector20:
  pushl $0
  105446:	6a 00                	push   $0x0
  pushl $20
  105448:	6a 14                	push   $0x14
  jmp alltraps
  10544a:	e9 b1 fa ff ff       	jmp    104f00 <alltraps>

0010544f <vector21>:
.globl vector21
vector21:
  pushl $0
  10544f:	6a 00                	push   $0x0
  pushl $21
  105451:	6a 15                	push   $0x15
  jmp alltraps
  105453:	e9 a8 fa ff ff       	jmp    104f00 <alltraps>

00105458 <vector22>:
.globl vector22
vector22:
  pushl $0
  105458:	6a 00                	push   $0x0
  pushl $22
  10545a:	6a 16                	push   $0x16
  jmp alltraps
  10545c:	e9 9f fa ff ff       	jmp    104f00 <alltraps>

00105461 <vector23>:
.globl vector23
vector23:
  pushl $0
  105461:	6a 00                	push   $0x0
  pushl $23
  105463:	6a 17                	push   $0x17
  jmp alltraps
  105465:	e9 96 fa ff ff       	jmp    104f00 <alltraps>

0010546a <vector24>:
.globl vector24
vector24:
  pushl $0
  10546a:	6a 00                	push   $0x0
  pushl $24
  10546c:	6a 18                	push   $0x18
  jmp alltraps
  10546e:	e9 8d fa ff ff       	jmp    104f00 <alltraps>

00105473 <vector25>:
.globl vector25
vector25:
  pushl $0
  105473:	6a 00                	push   $0x0
  pushl $25
  105475:	6a 19                	push   $0x19
  jmp alltraps
  105477:	e9 84 fa ff ff       	jmp    104f00 <alltraps>

0010547c <vector26>:
.globl vector26
vector26:
  pushl $0
  10547c:	6a 00                	push   $0x0
  pushl $26
  10547e:	6a 1a                	push   $0x1a
  jmp alltraps
  105480:	e9 7b fa ff ff       	jmp    104f00 <alltraps>

00105485 <vector27>:
.globl vector27
vector27:
  pushl $0
  105485:	6a 00                	push   $0x0
  pushl $27
  105487:	6a 1b                	push   $0x1b
  jmp alltraps
  105489:	e9 72 fa ff ff       	jmp    104f00 <alltraps>

0010548e <vector28>:
.globl vector28
vector28:
  pushl $0
  10548e:	6a 00                	push   $0x0
  pushl $28
  105490:	6a 1c                	push   $0x1c
  jmp alltraps
  105492:	e9 69 fa ff ff       	jmp    104f00 <alltraps>

00105497 <vector29>:
.globl vector29
vector29:
  pushl $0
  105497:	6a 00                	push   $0x0
  pushl $29
  105499:	6a 1d                	push   $0x1d
  jmp alltraps
  10549b:	e9 60 fa ff ff       	jmp    104f00 <alltraps>

001054a0 <vector30>:
.globl vector30
vector30:
  pushl $0
  1054a0:	6a 00                	push   $0x0
  pushl $30
  1054a2:	6a 1e                	push   $0x1e
  jmp alltraps
  1054a4:	e9 57 fa ff ff       	jmp    104f00 <alltraps>

001054a9 <vector31>:
.globl vector31
vector31:
  pushl $0
  1054a9:	6a 00                	push   $0x0
  pushl $31
  1054ab:	6a 1f                	push   $0x1f
  jmp alltraps
  1054ad:	e9 4e fa ff ff       	jmp    104f00 <alltraps>

001054b2 <vector32>:
.globl vector32
vector32:
  pushl $0
  1054b2:	6a 00                	push   $0x0
  pushl $32
  1054b4:	6a 20                	push   $0x20
  jmp alltraps
  1054b6:	e9 45 fa ff ff       	jmp    104f00 <alltraps>

001054bb <vector33>:
.globl vector33
vector33:
  pushl $0
  1054bb:	6a 00                	push   $0x0
  pushl $33
  1054bd:	6a 21                	push   $0x21
  jmp alltraps
  1054bf:	e9 3c fa ff ff       	jmp    104f00 <alltraps>

001054c4 <vector34>:
.globl vector34
vector34:
  pushl $0
  1054c4:	6a 00                	push   $0x0
  pushl $34
  1054c6:	6a 22                	push   $0x22
  jmp alltraps
  1054c8:	e9 33 fa ff ff       	jmp    104f00 <alltraps>

001054cd <vector35>:
.globl vector35
vector35:
  pushl $0
  1054cd:	6a 00                	push   $0x0
  pushl $35
  1054cf:	6a 23                	push   $0x23
  jmp alltraps
  1054d1:	e9 2a fa ff ff       	jmp    104f00 <alltraps>

001054d6 <vector36>:
.globl vector36
vector36:
  pushl $0
  1054d6:	6a 00                	push   $0x0
  pushl $36
  1054d8:	6a 24                	push   $0x24
  jmp alltraps
  1054da:	e9 21 fa ff ff       	jmp    104f00 <alltraps>

001054df <vector37>:
.globl vector37
vector37:
  pushl $0
  1054df:	6a 00                	push   $0x0
  pushl $37
  1054e1:	6a 25                	push   $0x25
  jmp alltraps
  1054e3:	e9 18 fa ff ff       	jmp    104f00 <alltraps>

001054e8 <vector38>:
.globl vector38
vector38:
  pushl $0
  1054e8:	6a 00                	push   $0x0
  pushl $38
  1054ea:	6a 26                	push   $0x26
  jmp alltraps
  1054ec:	e9 0f fa ff ff       	jmp    104f00 <alltraps>

001054f1 <vector39>:
.globl vector39
vector39:
  pushl $0
  1054f1:	6a 00                	push   $0x0
  pushl $39
  1054f3:	6a 27                	push   $0x27
  jmp alltraps
  1054f5:	e9 06 fa ff ff       	jmp    104f00 <alltraps>

001054fa <vector40>:
.globl vector40
vector40:
  pushl $0
  1054fa:	6a 00                	push   $0x0
  pushl $40
  1054fc:	6a 28                	push   $0x28
  jmp alltraps
  1054fe:	e9 fd f9 ff ff       	jmp    104f00 <alltraps>

00105503 <vector41>:
.globl vector41
vector41:
  pushl $0
  105503:	6a 00                	push   $0x0
  pushl $41
  105505:	6a 29                	push   $0x29
  jmp alltraps
  105507:	e9 f4 f9 ff ff       	jmp    104f00 <alltraps>

0010550c <vector42>:
.globl vector42
vector42:
  pushl $0
  10550c:	6a 00                	push   $0x0
  pushl $42
  10550e:	6a 2a                	push   $0x2a
  jmp alltraps
  105510:	e9 eb f9 ff ff       	jmp    104f00 <alltraps>

00105515 <vector43>:
.globl vector43
vector43:
  pushl $0
  105515:	6a 00                	push   $0x0
  pushl $43
  105517:	6a 2b                	push   $0x2b
  jmp alltraps
  105519:	e9 e2 f9 ff ff       	jmp    104f00 <alltraps>

0010551e <vector44>:
.globl vector44
vector44:
  pushl $0
  10551e:	6a 00                	push   $0x0
  pushl $44
  105520:	6a 2c                	push   $0x2c
  jmp alltraps
  105522:	e9 d9 f9 ff ff       	jmp    104f00 <alltraps>

00105527 <vector45>:
.globl vector45
vector45:
  pushl $0
  105527:	6a 00                	push   $0x0
  pushl $45
  105529:	6a 2d                	push   $0x2d
  jmp alltraps
  10552b:	e9 d0 f9 ff ff       	jmp    104f00 <alltraps>

00105530 <vector46>:
.globl vector46
vector46:
  pushl $0
  105530:	6a 00                	push   $0x0
  pushl $46
  105532:	6a 2e                	push   $0x2e
  jmp alltraps
  105534:	e9 c7 f9 ff ff       	jmp    104f00 <alltraps>

00105539 <vector47>:
.globl vector47
vector47:
  pushl $0
  105539:	6a 00                	push   $0x0
  pushl $47
  10553b:	6a 2f                	push   $0x2f
  jmp alltraps
  10553d:	e9 be f9 ff ff       	jmp    104f00 <alltraps>

00105542 <vector48>:
.globl vector48
vector48:
  pushl $0
  105542:	6a 00                	push   $0x0
  pushl $48
  105544:	6a 30                	push   $0x30
  jmp alltraps
  105546:	e9 b5 f9 ff ff       	jmp    104f00 <alltraps>

0010554b <vector49>:
.globl vector49
vector49:
  pushl $0
  10554b:	6a 00                	push   $0x0
  pushl $49
  10554d:	6a 31                	push   $0x31
  jmp alltraps
  10554f:	e9 ac f9 ff ff       	jmp    104f00 <alltraps>

00105554 <vector50>:
.globl vector50
vector50:
  pushl $0
  105554:	6a 00                	push   $0x0
  pushl $50
  105556:	6a 32                	push   $0x32
  jmp alltraps
  105558:	e9 a3 f9 ff ff       	jmp    104f00 <alltraps>

0010555d <vector51>:
.globl vector51
vector51:
  pushl $0
  10555d:	6a 00                	push   $0x0
  pushl $51
  10555f:	6a 33                	push   $0x33
  jmp alltraps
  105561:	e9 9a f9 ff ff       	jmp    104f00 <alltraps>

00105566 <vector52>:
.globl vector52
vector52:
  pushl $0
  105566:	6a 00                	push   $0x0
  pushl $52
  105568:	6a 34                	push   $0x34
  jmp alltraps
  10556a:	e9 91 f9 ff ff       	jmp    104f00 <alltraps>

0010556f <vector53>:
.globl vector53
vector53:
  pushl $0
  10556f:	6a 00                	push   $0x0
  pushl $53
  105571:	6a 35                	push   $0x35
  jmp alltraps
  105573:	e9 88 f9 ff ff       	jmp    104f00 <alltraps>

00105578 <vector54>:
.globl vector54
vector54:
  pushl $0
  105578:	6a 00                	push   $0x0
  pushl $54
  10557a:	6a 36                	push   $0x36
  jmp alltraps
  10557c:	e9 7f f9 ff ff       	jmp    104f00 <alltraps>

00105581 <vector55>:
.globl vector55
vector55:
  pushl $0
  105581:	6a 00                	push   $0x0
  pushl $55
  105583:	6a 37                	push   $0x37
  jmp alltraps
  105585:	e9 76 f9 ff ff       	jmp    104f00 <alltraps>

0010558a <vector56>:
.globl vector56
vector56:
  pushl $0
  10558a:	6a 00                	push   $0x0
  pushl $56
  10558c:	6a 38                	push   $0x38
  jmp alltraps
  10558e:	e9 6d f9 ff ff       	jmp    104f00 <alltraps>

00105593 <vector57>:
.globl vector57
vector57:
  pushl $0
  105593:	6a 00                	push   $0x0
  pushl $57
  105595:	6a 39                	push   $0x39
  jmp alltraps
  105597:	e9 64 f9 ff ff       	jmp    104f00 <alltraps>

0010559c <vector58>:
.globl vector58
vector58:
  pushl $0
  10559c:	6a 00                	push   $0x0
  pushl $58
  10559e:	6a 3a                	push   $0x3a
  jmp alltraps
  1055a0:	e9 5b f9 ff ff       	jmp    104f00 <alltraps>

001055a5 <vector59>:
.globl vector59
vector59:
  pushl $0
  1055a5:	6a 00                	push   $0x0
  pushl $59
  1055a7:	6a 3b                	push   $0x3b
  jmp alltraps
  1055a9:	e9 52 f9 ff ff       	jmp    104f00 <alltraps>

001055ae <vector60>:
.globl vector60
vector60:
  pushl $0
  1055ae:	6a 00                	push   $0x0
  pushl $60
  1055b0:	6a 3c                	push   $0x3c
  jmp alltraps
  1055b2:	e9 49 f9 ff ff       	jmp    104f00 <alltraps>

001055b7 <vector61>:
.globl vector61
vector61:
  pushl $0
  1055b7:	6a 00                	push   $0x0
  pushl $61
  1055b9:	6a 3d                	push   $0x3d
  jmp alltraps
  1055bb:	e9 40 f9 ff ff       	jmp    104f00 <alltraps>

001055c0 <vector62>:
.globl vector62
vector62:
  pushl $0
  1055c0:	6a 00                	push   $0x0
  pushl $62
  1055c2:	6a 3e                	push   $0x3e
  jmp alltraps
  1055c4:	e9 37 f9 ff ff       	jmp    104f00 <alltraps>

001055c9 <vector63>:
.globl vector63
vector63:
  pushl $0
  1055c9:	6a 00                	push   $0x0
  pushl $63
  1055cb:	6a 3f                	push   $0x3f
  jmp alltraps
  1055cd:	e9 2e f9 ff ff       	jmp    104f00 <alltraps>

001055d2 <vector64>:
.globl vector64
vector64:
  pushl $0
  1055d2:	6a 00                	push   $0x0
  pushl $64
  1055d4:	6a 40                	push   $0x40
  jmp alltraps
  1055d6:	e9 25 f9 ff ff       	jmp    104f00 <alltraps>

001055db <vector65>:
.globl vector65
vector65:
  pushl $0
  1055db:	6a 00                	push   $0x0
  pushl $65
  1055dd:	6a 41                	push   $0x41
  jmp alltraps
  1055df:	e9 1c f9 ff ff       	jmp    104f00 <alltraps>

001055e4 <vector66>:
.globl vector66
vector66:
  pushl $0
  1055e4:	6a 00                	push   $0x0
  pushl $66
  1055e6:	6a 42                	push   $0x42
  jmp alltraps
  1055e8:	e9 13 f9 ff ff       	jmp    104f00 <alltraps>

001055ed <vector67>:
.globl vector67
vector67:
  pushl $0
  1055ed:	6a 00                	push   $0x0
  pushl $67
  1055ef:	6a 43                	push   $0x43
  jmp alltraps
  1055f1:	e9 0a f9 ff ff       	jmp    104f00 <alltraps>

001055f6 <vector68>:
.globl vector68
vector68:
  pushl $0
  1055f6:	6a 00                	push   $0x0
  pushl $68
  1055f8:	6a 44                	push   $0x44
  jmp alltraps
  1055fa:	e9 01 f9 ff ff       	jmp    104f00 <alltraps>

001055ff <vector69>:
.globl vector69
vector69:
  pushl $0
  1055ff:	6a 00                	push   $0x0
  pushl $69
  105601:	6a 45                	push   $0x45
  jmp alltraps
  105603:	e9 f8 f8 ff ff       	jmp    104f00 <alltraps>

00105608 <vector70>:
.globl vector70
vector70:
  pushl $0
  105608:	6a 00                	push   $0x0
  pushl $70
  10560a:	6a 46                	push   $0x46
  jmp alltraps
  10560c:	e9 ef f8 ff ff       	jmp    104f00 <alltraps>

00105611 <vector71>:
.globl vector71
vector71:
  pushl $0
  105611:	6a 00                	push   $0x0
  pushl $71
  105613:	6a 47                	push   $0x47
  jmp alltraps
  105615:	e9 e6 f8 ff ff       	jmp    104f00 <alltraps>

0010561a <vector72>:
.globl vector72
vector72:
  pushl $0
  10561a:	6a 00                	push   $0x0
  pushl $72
  10561c:	6a 48                	push   $0x48
  jmp alltraps
  10561e:	e9 dd f8 ff ff       	jmp    104f00 <alltraps>

00105623 <vector73>:
.globl vector73
vector73:
  pushl $0
  105623:	6a 00                	push   $0x0
  pushl $73
  105625:	6a 49                	push   $0x49
  jmp alltraps
  105627:	e9 d4 f8 ff ff       	jmp    104f00 <alltraps>

0010562c <vector74>:
.globl vector74
vector74:
  pushl $0
  10562c:	6a 00                	push   $0x0
  pushl $74
  10562e:	6a 4a                	push   $0x4a
  jmp alltraps
  105630:	e9 cb f8 ff ff       	jmp    104f00 <alltraps>

00105635 <vector75>:
.globl vector75
vector75:
  pushl $0
  105635:	6a 00                	push   $0x0
  pushl $75
  105637:	6a 4b                	push   $0x4b
  jmp alltraps
  105639:	e9 c2 f8 ff ff       	jmp    104f00 <alltraps>

0010563e <vector76>:
.globl vector76
vector76:
  pushl $0
  10563e:	6a 00                	push   $0x0
  pushl $76
  105640:	6a 4c                	push   $0x4c
  jmp alltraps
  105642:	e9 b9 f8 ff ff       	jmp    104f00 <alltraps>

00105647 <vector77>:
.globl vector77
vector77:
  pushl $0
  105647:	6a 00                	push   $0x0
  pushl $77
  105649:	6a 4d                	push   $0x4d
  jmp alltraps
  10564b:	e9 b0 f8 ff ff       	jmp    104f00 <alltraps>

00105650 <vector78>:
.globl vector78
vector78:
  pushl $0
  105650:	6a 00                	push   $0x0
  pushl $78
  105652:	6a 4e                	push   $0x4e
  jmp alltraps
  105654:	e9 a7 f8 ff ff       	jmp    104f00 <alltraps>

00105659 <vector79>:
.globl vector79
vector79:
  pushl $0
  105659:	6a 00                	push   $0x0
  pushl $79
  10565b:	6a 4f                	push   $0x4f
  jmp alltraps
  10565d:	e9 9e f8 ff ff       	jmp    104f00 <alltraps>

00105662 <vector80>:
.globl vector80
vector80:
  pushl $0
  105662:	6a 00                	push   $0x0
  pushl $80
  105664:	6a 50                	push   $0x50
  jmp alltraps
  105666:	e9 95 f8 ff ff       	jmp    104f00 <alltraps>

0010566b <vector81>:
.globl vector81
vector81:
  pushl $0
  10566b:	6a 00                	push   $0x0
  pushl $81
  10566d:	6a 51                	push   $0x51
  jmp alltraps
  10566f:	e9 8c f8 ff ff       	jmp    104f00 <alltraps>

00105674 <vector82>:
.globl vector82
vector82:
  pushl $0
  105674:	6a 00                	push   $0x0
  pushl $82
  105676:	6a 52                	push   $0x52
  jmp alltraps
  105678:	e9 83 f8 ff ff       	jmp    104f00 <alltraps>

0010567d <vector83>:
.globl vector83
vector83:
  pushl $0
  10567d:	6a 00                	push   $0x0
  pushl $83
  10567f:	6a 53                	push   $0x53
  jmp alltraps
  105681:	e9 7a f8 ff ff       	jmp    104f00 <alltraps>

00105686 <vector84>:
.globl vector84
vector84:
  pushl $0
  105686:	6a 00                	push   $0x0
  pushl $84
  105688:	6a 54                	push   $0x54
  jmp alltraps
  10568a:	e9 71 f8 ff ff       	jmp    104f00 <alltraps>

0010568f <vector85>:
.globl vector85
vector85:
  pushl $0
  10568f:	6a 00                	push   $0x0
  pushl $85
  105691:	6a 55                	push   $0x55
  jmp alltraps
  105693:	e9 68 f8 ff ff       	jmp    104f00 <alltraps>

00105698 <vector86>:
.globl vector86
vector86:
  pushl $0
  105698:	6a 00                	push   $0x0
  pushl $86
  10569a:	6a 56                	push   $0x56
  jmp alltraps
  10569c:	e9 5f f8 ff ff       	jmp    104f00 <alltraps>

001056a1 <vector87>:
.globl vector87
vector87:
  pushl $0
  1056a1:	6a 00                	push   $0x0
  pushl $87
  1056a3:	6a 57                	push   $0x57
  jmp alltraps
  1056a5:	e9 56 f8 ff ff       	jmp    104f00 <alltraps>

001056aa <vector88>:
.globl vector88
vector88:
  pushl $0
  1056aa:	6a 00                	push   $0x0
  pushl $88
  1056ac:	6a 58                	push   $0x58
  jmp alltraps
  1056ae:	e9 4d f8 ff ff       	jmp    104f00 <alltraps>

001056b3 <vector89>:
.globl vector89
vector89:
  pushl $0
  1056b3:	6a 00                	push   $0x0
  pushl $89
  1056b5:	6a 59                	push   $0x59
  jmp alltraps
  1056b7:	e9 44 f8 ff ff       	jmp    104f00 <alltraps>

001056bc <vector90>:
.globl vector90
vector90:
  pushl $0
  1056bc:	6a 00                	push   $0x0
  pushl $90
  1056be:	6a 5a                	push   $0x5a
  jmp alltraps
  1056c0:	e9 3b f8 ff ff       	jmp    104f00 <alltraps>

001056c5 <vector91>:
.globl vector91
vector91:
  pushl $0
  1056c5:	6a 00                	push   $0x0
  pushl $91
  1056c7:	6a 5b                	push   $0x5b
  jmp alltraps
  1056c9:	e9 32 f8 ff ff       	jmp    104f00 <alltraps>

001056ce <vector92>:
.globl vector92
vector92:
  pushl $0
  1056ce:	6a 00                	push   $0x0
  pushl $92
  1056d0:	6a 5c                	push   $0x5c
  jmp alltraps
  1056d2:	e9 29 f8 ff ff       	jmp    104f00 <alltraps>

001056d7 <vector93>:
.globl vector93
vector93:
  pushl $0
  1056d7:	6a 00                	push   $0x0
  pushl $93
  1056d9:	6a 5d                	push   $0x5d
  jmp alltraps
  1056db:	e9 20 f8 ff ff       	jmp    104f00 <alltraps>

001056e0 <vector94>:
.globl vector94
vector94:
  pushl $0
  1056e0:	6a 00                	push   $0x0
  pushl $94
  1056e2:	6a 5e                	push   $0x5e
  jmp alltraps
  1056e4:	e9 17 f8 ff ff       	jmp    104f00 <alltraps>

001056e9 <vector95>:
.globl vector95
vector95:
  pushl $0
  1056e9:	6a 00                	push   $0x0
  pushl $95
  1056eb:	6a 5f                	push   $0x5f
  jmp alltraps
  1056ed:	e9 0e f8 ff ff       	jmp    104f00 <alltraps>

001056f2 <vector96>:
.globl vector96
vector96:
  pushl $0
  1056f2:	6a 00                	push   $0x0
  pushl $96
  1056f4:	6a 60                	push   $0x60
  jmp alltraps
  1056f6:	e9 05 f8 ff ff       	jmp    104f00 <alltraps>

001056fb <vector97>:
.globl vector97
vector97:
  pushl $0
  1056fb:	6a 00                	push   $0x0
  pushl $97
  1056fd:	6a 61                	push   $0x61
  jmp alltraps
  1056ff:	e9 fc f7 ff ff       	jmp    104f00 <alltraps>

00105704 <vector98>:
.globl vector98
vector98:
  pushl $0
  105704:	6a 00                	push   $0x0
  pushl $98
  105706:	6a 62                	push   $0x62
  jmp alltraps
  105708:	e9 f3 f7 ff ff       	jmp    104f00 <alltraps>

0010570d <vector99>:
.globl vector99
vector99:
  pushl $0
  10570d:	6a 00                	push   $0x0
  pushl $99
  10570f:	6a 63                	push   $0x63
  jmp alltraps
  105711:	e9 ea f7 ff ff       	jmp    104f00 <alltraps>

00105716 <vector100>:
.globl vector100
vector100:
  pushl $0
  105716:	6a 00                	push   $0x0
  pushl $100
  105718:	6a 64                	push   $0x64
  jmp alltraps
  10571a:	e9 e1 f7 ff ff       	jmp    104f00 <alltraps>

0010571f <vector101>:
.globl vector101
vector101:
  pushl $0
  10571f:	6a 00                	push   $0x0
  pushl $101
  105721:	6a 65                	push   $0x65
  jmp alltraps
  105723:	e9 d8 f7 ff ff       	jmp    104f00 <alltraps>

00105728 <vector102>:
.globl vector102
vector102:
  pushl $0
  105728:	6a 00                	push   $0x0
  pushl $102
  10572a:	6a 66                	push   $0x66
  jmp alltraps
  10572c:	e9 cf f7 ff ff       	jmp    104f00 <alltraps>

00105731 <vector103>:
.globl vector103
vector103:
  pushl $0
  105731:	6a 00                	push   $0x0
  pushl $103
  105733:	6a 67                	push   $0x67
  jmp alltraps
  105735:	e9 c6 f7 ff ff       	jmp    104f00 <alltraps>

0010573a <vector104>:
.globl vector104
vector104:
  pushl $0
  10573a:	6a 00                	push   $0x0
  pushl $104
  10573c:	6a 68                	push   $0x68
  jmp alltraps
  10573e:	e9 bd f7 ff ff       	jmp    104f00 <alltraps>

00105743 <vector105>:
.globl vector105
vector105:
  pushl $0
  105743:	6a 00                	push   $0x0
  pushl $105
  105745:	6a 69                	push   $0x69
  jmp alltraps
  105747:	e9 b4 f7 ff ff       	jmp    104f00 <alltraps>

0010574c <vector106>:
.globl vector106
vector106:
  pushl $0
  10574c:	6a 00                	push   $0x0
  pushl $106
  10574e:	6a 6a                	push   $0x6a
  jmp alltraps
  105750:	e9 ab f7 ff ff       	jmp    104f00 <alltraps>

00105755 <vector107>:
.globl vector107
vector107:
  pushl $0
  105755:	6a 00                	push   $0x0
  pushl $107
  105757:	6a 6b                	push   $0x6b
  jmp alltraps
  105759:	e9 a2 f7 ff ff       	jmp    104f00 <alltraps>

0010575e <vector108>:
.globl vector108
vector108:
  pushl $0
  10575e:	6a 00                	push   $0x0
  pushl $108
  105760:	6a 6c                	push   $0x6c
  jmp alltraps
  105762:	e9 99 f7 ff ff       	jmp    104f00 <alltraps>

00105767 <vector109>:
.globl vector109
vector109:
  pushl $0
  105767:	6a 00                	push   $0x0
  pushl $109
  105769:	6a 6d                	push   $0x6d
  jmp alltraps
  10576b:	e9 90 f7 ff ff       	jmp    104f00 <alltraps>

00105770 <vector110>:
.globl vector110
vector110:
  pushl $0
  105770:	6a 00                	push   $0x0
  pushl $110
  105772:	6a 6e                	push   $0x6e
  jmp alltraps
  105774:	e9 87 f7 ff ff       	jmp    104f00 <alltraps>

00105779 <vector111>:
.globl vector111
vector111:
  pushl $0
  105779:	6a 00                	push   $0x0
  pushl $111
  10577b:	6a 6f                	push   $0x6f
  jmp alltraps
  10577d:	e9 7e f7 ff ff       	jmp    104f00 <alltraps>

00105782 <vector112>:
.globl vector112
vector112:
  pushl $0
  105782:	6a 00                	push   $0x0
  pushl $112
  105784:	6a 70                	push   $0x70
  jmp alltraps
  105786:	e9 75 f7 ff ff       	jmp    104f00 <alltraps>

0010578b <vector113>:
.globl vector113
vector113:
  pushl $0
  10578b:	6a 00                	push   $0x0
  pushl $113
  10578d:	6a 71                	push   $0x71
  jmp alltraps
  10578f:	e9 6c f7 ff ff       	jmp    104f00 <alltraps>

00105794 <vector114>:
.globl vector114
vector114:
  pushl $0
  105794:	6a 00                	push   $0x0
  pushl $114
  105796:	6a 72                	push   $0x72
  jmp alltraps
  105798:	e9 63 f7 ff ff       	jmp    104f00 <alltraps>

0010579d <vector115>:
.globl vector115
vector115:
  pushl $0
  10579d:	6a 00                	push   $0x0
  pushl $115
  10579f:	6a 73                	push   $0x73
  jmp alltraps
  1057a1:	e9 5a f7 ff ff       	jmp    104f00 <alltraps>

001057a6 <vector116>:
.globl vector116
vector116:
  pushl $0
  1057a6:	6a 00                	push   $0x0
  pushl $116
  1057a8:	6a 74                	push   $0x74
  jmp alltraps
  1057aa:	e9 51 f7 ff ff       	jmp    104f00 <alltraps>

001057af <vector117>:
.globl vector117
vector117:
  pushl $0
  1057af:	6a 00                	push   $0x0
  pushl $117
  1057b1:	6a 75                	push   $0x75
  jmp alltraps
  1057b3:	e9 48 f7 ff ff       	jmp    104f00 <alltraps>

001057b8 <vector118>:
.globl vector118
vector118:
  pushl $0
  1057b8:	6a 00                	push   $0x0
  pushl $118
  1057ba:	6a 76                	push   $0x76
  jmp alltraps
  1057bc:	e9 3f f7 ff ff       	jmp    104f00 <alltraps>

001057c1 <vector119>:
.globl vector119
vector119:
  pushl $0
  1057c1:	6a 00                	push   $0x0
  pushl $119
  1057c3:	6a 77                	push   $0x77
  jmp alltraps
  1057c5:	e9 36 f7 ff ff       	jmp    104f00 <alltraps>

001057ca <vector120>:
.globl vector120
vector120:
  pushl $0
  1057ca:	6a 00                	push   $0x0
  pushl $120
  1057cc:	6a 78                	push   $0x78
  jmp alltraps
  1057ce:	e9 2d f7 ff ff       	jmp    104f00 <alltraps>

001057d3 <vector121>:
.globl vector121
vector121:
  pushl $0
  1057d3:	6a 00                	push   $0x0
  pushl $121
  1057d5:	6a 79                	push   $0x79
  jmp alltraps
  1057d7:	e9 24 f7 ff ff       	jmp    104f00 <alltraps>

001057dc <vector122>:
.globl vector122
vector122:
  pushl $0
  1057dc:	6a 00                	push   $0x0
  pushl $122
  1057de:	6a 7a                	push   $0x7a
  jmp alltraps
  1057e0:	e9 1b f7 ff ff       	jmp    104f00 <alltraps>

001057e5 <vector123>:
.globl vector123
vector123:
  pushl $0
  1057e5:	6a 00                	push   $0x0
  pushl $123
  1057e7:	6a 7b                	push   $0x7b
  jmp alltraps
  1057e9:	e9 12 f7 ff ff       	jmp    104f00 <alltraps>

001057ee <vector124>:
.globl vector124
vector124:
  pushl $0
  1057ee:	6a 00                	push   $0x0
  pushl $124
  1057f0:	6a 7c                	push   $0x7c
  jmp alltraps
  1057f2:	e9 09 f7 ff ff       	jmp    104f00 <alltraps>

001057f7 <vector125>:
.globl vector125
vector125:
  pushl $0
  1057f7:	6a 00                	push   $0x0
  pushl $125
  1057f9:	6a 7d                	push   $0x7d
  jmp alltraps
  1057fb:	e9 00 f7 ff ff       	jmp    104f00 <alltraps>

00105800 <vector126>:
.globl vector126
vector126:
  pushl $0
  105800:	6a 00                	push   $0x0
  pushl $126
  105802:	6a 7e                	push   $0x7e
  jmp alltraps
  105804:	e9 f7 f6 ff ff       	jmp    104f00 <alltraps>

00105809 <vector127>:
.globl vector127
vector127:
  pushl $0
  105809:	6a 00                	push   $0x0
  pushl $127
  10580b:	6a 7f                	push   $0x7f
  jmp alltraps
  10580d:	e9 ee f6 ff ff       	jmp    104f00 <alltraps>

00105812 <vector128>:
.globl vector128
vector128:
  pushl $0
  105812:	6a 00                	push   $0x0
  pushl $128
  105814:	68 80 00 00 00       	push   $0x80
  jmp alltraps
  105819:	e9 e2 f6 ff ff       	jmp    104f00 <alltraps>

0010581e <vector129>:
.globl vector129
vector129:
  pushl $0
  10581e:	6a 00                	push   $0x0
  pushl $129
  105820:	68 81 00 00 00       	push   $0x81
  jmp alltraps
  105825:	e9 d6 f6 ff ff       	jmp    104f00 <alltraps>

0010582a <vector130>:
.globl vector130
vector130:
  pushl $0
  10582a:	6a 00                	push   $0x0
  pushl $130
  10582c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
  105831:	e9 ca f6 ff ff       	jmp    104f00 <alltraps>

00105836 <vector131>:
.globl vector131
vector131:
  pushl $0
  105836:	6a 00                	push   $0x0
  pushl $131
  105838:	68 83 00 00 00       	push   $0x83
  jmp alltraps
  10583d:	e9 be f6 ff ff       	jmp    104f00 <alltraps>

00105842 <vector132>:
.globl vector132
vector132:
  pushl $0
  105842:	6a 00                	push   $0x0
  pushl $132
  105844:	68 84 00 00 00       	push   $0x84
  jmp alltraps
  105849:	e9 b2 f6 ff ff       	jmp    104f00 <alltraps>

0010584e <vector133>:
.globl vector133
vector133:
  pushl $0
  10584e:	6a 00                	push   $0x0
  pushl $133
  105850:	68 85 00 00 00       	push   $0x85
  jmp alltraps
  105855:	e9 a6 f6 ff ff       	jmp    104f00 <alltraps>

0010585a <vector134>:
.globl vector134
vector134:
  pushl $0
  10585a:	6a 00                	push   $0x0
  pushl $134
  10585c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
  105861:	e9 9a f6 ff ff       	jmp    104f00 <alltraps>

00105866 <vector135>:
.globl vector135
vector135:
  pushl $0
  105866:	6a 00                	push   $0x0
  pushl $135
  105868:	68 87 00 00 00       	push   $0x87
  jmp alltraps
  10586d:	e9 8e f6 ff ff       	jmp    104f00 <alltraps>

00105872 <vector136>:
.globl vector136
vector136:
  pushl $0
  105872:	6a 00                	push   $0x0
  pushl $136
  105874:	68 88 00 00 00       	push   $0x88
  jmp alltraps
  105879:	e9 82 f6 ff ff       	jmp    104f00 <alltraps>

0010587e <vector137>:
.globl vector137
vector137:
  pushl $0
  10587e:	6a 00                	push   $0x0
  pushl $137
  105880:	68 89 00 00 00       	push   $0x89
  jmp alltraps
  105885:	e9 76 f6 ff ff       	jmp    104f00 <alltraps>

0010588a <vector138>:
.globl vector138
vector138:
  pushl $0
  10588a:	6a 00                	push   $0x0
  pushl $138
  10588c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
  105891:	e9 6a f6 ff ff       	jmp    104f00 <alltraps>

00105896 <vector139>:
.globl vector139
vector139:
  pushl $0
  105896:	6a 00                	push   $0x0
  pushl $139
  105898:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
  10589d:	e9 5e f6 ff ff       	jmp    104f00 <alltraps>

001058a2 <vector140>:
.globl vector140
vector140:
  pushl $0
  1058a2:	6a 00                	push   $0x0
  pushl $140
  1058a4:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
  1058a9:	e9 52 f6 ff ff       	jmp    104f00 <alltraps>

001058ae <vector141>:
.globl vector141
vector141:
  pushl $0
  1058ae:	6a 00                	push   $0x0
  pushl $141
  1058b0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
  1058b5:	e9 46 f6 ff ff       	jmp    104f00 <alltraps>

001058ba <vector142>:
.globl vector142
vector142:
  pushl $0
  1058ba:	6a 00                	push   $0x0
  pushl $142
  1058bc:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
  1058c1:	e9 3a f6 ff ff       	jmp    104f00 <alltraps>

001058c6 <vector143>:
.globl vector143
vector143:
  pushl $0
  1058c6:	6a 00                	push   $0x0
  pushl $143
  1058c8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
  1058cd:	e9 2e f6 ff ff       	jmp    104f00 <alltraps>

001058d2 <vector144>:
.globl vector144
vector144:
  pushl $0
  1058d2:	6a 00                	push   $0x0
  pushl $144
  1058d4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
  1058d9:	e9 22 f6 ff ff       	jmp    104f00 <alltraps>

001058de <vector145>:
.globl vector145
vector145:
  pushl $0
  1058de:	6a 00                	push   $0x0
  pushl $145
  1058e0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
  1058e5:	e9 16 f6 ff ff       	jmp    104f00 <alltraps>

001058ea <vector146>:
.globl vector146
vector146:
  pushl $0
  1058ea:	6a 00                	push   $0x0
  pushl $146
  1058ec:	68 92 00 00 00       	push   $0x92
  jmp alltraps
  1058f1:	e9 0a f6 ff ff       	jmp    104f00 <alltraps>

001058f6 <vector147>:
.globl vector147
vector147:
  pushl $0
  1058f6:	6a 00                	push   $0x0
  pushl $147
  1058f8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
  1058fd:	e9 fe f5 ff ff       	jmp    104f00 <alltraps>

00105902 <vector148>:
.globl vector148
vector148:
  pushl $0
  105902:	6a 00                	push   $0x0
  pushl $148
  105904:	68 94 00 00 00       	push   $0x94
  jmp alltraps
  105909:	e9 f2 f5 ff ff       	jmp    104f00 <alltraps>

0010590e <vector149>:
.globl vector149
vector149:
  pushl $0
  10590e:	6a 00                	push   $0x0
  pushl $149
  105910:	68 95 00 00 00       	push   $0x95
  jmp alltraps
  105915:	e9 e6 f5 ff ff       	jmp    104f00 <alltraps>

0010591a <vector150>:
.globl vector150
vector150:
  pushl $0
  10591a:	6a 00                	push   $0x0
  pushl $150
  10591c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
  105921:	e9 da f5 ff ff       	jmp    104f00 <alltraps>

00105926 <vector151>:
.globl vector151
vector151:
  pushl $0
  105926:	6a 00                	push   $0x0
  pushl $151
  105928:	68 97 00 00 00       	push   $0x97
  jmp alltraps
  10592d:	e9 ce f5 ff ff       	jmp    104f00 <alltraps>

00105932 <vector152>:
.globl vector152
vector152:
  pushl $0
  105932:	6a 00                	push   $0x0
  pushl $152
  105934:	68 98 00 00 00       	push   $0x98
  jmp alltraps
  105939:	e9 c2 f5 ff ff       	jmp    104f00 <alltraps>

0010593e <vector153>:
.globl vector153
vector153:
  pushl $0
  10593e:	6a 00                	push   $0x0
  pushl $153
  105940:	68 99 00 00 00       	push   $0x99
  jmp alltraps
  105945:	e9 b6 f5 ff ff       	jmp    104f00 <alltraps>

0010594a <vector154>:
.globl vector154
vector154:
  pushl $0
  10594a:	6a 00                	push   $0x0
  pushl $154
  10594c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
  105951:	e9 aa f5 ff ff       	jmp    104f00 <alltraps>

00105956 <vector155>:
.globl vector155
vector155:
  pushl $0
  105956:	6a 00                	push   $0x0
  pushl $155
  105958:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
  10595d:	e9 9e f5 ff ff       	jmp    104f00 <alltraps>

00105962 <vector156>:
.globl vector156
vector156:
  pushl $0
  105962:	6a 00                	push   $0x0
  pushl $156
  105964:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
  105969:	e9 92 f5 ff ff       	jmp    104f00 <alltraps>

0010596e <vector157>:
.globl vector157
vector157:
  pushl $0
  10596e:	6a 00                	push   $0x0
  pushl $157
  105970:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
  105975:	e9 86 f5 ff ff       	jmp    104f00 <alltraps>

0010597a <vector158>:
.globl vector158
vector158:
  pushl $0
  10597a:	6a 00                	push   $0x0
  pushl $158
  10597c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
  105981:	e9 7a f5 ff ff       	jmp    104f00 <alltraps>

00105986 <vector159>:
.globl vector159
vector159:
  pushl $0
  105986:	6a 00                	push   $0x0
  pushl $159
  105988:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
  10598d:	e9 6e f5 ff ff       	jmp    104f00 <alltraps>

00105992 <vector160>:
.globl vector160
vector160:
  pushl $0
  105992:	6a 00                	push   $0x0
  pushl $160
  105994:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
  105999:	e9 62 f5 ff ff       	jmp    104f00 <alltraps>

0010599e <vector161>:
.globl vector161
vector161:
  pushl $0
  10599e:	6a 00                	push   $0x0
  pushl $161
  1059a0:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
  1059a5:	e9 56 f5 ff ff       	jmp    104f00 <alltraps>

001059aa <vector162>:
.globl vector162
vector162:
  pushl $0
  1059aa:	6a 00                	push   $0x0
  pushl $162
  1059ac:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
  1059b1:	e9 4a f5 ff ff       	jmp    104f00 <alltraps>

001059b6 <vector163>:
.globl vector163
vector163:
  pushl $0
  1059b6:	6a 00                	push   $0x0
  pushl $163
  1059b8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
  1059bd:	e9 3e f5 ff ff       	jmp    104f00 <alltraps>

001059c2 <vector164>:
.globl vector164
vector164:
  pushl $0
  1059c2:	6a 00                	push   $0x0
  pushl $164
  1059c4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
  1059c9:	e9 32 f5 ff ff       	jmp    104f00 <alltraps>

001059ce <vector165>:
.globl vector165
vector165:
  pushl $0
  1059ce:	6a 00                	push   $0x0
  pushl $165
  1059d0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
  1059d5:	e9 26 f5 ff ff       	jmp    104f00 <alltraps>

001059da <vector166>:
.globl vector166
vector166:
  pushl $0
  1059da:	6a 00                	push   $0x0
  pushl $166
  1059dc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
  1059e1:	e9 1a f5 ff ff       	jmp    104f00 <alltraps>

001059e6 <vector167>:
.globl vector167
vector167:
  pushl $0
  1059e6:	6a 00                	push   $0x0
  pushl $167
  1059e8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
  1059ed:	e9 0e f5 ff ff       	jmp    104f00 <alltraps>

001059f2 <vector168>:
.globl vector168
vector168:
  pushl $0
  1059f2:	6a 00                	push   $0x0
  pushl $168
  1059f4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
  1059f9:	e9 02 f5 ff ff       	jmp    104f00 <alltraps>

001059fe <vector169>:
.globl vector169
vector169:
  pushl $0
  1059fe:	6a 00                	push   $0x0
  pushl $169
  105a00:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
  105a05:	e9 f6 f4 ff ff       	jmp    104f00 <alltraps>

00105a0a <vector170>:
.globl vector170
vector170:
  pushl $0
  105a0a:	6a 00                	push   $0x0
  pushl $170
  105a0c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
  105a11:	e9 ea f4 ff ff       	jmp    104f00 <alltraps>

00105a16 <vector171>:
.globl vector171
vector171:
  pushl $0
  105a16:	6a 00                	push   $0x0
  pushl $171
  105a18:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
  105a1d:	e9 de f4 ff ff       	jmp    104f00 <alltraps>

00105a22 <vector172>:
.globl vector172
vector172:
  pushl $0
  105a22:	6a 00                	push   $0x0
  pushl $172
  105a24:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
  105a29:	e9 d2 f4 ff ff       	jmp    104f00 <alltraps>

00105a2e <vector173>:
.globl vector173
vector173:
  pushl $0
  105a2e:	6a 00                	push   $0x0
  pushl $173
  105a30:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
  105a35:	e9 c6 f4 ff ff       	jmp    104f00 <alltraps>

00105a3a <vector174>:
.globl vector174
vector174:
  pushl $0
  105a3a:	6a 00                	push   $0x0
  pushl $174
  105a3c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
  105a41:	e9 ba f4 ff ff       	jmp    104f00 <alltraps>

00105a46 <vector175>:
.globl vector175
vector175:
  pushl $0
  105a46:	6a 00                	push   $0x0
  pushl $175
  105a48:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
  105a4d:	e9 ae f4 ff ff       	jmp    104f00 <alltraps>

00105a52 <vector176>:
.globl vector176
vector176:
  pushl $0
  105a52:	6a 00                	push   $0x0
  pushl $176
  105a54:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
  105a59:	e9 a2 f4 ff ff       	jmp    104f00 <alltraps>

00105a5e <vector177>:
.globl vector177
vector177:
  pushl $0
  105a5e:	6a 00                	push   $0x0
  pushl $177
  105a60:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
  105a65:	e9 96 f4 ff ff       	jmp    104f00 <alltraps>

00105a6a <vector178>:
.globl vector178
vector178:
  pushl $0
  105a6a:	6a 00                	push   $0x0
  pushl $178
  105a6c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
  105a71:	e9 8a f4 ff ff       	jmp    104f00 <alltraps>

00105a76 <vector179>:
.globl vector179
vector179:
  pushl $0
  105a76:	6a 00                	push   $0x0
  pushl $179
  105a78:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
  105a7d:	e9 7e f4 ff ff       	jmp    104f00 <alltraps>

00105a82 <vector180>:
.globl vector180
vector180:
  pushl $0
  105a82:	6a 00                	push   $0x0
  pushl $180
  105a84:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
  105a89:	e9 72 f4 ff ff       	jmp    104f00 <alltraps>

00105a8e <vector181>:
.globl vector181
vector181:
  pushl $0
  105a8e:	6a 00                	push   $0x0
  pushl $181
  105a90:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
  105a95:	e9 66 f4 ff ff       	jmp    104f00 <alltraps>

00105a9a <vector182>:
.globl vector182
vector182:
  pushl $0
  105a9a:	6a 00                	push   $0x0
  pushl $182
  105a9c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
  105aa1:	e9 5a f4 ff ff       	jmp    104f00 <alltraps>

00105aa6 <vector183>:
.globl vector183
vector183:
  pushl $0
  105aa6:	6a 00                	push   $0x0
  pushl $183
  105aa8:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
  105aad:	e9 4e f4 ff ff       	jmp    104f00 <alltraps>

00105ab2 <vector184>:
.globl vector184
vector184:
  pushl $0
  105ab2:	6a 00                	push   $0x0
  pushl $184
  105ab4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
  105ab9:	e9 42 f4 ff ff       	jmp    104f00 <alltraps>

00105abe <vector185>:
.globl vector185
vector185:
  pushl $0
  105abe:	6a 00                	push   $0x0
  pushl $185
  105ac0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
  105ac5:	e9 36 f4 ff ff       	jmp    104f00 <alltraps>

00105aca <vector186>:
.globl vector186
vector186:
  pushl $0
  105aca:	6a 00                	push   $0x0
  pushl $186
  105acc:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
  105ad1:	e9 2a f4 ff ff       	jmp    104f00 <alltraps>

00105ad6 <vector187>:
.globl vector187
vector187:
  pushl $0
  105ad6:	6a 00                	push   $0x0
  pushl $187
  105ad8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
  105add:	e9 1e f4 ff ff       	jmp    104f00 <alltraps>

00105ae2 <vector188>:
.globl vector188
vector188:
  pushl $0
  105ae2:	6a 00                	push   $0x0
  pushl $188
  105ae4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
  105ae9:	e9 12 f4 ff ff       	jmp    104f00 <alltraps>

00105aee <vector189>:
.globl vector189
vector189:
  pushl $0
  105aee:	6a 00                	push   $0x0
  pushl $189
  105af0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
  105af5:	e9 06 f4 ff ff       	jmp    104f00 <alltraps>

00105afa <vector190>:
.globl vector190
vector190:
  pushl $0
  105afa:	6a 00                	push   $0x0
  pushl $190
  105afc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
  105b01:	e9 fa f3 ff ff       	jmp    104f00 <alltraps>

00105b06 <vector191>:
.globl vector191
vector191:
  pushl $0
  105b06:	6a 00                	push   $0x0
  pushl $191
  105b08:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
  105b0d:	e9 ee f3 ff ff       	jmp    104f00 <alltraps>

00105b12 <vector192>:
.globl vector192
vector192:
  pushl $0
  105b12:	6a 00                	push   $0x0
  pushl $192
  105b14:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
  105b19:	e9 e2 f3 ff ff       	jmp    104f00 <alltraps>

00105b1e <vector193>:
.globl vector193
vector193:
  pushl $0
  105b1e:	6a 00                	push   $0x0
  pushl $193
  105b20:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
  105b25:	e9 d6 f3 ff ff       	jmp    104f00 <alltraps>

00105b2a <vector194>:
.globl vector194
vector194:
  pushl $0
  105b2a:	6a 00                	push   $0x0
  pushl $194
  105b2c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
  105b31:	e9 ca f3 ff ff       	jmp    104f00 <alltraps>

00105b36 <vector195>:
.globl vector195
vector195:
  pushl $0
  105b36:	6a 00                	push   $0x0
  pushl $195
  105b38:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
  105b3d:	e9 be f3 ff ff       	jmp    104f00 <alltraps>

00105b42 <vector196>:
.globl vector196
vector196:
  pushl $0
  105b42:	6a 00                	push   $0x0
  pushl $196
  105b44:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
  105b49:	e9 b2 f3 ff ff       	jmp    104f00 <alltraps>

00105b4e <vector197>:
.globl vector197
vector197:
  pushl $0
  105b4e:	6a 00                	push   $0x0
  pushl $197
  105b50:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
  105b55:	e9 a6 f3 ff ff       	jmp    104f00 <alltraps>

00105b5a <vector198>:
.globl vector198
vector198:
  pushl $0
  105b5a:	6a 00                	push   $0x0
  pushl $198
  105b5c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
  105b61:	e9 9a f3 ff ff       	jmp    104f00 <alltraps>

00105b66 <vector199>:
.globl vector199
vector199:
  pushl $0
  105b66:	6a 00                	push   $0x0
  pushl $199
  105b68:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
  105b6d:	e9 8e f3 ff ff       	jmp    104f00 <alltraps>

00105b72 <vector200>:
.globl vector200
vector200:
  pushl $0
  105b72:	6a 00                	push   $0x0
  pushl $200
  105b74:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
  105b79:	e9 82 f3 ff ff       	jmp    104f00 <alltraps>

00105b7e <vector201>:
.globl vector201
vector201:
  pushl $0
  105b7e:	6a 00                	push   $0x0
  pushl $201
  105b80:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
  105b85:	e9 76 f3 ff ff       	jmp    104f00 <alltraps>

00105b8a <vector202>:
.globl vector202
vector202:
  pushl $0
  105b8a:	6a 00                	push   $0x0
  pushl $202
  105b8c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
  105b91:	e9 6a f3 ff ff       	jmp    104f00 <alltraps>

00105b96 <vector203>:
.globl vector203
vector203:
  pushl $0
  105b96:	6a 00                	push   $0x0
  pushl $203
  105b98:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
  105b9d:	e9 5e f3 ff ff       	jmp    104f00 <alltraps>

00105ba2 <vector204>:
.globl vector204
vector204:
  pushl $0
  105ba2:	6a 00                	push   $0x0
  pushl $204
  105ba4:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
  105ba9:	e9 52 f3 ff ff       	jmp    104f00 <alltraps>

00105bae <vector205>:
.globl vector205
vector205:
  pushl $0
  105bae:	6a 00                	push   $0x0
  pushl $205
  105bb0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
  105bb5:	e9 46 f3 ff ff       	jmp    104f00 <alltraps>

00105bba <vector206>:
.globl vector206
vector206:
  pushl $0
  105bba:	6a 00                	push   $0x0
  pushl $206
  105bbc:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
  105bc1:	e9 3a f3 ff ff       	jmp    104f00 <alltraps>

00105bc6 <vector207>:
.globl vector207
vector207:
  pushl $0
  105bc6:	6a 00                	push   $0x0
  pushl $207
  105bc8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
  105bcd:	e9 2e f3 ff ff       	jmp    104f00 <alltraps>

00105bd2 <vector208>:
.globl vector208
vector208:
  pushl $0
  105bd2:	6a 00                	push   $0x0
  pushl $208
  105bd4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
  105bd9:	e9 22 f3 ff ff       	jmp    104f00 <alltraps>

00105bde <vector209>:
.globl vector209
vector209:
  pushl $0
  105bde:	6a 00                	push   $0x0
  pushl $209
  105be0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
  105be5:	e9 16 f3 ff ff       	jmp    104f00 <alltraps>

00105bea <vector210>:
.globl vector210
vector210:
  pushl $0
  105bea:	6a 00                	push   $0x0
  pushl $210
  105bec:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
  105bf1:	e9 0a f3 ff ff       	jmp    104f00 <alltraps>

00105bf6 <vector211>:
.globl vector211
vector211:
  pushl $0
  105bf6:	6a 00                	push   $0x0
  pushl $211
  105bf8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
  105bfd:	e9 fe f2 ff ff       	jmp    104f00 <alltraps>

00105c02 <vector212>:
.globl vector212
vector212:
  pushl $0
  105c02:	6a 00                	push   $0x0
  pushl $212
  105c04:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
  105c09:	e9 f2 f2 ff ff       	jmp    104f00 <alltraps>

00105c0e <vector213>:
.globl vector213
vector213:
  pushl $0
  105c0e:	6a 00                	push   $0x0
  pushl $213
  105c10:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
  105c15:	e9 e6 f2 ff ff       	jmp    104f00 <alltraps>

00105c1a <vector214>:
.globl vector214
vector214:
  pushl $0
  105c1a:	6a 00                	push   $0x0
  pushl $214
  105c1c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
  105c21:	e9 da f2 ff ff       	jmp    104f00 <alltraps>

00105c26 <vector215>:
.globl vector215
vector215:
  pushl $0
  105c26:	6a 00                	push   $0x0
  pushl $215
  105c28:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
  105c2d:	e9 ce f2 ff ff       	jmp    104f00 <alltraps>

00105c32 <vector216>:
.globl vector216
vector216:
  pushl $0
  105c32:	6a 00                	push   $0x0
  pushl $216
  105c34:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
  105c39:	e9 c2 f2 ff ff       	jmp    104f00 <alltraps>

00105c3e <vector217>:
.globl vector217
vector217:
  pushl $0
  105c3e:	6a 00                	push   $0x0
  pushl $217
  105c40:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
  105c45:	e9 b6 f2 ff ff       	jmp    104f00 <alltraps>

00105c4a <vector218>:
.globl vector218
vector218:
  pushl $0
  105c4a:	6a 00                	push   $0x0
  pushl $218
  105c4c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
  105c51:	e9 aa f2 ff ff       	jmp    104f00 <alltraps>

00105c56 <vector219>:
.globl vector219
vector219:
  pushl $0
  105c56:	6a 00                	push   $0x0
  pushl $219
  105c58:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
  105c5d:	e9 9e f2 ff ff       	jmp    104f00 <alltraps>

00105c62 <vector220>:
.globl vector220
vector220:
  pushl $0
  105c62:	6a 00                	push   $0x0
  pushl $220
  105c64:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
  105c69:	e9 92 f2 ff ff       	jmp    104f00 <alltraps>

00105c6e <vector221>:
.globl vector221
vector221:
  pushl $0
  105c6e:	6a 00                	push   $0x0
  pushl $221
  105c70:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
  105c75:	e9 86 f2 ff ff       	jmp    104f00 <alltraps>

00105c7a <vector222>:
.globl vector222
vector222:
  pushl $0
  105c7a:	6a 00                	push   $0x0
  pushl $222
  105c7c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
  105c81:	e9 7a f2 ff ff       	jmp    104f00 <alltraps>

00105c86 <vector223>:
.globl vector223
vector223:
  pushl $0
  105c86:	6a 00                	push   $0x0
  pushl $223
  105c88:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
  105c8d:	e9 6e f2 ff ff       	jmp    104f00 <alltraps>

00105c92 <vector224>:
.globl vector224
vector224:
  pushl $0
  105c92:	6a 00                	push   $0x0
  pushl $224
  105c94:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
  105c99:	e9 62 f2 ff ff       	jmp    104f00 <alltraps>

00105c9e <vector225>:
.globl vector225
vector225:
  pushl $0
  105c9e:	6a 00                	push   $0x0
  pushl $225
  105ca0:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
  105ca5:	e9 56 f2 ff ff       	jmp    104f00 <alltraps>

00105caa <vector226>:
.globl vector226
vector226:
  pushl $0
  105caa:	6a 00                	push   $0x0
  pushl $226
  105cac:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
  105cb1:	e9 4a f2 ff ff       	jmp    104f00 <alltraps>

00105cb6 <vector227>:
.globl vector227
vector227:
  pushl $0
  105cb6:	6a 00                	push   $0x0
  pushl $227
  105cb8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
  105cbd:	e9 3e f2 ff ff       	jmp    104f00 <alltraps>

00105cc2 <vector228>:
.globl vector228
vector228:
  pushl $0
  105cc2:	6a 00                	push   $0x0
  pushl $228
  105cc4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
  105cc9:	e9 32 f2 ff ff       	jmp    104f00 <alltraps>

00105cce <vector229>:
.globl vector229
vector229:
  pushl $0
  105cce:	6a 00                	push   $0x0
  pushl $229
  105cd0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
  105cd5:	e9 26 f2 ff ff       	jmp    104f00 <alltraps>

00105cda <vector230>:
.globl vector230
vector230:
  pushl $0
  105cda:	6a 00                	push   $0x0
  pushl $230
  105cdc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
  105ce1:	e9 1a f2 ff ff       	jmp    104f00 <alltraps>

00105ce6 <vector231>:
.globl vector231
vector231:
  pushl $0
  105ce6:	6a 00                	push   $0x0
  pushl $231
  105ce8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
  105ced:	e9 0e f2 ff ff       	jmp    104f00 <alltraps>

00105cf2 <vector232>:
.globl vector232
vector232:
  pushl $0
  105cf2:	6a 00                	push   $0x0
  pushl $232
  105cf4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
  105cf9:	e9 02 f2 ff ff       	jmp    104f00 <alltraps>

00105cfe <vector233>:
.globl vector233
vector233:
  pushl $0
  105cfe:	6a 00                	push   $0x0
  pushl $233
  105d00:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
  105d05:	e9 f6 f1 ff ff       	jmp    104f00 <alltraps>

00105d0a <vector234>:
.globl vector234
vector234:
  pushl $0
  105d0a:	6a 00                	push   $0x0
  pushl $234
  105d0c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
  105d11:	e9 ea f1 ff ff       	jmp    104f00 <alltraps>

00105d16 <vector235>:
.globl vector235
vector235:
  pushl $0
  105d16:	6a 00                	push   $0x0
  pushl $235
  105d18:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
  105d1d:	e9 de f1 ff ff       	jmp    104f00 <alltraps>

00105d22 <vector236>:
.globl vector236
vector236:
  pushl $0
  105d22:	6a 00                	push   $0x0
  pushl $236
  105d24:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
  105d29:	e9 d2 f1 ff ff       	jmp    104f00 <alltraps>

00105d2e <vector237>:
.globl vector237
vector237:
  pushl $0
  105d2e:	6a 00                	push   $0x0
  pushl $237
  105d30:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
  105d35:	e9 c6 f1 ff ff       	jmp    104f00 <alltraps>

00105d3a <vector238>:
.globl vector238
vector238:
  pushl $0
  105d3a:	6a 00                	push   $0x0
  pushl $238
  105d3c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
  105d41:	e9 ba f1 ff ff       	jmp    104f00 <alltraps>

00105d46 <vector239>:
.globl vector239
vector239:
  pushl $0
  105d46:	6a 00                	push   $0x0
  pushl $239
  105d48:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
  105d4d:	e9 ae f1 ff ff       	jmp    104f00 <alltraps>

00105d52 <vector240>:
.globl vector240
vector240:
  pushl $0
  105d52:	6a 00                	push   $0x0
  pushl $240
  105d54:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
  105d59:	e9 a2 f1 ff ff       	jmp    104f00 <alltraps>

00105d5e <vector241>:
.globl vector241
vector241:
  pushl $0
  105d5e:	6a 00                	push   $0x0
  pushl $241
  105d60:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
  105d65:	e9 96 f1 ff ff       	jmp    104f00 <alltraps>

00105d6a <vector242>:
.globl vector242
vector242:
  pushl $0
  105d6a:	6a 00                	push   $0x0
  pushl $242
  105d6c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
  105d71:	e9 8a f1 ff ff       	jmp    104f00 <alltraps>

00105d76 <vector243>:
.globl vector243
vector243:
  pushl $0
  105d76:	6a 00                	push   $0x0
  pushl $243
  105d78:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
  105d7d:	e9 7e f1 ff ff       	jmp    104f00 <alltraps>

00105d82 <vector244>:
.globl vector244
vector244:
  pushl $0
  105d82:	6a 00                	push   $0x0
  pushl $244
  105d84:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
  105d89:	e9 72 f1 ff ff       	jmp    104f00 <alltraps>

00105d8e <vector245>:
.globl vector245
vector245:
  pushl $0
  105d8e:	6a 00                	push   $0x0
  pushl $245
  105d90:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
  105d95:	e9 66 f1 ff ff       	jmp    104f00 <alltraps>

00105d9a <vector246>:
.globl vector246
vector246:
  pushl $0
  105d9a:	6a 00                	push   $0x0
  pushl $246
  105d9c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
  105da1:	e9 5a f1 ff ff       	jmp    104f00 <alltraps>

00105da6 <vector247>:
.globl vector247
vector247:
  pushl $0
  105da6:	6a 00                	push   $0x0
  pushl $247
  105da8:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
  105dad:	e9 4e f1 ff ff       	jmp    104f00 <alltraps>

00105db2 <vector248>:
.globl vector248
vector248:
  pushl $0
  105db2:	6a 00                	push   $0x0
  pushl $248
  105db4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
  105db9:	e9 42 f1 ff ff       	jmp    104f00 <alltraps>

00105dbe <vector249>:
.globl vector249
vector249:
  pushl $0
  105dbe:	6a 00                	push   $0x0
  pushl $249
  105dc0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
  105dc5:	e9 36 f1 ff ff       	jmp    104f00 <alltraps>

00105dca <vector250>:
.globl vector250
vector250:
  pushl $0
  105dca:	6a 00                	push   $0x0
  pushl $250
  105dcc:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
  105dd1:	e9 2a f1 ff ff       	jmp    104f00 <alltraps>

00105dd6 <vector251>:
.globl vector251
vector251:
  pushl $0
  105dd6:	6a 00                	push   $0x0
  pushl $251
  105dd8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
  105ddd:	e9 1e f1 ff ff       	jmp    104f00 <alltraps>

00105de2 <vector252>:
.globl vector252
vector252:
  pushl $0
  105de2:	6a 00                	push   $0x0
  pushl $252
  105de4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
  105de9:	e9 12 f1 ff ff       	jmp    104f00 <alltraps>

00105dee <vector253>:
.globl vector253
vector253:
  pushl $0
  105dee:	6a 00                	push   $0x0
  pushl $253
  105df0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
  105df5:	e9 06 f1 ff ff       	jmp    104f00 <alltraps>

00105dfa <vector254>:
.globl vector254
vector254:
  pushl $0
  105dfa:	6a 00                	push   $0x0
  pushl $254
  105dfc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
  105e01:	e9 fa f0 ff ff       	jmp    104f00 <alltraps>

00105e06 <vector255>:
.globl vector255
vector255:
  pushl $0
  105e06:	6a 00                	push   $0x0
  pushl $255
  105e08:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
  105e0d:	e9 ee f0 ff ff       	jmp    104f00 <alltraps>
  105e12:	90                   	nop
  105e13:	90                   	nop
  105e14:	90                   	nop
  105e15:	90                   	nop
  105e16:	90                   	nop
  105e17:	90                   	nop
  105e18:	90                   	nop
  105e19:	90                   	nop
  105e1a:	90                   	nop
  105e1b:	90                   	nop
  105e1c:	90                   	nop
  105e1d:	90                   	nop
  105e1e:	90                   	nop
  105e1f:	90                   	nop

00105e20 <vmenable>:
}

// Turn on paging.
void
vmenable(void)
{
  105e20:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105e21:	a1 d0 78 10 00       	mov    0x1078d0,%eax
  105e26:	89 e5                	mov    %esp,%ebp
  105e28:	0f 22 d8             	mov    %eax,%cr3

static inline uint
rcr0(void)
{
  uint val;
  asm volatile("movl %%cr0,%0" : "=r" (val));
  105e2b:	0f 20 c0             	mov    %cr0,%eax
}

static inline void
lcr0(uint val)
{
  asm volatile("movl %0,%%cr0" : : "r" (val));
  105e2e:	0d 00 00 00 80       	or     $0x80000000,%eax
  105e33:	0f 22 c0             	mov    %eax,%cr0

  switchkvm(); // load kpgdir into cr3
  cr0 = rcr0();
  cr0 |= CR0_PG;
  lcr0(cr0);
}
  105e36:	5d                   	pop    %ebp
  105e37:	c3                   	ret    
  105e38:	90                   	nop
  105e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00105e40 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  105e40:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105e41:	a1 d0 78 10 00       	mov    0x1078d0,%eax
  105e46:	89 e5                	mov    %esp,%ebp
  105e48:	0f 22 d8             	mov    %eax,%cr3
  lcr3(PADDR(kpgdir));   // switch to the kernel page table
}
  105e4b:	5d                   	pop    %ebp
  105e4c:	c3                   	ret    
  105e4d:	8d 76 00             	lea    0x0(%esi),%esi

00105e50 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105e50:	55                   	push   %ebp
  105e51:	89 e5                	mov    %esp,%ebp
  105e53:	83 ec 28             	sub    $0x28,%esp
  105e56:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  105e59:	89 d3                	mov    %edx,%ebx
  105e5b:	c1 eb 16             	shr    $0x16,%ebx
  105e5e:	8d 1c 98             	lea    (%eax,%ebx,4),%ebx
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105e61:	89 75 fc             	mov    %esi,-0x4(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
  105e64:	8b 33                	mov    (%ebx),%esi
  105e66:	f7 c6 01 00 00 00    	test   $0x1,%esi
  105e6c:	74 22                	je     105e90 <walkpgdir+0x40>
    pgtab = (pte_t*)PTE_ADDR(*pde);
  105e6e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105e74:	c1 ea 0a             	shr    $0xa,%edx
  105e77:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  105e7d:	8d 04 16             	lea    (%esi,%edx,1),%eax
}
  105e80:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  105e83:	8b 75 fc             	mov    -0x4(%ebp),%esi
  105e86:	89 ec                	mov    %ebp,%esp
  105e88:	5d                   	pop    %ebp
  105e89:	c3                   	ret    
  105e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105e90:	85 c9                	test   %ecx,%ecx
  105e92:	75 04                	jne    105e98 <walkpgdir+0x48>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105e94:	31 c0                	xor    %eax,%eax
  105e96:	eb e8                	jmp    105e80 <walkpgdir+0x30>

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105e98:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105e9b:	90                   	nop
  105e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105ea0:	e8 db c3 ff ff       	call   102280 <kalloc>
  105ea5:	85 c0                	test   %eax,%eax
  105ea7:	89 c6                	mov    %eax,%esi
  105ea9:	74 e9                	je     105e94 <walkpgdir+0x44>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
  105eab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105eb2:	00 
  105eb3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105eba:	00 
  105ebb:	89 04 24             	mov    %eax,(%esp)
  105ebe:	e8 0d df ff ff       	call   103dd0 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  105ec3:	89 f0                	mov    %esi,%eax
  105ec5:	83 c8 07             	or     $0x7,%eax
  105ec8:	89 03                	mov    %eax,(%ebx)
  105eca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ecd:	eb a5                	jmp    105e74 <walkpgdir+0x24>
  105ecf:	90                   	nop

00105ed0 <uva2ka>:
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105ed0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105ed1:	31 c9                	xor    %ecx,%ecx
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105ed3:	89 e5                	mov    %esp,%ebp
  105ed5:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
  105edb:	8b 45 08             	mov    0x8(%ebp),%eax
  105ede:	e8 6d ff ff ff       	call   105e50 <walkpgdir>
  if((*pte & PTE_P) == 0)
  105ee3:	8b 00                	mov    (%eax),%eax
  105ee5:	a8 01                	test   $0x1,%al
  105ee7:	75 07                	jne    105ef0 <uva2ka+0x20>
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)PTE_ADDR(*pte);
  105ee9:	31 c0                	xor    %eax,%eax
}
  105eeb:	c9                   	leave  
  105eec:	c3                   	ret    
  105eed:	8d 76 00             	lea    0x0(%esi),%esi
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
  105ef0:	a8 04                	test   $0x4,%al
  105ef2:	74 f5                	je     105ee9 <uva2ka+0x19>
    return 0;
  return (char*)PTE_ADDR(*pte);
  105ef4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
  105ef9:	c9                   	leave  
  105efa:	c3                   	ret    
  105efb:	90                   	nop
  105efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00105f00 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  105f00:	55                   	push   %ebp
  105f01:	89 e5                	mov    %esp,%ebp
  105f03:	57                   	push   %edi
  105f04:	56                   	push   %esi
  105f05:	53                   	push   %ebx
  105f06:	83 ec 2c             	sub    $0x2c,%esp
  105f09:	8b 5d 14             	mov    0x14(%ebp),%ebx
  105f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  105f0f:	85 db                	test   %ebx,%ebx
  105f11:	74 75                	je     105f88 <copyout+0x88>
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  105f13:	8b 45 10             	mov    0x10(%ebp),%eax
  105f16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105f19:	eb 39                	jmp    105f54 <copyout+0x54>
  105f1b:	90                   	nop
  105f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
  105f20:	89 f7                	mov    %esi,%edi
  105f22:	29 d7                	sub    %edx,%edi
  105f24:	81 c7 00 10 00 00    	add    $0x1000,%edi
  105f2a:	39 df                	cmp    %ebx,%edi
  105f2c:	0f 47 fb             	cmova  %ebx,%edi
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
  105f2f:	29 f2                	sub    %esi,%edx
  105f31:	89 7c 24 08          	mov    %edi,0x8(%esp)
  105f35:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  105f38:	8d 14 10             	lea    (%eax,%edx,1),%edx
  105f3b:	89 14 24             	mov    %edx,(%esp)
  105f3e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  105f42:	e8 09 df ff ff       	call   103e50 <memmove>
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  105f47:	29 fb                	sub    %edi,%ebx
  105f49:	74 3d                	je     105f88 <copyout+0x88>
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
  105f4b:	01 7d e4             	add    %edi,-0x1c(%ebp)
    va = va0 + PGSIZE;
  105f4e:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
  105f54:	89 d6                	mov    %edx,%esi
  105f56:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
  105f5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  105f60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  105f63:	89 0c 24             	mov    %ecx,(%esp)
  105f66:	89 55 e0             	mov    %edx,-0x20(%ebp)
  105f69:	e8 62 ff ff ff       	call   105ed0 <uva2ka>
    if(pa0 == 0)
  105f6e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105f71:	85 c0                	test   %eax,%eax
  105f73:	75 ab                	jne    105f20 <copyout+0x20>
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
  105f75:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  105f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
  105f7d:	5b                   	pop    %ebx
  105f7e:	5e                   	pop    %esi
  105f7f:	5f                   	pop    %edi
  105f80:	5d                   	pop    %ebp
  105f81:	c3                   	ret    
  105f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  105f88:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  105f8b:	31 c0                	xor    %eax,%eax
  }
  return 0;
}
  105f8d:	5b                   	pop    %ebx
  105f8e:	5e                   	pop    %esi
  105f8f:	5f                   	pop    %edi
  105f90:	5d                   	pop    %ebp
  105f91:	c3                   	ret    
  105f92:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  105f99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00105fa0 <mappages>:
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  105fa0:	55                   	push   %ebp
  105fa1:	89 e5                	mov    %esp,%ebp
  105fa3:	57                   	push   %edi
  105fa4:	56                   	push   %esi
  105fa5:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  105fa6:	89 d3                	mov    %edx,%ebx
  last = PGROUNDDOWN(la + size - 1);
  105fa8:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  105fac:	83 ec 2c             	sub    $0x2c,%esp
  105faf:	8b 75 08             	mov    0x8(%ebp),%esi
  105fb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  105fb5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = PGROUNDDOWN(la + size - 1);
  105fbb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  105fc1:	83 4d 0c 01          	orl    $0x1,0xc(%ebp)
  105fc5:	eb 1d                	jmp    105fe4 <mappages+0x44>
  105fc7:	90                   	nop
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
  105fc8:	f6 00 01             	testb  $0x1,(%eax)
  105fcb:	75 45                	jne    106012 <mappages+0x72>
      panic("remap");
    *pte = pa | perm | PTE_P;
  105fcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  105fd0:	09 f2                	or     %esi,%edx
    if(a == last)
  105fd2:	39 fb                	cmp    %edi,%ebx
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  105fd4:	89 10                	mov    %edx,(%eax)
    if(a == last)
  105fd6:	74 30                	je     106008 <mappages+0x68>
      break;
    a += PGSIZE;
  105fd8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
  105fde:	81 c6 00 10 00 00    	add    $0x1000,%esi
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
  105fe4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105fe7:	b9 01 00 00 00       	mov    $0x1,%ecx
  105fec:	89 da                	mov    %ebx,%edx
  105fee:	e8 5d fe ff ff       	call   105e50 <walkpgdir>
    if(pte == 0)
  105ff3:	85 c0                	test   %eax,%eax
  105ff5:	75 d1                	jne    105fc8 <mappages+0x28>
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  105ff7:	83 c4 2c             	add    $0x2c,%esp
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  105ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  105fff:	5b                   	pop    %ebx
  106000:	5e                   	pop    %esi
  106001:	5f                   	pop    %edi
  106002:	5d                   	pop    %ebp
  106003:	c3                   	ret    
  106004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  106008:	83 c4 2c             	add    $0x2c,%esp
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
  10600b:	31 c0                	xor    %eax,%eax
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  10600d:	5b                   	pop    %ebx
  10600e:	5e                   	pop    %esi
  10600f:	5f                   	pop    %edi
  106010:	5d                   	pop    %ebp
  106011:	c3                   	ret    
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
  106012:	c7 04 24 b0 6e 10 00 	movl   $0x106eb0,(%esp)
  106019:	e8 02 a9 ff ff       	call   100920 <panic>
  10601e:	66 90                	xchg   %ax,%ax

00106020 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
  106020:	55                   	push   %ebp
  106021:	89 e5                	mov    %esp,%ebp
  106023:	56                   	push   %esi
  106024:	53                   	push   %ebx
  106025:	83 ec 10             	sub    $0x10,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
  106028:	e8 53 c2 ff ff       	call   102280 <kalloc>
  10602d:	85 c0                	test   %eax,%eax
  10602f:	89 c6                	mov    %eax,%esi
  106031:	74 50                	je     106083 <setupkvm+0x63>
    return 0;
  memset(pgdir, 0, PGSIZE);
  106033:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10603a:	00 
  10603b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  106042:	00 
  106043:	89 04 24             	mov    %eax,(%esp)
  106046:	e8 85 dd ff ff       	call   103dd0 <memset>
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  10604b:	b8 70 77 10 00       	mov    $0x107770,%eax
  106050:	3d 40 77 10 00       	cmp    $0x107740,%eax
  106055:	76 2c                	jbe    106083 <setupkvm+0x63>
  {(void*)0xFE000000, 0,               PTE_W},  // device mappings
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
  106057:	bb 40 77 10 00       	mov    $0x107740,%ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  10605c:	8b 13                	mov    (%ebx),%edx
  10605e:	8b 4b 04             	mov    0x4(%ebx),%ecx
  106061:	8b 43 08             	mov    0x8(%ebx),%eax
  106064:	89 14 24             	mov    %edx,(%esp)
  106067:	29 d1                	sub    %edx,%ecx
  106069:	89 44 24 04          	mov    %eax,0x4(%esp)
  10606d:	89 f0                	mov    %esi,%eax
  10606f:	e8 2c ff ff ff       	call   105fa0 <mappages>
  106074:	85 c0                	test   %eax,%eax
  106076:	78 18                	js     106090 <setupkvm+0x70>

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  106078:	83 c3 0c             	add    $0xc,%ebx
  10607b:	81 fb 70 77 10 00    	cmp    $0x107770,%ebx
  106081:	75 d9                	jne    10605c <setupkvm+0x3c>
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
      return 0;

  return pgdir;
}
  106083:	83 c4 10             	add    $0x10,%esp
  106086:	89 f0                	mov    %esi,%eax
  106088:	5b                   	pop    %ebx
  106089:	5e                   	pop    %esi
  10608a:	5d                   	pop    %ebp
  10608b:	c3                   	ret    
  10608c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  106090:	31 f6                	xor    %esi,%esi
      return 0;

  return pgdir;
}
  106092:	83 c4 10             	add    $0x10,%esp
  106095:	89 f0                	mov    %esi,%eax
  106097:	5b                   	pop    %ebx
  106098:	5e                   	pop    %esi
  106099:	5d                   	pop    %ebp
  10609a:	c3                   	ret    
  10609b:	90                   	nop
  10609c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

001060a0 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
  1060a0:	55                   	push   %ebp
  1060a1:	89 e5                	mov    %esp,%ebp
  1060a3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
  1060a6:	e8 75 ff ff ff       	call   106020 <setupkvm>
  1060ab:	a3 d0 78 10 00       	mov    %eax,0x1078d0
}
  1060b0:	c9                   	leave  
  1060b1:	c3                   	ret    
  1060b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1060b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001060c0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  1060c0:	55                   	push   %ebp
  1060c1:	89 e5                	mov    %esp,%ebp
  1060c3:	83 ec 38             	sub    $0x38,%esp
  1060c6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1060c9:	8b 75 10             	mov    0x10(%ebp),%esi
  1060cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1060cf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  1060d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  1060d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  1060d8:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  1060de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  1060e1:	77 53                	ja     106136 <inituvm+0x76>
    panic("inituvm: more than a page");
  mem = kalloc();
  1060e3:	e8 98 c1 ff ff       	call   102280 <kalloc>
  memset(mem, 0, PGSIZE);
  1060e8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1060ef:	00 
  1060f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1060f7:	00 
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  1060f8:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
  1060fa:	89 04 24             	mov    %eax,(%esp)
  1060fd:	e8 ce dc ff ff       	call   103dd0 <memset>
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  106102:	b9 00 10 00 00       	mov    $0x1000,%ecx
  106107:	31 d2                	xor    %edx,%edx
  106109:	89 1c 24             	mov    %ebx,(%esp)
  10610c:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  106113:	00 
  106114:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106117:	e8 84 fe ff ff       	call   105fa0 <mappages>
  memmove(mem, init, sz);
  10611c:	89 75 10             	mov    %esi,0x10(%ebp)
}
  10611f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106122:	89 7d 0c             	mov    %edi,0xc(%ebp)
}
  106125:	8b 7d fc             	mov    -0x4(%ebp),%edi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106128:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  10612b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10612e:	89 ec                	mov    %ebp,%esp
  106130:	5d                   	pop    %ebp
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106131:	e9 1a dd ff ff       	jmp    103e50 <memmove>
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  106136:	c7 04 24 b6 6e 10 00 	movl   $0x106eb6,(%esp)
  10613d:	e8 de a7 ff ff       	call   100920 <panic>
  106142:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  106149:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106150 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106150:	55                   	push   %ebp
  106151:	89 e5                	mov    %esp,%ebp
  106153:	57                   	push   %edi
  106154:	56                   	push   %esi
  106155:	53                   	push   %ebx
  106156:	83 ec 2c             	sub    $0x2c,%esp
  106159:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  10615c:	39 75 10             	cmp    %esi,0x10(%ebp)
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  10615f:	8b 7d 08             	mov    0x8(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;
  106162:	89 f0                	mov    %esi,%eax
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  106164:	73 59                	jae    1061bf <deallocuvm+0x6f>
    return oldsz;

  a = PGROUNDUP(newsz);
  106166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  106169:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  10616f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
  106175:	39 de                	cmp    %ebx,%esi
  106177:	76 43                	jbe    1061bc <deallocuvm+0x6c>
  106179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
  106180:	31 c9                	xor    %ecx,%ecx
  106182:	89 da                	mov    %ebx,%edx
  106184:	89 f8                	mov    %edi,%eax
  106186:	e8 c5 fc ff ff       	call   105e50 <walkpgdir>
    if(pte && (*pte & PTE_P) != 0){
  10618b:	85 c0                	test   %eax,%eax
  10618d:	74 23                	je     1061b2 <deallocuvm+0x62>
  10618f:	8b 10                	mov    (%eax),%edx
  106191:	f6 c2 01             	test   $0x1,%dl
  106194:	74 1c                	je     1061b2 <deallocuvm+0x62>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
  106196:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  10619c:	74 29                	je     1061c7 <deallocuvm+0x77>
        panic("kfree");
      kfree((char*)pa);
  10619e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1061a1:	89 14 24             	mov    %edx,(%esp)
  1061a4:	e8 17 c1 ff ff       	call   1022c0 <kfree>
      *pte = 0;
  1061a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1061ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
  1061b2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  1061b8:	39 de                	cmp    %ebx,%esi
  1061ba:	77 c4                	ja     106180 <deallocuvm+0x30>
        panic("kfree");
      kfree((char*)pa);
      *pte = 0;
    }
  }
  return newsz;
  1061bc:	8b 45 10             	mov    0x10(%ebp),%eax
}
  1061bf:	83 c4 2c             	add    $0x2c,%esp
  1061c2:	5b                   	pop    %ebx
  1061c3:	5e                   	pop    %esi
  1061c4:	5f                   	pop    %edi
  1061c5:	5d                   	pop    %ebp
  1061c6:	c3                   	ret    
  for(; a  < oldsz; a += PGSIZE){
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(pte && (*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
  1061c7:	c7 04 24 5e 68 10 00 	movl   $0x10685e,(%esp)
  1061ce:	e8 4d a7 ff ff       	call   100920 <panic>
  1061d3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1061d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001061e0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
  1061e0:	55                   	push   %ebp
  1061e1:	89 e5                	mov    %esp,%ebp
  1061e3:	56                   	push   %esi
  1061e4:	53                   	push   %ebx
  1061e5:	83 ec 10             	sub    $0x10,%esp
  1061e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint i;

  if(pgdir == 0)
  1061eb:	85 db                	test   %ebx,%ebx
  1061ed:	74 59                	je     106248 <freevm+0x68>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  1061ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1061f6:	00 
  1061f7:	31 f6                	xor    %esi,%esi
  1061f9:	c7 44 24 04 00 00 0a 	movl   $0xa0000,0x4(%esp)
  106200:	00 
  106201:	89 1c 24             	mov    %ebx,(%esp)
  106204:	e8 47 ff ff ff       	call   106150 <deallocuvm>
  106209:	eb 10                	jmp    10621b <freevm+0x3b>
  10620b:	90                   	nop
  10620c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(i = 0; i < NPDENTRIES; i++){
  106210:	83 c6 01             	add    $0x1,%esi
  106213:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106219:	74 1f                	je     10623a <freevm+0x5a>
    if(pgdir[i] & PTE_P)
  10621b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  10621e:	a8 01                	test   $0x1,%al
  106220:	74 ee                	je     106210 <freevm+0x30>
      kfree((char*)PTE_ADDR(pgdir[i]));
  106222:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106227:	83 c6 01             	add    $0x1,%esi
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  10622a:	89 04 24             	mov    %eax,(%esp)
  10622d:	e8 8e c0 ff ff       	call   1022c0 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106232:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106238:	75 e1                	jne    10621b <freevm+0x3b>
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  10623a:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  10623d:	83 c4 10             	add    $0x10,%esp
  106240:	5b                   	pop    %ebx
  106241:	5e                   	pop    %esi
  106242:	5d                   	pop    %ebp
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  106243:	e9 78 c0 ff ff       	jmp    1022c0 <kfree>
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  106248:	c7 04 24 d0 6e 10 00 	movl   $0x106ed0,(%esp)
  10624f:	e8 cc a6 ff ff       	call   100920 <panic>
  106254:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10625a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00106260 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
  106260:	55                   	push   %ebp
  106261:	89 e5                	mov    %esp,%ebp
  106263:	57                   	push   %edi
  106264:	56                   	push   %esi
  106265:	53                   	push   %ebx
  106266:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
  106269:	e8 b2 fd ff ff       	call   106020 <setupkvm>
  10626e:	85 c0                	test   %eax,%eax
  106270:	89 c6                	mov    %eax,%esi
  106272:	0f 84 84 00 00 00    	je     1062fc <copyuvm+0x9c>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  106278:	8b 45 0c             	mov    0xc(%ebp),%eax
  10627b:	85 c0                	test   %eax,%eax
  10627d:	74 7d                	je     1062fc <copyuvm+0x9c>
  10627f:	31 db                	xor    %ebx,%ebx
  106281:	eb 47                	jmp    1062ca <copyuvm+0x6a>
  106283:	90                   	nop
  106284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)pa, PGSIZE);
  106288:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  10628e:	89 54 24 04          	mov    %edx,0x4(%esp)
  106292:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  106299:	00 
  10629a:	89 04 24             	mov    %eax,(%esp)
  10629d:	e8 ae db ff ff       	call   103e50 <memmove>
    if(mappages(d, (void*)i, PGSIZE, PADDR(mem), PTE_W|PTE_U) < 0)
  1062a2:	b9 00 10 00 00       	mov    $0x1000,%ecx
  1062a7:	89 da                	mov    %ebx,%edx
  1062a9:	89 f0                	mov    %esi,%eax
  1062ab:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  1062b2:	00 
  1062b3:	89 3c 24             	mov    %edi,(%esp)
  1062b6:	e8 e5 fc ff ff       	call   105fa0 <mappages>
  1062bb:	85 c0                	test   %eax,%eax
  1062bd:	78 33                	js     1062f2 <copyuvm+0x92>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  1062bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  1062c5:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
  1062c8:	76 32                	jbe    1062fc <copyuvm+0x9c>
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
  1062ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1062cd:	31 c9                	xor    %ecx,%ecx
  1062cf:	89 da                	mov    %ebx,%edx
  1062d1:	e8 7a fb ff ff       	call   105e50 <walkpgdir>
  1062d6:	85 c0                	test   %eax,%eax
  1062d8:	74 2c                	je     106306 <copyuvm+0xa6>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
  1062da:	8b 10                	mov    (%eax),%edx
  1062dc:	f6 c2 01             	test   $0x1,%dl
  1062df:	74 31                	je     106312 <copyuvm+0xb2>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
  1062e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1062e4:	e8 97 bf ff ff       	call   102280 <kalloc>
  1062e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1062ec:	85 c0                	test   %eax,%eax
  1062ee:	89 c7                	mov    %eax,%edi
  1062f0:	75 96                	jne    106288 <copyuvm+0x28>
      goto bad;
  }
  return d;

bad:
  freevm(d);
  1062f2:	89 34 24             	mov    %esi,(%esp)
  1062f5:	31 f6                	xor    %esi,%esi
  1062f7:	e8 e4 fe ff ff       	call   1061e0 <freevm>
  return 0;
}
  1062fc:	83 c4 2c             	add    $0x2c,%esp
  1062ff:	89 f0                	mov    %esi,%eax
  106301:	5b                   	pop    %ebx
  106302:	5e                   	pop    %esi
  106303:	5f                   	pop    %edi
  106304:	5d                   	pop    %ebp
  106305:	c3                   	ret    

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
      panic("copyuvm: pte should exist");
  106306:	c7 04 24 e1 6e 10 00 	movl   $0x106ee1,(%esp)
  10630d:	e8 0e a6 ff ff       	call   100920 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
  106312:	c7 04 24 fb 6e 10 00 	movl   $0x106efb,(%esp)
  106319:	e8 02 a6 ff ff       	call   100920 <panic>
  10631e:	66 90                	xchg   %ax,%ax

00106320 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106320:	55                   	push   %ebp
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106321:	31 c0                	xor    %eax,%eax

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106323:	89 e5                	mov    %esp,%ebp
  106325:	57                   	push   %edi
  106326:	56                   	push   %esi
  106327:	53                   	push   %ebx
  106328:	83 ec 2c             	sub    $0x2c,%esp
  10632b:	8b 75 10             	mov    0x10(%ebp),%esi
  10632e:	8b 7d 08             	mov    0x8(%ebp),%edi
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106331:	81 fe 00 00 0a 00    	cmp    $0xa0000,%esi
  106337:	0f 87 8e 00 00 00    	ja     1063cb <allocuvm+0xab>
    return 0;
  if(newsz < oldsz)
    return oldsz;
  10633d:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *mem;
  uint a;

  if(newsz > USERTOP)
    return 0;
  if(newsz < oldsz)
  106340:	39 c6                	cmp    %eax,%esi
  106342:	0f 82 83 00 00 00    	jb     1063cb <allocuvm+0xab>
    return oldsz;

  a = PGROUNDUP(oldsz);
  106348:	89 c3                	mov    %eax,%ebx
  10634a:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  106350:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
  106356:	39 de                	cmp    %ebx,%esi
  106358:	77 47                	ja     1063a1 <allocuvm+0x81>
  10635a:	eb 7c                	jmp    1063d8 <allocuvm+0xb8>
  10635c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
  106360:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  106367:	00 
  106368:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10636f:	00 
  106370:	89 04 24             	mov    %eax,(%esp)
  106373:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106376:	e8 55 da ff ff       	call   103dd0 <memset>
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  10637b:	b9 00 10 00 00       	mov    $0x1000,%ecx
  106380:	89 f8                	mov    %edi,%eax
  106382:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  106389:	00 
  10638a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10638d:	89 14 24             	mov    %edx,(%esp)
  106390:	89 da                	mov    %ebx,%edx
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  106392:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  106398:	e8 03 fc ff ff       	call   105fa0 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  10639d:	39 de                	cmp    %ebx,%esi
  10639f:	76 37                	jbe    1063d8 <allocuvm+0xb8>
    mem = kalloc();
  1063a1:	e8 da be ff ff       	call   102280 <kalloc>
    if(mem == 0){
  1063a6:	85 c0                	test   %eax,%eax
  1063a8:	75 b6                	jne    106360 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
  1063aa:	c7 04 24 15 6f 10 00 	movl   $0x106f15,(%esp)
  1063b1:	e8 7a a1 ff ff       	call   100530 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
  1063b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  1063bd:	89 3c 24             	mov    %edi,(%esp)
  1063c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1063c4:	e8 87 fd ff ff       	call   106150 <deallocuvm>
  1063c9:	31 c0                	xor    %eax,%eax
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
}
  1063cb:	83 c4 2c             	add    $0x2c,%esp
  1063ce:	5b                   	pop    %ebx
  1063cf:	5e                   	pop    %esi
  1063d0:	5f                   	pop    %edi
  1063d1:	5d                   	pop    %ebp
  1063d2:	c3                   	ret    
  1063d3:	90                   	nop
  1063d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1063d8:	83 c4 2c             	add    $0x2c,%esp
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
  1063db:	89 f0                	mov    %esi,%eax
}
  1063dd:	5b                   	pop    %ebx
  1063de:	5e                   	pop    %esi
  1063df:	5f                   	pop    %edi
  1063e0:	5d                   	pop    %ebp
  1063e1:	c3                   	ret    
  1063e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1063e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001063f0 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
  1063f0:	55                   	push   %ebp
  1063f1:	89 e5                	mov    %esp,%ebp
  1063f3:	57                   	push   %edi
  1063f4:	56                   	push   %esi
  1063f5:	53                   	push   %ebx
  1063f6:	83 ec 2c             	sub    $0x2c,%esp
  1063f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
  1063fc:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
  106402:	0f 85 96 00 00 00    	jne    10649e <loaduvm+0xae>
    panic("loaduvm: addr must be page aligned");
  106408:	8b 75 18             	mov    0x18(%ebp),%esi
  10640b:	31 db                	xor    %ebx,%ebx
  for(i = 0; i < sz; i += PGSIZE){
  10640d:	85 f6                	test   %esi,%esi
  10640f:	75 18                	jne    106429 <loaduvm+0x39>
  106411:	eb 75                	jmp    106488 <loaduvm+0x98>
  106413:	90                   	nop
  106414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  106418:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  10641e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  106424:	39 5d 18             	cmp    %ebx,0x18(%ebp)
  106427:	76 5f                	jbe    106488 <loaduvm+0x98>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
  106429:	8b 45 08             	mov    0x8(%ebp),%eax
  10642c:	31 c9                	xor    %ecx,%ecx
  10642e:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
  106431:	e8 1a fa ff ff       	call   105e50 <walkpgdir>
  106436:	85 c0                	test   %eax,%eax
  106438:	74 58                	je     106492 <loaduvm+0xa2>
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
  10643a:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
  106440:	ba 00 10 00 00       	mov    $0x1000,%edx
  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
  106445:	8b 00                	mov    (%eax),%eax
    if(sz - i < PGSIZE)
  106447:	0f 42 d6             	cmovb  %esi,%edx
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  10644a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10644e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  106451:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  106456:	89 44 24 04          	mov    %eax,0x4(%esp)
  10645a:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
  10645d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  106461:	8b 45 10             	mov    0x10(%ebp),%eax
  106464:	89 04 24             	mov    %eax,(%esp)
  106467:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10646a:	e8 21 af ff ff       	call   101390 <readi>
  10646f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106472:	39 d0                	cmp    %edx,%eax
  106474:	74 a2                	je     106418 <loaduvm+0x28>
      return -1;
  }
  return 0;
}
  106476:	83 c4 2c             	add    $0x2c,%esp
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  106479:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return -1;
  }
  return 0;
}
  10647e:	5b                   	pop    %ebx
  10647f:	5e                   	pop    %esi
  106480:	5f                   	pop    %edi
  106481:	5d                   	pop    %ebp
  106482:	c3                   	ret    
  106483:	90                   	nop
  106484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  106488:	83 c4 2c             	add    $0x2c,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
  10648b:	31 c0                	xor    %eax,%eax
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
      return -1;
  }
  return 0;
}
  10648d:	5b                   	pop    %ebx
  10648e:	5e                   	pop    %esi
  10648f:	5f                   	pop    %edi
  106490:	5d                   	pop    %ebp
  106491:	c3                   	ret    

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
  106492:	c7 04 24 2d 6f 10 00 	movl   $0x106f2d,(%esp)
  106499:	e8 82 a4 ff ff       	call   100920 <panic>
{
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  10649e:	c7 04 24 60 6f 10 00 	movl   $0x106f60,(%esp)
  1064a5:	e8 76 a4 ff ff       	call   100920 <panic>
  1064aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001064b0 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  1064b0:	55                   	push   %ebp
  1064b1:	89 e5                	mov    %esp,%ebp
  1064b3:	53                   	push   %ebx
  1064b4:	83 ec 14             	sub    $0x14,%esp
  1064b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
  1064ba:	e8 81 d7 ff ff       	call   103c40 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
  1064bf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1064c5:	8d 50 08             	lea    0x8(%eax),%edx
  1064c8:	89 d1                	mov    %edx,%ecx
  1064ca:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
  1064d1:	c1 e9 10             	shr    $0x10,%ecx
  1064d4:	c1 ea 18             	shr    $0x18,%edx
  1064d7:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  1064dd:	c6 80 a5 00 00 00 99 	movb   $0x99,0xa5(%eax)
  1064e4:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  1064ea:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
  1064f1:	67 00 
  1064f3:	c6 80 a6 00 00 00 40 	movb   $0x40,0xa6(%eax)
  cpu->gdt[SEG_TSS].s = 0;
  1064fa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  106500:	80 a0 a5 00 00 00 ef 	andb   $0xef,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
  106507:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10650d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  106513:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  106519:	8b 50 08             	mov    0x8(%eax),%edx
  10651c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  106522:	81 c2 00 10 00 00    	add    $0x1000,%edx
  106528:	89 50 0c             	mov    %edx,0xc(%eax)
}

static inline void
ltr(ushort sel)
{
  asm volatile("ltr %0" : : "r" (sel));
  10652b:	b8 30 00 00 00       	mov    $0x30,%eax
  106530:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
  106533:	8b 43 04             	mov    0x4(%ebx),%eax
  106536:	85 c0                	test   %eax,%eax
  106538:	74 0d                	je     106547 <switchuvm+0x97>
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  10653a:	0f 22 d8             	mov    %eax,%cr3
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
}
  10653d:	83 c4 14             	add    $0x14,%esp
  106540:	5b                   	pop    %ebx
  106541:	5d                   	pop    %ebp
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
  106542:	e9 39 d7 ff ff       	jmp    103c80 <popcli>
  cpu->gdt[SEG_TSS].s = 0;
  cpu->ts.ss0 = SEG_KDATA << 3;
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  106547:	c7 04 24 4b 6f 10 00 	movl   $0x106f4b,(%esp)
  10654e:	e8 cd a3 ff ff       	call   100920 <panic>
  106553:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  106559:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106560 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once at boot time on each CPU.
void
seginit(void)
{
  106560:	55                   	push   %ebp
  106561:	89 e5                	mov    %esp,%ebp
  106563:	83 ec 18             	sub    $0x18,%esp

  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  106566:	e8 f5 bf ff ff       	call   102560 <cpunum>
  10656b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  106571:	05 20 bb 10 00       	add    $0x10bb20,%eax
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  106576:	8d 90 b4 00 00 00    	lea    0xb4(%eax),%edx
  10657c:	66 89 90 8a 00 00 00 	mov    %dx,0x8a(%eax)
  106583:	89 d1                	mov    %edx,%ecx
  106585:	c1 ea 18             	shr    $0x18,%edx
  106588:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)
  10658e:	c1 e9 10             	shr    $0x10,%ecx

  lgdt(c->gdt, sizeof(c->gdt));
  106591:	8d 50 70             	lea    0x70(%eax),%edx
  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  106594:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
  10659a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
  1065a0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
  1065a4:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
  1065a8:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
  1065ac:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  1065b0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
  1065b7:	ff ff 
  1065b9:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
  1065c0:	00 00 
  1065c2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
  1065c9:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
  1065d0:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
  1065d7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  1065de:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
  1065e5:	ff ff 
  1065e7:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
  1065ee:	00 00 
  1065f0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
  1065f7:	c6 80 95 00 00 00 fa 	movb   $0xfa,0x95(%eax)
  1065fe:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
  106605:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
  10660c:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
  106613:	ff ff 
  106615:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
  10661c:	00 00 
  10661e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
  106625:	c6 80 9d 00 00 00 f2 	movb   $0xf2,0x9d(%eax)
  10662c:	c6 80 9e 00 00 00 cf 	movb   $0xcf,0x9e(%eax)
  106633:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  10663a:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
  106641:	00 00 
  106643:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
  106649:	c6 80 8d 00 00 00 92 	movb   $0x92,0x8d(%eax)
  106650:	c6 80 8e 00 00 00 c0 	movb   $0xc0,0x8e(%eax)
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  106657:	66 c7 45 f2 37 00    	movw   $0x37,-0xe(%ebp)
  pd[1] = (uint)p;
  10665d:	66 89 55 f4          	mov    %dx,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
  106661:	c1 ea 10             	shr    $0x10,%edx
  106664:	66 89 55 f6          	mov    %dx,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
  106668:	8d 55 f2             	lea    -0xe(%ebp),%edx
  10666b:	0f 01 12             	lgdtl  (%edx)
}

static inline void
loadgs(ushort v)
{
  asm volatile("movw %0, %%gs" : : "r" (v));
  10666e:	ba 18 00 00 00       	mov    $0x18,%edx
  106673:	8e ea                	mov    %edx,%gs

  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);
  
  // Initialize cpu-local storage.
  cpu = c;
  106675:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
  10667b:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  106682:	00 00 00 00 
}
  106686:	c9                   	leave  
  106687:	c3                   	ret    
