
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
  100017:	00 44 e9 10          	add    %al,0x10(%ecx,%ebp,8)
  10001b:	00 20                	add    %ah,(%eax)
  10001d:	00 10                	add    %dl,(%eax)
	...

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
  100045:	e8 66 28 00 00       	call   1028b0 <main>

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
  100086:	e8 a5 3a 00 00       	call   103b30 <acquire>

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
  1000c0:	e8 6b 30 00 00       	call   103130 <wakeup>

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
  1000d1:	e9 0a 3a 00 00       	jmp    103ae0 <release>
// Release the buffer b.
void
brelse(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("brelse");
  1000d6:	c7 04 24 c0 65 10 00 	movl   $0x1065c0,(%esp)
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
  100109:	e9 32 1e 00 00       	jmp    101f40 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("bwrite");
  10010e:	c7 04 24 c7 65 10 00 	movl   $0x1065c7,(%esp)
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
  100136:	e8 f5 39 00 00       	call   103b30 <acquire>

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
  100178:	e8 d3 30 00 00       	call   103250 <sleep>
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
  1001b5:	e8 26 39 00 00       	call   103ae0 <release>
bread(uint dev, uint sector)
{
  struct buf *b;

  b = bget(dev, sector);
  if(!(b->flags & B_VALID))
  1001ba:	f6 03 02             	testb  $0x2,(%ebx)
  1001bd:	75 08                	jne    1001c7 <bread+0xa7>
    iderw(b);
  1001bf:	89 1c 24             	mov    %ebx,(%esp)
  1001c2:	e8 79 1d 00 00       	call   101f40 <iderw>
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
  1001dd:	e8 fe 38 00 00       	call   103ae0 <release>
  1001e2:	eb d6                	jmp    1001ba <bread+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
  1001e4:	c7 04 24 ce 65 10 00 	movl   $0x1065ce,(%esp)
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
  1001f6:	c7 44 24 04 df 65 10 	movl   $0x1065df,0x4(%esp)
  1001fd:	00 
  1001fe:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  100205:	e8 96 37 00 00       	call   1039a0 <initlock>
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
  100266:	c7 44 24 04 e6 65 10 	movl   $0x1065e6,0x4(%esp)
  10026d:	00 
  10026e:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100275:	e8 26 37 00 00       	call   1039a0 <initlock>
  initlock(&input.lock, "input");
  10027a:	c7 44 24 04 ee 65 10 	movl   $0x1065ee,0x4(%esp)
  100281:	00 
  100282:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  100289:	e8 12 37 00 00       	call   1039a0 <initlock>

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
  1002b3:	e8 d8 28 00 00       	call   102b90 <picenable>
  ioapicenable(IRQ_KBD, 0);
  1002b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1002bf:	00 
  1002c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1002c7:	e8 74 1e 00 00       	call   102140 <ioapicenable>
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
  1002f5:	e8 c6 4e 00 00       	call   1051c0 <uartputc>
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
  100399:	e8 22 4e 00 00       	call   1051c0 <uartputc>
  10039e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1003a5:	e8 16 4e 00 00       	call   1051c0 <uartputc>
  1003aa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1003b1:	e8 0a 4e 00 00       	call   1051c0 <uartputc>
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
  1003dc:	e8 6f 38 00 00       	call   103c50 <memmove>
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  1003e1:	b8 80 07 00 00       	mov    $0x780,%eax
  1003e6:	29 d8                	sub    %ebx,%eax
  1003e8:	01 c0                	add    %eax,%eax
  1003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  1003ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1003f5:	00 
  1003f6:	89 34 24             	mov    %esi,(%esp)
  1003f9:	e8 d2 37 00 00       	call   103bd0 <memset>
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
  100461:	e8 ca 36 00 00       	call   103b30 <acquire>
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
  100487:	e8 54 36 00 00       	call   103ae0 <release>
  ilock(ip);
  10048c:	8b 45 08             	mov    0x8(%ebp),%eax
  10048f:	89 04 24             	mov    %eax,(%esp)
  100492:	e8 19 17 00 00       	call   101bb0 <ilock>

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
  1004d4:	0f b6 92 0e 66 10 00 	movzbl 0x10660e(%edx),%edx
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
  1005f3:	e8 e8 34 00 00       	call   103ae0 <release>
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
  100677:	e8 b4 34 00 00       	call   103b30 <acquire>
  10067c:	e9 c6 fe ff ff       	jmp    100547 <cprintf+0x17>
  100681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
  100688:	ba f4 65 10 00       	mov    $0x1065f4,%edx
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
  1006b4:	e8 77 34 00 00       	call   103b30 <acquire>
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
  1006e4:	e8 67 2b 00 00       	call   103250 <sleep>

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
  100737:	e8 a4 33 00 00       	call   103ae0 <release>
        ilock(ip);
  10073c:	89 3c 24             	mov    %edi,(%esp)
  10073f:	e8 6c 14 00 00       	call   101bb0 <ilock>
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
  10076a:	e8 71 33 00 00       	call   103ae0 <release>
  ilock(ip);
  10076f:	89 3c 24             	mov    %edi,(%esp)
  100772:	e8 39 14 00 00       	call   101bb0 <ilock>
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
  1007a8:	e8 83 33 00 00       	call   103b30 <acquire>
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
  100841:	e8 ea 28 00 00       	call   103130 <wakeup>
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
  100866:	e9 75 32 00 00       	jmp    103ae0 <release>
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
  1008e0:	e8 eb 26 00 00       	call   102fd0 <procdump>
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
  100941:	c7 04 24 fb 65 10 00 	movl   $0x1065fb,(%esp)
  100948:	89 44 24 04          	mov    %eax,0x4(%esp)
  10094c:	e8 df fb ff ff       	call   100530 <cprintf>
  cprintf(s);
  100951:	8b 45 08             	mov    0x8(%ebp),%eax
  100954:	89 04 24             	mov    %eax,(%esp)
  100957:	e8 d4 fb ff ff       	call   100530 <cprintf>
  cprintf("\n");
  10095c:	c7 04 24 16 6a 10 00 	movl   $0x106a16,(%esp)
  100963:	e8 c8 fb ff ff       	call   100530 <cprintf>
  getcallerpcs(&s, pcs);
  100968:	8d 45 08             	lea    0x8(%ebp),%eax
  10096b:	89 74 24 04          	mov    %esi,0x4(%esp)
  10096f:	89 04 24             	mov    %eax,(%esp)
  100972:	e8 49 30 00 00       	call   1039c0 <getcallerpcs>
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
  10097e:	c7 04 24 0a 66 10 00 	movl   $0x10660a,(%esp)
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
  1009b2:	e8 99 14 00 00       	call   101e50 <namei>
  1009b7:	85 c0                	test   %eax,%eax
  1009b9:	89 c7                	mov    %eax,%edi
  1009bb:	0f 84 25 01 00 00    	je     100ae6 <exec+0x146>
    return -1;
  ilock(ip);
  1009c1:	89 04 24             	mov    %eax,(%esp)
  1009c4:	e8 e7 11 00 00       	call   101bb0 <ilock>
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
  100a00:	e8 3b 55 00 00       	call   105f40 <setupkvm>
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
  100a8c:	e8 af 57 00 00       	call   106240 <allocuvm>
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
  100abd:	e8 4e 58 00 00       	call   106310 <loaduvm>
  100ac2:	85 c0                	test   %eax,%eax
  100ac4:	0f 89 66 ff ff ff    	jns    100a30 <exec+0x90>
  100aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  100ad0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100ad6:	89 04 24             	mov    %eax,(%esp)
  100ad9:	e8 22 56 00 00       	call   106100 <freevm>
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
  100b13:	e8 a8 0f 00 00       	call   101ac0 <iunlockput>
  ip = 0;

  // Allocate a one-page stack at the next page boundary
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
  100b18:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
  100b1e:	89 74 24 08          	mov    %esi,0x8(%esp)
  100b22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100b26:	89 0c 24             	mov    %ecx,(%esp)
  100b29:	e8 12 57 00 00       	call   106240 <allocuvm>
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
  100b7d:	e8 2e 32 00 00       	call   103db0 <strlen>
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
  100b8f:	e8 1c 32 00 00       	call   103db0 <strlen>
  100b94:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
  100b9a:	83 c0 01             	add    $0x1,%eax
  100b9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100ba1:	8b 07                	mov    (%edi),%eax
  100ba3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100ba7:	89 0c 24             	mov    %ecx,(%esp)
  100baa:	89 44 24 08          	mov    %eax,0x8(%esp)
  100bae:	e8 6d 52 00 00       	call   105e20 <copyout>
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
  100bc3:	e8 f8 0e 00 00       	call   101ac0 <iunlockput>
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
  100c1f:	e8 fc 51 00 00       	call   105e20 <copyout>
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
  100c6b:	e8 00 31 00 00       	call   103d70 <safestrcpy>

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
  100cb4:	e8 17 57 00 00       	call   1063d0 <switchuvm>
  freevm(oldpgdir);
  100cb9:	89 34 24             	mov    %esi,(%esp)
  100cbc:	e8 3f 54 00 00       	call   106100 <freevm>
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
  100d30:	e8 7b 0e 00 00       	call   101bb0 <ilock>
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
  100d92:	e9 c9 1f 00 00       	jmp    102d60 <pipewrite>
    if((r = writei(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
  100d97:	c7 04 24 1f 66 10 00 	movl   $0x10661f,(%esp)
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
  100de0:	e8 cb 0d 00 00       	call   101bb0 <ilock>
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
  100e42:	e9 19 1e 00 00       	jmp    102c60 <piperead>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
  100e47:	c7 04 24 29 66 10 00 	movl   $0x106629,(%esp)
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
  100e86:	e8 25 0d 00 00       	call   101bb0 <ilock>
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
  100ec1:	e8 6a 2c 00 00       	call   103b30 <acquire>
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
  100eda:	e8 01 2c 00 00       	call   103ae0 <release>
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
  100ee7:	c7 04 24 32 66 10 00 	movl   $0x106632,(%esp)
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
  100f13:	e8 18 2c 00 00       	call   103b30 <acquire>
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
  100f48:	e8 93 2b 00 00       	call   103ae0 <release>
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
  100f61:	e8 7a 2b 00 00       	call   103ae0 <release>
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
  100f99:	e8 92 2b 00 00       	call   103b30 <acquire>
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
  100fc6:	e9 15 2b 00 00       	jmp    103ae0 <release>
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
  100ff6:	e8 e5 2a 00 00       	call   103ae0 <release>
  
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
  10103e:	e8 0d 1e 00 00       	call   102e50 <pipeclose>
  101043:	eb c0                	jmp    101005 <fileclose+0x85>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  101045:	c7 04 24 3a 66 10 00 	movl   $0x10663a,(%esp)
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
  101066:	c7 44 24 04 44 66 10 	movl   $0x106644,0x4(%esp)
  10106d:	00 
  10106e:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  101075:	e8 26 29 00 00       	call   1039a0 <initlock>
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
  1010c1:	e8 6a 2a 00 00       	call   103b30 <acquire>
  ip->ref++;
  1010c6:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
  1010ca:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1010d1:	e8 0a 2a 00 00       	call   103ae0 <release>
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
  1010f6:	e8 35 2a 00 00       	call   103b30 <acquire>
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
  101136:	e8 a5 29 00 00       	call   103ae0 <release>
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
  101176:	e8 65 29 00 00       	call   103ae0 <release>

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
  101185:	c7 04 24 4b 66 10 00 	movl   $0x10664b,(%esp)
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
  1011d2:	e8 79 2a 00 00       	call   103c50 <memmove>
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
  1012ab:	c7 04 24 5b 66 10 00 	movl   $0x10665b,(%esp)
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
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
  1012c6:	83 fa 0b             	cmp    $0xb,%edx

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
  1012c9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1012cc:	89 c3                	mov    %eax,%ebx
  1012ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1012d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
  1012d4:	77 1a                	ja     1012f0 <bmap+0x30>
    if((addr = ip->addrs[bn]) == 0)
  1012d6:	8d 7a 04             	lea    0x4(%edx),%edi
  1012d9:	8b 44 b8 0c          	mov    0xc(%eax,%edi,4),%eax
  1012dd:	85 c0                	test   %eax,%eax
  1012df:	74 5f                	je     101340 <bmap+0x80>
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
  1012e1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1012e4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1012e7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1012ea:	89 ec                	mov    %ebp,%esp
  1012ec:	5d                   	pop    %ebp
  1012ed:	c3                   	ret    
  1012ee:	66 90                	xchg   %ax,%ax
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
  1012f0:	8d 7a f4             	lea    -0xc(%edx),%edi

  if(bn < NINDIRECT){
  1012f3:	83 ff 7f             	cmp    $0x7f,%edi
  1012f6:	77 64                	ja     10135c <bmap+0x9c>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
  1012f8:	8b 40 4c             	mov    0x4c(%eax),%eax
  1012fb:	85 c0                	test   %eax,%eax
  1012fd:	74 51                	je     101350 <bmap+0x90>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  1012ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  101303:	8b 03                	mov    (%ebx),%eax
  101305:	89 04 24             	mov    %eax,(%esp)
  101308:	e8 13 ee ff ff       	call   100120 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  10130d:	8d 7c b8 18          	lea    0x18(%eax,%edi,4),%edi

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  101311:	89 c6                	mov    %eax,%esi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  101313:	8b 07                	mov    (%edi),%eax
  101315:	85 c0                	test   %eax,%eax
  101317:	75 17                	jne    101330 <bmap+0x70>
      a[bn] = addr = balloc(ip->dev);
  101319:	8b 03                	mov    (%ebx),%eax
  10131b:	e8 d0 fe ff ff       	call   1011f0 <balloc>
  101320:	89 07                	mov    %eax,(%edi)
      bwrite(bp);
  101322:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101325:	89 34 24             	mov    %esi,(%esp)
  101328:	e8 c3 ed ff ff       	call   1000f0 <bwrite>
  10132d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    }
    brelse(bp);
  101330:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101333:	89 34 24             	mov    %esi,(%esp)
  101336:	e8 35 ed ff ff       	call   100070 <brelse>
    return addr;
  10133b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10133e:	eb a1                	jmp    1012e1 <bmap+0x21>
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
  101340:	8b 03                	mov    (%ebx),%eax
  101342:	e8 a9 fe ff ff       	call   1011f0 <balloc>
  101347:	89 44 bb 0c          	mov    %eax,0xc(%ebx,%edi,4)
  10134b:	eb 94                	jmp    1012e1 <bmap+0x21>
  10134d:	8d 76 00             	lea    0x0(%esi),%esi
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
  101350:	8b 03                	mov    (%ebx),%eax
  101352:	e8 99 fe ff ff       	call   1011f0 <balloc>
  101357:	89 43 4c             	mov    %eax,0x4c(%ebx)
  10135a:	eb a3                	jmp    1012ff <bmap+0x3f>
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
  10135c:	c7 04 24 71 66 10 00 	movl   $0x106671,(%esp)
  101363:	e8 b8 f5 ff ff       	call   100920 <panic>
  101368:	90                   	nop
  101369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

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
  101445:	e8 06 28 00 00       	call   103c50 <memmove>
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
  1014db:	e8 70 27 00 00       	call   103c50 <memmove>
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
  1015e5:	e8 66 26 00 00       	call   103c50 <memmove>
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
  10165b:	e8 60 26 00 00       	call   103cc0 <strncmp>
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
  101763:	c7 04 24 84 66 10 00 	movl   $0x106684,(%esp)
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
  101792:	e8 99 23 00 00       	call   103b30 <acquire>
  ip->flags &= ~I_BUSY;
  101797:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
  10179b:	89 1c 24             	mov    %ebx,(%esp)
  10179e:	e8 8d 19 00 00       	call   103130 <wakeup>
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
  1017af:	e9 2c 23 00 00       	jmp    103ae0 <release>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
    panic("iunlock");
  1017b4:	c7 04 24 96 66 10 00 	movl   $0x106696,(%esp)
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
  1017f1:	e8 da 23 00 00       	call   103bd0 <memset>
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
  101872:	c7 04 24 9e 66 10 00 	movl   $0x10669e,(%esp)
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
  101893:	e8 98 22 00 00       	call   103b30 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
  101898:	8b 46 08             	mov    0x8(%esi),%eax
  10189b:	83 f8 01             	cmp    $0x1,%eax
  10189e:	0f 85 a1 00 00 00    	jne    101945 <iput+0xc5>
  1018a4:	8b 56 0c             	mov    0xc(%esi),%edx
  1018a7:	f6 c2 02             	test   $0x2,%dl
  1018aa:	0f 84 95 00 00 00    	je     101945 <iput+0xc5>
  1018b0:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  1018b5:	0f 85 8a 00 00 00    	jne    101945 <iput+0xc5>
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
  1018bb:	f6 c2 01             	test   $0x1,%dl
  1018be:	66 90                	xchg   %ax,%ax
  1018c0:	0f 85 f8 00 00 00    	jne    1019be <iput+0x13e>
      panic("iput busy");
    ip->flags |= I_BUSY;
  1018c6:	83 ca 01             	or     $0x1,%edx
    release(&icache.lock);
  1018c9:	89 f3                	mov    %esi,%ebx
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
  1018cb:	89 56 0c             	mov    %edx,0xc(%esi)
  release(&icache.lock);
}

// Caller holds reference to unlocked ip.  Drop reference.
void
iput(struct inode *ip)
  1018ce:	8d 7e 30             	lea    0x30(%esi),%edi
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
  1018d1:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1018d8:	e8 03 22 00 00       	call   103ae0 <release>
  1018dd:	eb 08                	jmp    1018e7 <iput+0x67>
  1018df:	90                   	nop
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
  1018e0:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
  1018e3:	39 fb                	cmp    %edi,%ebx
  1018e5:	74 1c                	je     101903 <iput+0x83>
    if(ip->addrs[i]){
  1018e7:	8b 53 1c             	mov    0x1c(%ebx),%edx
  1018ea:	85 d2                	test   %edx,%edx
  1018ec:	74 f2                	je     1018e0 <iput+0x60>
      bfree(ip->dev, ip->addrs[i]);
  1018ee:	8b 06                	mov    (%esi),%eax
  1018f0:	e8 cb fe ff ff       	call   1017c0 <bfree>
      ip->addrs[i] = 0;
  1018f5:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
  1018fc:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
  1018ff:	39 fb                	cmp    %edi,%ebx
  101901:	75 e4                	jne    1018e7 <iput+0x67>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
  101903:	8b 46 4c             	mov    0x4c(%esi),%eax
  101906:	85 c0                	test   %eax,%eax
  101908:	75 56                	jne    101960 <iput+0xe0>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  10190a:	c7 46 18 00 00 00 00 	movl   $0x0,0x18(%esi)
  iupdate(ip);
  101911:	89 34 24             	mov    %esi,(%esp)
  101914:	e8 57 fb ff ff       	call   101470 <iupdate>
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
    itrunc(ip);
    ip->type = 0;
  101919:	66 c7 46 10 00 00    	movw   $0x0,0x10(%esi)
    iupdate(ip);
  10191f:	89 34 24             	mov    %esi,(%esp)
  101922:	e8 49 fb ff ff       	call   101470 <iupdate>
    acquire(&icache.lock);
  101927:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  10192e:	e8 fd 21 00 00       	call   103b30 <acquire>
    ip->flags = 0;
  101933:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
  10193a:	89 34 24             	mov    %esi,(%esp)
  10193d:	e8 ee 17 00 00       	call   103130 <wakeup>
  101942:	8b 46 08             	mov    0x8(%esi),%eax
  }
  ip->ref--;
  101945:	83 e8 01             	sub    $0x1,%eax
  101948:	89 46 08             	mov    %eax,0x8(%esi)
  release(&icache.lock);
  10194b:	c7 45 08 e0 aa 10 00 	movl   $0x10aae0,0x8(%ebp)
}
  101952:	83 c4 2c             	add    $0x2c,%esp
  101955:	5b                   	pop    %ebx
  101956:	5e                   	pop    %esi
  101957:	5f                   	pop    %edi
  101958:	5d                   	pop    %ebp
    acquire(&icache.lock);
    ip->flags = 0;
    wakeup(ip);
  }
  ip->ref--;
  release(&icache.lock);
  101959:	e9 82 21 00 00       	jmp    103ae0 <release>
  10195e:	66 90                	xchg   %ax,%ax
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  101960:	89 44 24 04          	mov    %eax,0x4(%esp)
  101964:	8b 06                	mov    (%esi),%eax
    a = (uint*)bp->data;
  101966:	31 db                	xor    %ebx,%ebx
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  101968:	89 04 24             	mov    %eax,(%esp)
  10196b:	e8 b0 e7 ff ff       	call   100120 <bread>
    a = (uint*)bp->data;
  101970:	89 c7                	mov    %eax,%edi
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  101972:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
  101975:	83 c7 18             	add    $0x18,%edi
  101978:	31 c0                	xor    %eax,%eax
  10197a:	eb 11                	jmp    10198d <iput+0x10d>
  10197c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(j = 0; j < NINDIRECT; j++){
  101980:	83 c3 01             	add    $0x1,%ebx
  101983:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  101989:	89 d8                	mov    %ebx,%eax
  10198b:	74 10                	je     10199d <iput+0x11d>
      if(a[j])
  10198d:	8b 14 87             	mov    (%edi,%eax,4),%edx
  101990:	85 d2                	test   %edx,%edx
  101992:	74 ec                	je     101980 <iput+0x100>
        bfree(ip->dev, a[j]);
  101994:	8b 06                	mov    (%esi),%eax
  101996:	e8 25 fe ff ff       	call   1017c0 <bfree>
  10199b:	eb e3                	jmp    101980 <iput+0x100>
    }
    brelse(bp);
  10199d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1019a0:	89 04 24             	mov    %eax,(%esp)
  1019a3:	e8 c8 e6 ff ff       	call   100070 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
  1019a8:	8b 56 4c             	mov    0x4c(%esi),%edx
  1019ab:	8b 06                	mov    (%esi),%eax
  1019ad:	e8 0e fe ff ff       	call   1017c0 <bfree>
    ip->addrs[NDIRECT] = 0;
  1019b2:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  1019b9:	e9 4c ff ff ff       	jmp    10190a <iput+0x8a>
{
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
  1019be:	c7 04 24 b1 66 10 00 	movl   $0x1066b1,(%esp)
  1019c5:	e8 56 ef ff ff       	call   100920 <panic>
  1019ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001019d0 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
  1019d0:	55                   	push   %ebp
  1019d1:	89 e5                	mov    %esp,%ebp
  1019d3:	57                   	push   %edi
  1019d4:	56                   	push   %esi
  1019d5:	53                   	push   %ebx
  1019d6:	83 ec 2c             	sub    $0x2c,%esp
  1019d9:	8b 75 08             	mov    0x8(%ebp),%esi
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
  1019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1019df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1019e6:	00 
  1019e7:	89 34 24             	mov    %esi,(%esp)
  1019ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019ee:	e8 7d fc ff ff       	call   101670 <dirlookup>
  1019f3:	85 c0                	test   %eax,%eax
  1019f5:	0f 85 89 00 00 00    	jne    101a84 <dirlink+0xb4>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  1019fb:	8b 56 18             	mov    0x18(%esi),%edx
  1019fe:	85 d2                	test   %edx,%edx
  101a00:	0f 84 8d 00 00 00    	je     101a93 <dirlink+0xc3>
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
    return -1;
  101a06:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101a09:	31 db                	xor    %ebx,%ebx
  101a0b:	eb 0b                	jmp    101a18 <dirlink+0x48>
  101a0d:	8d 76 00             	lea    0x0(%esi),%esi
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101a10:	83 c3 10             	add    $0x10,%ebx
  101a13:	39 5e 18             	cmp    %ebx,0x18(%esi)
  101a16:	76 24                	jbe    101a3c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a18:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101a1f:	00 
  101a20:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101a24:	89 7c 24 04          	mov    %edi,0x4(%esp)
  101a28:	89 34 24             	mov    %esi,(%esp)
  101a2b:	e8 40 f9 ff ff       	call   101370 <readi>
  101a30:	83 f8 10             	cmp    $0x10,%eax
  101a33:	75 65                	jne    101a9a <dirlink+0xca>
      panic("dirlink read");
    if(de.inum == 0)
  101a35:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
  101a3a:	75 d4                	jne    101a10 <dirlink+0x40>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  101a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  101a3f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101a46:	00 
  101a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a4b:	8d 45 da             	lea    -0x26(%ebp),%eax
  101a4e:	89 04 24             	mov    %eax,(%esp)
  101a51:	e8 ca 22 00 00       	call   103d20 <strncpy>
  de.inum = inum;
  101a56:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a59:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101a60:	00 
  101a61:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101a65:	89 7c 24 04          	mov    %edi,0x4(%esp)
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  101a69:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a6d:	89 34 24             	mov    %esi,(%esp)
  101a70:	e8 8b fa ff ff       	call   101500 <writei>
  101a75:	83 f8 10             	cmp    $0x10,%eax
  101a78:	75 2c                	jne    101aa6 <dirlink+0xd6>
    panic("dirlink");
  101a7a:	31 c0                	xor    %eax,%eax
  
  return 0;
}
  101a7c:	83 c4 2c             	add    $0x2c,%esp
  101a7f:	5b                   	pop    %ebx
  101a80:	5e                   	pop    %esi
  101a81:	5f                   	pop    %edi
  101a82:	5d                   	pop    %ebp
  101a83:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
  101a84:	89 04 24             	mov    %eax,(%esp)
  101a87:	e8 f4 fd ff ff       	call   101880 <iput>
  101a8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  101a91:	eb e9                	jmp    101a7c <dirlink+0xac>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101a93:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101a96:	31 db                	xor    %ebx,%ebx
  101a98:	eb a2                	jmp    101a3c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
  101a9a:	c7 04 24 bb 66 10 00 	movl   $0x1066bb,(%esp)
  101aa1:	e8 7a ee ff ff       	call   100920 <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
  101aa6:	c7 04 24 62 6c 10 00 	movl   $0x106c62,(%esp)
  101aad:	e8 6e ee ff ff       	call   100920 <panic>
  101ab2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  101ab9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101ac0 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  101ac0:	55                   	push   %ebp
  101ac1:	89 e5                	mov    %esp,%ebp
  101ac3:	53                   	push   %ebx
  101ac4:	83 ec 14             	sub    $0x14,%esp
  101ac7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
  101aca:	89 1c 24             	mov    %ebx,(%esp)
  101acd:	e8 9e fc ff ff       	call   101770 <iunlock>
  iput(ip);
  101ad2:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  101ad5:	83 c4 14             	add    $0x14,%esp
  101ad8:	5b                   	pop    %ebx
  101ad9:	5d                   	pop    %ebp
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
  101ada:	e9 a1 fd ff ff       	jmp    101880 <iput>
  101adf:	90                   	nop

00101ae0 <ialloc>:
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101ae0:	55                   	push   %ebp
  101ae1:	89 e5                	mov    %esp,%ebp
  101ae3:	57                   	push   %edi
  101ae4:	56                   	push   %esi
  101ae5:	53                   	push   %ebx
  101ae6:	83 ec 3c             	sub    $0x3c,%esp
  101ae9:	0f b7 45 0c          	movzwl 0xc(%ebp),%eax
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101aed:	8d 55 dc             	lea    -0x24(%ebp),%edx
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101af0:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101af4:	8b 45 08             	mov    0x8(%ebp),%eax
  101af7:	e8 a4 f6 ff ff       	call   1011a0 <readsb>
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101afc:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
  101b00:	0f 86 96 00 00 00    	jbe    101b9c <ialloc+0xbc>
  101b06:	be 01 00 00 00       	mov    $0x1,%esi
  101b0b:	bb 01 00 00 00       	mov    $0x1,%ebx
  101b10:	eb 18                	jmp    101b2a <ialloc+0x4a>
  101b12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101b18:	83 c3 01             	add    $0x1,%ebx
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101b1b:	89 3c 24             	mov    %edi,(%esp)
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b1e:	89 de                	mov    %ebx,%esi
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101b20:	e8 4b e5 ff ff       	call   100070 <brelse>
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b25:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  101b28:	76 72                	jbe    101b9c <ialloc+0xbc>
    bp = bread(dev, IBLOCK(inum));
  101b2a:	89 f0                	mov    %esi,%eax
  101b2c:	c1 e8 03             	shr    $0x3,%eax
  101b2f:	83 c0 02             	add    $0x2,%eax
  101b32:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b36:	8b 45 08             	mov    0x8(%ebp),%eax
  101b39:	89 04 24             	mov    %eax,(%esp)
  101b3c:	e8 df e5 ff ff       	call   100120 <bread>
  101b41:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
  101b43:	89 f0                	mov    %esi,%eax
  101b45:	83 e0 07             	and    $0x7,%eax
  101b48:	c1 e0 06             	shl    $0x6,%eax
  101b4b:	8d 54 07 18          	lea    0x18(%edi,%eax,1),%edx
    if(dip->type == 0){  // a free inode
  101b4f:	66 83 3a 00          	cmpw   $0x0,(%edx)
  101b53:	75 c3                	jne    101b18 <ialloc+0x38>
      memset(dip, 0, sizeof(*dip));
  101b55:	89 14 24             	mov    %edx,(%esp)
  101b58:	89 55 d0             	mov    %edx,-0x30(%ebp)
  101b5b:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
  101b62:	00 
  101b63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101b6a:	00 
  101b6b:	e8 60 20 00 00       	call   103bd0 <memset>
      dip->type = type;
  101b70:	8b 55 d0             	mov    -0x30(%ebp),%edx
  101b73:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101b77:	66 89 02             	mov    %ax,(%edx)
      bwrite(bp);   // mark it allocated on the disk
  101b7a:	89 3c 24             	mov    %edi,(%esp)
  101b7d:	e8 6e e5 ff ff       	call   1000f0 <bwrite>
      brelse(bp);
  101b82:	89 3c 24             	mov    %edi,(%esp)
  101b85:	e8 e6 e4 ff ff       	call   100070 <brelse>
      return iget(dev, inum);
  101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8d:	89 f2                	mov    %esi,%edx
  101b8f:	e8 4c f5 ff ff       	call   1010e0 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
  101b94:	83 c4 3c             	add    $0x3c,%esp
  101b97:	5b                   	pop    %ebx
  101b98:	5e                   	pop    %esi
  101b99:	5f                   	pop    %edi
  101b9a:	5d                   	pop    %ebp
  101b9b:	c3                   	ret    
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
  101b9c:	c7 04 24 c8 66 10 00 	movl   $0x1066c8,(%esp)
  101ba3:	e8 78 ed ff ff       	call   100920 <panic>
  101ba8:	90                   	nop
  101ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00101bb0 <ilock>:
}

// Lock the given inode.
void
ilock(struct inode *ip)
{
  101bb0:	55                   	push   %ebp
  101bb1:	89 e5                	mov    %esp,%ebp
  101bb3:	56                   	push   %esi
  101bb4:	53                   	push   %ebx
  101bb5:	83 ec 10             	sub    $0x10,%esp
  101bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
  101bbb:	85 db                	test   %ebx,%ebx
  101bbd:	0f 84 e5 00 00 00    	je     101ca8 <ilock+0xf8>
  101bc3:	8b 4b 08             	mov    0x8(%ebx),%ecx
  101bc6:	85 c9                	test   %ecx,%ecx
  101bc8:	0f 8e da 00 00 00    	jle    101ca8 <ilock+0xf8>
    panic("ilock");

  acquire(&icache.lock);
  101bce:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101bd5:	e8 56 1f 00 00       	call   103b30 <acquire>
  while(ip->flags & I_BUSY)
  101bda:	8b 43 0c             	mov    0xc(%ebx),%eax
  101bdd:	a8 01                	test   $0x1,%al
  101bdf:	74 1e                	je     101bff <ilock+0x4f>
  101be1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sleep(ip, &icache.lock);
  101be8:	c7 44 24 04 e0 aa 10 	movl   $0x10aae0,0x4(%esp)
  101bef:	00 
  101bf0:	89 1c 24             	mov    %ebx,(%esp)
  101bf3:	e8 58 16 00 00       	call   103250 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
  101bf8:	8b 43 0c             	mov    0xc(%ebx),%eax
  101bfb:	a8 01                	test   $0x1,%al
  101bfd:	75 e9                	jne    101be8 <ilock+0x38>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  101bff:	83 c8 01             	or     $0x1,%eax
  101c02:	89 43 0c             	mov    %eax,0xc(%ebx)
  release(&icache.lock);
  101c05:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101c0c:	e8 cf 1e 00 00       	call   103ae0 <release>

  if(!(ip->flags & I_VALID)){
  101c11:	f6 43 0c 02          	testb  $0x2,0xc(%ebx)
  101c15:	74 09                	je     101c20 <ilock+0x70>
    brelse(bp);
    ip->flags |= I_VALID;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
  101c17:	83 c4 10             	add    $0x10,%esp
  101c1a:	5b                   	pop    %ebx
  101c1b:	5e                   	pop    %esi
  101c1c:	5d                   	pop    %ebp
  101c1d:	c3                   	ret    
  101c1e:	66 90                	xchg   %ax,%ax
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  release(&icache.lock);

  if(!(ip->flags & I_VALID)){
    bp = bread(ip->dev, IBLOCK(ip->inum));
  101c20:	8b 43 04             	mov    0x4(%ebx),%eax
  101c23:	c1 e8 03             	shr    $0x3,%eax
  101c26:	83 c0 02             	add    $0x2,%eax
  101c29:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c2d:	8b 03                	mov    (%ebx),%eax
  101c2f:	89 04 24             	mov    %eax,(%esp)
  101c32:	e8 e9 e4 ff ff       	call   100120 <bread>
  101c37:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
  101c39:	8b 43 04             	mov    0x4(%ebx),%eax
  101c3c:	83 e0 07             	and    $0x7,%eax
  101c3f:	c1 e0 06             	shl    $0x6,%eax
  101c42:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
    ip->type = dip->type;
  101c46:	0f b7 10             	movzwl (%eax),%edx
  101c49:	66 89 53 10          	mov    %dx,0x10(%ebx)
    ip->major = dip->major;
  101c4d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
  101c51:	66 89 53 12          	mov    %dx,0x12(%ebx)
    ip->minor = dip->minor;
  101c55:	0f b7 50 04          	movzwl 0x4(%eax),%edx
  101c59:	66 89 53 14          	mov    %dx,0x14(%ebx)
    ip->nlink = dip->nlink;
  101c5d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
  101c61:	66 89 53 16          	mov    %dx,0x16(%ebx)
    ip->size = dip->size;
  101c65:	8b 50 08             	mov    0x8(%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101c68:	83 c0 0c             	add    $0xc,%eax
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
  101c6b:	89 53 18             	mov    %edx,0x18(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c72:	8d 43 1c             	lea    0x1c(%ebx),%eax
  101c75:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
  101c7c:	00 
  101c7d:	89 04 24             	mov    %eax,(%esp)
  101c80:	e8 cb 1f 00 00       	call   103c50 <memmove>
    brelse(bp);
  101c85:	89 34 24             	mov    %esi,(%esp)
  101c88:	e8 e3 e3 ff ff       	call   100070 <brelse>
    ip->flags |= I_VALID;
  101c8d:	83 4b 0c 02          	orl    $0x2,0xc(%ebx)
    if(ip->type == 0)
  101c91:	66 83 7b 10 00       	cmpw   $0x0,0x10(%ebx)
  101c96:	0f 85 7b ff ff ff    	jne    101c17 <ilock+0x67>
      panic("ilock: no type");
  101c9c:	c7 04 24 e0 66 10 00 	movl   $0x1066e0,(%esp)
  101ca3:	e8 78 ec ff ff       	call   100920 <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
  101ca8:	c7 04 24 da 66 10 00 	movl   $0x1066da,(%esp)
  101caf:	e8 6c ec ff ff       	call   100920 <panic>
  101cb4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101cba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00101cc0 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
  101cc0:	55                   	push   %ebp
  101cc1:	89 e5                	mov    %esp,%ebp
  101cc3:	57                   	push   %edi
  101cc4:	56                   	push   %esi
  101cc5:	53                   	push   %ebx
  101cc6:	89 c3                	mov    %eax,%ebx
  101cc8:	83 ec 2c             	sub    $0x2c,%esp
  101ccb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  101cce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
  101cd1:	80 38 2f             	cmpb   $0x2f,(%eax)
  101cd4:	0f 84 14 01 00 00    	je     101dee <namex+0x12e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
  101cda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  101ce0:	8b 40 68             	mov    0x68(%eax),%eax
  101ce3:	89 04 24             	mov    %eax,(%esp)
  101ce6:	e8 c5 f3 ff ff       	call   1010b0 <idup>
  101ceb:	89 c7                	mov    %eax,%edi
  101ced:	eb 04                	jmp    101cf3 <namex+0x33>
  101cef:	90                   	nop
{
  char *s;
  int len;

  while(*path == '/')
    path++;
  101cf0:	83 c3 01             	add    $0x1,%ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
  101cf3:	0f b6 03             	movzbl (%ebx),%eax
  101cf6:	3c 2f                	cmp    $0x2f,%al
  101cf8:	74 f6                	je     101cf0 <namex+0x30>
    path++;
  if(*path == 0)
  101cfa:	84 c0                	test   %al,%al
  101cfc:	75 1a                	jne    101d18 <namex+0x58>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
  101cfe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  101d01:	85 db                	test   %ebx,%ebx
  101d03:	0f 85 0d 01 00 00    	jne    101e16 <namex+0x156>
    iput(ip);
    return 0;
  }
  return ip;
}
  101d09:	83 c4 2c             	add    $0x2c,%esp
  101d0c:	89 f8                	mov    %edi,%eax
  101d0e:	5b                   	pop    %ebx
  101d0f:	5e                   	pop    %esi
  101d10:	5f                   	pop    %edi
  101d11:	5d                   	pop    %ebp
  101d12:	c3                   	ret    
  101d13:	90                   	nop
  101d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101d18:	3c 2f                	cmp    $0x2f,%al
  101d1a:	0f 84 94 00 00 00    	je     101db4 <namex+0xf4>
  101d20:	89 de                	mov    %ebx,%esi
  101d22:	eb 08                	jmp    101d2c <namex+0x6c>
  101d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101d28:	3c 2f                	cmp    $0x2f,%al
  101d2a:	74 0a                	je     101d36 <namex+0x76>
    path++;
  101d2c:	83 c6 01             	add    $0x1,%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101d2f:	0f b6 06             	movzbl (%esi),%eax
  101d32:	84 c0                	test   %al,%al
  101d34:	75 f2                	jne    101d28 <namex+0x68>
  101d36:	89 f2                	mov    %esi,%edx
  101d38:	29 da                	sub    %ebx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
  101d3a:	83 fa 0d             	cmp    $0xd,%edx
  101d3d:	7e 79                	jle    101db8 <namex+0xf8>
    memmove(name, s, DIRSIZ);
  101d3f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101d46:	00 
  101d47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101d4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101d4e:	89 04 24             	mov    %eax,(%esp)
  101d51:	e8 fa 1e 00 00       	call   103c50 <memmove>
  101d56:	eb 03                	jmp    101d5b <namex+0x9b>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
    path++;
  101d58:	83 c6 01             	add    $0x1,%esi
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101d5b:	80 3e 2f             	cmpb   $0x2f,(%esi)
  101d5e:	74 f8                	je     101d58 <namex+0x98>
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
  101d60:	85 f6                	test   %esi,%esi
  101d62:	74 9a                	je     101cfe <namex+0x3e>
    ilock(ip);
  101d64:	89 3c 24             	mov    %edi,(%esp)
  101d67:	e8 44 fe ff ff       	call   101bb0 <ilock>
    if(ip->type != T_DIR){
  101d6c:	66 83 7f 10 01       	cmpw   $0x1,0x10(%edi)
  101d71:	75 67                	jne    101dda <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
  101d73:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101d76:	85 c0                	test   %eax,%eax
  101d78:	74 0c                	je     101d86 <namex+0xc6>
  101d7a:	80 3e 00             	cmpb   $0x0,(%esi)
  101d7d:	8d 76 00             	lea    0x0(%esi),%esi
  101d80:	0f 84 7e 00 00 00    	je     101e04 <namex+0x144>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
  101d86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  101d8d:	00 
  101d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101d91:	89 3c 24             	mov    %edi,(%esp)
  101d94:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d98:	e8 d3 f8 ff ff       	call   101670 <dirlookup>
  101d9d:	85 c0                	test   %eax,%eax
  101d9f:	89 c3                	mov    %eax,%ebx
  101da1:	74 37                	je     101dda <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
  101da3:	89 3c 24             	mov    %edi,(%esp)
  101da6:	89 df                	mov    %ebx,%edi
  101da8:	89 f3                	mov    %esi,%ebx
  101daa:	e8 11 fd ff ff       	call   101ac0 <iunlockput>
  101daf:	e9 3f ff ff ff       	jmp    101cf3 <namex+0x33>
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101db4:	89 de                	mov    %ebx,%esi
  101db6:	31 d2                	xor    %edx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
  101db8:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101dc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101dc3:	89 04 24             	mov    %eax,(%esp)
  101dc6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  101dc9:	e8 82 1e 00 00       	call   103c50 <memmove>
    name[len] = 0;
  101dce:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101dd4:	c6 04 10 00          	movb   $0x0,(%eax,%edx,1)
  101dd8:	eb 81                	jmp    101d5b <namex+0x9b>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
  101dda:	89 3c 24             	mov    %edi,(%esp)
  101ddd:	31 ff                	xor    %edi,%edi
  101ddf:	e8 dc fc ff ff       	call   101ac0 <iunlockput>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101de4:	83 c4 2c             	add    $0x2c,%esp
  101de7:	89 f8                	mov    %edi,%eax
  101de9:	5b                   	pop    %ebx
  101dea:	5e                   	pop    %esi
  101deb:	5f                   	pop    %edi
  101dec:	5d                   	pop    %ebp
  101ded:	c3                   	ret    
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  101dee:	ba 01 00 00 00       	mov    $0x1,%edx
  101df3:	b8 01 00 00 00       	mov    $0x1,%eax
  101df8:	e8 e3 f2 ff ff       	call   1010e0 <iget>
  101dfd:	89 c7                	mov    %eax,%edi
  101dff:	e9 ef fe ff ff       	jmp    101cf3 <namex+0x33>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
  101e04:	89 3c 24             	mov    %edi,(%esp)
  101e07:	e8 64 f9 ff ff       	call   101770 <iunlock>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101e0c:	83 c4 2c             	add    $0x2c,%esp
  101e0f:	89 f8                	mov    %edi,%eax
  101e11:	5b                   	pop    %ebx
  101e12:	5e                   	pop    %esi
  101e13:	5f                   	pop    %edi
  101e14:	5d                   	pop    %ebp
  101e15:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
  101e16:	89 3c 24             	mov    %edi,(%esp)
  101e19:	31 ff                	xor    %edi,%edi
  101e1b:	e8 60 fa ff ff       	call   101880 <iput>
    return 0;
  101e20:	e9 e4 fe ff ff       	jmp    101d09 <namex+0x49>
  101e25:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101e30 <nameiparent>:
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101e30:	55                   	push   %ebp
  return namex(path, 1, name);
  101e31:	ba 01 00 00 00       	mov    $0x1,%edx
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101e36:	89 e5                	mov    %esp,%ebp
  101e38:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
  101e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  101e41:	c9                   	leave  
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
  101e42:	e9 79 fe ff ff       	jmp    101cc0 <namex>
  101e47:	89 f6                	mov    %esi,%esi
  101e49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101e50 <namei>:
  return ip;
}

struct inode*
namei(char *path)
{
  101e50:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101e51:	31 d2                	xor    %edx,%edx
  return ip;
}

struct inode*
namei(char *path)
{
  101e53:	89 e5                	mov    %esp,%ebp
  101e55:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101e58:	8b 45 08             	mov    0x8(%ebp),%eax
  101e5b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
  101e5e:	e8 5d fe ff ff       	call   101cc0 <namex>
}
  101e63:	c9                   	leave  
  101e64:	c3                   	ret    
  101e65:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101e69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101e70 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
  101e70:	55                   	push   %ebp
  101e71:	89 e5                	mov    %esp,%ebp
  101e73:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
  101e76:	c7 44 24 04 ef 66 10 	movl   $0x1066ef,0x4(%esp)
  101e7d:	00 
  101e7e:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101e85:	e8 16 1b 00 00       	call   1039a0 <initlock>
}
  101e8a:	c9                   	leave  
  101e8b:	c3                   	ret    
  101e8c:	90                   	nop
  101e8d:	90                   	nop
  101e8e:	90                   	nop
  101e8f:	90                   	nop

00101e90 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  101e90:	55                   	push   %ebp
  101e91:	89 e5                	mov    %esp,%ebp
  101e93:	56                   	push   %esi
  101e94:	89 c6                	mov    %eax,%esi
  101e96:	83 ec 14             	sub    $0x14,%esp
  if(b == 0)
  101e99:	85 c0                	test   %eax,%eax
  101e9b:	0f 84 8d 00 00 00    	je     101f2e <idestart+0x9e>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  101ea1:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101ea6:	66 90                	xchg   %ax,%ax
  101ea8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  101ea9:	25 c0 00 00 00       	and    $0xc0,%eax
  101eae:	83 f8 40             	cmp    $0x40,%eax
  101eb1:	75 f5                	jne    101ea8 <idestart+0x18>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  101eb3:	ba f6 03 00 00       	mov    $0x3f6,%edx
  101eb8:	31 c0                	xor    %eax,%eax
  101eba:	ee                   	out    %al,(%dx)
  101ebb:	ba f2 01 00 00       	mov    $0x1f2,%edx
  101ec0:	b8 01 00 00 00       	mov    $0x1,%eax
  101ec5:	ee                   	out    %al,(%dx)
    panic("idestart");

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, 1);  // number of sectors
  outb(0x1f3, b->sector & 0xff);
  101ec6:	8b 4e 08             	mov    0x8(%esi),%ecx
  101ec9:	b2 f3                	mov    $0xf3,%dl
  101ecb:	89 c8                	mov    %ecx,%eax
  101ecd:	ee                   	out    %al,(%dx)
  101ece:	89 c8                	mov    %ecx,%eax
  101ed0:	b2 f4                	mov    $0xf4,%dl
  101ed2:	c1 e8 08             	shr    $0x8,%eax
  101ed5:	ee                   	out    %al,(%dx)
  101ed6:	89 c8                	mov    %ecx,%eax
  101ed8:	b2 f5                	mov    $0xf5,%dl
  101eda:	c1 e8 10             	shr    $0x10,%eax
  101edd:	ee                   	out    %al,(%dx)
  101ede:	8b 46 04             	mov    0x4(%esi),%eax
  101ee1:	c1 e9 18             	shr    $0x18,%ecx
  101ee4:	b2 f6                	mov    $0xf6,%dl
  101ee6:	83 e1 0f             	and    $0xf,%ecx
  101ee9:	83 e0 01             	and    $0x1,%eax
  101eec:	c1 e0 04             	shl    $0x4,%eax
  101eef:	09 c8                	or     %ecx,%eax
  101ef1:	83 c8 e0             	or     $0xffffffe0,%eax
  101ef4:	ee                   	out    %al,(%dx)
  outb(0x1f4, (b->sector >> 8) & 0xff);
  outb(0x1f5, (b->sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
  101ef5:	f6 06 04             	testb  $0x4,(%esi)
  101ef8:	75 16                	jne    101f10 <idestart+0x80>
  101efa:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101eff:	b8 20 00 00 00       	mov    $0x20,%eax
  101f04:	ee                   	out    %al,(%dx)
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
  101f05:	83 c4 14             	add    $0x14,%esp
  101f08:	5e                   	pop    %esi
  101f09:	5d                   	pop    %ebp
  101f0a:	c3                   	ret    
  101f0b:	90                   	nop
  101f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101f10:	b2 f7                	mov    $0xf7,%dl
  101f12:	b8 30 00 00 00       	mov    $0x30,%eax
  101f17:	ee                   	out    %al,(%dx)
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
  101f18:	b9 80 00 00 00       	mov    $0x80,%ecx
  101f1d:	83 c6 18             	add    $0x18,%esi
  101f20:	ba f0 01 00 00       	mov    $0x1f0,%edx
  101f25:	fc                   	cld    
  101f26:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  101f28:	83 c4 14             	add    $0x14,%esp
  101f2b:	5e                   	pop    %esi
  101f2c:	5d                   	pop    %ebp
  101f2d:	c3                   	ret    
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  101f2e:	c7 04 24 f6 66 10 00 	movl   $0x1066f6,(%esp)
  101f35:	e8 e6 e9 ff ff       	call   100920 <panic>
  101f3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00101f40 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
  101f40:	55                   	push   %ebp
  101f41:	89 e5                	mov    %esp,%ebp
  101f43:	53                   	push   %ebx
  101f44:	83 ec 14             	sub    $0x14,%esp
  101f47:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!(b->flags & B_BUSY))
  101f4a:	8b 03                	mov    (%ebx),%eax
  101f4c:	a8 01                	test   $0x1,%al
  101f4e:	0f 84 90 00 00 00    	je     101fe4 <iderw+0xa4>
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
  101f54:	83 e0 06             	and    $0x6,%eax
  101f57:	83 f8 02             	cmp    $0x2,%eax
  101f5a:	0f 84 9c 00 00 00    	je     101ffc <iderw+0xbc>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
  101f60:	8b 53 04             	mov    0x4(%ebx),%edx
  101f63:	85 d2                	test   %edx,%edx
  101f65:	74 0d                	je     101f74 <iderw+0x34>
  101f67:	a1 b8 78 10 00       	mov    0x1078b8,%eax
  101f6c:	85 c0                	test   %eax,%eax
  101f6e:	0f 84 7c 00 00 00    	je     101ff0 <iderw+0xb0>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);
  101f74:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  101f7b:	e8 b0 1b 00 00       	call   103b30 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  101f80:	ba b4 78 10 00       	mov    $0x1078b4,%edx
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);

  // Append b to idequeue.
  b->qnext = 0;
  101f85:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  101f8c:	a1 b4 78 10 00       	mov    0x1078b4,%eax
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  101f91:	85 c0                	test   %eax,%eax
  101f93:	74 0d                	je     101fa2 <iderw+0x62>
  101f95:	8d 76 00             	lea    0x0(%esi),%esi
  101f98:	8d 50 14             	lea    0x14(%eax),%edx
  101f9b:	8b 40 14             	mov    0x14(%eax),%eax
  101f9e:	85 c0                	test   %eax,%eax
  101fa0:	75 f6                	jne    101f98 <iderw+0x58>
    ;
  *pp = b;
  101fa2:	89 1a                	mov    %ebx,(%edx)
  
  // Start disk if necessary.
  if(idequeue == b)
  101fa4:	39 1d b4 78 10 00    	cmp    %ebx,0x1078b4
  101faa:	75 14                	jne    101fc0 <iderw+0x80>
  101fac:	eb 2d                	jmp    101fdb <iderw+0x9b>
  101fae:	66 90                	xchg   %ax,%ax
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  101fb0:	c7 44 24 04 80 78 10 	movl   $0x107880,0x4(%esp)
  101fb7:	00 
  101fb8:	89 1c 24             	mov    %ebx,(%esp)
  101fbb:	e8 90 12 00 00       	call   103250 <sleep>
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
  101fc0:	8b 03                	mov    (%ebx),%eax
  101fc2:	83 e0 06             	and    $0x6,%eax
  101fc5:	83 f8 02             	cmp    $0x2,%eax
  101fc8:	75 e6                	jne    101fb0 <iderw+0x70>
    sleep(b, &idelock);
  }

  release(&idelock);
  101fca:	c7 45 08 80 78 10 00 	movl   $0x107880,0x8(%ebp)
}
  101fd1:	83 c4 14             	add    $0x14,%esp
  101fd4:	5b                   	pop    %ebx
  101fd5:	5d                   	pop    %ebp
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }

  release(&idelock);
  101fd6:	e9 05 1b 00 00       	jmp    103ae0 <release>
    ;
  *pp = b;
  
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  101fdb:	89 d8                	mov    %ebx,%eax
  101fdd:	e8 ae fe ff ff       	call   101e90 <idestart>
  101fe2:	eb dc                	jmp    101fc0 <iderw+0x80>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  101fe4:	c7 04 24 ff 66 10 00 	movl   $0x1066ff,(%esp)
  101feb:	e8 30 e9 ff ff       	call   100920 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
  101ff0:	c7 04 24 28 67 10 00 	movl   $0x106728,(%esp)
  101ff7:	e8 24 e9 ff ff       	call   100920 <panic>
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  101ffc:	c7 04 24 13 67 10 00 	movl   $0x106713,(%esp)
  102003:	e8 18 e9 ff ff       	call   100920 <panic>
  102008:	90                   	nop
  102009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102010 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
  102010:	55                   	push   %ebp
  102011:	89 e5                	mov    %esp,%ebp
  102013:	57                   	push   %edi
  102014:	53                   	push   %ebx
  102015:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  // Take first buffer off queue.
  acquire(&idelock);
  102018:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  10201f:	e8 0c 1b 00 00       	call   103b30 <acquire>
  if((b = idequeue) == 0){
  102024:	8b 1d b4 78 10 00    	mov    0x1078b4,%ebx
  10202a:	85 db                	test   %ebx,%ebx
  10202c:	74 2d                	je     10205b <ideintr+0x4b>
    release(&idelock);
    // cprintf("spurious IDE interrupt\n");
    return;
  }
  idequeue = b->qnext;
  10202e:	8b 43 14             	mov    0x14(%ebx),%eax
  102031:	a3 b4 78 10 00       	mov    %eax,0x1078b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
  102036:	8b 0b                	mov    (%ebx),%ecx
  102038:	f6 c1 04             	test   $0x4,%cl
  10203b:	74 33                	je     102070 <ideintr+0x60>
    insl(0x1f0, b->data, 512/4);
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
  10203d:	83 c9 02             	or     $0x2,%ecx
  102040:	83 e1 fb             	and    $0xfffffffb,%ecx
  102043:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
  102045:	89 1c 24             	mov    %ebx,(%esp)
  102048:	e8 e3 10 00 00       	call   103130 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
  10204d:	a1 b4 78 10 00       	mov    0x1078b4,%eax
  102052:	85 c0                	test   %eax,%eax
  102054:	74 05                	je     10205b <ideintr+0x4b>
    idestart(idequeue);
  102056:	e8 35 fe ff ff       	call   101e90 <idestart>

  release(&idelock);
  10205b:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  102062:	e8 79 1a 00 00       	call   103ae0 <release>
}
  102067:	83 c4 10             	add    $0x10,%esp
  10206a:	5b                   	pop    %ebx
  10206b:	5f                   	pop    %edi
  10206c:	5d                   	pop    %ebp
  10206d:	c3                   	ret    
  10206e:	66 90                	xchg   %ax,%ax
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102070:	ba f7 01 00 00       	mov    $0x1f7,%edx
  102075:	8d 76 00             	lea    0x0(%esi),%esi
  102078:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  102079:	0f b6 c0             	movzbl %al,%eax
  10207c:	89 c7                	mov    %eax,%edi
  10207e:	81 e7 c0 00 00 00    	and    $0xc0,%edi
  102084:	83 ff 40             	cmp    $0x40,%edi
  102087:	75 ef                	jne    102078 <ideintr+0x68>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
  102089:	a8 21                	test   $0x21,%al
  10208b:	75 b0                	jne    10203d <ideintr+0x2d>
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
  10208d:	8d 7b 18             	lea    0x18(%ebx),%edi
  102090:	b9 80 00 00 00       	mov    $0x80,%ecx
  102095:	ba f0 01 00 00       	mov    $0x1f0,%edx
  10209a:	fc                   	cld    
  10209b:	f3 6d                	rep insl (%dx),%es:(%edi)
  10209d:	8b 0b                	mov    (%ebx),%ecx
  10209f:	eb 9c                	jmp    10203d <ideintr+0x2d>
  1020a1:	eb 0d                	jmp    1020b0 <ideinit>
  1020a3:	90                   	nop
  1020a4:	90                   	nop
  1020a5:	90                   	nop
  1020a6:	90                   	nop
  1020a7:	90                   	nop
  1020a8:	90                   	nop
  1020a9:	90                   	nop
  1020aa:	90                   	nop
  1020ab:	90                   	nop
  1020ac:	90                   	nop
  1020ad:	90                   	nop
  1020ae:	90                   	nop
  1020af:	90                   	nop

001020b0 <ideinit>:
  return 0;
}

void
ideinit(void)
{
  1020b0:	55                   	push   %ebp
  1020b1:	89 e5                	mov    %esp,%ebp
  1020b3:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
  1020b6:	c7 44 24 04 46 67 10 	movl   $0x106746,0x4(%esp)
  1020bd:	00 
  1020be:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  1020c5:	e8 d6 18 00 00       	call   1039a0 <initlock>
  picenable(IRQ_IDE);
  1020ca:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  1020d1:	e8 ba 0a 00 00       	call   102b90 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
  1020d6:	a1 00 c1 10 00       	mov    0x10c100,%eax
  1020db:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  1020e2:	83 e8 01             	sub    $0x1,%eax
  1020e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1020e9:	e8 52 00 00 00       	call   102140 <ioapicenable>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  1020ee:	ba f7 01 00 00       	mov    $0x1f7,%edx
  1020f3:	90                   	nop
  1020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1020f8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  1020f9:	25 c0 00 00 00       	and    $0xc0,%eax
  1020fe:	83 f8 40             	cmp    $0x40,%eax
  102101:	75 f5                	jne    1020f8 <ideinit+0x48>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102103:	ba f6 01 00 00       	mov    $0x1f6,%edx
  102108:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  10210d:	ee                   	out    %al,(%dx)
  10210e:	31 c9                	xor    %ecx,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102110:	b2 f7                	mov    $0xf7,%dl
  102112:	eb 0f                	jmp    102123 <ideinit+0x73>
  102114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
  102118:	83 c1 01             	add    $0x1,%ecx
  10211b:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  102121:	74 0f                	je     102132 <ideinit+0x82>
  102123:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
  102124:	84 c0                	test   %al,%al
  102126:	74 f0                	je     102118 <ideinit+0x68>
      havedisk1 = 1;
  102128:	c7 05 b8 78 10 00 01 	movl   $0x1,0x1078b8
  10212f:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102132:	ba f6 01 00 00       	mov    $0x1f6,%edx
  102137:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  10213c:	ee                   	out    %al,(%dx)
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
  10213d:	c9                   	leave  
  10213e:	c3                   	ret    
  10213f:	90                   	nop

00102140 <ioapicenable>:
}

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
  102140:	8b 15 04 bb 10 00    	mov    0x10bb04,%edx
  }
}

void
ioapicenable(int irq, int cpunum)
{
  102146:	55                   	push   %ebp
  102147:	89 e5                	mov    %esp,%ebp
  102149:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!ismp)
  10214c:	85 d2                	test   %edx,%edx
  10214e:	74 31                	je     102181 <ioapicenable+0x41>
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102150:	8b 15 b4 ba 10 00    	mov    0x10bab4,%edx
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  102156:	8d 48 20             	lea    0x20(%eax),%ecx
  102159:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10215d:	89 02                	mov    %eax,(%edx)
  ioapic->data = data;
  10215f:	8b 15 b4 ba 10 00    	mov    0x10bab4,%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102165:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
  102168:	89 4a 10             	mov    %ecx,0x10(%edx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10216b:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  102171:	8b 55 0c             	mov    0xc(%ebp),%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102174:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
  102176:	a1 b4 ba 10 00       	mov    0x10bab4,%eax

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  10217b:	c1 e2 18             	shl    $0x18,%edx

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  10217e:	89 50 10             	mov    %edx,0x10(%eax)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
  102181:	5d                   	pop    %ebp
  102182:	c3                   	ret    
  102183:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  102189:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102190 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
  102190:	55                   	push   %ebp
  102191:	89 e5                	mov    %esp,%ebp
  102193:	56                   	push   %esi
  102194:	53                   	push   %ebx
  102195:	83 ec 10             	sub    $0x10,%esp
  int i, id, maxintr;

  if(!ismp)
  102198:	8b 0d 04 bb 10 00    	mov    0x10bb04,%ecx
  10219e:	85 c9                	test   %ecx,%ecx
  1021a0:	0f 84 9e 00 00 00    	je     102244 <ioapicinit+0xb4>
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  1021a6:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
  1021ad:	00 00 00 
  return ioapic->data;
  1021b0:	8b 35 10 00 c0 fe    	mov    0xfec00010,%esi
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021b6:	bb 00 00 c0 fe       	mov    $0xfec00000,%ebx
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  1021bb:	c7 05 00 00 c0 fe 00 	movl   $0x0,0xfec00000
  1021c2:	00 00 00 
  return ioapic->data;
  1021c5:	a1 10 00 c0 fe       	mov    0xfec00010,%eax
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021ca:	0f b6 15 00 bb 10 00 	movzbl 0x10bb00,%edx
  int i, id, maxintr;

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  1021d1:	c7 05 b4 ba 10 00 00 	movl   $0xfec00000,0x10bab4
  1021d8:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  1021db:	c1 ee 10             	shr    $0x10,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021de:	c1 e8 18             	shr    $0x18,%eax

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  1021e1:	81 e6 ff 00 00 00    	and    $0xff,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  1021e7:	39 c2                	cmp    %eax,%edx
  1021e9:	74 12                	je     1021fd <ioapicinit+0x6d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
  1021eb:	c7 04 24 4c 67 10 00 	movl   $0x10674c,(%esp)
  1021f2:	e8 39 e3 ff ff       	call   100530 <cprintf>
  1021f7:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
  1021fd:	ba 10 00 00 00       	mov    $0x10,%edx
  102202:	31 c0                	xor    %eax,%eax
  102204:	eb 08                	jmp    10220e <ioapicinit+0x7e>
  102206:	66 90                	xchg   %ax,%ax

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  102208:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10220e:	89 13                	mov    %edx,(%ebx)
  ioapic->data = data;
  102210:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
  102216:	8d 48 20             	lea    0x20(%eax),%ecx
  102219:	81 c9 00 00 01 00    	or     $0x10000,%ecx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  10221f:	83 c0 01             	add    $0x1,%eax

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  102222:	89 4b 10             	mov    %ecx,0x10(%ebx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102225:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx
  10222b:	8d 5a 01             	lea    0x1(%edx),%ebx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  10222e:	83 c2 02             	add    $0x2,%edx
  102231:	39 c6                	cmp    %eax,%esi
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102233:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
  102235:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx
  10223b:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  102242:	7d c4                	jge    102208 <ioapicinit+0x78>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
  102244:	83 c4 10             	add    $0x10,%esp
  102247:	5b                   	pop    %ebx
  102248:	5e                   	pop    %esi
  102249:	5d                   	pop    %ebp
  10224a:	c3                   	ret    
  10224b:	90                   	nop
  10224c:	90                   	nop
  10224d:	90                   	nop
  10224e:	90                   	nop
  10224f:	90                   	nop

00102250 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  102250:	55                   	push   %ebp
  102251:	89 e5                	mov    %esp,%ebp
  102253:	53                   	push   %ebx
  102254:	83 ec 14             	sub    $0x14,%esp
  struct run *r;

  acquire(&kmem.lock);
  102257:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  10225e:	e8 cd 18 00 00       	call   103b30 <acquire>
  r = kmem.freelist;
  102263:	8b 1d f4 ba 10 00    	mov    0x10baf4,%ebx
  if(r)
  102269:	85 db                	test   %ebx,%ebx
  10226b:	74 07                	je     102274 <kalloc+0x24>
    kmem.freelist = r->next;
  10226d:	8b 03                	mov    (%ebx),%eax
  10226f:	a3 f4 ba 10 00       	mov    %eax,0x10baf4
  release(&kmem.lock);
  102274:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  10227b:	e8 60 18 00 00       	call   103ae0 <release>
  return (char*)r;
}
  102280:	89 d8                	mov    %ebx,%eax
  102282:	83 c4 14             	add    $0x14,%esp
  102285:	5b                   	pop    %ebx
  102286:	5d                   	pop    %ebp
  102287:	c3                   	ret    
  102288:	90                   	nop
  102289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102290 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
  102290:	55                   	push   %ebp
  102291:	89 e5                	mov    %esp,%ebp
  102293:	53                   	push   %ebx
  102294:	83 ec 14             	sub    $0x14,%esp
  102297:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
  10229a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  1022a0:	75 52                	jne    1022f4 <kfree+0x64>
  1022a2:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  1022a8:	77 4a                	ja     1022f4 <kfree+0x64>
  1022aa:	81 fb 44 e9 10 00    	cmp    $0x10e944,%ebx
  1022b0:	72 42                	jb     1022f4 <kfree+0x64>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
  1022b2:	89 1c 24             	mov    %ebx,(%esp)
  1022b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1022bc:	00 
  1022bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1022c4:	00 
  1022c5:	e8 06 19 00 00       	call   103bd0 <memset>

  acquire(&kmem.lock);
  1022ca:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  1022d1:	e8 5a 18 00 00       	call   103b30 <acquire>
  r = (struct run*)v;
  r->next = kmem.freelist;
  1022d6:	a1 f4 ba 10 00       	mov    0x10baf4,%eax
  1022db:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  1022dd:	89 1d f4 ba 10 00    	mov    %ebx,0x10baf4
  release(&kmem.lock);
  1022e3:	c7 45 08 c0 ba 10 00 	movl   $0x10bac0,0x8(%ebp)
}
  1022ea:	83 c4 14             	add    $0x14,%esp
  1022ed:	5b                   	pop    %ebx
  1022ee:	5d                   	pop    %ebp

  acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
  1022ef:	e9 ec 17 00 00       	jmp    103ae0 <release>
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
    panic("kfree");
  1022f4:	c7 04 24 7e 67 10 00 	movl   $0x10677e,(%esp)
  1022fb:	e8 20 e6 ff ff       	call   100920 <panic>

00102300 <kinit>:
extern char end[]; // first address after kernel loaded from ELF file

// Initialize free list of physical pages.
void
kinit(void)
{
  102300:	55                   	push   %ebp
  102301:	89 e5                	mov    %esp,%ebp
  102303:	53                   	push   %ebx
  102304:	83 ec 14             	sub    $0x14,%esp
  char *p;

  initlock(&kmem.lock, "kmem");
  102307:	c7 44 24 04 84 67 10 	movl   $0x106784,0x4(%esp)
  10230e:	00 
  10230f:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  102316:	e8 85 16 00 00       	call   1039a0 <initlock>
  p = (char*)PGROUNDUP((uint)end);
  10231b:	ba 43 f9 10 00       	mov    $0x10f943,%edx
  102320:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  102326:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
  10232c:	81 fb 00 00 00 01    	cmp    $0x1000000,%ebx
  102332:	76 08                	jbe    10233c <kinit+0x3c>
  102334:	eb 1b                	jmp    102351 <kinit+0x51>
  102336:	66 90                	xchg   %ax,%ax
  102338:	89 da                	mov    %ebx,%edx
  10233a:	89 c3                	mov    %eax,%ebx
    kfree(p);
  10233c:	89 14 24             	mov    %edx,(%esp)
  10233f:	e8 4c ff ff ff       	call   102290 <kfree>
{
  char *p;

  initlock(&kmem.lock, "kmem");
  p = (char*)PGROUNDUP((uint)end);
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  102344:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  10234a:	3d 00 00 00 01       	cmp    $0x1000000,%eax
  10234f:	76 e7                	jbe    102338 <kinit+0x38>
    kfree(p);
}
  102351:	83 c4 14             	add    $0x14,%esp
  102354:	5b                   	pop    %ebx
  102355:	5d                   	pop    %ebp
  102356:	c3                   	ret    
  102357:	90                   	nop
  102358:	90                   	nop
  102359:	90                   	nop
  10235a:	90                   	nop
  10235b:	90                   	nop
  10235c:	90                   	nop
  10235d:	90                   	nop
  10235e:	90                   	nop
  10235f:	90                   	nop

00102360 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
  102360:	55                   	push   %ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102361:	ba 64 00 00 00       	mov    $0x64,%edx
  102366:	89 e5                	mov    %esp,%ebp
  102368:	ec                   	in     (%dx),%al
  102369:	89 c2                	mov    %eax,%edx
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
  10236b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102370:	83 e2 01             	and    $0x1,%edx
  102373:	74 3e                	je     1023b3 <kbdgetc+0x53>
  102375:	ba 60 00 00 00       	mov    $0x60,%edx
  10237a:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
  10237b:	0f b6 c0             	movzbl %al,%eax

  if(data == 0xE0){
  10237e:	3d e0 00 00 00       	cmp    $0xe0,%eax
  102383:	0f 84 7f 00 00 00    	je     102408 <kbdgetc+0xa8>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
  102389:	84 c0                	test   %al,%al
  10238b:	79 2b                	jns    1023b8 <kbdgetc+0x58>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
  10238d:	8b 15 bc 78 10 00    	mov    0x1078bc,%edx
  102393:	f6 c2 40             	test   $0x40,%dl
  102396:	75 03                	jne    10239b <kbdgetc+0x3b>
  102398:	83 e0 7f             	and    $0x7f,%eax
    shift &= ~(shiftcode[data] | E0ESC);
  10239b:	0f b6 80 a0 67 10 00 	movzbl 0x1067a0(%eax),%eax
  1023a2:	83 c8 40             	or     $0x40,%eax
  1023a5:	0f b6 c0             	movzbl %al,%eax
  1023a8:	f7 d0                	not    %eax
  1023aa:	21 d0                	and    %edx,%eax
  1023ac:	a3 bc 78 10 00       	mov    %eax,0x1078bc
  1023b1:	31 c0                	xor    %eax,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  1023b3:	5d                   	pop    %ebp
  1023b4:	c3                   	ret    
  1023b5:	8d 76 00             	lea    0x0(%esi),%esi
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
  1023b8:	8b 0d bc 78 10 00    	mov    0x1078bc,%ecx
  1023be:	f6 c1 40             	test   $0x40,%cl
  1023c1:	74 05                	je     1023c8 <kbdgetc+0x68>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
  1023c3:	0c 80                	or     $0x80,%al
    shift &= ~E0ESC;
  1023c5:	83 e1 bf             	and    $0xffffffbf,%ecx
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  1023c8:	0f b6 90 a0 67 10 00 	movzbl 0x1067a0(%eax),%edx
  1023cf:	09 ca                	or     %ecx,%edx
  1023d1:	0f b6 88 a0 68 10 00 	movzbl 0x1068a0(%eax),%ecx
  1023d8:	31 ca                	xor    %ecx,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
  1023da:	89 d1                	mov    %edx,%ecx
  1023dc:	83 e1 03             	and    $0x3,%ecx
  1023df:	8b 0c 8d a0 69 10 00 	mov    0x1069a0(,%ecx,4),%ecx
    data |= 0x80;
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  1023e6:	89 15 bc 78 10 00    	mov    %edx,0x1078bc
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
  1023ec:	83 e2 08             	and    $0x8,%edx
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  1023ef:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
  if(shift & CAPSLOCK){
  1023f3:	74 be                	je     1023b3 <kbdgetc+0x53>
    if('a' <= c && c <= 'z')
  1023f5:	8d 50 9f             	lea    -0x61(%eax),%edx
  1023f8:	83 fa 19             	cmp    $0x19,%edx
  1023fb:	77 1b                	ja     102418 <kbdgetc+0xb8>
      c += 'A' - 'a';
  1023fd:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102400:	5d                   	pop    %ebp
  102401:	c3                   	ret    
  102402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if((st & KBS_DIB) == 0)
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
  102408:	30 c0                	xor    %al,%al
  10240a:	83 0d bc 78 10 00 40 	orl    $0x40,0x1078bc
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102411:	5d                   	pop    %ebp
  102412:	c3                   	ret    
  102413:	90                   	nop
  102414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
  102418:	8d 50 bf             	lea    -0x41(%eax),%edx
  10241b:	83 fa 19             	cmp    $0x19,%edx
  10241e:	77 93                	ja     1023b3 <kbdgetc+0x53>
      c += 'a' - 'A';
  102420:	83 c0 20             	add    $0x20,%eax
  }
  return c;
}
  102423:	5d                   	pop    %ebp
  102424:	c3                   	ret    
  102425:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102429:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102430 <kbdintr>:

void
kbdintr(void)
{
  102430:	55                   	push   %ebp
  102431:	89 e5                	mov    %esp,%ebp
  102433:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
  102436:	c7 04 24 60 23 10 00 	movl   $0x102360,(%esp)
  10243d:	e8 4e e3 ff ff       	call   100790 <consoleintr>
}
  102442:	c9                   	leave  
  102443:	c3                   	ret    
  102444:	90                   	nop
  102445:	90                   	nop
  102446:	90                   	nop
  102447:	90                   	nop
  102448:	90                   	nop
  102449:	90                   	nop
  10244a:	90                   	nop
  10244b:	90                   	nop
  10244c:	90                   	nop
  10244d:	90                   	nop
  10244e:	90                   	nop
  10244f:	90                   	nop

00102450 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
  102450:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
}

// Acknowledge interrupt.
void
lapiceoi(void)
{
  102455:	55                   	push   %ebp
  102456:	89 e5                	mov    %esp,%ebp
  if(lapic)
  102458:	85 c0                	test   %eax,%eax
  10245a:	74 12                	je     10246e <lapiceoi+0x1e>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10245c:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  102463:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102466:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10246b:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
  10246e:	5d                   	pop    %ebp
  10246f:	c3                   	ret    

00102470 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
  102470:	55                   	push   %ebp
  102471:	89 e5                	mov    %esp,%ebp
}
  102473:	5d                   	pop    %ebp
  102474:	c3                   	ret    
  102475:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102480 <lapicstartap>:

// Start additional processor running bootstrap code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
  102480:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102481:	ba 70 00 00 00       	mov    $0x70,%edx
  102486:	89 e5                	mov    %esp,%ebp
  102488:	b8 0f 00 00 00       	mov    $0xf,%eax
  10248d:	53                   	push   %ebx
  10248e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  102491:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
  102495:	ee                   	out    %al,(%dx)
  102496:	b8 0a 00 00 00       	mov    $0xa,%eax
  10249b:	b2 71                	mov    $0x71,%dl
  10249d:	ee                   	out    %al,(%dx)
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  wrv[1] = addr >> 4;
  10249e:	89 c8                	mov    %ecx,%eax
  1024a0:	c1 e8 04             	shr    $0x4,%eax
  1024a3:	66 a3 69 04 00 00    	mov    %ax,0x469
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024a9:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024ae:	c1 e3 18             	shl    $0x18,%ebx
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  1024b1:	66 c7 05 67 04 00 00 	movw   $0x0,0x467
  1024b8:	00 00 

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  1024ba:	c1 e9 0c             	shr    $0xc,%ecx
  1024bd:	80 cd 06             	or     $0x6,%ch
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024c0:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  1024c6:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024cb:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024ce:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
  1024d5:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1024d8:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024dd:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024e0:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
  1024e7:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1024ea:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024ef:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024f2:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  1024f8:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024fd:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102500:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102506:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10250b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10250e:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102514:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102519:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10251c:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102522:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  102527:	5b                   	pop    %ebx
  102528:	5d                   	pop    %ebp

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  102529:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  10252c:	c3                   	ret    
  10252d:	8d 76 00             	lea    0x0(%esi),%esi

00102530 <cpunum>:
  lapicw(TPR, 0);
}

int
cpunum(void)
{
  102530:	55                   	push   %ebp
  102531:	89 e5                	mov    %esp,%ebp
  102533:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  102536:	9c                   	pushf  
  102537:	58                   	pop    %eax
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
  102538:	f6 c4 02             	test   $0x2,%ah
  10253b:	74 12                	je     10254f <cpunum+0x1f>
    static int n;
    if(n++ == 0)
  10253d:	a1 c0 78 10 00       	mov    0x1078c0,%eax
  102542:	8d 50 01             	lea    0x1(%eax),%edx
  102545:	85 c0                	test   %eax,%eax
  102547:	89 15 c0 78 10 00    	mov    %edx,0x1078c0
  10254d:	74 19                	je     102568 <cpunum+0x38>
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if(lapic)
  10254f:	8b 15 f8 ba 10 00    	mov    0x10baf8,%edx
  102555:	31 c0                	xor    %eax,%eax
  102557:	85 d2                	test   %edx,%edx
  102559:	74 06                	je     102561 <cpunum+0x31>
    return lapic[ID]>>24;
  10255b:	8b 42 20             	mov    0x20(%edx),%eax
  10255e:	c1 e8 18             	shr    $0x18,%eax
  return 0;
}
  102561:	c9                   	leave  
  102562:	c3                   	ret    
  102563:	90                   	nop
  102564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
    static int n;
    if(n++ == 0)
      cprintf("cpu called from %x with interrupts enabled\n",
  102568:	8b 45 04             	mov    0x4(%ebp),%eax
  10256b:	c7 04 24 b0 69 10 00 	movl   $0x1069b0,(%esp)
  102572:	89 44 24 04          	mov    %eax,0x4(%esp)
  102576:	e8 b5 df ff ff       	call   100530 <cprintf>
  10257b:	eb d2                	jmp    10254f <cpunum+0x1f>
  10257d:	8d 76 00             	lea    0x0(%esi),%esi

00102580 <lapicinit>:
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(int c)
{
  102580:	55                   	push   %ebp
  102581:	89 e5                	mov    %esp,%ebp
  102583:	83 ec 18             	sub    $0x18,%esp
  cprintf("lapicinit: %d 0x%x\n", c, lapic);
  102586:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10258b:	c7 04 24 dc 69 10 00 	movl   $0x1069dc,(%esp)
  102592:	89 44 24 08          	mov    %eax,0x8(%esp)
  102596:	8b 45 08             	mov    0x8(%ebp),%eax
  102599:	89 44 24 04          	mov    %eax,0x4(%esp)
  10259d:	e8 8e df ff ff       	call   100530 <cprintf>
  if(!lapic) 
  1025a2:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025a7:	85 c0                	test   %eax,%eax
  1025a9:	0f 84 0a 01 00 00    	je     1026b9 <lapicinit+0x139>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025af:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
  1025b6:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1025b9:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025be:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025c1:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
  1025c8:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1025cb:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025d0:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025d3:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
  1025da:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
  1025dd:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025e2:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025e5:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
  1025ec:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
  1025ef:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025f4:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025f7:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
  1025fe:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  102601:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102606:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102609:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
  102610:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  102613:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102618:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
  10261b:	8b 50 30             	mov    0x30(%eax),%edx
  10261e:	c1 ea 10             	shr    $0x10,%edx
  102621:	80 fa 03             	cmp    $0x3,%dl
  102624:	0f 87 96 00 00 00    	ja     1026c0 <lapicinit+0x140>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10262a:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
  102631:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102634:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102639:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10263c:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  102643:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102646:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10264b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10264e:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  102655:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102658:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10265d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102660:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  102667:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10266a:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10266f:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102672:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
  102679:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10267c:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102681:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102684:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
  10268b:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
  10268e:	8b 0d f8 ba 10 00    	mov    0x10baf8,%ecx
  102694:	8b 41 20             	mov    0x20(%ecx),%eax
  102697:	8d 91 00 03 00 00    	lea    0x300(%ecx),%edx
  10269d:	8d 76 00             	lea    0x0(%esi),%esi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
  1026a0:	8b 02                	mov    (%edx),%eax
  1026a2:	f6 c4 10             	test   $0x10,%ah
  1026a5:	75 f9                	jne    1026a0 <lapicinit+0x120>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026a7:	c7 81 80 00 00 00 00 	movl   $0x0,0x80(%ecx)
  1026ae:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026b1:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026b6:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
  1026b9:	c9                   	leave  
  1026ba:	c3                   	ret    
  1026bb:	90                   	nop
  1026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026c0:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
  1026c7:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  1026ca:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026cf:	8b 50 20             	mov    0x20(%eax),%edx
  1026d2:	e9 53 ff ff ff       	jmp    10262a <lapicinit+0xaa>
  1026d7:	90                   	nop
  1026d8:	90                   	nop
  1026d9:	90                   	nop
  1026da:	90                   	nop
  1026db:	90                   	nop
  1026dc:	90                   	nop
  1026dd:	90                   	nop
  1026de:	90                   	nop
  1026df:	90                   	nop

001026e0 <mpmain>:
// Common CPU setup code.
// Bootstrap CPU comes here from mainc().
// Other CPUs jump here from bootother.S.
static void
mpmain(void)
{
  1026e0:	55                   	push   %ebp
  1026e1:	89 e5                	mov    %esp,%ebp
  1026e3:	53                   	push   %ebx
  1026e4:	83 ec 14             	sub    $0x14,%esp
  if(cpunum() != mpbcpu()){
  1026e7:	e8 44 fe ff ff       	call   102530 <cpunum>
  1026ec:	89 c3                	mov    %eax,%ebx
  1026ee:	e8 ed 01 00 00       	call   1028e0 <mpbcpu>
  1026f3:	39 c3                	cmp    %eax,%ebx
  1026f5:	74 16                	je     10270d <mpmain+0x2d>
    seginit();
  1026f7:	e8 84 3d 00 00       	call   106480 <seginit>
  1026fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    lapicinit(cpunum());
  102700:	e8 2b fe ff ff       	call   102530 <cpunum>
  102705:	89 04 24             	mov    %eax,(%esp)
  102708:	e8 73 fe ff ff       	call   102580 <lapicinit>
  }
  vmenable();        // turn on paging
  10270d:	e8 2e 36 00 00       	call   105d40 <vmenable>
  cprintf("cpu%d: starting\n", cpu->id);
  102712:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  102718:	0f b6 00             	movzbl (%eax),%eax
  10271b:	c7 04 24 f0 69 10 00 	movl   $0x1069f0,(%esp)
  102722:	89 44 24 04          	mov    %eax,0x4(%esp)
  102726:	e8 05 de ff ff       	call   100530 <cprintf>
  idtinit();       // load idt register
  10272b:	e8 20 27 00 00       	call   104e50 <idtinit>
  xchg(&cpu->booted, 1); // tell bootothers() we're up
  102730:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  102737:	b8 01 00 00 00       	mov    $0x1,%eax
  10273c:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler();     // start running processes
  102743:	e8 18 0c 00 00       	call   103360 <scheduler>
  102748:	90                   	nop
  102749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102750 <mainc>:

// Set up hardware and software.
// Runs only on the boostrap processor.
void
mainc(void)
{
  102750:	55                   	push   %ebp
  102751:	89 e5                	mov    %esp,%ebp
  102753:	53                   	push   %ebx
  102754:	83 ec 14             	sub    $0x14,%esp
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  102757:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10275d:	0f b6 00             	movzbl (%eax),%eax
  102760:	c7 04 24 01 6a 10 00 	movl   $0x106a01,(%esp)
  102767:	89 44 24 04          	mov    %eax,0x4(%esp)
  10276b:	e8 c0 dd ff ff       	call   100530 <cprintf>
  picinit();       // interrupt controller
  102770:	e8 4b 04 00 00       	call   102bc0 <picinit>
  ioapicinit();    // another interrupt controller
  102775:	e8 16 fa ff ff       	call   102190 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
  10277a:	e8 e1 da ff ff       	call   100260 <consoleinit>
  10277f:	90                   	nop
  uartinit();      // serial port
  102780:	e8 8b 2a 00 00       	call   105210 <uartinit>
  kvmalloc();      // initialize the kernel page table
  102785:	e8 36 38 00 00       	call   105fc0 <kvmalloc>
  pinit();         // process table
  10278a:	e8 f1 11 00 00       	call   103980 <pinit>
  10278f:	90                   	nop
  tvinit();        // trap vectors
  102790:	e8 4b 29 00 00       	call   1050e0 <tvinit>
  binit();         // buffer cache
  102795:	e8 56 da ff ff       	call   1001f0 <binit>
  fileinit();      // file table
  10279a:	e8 c1 e8 ff ff       	call   101060 <fileinit>
  10279f:	90                   	nop
  iinit();         // inode cache
  1027a0:	e8 cb f6 ff ff       	call   101e70 <iinit>
  ideinit();       // disk
  1027a5:	e8 06 f9 ff ff       	call   1020b0 <ideinit>
  if(!ismp)
  1027aa:	a1 04 bb 10 00       	mov    0x10bb04,%eax
  1027af:	85 c0                	test   %eax,%eax
  1027b1:	0f 84 ae 00 00 00    	je     102865 <mainc+0x115>
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  1027b7:	e8 d4 10 00 00       	call   103890 <userinit>

  // Write bootstrap code to unused memory at 0x7000.
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);
  1027bc:	c7 44 24 08 6a 00 00 	movl   $0x6a,0x8(%esp)
  1027c3:	00 
  1027c4:	c7 44 24 04 9c 77 10 	movl   $0x10779c,0x4(%esp)
  1027cb:	00 
  1027cc:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
  1027d3:	e8 78 14 00 00       	call   103c50 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
  1027d8:	69 05 00 c1 10 00 bc 	imul   $0xbc,0x10c100,%eax
  1027df:	00 00 00 
  1027e2:	05 20 bb 10 00       	add    $0x10bb20,%eax
  1027e7:	3d 20 bb 10 00       	cmp    $0x10bb20,%eax
  1027ec:	76 6d                	jbe    10285b <mainc+0x10b>
  1027ee:	bb 20 bb 10 00       	mov    $0x10bb20,%ebx
  1027f3:	90                   	nop
  1027f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(c == cpus+cpunum())  // We've started already.
  1027f8:	e8 33 fd ff ff       	call   102530 <cpunum>
  1027fd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  102803:	05 20 bb 10 00       	add    $0x10bb20,%eax
  102808:	39 c3                	cmp    %eax,%ebx
  10280a:	74 36                	je     102842 <mainc+0xf2>
      continue;

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
  10280c:	e8 3f fa ff ff       	call   102250 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpmain;
  102811:	c7 05 f8 6f 00 00 e0 	movl   $0x1026e0,0x6ff8
  102818:	26 10 00 

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
    *(void**)(code-4) = stack + KSTACKSIZE;
  10281b:	05 00 10 00 00       	add    $0x1000,%eax
  102820:	a3 fc 6f 00 00       	mov    %eax,0x6ffc
    *(void**)(code-8) = mpmain;

    lapicstartap(c->id, (uint)code);
  102825:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
  10282c:	00 
  10282d:	0f b6 03             	movzbl (%ebx),%eax
  102830:	89 04 24             	mov    %eax,(%esp)
  102833:	e8 48 fc ff ff       	call   102480 <lapicstartap>

    // Wait for cpu to finish mpmain()
    while(c->booted == 0)
  102838:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
  10283e:	85 c0                	test   %eax,%eax
  102840:	74 f6                	je     102838 <mainc+0xe8>
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);

  for(c = cpus; c < cpus+ncpu; c++){
  102842:	69 05 00 c1 10 00 bc 	imul   $0xbc,0x10c100,%eax
  102849:	00 00 00 
  10284c:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
  102852:	05 20 bb 10 00       	add    $0x10bb20,%eax
  102857:	39 c3                	cmp    %eax,%ebx
  102859:	72 9d                	jb     1027f8 <mainc+0xa8>
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
}
  10285b:	83 c4 14             	add    $0x14,%esp
  10285e:	5b                   	pop    %ebx
  10285f:	5d                   	pop    %ebp
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
  102860:	e9 7b fe ff ff       	jmp    1026e0 <mpmain>
  binit();         // buffer cache
  fileinit();      // file table
  iinit();         // inode cache
  ideinit();       // disk
  if(!ismp)
    timerinit();   // uniprocessor timer
  102865:	e8 86 25 00 00       	call   104df0 <timerinit>
  10286a:	e9 48 ff ff ff       	jmp    1027b7 <mainc+0x67>
  10286f:	90                   	nop

00102870 <jmpkstack>:
  jmpkstack();       // call mainc() on a properly-allocated stack 
}

void
jmpkstack(void)
{
  102870:	55                   	push   %ebp
  102871:	89 e5                	mov    %esp,%ebp
  102873:	83 ec 18             	sub    $0x18,%esp
  char *kstack, *top;
  
  kstack = kalloc();
  102876:	e8 d5 f9 ff ff       	call   102250 <kalloc>
  if(kstack == 0)
  10287b:	85 c0                	test   %eax,%eax
  10287d:	74 19                	je     102898 <jmpkstack+0x28>
    panic("jmpkstack kalloc");
  top = kstack + PGSIZE;
  asm volatile("movl %0,%%esp; call mainc" : : "r" (top));
  10287f:	05 00 10 00 00       	add    $0x1000,%eax
  102884:	89 c4                	mov    %eax,%esp
  102886:	e8 c5 fe ff ff       	call   102750 <mainc>
  panic("jmpkstack");
  10288b:	c7 04 24 29 6a 10 00 	movl   $0x106a29,(%esp)
  102892:	e8 89 e0 ff ff       	call   100920 <panic>
  102897:	90                   	nop
{
  char *kstack, *top;
  
  kstack = kalloc();
  if(kstack == 0)
    panic("jmpkstack kalloc");
  102898:	c7 04 24 18 6a 10 00 	movl   $0x106a18,(%esp)
  10289f:	e8 7c e0 ff ff       	call   100920 <panic>
  1028a4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1028aa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001028b0 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
  1028b0:	55                   	push   %ebp
  1028b1:	89 e5                	mov    %esp,%ebp
  1028b3:	83 e4 f0             	and    $0xfffffff0,%esp
  1028b6:	83 ec 10             	sub    $0x10,%esp
  mpinit();        // collect info about this machine
  1028b9:	e8 b2 00 00 00       	call   102970 <mpinit>
  lapicinit(mpbcpu());
  1028be:	e8 1d 00 00 00       	call   1028e0 <mpbcpu>
  1028c3:	89 04 24             	mov    %eax,(%esp)
  1028c6:	e8 b5 fc ff ff       	call   102580 <lapicinit>
  seginit();       // set up segments
  1028cb:	e8 b0 3b 00 00       	call   106480 <seginit>
  kinit();         // initialize memory allocator
  1028d0:	e8 2b fa ff ff       	call   102300 <kinit>
  jmpkstack();       // call mainc() on a properly-allocated stack 
  1028d5:	e8 96 ff ff ff       	call   102870 <jmpkstack>
  1028da:	90                   	nop
  1028db:	90                   	nop
  1028dc:	90                   	nop
  1028dd:	90                   	nop
  1028de:	90                   	nop
  1028df:	90                   	nop

001028e0 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  1028e0:	a1 c4 78 10 00       	mov    0x1078c4,%eax
  1028e5:	55                   	push   %ebp
  1028e6:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
}
  1028e8:	5d                   	pop    %ebp
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  1028e9:	2d 20 bb 10 00       	sub    $0x10bb20,%eax
  1028ee:	c1 f8 02             	sar    $0x2,%eax
  1028f1:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
  return bcpu-cpus;
}
  1028f7:	c3                   	ret    
  1028f8:	90                   	nop
  1028f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102900 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102900:	55                   	push   %ebp
  102901:	89 e5                	mov    %esp,%ebp
  102903:	56                   	push   %esi
  102904:	53                   	push   %ebx
  uchar *e, *p;

  e = addr+len;
  102905:	8d 34 10             	lea    (%eax,%edx,1),%esi
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102908:	83 ec 10             	sub    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  10290b:	39 f0                	cmp    %esi,%eax
  10290d:	73 42                	jae    102951 <mpsearch1+0x51>
  10290f:	89 c3                	mov    %eax,%ebx
  102911:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  102918:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  10291f:	00 
  102920:	c7 44 24 04 33 6a 10 	movl   $0x106a33,0x4(%esp)
  102927:	00 
  102928:	89 1c 24             	mov    %ebx,(%esp)
  10292b:	e8 c0 12 00 00       	call   103bf0 <memcmp>
  102930:	85 c0                	test   %eax,%eax
  102932:	75 16                	jne    10294a <mpsearch1+0x4a>
  102934:	31 d2                	xor    %edx,%edx
  102936:	66 90                	xchg   %ax,%ax
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
  102938:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  10293c:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  10293f:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102941:	83 f8 10             	cmp    $0x10,%eax
  102944:	75 f2                	jne    102938 <mpsearch1+0x38>
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  102946:	84 d2                	test   %dl,%dl
  102948:	74 10                	je     10295a <mpsearch1+0x5a>
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  10294a:	83 c3 10             	add    $0x10,%ebx
  10294d:	39 de                	cmp    %ebx,%esi
  10294f:	77 c7                	ja     102918 <mpsearch1+0x18>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  102951:	83 c4 10             	add    $0x10,%esp
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  102954:	31 c0                	xor    %eax,%eax
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  102956:	5b                   	pop    %ebx
  102957:	5e                   	pop    %esi
  102958:	5d                   	pop    %ebp
  102959:	c3                   	ret    
  10295a:	83 c4 10             	add    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  10295d:	89 d8                	mov    %ebx,%eax
  return 0;
}
  10295f:	5b                   	pop    %ebx
  102960:	5e                   	pop    %esi
  102961:	5d                   	pop    %ebp
  102962:	c3                   	ret    
  102963:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  102969:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102970 <mpinit>:
  return conf;
}

void
mpinit(void)
{
  102970:	55                   	push   %ebp
  102971:	89 e5                	mov    %esp,%ebp
  102973:	57                   	push   %edi
  102974:	56                   	push   %esi
  102975:	53                   	push   %ebx
  102976:	83 ec 1c             	sub    $0x1c,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  102979:	0f b6 05 0f 04 00 00 	movzbl 0x40f,%eax
  102980:	0f b6 15 0e 04 00 00 	movzbl 0x40e,%edx
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  102987:	c7 05 c4 78 10 00 20 	movl   $0x10bb20,0x1078c4
  10298e:	bb 10 00 
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  102991:	c1 e0 08             	shl    $0x8,%eax
  102994:	09 d0                	or     %edx,%eax
  102996:	c1 e0 04             	shl    $0x4,%eax
  102999:	85 c0                	test   %eax,%eax
  10299b:	75 1b                	jne    1029b8 <mpinit+0x48>
    if((mp = mpsearch1((uchar*)p, 1024)))
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
  10299d:	0f b6 05 14 04 00 00 	movzbl 0x414,%eax
  1029a4:	0f b6 15 13 04 00 00 	movzbl 0x413,%edx
  1029ab:	c1 e0 08             	shl    $0x8,%eax
  1029ae:	09 d0                	or     %edx,%eax
  1029b0:	c1 e0 0a             	shl    $0xa,%eax
  1029b3:	2d 00 04 00 00       	sub    $0x400,%eax
  1029b8:	ba 00 04 00 00       	mov    $0x400,%edx
  1029bd:	e8 3e ff ff ff       	call   102900 <mpsearch1>
  1029c2:	85 c0                	test   %eax,%eax
  1029c4:	89 c6                	mov    %eax,%esi
  1029c6:	0f 84 94 01 00 00    	je     102b60 <mpinit+0x1f0>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  1029cc:	8b 5e 04             	mov    0x4(%esi),%ebx
  1029cf:	85 db                	test   %ebx,%ebx
  1029d1:	74 1c                	je     1029ef <mpinit+0x7f>
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
  1029d3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  1029da:	00 
  1029db:	c7 44 24 04 38 6a 10 	movl   $0x106a38,0x4(%esp)
  1029e2:	00 
  1029e3:	89 1c 24             	mov    %ebx,(%esp)
  1029e6:	e8 05 12 00 00       	call   103bf0 <memcmp>
  1029eb:	85 c0                	test   %eax,%eax
  1029ed:	74 09                	je     1029f8 <mpinit+0x88>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  1029ef:	83 c4 1c             	add    $0x1c,%esp
  1029f2:	5b                   	pop    %ebx
  1029f3:	5e                   	pop    %esi
  1029f4:	5f                   	pop    %edi
  1029f5:	5d                   	pop    %ebp
  1029f6:	c3                   	ret    
  1029f7:	90                   	nop
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
  1029f8:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
  1029fc:	3c 04                	cmp    $0x4,%al
  1029fe:	74 04                	je     102a04 <mpinit+0x94>
  102a00:	3c 01                	cmp    $0x1,%al
  102a02:	75 eb                	jne    1029ef <mpinit+0x7f>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102a04:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a08:	85 ff                	test   %edi,%edi
  102a0a:	74 15                	je     102a21 <mpinit+0xb1>
  102a0c:	31 d2                	xor    %edx,%edx
  102a0e:	31 c0                	xor    %eax,%eax
    sum += addr[i];
  102a10:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a14:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  102a17:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a19:	39 c7                	cmp    %eax,%edi
  102a1b:	7f f3                	jg     102a10 <mpinit+0xa0>
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102a1d:	84 d2                	test   %dl,%dl
  102a1f:	75 ce                	jne    1029ef <mpinit+0x7f>
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  102a21:	c7 05 04 bb 10 00 01 	movl   $0x1,0x10bb04
  102a28:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
  102a2b:	8b 43 24             	mov    0x24(%ebx),%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a2e:	8d 7b 2c             	lea    0x2c(%ebx),%edi

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  102a31:	a3 f8 ba 10 00       	mov    %eax,0x10baf8
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a36:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
  102a3a:	01 c3                	add    %eax,%ebx
  102a3c:	39 df                	cmp    %ebx,%edi
  102a3e:	72 29                	jb     102a69 <mpinit+0xf9>
  102a40:	eb 52                	jmp    102a94 <mpinit+0x124>
  102a42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case MPIOINTR:
    case MPLINTR:
      p += 8;
      continue;
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
  102a48:	0f b6 c0             	movzbl %al,%eax
  102a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102a4f:	c7 04 24 58 6a 10 00 	movl   $0x106a58,(%esp)
  102a56:	e8 d5 da ff ff       	call   100530 <cprintf>
      ismp = 0;
  102a5b:	c7 05 04 bb 10 00 00 	movl   $0x0,0x10bb04
  102a62:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a65:	39 fb                	cmp    %edi,%ebx
  102a67:	76 1e                	jbe    102a87 <mpinit+0x117>
    switch(*p){
  102a69:	0f b6 07             	movzbl (%edi),%eax
  102a6c:	3c 04                	cmp    $0x4,%al
  102a6e:	77 d8                	ja     102a48 <mpinit+0xd8>
  102a70:	0f b6 c0             	movzbl %al,%eax
  102a73:	ff 24 85 78 6a 10 00 	jmp    *0x106a78(,%eax,4)
  102a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
  102a80:	83 c7 08             	add    $0x8,%edi
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a83:	39 fb                	cmp    %edi,%ebx
  102a85:	77 e2                	ja     102a69 <mpinit+0xf9>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
  102a87:	a1 04 bb 10 00       	mov    0x10bb04,%eax
  102a8c:	85 c0                	test   %eax,%eax
  102a8e:	0f 84 a4 00 00 00    	je     102b38 <mpinit+0x1c8>
    lapic = 0;
    ioapicid = 0;
    return;
  }

  if(mp->imcrp){
  102a94:	80 7e 0c 00          	cmpb   $0x0,0xc(%esi)
  102a98:	0f 84 51 ff ff ff    	je     1029ef <mpinit+0x7f>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102a9e:	ba 22 00 00 00       	mov    $0x22,%edx
  102aa3:	b8 70 00 00 00       	mov    $0x70,%eax
  102aa8:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102aa9:	b2 23                	mov    $0x23,%dl
  102aab:	ec                   	in     (%dx),%al
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102aac:	83 c8 01             	or     $0x1,%eax
  102aaf:	ee                   	out    %al,(%dx)
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102ab0:	83 c4 1c             	add    $0x1c,%esp
  102ab3:	5b                   	pop    %ebx
  102ab4:	5e                   	pop    %esi
  102ab5:	5f                   	pop    %edi
  102ab6:	5d                   	pop    %ebp
  102ab7:	c3                   	ret    
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu != proc->apicid){
  102ab8:	0f b6 57 01          	movzbl 0x1(%edi),%edx
  102abc:	a1 00 c1 10 00       	mov    0x10c100,%eax
  102ac1:	39 c2                	cmp    %eax,%edx
  102ac3:	74 23                	je     102ae8 <mpinit+0x178>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
  102ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ac9:	89 54 24 08          	mov    %edx,0x8(%esp)
  102acd:	c7 04 24 3d 6a 10 00 	movl   $0x106a3d,(%esp)
  102ad4:	e8 57 da ff ff       	call   100530 <cprintf>
        ismp = 0;
  102ad9:	a1 00 c1 10 00       	mov    0x10c100,%eax
  102ade:	c7 05 04 bb 10 00 00 	movl   $0x0,0x10bb04
  102ae5:	00 00 00 
      }
      if(proc->flags & MPBOOT)
  102ae8:	f6 47 03 02          	testb  $0x2,0x3(%edi)
  102aec:	74 12                	je     102b00 <mpinit+0x190>
        bcpu = &cpus[ncpu];
  102aee:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
  102af4:	81 c2 20 bb 10 00    	add    $0x10bb20,%edx
  102afa:	89 15 c4 78 10 00    	mov    %edx,0x1078c4
      cpus[ncpu].id = ncpu;
  102b00:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
      ncpu++;
      p += sizeof(struct mpproc);
  102b06:	83 c7 14             	add    $0x14,%edi
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
        ismp = 0;
      }
      if(proc->flags & MPBOOT)
        bcpu = &cpus[ncpu];
      cpus[ncpu].id = ncpu;
  102b09:	88 82 20 bb 10 00    	mov    %al,0x10bb20(%edx)
      ncpu++;
  102b0f:	83 c0 01             	add    $0x1,%eax
  102b12:	a3 00 c1 10 00       	mov    %eax,0x10c100
      p += sizeof(struct mpproc);
      continue;
  102b17:	e9 49 ff ff ff       	jmp    102a65 <mpinit+0xf5>
  102b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102b20:	0f b6 47 01          	movzbl 0x1(%edi),%eax
      p += sizeof(struct mpioapic);
  102b24:	83 c7 08             	add    $0x8,%edi
      ncpu++;
      p += sizeof(struct mpproc);
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102b27:	a2 00 bb 10 00       	mov    %al,0x10bb00
      p += sizeof(struct mpioapic);
      continue;
  102b2c:	e9 34 ff ff ff       	jmp    102a65 <mpinit+0xf5>
  102b31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ismp = 0;
    }
  }
  if(!ismp){
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
  102b38:	c7 05 00 c1 10 00 01 	movl   $0x1,0x10c100
  102b3f:	00 00 00 
    lapic = 0;
  102b42:	c7 05 f8 ba 10 00 00 	movl   $0x0,0x10baf8
  102b49:	00 00 00 
    ioapicid = 0;
  102b4c:	c6 05 00 bb 10 00 00 	movb   $0x0,0x10bb00
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102b53:	83 c4 1c             	add    $0x1c,%esp
  102b56:	5b                   	pop    %ebx
  102b57:	5e                   	pop    %esi
  102b58:	5f                   	pop    %edi
  102b59:	5d                   	pop    %ebp
  102b5a:	c3                   	ret    
  102b5b:	90                   	nop
  102b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102b60:	ba 00 00 01 00       	mov    $0x10000,%edx
  102b65:	b8 00 00 0f 00       	mov    $0xf0000,%eax
  102b6a:	e8 91 fd ff ff       	call   102900 <mpsearch1>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102b6f:	85 c0                	test   %eax,%eax
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102b71:	89 c6                	mov    %eax,%esi
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102b73:	0f 85 53 fe ff ff    	jne    1029cc <mpinit+0x5c>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102b79:	83 c4 1c             	add    $0x1c,%esp
  102b7c:	5b                   	pop    %ebx
  102b7d:	5e                   	pop    %esi
  102b7e:	5f                   	pop    %edi
  102b7f:	5d                   	pop    %ebp
  102b80:	c3                   	ret    
  102b81:	90                   	nop
  102b82:	90                   	nop
  102b83:	90                   	nop
  102b84:	90                   	nop
  102b85:	90                   	nop
  102b86:	90                   	nop
  102b87:	90                   	nop
  102b88:	90                   	nop
  102b89:	90                   	nop
  102b8a:	90                   	nop
  102b8b:	90                   	nop
  102b8c:	90                   	nop
  102b8d:	90                   	nop
  102b8e:	90                   	nop
  102b8f:	90                   	nop

00102b90 <picenable>:
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102b90:	55                   	push   %ebp
  picsetmask(irqmask & ~(1<<irq));
  102b91:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102b96:	89 e5                	mov    %esp,%ebp
  102b98:	ba 21 00 00 00       	mov    $0x21,%edx
  picsetmask(irqmask & ~(1<<irq));
  102b9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102ba0:	d3 c0                	rol    %cl,%eax
  102ba2:	66 23 05 20 73 10 00 	and    0x107320,%ax
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
  irqmask = mask;
  102ba9:	66 a3 20 73 10 00    	mov    %ax,0x107320
  102baf:	ee                   	out    %al,(%dx)
  102bb0:	66 c1 e8 08          	shr    $0x8,%ax
  102bb4:	b2 a1                	mov    $0xa1,%dl
  102bb6:	ee                   	out    %al,(%dx)

void
picenable(int irq)
{
  picsetmask(irqmask & ~(1<<irq));
}
  102bb7:	5d                   	pop    %ebp
  102bb8:	c3                   	ret    
  102bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102bc0 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
  102bc0:	55                   	push   %ebp
  102bc1:	b9 21 00 00 00       	mov    $0x21,%ecx
  102bc6:	89 e5                	mov    %esp,%ebp
  102bc8:	83 ec 0c             	sub    $0xc,%esp
  102bcb:	89 1c 24             	mov    %ebx,(%esp)
  102bce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102bd3:	89 ca                	mov    %ecx,%edx
  102bd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  102bd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  102bdd:	ee                   	out    %al,(%dx)
  102bde:	bb a1 00 00 00       	mov    $0xa1,%ebx
  102be3:	89 da                	mov    %ebx,%edx
  102be5:	ee                   	out    %al,(%dx)
  102be6:	be 11 00 00 00       	mov    $0x11,%esi
  102beb:	b2 20                	mov    $0x20,%dl
  102bed:	89 f0                	mov    %esi,%eax
  102bef:	ee                   	out    %al,(%dx)
  102bf0:	b8 20 00 00 00       	mov    $0x20,%eax
  102bf5:	89 ca                	mov    %ecx,%edx
  102bf7:	ee                   	out    %al,(%dx)
  102bf8:	b8 04 00 00 00       	mov    $0x4,%eax
  102bfd:	ee                   	out    %al,(%dx)
  102bfe:	bf 03 00 00 00       	mov    $0x3,%edi
  102c03:	89 f8                	mov    %edi,%eax
  102c05:	ee                   	out    %al,(%dx)
  102c06:	b1 a0                	mov    $0xa0,%cl
  102c08:	89 f0                	mov    %esi,%eax
  102c0a:	89 ca                	mov    %ecx,%edx
  102c0c:	ee                   	out    %al,(%dx)
  102c0d:	b8 28 00 00 00       	mov    $0x28,%eax
  102c12:	89 da                	mov    %ebx,%edx
  102c14:	ee                   	out    %al,(%dx)
  102c15:	b8 02 00 00 00       	mov    $0x2,%eax
  102c1a:	ee                   	out    %al,(%dx)
  102c1b:	89 f8                	mov    %edi,%eax
  102c1d:	ee                   	out    %al,(%dx)
  102c1e:	be 68 00 00 00       	mov    $0x68,%esi
  102c23:	b2 20                	mov    $0x20,%dl
  102c25:	89 f0                	mov    %esi,%eax
  102c27:	ee                   	out    %al,(%dx)
  102c28:	bb 0a 00 00 00       	mov    $0xa,%ebx
  102c2d:	89 d8                	mov    %ebx,%eax
  102c2f:	ee                   	out    %al,(%dx)
  102c30:	89 f0                	mov    %esi,%eax
  102c32:	89 ca                	mov    %ecx,%edx
  102c34:	ee                   	out    %al,(%dx)
  102c35:	89 d8                	mov    %ebx,%eax
  102c37:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);             // read IRR by default

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
  102c38:	0f b7 05 20 73 10 00 	movzwl 0x107320,%eax
  102c3f:	66 83 f8 ff          	cmp    $0xffffffff,%ax
  102c43:	74 0a                	je     102c4f <picinit+0x8f>
  102c45:	b2 21                	mov    $0x21,%dl
  102c47:	ee                   	out    %al,(%dx)
  102c48:	66 c1 e8 08          	shr    $0x8,%ax
  102c4c:	b2 a1                	mov    $0xa1,%dl
  102c4e:	ee                   	out    %al,(%dx)
    picsetmask(irqmask);
}
  102c4f:	8b 1c 24             	mov    (%esp),%ebx
  102c52:	8b 74 24 04          	mov    0x4(%esp),%esi
  102c56:	8b 7c 24 08          	mov    0x8(%esp),%edi
  102c5a:	89 ec                	mov    %ebp,%esp
  102c5c:	5d                   	pop    %ebp
  102c5d:	c3                   	ret    
  102c5e:	90                   	nop
  102c5f:	90                   	nop

00102c60 <piperead>:
  return n;
}

int
piperead(struct pipe *p, char *addr, int n)
{
  102c60:	55                   	push   %ebp
  102c61:	89 e5                	mov    %esp,%ebp
  102c63:	57                   	push   %edi
  102c64:	56                   	push   %esi
  102c65:	53                   	push   %ebx
  102c66:	83 ec 1c             	sub    $0x1c,%esp
  102c69:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102c6c:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  acquire(&p->lock);
  102c6f:	89 1c 24             	mov    %ebx,(%esp)
  102c72:	e8 b9 0e 00 00       	call   103b30 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102c77:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102c7d:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102c83:	75 58                	jne    102cdd <piperead+0x7d>
  102c85:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102c8b:	85 f6                	test   %esi,%esi
  102c8d:	74 4e                	je     102cdd <piperead+0x7d>
    if(proc->killed){
  102c8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102c95:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
  102c9b:	8b 48 24             	mov    0x24(%eax),%ecx
  102c9e:	85 c9                	test   %ecx,%ecx
  102ca0:	74 21                	je     102cc3 <piperead+0x63>
  102ca2:	e9 99 00 00 00       	jmp    102d40 <piperead+0xe0>
  102ca7:	90                   	nop
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102ca8:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
  102cae:	85 c0                	test   %eax,%eax
  102cb0:	74 2b                	je     102cdd <piperead+0x7d>
    if(proc->killed){
  102cb2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102cb8:	8b 50 24             	mov    0x24(%eax),%edx
  102cbb:	85 d2                	test   %edx,%edx
  102cbd:	0f 85 7d 00 00 00    	jne    102d40 <piperead+0xe0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102cc3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102cc7:	89 34 24             	mov    %esi,(%esp)
  102cca:	e8 81 05 00 00       	call   103250 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102ccf:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102cd5:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102cdb:	74 cb                	je     102ca8 <piperead+0x48>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102cdd:	85 ff                	test   %edi,%edi
  102cdf:	7e 76                	jle    102d57 <piperead+0xf7>
    if(p->nread == p->nwrite)
  102ce1:	31 f6                	xor    %esi,%esi
  102ce3:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102ce9:	75 0d                	jne    102cf8 <piperead+0x98>
  102ceb:	eb 6a                	jmp    102d57 <piperead+0xf7>
  102ced:	8d 76 00             	lea    0x0(%esi),%esi
  102cf0:	39 93 38 02 00 00    	cmp    %edx,0x238(%ebx)
  102cf6:	74 22                	je     102d1a <piperead+0xba>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102cf8:	89 d0                	mov    %edx,%eax
  102cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  102cfd:	83 c2 01             	add    $0x1,%edx
  102d00:	25 ff 01 00 00       	and    $0x1ff,%eax
  102d05:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
  102d0a:	88 04 31             	mov    %al,(%ecx,%esi,1)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d0d:	83 c6 01             	add    $0x1,%esi
  102d10:	39 f7                	cmp    %esi,%edi
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102d12:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d18:	7f d6                	jg     102cf0 <piperead+0x90>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  102d1a:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  102d20:	89 04 24             	mov    %eax,(%esp)
  102d23:	e8 08 04 00 00       	call   103130 <wakeup>
  release(&p->lock);
  102d28:	89 1c 24             	mov    %ebx,(%esp)
  102d2b:	e8 b0 0d 00 00       	call   103ae0 <release>
  return i;
}
  102d30:	83 c4 1c             	add    $0x1c,%esp
  102d33:	89 f0                	mov    %esi,%eax
  102d35:	5b                   	pop    %ebx
  102d36:	5e                   	pop    %esi
  102d37:	5f                   	pop    %edi
  102d38:	5d                   	pop    %ebp
  102d39:	c3                   	ret    
  102d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
      release(&p->lock);
  102d40:	be ff ff ff ff       	mov    $0xffffffff,%esi
  102d45:	89 1c 24             	mov    %ebx,(%esp)
  102d48:	e8 93 0d 00 00       	call   103ae0 <release>
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
  102d4d:	83 c4 1c             	add    $0x1c,%esp
  102d50:	89 f0                	mov    %esi,%eax
  102d52:	5b                   	pop    %ebx
  102d53:	5e                   	pop    %esi
  102d54:	5f                   	pop    %edi
  102d55:	5d                   	pop    %ebp
  102d56:	c3                   	ret    
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d57:	31 f6                	xor    %esi,%esi
  102d59:	eb bf                	jmp    102d1a <piperead+0xba>
  102d5b:	90                   	nop
  102d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00102d60 <pipewrite>:
    release(&p->lock);
}

int
pipewrite(struct pipe *p, char *addr, int n)
{
  102d60:	55                   	push   %ebp
  102d61:	89 e5                	mov    %esp,%ebp
  102d63:	57                   	push   %edi
  102d64:	56                   	push   %esi
  102d65:	53                   	push   %ebx
  102d66:	83 ec 3c             	sub    $0x3c,%esp
  102d69:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
  102d6c:	89 1c 24             	mov    %ebx,(%esp)
  102d6f:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
  102d75:	e8 b6 0d 00 00       	call   103b30 <acquire>
  for(i = 0; i < n; i++){
  102d7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  102d7d:	85 c9                	test   %ecx,%ecx
  102d7f:	0f 8e 8d 00 00 00    	jle    102e12 <pipewrite+0xb2>
  102d85:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102d8b:	8d bb 38 02 00 00    	lea    0x238(%ebx),%edi
  102d91:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  102d98:	eb 37                	jmp    102dd1 <pipewrite+0x71>
  102d9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
  102da0:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102da6:	85 c0                	test   %eax,%eax
  102da8:	74 7e                	je     102e28 <pipewrite+0xc8>
  102daa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102db0:	8b 50 24             	mov    0x24(%eax),%edx
  102db3:	85 d2                	test   %edx,%edx
  102db5:	75 71                	jne    102e28 <pipewrite+0xc8>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
  102db7:	89 34 24             	mov    %esi,(%esp)
  102dba:	e8 71 03 00 00       	call   103130 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102dbf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102dc3:	89 3c 24             	mov    %edi,(%esp)
  102dc6:	e8 85 04 00 00       	call   103250 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
  102dcb:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
  102dd1:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102dd7:	81 c2 00 02 00 00    	add    $0x200,%edx
  102ddd:	39 d0                	cmp    %edx,%eax
  102ddf:	74 bf                	je     102da0 <pipewrite+0x40>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  102de1:	89 c2                	mov    %eax,%edx
  102de3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102de6:	83 c0 01             	add    $0x1,%eax
  102de9:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  102def:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102df2:	8b 55 0c             	mov    0xc(%ebp),%edx
  102df5:	0f b6 0c 0a          	movzbl (%edx,%ecx,1),%ecx
  102df9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102dfc:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
  102e00:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
  102e06:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  102e0a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102e0d:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  102e10:	7f bf                	jg     102dd1 <pipewrite+0x71>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  102e12:	89 34 24             	mov    %esi,(%esp)
  102e15:	e8 16 03 00 00       	call   103130 <wakeup>
  release(&p->lock);
  102e1a:	89 1c 24             	mov    %ebx,(%esp)
  102e1d:	e8 be 0c 00 00       	call   103ae0 <release>
  return n;
  102e22:	eb 13                	jmp    102e37 <pipewrite+0xd7>
  102e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
  102e28:	89 1c 24             	mov    %ebx,(%esp)
  102e2b:	e8 b0 0c 00 00       	call   103ae0 <release>
  102e30:	c7 45 10 ff ff ff ff 	movl   $0xffffffff,0x10(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
  102e37:	8b 45 10             	mov    0x10(%ebp),%eax
  102e3a:	83 c4 3c             	add    $0x3c,%esp
  102e3d:	5b                   	pop    %ebx
  102e3e:	5e                   	pop    %esi
  102e3f:	5f                   	pop    %edi
  102e40:	5d                   	pop    %ebp
  102e41:	c3                   	ret    
  102e42:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  102e49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102e50 <pipeclose>:
  return -1;
}

void
pipeclose(struct pipe *p, int writable)
{
  102e50:	55                   	push   %ebp
  102e51:	89 e5                	mov    %esp,%ebp
  102e53:	83 ec 18             	sub    $0x18,%esp
  102e56:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  102e59:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102e5c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  102e5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
  102e62:	89 1c 24             	mov    %ebx,(%esp)
  102e65:	e8 c6 0c 00 00       	call   103b30 <acquire>
  if(writable){
  102e6a:	85 f6                	test   %esi,%esi
  102e6c:	74 42                	je     102eb0 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
  102e6e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
void
pipeclose(struct pipe *p, int writable)
{
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
  102e74:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
  102e7b:	00 00 00 
    wakeup(&p->nread);
  102e7e:	89 04 24             	mov    %eax,(%esp)
  102e81:	e8 aa 02 00 00       	call   103130 <wakeup>
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
  102e86:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102e8c:	85 c0                	test   %eax,%eax
  102e8e:	75 0a                	jne    102e9a <pipeclose+0x4a>
  102e90:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102e96:	85 f6                	test   %esi,%esi
  102e98:	74 36                	je     102ed0 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102e9a:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  102e9d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  102ea0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102ea3:	89 ec                	mov    %ebp,%esp
  102ea5:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102ea6:	e9 35 0c 00 00       	jmp    103ae0 <release>
  102eab:	90                   	nop
  102eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  102eb0:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
  102eb6:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
  102ebd:	00 00 00 
    wakeup(&p->nwrite);
  102ec0:	89 04 24             	mov    %eax,(%esp)
  102ec3:	e8 68 02 00 00       	call   103130 <wakeup>
  102ec8:	eb bc                	jmp    102e86 <pipeclose+0x36>
  102eca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
  102ed0:	89 1c 24             	mov    %ebx,(%esp)
  102ed3:	e8 08 0c 00 00       	call   103ae0 <release>
    kfree((char*)p);
  } else
    release(&p->lock);
}
  102ed8:	8b 75 fc             	mov    -0x4(%ebp),%esi
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102edb:	89 5d 08             	mov    %ebx,0x8(%ebp)
  } else
    release(&p->lock);
}
  102ede:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102ee1:	89 ec                	mov    %ebp,%esp
  102ee3:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102ee4:	e9 a7 f3 ff ff       	jmp    102290 <kfree>
  102ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102ef0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
  102ef0:	55                   	push   %ebp
  102ef1:	89 e5                	mov    %esp,%ebp
  102ef3:	57                   	push   %edi
  102ef4:	56                   	push   %esi
  102ef5:	53                   	push   %ebx
  102ef6:	83 ec 1c             	sub    $0x1c,%esp
  102ef9:	8b 75 08             	mov    0x8(%ebp),%esi
  102efc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
  102eff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  102f05:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
  102f0b:	e8 f0 df ff ff       	call   100f00 <filealloc>
  102f10:	85 c0                	test   %eax,%eax
  102f12:	89 06                	mov    %eax,(%esi)
  102f14:	0f 84 9c 00 00 00    	je     102fb6 <pipealloc+0xc6>
  102f1a:	e8 e1 df ff ff       	call   100f00 <filealloc>
  102f1f:	85 c0                	test   %eax,%eax
  102f21:	89 03                	mov    %eax,(%ebx)
  102f23:	0f 84 7f 00 00 00    	je     102fa8 <pipealloc+0xb8>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
  102f29:	e8 22 f3 ff ff       	call   102250 <kalloc>
  102f2e:	85 c0                	test   %eax,%eax
  102f30:	89 c7                	mov    %eax,%edi
  102f32:	74 74                	je     102fa8 <pipealloc+0xb8>
    goto bad;
  p->readopen = 1;
  102f34:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
  102f3b:	00 00 00 
  p->writeopen = 1;
  102f3e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
  102f45:	00 00 00 
  p->nwrite = 0;
  102f48:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
  102f4f:	00 00 00 
  p->nread = 0;
  102f52:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
  102f59:	00 00 00 
  initlock(&p->lock, "pipe");
  102f5c:	89 04 24             	mov    %eax,(%esp)
  102f5f:	c7 44 24 04 8c 6a 10 	movl   $0x106a8c,0x4(%esp)
  102f66:	00 
  102f67:	e8 34 0a 00 00       	call   1039a0 <initlock>
  (*f0)->type = FD_PIPE;
  102f6c:	8b 06                	mov    (%esi),%eax
  102f6e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
  102f74:	8b 06                	mov    (%esi),%eax
  102f76:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
  102f7a:	8b 06                	mov    (%esi),%eax
  102f7c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
  102f80:	8b 06                	mov    (%esi),%eax
  102f82:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
  102f85:	8b 03                	mov    (%ebx),%eax
  102f87:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
  102f8d:	8b 03                	mov    (%ebx),%eax
  102f8f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
  102f93:	8b 03                	mov    (%ebx),%eax
  102f95:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
  102f99:	8b 03                	mov    (%ebx),%eax
  102f9b:	89 78 0c             	mov    %edi,0xc(%eax)
  102f9e:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
  102fa0:	83 c4 1c             	add    $0x1c,%esp
  102fa3:	5b                   	pop    %ebx
  102fa4:	5e                   	pop    %esi
  102fa5:	5f                   	pop    %edi
  102fa6:	5d                   	pop    %ebp
  102fa7:	c3                   	ret    
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
  102fa8:	8b 06                	mov    (%esi),%eax
  102faa:	85 c0                	test   %eax,%eax
  102fac:	74 08                	je     102fb6 <pipealloc+0xc6>
    fileclose(*f0);
  102fae:	89 04 24             	mov    %eax,(%esp)
  102fb1:	e8 ca df ff ff       	call   100f80 <fileclose>
  if(*f1)
  102fb6:	8b 13                	mov    (%ebx),%edx
  102fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102fbd:	85 d2                	test   %edx,%edx
  102fbf:	74 df                	je     102fa0 <pipealloc+0xb0>
    fileclose(*f1);
  102fc1:	89 14 24             	mov    %edx,(%esp)
  102fc4:	e8 b7 df ff ff       	call   100f80 <fileclose>
  102fc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102fce:	eb d0                	jmp    102fa0 <pipealloc+0xb0>

00102fd0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  102fd0:	55                   	push   %ebp
  102fd1:	89 e5                	mov    %esp,%ebp
  102fd3:	57                   	push   %edi
  102fd4:	56                   	push   %esi
  102fd5:	53                   	push   %ebx

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
  102fd6:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
{
  102fdb:	83 ec 4c             	sub    $0x4c,%esp
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  102fde:	8d 7d c0             	lea    -0x40(%ebp),%edi
  102fe1:	eb 4b                	jmp    10302e <procdump+0x5e>
  102fe3:	90                   	nop
  102fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  102fe8:	8b 04 85 64 6b 10 00 	mov    0x106b64(,%eax,4),%eax
  102fef:	85 c0                	test   %eax,%eax
  102ff1:	74 47                	je     10303a <procdump+0x6a>
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
  102ff3:	8b 53 10             	mov    0x10(%ebx),%edx
  102ff6:	8d 4b 6c             	lea    0x6c(%ebx),%ecx
  102ff9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  102ffd:	89 44 24 08          	mov    %eax,0x8(%esp)
  103001:	c7 04 24 95 6a 10 00 	movl   $0x106a95,(%esp)
  103008:	89 54 24 04          	mov    %edx,0x4(%esp)
  10300c:	e8 1f d5 ff ff       	call   100530 <cprintf>
    if(p->state == SLEEPING){
  103011:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
  103015:	74 31                	je     103048 <procdump+0x78>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  103017:	c7 04 24 16 6a 10 00 	movl   $0x106a16,(%esp)
  10301e:	e8 0d d5 ff ff       	call   100530 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103023:	83 c3 7c             	add    $0x7c,%ebx
  103026:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  10302c:	74 5a                	je     103088 <procdump+0xb8>
    if(p->state == UNUSED)
  10302e:	8b 43 0c             	mov    0xc(%ebx),%eax
  103031:	85 c0                	test   %eax,%eax
  103033:	74 ee                	je     103023 <procdump+0x53>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  103035:	83 f8 05             	cmp    $0x5,%eax
  103038:	76 ae                	jbe    102fe8 <procdump+0x18>
  10303a:	b8 91 6a 10 00       	mov    $0x106a91,%eax
  10303f:	eb b2                	jmp    102ff3 <procdump+0x23>
  103041:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  103048:	8b 43 1c             	mov    0x1c(%ebx),%eax
  10304b:	31 f6                	xor    %esi,%esi
  10304d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  103051:	8b 40 0c             	mov    0xc(%eax),%eax
  103054:	83 c0 08             	add    $0x8,%eax
  103057:	89 04 24             	mov    %eax,(%esp)
  10305a:	e8 61 09 00 00       	call   1039c0 <getcallerpcs>
  10305f:	90                   	nop
      for(i=0; i<10 && pc[i] != 0; i++)
  103060:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  103063:	85 c0                	test   %eax,%eax
  103065:	74 b0                	je     103017 <procdump+0x47>
  103067:	83 c6 01             	add    $0x1,%esi
        cprintf(" %p", pc[i]);
  10306a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10306e:	c7 04 24 0a 66 10 00 	movl   $0x10660a,(%esp)
  103075:	e8 b6 d4 ff ff       	call   100530 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
  10307a:	83 fe 0a             	cmp    $0xa,%esi
  10307d:	75 e1                	jne    103060 <procdump+0x90>
  10307f:	eb 96                	jmp    103017 <procdump+0x47>
  103081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
  103088:	83 c4 4c             	add    $0x4c,%esp
  10308b:	5b                   	pop    %ebx
  10308c:	5e                   	pop    %esi
  10308d:	5f                   	pop    %edi
  10308e:	5d                   	pop    %ebp
  10308f:	90                   	nop
  103090:	c3                   	ret    
  103091:	eb 0d                	jmp    1030a0 <kill>
  103093:	90                   	nop
  103094:	90                   	nop
  103095:	90                   	nop
  103096:	90                   	nop
  103097:	90                   	nop
  103098:	90                   	nop
  103099:	90                   	nop
  10309a:	90                   	nop
  10309b:	90                   	nop
  10309c:	90                   	nop
  10309d:	90                   	nop
  10309e:	90                   	nop
  10309f:	90                   	nop

001030a0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  1030a0:	55                   	push   %ebp
  1030a1:	89 e5                	mov    %esp,%ebp
  1030a3:	53                   	push   %ebx
  1030a4:	83 ec 14             	sub    $0x14,%esp
  1030a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
  1030aa:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1030b1:	e8 7a 0a 00 00       	call   103b30 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  1030b6:	8b 15 64 c1 10 00    	mov    0x10c164,%edx

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
  1030bc:	b8 d0 c1 10 00       	mov    $0x10c1d0,%eax
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  1030c1:	39 da                	cmp    %ebx,%edx
  1030c3:	75 0d                	jne    1030d2 <kill+0x32>
  1030c5:	eb 60                	jmp    103127 <kill+0x87>
  1030c7:	90                   	nop
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1030c8:	83 c0 7c             	add    $0x7c,%eax
  1030cb:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  1030d0:	74 3e                	je     103110 <kill+0x70>
    if(p->pid == pid){
  1030d2:	8b 50 10             	mov    0x10(%eax),%edx
  1030d5:	39 da                	cmp    %ebx,%edx
  1030d7:	75 ef                	jne    1030c8 <kill+0x28>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  1030d9:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
  1030dd:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  1030e4:	74 1a                	je     103100 <kill+0x60>
        p->state = RUNNABLE;
      release(&ptable.lock);
  1030e6:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1030ed:	e8 ee 09 00 00       	call   103ae0 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  1030f2:	83 c4 14             	add    $0x14,%esp
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
  1030f5:	31 c0                	xor    %eax,%eax
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  1030f7:	5b                   	pop    %ebx
  1030f8:	5d                   	pop    %ebp
  1030f9:	c3                   	ret    
  1030fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
  103100:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  103107:	eb dd                	jmp    1030e6 <kill+0x46>
  103109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  103110:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103117:	e8 c4 09 00 00       	call   103ae0 <release>
  return -1;
}
  10311c:	83 c4 14             	add    $0x14,%esp
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  10311f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
  103124:	5b                   	pop    %ebx
  103125:	5d                   	pop    %ebp
  103126:	c3                   	ret    
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  103127:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  10312c:	eb ab                	jmp    1030d9 <kill+0x39>
  10312e:	66 90                	xchg   %ax,%ax

00103130 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  103130:	55                   	push   %ebp
  103131:	89 e5                	mov    %esp,%ebp
  103133:	53                   	push   %ebx
  103134:	83 ec 14             	sub    $0x14,%esp
  103137:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
  10313a:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103141:	e8 ea 09 00 00       	call   103b30 <acquire>
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
  103146:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  10314b:	eb 0d                	jmp    10315a <wakeup+0x2a>
  10314d:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103150:	83 c0 7c             	add    $0x7c,%eax
  103153:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  103158:	74 1e                	je     103178 <wakeup+0x48>
    if(p->state == SLEEPING && p->chan == chan)
  10315a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  10315e:	75 f0                	jne    103150 <wakeup+0x20>
  103160:	3b 58 20             	cmp    0x20(%eax),%ebx
  103163:	75 eb                	jne    103150 <wakeup+0x20>
      p->state = RUNNABLE;
  103165:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  10316c:	83 c0 7c             	add    $0x7c,%eax
  10316f:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  103174:	75 e4                	jne    10315a <wakeup+0x2a>
  103176:	66 90                	xchg   %ax,%ax
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  103178:	c7 45 08 20 c1 10 00 	movl   $0x10c120,0x8(%ebp)
}
  10317f:	83 c4 14             	add    $0x14,%esp
  103182:	5b                   	pop    %ebx
  103183:	5d                   	pop    %ebp
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  103184:	e9 57 09 00 00       	jmp    103ae0 <release>
  103189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103190 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  103190:	55                   	push   %ebp
  103191:	89 e5                	mov    %esp,%ebp
  103193:	83 ec 18             	sub    $0x18,%esp
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
  103196:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10319d:	e8 3e 09 00 00       	call   103ae0 <release>
  
  // Return to "caller", actually trapret (see allocproc).
}
  1031a2:	c9                   	leave  
  1031a3:	c3                   	ret    
  1031a4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1031aa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001031b0 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  1031b0:	55                   	push   %ebp
  1031b1:	89 e5                	mov    %esp,%ebp
  1031b3:	53                   	push   %ebx
  1031b4:	83 ec 14             	sub    $0x14,%esp
  int intena;

  if(!holding(&ptable.lock))
  1031b7:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1031be:	e8 5d 08 00 00       	call   103a20 <holding>
  1031c3:	85 c0                	test   %eax,%eax
  1031c5:	74 4d                	je     103214 <sched+0x64>
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
  1031c7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1031cd:	83 b8 ac 00 00 00 01 	cmpl   $0x1,0xac(%eax)
  1031d4:	75 62                	jne    103238 <sched+0x88>
    panic("sched locks");
  if(proc->state == RUNNING)
  1031d6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  1031dd:	83 7a 0c 04          	cmpl   $0x4,0xc(%edx)
  1031e1:	74 49                	je     10322c <sched+0x7c>

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  1031e3:	9c                   	pushf  
  1031e4:	59                   	pop    %ecx
    panic("sched running");
  if(readeflags()&FL_IF)
  1031e5:	80 e5 02             	and    $0x2,%ch
  1031e8:	75 36                	jne    103220 <sched+0x70>
    panic("sched interruptible");
  intena = cpu->intena;
  1031ea:	8b 98 b0 00 00 00    	mov    0xb0(%eax),%ebx
  swtch(&proc->context, cpu->scheduler);
  1031f0:	83 c2 1c             	add    $0x1c,%edx
  1031f3:	8b 40 04             	mov    0x4(%eax),%eax
  1031f6:	89 14 24             	mov    %edx,(%esp)
  1031f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031fd:	e8 ca 0b 00 00       	call   103dcc <swtch>
  cpu->intena = intena;
  103202:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103208:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  10320e:	83 c4 14             	add    $0x14,%esp
  103211:	5b                   	pop    %ebx
  103212:	5d                   	pop    %ebp
  103213:	c3                   	ret    
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  103214:	c7 04 24 9e 6a 10 00 	movl   $0x106a9e,(%esp)
  10321b:	e8 00 d7 ff ff       	call   100920 <panic>
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  103220:	c7 04 24 ca 6a 10 00 	movl   $0x106aca,(%esp)
  103227:	e8 f4 d6 ff ff       	call   100920 <panic>
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  10322c:	c7 04 24 bc 6a 10 00 	movl   $0x106abc,(%esp)
  103233:	e8 e8 d6 ff ff       	call   100920 <panic>
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  103238:	c7 04 24 b0 6a 10 00 	movl   $0x106ab0,(%esp)
  10323f:	e8 dc d6 ff ff       	call   100920 <panic>
  103244:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10324a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103250 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  103250:	55                   	push   %ebp
  103251:	89 e5                	mov    %esp,%ebp
  103253:	56                   	push   %esi
  103254:	53                   	push   %ebx
  103255:	83 ec 10             	sub    $0x10,%esp
  if(proc == 0)
  103258:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  10325e:	8b 75 08             	mov    0x8(%ebp),%esi
  103261:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
  103264:	85 c0                	test   %eax,%eax
  103266:	0f 84 a1 00 00 00    	je     10330d <sleep+0xbd>
    panic("sleep");

  if(lk == 0)
  10326c:	85 db                	test   %ebx,%ebx
  10326e:	0f 84 8d 00 00 00    	je     103301 <sleep+0xb1>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
  103274:	81 fb 20 c1 10 00    	cmp    $0x10c120,%ebx
  10327a:	74 5c                	je     1032d8 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
  10327c:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103283:	e8 a8 08 00 00       	call   103b30 <acquire>
    release(lk);
  103288:	89 1c 24             	mov    %ebx,(%esp)
  10328b:	e8 50 08 00 00       	call   103ae0 <release>
  }

  // Go to sleep.
  proc->chan = chan;
  103290:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103296:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  103299:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10329f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  1032a6:	e8 05 ff ff ff       	call   1031b0 <sched>

  // Tidy up.
  proc->chan = 0;
  1032ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032b1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
  1032b8:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1032bf:	e8 1c 08 00 00       	call   103ae0 <release>
    acquire(lk);
  1032c4:	89 5d 08             	mov    %ebx,0x8(%ebp)
  }
}
  1032c7:	83 c4 10             	add    $0x10,%esp
  1032ca:	5b                   	pop    %ebx
  1032cb:	5e                   	pop    %esi
  1032cc:	5d                   	pop    %ebp
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  1032cd:	e9 5e 08 00 00       	jmp    103b30 <acquire>
  1032d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  1032d8:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  1032db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032e1:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  1032e8:	e8 c3 fe ff ff       	call   1031b0 <sched>

  // Tidy up.
  proc->chan = 0;
  1032ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032f3:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}
  1032fa:	83 c4 10             	add    $0x10,%esp
  1032fd:	5b                   	pop    %ebx
  1032fe:	5e                   	pop    %esi
  1032ff:	5d                   	pop    %ebp
  103300:	c3                   	ret    
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");
  103301:	c7 04 24 e4 6a 10 00 	movl   $0x106ae4,(%esp)
  103308:	e8 13 d6 ff ff       	call   100920 <panic>
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");
  10330d:	c7 04 24 de 6a 10 00 	movl   $0x106ade,(%esp)
  103314:	e8 07 d6 ff ff       	call   100920 <panic>
  103319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103320 <yield>:
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  103320:	55                   	push   %ebp
  103321:	89 e5                	mov    %esp,%ebp
  103323:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
  103326:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10332d:	e8 fe 07 00 00       	call   103b30 <acquire>
  proc->state = RUNNABLE;
  103332:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103338:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
  10333f:	e8 6c fe ff ff       	call   1031b0 <sched>
  release(&ptable.lock);
  103344:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10334b:	e8 90 07 00 00       	call   103ae0 <release>
}
  103350:	c9                   	leave  
  103351:	c3                   	ret    
  103352:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  103359:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103360 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  103360:	55                   	push   %ebp
  103361:	89 e5                	mov    %esp,%ebp
  103363:	53                   	push   %ebx
  103364:	83 ec 14             	sub    $0x14,%esp
  103367:	90                   	nop
}

static inline void
sti(void)
{
  asm volatile("sti");
  103368:	fb                   	sti    
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
  103369:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
  10336e:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103375:	e8 b6 07 00 00       	call   103b30 <acquire>
  10337a:	eb 0f                	jmp    10338b <scheduler+0x2b>
  10337c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103380:	83 c3 7c             	add    $0x7c,%ebx
  103383:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103389:	74 5d                	je     1033e8 <scheduler+0x88>
      if(p->state != RUNNABLE)
  10338b:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
  10338f:	90                   	nop
  103390:	75 ee                	jne    103380 <scheduler+0x20>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
  103392:	65 89 1d 04 00 00 00 	mov    %ebx,%gs:0x4
      switchuvm(p);
  103399:	89 1c 24             	mov    %ebx,(%esp)
  10339c:	e8 2f 30 00 00       	call   1063d0 <switchuvm>
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  1033a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
  1033a7:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1033ae:	83 c3 7c             	add    $0x7c,%ebx
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  1033b1:	8b 40 1c             	mov    0x1c(%eax),%eax
  1033b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033b8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1033be:	83 c0 04             	add    $0x4,%eax
  1033c1:	89 04 24             	mov    %eax,(%esp)
  1033c4:	e8 03 0a 00 00       	call   103dcc <swtch>
      switchkvm();
  1033c9:	e8 92 29 00 00       	call   105d60 <switchkvm>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1033ce:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
  1033d4:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  1033db:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1033df:	75 aa                	jne    10338b <scheduler+0x2b>
  1033e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
  1033e8:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1033ef:	e8 ec 06 00 00       	call   103ae0 <release>

  }
  1033f4:	e9 6f ff ff ff       	jmp    103368 <scheduler+0x8>
  1033f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103400 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103400:	55                   	push   %ebp
  103401:	89 e5                	mov    %esp,%ebp
  103403:	53                   	push   %ebx
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  103404:	bb 54 c1 10 00       	mov    $0x10c154,%ebx

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103409:	83 ec 24             	sub    $0x24,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  10340c:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103413:	e8 18 07 00 00       	call   103b30 <acquire>
  103418:	31 c0                	xor    %eax,%eax
  10341a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103420:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103426:	72 30                	jb     103458 <wait+0x58>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
  103428:	85 c0                	test   %eax,%eax
  10342a:	74 5c                	je     103488 <wait+0x88>
  10342c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103432:	8b 50 24             	mov    0x24(%eax),%edx
  103435:	85 d2                	test   %edx,%edx
  103437:	75 4f                	jne    103488 <wait+0x88>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  103439:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  10343e:	89 04 24             	mov    %eax,(%esp)
  103441:	c7 44 24 04 20 c1 10 	movl   $0x10c120,0x4(%esp)
  103448:	00 
  103449:	e8 02 fe ff ff       	call   103250 <sleep>
  10344e:	31 c0                	xor    %eax,%eax

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103450:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103456:	73 d0                	jae    103428 <wait+0x28>
      if(p->parent != proc)
  103458:	8b 53 14             	mov    0x14(%ebx),%edx
  10345b:	65 3b 15 04 00 00 00 	cmp    %gs:0x4,%edx
  103462:	74 0c                	je     103470 <wait+0x70>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103464:	83 c3 7c             	add    $0x7c,%ebx
  103467:	eb b7                	jmp    103420 <wait+0x20>
  103469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
  103470:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
  103474:	74 29                	je     10349f <wait+0x9f>
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
  103476:	b8 01 00 00 00       	mov    $0x1,%eax
  10347b:	90                   	nop
  10347c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103480:	eb e2                	jmp    103464 <wait+0x64>
  103482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
  103488:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10348f:	e8 4c 06 00 00       	call   103ae0 <release>
  103494:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
  103499:	83 c4 24             	add    $0x24,%esp
  10349c:	5b                   	pop    %ebx
  10349d:	5d                   	pop    %ebp
  10349e:	c3                   	ret    
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
  10349f:	8b 43 10             	mov    0x10(%ebx),%eax
        kfree(p->kstack);
  1034a2:	8b 53 08             	mov    0x8(%ebx),%edx
  1034a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1034a8:	89 14 24             	mov    %edx,(%esp)
  1034ab:	e8 e0 ed ff ff       	call   102290 <kfree>
        p->kstack = 0;
        freevm(p->pgdir);
  1034b0:	8b 53 04             	mov    0x4(%ebx),%edx
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
  1034b3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
  1034ba:	89 14 24             	mov    %edx,(%esp)
  1034bd:	e8 3e 2c 00 00       	call   106100 <freevm>
        p->state = UNUSED;
  1034c2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->pid = 0;
  1034c9:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
  1034d0:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
  1034d7:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
  1034db:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        release(&ptable.lock);
  1034e2:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1034e9:	e8 f2 05 00 00       	call   103ae0 <release>
        return pid;
  1034ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034f1:	eb a6                	jmp    103499 <wait+0x99>
  1034f3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1034f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103500 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  103500:	55                   	push   %ebp
  103501:	89 e5                	mov    %esp,%ebp
  103503:	56                   	push   %esi
  103504:	53                   	push   %ebx
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  103505:	31 db                	xor    %ebx,%ebx
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  103507:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
  10350a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103511:	3b 15 c8 78 10 00    	cmp    0x1078c8,%edx
  103517:	0f 84 fd 00 00 00    	je     10361a <exit+0x11a>
  10351d:	8d 76 00             	lea    0x0(%esi),%esi
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
  103520:	8d 73 08             	lea    0x8(%ebx),%esi
  103523:	8b 44 b2 08          	mov    0x8(%edx,%esi,4),%eax
  103527:	85 c0                	test   %eax,%eax
  103529:	74 1d                	je     103548 <exit+0x48>
      fileclose(proc->ofile[fd]);
  10352b:	89 04 24             	mov    %eax,(%esp)
  10352e:	e8 4d da ff ff       	call   100f80 <fileclose>
      proc->ofile[fd] = 0;
  103533:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103539:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
  103540:	00 
  103541:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
  103548:	83 c3 01             	add    $0x1,%ebx
  10354b:	83 fb 10             	cmp    $0x10,%ebx
  10354e:	75 d0                	jne    103520 <exit+0x20>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
  103550:	8b 42 68             	mov    0x68(%edx),%eax
  103553:	89 04 24             	mov    %eax,(%esp)
  103556:	e8 25 e3 ff ff       	call   101880 <iput>
  proc->cwd = 0;
  10355b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103561:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
  103568:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10356f:	e8 bc 05 00 00       	call   103b30 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  103574:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
  10357b:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  103580:	8b 51 14             	mov    0x14(%ecx),%edx
  103583:	eb 0d                	jmp    103592 <exit+0x92>
  103585:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103588:	83 c0 7c             	add    $0x7c,%eax
  10358b:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  103590:	74 1c                	je     1035ae <exit+0xae>
    if(p->state == SLEEPING && p->chan == chan)
  103592:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  103596:	75 f0                	jne    103588 <exit+0x88>
  103598:	3b 50 20             	cmp    0x20(%eax),%edx
  10359b:	75 eb                	jne    103588 <exit+0x88>
      p->state = RUNNABLE;
  10359d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1035a4:	83 c0 7c             	add    $0x7c,%eax
  1035a7:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  1035ac:	75 e4                	jne    103592 <exit+0x92>
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  1035ae:	8b 1d c8 78 10 00    	mov    0x1078c8,%ebx
  1035b4:	ba 54 c1 10 00       	mov    $0x10c154,%edx
  1035b9:	eb 10                	jmp    1035cb <exit+0xcb>
  1035bb:	90                   	nop
  1035bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1035c0:	83 c2 7c             	add    $0x7c,%edx
  1035c3:	81 fa 54 e0 10 00    	cmp    $0x10e054,%edx
  1035c9:	74 37                	je     103602 <exit+0x102>
    if(p->parent == proc){
  1035cb:	3b 4a 14             	cmp    0x14(%edx),%ecx
  1035ce:	75 f0                	jne    1035c0 <exit+0xc0>
      p->parent = initproc;
      if(p->state == ZOMBIE)
  1035d0:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  1035d4:	89 5a 14             	mov    %ebx,0x14(%edx)
      if(p->state == ZOMBIE)
  1035d7:	75 e7                	jne    1035c0 <exit+0xc0>
  1035d9:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  1035de:	eb 0a                	jmp    1035ea <exit+0xea>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1035e0:	83 c0 7c             	add    $0x7c,%eax
  1035e3:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  1035e8:	74 d6                	je     1035c0 <exit+0xc0>
    if(p->state == SLEEPING && p->chan == chan)
  1035ea:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  1035ee:	75 f0                	jne    1035e0 <exit+0xe0>
  1035f0:	3b 58 20             	cmp    0x20(%eax),%ebx
  1035f3:	75 eb                	jne    1035e0 <exit+0xe0>
      p->state = RUNNABLE;
  1035f5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  1035fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103600:	eb de                	jmp    1035e0 <exit+0xe0>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  103602:	c7 41 0c 05 00 00 00 	movl   $0x5,0xc(%ecx)
  sched();
  103609:	e8 a2 fb ff ff       	call   1031b0 <sched>
  panic("zombie exit");
  10360e:	c7 04 24 02 6b 10 00 	movl   $0x106b02,(%esp)
  103615:	e8 06 d3 ff ff       	call   100920 <panic>
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  10361a:	c7 04 24 f5 6a 10 00 	movl   $0x106af5,(%esp)
  103621:	e8 fa d2 ff ff       	call   100920 <panic>
  103626:	8d 76 00             	lea    0x0(%esi),%esi
  103629:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103630 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  103630:	55                   	push   %ebp
  103631:	89 e5                	mov    %esp,%ebp
  103633:	53                   	push   %ebx
  103634:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  103637:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10363e:	e8 ed 04 00 00       	call   103b30 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
  103643:	8b 1d 60 c1 10 00    	mov    0x10c160,%ebx
  103649:	85 db                	test   %ebx,%ebx
  10364b:	0f 84 a5 00 00 00    	je     1036f6 <allocproc+0xc6>
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
  103651:	bb d0 c1 10 00       	mov    $0x10c1d0,%ebx
  103656:	eb 0b                	jmp    103663 <allocproc+0x33>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103658:	83 c3 7c             	add    $0x7c,%ebx
  10365b:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103661:	74 7d                	je     1036e0 <allocproc+0xb0>
    if(p->state == UNUSED)
  103663:	8b 4b 0c             	mov    0xc(%ebx),%ecx
  103666:	85 c9                	test   %ecx,%ecx
  103668:	75 ee                	jne    103658 <allocproc+0x28>
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  10366a:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
  103671:	a1 24 73 10 00       	mov    0x107324,%eax
  103676:	89 43 10             	mov    %eax,0x10(%ebx)
  103679:	83 c0 01             	add    $0x1,%eax
  10367c:	a3 24 73 10 00       	mov    %eax,0x107324
  release(&ptable.lock);
  103681:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103688:	e8 53 04 00 00       	call   103ae0 <release>

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
  10368d:	e8 be eb ff ff       	call   102250 <kalloc>
  103692:	85 c0                	test   %eax,%eax
  103694:	89 43 08             	mov    %eax,0x8(%ebx)
  103697:	74 67                	je     103700 <allocproc+0xd0>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  103699:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
  10369f:	89 53 18             	mov    %edx,0x18(%ebx)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
  1036a2:	c7 80 b0 0f 00 00 40 	movl   $0x104e40,0xfb0(%eax)
  1036a9:	4e 10 00 

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  1036ac:	05 9c 0f 00 00       	add    $0xf9c,%eax
  1036b1:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
  1036b4:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  1036bb:	00 
  1036bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1036c3:	00 
  1036c4:	89 04 24             	mov    %eax,(%esp)
  1036c7:	e8 04 05 00 00       	call   103bd0 <memset>
  p->context->eip = (uint)forkret;
  1036cc:	8b 43 1c             	mov    0x1c(%ebx),%eax
  1036cf:	c7 40 10 90 31 10 00 	movl   $0x103190,0x10(%eax)

  return p;
}
  1036d6:	89 d8                	mov    %ebx,%eax
  1036d8:	83 c4 14             	add    $0x14,%esp
  1036db:	5b                   	pop    %ebx
  1036dc:	5d                   	pop    %ebp
  1036dd:	c3                   	ret    
  1036de:	66 90                	xchg   %ax,%ax

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  1036e0:	31 db                	xor    %ebx,%ebx
  1036e2:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1036e9:	e8 f2 03 00 00       	call   103ae0 <release>
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}
  1036ee:	89 d8                	mov    %ebx,%eax
  1036f0:	83 c4 14             	add    $0x14,%esp
  1036f3:	5b                   	pop    %ebx
  1036f4:	5d                   	pop    %ebp
  1036f5:	c3                   	ret    
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;
  1036f6:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  1036fb:	e9 6a ff ff ff       	jmp    10366a <allocproc+0x3a>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
  103700:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  103707:	31 db                	xor    %ebx,%ebx
    return 0;
  103709:	eb cb                	jmp    1036d6 <allocproc+0xa6>
  10370b:	90                   	nop
  10370c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103710 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  103710:	55                   	push   %ebp
  103711:	89 e5                	mov    %esp,%ebp
  103713:	57                   	push   %edi
  103714:	56                   	push   %esi
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  103715:	be ff ff ff ff       	mov    $0xffffffff,%esi
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  10371a:	53                   	push   %ebx
  10371b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  10371e:	e8 0d ff ff ff       	call   103630 <allocproc>
  103723:	85 c0                	test   %eax,%eax
  103725:	89 c3                	mov    %eax,%ebx
  103727:	0f 84 be 00 00 00    	je     1037eb <fork+0xdb>
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
  10372d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103733:	8b 10                	mov    (%eax),%edx
  103735:	89 54 24 04          	mov    %edx,0x4(%esp)
  103739:	8b 40 04             	mov    0x4(%eax),%eax
  10373c:	89 04 24             	mov    %eax,(%esp)
  10373f:	e8 3c 2a 00 00       	call   106180 <copyuvm>
  103744:	85 c0                	test   %eax,%eax
  103746:	89 43 04             	mov    %eax,0x4(%ebx)
  103749:	0f 84 a6 00 00 00    	je     1037f5 <fork+0xe5>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  10374f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  np->parent = proc;
  *np->tf = *proc->tf;
  103755:	b9 13 00 00 00       	mov    $0x13,%ecx
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  10375a:	8b 00                	mov    (%eax),%eax
  10375c:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
  10375e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103764:	89 43 14             	mov    %eax,0x14(%ebx)
  *np->tf = *proc->tf;
  103767:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10376e:	8b 43 18             	mov    0x18(%ebx),%eax
  103771:	8b 72 18             	mov    0x18(%edx),%esi
  103774:	89 c7                	mov    %eax,%edi
  103776:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
  103778:	31 f6                	xor    %esi,%esi
  10377a:	8b 43 18             	mov    0x18(%ebx),%eax
  10377d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  103784:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10378b:	90                   	nop
  10378c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
  103790:	8b 44 b2 28          	mov    0x28(%edx,%esi,4),%eax
  103794:	85 c0                	test   %eax,%eax
  103796:	74 13                	je     1037ab <fork+0x9b>
      np->ofile[i] = filedup(proc->ofile[i]);
  103798:	89 04 24             	mov    %eax,(%esp)
  10379b:	e8 10 d7 ff ff       	call   100eb0 <filedup>
  1037a0:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
  1037a4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
  1037ab:	83 c6 01             	add    $0x1,%esi
  1037ae:	83 fe 10             	cmp    $0x10,%esi
  1037b1:	75 dd                	jne    103790 <fork+0x80>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1037b3:	8b 42 68             	mov    0x68(%edx),%eax
  1037b6:	89 04 24             	mov    %eax,(%esp)
  1037b9:	e8 f2 d8 ff ff       	call   1010b0 <idup>
 
  pid = np->pid;
  1037be:	8b 73 10             	mov    0x10(%ebx),%esi
  np->state = RUNNABLE;
  1037c1:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1037c8:	89 43 68             	mov    %eax,0x68(%ebx)
 
  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  1037cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1037d1:	83 c3 6c             	add    $0x6c,%ebx
  1037d4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  1037db:	00 
  1037dc:	89 1c 24             	mov    %ebx,(%esp)
  1037df:	83 c0 6c             	add    $0x6c,%eax
  1037e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1037e6:	e8 85 05 00 00       	call   103d70 <safestrcpy>
  return pid;
}
  1037eb:	83 c4 1c             	add    $0x1c,%esp
  1037ee:	89 f0                	mov    %esi,%eax
  1037f0:	5b                   	pop    %ebx
  1037f1:	5e                   	pop    %esi
  1037f2:	5f                   	pop    %edi
  1037f3:	5d                   	pop    %ebp
  1037f4:	c3                   	ret    
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
  1037f5:	8b 43 08             	mov    0x8(%ebx),%eax
  1037f8:	89 04 24             	mov    %eax,(%esp)
  1037fb:	e8 90 ea ff ff       	call   102290 <kfree>
    np->kstack = 0;
  103800:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
  103807:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
  10380e:	eb db                	jmp    1037eb <fork+0xdb>

00103810 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  103810:	55                   	push   %ebp
  103811:	89 e5                	mov    %esp,%ebp
  103813:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
  103816:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  10381d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  uint sz;
  
  sz = proc->sz;
  103820:	8b 02                	mov    (%edx),%eax
  if(n > 0){
  103822:	83 f9 00             	cmp    $0x0,%ecx
  103825:	7f 19                	jg     103840 <growproc+0x30>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
  103827:	75 39                	jne    103862 <growproc+0x52>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  103829:	89 02                	mov    %eax,(%edx)
  switchuvm(proc);
  10382b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103831:	89 04 24             	mov    %eax,(%esp)
  103834:	e8 97 2b 00 00       	call   1063d0 <switchuvm>
  103839:	31 c0                	xor    %eax,%eax
  return 0;
}
  10383b:	c9                   	leave  
  10383c:	c3                   	ret    
  10383d:	8d 76 00             	lea    0x0(%esi),%esi
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
  103840:	01 c1                	add    %eax,%ecx
  103842:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103846:	89 44 24 04          	mov    %eax,0x4(%esp)
  10384a:	8b 42 04             	mov    0x4(%edx),%eax
  10384d:	89 04 24             	mov    %eax,(%esp)
  103850:	e8 eb 29 00 00       	call   106240 <allocuvm>
  103855:	85 c0                	test   %eax,%eax
  103857:	74 27                	je     103880 <growproc+0x70>
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
  103859:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103860:	eb c7                	jmp    103829 <growproc+0x19>
  103862:	01 c1                	add    %eax,%ecx
  103864:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103868:	89 44 24 04          	mov    %eax,0x4(%esp)
  10386c:	8b 42 04             	mov    0x4(%edx),%eax
  10386f:	89 04 24             	mov    %eax,(%esp)
  103872:	e8 f9 27 00 00       	call   106070 <deallocuvm>
  103877:	85 c0                	test   %eax,%eax
  103879:	75 de                	jne    103859 <growproc+0x49>
  10387b:	90                   	nop
  10387c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
  103880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  103885:	c9                   	leave  
  103886:	c3                   	ret    
  103887:	89 f6                	mov    %esi,%esi
  103889:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103890 <userinit>:
}

// Set up first user process.
void
userinit(void)
{
  103890:	55                   	push   %ebp
  103891:	89 e5                	mov    %esp,%ebp
  103893:	53                   	push   %ebx
  103894:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  103897:	e8 94 fd ff ff       	call   103630 <allocproc>
  10389c:	89 c3                	mov    %eax,%ebx
  initproc = p;
  10389e:	a3 c8 78 10 00       	mov    %eax,0x1078c8
  if((p->pgdir = setupkvm()) == 0)
  1038a3:	e8 98 26 00 00       	call   105f40 <setupkvm>
  1038a8:	85 c0                	test   %eax,%eax
  1038aa:	89 43 04             	mov    %eax,0x4(%ebx)
  1038ad:	0f 84 b6 00 00 00    	je     103969 <userinit+0xd9>
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  1038b3:	89 04 24             	mov    %eax,(%esp)
  1038b6:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
  1038bd:	00 
  1038be:	c7 44 24 04 70 77 10 	movl   $0x107770,0x4(%esp)
  1038c5:	00 
  1038c6:	e8 15 27 00 00       	call   105fe0 <inituvm>
  p->sz = PGSIZE;
  1038cb:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
  1038d1:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
  1038d8:	00 
  1038d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1038e0:	00 
  1038e1:	8b 43 18             	mov    0x18(%ebx),%eax
  1038e4:	89 04 24             	mov    %eax,(%esp)
  1038e7:	e8 e4 02 00 00       	call   103bd0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  1038ec:	8b 43 18             	mov    0x18(%ebx),%eax
  1038ef:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  1038f5:	8b 43 18             	mov    0x18(%ebx),%eax
  1038f8:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
  1038fe:	8b 43 18             	mov    0x18(%ebx),%eax
  103901:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103905:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
  103909:	8b 43 18             	mov    0x18(%ebx),%eax
  10390c:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103910:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
  103914:	8b 43 18             	mov    0x18(%ebx),%eax
  103917:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
  10391e:	8b 43 18             	mov    0x18(%ebx),%eax
  103921:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
  103928:	8b 43 18             	mov    0x18(%ebx),%eax
  10392b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
  103932:	8d 43 6c             	lea    0x6c(%ebx),%eax
  103935:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  10393c:	00 
  10393d:	c7 44 24 04 27 6b 10 	movl   $0x106b27,0x4(%esp)
  103944:	00 
  103945:	89 04 24             	mov    %eax,(%esp)
  103948:	e8 23 04 00 00       	call   103d70 <safestrcpy>
  p->cwd = namei("/");
  10394d:	c7 04 24 30 6b 10 00 	movl   $0x106b30,(%esp)
  103954:	e8 f7 e4 ff ff       	call   101e50 <namei>

  p->state = RUNNABLE;
  103959:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");
  103960:	89 43 68             	mov    %eax,0x68(%ebx)

  p->state = RUNNABLE;
}
  103963:	83 c4 14             	add    $0x14,%esp
  103966:	5b                   	pop    %ebx
  103967:	5d                   	pop    %ebp
  103968:	c3                   	ret    
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  103969:	c7 04 24 0e 6b 10 00 	movl   $0x106b0e,(%esp)
  103970:	e8 ab cf ff ff       	call   100920 <panic>
  103975:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103979:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103980 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
  103980:	55                   	push   %ebp
  103981:	89 e5                	mov    %esp,%ebp
  103983:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
  103986:	c7 44 24 04 32 6b 10 	movl   $0x106b32,0x4(%esp)
  10398d:	00 
  10398e:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103995:	e8 06 00 00 00       	call   1039a0 <initlock>
}
  10399a:	c9                   	leave  
  10399b:	c3                   	ret    
  10399c:	90                   	nop
  10399d:	90                   	nop
  10399e:	90                   	nop
  10399f:	90                   	nop

001039a0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  1039a0:	55                   	push   %ebp
  1039a1:	89 e5                	mov    %esp,%ebp
  1039a3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
  1039a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
  1039a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
  1039af:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
  lk->cpu = 0;
  1039b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
  1039b9:	5d                   	pop    %ebp
  1039ba:	c3                   	ret    
  1039bb:	90                   	nop
  1039bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

001039c0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  1039c0:	55                   	push   %ebp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  1039c1:	31 c0                	xor    %eax,%eax
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  1039c3:	89 e5                	mov    %esp,%ebp
  1039c5:	53                   	push   %ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  1039c6:	8b 55 08             	mov    0x8(%ebp),%edx
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  1039c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  1039cc:	83 ea 08             	sub    $0x8,%edx
  1039cf:	90                   	nop
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
  1039d0:	8d 8a 00 00 f0 ff    	lea    -0x100000(%edx),%ecx
  1039d6:	81 f9 fe ff ef ff    	cmp    $0xffeffffe,%ecx
  1039dc:	77 1a                	ja     1039f8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
  1039de:	8b 4a 04             	mov    0x4(%edx),%ecx
  1039e1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  1039e4:	83 c0 01             	add    $0x1,%eax
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  1039e7:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  1039e9:	83 f8 0a             	cmp    $0xa,%eax
  1039ec:	75 e2                	jne    1039d0 <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
  1039ee:	5b                   	pop    %ebx
  1039ef:	5d                   	pop    %ebp
  1039f0:	c3                   	ret    
  1039f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  1039f8:	83 f8 09             	cmp    $0x9,%eax
  1039fb:	7f f1                	jg     1039ee <getcallerpcs+0x2e>
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  1039fd:	8d 14 83             	lea    (%ebx,%eax,4),%edx
  }
  for(; i < 10; i++)
  103a00:	83 c0 01             	add    $0x1,%eax
    pcs[i] = 0;
  103a03:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  103a09:	83 c2 04             	add    $0x4,%edx
  103a0c:	83 f8 0a             	cmp    $0xa,%eax
  103a0f:	75 ef                	jne    103a00 <getcallerpcs+0x40>
    pcs[i] = 0;
}
  103a11:	5b                   	pop    %ebx
  103a12:	5d                   	pop    %ebp
  103a13:	c3                   	ret    
  103a14:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103a1a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103a20 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103a20:	55                   	push   %ebp
  return lock->locked && lock->cpu == cpu;
  103a21:	31 c0                	xor    %eax,%eax
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103a23:	89 e5                	mov    %esp,%ebp
  103a25:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
  103a28:	8b 0a                	mov    (%edx),%ecx
  103a2a:	85 c9                	test   %ecx,%ecx
  103a2c:	74 10                	je     103a3e <holding+0x1e>
  103a2e:	8b 42 08             	mov    0x8(%edx),%eax
  103a31:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103a38:	0f 94 c0             	sete   %al
  103a3b:	0f b6 c0             	movzbl %al,%eax
}
  103a3e:	5d                   	pop    %ebp
  103a3f:	c3                   	ret    

00103a40 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
  103a40:	55                   	push   %ebp
  103a41:	89 e5                	mov    %esp,%ebp
  103a43:	53                   	push   %ebx

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103a44:	9c                   	pushf  
  103a45:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103a46:	fa                   	cli    
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103a47:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103a4e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103a54:	8d 48 01             	lea    0x1(%eax),%ecx
  103a57:	85 c0                	test   %eax,%eax
  103a59:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103a5f:	75 12                	jne    103a73 <pushcli+0x33>
    cpu->intena = eflags & FL_IF;
  103a61:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103a67:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103a6d:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  103a73:	5b                   	pop    %ebx
  103a74:	5d                   	pop    %ebp
  103a75:	c3                   	ret    
  103a76:	8d 76 00             	lea    0x0(%esi),%esi
  103a79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103a80 <popcli>:

void
popcli(void)
{
  103a80:	55                   	push   %ebp
  103a81:	89 e5                	mov    %esp,%ebp
  103a83:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103a86:	9c                   	pushf  
  103a87:	58                   	pop    %eax
  if(readeflags()&FL_IF)
  103a88:	f6 c4 02             	test   $0x2,%ah
  103a8b:	75 43                	jne    103ad0 <popcli+0x50>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
  103a8d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103a94:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103a9a:	83 e8 01             	sub    $0x1,%eax
  103a9d:	85 c0                	test   %eax,%eax
  103a9f:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
  103aa5:	78 1d                	js     103ac4 <popcli+0x44>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
  103aa7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103aad:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
  103ab3:	85 d2                	test   %edx,%edx
  103ab5:	75 0b                	jne    103ac2 <popcli+0x42>
  103ab7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  103abd:	85 c0                	test   %eax,%eax
  103abf:	74 01                	je     103ac2 <popcli+0x42>
}

static inline void
sti(void)
{
  asm volatile("sti");
  103ac1:	fb                   	sti    
    sti();
}
  103ac2:	c9                   	leave  
  103ac3:	c3                   	ret    
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
    panic("popcli");
  103ac4:	c7 04 24 93 6b 10 00 	movl   $0x106b93,(%esp)
  103acb:	e8 50 ce ff ff       	call   100920 <panic>

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  103ad0:	c7 04 24 7c 6b 10 00 	movl   $0x106b7c,(%esp)
  103ad7:	e8 44 ce ff ff       	call   100920 <panic>
  103adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103ae0 <release>:
}

// Release the lock.
void
release(struct spinlock *lk)
{
  103ae0:	55                   	push   %ebp
  103ae1:	89 e5                	mov    %esp,%ebp
  103ae3:	83 ec 18             	sub    $0x18,%esp
  103ae6:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103ae9:	8b 0a                	mov    (%edx),%ecx
  103aeb:	85 c9                	test   %ecx,%ecx
  103aed:	74 0c                	je     103afb <release+0x1b>
  103aef:	8b 42 08             	mov    0x8(%edx),%eax
  103af2:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103af9:	74 0d                	je     103b08 <release+0x28>
// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");
  103afb:	c7 04 24 9a 6b 10 00 	movl   $0x106b9a,(%esp)
  103b02:	e8 19 ce ff ff       	call   100920 <panic>
  103b07:	90                   	nop

  lk->pcs[0] = 0;
  103b08:	c7 42 0c 00 00 00 00 	movl   $0x0,0xc(%edx)
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103b0f:	31 c0                	xor    %eax,%eax
  lk->cpu = 0;
  103b11:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
  103b18:	f0 87 02             	lock xchg %eax,(%edx)
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
}
  103b1b:	c9                   	leave  
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
  103b1c:	e9 5f ff ff ff       	jmp    103a80 <popcli>
  103b21:	eb 0d                	jmp    103b30 <acquire>
  103b23:	90                   	nop
  103b24:	90                   	nop
  103b25:	90                   	nop
  103b26:	90                   	nop
  103b27:	90                   	nop
  103b28:	90                   	nop
  103b29:	90                   	nop
  103b2a:	90                   	nop
  103b2b:	90                   	nop
  103b2c:	90                   	nop
  103b2d:	90                   	nop
  103b2e:	90                   	nop
  103b2f:	90                   	nop

00103b30 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  103b30:	55                   	push   %ebp
  103b31:	89 e5                	mov    %esp,%ebp
  103b33:	53                   	push   %ebx
  103b34:	83 ec 14             	sub    $0x14,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103b37:	9c                   	pushf  
  103b38:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103b39:	fa                   	cli    
{
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103b3a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103b41:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103b47:	8d 48 01             	lea    0x1(%eax),%ecx
  103b4a:	85 c0                	test   %eax,%eax
  103b4c:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103b52:	75 12                	jne    103b66 <acquire+0x36>
    cpu->intena = eflags & FL_IF;
  103b54:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103b5a:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103b60:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
  103b66:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103b69:	8b 1a                	mov    (%edx),%ebx
  103b6b:	85 db                	test   %ebx,%ebx
  103b6d:	74 0c                	je     103b7b <acquire+0x4b>
  103b6f:	8b 42 08             	mov    0x8(%edx),%eax
  103b72:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103b79:	74 45                	je     103bc0 <acquire+0x90>
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103b7b:	b9 01 00 00 00       	mov    $0x1,%ecx
  103b80:	eb 09                	jmp    103b8b <acquire+0x5b>
  103b82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
  103b88:	8b 55 08             	mov    0x8(%ebp),%edx
  103b8b:	89 c8                	mov    %ecx,%eax
  103b8d:	f0 87 02             	lock xchg %eax,(%edx)
  103b90:	85 c0                	test   %eax,%eax
  103b92:	75 f4                	jne    103b88 <acquire+0x58>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
  103b94:	8b 45 08             	mov    0x8(%ebp),%eax
  103b97:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103b9e:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
  103ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  103ba4:	83 c0 0c             	add    $0xc,%eax
  103ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
  103bab:	8d 45 08             	lea    0x8(%ebp),%eax
  103bae:	89 04 24             	mov    %eax,(%esp)
  103bb1:	e8 0a fe ff ff       	call   1039c0 <getcallerpcs>
}
  103bb6:	83 c4 14             	add    $0x14,%esp
  103bb9:	5b                   	pop    %ebx
  103bba:	5d                   	pop    %ebp
  103bbb:	c3                   	ret    
  103bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");
  103bc0:	c7 04 24 a2 6b 10 00 	movl   $0x106ba2,(%esp)
  103bc7:	e8 54 cd ff ff       	call   100920 <panic>
  103bcc:	90                   	nop
  103bcd:	90                   	nop
  103bce:	90                   	nop
  103bcf:	90                   	nop

00103bd0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
  103bd0:	55                   	push   %ebp
  103bd1:	89 e5                	mov    %esp,%ebp
  103bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  103bd6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  103bd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  103bdd:	89 d7                	mov    %edx,%edi
  103bdf:	fc                   	cld    
  103be0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  103be2:	89 d0                	mov    %edx,%eax
  103be4:	5f                   	pop    %edi
  103be5:	5d                   	pop    %ebp
  103be6:	c3                   	ret    
  103be7:	89 f6                	mov    %esi,%esi
  103be9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103bf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
  103bf0:	55                   	push   %ebp
  103bf1:	89 e5                	mov    %esp,%ebp
  103bf3:	57                   	push   %edi
  103bf4:	56                   	push   %esi
  103bf5:	53                   	push   %ebx
  103bf6:	8b 55 10             	mov    0x10(%ebp),%edx
  103bf9:	8b 75 08             	mov    0x8(%ebp),%esi
  103bfc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103bff:	85 d2                	test   %edx,%edx
  103c01:	74 2d                	je     103c30 <memcmp+0x40>
    if(*s1 != *s2)
  103c03:	0f b6 1e             	movzbl (%esi),%ebx
  103c06:	0f b6 0f             	movzbl (%edi),%ecx
  103c09:	38 cb                	cmp    %cl,%bl
  103c0b:	75 2b                	jne    103c38 <memcmp+0x48>
      return *s1 - *s2;
  103c0d:	83 ea 01             	sub    $0x1,%edx
  103c10:	31 c0                	xor    %eax,%eax
  103c12:	eb 18                	jmp    103c2c <memcmp+0x3c>
  103c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
  103c18:	0f b6 5c 06 01       	movzbl 0x1(%esi,%eax,1),%ebx
  103c1d:	83 ea 01             	sub    $0x1,%edx
  103c20:	0f b6 4c 07 01       	movzbl 0x1(%edi,%eax,1),%ecx
  103c25:	83 c0 01             	add    $0x1,%eax
  103c28:	38 cb                	cmp    %cl,%bl
  103c2a:	75 0c                	jne    103c38 <memcmp+0x48>
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103c2c:	85 d2                	test   %edx,%edx
  103c2e:	75 e8                	jne    103c18 <memcmp+0x28>
  103c30:	31 c0                	xor    %eax,%eax
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
  103c32:	5b                   	pop    %ebx
  103c33:	5e                   	pop    %esi
  103c34:	5f                   	pop    %edi
  103c35:	5d                   	pop    %ebp
  103c36:	c3                   	ret    
  103c37:	90                   	nop
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
  103c38:	0f b6 c3             	movzbl %bl,%eax
  103c3b:	0f b6 c9             	movzbl %cl,%ecx
  103c3e:	29 c8                	sub    %ecx,%eax
    s1++, s2++;
  }

  return 0;
}
  103c40:	5b                   	pop    %ebx
  103c41:	5e                   	pop    %esi
  103c42:	5f                   	pop    %edi
  103c43:	5d                   	pop    %ebp
  103c44:	c3                   	ret    
  103c45:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103c49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103c50 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
  103c50:	55                   	push   %ebp
  103c51:	89 e5                	mov    %esp,%ebp
  103c53:	57                   	push   %edi
  103c54:	56                   	push   %esi
  103c55:	53                   	push   %ebx
  103c56:	8b 45 08             	mov    0x8(%ebp),%eax
  103c59:	8b 75 0c             	mov    0xc(%ebp),%esi
  103c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
  103c5f:	39 c6                	cmp    %eax,%esi
  103c61:	73 2d                	jae    103c90 <memmove+0x40>
  103c63:	8d 3c 1e             	lea    (%esi,%ebx,1),%edi
  103c66:	39 f8                	cmp    %edi,%eax
  103c68:	73 26                	jae    103c90 <memmove+0x40>
    s += n;
    d += n;
    while(n-- > 0)
  103c6a:	85 db                	test   %ebx,%ebx
  103c6c:	74 1d                	je     103c8b <memmove+0x3b>

  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
  103c6e:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  103c71:	31 d2                	xor    %edx,%edx
  103c73:	90                   	nop
  103c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
      *--d = *--s;
  103c78:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  103c7d:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  103c81:	83 ea 01             	sub    $0x1,%edx
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103c84:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  103c87:	85 c9                	test   %ecx,%ecx
  103c89:	75 ed                	jne    103c78 <memmove+0x28>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
  103c8b:	5b                   	pop    %ebx
  103c8c:	5e                   	pop    %esi
  103c8d:	5f                   	pop    %edi
  103c8e:	5d                   	pop    %ebp
  103c8f:	c3                   	ret    
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103c90:	31 d2                	xor    %edx,%edx
      *--d = *--s;
  } else
    while(n-- > 0)
  103c92:	85 db                	test   %ebx,%ebx
  103c94:	74 f5                	je     103c8b <memmove+0x3b>
  103c96:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
  103c98:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  103c9c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  103c9f:	83 c2 01             	add    $0x1,%edx
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
  103ca2:	39 d3                	cmp    %edx,%ebx
  103ca4:	75 f2                	jne    103c98 <memmove+0x48>
      *d++ = *s++;

  return dst;
}
  103ca6:	5b                   	pop    %ebx
  103ca7:	5e                   	pop    %esi
  103ca8:	5f                   	pop    %edi
  103ca9:	5d                   	pop    %ebp
  103caa:	c3                   	ret    
  103cab:	90                   	nop
  103cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103cb0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  103cb0:	55                   	push   %ebp
  103cb1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
  103cb3:	5d                   	pop    %ebp

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
  103cb4:	e9 97 ff ff ff       	jmp    103c50 <memmove>
  103cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103cc0 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
  103cc0:	55                   	push   %ebp
  103cc1:	89 e5                	mov    %esp,%ebp
  103cc3:	57                   	push   %edi
  103cc4:	56                   	push   %esi
  103cc5:	53                   	push   %ebx
  103cc6:	8b 7d 10             	mov    0x10(%ebp),%edi
  103cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103ccc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  while(n > 0 && *p && *p == *q)
  103ccf:	85 ff                	test   %edi,%edi
  103cd1:	74 3d                	je     103d10 <strncmp+0x50>
  103cd3:	0f b6 01             	movzbl (%ecx),%eax
  103cd6:	84 c0                	test   %al,%al
  103cd8:	75 18                	jne    103cf2 <strncmp+0x32>
  103cda:	eb 3c                	jmp    103d18 <strncmp+0x58>
  103cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103ce0:	83 ef 01             	sub    $0x1,%edi
  103ce3:	74 2b                	je     103d10 <strncmp+0x50>
    n--, p++, q++;
  103ce5:	83 c1 01             	add    $0x1,%ecx
  103ce8:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103ceb:	0f b6 01             	movzbl (%ecx),%eax
  103cee:	84 c0                	test   %al,%al
  103cf0:	74 26                	je     103d18 <strncmp+0x58>
  103cf2:	0f b6 33             	movzbl (%ebx),%esi
  103cf5:	89 f2                	mov    %esi,%edx
  103cf7:	38 d0                	cmp    %dl,%al
  103cf9:	74 e5                	je     103ce0 <strncmp+0x20>
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
  103cfb:	81 e6 ff 00 00 00    	and    $0xff,%esi
  103d01:	0f b6 c0             	movzbl %al,%eax
  103d04:	29 f0                	sub    %esi,%eax
}
  103d06:	5b                   	pop    %ebx
  103d07:	5e                   	pop    %esi
  103d08:	5f                   	pop    %edi
  103d09:	5d                   	pop    %ebp
  103d0a:	c3                   	ret    
  103d0b:	90                   	nop
  103d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103d10:	31 c0                	xor    %eax,%eax
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
  103d12:	5b                   	pop    %ebx
  103d13:	5e                   	pop    %esi
  103d14:	5f                   	pop    %edi
  103d15:	5d                   	pop    %ebp
  103d16:	c3                   	ret    
  103d17:	90                   	nop
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103d18:	0f b6 33             	movzbl (%ebx),%esi
  103d1b:	eb de                	jmp    103cfb <strncmp+0x3b>
  103d1d:	8d 76 00             	lea    0x0(%esi),%esi

00103d20 <strncpy>:
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
{
  103d20:	55                   	push   %ebp
  103d21:	89 e5                	mov    %esp,%ebp
  103d23:	8b 45 08             	mov    0x8(%ebp),%eax
  103d26:	56                   	push   %esi
  103d27:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103d2a:	53                   	push   %ebx
  103d2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  103d2e:	89 c3                	mov    %eax,%ebx
  103d30:	eb 09                	jmp    103d3b <strncpy+0x1b>
  103d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  103d38:	83 c6 01             	add    $0x1,%esi
  103d3b:	83 e9 01             	sub    $0x1,%ecx
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  103d3e:	8d 51 01             	lea    0x1(%ecx),%edx
{
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  103d41:	85 d2                	test   %edx,%edx
  103d43:	7e 0c                	jle    103d51 <strncpy+0x31>
  103d45:	0f b6 16             	movzbl (%esi),%edx
  103d48:	88 13                	mov    %dl,(%ebx)
  103d4a:	83 c3 01             	add    $0x1,%ebx
  103d4d:	84 d2                	test   %dl,%dl
  103d4f:	75 e7                	jne    103d38 <strncpy+0x18>
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  103d51:	31 d2                	xor    %edx,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  103d53:	85 c9                	test   %ecx,%ecx
  103d55:	7e 0c                	jle    103d63 <strncpy+0x43>
  103d57:	90                   	nop
    *s++ = 0;
  103d58:	c6 04 13 00          	movb   $0x0,(%ebx,%edx,1)
  103d5c:	83 c2 01             	add    $0x1,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  103d5f:	39 ca                	cmp    %ecx,%edx
  103d61:	75 f5                	jne    103d58 <strncpy+0x38>
    *s++ = 0;
  return os;
}
  103d63:	5b                   	pop    %ebx
  103d64:	5e                   	pop    %esi
  103d65:	5d                   	pop    %ebp
  103d66:	c3                   	ret    
  103d67:	89 f6                	mov    %esi,%esi
  103d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103d70 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
  103d70:	55                   	push   %ebp
  103d71:	89 e5                	mov    %esp,%ebp
  103d73:	8b 55 10             	mov    0x10(%ebp),%edx
  103d76:	56                   	push   %esi
  103d77:	8b 45 08             	mov    0x8(%ebp),%eax
  103d7a:	53                   	push   %ebx
  103d7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *os;
  
  os = s;
  if(n <= 0)
  103d7e:	85 d2                	test   %edx,%edx
  103d80:	7e 1f                	jle    103da1 <safestrcpy+0x31>
  103d82:	89 c1                	mov    %eax,%ecx
  103d84:	eb 05                	jmp    103d8b <safestrcpy+0x1b>
  103d86:	66 90                	xchg   %ax,%ax
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
  103d88:	83 c6 01             	add    $0x1,%esi
  103d8b:	83 ea 01             	sub    $0x1,%edx
  103d8e:	85 d2                	test   %edx,%edx
  103d90:	7e 0c                	jle    103d9e <safestrcpy+0x2e>
  103d92:	0f b6 1e             	movzbl (%esi),%ebx
  103d95:	88 19                	mov    %bl,(%ecx)
  103d97:	83 c1 01             	add    $0x1,%ecx
  103d9a:	84 db                	test   %bl,%bl
  103d9c:	75 ea                	jne    103d88 <safestrcpy+0x18>
    ;
  *s = 0;
  103d9e:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
  103da1:	5b                   	pop    %ebx
  103da2:	5e                   	pop    %esi
  103da3:	5d                   	pop    %ebp
  103da4:	c3                   	ret    
  103da5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103da9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103db0 <strlen>:

int
strlen(const char *s)
{
  103db0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
  103db1:	31 c0                	xor    %eax,%eax
  return os;
}

int
strlen(const char *s)
{
  103db3:	89 e5                	mov    %esp,%ebp
  103db5:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
  103db8:	80 3a 00             	cmpb   $0x0,(%edx)
  103dbb:	74 0c                	je     103dc9 <strlen+0x19>
  103dbd:	8d 76 00             	lea    0x0(%esi),%esi
  103dc0:	83 c0 01             	add    $0x1,%eax
  103dc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  103dc7:	75 f7                	jne    103dc0 <strlen+0x10>
    ;
  return n;
}
  103dc9:	5d                   	pop    %ebp
  103dca:	c3                   	ret    
  103dcb:	90                   	nop

00103dcc <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
  103dcc:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
  103dd0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
  103dd4:	55                   	push   %ebp
  pushl %ebx
  103dd5:	53                   	push   %ebx
  pushl %esi
  103dd6:	56                   	push   %esi
  pushl %edi
  103dd7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
  103dd8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
  103dda:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
  103ddc:	5f                   	pop    %edi
  popl %esi
  103ddd:	5e                   	pop    %esi
  popl %ebx
  103dde:	5b                   	pop    %ebx
  popl %ebp
  103ddf:	5d                   	pop    %ebp
  ret
  103de0:	c3                   	ret    
  103de1:	90                   	nop
  103de2:	90                   	nop
  103de3:	90                   	nop
  103de4:	90                   	nop
  103de5:	90                   	nop
  103de6:	90                   	nop
  103de7:	90                   	nop
  103de8:	90                   	nop
  103de9:	90                   	nop
  103dea:	90                   	nop
  103deb:	90                   	nop
  103dec:	90                   	nop
  103ded:	90                   	nop
  103dee:	90                   	nop
  103def:	90                   	nop

00103df0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  103df0:	55                   	push   %ebp
  103df1:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
  103df3:	8b 55 08             	mov    0x8(%ebp),%edx
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  103df6:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(addr >= p->sz || addr+4 > p->sz)
  103df9:	8b 12                	mov    (%edx),%edx
  103dfb:	39 c2                	cmp    %eax,%edx
  103dfd:	77 09                	ja     103e08 <fetchint+0x18>
    return -1;
  *ip = *(int*)(addr);
  return 0;
  103dff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  103e04:	5d                   	pop    %ebp
  103e05:	c3                   	ret    
  103e06:	66 90                	xchg   %ax,%ax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103e08:	8d 48 04             	lea    0x4(%eax),%ecx
  103e0b:	39 ca                	cmp    %ecx,%edx
  103e0d:	72 f0                	jb     103dff <fetchint+0xf>
    return -1;
  *ip = *(int*)(addr);
  103e0f:	8b 10                	mov    (%eax),%edx
  103e11:	8b 45 10             	mov    0x10(%ebp),%eax
  103e14:	89 10                	mov    %edx,(%eax)
  103e16:	31 c0                	xor    %eax,%eax
  return 0;
}
  103e18:	5d                   	pop    %ebp
  103e19:	c3                   	ret    
  103e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00103e20 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  103e20:	55                   	push   %ebp
  103e21:	89 e5                	mov    %esp,%ebp
  103e23:	8b 45 08             	mov    0x8(%ebp),%eax
  103e26:	8b 55 0c             	mov    0xc(%ebp),%edx
  103e29:	53                   	push   %ebx
  char *s, *ep;

  if(addr >= p->sz)
  103e2a:	39 10                	cmp    %edx,(%eax)
  103e2c:	77 0a                	ja     103e38 <fetchstr+0x18>
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  103e2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    if(*s == 0)
      return s - *pp;
  return -1;
}
  103e33:	5b                   	pop    %ebx
  103e34:	5d                   	pop    %ebp
  103e35:	c3                   	ret    
  103e36:	66 90                	xchg   %ax,%ax
{
  char *s, *ep;

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  103e38:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103e3b:	89 11                	mov    %edx,(%ecx)
  ep = (char*)p->sz;
  103e3d:	8b 18                	mov    (%eax),%ebx
  for(s = *pp; s < ep; s++)
  103e3f:	39 da                	cmp    %ebx,%edx
  103e41:	73 eb                	jae    103e2e <fetchstr+0xe>
    if(*s == 0)
  103e43:	31 c0                	xor    %eax,%eax
  103e45:	89 d1                	mov    %edx,%ecx
  103e47:	80 3a 00             	cmpb   $0x0,(%edx)
  103e4a:	74 e7                	je     103e33 <fetchstr+0x13>
  103e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  103e50:	83 c1 01             	add    $0x1,%ecx
  103e53:	39 cb                	cmp    %ecx,%ebx
  103e55:	76 d7                	jbe    103e2e <fetchstr+0xe>
    if(*s == 0)
  103e57:	80 39 00             	cmpb   $0x0,(%ecx)
  103e5a:	75 f4                	jne    103e50 <fetchstr+0x30>
  103e5c:	89 c8                	mov    %ecx,%eax
  103e5e:	29 d0                	sub    %edx,%eax
  103e60:	eb d1                	jmp    103e33 <fetchstr+0x13>
  103e62:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  103e69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103e70 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103e70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  103e76:	55                   	push   %ebp
  103e77:	89 e5                	mov    %esp,%ebp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103e79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103e7c:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103e7f:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103e81:	8b 52 44             	mov    0x44(%edx),%edx
  103e84:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103e88:	39 c2                	cmp    %eax,%edx
  103e8a:	72 0c                	jb     103e98 <argint+0x28>
    return -1;
  *ip = *(int*)(addr);
  103e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  103e91:	5d                   	pop    %ebp
  103e92:	c3                   	ret    
  103e93:	90                   	nop
  103e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103e98:	8d 4a 04             	lea    0x4(%edx),%ecx
  103e9b:	39 c8                	cmp    %ecx,%eax
  103e9d:	72 ed                	jb     103e8c <argint+0x1c>
    return -1;
  *ip = *(int*)(addr);
  103e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103ea2:	8b 12                	mov    (%edx),%edx
  103ea4:	89 10                	mov    %edx,(%eax)
  103ea6:	31 c0                	xor    %eax,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  103ea8:	5d                   	pop    %ebp
  103ea9:	c3                   	ret    
  103eaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00103eb0 <argptr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
  103eb6:	55                   	push   %ebp
  103eb7:	89 e5                	mov    %esp,%ebp

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103eb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103ebc:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103ebf:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103ec1:	8b 52 44             	mov    0x44(%edx),%edx
  103ec4:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103ec8:	39 c2                	cmp    %eax,%edx
  103eca:	73 07                	jae    103ed3 <argptr+0x23>
  103ecc:	8d 4a 04             	lea    0x4(%edx),%ecx
  103ecf:	39 c8                	cmp    %ecx,%eax
  103ed1:	73 0d                	jae    103ee0 <argptr+0x30>
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
    return -1;
  *pp = (char*)i;
  return 0;
  103ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  103ed8:	5d                   	pop    %ebp
  103ed9:	c3                   	ret    
  103eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  103ee0:	8b 12                	mov    (%edx),%edx
{
  int i;
  
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
  103ee2:	39 c2                	cmp    %eax,%edx
  103ee4:	73 ed                	jae    103ed3 <argptr+0x23>
  103ee6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103ee9:	01 d1                	add    %edx,%ecx
  103eeb:	39 c1                	cmp    %eax,%ecx
  103eed:	77 e4                	ja     103ed3 <argptr+0x23>
    return -1;
  *pp = (char*)i;
  103eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  103ef2:	89 10                	mov    %edx,(%eax)
  103ef4:	31 c0                	xor    %eax,%eax
  return 0;
}
  103ef6:	5d                   	pop    %ebp
  103ef7:	c3                   	ret    
  103ef8:	90                   	nop
  103ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103f00 <argstr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103f00:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
  103f07:	55                   	push   %ebp
  103f08:	89 e5                	mov    %esp,%ebp
  103f0a:	53                   	push   %ebx

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  103f0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103f0e:	8b 42 18             	mov    0x18(%edx),%eax
  103f11:	8b 40 44             	mov    0x44(%eax),%eax
  103f14:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  103f18:	8b 0a                	mov    (%edx),%ecx
  103f1a:	39 c8                	cmp    %ecx,%eax
  103f1c:	73 07                	jae    103f25 <argstr+0x25>
  103f1e:	8d 58 04             	lea    0x4(%eax),%ebx
  103f21:	39 d9                	cmp    %ebx,%ecx
  103f23:	73 0b                	jae    103f30 <argstr+0x30>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  103f25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  103f2a:	5b                   	pop    %ebx
  103f2b:	5d                   	pop    %ebp
  103f2c:	c3                   	ret    
  103f2d:	8d 76 00             	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  103f30:	8b 18                	mov    (%eax),%ebx
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  char *s, *ep;

  if(addr >= p->sz)
  103f32:	39 cb                	cmp    %ecx,%ebx
  103f34:	73 ef                	jae    103f25 <argstr+0x25>
    return -1;
  *pp = (char*)addr;
  103f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  103f39:	89 d8                	mov    %ebx,%eax
  103f3b:	89 19                	mov    %ebx,(%ecx)
  ep = (char*)p->sz;
  103f3d:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
  103f3f:	39 d3                	cmp    %edx,%ebx
  103f41:	73 e2                	jae    103f25 <argstr+0x25>
    if(*s == 0)
  103f43:	80 3b 00             	cmpb   $0x0,(%ebx)
  103f46:	75 12                	jne    103f5a <argstr+0x5a>
  103f48:	eb 1e                	jmp    103f68 <argstr+0x68>
  103f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103f50:	80 38 00             	cmpb   $0x0,(%eax)
  103f53:	90                   	nop
  103f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103f58:	74 0e                	je     103f68 <argstr+0x68>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  103f5a:	83 c0 01             	add    $0x1,%eax
  103f5d:	39 c2                	cmp    %eax,%edx
  103f5f:	90                   	nop
  103f60:	77 ee                	ja     103f50 <argstr+0x50>
  103f62:	eb c1                	jmp    103f25 <argstr+0x25>
  103f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
      return s - *pp;
  103f68:	29 d8                	sub    %ebx,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  103f6a:	5b                   	pop    %ebx
  103f6b:	5d                   	pop    %ebp
  103f6c:	c3                   	ret    
  103f6d:	8d 76 00             	lea    0x0(%esi),%esi

00103f70 <getcountinit>:

// Check if initialized
int init = 0;

// Initializes data structures for getcount()
void getcountinit() {
  103f70:	55                   	push   %ebp
  103f71:	89 e5                	mov    %esp,%ebp
  103f73:	83 ec 18             	sub    $0x18,%esp
  initlock(&lock, "getcount lock");
  103f76:	c7 44 24 04 aa 6b 10 	movl   $0x106baa,0x4(%esp)
  103f7d:	00 
  103f7e:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  103f85:	e8 16 fa ff ff       	call   1039a0 <initlock>
  init = 1;
  103f8a:	c7 05 cc 78 10 00 01 	movl   $0x1,0x1078cc
  103f91:	00 00 00 
}
  103f94:	c9                   	leave  
  103f95:	c3                   	ret    
  103f96:	8d 76 00             	lea    0x0(%esi),%esi
  103f99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103fa0 <syscall>:
[SYS_getcount] getcount,
};

void
syscall(void)
{
  103fa0:	55                   	push   %ebp
  103fa1:	89 e5                	mov    %esp,%ebp
  103fa3:	53                   	push   %ebx
  103fa4:	83 ec 14             	sub    $0x14,%esp
  if (init == 0) {
  103fa7:	a1 cc 78 10 00       	mov    0x1078cc,%eax
  103fac:	85 c0                	test   %eax,%eax
  103fae:	0f 84 94 00 00 00    	je     104048 <syscall+0xa8>
    getcountinit();
    init = 1;
  }
  int num;

  num = proc->tf->eax;
  103fb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103fba:	8b 40 18             	mov    0x18(%eax),%eax
  103fbd:	8b 58 1c             	mov    0x1c(%eax),%ebx
  acquire(&lock);
  103fc0:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  103fc7:	e8 64 fb ff ff       	call   103b30 <acquire>
  updatecount(num);
  103fcc:	89 1c 24             	mov    %ebx,(%esp)
  103fcf:	e8 8c 00 00 00       	call   104060 <updatecount>
  release(&lock);
  103fd4:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  103fdb:	e8 00 fb ff ff       	call   103ae0 <release>
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
  103fe0:	83 fb 16             	cmp    $0x16,%ebx
  103fe3:	77 23                	ja     104008 <syscall+0x68>
  103fe5:	8b 04 9d e0 6b 10 00 	mov    0x106be0(,%ebx,4),%eax
  103fec:	85 c0                	test   %eax,%eax
  103fee:	74 18                	je     104008 <syscall+0x68>
    proc->tf->eax = syscalls[num]();
  103ff0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103ff7:	8b 5a 18             	mov    0x18(%edx),%ebx
  103ffa:	ff d0                	call   *%eax
  103ffc:	89 43 1c             	mov    %eax,0x1c(%ebx)
  else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
  103fff:	83 c4 14             	add    $0x14,%esp
  104002:	5b                   	pop    %ebx
  104003:	5d                   	pop    %ebp
  104004:	c3                   	ret    
  104005:	8d 76 00             	lea    0x0(%esi),%esi
  release(&lock);
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
    proc->tf->eax = syscalls[num]();
  else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
  104008:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  updatecount(num);
  release(&lock);
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
    proc->tf->eax = syscalls[num]();
  else {
    cprintf("%d %s: unknown sys call %d\n",
  10400e:	8b 50 10             	mov    0x10(%eax),%edx
  104011:	83 c0 6c             	add    $0x6c,%eax
  104014:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104018:	89 44 24 08          	mov    %eax,0x8(%esp)
  10401c:	c7 04 24 b8 6b 10 00 	movl   $0x106bb8,(%esp)
  104023:	89 54 24 04          	mov    %edx,0x4(%esp)
  104027:	e8 04 c5 ff ff       	call   100530 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  10402c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104032:	8b 40 18             	mov    0x18(%eax),%eax
  104035:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
  10403c:	83 c4 14             	add    $0x14,%esp
  10403f:	5b                   	pop    %ebx
  104040:	5d                   	pop    %ebp
  104041:	c3                   	ret    
  104042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

void
syscall(void)
{
  if (init == 0) {
    getcountinit();
  104048:	e8 23 ff ff ff       	call   103f70 <getcountinit>
    init = 1;
  10404d:	c7 05 cc 78 10 00 01 	movl   $0x1,0x1078cc
  104054:	00 00 00 
  104057:	e9 58 ff ff ff       	jmp    103fb4 <syscall+0x14>
  10405c:	90                   	nop
  10405d:	90                   	nop
  10405e:	90                   	nop
  10405f:	90                   	nop

00104060 <updatecount>:
int count_array[23];
int inits = 0;

void
updatecount(int syscall) {
  if (inits == 0) {
  104060:	a1 d0 78 10 00       	mov    0x1078d0,%eax

int count_array[23];
int inits = 0;

void
updatecount(int syscall) {
  104065:	55                   	push   %ebp
  104066:	89 e5                	mov    %esp,%ebp
  104068:	8b 55 08             	mov    0x8(%ebp),%edx
  if (inits == 0) {
  10406b:	85 c0                	test   %eax,%eax
  10406d:	75 1c                	jne    10408b <updatecount+0x2b>
  10406f:	31 c0                	xor    %eax,%eax
  104071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    int i;
    for (i = 0; i < 23; i++) {
      count_array[i] = 0;
  104078:	c7 04 85 a0 e0 10 00 	movl   $0x0,0x10e0a0(,%eax,4)
  10407f:	00 00 00 00 

void
updatecount(int syscall) {
  if (inits == 0) {
    int i;
    for (i = 0; i < 23; i++) {
  104083:	83 c0 01             	add    $0x1,%eax
  104086:	83 f8 17             	cmp    $0x17,%eax
  104089:	75 ed                	jne    104078 <updatecount+0x18>
      count_array[i] = 0;
     }
  }
  inits = 1;
  10408b:	c7 05 d0 78 10 00 01 	movl   $0x1,0x1078d0
  104092:	00 00 00 
  count_array[syscall]++;
  104095:	83 04 95 a0 e0 10 00 	addl   $0x1,0x10e0a0(,%edx,4)
  10409c:	01 
}
  10409d:	5d                   	pop    %ebp
  10409e:	c3                   	ret    
  10409f:	90                   	nop

001040a0 <getcount>:

int
getcount(void)
{
  1040a0:	55                   	push   %ebp
  1040a1:	89 e5                	mov    %esp,%ebp
  1040a3:	83 ec 28             	sub    $0x28,%esp
  int *counts; //Passed in pointer
  int size;
  if(argint(1, &size) < 0 || argptr(0, (void*)&counts, size) < 0)
  1040a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1040a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1040ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1040b4:	e8 b7 fd ff ff       	call   103e70 <argint>
  1040b9:	85 c0                	test   %eax,%eax
  1040bb:	79 0b                	jns    1040c8 <getcount+0x28>
    return -1;
  if (size < 23 || counts == 0) {
    return -1;
  }
  int i;
  for (i = 0; i < 23; i++) {
  1040bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    counts[i] = count_array[i];
  }
  return 0;

}
  1040c2:	c9                   	leave  
  1040c3:	c3                   	ret    
  1040c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
int
getcount(void)
{
  int *counts; //Passed in pointer
  int size;
  if(argint(1, &size) < 0 || argptr(0, (void*)&counts, size) < 0)
  1040c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1040cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1040d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1040d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1040d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1040dd:	e8 ce fd ff ff       	call   103eb0 <argptr>
  1040e2:	85 c0                	test   %eax,%eax
  1040e4:	78 d7                	js     1040bd <getcount+0x1d>
    return -1;
  if (size < 23 || counts == 0) {
  1040e6:	83 7d f0 16          	cmpl   $0x16,-0x10(%ebp)
  1040ea:	7e d1                	jle    1040bd <getcount+0x1d>
  1040ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1040ef:	85 d2                	test   %edx,%edx
  1040f1:	74 ca                	je     1040bd <getcount+0x1d>
  1040f3:	31 c0                	xor    %eax,%eax
  1040f5:	eb 04                	jmp    1040fb <getcount+0x5b>
  1040f7:	90                   	nop
    return -1;
  }
  int i;
  for (i = 0; i < 23; i++) {
  1040f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
    counts[i] = count_array[i];
  1040fb:	8b 88 a0 e0 10 00    	mov    0x10e0a0(%eax),%ecx
  104101:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
  104104:	83 c0 04             	add    $0x4,%eax
    return -1;
  if (size < 23 || counts == 0) {
    return -1;
  }
  int i;
  for (i = 0; i < 23; i++) {
  104107:	83 f8 5c             	cmp    $0x5c,%eax
  10410a:	75 ec                	jne    1040f8 <getcount+0x58>
  10410c:	30 c0                	xor    %al,%al
    counts[i] = count_array[i];
  }
  return 0;

}
  10410e:	c9                   	leave  
  10410f:	c3                   	ret    

00104110 <sys_pipe>:
  return exec(path, argv);
}

int
sys_pipe(void)
{
  104110:	55                   	push   %ebp
  104111:	89 e5                	mov    %esp,%ebp
  104113:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  104116:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return exec(path, argv);
}

int
sys_pipe(void)
{
  104119:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  10411c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  10411f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  104126:	00 
  104127:	89 44 24 04          	mov    %eax,0x4(%esp)
  10412b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104132:	e8 79 fd ff ff       	call   103eb0 <argptr>
  104137:	85 c0                	test   %eax,%eax
  104139:	79 15                	jns    104150 <sys_pipe+0x40>
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  10413b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
}
  104140:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  104143:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104146:	89 ec                	mov    %ebp,%esp
  104148:	5d                   	pop    %ebp
  104149:	c3                   	ret    
  10414a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
  104150:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104153:	89 44 24 04          	mov    %eax,0x4(%esp)
  104157:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10415a:	89 04 24             	mov    %eax,(%esp)
  10415d:	e8 8e ed ff ff       	call   102ef0 <pipealloc>
  104162:	85 c0                	test   %eax,%eax
  104164:	78 d5                	js     10413b <sys_pipe+0x2b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  104166:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  104169:	31 c0                	xor    %eax,%eax
  10416b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104178:	8b 5c 82 28          	mov    0x28(%edx,%eax,4),%ebx
  10417c:	85 db                	test   %ebx,%ebx
  10417e:	74 28                	je     1041a8 <sys_pipe+0x98>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104180:	83 c0 01             	add    $0x1,%eax
  104183:	83 f8 10             	cmp    $0x10,%eax
  104186:	75 f0                	jne    104178 <sys_pipe+0x68>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
  104188:	89 0c 24             	mov    %ecx,(%esp)
  10418b:	e8 f0 cd ff ff       	call   100f80 <fileclose>
    fileclose(wf);
  104190:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104193:	89 04 24             	mov    %eax,(%esp)
  104196:	e8 e5 cd ff ff       	call   100f80 <fileclose>
  10419b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  1041a0:	eb 9e                	jmp    104140 <sys_pipe+0x30>
  1041a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1041a8:	8d 58 08             	lea    0x8(%eax),%ebx
  1041ab:	89 4c 9a 08          	mov    %ecx,0x8(%edx,%ebx,4)
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  1041af:	8b 75 ec             	mov    -0x14(%ebp),%esi
  1041b2:	31 d2                	xor    %edx,%edx
  1041b4:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  1041bb:	90                   	nop
  1041bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  1041c0:	83 7c 91 28 00       	cmpl   $0x0,0x28(%ecx,%edx,4)
  1041c5:	74 19                	je     1041e0 <sys_pipe+0xd0>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  1041c7:	83 c2 01             	add    $0x1,%edx
  1041ca:	83 fa 10             	cmp    $0x10,%edx
  1041cd:	75 f1                	jne    1041c0 <sys_pipe+0xb0>
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
  1041cf:	c7 44 99 08 00 00 00 	movl   $0x0,0x8(%ecx,%ebx,4)
  1041d6:	00 
  1041d7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1041da:	eb ac                	jmp    104188 <sys_pipe+0x78>
  1041dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1041e0:	89 74 91 28          	mov    %esi,0x28(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
  1041e4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1041e7:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
  1041e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1041ec:	89 50 04             	mov    %edx,0x4(%eax)
  1041ef:	31 c0                	xor    %eax,%eax
  return 0;
  1041f1:	e9 4a ff ff ff       	jmp    104140 <sys_pipe+0x30>
  1041f6:	8d 76 00             	lea    0x0(%esi),%esi
  1041f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104200 <sys_exec>:
  return 0;
}

int
sys_exec(void)
{
  104200:	55                   	push   %ebp
  104201:	89 e5                	mov    %esp,%ebp
  104203:	81 ec b8 00 00 00    	sub    $0xb8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  104209:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 0;
}

int
sys_exec(void)
{
  10420c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  10420f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  104212:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  104215:	89 44 24 04          	mov    %eax,0x4(%esp)
  104219:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104220:	e8 db fc ff ff       	call   103f00 <argstr>
  104225:	85 c0                	test   %eax,%eax
  104227:	79 17                	jns    104240 <sys_exec+0x40>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv))
  104229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
}
  10422e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  104231:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104234:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104237:	89 ec                	mov    %ebp,%esp
  104239:	5d                   	pop    %ebp
  10423a:	c3                   	ret    
  10423b:	90                   	nop
  10423c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  104240:	8d 45 e0             	lea    -0x20(%ebp),%eax
  104243:	89 44 24 04          	mov    %eax,0x4(%esp)
  104247:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10424e:	e8 1d fc ff ff       	call   103e70 <argint>
  104253:	85 c0                	test   %eax,%eax
  104255:	78 d2                	js     104229 <sys_exec+0x29>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  104257:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  10425d:	31 f6                	xor    %esi,%esi
  10425f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  104266:	00 
  104267:	31 db                	xor    %ebx,%ebx
  104269:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104270:	00 
  104271:	89 3c 24             	mov    %edi,(%esp)
  104274:	e8 57 f9 ff ff       	call   103bd0 <memset>
  104279:	eb 2c                	jmp    1042a7 <sys_exec+0xa7>
  10427b:	90                   	nop
  10427c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
  104280:	89 44 24 04          	mov    %eax,0x4(%esp)
  104284:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10428a:	8d 14 b7             	lea    (%edi,%esi,4),%edx
  10428d:	89 54 24 08          	mov    %edx,0x8(%esp)
  104291:	89 04 24             	mov    %eax,(%esp)
  104294:	e8 87 fb ff ff       	call   103e20 <fetchstr>
  104299:	85 c0                	test   %eax,%eax
  10429b:	78 8c                	js     104229 <sys_exec+0x29>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  10429d:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
  1042a0:	83 fb 20             	cmp    $0x20,%ebx

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  1042a3:	89 de                	mov    %ebx,%esi
    if(i >= NELEM(argv))
  1042a5:	74 82                	je     104229 <sys_exec+0x29>
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
  1042a7:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1042aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  1042ae:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  1042b5:	03 45 e0             	add    -0x20(%ebp),%eax
  1042b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1042bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1042c2:	89 04 24             	mov    %eax,(%esp)
  1042c5:	e8 26 fb ff ff       	call   103df0 <fetchint>
  1042ca:	85 c0                	test   %eax,%eax
  1042cc:	0f 88 57 ff ff ff    	js     104229 <sys_exec+0x29>
      return -1;
    if(uarg == 0){
  1042d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1042d5:	85 c0                	test   %eax,%eax
  1042d7:	75 a7                	jne    104280 <sys_exec+0x80>
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  1042d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
  1042dc:	c7 84 9d 5c ff ff ff 	movl   $0x0,-0xa4(%ebp,%ebx,4)
  1042e3:	00 00 00 00 
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  1042e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1042eb:	89 04 24             	mov    %eax,(%esp)
  1042ee:	e8 ad c6 ff ff       	call   1009a0 <exec>
  1042f3:	e9 36 ff ff ff       	jmp    10422e <sys_exec+0x2e>
  1042f8:	90                   	nop
  1042f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104300 <sys_chdir>:
  return 0;
}

int
sys_chdir(void)
{
  104300:	55                   	push   %ebp
  104301:	89 e5                	mov    %esp,%ebp
  104303:	53                   	push   %ebx
  104304:	83 ec 24             	sub    $0x24,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  104307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10430a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10430e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104315:	e8 e6 fb ff ff       	call   103f00 <argstr>
  10431a:	85 c0                	test   %eax,%eax
  10431c:	79 12                	jns    104330 <sys_chdir+0x30>
    return -1;
  }
  iunlock(ip);
  iput(proc->cwd);
  proc->cwd = ip;
  return 0;
  10431e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104323:	83 c4 24             	add    $0x24,%esp
  104326:	5b                   	pop    %ebx
  104327:	5d                   	pop    %ebp
  104328:	c3                   	ret    
  104329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
sys_chdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  104330:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104333:	89 04 24             	mov    %eax,(%esp)
  104336:	e8 15 db ff ff       	call   101e50 <namei>
  10433b:	85 c0                	test   %eax,%eax
  10433d:	89 c3                	mov    %eax,%ebx
  10433f:	74 dd                	je     10431e <sys_chdir+0x1e>
    return -1;
  ilock(ip);
  104341:	89 04 24             	mov    %eax,(%esp)
  104344:	e8 67 d8 ff ff       	call   101bb0 <ilock>
  if(ip->type != T_DIR){
  104349:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10434e:	75 26                	jne    104376 <sys_chdir+0x76>
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  104350:	89 1c 24             	mov    %ebx,(%esp)
  104353:	e8 18 d4 ff ff       	call   101770 <iunlock>
  iput(proc->cwd);
  104358:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10435e:	8b 40 68             	mov    0x68(%eax),%eax
  104361:	89 04 24             	mov    %eax,(%esp)
  104364:	e8 17 d5 ff ff       	call   101880 <iput>
  proc->cwd = ip;
  104369:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10436f:	89 58 68             	mov    %ebx,0x68(%eax)
  104372:	31 c0                	xor    %eax,%eax
  return 0;
  104374:	eb ad                	jmp    104323 <sys_chdir+0x23>

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
    return -1;
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
  104376:	89 1c 24             	mov    %ebx,(%esp)
  104379:	e8 42 d7 ff ff       	call   101ac0 <iunlockput>
  10437e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104383:	eb 9e                	jmp    104323 <sys_chdir+0x23>
  104385:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104389:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104390 <create>:
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104390:	55                   	push   %ebp
  104391:	89 e5                	mov    %esp,%ebp
  104393:	83 ec 58             	sub    $0x58,%esp
  104396:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  104399:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10439c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  10439f:	8d 75 d6             	lea    -0x2a(%ebp),%esi
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  1043a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  1043a5:	31 db                	xor    %ebx,%ebx
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  1043a7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  1043aa:	89 d7                	mov    %edx,%edi
  1043ac:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  1043af:	89 74 24 04          	mov    %esi,0x4(%esp)
  1043b3:	89 04 24             	mov    %eax,(%esp)
  1043b6:	e8 75 da ff ff       	call   101e30 <nameiparent>
  1043bb:	85 c0                	test   %eax,%eax
  1043bd:	74 47                	je     104406 <create+0x76>
    return 0;
  ilock(dp);
  1043bf:	89 04 24             	mov    %eax,(%esp)
  1043c2:	89 45 bc             	mov    %eax,-0x44(%ebp)
  1043c5:	e8 e6 d7 ff ff       	call   101bb0 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
  1043ca:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1043cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1043d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1043d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  1043d8:	89 14 24             	mov    %edx,(%esp)
  1043db:	e8 90 d2 ff ff       	call   101670 <dirlookup>
  1043e0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1043e3:	85 c0                	test   %eax,%eax
  1043e5:	89 c3                	mov    %eax,%ebx
  1043e7:	74 3f                	je     104428 <create+0x98>
    iunlockput(dp);
  1043e9:	89 14 24             	mov    %edx,(%esp)
  1043ec:	e8 cf d6 ff ff       	call   101ac0 <iunlockput>
    ilock(ip);
  1043f1:	89 1c 24             	mov    %ebx,(%esp)
  1043f4:	e8 b7 d7 ff ff       	call   101bb0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
  1043f9:	66 83 ff 02          	cmp    $0x2,%di
  1043fd:	75 19                	jne    104418 <create+0x88>
  1043ff:	66 83 7b 10 02       	cmpw   $0x2,0x10(%ebx)
  104404:	75 12                	jne    104418 <create+0x88>
  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);
  return ip;
}
  104406:	89 d8                	mov    %ebx,%eax
  104408:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10440b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10440e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104411:	89 ec                	mov    %ebp,%esp
  104413:	5d                   	pop    %ebp
  104414:	c3                   	ret    
  104415:	8d 76 00             	lea    0x0(%esi),%esi
  if((ip = dirlookup(dp, name, &off)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
  104418:	89 1c 24             	mov    %ebx,(%esp)
  10441b:	31 db                	xor    %ebx,%ebx
  10441d:	e8 9e d6 ff ff       	call   101ac0 <iunlockput>
    return 0;
  104422:	eb e2                	jmp    104406 <create+0x76>
  104424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

  if((ip = ialloc(dp->dev, type)) == 0)
  104428:	0f bf c7             	movswl %di,%eax
  10442b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10442f:	8b 02                	mov    (%edx),%eax
  104431:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104434:	89 04 24             	mov    %eax,(%esp)
  104437:	e8 a4 d6 ff ff       	call   101ae0 <ialloc>
  10443c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10443f:	85 c0                	test   %eax,%eax
  104441:	89 c3                	mov    %eax,%ebx
  104443:	0f 84 b7 00 00 00    	je     104500 <create+0x170>
    panic("create: ialloc");

  ilock(ip);
  104449:	89 55 bc             	mov    %edx,-0x44(%ebp)
  10444c:	89 04 24             	mov    %eax,(%esp)
  10444f:	e8 5c d7 ff ff       	call   101bb0 <ilock>
  ip->major = major;
  104454:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
  104458:	66 89 43 12          	mov    %ax,0x12(%ebx)
  ip->minor = minor;
  10445c:	0f b7 4d c0          	movzwl -0x40(%ebp),%ecx
  ip->nlink = 1;
  104460:	66 c7 43 16 01 00    	movw   $0x1,0x16(%ebx)
  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");

  ilock(ip);
  ip->major = major;
  ip->minor = minor;
  104466:	66 89 4b 14          	mov    %cx,0x14(%ebx)
  ip->nlink = 1;
  iupdate(ip);
  10446a:	89 1c 24             	mov    %ebx,(%esp)
  10446d:	e8 fe cf ff ff       	call   101470 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
  104472:	66 83 ff 01          	cmp    $0x1,%di
  104476:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104479:	74 2d                	je     1044a8 <create+0x118>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
  10447b:	8b 43 04             	mov    0x4(%ebx),%eax
  10447e:	89 14 24             	mov    %edx,(%esp)
  104481:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104484:	89 74 24 04          	mov    %esi,0x4(%esp)
  104488:	89 44 24 08          	mov    %eax,0x8(%esp)
  10448c:	e8 3f d5 ff ff       	call   1019d0 <dirlink>
  104491:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104494:	85 c0                	test   %eax,%eax
  104496:	78 74                	js     10450c <create+0x17c>
    panic("create: dirlink");

  iunlockput(dp);
  104498:	89 14 24             	mov    %edx,(%esp)
  10449b:	e8 20 d6 ff ff       	call   101ac0 <iunlockput>
  return ip;
  1044a0:	e9 61 ff ff ff       	jmp    104406 <create+0x76>
  1044a5:	8d 76 00             	lea    0x0(%esi),%esi
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
  1044a8:	66 83 42 16 01       	addw   $0x1,0x16(%edx)
    iupdate(dp);
  1044ad:	89 14 24             	mov    %edx,(%esp)
  1044b0:	89 55 bc             	mov    %edx,-0x44(%ebp)
  1044b3:	e8 b8 cf ff ff       	call   101470 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
  1044b8:	8b 43 04             	mov    0x4(%ebx),%eax
  1044bb:	c7 44 24 04 4c 6c 10 	movl   $0x106c4c,0x4(%esp)
  1044c2:	00 
  1044c3:	89 1c 24             	mov    %ebx,(%esp)
  1044c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1044ca:	e8 01 d5 ff ff       	call   1019d0 <dirlink>
  1044cf:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1044d2:	85 c0                	test   %eax,%eax
  1044d4:	78 1e                	js     1044f4 <create+0x164>
  1044d6:	8b 42 04             	mov    0x4(%edx),%eax
  1044d9:	c7 44 24 04 4b 6c 10 	movl   $0x106c4b,0x4(%esp)
  1044e0:	00 
  1044e1:	89 1c 24             	mov    %ebx,(%esp)
  1044e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1044e8:	e8 e3 d4 ff ff       	call   1019d0 <dirlink>
  1044ed:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1044f0:	85 c0                	test   %eax,%eax
  1044f2:	79 87                	jns    10447b <create+0xeb>
      panic("create dots");
  1044f4:	c7 04 24 4e 6c 10 00 	movl   $0x106c4e,(%esp)
  1044fb:	e8 20 c4 ff ff       	call   100920 <panic>
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");
  104500:	c7 04 24 3c 6c 10 00 	movl   $0x106c3c,(%esp)
  104507:	e8 14 c4 ff ff       	call   100920 <panic>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");
  10450c:	c7 04 24 5a 6c 10 00 	movl   $0x106c5a,(%esp)
  104513:	e8 08 c4 ff ff       	call   100920 <panic>
  104518:	90                   	nop
  104519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104520 <sys_mknod>:
  return 0;
}

int
sys_mknod(void)
{
  104520:	55                   	push   %ebp
  104521:	89 e5                	mov    %esp,%ebp
  104523:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  104526:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104529:	89 44 24 04          	mov    %eax,0x4(%esp)
  10452d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104534:	e8 c7 f9 ff ff       	call   103f00 <argstr>
  104539:	85 c0                	test   %eax,%eax
  10453b:	79 0b                	jns    104548 <sys_mknod+0x28>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  return 0;
  10453d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104542:	c9                   	leave  
  104543:	c3                   	ret    
  104544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
  104548:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10454b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10454f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104556:	e8 15 f9 ff ff       	call   103e70 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10455b:	85 c0                	test   %eax,%eax
  10455d:	78 de                	js     10453d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
  10455f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104562:	89 44 24 04          	mov    %eax,0x4(%esp)
  104566:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10456d:	e8 fe f8 ff ff       	call   103e70 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  104572:	85 c0                	test   %eax,%eax
  104574:	78 c7                	js     10453d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
  104576:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
  10457a:	ba 03 00 00 00       	mov    $0x3,%edx
  10457f:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
  104583:	89 04 24             	mov    %eax,(%esp)
  104586:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104589:	e8 02 fe ff ff       	call   104390 <create>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10458e:	85 c0                	test   %eax,%eax
  104590:	74 ab                	je     10453d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  104592:	89 04 24             	mov    %eax,(%esp)
  104595:	e8 26 d5 ff ff       	call   101ac0 <iunlockput>
  10459a:	31 c0                	xor    %eax,%eax
  return 0;
}
  10459c:	c9                   	leave  
  10459d:	c3                   	ret    
  10459e:	66 90                	xchg   %ax,%ax

001045a0 <sys_mkdir>:
  return fd;
}

int
sys_mkdir(void)
{
  1045a0:	55                   	push   %ebp
  1045a1:	89 e5                	mov    %esp,%ebp
  1045a3:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  1045a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1045a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1045ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1045b4:	e8 47 f9 ff ff       	call   103f00 <argstr>
  1045b9:	85 c0                	test   %eax,%eax
  1045bb:	79 0b                	jns    1045c8 <sys_mkdir+0x28>
    return -1;
  iunlockput(ip);
  return 0;
  1045bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1045c2:	c9                   	leave  
  1045c3:	c3                   	ret    
  1045c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_mkdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  1045c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1045cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045d2:	31 c9                	xor    %ecx,%ecx
  1045d4:	ba 01 00 00 00       	mov    $0x1,%edx
  1045d9:	e8 b2 fd ff ff       	call   104390 <create>
  1045de:	85 c0                	test   %eax,%eax
  1045e0:	74 db                	je     1045bd <sys_mkdir+0x1d>
    return -1;
  iunlockput(ip);
  1045e2:	89 04 24             	mov    %eax,(%esp)
  1045e5:	e8 d6 d4 ff ff       	call   101ac0 <iunlockput>
  1045ea:	31 c0                	xor    %eax,%eax
  return 0;
}
  1045ec:	c9                   	leave  
  1045ed:	c3                   	ret    
  1045ee:	66 90                	xchg   %ax,%ax

001045f0 <sys_link>:
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1045f0:	55                   	push   %ebp
  1045f1:	89 e5                	mov    %esp,%ebp
  1045f3:	83 ec 48             	sub    $0x48,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1045f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1045f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1045fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1045ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  104602:	89 44 24 04          	mov    %eax,0x4(%esp)
  104606:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10460d:	e8 ee f8 ff ff       	call   103f00 <argstr>
  104612:	85 c0                	test   %eax,%eax
  104614:	79 12                	jns    104628 <sys_link+0x38>
bad:
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return -1;
  104616:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10461b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10461e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104621:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104624:	89 ec                	mov    %ebp,%esp
  104626:	5d                   	pop    %ebp
  104627:	c3                   	ret    
sys_link(void)
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  104628:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  10462b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10462f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104636:	e8 c5 f8 ff ff       	call   103f00 <argstr>
  10463b:	85 c0                	test   %eax,%eax
  10463d:	78 d7                	js     104616 <sys_link+0x26>
    return -1;
  if((ip = namei(old)) == 0)
  10463f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104642:	89 04 24             	mov    %eax,(%esp)
  104645:	e8 06 d8 ff ff       	call   101e50 <namei>
  10464a:	85 c0                	test   %eax,%eax
  10464c:	89 c3                	mov    %eax,%ebx
  10464e:	74 c6                	je     104616 <sys_link+0x26>
    return -1;
  ilock(ip);
  104650:	89 04 24             	mov    %eax,(%esp)
  104653:	e8 58 d5 ff ff       	call   101bb0 <ilock>
  if(ip->type == T_DIR){
  104658:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10465d:	0f 84 86 00 00 00    	je     1046e9 <sys_link+0xf9>
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  104663:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
  104668:	8d 7d d2             	lea    -0x2e(%ebp),%edi
  if(ip->type == T_DIR){
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  iupdate(ip);
  10466b:	89 1c 24             	mov    %ebx,(%esp)
  10466e:	e8 fd cd ff ff       	call   101470 <iupdate>
  iunlock(ip);
  104673:	89 1c 24             	mov    %ebx,(%esp)
  104676:	e8 f5 d0 ff ff       	call   101770 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
  10467b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10467e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104682:	89 04 24             	mov    %eax,(%esp)
  104685:	e8 a6 d7 ff ff       	call   101e30 <nameiparent>
  10468a:	85 c0                	test   %eax,%eax
  10468c:	89 c6                	mov    %eax,%esi
  10468e:	74 44                	je     1046d4 <sys_link+0xe4>
    goto bad;
  ilock(dp);
  104690:	89 04 24             	mov    %eax,(%esp)
  104693:	e8 18 d5 ff ff       	call   101bb0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
  104698:	8b 06                	mov    (%esi),%eax
  10469a:	3b 03                	cmp    (%ebx),%eax
  10469c:	75 2e                	jne    1046cc <sys_link+0xdc>
  10469e:	8b 43 04             	mov    0x4(%ebx),%eax
  1046a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1046a5:	89 34 24             	mov    %esi,(%esp)
  1046a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1046ac:	e8 1f d3 ff ff       	call   1019d0 <dirlink>
  1046b1:	85 c0                	test   %eax,%eax
  1046b3:	78 17                	js     1046cc <sys_link+0xdc>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
  1046b5:	89 34 24             	mov    %esi,(%esp)
  1046b8:	e8 03 d4 ff ff       	call   101ac0 <iunlockput>
  iput(ip);
  1046bd:	89 1c 24             	mov    %ebx,(%esp)
  1046c0:	e8 bb d1 ff ff       	call   101880 <iput>
  1046c5:	31 c0                	xor    %eax,%eax
  return 0;
  1046c7:	e9 4f ff ff ff       	jmp    10461b <sys_link+0x2b>

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
  1046cc:	89 34 24             	mov    %esi,(%esp)
  1046cf:	e8 ec d3 ff ff       	call   101ac0 <iunlockput>
  iunlockput(dp);
  iput(ip);
  return 0;

bad:
  ilock(ip);
  1046d4:	89 1c 24             	mov    %ebx,(%esp)
  1046d7:	e8 d4 d4 ff ff       	call   101bb0 <ilock>
  ip->nlink--;
  1046dc:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
  1046e1:	89 1c 24             	mov    %ebx,(%esp)
  1046e4:	e8 87 cd ff ff       	call   101470 <iupdate>
  iunlockput(ip);
  1046e9:	89 1c 24             	mov    %ebx,(%esp)
  1046ec:	e8 cf d3 ff ff       	call   101ac0 <iunlockput>
  1046f1:	83 c8 ff             	or     $0xffffffff,%eax
  return -1;
  1046f4:	e9 22 ff ff ff       	jmp    10461b <sys_link+0x2b>
  1046f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104700 <sys_open>:
  return ip;
}

int
sys_open(void)
{
  104700:	55                   	push   %ebp
  104701:	89 e5                	mov    %esp,%ebp
  104703:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  104706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return ip;
}

int
sys_open(void)
{
  104709:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  10470c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  10470f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104713:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10471a:	e8 e1 f7 ff ff       	call   103f00 <argstr>
  10471f:	85 c0                	test   %eax,%eax
  104721:	79 15                	jns    104738 <sys_open+0x38>

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  104723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
}
  104728:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  10472b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  10472e:	89 ec                	mov    %ebp,%esp
  104730:	5d                   	pop    %ebp
  104731:	c3                   	ret    
  104732:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  104738:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10473b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10473f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104746:	e8 25 f7 ff ff       	call   103e70 <argint>
  10474b:	85 c0                	test   %eax,%eax
  10474d:	78 d4                	js     104723 <sys_open+0x23>
    return -1;
  if(omode & O_CREATE){
  10474f:	f6 45 f1 02          	testb  $0x2,-0xf(%ebp)
  104753:	74 63                	je     1047b8 <sys_open+0xb8>
    if((ip = create(path, T_FILE, 0, 0)) == 0)
  104755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104758:	31 c9                	xor    %ecx,%ecx
  10475a:	ba 02 00 00 00       	mov    $0x2,%edx
  10475f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104766:	e8 25 fc ff ff       	call   104390 <create>
  10476b:	85 c0                	test   %eax,%eax
  10476d:	89 c3                	mov    %eax,%ebx
  10476f:	74 b2                	je     104723 <sys_open+0x23>
      iunlockput(ip);
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
  104771:	e8 8a c7 ff ff       	call   100f00 <filealloc>
  104776:	85 c0                	test   %eax,%eax
  104778:	89 c6                	mov    %eax,%esi
  10477a:	74 24                	je     1047a0 <sys_open+0xa0>
  10477c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104783:	31 c0                	xor    %eax,%eax
  104785:	8d 76 00             	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104788:	8b 4c 82 28          	mov    0x28(%edx,%eax,4),%ecx
  10478c:	85 c9                	test   %ecx,%ecx
  10478e:	74 58                	je     1047e8 <sys_open+0xe8>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104790:	83 c0 01             	add    $0x1,%eax
  104793:	83 f8 10             	cmp    $0x10,%eax
  104796:	75 f0                	jne    104788 <sys_open+0x88>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
  104798:	89 34 24             	mov    %esi,(%esp)
  10479b:	e8 e0 c7 ff ff       	call   100f80 <fileclose>
    iunlockput(ip);
  1047a0:	89 1c 24             	mov    %ebx,(%esp)
  1047a3:	e8 18 d3 ff ff       	call   101ac0 <iunlockput>
  1047a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  1047ad:	e9 76 ff ff ff       	jmp    104728 <sys_open+0x28>
  1047b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
  if(omode & O_CREATE){
    if((ip = create(path, T_FILE, 0, 0)) == 0)
      return -1;
  } else {
    if((ip = namei(path)) == 0)
  1047b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047bb:	89 04 24             	mov    %eax,(%esp)
  1047be:	e8 8d d6 ff ff       	call   101e50 <namei>
  1047c3:	85 c0                	test   %eax,%eax
  1047c5:	89 c3                	mov    %eax,%ebx
  1047c7:	0f 84 56 ff ff ff    	je     104723 <sys_open+0x23>
      return -1;
    ilock(ip);
  1047cd:	89 04 24             	mov    %eax,(%esp)
  1047d0:	e8 db d3 ff ff       	call   101bb0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
  1047d5:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  1047da:	75 95                	jne    104771 <sys_open+0x71>
  1047dc:	8b 75 f0             	mov    -0x10(%ebp),%esi
  1047df:	85 f6                	test   %esi,%esi
  1047e1:	74 8e                	je     104771 <sys_open+0x71>
  1047e3:	eb bb                	jmp    1047a0 <sys_open+0xa0>
  1047e5:	8d 76 00             	lea    0x0(%esi),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1047e8:	89 74 82 28          	mov    %esi,0x28(%edx,%eax,4)
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  1047ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1047ef:	89 1c 24             	mov    %ebx,(%esp)
  1047f2:	e8 79 cf ff ff       	call   101770 <iunlock>

  f->type = FD_INODE;
  1047f7:	c7 06 02 00 00 00    	movl   $0x2,(%esi)
  f->ip = ip;
  1047fd:	89 5e 10             	mov    %ebx,0x10(%esi)
  f->off = 0;
  104800:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)
  f->readable = !(omode & O_WRONLY);
  104807:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10480a:	83 f2 01             	xor    $0x1,%edx
  10480d:	83 e2 01             	and    $0x1,%edx
  104810:	88 56 08             	mov    %dl,0x8(%esi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  104813:	f6 45 f0 03          	testb  $0x3,-0x10(%ebp)
  104817:	0f 95 46 09          	setne  0x9(%esi)
  return fd;
  10481b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10481e:	e9 05 ff ff ff       	jmp    104728 <sys_open+0x28>
  104823:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104829:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104830 <sys_unlink>:
  return 1;
}

int
sys_unlink(void)
{
  104830:	55                   	push   %ebp
  104831:	89 e5                	mov    %esp,%ebp
  104833:	83 ec 78             	sub    $0x78,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  104836:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 1;
}

int
sys_unlink(void)
{
  104839:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  10483c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10483f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  104842:	89 44 24 04          	mov    %eax,0x4(%esp)
  104846:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10484d:	e8 ae f6 ff ff       	call   103f00 <argstr>
  104852:	85 c0                	test   %eax,%eax
  104854:	79 12                	jns    104868 <sys_unlink+0x38>
  iunlockput(dp);

  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return 0;
  104856:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10485b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10485e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104861:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104864:	89 ec                	mov    %ebp,%esp
  104866:	5d                   	pop    %ebp
  104867:	c3                   	ret    
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
    return -1;
  if((dp = nameiparent(path, name)) == 0)
  104868:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10486b:	8d 5d d2             	lea    -0x2e(%ebp),%ebx
  10486e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104872:	89 04 24             	mov    %eax,(%esp)
  104875:	e8 b6 d5 ff ff       	call   101e30 <nameiparent>
  10487a:	85 c0                	test   %eax,%eax
  10487c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  10487f:	74 d5                	je     104856 <sys_unlink+0x26>
    return -1;
  ilock(dp);
  104881:	89 04 24             	mov    %eax,(%esp)
  104884:	e8 27 d3 ff ff       	call   101bb0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0){
  104889:	c7 44 24 04 4c 6c 10 	movl   $0x106c4c,0x4(%esp)
  104890:	00 
  104891:	89 1c 24             	mov    %ebx,(%esp)
  104894:	e8 a7 cd ff ff       	call   101640 <namecmp>
  104899:	85 c0                	test   %eax,%eax
  10489b:	0f 84 a4 00 00 00    	je     104945 <sys_unlink+0x115>
  1048a1:	c7 44 24 04 4b 6c 10 	movl   $0x106c4b,0x4(%esp)
  1048a8:	00 
  1048a9:	89 1c 24             	mov    %ebx,(%esp)
  1048ac:	e8 8f cd ff ff       	call   101640 <namecmp>
  1048b1:	85 c0                	test   %eax,%eax
  1048b3:	0f 84 8c 00 00 00    	je     104945 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }

  if((ip = dirlookup(dp, name, &off)) == 0){
  1048b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1048bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  1048c0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1048c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1048c7:	89 04 24             	mov    %eax,(%esp)
  1048ca:	e8 a1 cd ff ff       	call   101670 <dirlookup>
  1048cf:	85 c0                	test   %eax,%eax
  1048d1:	89 c6                	mov    %eax,%esi
  1048d3:	74 70                	je     104945 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }
  ilock(ip);
  1048d5:	89 04 24             	mov    %eax,(%esp)
  1048d8:	e8 d3 d2 ff ff       	call   101bb0 <ilock>

  if(ip->nlink < 1)
  1048dd:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  1048e2:	0f 8e 0e 01 00 00    	jle    1049f6 <sys_unlink+0x1c6>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
  1048e8:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  1048ed:	75 71                	jne    104960 <sys_unlink+0x130>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
  1048ef:	83 7e 18 20          	cmpl   $0x20,0x18(%esi)
  1048f3:	76 6b                	jbe    104960 <sys_unlink+0x130>
  1048f5:	8d 7d b2             	lea    -0x4e(%ebp),%edi
  1048f8:	bb 20 00 00 00       	mov    $0x20,%ebx
  1048fd:	8d 76 00             	lea    0x0(%esi),%esi
  104900:	eb 0e                	jmp    104910 <sys_unlink+0xe0>
  104902:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104908:	83 c3 10             	add    $0x10,%ebx
  10490b:	3b 5e 18             	cmp    0x18(%esi),%ebx
  10490e:	73 50                	jae    104960 <sys_unlink+0x130>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  104910:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  104917:	00 
  104918:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  10491c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104920:	89 34 24             	mov    %esi,(%esp)
  104923:	e8 48 ca ff ff       	call   101370 <readi>
  104928:	83 f8 10             	cmp    $0x10,%eax
  10492b:	0f 85 ad 00 00 00    	jne    1049de <sys_unlink+0x1ae>
      panic("isdirempty: readi");
    if(de.inum != 0)
  104931:	66 83 7d b2 00       	cmpw   $0x0,-0x4e(%ebp)
  104936:	74 d0                	je     104908 <sys_unlink+0xd8>
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
  104938:	89 34 24             	mov    %esi,(%esp)
  10493b:	90                   	nop
  10493c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104940:	e8 7b d1 ff ff       	call   101ac0 <iunlockput>
    iunlockput(dp);
  104945:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104948:	89 04 24             	mov    %eax,(%esp)
  10494b:	e8 70 d1 ff ff       	call   101ac0 <iunlockput>
  104950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104955:	e9 01 ff ff ff       	jmp    10485b <sys_unlink+0x2b>
  10495a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  memset(&de, 0, sizeof(de));
  104960:	8d 5d c2             	lea    -0x3e(%ebp),%ebx
  104963:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  10496a:	00 
  10496b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104972:	00 
  104973:	89 1c 24             	mov    %ebx,(%esp)
  104976:	e8 55 f2 ff ff       	call   103bd0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  10497b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10497e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  104985:	00 
  104986:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10498a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10498e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104991:	89 04 24             	mov    %eax,(%esp)
  104994:	e8 67 cb ff ff       	call   101500 <writei>
  104999:	83 f8 10             	cmp    $0x10,%eax
  10499c:	75 4c                	jne    1049ea <sys_unlink+0x1ba>
    panic("unlink: writei");
  if(ip->type == T_DIR){
  10499e:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  1049a3:	74 27                	je     1049cc <sys_unlink+0x19c>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
  1049a5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1049a8:	89 04 24             	mov    %eax,(%esp)
  1049ab:	e8 10 d1 ff ff       	call   101ac0 <iunlockput>

  ip->nlink--;
  1049b0:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
  iupdate(ip);
  1049b5:	89 34 24             	mov    %esi,(%esp)
  1049b8:	e8 b3 ca ff ff       	call   101470 <iupdate>
  iunlockput(ip);
  1049bd:	89 34 24             	mov    %esi,(%esp)
  1049c0:	e8 fb d0 ff ff       	call   101ac0 <iunlockput>
  1049c5:	31 c0                	xor    %eax,%eax
  return 0;
  1049c7:	e9 8f fe ff ff       	jmp    10485b <sys_unlink+0x2b>

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
  1049cc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1049cf:	66 83 68 16 01       	subw   $0x1,0x16(%eax)
    iupdate(dp);
  1049d4:	89 04 24             	mov    %eax,(%esp)
  1049d7:	e8 94 ca ff ff       	call   101470 <iupdate>
  1049dc:	eb c7                	jmp    1049a5 <sys_unlink+0x175>
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
  1049de:	c7 04 24 7c 6c 10 00 	movl   $0x106c7c,(%esp)
  1049e5:	e8 36 bf ff ff       	call   100920 <panic>
    return -1;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  1049ea:	c7 04 24 8e 6c 10 00 	movl   $0x106c8e,(%esp)
  1049f1:	e8 2a bf ff ff       	call   100920 <panic>
    return -1;
  }
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  1049f6:	c7 04 24 6a 6c 10 00 	movl   $0x106c6a,(%esp)
  1049fd:	e8 1e bf ff ff       	call   100920 <panic>
  104a02:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  104a09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104a10 <T.75>:
#include "sysfile.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  104a10:	55                   	push   %ebp
  104a11:	89 e5                	mov    %esp,%ebp
  104a13:	83 ec 28             	sub    $0x28,%esp
  104a16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  104a19:	89 c3                	mov    %eax,%ebx
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  104a1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
#include "sysfile.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  104a1e:	89 75 fc             	mov    %esi,-0x4(%ebp)
  104a21:	89 d6                	mov    %edx,%esi
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  104a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104a2e:	e8 3d f4 ff ff       	call   103e70 <argint>
  104a33:	85 c0                	test   %eax,%eax
  104a35:	79 11                	jns    104a48 <T.75+0x38>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  104a37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  104a3c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  104a3f:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104a42:	89 ec                	mov    %ebp,%esp
  104a44:	5d                   	pop    %ebp
  104a45:	c3                   	ret    
  104a46:	66 90                	xchg   %ax,%ax
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
  104a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a4b:	83 f8 0f             	cmp    $0xf,%eax
  104a4e:	77 e7                	ja     104a37 <T.75+0x27>
  104a50:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104a57:	8b 54 82 28          	mov    0x28(%edx,%eax,4),%edx
  104a5b:	85 d2                	test   %edx,%edx
  104a5d:	74 d8                	je     104a37 <T.75+0x27>
    return -1;
  if(pfd)
  104a5f:	85 db                	test   %ebx,%ebx
  104a61:	74 02                	je     104a65 <T.75+0x55>
    *pfd = fd;
  104a63:	89 03                	mov    %eax,(%ebx)
  if(pf)
  104a65:	31 c0                	xor    %eax,%eax
  104a67:	85 f6                	test   %esi,%esi
  104a69:	74 d1                	je     104a3c <T.75+0x2c>
    *pf = f;
  104a6b:	89 16                	mov    %edx,(%esi)
  104a6d:	eb cd                	jmp    104a3c <T.75+0x2c>
  104a6f:	90                   	nop

00104a70 <sys_dup>:
  return -1;
}

int
sys_dup(void)
{
  104a70:	55                   	push   %ebp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104a71:	31 c0                	xor    %eax,%eax
  return -1;
}

int
sys_dup(void)
{
  104a73:	89 e5                	mov    %esp,%ebp
  104a75:	53                   	push   %ebx
  104a76:	83 ec 24             	sub    $0x24,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104a79:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104a7c:	e8 8f ff ff ff       	call   104a10 <T.75>
  104a81:	85 c0                	test   %eax,%eax
  104a83:	79 13                	jns    104a98 <sys_dup+0x28>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104a85:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
}
  104a8a:	89 d8                	mov    %ebx,%eax
  104a8c:	83 c4 24             	add    $0x24,%esp
  104a8f:	5b                   	pop    %ebx
  104a90:	5d                   	pop    %ebp
  104a91:	c3                   	ret    
  104a92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
  104a98:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104a9b:	31 db                	xor    %ebx,%ebx
  104a9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104aa3:	eb 0b                	jmp    104ab0 <sys_dup+0x40>
  104aa5:	8d 76 00             	lea    0x0(%esi),%esi
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104aa8:	83 c3 01             	add    $0x1,%ebx
  104aab:	83 fb 10             	cmp    $0x10,%ebx
  104aae:	74 d5                	je     104a85 <sys_dup+0x15>
    if(proc->ofile[fd] == 0){
  104ab0:	8b 4c 98 28          	mov    0x28(%eax,%ebx,4),%ecx
  104ab4:	85 c9                	test   %ecx,%ecx
  104ab6:	75 f0                	jne    104aa8 <sys_dup+0x38>
      proc->ofile[fd] = f;
  104ab8:	89 54 98 28          	mov    %edx,0x28(%eax,%ebx,4)
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  104abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104abf:	89 04 24             	mov    %eax,(%esp)
  104ac2:	e8 e9 c3 ff ff       	call   100eb0 <filedup>
  return fd;
  104ac7:	eb c1                	jmp    104a8a <sys_dup+0x1a>
  104ac9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104ad0 <sys_read>:
}

int
sys_read(void)
{
  104ad0:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104ad1:	31 c0                	xor    %eax,%eax
  return fd;
}

int
sys_read(void)
{
  104ad3:	89 e5                	mov    %esp,%ebp
  104ad5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104ad8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104adb:	e8 30 ff ff ff       	call   104a10 <T.75>
  104ae0:	85 c0                	test   %eax,%eax
  104ae2:	79 0c                	jns    104af0 <sys_read+0x20>
    return -1;
  return fileread(f, p, n);
  104ae4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104ae9:	c9                   	leave  
  104aea:	c3                   	ret    
  104aeb:	90                   	nop
  104aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104af0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104af3:	89 44 24 04          	mov    %eax,0x4(%esp)
  104af7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104afe:	e8 6d f3 ff ff       	call   103e70 <argint>
  104b03:	85 c0                	test   %eax,%eax
  104b05:	78 dd                	js     104ae4 <sys_read+0x14>
  104b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b11:	89 44 24 08          	mov    %eax,0x8(%esp)
  104b15:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  104b1c:	e8 8f f3 ff ff       	call   103eb0 <argptr>
  104b21:	85 c0                	test   %eax,%eax
  104b23:	78 bf                	js     104ae4 <sys_read+0x14>
    return -1;
  return fileread(f, p, n);
  104b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b28:	89 44 24 08          	mov    %eax,0x8(%esp)
  104b2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b36:	89 04 24             	mov    %eax,(%esp)
  104b39:	e8 72 c2 ff ff       	call   100db0 <fileread>
}
  104b3e:	c9                   	leave  
  104b3f:	c3                   	ret    

00104b40 <sys_write>:

int
sys_write(void)
{
  104b40:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104b41:	31 c0                	xor    %eax,%eax
  return fileread(f, p, n);
}

int
sys_write(void)
{
  104b43:	89 e5                	mov    %esp,%ebp
  104b45:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104b48:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104b4b:	e8 c0 fe ff ff       	call   104a10 <T.75>
  104b50:	85 c0                	test   %eax,%eax
  104b52:	79 0c                	jns    104b60 <sys_write+0x20>
    return -1;
  return filewrite(f, p, n);
  104b54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104b59:	c9                   	leave  
  104b5a:	c3                   	ret    
  104b5b:	90                   	nop
  104b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104b60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  104b67:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104b6e:	e8 fd f2 ff ff       	call   103e70 <argint>
  104b73:	85 c0                	test   %eax,%eax
  104b75:	78 dd                	js     104b54 <sys_write+0x14>
  104b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b7a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b81:	89 44 24 08          	mov    %eax,0x8(%esp)
  104b85:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104b88:	89 44 24 04          	mov    %eax,0x4(%esp)
  104b8c:	e8 1f f3 ff ff       	call   103eb0 <argptr>
  104b91:	85 c0                	test   %eax,%eax
  104b93:	78 bf                	js     104b54 <sys_write+0x14>
    return -1;
  return filewrite(f, p, n);
  104b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b98:	89 44 24 08          	mov    %eax,0x8(%esp)
  104b9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ba6:	89 04 24             	mov    %eax,(%esp)
  104ba9:	e8 52 c1 ff ff       	call   100d00 <filewrite>
}
  104bae:	c9                   	leave  
  104baf:	c3                   	ret    

00104bb0 <sys_fstat>:
  return 0;
}

int
sys_fstat(void)
{
  104bb0:	55                   	push   %ebp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104bb1:	31 c0                	xor    %eax,%eax
  return 0;
}

int
sys_fstat(void)
{
  104bb3:	89 e5                	mov    %esp,%ebp
  104bb5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104bb8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104bbb:	e8 50 fe ff ff       	call   104a10 <T.75>
  104bc0:	85 c0                	test   %eax,%eax
  104bc2:	79 0c                	jns    104bd0 <sys_fstat+0x20>
    return -1;
  return filestat(f, st);
  104bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104bc9:	c9                   	leave  
  104bca:	c3                   	ret    
  104bcb:	90                   	nop
  104bcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_fstat(void)
{
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104bd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104bd3:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  104bda:	00 
  104bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  104bdf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104be6:	e8 c5 f2 ff ff       	call   103eb0 <argptr>
  104beb:	85 c0                	test   %eax,%eax
  104bed:	78 d5                	js     104bc4 <sys_fstat+0x14>
    return -1;
  return filestat(f, st);
  104bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  104bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bf9:	89 04 24             	mov    %eax,(%esp)
  104bfc:	e8 5f c2 ff ff       	call   100e60 <filestat>
}
  104c01:	c9                   	leave  
  104c02:	c3                   	ret    
  104c03:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104c09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104c10 <sys_close>:
  return filewrite(f, p, n);
}

int
sys_close(void)
{
  104c10:	55                   	push   %ebp
  104c11:	89 e5                	mov    %esp,%ebp
  104c13:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
  104c16:	8d 55 f0             	lea    -0x10(%ebp),%edx
  104c19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104c1c:	e8 ef fd ff ff       	call   104a10 <T.75>
  104c21:	89 c2                	mov    %eax,%edx
  104c23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104c28:	85 d2                	test   %edx,%edx
  104c2a:	78 1e                	js     104c4a <sys_close+0x3a>
    return -1;
  proc->ofile[fd] = 0;
  104c2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104c35:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
  104c3c:	00 
  fileclose(f);
  104c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c40:	89 04 24             	mov    %eax,(%esp)
  104c43:	e8 38 c3 ff ff       	call   100f80 <fileclose>
  104c48:	31 c0                	xor    %eax,%eax
  return 0;
}
  104c4a:	c9                   	leave  
  104c4b:	c3                   	ret    
  104c4c:	90                   	nop
  104c4d:	90                   	nop
  104c4e:	90                   	nop
  104c4f:	90                   	nop

00104c50 <sys_getpid>:
}

int
sys_getpid(void)
{
  return proc->pid;
  104c50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return kill(pid);
}

int
sys_getpid(void)
{
  104c56:	55                   	push   %ebp
  104c57:	89 e5                	mov    %esp,%ebp
  return proc->pid;
}
  104c59:	5d                   	pop    %ebp
}

int
sys_getpid(void)
{
  return proc->pid;
  104c5a:	8b 40 10             	mov    0x10(%eax),%eax
}
  104c5d:	c3                   	ret    
  104c5e:	66 90                	xchg   %ax,%ax

00104c60 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since boot.
int
sys_uptime(void)
{
  104c60:	55                   	push   %ebp
  104c61:	89 e5                	mov    %esp,%ebp
  104c63:	53                   	push   %ebx
  104c64:	83 ec 14             	sub    $0x14,%esp
  uint xticks;
  
  acquire(&tickslock);
  104c67:	c7 04 24 00 e1 10 00 	movl   $0x10e100,(%esp)
  104c6e:	e8 bd ee ff ff       	call   103b30 <acquire>
  xticks = ticks;
  104c73:	8b 1d 40 e9 10 00    	mov    0x10e940,%ebx
  release(&tickslock);
  104c79:	c7 04 24 00 e1 10 00 	movl   $0x10e100,(%esp)
  104c80:	e8 5b ee ff ff       	call   103ae0 <release>
  return xticks;
}
  104c85:	83 c4 14             	add    $0x14,%esp
  104c88:	89 d8                	mov    %ebx,%eax
  104c8a:	5b                   	pop    %ebx
  104c8b:	5d                   	pop    %ebp
  104c8c:	c3                   	ret    
  104c8d:	8d 76 00             	lea    0x0(%esi),%esi

00104c90 <sys_sleep>:
  return addr;
}

int
sys_sleep(void)
{
  104c90:	55                   	push   %ebp
  104c91:	89 e5                	mov    %esp,%ebp
  104c93:	53                   	push   %ebx
  104c94:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
  104c97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104ca5:	e8 c6 f1 ff ff       	call   103e70 <argint>
  104caa:	89 c2                	mov    %eax,%edx
  104cac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104cb1:	85 d2                	test   %edx,%edx
  104cb3:	78 59                	js     104d0e <sys_sleep+0x7e>
    return -1;
  acquire(&tickslock);
  104cb5:	c7 04 24 00 e1 10 00 	movl   $0x10e100,(%esp)
  104cbc:	e8 6f ee ff ff       	call   103b30 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104cc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  104cc4:	8b 1d 40 e9 10 00    	mov    0x10e940,%ebx
  while(ticks - ticks0 < n){
  104cca:	85 d2                	test   %edx,%edx
  104ccc:	75 22                	jne    104cf0 <sys_sleep+0x60>
  104cce:	eb 48                	jmp    104d18 <sys_sleep+0x88>
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  104cd0:	c7 44 24 04 00 e1 10 	movl   $0x10e100,0x4(%esp)
  104cd7:	00 
  104cd8:	c7 04 24 40 e9 10 00 	movl   $0x10e940,(%esp)
  104cdf:	e8 6c e5 ff ff       	call   103250 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104ce4:	a1 40 e9 10 00       	mov    0x10e940,%eax
  104ce9:	29 d8                	sub    %ebx,%eax
  104ceb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104cee:	73 28                	jae    104d18 <sys_sleep+0x88>
    if(proc->killed){
  104cf0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104cf6:	8b 40 24             	mov    0x24(%eax),%eax
  104cf9:	85 c0                	test   %eax,%eax
  104cfb:	74 d3                	je     104cd0 <sys_sleep+0x40>
      release(&tickslock);
  104cfd:	c7 04 24 00 e1 10 00 	movl   $0x10e100,(%esp)
  104d04:	e8 d7 ed ff ff       	call   103ae0 <release>
  104d09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
  104d0e:	83 c4 24             	add    $0x24,%esp
  104d11:	5b                   	pop    %ebx
  104d12:	5d                   	pop    %ebp
  104d13:	c3                   	ret    
  104d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104d18:	c7 04 24 00 e1 10 00 	movl   $0x10e100,(%esp)
  104d1f:	e8 bc ed ff ff       	call   103ae0 <release>
  return 0;
}
  104d24:	83 c4 24             	add    $0x24,%esp
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104d27:	31 c0                	xor    %eax,%eax
  return 0;
}
  104d29:	5b                   	pop    %ebx
  104d2a:	5d                   	pop    %ebp
  104d2b:	c3                   	ret    
  104d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104d30 <sys_sbrk>:
  return proc->pid;
}

int
sys_sbrk(void)
{
  104d30:	55                   	push   %ebp
  104d31:	89 e5                	mov    %esp,%ebp
  104d33:	53                   	push   %ebx
  104d34:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
  104d37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104d45:	e8 26 f1 ff ff       	call   103e70 <argint>
  104d4a:	85 c0                	test   %eax,%eax
  104d4c:	79 12                	jns    104d60 <sys_sbrk+0x30>
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
  104d4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104d53:	83 c4 24             	add    $0x24,%esp
  104d56:	5b                   	pop    %ebx
  104d57:	5d                   	pop    %ebp
  104d58:	c3                   	ret    
  104d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104d60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104d66:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
  104d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d6b:	89 04 24             	mov    %eax,(%esp)
  104d6e:	e8 9d ea ff ff       	call   103810 <growproc>
  104d73:	89 c2                	mov    %eax,%edx
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104d75:	89 d8                	mov    %ebx,%eax
  if(growproc(n) < 0)
  104d77:	85 d2                	test   %edx,%edx
  104d79:	79 d8                	jns    104d53 <sys_sbrk+0x23>
  104d7b:	eb d1                	jmp    104d4e <sys_sbrk+0x1e>
  104d7d:	8d 76 00             	lea    0x0(%esi),%esi

00104d80 <sys_kill>:
  return wait();
}

int
sys_kill(void)
{
  104d80:	55                   	push   %ebp
  104d81:	89 e5                	mov    %esp,%ebp
  104d83:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
  104d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104d89:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104d94:	e8 d7 f0 ff ff       	call   103e70 <argint>
  104d99:	89 c2                	mov    %eax,%edx
  104d9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104da0:	85 d2                	test   %edx,%edx
  104da2:	78 0b                	js     104daf <sys_kill+0x2f>
    return -1;
  return kill(pid);
  104da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104da7:	89 04 24             	mov    %eax,(%esp)
  104daa:	e8 f1 e2 ff ff       	call   1030a0 <kill>
}
  104daf:	c9                   	leave  
  104db0:	c3                   	ret    
  104db1:	eb 0d                	jmp    104dc0 <sys_wait>
  104db3:	90                   	nop
  104db4:	90                   	nop
  104db5:	90                   	nop
  104db6:	90                   	nop
  104db7:	90                   	nop
  104db8:	90                   	nop
  104db9:	90                   	nop
  104dba:	90                   	nop
  104dbb:	90                   	nop
  104dbc:	90                   	nop
  104dbd:	90                   	nop
  104dbe:	90                   	nop
  104dbf:	90                   	nop

00104dc0 <sys_wait>:
  return 0;  // not reached
}

int
sys_wait(void)
{
  104dc0:	55                   	push   %ebp
  104dc1:	89 e5                	mov    %esp,%ebp
  104dc3:	83 ec 08             	sub    $0x8,%esp
  return wait();
}
  104dc6:	c9                   	leave  
}

int
sys_wait(void)
{
  return wait();
  104dc7:	e9 34 e6 ff ff       	jmp    103400 <wait>
  104dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104dd0 <sys_exit>:
  return fork();
}

int
sys_exit(void)
{
  104dd0:	55                   	push   %ebp
  104dd1:	89 e5                	mov    %esp,%ebp
  104dd3:	83 ec 08             	sub    $0x8,%esp
  exit();
  104dd6:	e8 25 e7 ff ff       	call   103500 <exit>
  return 0;  // not reached
}
  104ddb:	31 c0                	xor    %eax,%eax
  104ddd:	c9                   	leave  
  104dde:	c3                   	ret    
  104ddf:	90                   	nop

00104de0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  104de0:	55                   	push   %ebp
  104de1:	89 e5                	mov    %esp,%ebp
  104de3:	83 ec 08             	sub    $0x8,%esp
  return fork();
}
  104de6:	c9                   	leave  
#include "proc.h"

int
sys_fork(void)
{
  return fork();
  104de7:	e9 24 e9 ff ff       	jmp    103710 <fork>
  104dec:	90                   	nop
  104ded:	90                   	nop
  104dee:	90                   	nop
  104def:	90                   	nop

00104df0 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
  104df0:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  104df1:	ba 43 00 00 00       	mov    $0x43,%edx
  104df6:	89 e5                	mov    %esp,%ebp
  104df8:	83 ec 18             	sub    $0x18,%esp
  104dfb:	b8 34 00 00 00       	mov    $0x34,%eax
  104e00:	ee                   	out    %al,(%dx)
  104e01:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
  104e06:	b2 40                	mov    $0x40,%dl
  104e08:	ee                   	out    %al,(%dx)
  104e09:	b8 2e 00 00 00       	mov    $0x2e,%eax
  104e0e:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
  104e0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104e16:	e8 75 dd ff ff       	call   102b90 <picenable>
}
  104e1b:	c9                   	leave  
  104e1c:	c3                   	ret    
  104e1d:	90                   	nop
  104e1e:	90                   	nop
  104e1f:	90                   	nop

00104e20 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
  104e20:	1e                   	push   %ds
  pushl %es
  104e21:	06                   	push   %es
  pushl %fs
  104e22:	0f a0                	push   %fs
  pushl %gs
  104e24:	0f a8                	push   %gs
  pushal
  104e26:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
  104e27:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
  104e2b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
  104e2d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
  104e2f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
  104e33:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
  104e35:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
  104e37:	54                   	push   %esp
  call trap
  104e38:	e8 43 00 00 00       	call   104e80 <trap>
  addl $4, %esp
  104e3d:	83 c4 04             	add    $0x4,%esp

00104e40 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
  104e40:	61                   	popa   
  popl %gs
  104e41:	0f a9                	pop    %gs
  popl %fs
  104e43:	0f a1                	pop    %fs
  popl %es
  104e45:	07                   	pop    %es
  popl %ds
  104e46:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
  104e47:	83 c4 08             	add    $0x8,%esp
  iret
  104e4a:	cf                   	iret   
  104e4b:	90                   	nop
  104e4c:	90                   	nop
  104e4d:	90                   	nop
  104e4e:	90                   	nop
  104e4f:	90                   	nop

00104e50 <idtinit>:
  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  104e50:	55                   	push   %ebp
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  pd[1] = (uint)p;
  104e51:	b8 40 e1 10 00       	mov    $0x10e140,%eax
  104e56:	89 e5                	mov    %esp,%ebp
  104e58:	83 ec 10             	sub    $0x10,%esp
static inline void
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  104e5b:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
  104e61:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
  104e65:	c1 e8 10             	shr    $0x10,%eax
  104e68:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
  104e6c:	8d 45 fa             	lea    -0x6(%ebp),%eax
  104e6f:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
  104e72:	c9                   	leave  
  104e73:	c3                   	ret    
  104e74:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104e7a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00104e80 <trap>:

void
trap(struct trapframe *tf)
{
  104e80:	55                   	push   %ebp
  104e81:	89 e5                	mov    %esp,%ebp
  104e83:	56                   	push   %esi
  104e84:	53                   	push   %ebx
  104e85:	83 ec 20             	sub    $0x20,%esp
  104e88:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
  104e8b:	8b 43 30             	mov    0x30(%ebx),%eax
  104e8e:	83 f8 40             	cmp    $0x40,%eax
  104e91:	0f 84 c9 00 00 00    	je     104f60 <trap+0xe0>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  104e97:	8d 50 e0             	lea    -0x20(%eax),%edx
  104e9a:	83 fa 1f             	cmp    $0x1f,%edx
  104e9d:	0f 86 b5 00 00 00    	jbe    104f58 <trap+0xd8>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
  104ea3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104eaa:	85 d2                	test   %edx,%edx
  104eac:	0f 84 f6 01 00 00    	je     1050a8 <trap+0x228>
  104eb2:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
  104eb6:	0f 84 ec 01 00 00    	je     1050a8 <trap+0x228>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
  104ebc:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
  104ebf:	8b 4a 10             	mov    0x10(%edx),%ecx
  104ec2:	83 c2 6c             	add    $0x6c,%edx
  104ec5:	89 74 24 1c          	mov    %esi,0x1c(%esp)
  104ec9:	8b 73 38             	mov    0x38(%ebx),%esi
  104ecc:	89 74 24 18          	mov    %esi,0x18(%esp)
  104ed0:	65 8b 35 00 00 00 00 	mov    %gs:0x0,%esi
  104ed7:	0f b6 36             	movzbl (%esi),%esi
  104eda:	89 74 24 14          	mov    %esi,0x14(%esp)
  104ede:	8b 73 34             	mov    0x34(%ebx),%esi
  104ee1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104ee5:	89 54 24 08          	mov    %edx,0x8(%esp)
  104ee9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104eed:	89 74 24 10          	mov    %esi,0x10(%esp)
  104ef1:	c7 04 24 f8 6c 10 00 	movl   $0x106cf8,(%esp)
  104ef8:	e8 33 b6 ff ff       	call   100530 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
  104efd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104f03:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  104f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  104f10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104f16:	85 c0                	test   %eax,%eax
  104f18:	74 34                	je     104f4e <trap+0xce>
  104f1a:	8b 50 24             	mov    0x24(%eax),%edx
  104f1d:	85 d2                	test   %edx,%edx
  104f1f:	74 10                	je     104f31 <trap+0xb1>
  104f21:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
  104f25:	83 e2 03             	and    $0x3,%edx
  104f28:	83 fa 03             	cmp    $0x3,%edx
  104f2b:	0f 84 5f 01 00 00    	je     105090 <trap+0x210>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  104f31:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
  104f35:	0f 84 2d 01 00 00    	je     105068 <trap+0x1e8>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  104f3b:	8b 40 24             	mov    0x24(%eax),%eax
  104f3e:	85 c0                	test   %eax,%eax
  104f40:	74 0c                	je     104f4e <trap+0xce>
  104f42:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  104f46:	83 e0 03             	and    $0x3,%eax
  104f49:	83 f8 03             	cmp    $0x3,%eax
  104f4c:	74 34                	je     104f82 <trap+0x102>
    exit();
}
  104f4e:	83 c4 20             	add    $0x20,%esp
  104f51:	5b                   	pop    %ebx
  104f52:	5e                   	pop    %esi
  104f53:	5d                   	pop    %ebp
  104f54:	c3                   	ret    
  104f55:	8d 76 00             	lea    0x0(%esi),%esi
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  104f58:	ff 24 95 48 6d 10 00 	jmp    *0x106d48(,%edx,4)
  104f5f:	90                   	nop

void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
  104f60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104f66:	8b 70 24             	mov    0x24(%eax),%esi
  104f69:	85 f6                	test   %esi,%esi
  104f6b:	75 23                	jne    104f90 <trap+0x110>
      exit();
    proc->tf = tf;
  104f6d:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
  104f70:	e8 2b f0 ff ff       	call   103fa0 <syscall>
    if(proc->killed)
  104f75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104f7b:	8b 48 24             	mov    0x24(%eax),%ecx
  104f7e:	85 c9                	test   %ecx,%ecx
  104f80:	74 cc                	je     104f4e <trap+0xce>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
  104f82:	83 c4 20             	add    $0x20,%esp
  104f85:	5b                   	pop    %ebx
  104f86:	5e                   	pop    %esi
  104f87:	5d                   	pop    %ebp
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  104f88:	e9 73 e5 ff ff       	jmp    103500 <exit>
  104f8d:	8d 76 00             	lea    0x0(%esi),%esi
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
      exit();
  104f90:	e8 6b e5 ff ff       	call   103500 <exit>
  104f95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104f9b:	eb d0                	jmp    104f6d <trap+0xed>
  104f9d:	8d 76 00             	lea    0x0(%esi),%esi
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
  104fa0:	e8 6b d0 ff ff       	call   102010 <ideintr>
    lapiceoi();
  104fa5:	e8 a6 d4 ff ff       	call   102450 <lapiceoi>
    break;
  104faa:	e9 61 ff ff ff       	jmp    104f10 <trap+0x90>
  104faf:	90                   	nop
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
  104fb0:	8b 43 38             	mov    0x38(%ebx),%eax
  104fb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104fb7:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  104fbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  104fbf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  104fc5:	0f b6 00             	movzbl (%eax),%eax
  104fc8:	c7 04 24 a0 6c 10 00 	movl   $0x106ca0,(%esp)
  104fcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  104fd3:	e8 58 b5 ff ff       	call   100530 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
  104fd8:	e8 73 d4 ff ff       	call   102450 <lapiceoi>
    break;
  104fdd:	e9 2e ff ff ff       	jmp    104f10 <trap+0x90>
  104fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104fe8:	90                   	nop
  104fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
  104ff0:	e8 ab 01 00 00       	call   1051a0 <uartintr>
  104ff5:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  104ff8:	e8 53 d4 ff ff       	call   102450 <lapiceoi>
  104ffd:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  105000:	e9 0b ff ff ff       	jmp    104f10 <trap+0x90>
  105005:	8d 76 00             	lea    0x0(%esi),%esi
  105008:	90                   	nop
  105009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
  105010:	e8 1b d4 ff ff       	call   102430 <kbdintr>
  105015:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  105018:	e8 33 d4 ff ff       	call   102450 <lapiceoi>
  10501d:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  105020:	e9 eb fe ff ff       	jmp    104f10 <trap+0x90>
  105025:	8d 76 00             	lea    0x0(%esi),%esi
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
  105028:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10502e:	80 38 00             	cmpb   $0x0,(%eax)
  105031:	0f 85 6e ff ff ff    	jne    104fa5 <trap+0x125>
      acquire(&tickslock);
  105037:	c7 04 24 00 e1 10 00 	movl   $0x10e100,(%esp)
  10503e:	e8 ed ea ff ff       	call   103b30 <acquire>
      ticks++;
  105043:	83 05 40 e9 10 00 01 	addl   $0x1,0x10e940
      wakeup(&ticks);
  10504a:	c7 04 24 40 e9 10 00 	movl   $0x10e940,(%esp)
  105051:	e8 da e0 ff ff       	call   103130 <wakeup>
      release(&tickslock);
  105056:	c7 04 24 00 e1 10 00 	movl   $0x10e100,(%esp)
  10505d:	e8 7e ea ff ff       	call   103ae0 <release>
  105062:	e9 3e ff ff ff       	jmp    104fa5 <trap+0x125>
  105067:	90                   	nop
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105068:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
  10506c:	0f 85 c9 fe ff ff    	jne    104f3b <trap+0xbb>
  105072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    yield();
  105078:	e8 a3 e2 ff ff       	call   103320 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  10507d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  105083:	85 c0                	test   %eax,%eax
  105085:	0f 85 b0 fe ff ff    	jne    104f3b <trap+0xbb>
  10508b:	e9 be fe ff ff       	jmp    104f4e <trap+0xce>

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  105090:	e8 6b e4 ff ff       	call   103500 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105095:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10509b:	85 c0                	test   %eax,%eax
  10509d:	0f 85 8e fe ff ff    	jne    104f31 <trap+0xb1>
  1050a3:	e9 a6 fe ff ff       	jmp    104f4e <trap+0xce>
  1050a8:	0f 20 d2             	mov    %cr2,%edx
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
  1050ab:	89 54 24 10          	mov    %edx,0x10(%esp)
  1050af:	8b 53 38             	mov    0x38(%ebx),%edx
  1050b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1050b6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  1050bd:	0f b6 12             	movzbl (%edx),%edx
  1050c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1050c4:	c7 04 24 c4 6c 10 00 	movl   $0x106cc4,(%esp)
  1050cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  1050cf:	e8 5c b4 ff ff       	call   100530 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
  1050d4:	c7 04 24 3b 6d 10 00 	movl   $0x106d3b,(%esp)
  1050db:	e8 40 b8 ff ff       	call   100920 <panic>

001050e0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  1050e0:	55                   	push   %ebp
  1050e1:	31 c0                	xor    %eax,%eax
  1050e3:	89 e5                	mov    %esp,%ebp
  1050e5:	ba 40 e1 10 00       	mov    $0x10e140,%edx
  1050ea:	83 ec 18             	sub    $0x18,%esp
  1050ed:	8d 76 00             	lea    0x0(%esi),%esi
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  1050f0:	8b 0c 85 28 73 10 00 	mov    0x107328(,%eax,4),%ecx
  1050f7:	66 89 0c c5 40 e1 10 	mov    %cx,0x10e140(,%eax,8)
  1050fe:	00 
  1050ff:	c1 e9 10             	shr    $0x10,%ecx
  105102:	66 c7 44 c2 02 08 00 	movw   $0x8,0x2(%edx,%eax,8)
  105109:	c6 44 c2 04 00       	movb   $0x0,0x4(%edx,%eax,8)
  10510e:	c6 44 c2 05 8e       	movb   $0x8e,0x5(%edx,%eax,8)
  105113:	66 89 4c c2 06       	mov    %cx,0x6(%edx,%eax,8)
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
  105118:	83 c0 01             	add    $0x1,%eax
  10511b:	3d 00 01 00 00       	cmp    $0x100,%eax
  105120:	75 ce                	jne    1050f0 <tvinit+0x10>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  105122:	a1 28 74 10 00       	mov    0x107428,%eax
  
  initlock(&tickslock, "time");
  105127:	c7 44 24 04 40 6d 10 	movl   $0x106d40,0x4(%esp)
  10512e:	00 
  10512f:	c7 04 24 00 e1 10 00 	movl   $0x10e100,(%esp)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  105136:	66 c7 05 42 e3 10 00 	movw   $0x8,0x10e342
  10513d:	08 00 
  10513f:	66 a3 40 e3 10 00    	mov    %ax,0x10e340
  105145:	c1 e8 10             	shr    $0x10,%eax
  105148:	c6 05 44 e3 10 00 00 	movb   $0x0,0x10e344
  10514f:	c6 05 45 e3 10 00 ef 	movb   $0xef,0x10e345
  105156:	66 a3 46 e3 10 00    	mov    %ax,0x10e346
  
  initlock(&tickslock, "time");
  10515c:	e8 3f e8 ff ff       	call   1039a0 <initlock>
}
  105161:	c9                   	leave  
  105162:	c3                   	ret    
  105163:	90                   	nop
  105164:	90                   	nop
  105165:	90                   	nop
  105166:	90                   	nop
  105167:	90                   	nop
  105168:	90                   	nop
  105169:	90                   	nop
  10516a:	90                   	nop
  10516b:	90                   	nop
  10516c:	90                   	nop
  10516d:	90                   	nop
  10516e:	90                   	nop
  10516f:	90                   	nop

00105170 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
  105170:	a1 d4 78 10 00       	mov    0x1078d4,%eax
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
  105175:	55                   	push   %ebp
  105176:	89 e5                	mov    %esp,%ebp
  if(!uart)
  105178:	85 c0                	test   %eax,%eax
  10517a:	75 0c                	jne    105188 <uartgetc+0x18>
    return -1;
  if(!(inb(COM1+5) & 0x01))
    return -1;
  return inb(COM1+0);
  10517c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  105181:	5d                   	pop    %ebp
  105182:	c3                   	ret    
  105183:	90                   	nop
  105184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105188:	ba fd 03 00 00       	mov    $0x3fd,%edx
  10518d:	ec                   	in     (%dx),%al
static int
uartgetc(void)
{
  if(!uart)
    return -1;
  if(!(inb(COM1+5) & 0x01))
  10518e:	a8 01                	test   $0x1,%al
  105190:	74 ea                	je     10517c <uartgetc+0xc>
  105192:	b2 f8                	mov    $0xf8,%dl
  105194:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
  105195:	0f b6 c0             	movzbl %al,%eax
}
  105198:	5d                   	pop    %ebp
  105199:	c3                   	ret    
  10519a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001051a0 <uartintr>:

void
uartintr(void)
{
  1051a0:	55                   	push   %ebp
  1051a1:	89 e5                	mov    %esp,%ebp
  1051a3:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
  1051a6:	c7 04 24 70 51 10 00 	movl   $0x105170,(%esp)
  1051ad:	e8 de b5 ff ff       	call   100790 <consoleintr>
}
  1051b2:	c9                   	leave  
  1051b3:	c3                   	ret    
  1051b4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1051ba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001051c0 <uartputc>:
    uartputc(*p);
}

void
uartputc(int c)
{
  1051c0:	55                   	push   %ebp
  1051c1:	89 e5                	mov    %esp,%ebp
  1051c3:	56                   	push   %esi
  1051c4:	be fd 03 00 00       	mov    $0x3fd,%esi
  1051c9:	53                   	push   %ebx
  int i;

  if(!uart)
  1051ca:	31 db                	xor    %ebx,%ebx
    uartputc(*p);
}

void
uartputc(int c)
{
  1051cc:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(!uart)
  1051cf:	8b 15 d4 78 10 00    	mov    0x1078d4,%edx
  1051d5:	85 d2                	test   %edx,%edx
  1051d7:	75 1e                	jne    1051f7 <uartputc+0x37>
  1051d9:	eb 2c                	jmp    105207 <uartputc+0x47>
  1051db:	90                   	nop
  1051dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1051e0:	83 c3 01             	add    $0x1,%ebx
    microdelay(10);
  1051e3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1051ea:	e8 81 d2 ff ff       	call   102470 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1051ef:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  1051f5:	74 07                	je     1051fe <uartputc+0x3e>
  1051f7:	89 f2                	mov    %esi,%edx
  1051f9:	ec                   	in     (%dx),%al
  1051fa:	a8 20                	test   $0x20,%al
  1051fc:	74 e2                	je     1051e0 <uartputc+0x20>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1051fe:	ba f8 03 00 00       	mov    $0x3f8,%edx
  105203:	8b 45 08             	mov    0x8(%ebp),%eax
  105206:	ee                   	out    %al,(%dx)
    microdelay(10);
  outb(COM1+0, c);
}
  105207:	83 c4 10             	add    $0x10,%esp
  10520a:	5b                   	pop    %ebx
  10520b:	5e                   	pop    %esi
  10520c:	5d                   	pop    %ebp
  10520d:	c3                   	ret    
  10520e:	66 90                	xchg   %ax,%ax

00105210 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
  105210:	55                   	push   %ebp
  105211:	31 c9                	xor    %ecx,%ecx
  105213:	89 e5                	mov    %esp,%ebp
  105215:	89 c8                	mov    %ecx,%eax
  105217:	57                   	push   %edi
  105218:	bf fa 03 00 00       	mov    $0x3fa,%edi
  10521d:	56                   	push   %esi
  10521e:	89 fa                	mov    %edi,%edx
  105220:	53                   	push   %ebx
  105221:	83 ec 1c             	sub    $0x1c,%esp
  105224:	ee                   	out    %al,(%dx)
  105225:	bb fb 03 00 00       	mov    $0x3fb,%ebx
  10522a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  10522f:	89 da                	mov    %ebx,%edx
  105231:	ee                   	out    %al,(%dx)
  105232:	b8 0c 00 00 00       	mov    $0xc,%eax
  105237:	b2 f8                	mov    $0xf8,%dl
  105239:	ee                   	out    %al,(%dx)
  10523a:	be f9 03 00 00       	mov    $0x3f9,%esi
  10523f:	89 c8                	mov    %ecx,%eax
  105241:	89 f2                	mov    %esi,%edx
  105243:	ee                   	out    %al,(%dx)
  105244:	b8 03 00 00 00       	mov    $0x3,%eax
  105249:	89 da                	mov    %ebx,%edx
  10524b:	ee                   	out    %al,(%dx)
  10524c:	b2 fc                	mov    $0xfc,%dl
  10524e:	89 c8                	mov    %ecx,%eax
  105250:	ee                   	out    %al,(%dx)
  105251:	b8 01 00 00 00       	mov    $0x1,%eax
  105256:	89 f2                	mov    %esi,%edx
  105258:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105259:	b2 fd                	mov    $0xfd,%dl
  10525b:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
  10525c:	3c ff                	cmp    $0xff,%al
  10525e:	74 55                	je     1052b5 <uartinit+0xa5>
    return;
  uart = 1;
  105260:	c7 05 d4 78 10 00 01 	movl   $0x1,0x1078d4
  105267:	00 00 00 
  10526a:	89 fa                	mov    %edi,%edx
  10526c:	ec                   	in     (%dx),%al
  10526d:	b2 f8                	mov    $0xf8,%dl
  10526f:	ec                   	in     (%dx),%al
  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  105270:	bb c8 6d 10 00       	mov    $0x106dc8,%ebx

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  105275:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10527c:	e8 0f d9 ff ff       	call   102b90 <picenable>
  ioapicenable(IRQ_COM1, 0);
  105281:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105288:	00 
  105289:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  105290:	e8 ab ce ff ff       	call   102140 <ioapicenable>
  105295:	b8 78 00 00 00       	mov    $0x78,%eax
  10529a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
  1052a0:	0f be c0             	movsbl %al,%eax
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  1052a3:	83 c3 01             	add    $0x1,%ebx
    uartputc(*p);
  1052a6:	89 04 24             	mov    %eax,(%esp)
  1052a9:	e8 12 ff ff ff       	call   1051c0 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  1052ae:	0f b6 03             	movzbl (%ebx),%eax
  1052b1:	84 c0                	test   %al,%al
  1052b3:	75 eb                	jne    1052a0 <uartinit+0x90>
    uartputc(*p);
}
  1052b5:	83 c4 1c             	add    $0x1c,%esp
  1052b8:	5b                   	pop    %ebx
  1052b9:	5e                   	pop    %esi
  1052ba:	5f                   	pop    %edi
  1052bb:	5d                   	pop    %ebp
  1052bc:	c3                   	ret    
  1052bd:	90                   	nop
  1052be:	90                   	nop
  1052bf:	90                   	nop

001052c0 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
  1052c0:	6a 00                	push   $0x0
  pushl $0
  1052c2:	6a 00                	push   $0x0
  jmp alltraps
  1052c4:	e9 57 fb ff ff       	jmp    104e20 <alltraps>

001052c9 <vector1>:
.globl vector1
vector1:
  pushl $0
  1052c9:	6a 00                	push   $0x0
  pushl $1
  1052cb:	6a 01                	push   $0x1
  jmp alltraps
  1052cd:	e9 4e fb ff ff       	jmp    104e20 <alltraps>

001052d2 <vector2>:
.globl vector2
vector2:
  pushl $0
  1052d2:	6a 00                	push   $0x0
  pushl $2
  1052d4:	6a 02                	push   $0x2
  jmp alltraps
  1052d6:	e9 45 fb ff ff       	jmp    104e20 <alltraps>

001052db <vector3>:
.globl vector3
vector3:
  pushl $0
  1052db:	6a 00                	push   $0x0
  pushl $3
  1052dd:	6a 03                	push   $0x3
  jmp alltraps
  1052df:	e9 3c fb ff ff       	jmp    104e20 <alltraps>

001052e4 <vector4>:
.globl vector4
vector4:
  pushl $0
  1052e4:	6a 00                	push   $0x0
  pushl $4
  1052e6:	6a 04                	push   $0x4
  jmp alltraps
  1052e8:	e9 33 fb ff ff       	jmp    104e20 <alltraps>

001052ed <vector5>:
.globl vector5
vector5:
  pushl $0
  1052ed:	6a 00                	push   $0x0
  pushl $5
  1052ef:	6a 05                	push   $0x5
  jmp alltraps
  1052f1:	e9 2a fb ff ff       	jmp    104e20 <alltraps>

001052f6 <vector6>:
.globl vector6
vector6:
  pushl $0
  1052f6:	6a 00                	push   $0x0
  pushl $6
  1052f8:	6a 06                	push   $0x6
  jmp alltraps
  1052fa:	e9 21 fb ff ff       	jmp    104e20 <alltraps>

001052ff <vector7>:
.globl vector7
vector7:
  pushl $0
  1052ff:	6a 00                	push   $0x0
  pushl $7
  105301:	6a 07                	push   $0x7
  jmp alltraps
  105303:	e9 18 fb ff ff       	jmp    104e20 <alltraps>

00105308 <vector8>:
.globl vector8
vector8:
  pushl $8
  105308:	6a 08                	push   $0x8
  jmp alltraps
  10530a:	e9 11 fb ff ff       	jmp    104e20 <alltraps>

0010530f <vector9>:
.globl vector9
vector9:
  pushl $0
  10530f:	6a 00                	push   $0x0
  pushl $9
  105311:	6a 09                	push   $0x9
  jmp alltraps
  105313:	e9 08 fb ff ff       	jmp    104e20 <alltraps>

00105318 <vector10>:
.globl vector10
vector10:
  pushl $10
  105318:	6a 0a                	push   $0xa
  jmp alltraps
  10531a:	e9 01 fb ff ff       	jmp    104e20 <alltraps>

0010531f <vector11>:
.globl vector11
vector11:
  pushl $11
  10531f:	6a 0b                	push   $0xb
  jmp alltraps
  105321:	e9 fa fa ff ff       	jmp    104e20 <alltraps>

00105326 <vector12>:
.globl vector12
vector12:
  pushl $12
  105326:	6a 0c                	push   $0xc
  jmp alltraps
  105328:	e9 f3 fa ff ff       	jmp    104e20 <alltraps>

0010532d <vector13>:
.globl vector13
vector13:
  pushl $13
  10532d:	6a 0d                	push   $0xd
  jmp alltraps
  10532f:	e9 ec fa ff ff       	jmp    104e20 <alltraps>

00105334 <vector14>:
.globl vector14
vector14:
  pushl $14
  105334:	6a 0e                	push   $0xe
  jmp alltraps
  105336:	e9 e5 fa ff ff       	jmp    104e20 <alltraps>

0010533b <vector15>:
.globl vector15
vector15:
  pushl $0
  10533b:	6a 00                	push   $0x0
  pushl $15
  10533d:	6a 0f                	push   $0xf
  jmp alltraps
  10533f:	e9 dc fa ff ff       	jmp    104e20 <alltraps>

00105344 <vector16>:
.globl vector16
vector16:
  pushl $0
  105344:	6a 00                	push   $0x0
  pushl $16
  105346:	6a 10                	push   $0x10
  jmp alltraps
  105348:	e9 d3 fa ff ff       	jmp    104e20 <alltraps>

0010534d <vector17>:
.globl vector17
vector17:
  pushl $17
  10534d:	6a 11                	push   $0x11
  jmp alltraps
  10534f:	e9 cc fa ff ff       	jmp    104e20 <alltraps>

00105354 <vector18>:
.globl vector18
vector18:
  pushl $0
  105354:	6a 00                	push   $0x0
  pushl $18
  105356:	6a 12                	push   $0x12
  jmp alltraps
  105358:	e9 c3 fa ff ff       	jmp    104e20 <alltraps>

0010535d <vector19>:
.globl vector19
vector19:
  pushl $0
  10535d:	6a 00                	push   $0x0
  pushl $19
  10535f:	6a 13                	push   $0x13
  jmp alltraps
  105361:	e9 ba fa ff ff       	jmp    104e20 <alltraps>

00105366 <vector20>:
.globl vector20
vector20:
  pushl $0
  105366:	6a 00                	push   $0x0
  pushl $20
  105368:	6a 14                	push   $0x14
  jmp alltraps
  10536a:	e9 b1 fa ff ff       	jmp    104e20 <alltraps>

0010536f <vector21>:
.globl vector21
vector21:
  pushl $0
  10536f:	6a 00                	push   $0x0
  pushl $21
  105371:	6a 15                	push   $0x15
  jmp alltraps
  105373:	e9 a8 fa ff ff       	jmp    104e20 <alltraps>

00105378 <vector22>:
.globl vector22
vector22:
  pushl $0
  105378:	6a 00                	push   $0x0
  pushl $22
  10537a:	6a 16                	push   $0x16
  jmp alltraps
  10537c:	e9 9f fa ff ff       	jmp    104e20 <alltraps>

00105381 <vector23>:
.globl vector23
vector23:
  pushl $0
  105381:	6a 00                	push   $0x0
  pushl $23
  105383:	6a 17                	push   $0x17
  jmp alltraps
  105385:	e9 96 fa ff ff       	jmp    104e20 <alltraps>

0010538a <vector24>:
.globl vector24
vector24:
  pushl $0
  10538a:	6a 00                	push   $0x0
  pushl $24
  10538c:	6a 18                	push   $0x18
  jmp alltraps
  10538e:	e9 8d fa ff ff       	jmp    104e20 <alltraps>

00105393 <vector25>:
.globl vector25
vector25:
  pushl $0
  105393:	6a 00                	push   $0x0
  pushl $25
  105395:	6a 19                	push   $0x19
  jmp alltraps
  105397:	e9 84 fa ff ff       	jmp    104e20 <alltraps>

0010539c <vector26>:
.globl vector26
vector26:
  pushl $0
  10539c:	6a 00                	push   $0x0
  pushl $26
  10539e:	6a 1a                	push   $0x1a
  jmp alltraps
  1053a0:	e9 7b fa ff ff       	jmp    104e20 <alltraps>

001053a5 <vector27>:
.globl vector27
vector27:
  pushl $0
  1053a5:	6a 00                	push   $0x0
  pushl $27
  1053a7:	6a 1b                	push   $0x1b
  jmp alltraps
  1053a9:	e9 72 fa ff ff       	jmp    104e20 <alltraps>

001053ae <vector28>:
.globl vector28
vector28:
  pushl $0
  1053ae:	6a 00                	push   $0x0
  pushl $28
  1053b0:	6a 1c                	push   $0x1c
  jmp alltraps
  1053b2:	e9 69 fa ff ff       	jmp    104e20 <alltraps>

001053b7 <vector29>:
.globl vector29
vector29:
  pushl $0
  1053b7:	6a 00                	push   $0x0
  pushl $29
  1053b9:	6a 1d                	push   $0x1d
  jmp alltraps
  1053bb:	e9 60 fa ff ff       	jmp    104e20 <alltraps>

001053c0 <vector30>:
.globl vector30
vector30:
  pushl $0
  1053c0:	6a 00                	push   $0x0
  pushl $30
  1053c2:	6a 1e                	push   $0x1e
  jmp alltraps
  1053c4:	e9 57 fa ff ff       	jmp    104e20 <alltraps>

001053c9 <vector31>:
.globl vector31
vector31:
  pushl $0
  1053c9:	6a 00                	push   $0x0
  pushl $31
  1053cb:	6a 1f                	push   $0x1f
  jmp alltraps
  1053cd:	e9 4e fa ff ff       	jmp    104e20 <alltraps>

001053d2 <vector32>:
.globl vector32
vector32:
  pushl $0
  1053d2:	6a 00                	push   $0x0
  pushl $32
  1053d4:	6a 20                	push   $0x20
  jmp alltraps
  1053d6:	e9 45 fa ff ff       	jmp    104e20 <alltraps>

001053db <vector33>:
.globl vector33
vector33:
  pushl $0
  1053db:	6a 00                	push   $0x0
  pushl $33
  1053dd:	6a 21                	push   $0x21
  jmp alltraps
  1053df:	e9 3c fa ff ff       	jmp    104e20 <alltraps>

001053e4 <vector34>:
.globl vector34
vector34:
  pushl $0
  1053e4:	6a 00                	push   $0x0
  pushl $34
  1053e6:	6a 22                	push   $0x22
  jmp alltraps
  1053e8:	e9 33 fa ff ff       	jmp    104e20 <alltraps>

001053ed <vector35>:
.globl vector35
vector35:
  pushl $0
  1053ed:	6a 00                	push   $0x0
  pushl $35
  1053ef:	6a 23                	push   $0x23
  jmp alltraps
  1053f1:	e9 2a fa ff ff       	jmp    104e20 <alltraps>

001053f6 <vector36>:
.globl vector36
vector36:
  pushl $0
  1053f6:	6a 00                	push   $0x0
  pushl $36
  1053f8:	6a 24                	push   $0x24
  jmp alltraps
  1053fa:	e9 21 fa ff ff       	jmp    104e20 <alltraps>

001053ff <vector37>:
.globl vector37
vector37:
  pushl $0
  1053ff:	6a 00                	push   $0x0
  pushl $37
  105401:	6a 25                	push   $0x25
  jmp alltraps
  105403:	e9 18 fa ff ff       	jmp    104e20 <alltraps>

00105408 <vector38>:
.globl vector38
vector38:
  pushl $0
  105408:	6a 00                	push   $0x0
  pushl $38
  10540a:	6a 26                	push   $0x26
  jmp alltraps
  10540c:	e9 0f fa ff ff       	jmp    104e20 <alltraps>

00105411 <vector39>:
.globl vector39
vector39:
  pushl $0
  105411:	6a 00                	push   $0x0
  pushl $39
  105413:	6a 27                	push   $0x27
  jmp alltraps
  105415:	e9 06 fa ff ff       	jmp    104e20 <alltraps>

0010541a <vector40>:
.globl vector40
vector40:
  pushl $0
  10541a:	6a 00                	push   $0x0
  pushl $40
  10541c:	6a 28                	push   $0x28
  jmp alltraps
  10541e:	e9 fd f9 ff ff       	jmp    104e20 <alltraps>

00105423 <vector41>:
.globl vector41
vector41:
  pushl $0
  105423:	6a 00                	push   $0x0
  pushl $41
  105425:	6a 29                	push   $0x29
  jmp alltraps
  105427:	e9 f4 f9 ff ff       	jmp    104e20 <alltraps>

0010542c <vector42>:
.globl vector42
vector42:
  pushl $0
  10542c:	6a 00                	push   $0x0
  pushl $42
  10542e:	6a 2a                	push   $0x2a
  jmp alltraps
  105430:	e9 eb f9 ff ff       	jmp    104e20 <alltraps>

00105435 <vector43>:
.globl vector43
vector43:
  pushl $0
  105435:	6a 00                	push   $0x0
  pushl $43
  105437:	6a 2b                	push   $0x2b
  jmp alltraps
  105439:	e9 e2 f9 ff ff       	jmp    104e20 <alltraps>

0010543e <vector44>:
.globl vector44
vector44:
  pushl $0
  10543e:	6a 00                	push   $0x0
  pushl $44
  105440:	6a 2c                	push   $0x2c
  jmp alltraps
  105442:	e9 d9 f9 ff ff       	jmp    104e20 <alltraps>

00105447 <vector45>:
.globl vector45
vector45:
  pushl $0
  105447:	6a 00                	push   $0x0
  pushl $45
  105449:	6a 2d                	push   $0x2d
  jmp alltraps
  10544b:	e9 d0 f9 ff ff       	jmp    104e20 <alltraps>

00105450 <vector46>:
.globl vector46
vector46:
  pushl $0
  105450:	6a 00                	push   $0x0
  pushl $46
  105452:	6a 2e                	push   $0x2e
  jmp alltraps
  105454:	e9 c7 f9 ff ff       	jmp    104e20 <alltraps>

00105459 <vector47>:
.globl vector47
vector47:
  pushl $0
  105459:	6a 00                	push   $0x0
  pushl $47
  10545b:	6a 2f                	push   $0x2f
  jmp alltraps
  10545d:	e9 be f9 ff ff       	jmp    104e20 <alltraps>

00105462 <vector48>:
.globl vector48
vector48:
  pushl $0
  105462:	6a 00                	push   $0x0
  pushl $48
  105464:	6a 30                	push   $0x30
  jmp alltraps
  105466:	e9 b5 f9 ff ff       	jmp    104e20 <alltraps>

0010546b <vector49>:
.globl vector49
vector49:
  pushl $0
  10546b:	6a 00                	push   $0x0
  pushl $49
  10546d:	6a 31                	push   $0x31
  jmp alltraps
  10546f:	e9 ac f9 ff ff       	jmp    104e20 <alltraps>

00105474 <vector50>:
.globl vector50
vector50:
  pushl $0
  105474:	6a 00                	push   $0x0
  pushl $50
  105476:	6a 32                	push   $0x32
  jmp alltraps
  105478:	e9 a3 f9 ff ff       	jmp    104e20 <alltraps>

0010547d <vector51>:
.globl vector51
vector51:
  pushl $0
  10547d:	6a 00                	push   $0x0
  pushl $51
  10547f:	6a 33                	push   $0x33
  jmp alltraps
  105481:	e9 9a f9 ff ff       	jmp    104e20 <alltraps>

00105486 <vector52>:
.globl vector52
vector52:
  pushl $0
  105486:	6a 00                	push   $0x0
  pushl $52
  105488:	6a 34                	push   $0x34
  jmp alltraps
  10548a:	e9 91 f9 ff ff       	jmp    104e20 <alltraps>

0010548f <vector53>:
.globl vector53
vector53:
  pushl $0
  10548f:	6a 00                	push   $0x0
  pushl $53
  105491:	6a 35                	push   $0x35
  jmp alltraps
  105493:	e9 88 f9 ff ff       	jmp    104e20 <alltraps>

00105498 <vector54>:
.globl vector54
vector54:
  pushl $0
  105498:	6a 00                	push   $0x0
  pushl $54
  10549a:	6a 36                	push   $0x36
  jmp alltraps
  10549c:	e9 7f f9 ff ff       	jmp    104e20 <alltraps>

001054a1 <vector55>:
.globl vector55
vector55:
  pushl $0
  1054a1:	6a 00                	push   $0x0
  pushl $55
  1054a3:	6a 37                	push   $0x37
  jmp alltraps
  1054a5:	e9 76 f9 ff ff       	jmp    104e20 <alltraps>

001054aa <vector56>:
.globl vector56
vector56:
  pushl $0
  1054aa:	6a 00                	push   $0x0
  pushl $56
  1054ac:	6a 38                	push   $0x38
  jmp alltraps
  1054ae:	e9 6d f9 ff ff       	jmp    104e20 <alltraps>

001054b3 <vector57>:
.globl vector57
vector57:
  pushl $0
  1054b3:	6a 00                	push   $0x0
  pushl $57
  1054b5:	6a 39                	push   $0x39
  jmp alltraps
  1054b7:	e9 64 f9 ff ff       	jmp    104e20 <alltraps>

001054bc <vector58>:
.globl vector58
vector58:
  pushl $0
  1054bc:	6a 00                	push   $0x0
  pushl $58
  1054be:	6a 3a                	push   $0x3a
  jmp alltraps
  1054c0:	e9 5b f9 ff ff       	jmp    104e20 <alltraps>

001054c5 <vector59>:
.globl vector59
vector59:
  pushl $0
  1054c5:	6a 00                	push   $0x0
  pushl $59
  1054c7:	6a 3b                	push   $0x3b
  jmp alltraps
  1054c9:	e9 52 f9 ff ff       	jmp    104e20 <alltraps>

001054ce <vector60>:
.globl vector60
vector60:
  pushl $0
  1054ce:	6a 00                	push   $0x0
  pushl $60
  1054d0:	6a 3c                	push   $0x3c
  jmp alltraps
  1054d2:	e9 49 f9 ff ff       	jmp    104e20 <alltraps>

001054d7 <vector61>:
.globl vector61
vector61:
  pushl $0
  1054d7:	6a 00                	push   $0x0
  pushl $61
  1054d9:	6a 3d                	push   $0x3d
  jmp alltraps
  1054db:	e9 40 f9 ff ff       	jmp    104e20 <alltraps>

001054e0 <vector62>:
.globl vector62
vector62:
  pushl $0
  1054e0:	6a 00                	push   $0x0
  pushl $62
  1054e2:	6a 3e                	push   $0x3e
  jmp alltraps
  1054e4:	e9 37 f9 ff ff       	jmp    104e20 <alltraps>

001054e9 <vector63>:
.globl vector63
vector63:
  pushl $0
  1054e9:	6a 00                	push   $0x0
  pushl $63
  1054eb:	6a 3f                	push   $0x3f
  jmp alltraps
  1054ed:	e9 2e f9 ff ff       	jmp    104e20 <alltraps>

001054f2 <vector64>:
.globl vector64
vector64:
  pushl $0
  1054f2:	6a 00                	push   $0x0
  pushl $64
  1054f4:	6a 40                	push   $0x40
  jmp alltraps
  1054f6:	e9 25 f9 ff ff       	jmp    104e20 <alltraps>

001054fb <vector65>:
.globl vector65
vector65:
  pushl $0
  1054fb:	6a 00                	push   $0x0
  pushl $65
  1054fd:	6a 41                	push   $0x41
  jmp alltraps
  1054ff:	e9 1c f9 ff ff       	jmp    104e20 <alltraps>

00105504 <vector66>:
.globl vector66
vector66:
  pushl $0
  105504:	6a 00                	push   $0x0
  pushl $66
  105506:	6a 42                	push   $0x42
  jmp alltraps
  105508:	e9 13 f9 ff ff       	jmp    104e20 <alltraps>

0010550d <vector67>:
.globl vector67
vector67:
  pushl $0
  10550d:	6a 00                	push   $0x0
  pushl $67
  10550f:	6a 43                	push   $0x43
  jmp alltraps
  105511:	e9 0a f9 ff ff       	jmp    104e20 <alltraps>

00105516 <vector68>:
.globl vector68
vector68:
  pushl $0
  105516:	6a 00                	push   $0x0
  pushl $68
  105518:	6a 44                	push   $0x44
  jmp alltraps
  10551a:	e9 01 f9 ff ff       	jmp    104e20 <alltraps>

0010551f <vector69>:
.globl vector69
vector69:
  pushl $0
  10551f:	6a 00                	push   $0x0
  pushl $69
  105521:	6a 45                	push   $0x45
  jmp alltraps
  105523:	e9 f8 f8 ff ff       	jmp    104e20 <alltraps>

00105528 <vector70>:
.globl vector70
vector70:
  pushl $0
  105528:	6a 00                	push   $0x0
  pushl $70
  10552a:	6a 46                	push   $0x46
  jmp alltraps
  10552c:	e9 ef f8 ff ff       	jmp    104e20 <alltraps>

00105531 <vector71>:
.globl vector71
vector71:
  pushl $0
  105531:	6a 00                	push   $0x0
  pushl $71
  105533:	6a 47                	push   $0x47
  jmp alltraps
  105535:	e9 e6 f8 ff ff       	jmp    104e20 <alltraps>

0010553a <vector72>:
.globl vector72
vector72:
  pushl $0
  10553a:	6a 00                	push   $0x0
  pushl $72
  10553c:	6a 48                	push   $0x48
  jmp alltraps
  10553e:	e9 dd f8 ff ff       	jmp    104e20 <alltraps>

00105543 <vector73>:
.globl vector73
vector73:
  pushl $0
  105543:	6a 00                	push   $0x0
  pushl $73
  105545:	6a 49                	push   $0x49
  jmp alltraps
  105547:	e9 d4 f8 ff ff       	jmp    104e20 <alltraps>

0010554c <vector74>:
.globl vector74
vector74:
  pushl $0
  10554c:	6a 00                	push   $0x0
  pushl $74
  10554e:	6a 4a                	push   $0x4a
  jmp alltraps
  105550:	e9 cb f8 ff ff       	jmp    104e20 <alltraps>

00105555 <vector75>:
.globl vector75
vector75:
  pushl $0
  105555:	6a 00                	push   $0x0
  pushl $75
  105557:	6a 4b                	push   $0x4b
  jmp alltraps
  105559:	e9 c2 f8 ff ff       	jmp    104e20 <alltraps>

0010555e <vector76>:
.globl vector76
vector76:
  pushl $0
  10555e:	6a 00                	push   $0x0
  pushl $76
  105560:	6a 4c                	push   $0x4c
  jmp alltraps
  105562:	e9 b9 f8 ff ff       	jmp    104e20 <alltraps>

00105567 <vector77>:
.globl vector77
vector77:
  pushl $0
  105567:	6a 00                	push   $0x0
  pushl $77
  105569:	6a 4d                	push   $0x4d
  jmp alltraps
  10556b:	e9 b0 f8 ff ff       	jmp    104e20 <alltraps>

00105570 <vector78>:
.globl vector78
vector78:
  pushl $0
  105570:	6a 00                	push   $0x0
  pushl $78
  105572:	6a 4e                	push   $0x4e
  jmp alltraps
  105574:	e9 a7 f8 ff ff       	jmp    104e20 <alltraps>

00105579 <vector79>:
.globl vector79
vector79:
  pushl $0
  105579:	6a 00                	push   $0x0
  pushl $79
  10557b:	6a 4f                	push   $0x4f
  jmp alltraps
  10557d:	e9 9e f8 ff ff       	jmp    104e20 <alltraps>

00105582 <vector80>:
.globl vector80
vector80:
  pushl $0
  105582:	6a 00                	push   $0x0
  pushl $80
  105584:	6a 50                	push   $0x50
  jmp alltraps
  105586:	e9 95 f8 ff ff       	jmp    104e20 <alltraps>

0010558b <vector81>:
.globl vector81
vector81:
  pushl $0
  10558b:	6a 00                	push   $0x0
  pushl $81
  10558d:	6a 51                	push   $0x51
  jmp alltraps
  10558f:	e9 8c f8 ff ff       	jmp    104e20 <alltraps>

00105594 <vector82>:
.globl vector82
vector82:
  pushl $0
  105594:	6a 00                	push   $0x0
  pushl $82
  105596:	6a 52                	push   $0x52
  jmp alltraps
  105598:	e9 83 f8 ff ff       	jmp    104e20 <alltraps>

0010559d <vector83>:
.globl vector83
vector83:
  pushl $0
  10559d:	6a 00                	push   $0x0
  pushl $83
  10559f:	6a 53                	push   $0x53
  jmp alltraps
  1055a1:	e9 7a f8 ff ff       	jmp    104e20 <alltraps>

001055a6 <vector84>:
.globl vector84
vector84:
  pushl $0
  1055a6:	6a 00                	push   $0x0
  pushl $84
  1055a8:	6a 54                	push   $0x54
  jmp alltraps
  1055aa:	e9 71 f8 ff ff       	jmp    104e20 <alltraps>

001055af <vector85>:
.globl vector85
vector85:
  pushl $0
  1055af:	6a 00                	push   $0x0
  pushl $85
  1055b1:	6a 55                	push   $0x55
  jmp alltraps
  1055b3:	e9 68 f8 ff ff       	jmp    104e20 <alltraps>

001055b8 <vector86>:
.globl vector86
vector86:
  pushl $0
  1055b8:	6a 00                	push   $0x0
  pushl $86
  1055ba:	6a 56                	push   $0x56
  jmp alltraps
  1055bc:	e9 5f f8 ff ff       	jmp    104e20 <alltraps>

001055c1 <vector87>:
.globl vector87
vector87:
  pushl $0
  1055c1:	6a 00                	push   $0x0
  pushl $87
  1055c3:	6a 57                	push   $0x57
  jmp alltraps
  1055c5:	e9 56 f8 ff ff       	jmp    104e20 <alltraps>

001055ca <vector88>:
.globl vector88
vector88:
  pushl $0
  1055ca:	6a 00                	push   $0x0
  pushl $88
  1055cc:	6a 58                	push   $0x58
  jmp alltraps
  1055ce:	e9 4d f8 ff ff       	jmp    104e20 <alltraps>

001055d3 <vector89>:
.globl vector89
vector89:
  pushl $0
  1055d3:	6a 00                	push   $0x0
  pushl $89
  1055d5:	6a 59                	push   $0x59
  jmp alltraps
  1055d7:	e9 44 f8 ff ff       	jmp    104e20 <alltraps>

001055dc <vector90>:
.globl vector90
vector90:
  pushl $0
  1055dc:	6a 00                	push   $0x0
  pushl $90
  1055de:	6a 5a                	push   $0x5a
  jmp alltraps
  1055e0:	e9 3b f8 ff ff       	jmp    104e20 <alltraps>

001055e5 <vector91>:
.globl vector91
vector91:
  pushl $0
  1055e5:	6a 00                	push   $0x0
  pushl $91
  1055e7:	6a 5b                	push   $0x5b
  jmp alltraps
  1055e9:	e9 32 f8 ff ff       	jmp    104e20 <alltraps>

001055ee <vector92>:
.globl vector92
vector92:
  pushl $0
  1055ee:	6a 00                	push   $0x0
  pushl $92
  1055f0:	6a 5c                	push   $0x5c
  jmp alltraps
  1055f2:	e9 29 f8 ff ff       	jmp    104e20 <alltraps>

001055f7 <vector93>:
.globl vector93
vector93:
  pushl $0
  1055f7:	6a 00                	push   $0x0
  pushl $93
  1055f9:	6a 5d                	push   $0x5d
  jmp alltraps
  1055fb:	e9 20 f8 ff ff       	jmp    104e20 <alltraps>

00105600 <vector94>:
.globl vector94
vector94:
  pushl $0
  105600:	6a 00                	push   $0x0
  pushl $94
  105602:	6a 5e                	push   $0x5e
  jmp alltraps
  105604:	e9 17 f8 ff ff       	jmp    104e20 <alltraps>

00105609 <vector95>:
.globl vector95
vector95:
  pushl $0
  105609:	6a 00                	push   $0x0
  pushl $95
  10560b:	6a 5f                	push   $0x5f
  jmp alltraps
  10560d:	e9 0e f8 ff ff       	jmp    104e20 <alltraps>

00105612 <vector96>:
.globl vector96
vector96:
  pushl $0
  105612:	6a 00                	push   $0x0
  pushl $96
  105614:	6a 60                	push   $0x60
  jmp alltraps
  105616:	e9 05 f8 ff ff       	jmp    104e20 <alltraps>

0010561b <vector97>:
.globl vector97
vector97:
  pushl $0
  10561b:	6a 00                	push   $0x0
  pushl $97
  10561d:	6a 61                	push   $0x61
  jmp alltraps
  10561f:	e9 fc f7 ff ff       	jmp    104e20 <alltraps>

00105624 <vector98>:
.globl vector98
vector98:
  pushl $0
  105624:	6a 00                	push   $0x0
  pushl $98
  105626:	6a 62                	push   $0x62
  jmp alltraps
  105628:	e9 f3 f7 ff ff       	jmp    104e20 <alltraps>

0010562d <vector99>:
.globl vector99
vector99:
  pushl $0
  10562d:	6a 00                	push   $0x0
  pushl $99
  10562f:	6a 63                	push   $0x63
  jmp alltraps
  105631:	e9 ea f7 ff ff       	jmp    104e20 <alltraps>

00105636 <vector100>:
.globl vector100
vector100:
  pushl $0
  105636:	6a 00                	push   $0x0
  pushl $100
  105638:	6a 64                	push   $0x64
  jmp alltraps
  10563a:	e9 e1 f7 ff ff       	jmp    104e20 <alltraps>

0010563f <vector101>:
.globl vector101
vector101:
  pushl $0
  10563f:	6a 00                	push   $0x0
  pushl $101
  105641:	6a 65                	push   $0x65
  jmp alltraps
  105643:	e9 d8 f7 ff ff       	jmp    104e20 <alltraps>

00105648 <vector102>:
.globl vector102
vector102:
  pushl $0
  105648:	6a 00                	push   $0x0
  pushl $102
  10564a:	6a 66                	push   $0x66
  jmp alltraps
  10564c:	e9 cf f7 ff ff       	jmp    104e20 <alltraps>

00105651 <vector103>:
.globl vector103
vector103:
  pushl $0
  105651:	6a 00                	push   $0x0
  pushl $103
  105653:	6a 67                	push   $0x67
  jmp alltraps
  105655:	e9 c6 f7 ff ff       	jmp    104e20 <alltraps>

0010565a <vector104>:
.globl vector104
vector104:
  pushl $0
  10565a:	6a 00                	push   $0x0
  pushl $104
  10565c:	6a 68                	push   $0x68
  jmp alltraps
  10565e:	e9 bd f7 ff ff       	jmp    104e20 <alltraps>

00105663 <vector105>:
.globl vector105
vector105:
  pushl $0
  105663:	6a 00                	push   $0x0
  pushl $105
  105665:	6a 69                	push   $0x69
  jmp alltraps
  105667:	e9 b4 f7 ff ff       	jmp    104e20 <alltraps>

0010566c <vector106>:
.globl vector106
vector106:
  pushl $0
  10566c:	6a 00                	push   $0x0
  pushl $106
  10566e:	6a 6a                	push   $0x6a
  jmp alltraps
  105670:	e9 ab f7 ff ff       	jmp    104e20 <alltraps>

00105675 <vector107>:
.globl vector107
vector107:
  pushl $0
  105675:	6a 00                	push   $0x0
  pushl $107
  105677:	6a 6b                	push   $0x6b
  jmp alltraps
  105679:	e9 a2 f7 ff ff       	jmp    104e20 <alltraps>

0010567e <vector108>:
.globl vector108
vector108:
  pushl $0
  10567e:	6a 00                	push   $0x0
  pushl $108
  105680:	6a 6c                	push   $0x6c
  jmp alltraps
  105682:	e9 99 f7 ff ff       	jmp    104e20 <alltraps>

00105687 <vector109>:
.globl vector109
vector109:
  pushl $0
  105687:	6a 00                	push   $0x0
  pushl $109
  105689:	6a 6d                	push   $0x6d
  jmp alltraps
  10568b:	e9 90 f7 ff ff       	jmp    104e20 <alltraps>

00105690 <vector110>:
.globl vector110
vector110:
  pushl $0
  105690:	6a 00                	push   $0x0
  pushl $110
  105692:	6a 6e                	push   $0x6e
  jmp alltraps
  105694:	e9 87 f7 ff ff       	jmp    104e20 <alltraps>

00105699 <vector111>:
.globl vector111
vector111:
  pushl $0
  105699:	6a 00                	push   $0x0
  pushl $111
  10569b:	6a 6f                	push   $0x6f
  jmp alltraps
  10569d:	e9 7e f7 ff ff       	jmp    104e20 <alltraps>

001056a2 <vector112>:
.globl vector112
vector112:
  pushl $0
  1056a2:	6a 00                	push   $0x0
  pushl $112
  1056a4:	6a 70                	push   $0x70
  jmp alltraps
  1056a6:	e9 75 f7 ff ff       	jmp    104e20 <alltraps>

001056ab <vector113>:
.globl vector113
vector113:
  pushl $0
  1056ab:	6a 00                	push   $0x0
  pushl $113
  1056ad:	6a 71                	push   $0x71
  jmp alltraps
  1056af:	e9 6c f7 ff ff       	jmp    104e20 <alltraps>

001056b4 <vector114>:
.globl vector114
vector114:
  pushl $0
  1056b4:	6a 00                	push   $0x0
  pushl $114
  1056b6:	6a 72                	push   $0x72
  jmp alltraps
  1056b8:	e9 63 f7 ff ff       	jmp    104e20 <alltraps>

001056bd <vector115>:
.globl vector115
vector115:
  pushl $0
  1056bd:	6a 00                	push   $0x0
  pushl $115
  1056bf:	6a 73                	push   $0x73
  jmp alltraps
  1056c1:	e9 5a f7 ff ff       	jmp    104e20 <alltraps>

001056c6 <vector116>:
.globl vector116
vector116:
  pushl $0
  1056c6:	6a 00                	push   $0x0
  pushl $116
  1056c8:	6a 74                	push   $0x74
  jmp alltraps
  1056ca:	e9 51 f7 ff ff       	jmp    104e20 <alltraps>

001056cf <vector117>:
.globl vector117
vector117:
  pushl $0
  1056cf:	6a 00                	push   $0x0
  pushl $117
  1056d1:	6a 75                	push   $0x75
  jmp alltraps
  1056d3:	e9 48 f7 ff ff       	jmp    104e20 <alltraps>

001056d8 <vector118>:
.globl vector118
vector118:
  pushl $0
  1056d8:	6a 00                	push   $0x0
  pushl $118
  1056da:	6a 76                	push   $0x76
  jmp alltraps
  1056dc:	e9 3f f7 ff ff       	jmp    104e20 <alltraps>

001056e1 <vector119>:
.globl vector119
vector119:
  pushl $0
  1056e1:	6a 00                	push   $0x0
  pushl $119
  1056e3:	6a 77                	push   $0x77
  jmp alltraps
  1056e5:	e9 36 f7 ff ff       	jmp    104e20 <alltraps>

001056ea <vector120>:
.globl vector120
vector120:
  pushl $0
  1056ea:	6a 00                	push   $0x0
  pushl $120
  1056ec:	6a 78                	push   $0x78
  jmp alltraps
  1056ee:	e9 2d f7 ff ff       	jmp    104e20 <alltraps>

001056f3 <vector121>:
.globl vector121
vector121:
  pushl $0
  1056f3:	6a 00                	push   $0x0
  pushl $121
  1056f5:	6a 79                	push   $0x79
  jmp alltraps
  1056f7:	e9 24 f7 ff ff       	jmp    104e20 <alltraps>

001056fc <vector122>:
.globl vector122
vector122:
  pushl $0
  1056fc:	6a 00                	push   $0x0
  pushl $122
  1056fe:	6a 7a                	push   $0x7a
  jmp alltraps
  105700:	e9 1b f7 ff ff       	jmp    104e20 <alltraps>

00105705 <vector123>:
.globl vector123
vector123:
  pushl $0
  105705:	6a 00                	push   $0x0
  pushl $123
  105707:	6a 7b                	push   $0x7b
  jmp alltraps
  105709:	e9 12 f7 ff ff       	jmp    104e20 <alltraps>

0010570e <vector124>:
.globl vector124
vector124:
  pushl $0
  10570e:	6a 00                	push   $0x0
  pushl $124
  105710:	6a 7c                	push   $0x7c
  jmp alltraps
  105712:	e9 09 f7 ff ff       	jmp    104e20 <alltraps>

00105717 <vector125>:
.globl vector125
vector125:
  pushl $0
  105717:	6a 00                	push   $0x0
  pushl $125
  105719:	6a 7d                	push   $0x7d
  jmp alltraps
  10571b:	e9 00 f7 ff ff       	jmp    104e20 <alltraps>

00105720 <vector126>:
.globl vector126
vector126:
  pushl $0
  105720:	6a 00                	push   $0x0
  pushl $126
  105722:	6a 7e                	push   $0x7e
  jmp alltraps
  105724:	e9 f7 f6 ff ff       	jmp    104e20 <alltraps>

00105729 <vector127>:
.globl vector127
vector127:
  pushl $0
  105729:	6a 00                	push   $0x0
  pushl $127
  10572b:	6a 7f                	push   $0x7f
  jmp alltraps
  10572d:	e9 ee f6 ff ff       	jmp    104e20 <alltraps>

00105732 <vector128>:
.globl vector128
vector128:
  pushl $0
  105732:	6a 00                	push   $0x0
  pushl $128
  105734:	68 80 00 00 00       	push   $0x80
  jmp alltraps
  105739:	e9 e2 f6 ff ff       	jmp    104e20 <alltraps>

0010573e <vector129>:
.globl vector129
vector129:
  pushl $0
  10573e:	6a 00                	push   $0x0
  pushl $129
  105740:	68 81 00 00 00       	push   $0x81
  jmp alltraps
  105745:	e9 d6 f6 ff ff       	jmp    104e20 <alltraps>

0010574a <vector130>:
.globl vector130
vector130:
  pushl $0
  10574a:	6a 00                	push   $0x0
  pushl $130
  10574c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
  105751:	e9 ca f6 ff ff       	jmp    104e20 <alltraps>

00105756 <vector131>:
.globl vector131
vector131:
  pushl $0
  105756:	6a 00                	push   $0x0
  pushl $131
  105758:	68 83 00 00 00       	push   $0x83
  jmp alltraps
  10575d:	e9 be f6 ff ff       	jmp    104e20 <alltraps>

00105762 <vector132>:
.globl vector132
vector132:
  pushl $0
  105762:	6a 00                	push   $0x0
  pushl $132
  105764:	68 84 00 00 00       	push   $0x84
  jmp alltraps
  105769:	e9 b2 f6 ff ff       	jmp    104e20 <alltraps>

0010576e <vector133>:
.globl vector133
vector133:
  pushl $0
  10576e:	6a 00                	push   $0x0
  pushl $133
  105770:	68 85 00 00 00       	push   $0x85
  jmp alltraps
  105775:	e9 a6 f6 ff ff       	jmp    104e20 <alltraps>

0010577a <vector134>:
.globl vector134
vector134:
  pushl $0
  10577a:	6a 00                	push   $0x0
  pushl $134
  10577c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
  105781:	e9 9a f6 ff ff       	jmp    104e20 <alltraps>

00105786 <vector135>:
.globl vector135
vector135:
  pushl $0
  105786:	6a 00                	push   $0x0
  pushl $135
  105788:	68 87 00 00 00       	push   $0x87
  jmp alltraps
  10578d:	e9 8e f6 ff ff       	jmp    104e20 <alltraps>

00105792 <vector136>:
.globl vector136
vector136:
  pushl $0
  105792:	6a 00                	push   $0x0
  pushl $136
  105794:	68 88 00 00 00       	push   $0x88
  jmp alltraps
  105799:	e9 82 f6 ff ff       	jmp    104e20 <alltraps>

0010579e <vector137>:
.globl vector137
vector137:
  pushl $0
  10579e:	6a 00                	push   $0x0
  pushl $137
  1057a0:	68 89 00 00 00       	push   $0x89
  jmp alltraps
  1057a5:	e9 76 f6 ff ff       	jmp    104e20 <alltraps>

001057aa <vector138>:
.globl vector138
vector138:
  pushl $0
  1057aa:	6a 00                	push   $0x0
  pushl $138
  1057ac:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
  1057b1:	e9 6a f6 ff ff       	jmp    104e20 <alltraps>

001057b6 <vector139>:
.globl vector139
vector139:
  pushl $0
  1057b6:	6a 00                	push   $0x0
  pushl $139
  1057b8:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
  1057bd:	e9 5e f6 ff ff       	jmp    104e20 <alltraps>

001057c2 <vector140>:
.globl vector140
vector140:
  pushl $0
  1057c2:	6a 00                	push   $0x0
  pushl $140
  1057c4:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
  1057c9:	e9 52 f6 ff ff       	jmp    104e20 <alltraps>

001057ce <vector141>:
.globl vector141
vector141:
  pushl $0
  1057ce:	6a 00                	push   $0x0
  pushl $141
  1057d0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
  1057d5:	e9 46 f6 ff ff       	jmp    104e20 <alltraps>

001057da <vector142>:
.globl vector142
vector142:
  pushl $0
  1057da:	6a 00                	push   $0x0
  pushl $142
  1057dc:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
  1057e1:	e9 3a f6 ff ff       	jmp    104e20 <alltraps>

001057e6 <vector143>:
.globl vector143
vector143:
  pushl $0
  1057e6:	6a 00                	push   $0x0
  pushl $143
  1057e8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
  1057ed:	e9 2e f6 ff ff       	jmp    104e20 <alltraps>

001057f2 <vector144>:
.globl vector144
vector144:
  pushl $0
  1057f2:	6a 00                	push   $0x0
  pushl $144
  1057f4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
  1057f9:	e9 22 f6 ff ff       	jmp    104e20 <alltraps>

001057fe <vector145>:
.globl vector145
vector145:
  pushl $0
  1057fe:	6a 00                	push   $0x0
  pushl $145
  105800:	68 91 00 00 00       	push   $0x91
  jmp alltraps
  105805:	e9 16 f6 ff ff       	jmp    104e20 <alltraps>

0010580a <vector146>:
.globl vector146
vector146:
  pushl $0
  10580a:	6a 00                	push   $0x0
  pushl $146
  10580c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
  105811:	e9 0a f6 ff ff       	jmp    104e20 <alltraps>

00105816 <vector147>:
.globl vector147
vector147:
  pushl $0
  105816:	6a 00                	push   $0x0
  pushl $147
  105818:	68 93 00 00 00       	push   $0x93
  jmp alltraps
  10581d:	e9 fe f5 ff ff       	jmp    104e20 <alltraps>

00105822 <vector148>:
.globl vector148
vector148:
  pushl $0
  105822:	6a 00                	push   $0x0
  pushl $148
  105824:	68 94 00 00 00       	push   $0x94
  jmp alltraps
  105829:	e9 f2 f5 ff ff       	jmp    104e20 <alltraps>

0010582e <vector149>:
.globl vector149
vector149:
  pushl $0
  10582e:	6a 00                	push   $0x0
  pushl $149
  105830:	68 95 00 00 00       	push   $0x95
  jmp alltraps
  105835:	e9 e6 f5 ff ff       	jmp    104e20 <alltraps>

0010583a <vector150>:
.globl vector150
vector150:
  pushl $0
  10583a:	6a 00                	push   $0x0
  pushl $150
  10583c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
  105841:	e9 da f5 ff ff       	jmp    104e20 <alltraps>

00105846 <vector151>:
.globl vector151
vector151:
  pushl $0
  105846:	6a 00                	push   $0x0
  pushl $151
  105848:	68 97 00 00 00       	push   $0x97
  jmp alltraps
  10584d:	e9 ce f5 ff ff       	jmp    104e20 <alltraps>

00105852 <vector152>:
.globl vector152
vector152:
  pushl $0
  105852:	6a 00                	push   $0x0
  pushl $152
  105854:	68 98 00 00 00       	push   $0x98
  jmp alltraps
  105859:	e9 c2 f5 ff ff       	jmp    104e20 <alltraps>

0010585e <vector153>:
.globl vector153
vector153:
  pushl $0
  10585e:	6a 00                	push   $0x0
  pushl $153
  105860:	68 99 00 00 00       	push   $0x99
  jmp alltraps
  105865:	e9 b6 f5 ff ff       	jmp    104e20 <alltraps>

0010586a <vector154>:
.globl vector154
vector154:
  pushl $0
  10586a:	6a 00                	push   $0x0
  pushl $154
  10586c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
  105871:	e9 aa f5 ff ff       	jmp    104e20 <alltraps>

00105876 <vector155>:
.globl vector155
vector155:
  pushl $0
  105876:	6a 00                	push   $0x0
  pushl $155
  105878:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
  10587d:	e9 9e f5 ff ff       	jmp    104e20 <alltraps>

00105882 <vector156>:
.globl vector156
vector156:
  pushl $0
  105882:	6a 00                	push   $0x0
  pushl $156
  105884:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
  105889:	e9 92 f5 ff ff       	jmp    104e20 <alltraps>

0010588e <vector157>:
.globl vector157
vector157:
  pushl $0
  10588e:	6a 00                	push   $0x0
  pushl $157
  105890:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
  105895:	e9 86 f5 ff ff       	jmp    104e20 <alltraps>

0010589a <vector158>:
.globl vector158
vector158:
  pushl $0
  10589a:	6a 00                	push   $0x0
  pushl $158
  10589c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
  1058a1:	e9 7a f5 ff ff       	jmp    104e20 <alltraps>

001058a6 <vector159>:
.globl vector159
vector159:
  pushl $0
  1058a6:	6a 00                	push   $0x0
  pushl $159
  1058a8:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
  1058ad:	e9 6e f5 ff ff       	jmp    104e20 <alltraps>

001058b2 <vector160>:
.globl vector160
vector160:
  pushl $0
  1058b2:	6a 00                	push   $0x0
  pushl $160
  1058b4:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
  1058b9:	e9 62 f5 ff ff       	jmp    104e20 <alltraps>

001058be <vector161>:
.globl vector161
vector161:
  pushl $0
  1058be:	6a 00                	push   $0x0
  pushl $161
  1058c0:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
  1058c5:	e9 56 f5 ff ff       	jmp    104e20 <alltraps>

001058ca <vector162>:
.globl vector162
vector162:
  pushl $0
  1058ca:	6a 00                	push   $0x0
  pushl $162
  1058cc:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
  1058d1:	e9 4a f5 ff ff       	jmp    104e20 <alltraps>

001058d6 <vector163>:
.globl vector163
vector163:
  pushl $0
  1058d6:	6a 00                	push   $0x0
  pushl $163
  1058d8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
  1058dd:	e9 3e f5 ff ff       	jmp    104e20 <alltraps>

001058e2 <vector164>:
.globl vector164
vector164:
  pushl $0
  1058e2:	6a 00                	push   $0x0
  pushl $164
  1058e4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
  1058e9:	e9 32 f5 ff ff       	jmp    104e20 <alltraps>

001058ee <vector165>:
.globl vector165
vector165:
  pushl $0
  1058ee:	6a 00                	push   $0x0
  pushl $165
  1058f0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
  1058f5:	e9 26 f5 ff ff       	jmp    104e20 <alltraps>

001058fa <vector166>:
.globl vector166
vector166:
  pushl $0
  1058fa:	6a 00                	push   $0x0
  pushl $166
  1058fc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
  105901:	e9 1a f5 ff ff       	jmp    104e20 <alltraps>

00105906 <vector167>:
.globl vector167
vector167:
  pushl $0
  105906:	6a 00                	push   $0x0
  pushl $167
  105908:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
  10590d:	e9 0e f5 ff ff       	jmp    104e20 <alltraps>

00105912 <vector168>:
.globl vector168
vector168:
  pushl $0
  105912:	6a 00                	push   $0x0
  pushl $168
  105914:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
  105919:	e9 02 f5 ff ff       	jmp    104e20 <alltraps>

0010591e <vector169>:
.globl vector169
vector169:
  pushl $0
  10591e:	6a 00                	push   $0x0
  pushl $169
  105920:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
  105925:	e9 f6 f4 ff ff       	jmp    104e20 <alltraps>

0010592a <vector170>:
.globl vector170
vector170:
  pushl $0
  10592a:	6a 00                	push   $0x0
  pushl $170
  10592c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
  105931:	e9 ea f4 ff ff       	jmp    104e20 <alltraps>

00105936 <vector171>:
.globl vector171
vector171:
  pushl $0
  105936:	6a 00                	push   $0x0
  pushl $171
  105938:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
  10593d:	e9 de f4 ff ff       	jmp    104e20 <alltraps>

00105942 <vector172>:
.globl vector172
vector172:
  pushl $0
  105942:	6a 00                	push   $0x0
  pushl $172
  105944:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
  105949:	e9 d2 f4 ff ff       	jmp    104e20 <alltraps>

0010594e <vector173>:
.globl vector173
vector173:
  pushl $0
  10594e:	6a 00                	push   $0x0
  pushl $173
  105950:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
  105955:	e9 c6 f4 ff ff       	jmp    104e20 <alltraps>

0010595a <vector174>:
.globl vector174
vector174:
  pushl $0
  10595a:	6a 00                	push   $0x0
  pushl $174
  10595c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
  105961:	e9 ba f4 ff ff       	jmp    104e20 <alltraps>

00105966 <vector175>:
.globl vector175
vector175:
  pushl $0
  105966:	6a 00                	push   $0x0
  pushl $175
  105968:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
  10596d:	e9 ae f4 ff ff       	jmp    104e20 <alltraps>

00105972 <vector176>:
.globl vector176
vector176:
  pushl $0
  105972:	6a 00                	push   $0x0
  pushl $176
  105974:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
  105979:	e9 a2 f4 ff ff       	jmp    104e20 <alltraps>

0010597e <vector177>:
.globl vector177
vector177:
  pushl $0
  10597e:	6a 00                	push   $0x0
  pushl $177
  105980:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
  105985:	e9 96 f4 ff ff       	jmp    104e20 <alltraps>

0010598a <vector178>:
.globl vector178
vector178:
  pushl $0
  10598a:	6a 00                	push   $0x0
  pushl $178
  10598c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
  105991:	e9 8a f4 ff ff       	jmp    104e20 <alltraps>

00105996 <vector179>:
.globl vector179
vector179:
  pushl $0
  105996:	6a 00                	push   $0x0
  pushl $179
  105998:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
  10599d:	e9 7e f4 ff ff       	jmp    104e20 <alltraps>

001059a2 <vector180>:
.globl vector180
vector180:
  pushl $0
  1059a2:	6a 00                	push   $0x0
  pushl $180
  1059a4:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
  1059a9:	e9 72 f4 ff ff       	jmp    104e20 <alltraps>

001059ae <vector181>:
.globl vector181
vector181:
  pushl $0
  1059ae:	6a 00                	push   $0x0
  pushl $181
  1059b0:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
  1059b5:	e9 66 f4 ff ff       	jmp    104e20 <alltraps>

001059ba <vector182>:
.globl vector182
vector182:
  pushl $0
  1059ba:	6a 00                	push   $0x0
  pushl $182
  1059bc:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
  1059c1:	e9 5a f4 ff ff       	jmp    104e20 <alltraps>

001059c6 <vector183>:
.globl vector183
vector183:
  pushl $0
  1059c6:	6a 00                	push   $0x0
  pushl $183
  1059c8:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
  1059cd:	e9 4e f4 ff ff       	jmp    104e20 <alltraps>

001059d2 <vector184>:
.globl vector184
vector184:
  pushl $0
  1059d2:	6a 00                	push   $0x0
  pushl $184
  1059d4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
  1059d9:	e9 42 f4 ff ff       	jmp    104e20 <alltraps>

001059de <vector185>:
.globl vector185
vector185:
  pushl $0
  1059de:	6a 00                	push   $0x0
  pushl $185
  1059e0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
  1059e5:	e9 36 f4 ff ff       	jmp    104e20 <alltraps>

001059ea <vector186>:
.globl vector186
vector186:
  pushl $0
  1059ea:	6a 00                	push   $0x0
  pushl $186
  1059ec:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
  1059f1:	e9 2a f4 ff ff       	jmp    104e20 <alltraps>

001059f6 <vector187>:
.globl vector187
vector187:
  pushl $0
  1059f6:	6a 00                	push   $0x0
  pushl $187
  1059f8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
  1059fd:	e9 1e f4 ff ff       	jmp    104e20 <alltraps>

00105a02 <vector188>:
.globl vector188
vector188:
  pushl $0
  105a02:	6a 00                	push   $0x0
  pushl $188
  105a04:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
  105a09:	e9 12 f4 ff ff       	jmp    104e20 <alltraps>

00105a0e <vector189>:
.globl vector189
vector189:
  pushl $0
  105a0e:	6a 00                	push   $0x0
  pushl $189
  105a10:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
  105a15:	e9 06 f4 ff ff       	jmp    104e20 <alltraps>

00105a1a <vector190>:
.globl vector190
vector190:
  pushl $0
  105a1a:	6a 00                	push   $0x0
  pushl $190
  105a1c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
  105a21:	e9 fa f3 ff ff       	jmp    104e20 <alltraps>

00105a26 <vector191>:
.globl vector191
vector191:
  pushl $0
  105a26:	6a 00                	push   $0x0
  pushl $191
  105a28:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
  105a2d:	e9 ee f3 ff ff       	jmp    104e20 <alltraps>

00105a32 <vector192>:
.globl vector192
vector192:
  pushl $0
  105a32:	6a 00                	push   $0x0
  pushl $192
  105a34:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
  105a39:	e9 e2 f3 ff ff       	jmp    104e20 <alltraps>

00105a3e <vector193>:
.globl vector193
vector193:
  pushl $0
  105a3e:	6a 00                	push   $0x0
  pushl $193
  105a40:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
  105a45:	e9 d6 f3 ff ff       	jmp    104e20 <alltraps>

00105a4a <vector194>:
.globl vector194
vector194:
  pushl $0
  105a4a:	6a 00                	push   $0x0
  pushl $194
  105a4c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
  105a51:	e9 ca f3 ff ff       	jmp    104e20 <alltraps>

00105a56 <vector195>:
.globl vector195
vector195:
  pushl $0
  105a56:	6a 00                	push   $0x0
  pushl $195
  105a58:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
  105a5d:	e9 be f3 ff ff       	jmp    104e20 <alltraps>

00105a62 <vector196>:
.globl vector196
vector196:
  pushl $0
  105a62:	6a 00                	push   $0x0
  pushl $196
  105a64:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
  105a69:	e9 b2 f3 ff ff       	jmp    104e20 <alltraps>

00105a6e <vector197>:
.globl vector197
vector197:
  pushl $0
  105a6e:	6a 00                	push   $0x0
  pushl $197
  105a70:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
  105a75:	e9 a6 f3 ff ff       	jmp    104e20 <alltraps>

00105a7a <vector198>:
.globl vector198
vector198:
  pushl $0
  105a7a:	6a 00                	push   $0x0
  pushl $198
  105a7c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
  105a81:	e9 9a f3 ff ff       	jmp    104e20 <alltraps>

00105a86 <vector199>:
.globl vector199
vector199:
  pushl $0
  105a86:	6a 00                	push   $0x0
  pushl $199
  105a88:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
  105a8d:	e9 8e f3 ff ff       	jmp    104e20 <alltraps>

00105a92 <vector200>:
.globl vector200
vector200:
  pushl $0
  105a92:	6a 00                	push   $0x0
  pushl $200
  105a94:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
  105a99:	e9 82 f3 ff ff       	jmp    104e20 <alltraps>

00105a9e <vector201>:
.globl vector201
vector201:
  pushl $0
  105a9e:	6a 00                	push   $0x0
  pushl $201
  105aa0:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
  105aa5:	e9 76 f3 ff ff       	jmp    104e20 <alltraps>

00105aaa <vector202>:
.globl vector202
vector202:
  pushl $0
  105aaa:	6a 00                	push   $0x0
  pushl $202
  105aac:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
  105ab1:	e9 6a f3 ff ff       	jmp    104e20 <alltraps>

00105ab6 <vector203>:
.globl vector203
vector203:
  pushl $0
  105ab6:	6a 00                	push   $0x0
  pushl $203
  105ab8:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
  105abd:	e9 5e f3 ff ff       	jmp    104e20 <alltraps>

00105ac2 <vector204>:
.globl vector204
vector204:
  pushl $0
  105ac2:	6a 00                	push   $0x0
  pushl $204
  105ac4:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
  105ac9:	e9 52 f3 ff ff       	jmp    104e20 <alltraps>

00105ace <vector205>:
.globl vector205
vector205:
  pushl $0
  105ace:	6a 00                	push   $0x0
  pushl $205
  105ad0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
  105ad5:	e9 46 f3 ff ff       	jmp    104e20 <alltraps>

00105ada <vector206>:
.globl vector206
vector206:
  pushl $0
  105ada:	6a 00                	push   $0x0
  pushl $206
  105adc:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
  105ae1:	e9 3a f3 ff ff       	jmp    104e20 <alltraps>

00105ae6 <vector207>:
.globl vector207
vector207:
  pushl $0
  105ae6:	6a 00                	push   $0x0
  pushl $207
  105ae8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
  105aed:	e9 2e f3 ff ff       	jmp    104e20 <alltraps>

00105af2 <vector208>:
.globl vector208
vector208:
  pushl $0
  105af2:	6a 00                	push   $0x0
  pushl $208
  105af4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
  105af9:	e9 22 f3 ff ff       	jmp    104e20 <alltraps>

00105afe <vector209>:
.globl vector209
vector209:
  pushl $0
  105afe:	6a 00                	push   $0x0
  pushl $209
  105b00:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
  105b05:	e9 16 f3 ff ff       	jmp    104e20 <alltraps>

00105b0a <vector210>:
.globl vector210
vector210:
  pushl $0
  105b0a:	6a 00                	push   $0x0
  pushl $210
  105b0c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
  105b11:	e9 0a f3 ff ff       	jmp    104e20 <alltraps>

00105b16 <vector211>:
.globl vector211
vector211:
  pushl $0
  105b16:	6a 00                	push   $0x0
  pushl $211
  105b18:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
  105b1d:	e9 fe f2 ff ff       	jmp    104e20 <alltraps>

00105b22 <vector212>:
.globl vector212
vector212:
  pushl $0
  105b22:	6a 00                	push   $0x0
  pushl $212
  105b24:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
  105b29:	e9 f2 f2 ff ff       	jmp    104e20 <alltraps>

00105b2e <vector213>:
.globl vector213
vector213:
  pushl $0
  105b2e:	6a 00                	push   $0x0
  pushl $213
  105b30:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
  105b35:	e9 e6 f2 ff ff       	jmp    104e20 <alltraps>

00105b3a <vector214>:
.globl vector214
vector214:
  pushl $0
  105b3a:	6a 00                	push   $0x0
  pushl $214
  105b3c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
  105b41:	e9 da f2 ff ff       	jmp    104e20 <alltraps>

00105b46 <vector215>:
.globl vector215
vector215:
  pushl $0
  105b46:	6a 00                	push   $0x0
  pushl $215
  105b48:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
  105b4d:	e9 ce f2 ff ff       	jmp    104e20 <alltraps>

00105b52 <vector216>:
.globl vector216
vector216:
  pushl $0
  105b52:	6a 00                	push   $0x0
  pushl $216
  105b54:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
  105b59:	e9 c2 f2 ff ff       	jmp    104e20 <alltraps>

00105b5e <vector217>:
.globl vector217
vector217:
  pushl $0
  105b5e:	6a 00                	push   $0x0
  pushl $217
  105b60:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
  105b65:	e9 b6 f2 ff ff       	jmp    104e20 <alltraps>

00105b6a <vector218>:
.globl vector218
vector218:
  pushl $0
  105b6a:	6a 00                	push   $0x0
  pushl $218
  105b6c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
  105b71:	e9 aa f2 ff ff       	jmp    104e20 <alltraps>

00105b76 <vector219>:
.globl vector219
vector219:
  pushl $0
  105b76:	6a 00                	push   $0x0
  pushl $219
  105b78:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
  105b7d:	e9 9e f2 ff ff       	jmp    104e20 <alltraps>

00105b82 <vector220>:
.globl vector220
vector220:
  pushl $0
  105b82:	6a 00                	push   $0x0
  pushl $220
  105b84:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
  105b89:	e9 92 f2 ff ff       	jmp    104e20 <alltraps>

00105b8e <vector221>:
.globl vector221
vector221:
  pushl $0
  105b8e:	6a 00                	push   $0x0
  pushl $221
  105b90:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
  105b95:	e9 86 f2 ff ff       	jmp    104e20 <alltraps>

00105b9a <vector222>:
.globl vector222
vector222:
  pushl $0
  105b9a:	6a 00                	push   $0x0
  pushl $222
  105b9c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
  105ba1:	e9 7a f2 ff ff       	jmp    104e20 <alltraps>

00105ba6 <vector223>:
.globl vector223
vector223:
  pushl $0
  105ba6:	6a 00                	push   $0x0
  pushl $223
  105ba8:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
  105bad:	e9 6e f2 ff ff       	jmp    104e20 <alltraps>

00105bb2 <vector224>:
.globl vector224
vector224:
  pushl $0
  105bb2:	6a 00                	push   $0x0
  pushl $224
  105bb4:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
  105bb9:	e9 62 f2 ff ff       	jmp    104e20 <alltraps>

00105bbe <vector225>:
.globl vector225
vector225:
  pushl $0
  105bbe:	6a 00                	push   $0x0
  pushl $225
  105bc0:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
  105bc5:	e9 56 f2 ff ff       	jmp    104e20 <alltraps>

00105bca <vector226>:
.globl vector226
vector226:
  pushl $0
  105bca:	6a 00                	push   $0x0
  pushl $226
  105bcc:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
  105bd1:	e9 4a f2 ff ff       	jmp    104e20 <alltraps>

00105bd6 <vector227>:
.globl vector227
vector227:
  pushl $0
  105bd6:	6a 00                	push   $0x0
  pushl $227
  105bd8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
  105bdd:	e9 3e f2 ff ff       	jmp    104e20 <alltraps>

00105be2 <vector228>:
.globl vector228
vector228:
  pushl $0
  105be2:	6a 00                	push   $0x0
  pushl $228
  105be4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
  105be9:	e9 32 f2 ff ff       	jmp    104e20 <alltraps>

00105bee <vector229>:
.globl vector229
vector229:
  pushl $0
  105bee:	6a 00                	push   $0x0
  pushl $229
  105bf0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
  105bf5:	e9 26 f2 ff ff       	jmp    104e20 <alltraps>

00105bfa <vector230>:
.globl vector230
vector230:
  pushl $0
  105bfa:	6a 00                	push   $0x0
  pushl $230
  105bfc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
  105c01:	e9 1a f2 ff ff       	jmp    104e20 <alltraps>

00105c06 <vector231>:
.globl vector231
vector231:
  pushl $0
  105c06:	6a 00                	push   $0x0
  pushl $231
  105c08:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
  105c0d:	e9 0e f2 ff ff       	jmp    104e20 <alltraps>

00105c12 <vector232>:
.globl vector232
vector232:
  pushl $0
  105c12:	6a 00                	push   $0x0
  pushl $232
  105c14:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
  105c19:	e9 02 f2 ff ff       	jmp    104e20 <alltraps>

00105c1e <vector233>:
.globl vector233
vector233:
  pushl $0
  105c1e:	6a 00                	push   $0x0
  pushl $233
  105c20:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
  105c25:	e9 f6 f1 ff ff       	jmp    104e20 <alltraps>

00105c2a <vector234>:
.globl vector234
vector234:
  pushl $0
  105c2a:	6a 00                	push   $0x0
  pushl $234
  105c2c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
  105c31:	e9 ea f1 ff ff       	jmp    104e20 <alltraps>

00105c36 <vector235>:
.globl vector235
vector235:
  pushl $0
  105c36:	6a 00                	push   $0x0
  pushl $235
  105c38:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
  105c3d:	e9 de f1 ff ff       	jmp    104e20 <alltraps>

00105c42 <vector236>:
.globl vector236
vector236:
  pushl $0
  105c42:	6a 00                	push   $0x0
  pushl $236
  105c44:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
  105c49:	e9 d2 f1 ff ff       	jmp    104e20 <alltraps>

00105c4e <vector237>:
.globl vector237
vector237:
  pushl $0
  105c4e:	6a 00                	push   $0x0
  pushl $237
  105c50:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
  105c55:	e9 c6 f1 ff ff       	jmp    104e20 <alltraps>

00105c5a <vector238>:
.globl vector238
vector238:
  pushl $0
  105c5a:	6a 00                	push   $0x0
  pushl $238
  105c5c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
  105c61:	e9 ba f1 ff ff       	jmp    104e20 <alltraps>

00105c66 <vector239>:
.globl vector239
vector239:
  pushl $0
  105c66:	6a 00                	push   $0x0
  pushl $239
  105c68:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
  105c6d:	e9 ae f1 ff ff       	jmp    104e20 <alltraps>

00105c72 <vector240>:
.globl vector240
vector240:
  pushl $0
  105c72:	6a 00                	push   $0x0
  pushl $240
  105c74:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
  105c79:	e9 a2 f1 ff ff       	jmp    104e20 <alltraps>

00105c7e <vector241>:
.globl vector241
vector241:
  pushl $0
  105c7e:	6a 00                	push   $0x0
  pushl $241
  105c80:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
  105c85:	e9 96 f1 ff ff       	jmp    104e20 <alltraps>

00105c8a <vector242>:
.globl vector242
vector242:
  pushl $0
  105c8a:	6a 00                	push   $0x0
  pushl $242
  105c8c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
  105c91:	e9 8a f1 ff ff       	jmp    104e20 <alltraps>

00105c96 <vector243>:
.globl vector243
vector243:
  pushl $0
  105c96:	6a 00                	push   $0x0
  pushl $243
  105c98:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
  105c9d:	e9 7e f1 ff ff       	jmp    104e20 <alltraps>

00105ca2 <vector244>:
.globl vector244
vector244:
  pushl $0
  105ca2:	6a 00                	push   $0x0
  pushl $244
  105ca4:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
  105ca9:	e9 72 f1 ff ff       	jmp    104e20 <alltraps>

00105cae <vector245>:
.globl vector245
vector245:
  pushl $0
  105cae:	6a 00                	push   $0x0
  pushl $245
  105cb0:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
  105cb5:	e9 66 f1 ff ff       	jmp    104e20 <alltraps>

00105cba <vector246>:
.globl vector246
vector246:
  pushl $0
  105cba:	6a 00                	push   $0x0
  pushl $246
  105cbc:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
  105cc1:	e9 5a f1 ff ff       	jmp    104e20 <alltraps>

00105cc6 <vector247>:
.globl vector247
vector247:
  pushl $0
  105cc6:	6a 00                	push   $0x0
  pushl $247
  105cc8:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
  105ccd:	e9 4e f1 ff ff       	jmp    104e20 <alltraps>

00105cd2 <vector248>:
.globl vector248
vector248:
  pushl $0
  105cd2:	6a 00                	push   $0x0
  pushl $248
  105cd4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
  105cd9:	e9 42 f1 ff ff       	jmp    104e20 <alltraps>

00105cde <vector249>:
.globl vector249
vector249:
  pushl $0
  105cde:	6a 00                	push   $0x0
  pushl $249
  105ce0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
  105ce5:	e9 36 f1 ff ff       	jmp    104e20 <alltraps>

00105cea <vector250>:
.globl vector250
vector250:
  pushl $0
  105cea:	6a 00                	push   $0x0
  pushl $250
  105cec:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
  105cf1:	e9 2a f1 ff ff       	jmp    104e20 <alltraps>

00105cf6 <vector251>:
.globl vector251
vector251:
  pushl $0
  105cf6:	6a 00                	push   $0x0
  pushl $251
  105cf8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
  105cfd:	e9 1e f1 ff ff       	jmp    104e20 <alltraps>

00105d02 <vector252>:
.globl vector252
vector252:
  pushl $0
  105d02:	6a 00                	push   $0x0
  pushl $252
  105d04:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
  105d09:	e9 12 f1 ff ff       	jmp    104e20 <alltraps>

00105d0e <vector253>:
.globl vector253
vector253:
  pushl $0
  105d0e:	6a 00                	push   $0x0
  pushl $253
  105d10:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
  105d15:	e9 06 f1 ff ff       	jmp    104e20 <alltraps>

00105d1a <vector254>:
.globl vector254
vector254:
  pushl $0
  105d1a:	6a 00                	push   $0x0
  pushl $254
  105d1c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
  105d21:	e9 fa f0 ff ff       	jmp    104e20 <alltraps>

00105d26 <vector255>:
.globl vector255
vector255:
  pushl $0
  105d26:	6a 00                	push   $0x0
  pushl $255
  105d28:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
  105d2d:	e9 ee f0 ff ff       	jmp    104e20 <alltraps>
  105d32:	90                   	nop
  105d33:	90                   	nop
  105d34:	90                   	nop
  105d35:	90                   	nop
  105d36:	90                   	nop
  105d37:	90                   	nop
  105d38:	90                   	nop
  105d39:	90                   	nop
  105d3a:	90                   	nop
  105d3b:	90                   	nop
  105d3c:	90                   	nop
  105d3d:	90                   	nop
  105d3e:	90                   	nop
  105d3f:	90                   	nop

00105d40 <vmenable>:
}

// Turn on paging.
void
vmenable(void)
{
  105d40:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105d41:	a1 d8 78 10 00       	mov    0x1078d8,%eax
  105d46:	89 e5                	mov    %esp,%ebp
  105d48:	0f 22 d8             	mov    %eax,%cr3

static inline uint
rcr0(void)
{
  uint val;
  asm volatile("movl %%cr0,%0" : "=r" (val));
  105d4b:	0f 20 c0             	mov    %cr0,%eax
}

static inline void
lcr0(uint val)
{
  asm volatile("movl %0,%%cr0" : : "r" (val));
  105d4e:	0d 00 00 00 80       	or     $0x80000000,%eax
  105d53:	0f 22 c0             	mov    %eax,%cr0

  switchkvm(); // load kpgdir into cr3
  cr0 = rcr0();
  cr0 |= CR0_PG;
  lcr0(cr0);
}
  105d56:	5d                   	pop    %ebp
  105d57:	c3                   	ret    
  105d58:	90                   	nop
  105d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00105d60 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  105d60:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105d61:	a1 d8 78 10 00       	mov    0x1078d8,%eax
  105d66:	89 e5                	mov    %esp,%ebp
  105d68:	0f 22 d8             	mov    %eax,%cr3
  lcr3(PADDR(kpgdir));   // switch to the kernel page table
}
  105d6b:	5d                   	pop    %ebp
  105d6c:	c3                   	ret    
  105d6d:	8d 76 00             	lea    0x0(%esi),%esi

00105d70 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105d70:	55                   	push   %ebp
  105d71:	89 e5                	mov    %esp,%ebp
  105d73:	83 ec 28             	sub    $0x28,%esp
  105d76:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  105d79:	89 d3                	mov    %edx,%ebx
  105d7b:	c1 eb 16             	shr    $0x16,%ebx
  105d7e:	8d 1c 98             	lea    (%eax,%ebx,4),%ebx
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105d81:	89 75 fc             	mov    %esi,-0x4(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
  105d84:	8b 33                	mov    (%ebx),%esi
  105d86:	f7 c6 01 00 00 00    	test   $0x1,%esi
  105d8c:	74 22                	je     105db0 <walkpgdir+0x40>
    pgtab = (pte_t*)PTE_ADDR(*pde);
  105d8e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105d94:	c1 ea 0a             	shr    $0xa,%edx
  105d97:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  105d9d:	8d 04 16             	lea    (%esi,%edx,1),%eax
}
  105da0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  105da3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  105da6:	89 ec                	mov    %ebp,%esp
  105da8:	5d                   	pop    %ebp
  105da9:	c3                   	ret    
  105daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105db0:	85 c9                	test   %ecx,%ecx
  105db2:	75 04                	jne    105db8 <walkpgdir+0x48>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105db4:	31 c0                	xor    %eax,%eax
  105db6:	eb e8                	jmp    105da0 <walkpgdir+0x30>

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105db8:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105dbb:	90                   	nop
  105dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105dc0:	e8 8b c4 ff ff       	call   102250 <kalloc>
  105dc5:	85 c0                	test   %eax,%eax
  105dc7:	89 c6                	mov    %eax,%esi
  105dc9:	74 e9                	je     105db4 <walkpgdir+0x44>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
  105dcb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105dd2:	00 
  105dd3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105dda:	00 
  105ddb:	89 04 24             	mov    %eax,(%esp)
  105dde:	e8 ed dd ff ff       	call   103bd0 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  105de3:	89 f0                	mov    %esi,%eax
  105de5:	83 c8 07             	or     $0x7,%eax
  105de8:	89 03                	mov    %eax,(%ebx)
  105dea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ded:	eb a5                	jmp    105d94 <walkpgdir+0x24>
  105def:	90                   	nop

00105df0 <uva2ka>:
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105df0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105df1:	31 c9                	xor    %ecx,%ecx
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105df3:	89 e5                	mov    %esp,%ebp
  105df5:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105df8:	8b 55 0c             	mov    0xc(%ebp),%edx
  105dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  105dfe:	e8 6d ff ff ff       	call   105d70 <walkpgdir>
  if((*pte & PTE_P) == 0)
  105e03:	8b 00                	mov    (%eax),%eax
  105e05:	a8 01                	test   $0x1,%al
  105e07:	75 07                	jne    105e10 <uva2ka+0x20>
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)PTE_ADDR(*pte);
  105e09:	31 c0                	xor    %eax,%eax
}
  105e0b:	c9                   	leave  
  105e0c:	c3                   	ret    
  105e0d:	8d 76 00             	lea    0x0(%esi),%esi
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
  105e10:	a8 04                	test   $0x4,%al
  105e12:	74 f5                	je     105e09 <uva2ka+0x19>
    return 0;
  return (char*)PTE_ADDR(*pte);
  105e14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
  105e19:	c9                   	leave  
  105e1a:	c3                   	ret    
  105e1b:	90                   	nop
  105e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00105e20 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  105e20:	55                   	push   %ebp
  105e21:	89 e5                	mov    %esp,%ebp
  105e23:	57                   	push   %edi
  105e24:	56                   	push   %esi
  105e25:	53                   	push   %ebx
  105e26:	83 ec 2c             	sub    $0x2c,%esp
  105e29:	8b 7d 14             	mov    0x14(%ebp),%edi
  105e2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  105e2f:	85 ff                	test   %edi,%edi
  105e31:	74 75                	je     105ea8 <copyout+0x88>
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  105e33:	8b 45 10             	mov    0x10(%ebp),%eax
  105e36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105e39:	eb 3a                	jmp    105e75 <copyout+0x55>
  105e3b:	90                   	nop
  105e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
  105e40:	89 f3                	mov    %esi,%ebx
  105e42:	29 d3                	sub    %edx,%ebx
  105e44:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  105e4a:	39 fb                	cmp    %edi,%ebx
  105e4c:	76 02                	jbe    105e50 <copyout+0x30>
  105e4e:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
  105e50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  105e54:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  105e57:	29 f2                	sub    %esi,%edx
  105e59:	8d 14 10             	lea    (%eax,%edx,1),%edx
  105e5c:	89 14 24             	mov    %edx,(%esp)
  105e5f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  105e63:	e8 e8 dd ff ff       	call   103c50 <memmove>
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  105e68:	29 df                	sub    %ebx,%edi
  105e6a:	74 3c                	je     105ea8 <copyout+0x88>
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
  105e6c:	01 5d e4             	add    %ebx,-0x1c(%ebp)
    va = va0 + PGSIZE;
  105e6f:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
  105e75:	89 d6                	mov    %edx,%esi
  105e77:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
  105e7d:	89 74 24 04          	mov    %esi,0x4(%esp)
  105e81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  105e84:	89 0c 24             	mov    %ecx,(%esp)
  105e87:	89 55 e0             	mov    %edx,-0x20(%ebp)
  105e8a:	e8 61 ff ff ff       	call   105df0 <uva2ka>
    if(pa0 == 0)
  105e8f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105e92:	85 c0                	test   %eax,%eax
  105e94:	75 aa                	jne    105e40 <copyout+0x20>
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
  105e96:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  105e99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
  105e9e:	5b                   	pop    %ebx
  105e9f:	5e                   	pop    %esi
  105ea0:	5f                   	pop    %edi
  105ea1:	5d                   	pop    %ebp
  105ea2:	c3                   	ret    
  105ea3:	90                   	nop
  105ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105ea8:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  105eab:	31 c0                	xor    %eax,%eax
  }
  return 0;
}
  105ead:	5b                   	pop    %ebx
  105eae:	5e                   	pop    %esi
  105eaf:	5f                   	pop    %edi
  105eb0:	5d                   	pop    %ebp
  105eb1:	c3                   	ret    
  105eb2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  105eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00105ec0 <mappages>:
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  105ec0:	55                   	push   %ebp
  105ec1:	89 e5                	mov    %esp,%ebp
  105ec3:	57                   	push   %edi
  105ec4:	56                   	push   %esi
  105ec5:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  105ec6:	89 d3                	mov    %edx,%ebx
  last = PGROUNDDOWN(la + size - 1);
  105ec8:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  105ecc:	83 ec 2c             	sub    $0x2c,%esp
  105ecf:	8b 75 08             	mov    0x8(%ebp),%esi
  105ed2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  105ed5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = PGROUNDDOWN(la + size - 1);
  105edb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  105ee1:	83 4d 0c 01          	orl    $0x1,0xc(%ebp)
  105ee5:	eb 1d                	jmp    105f04 <mappages+0x44>
  105ee7:	90                   	nop
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
  105ee8:	f6 00 01             	testb  $0x1,(%eax)
  105eeb:	75 45                	jne    105f32 <mappages+0x72>
      panic("remap");
    *pte = pa | perm | PTE_P;
  105eed:	8b 55 0c             	mov    0xc(%ebp),%edx
  105ef0:	09 f2                	or     %esi,%edx
    if(a == last)
  105ef2:	39 fb                	cmp    %edi,%ebx
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  105ef4:	89 10                	mov    %edx,(%eax)
    if(a == last)
  105ef6:	74 30                	je     105f28 <mappages+0x68>
      break;
    a += PGSIZE;
  105ef8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
  105efe:	81 c6 00 10 00 00    	add    $0x1000,%esi
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
  105f04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105f07:	b9 01 00 00 00       	mov    $0x1,%ecx
  105f0c:	89 da                	mov    %ebx,%edx
  105f0e:	e8 5d fe ff ff       	call   105d70 <walkpgdir>
    if(pte == 0)
  105f13:	85 c0                	test   %eax,%eax
  105f15:	75 d1                	jne    105ee8 <mappages+0x28>
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  105f17:	83 c4 2c             	add    $0x2c,%esp
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  105f1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  105f1f:	5b                   	pop    %ebx
  105f20:	5e                   	pop    %esi
  105f21:	5f                   	pop    %edi
  105f22:	5d                   	pop    %ebp
  105f23:	c3                   	ret    
  105f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105f28:	83 c4 2c             	add    $0x2c,%esp
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
  105f2b:	31 c0                	xor    %eax,%eax
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  105f2d:	5b                   	pop    %ebx
  105f2e:	5e                   	pop    %esi
  105f2f:	5f                   	pop    %edi
  105f30:	5d                   	pop    %ebp
  105f31:	c3                   	ret    
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
  105f32:	c7 04 24 d0 6d 10 00 	movl   $0x106dd0,(%esp)
  105f39:	e8 e2 a9 ff ff       	call   100920 <panic>
  105f3e:	66 90                	xchg   %ax,%ax

00105f40 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
  105f40:	55                   	push   %ebp
  105f41:	89 e5                	mov    %esp,%ebp
  105f43:	56                   	push   %esi
  105f44:	53                   	push   %ebx
  105f45:	83 ec 10             	sub    $0x10,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
  105f48:	e8 03 c3 ff ff       	call   102250 <kalloc>
  105f4d:	85 c0                	test   %eax,%eax
  105f4f:	89 c6                	mov    %eax,%esi
  105f51:	74 50                	je     105fa3 <setupkvm+0x63>
    return 0;
  memset(pgdir, 0, PGSIZE);
  105f53:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105f5a:	00 
  105f5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105f62:	00 
  105f63:	89 04 24             	mov    %eax,(%esp)
  105f66:	e8 65 dc ff ff       	call   103bd0 <memset>
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  105f6b:	b8 70 77 10 00       	mov    $0x107770,%eax
  105f70:	3d 40 77 10 00       	cmp    $0x107740,%eax
  105f75:	76 2c                	jbe    105fa3 <setupkvm+0x63>
  {(void*)0xFE000000, 0,               PTE_W},  // device mappings
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
  105f77:	bb 40 77 10 00       	mov    $0x107740,%ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  105f7c:	8b 13                	mov    (%ebx),%edx
  105f7e:	8b 4b 04             	mov    0x4(%ebx),%ecx
  105f81:	8b 43 08             	mov    0x8(%ebx),%eax
  105f84:	89 14 24             	mov    %edx,(%esp)
  105f87:	29 d1                	sub    %edx,%ecx
  105f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f8d:	89 f0                	mov    %esi,%eax
  105f8f:	e8 2c ff ff ff       	call   105ec0 <mappages>
  105f94:	85 c0                	test   %eax,%eax
  105f96:	78 18                	js     105fb0 <setupkvm+0x70>

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  105f98:	83 c3 0c             	add    $0xc,%ebx
  105f9b:	81 fb 70 77 10 00    	cmp    $0x107770,%ebx
  105fa1:	75 d9                	jne    105f7c <setupkvm+0x3c>
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
      return 0;

  return pgdir;
}
  105fa3:	83 c4 10             	add    $0x10,%esp
  105fa6:	89 f0                	mov    %esi,%eax
  105fa8:	5b                   	pop    %ebx
  105fa9:	5e                   	pop    %esi
  105faa:	5d                   	pop    %ebp
  105fab:	c3                   	ret    
  105fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  105fb0:	31 f6                	xor    %esi,%esi
      return 0;

  return pgdir;
}
  105fb2:	83 c4 10             	add    $0x10,%esp
  105fb5:	89 f0                	mov    %esi,%eax
  105fb7:	5b                   	pop    %ebx
  105fb8:	5e                   	pop    %esi
  105fb9:	5d                   	pop    %ebp
  105fba:	c3                   	ret    
  105fbb:	90                   	nop
  105fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00105fc0 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
  105fc0:	55                   	push   %ebp
  105fc1:	89 e5                	mov    %esp,%ebp
  105fc3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
  105fc6:	e8 75 ff ff ff       	call   105f40 <setupkvm>
  105fcb:	a3 d8 78 10 00       	mov    %eax,0x1078d8
}
  105fd0:	c9                   	leave  
  105fd1:	c3                   	ret    
  105fd2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  105fd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00105fe0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  105fe0:	55                   	push   %ebp
  105fe1:	89 e5                	mov    %esp,%ebp
  105fe3:	83 ec 38             	sub    $0x38,%esp
  105fe6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  105fe9:	8b 75 10             	mov    0x10(%ebp),%esi
  105fec:	8b 45 08             	mov    0x8(%ebp),%eax
  105fef:	89 7d fc             	mov    %edi,-0x4(%ebp)
  105ff2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  105ff5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  105ff8:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  105ffe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  106001:	77 53                	ja     106056 <inituvm+0x76>
    panic("inituvm: more than a page");
  mem = kalloc();
  106003:	e8 48 c2 ff ff       	call   102250 <kalloc>
  memset(mem, 0, PGSIZE);
  106008:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10600f:	00 
  106010:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  106017:	00 
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  106018:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
  10601a:	89 04 24             	mov    %eax,(%esp)
  10601d:	e8 ae db ff ff       	call   103bd0 <memset>
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  106022:	b9 00 10 00 00       	mov    $0x1000,%ecx
  106027:	31 d2                	xor    %edx,%edx
  106029:	89 1c 24             	mov    %ebx,(%esp)
  10602c:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  106033:	00 
  106034:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106037:	e8 84 fe ff ff       	call   105ec0 <mappages>
  memmove(mem, init, sz);
  10603c:	89 75 10             	mov    %esi,0x10(%ebp)
}
  10603f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106042:	89 7d 0c             	mov    %edi,0xc(%ebp)
}
  106045:	8b 7d fc             	mov    -0x4(%ebp),%edi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106048:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  10604b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10604e:	89 ec                	mov    %ebp,%esp
  106050:	5d                   	pop    %ebp
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106051:	e9 fa db ff ff       	jmp    103c50 <memmove>
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  106056:	c7 04 24 d6 6d 10 00 	movl   $0x106dd6,(%esp)
  10605d:	e8 be a8 ff ff       	call   100920 <panic>
  106062:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  106069:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106070 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106070:	55                   	push   %ebp
  106071:	89 e5                	mov    %esp,%ebp
  106073:	57                   	push   %edi
  106074:	56                   	push   %esi
  106075:	53                   	push   %ebx
  106076:	83 ec 2c             	sub    $0x2c,%esp
  106079:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  10607c:	39 75 10             	cmp    %esi,0x10(%ebp)
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  10607f:	8b 7d 08             	mov    0x8(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;
  106082:	89 f0                	mov    %esi,%eax
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  106084:	73 59                	jae    1060df <deallocuvm+0x6f>
    return oldsz;

  a = PGROUNDUP(newsz);
  106086:	8b 5d 10             	mov    0x10(%ebp),%ebx
  106089:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  10608f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
  106095:	39 de                	cmp    %ebx,%esi
  106097:	76 43                	jbe    1060dc <deallocuvm+0x6c>
  106099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
  1060a0:	31 c9                	xor    %ecx,%ecx
  1060a2:	89 da                	mov    %ebx,%edx
  1060a4:	89 f8                	mov    %edi,%eax
  1060a6:	e8 c5 fc ff ff       	call   105d70 <walkpgdir>
    if(pte && (*pte & PTE_P) != 0){
  1060ab:	85 c0                	test   %eax,%eax
  1060ad:	74 23                	je     1060d2 <deallocuvm+0x62>
  1060af:	8b 10                	mov    (%eax),%edx
  1060b1:	f6 c2 01             	test   $0x1,%dl
  1060b4:	74 1c                	je     1060d2 <deallocuvm+0x62>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
  1060b6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  1060bc:	74 29                	je     1060e7 <deallocuvm+0x77>
        panic("kfree");
      kfree((char*)pa);
  1060be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1060c1:	89 14 24             	mov    %edx,(%esp)
  1060c4:	e8 c7 c1 ff ff       	call   102290 <kfree>
      *pte = 0;
  1060c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1060cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
  1060d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  1060d8:	39 de                	cmp    %ebx,%esi
  1060da:	77 c4                	ja     1060a0 <deallocuvm+0x30>
        panic("kfree");
      kfree((char*)pa);
      *pte = 0;
    }
  }
  return newsz;
  1060dc:	8b 45 10             	mov    0x10(%ebp),%eax
}
  1060df:	83 c4 2c             	add    $0x2c,%esp
  1060e2:	5b                   	pop    %ebx
  1060e3:	5e                   	pop    %esi
  1060e4:	5f                   	pop    %edi
  1060e5:	5d                   	pop    %ebp
  1060e6:	c3                   	ret    
  for(; a  < oldsz; a += PGSIZE){
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(pte && (*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
  1060e7:	c7 04 24 7e 67 10 00 	movl   $0x10677e,(%esp)
  1060ee:	e8 2d a8 ff ff       	call   100920 <panic>
  1060f3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1060f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106100 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
  106100:	55                   	push   %ebp
  106101:	89 e5                	mov    %esp,%ebp
  106103:	56                   	push   %esi
  106104:	53                   	push   %ebx
  106105:	83 ec 10             	sub    $0x10,%esp
  106108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint i;

  if(pgdir == 0)
  10610b:	85 db                	test   %ebx,%ebx
  10610d:	74 59                	je     106168 <freevm+0x68>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  10610f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  106116:	00 
  106117:	31 f6                	xor    %esi,%esi
  106119:	c7 44 24 04 00 00 0a 	movl   $0xa0000,0x4(%esp)
  106120:	00 
  106121:	89 1c 24             	mov    %ebx,(%esp)
  106124:	e8 47 ff ff ff       	call   106070 <deallocuvm>
  106129:	eb 10                	jmp    10613b <freevm+0x3b>
  10612b:	90                   	nop
  10612c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(i = 0; i < NPDENTRIES; i++){
  106130:	83 c6 01             	add    $0x1,%esi
  106133:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106139:	74 1f                	je     10615a <freevm+0x5a>
    if(pgdir[i] & PTE_P)
  10613b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  10613e:	a8 01                	test   $0x1,%al
  106140:	74 ee                	je     106130 <freevm+0x30>
      kfree((char*)PTE_ADDR(pgdir[i]));
  106142:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106147:	83 c6 01             	add    $0x1,%esi
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  10614a:	89 04 24             	mov    %eax,(%esp)
  10614d:	e8 3e c1 ff ff       	call   102290 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106152:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106158:	75 e1                	jne    10613b <freevm+0x3b>
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  10615a:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  10615d:	83 c4 10             	add    $0x10,%esp
  106160:	5b                   	pop    %ebx
  106161:	5e                   	pop    %esi
  106162:	5d                   	pop    %ebp
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  106163:	e9 28 c1 ff ff       	jmp    102290 <kfree>
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  106168:	c7 04 24 f0 6d 10 00 	movl   $0x106df0,(%esp)
  10616f:	e8 ac a7 ff ff       	call   100920 <panic>
  106174:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10617a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00106180 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
  106180:	55                   	push   %ebp
  106181:	89 e5                	mov    %esp,%ebp
  106183:	57                   	push   %edi
  106184:	56                   	push   %esi
  106185:	53                   	push   %ebx
  106186:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
  106189:	e8 b2 fd ff ff       	call   105f40 <setupkvm>
  10618e:	85 c0                	test   %eax,%eax
  106190:	89 c6                	mov    %eax,%esi
  106192:	0f 84 84 00 00 00    	je     10621c <copyuvm+0x9c>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  106198:	8b 45 0c             	mov    0xc(%ebp),%eax
  10619b:	85 c0                	test   %eax,%eax
  10619d:	74 7d                	je     10621c <copyuvm+0x9c>
  10619f:	31 db                	xor    %ebx,%ebx
  1061a1:	eb 47                	jmp    1061ea <copyuvm+0x6a>
  1061a3:	90                   	nop
  1061a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)pa, PGSIZE);
  1061a8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  1061ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  1061b2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1061b9:	00 
  1061ba:	89 04 24             	mov    %eax,(%esp)
  1061bd:	e8 8e da ff ff       	call   103c50 <memmove>
    if(mappages(d, (void*)i, PGSIZE, PADDR(mem), PTE_W|PTE_U) < 0)
  1061c2:	b9 00 10 00 00       	mov    $0x1000,%ecx
  1061c7:	89 da                	mov    %ebx,%edx
  1061c9:	89 f0                	mov    %esi,%eax
  1061cb:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  1061d2:	00 
  1061d3:	89 3c 24             	mov    %edi,(%esp)
  1061d6:	e8 e5 fc ff ff       	call   105ec0 <mappages>
  1061db:	85 c0                	test   %eax,%eax
  1061dd:	78 33                	js     106212 <copyuvm+0x92>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  1061df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  1061e5:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
  1061e8:	76 32                	jbe    10621c <copyuvm+0x9c>
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
  1061ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1061ed:	31 c9                	xor    %ecx,%ecx
  1061ef:	89 da                	mov    %ebx,%edx
  1061f1:	e8 7a fb ff ff       	call   105d70 <walkpgdir>
  1061f6:	85 c0                	test   %eax,%eax
  1061f8:	74 2c                	je     106226 <copyuvm+0xa6>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
  1061fa:	8b 10                	mov    (%eax),%edx
  1061fc:	f6 c2 01             	test   $0x1,%dl
  1061ff:	74 31                	je     106232 <copyuvm+0xb2>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
  106201:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  106204:	e8 47 c0 ff ff       	call   102250 <kalloc>
  106209:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10620c:	85 c0                	test   %eax,%eax
  10620e:	89 c7                	mov    %eax,%edi
  106210:	75 96                	jne    1061a8 <copyuvm+0x28>
      goto bad;
  }
  return d;

bad:
  freevm(d);
  106212:	89 34 24             	mov    %esi,(%esp)
  106215:	31 f6                	xor    %esi,%esi
  106217:	e8 e4 fe ff ff       	call   106100 <freevm>
  return 0;
}
  10621c:	83 c4 2c             	add    $0x2c,%esp
  10621f:	89 f0                	mov    %esi,%eax
  106221:	5b                   	pop    %ebx
  106222:	5e                   	pop    %esi
  106223:	5f                   	pop    %edi
  106224:	5d                   	pop    %ebp
  106225:	c3                   	ret    

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
      panic("copyuvm: pte should exist");
  106226:	c7 04 24 01 6e 10 00 	movl   $0x106e01,(%esp)
  10622d:	e8 ee a6 ff ff       	call   100920 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
  106232:	c7 04 24 1b 6e 10 00 	movl   $0x106e1b,(%esp)
  106239:	e8 e2 a6 ff ff       	call   100920 <panic>
  10623e:	66 90                	xchg   %ax,%ax

00106240 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106240:	55                   	push   %ebp
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106241:	31 c0                	xor    %eax,%eax

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106243:	89 e5                	mov    %esp,%ebp
  106245:	57                   	push   %edi
  106246:	56                   	push   %esi
  106247:	53                   	push   %ebx
  106248:	83 ec 2c             	sub    $0x2c,%esp
  10624b:	8b 75 10             	mov    0x10(%ebp),%esi
  10624e:	8b 7d 08             	mov    0x8(%ebp),%edi
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106251:	81 fe 00 00 0a 00    	cmp    $0xa0000,%esi
  106257:	0f 87 8e 00 00 00    	ja     1062eb <allocuvm+0xab>
    return 0;
  if(newsz < oldsz)
    return oldsz;
  10625d:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *mem;
  uint a;

  if(newsz > USERTOP)
    return 0;
  if(newsz < oldsz)
  106260:	39 c6                	cmp    %eax,%esi
  106262:	0f 82 83 00 00 00    	jb     1062eb <allocuvm+0xab>
    return oldsz;

  a = PGROUNDUP(oldsz);
  106268:	89 c3                	mov    %eax,%ebx
  10626a:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  106270:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
  106276:	39 de                	cmp    %ebx,%esi
  106278:	77 47                	ja     1062c1 <allocuvm+0x81>
  10627a:	eb 7c                	jmp    1062f8 <allocuvm+0xb8>
  10627c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
  106280:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  106287:	00 
  106288:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10628f:	00 
  106290:	89 04 24             	mov    %eax,(%esp)
  106293:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106296:	e8 35 d9 ff ff       	call   103bd0 <memset>
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  10629b:	b9 00 10 00 00       	mov    $0x1000,%ecx
  1062a0:	89 f8                	mov    %edi,%eax
  1062a2:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  1062a9:	00 
  1062aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1062ad:	89 14 24             	mov    %edx,(%esp)
  1062b0:	89 da                	mov    %ebx,%edx
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  1062b2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  1062b8:	e8 03 fc ff ff       	call   105ec0 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  1062bd:	39 de                	cmp    %ebx,%esi
  1062bf:	76 37                	jbe    1062f8 <allocuvm+0xb8>
    mem = kalloc();
  1062c1:	e8 8a bf ff ff       	call   102250 <kalloc>
    if(mem == 0){
  1062c6:	85 c0                	test   %eax,%eax
  1062c8:	75 b6                	jne    106280 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
  1062ca:	c7 04 24 35 6e 10 00 	movl   $0x106e35,(%esp)
  1062d1:	e8 5a a2 ff ff       	call   100530 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
  1062d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  1062dd:	89 3c 24             	mov    %edi,(%esp)
  1062e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1062e4:	e8 87 fd ff ff       	call   106070 <deallocuvm>
  1062e9:	31 c0                	xor    %eax,%eax
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
}
  1062eb:	83 c4 2c             	add    $0x2c,%esp
  1062ee:	5b                   	pop    %ebx
  1062ef:	5e                   	pop    %esi
  1062f0:	5f                   	pop    %edi
  1062f1:	5d                   	pop    %ebp
  1062f2:	c3                   	ret    
  1062f3:	90                   	nop
  1062f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1062f8:	83 c4 2c             	add    $0x2c,%esp
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
  1062fb:	89 f0                	mov    %esi,%eax
}
  1062fd:	5b                   	pop    %ebx
  1062fe:	5e                   	pop    %esi
  1062ff:	5f                   	pop    %edi
  106300:	5d                   	pop    %ebp
  106301:	c3                   	ret    
  106302:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  106309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106310 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
  106310:	55                   	push   %ebp
  106311:	89 e5                	mov    %esp,%ebp
  106313:	57                   	push   %edi
  106314:	56                   	push   %esi
  106315:	53                   	push   %ebx
  106316:	83 ec 3c             	sub    $0x3c,%esp
  106319:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
  10631c:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
  106322:	0f 85 96 00 00 00    	jne    1063be <loaduvm+0xae>
    panic("loaduvm: addr must be page aligned");
  106328:	8b 75 18             	mov    0x18(%ebp),%esi
  10632b:	31 db                	xor    %ebx,%ebx
  for(i = 0; i < sz; i += PGSIZE){
  10632d:	85 f6                	test   %esi,%esi
  10632f:	74 77                	je     1063a8 <loaduvm+0x98>
  106331:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  106334:	eb 13                	jmp    106349 <loaduvm+0x39>
  106336:	66 90                	xchg   %ax,%ax
  106338:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  10633e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  106344:	39 5d 18             	cmp    %ebx,0x18(%ebp)
  106347:	76 5f                	jbe    1063a8 <loaduvm+0x98>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
  106349:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10634c:	31 c9                	xor    %ecx,%ecx
  10634e:	8b 45 08             	mov    0x8(%ebp),%eax
  106351:	01 da                	add    %ebx,%edx
  106353:	e8 18 fa ff ff       	call   105d70 <walkpgdir>
  106358:	85 c0                	test   %eax,%eax
  10635a:	74 56                	je     1063b2 <loaduvm+0xa2>
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
  10635c:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
  106362:	8b 00                	mov    (%eax),%eax
    if(sz - i < PGSIZE)
  106364:	ba 00 10 00 00       	mov    $0x1000,%edx
  106369:	77 02                	ja     10636d <loaduvm+0x5d>
  10636b:	89 f2                	mov    %esi,%edx
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  10636d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106371:	8b 7d 14             	mov    0x14(%ebp),%edi
  106374:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  106379:	89 44 24 04          	mov    %eax,0x4(%esp)
  10637d:	8d 0c 3b             	lea    (%ebx,%edi,1),%ecx
  106380:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  106384:	8b 45 10             	mov    0x10(%ebp),%eax
  106387:	89 04 24             	mov    %eax,(%esp)
  10638a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10638d:	e8 de af ff ff       	call   101370 <readi>
  106392:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106395:	39 d0                	cmp    %edx,%eax
  106397:	74 9f                	je     106338 <loaduvm+0x28>
      return -1;
  }
  return 0;
}
  106399:	83 c4 3c             	add    $0x3c,%esp
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  10639c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return -1;
  }
  return 0;
}
  1063a1:	5b                   	pop    %ebx
  1063a2:	5e                   	pop    %esi
  1063a3:	5f                   	pop    %edi
  1063a4:	5d                   	pop    %ebp
  1063a5:	c3                   	ret    
  1063a6:	66 90                	xchg   %ax,%ax
  1063a8:	83 c4 3c             	add    $0x3c,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
  1063ab:	31 c0                	xor    %eax,%eax
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
      return -1;
  }
  return 0;
}
  1063ad:	5b                   	pop    %ebx
  1063ae:	5e                   	pop    %esi
  1063af:	5f                   	pop    %edi
  1063b0:	5d                   	pop    %ebp
  1063b1:	c3                   	ret    

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
  1063b2:	c7 04 24 4d 6e 10 00 	movl   $0x106e4d,(%esp)
  1063b9:	e8 62 a5 ff ff       	call   100920 <panic>
{
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  1063be:	c7 04 24 80 6e 10 00 	movl   $0x106e80,(%esp)
  1063c5:	e8 56 a5 ff ff       	call   100920 <panic>
  1063ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001063d0 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  1063d0:	55                   	push   %ebp
  1063d1:	89 e5                	mov    %esp,%ebp
  1063d3:	53                   	push   %ebx
  1063d4:	83 ec 14             	sub    $0x14,%esp
  1063d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
  1063da:	e8 61 d6 ff ff       	call   103a40 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
  1063df:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1063e5:	8d 50 08             	lea    0x8(%eax),%edx
  1063e8:	89 d1                	mov    %edx,%ecx
  1063ea:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
  1063f1:	c1 e9 10             	shr    $0x10,%ecx
  1063f4:	c1 ea 18             	shr    $0x18,%edx
  1063f7:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  1063fd:	c6 80 a5 00 00 00 99 	movb   $0x99,0xa5(%eax)
  106404:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  10640a:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
  106411:	67 00 
  106413:	c6 80 a6 00 00 00 40 	movb   $0x40,0xa6(%eax)
  cpu->gdt[SEG_TSS].s = 0;
  10641a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  106420:	80 a0 a5 00 00 00 ef 	andb   $0xef,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
  106427:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10642d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  106433:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  106439:	8b 50 08             	mov    0x8(%eax),%edx
  10643c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  106442:	81 c2 00 10 00 00    	add    $0x1000,%edx
  106448:	89 50 0c             	mov    %edx,0xc(%eax)
}

static inline void
ltr(ushort sel)
{
  asm volatile("ltr %0" : : "r" (sel));
  10644b:	b8 30 00 00 00       	mov    $0x30,%eax
  106450:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
  106453:	8b 43 04             	mov    0x4(%ebx),%eax
  106456:	85 c0                	test   %eax,%eax
  106458:	74 0d                	je     106467 <switchuvm+0x97>
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  10645a:	0f 22 d8             	mov    %eax,%cr3
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
}
  10645d:	83 c4 14             	add    $0x14,%esp
  106460:	5b                   	pop    %ebx
  106461:	5d                   	pop    %ebp
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
  106462:	e9 19 d6 ff ff       	jmp    103a80 <popcli>
  cpu->gdt[SEG_TSS].s = 0;
  cpu->ts.ss0 = SEG_KDATA << 3;
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  106467:	c7 04 24 6b 6e 10 00 	movl   $0x106e6b,(%esp)
  10646e:	e8 ad a4 ff ff       	call   100920 <panic>
  106473:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  106479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106480 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once at boot time on each CPU.
void
seginit(void)
{
  106480:	55                   	push   %ebp
  106481:	89 e5                	mov    %esp,%ebp
  106483:	83 ec 18             	sub    $0x18,%esp

  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  106486:	e8 a5 c0 ff ff       	call   102530 <cpunum>
  10648b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  106491:	05 20 bb 10 00       	add    $0x10bb20,%eax
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  106496:	8d 90 b4 00 00 00    	lea    0xb4(%eax),%edx
  10649c:	66 89 90 8a 00 00 00 	mov    %dx,0x8a(%eax)
  1064a3:	89 d1                	mov    %edx,%ecx
  1064a5:	c1 ea 18             	shr    $0x18,%edx
  1064a8:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)
  1064ae:	c1 e9 10             	shr    $0x10,%ecx

  lgdt(c->gdt, sizeof(c->gdt));
  1064b1:	8d 50 70             	lea    0x70(%eax),%edx
  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  1064b4:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
  1064ba:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
  1064c0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
  1064c4:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
  1064c8:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
  1064cc:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  1064d0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
  1064d7:	ff ff 
  1064d9:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
  1064e0:	00 00 
  1064e2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
  1064e9:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
  1064f0:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
  1064f7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  1064fe:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
  106505:	ff ff 
  106507:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
  10650e:	00 00 
  106510:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
  106517:	c6 80 95 00 00 00 fa 	movb   $0xfa,0x95(%eax)
  10651e:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
  106525:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
  10652c:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
  106533:	ff ff 
  106535:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
  10653c:	00 00 
  10653e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
  106545:	c6 80 9d 00 00 00 f2 	movb   $0xf2,0x9d(%eax)
  10654c:	c6 80 9e 00 00 00 cf 	movb   $0xcf,0x9e(%eax)
  106553:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  10655a:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
  106561:	00 00 
  106563:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
  106569:	c6 80 8d 00 00 00 92 	movb   $0x92,0x8d(%eax)
  106570:	c6 80 8e 00 00 00 c0 	movb   $0xc0,0x8e(%eax)
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  106577:	66 c7 45 f2 37 00    	movw   $0x37,-0xe(%ebp)
  pd[1] = (uint)p;
  10657d:	66 89 55 f4          	mov    %dx,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
  106581:	c1 ea 10             	shr    $0x10,%edx
  106584:	66 89 55 f6          	mov    %dx,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
  106588:	8d 55 f2             	lea    -0xe(%ebp),%edx
  10658b:	0f 01 12             	lgdtl  (%edx)
}

static inline void
loadgs(ushort v)
{
  asm volatile("movw %0, %%gs" : : "r" (v));
  10658e:	ba 18 00 00 00       	mov    $0x18,%edx
  106593:	8e ea                	mov    %edx,%gs

  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);
  
  // Initialize cpu-local storage.
  cpu = c;
  106595:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
  10659b:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  1065a2:	00 00 00 00 
}
  1065a6:	c9                   	leave  
  1065a7:	c3                   	ret    
