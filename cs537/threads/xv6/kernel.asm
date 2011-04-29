
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
  100015:	98                   	cwtl   
  100016:	10 00                	adc    %al,(%eax)
  100018:	a4                   	movsb  %ds:(%esi),%es:(%edi)
  100019:	0a 11                	or     (%ecx),%dl
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
  100040:	bc e0 a8 10 00       	mov    $0x10a8e0,%esp
  call main
  100045:	e8 b6 28 00 00       	call   102900 <main>

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

00100070 <lock_init>:
#include "thread.h"
#include "stat.h"

void
lock_init(struct lock_t *lock)
{
  100070:	55                   	push   %ebp
  100071:	89 e5                	mov    %esp,%ebp
  lock->locked = 0;
  100073:	8b 45 08             	mov    0x8(%ebp),%eax
  100076:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  10007c:	5d                   	pop    %ebp
  10007d:	c3                   	ret    
  10007e:	66 90                	xchg   %ax,%ax

00100080 <lock_acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
lock_acquire(struct lock_t *lock)
{
  100080:	55                   	push   %ebp
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  100081:	b9 01 00 00 00       	mov    $0x1,%ecx
  100086:	89 e5                	mov    %esp,%ebp
  100088:	8b 55 08             	mov    0x8(%ebp),%edx
  10008b:	90                   	nop
  10008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  100090:	89 c8                	mov    %ecx,%eax
  100092:	f0 87 02             	lock xchg %eax,(%edx)
//     panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lock->locked, 1) != 0)
  100095:	85 c0                	test   %eax,%eax
  100097:	75 f7                	jne    100090 <lock_acquire+0x10>
    ;

}
  100099:	5d                   	pop    %ebp
  10009a:	c3                   	ret    
  10009b:	90                   	nop
  10009c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

001000a0 <lock_release>:

// Release the lock.
void
lock_release(struct lock_t *lock)
{
  1000a0:	55                   	push   %ebp
  1000a1:	31 c0                	xor    %eax,%eax
  1000a3:	89 e5                	mov    %esp,%ebp
  1000a5:	8b 55 08             	mov    0x8(%ebp),%edx
  1000a8:	f0 87 02             	lock xchg %eax,(%edx)
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lock->locked, 0);

}
  1000ab:	5d                   	pop    %ebp
  1000ac:	c3                   	ret    
  1000ad:	8d 76 00             	lea    0x0(%esi),%esi

001000b0 <lock_holding>:

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
  1000b0:	55                   	push   %ebp
  1000b1:	89 e5                	mov    %esp,%ebp
  1000b3:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked;
  1000b6:	5d                   	pop    %ebp
}

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
  1000b7:	8b 00                	mov    (%eax),%eax
  return lock->locked;
  1000b9:	c3                   	ret    
  1000ba:	90                   	nop
  1000bb:	90                   	nop
  1000bc:	90                   	nop
  1000bd:	90                   	nop
  1000be:	90                   	nop
  1000bf:	90                   	nop

001000c0 <brelse>:
}

// Release the buffer b.
void
brelse(struct buf *b)
{
  1000c0:	55                   	push   %ebp
  1000c1:	89 e5                	mov    %esp,%ebp
  1000c3:	53                   	push   %ebx
  1000c4:	83 ec 14             	sub    $0x14,%esp
  1000c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((b->flags & B_BUSY) == 0)
  1000ca:	f6 03 01             	testb  $0x1,(%ebx)
  1000cd:	74 57                	je     100126 <brelse+0x66>
    panic("brelse");

  acquire(&bcache.lock);
  1000cf:	c7 04 24 e0 a8 10 00 	movl   $0x10a8e0,(%esp)
  1000d6:	e8 45 3d 00 00       	call   103e20 <acquire>

  b->next->prev = b->prev;
  1000db:	8b 43 10             	mov    0x10(%ebx),%eax
  1000de:	8b 53 0c             	mov    0xc(%ebx),%edx
  1000e1:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
  1000e4:	8b 43 0c             	mov    0xc(%ebx),%eax
  1000e7:	8b 53 10             	mov    0x10(%ebx),%edx
  1000ea:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
  1000ed:	a1 14 be 10 00       	mov    0x10be14,%eax
  b->prev = &bcache.head;
  1000f2:	c7 43 0c 04 be 10 00 	movl   $0x10be04,0xc(%ebx)

  acquire(&bcache.lock);

  b->next->prev = b->prev;
  b->prev->next = b->next;
  b->next = bcache.head.next;
  1000f9:	89 43 10             	mov    %eax,0x10(%ebx)
  b->prev = &bcache.head;
  bcache.head.next->prev = b;
  1000fc:	a1 14 be 10 00       	mov    0x10be14,%eax
  100101:	89 58 0c             	mov    %ebx,0xc(%eax)
  bcache.head.next = b;
  100104:	89 1d 14 be 10 00    	mov    %ebx,0x10be14

  b->flags &= ~B_BUSY;
  10010a:	83 23 fe             	andl   $0xfffffffe,(%ebx)
  wakeup(b);
  10010d:	89 1c 24             	mov    %ebx,(%esp)
  100110:	e8 6b 30 00 00       	call   103180 <wakeup>

  release(&bcache.lock);
  100115:	c7 45 08 e0 a8 10 00 	movl   $0x10a8e0,0x8(%ebp)
}
  10011c:	83 c4 14             	add    $0x14,%esp
  10011f:	5b                   	pop    %ebx
  100120:	5d                   	pop    %ebp
  bcache.head.next = b;

  b->flags &= ~B_BUSY;
  wakeup(b);

  release(&bcache.lock);
  100121:	e9 aa 3c 00 00       	jmp    103dd0 <release>
// Release the buffer b.
void
brelse(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("brelse");
  100126:	c7 04 24 80 67 10 00 	movl   $0x106780,(%esp)
  10012d:	e8 3e 08 00 00       	call   100970 <panic>
  100132:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  100139:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100140 <bwrite>:
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  100140:	55                   	push   %ebp
  100141:	89 e5                	mov    %esp,%ebp
  100143:	83 ec 18             	sub    $0x18,%esp
  100146:	8b 45 08             	mov    0x8(%ebp),%eax
  if((b->flags & B_BUSY) == 0)
  100149:	8b 10                	mov    (%eax),%edx
  10014b:	f6 c2 01             	test   $0x1,%dl
  10014e:	74 0e                	je     10015e <bwrite+0x1e>
    panic("bwrite");
  b->flags |= B_DIRTY;
  100150:	83 ca 04             	or     $0x4,%edx
  100153:	89 10                	mov    %edx,(%eax)
  iderw(b);
  100155:	89 45 08             	mov    %eax,0x8(%ebp)
}
  100158:	c9                   	leave  
bwrite(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("bwrite");
  b->flags |= B_DIRTY;
  iderw(b);
  100159:	e9 32 1e 00 00       	jmp    101f90 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("bwrite");
  10015e:	c7 04 24 87 67 10 00 	movl   $0x106787,(%esp)
  100165:	e8 06 08 00 00       	call   100970 <panic>
  10016a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00100170 <bread>:
}

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
  100170:	55                   	push   %ebp
  100171:	89 e5                	mov    %esp,%ebp
  100173:	57                   	push   %edi
  100174:	56                   	push   %esi
  100175:	53                   	push   %ebx
  100176:	83 ec 1c             	sub    $0x1c,%esp
  100179:	8b 75 08             	mov    0x8(%ebp),%esi
  10017c:	8b 7d 0c             	mov    0xc(%ebp),%edi
static struct buf*
bget(uint dev, uint sector)
{
  struct buf *b;

  acquire(&bcache.lock);
  10017f:	c7 04 24 e0 a8 10 00 	movl   $0x10a8e0,(%esp)
  100186:	e8 95 3c 00 00       	call   103e20 <acquire>

 loop:
  // Try for cached block.
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
  10018b:	8b 1d 14 be 10 00    	mov    0x10be14,%ebx
  100191:	81 fb 04 be 10 00    	cmp    $0x10be04,%ebx
  100197:	75 12                	jne    1001ab <bread+0x3b>
  100199:	eb 35                	jmp    1001d0 <bread+0x60>
  10019b:	90                   	nop
  10019c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1001a0:	8b 5b 10             	mov    0x10(%ebx),%ebx
  1001a3:	81 fb 04 be 10 00    	cmp    $0x10be04,%ebx
  1001a9:	74 25                	je     1001d0 <bread+0x60>
    if(b->dev == dev && b->sector == sector){
  1001ab:	3b 73 04             	cmp    0x4(%ebx),%esi
  1001ae:	66 90                	xchg   %ax,%ax
  1001b0:	75 ee                	jne    1001a0 <bread+0x30>
  1001b2:	3b 7b 08             	cmp    0x8(%ebx),%edi
  1001b5:	75 e9                	jne    1001a0 <bread+0x30>
      if(!(b->flags & B_BUSY)){
  1001b7:	8b 03                	mov    (%ebx),%eax
  1001b9:	a8 01                	test   $0x1,%al
  1001bb:	74 64                	je     100221 <bread+0xb1>
        b->flags |= B_BUSY;
        release(&bcache.lock);
        return b;
      }
      sleep(b, &bcache.lock);
  1001bd:	c7 44 24 04 e0 a8 10 	movl   $0x10a8e0,0x4(%esp)
  1001c4:	00 
  1001c5:	89 1c 24             	mov    %ebx,(%esp)
  1001c8:	e8 e3 30 00 00       	call   1032b0 <sleep>
  1001cd:	eb bc                	jmp    10018b <bread+0x1b>
  1001cf:	90                   	nop
      goto loop;
    }
  }

  // Allocate fresh block.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
  1001d0:	8b 1d 10 be 10 00    	mov    0x10be10,%ebx
  1001d6:	81 fb 04 be 10 00    	cmp    $0x10be04,%ebx
  1001dc:	75 0d                	jne    1001eb <bread+0x7b>
  1001de:	eb 54                	jmp    100234 <bread+0xc4>
  1001e0:	8b 5b 0c             	mov    0xc(%ebx),%ebx
  1001e3:	81 fb 04 be 10 00    	cmp    $0x10be04,%ebx
  1001e9:	74 49                	je     100234 <bread+0xc4>
    if((b->flags & B_BUSY) == 0){
  1001eb:	f6 03 01             	testb  $0x1,(%ebx)
  1001ee:	66 90                	xchg   %ax,%ax
  1001f0:	75 ee                	jne    1001e0 <bread+0x70>
      b->dev = dev;
  1001f2:	89 73 04             	mov    %esi,0x4(%ebx)
      b->sector = sector;
  1001f5:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = B_BUSY;
  1001f8:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
      release(&bcache.lock);
  1001fe:	c7 04 24 e0 a8 10 00 	movl   $0x10a8e0,(%esp)
  100205:	e8 c6 3b 00 00       	call   103dd0 <release>
bread(uint dev, uint sector)
{
  struct buf *b;

  b = bget(dev, sector);
  if(!(b->flags & B_VALID))
  10020a:	f6 03 02             	testb  $0x2,(%ebx)
  10020d:	75 08                	jne    100217 <bread+0xa7>
    iderw(b);
  10020f:	89 1c 24             	mov    %ebx,(%esp)
  100212:	e8 79 1d 00 00       	call   101f90 <iderw>
  return b;
}
  100217:	83 c4 1c             	add    $0x1c,%esp
  10021a:	89 d8                	mov    %ebx,%eax
  10021c:	5b                   	pop    %ebx
  10021d:	5e                   	pop    %esi
  10021e:	5f                   	pop    %edi
  10021f:	5d                   	pop    %ebp
  100220:	c3                   	ret    
 loop:
  // Try for cached block.
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    if(b->dev == dev && b->sector == sector){
      if(!(b->flags & B_BUSY)){
        b->flags |= B_BUSY;
  100221:	83 c8 01             	or     $0x1,%eax
  100224:	89 03                	mov    %eax,(%ebx)
        release(&bcache.lock);
  100226:	c7 04 24 e0 a8 10 00 	movl   $0x10a8e0,(%esp)
  10022d:	e8 9e 3b 00 00       	call   103dd0 <release>
  100232:	eb d6                	jmp    10020a <bread+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
  100234:	c7 04 24 8e 67 10 00 	movl   $0x10678e,(%esp)
  10023b:	e8 30 07 00 00       	call   100970 <panic>

00100240 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
  100240:	55                   	push   %ebp
  100241:	89 e5                	mov    %esp,%ebp
  100243:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
  100246:	c7 44 24 04 9f 67 10 	movl   $0x10679f,0x4(%esp)
  10024d:	00 
  10024e:	c7 04 24 e0 a8 10 00 	movl   $0x10a8e0,(%esp)
  100255:	e8 36 3a 00 00       	call   103c90 <initlock>
  // head.next is most recently used.
  struct buf head;
} bcache;

void
binit(void)
  10025a:	ba 04 be 10 00       	mov    $0x10be04,%edx
  10025f:	b8 14 a9 10 00       	mov    $0x10a914,%eax
  struct buf *b;

  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  100264:	c7 05 10 be 10 00 04 	movl   $0x10be04,0x10be10
  10026b:	be 10 00 
  bcache.head.next = &bcache.head;
  10026e:	c7 05 14 be 10 00 04 	movl   $0x10be04,0x10be14
  100275:	be 10 00 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
  100278:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
  10027b:	c7 40 0c 04 be 10 00 	movl   $0x10be04,0xc(%eax)
    b->dev = -1;
  100282:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
  100289:	8b 15 14 be 10 00    	mov    0x10be14,%edx
  10028f:	89 42 0c             	mov    %eax,0xc(%edx)
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
  100292:	89 c2                	mov    %eax,%edx
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  100294:	a3 14 be 10 00       	mov    %eax,0x10be14
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
  100299:	05 18 02 00 00       	add    $0x218,%eax
  10029e:	3d 04 be 10 00       	cmp    $0x10be04,%eax
  1002a3:	75 d3                	jne    100278 <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
  1002a5:	c9                   	leave  
  1002a6:	c3                   	ret    
  1002a7:	90                   	nop
  1002a8:	90                   	nop
  1002a9:	90                   	nop
  1002aa:	90                   	nop
  1002ab:	90                   	nop
  1002ac:	90                   	nop
  1002ad:	90                   	nop
  1002ae:	90                   	nop
  1002af:	90                   	nop

001002b0 <consoleinit>:
  return n;
}

void
consoleinit(void)
{
  1002b0:	55                   	push   %ebp
  1002b1:	89 e5                	mov    %esp,%ebp
  1002b3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
  1002b6:	c7 44 24 04 a6 67 10 	movl   $0x1067a6,0x4(%esp)
  1002bd:	00 
  1002be:	c7 04 24 40 98 10 00 	movl   $0x109840,(%esp)
  1002c5:	e8 c6 39 00 00       	call   103c90 <initlock>
  initlock(&input.lock, "input");
  1002ca:	c7 44 24 04 ae 67 10 	movl   $0x1067ae,0x4(%esp)
  1002d1:	00 
  1002d2:	c7 04 24 20 c0 10 00 	movl   $0x10c020,(%esp)
  1002d9:	e8 b2 39 00 00       	call   103c90 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  picenable(IRQ_KBD);
  1002de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
consoleinit(void)
{
  initlock(&cons.lock, "console");
  initlock(&input.lock, "input");

  devsw[CONSOLE].write = consolewrite;
  1002e5:	c7 05 8c ca 10 00 90 	movl   $0x100490,0x10ca8c
  1002ec:	04 10 00 
  devsw[CONSOLE].read = consoleread;
  1002ef:	c7 05 88 ca 10 00 e0 	movl   $0x1006e0,0x10ca88
  1002f6:	06 10 00 
  cons.locking = 1;
  1002f9:	c7 05 74 98 10 00 01 	movl   $0x1,0x109874
  100300:	00 00 00 

  picenable(IRQ_KBD);
  100303:	e8 d8 28 00 00       	call   102be0 <picenable>
  ioapicenable(IRQ_KBD, 0);
  100308:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10030f:	00 
  100310:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  100317:	e8 74 1e 00 00       	call   102190 <ioapicenable>
}
  10031c:	c9                   	leave  
  10031d:	c3                   	ret    
  10031e:	66 90                	xchg   %ax,%ax

00100320 <consputc>:
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
{
  100320:	55                   	push   %ebp
  100321:	89 e5                	mov    %esp,%ebp
  100323:	57                   	push   %edi
  100324:	56                   	push   %esi
  100325:	89 c6                	mov    %eax,%esi
  100327:	53                   	push   %ebx
  100328:	83 ec 1c             	sub    $0x1c,%esp
  if(panicked){
  10032b:	83 3d 20 98 10 00 00 	cmpl   $0x0,0x109820
  100332:	74 03                	je     100337 <consputc+0x17>
}

static inline void
cli(void)
{
  asm volatile("cli");
  100334:	fa                   	cli    
  100335:	eb fe                	jmp    100335 <consputc+0x15>
    cli();
    for(;;)
      ;
  }

  if(c == BACKSPACE){
  100337:	3d 00 01 00 00       	cmp    $0x100,%eax
  10033c:	0f 84 a0 00 00 00    	je     1003e2 <consputc+0xc2>
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  100342:	89 04 24             	mov    %eax,(%esp)
  100345:	e8 46 50 00 00       	call   105390 <uartputc>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  10034a:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
  10034f:	b8 0e 00 00 00       	mov    $0xe,%eax
  100354:	89 ca                	mov    %ecx,%edx
  100356:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  100357:	bf d5 03 00 00       	mov    $0x3d5,%edi
  10035c:	89 fa                	mov    %edi,%edx
  10035e:	ec                   	in     (%dx),%al
{
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
  10035f:	0f b6 d8             	movzbl %al,%ebx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  100362:	89 ca                	mov    %ecx,%edx
  100364:	c1 e3 08             	shl    $0x8,%ebx
  100367:	b8 0f 00 00 00       	mov    $0xf,%eax
  10036c:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  10036d:	89 fa                	mov    %edi,%edx
  10036f:	ec                   	in     (%dx),%al
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);
  100370:	0f b6 c0             	movzbl %al,%eax
  100373:	09 c3                	or     %eax,%ebx

  if(c == '\n')
  100375:	83 fe 0a             	cmp    $0xa,%esi
  100378:	0f 84 ee 00 00 00    	je     10046c <consputc+0x14c>
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
  10037e:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  100384:	0f 84 cb 00 00 00    	je     100455 <consputc+0x135>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  10038a:	66 81 e6 ff 00       	and    $0xff,%si
  10038f:	66 81 ce 00 07       	or     $0x700,%si
  100394:	66 89 b4 1b 00 80 0b 	mov    %si,0xb8000(%ebx,%ebx,1)
  10039b:	00 
  10039c:	83 c3 01             	add    $0x1,%ebx
  
  if((pos/80) >= 24){  // Scroll up.
  10039f:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
  1003a5:	8d 8c 1b 00 80 0b 00 	lea    0xb8000(%ebx,%ebx,1),%ecx
  1003ac:	7f 5d                	jg     10040b <consputc+0xeb>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1003ae:	be d4 03 00 00       	mov    $0x3d4,%esi
  1003b3:	b8 0e 00 00 00       	mov    $0xe,%eax
  1003b8:	89 f2                	mov    %esi,%edx
  1003ba:	ee                   	out    %al,(%dx)
  1003bb:	bf d5 03 00 00       	mov    $0x3d5,%edi
  1003c0:	89 d8                	mov    %ebx,%eax
  1003c2:	c1 f8 08             	sar    $0x8,%eax
  1003c5:	89 fa                	mov    %edi,%edx
  1003c7:	ee                   	out    %al,(%dx)
  1003c8:	b8 0f 00 00 00       	mov    $0xf,%eax
  1003cd:	89 f2                	mov    %esi,%edx
  1003cf:	ee                   	out    %al,(%dx)
  1003d0:	89 d8                	mov    %ebx,%eax
  1003d2:	89 fa                	mov    %edi,%edx
  1003d4:	ee                   	out    %al,(%dx)
  
  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
  1003d5:	66 c7 01 20 07       	movw   $0x720,(%ecx)
  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  cgaputc(c);
}
  1003da:	83 c4 1c             	add    $0x1c,%esp
  1003dd:	5b                   	pop    %ebx
  1003de:	5e                   	pop    %esi
  1003df:	5f                   	pop    %edi
  1003e0:	5d                   	pop    %ebp
  1003e1:	c3                   	ret    
    for(;;)
      ;
  }

  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  1003e2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1003e9:	e8 a2 4f 00 00       	call   105390 <uartputc>
  1003ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1003f5:	e8 96 4f 00 00       	call   105390 <uartputc>
  1003fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  100401:	e8 8a 4f 00 00       	call   105390 <uartputc>
  100406:	e9 3f ff ff ff       	jmp    10034a <consputc+0x2a>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
    pos -= 80;
  10040b:	83 eb 50             	sub    $0x50,%ebx
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
  10040e:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
  100415:	00 
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  100416:	8d b4 1b 00 80 0b 00 	lea    0xb8000(%ebx,%ebx,1),%esi
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
  10041d:	c7 44 24 04 a0 80 0b 	movl   $0xb80a0,0x4(%esp)
  100424:	00 
  100425:	c7 04 24 00 80 0b 00 	movl   $0xb8000,(%esp)
  10042c:	e8 0f 3b 00 00       	call   103f40 <memmove>
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  100431:	b8 80 07 00 00       	mov    $0x780,%eax
  100436:	29 d8                	sub    %ebx,%eax
  100438:	01 c0                	add    %eax,%eax
  10043a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10043e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100445:	00 
  100446:	89 34 24             	mov    %esi,(%esp)
  100449:	e8 72 3a 00 00       	call   103ec0 <memset>
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
  10044e:	89 f1                	mov    %esi,%ecx
  100450:	e9 59 ff ff ff       	jmp    1003ae <consputc+0x8e>
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
    if(pos > 0) --pos;
  100455:	85 db                	test   %ebx,%ebx
  100457:	8d 8c 1b 00 80 0b 00 	lea    0xb8000(%ebx,%ebx,1),%ecx
  10045e:	0f 8e 4a ff ff ff    	jle    1003ae <consputc+0x8e>
  100464:	83 eb 01             	sub    $0x1,%ebx
  100467:	e9 33 ff ff ff       	jmp    10039f <consputc+0x7f>
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  10046c:	89 da                	mov    %ebx,%edx
  10046e:	89 d8                	mov    %ebx,%eax
  100470:	b9 50 00 00 00       	mov    $0x50,%ecx
  100475:	83 c3 50             	add    $0x50,%ebx
  100478:	c1 fa 1f             	sar    $0x1f,%edx
  10047b:	f7 f9                	idiv   %ecx
  10047d:	29 d3                	sub    %edx,%ebx
  10047f:	e9 1b ff ff ff       	jmp    10039f <consputc+0x7f>
  100484:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10048a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00100490 <consolewrite>:
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
  100490:	55                   	push   %ebp
  100491:	89 e5                	mov    %esp,%ebp
  100493:	57                   	push   %edi
  100494:	56                   	push   %esi
  100495:	53                   	push   %ebx
  100496:	83 ec 1c             	sub    $0x1c,%esp
  int i;

  iunlock(ip);
  100499:	8b 45 08             	mov    0x8(%ebp),%eax
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
  10049c:	8b 75 10             	mov    0x10(%ebp),%esi
  10049f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  iunlock(ip);
  1004a2:	89 04 24             	mov    %eax,(%esp)
  1004a5:	e8 16 13 00 00       	call   1017c0 <iunlock>
  acquire(&cons.lock);
  1004aa:	c7 04 24 40 98 10 00 	movl   $0x109840,(%esp)
  1004b1:	e8 6a 39 00 00       	call   103e20 <acquire>
  for(i = 0; i < n; i++)
  1004b6:	85 f6                	test   %esi,%esi
  1004b8:	7e 16                	jle    1004d0 <consolewrite+0x40>
  1004ba:	31 db                	xor    %ebx,%ebx
  1004bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    consputc(buf[i] & 0xff);
  1004c0:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
  1004c4:	83 c3 01             	add    $0x1,%ebx
    consputc(buf[i] & 0xff);
  1004c7:	e8 54 fe ff ff       	call   100320 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
  1004cc:	39 de                	cmp    %ebx,%esi
  1004ce:	7f f0                	jg     1004c0 <consolewrite+0x30>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
  1004d0:	c7 04 24 40 98 10 00 	movl   $0x109840,(%esp)
  1004d7:	e8 f4 38 00 00       	call   103dd0 <release>
  ilock(ip);
  1004dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1004df:	89 04 24             	mov    %eax,(%esp)
  1004e2:	e8 19 17 00 00       	call   101c00 <ilock>

  return n;
}
  1004e7:	83 c4 1c             	add    $0x1c,%esp
  1004ea:	89 f0                	mov    %esi,%eax
  1004ec:	5b                   	pop    %ebx
  1004ed:	5e                   	pop    %esi
  1004ee:	5f                   	pop    %edi
  1004ef:	5d                   	pop    %ebp
  1004f0:	c3                   	ret    
  1004f1:	eb 0d                	jmp    100500 <printint>
  1004f3:	90                   	nop
  1004f4:	90                   	nop
  1004f5:	90                   	nop
  1004f6:	90                   	nop
  1004f7:	90                   	nop
  1004f8:	90                   	nop
  1004f9:	90                   	nop
  1004fa:	90                   	nop
  1004fb:	90                   	nop
  1004fc:	90                   	nop
  1004fd:	90                   	nop
  1004fe:	90                   	nop
  1004ff:	90                   	nop

00100500 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
  100500:	55                   	push   %ebp
  100501:	89 e5                	mov    %esp,%ebp
  100503:	57                   	push   %edi
  100504:	56                   	push   %esi
  100505:	89 d6                	mov    %edx,%esi
  100507:	53                   	push   %ebx
  100508:	83 ec 1c             	sub    $0x1c,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
  10050b:	85 c9                	test   %ecx,%ecx
  10050d:	74 04                	je     100513 <printint+0x13>
  10050f:	85 c0                	test   %eax,%eax
  100511:	78 55                	js     100568 <printint+0x68>
    x = -xx;
  else
    x = xx;
  100513:	31 ff                	xor    %edi,%edi
  100515:	31 c9                	xor    %ecx,%ecx
  100517:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  10051a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  i = 0;
  do{
    buf[i++] = digits[x % base];
  100520:	31 d2                	xor    %edx,%edx
  100522:	f7 f6                	div    %esi
  100524:	0f b6 92 ce 67 10 00 	movzbl 0x1067ce(%edx),%edx
  10052b:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
  10052e:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
  100531:	85 c0                	test   %eax,%eax
  100533:	75 eb                	jne    100520 <printint+0x20>

  if(sign)
  100535:	85 ff                	test   %edi,%edi
  100537:	74 08                	je     100541 <printint+0x41>
    buf[i++] = '-';
  100539:	c6 44 0d d8 2d       	movb   $0x2d,-0x28(%ebp,%ecx,1)
  10053e:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
  100541:	8d 71 ff             	lea    -0x1(%ecx),%esi
  100544:	01 f3                	add    %esi,%ebx
  100546:	66 90                	xchg   %ax,%ax
    consputc(buf[i]);
  100548:	0f be 03             	movsbl (%ebx),%eax
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
  10054b:	83 ee 01             	sub    $0x1,%esi
  10054e:	83 eb 01             	sub    $0x1,%ebx
    consputc(buf[i]);
  100551:	e8 ca fd ff ff       	call   100320 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
  100556:	83 fe ff             	cmp    $0xffffffff,%esi
  100559:	75 ed                	jne    100548 <printint+0x48>
    consputc(buf[i]);
}
  10055b:	83 c4 1c             	add    $0x1c,%esp
  10055e:	5b                   	pop    %ebx
  10055f:	5e                   	pop    %esi
  100560:	5f                   	pop    %edi
  100561:	5d                   	pop    %ebp
  100562:	c3                   	ret    
  100563:	90                   	nop
  100564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  100568:	f7 d8                	neg    %eax
  10056a:	bf 01 00 00 00       	mov    $0x1,%edi
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
  10056f:	eb a4                	jmp    100515 <printint+0x15>
  100571:	eb 0d                	jmp    100580 <cprintf>
  100573:	90                   	nop
  100574:	90                   	nop
  100575:	90                   	nop
  100576:	90                   	nop
  100577:	90                   	nop
  100578:	90                   	nop
  100579:	90                   	nop
  10057a:	90                   	nop
  10057b:	90                   	nop
  10057c:	90                   	nop
  10057d:	90                   	nop
  10057e:	90                   	nop
  10057f:	90                   	nop

00100580 <cprintf>:
}

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
  100580:	55                   	push   %ebp
  100581:	89 e5                	mov    %esp,%ebp
  100583:	57                   	push   %edi
  100584:	56                   	push   %esi
  100585:	53                   	push   %ebx
  100586:	83 ec 2c             	sub    $0x2c,%esp
  int i, c, state, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
  100589:	8b 3d 74 98 10 00    	mov    0x109874,%edi
  if(locking)
  10058f:	85 ff                	test   %edi,%edi
  100591:	0f 85 29 01 00 00    	jne    1006c0 <cprintf+0x140>
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  100597:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10059a:	0f b6 01             	movzbl (%ecx),%eax
  10059d:	85 c0                	test   %eax,%eax
  10059f:	0f 84 93 00 00 00    	je     100638 <cprintf+0xb8>

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  1005a5:	8d 75 0c             	lea    0xc(%ebp),%esi
  1005a8:	31 db                	xor    %ebx,%ebx
  1005aa:	eb 3f                	jmp    1005eb <cprintf+0x6b>
  1005ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
  1005b0:	83 fa 25             	cmp    $0x25,%edx
  1005b3:	0f 84 b7 00 00 00    	je     100670 <cprintf+0xf0>
  1005b9:	83 fa 64             	cmp    $0x64,%edx
  1005bc:	0f 84 8e 00 00 00    	je     100650 <cprintf+0xd0>
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
  1005c2:	b8 25 00 00 00       	mov    $0x25,%eax
  1005c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1005ca:	e8 51 fd ff ff       	call   100320 <consputc>
      consputc(c);
  1005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1005d2:	89 d0                	mov    %edx,%eax
  1005d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1005d8:	e8 43 fd ff ff       	call   100320 <consputc>
  1005dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  1005e0:	83 c3 01             	add    $0x1,%ebx
  1005e3:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
  1005e7:	85 c0                	test   %eax,%eax
  1005e9:	74 4d                	je     100638 <cprintf+0xb8>
    if(c != '%'){
  1005eb:	83 f8 25             	cmp    $0x25,%eax
  1005ee:	75 e8                	jne    1005d8 <cprintf+0x58>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
  1005f0:	83 c3 01             	add    $0x1,%ebx
  1005f3:	0f b6 14 19          	movzbl (%ecx,%ebx,1),%edx
    if(c == 0)
  1005f7:	85 d2                	test   %edx,%edx
  1005f9:	74 3d                	je     100638 <cprintf+0xb8>
      break;
    switch(c){
  1005fb:	83 fa 70             	cmp    $0x70,%edx
  1005fe:	74 12                	je     100612 <cprintf+0x92>
  100600:	7e ae                	jle    1005b0 <cprintf+0x30>
  100602:	83 fa 73             	cmp    $0x73,%edx
  100605:	8d 76 00             	lea    0x0(%esi),%esi
  100608:	74 7e                	je     100688 <cprintf+0x108>
  10060a:	83 fa 78             	cmp    $0x78,%edx
  10060d:	8d 76 00             	lea    0x0(%esi),%esi
  100610:	75 b0                	jne    1005c2 <cprintf+0x42>
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
  100612:	8b 06                	mov    (%esi),%eax
  100614:	31 c9                	xor    %ecx,%ecx
  100616:	ba 10 00 00 00       	mov    $0x10,%edx
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  10061b:	83 c3 01             	add    $0x1,%ebx
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
  10061e:	83 c6 04             	add    $0x4,%esi
  100621:	e8 da fe ff ff       	call   100500 <printint>
  100626:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  100629:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
  10062d:	85 c0                	test   %eax,%eax
  10062f:	75 ba                	jne    1005eb <cprintf+0x6b>
  100631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      consputc(c);
      break;
    }
  }

  if(locking)
  100638:	85 ff                	test   %edi,%edi
  10063a:	74 0c                	je     100648 <cprintf+0xc8>
    release(&cons.lock);
  10063c:	c7 04 24 40 98 10 00 	movl   $0x109840,(%esp)
  100643:	e8 88 37 00 00       	call   103dd0 <release>
}
  100648:	83 c4 2c             	add    $0x2c,%esp
  10064b:	5b                   	pop    %ebx
  10064c:	5e                   	pop    %esi
  10064d:	5f                   	pop    %edi
  10064e:	5d                   	pop    %ebp
  10064f:	c3                   	ret    
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      printint(*argp++, 10, 1);
  100650:	8b 06                	mov    (%esi),%eax
  100652:	b9 01 00 00 00       	mov    $0x1,%ecx
  100657:	ba 0a 00 00 00       	mov    $0xa,%edx
  10065c:	83 c6 04             	add    $0x4,%esi
  10065f:	e8 9c fe ff ff       	call   100500 <printint>
  100664:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
  100667:	e9 74 ff ff ff       	jmp    1005e0 <cprintf+0x60>
  10066c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
  100670:	b8 25 00 00 00       	mov    $0x25,%eax
  100675:	e8 a6 fc ff ff       	call   100320 <consputc>
  10067a:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
  10067d:	e9 5e ff ff ff       	jmp    1005e0 <cprintf+0x60>
  100682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
  100688:	8b 16                	mov    (%esi),%edx
  10068a:	83 c6 04             	add    $0x4,%esi
  10068d:	85 d2                	test   %edx,%edx
  10068f:	74 47                	je     1006d8 <cprintf+0x158>
        s = "(null)";
      for(; *s; s++)
  100691:	0f b6 02             	movzbl (%edx),%eax
  100694:	84 c0                	test   %al,%al
  100696:	0f 84 44 ff ff ff    	je     1005e0 <cprintf+0x60>
  10069c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        consputc(*s);
  1006a0:	0f be c0             	movsbl %al,%eax
  1006a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1006a6:	e8 75 fc ff ff       	call   100320 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
  1006ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1006ae:	83 c2 01             	add    $0x1,%edx
  1006b1:	0f b6 02             	movzbl (%edx),%eax
  1006b4:	84 c0                	test   %al,%al
  1006b6:	75 e8                	jne    1006a0 <cprintf+0x120>
  1006b8:	e9 20 ff ff ff       	jmp    1005dd <cprintf+0x5d>
  1006bd:	8d 76 00             	lea    0x0(%esi),%esi
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);
  1006c0:	c7 04 24 40 98 10 00 	movl   $0x109840,(%esp)
  1006c7:	e8 54 37 00 00       	call   103e20 <acquire>
  1006cc:	e9 c6 fe ff ff       	jmp    100597 <cprintf+0x17>
  1006d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
  1006d8:	ba b4 67 10 00       	mov    $0x1067b4,%edx
  1006dd:	eb b2                	jmp    100691 <cprintf+0x111>
  1006df:	90                   	nop

001006e0 <consoleread>:
  release(&input.lock);
}

int
consoleread(struct inode *ip, char *dst, int n)
{
  1006e0:	55                   	push   %ebp
  1006e1:	89 e5                	mov    %esp,%ebp
  1006e3:	57                   	push   %edi
  1006e4:	56                   	push   %esi
  1006e5:	53                   	push   %ebx
  1006e6:	83 ec 3c             	sub    $0x3c,%esp
  1006e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  1006ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  1006ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
  1006f2:	89 3c 24             	mov    %edi,(%esp)
  1006f5:	e8 c6 10 00 00       	call   1017c0 <iunlock>
  target = n;
  1006fa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&input.lock);
  1006fd:	c7 04 24 20 c0 10 00 	movl   $0x10c020,(%esp)
  100704:	e8 17 37 00 00       	call   103e20 <acquire>
  while(n > 0){
  100709:	85 db                	test   %ebx,%ebx
  10070b:	7f 2c                	jg     100739 <consoleread+0x59>
  10070d:	e9 c0 00 00 00       	jmp    1007d2 <consoleread+0xf2>
  100712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(input.r == input.w){
      if(proc->killed){
  100718:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10071e:	8b 40 24             	mov    0x24(%eax),%eax
  100721:	85 c0                	test   %eax,%eax
  100723:	75 5b                	jne    100780 <consoleread+0xa0>
        release(&input.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
  100725:	c7 44 24 04 20 c0 10 	movl   $0x10c020,0x4(%esp)
  10072c:	00 
  10072d:	c7 04 24 d4 c0 10 00 	movl   $0x10c0d4,(%esp)
  100734:	e8 77 2b 00 00       	call   1032b0 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
  100739:	a1 d4 c0 10 00       	mov    0x10c0d4,%eax
  10073e:	3b 05 d8 c0 10 00    	cmp    0x10c0d8,%eax
  100744:	74 d2                	je     100718 <consoleread+0x38>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
  100746:	89 c2                	mov    %eax,%edx
  100748:	83 e2 7f             	and    $0x7f,%edx
  10074b:	0f b6 8a 54 c0 10 00 	movzbl 0x10c054(%edx),%ecx
  100752:	0f be d1             	movsbl %cl,%edx
  100755:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  100758:	8d 50 01             	lea    0x1(%eax),%edx
    if(c == C('D')){  // EOF
  10075b:	83 7d d4 04          	cmpl   $0x4,-0x2c(%ebp)
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
  10075f:	89 15 d4 c0 10 00    	mov    %edx,0x10c0d4
    if(c == C('D')){  // EOF
  100765:	74 3a                	je     1007a1 <consoleread+0xc1>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
  100767:	88 0e                	mov    %cl,(%esi)
    --n;
  100769:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
  10076c:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  100770:	74 39                	je     1007ab <consoleread+0xcb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
  100772:	85 db                	test   %ebx,%ebx
  100774:	7e 35                	jle    1007ab <consoleread+0xcb>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
  100776:	83 c6 01             	add    $0x1,%esi
  100779:	eb be                	jmp    100739 <consoleread+0x59>
  10077b:	90                   	nop
  10077c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
        release(&input.lock);
  100780:	c7 04 24 20 c0 10 00 	movl   $0x10c020,(%esp)
  100787:	e8 44 36 00 00       	call   103dd0 <release>
        ilock(ip);
  10078c:	89 3c 24             	mov    %edi,(%esp)
  10078f:	e8 6c 14 00 00       	call   101c00 <ilock>
  }
  release(&input.lock);
  ilock(ip);

  return target - n;
}
  100794:	83 c4 3c             	add    $0x3c,%esp
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
        release(&input.lock);
        ilock(ip);
  100797:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&input.lock);
  ilock(ip);

  return target - n;
}
  10079c:	5b                   	pop    %ebx
  10079d:	5e                   	pop    %esi
  10079e:	5f                   	pop    %edi
  10079f:	5d                   	pop    %ebp
  1007a0:	c3                   	ret    
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
  1007a1:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  1007a4:	76 05                	jbe    1007ab <consoleread+0xcb>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
  1007a6:	a3 d4 c0 10 00       	mov    %eax,0x10c0d4
  1007ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007ae:	29 d8                	sub    %ebx,%eax
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
  1007b0:	c7 04 24 20 c0 10 00 	movl   $0x10c020,(%esp)
  1007b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1007ba:	e8 11 36 00 00       	call   103dd0 <release>
  ilock(ip);
  1007bf:	89 3c 24             	mov    %edi,(%esp)
  1007c2:	e8 39 14 00 00       	call   101c00 <ilock>
  1007c7:	8b 45 e0             	mov    -0x20(%ebp),%eax

  return target - n;
}
  1007ca:	83 c4 3c             	add    $0x3c,%esp
  1007cd:	5b                   	pop    %ebx
  1007ce:	5e                   	pop    %esi
  1007cf:	5f                   	pop    %edi
  1007d0:	5d                   	pop    %ebp
  1007d1:	c3                   	ret    
  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
  1007d2:	31 c0                	xor    %eax,%eax
  1007d4:	eb da                	jmp    1007b0 <consoleread+0xd0>
  1007d6:	8d 76 00             	lea    0x0(%esi),%esi
  1007d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001007e0 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
  1007e0:	55                   	push   %ebp
  1007e1:	89 e5                	mov    %esp,%ebp
  1007e3:	57                   	push   %edi
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
  1007e4:	bf 50 c0 10 00       	mov    $0x10c050,%edi

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
  1007e9:	56                   	push   %esi
  1007ea:	53                   	push   %ebx
  1007eb:	83 ec 1c             	sub    $0x1c,%esp
  1007ee:	8b 75 08             	mov    0x8(%ebp),%esi
  int c;

  acquire(&input.lock);
  1007f1:	c7 04 24 20 c0 10 00 	movl   $0x10c020,(%esp)
  1007f8:	e8 23 36 00 00       	call   103e20 <acquire>
  1007fd:	8d 76 00             	lea    0x0(%esi),%esi
  while((c = getc()) >= 0){
  100800:	ff d6                	call   *%esi
  100802:	85 c0                	test   %eax,%eax
  100804:	89 c3                	mov    %eax,%ebx
  100806:	0f 88 9c 00 00 00    	js     1008a8 <consoleintr+0xc8>
    switch(c){
  10080c:	83 fb 10             	cmp    $0x10,%ebx
  10080f:	90                   	nop
  100810:	0f 84 1a 01 00 00    	je     100930 <consoleintr+0x150>
  100816:	0f 8f a4 00 00 00    	jg     1008c0 <consoleintr+0xe0>
  10081c:	83 fb 08             	cmp    $0x8,%ebx
  10081f:	90                   	nop
  100820:	0f 84 a8 00 00 00    	je     1008ce <consoleintr+0xee>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
  100826:	85 db                	test   %ebx,%ebx
  100828:	74 d6                	je     100800 <consoleintr+0x20>
  10082a:	a1 dc c0 10 00       	mov    0x10c0dc,%eax
  10082f:	89 c2                	mov    %eax,%edx
  100831:	2b 15 d4 c0 10 00    	sub    0x10c0d4,%edx
  100837:	83 fa 7f             	cmp    $0x7f,%edx
  10083a:	77 c4                	ja     100800 <consoleintr+0x20>
        c = (c == '\r') ? '\n' : c;
  10083c:	83 fb 0d             	cmp    $0xd,%ebx
  10083f:	0f 84 f8 00 00 00    	je     10093d <consoleintr+0x15d>
        input.buf[input.e++ % INPUT_BUF] = c;
  100845:	89 c2                	mov    %eax,%edx
  100847:	83 c0 01             	add    $0x1,%eax
  10084a:	83 e2 7f             	and    $0x7f,%edx
  10084d:	88 5c 17 04          	mov    %bl,0x4(%edi,%edx,1)
  100851:	a3 dc c0 10 00       	mov    %eax,0x10c0dc
        consputc(c);
  100856:	89 d8                	mov    %ebx,%eax
  100858:	e8 c3 fa ff ff       	call   100320 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
  10085d:	83 fb 04             	cmp    $0x4,%ebx
  100860:	0f 84 f3 00 00 00    	je     100959 <consoleintr+0x179>
  100866:	83 fb 0a             	cmp    $0xa,%ebx
  100869:	0f 84 ea 00 00 00    	je     100959 <consoleintr+0x179>
  10086f:	8b 15 d4 c0 10 00    	mov    0x10c0d4,%edx
  100875:	a1 dc c0 10 00       	mov    0x10c0dc,%eax
  10087a:	83 ea 80             	sub    $0xffffff80,%edx
  10087d:	39 d0                	cmp    %edx,%eax
  10087f:	0f 85 7b ff ff ff    	jne    100800 <consoleintr+0x20>
          input.w = input.e;
  100885:	a3 d8 c0 10 00       	mov    %eax,0x10c0d8
          wakeup(&input.r);
  10088a:	c7 04 24 d4 c0 10 00 	movl   $0x10c0d4,(%esp)
  100891:	e8 ea 28 00 00       	call   103180 <wakeup>
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
  100896:	ff d6                	call   *%esi
  100898:	85 c0                	test   %eax,%eax
  10089a:	89 c3                	mov    %eax,%ebx
  10089c:	0f 89 6a ff ff ff    	jns    10080c <consoleintr+0x2c>
  1008a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        }
      }
      break;
    }
  }
  release(&input.lock);
  1008a8:	c7 45 08 20 c0 10 00 	movl   $0x10c020,0x8(%ebp)
}
  1008af:	83 c4 1c             	add    $0x1c,%esp
  1008b2:	5b                   	pop    %ebx
  1008b3:	5e                   	pop    %esi
  1008b4:	5f                   	pop    %edi
  1008b5:	5d                   	pop    %ebp
        }
      }
      break;
    }
  }
  release(&input.lock);
  1008b6:	e9 15 35 00 00       	jmp    103dd0 <release>
  1008bb:	90                   	nop
  1008bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
    switch(c){
  1008c0:	83 fb 15             	cmp    $0x15,%ebx
  1008c3:	74 57                	je     10091c <consoleintr+0x13c>
  1008c5:	83 fb 7f             	cmp    $0x7f,%ebx
  1008c8:	0f 85 58 ff ff ff    	jne    100826 <consoleintr+0x46>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
  1008ce:	a1 dc c0 10 00       	mov    0x10c0dc,%eax
  1008d3:	3b 05 d8 c0 10 00    	cmp    0x10c0d8,%eax
  1008d9:	0f 84 21 ff ff ff    	je     100800 <consoleintr+0x20>
        input.e--;
  1008df:	83 e8 01             	sub    $0x1,%eax
  1008e2:	a3 dc c0 10 00       	mov    %eax,0x10c0dc
        consputc(BACKSPACE);
  1008e7:	b8 00 01 00 00       	mov    $0x100,%eax
  1008ec:	e8 2f fa ff ff       	call   100320 <consputc>
  1008f1:	e9 0a ff ff ff       	jmp    100800 <consoleintr+0x20>
  1008f6:	66 90                	xchg   %ax,%ax
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
  1008f8:	83 e8 01             	sub    $0x1,%eax
  1008fb:	89 c2                	mov    %eax,%edx
  1008fd:	83 e2 7f             	and    $0x7f,%edx
  100900:	80 ba 54 c0 10 00 0a 	cmpb   $0xa,0x10c054(%edx)
  100907:	0f 84 f3 fe ff ff    	je     100800 <consoleintr+0x20>
        input.e--;
  10090d:	a3 dc c0 10 00       	mov    %eax,0x10c0dc
        consputc(BACKSPACE);
  100912:	b8 00 01 00 00       	mov    $0x100,%eax
  100917:	e8 04 fa ff ff       	call   100320 <consputc>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
  10091c:	a1 dc c0 10 00       	mov    0x10c0dc,%eax
  100921:	3b 05 d8 c0 10 00    	cmp    0x10c0d8,%eax
  100927:	75 cf                	jne    1008f8 <consoleintr+0x118>
  100929:	e9 d2 fe ff ff       	jmp    100800 <consoleintr+0x20>
  10092e:	66 90                	xchg   %ax,%ax

  acquire(&input.lock);
  while((c = getc()) >= 0){
    switch(c){
    case C('P'):  // Process listing.
      procdump();
  100930:	e8 eb 26 00 00       	call   103020 <procdump>
  100935:	8d 76 00             	lea    0x0(%esi),%esi
      break;
  100938:	e9 c3 fe ff ff       	jmp    100800 <consoleintr+0x20>
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
  10093d:	89 c2                	mov    %eax,%edx
  10093f:	83 c0 01             	add    $0x1,%eax
  100942:	83 e2 7f             	and    $0x7f,%edx
  100945:	c6 44 17 04 0a       	movb   $0xa,0x4(%edi,%edx,1)
  10094a:	a3 dc c0 10 00       	mov    %eax,0x10c0dc
        consputc(c);
  10094f:	b8 0a 00 00 00       	mov    $0xa,%eax
  100954:	e8 c7 f9 ff ff       	call   100320 <consputc>
  100959:	a1 dc c0 10 00       	mov    0x10c0dc,%eax
  10095e:	e9 22 ff ff ff       	jmp    100885 <consoleintr+0xa5>
  100963:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100969:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100970 <panic>:
    release(&cons.lock);
}

void
panic(char *s)
{
  100970:	55                   	push   %ebp
  100971:	89 e5                	mov    %esp,%ebp
  100973:	56                   	push   %esi
  100974:	53                   	push   %ebx
  100975:	83 ec 40             	sub    $0x40,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
  100978:	fa                   	cli    
  int i;
  uint pcs[10];
  
  cli();
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  100979:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  10097f:	8d 75 d0             	lea    -0x30(%ebp),%esi
  100982:	31 db                	xor    %ebx,%ebx
{
  int i;
  uint pcs[10];
  
  cli();
  cons.locking = 0;
  100984:	c7 05 74 98 10 00 00 	movl   $0x0,0x109874
  10098b:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
  10098e:	0f b6 00             	movzbl (%eax),%eax
  100991:	c7 04 24 bb 67 10 00 	movl   $0x1067bb,(%esp)
  100998:	89 44 24 04          	mov    %eax,0x4(%esp)
  10099c:	e8 df fb ff ff       	call   100580 <cprintf>
  cprintf(s);
  1009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1009a4:	89 04 24             	mov    %eax,(%esp)
  1009a7:	e8 d4 fb ff ff       	call   100580 <cprintf>
  cprintf("\n");
  1009ac:	c7 04 24 d6 6b 10 00 	movl   $0x106bd6,(%esp)
  1009b3:	e8 c8 fb ff ff       	call   100580 <cprintf>
  getcallerpcs(&s, pcs);
  1009b8:	8d 45 08             	lea    0x8(%ebp),%eax
  1009bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  1009bf:	89 04 24             	mov    %eax,(%esp)
  1009c2:	e8 e9 32 00 00       	call   103cb0 <getcallerpcs>
  1009c7:	90                   	nop
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
  1009c8:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
  1009cb:	83 c3 01             	add    $0x1,%ebx
    cprintf(" %p", pcs[i]);
  1009ce:	c7 04 24 ca 67 10 00 	movl   $0x1067ca,(%esp)
  1009d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009d9:	e8 a2 fb ff ff       	call   100580 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
  1009de:	83 fb 0a             	cmp    $0xa,%ebx
  1009e1:	75 e5                	jne    1009c8 <panic+0x58>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
  1009e3:	c7 05 20 98 10 00 01 	movl   $0x1,0x109820
  1009ea:	00 00 00 
  1009ed:	eb fe                	jmp    1009ed <panic+0x7d>
  1009ef:	90                   	nop

001009f0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
  1009f0:	55                   	push   %ebp
  1009f1:	89 e5                	mov    %esp,%ebp
  1009f3:	57                   	push   %edi
  1009f4:	56                   	push   %esi
  1009f5:	53                   	push   %ebx
  1009f6:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
  1009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1009ff:	89 04 24             	mov    %eax,(%esp)
  100a02:	e8 99 14 00 00       	call   101ea0 <namei>
  100a07:	85 c0                	test   %eax,%eax
  100a09:	89 c7                	mov    %eax,%edi
  100a0b:	0f 84 25 01 00 00    	je     100b36 <exec+0x146>
    return -1;
  ilock(ip);
  100a11:	89 04 24             	mov    %eax,(%esp)
  100a14:	e8 e7 11 00 00       	call   101c00 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
  100a19:	8d 45 94             	lea    -0x6c(%ebp),%eax
  100a1c:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
  100a23:	00 
  100a24:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100a2b:	00 
  100a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a30:	89 3c 24             	mov    %edi,(%esp)
  100a33:	e8 88 09 00 00       	call   1013c0 <readi>
  100a38:	83 f8 33             	cmp    $0x33,%eax
  100a3b:	0f 86 df 01 00 00    	jbe    100c20 <exec+0x230>
    goto bad;
  if(elf.magic != ELF_MAGIC)
  100a41:	81 7d 94 7f 45 4c 46 	cmpl   $0x464c457f,-0x6c(%ebp)
  100a48:	0f 85 d2 01 00 00    	jne    100c20 <exec+0x230>
  100a4e:	66 90                	xchg   %ax,%ax
    goto bad;

  if((pgdir = setupkvm()) == 0)
  100a50:	e8 bb 56 00 00       	call   106110 <setupkvm>
  100a55:	85 c0                	test   %eax,%eax
  100a57:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
  100a5d:	0f 84 bd 01 00 00    	je     100c20 <exec+0x230>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100a63:	66 83 7d c0 00       	cmpw   $0x0,-0x40(%ebp)
  100a68:	8b 75 b0             	mov    -0x50(%ebp),%esi
  100a6b:	0f 84 d2 02 00 00    	je     100d43 <exec+0x353>
  100a71:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  100a78:	00 00 00 
  100a7b:	31 db                	xor    %ebx,%ebx
  100a7d:	eb 13                	jmp    100a92 <exec+0xa2>
  100a7f:	90                   	nop
  100a80:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
  100a84:	83 c3 01             	add    $0x1,%ebx
  100a87:	39 d8                	cmp    %ebx,%eax
  100a89:	0f 8e b9 00 00 00    	jle    100b48 <exec+0x158>
  100a8f:	83 c6 20             	add    $0x20,%esi
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
  100a92:	8d 55 c8             	lea    -0x38(%ebp),%edx
  100a95:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
  100a9c:	00 
  100a9d:	89 74 24 08          	mov    %esi,0x8(%esp)
  100aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  100aa5:	89 3c 24             	mov    %edi,(%esp)
  100aa8:	e8 13 09 00 00       	call   1013c0 <readi>
  100aad:	83 f8 20             	cmp    $0x20,%eax
  100ab0:	75 6e                	jne    100b20 <exec+0x130>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
  100ab2:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  100ab6:	75 c8                	jne    100a80 <exec+0x90>
      continue;
    if(ph.memsz < ph.filesz)
  100ab8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100abb:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  100abe:	66 90                	xchg   %ax,%ax
  100ac0:	72 5e                	jb     100b20 <exec+0x130>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.va + ph.memsz)) == 0)
  100ac2:	03 45 d0             	add    -0x30(%ebp),%eax
  100ac5:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  100acb:	89 44 24 08          	mov    %eax,0x8(%esp)
  100acf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100ad5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100ad9:	89 04 24             	mov    %eax,(%esp)
  100adc:	e8 2f 59 00 00       	call   106410 <allocuvm>
  100ae1:	85 c0                	test   %eax,%eax
  100ae3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
  100ae9:	74 35                	je     100b20 <exec+0x130>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.va, ip, ph.offset, ph.filesz) < 0)
  100aeb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100aee:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  100af4:	89 7c 24 08          	mov    %edi,0x8(%esp)
  100af8:	89 44 24 10          	mov    %eax,0x10(%esp)
  100afc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  100aff:	89 14 24             	mov    %edx,(%esp)
  100b02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100b06:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b0d:	e8 ce 59 00 00       	call   1064e0 <loaduvm>
  100b12:	85 c0                	test   %eax,%eax
  100b14:	0f 89 66 ff ff ff    	jns    100a80 <exec+0x90>
  100b1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  100b20:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100b26:	89 04 24             	mov    %eax,(%esp)
  100b29:	e8 a2 57 00 00       	call   1062d0 <freevm>
  if(ip)
  100b2e:	85 ff                	test   %edi,%edi
  100b30:	0f 85 ea 00 00 00    	jne    100c20 <exec+0x230>
    iunlockput(ip);
  100b36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
  100b3b:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  100b41:	5b                   	pop    %ebx
  100b42:	5e                   	pop    %esi
  100b43:	5f                   	pop    %edi
  100b44:	5d                   	pop    %ebp
  100b45:	c3                   	ret    
  100b46:	66 90                	xchg   %ax,%ax
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100b48:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100b4e:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  100b54:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  100b5a:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
    if((sz = allocuvm(pgdir, sz, ph.va + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.va, ip, ph.offset, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  100b60:	89 3c 24             	mov    %edi,(%esp)
  100b63:	e8 a8 0f 00 00       	call   101b10 <iunlockput>
  ip = 0;

  // Allocate a one-page stack at the next page boundary  
  sz = PGROUNDUP(sz);
  
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
  100b68:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
  100b6e:	89 74 24 08          	mov    %esi,0x8(%esp)
  100b72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100b76:	89 0c 24             	mov    %ecx,(%esp)
  100b79:	e8 92 58 00 00       	call   106410 <allocuvm>
  100b7e:	85 c0                	test   %eax,%eax
  100b80:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
  100b86:	0f 84 8b 00 00 00    	je     100c17 <exec+0x227>
    goto bad;

  proc->pstack = (uint *)sz;
  100b8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100b92:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
  100b98:	89 50 7c             	mov    %edx,0x7c(%eax)
//  proc->pstack2 = (uint *)sz + PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100b9e:	8b 01                	mov    (%ecx),%eax
  100ba0:	85 c0                	test   %eax,%eax
  100ba2:	0f 84 80 01 00 00    	je     100d28 <exec+0x338>
  100ba8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  100bab:	31 f6                	xor    %esi,%esi
  100bad:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100bb3:	eb 25                	jmp    100bda <exec+0x1ea>
  100bb5:	8d 76 00             	lea    0x0(%esi),%esi
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  100bb8:	89 9c b5 10 ff ff ff 	mov    %ebx,-0xf0(%ebp,%esi,4)
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
  100bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  proc->pstack = (uint *)sz;
//  proc->pstack2 = (uint *)sz + PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100bc2:	83 c6 01             	add    $0x1,%esi
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  100bc5:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
  proc->pstack = (uint *)sz;
//  proc->pstack2 = (uint *)sz + PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100bcb:	8b 04 b1             	mov    (%ecx,%esi,4),%eax
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
  100bce:	8d 3c b1             	lea    (%ecx,%esi,4),%edi
  proc->pstack = (uint *)sz;
//  proc->pstack2 = (uint *)sz + PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100bd1:	85 c0                	test   %eax,%eax
  100bd3:	74 5d                	je     100c32 <exec+0x242>
    if(argc >= MAXARG)
  100bd5:	83 fe 20             	cmp    $0x20,%esi
  100bd8:	74 3d                	je     100c17 <exec+0x227>
      goto bad;
    sp -= strlen(argv[argc]) + 1;
  100bda:	89 04 24             	mov    %eax,(%esp)
  100bdd:	e8 be 34 00 00       	call   1040a0 <strlen>
  100be2:	f7 d0                	not    %eax
  100be4:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
  100be7:	8b 07                	mov    (%edi),%eax
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
  100be9:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
  100bec:	89 04 24             	mov    %eax,(%esp)
  100bef:	e8 ac 34 00 00       	call   1040a0 <strlen>
  100bf4:	83 c0 01             	add    $0x1,%eax
  100bf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100bfb:	8b 07                	mov    (%edi),%eax
  100bfd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100c01:	89 44 24 08          	mov    %eax,0x8(%esp)
  100c05:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100c0b:	89 04 24             	mov    %eax,(%esp)
  100c0e:	e8 dd 53 00 00       	call   105ff0 <copyout>
  100c13:	85 c0                	test   %eax,%eax
  100c15:	79 a1                	jns    100bb8 <exec+0x1c8>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip)
    iunlockput(ip);
  100c17:	31 ff                	xor    %edi,%edi
  100c19:	e9 02 ff ff ff       	jmp    100b20 <exec+0x130>
  100c1e:	66 90                	xchg   %ax,%ax
  100c20:	89 3c 24             	mov    %edi,(%esp)
  100c23:	e8 e8 0e 00 00       	call   101b10 <iunlockput>
  100c28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100c2d:	e9 09 ff ff ff       	jmp    100b3b <exec+0x14b>
  proc->pstack = (uint *)sz;
//  proc->pstack2 = (uint *)sz + PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100c32:	8d 4e 03             	lea    0x3(%esi),%ecx
  100c35:	8d 3c b5 04 00 00 00 	lea    0x4(,%esi,4),%edi
  100c3c:	8d 04 b5 10 00 00 00 	lea    0x10(,%esi,4),%eax
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
  100c43:	c7 84 8d 04 ff ff ff 	movl   $0x0,-0xfc(%ebp,%ecx,4)
  100c4a:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c4e:	89 d9                	mov    %ebx,%ecx

  sp -= (3+argc+1) * 4;
  100c50:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
  100c52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100c56:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c5c:	29 f9                	sub    %edi,%ecx
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  100c5e:	c7 85 04 ff ff ff ff 	movl   $0xffffffff,-0xfc(%ebp)
  100c65:	ff ff ff 
  ustack[1] = argc;
  100c68:	89 b5 08 ff ff ff    	mov    %esi,-0xf8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c6e:	89 8d 0c ff ff ff    	mov    %ecx,-0xf4(%ebp)

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
  100c74:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c78:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100c7c:	89 04 24             	mov    %eax,(%esp)
  100c7f:	e8 6c 53 00 00       	call   105ff0 <copyout>
  100c84:	85 c0                	test   %eax,%eax
  100c86:	78 8f                	js     100c17 <exec+0x227>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
  100c88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  100c8b:	0f b6 11             	movzbl (%ecx),%edx
  100c8e:	84 d2                	test   %dl,%dl
  100c90:	74 21                	je     100cb3 <exec+0x2c3>
  100c92:	89 c8                	mov    %ecx,%eax
  100c94:	83 c0 01             	add    $0x1,%eax
  100c97:	eb 11                	jmp    100caa <exec+0x2ba>
  100c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  100ca0:	0f b6 10             	movzbl (%eax),%edx
  100ca3:	83 c0 01             	add    $0x1,%eax
  100ca6:	84 d2                	test   %dl,%dl
  100ca8:	74 09                	je     100cb3 <exec+0x2c3>
    if(*s == '/')
  100caa:	80 fa 2f             	cmp    $0x2f,%dl
  100cad:	75 f1                	jne    100ca0 <exec+0x2b0>
  100caf:	89 c1                	mov    %eax,%ecx
  100cb1:	eb ed                	jmp    100ca0 <exec+0x2b0>
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
  100cb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100cb9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100cbd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  100cc4:	00 
  100cc5:	83 c0 6c             	add    $0x6c,%eax
  100cc8:	89 04 24             	mov    %eax,(%esp)
  100ccb:	e8 90 33 00 00       	call   104060 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  100cd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  proc->pgdir = pgdir;
  100cd6:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  100cdc:	8b 70 04             	mov    0x4(%eax),%esi
  proc->pgdir = pgdir;
  100cdf:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
  100ce2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100ce8:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  100cee:	89 08                	mov    %ecx,(%eax)
  proc->tf->eip = elf.entry;  // main
  100cf0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100cf6:	8b 55 ac             	mov    -0x54(%ebp),%edx
  100cf9:	8b 40 18             	mov    0x18(%eax),%eax
  100cfc:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
  100cff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100d05:	8b 40 18             	mov    0x18(%eax),%eax
  100d08:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(proc);
  100d0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100d11:	89 04 24             	mov    %eax,(%esp)
  100d14:	e8 87 58 00 00       	call   1065a0 <switchuvm>
  freevm(oldpgdir);
  100d19:	89 34 24             	mov    %esi,(%esp)
  100d1c:	e8 af 55 00 00       	call   1062d0 <freevm>
  100d21:	31 c0                	xor    %eax,%eax

  return 0;
  100d23:	e9 13 fe ff ff       	jmp    100b3b <exec+0x14b>
  proc->pstack = (uint *)sz;
//  proc->pstack2 = (uint *)sz + PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100d28:	89 d3                	mov    %edx,%ebx
  100d2a:	b0 10                	mov    $0x10,%al
  100d2c:	bf 04 00 00 00       	mov    $0x4,%edi
  100d31:	b9 03 00 00 00       	mov    $0x3,%ecx
  100d36:	31 f6                	xor    %esi,%esi
  100d38:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
  100d3e:	e9 00 ff ff ff       	jmp    100c43 <exec+0x253>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100d43:	be 00 10 00 00       	mov    $0x1000,%esi
  100d48:	31 db                	xor    %ebx,%ebx
  100d4a:	e9 11 fe ff ff       	jmp    100b60 <exec+0x170>
  100d4f:	90                   	nop

00100d50 <filewrite>:
}

// Write to file f.  Addr is kernel address.
int
filewrite(struct file *f, char *addr, int n)
{
  100d50:	55                   	push   %ebp
  100d51:	89 e5                	mov    %esp,%ebp
  100d53:	83 ec 38             	sub    $0x38,%esp
  100d56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100d59:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100d5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100d5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  100d62:	89 7d fc             	mov    %edi,-0x4(%ebp)
  100d65:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->writable == 0)
  100d68:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
  100d6c:	74 5a                	je     100dc8 <filewrite+0x78>
    return -1;
  if(f->type == FD_PIPE)
  100d6e:	8b 03                	mov    (%ebx),%eax
  100d70:	83 f8 01             	cmp    $0x1,%eax
  100d73:	74 5b                	je     100dd0 <filewrite+0x80>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
  100d75:	83 f8 02             	cmp    $0x2,%eax
  100d78:	75 6d                	jne    100de7 <filewrite+0x97>
    ilock(f->ip);
  100d7a:	8b 43 10             	mov    0x10(%ebx),%eax
  100d7d:	89 04 24             	mov    %eax,(%esp)
  100d80:	e8 7b 0e 00 00       	call   101c00 <ilock>
    if((r = writei(f->ip, addr, f->off, n)) > 0)
  100d85:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  100d89:	8b 43 14             	mov    0x14(%ebx),%eax
  100d8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  100d90:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d94:	8b 43 10             	mov    0x10(%ebx),%eax
  100d97:	89 04 24             	mov    %eax,(%esp)
  100d9a:	e8 b1 07 00 00       	call   101550 <writei>
  100d9f:	85 c0                	test   %eax,%eax
  100da1:	7e 03                	jle    100da6 <filewrite+0x56>
      f->off += r;
  100da3:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
  100da6:	8b 53 10             	mov    0x10(%ebx),%edx
  100da9:	89 14 24             	mov    %edx,(%esp)
  100dac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100daf:	e8 0c 0a 00 00       	call   1017c0 <iunlock>
    return r;
  100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("filewrite");
}
  100db7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100dba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100dbd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100dc0:	89 ec                	mov    %ebp,%esp
  100dc2:	5d                   	pop    %ebp
  100dc3:	c3                   	ret    
  100dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((r = writei(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
  100dc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100dcd:	eb e8                	jmp    100db7 <filewrite+0x67>
  100dcf:	90                   	nop
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100dd0:	8b 43 0c             	mov    0xc(%ebx),%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
}
  100dd3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100dd6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100dd9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100ddc:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
}
  100ddf:	89 ec                	mov    %ebp,%esp
  100de1:	5d                   	pop    %ebp
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100de2:	e9 c9 1f 00 00       	jmp    102db0 <pipewrite>
    if((r = writei(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
  100de7:	c7 04 24 df 67 10 00 	movl   $0x1067df,(%esp)
  100dee:	e8 7d fb ff ff       	call   100970 <panic>
  100df3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100df9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100e00 <fileread>:
}

// Read from file f.  Addr is kernel address.
int
fileread(struct file *f, char *addr, int n)
{
  100e00:	55                   	push   %ebp
  100e01:	89 e5                	mov    %esp,%ebp
  100e03:	83 ec 38             	sub    $0x38,%esp
  100e06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100e09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100e0c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100e0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  100e12:	89 7d fc             	mov    %edi,-0x4(%ebp)
  100e15:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
  100e18:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
  100e1c:	74 5a                	je     100e78 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
  100e1e:	8b 03                	mov    (%ebx),%eax
  100e20:	83 f8 01             	cmp    $0x1,%eax
  100e23:	74 5b                	je     100e80 <fileread+0x80>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
  100e25:	83 f8 02             	cmp    $0x2,%eax
  100e28:	75 6d                	jne    100e97 <fileread+0x97>
    ilock(f->ip);
  100e2a:	8b 43 10             	mov    0x10(%ebx),%eax
  100e2d:	89 04 24             	mov    %eax,(%esp)
  100e30:	e8 cb 0d 00 00       	call   101c00 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
  100e35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  100e39:	8b 43 14             	mov    0x14(%ebx),%eax
  100e3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  100e40:	89 44 24 08          	mov    %eax,0x8(%esp)
  100e44:	8b 43 10             	mov    0x10(%ebx),%eax
  100e47:	89 04 24             	mov    %eax,(%esp)
  100e4a:	e8 71 05 00 00       	call   1013c0 <readi>
  100e4f:	85 c0                	test   %eax,%eax
  100e51:	7e 03                	jle    100e56 <fileread+0x56>
      f->off += r;
  100e53:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
  100e56:	8b 53 10             	mov    0x10(%ebx),%edx
  100e59:	89 14 24             	mov    %edx,(%esp)
  100e5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100e5f:	e8 5c 09 00 00       	call   1017c0 <iunlock>
    return r;
  100e64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("fileread");
}
  100e67:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100e6a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100e6d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100e70:	89 ec                	mov    %ebp,%esp
  100e72:	5d                   	pop    %ebp
  100e73:	c3                   	ret    
  100e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
  100e78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100e7d:	eb e8                	jmp    100e67 <fileread+0x67>
  100e7f:	90                   	nop
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100e80:	8b 43 0c             	mov    0xc(%ebx),%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
  100e83:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100e86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100e89:	8b 7d fc             	mov    -0x4(%ebp),%edi
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100e8c:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
  100e8f:	89 ec                	mov    %ebp,%esp
  100e91:	5d                   	pop    %ebp
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100e92:	e9 19 1e 00 00       	jmp    102cb0 <piperead>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
  100e97:	c7 04 24 e9 67 10 00 	movl   $0x1067e9,(%esp)
  100e9e:	e8 cd fa ff ff       	call   100970 <panic>
  100ea3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100ea9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100eb0 <filestat>:
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  100eb0:	55                   	push   %ebp
  if(f->type == FD_INODE){
  100eb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  100eb6:	89 e5                	mov    %esp,%ebp
  100eb8:	53                   	push   %ebx
  100eb9:	83 ec 14             	sub    $0x14,%esp
  100ebc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
  100ebf:	83 3b 02             	cmpl   $0x2,(%ebx)
  100ec2:	74 0c                	je     100ed0 <filestat+0x20>
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
  }
  return -1;
}
  100ec4:	83 c4 14             	add    $0x14,%esp
  100ec7:	5b                   	pop    %ebx
  100ec8:	5d                   	pop    %ebp
  100ec9:	c3                   	ret    
  100eca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
  100ed0:	8b 43 10             	mov    0x10(%ebx),%eax
  100ed3:	89 04 24             	mov    %eax,(%esp)
  100ed6:	e8 25 0d 00 00       	call   101c00 <ilock>
    stati(f->ip, st);
  100edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ede:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ee2:	8b 43 10             	mov    0x10(%ebx),%eax
  100ee5:	89 04 24             	mov    %eax,(%esp)
  100ee8:	e8 e3 01 00 00       	call   1010d0 <stati>
    iunlock(f->ip);
  100eed:	8b 43 10             	mov    0x10(%ebx),%eax
  100ef0:	89 04 24             	mov    %eax,(%esp)
  100ef3:	e8 c8 08 00 00       	call   1017c0 <iunlock>
    return 0;
  }
  return -1;
}
  100ef8:	83 c4 14             	add    $0x14,%esp
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
  100efb:	31 c0                	xor    %eax,%eax
    return 0;
  }
  return -1;
}
  100efd:	5b                   	pop    %ebx
  100efe:	5d                   	pop    %ebp
  100eff:	c3                   	ret    

00100f00 <filedup>:
}

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
  100f00:	55                   	push   %ebp
  100f01:	89 e5                	mov    %esp,%ebp
  100f03:	53                   	push   %ebx
  100f04:	83 ec 14             	sub    $0x14,%esp
  100f07:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
  100f0a:	c7 04 24 e0 c0 10 00 	movl   $0x10c0e0,(%esp)
  100f11:	e8 0a 2f 00 00       	call   103e20 <acquire>
  if(f->ref < 1)
  100f16:	8b 43 04             	mov    0x4(%ebx),%eax
  100f19:	85 c0                	test   %eax,%eax
  100f1b:	7e 1a                	jle    100f37 <filedup+0x37>
    panic("filedup");
  f->ref++;
  100f1d:	83 c0 01             	add    $0x1,%eax
  100f20:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
  100f23:	c7 04 24 e0 c0 10 00 	movl   $0x10c0e0,(%esp)
  100f2a:	e8 a1 2e 00 00       	call   103dd0 <release>
  return f;
}
  100f2f:	89 d8                	mov    %ebx,%eax
  100f31:	83 c4 14             	add    $0x14,%esp
  100f34:	5b                   	pop    %ebx
  100f35:	5d                   	pop    %ebp
  100f36:	c3                   	ret    
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
  100f37:	c7 04 24 f2 67 10 00 	movl   $0x1067f2,(%esp)
  100f3e:	e8 2d fa ff ff       	call   100970 <panic>
  100f43:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100f49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100f50 <filealloc>:
}

// Allocate a file structure.
struct file*
filealloc(void)
{
  100f50:	55                   	push   %ebp
  100f51:	89 e5                	mov    %esp,%ebp
  100f53:	53                   	push   %ebx
  initlock(&ftable.lock, "ftable");
}

// Allocate a file structure.
struct file*
filealloc(void)
  100f54:	bb 2c c1 10 00       	mov    $0x10c12c,%ebx
{
  100f59:	83 ec 14             	sub    $0x14,%esp
  struct file *f;

  acquire(&ftable.lock);
  100f5c:	c7 04 24 e0 c0 10 00 	movl   $0x10c0e0,(%esp)
  100f63:	e8 b8 2e 00 00       	call   103e20 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
  100f68:	8b 15 18 c1 10 00    	mov    0x10c118,%edx
  100f6e:	85 d2                	test   %edx,%edx
  100f70:	75 11                	jne    100f83 <filealloc+0x33>
  100f72:	eb 4a                	jmp    100fbe <filealloc+0x6e>
  100f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
  100f78:	83 c3 18             	add    $0x18,%ebx
  100f7b:	81 fb 74 ca 10 00    	cmp    $0x10ca74,%ebx
  100f81:	74 25                	je     100fa8 <filealloc+0x58>
    if(f->ref == 0){
  100f83:	8b 43 04             	mov    0x4(%ebx),%eax
  100f86:	85 c0                	test   %eax,%eax
  100f88:	75 ee                	jne    100f78 <filealloc+0x28>
      f->ref = 1;
  100f8a:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
  100f91:	c7 04 24 e0 c0 10 00 	movl   $0x10c0e0,(%esp)
  100f98:	e8 33 2e 00 00       	call   103dd0 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
  100f9d:	89 d8                	mov    %ebx,%eax
  100f9f:	83 c4 14             	add    $0x14,%esp
  100fa2:	5b                   	pop    %ebx
  100fa3:	5d                   	pop    %ebp
  100fa4:	c3                   	ret    
  100fa5:	8d 76 00             	lea    0x0(%esi),%esi
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
  100fa8:	31 db                	xor    %ebx,%ebx
  100faa:	c7 04 24 e0 c0 10 00 	movl   $0x10c0e0,(%esp)
  100fb1:	e8 1a 2e 00 00       	call   103dd0 <release>
  return 0;
}
  100fb6:	89 d8                	mov    %ebx,%eax
  100fb8:	83 c4 14             	add    $0x14,%esp
  100fbb:	5b                   	pop    %ebx
  100fbc:	5d                   	pop    %ebp
  100fbd:	c3                   	ret    
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
  100fbe:	bb 14 c1 10 00       	mov    $0x10c114,%ebx
  100fc3:	eb c5                	jmp    100f8a <filealloc+0x3a>
  100fc5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  100fc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100fd0 <fileclose>:
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
  100fd0:	55                   	push   %ebp
  100fd1:	89 e5                	mov    %esp,%ebp
  100fd3:	83 ec 38             	sub    $0x38,%esp
  100fd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100fd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100fdc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100fdf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct file ff;

  acquire(&ftable.lock);
  100fe2:	c7 04 24 e0 c0 10 00 	movl   $0x10c0e0,(%esp)
  100fe9:	e8 32 2e 00 00       	call   103e20 <acquire>
  if(f->ref < 1)
  100fee:	8b 43 04             	mov    0x4(%ebx),%eax
  100ff1:	85 c0                	test   %eax,%eax
  100ff3:	0f 8e 9c 00 00 00    	jle    101095 <fileclose+0xc5>
    panic("fileclose");
  if(--f->ref > 0){
  100ff9:	83 e8 01             	sub    $0x1,%eax
  100ffc:	85 c0                	test   %eax,%eax
  100ffe:	89 43 04             	mov    %eax,0x4(%ebx)
  101001:	74 1d                	je     101020 <fileclose+0x50>
    release(&ftable.lock);
  101003:	c7 45 08 e0 c0 10 00 	movl   $0x10c0e0,0x8(%ebp)
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
}
  10100a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10100d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101010:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101013:	89 ec                	mov    %ebp,%esp
  101015:	5d                   	pop    %ebp

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
  101016:	e9 b5 2d 00 00       	jmp    103dd0 <release>
  10101b:	90                   	nop
  10101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  }
  ff = *f;
  101020:	8b 43 0c             	mov    0xc(%ebx),%eax
  101023:	8b 7b 10             	mov    0x10(%ebx),%edi
  101026:	89 45 e0             	mov    %eax,-0x20(%ebp)
  101029:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  10102d:	88 45 e7             	mov    %al,-0x19(%ebp)
  101030:	8b 33                	mov    (%ebx),%esi
  f->ref = 0;
  101032:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
  101039:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
  10103f:	c7 04 24 e0 c0 10 00 	movl   $0x10c0e0,(%esp)
  101046:	e8 85 2d 00 00       	call   103dd0 <release>
  
  if(ff.type == FD_PIPE)
  10104b:	83 fe 01             	cmp    $0x1,%esi
  10104e:	74 30                	je     101080 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
  101050:	83 fe 02             	cmp    $0x2,%esi
  101053:	74 13                	je     101068 <fileclose+0x98>
    iput(ff.ip);
}
  101055:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  101058:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10105b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  10105e:	89 ec                	mov    %ebp,%esp
  101060:	5d                   	pop    %ebp
  101061:	c3                   	ret    
  101062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
  101068:	89 7d 08             	mov    %edi,0x8(%ebp)
}
  10106b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10106e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101071:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101074:	89 ec                	mov    %ebp,%esp
  101076:	5d                   	pop    %ebp
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
  101077:	e9 54 08 00 00       	jmp    1018d0 <iput>
  10107c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  101080:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101084:	89 44 24 04          	mov    %eax,0x4(%esp)
  101088:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10108b:	89 04 24             	mov    %eax,(%esp)
  10108e:	e8 0d 1e 00 00       	call   102ea0 <pipeclose>
  101093:	eb c0                	jmp    101055 <fileclose+0x85>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  101095:	c7 04 24 fa 67 10 00 	movl   $0x1067fa,(%esp)
  10109c:	e8 cf f8 ff ff       	call   100970 <panic>
  1010a1:	eb 0d                	jmp    1010b0 <fileinit>
  1010a3:	90                   	nop
  1010a4:	90                   	nop
  1010a5:	90                   	nop
  1010a6:	90                   	nop
  1010a7:	90                   	nop
  1010a8:	90                   	nop
  1010a9:	90                   	nop
  1010aa:	90                   	nop
  1010ab:	90                   	nop
  1010ac:	90                   	nop
  1010ad:	90                   	nop
  1010ae:	90                   	nop
  1010af:	90                   	nop

001010b0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
  1010b0:	55                   	push   %ebp
  1010b1:	89 e5                	mov    %esp,%ebp
  1010b3:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
  1010b6:	c7 44 24 04 04 68 10 	movl   $0x106804,0x4(%esp)
  1010bd:	00 
  1010be:	c7 04 24 e0 c0 10 00 	movl   $0x10c0e0,(%esp)
  1010c5:	e8 c6 2b 00 00       	call   103c90 <initlock>
}
  1010ca:	c9                   	leave  
  1010cb:	c3                   	ret    
  1010cc:	90                   	nop
  1010cd:	90                   	nop
  1010ce:	90                   	nop
  1010cf:	90                   	nop

001010d0 <stati>:
}

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
  1010d0:	55                   	push   %ebp
  1010d1:	89 e5                	mov    %esp,%ebp
  1010d3:	8b 55 08             	mov    0x8(%ebp),%edx
  1010d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
  1010d9:	8b 0a                	mov    (%edx),%ecx
  1010db:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
  1010de:	8b 4a 04             	mov    0x4(%edx),%ecx
  1010e1:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
  1010e4:	0f b7 4a 10          	movzwl 0x10(%edx),%ecx
  1010e8:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
  1010eb:	0f b7 4a 16          	movzwl 0x16(%edx),%ecx
  1010ef:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
  1010f3:	8b 52 18             	mov    0x18(%edx),%edx
  1010f6:	89 50 10             	mov    %edx,0x10(%eax)
}
  1010f9:	5d                   	pop    %ebp
  1010fa:	c3                   	ret    
  1010fb:	90                   	nop
  1010fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00101100 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
  101100:	55                   	push   %ebp
  101101:	89 e5                	mov    %esp,%ebp
  101103:	53                   	push   %ebx
  101104:	83 ec 14             	sub    $0x14,%esp
  101107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
  10110a:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  101111:	e8 0a 2d 00 00       	call   103e20 <acquire>
  ip->ref++;
  101116:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
  10111a:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  101121:	e8 aa 2c 00 00       	call   103dd0 <release>
  return ip;
}
  101126:	89 d8                	mov    %ebx,%eax
  101128:	83 c4 14             	add    $0x14,%esp
  10112b:	5b                   	pop    %ebx
  10112c:	5d                   	pop    %ebp
  10112d:	c3                   	ret    
  10112e:	66 90                	xchg   %ax,%ax

00101130 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
{
  101130:	55                   	push   %ebp
  101131:	89 e5                	mov    %esp,%ebp
  101133:	57                   	push   %edi
  101134:	89 d7                	mov    %edx,%edi
  101136:	56                   	push   %esi
}

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
  101137:	31 f6                	xor    %esi,%esi
{
  101139:	53                   	push   %ebx
  10113a:	89 c3                	mov    %eax,%ebx
  10113c:	83 ec 2c             	sub    $0x2c,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
  10113f:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  101146:	e8 d5 2c 00 00       	call   103e20 <acquire>
}

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
  10114b:	b8 14 cb 10 00       	mov    $0x10cb14,%eax
  101150:	eb 14                	jmp    101166 <iget+0x36>
  101152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
  101158:	85 f6                	test   %esi,%esi
  10115a:	74 3c                	je     101198 <iget+0x68>

  acquire(&icache.lock);

  // Try for cached inode.
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
  10115c:	83 c0 50             	add    $0x50,%eax
  10115f:	3d b4 da 10 00       	cmp    $0x10dab4,%eax
  101164:	74 42                	je     1011a8 <iget+0x78>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
  101166:	8b 48 08             	mov    0x8(%eax),%ecx
  101169:	85 c9                	test   %ecx,%ecx
  10116b:	7e eb                	jle    101158 <iget+0x28>
  10116d:	39 18                	cmp    %ebx,(%eax)
  10116f:	75 e7                	jne    101158 <iget+0x28>
  101171:	39 78 04             	cmp    %edi,0x4(%eax)
  101174:	75 e2                	jne    101158 <iget+0x28>
      ip->ref++;
  101176:	83 c1 01             	add    $0x1,%ecx
  101179:	89 48 08             	mov    %ecx,0x8(%eax)
      release(&icache.lock);
  10117c:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  101183:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101186:	e8 45 2c 00 00       	call   103dd0 <release>
      return ip;
  10118b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);

  return ip;
}
  10118e:	83 c4 2c             	add    $0x2c,%esp
  101191:	5b                   	pop    %ebx
  101192:	5e                   	pop    %esi
  101193:	5f                   	pop    %edi
  101194:	5d                   	pop    %ebp
  101195:	c3                   	ret    
  101196:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
  101198:	85 c9                	test   %ecx,%ecx
  10119a:	75 c0                	jne    10115c <iget+0x2c>
  10119c:	89 c6                	mov    %eax,%esi

  acquire(&icache.lock);

  // Try for cached inode.
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
  10119e:	83 c0 50             	add    $0x50,%eax
  1011a1:	3d b4 da 10 00       	cmp    $0x10dab4,%eax
  1011a6:	75 be                	jne    101166 <iget+0x36>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Allocate fresh inode.
  if(empty == 0)
  1011a8:	85 f6                	test   %esi,%esi
  1011aa:	74 29                	je     1011d5 <iget+0xa5>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
  1011ac:	89 1e                	mov    %ebx,(%esi)
  ip->inum = inum;
  1011ae:	89 7e 04             	mov    %edi,0x4(%esi)
  ip->ref = 1;
  1011b1:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->flags = 0;
  1011b8:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
  release(&icache.lock);
  1011bf:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  1011c6:	e8 05 2c 00 00       	call   103dd0 <release>

  return ip;
}
  1011cb:	83 c4 2c             	add    $0x2c,%esp
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);
  1011ce:	89 f0                	mov    %esi,%eax

  return ip;
}
  1011d0:	5b                   	pop    %ebx
  1011d1:	5e                   	pop    %esi
  1011d2:	5f                   	pop    %edi
  1011d3:	5d                   	pop    %ebp
  1011d4:	c3                   	ret    
      empty = ip;
  }

  // Allocate fresh inode.
  if(empty == 0)
    panic("iget: no inodes");
  1011d5:	c7 04 24 0b 68 10 00 	movl   $0x10680b,(%esp)
  1011dc:	e8 8f f7 ff ff       	call   100970 <panic>
  1011e1:	eb 0d                	jmp    1011f0 <readsb>
  1011e3:	90                   	nop
  1011e4:	90                   	nop
  1011e5:	90                   	nop
  1011e6:	90                   	nop
  1011e7:	90                   	nop
  1011e8:	90                   	nop
  1011e9:	90                   	nop
  1011ea:	90                   	nop
  1011eb:	90                   	nop
  1011ec:	90                   	nop
  1011ed:	90                   	nop
  1011ee:	90                   	nop
  1011ef:	90                   	nop

001011f0 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
static void
readsb(int dev, struct superblock *sb)
{
  1011f0:	55                   	push   %ebp
  1011f1:	89 e5                	mov    %esp,%ebp
  1011f3:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
  1011f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1011fd:	00 
static void itrunc(struct inode*);

// Read the super block.
static void
readsb(int dev, struct superblock *sb)
{
  1011fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  101201:	89 75 fc             	mov    %esi,-0x4(%ebp)
  101204:	89 d6                	mov    %edx,%esi
  struct buf *bp;
  
  bp = bread(dev, 1);
  101206:	89 04 24             	mov    %eax,(%esp)
  101209:	e8 62 ef ff ff       	call   100170 <bread>
  memmove(sb, bp->data, sizeof(*sb));
  10120e:	89 34 24             	mov    %esi,(%esp)
  101211:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
  101218:	00 
static void
readsb(int dev, struct superblock *sb)
{
  struct buf *bp;
  
  bp = bread(dev, 1);
  101219:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
  10121b:	8d 40 18             	lea    0x18(%eax),%eax
  10121e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101222:	e8 19 2d 00 00       	call   103f40 <memmove>
  brelse(bp);
  101227:	89 1c 24             	mov    %ebx,(%esp)
  10122a:	e8 91 ee ff ff       	call   1000c0 <brelse>
}
  10122f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  101232:	8b 75 fc             	mov    -0x4(%ebp),%esi
  101235:	89 ec                	mov    %ebp,%esp
  101237:	5d                   	pop    %ebp
  101238:	c3                   	ret    
  101239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00101240 <balloc>:
// Blocks. 

// Allocate a disk block.
static uint
balloc(uint dev)
{
  101240:	55                   	push   %ebp
  101241:	89 e5                	mov    %esp,%ebp
  101243:	57                   	push   %edi
  101244:	56                   	push   %esi
  101245:	53                   	push   %ebx
  101246:	83 ec 3c             	sub    $0x3c,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  101249:	8d 55 dc             	lea    -0x24(%ebp),%edx
// Blocks. 

// Allocate a disk block.
static uint
balloc(uint dev)
{
  10124c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  10124f:	e8 9c ff ff ff       	call   1011f0 <readsb>
  for(b = 0; b < sb.size; b += BPB){
  101254:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101257:	85 c0                	test   %eax,%eax
  101259:	0f 84 9c 00 00 00    	je     1012fb <balloc+0xbb>
  10125f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    bp = bread(dev, BBLOCK(b, sb.ninodes));
  101266:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101269:	31 db                	xor    %ebx,%ebx
  10126b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10126e:	c1 e8 03             	shr    $0x3,%eax
  101271:	c1 fa 0c             	sar    $0xc,%edx
  101274:	8d 44 10 03          	lea    0x3(%eax,%edx,1),%eax
  101278:	89 44 24 04          	mov    %eax,0x4(%esp)
  10127c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10127f:	89 04 24             	mov    %eax,(%esp)
  101282:	e8 e9 ee ff ff       	call   100170 <bread>
  101287:	89 c6                	mov    %eax,%esi
  101289:	eb 10                	jmp    10129b <balloc+0x5b>
  10128b:	90                   	nop
  10128c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(bi = 0; bi < BPB; bi++){
  101290:	83 c3 01             	add    $0x1,%ebx
  101293:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  101299:	74 45                	je     1012e0 <balloc+0xa0>
      m = 1 << (bi % 8);
  10129b:	89 d9                	mov    %ebx,%ecx
  10129d:	ba 01 00 00 00       	mov    $0x1,%edx
  1012a2:	83 e1 07             	and    $0x7,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
  1012a5:	89 d8                	mov    %ebx,%eax
  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB; bi++){
      m = 1 << (bi % 8);
  1012a7:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
  1012a9:	c1 f8 03             	sar    $0x3,%eax
  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB; bi++){
      m = 1 << (bi % 8);
  1012ac:	89 d1                	mov    %edx,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
  1012ae:	0f b6 54 06 18       	movzbl 0x18(%esi,%eax,1),%edx
  1012b3:	0f b6 fa             	movzbl %dl,%edi
  1012b6:	85 cf                	test   %ecx,%edi
  1012b8:	75 d6                	jne    101290 <balloc+0x50>
        bp->data[bi/8] |= m;  // Mark block in use on disk.
  1012ba:	09 d1                	or     %edx,%ecx
  1012bc:	88 4c 06 18          	mov    %cl,0x18(%esi,%eax,1)
        bwrite(bp);
  1012c0:	89 34 24             	mov    %esi,(%esp)
  1012c3:	e8 78 ee ff ff       	call   100140 <bwrite>
        brelse(bp);
  1012c8:	89 34 24             	mov    %esi,(%esp)
  1012cb:	e8 f0 ed ff ff       	call   1000c0 <brelse>
  1012d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
  1012d3:	83 c4 3c             	add    $0x3c,%esp
    for(bi = 0; bi < BPB; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use on disk.
        bwrite(bp);
        brelse(bp);
  1012d6:	8d 04 13             	lea    (%ebx,%edx,1),%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
  1012d9:	5b                   	pop    %ebx
  1012da:	5e                   	pop    %esi
  1012db:	5f                   	pop    %edi
  1012dc:	5d                   	pop    %ebp
  1012dd:	c3                   	ret    
  1012de:	66 90                	xchg   %ax,%ax
        bwrite(bp);
        brelse(bp);
        return b + bi;
      }
    }
    brelse(bp);
  1012e0:	89 34 24             	mov    %esi,(%esp)
  1012e3:	e8 d8 ed ff ff       	call   1000c0 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
  1012e8:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
  1012ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1012f2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1012f5:	0f 87 6b ff ff ff    	ja     101266 <balloc+0x26>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
  1012fb:	c7 04 24 1b 68 10 00 	movl   $0x10681b,(%esp)
  101302:	e8 69 f6 ff ff       	call   100970 <panic>
  101307:	89 f6                	mov    %esi,%esi
  101309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101310 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
  101310:	55                   	push   %ebp
  101311:	89 e5                	mov    %esp,%ebp
  101313:	83 ec 38             	sub    $0x38,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
  101316:	83 fa 0b             	cmp    $0xb,%edx

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
  101319:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  10131c:	89 c3                	mov    %eax,%ebx
  10131e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  101321:	89 7d fc             	mov    %edi,-0x4(%ebp)
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
  101324:	77 1a                	ja     101340 <bmap+0x30>
    if((addr = ip->addrs[bn]) == 0)
  101326:	8d 7a 04             	lea    0x4(%edx),%edi
  101329:	8b 44 b8 0c          	mov    0xc(%eax,%edi,4),%eax
  10132d:	85 c0                	test   %eax,%eax
  10132f:	74 5f                	je     101390 <bmap+0x80>
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
  101331:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  101334:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101337:	8b 7d fc             	mov    -0x4(%ebp),%edi
  10133a:	89 ec                	mov    %ebp,%esp
  10133c:	5d                   	pop    %ebp
  10133d:	c3                   	ret    
  10133e:	66 90                	xchg   %ax,%ax
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
  101340:	8d 7a f4             	lea    -0xc(%edx),%edi

  if(bn < NINDIRECT){
  101343:	83 ff 7f             	cmp    $0x7f,%edi
  101346:	77 64                	ja     1013ac <bmap+0x9c>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
  101348:	8b 40 4c             	mov    0x4c(%eax),%eax
  10134b:	85 c0                	test   %eax,%eax
  10134d:	74 51                	je     1013a0 <bmap+0x90>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  10134f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101353:	8b 03                	mov    (%ebx),%eax
  101355:	89 04 24             	mov    %eax,(%esp)
  101358:	e8 13 ee ff ff       	call   100170 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  10135d:	8d 7c b8 18          	lea    0x18(%eax,%edi,4),%edi

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  101361:	89 c6                	mov    %eax,%esi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  101363:	8b 07                	mov    (%edi),%eax
  101365:	85 c0                	test   %eax,%eax
  101367:	75 17                	jne    101380 <bmap+0x70>
      a[bn] = addr = balloc(ip->dev);
  101369:	8b 03                	mov    (%ebx),%eax
  10136b:	e8 d0 fe ff ff       	call   101240 <balloc>
  101370:	89 07                	mov    %eax,(%edi)
      bwrite(bp);
  101372:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101375:	89 34 24             	mov    %esi,(%esp)
  101378:	e8 c3 ed ff ff       	call   100140 <bwrite>
  10137d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    }
    brelse(bp);
  101380:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101383:	89 34 24             	mov    %esi,(%esp)
  101386:	e8 35 ed ff ff       	call   1000c0 <brelse>
    return addr;
  10138b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10138e:	eb a1                	jmp    101331 <bmap+0x21>
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
  101390:	8b 03                	mov    (%ebx),%eax
  101392:	e8 a9 fe ff ff       	call   101240 <balloc>
  101397:	89 44 bb 0c          	mov    %eax,0xc(%ebx,%edi,4)
  10139b:	eb 94                	jmp    101331 <bmap+0x21>
  10139d:	8d 76 00             	lea    0x0(%esi),%esi
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
  1013a0:	8b 03                	mov    (%ebx),%eax
  1013a2:	e8 99 fe ff ff       	call   101240 <balloc>
  1013a7:	89 43 4c             	mov    %eax,0x4c(%ebx)
  1013aa:	eb a3                	jmp    10134f <bmap+0x3f>
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
  1013ac:	c7 04 24 31 68 10 00 	movl   $0x106831,(%esp)
  1013b3:	e8 b8 f5 ff ff       	call   100970 <panic>
  1013b8:	90                   	nop
  1013b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001013c0 <readi>:
}

// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
  1013c0:	55                   	push   %ebp
  1013c1:	89 e5                	mov    %esp,%ebp
  1013c3:	83 ec 38             	sub    $0x38,%esp
  1013c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1013c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  1013cc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1013cf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  1013d2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  1013d5:	8b 75 10             	mov    0x10(%ebp),%esi
  1013d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
  1013db:	66 83 7b 10 03       	cmpw   $0x3,0x10(%ebx)
  1013e0:	74 1e                	je     101400 <readi+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
  1013e2:	8b 43 18             	mov    0x18(%ebx),%eax
  1013e5:	39 f0                	cmp    %esi,%eax
  1013e7:	73 3f                	jae    101428 <readi+0x68>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
  1013e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1013ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1013f1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1013f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1013f7:	89 ec                	mov    %ebp,%esp
  1013f9:	5d                   	pop    %ebp
  1013fa:	c3                   	ret    
  1013fb:	90                   	nop
  1013fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
  101400:	0f b7 43 12          	movzwl 0x12(%ebx),%eax
  101404:	66 83 f8 09          	cmp    $0x9,%ax
  101408:	77 df                	ja     1013e9 <readi+0x29>
  10140a:	98                   	cwtl   
  10140b:	8b 04 c5 80 ca 10 00 	mov    0x10ca80(,%eax,8),%eax
  101412:	85 c0                	test   %eax,%eax
  101414:	74 d3                	je     1013e9 <readi+0x29>
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  101416:	89 4d 10             	mov    %ecx,0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}
  101419:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10141c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10141f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101422:	89 ec                	mov    %ebp,%esp
  101424:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  101425:	ff e0                	jmp    *%eax
  101427:	90                   	nop
  }

  if(off > ip->size || off + n < off)
  101428:	89 ca                	mov    %ecx,%edx
  10142a:	01 f2                	add    %esi,%edx
  10142c:	72 bb                	jb     1013e9 <readi+0x29>
    return -1;
  if(off + n > ip->size)
  10142e:	39 d0                	cmp    %edx,%eax
  101430:	73 04                	jae    101436 <readi+0x76>
    n = ip->size - off;
  101432:	89 c1                	mov    %eax,%ecx
  101434:	29 f1                	sub    %esi,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  101436:	85 c9                	test   %ecx,%ecx
  101438:	74 7c                	je     1014b6 <readi+0xf6>
  10143a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
  101441:	89 7d e0             	mov    %edi,-0x20(%ebp)
  101444:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  101447:	90                   	nop
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  101448:	89 f2                	mov    %esi,%edx
  10144a:	89 d8                	mov    %ebx,%eax
  10144c:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  10144f:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  101454:	e8 b7 fe ff ff       	call   101310 <bmap>
  101459:	89 44 24 04          	mov    %eax,0x4(%esp)
  10145d:	8b 03                	mov    (%ebx),%eax
  10145f:	89 04 24             	mov    %eax,(%esp)
  101462:	e8 09 ed ff ff       	call   100170 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
  101467:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10146a:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  10146d:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  10146f:	89 f0                	mov    %esi,%eax
  101471:	25 ff 01 00 00       	and    $0x1ff,%eax
  101476:	29 c7                	sub    %eax,%edi
  101478:	39 cf                	cmp    %ecx,%edi
  10147a:	76 02                	jbe    10147e <readi+0xbe>
  10147c:	89 cf                	mov    %ecx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
  10147e:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  101482:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
  101484:	89 7c 24 08          	mov    %edi,0x8(%esp)
  101488:	89 44 24 04          	mov    %eax,0x4(%esp)
  10148c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10148f:	89 04 24             	mov    %eax,(%esp)
  101492:	89 55 d8             	mov    %edx,-0x28(%ebp)
  101495:	e8 a6 2a 00 00       	call   103f40 <memmove>
    brelse(bp);
  10149a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10149d:	89 14 24             	mov    %edx,(%esp)
  1014a0:	e8 1b ec ff ff       	call   1000c0 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  1014a5:	01 7d e4             	add    %edi,-0x1c(%ebp)
  1014a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1014ab:	01 7d e0             	add    %edi,-0x20(%ebp)
  1014ae:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1014b1:	77 95                	ja     101448 <readi+0x88>
  1014b3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
  1014b6:	89 c8                	mov    %ecx,%eax
  1014b8:	e9 31 ff ff ff       	jmp    1013ee <readi+0x2e>
  1014bd:	8d 76 00             	lea    0x0(%esi),%esi

001014c0 <iupdate>:
}

// Copy inode, which has changed, from memory to disk.
void
iupdate(struct inode *ip)
{
  1014c0:	55                   	push   %ebp
  1014c1:	89 e5                	mov    %esp,%ebp
  1014c3:	56                   	push   %esi
  1014c4:	53                   	push   %ebx
  1014c5:	83 ec 10             	sub    $0x10,%esp
  1014c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
  1014cb:	8b 43 04             	mov    0x4(%ebx),%eax
  1014ce:	c1 e8 03             	shr    $0x3,%eax
  1014d1:	83 c0 02             	add    $0x2,%eax
  1014d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1014d8:	8b 03                	mov    (%ebx),%eax
  1014da:	89 04 24             	mov    %eax,(%esp)
  1014dd:	e8 8e ec ff ff       	call   100170 <bread>
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  1014e2:	0f b7 53 10          	movzwl 0x10(%ebx),%edx
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
  1014e6:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  1014e8:	8b 43 04             	mov    0x4(%ebx),%eax
  1014eb:	83 e0 07             	and    $0x7,%eax
  1014ee:	c1 e0 06             	shl    $0x6,%eax
  1014f1:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
  dip->type = ip->type;
  1014f5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
  1014f8:	0f b7 53 12          	movzwl 0x12(%ebx),%edx
  1014fc:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
  101500:	0f b7 53 14          	movzwl 0x14(%ebx),%edx
  101504:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
  101508:	0f b7 53 16          	movzwl 0x16(%ebx),%edx
  10150c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
  101510:	8b 53 18             	mov    0x18(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  101513:	83 c3 1c             	add    $0x1c,%ebx
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  101516:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  101519:	83 c0 0c             	add    $0xc,%eax
  10151c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101520:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
  101527:	00 
  101528:	89 04 24             	mov    %eax,(%esp)
  10152b:	e8 10 2a 00 00       	call   103f40 <memmove>
  bwrite(bp);
  101530:	89 34 24             	mov    %esi,(%esp)
  101533:	e8 08 ec ff ff       	call   100140 <bwrite>
  brelse(bp);
  101538:	89 75 08             	mov    %esi,0x8(%ebp)
}
  10153b:	83 c4 10             	add    $0x10,%esp
  10153e:	5b                   	pop    %ebx
  10153f:	5e                   	pop    %esi
  101540:	5d                   	pop    %ebp
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  bwrite(bp);
  brelse(bp);
  101541:	e9 7a eb ff ff       	jmp    1000c0 <brelse>
  101546:	8d 76 00             	lea    0x0(%esi),%esi
  101549:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101550 <writei>:
}

// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
  101550:	55                   	push   %ebp
  101551:	89 e5                	mov    %esp,%ebp
  101553:	83 ec 38             	sub    $0x38,%esp
  101556:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  101559:	8b 5d 08             	mov    0x8(%ebp),%ebx
  10155c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10155f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  101562:	89 7d fc             	mov    %edi,-0x4(%ebp)
  101565:	8b 75 10             	mov    0x10(%ebp),%esi
  101568:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
  10156b:	66 83 7b 10 03       	cmpw   $0x3,0x10(%ebx)
  101570:	74 1e                	je     101590 <writei+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
  101572:	39 73 18             	cmp    %esi,0x18(%ebx)
  101575:	73 41                	jae    1015b8 <writei+0x68>

  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
  101577:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10157c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10157f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101582:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101585:	89 ec                	mov    %ebp,%esp
  101587:	5d                   	pop    %ebp
  101588:	c3                   	ret    
  101589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
  101590:	0f b7 43 12          	movzwl 0x12(%ebx),%eax
  101594:	66 83 f8 09          	cmp    $0x9,%ax
  101598:	77 dd                	ja     101577 <writei+0x27>
  10159a:	98                   	cwtl   
  10159b:	8b 04 c5 84 ca 10 00 	mov    0x10ca84(,%eax,8),%eax
  1015a2:	85 c0                	test   %eax,%eax
  1015a4:	74 d1                	je     101577 <writei+0x27>
      return -1;
    return devsw[ip->major].write(ip, src, n);
  1015a6:	89 4d 10             	mov    %ecx,0x10(%ebp)
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
  1015a9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1015ac:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1015af:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1015b2:	89 ec                	mov    %ebp,%esp
  1015b4:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  1015b5:	ff e0                	jmp    *%eax
  1015b7:	90                   	nop
  }

  if(off > ip->size || off + n < off)
  1015b8:	89 c8                	mov    %ecx,%eax
  1015ba:	01 f0                	add    %esi,%eax
  1015bc:	72 b9                	jb     101577 <writei+0x27>
    return -1;
  if(off + n > MAXFILE*BSIZE)
  1015be:	3d 00 18 01 00       	cmp    $0x11800,%eax
  1015c3:	76 07                	jbe    1015cc <writei+0x7c>
    n = MAXFILE*BSIZE - off;
  1015c5:	b9 00 18 01 00       	mov    $0x11800,%ecx
  1015ca:	29 f1                	sub    %esi,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  1015cc:	85 c9                	test   %ecx,%ecx
  1015ce:	0f 84 92 00 00 00    	je     101666 <writei+0x116>
  1015d4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
  1015db:	89 7d e0             	mov    %edi,-0x20(%ebp)
  1015de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  1015e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  1015e8:	89 f2                	mov    %esi,%edx
  1015ea:	89 d8                	mov    %ebx,%eax
  1015ec:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  1015ef:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  1015f4:	e8 17 fd ff ff       	call   101310 <bmap>
  1015f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1015fd:	8b 03                	mov    (%ebx),%eax
  1015ff:	89 04 24             	mov    %eax,(%esp)
  101602:	e8 69 eb ff ff       	call   100170 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
  101607:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10160a:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  10160d:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  10160f:	89 f0                	mov    %esi,%eax
  101611:	25 ff 01 00 00       	and    $0x1ff,%eax
  101616:	29 c7                	sub    %eax,%edi
  101618:	39 cf                	cmp    %ecx,%edi
  10161a:	76 02                	jbe    10161e <writei+0xce>
  10161c:	89 cf                	mov    %ecx,%edi
    memmove(bp->data + off%BSIZE, src, m);
  10161e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  101622:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  101625:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
  101629:	89 04 24             	mov    %eax,(%esp)
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  10162c:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(bp->data + off%BSIZE, src, m);
  10162e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  101632:	89 55 d8             	mov    %edx,-0x28(%ebp)
  101635:	e8 06 29 00 00       	call   103f40 <memmove>
    bwrite(bp);
  10163a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10163d:	89 14 24             	mov    %edx,(%esp)
  101640:	e8 fb ea ff ff       	call   100140 <bwrite>
    brelse(bp);
  101645:	8b 55 d8             	mov    -0x28(%ebp),%edx
  101648:	89 14 24             	mov    %edx,(%esp)
  10164b:	e8 70 ea ff ff       	call   1000c0 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  101650:	01 7d e4             	add    %edi,-0x1c(%ebp)
  101653:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101656:	01 7d e0             	add    %edi,-0x20(%ebp)
  101659:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10165c:	77 8a                	ja     1015e8 <writei+0x98>
    memmove(bp->data + off%BSIZE, src, m);
    bwrite(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
  10165e:	3b 73 18             	cmp    0x18(%ebx),%esi
  101661:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  101664:	77 07                	ja     10166d <writei+0x11d>
    ip->size = off;
    iupdate(ip);
  }
  return n;
  101666:	89 c8                	mov    %ecx,%eax
  101668:	e9 0f ff ff ff       	jmp    10157c <writei+0x2c>
    bwrite(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
    ip->size = off;
  10166d:	89 73 18             	mov    %esi,0x18(%ebx)
    iupdate(ip);
  101670:	89 1c 24             	mov    %ebx,(%esp)
  101673:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  101676:	e8 45 fe ff ff       	call   1014c0 <iupdate>
  10167b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  }
  return n;
  10167e:	89 c8                	mov    %ecx,%eax
  101680:	e9 f7 fe ff ff       	jmp    10157c <writei+0x2c>
  101685:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101689:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101690 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
  101690:	55                   	push   %ebp
  101691:	89 e5                	mov    %esp,%ebp
  101693:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
  101696:	8b 45 0c             	mov    0xc(%ebp),%eax
  101699:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  1016a0:	00 
  1016a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1016a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1016a8:	89 04 24             	mov    %eax,(%esp)
  1016ab:	e8 00 29 00 00       	call   103fb0 <strncmp>
}
  1016b0:	c9                   	leave  
  1016b1:	c3                   	ret    
  1016b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1016b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001016c0 <dirlookup>:
// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
  1016c0:	55                   	push   %ebp
  1016c1:	89 e5                	mov    %esp,%ebp
  1016c3:	57                   	push   %edi
  1016c4:	56                   	push   %esi
  1016c5:	53                   	push   %ebx
  1016c6:	83 ec 3c             	sub    $0x3c,%esp
  1016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1016cc:	8b 55 10             	mov    0x10(%ebp),%edx
  1016cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  1016d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1016d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  uint off, inum;
  struct buf *bp;
  struct dirent *de;

  if(dp->type != T_DIR)
  1016d8:	66 83 78 10 01       	cmpw   $0x1,0x10(%eax)
  1016dd:	0f 85 d0 00 00 00    	jne    1017b3 <dirlookup+0xf3>
    panic("dirlookup not DIR");
  1016e3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  for(off = 0; off < dp->size; off += BSIZE){
  1016ea:	8b 48 18             	mov    0x18(%eax),%ecx
  1016ed:	85 c9                	test   %ecx,%ecx
  1016ef:	0f 84 b4 00 00 00    	je     1017a9 <dirlookup+0xe9>
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
  1016f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1016f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1016fb:	c1 ea 09             	shr    $0x9,%edx
  1016fe:	e8 0d fc ff ff       	call   101310 <bmap>
  101703:	89 44 24 04          	mov    %eax,0x4(%esp)
  101707:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10170a:	8b 01                	mov    (%ecx),%eax
  10170c:	89 04 24             	mov    %eax,(%esp)
  10170f:	e8 5c ea ff ff       	call   100170 <bread>
  101714:	89 45 e4             	mov    %eax,-0x1c(%ebp)

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
  101717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
  10171a:	83 c0 18             	add    $0x18,%eax
  10171d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  101720:	89 c6                	mov    %eax,%esi

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
  101722:	81 c7 18 02 00 00    	add    $0x218,%edi
  101728:	eb 0d                	jmp    101737 <dirlookup+0x77>
  10172a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
        de < (struct dirent*)(bp->data + BSIZE);
        de++){
  101730:	83 c6 10             	add    $0x10,%esi
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
  101733:	39 fe                	cmp    %edi,%esi
  101735:	74 51                	je     101788 <dirlookup+0xc8>
        de < (struct dirent*)(bp->data + BSIZE);
        de++){
      if(de->inum == 0)
  101737:	66 83 3e 00          	cmpw   $0x0,(%esi)
  10173b:	74 f3                	je     101730 <dirlookup+0x70>
        continue;
      if(namecmp(name, de->name) == 0){
  10173d:	8d 46 02             	lea    0x2(%esi),%eax
  101740:	89 44 24 04          	mov    %eax,0x4(%esp)
  101744:	89 1c 24             	mov    %ebx,(%esp)
  101747:	e8 44 ff ff ff       	call   101690 <namecmp>
  10174c:	85 c0                	test   %eax,%eax
  10174e:	75 e0                	jne    101730 <dirlookup+0x70>
        // entry matches path element
        if(poff)
  101750:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  101753:	85 d2                	test   %edx,%edx
  101755:	74 0e                	je     101765 <dirlookup+0xa5>
          *poff = off + (uchar*)de - bp->data;
  101757:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10175a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10175d:	8d 04 16             	lea    (%esi,%edx,1),%eax
  101760:	2b 45 d8             	sub    -0x28(%ebp),%eax
  101763:	89 01                	mov    %eax,(%ecx)
        inum = de->inum;
        brelse(bp);
  101765:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        continue;
      if(namecmp(name, de->name) == 0){
        // entry matches path element
        if(poff)
          *poff = off + (uchar*)de - bp->data;
        inum = de->inum;
  101768:	0f b7 1e             	movzwl (%esi),%ebx
        brelse(bp);
  10176b:	89 04 24             	mov    %eax,(%esp)
  10176e:	e8 4d e9 ff ff       	call   1000c0 <brelse>
        return iget(dp->dev, inum);
  101773:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  101776:	89 da                	mov    %ebx,%edx
  101778:	8b 01                	mov    (%ecx),%eax
      }
    }
    brelse(bp);
  }
  return 0;
}
  10177a:	83 c4 3c             	add    $0x3c,%esp
  10177d:	5b                   	pop    %ebx
  10177e:	5e                   	pop    %esi
  10177f:	5f                   	pop    %edi
  101780:	5d                   	pop    %ebp
        // entry matches path element
        if(poff)
          *poff = off + (uchar*)de - bp->data;
        inum = de->inum;
        brelse(bp);
        return iget(dp->dev, inum);
  101781:	e9 aa f9 ff ff       	jmp    101130 <iget>
  101786:	66 90                	xchg   %ax,%ax
      }
    }
    brelse(bp);
  101788:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10178b:	89 04 24             	mov    %eax,(%esp)
  10178e:	e8 2d e9 ff ff       	call   1000c0 <brelse>
  struct dirent *de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
  101793:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101796:	81 45 e0 00 02 00 00 	addl   $0x200,-0x20(%ebp)
  10179d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1017a0:	39 4a 18             	cmp    %ecx,0x18(%edx)
  1017a3:	0f 87 4c ff ff ff    	ja     1016f5 <dirlookup+0x35>
      }
    }
    brelse(bp);
  }
  return 0;
}
  1017a9:	83 c4 3c             	add    $0x3c,%esp
  1017ac:	31 c0                	xor    %eax,%eax
  1017ae:	5b                   	pop    %ebx
  1017af:	5e                   	pop    %esi
  1017b0:	5f                   	pop    %edi
  1017b1:	5d                   	pop    %ebp
  1017b2:	c3                   	ret    
  uint off, inum;
  struct buf *bp;
  struct dirent *de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
  1017b3:	c7 04 24 44 68 10 00 	movl   $0x106844,(%esp)
  1017ba:	e8 b1 f1 ff ff       	call   100970 <panic>
  1017bf:	90                   	nop

001017c0 <iunlock>:
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  1017c0:	55                   	push   %ebp
  1017c1:	89 e5                	mov    %esp,%ebp
  1017c3:	53                   	push   %ebx
  1017c4:	83 ec 14             	sub    $0x14,%esp
  1017c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
  1017ca:	85 db                	test   %ebx,%ebx
  1017cc:	74 36                	je     101804 <iunlock+0x44>
  1017ce:	f6 43 0c 01          	testb  $0x1,0xc(%ebx)
  1017d2:	74 30                	je     101804 <iunlock+0x44>
  1017d4:	8b 43 08             	mov    0x8(%ebx),%eax
  1017d7:	85 c0                	test   %eax,%eax
  1017d9:	7e 29                	jle    101804 <iunlock+0x44>
    panic("iunlock");

  acquire(&icache.lock);
  1017db:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  1017e2:	e8 39 26 00 00       	call   103e20 <acquire>
  ip->flags &= ~I_BUSY;
  1017e7:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
  1017eb:	89 1c 24             	mov    %ebx,(%esp)
  1017ee:	e8 8d 19 00 00       	call   103180 <wakeup>
  release(&icache.lock);
  1017f3:	c7 45 08 e0 ca 10 00 	movl   $0x10cae0,0x8(%ebp)
}
  1017fa:	83 c4 14             	add    $0x14,%esp
  1017fd:	5b                   	pop    %ebx
  1017fe:	5d                   	pop    %ebp
    panic("iunlock");

  acquire(&icache.lock);
  ip->flags &= ~I_BUSY;
  wakeup(ip);
  release(&icache.lock);
  1017ff:	e9 cc 25 00 00       	jmp    103dd0 <release>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
    panic("iunlock");
  101804:	c7 04 24 56 68 10 00 	movl   $0x106856,(%esp)
  10180b:	e8 60 f1 ff ff       	call   100970 <panic>

00101810 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
  101810:	55                   	push   %ebp
  101811:	89 e5                	mov    %esp,%ebp
  101813:	57                   	push   %edi
  101814:	56                   	push   %esi
  101815:	89 c6                	mov    %eax,%esi
  101817:	53                   	push   %ebx
  101818:	89 d3                	mov    %edx,%ebx
  10181a:	83 ec 2c             	sub    $0x2c,%esp
static void
bzero(int dev, int bno)
{
  struct buf *bp;
  
  bp = bread(dev, bno);
  10181d:	89 54 24 04          	mov    %edx,0x4(%esp)
  101821:	89 04 24             	mov    %eax,(%esp)
  101824:	e8 47 e9 ff ff       	call   100170 <bread>
  memset(bp->data, 0, BSIZE);
  101829:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  101830:	00 
  101831:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101838:	00 
static void
bzero(int dev, int bno)
{
  struct buf *bp;
  
  bp = bread(dev, bno);
  101839:	89 c7                	mov    %eax,%edi
  memset(bp->data, 0, BSIZE);
  10183b:	8d 40 18             	lea    0x18(%eax),%eax
  10183e:	89 04 24             	mov    %eax,(%esp)
  101841:	e8 7a 26 00 00       	call   103ec0 <memset>
  bwrite(bp);
  101846:	89 3c 24             	mov    %edi,(%esp)
  101849:	e8 f2 e8 ff ff       	call   100140 <bwrite>
  brelse(bp);
  10184e:	89 3c 24             	mov    %edi,(%esp)
  101851:	e8 6a e8 ff ff       	call   1000c0 <brelse>
  struct superblock sb;
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  101856:	89 f0                	mov    %esi,%eax
  101858:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10185b:	e8 90 f9 ff ff       	call   1011f0 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  101860:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101863:	89 da                	mov    %ebx,%edx
  101865:	c1 ea 0c             	shr    $0xc,%edx
  101868:	89 34 24             	mov    %esi,(%esp)
  bi = b % BPB;
  m = 1 << (bi % 8);
  10186b:	be 01 00 00 00       	mov    $0x1,%esi
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  101870:	c1 e8 03             	shr    $0x3,%eax
  101873:	8d 44 10 03          	lea    0x3(%eax,%edx,1),%eax
  101877:	89 44 24 04          	mov    %eax,0x4(%esp)
  10187b:	e8 f0 e8 ff ff       	call   100170 <bread>
  bi = b % BPB;
  101880:	89 da                	mov    %ebx,%edx
  m = 1 << (bi % 8);
  101882:	89 d9                	mov    %ebx,%ecx

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  101884:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
  10188a:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
  10188d:	c1 fa 03             	sar    $0x3,%edx
  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  m = 1 << (bi % 8);
  101890:	d3 e6                	shl    %cl,%esi
  if((bp->data[bi/8] & m) == 0)
  101892:	0f b6 4c 10 18       	movzbl 0x18(%eax,%edx,1),%ecx
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  101897:	89 c7                	mov    %eax,%edi
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
  101899:	0f b6 c1             	movzbl %cl,%eax
  10189c:	85 f0                	test   %esi,%eax
  10189e:	74 22                	je     1018c2 <bfree+0xb2>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;  // Mark block free on disk.
  1018a0:	89 f0                	mov    %esi,%eax
  1018a2:	f7 d0                	not    %eax
  1018a4:	21 c8                	and    %ecx,%eax
  1018a6:	88 44 17 18          	mov    %al,0x18(%edi,%edx,1)
  bwrite(bp);
  1018aa:	89 3c 24             	mov    %edi,(%esp)
  1018ad:	e8 8e e8 ff ff       	call   100140 <bwrite>
  brelse(bp);
  1018b2:	89 3c 24             	mov    %edi,(%esp)
  1018b5:	e8 06 e8 ff ff       	call   1000c0 <brelse>
}
  1018ba:	83 c4 2c             	add    $0x2c,%esp
  1018bd:	5b                   	pop    %ebx
  1018be:	5e                   	pop    %esi
  1018bf:	5f                   	pop    %edi
  1018c0:	5d                   	pop    %ebp
  1018c1:	c3                   	ret    
  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
  1018c2:	c7 04 24 5e 68 10 00 	movl   $0x10685e,(%esp)
  1018c9:	e8 a2 f0 ff ff       	call   100970 <panic>
  1018ce:	66 90                	xchg   %ax,%ax

001018d0 <iput>:
}

// Caller holds reference to unlocked ip.  Drop reference.
void
iput(struct inode *ip)
{
  1018d0:	55                   	push   %ebp
  1018d1:	89 e5                	mov    %esp,%ebp
  1018d3:	57                   	push   %edi
  1018d4:	56                   	push   %esi
  1018d5:	53                   	push   %ebx
  1018d6:	83 ec 2c             	sub    $0x2c,%esp
  1018d9:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&icache.lock);
  1018dc:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  1018e3:	e8 38 25 00 00       	call   103e20 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
  1018e8:	8b 46 08             	mov    0x8(%esi),%eax
  1018eb:	83 f8 01             	cmp    $0x1,%eax
  1018ee:	0f 85 a1 00 00 00    	jne    101995 <iput+0xc5>
  1018f4:	8b 56 0c             	mov    0xc(%esi),%edx
  1018f7:	f6 c2 02             	test   $0x2,%dl
  1018fa:	0f 84 95 00 00 00    	je     101995 <iput+0xc5>
  101900:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  101905:	0f 85 8a 00 00 00    	jne    101995 <iput+0xc5>
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
  10190b:	f6 c2 01             	test   $0x1,%dl
  10190e:	66 90                	xchg   %ax,%ax
  101910:	0f 85 f8 00 00 00    	jne    101a0e <iput+0x13e>
      panic("iput busy");
    ip->flags |= I_BUSY;
  101916:	83 ca 01             	or     $0x1,%edx
    release(&icache.lock);
  101919:	89 f3                	mov    %esi,%ebx
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
  10191b:	89 56 0c             	mov    %edx,0xc(%esi)
  release(&icache.lock);
}

// Caller holds reference to unlocked ip.  Drop reference.
void
iput(struct inode *ip)
  10191e:	8d 7e 30             	lea    0x30(%esi),%edi
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
  101921:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  101928:	e8 a3 24 00 00       	call   103dd0 <release>
  10192d:	eb 08                	jmp    101937 <iput+0x67>
  10192f:	90                   	nop
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
  101930:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
  101933:	39 fb                	cmp    %edi,%ebx
  101935:	74 1c                	je     101953 <iput+0x83>
    if(ip->addrs[i]){
  101937:	8b 53 1c             	mov    0x1c(%ebx),%edx
  10193a:	85 d2                	test   %edx,%edx
  10193c:	74 f2                	je     101930 <iput+0x60>
      bfree(ip->dev, ip->addrs[i]);
  10193e:	8b 06                	mov    (%esi),%eax
  101940:	e8 cb fe ff ff       	call   101810 <bfree>
      ip->addrs[i] = 0;
  101945:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
  10194c:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
  10194f:	39 fb                	cmp    %edi,%ebx
  101951:	75 e4                	jne    101937 <iput+0x67>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
  101953:	8b 46 4c             	mov    0x4c(%esi),%eax
  101956:	85 c0                	test   %eax,%eax
  101958:	75 56                	jne    1019b0 <iput+0xe0>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  10195a:	c7 46 18 00 00 00 00 	movl   $0x0,0x18(%esi)
  iupdate(ip);
  101961:	89 34 24             	mov    %esi,(%esp)
  101964:	e8 57 fb ff ff       	call   1014c0 <iupdate>
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
    itrunc(ip);
    ip->type = 0;
  101969:	66 c7 46 10 00 00    	movw   $0x0,0x10(%esi)
    iupdate(ip);
  10196f:	89 34 24             	mov    %esi,(%esp)
  101972:	e8 49 fb ff ff       	call   1014c0 <iupdate>
    acquire(&icache.lock);
  101977:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  10197e:	e8 9d 24 00 00       	call   103e20 <acquire>
    ip->flags = 0;
  101983:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
  10198a:	89 34 24             	mov    %esi,(%esp)
  10198d:	e8 ee 17 00 00       	call   103180 <wakeup>
  101992:	8b 46 08             	mov    0x8(%esi),%eax
  }
  ip->ref--;
  101995:	83 e8 01             	sub    $0x1,%eax
  101998:	89 46 08             	mov    %eax,0x8(%esi)
  release(&icache.lock);
  10199b:	c7 45 08 e0 ca 10 00 	movl   $0x10cae0,0x8(%ebp)
}
  1019a2:	83 c4 2c             	add    $0x2c,%esp
  1019a5:	5b                   	pop    %ebx
  1019a6:	5e                   	pop    %esi
  1019a7:	5f                   	pop    %edi
  1019a8:	5d                   	pop    %ebp
    acquire(&icache.lock);
    ip->flags = 0;
    wakeup(ip);
  }
  ip->ref--;
  release(&icache.lock);
  1019a9:	e9 22 24 00 00       	jmp    103dd0 <release>
  1019ae:	66 90                	xchg   %ax,%ax
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  1019b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019b4:	8b 06                	mov    (%esi),%eax
    a = (uint*)bp->data;
  1019b6:	31 db                	xor    %ebx,%ebx
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  1019b8:	89 04 24             	mov    %eax,(%esp)
  1019bb:	e8 b0 e7 ff ff       	call   100170 <bread>
    a = (uint*)bp->data;
  1019c0:	89 c7                	mov    %eax,%edi
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  1019c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
  1019c5:	83 c7 18             	add    $0x18,%edi
  1019c8:	31 c0                	xor    %eax,%eax
  1019ca:	eb 11                	jmp    1019dd <iput+0x10d>
  1019cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(j = 0; j < NINDIRECT; j++){
  1019d0:	83 c3 01             	add    $0x1,%ebx
  1019d3:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  1019d9:	89 d8                	mov    %ebx,%eax
  1019db:	74 10                	je     1019ed <iput+0x11d>
      if(a[j])
  1019dd:	8b 14 87             	mov    (%edi,%eax,4),%edx
  1019e0:	85 d2                	test   %edx,%edx
  1019e2:	74 ec                	je     1019d0 <iput+0x100>
        bfree(ip->dev, a[j]);
  1019e4:	8b 06                	mov    (%esi),%eax
  1019e6:	e8 25 fe ff ff       	call   101810 <bfree>
  1019eb:	eb e3                	jmp    1019d0 <iput+0x100>
    }
    brelse(bp);
  1019ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1019f0:	89 04 24             	mov    %eax,(%esp)
  1019f3:	e8 c8 e6 ff ff       	call   1000c0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
  1019f8:	8b 56 4c             	mov    0x4c(%esi),%edx
  1019fb:	8b 06                	mov    (%esi),%eax
  1019fd:	e8 0e fe ff ff       	call   101810 <bfree>
    ip->addrs[NDIRECT] = 0;
  101a02:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  101a09:	e9 4c ff ff ff       	jmp    10195a <iput+0x8a>
{
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
  101a0e:	c7 04 24 71 68 10 00 	movl   $0x106871,(%esp)
  101a15:	e8 56 ef ff ff       	call   100970 <panic>
  101a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00101a20 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
  101a20:	55                   	push   %ebp
  101a21:	89 e5                	mov    %esp,%ebp
  101a23:	57                   	push   %edi
  101a24:	56                   	push   %esi
  101a25:	53                   	push   %ebx
  101a26:	83 ec 2c             	sub    $0x2c,%esp
  101a29:	8b 75 08             	mov    0x8(%ebp),%esi
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
  101a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  101a2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  101a36:	00 
  101a37:	89 34 24             	mov    %esi,(%esp)
  101a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a3e:	e8 7d fc ff ff       	call   1016c0 <dirlookup>
  101a43:	85 c0                	test   %eax,%eax
  101a45:	0f 85 89 00 00 00    	jne    101ad4 <dirlink+0xb4>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101a4b:	8b 56 18             	mov    0x18(%esi),%edx
  101a4e:	85 d2                	test   %edx,%edx
  101a50:	0f 84 8d 00 00 00    	je     101ae3 <dirlink+0xc3>
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
    return -1;
  101a56:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101a59:	31 db                	xor    %ebx,%ebx
  101a5b:	eb 0b                	jmp    101a68 <dirlink+0x48>
  101a5d:	8d 76 00             	lea    0x0(%esi),%esi
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101a60:	83 c3 10             	add    $0x10,%ebx
  101a63:	39 5e 18             	cmp    %ebx,0x18(%esi)
  101a66:	76 24                	jbe    101a8c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101a68:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101a6f:	00 
  101a70:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101a74:	89 7c 24 04          	mov    %edi,0x4(%esp)
  101a78:	89 34 24             	mov    %esi,(%esp)
  101a7b:	e8 40 f9 ff ff       	call   1013c0 <readi>
  101a80:	83 f8 10             	cmp    $0x10,%eax
  101a83:	75 65                	jne    101aea <dirlink+0xca>
      panic("dirlink read");
    if(de.inum == 0)
  101a85:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
  101a8a:	75 d4                	jne    101a60 <dirlink+0x40>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  101a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  101a8f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101a96:	00 
  101a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9b:	8d 45 da             	lea    -0x26(%ebp),%eax
  101a9e:	89 04 24             	mov    %eax,(%esp)
  101aa1:	e8 6a 25 00 00       	call   104010 <strncpy>
  de.inum = inum;
  101aa6:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101aa9:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101ab0:	00 
  101ab1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101ab5:	89 7c 24 04          	mov    %edi,0x4(%esp)
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  101ab9:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101abd:	89 34 24             	mov    %esi,(%esp)
  101ac0:	e8 8b fa ff ff       	call   101550 <writei>
  101ac5:	83 f8 10             	cmp    $0x10,%eax
  101ac8:	75 2c                	jne    101af6 <dirlink+0xd6>
    panic("dirlink");
  101aca:	31 c0                	xor    %eax,%eax
  
  return 0;
}
  101acc:	83 c4 2c             	add    $0x2c,%esp
  101acf:	5b                   	pop    %ebx
  101ad0:	5e                   	pop    %esi
  101ad1:	5f                   	pop    %edi
  101ad2:	5d                   	pop    %ebp
  101ad3:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
  101ad4:	89 04 24             	mov    %eax,(%esp)
  101ad7:	e8 f4 fd ff ff       	call   1018d0 <iput>
  101adc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  101ae1:	eb e9                	jmp    101acc <dirlink+0xac>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101ae3:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101ae6:	31 db                	xor    %ebx,%ebx
  101ae8:	eb a2                	jmp    101a8c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
  101aea:	c7 04 24 7b 68 10 00 	movl   $0x10687b,(%esp)
  101af1:	e8 7a ee ff ff       	call   100970 <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
  101af6:	c7 04 24 e2 6e 10 00 	movl   $0x106ee2,(%esp)
  101afd:	e8 6e ee ff ff       	call   100970 <panic>
  101b02:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  101b09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101b10 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  101b10:	55                   	push   %ebp
  101b11:	89 e5                	mov    %esp,%ebp
  101b13:	53                   	push   %ebx
  101b14:	83 ec 14             	sub    $0x14,%esp
  101b17:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
  101b1a:	89 1c 24             	mov    %ebx,(%esp)
  101b1d:	e8 9e fc ff ff       	call   1017c0 <iunlock>
  iput(ip);
  101b22:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  101b25:	83 c4 14             	add    $0x14,%esp
  101b28:	5b                   	pop    %ebx
  101b29:	5d                   	pop    %ebp
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
  101b2a:	e9 a1 fd ff ff       	jmp    1018d0 <iput>
  101b2f:	90                   	nop

00101b30 <ialloc>:
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101b30:	55                   	push   %ebp
  101b31:	89 e5                	mov    %esp,%ebp
  101b33:	57                   	push   %edi
  101b34:	56                   	push   %esi
  101b35:	53                   	push   %ebx
  101b36:	83 ec 3c             	sub    $0x3c,%esp
  101b39:	0f b7 45 0c          	movzwl 0xc(%ebp),%eax
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101b3d:	8d 55 dc             	lea    -0x24(%ebp),%edx
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101b40:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101b44:	8b 45 08             	mov    0x8(%ebp),%eax
  101b47:	e8 a4 f6 ff ff       	call   1011f0 <readsb>
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b4c:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
  101b50:	0f 86 96 00 00 00    	jbe    101bec <ialloc+0xbc>
  101b56:	be 01 00 00 00       	mov    $0x1,%esi
  101b5b:	bb 01 00 00 00       	mov    $0x1,%ebx
  101b60:	eb 18                	jmp    101b7a <ialloc+0x4a>
  101b62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101b68:	83 c3 01             	add    $0x1,%ebx
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101b6b:	89 3c 24             	mov    %edi,(%esp)
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b6e:	89 de                	mov    %ebx,%esi
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101b70:	e8 4b e5 ff ff       	call   1000c0 <brelse>
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b75:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  101b78:	76 72                	jbe    101bec <ialloc+0xbc>
    bp = bread(dev, IBLOCK(inum));
  101b7a:	89 f0                	mov    %esi,%eax
  101b7c:	c1 e8 03             	shr    $0x3,%eax
  101b7f:	83 c0 02             	add    $0x2,%eax
  101b82:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b86:	8b 45 08             	mov    0x8(%ebp),%eax
  101b89:	89 04 24             	mov    %eax,(%esp)
  101b8c:	e8 df e5 ff ff       	call   100170 <bread>
  101b91:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
  101b93:	89 f0                	mov    %esi,%eax
  101b95:	83 e0 07             	and    $0x7,%eax
  101b98:	c1 e0 06             	shl    $0x6,%eax
  101b9b:	8d 54 07 18          	lea    0x18(%edi,%eax,1),%edx
    if(dip->type == 0){  // a free inode
  101b9f:	66 83 3a 00          	cmpw   $0x0,(%edx)
  101ba3:	75 c3                	jne    101b68 <ialloc+0x38>
      memset(dip, 0, sizeof(*dip));
  101ba5:	89 14 24             	mov    %edx,(%esp)
  101ba8:	89 55 d0             	mov    %edx,-0x30(%ebp)
  101bab:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
  101bb2:	00 
  101bb3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101bba:	00 
  101bbb:	e8 00 23 00 00       	call   103ec0 <memset>
      dip->type = type;
  101bc0:	8b 55 d0             	mov    -0x30(%ebp),%edx
  101bc3:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101bc7:	66 89 02             	mov    %ax,(%edx)
      bwrite(bp);   // mark it allocated on the disk
  101bca:	89 3c 24             	mov    %edi,(%esp)
  101bcd:	e8 6e e5 ff ff       	call   100140 <bwrite>
      brelse(bp);
  101bd2:	89 3c 24             	mov    %edi,(%esp)
  101bd5:	e8 e6 e4 ff ff       	call   1000c0 <brelse>
      return iget(dev, inum);
  101bda:	8b 45 08             	mov    0x8(%ebp),%eax
  101bdd:	89 f2                	mov    %esi,%edx
  101bdf:	e8 4c f5 ff ff       	call   101130 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
  101be4:	83 c4 3c             	add    $0x3c,%esp
  101be7:	5b                   	pop    %ebx
  101be8:	5e                   	pop    %esi
  101be9:	5f                   	pop    %edi
  101bea:	5d                   	pop    %ebp
  101beb:	c3                   	ret    
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
  101bec:	c7 04 24 88 68 10 00 	movl   $0x106888,(%esp)
  101bf3:	e8 78 ed ff ff       	call   100970 <panic>
  101bf8:	90                   	nop
  101bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00101c00 <ilock>:
}

// Lock the given inode.
void
ilock(struct inode *ip)
{
  101c00:	55                   	push   %ebp
  101c01:	89 e5                	mov    %esp,%ebp
  101c03:	56                   	push   %esi
  101c04:	53                   	push   %ebx
  101c05:	83 ec 10             	sub    $0x10,%esp
  101c08:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
  101c0b:	85 db                	test   %ebx,%ebx
  101c0d:	0f 84 e5 00 00 00    	je     101cf8 <ilock+0xf8>
  101c13:	8b 4b 08             	mov    0x8(%ebx),%ecx
  101c16:	85 c9                	test   %ecx,%ecx
  101c18:	0f 8e da 00 00 00    	jle    101cf8 <ilock+0xf8>
    panic("ilock");

  acquire(&icache.lock);
  101c1e:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  101c25:	e8 f6 21 00 00       	call   103e20 <acquire>
  while(ip->flags & I_BUSY)
  101c2a:	8b 43 0c             	mov    0xc(%ebx),%eax
  101c2d:	a8 01                	test   $0x1,%al
  101c2f:	74 1e                	je     101c4f <ilock+0x4f>
  101c31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sleep(ip, &icache.lock);
  101c38:	c7 44 24 04 e0 ca 10 	movl   $0x10cae0,0x4(%esp)
  101c3f:	00 
  101c40:	89 1c 24             	mov    %ebx,(%esp)
  101c43:	e8 68 16 00 00       	call   1032b0 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
  101c48:	8b 43 0c             	mov    0xc(%ebx),%eax
  101c4b:	a8 01                	test   $0x1,%al
  101c4d:	75 e9                	jne    101c38 <ilock+0x38>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  101c4f:	83 c8 01             	or     $0x1,%eax
  101c52:	89 43 0c             	mov    %eax,0xc(%ebx)
  release(&icache.lock);
  101c55:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  101c5c:	e8 6f 21 00 00       	call   103dd0 <release>

  if(!(ip->flags & I_VALID)){
  101c61:	f6 43 0c 02          	testb  $0x2,0xc(%ebx)
  101c65:	74 09                	je     101c70 <ilock+0x70>
    brelse(bp);
    ip->flags |= I_VALID;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
  101c67:	83 c4 10             	add    $0x10,%esp
  101c6a:	5b                   	pop    %ebx
  101c6b:	5e                   	pop    %esi
  101c6c:	5d                   	pop    %ebp
  101c6d:	c3                   	ret    
  101c6e:	66 90                	xchg   %ax,%ax
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  release(&icache.lock);

  if(!(ip->flags & I_VALID)){
    bp = bread(ip->dev, IBLOCK(ip->inum));
  101c70:	8b 43 04             	mov    0x4(%ebx),%eax
  101c73:	c1 e8 03             	shr    $0x3,%eax
  101c76:	83 c0 02             	add    $0x2,%eax
  101c79:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7d:	8b 03                	mov    (%ebx),%eax
  101c7f:	89 04 24             	mov    %eax,(%esp)
  101c82:	e8 e9 e4 ff ff       	call   100170 <bread>
  101c87:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
  101c89:	8b 43 04             	mov    0x4(%ebx),%eax
  101c8c:	83 e0 07             	and    $0x7,%eax
  101c8f:	c1 e0 06             	shl    $0x6,%eax
  101c92:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
    ip->type = dip->type;
  101c96:	0f b7 10             	movzwl (%eax),%edx
  101c99:	66 89 53 10          	mov    %dx,0x10(%ebx)
    ip->major = dip->major;
  101c9d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
  101ca1:	66 89 53 12          	mov    %dx,0x12(%ebx)
    ip->minor = dip->minor;
  101ca5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
  101ca9:	66 89 53 14          	mov    %dx,0x14(%ebx)
    ip->nlink = dip->nlink;
  101cad:	0f b7 50 06          	movzwl 0x6(%eax),%edx
  101cb1:	66 89 53 16          	mov    %dx,0x16(%ebx)
    ip->size = dip->size;
  101cb5:	8b 50 08             	mov    0x8(%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101cb8:	83 c0 0c             	add    $0xc,%eax
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
  101cbb:	89 53 18             	mov    %edx,0x18(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc2:	8d 43 1c             	lea    0x1c(%ebx),%eax
  101cc5:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
  101ccc:	00 
  101ccd:	89 04 24             	mov    %eax,(%esp)
  101cd0:	e8 6b 22 00 00       	call   103f40 <memmove>
    brelse(bp);
  101cd5:	89 34 24             	mov    %esi,(%esp)
  101cd8:	e8 e3 e3 ff ff       	call   1000c0 <brelse>
    ip->flags |= I_VALID;
  101cdd:	83 4b 0c 02          	orl    $0x2,0xc(%ebx)
    if(ip->type == 0)
  101ce1:	66 83 7b 10 00       	cmpw   $0x0,0x10(%ebx)
  101ce6:	0f 85 7b ff ff ff    	jne    101c67 <ilock+0x67>
      panic("ilock: no type");
  101cec:	c7 04 24 a0 68 10 00 	movl   $0x1068a0,(%esp)
  101cf3:	e8 78 ec ff ff       	call   100970 <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
  101cf8:	c7 04 24 9a 68 10 00 	movl   $0x10689a,(%esp)
  101cff:	e8 6c ec ff ff       	call   100970 <panic>
  101d04:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101d0a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00101d10 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
  101d10:	55                   	push   %ebp
  101d11:	89 e5                	mov    %esp,%ebp
  101d13:	57                   	push   %edi
  101d14:	56                   	push   %esi
  101d15:	53                   	push   %ebx
  101d16:	89 c3                	mov    %eax,%ebx
  101d18:	83 ec 2c             	sub    $0x2c,%esp
  101d1b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  101d1e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
  101d21:	80 38 2f             	cmpb   $0x2f,(%eax)
  101d24:	0f 84 14 01 00 00    	je     101e3e <namex+0x12e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
  101d2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  101d30:	8b 40 68             	mov    0x68(%eax),%eax
  101d33:	89 04 24             	mov    %eax,(%esp)
  101d36:	e8 c5 f3 ff ff       	call   101100 <idup>
  101d3b:	89 c7                	mov    %eax,%edi
  101d3d:	eb 04                	jmp    101d43 <namex+0x33>
  101d3f:	90                   	nop
{
  char *s;
  int len;

  while(*path == '/')
    path++;
  101d40:	83 c3 01             	add    $0x1,%ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
  101d43:	0f b6 03             	movzbl (%ebx),%eax
  101d46:	3c 2f                	cmp    $0x2f,%al
  101d48:	74 f6                	je     101d40 <namex+0x30>
    path++;
  if(*path == 0)
  101d4a:	84 c0                	test   %al,%al
  101d4c:	75 1a                	jne    101d68 <namex+0x58>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
  101d4e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  101d51:	85 db                	test   %ebx,%ebx
  101d53:	0f 85 0d 01 00 00    	jne    101e66 <namex+0x156>
    iput(ip);
    return 0;
  }
  return ip;
}
  101d59:	83 c4 2c             	add    $0x2c,%esp
  101d5c:	89 f8                	mov    %edi,%eax
  101d5e:	5b                   	pop    %ebx
  101d5f:	5e                   	pop    %esi
  101d60:	5f                   	pop    %edi
  101d61:	5d                   	pop    %ebp
  101d62:	c3                   	ret    
  101d63:	90                   	nop
  101d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101d68:	3c 2f                	cmp    $0x2f,%al
  101d6a:	0f 84 94 00 00 00    	je     101e04 <namex+0xf4>
  101d70:	89 de                	mov    %ebx,%esi
  101d72:	eb 08                	jmp    101d7c <namex+0x6c>
  101d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101d78:	3c 2f                	cmp    $0x2f,%al
  101d7a:	74 0a                	je     101d86 <namex+0x76>
    path++;
  101d7c:	83 c6 01             	add    $0x1,%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101d7f:	0f b6 06             	movzbl (%esi),%eax
  101d82:	84 c0                	test   %al,%al
  101d84:	75 f2                	jne    101d78 <namex+0x68>
  101d86:	89 f2                	mov    %esi,%edx
  101d88:	29 da                	sub    %ebx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
  101d8a:	83 fa 0d             	cmp    $0xd,%edx
  101d8d:	7e 79                	jle    101e08 <namex+0xf8>
    memmove(name, s, DIRSIZ);
  101d8f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101d96:	00 
  101d97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101d9e:	89 04 24             	mov    %eax,(%esp)
  101da1:	e8 9a 21 00 00       	call   103f40 <memmove>
  101da6:	eb 03                	jmp    101dab <namex+0x9b>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
    path++;
  101da8:	83 c6 01             	add    $0x1,%esi
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101dab:	80 3e 2f             	cmpb   $0x2f,(%esi)
  101dae:	74 f8                	je     101da8 <namex+0x98>
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
  101db0:	85 f6                	test   %esi,%esi
  101db2:	74 9a                	je     101d4e <namex+0x3e>
    ilock(ip);
  101db4:	89 3c 24             	mov    %edi,(%esp)
  101db7:	e8 44 fe ff ff       	call   101c00 <ilock>
    if(ip->type != T_DIR){
  101dbc:	66 83 7f 10 01       	cmpw   $0x1,0x10(%edi)
  101dc1:	75 67                	jne    101e2a <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
  101dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101dc6:	85 c0                	test   %eax,%eax
  101dc8:	74 0c                	je     101dd6 <namex+0xc6>
  101dca:	80 3e 00             	cmpb   $0x0,(%esi)
  101dcd:	8d 76 00             	lea    0x0(%esi),%esi
  101dd0:	0f 84 7e 00 00 00    	je     101e54 <namex+0x144>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
  101dd6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  101ddd:	00 
  101dde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101de1:	89 3c 24             	mov    %edi,(%esp)
  101de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101de8:	e8 d3 f8 ff ff       	call   1016c0 <dirlookup>
  101ded:	85 c0                	test   %eax,%eax
  101def:	89 c3                	mov    %eax,%ebx
  101df1:	74 37                	je     101e2a <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
  101df3:	89 3c 24             	mov    %edi,(%esp)
  101df6:	89 df                	mov    %ebx,%edi
  101df8:	89 f3                	mov    %esi,%ebx
  101dfa:	e8 11 fd ff ff       	call   101b10 <iunlockput>
  101dff:	e9 3f ff ff ff       	jmp    101d43 <namex+0x33>
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101e04:	89 de                	mov    %ebx,%esi
  101e06:	31 d2                	xor    %edx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
  101e08:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101e13:	89 04 24             	mov    %eax,(%esp)
  101e16:	89 55 dc             	mov    %edx,-0x24(%ebp)
  101e19:	e8 22 21 00 00       	call   103f40 <memmove>
    name[len] = 0;
  101e1e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101e21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101e24:	c6 04 10 00          	movb   $0x0,(%eax,%edx,1)
  101e28:	eb 81                	jmp    101dab <namex+0x9b>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
  101e2a:	89 3c 24             	mov    %edi,(%esp)
  101e2d:	31 ff                	xor    %edi,%edi
  101e2f:	e8 dc fc ff ff       	call   101b10 <iunlockput>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101e34:	83 c4 2c             	add    $0x2c,%esp
  101e37:	89 f8                	mov    %edi,%eax
  101e39:	5b                   	pop    %ebx
  101e3a:	5e                   	pop    %esi
  101e3b:	5f                   	pop    %edi
  101e3c:	5d                   	pop    %ebp
  101e3d:	c3                   	ret    
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  101e3e:	ba 01 00 00 00       	mov    $0x1,%edx
  101e43:	b8 01 00 00 00       	mov    $0x1,%eax
  101e48:	e8 e3 f2 ff ff       	call   101130 <iget>
  101e4d:	89 c7                	mov    %eax,%edi
  101e4f:	e9 ef fe ff ff       	jmp    101d43 <namex+0x33>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
  101e54:	89 3c 24             	mov    %edi,(%esp)
  101e57:	e8 64 f9 ff ff       	call   1017c0 <iunlock>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101e5c:	83 c4 2c             	add    $0x2c,%esp
  101e5f:	89 f8                	mov    %edi,%eax
  101e61:	5b                   	pop    %ebx
  101e62:	5e                   	pop    %esi
  101e63:	5f                   	pop    %edi
  101e64:	5d                   	pop    %ebp
  101e65:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
  101e66:	89 3c 24             	mov    %edi,(%esp)
  101e69:	31 ff                	xor    %edi,%edi
  101e6b:	e8 60 fa ff ff       	call   1018d0 <iput>
    return 0;
  101e70:	e9 e4 fe ff ff       	jmp    101d59 <namex+0x49>
  101e75:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101e80 <nameiparent>:
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101e80:	55                   	push   %ebp
  return namex(path, 1, name);
  101e81:	ba 01 00 00 00       	mov    $0x1,%edx
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101e86:	89 e5                	mov    %esp,%ebp
  101e88:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
  101e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  101e91:	c9                   	leave  
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
  101e92:	e9 79 fe ff ff       	jmp    101d10 <namex>
  101e97:	89 f6                	mov    %esi,%esi
  101e99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101ea0 <namei>:
  return ip;
}

struct inode*
namei(char *path)
{
  101ea0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101ea1:	31 d2                	xor    %edx,%edx
  return ip;
}

struct inode*
namei(char *path)
{
  101ea3:	89 e5                	mov    %esp,%ebp
  101ea5:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  101eab:	8d 4d ea             	lea    -0x16(%ebp),%ecx
  101eae:	e8 5d fe ff ff       	call   101d10 <namex>
}
  101eb3:	c9                   	leave  
  101eb4:	c3                   	ret    
  101eb5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101ec0 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
  101ec0:	55                   	push   %ebp
  101ec1:	89 e5                	mov    %esp,%ebp
  101ec3:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
  101ec6:	c7 44 24 04 af 68 10 	movl   $0x1068af,0x4(%esp)
  101ecd:	00 
  101ece:	c7 04 24 e0 ca 10 00 	movl   $0x10cae0,(%esp)
  101ed5:	e8 b6 1d 00 00       	call   103c90 <initlock>
}
  101eda:	c9                   	leave  
  101edb:	c3                   	ret    
  101edc:	90                   	nop
  101edd:	90                   	nop
  101ede:	90                   	nop
  101edf:	90                   	nop

00101ee0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  101ee0:	55                   	push   %ebp
  101ee1:	89 e5                	mov    %esp,%ebp
  101ee3:	56                   	push   %esi
  101ee4:	89 c6                	mov    %eax,%esi
  101ee6:	83 ec 14             	sub    $0x14,%esp
  if(b == 0)
  101ee9:	85 c0                	test   %eax,%eax
  101eeb:	0f 84 8d 00 00 00    	je     101f7e <idestart+0x9e>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  101ef1:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101ef6:	66 90                	xchg   %ax,%ax
  101ef8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  101ef9:	25 c0 00 00 00       	and    $0xc0,%eax
  101efe:	83 f8 40             	cmp    $0x40,%eax
  101f01:	75 f5                	jne    101ef8 <idestart+0x18>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  101f03:	ba f6 03 00 00       	mov    $0x3f6,%edx
  101f08:	31 c0                	xor    %eax,%eax
  101f0a:	ee                   	out    %al,(%dx)
  101f0b:	ba f2 01 00 00       	mov    $0x1f2,%edx
  101f10:	b8 01 00 00 00       	mov    $0x1,%eax
  101f15:	ee                   	out    %al,(%dx)
    panic("idestart");

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, 1);  // number of sectors
  outb(0x1f3, b->sector & 0xff);
  101f16:	8b 4e 08             	mov    0x8(%esi),%ecx
  101f19:	b2 f3                	mov    $0xf3,%dl
  101f1b:	89 c8                	mov    %ecx,%eax
  101f1d:	ee                   	out    %al,(%dx)
  101f1e:	89 c8                	mov    %ecx,%eax
  101f20:	b2 f4                	mov    $0xf4,%dl
  101f22:	c1 e8 08             	shr    $0x8,%eax
  101f25:	ee                   	out    %al,(%dx)
  101f26:	89 c8                	mov    %ecx,%eax
  101f28:	b2 f5                	mov    $0xf5,%dl
  101f2a:	c1 e8 10             	shr    $0x10,%eax
  101f2d:	ee                   	out    %al,(%dx)
  101f2e:	8b 46 04             	mov    0x4(%esi),%eax
  101f31:	c1 e9 18             	shr    $0x18,%ecx
  101f34:	b2 f6                	mov    $0xf6,%dl
  101f36:	83 e1 0f             	and    $0xf,%ecx
  101f39:	83 e0 01             	and    $0x1,%eax
  101f3c:	c1 e0 04             	shl    $0x4,%eax
  101f3f:	09 c8                	or     %ecx,%eax
  101f41:	83 c8 e0             	or     $0xffffffe0,%eax
  101f44:	ee                   	out    %al,(%dx)
  outb(0x1f4, (b->sector >> 8) & 0xff);
  outb(0x1f5, (b->sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
  101f45:	f6 06 04             	testb  $0x4,(%esi)
  101f48:	75 16                	jne    101f60 <idestart+0x80>
  101f4a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101f4f:	b8 20 00 00 00       	mov    $0x20,%eax
  101f54:	ee                   	out    %al,(%dx)
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
  101f55:	83 c4 14             	add    $0x14,%esp
  101f58:	5e                   	pop    %esi
  101f59:	5d                   	pop    %ebp
  101f5a:	c3                   	ret    
  101f5b:	90                   	nop
  101f5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101f60:	b2 f7                	mov    $0xf7,%dl
  101f62:	b8 30 00 00 00       	mov    $0x30,%eax
  101f67:	ee                   	out    %al,(%dx)
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
  101f68:	b9 80 00 00 00       	mov    $0x80,%ecx
  101f6d:	83 c6 18             	add    $0x18,%esi
  101f70:	ba f0 01 00 00       	mov    $0x1f0,%edx
  101f75:	fc                   	cld    
  101f76:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  101f78:	83 c4 14             	add    $0x14,%esp
  101f7b:	5e                   	pop    %esi
  101f7c:	5d                   	pop    %ebp
  101f7d:	c3                   	ret    
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  101f7e:	c7 04 24 b6 68 10 00 	movl   $0x1068b6,(%esp)
  101f85:	e8 e6 e9 ff ff       	call   100970 <panic>
  101f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00101f90 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
  101f90:	55                   	push   %ebp
  101f91:	89 e5                	mov    %esp,%ebp
  101f93:	53                   	push   %ebx
  101f94:	83 ec 14             	sub    $0x14,%esp
  101f97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!(b->flags & B_BUSY))
  101f9a:	8b 03                	mov    (%ebx),%eax
  101f9c:	a8 01                	test   $0x1,%al
  101f9e:	0f 84 90 00 00 00    	je     102034 <iderw+0xa4>
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
  101fa4:	83 e0 06             	and    $0x6,%eax
  101fa7:	83 f8 02             	cmp    $0x2,%eax
  101faa:	0f 84 9c 00 00 00    	je     10204c <iderw+0xbc>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
  101fb0:	8b 53 04             	mov    0x4(%ebx),%edx
  101fb3:	85 d2                	test   %edx,%edx
  101fb5:	74 0d                	je     101fc4 <iderw+0x34>
  101fb7:	a1 b8 98 10 00       	mov    0x1098b8,%eax
  101fbc:	85 c0                	test   %eax,%eax
  101fbe:	0f 84 7c 00 00 00    	je     102040 <iderw+0xb0>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);
  101fc4:	c7 04 24 80 98 10 00 	movl   $0x109880,(%esp)
  101fcb:	e8 50 1e 00 00       	call   103e20 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  101fd0:	ba b4 98 10 00       	mov    $0x1098b4,%edx
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);

  // Append b to idequeue.
  b->qnext = 0;
  101fd5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  101fdc:	a1 b4 98 10 00       	mov    0x1098b4,%eax
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  101fe1:	85 c0                	test   %eax,%eax
  101fe3:	74 0d                	je     101ff2 <iderw+0x62>
  101fe5:	8d 76 00             	lea    0x0(%esi),%esi
  101fe8:	8d 50 14             	lea    0x14(%eax),%edx
  101feb:	8b 40 14             	mov    0x14(%eax),%eax
  101fee:	85 c0                	test   %eax,%eax
  101ff0:	75 f6                	jne    101fe8 <iderw+0x58>
    ;
  *pp = b;
  101ff2:	89 1a                	mov    %ebx,(%edx)
  
  // Start disk if necessary.
  if(idequeue == b)
  101ff4:	39 1d b4 98 10 00    	cmp    %ebx,0x1098b4
  101ffa:	75 14                	jne    102010 <iderw+0x80>
  101ffc:	eb 2d                	jmp    10202b <iderw+0x9b>
  101ffe:	66 90                	xchg   %ax,%ax
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  102000:	c7 44 24 04 80 98 10 	movl   $0x109880,0x4(%esp)
  102007:	00 
  102008:	89 1c 24             	mov    %ebx,(%esp)
  10200b:	e8 a0 12 00 00       	call   1032b0 <sleep>
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
  102010:	8b 03                	mov    (%ebx),%eax
  102012:	83 e0 06             	and    $0x6,%eax
  102015:	83 f8 02             	cmp    $0x2,%eax
  102018:	75 e6                	jne    102000 <iderw+0x70>
    sleep(b, &idelock);
  }

  release(&idelock);
  10201a:	c7 45 08 80 98 10 00 	movl   $0x109880,0x8(%ebp)
}
  102021:	83 c4 14             	add    $0x14,%esp
  102024:	5b                   	pop    %ebx
  102025:	5d                   	pop    %ebp
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }

  release(&idelock);
  102026:	e9 a5 1d 00 00       	jmp    103dd0 <release>
    ;
  *pp = b;
  
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  10202b:	89 d8                	mov    %ebx,%eax
  10202d:	e8 ae fe ff ff       	call   101ee0 <idestart>
  102032:	eb dc                	jmp    102010 <iderw+0x80>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  102034:	c7 04 24 bf 68 10 00 	movl   $0x1068bf,(%esp)
  10203b:	e8 30 e9 ff ff       	call   100970 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
  102040:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  102047:	e8 24 e9 ff ff       	call   100970 <panic>
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  10204c:	c7 04 24 d3 68 10 00 	movl   $0x1068d3,(%esp)
  102053:	e8 18 e9 ff ff       	call   100970 <panic>
  102058:	90                   	nop
  102059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102060 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
  102060:	55                   	push   %ebp
  102061:	89 e5                	mov    %esp,%ebp
  102063:	57                   	push   %edi
  102064:	53                   	push   %ebx
  102065:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  // Take first buffer off queue.
  acquire(&idelock);
  102068:	c7 04 24 80 98 10 00 	movl   $0x109880,(%esp)
  10206f:	e8 ac 1d 00 00       	call   103e20 <acquire>
  if((b = idequeue) == 0){
  102074:	8b 1d b4 98 10 00    	mov    0x1098b4,%ebx
  10207a:	85 db                	test   %ebx,%ebx
  10207c:	74 2d                	je     1020ab <ideintr+0x4b>
    release(&idelock);
    // cprintf("spurious IDE interrupt\n");
    return;
  }
  idequeue = b->qnext;
  10207e:	8b 43 14             	mov    0x14(%ebx),%eax
  102081:	a3 b4 98 10 00       	mov    %eax,0x1098b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
  102086:	8b 0b                	mov    (%ebx),%ecx
  102088:	f6 c1 04             	test   $0x4,%cl
  10208b:	74 33                	je     1020c0 <ideintr+0x60>
    insl(0x1f0, b->data, 512/4);
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
  10208d:	83 c9 02             	or     $0x2,%ecx
  102090:	83 e1 fb             	and    $0xfffffffb,%ecx
  102093:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
  102095:	89 1c 24             	mov    %ebx,(%esp)
  102098:	e8 e3 10 00 00       	call   103180 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
  10209d:	a1 b4 98 10 00       	mov    0x1098b4,%eax
  1020a2:	85 c0                	test   %eax,%eax
  1020a4:	74 05                	je     1020ab <ideintr+0x4b>
    idestart(idequeue);
  1020a6:	e8 35 fe ff ff       	call   101ee0 <idestart>

  release(&idelock);
  1020ab:	c7 04 24 80 98 10 00 	movl   $0x109880,(%esp)
  1020b2:	e8 19 1d 00 00       	call   103dd0 <release>
}
  1020b7:	83 c4 10             	add    $0x10,%esp
  1020ba:	5b                   	pop    %ebx
  1020bb:	5f                   	pop    %edi
  1020bc:	5d                   	pop    %ebp
  1020bd:	c3                   	ret    
  1020be:	66 90                	xchg   %ax,%ax
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  1020c0:	ba f7 01 00 00       	mov    $0x1f7,%edx
  1020c5:	8d 76 00             	lea    0x0(%esi),%esi
  1020c8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  1020c9:	0f b6 c0             	movzbl %al,%eax
  1020cc:	89 c7                	mov    %eax,%edi
  1020ce:	81 e7 c0 00 00 00    	and    $0xc0,%edi
  1020d4:	83 ff 40             	cmp    $0x40,%edi
  1020d7:	75 ef                	jne    1020c8 <ideintr+0x68>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
  1020d9:	a8 21                	test   $0x21,%al
  1020db:	75 b0                	jne    10208d <ideintr+0x2d>
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
  1020dd:	8d 7b 18             	lea    0x18(%ebx),%edi
  1020e0:	b9 80 00 00 00       	mov    $0x80,%ecx
  1020e5:	ba f0 01 00 00       	mov    $0x1f0,%edx
  1020ea:	fc                   	cld    
  1020eb:	f3 6d                	rep insl (%dx),%es:(%edi)
  1020ed:	8b 0b                	mov    (%ebx),%ecx
  1020ef:	eb 9c                	jmp    10208d <ideintr+0x2d>
  1020f1:	eb 0d                	jmp    102100 <ideinit>
  1020f3:	90                   	nop
  1020f4:	90                   	nop
  1020f5:	90                   	nop
  1020f6:	90                   	nop
  1020f7:	90                   	nop
  1020f8:	90                   	nop
  1020f9:	90                   	nop
  1020fa:	90                   	nop
  1020fb:	90                   	nop
  1020fc:	90                   	nop
  1020fd:	90                   	nop
  1020fe:	90                   	nop
  1020ff:	90                   	nop

00102100 <ideinit>:
  return 0;
}

void
ideinit(void)
{
  102100:	55                   	push   %ebp
  102101:	89 e5                	mov    %esp,%ebp
  102103:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
  102106:	c7 44 24 04 06 69 10 	movl   $0x106906,0x4(%esp)
  10210d:	00 
  10210e:	c7 04 24 80 98 10 00 	movl   $0x109880,(%esp)
  102115:	e8 76 1b 00 00       	call   103c90 <initlock>
  picenable(IRQ_IDE);
  10211a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  102121:	e8 ba 0a 00 00       	call   102be0 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
  102126:	a1 00 e1 10 00       	mov    0x10e100,%eax
  10212b:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  102132:	83 e8 01             	sub    $0x1,%eax
  102135:	89 44 24 04          	mov    %eax,0x4(%esp)
  102139:	e8 52 00 00 00       	call   102190 <ioapicenable>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  10213e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  102143:	90                   	nop
  102144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102148:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  102149:	25 c0 00 00 00       	and    $0xc0,%eax
  10214e:	83 f8 40             	cmp    $0x40,%eax
  102151:	75 f5                	jne    102148 <ideinit+0x48>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102153:	ba f6 01 00 00       	mov    $0x1f6,%edx
  102158:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  10215d:	ee                   	out    %al,(%dx)
  10215e:	31 c9                	xor    %ecx,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102160:	b2 f7                	mov    $0xf7,%dl
  102162:	eb 0f                	jmp    102173 <ideinit+0x73>
  102164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
  102168:	83 c1 01             	add    $0x1,%ecx
  10216b:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  102171:	74 0f                	je     102182 <ideinit+0x82>
  102173:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
  102174:	84 c0                	test   %al,%al
  102176:	74 f0                	je     102168 <ideinit+0x68>
      havedisk1 = 1;
  102178:	c7 05 b8 98 10 00 01 	movl   $0x1,0x1098b8
  10217f:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102182:	ba f6 01 00 00       	mov    $0x1f6,%edx
  102187:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  10218c:	ee                   	out    %al,(%dx)
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
  10218d:	c9                   	leave  
  10218e:	c3                   	ret    
  10218f:	90                   	nop

00102190 <ioapicenable>:
}

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
  102190:	8b 15 04 db 10 00    	mov    0x10db04,%edx
  }
}

void
ioapicenable(int irq, int cpunum)
{
  102196:	55                   	push   %ebp
  102197:	89 e5                	mov    %esp,%ebp
  102199:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!ismp)
  10219c:	85 d2                	test   %edx,%edx
  10219e:	74 31                	je     1021d1 <ioapicenable+0x41>
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021a0:	8b 15 b4 da 10 00    	mov    0x10dab4,%edx
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  1021a6:	8d 48 20             	lea    0x20(%eax),%ecx
  1021a9:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021ad:	89 02                	mov    %eax,(%edx)
  ioapic->data = data;
  1021af:	8b 15 b4 da 10 00    	mov    0x10dab4,%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021b5:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
  1021b8:	89 4a 10             	mov    %ecx,0x10(%edx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021bb:	8b 0d b4 da 10 00    	mov    0x10dab4,%ecx

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  1021c1:	8b 55 0c             	mov    0xc(%ebp),%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021c4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
  1021c6:	a1 b4 da 10 00       	mov    0x10dab4,%eax

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  1021cb:	c1 e2 18             	shl    $0x18,%edx

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  1021ce:	89 50 10             	mov    %edx,0x10(%eax)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
  1021d1:	5d                   	pop    %ebp
  1021d2:	c3                   	ret    
  1021d3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1021d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001021e0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
  1021e0:	55                   	push   %ebp
  1021e1:	89 e5                	mov    %esp,%ebp
  1021e3:	56                   	push   %esi
  1021e4:	53                   	push   %ebx
  1021e5:	83 ec 10             	sub    $0x10,%esp
  int i, id, maxintr;

  if(!ismp)
  1021e8:	8b 0d 04 db 10 00    	mov    0x10db04,%ecx
  1021ee:	85 c9                	test   %ecx,%ecx
  1021f0:	0f 84 9e 00 00 00    	je     102294 <ioapicinit+0xb4>
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  1021f6:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
  1021fd:	00 00 00 
  return ioapic->data;
  102200:	8b 35 10 00 c0 fe    	mov    0xfec00010,%esi
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  102206:	bb 00 00 c0 fe       	mov    $0xfec00000,%ebx
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  10220b:	c7 05 00 00 c0 fe 00 	movl   $0x0,0xfec00000
  102212:	00 00 00 
  return ioapic->data;
  102215:	a1 10 00 c0 fe       	mov    0xfec00010,%eax
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  10221a:	0f b6 15 00 db 10 00 	movzbl 0x10db00,%edx
  int i, id, maxintr;

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  102221:	c7 05 b4 da 10 00 00 	movl   $0xfec00000,0x10dab4
  102228:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  10222b:	c1 ee 10             	shr    $0x10,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  10222e:	c1 e8 18             	shr    $0x18,%eax

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  102231:	81 e6 ff 00 00 00    	and    $0xff,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  102237:	39 c2                	cmp    %eax,%edx
  102239:	74 12                	je     10224d <ioapicinit+0x6d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
  10223b:	c7 04 24 0c 69 10 00 	movl   $0x10690c,(%esp)
  102242:	e8 39 e3 ff ff       	call   100580 <cprintf>
  102247:	8b 1d b4 da 10 00    	mov    0x10dab4,%ebx
  10224d:	ba 10 00 00 00       	mov    $0x10,%edx
  102252:	31 c0                	xor    %eax,%eax
  102254:	eb 08                	jmp    10225e <ioapicinit+0x7e>
  102256:	66 90                	xchg   %ax,%ax

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  102258:	8b 1d b4 da 10 00    	mov    0x10dab4,%ebx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10225e:	89 13                	mov    %edx,(%ebx)
  ioapic->data = data;
  102260:	8b 1d b4 da 10 00    	mov    0x10dab4,%ebx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
  102266:	8d 48 20             	lea    0x20(%eax),%ecx
  102269:	81 c9 00 00 01 00    	or     $0x10000,%ecx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  10226f:	83 c0 01             	add    $0x1,%eax

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  102272:	89 4b 10             	mov    %ecx,0x10(%ebx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102275:	8b 0d b4 da 10 00    	mov    0x10dab4,%ecx
  10227b:	8d 5a 01             	lea    0x1(%edx),%ebx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  10227e:	83 c2 02             	add    $0x2,%edx
  102281:	39 c6                	cmp    %eax,%esi
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102283:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
  102285:	8b 0d b4 da 10 00    	mov    0x10dab4,%ecx
  10228b:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  102292:	7d c4                	jge    102258 <ioapicinit+0x78>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
  102294:	83 c4 10             	add    $0x10,%esp
  102297:	5b                   	pop    %ebx
  102298:	5e                   	pop    %esi
  102299:	5d                   	pop    %ebp
  10229a:	c3                   	ret    
  10229b:	90                   	nop
  10229c:	90                   	nop
  10229d:	90                   	nop
  10229e:	90                   	nop
  10229f:	90                   	nop

001022a0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  1022a0:	55                   	push   %ebp
  1022a1:	89 e5                	mov    %esp,%ebp
  1022a3:	53                   	push   %ebx
  1022a4:	83 ec 14             	sub    $0x14,%esp
  struct run *r;

  acquire(&kmem.lock);
  1022a7:	c7 04 24 c0 da 10 00 	movl   $0x10dac0,(%esp)
  1022ae:	e8 6d 1b 00 00       	call   103e20 <acquire>
  r = kmem.freelist;
  1022b3:	8b 1d f4 da 10 00    	mov    0x10daf4,%ebx
  if(r)
  1022b9:	85 db                	test   %ebx,%ebx
  1022bb:	74 07                	je     1022c4 <kalloc+0x24>
    kmem.freelist = r->next;
  1022bd:	8b 03                	mov    (%ebx),%eax
  1022bf:	a3 f4 da 10 00       	mov    %eax,0x10daf4
  release(&kmem.lock);
  1022c4:	c7 04 24 c0 da 10 00 	movl   $0x10dac0,(%esp)
  1022cb:	e8 00 1b 00 00       	call   103dd0 <release>
  return (char*)r;
}
  1022d0:	89 d8                	mov    %ebx,%eax
  1022d2:	83 c4 14             	add    $0x14,%esp
  1022d5:	5b                   	pop    %ebx
  1022d6:	5d                   	pop    %ebp
  1022d7:	c3                   	ret    
  1022d8:	90                   	nop
  1022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001022e0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
  1022e0:	55                   	push   %ebp
  1022e1:	89 e5                	mov    %esp,%ebp
  1022e3:	53                   	push   %ebx
  1022e4:	83 ec 14             	sub    $0x14,%esp
  1022e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
  1022ea:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  1022f0:	75 52                	jne    102344 <kfree+0x64>
  1022f2:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  1022f8:	77 4a                	ja     102344 <kfree+0x64>
  1022fa:	81 fb a4 0a 11 00    	cmp    $0x110aa4,%ebx
  102300:	72 42                	jb     102344 <kfree+0x64>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
  102302:	89 1c 24             	mov    %ebx,(%esp)
  102305:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10230c:	00 
  10230d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  102314:	00 
  102315:	e8 a6 1b 00 00       	call   103ec0 <memset>

  acquire(&kmem.lock);
  10231a:	c7 04 24 c0 da 10 00 	movl   $0x10dac0,(%esp)
  102321:	e8 fa 1a 00 00       	call   103e20 <acquire>
  r = (struct run*)v;
  r->next = kmem.freelist;
  102326:	a1 f4 da 10 00       	mov    0x10daf4,%eax
  10232b:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  10232d:	89 1d f4 da 10 00    	mov    %ebx,0x10daf4
  release(&kmem.lock);
  102333:	c7 45 08 c0 da 10 00 	movl   $0x10dac0,0x8(%ebp)
}
  10233a:	83 c4 14             	add    $0x14,%esp
  10233d:	5b                   	pop    %ebx
  10233e:	5d                   	pop    %ebp

  acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
  10233f:	e9 8c 1a 00 00       	jmp    103dd0 <release>
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
    panic("kfree");
  102344:	c7 04 24 3e 69 10 00 	movl   $0x10693e,(%esp)
  10234b:	e8 20 e6 ff ff       	call   100970 <panic>

00102350 <kinit>:
extern char end[]; // first address after kernel loaded from ELF file

// Initialize free list of physical pages.
void
kinit(void)
{
  102350:	55                   	push   %ebp
  102351:	89 e5                	mov    %esp,%ebp
  102353:	53                   	push   %ebx
  102354:	83 ec 14             	sub    $0x14,%esp
  char *p;

  initlock(&kmem.lock, "kmem");
  102357:	c7 44 24 04 44 69 10 	movl   $0x106944,0x4(%esp)
  10235e:	00 
  10235f:	c7 04 24 c0 da 10 00 	movl   $0x10dac0,(%esp)
  102366:	e8 25 19 00 00       	call   103c90 <initlock>
  p = (char*)PGROUNDUP((uint)end);
  10236b:	ba a3 1a 11 00       	mov    $0x111aa3,%edx
  102370:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  102376:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
  10237c:	81 fb 00 00 00 01    	cmp    $0x1000000,%ebx
  102382:	76 08                	jbe    10238c <kinit+0x3c>
  102384:	eb 1b                	jmp    1023a1 <kinit+0x51>
  102386:	66 90                	xchg   %ax,%ax
  102388:	89 da                	mov    %ebx,%edx
  10238a:	89 c3                	mov    %eax,%ebx
    kfree(p);
  10238c:	89 14 24             	mov    %edx,(%esp)
  10238f:	e8 4c ff ff ff       	call   1022e0 <kfree>
{
  char *p;

  initlock(&kmem.lock, "kmem");
  p = (char*)PGROUNDUP((uint)end);
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  102394:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  10239a:	3d 00 00 00 01       	cmp    $0x1000000,%eax
  10239f:	76 e7                	jbe    102388 <kinit+0x38>
    kfree(p);
}
  1023a1:	83 c4 14             	add    $0x14,%esp
  1023a4:	5b                   	pop    %ebx
  1023a5:	5d                   	pop    %ebp
  1023a6:	c3                   	ret    
  1023a7:	90                   	nop
  1023a8:	90                   	nop
  1023a9:	90                   	nop
  1023aa:	90                   	nop
  1023ab:	90                   	nop
  1023ac:	90                   	nop
  1023ad:	90                   	nop
  1023ae:	90                   	nop
  1023af:	90                   	nop

001023b0 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
  1023b0:	55                   	push   %ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  1023b1:	ba 64 00 00 00       	mov    $0x64,%edx
  1023b6:	89 e5                	mov    %esp,%ebp
  1023b8:	ec                   	in     (%dx),%al
  1023b9:	89 c2                	mov    %eax,%edx
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
  1023bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1023c0:	83 e2 01             	and    $0x1,%edx
  1023c3:	74 3e                	je     102403 <kbdgetc+0x53>
  1023c5:	ba 60 00 00 00       	mov    $0x60,%edx
  1023ca:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
  1023cb:	0f b6 c0             	movzbl %al,%eax

  if(data == 0xE0){
  1023ce:	3d e0 00 00 00       	cmp    $0xe0,%eax
  1023d3:	0f 84 7f 00 00 00    	je     102458 <kbdgetc+0xa8>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
  1023d9:	84 c0                	test   %al,%al
  1023db:	79 2b                	jns    102408 <kbdgetc+0x58>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
  1023dd:	8b 15 bc 98 10 00    	mov    0x1098bc,%edx
  1023e3:	f6 c2 40             	test   $0x40,%dl
  1023e6:	75 03                	jne    1023eb <kbdgetc+0x3b>
  1023e8:	83 e0 7f             	and    $0x7f,%eax
    shift &= ~(shiftcode[data] | E0ESC);
  1023eb:	0f b6 80 60 69 10 00 	movzbl 0x106960(%eax),%eax
  1023f2:	83 c8 40             	or     $0x40,%eax
  1023f5:	0f b6 c0             	movzbl %al,%eax
  1023f8:	f7 d0                	not    %eax
  1023fa:	21 d0                	and    %edx,%eax
  1023fc:	a3 bc 98 10 00       	mov    %eax,0x1098bc
  102401:	31 c0                	xor    %eax,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102403:	5d                   	pop    %ebp
  102404:	c3                   	ret    
  102405:	8d 76 00             	lea    0x0(%esi),%esi
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
  102408:	8b 0d bc 98 10 00    	mov    0x1098bc,%ecx
  10240e:	f6 c1 40             	test   $0x40,%cl
  102411:	74 05                	je     102418 <kbdgetc+0x68>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
  102413:	0c 80                	or     $0x80,%al
    shift &= ~E0ESC;
  102415:	83 e1 bf             	and    $0xffffffbf,%ecx
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  102418:	0f b6 90 60 69 10 00 	movzbl 0x106960(%eax),%edx
  10241f:	09 ca                	or     %ecx,%edx
  102421:	0f b6 88 60 6a 10 00 	movzbl 0x106a60(%eax),%ecx
  102428:	31 ca                	xor    %ecx,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
  10242a:	89 d1                	mov    %edx,%ecx
  10242c:	83 e1 03             	and    $0x3,%ecx
  10242f:	8b 0c 8d 60 6b 10 00 	mov    0x106b60(,%ecx,4),%ecx
    data |= 0x80;
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  102436:	89 15 bc 98 10 00    	mov    %edx,0x1098bc
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
  10243c:	83 e2 08             	and    $0x8,%edx
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  10243f:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
  if(shift & CAPSLOCK){
  102443:	74 be                	je     102403 <kbdgetc+0x53>
    if('a' <= c && c <= 'z')
  102445:	8d 50 9f             	lea    -0x61(%eax),%edx
  102448:	83 fa 19             	cmp    $0x19,%edx
  10244b:	77 1b                	ja     102468 <kbdgetc+0xb8>
      c += 'A' - 'a';
  10244d:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102450:	5d                   	pop    %ebp
  102451:	c3                   	ret    
  102452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if((st & KBS_DIB) == 0)
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
  102458:	30 c0                	xor    %al,%al
  10245a:	83 0d bc 98 10 00 40 	orl    $0x40,0x1098bc
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102461:	5d                   	pop    %ebp
  102462:	c3                   	ret    
  102463:	90                   	nop
  102464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
  102468:	8d 50 bf             	lea    -0x41(%eax),%edx
  10246b:	83 fa 19             	cmp    $0x19,%edx
  10246e:	77 93                	ja     102403 <kbdgetc+0x53>
      c += 'a' - 'A';
  102470:	83 c0 20             	add    $0x20,%eax
  }
  return c;
}
  102473:	5d                   	pop    %ebp
  102474:	c3                   	ret    
  102475:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102480 <kbdintr>:

void
kbdintr(void)
{
  102480:	55                   	push   %ebp
  102481:	89 e5                	mov    %esp,%ebp
  102483:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
  102486:	c7 04 24 b0 23 10 00 	movl   $0x1023b0,(%esp)
  10248d:	e8 4e e3 ff ff       	call   1007e0 <consoleintr>
}
  102492:	c9                   	leave  
  102493:	c3                   	ret    
  102494:	90                   	nop
  102495:	90                   	nop
  102496:	90                   	nop
  102497:	90                   	nop
  102498:	90                   	nop
  102499:	90                   	nop
  10249a:	90                   	nop
  10249b:	90                   	nop
  10249c:	90                   	nop
  10249d:	90                   	nop
  10249e:	90                   	nop
  10249f:	90                   	nop

001024a0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
  1024a0:	a1 f8 da 10 00       	mov    0x10daf8,%eax
}

// Acknowledge interrupt.
void
lapiceoi(void)
{
  1024a5:	55                   	push   %ebp
  1024a6:	89 e5                	mov    %esp,%ebp
  if(lapic)
  1024a8:	85 c0                	test   %eax,%eax
  1024aa:	74 12                	je     1024be <lapiceoi+0x1e>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024ac:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  1024b3:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1024b6:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  1024bb:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
  1024be:	5d                   	pop    %ebp
  1024bf:	c3                   	ret    

001024c0 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
  1024c0:	55                   	push   %ebp
  1024c1:	89 e5                	mov    %esp,%ebp
}
  1024c3:	5d                   	pop    %ebp
  1024c4:	c3                   	ret    
  1024c5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1024c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001024d0 <lapicstartap>:

// Start additional processor running bootstrap code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
  1024d0:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1024d1:	ba 70 00 00 00       	mov    $0x70,%edx
  1024d6:	89 e5                	mov    %esp,%ebp
  1024d8:	b8 0f 00 00 00       	mov    $0xf,%eax
  1024dd:	53                   	push   %ebx
  1024de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1024e1:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
  1024e5:	ee                   	out    %al,(%dx)
  1024e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  1024eb:	b2 71                	mov    $0x71,%dl
  1024ed:	ee                   	out    %al,(%dx)
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  wrv[1] = addr >> 4;
  1024ee:	89 c8                	mov    %ecx,%eax
  1024f0:	c1 e8 04             	shr    $0x4,%eax
  1024f3:	66 a3 69 04 00 00    	mov    %ax,0x469
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024f9:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  1024fe:	c1 e3 18             	shl    $0x18,%ebx
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  102501:	66 c7 05 67 04 00 00 	movw   $0x0,0x467
  102508:	00 00 

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  10250a:	c1 e9 0c             	shr    $0xc,%ecx
  10250d:	80 cd 06             	or     $0x6,%ch
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102510:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102516:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  10251b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10251e:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
  102525:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102528:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  10252d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102530:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
  102537:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10253a:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  10253f:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102542:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102548:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  10254d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102550:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102556:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  10255b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10255e:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102564:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  102569:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10256c:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102572:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  102577:	5b                   	pop    %ebx
  102578:	5d                   	pop    %ebp

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  102579:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  10257c:	c3                   	ret    
  10257d:	8d 76 00             	lea    0x0(%esi),%esi

00102580 <cpunum>:
  lapicw(TPR, 0);
}

int
cpunum(void)
{
  102580:	55                   	push   %ebp
  102581:	89 e5                	mov    %esp,%ebp
  102583:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  102586:	9c                   	pushf  
  102587:	58                   	pop    %eax
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
  102588:	f6 c4 02             	test   $0x2,%ah
  10258b:	74 12                	je     10259f <cpunum+0x1f>
    static int n;
    if(n++ == 0)
  10258d:	a1 c0 98 10 00       	mov    0x1098c0,%eax
  102592:	8d 50 01             	lea    0x1(%eax),%edx
  102595:	85 c0                	test   %eax,%eax
  102597:	89 15 c0 98 10 00    	mov    %edx,0x1098c0
  10259d:	74 19                	je     1025b8 <cpunum+0x38>
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if(lapic)
  10259f:	8b 15 f8 da 10 00    	mov    0x10daf8,%edx
  1025a5:	31 c0                	xor    %eax,%eax
  1025a7:	85 d2                	test   %edx,%edx
  1025a9:	74 06                	je     1025b1 <cpunum+0x31>
    return lapic[ID]>>24;
  1025ab:	8b 42 20             	mov    0x20(%edx),%eax
  1025ae:	c1 e8 18             	shr    $0x18,%eax
  return 0;
}
  1025b1:	c9                   	leave  
  1025b2:	c3                   	ret    
  1025b3:	90                   	nop
  1025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
    static int n;
    if(n++ == 0)
      cprintf("cpu called from %x with interrupts enabled\n",
  1025b8:	8b 45 04             	mov    0x4(%ebp),%eax
  1025bb:	c7 04 24 70 6b 10 00 	movl   $0x106b70,(%esp)
  1025c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1025c6:	e8 b5 df ff ff       	call   100580 <cprintf>
  1025cb:	eb d2                	jmp    10259f <cpunum+0x1f>
  1025cd:	8d 76 00             	lea    0x0(%esi),%esi

001025d0 <lapicinit>:
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(int c)
{
  1025d0:	55                   	push   %ebp
  1025d1:	89 e5                	mov    %esp,%ebp
  1025d3:	83 ec 18             	sub    $0x18,%esp
  cprintf("lapicinit: %d 0x%x\n", c, lapic);
  1025d6:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  1025db:	c7 04 24 9c 6b 10 00 	movl   $0x106b9c,(%esp)
  1025e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1025e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1025e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1025ed:	e8 8e df ff ff       	call   100580 <cprintf>
  if(!lapic) 
  1025f2:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  1025f7:	85 c0                	test   %eax,%eax
  1025f9:	0f 84 0a 01 00 00    	je     102709 <lapicinit+0x139>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025ff:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
  102606:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102609:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  10260e:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102611:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
  102618:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10261b:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  102620:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102623:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
  10262a:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
  10262d:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  102632:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102635:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
  10263c:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
  10263f:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  102644:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102647:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
  10264e:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  102651:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  102656:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102659:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
  102660:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  102663:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  102668:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
  10266b:	8b 50 30             	mov    0x30(%eax),%edx
  10266e:	c1 ea 10             	shr    $0x10,%edx
  102671:	80 fa 03             	cmp    $0x3,%dl
  102674:	0f 87 96 00 00 00    	ja     102710 <lapicinit+0x140>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10267a:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
  102681:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102684:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  102689:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10268c:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  102693:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102696:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  10269b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10269e:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  1026a5:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026a8:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  1026ad:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026b0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  1026b7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026ba:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  1026bf:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026c2:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
  1026c9:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026cc:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  1026d1:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026d4:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
  1026db:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
  1026de:	8b 0d f8 da 10 00    	mov    0x10daf8,%ecx
  1026e4:	8b 41 20             	mov    0x20(%ecx),%eax
  1026e7:	8d 91 00 03 00 00    	lea    0x300(%ecx),%edx
  1026ed:	8d 76 00             	lea    0x0(%esi),%esi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
  1026f0:	8b 02                	mov    (%edx),%eax
  1026f2:	f6 c4 10             	test   $0x10,%ah
  1026f5:	75 f9                	jne    1026f0 <lapicinit+0x120>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026f7:	c7 81 80 00 00 00 00 	movl   $0x0,0x80(%ecx)
  1026fe:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102701:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  102706:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
  102709:	c9                   	leave  
  10270a:	c3                   	ret    
  10270b:	90                   	nop
  10270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102710:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
  102717:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  10271a:	a1 f8 da 10 00       	mov    0x10daf8,%eax
  10271f:	8b 50 20             	mov    0x20(%eax),%edx
  102722:	e9 53 ff ff ff       	jmp    10267a <lapicinit+0xaa>
  102727:	90                   	nop
  102728:	90                   	nop
  102729:	90                   	nop
  10272a:	90                   	nop
  10272b:	90                   	nop
  10272c:	90                   	nop
  10272d:	90                   	nop
  10272e:	90                   	nop
  10272f:	90                   	nop

00102730 <mpmain>:
// Common CPU setup code.
// Bootstrap CPU comes here from mainc().
// Other CPUs jump here from bootother.S.
static void
mpmain(void)
{
  102730:	55                   	push   %ebp
  102731:	89 e5                	mov    %esp,%ebp
  102733:	53                   	push   %ebx
  102734:	83 ec 14             	sub    $0x14,%esp
  if(cpunum() != mpbcpu()){
  102737:	e8 44 fe ff ff       	call   102580 <cpunum>
  10273c:	89 c3                	mov    %eax,%ebx
  10273e:	e8 ed 01 00 00       	call   102930 <mpbcpu>
  102743:	39 c3                	cmp    %eax,%ebx
  102745:	74 16                	je     10275d <mpmain+0x2d>
    seginit();
  102747:	e8 04 3f 00 00       	call   106650 <seginit>
  10274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    lapicinit(cpunum());
  102750:	e8 2b fe ff ff       	call   102580 <cpunum>
  102755:	89 04 24             	mov    %eax,(%esp)
  102758:	e8 73 fe ff ff       	call   1025d0 <lapicinit>
  }
  vmenable();        // turn on paging
  10275d:	e8 ae 37 00 00       	call   105f10 <vmenable>
  cprintf("cpu%d: starting\n", cpu->id);
  102762:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  102768:	0f b6 00             	movzbl (%eax),%eax
  10276b:	c7 04 24 b0 6b 10 00 	movl   $0x106bb0,(%esp)
  102772:	89 44 24 04          	mov    %eax,0x4(%esp)
  102776:	e8 05 de ff ff       	call   100580 <cprintf>
  idtinit();       // load idt register
  10277b:	e8 a0 28 00 00       	call   105020 <idtinit>
  xchg(&cpu->booted, 1); // tell bootothers() we're up
  102780:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  102787:	b8 01 00 00 00       	mov    $0x1,%eax
  10278c:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler();     // start running processes
  102793:	e8 28 0c 00 00       	call   1033c0 <scheduler>
  102798:	90                   	nop
  102799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001027a0 <mainc>:

// Set up hardware and software.
// Runs only on the boostrap processor.
void
mainc(void)
{
  1027a0:	55                   	push   %ebp
  1027a1:	89 e5                	mov    %esp,%ebp
  1027a3:	53                   	push   %ebx
  1027a4:	83 ec 14             	sub    $0x14,%esp
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  1027a7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1027ad:	0f b6 00             	movzbl (%eax),%eax
  1027b0:	c7 04 24 c1 6b 10 00 	movl   $0x106bc1,(%esp)
  1027b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1027bb:	e8 c0 dd ff ff       	call   100580 <cprintf>
  picinit();       // interrupt controller
  1027c0:	e8 4b 04 00 00       	call   102c10 <picinit>
  ioapicinit();    // another interrupt controller
  1027c5:	e8 16 fa ff ff       	call   1021e0 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
  1027ca:	e8 e1 da ff ff       	call   1002b0 <consoleinit>
  1027cf:	90                   	nop
  uartinit();      // serial port
  1027d0:	e8 0b 2c 00 00       	call   1053e0 <uartinit>
  kvmalloc();      // initialize the kernel page table
  1027d5:	e8 b6 39 00 00       	call   106190 <kvmalloc>
  pinit();         // process table
  1027da:	e8 91 14 00 00       	call   103c70 <pinit>
  1027df:	90                   	nop
  tvinit();        // trap vectors
  1027e0:	e8 cb 2a 00 00       	call   1052b0 <tvinit>
  binit();         // buffer cache
  1027e5:	e8 56 da ff ff       	call   100240 <binit>
  fileinit();      // file table
  1027ea:	e8 c1 e8 ff ff       	call   1010b0 <fileinit>
  1027ef:	90                   	nop
  iinit();         // inode cache
  1027f0:	e8 cb f6 ff ff       	call   101ec0 <iinit>
  ideinit();       // disk
  1027f5:	e8 06 f9 ff ff       	call   102100 <ideinit>
  if(!ismp)
  1027fa:	a1 04 db 10 00       	mov    0x10db04,%eax
  1027ff:	85 c0                	test   %eax,%eax
  102801:	0f 84 ae 00 00 00    	je     1028b5 <mainc+0x115>
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  102807:	e8 74 13 00 00       	call   103b80 <userinit>

  // Write bootstrap code to unused memory at 0x7000.
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);
  10280c:	c7 44 24 08 6a 00 00 	movl   $0x6a,0x8(%esp)
  102813:	00 
  102814:	c7 44 24 04 9c 97 10 	movl   $0x10979c,0x4(%esp)
  10281b:	00 
  10281c:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
  102823:	e8 18 17 00 00       	call   103f40 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
  102828:	69 05 00 e1 10 00 bc 	imul   $0xbc,0x10e100,%eax
  10282f:	00 00 00 
  102832:	05 20 db 10 00       	add    $0x10db20,%eax
  102837:	3d 20 db 10 00       	cmp    $0x10db20,%eax
  10283c:	76 6d                	jbe    1028ab <mainc+0x10b>
  10283e:	bb 20 db 10 00       	mov    $0x10db20,%ebx
  102843:	90                   	nop
  102844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(c == cpus+cpunum())  // We've started already.
  102848:	e8 33 fd ff ff       	call   102580 <cpunum>
  10284d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  102853:	05 20 db 10 00       	add    $0x10db20,%eax
  102858:	39 c3                	cmp    %eax,%ebx
  10285a:	74 36                	je     102892 <mainc+0xf2>
      continue;

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
  10285c:	e8 3f fa ff ff       	call   1022a0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpmain;
  102861:	c7 05 f8 6f 00 00 30 	movl   $0x102730,0x6ff8
  102868:	27 10 00 

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
    *(void**)(code-4) = stack + KSTACKSIZE;
  10286b:	05 00 10 00 00       	add    $0x1000,%eax
  102870:	a3 fc 6f 00 00       	mov    %eax,0x6ffc
    *(void**)(code-8) = mpmain;

    lapicstartap(c->id, (uint)code);
  102875:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
  10287c:	00 
  10287d:	0f b6 03             	movzbl (%ebx),%eax
  102880:	89 04 24             	mov    %eax,(%esp)
  102883:	e8 48 fc ff ff       	call   1024d0 <lapicstartap>

    // Wait for cpu to finish mpmain()
    while(c->booted == 0)
  102888:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
  10288e:	85 c0                	test   %eax,%eax
  102890:	74 f6                	je     102888 <mainc+0xe8>
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);

  for(c = cpus; c < cpus+ncpu; c++){
  102892:	69 05 00 e1 10 00 bc 	imul   $0xbc,0x10e100,%eax
  102899:	00 00 00 
  10289c:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
  1028a2:	05 20 db 10 00       	add    $0x10db20,%eax
  1028a7:	39 c3                	cmp    %eax,%ebx
  1028a9:	72 9d                	jb     102848 <mainc+0xa8>
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
}
  1028ab:	83 c4 14             	add    $0x14,%esp
  1028ae:	5b                   	pop    %ebx
  1028af:	5d                   	pop    %ebp
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
  1028b0:	e9 7b fe ff ff       	jmp    102730 <mpmain>
  binit();         // buffer cache
  fileinit();      // file table
  iinit();         // inode cache
  ideinit();       // disk
  if(!ismp)
    timerinit();   // uniprocessor timer
  1028b5:	e8 06 27 00 00       	call   104fc0 <timerinit>
  1028ba:	e9 48 ff ff ff       	jmp    102807 <mainc+0x67>
  1028bf:	90                   	nop

001028c0 <jmpkstack>:
  jmpkstack();       // call mainc() on a properly-allocated stack 
}

void
jmpkstack(void)
{
  1028c0:	55                   	push   %ebp
  1028c1:	89 e5                	mov    %esp,%ebp
  1028c3:	83 ec 18             	sub    $0x18,%esp
  char *kstack, *top;
  
  kstack = kalloc();
  1028c6:	e8 d5 f9 ff ff       	call   1022a0 <kalloc>
  if(kstack == 0)
  1028cb:	85 c0                	test   %eax,%eax
  1028cd:	74 19                	je     1028e8 <jmpkstack+0x28>
    panic("jmpkstack kalloc");
  top = kstack + PGSIZE;
  asm volatile("movl %0,%%esp; call mainc" : : "r" (top));
  1028cf:	05 00 10 00 00       	add    $0x1000,%eax
  1028d4:	89 c4                	mov    %eax,%esp
  1028d6:	e8 c5 fe ff ff       	call   1027a0 <mainc>
  panic("jmpkstack");
  1028db:	c7 04 24 e9 6b 10 00 	movl   $0x106be9,(%esp)
  1028e2:	e8 89 e0 ff ff       	call   100970 <panic>
  1028e7:	90                   	nop
{
  char *kstack, *top;
  
  kstack = kalloc();
  if(kstack == 0)
    panic("jmpkstack kalloc");
  1028e8:	c7 04 24 d8 6b 10 00 	movl   $0x106bd8,(%esp)
  1028ef:	e8 7c e0 ff ff       	call   100970 <panic>
  1028f4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1028fa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00102900 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
  102900:	55                   	push   %ebp
  102901:	89 e5                	mov    %esp,%ebp
  102903:	83 e4 f0             	and    $0xfffffff0,%esp
  102906:	83 ec 10             	sub    $0x10,%esp
  mpinit();        // collect info about this machine
  102909:	e8 b2 00 00 00       	call   1029c0 <mpinit>
  lapicinit(mpbcpu());
  10290e:	e8 1d 00 00 00       	call   102930 <mpbcpu>
  102913:	89 04 24             	mov    %eax,(%esp)
  102916:	e8 b5 fc ff ff       	call   1025d0 <lapicinit>
  seginit();       // set up segments
  10291b:	e8 30 3d 00 00       	call   106650 <seginit>
  kinit();         // initialize memory allocator
  102920:	e8 2b fa ff ff       	call   102350 <kinit>
  jmpkstack();       // call mainc() on a properly-allocated stack 
  102925:	e8 96 ff ff ff       	call   1028c0 <jmpkstack>
  10292a:	90                   	nop
  10292b:	90                   	nop
  10292c:	90                   	nop
  10292d:	90                   	nop
  10292e:	90                   	nop
  10292f:	90                   	nop

00102930 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  102930:	a1 c4 98 10 00       	mov    0x1098c4,%eax
  102935:	55                   	push   %ebp
  102936:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
}
  102938:	5d                   	pop    %ebp
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  102939:	2d 20 db 10 00       	sub    $0x10db20,%eax
  10293e:	c1 f8 02             	sar    $0x2,%eax
  102941:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
  return bcpu-cpus;
}
  102947:	c3                   	ret    
  102948:	90                   	nop
  102949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102950 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102950:	55                   	push   %ebp
  102951:	89 e5                	mov    %esp,%ebp
  102953:	56                   	push   %esi
  102954:	53                   	push   %ebx
  uchar *e, *p;

  e = addr+len;
  102955:	8d 34 10             	lea    (%eax,%edx,1),%esi
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102958:	83 ec 10             	sub    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  10295b:	39 f0                	cmp    %esi,%eax
  10295d:	73 42                	jae    1029a1 <mpsearch1+0x51>
  10295f:	89 c3                	mov    %eax,%ebx
  102961:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  102968:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  10296f:	00 
  102970:	c7 44 24 04 f3 6b 10 	movl   $0x106bf3,0x4(%esp)
  102977:	00 
  102978:	89 1c 24             	mov    %ebx,(%esp)
  10297b:	e8 60 15 00 00       	call   103ee0 <memcmp>
  102980:	85 c0                	test   %eax,%eax
  102982:	75 16                	jne    10299a <mpsearch1+0x4a>
  102984:	31 d2                	xor    %edx,%edx
  102986:	66 90                	xchg   %ax,%ax
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
  102988:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  10298c:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  10298f:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102991:	83 f8 10             	cmp    $0x10,%eax
  102994:	75 f2                	jne    102988 <mpsearch1+0x38>
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  102996:	84 d2                	test   %dl,%dl
  102998:	74 10                	je     1029aa <mpsearch1+0x5a>
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  10299a:	83 c3 10             	add    $0x10,%ebx
  10299d:	39 de                	cmp    %ebx,%esi
  10299f:	77 c7                	ja     102968 <mpsearch1+0x18>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  1029a1:	83 c4 10             	add    $0x10,%esp
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  1029a4:	31 c0                	xor    %eax,%eax
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  1029a6:	5b                   	pop    %ebx
  1029a7:	5e                   	pop    %esi
  1029a8:	5d                   	pop    %ebp
  1029a9:	c3                   	ret    
  1029aa:	83 c4 10             	add    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  1029ad:	89 d8                	mov    %ebx,%eax
  return 0;
}
  1029af:	5b                   	pop    %ebx
  1029b0:	5e                   	pop    %esi
  1029b1:	5d                   	pop    %ebp
  1029b2:	c3                   	ret    
  1029b3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1029b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001029c0 <mpinit>:
  return conf;
}

void
mpinit(void)
{
  1029c0:	55                   	push   %ebp
  1029c1:	89 e5                	mov    %esp,%ebp
  1029c3:	57                   	push   %edi
  1029c4:	56                   	push   %esi
  1029c5:	53                   	push   %ebx
  1029c6:	83 ec 1c             	sub    $0x1c,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  1029c9:	0f b6 05 0f 04 00 00 	movzbl 0x40f,%eax
  1029d0:	0f b6 15 0e 04 00 00 	movzbl 0x40e,%edx
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  1029d7:	c7 05 c4 98 10 00 20 	movl   $0x10db20,0x1098c4
  1029de:	db 10 00 
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  1029e1:	c1 e0 08             	shl    $0x8,%eax
  1029e4:	09 d0                	or     %edx,%eax
  1029e6:	c1 e0 04             	shl    $0x4,%eax
  1029e9:	85 c0                	test   %eax,%eax
  1029eb:	75 1b                	jne    102a08 <mpinit+0x48>
    if((mp = mpsearch1((uchar*)p, 1024)))
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
  1029ed:	0f b6 05 14 04 00 00 	movzbl 0x414,%eax
  1029f4:	0f b6 15 13 04 00 00 	movzbl 0x413,%edx
  1029fb:	c1 e0 08             	shl    $0x8,%eax
  1029fe:	09 d0                	or     %edx,%eax
  102a00:	c1 e0 0a             	shl    $0xa,%eax
  102a03:	2d 00 04 00 00       	sub    $0x400,%eax
  102a08:	ba 00 04 00 00       	mov    $0x400,%edx
  102a0d:	e8 3e ff ff ff       	call   102950 <mpsearch1>
  102a12:	85 c0                	test   %eax,%eax
  102a14:	89 c6                	mov    %eax,%esi
  102a16:	0f 84 94 01 00 00    	je     102bb0 <mpinit+0x1f0>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102a1c:	8b 5e 04             	mov    0x4(%esi),%ebx
  102a1f:	85 db                	test   %ebx,%ebx
  102a21:	74 1c                	je     102a3f <mpinit+0x7f>
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
  102a23:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  102a2a:	00 
  102a2b:	c7 44 24 04 f8 6b 10 	movl   $0x106bf8,0x4(%esp)
  102a32:	00 
  102a33:	89 1c 24             	mov    %ebx,(%esp)
  102a36:	e8 a5 14 00 00       	call   103ee0 <memcmp>
  102a3b:	85 c0                	test   %eax,%eax
  102a3d:	74 09                	je     102a48 <mpinit+0x88>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102a3f:	83 c4 1c             	add    $0x1c,%esp
  102a42:	5b                   	pop    %ebx
  102a43:	5e                   	pop    %esi
  102a44:	5f                   	pop    %edi
  102a45:	5d                   	pop    %ebp
  102a46:	c3                   	ret    
  102a47:	90                   	nop
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
  102a48:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
  102a4c:	3c 04                	cmp    $0x4,%al
  102a4e:	74 04                	je     102a54 <mpinit+0x94>
  102a50:	3c 01                	cmp    $0x1,%al
  102a52:	75 eb                	jne    102a3f <mpinit+0x7f>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102a54:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a58:	85 ff                	test   %edi,%edi
  102a5a:	74 15                	je     102a71 <mpinit+0xb1>
  102a5c:	31 d2                	xor    %edx,%edx
  102a5e:	31 c0                	xor    %eax,%eax
    sum += addr[i];
  102a60:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a64:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  102a67:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a69:	39 c7                	cmp    %eax,%edi
  102a6b:	7f f3                	jg     102a60 <mpinit+0xa0>
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102a6d:	84 d2                	test   %dl,%dl
  102a6f:	75 ce                	jne    102a3f <mpinit+0x7f>
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  102a71:	c7 05 04 db 10 00 01 	movl   $0x1,0x10db04
  102a78:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
  102a7b:	8b 43 24             	mov    0x24(%ebx),%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a7e:	8d 7b 2c             	lea    0x2c(%ebx),%edi

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  102a81:	a3 f8 da 10 00       	mov    %eax,0x10daf8
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102a86:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
  102a8a:	01 c3                	add    %eax,%ebx
  102a8c:	39 df                	cmp    %ebx,%edi
  102a8e:	72 29                	jb     102ab9 <mpinit+0xf9>
  102a90:	eb 52                	jmp    102ae4 <mpinit+0x124>
  102a92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case MPIOINTR:
    case MPLINTR:
      p += 8;
      continue;
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
  102a98:	0f b6 c0             	movzbl %al,%eax
  102a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102a9f:	c7 04 24 18 6c 10 00 	movl   $0x106c18,(%esp)
  102aa6:	e8 d5 da ff ff       	call   100580 <cprintf>
      ismp = 0;
  102aab:	c7 05 04 db 10 00 00 	movl   $0x0,0x10db04
  102ab2:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102ab5:	39 fb                	cmp    %edi,%ebx
  102ab7:	76 1e                	jbe    102ad7 <mpinit+0x117>
    switch(*p){
  102ab9:	0f b6 07             	movzbl (%edi),%eax
  102abc:	3c 04                	cmp    $0x4,%al
  102abe:	77 d8                	ja     102a98 <mpinit+0xd8>
  102ac0:	0f b6 c0             	movzbl %al,%eax
  102ac3:	ff 24 85 38 6c 10 00 	jmp    *0x106c38(,%eax,4)
  102aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
  102ad0:	83 c7 08             	add    $0x8,%edi
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102ad3:	39 fb                	cmp    %edi,%ebx
  102ad5:	77 e2                	ja     102ab9 <mpinit+0xf9>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
  102ad7:	a1 04 db 10 00       	mov    0x10db04,%eax
  102adc:	85 c0                	test   %eax,%eax
  102ade:	0f 84 a4 00 00 00    	je     102b88 <mpinit+0x1c8>
    lapic = 0;
    ioapicid = 0;
    return;
  }

  if(mp->imcrp){
  102ae4:	80 7e 0c 00          	cmpb   $0x0,0xc(%esi)
  102ae8:	0f 84 51 ff ff ff    	je     102a3f <mpinit+0x7f>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102aee:	ba 22 00 00 00       	mov    $0x22,%edx
  102af3:	b8 70 00 00 00       	mov    $0x70,%eax
  102af8:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102af9:	b2 23                	mov    $0x23,%dl
  102afb:	ec                   	in     (%dx),%al
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102afc:	83 c8 01             	or     $0x1,%eax
  102aff:	ee                   	out    %al,(%dx)
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102b00:	83 c4 1c             	add    $0x1c,%esp
  102b03:	5b                   	pop    %ebx
  102b04:	5e                   	pop    %esi
  102b05:	5f                   	pop    %edi
  102b06:	5d                   	pop    %ebp
  102b07:	c3                   	ret    
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu != proc->apicid){
  102b08:	0f b6 57 01          	movzbl 0x1(%edi),%edx
  102b0c:	a1 00 e1 10 00       	mov    0x10e100,%eax
  102b11:	39 c2                	cmp    %eax,%edx
  102b13:	74 23                	je     102b38 <mpinit+0x178>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
  102b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b19:	89 54 24 08          	mov    %edx,0x8(%esp)
  102b1d:	c7 04 24 fd 6b 10 00 	movl   $0x106bfd,(%esp)
  102b24:	e8 57 da ff ff       	call   100580 <cprintf>
        ismp = 0;
  102b29:	a1 00 e1 10 00       	mov    0x10e100,%eax
  102b2e:	c7 05 04 db 10 00 00 	movl   $0x0,0x10db04
  102b35:	00 00 00 
      }
      if(proc->flags & MPBOOT)
  102b38:	f6 47 03 02          	testb  $0x2,0x3(%edi)
  102b3c:	74 12                	je     102b50 <mpinit+0x190>
        bcpu = &cpus[ncpu];
  102b3e:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
  102b44:	81 c2 20 db 10 00    	add    $0x10db20,%edx
  102b4a:	89 15 c4 98 10 00    	mov    %edx,0x1098c4
      cpus[ncpu].id = ncpu;
  102b50:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
      ncpu++;
      p += sizeof(struct mpproc);
  102b56:	83 c7 14             	add    $0x14,%edi
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
        ismp = 0;
      }
      if(proc->flags & MPBOOT)
        bcpu = &cpus[ncpu];
      cpus[ncpu].id = ncpu;
  102b59:	88 82 20 db 10 00    	mov    %al,0x10db20(%edx)
      ncpu++;
  102b5f:	83 c0 01             	add    $0x1,%eax
  102b62:	a3 00 e1 10 00       	mov    %eax,0x10e100
      p += sizeof(struct mpproc);
      continue;
  102b67:	e9 49 ff ff ff       	jmp    102ab5 <mpinit+0xf5>
  102b6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102b70:	0f b6 47 01          	movzbl 0x1(%edi),%eax
      p += sizeof(struct mpioapic);
  102b74:	83 c7 08             	add    $0x8,%edi
      ncpu++;
      p += sizeof(struct mpproc);
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102b77:	a2 00 db 10 00       	mov    %al,0x10db00
      p += sizeof(struct mpioapic);
      continue;
  102b7c:	e9 34 ff ff ff       	jmp    102ab5 <mpinit+0xf5>
  102b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ismp = 0;
    }
  }
  if(!ismp){
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
  102b88:	c7 05 00 e1 10 00 01 	movl   $0x1,0x10e100
  102b8f:	00 00 00 
    lapic = 0;
  102b92:	c7 05 f8 da 10 00 00 	movl   $0x0,0x10daf8
  102b99:	00 00 00 
    ioapicid = 0;
  102b9c:	c6 05 00 db 10 00 00 	movb   $0x0,0x10db00
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102ba3:	83 c4 1c             	add    $0x1c,%esp
  102ba6:	5b                   	pop    %ebx
  102ba7:	5e                   	pop    %esi
  102ba8:	5f                   	pop    %edi
  102ba9:	5d                   	pop    %ebp
  102baa:	c3                   	ret    
  102bab:	90                   	nop
  102bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102bb0:	ba 00 00 01 00       	mov    $0x10000,%edx
  102bb5:	b8 00 00 0f 00       	mov    $0xf0000,%eax
  102bba:	e8 91 fd ff ff       	call   102950 <mpsearch1>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102bbf:	85 c0                	test   %eax,%eax
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102bc1:	89 c6                	mov    %eax,%esi
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102bc3:	0f 85 53 fe ff ff    	jne    102a1c <mpinit+0x5c>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102bc9:	83 c4 1c             	add    $0x1c,%esp
  102bcc:	5b                   	pop    %ebx
  102bcd:	5e                   	pop    %esi
  102bce:	5f                   	pop    %edi
  102bcf:	5d                   	pop    %ebp
  102bd0:	c3                   	ret    
  102bd1:	90                   	nop
  102bd2:	90                   	nop
  102bd3:	90                   	nop
  102bd4:	90                   	nop
  102bd5:	90                   	nop
  102bd6:	90                   	nop
  102bd7:	90                   	nop
  102bd8:	90                   	nop
  102bd9:	90                   	nop
  102bda:	90                   	nop
  102bdb:	90                   	nop
  102bdc:	90                   	nop
  102bdd:	90                   	nop
  102bde:	90                   	nop
  102bdf:	90                   	nop

00102be0 <picenable>:
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102be0:	55                   	push   %ebp
  picsetmask(irqmask & ~(1<<irq));
  102be1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102be6:	89 e5                	mov    %esp,%ebp
  102be8:	ba 21 00 00 00       	mov    $0x21,%edx
  picsetmask(irqmask & ~(1<<irq));
  102bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102bf0:	d3 c0                	rol    %cl,%eax
  102bf2:	66 23 05 20 93 10 00 	and    0x109320,%ax
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
  irqmask = mask;
  102bf9:	66 a3 20 93 10 00    	mov    %ax,0x109320
  102bff:	ee                   	out    %al,(%dx)
  102c00:	66 c1 e8 08          	shr    $0x8,%ax
  102c04:	b2 a1                	mov    $0xa1,%dl
  102c06:	ee                   	out    %al,(%dx)

void
picenable(int irq)
{
  picsetmask(irqmask & ~(1<<irq));
}
  102c07:	5d                   	pop    %ebp
  102c08:	c3                   	ret    
  102c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102c10 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
  102c10:	55                   	push   %ebp
  102c11:	b9 21 00 00 00       	mov    $0x21,%ecx
  102c16:	89 e5                	mov    %esp,%ebp
  102c18:	83 ec 0c             	sub    $0xc,%esp
  102c1b:	89 1c 24             	mov    %ebx,(%esp)
  102c1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102c23:	89 ca                	mov    %ecx,%edx
  102c25:	89 74 24 04          	mov    %esi,0x4(%esp)
  102c29:	89 7c 24 08          	mov    %edi,0x8(%esp)
  102c2d:	ee                   	out    %al,(%dx)
  102c2e:	bb a1 00 00 00       	mov    $0xa1,%ebx
  102c33:	89 da                	mov    %ebx,%edx
  102c35:	ee                   	out    %al,(%dx)
  102c36:	be 11 00 00 00       	mov    $0x11,%esi
  102c3b:	b2 20                	mov    $0x20,%dl
  102c3d:	89 f0                	mov    %esi,%eax
  102c3f:	ee                   	out    %al,(%dx)
  102c40:	b8 20 00 00 00       	mov    $0x20,%eax
  102c45:	89 ca                	mov    %ecx,%edx
  102c47:	ee                   	out    %al,(%dx)
  102c48:	b8 04 00 00 00       	mov    $0x4,%eax
  102c4d:	ee                   	out    %al,(%dx)
  102c4e:	bf 03 00 00 00       	mov    $0x3,%edi
  102c53:	89 f8                	mov    %edi,%eax
  102c55:	ee                   	out    %al,(%dx)
  102c56:	b1 a0                	mov    $0xa0,%cl
  102c58:	89 f0                	mov    %esi,%eax
  102c5a:	89 ca                	mov    %ecx,%edx
  102c5c:	ee                   	out    %al,(%dx)
  102c5d:	b8 28 00 00 00       	mov    $0x28,%eax
  102c62:	89 da                	mov    %ebx,%edx
  102c64:	ee                   	out    %al,(%dx)
  102c65:	b8 02 00 00 00       	mov    $0x2,%eax
  102c6a:	ee                   	out    %al,(%dx)
  102c6b:	89 f8                	mov    %edi,%eax
  102c6d:	ee                   	out    %al,(%dx)
  102c6e:	be 68 00 00 00       	mov    $0x68,%esi
  102c73:	b2 20                	mov    $0x20,%dl
  102c75:	89 f0                	mov    %esi,%eax
  102c77:	ee                   	out    %al,(%dx)
  102c78:	bb 0a 00 00 00       	mov    $0xa,%ebx
  102c7d:	89 d8                	mov    %ebx,%eax
  102c7f:	ee                   	out    %al,(%dx)
  102c80:	89 f0                	mov    %esi,%eax
  102c82:	89 ca                	mov    %ecx,%edx
  102c84:	ee                   	out    %al,(%dx)
  102c85:	89 d8                	mov    %ebx,%eax
  102c87:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);             // read IRR by default

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
  102c88:	0f b7 05 20 93 10 00 	movzwl 0x109320,%eax
  102c8f:	66 83 f8 ff          	cmp    $0xffffffff,%ax
  102c93:	74 0a                	je     102c9f <picinit+0x8f>
  102c95:	b2 21                	mov    $0x21,%dl
  102c97:	ee                   	out    %al,(%dx)
  102c98:	66 c1 e8 08          	shr    $0x8,%ax
  102c9c:	b2 a1                	mov    $0xa1,%dl
  102c9e:	ee                   	out    %al,(%dx)
    picsetmask(irqmask);
}
  102c9f:	8b 1c 24             	mov    (%esp),%ebx
  102ca2:	8b 74 24 04          	mov    0x4(%esp),%esi
  102ca6:	8b 7c 24 08          	mov    0x8(%esp),%edi
  102caa:	89 ec                	mov    %ebp,%esp
  102cac:	5d                   	pop    %ebp
  102cad:	c3                   	ret    
  102cae:	90                   	nop
  102caf:	90                   	nop

00102cb0 <piperead>:
  return n;
}

int
piperead(struct pipe *p, char *addr, int n)
{
  102cb0:	55                   	push   %ebp
  102cb1:	89 e5                	mov    %esp,%ebp
  102cb3:	57                   	push   %edi
  102cb4:	56                   	push   %esi
  102cb5:	53                   	push   %ebx
  102cb6:	83 ec 1c             	sub    $0x1c,%esp
  102cb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102cbc:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  acquire(&p->lock);
  102cbf:	89 1c 24             	mov    %ebx,(%esp)
  102cc2:	e8 59 11 00 00       	call   103e20 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102cc7:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102ccd:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102cd3:	75 58                	jne    102d2d <piperead+0x7d>
  102cd5:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102cdb:	85 f6                	test   %esi,%esi
  102cdd:	74 4e                	je     102d2d <piperead+0x7d>
    if(proc->killed){
  102cdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102ce5:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
  102ceb:	8b 48 24             	mov    0x24(%eax),%ecx
  102cee:	85 c9                	test   %ecx,%ecx
  102cf0:	74 21                	je     102d13 <piperead+0x63>
  102cf2:	e9 99 00 00 00       	jmp    102d90 <piperead+0xe0>
  102cf7:	90                   	nop
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102cf8:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
  102cfe:	85 c0                	test   %eax,%eax
  102d00:	74 2b                	je     102d2d <piperead+0x7d>
    if(proc->killed){
  102d02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102d08:	8b 50 24             	mov    0x24(%eax),%edx
  102d0b:	85 d2                	test   %edx,%edx
  102d0d:	0f 85 7d 00 00 00    	jne    102d90 <piperead+0xe0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102d13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102d17:	89 34 24             	mov    %esi,(%esp)
  102d1a:	e8 91 05 00 00       	call   1032b0 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102d1f:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102d25:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102d2b:	74 cb                	je     102cf8 <piperead+0x48>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d2d:	85 ff                	test   %edi,%edi
  102d2f:	7e 76                	jle    102da7 <piperead+0xf7>
    if(p->nread == p->nwrite)
  102d31:	31 f6                	xor    %esi,%esi
  102d33:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102d39:	75 0d                	jne    102d48 <piperead+0x98>
  102d3b:	eb 6a                	jmp    102da7 <piperead+0xf7>
  102d3d:	8d 76 00             	lea    0x0(%esi),%esi
  102d40:	39 93 38 02 00 00    	cmp    %edx,0x238(%ebx)
  102d46:	74 22                	je     102d6a <piperead+0xba>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102d48:	89 d0                	mov    %edx,%eax
  102d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  102d4d:	83 c2 01             	add    $0x1,%edx
  102d50:	25 ff 01 00 00       	and    $0x1ff,%eax
  102d55:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
  102d5a:	88 04 31             	mov    %al,(%ecx,%esi,1)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d5d:	83 c6 01             	add    $0x1,%esi
  102d60:	39 f7                	cmp    %esi,%edi
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102d62:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d68:	7f d6                	jg     102d40 <piperead+0x90>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  102d6a:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  102d70:	89 04 24             	mov    %eax,(%esp)
  102d73:	e8 08 04 00 00       	call   103180 <wakeup>
  release(&p->lock);
  102d78:	89 1c 24             	mov    %ebx,(%esp)
  102d7b:	e8 50 10 00 00       	call   103dd0 <release>
  return i;
}
  102d80:	83 c4 1c             	add    $0x1c,%esp
  102d83:	89 f0                	mov    %esi,%eax
  102d85:	5b                   	pop    %ebx
  102d86:	5e                   	pop    %esi
  102d87:	5f                   	pop    %edi
  102d88:	5d                   	pop    %ebp
  102d89:	c3                   	ret    
  102d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
      release(&p->lock);
  102d90:	be ff ff ff ff       	mov    $0xffffffff,%esi
  102d95:	89 1c 24             	mov    %ebx,(%esp)
  102d98:	e8 33 10 00 00       	call   103dd0 <release>
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
  102d9d:	83 c4 1c             	add    $0x1c,%esp
  102da0:	89 f0                	mov    %esi,%eax
  102da2:	5b                   	pop    %ebx
  102da3:	5e                   	pop    %esi
  102da4:	5f                   	pop    %edi
  102da5:	5d                   	pop    %ebp
  102da6:	c3                   	ret    
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102da7:	31 f6                	xor    %esi,%esi
  102da9:	eb bf                	jmp    102d6a <piperead+0xba>
  102dab:	90                   	nop
  102dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00102db0 <pipewrite>:
    release(&p->lock);
}

int
pipewrite(struct pipe *p, char *addr, int n)
{
  102db0:	55                   	push   %ebp
  102db1:	89 e5                	mov    %esp,%ebp
  102db3:	57                   	push   %edi
  102db4:	56                   	push   %esi
  102db5:	53                   	push   %ebx
  102db6:	83 ec 3c             	sub    $0x3c,%esp
  102db9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
  102dbc:	89 1c 24             	mov    %ebx,(%esp)
  102dbf:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
  102dc5:	e8 56 10 00 00       	call   103e20 <acquire>
  for(i = 0; i < n; i++){
  102dca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  102dcd:	85 c9                	test   %ecx,%ecx
  102dcf:	0f 8e 8d 00 00 00    	jle    102e62 <pipewrite+0xb2>
  102dd5:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102ddb:	8d bb 38 02 00 00    	lea    0x238(%ebx),%edi
  102de1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  102de8:	eb 37                	jmp    102e21 <pipewrite+0x71>
  102dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
  102df0:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102df6:	85 c0                	test   %eax,%eax
  102df8:	74 7e                	je     102e78 <pipewrite+0xc8>
  102dfa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102e00:	8b 50 24             	mov    0x24(%eax),%edx
  102e03:	85 d2                	test   %edx,%edx
  102e05:	75 71                	jne    102e78 <pipewrite+0xc8>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
  102e07:	89 34 24             	mov    %esi,(%esp)
  102e0a:	e8 71 03 00 00       	call   103180 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102e0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102e13:	89 3c 24             	mov    %edi,(%esp)
  102e16:	e8 95 04 00 00       	call   1032b0 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
  102e1b:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
  102e21:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102e27:	81 c2 00 02 00 00    	add    $0x200,%edx
  102e2d:	39 d0                	cmp    %edx,%eax
  102e2f:	74 bf                	je     102df0 <pipewrite+0x40>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  102e31:	89 c2                	mov    %eax,%edx
  102e33:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102e36:	83 c0 01             	add    $0x1,%eax
  102e39:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  102e3f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e45:	0f b6 0c 0a          	movzbl (%edx,%ecx,1),%ecx
  102e49:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e4c:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
  102e50:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
  102e56:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  102e5a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102e5d:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  102e60:	7f bf                	jg     102e21 <pipewrite+0x71>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  102e62:	89 34 24             	mov    %esi,(%esp)
  102e65:	e8 16 03 00 00       	call   103180 <wakeup>
  release(&p->lock);
  102e6a:	89 1c 24             	mov    %ebx,(%esp)
  102e6d:	e8 5e 0f 00 00       	call   103dd0 <release>
  return n;
  102e72:	eb 13                	jmp    102e87 <pipewrite+0xd7>
  102e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
  102e78:	89 1c 24             	mov    %ebx,(%esp)
  102e7b:	e8 50 0f 00 00       	call   103dd0 <release>
  102e80:	c7 45 10 ff ff ff ff 	movl   $0xffffffff,0x10(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
  102e87:	8b 45 10             	mov    0x10(%ebp),%eax
  102e8a:	83 c4 3c             	add    $0x3c,%esp
  102e8d:	5b                   	pop    %ebx
  102e8e:	5e                   	pop    %esi
  102e8f:	5f                   	pop    %edi
  102e90:	5d                   	pop    %ebp
  102e91:	c3                   	ret    
  102e92:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  102e99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102ea0 <pipeclose>:
  return -1;
}

void
pipeclose(struct pipe *p, int writable)
{
  102ea0:	55                   	push   %ebp
  102ea1:	89 e5                	mov    %esp,%ebp
  102ea3:	83 ec 18             	sub    $0x18,%esp
  102ea6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  102ea9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102eac:	89 75 fc             	mov    %esi,-0x4(%ebp)
  102eaf:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
  102eb2:	89 1c 24             	mov    %ebx,(%esp)
  102eb5:	e8 66 0f 00 00       	call   103e20 <acquire>
  if(writable){
  102eba:	85 f6                	test   %esi,%esi
  102ebc:	74 42                	je     102f00 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
  102ebe:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
void
pipeclose(struct pipe *p, int writable)
{
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
  102ec4:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
  102ecb:	00 00 00 
    wakeup(&p->nread);
  102ece:	89 04 24             	mov    %eax,(%esp)
  102ed1:	e8 aa 02 00 00       	call   103180 <wakeup>
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
  102ed6:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102edc:	85 c0                	test   %eax,%eax
  102ede:	75 0a                	jne    102eea <pipeclose+0x4a>
  102ee0:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102ee6:	85 f6                	test   %esi,%esi
  102ee8:	74 36                	je     102f20 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102eea:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  102eed:	8b 75 fc             	mov    -0x4(%ebp),%esi
  102ef0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102ef3:	89 ec                	mov    %ebp,%esp
  102ef5:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102ef6:	e9 d5 0e 00 00       	jmp    103dd0 <release>
  102efb:	90                   	nop
  102efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  102f00:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
  102f06:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
  102f0d:	00 00 00 
    wakeup(&p->nwrite);
  102f10:	89 04 24             	mov    %eax,(%esp)
  102f13:	e8 68 02 00 00       	call   103180 <wakeup>
  102f18:	eb bc                	jmp    102ed6 <pipeclose+0x36>
  102f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
  102f20:	89 1c 24             	mov    %ebx,(%esp)
  102f23:	e8 a8 0e 00 00       	call   103dd0 <release>
    kfree((char*)p);
  } else
    release(&p->lock);
}
  102f28:	8b 75 fc             	mov    -0x4(%ebp),%esi
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102f2b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  } else
    release(&p->lock);
}
  102f2e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102f31:	89 ec                	mov    %ebp,%esp
  102f33:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102f34:	e9 a7 f3 ff ff       	jmp    1022e0 <kfree>
  102f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102f40 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
  102f40:	55                   	push   %ebp
  102f41:	89 e5                	mov    %esp,%ebp
  102f43:	57                   	push   %edi
  102f44:	56                   	push   %esi
  102f45:	53                   	push   %ebx
  102f46:	83 ec 1c             	sub    $0x1c,%esp
  102f49:	8b 75 08             	mov    0x8(%ebp),%esi
  102f4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
  102f4f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  102f55:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
  102f5b:	e8 f0 df ff ff       	call   100f50 <filealloc>
  102f60:	85 c0                	test   %eax,%eax
  102f62:	89 06                	mov    %eax,(%esi)
  102f64:	0f 84 9c 00 00 00    	je     103006 <pipealloc+0xc6>
  102f6a:	e8 e1 df ff ff       	call   100f50 <filealloc>
  102f6f:	85 c0                	test   %eax,%eax
  102f71:	89 03                	mov    %eax,(%ebx)
  102f73:	0f 84 7f 00 00 00    	je     102ff8 <pipealloc+0xb8>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
  102f79:	e8 22 f3 ff ff       	call   1022a0 <kalloc>
  102f7e:	85 c0                	test   %eax,%eax
  102f80:	89 c7                	mov    %eax,%edi
  102f82:	74 74                	je     102ff8 <pipealloc+0xb8>
    goto bad;
  p->readopen = 1;
  102f84:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
  102f8b:	00 00 00 
  p->writeopen = 1;
  102f8e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
  102f95:	00 00 00 
  p->nwrite = 0;
  102f98:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
  102f9f:	00 00 00 
  p->nread = 0;
  102fa2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
  102fa9:	00 00 00 
  initlock(&p->lock, "pipe");
  102fac:	89 04 24             	mov    %eax,(%esp)
  102faf:	c7 44 24 04 4c 6c 10 	movl   $0x106c4c,0x4(%esp)
  102fb6:	00 
  102fb7:	e8 d4 0c 00 00       	call   103c90 <initlock>
  (*f0)->type = FD_PIPE;
  102fbc:	8b 06                	mov    (%esi),%eax
  102fbe:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
  102fc4:	8b 06                	mov    (%esi),%eax
  102fc6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
  102fca:	8b 06                	mov    (%esi),%eax
  102fcc:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
  102fd0:	8b 06                	mov    (%esi),%eax
  102fd2:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
  102fd5:	8b 03                	mov    (%ebx),%eax
  102fd7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
  102fdd:	8b 03                	mov    (%ebx),%eax
  102fdf:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
  102fe3:	8b 03                	mov    (%ebx),%eax
  102fe5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
  102fe9:	8b 03                	mov    (%ebx),%eax
  102feb:	89 78 0c             	mov    %edi,0xc(%eax)
  102fee:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
  102ff0:	83 c4 1c             	add    $0x1c,%esp
  102ff3:	5b                   	pop    %ebx
  102ff4:	5e                   	pop    %esi
  102ff5:	5f                   	pop    %edi
  102ff6:	5d                   	pop    %ebp
  102ff7:	c3                   	ret    
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
  102ff8:	8b 06                	mov    (%esi),%eax
  102ffa:	85 c0                	test   %eax,%eax
  102ffc:	74 08                	je     103006 <pipealloc+0xc6>
    fileclose(*f0);
  102ffe:	89 04 24             	mov    %eax,(%esp)
  103001:	e8 ca df ff ff       	call   100fd0 <fileclose>
  if(*f1)
  103006:	8b 13                	mov    (%ebx),%edx
  103008:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10300d:	85 d2                	test   %edx,%edx
  10300f:	74 df                	je     102ff0 <pipealloc+0xb0>
    fileclose(*f1);
  103011:	89 14 24             	mov    %edx,(%esp)
  103014:	e8 b7 df ff ff       	call   100fd0 <fileclose>
  103019:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10301e:	eb d0                	jmp    102ff0 <pipealloc+0xb0>

00103020 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  103020:	55                   	push   %ebp
  103021:	89 e5                	mov    %esp,%ebp
  103023:	57                   	push   %edi
  103024:	56                   	push   %esi
  103025:	53                   	push   %ebx

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
  103026:	bb 54 e1 10 00       	mov    $0x10e154,%ebx
{
  10302b:	83 ec 4c             	sub    $0x4c,%esp
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  10302e:	8d 7d c0             	lea    -0x40(%ebp),%edi
  103031:	eb 4e                	jmp    103081 <procdump+0x61>
  103033:	90                   	nop
  103034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  103038:	8b 04 85 e8 6d 10 00 	mov    0x106de8(,%eax,4),%eax
  10303f:	85 c0                	test   %eax,%eax
  103041:	74 4a                	je     10308d <procdump+0x6d>
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
  103043:	8b 53 10             	mov    0x10(%ebx),%edx
  103046:	8d 4b 6c             	lea    0x6c(%ebx),%ecx
  103049:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10304d:	89 44 24 08          	mov    %eax,0x8(%esp)
  103051:	c7 04 24 55 6c 10 00 	movl   $0x106c55,(%esp)
  103058:	89 54 24 04          	mov    %edx,0x4(%esp)
  10305c:	e8 1f d5 ff ff       	call   100580 <cprintf>
    if(p->state == SLEEPING){
  103061:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
  103065:	74 31                	je     103098 <procdump+0x78>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  103067:	c7 04 24 d6 6b 10 00 	movl   $0x106bd6,(%esp)
  10306e:	e8 0d d5 ff ff       	call   100580 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103073:	81 c3 84 00 00 00    	add    $0x84,%ebx
  103079:	81 fb 54 02 11 00    	cmp    $0x110254,%ebx
  10307f:	74 57                	je     1030d8 <procdump+0xb8>
    if(p->state == UNUSED)
  103081:	8b 43 0c             	mov    0xc(%ebx),%eax
  103084:	85 c0                	test   %eax,%eax
  103086:	74 eb                	je     103073 <procdump+0x53>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  103088:	83 f8 05             	cmp    $0x5,%eax
  10308b:	76 ab                	jbe    103038 <procdump+0x18>
  10308d:	b8 51 6c 10 00       	mov    $0x106c51,%eax
  103092:	eb af                	jmp    103043 <procdump+0x23>
  103094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  103098:	8b 43 1c             	mov    0x1c(%ebx),%eax
  10309b:	31 f6                	xor    %esi,%esi
  10309d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1030a1:	8b 40 0c             	mov    0xc(%eax),%eax
  1030a4:	83 c0 08             	add    $0x8,%eax
  1030a7:	89 04 24             	mov    %eax,(%esp)
  1030aa:	e8 01 0c 00 00       	call   103cb0 <getcallerpcs>
  1030af:	90                   	nop
      for(i=0; i<10 && pc[i] != 0; i++)
  1030b0:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  1030b3:	85 c0                	test   %eax,%eax
  1030b5:	74 b0                	je     103067 <procdump+0x47>
  1030b7:	83 c6 01             	add    $0x1,%esi
        cprintf(" %p", pc[i]);
  1030ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030be:	c7 04 24 ca 67 10 00 	movl   $0x1067ca,(%esp)
  1030c5:	e8 b6 d4 ff ff       	call   100580 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
  1030ca:	83 fe 0a             	cmp    $0xa,%esi
  1030cd:	75 e1                	jne    1030b0 <procdump+0x90>
  1030cf:	eb 96                	jmp    103067 <procdump+0x47>
  1030d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
  1030d8:	83 c4 4c             	add    $0x4c,%esp
  1030db:	5b                   	pop    %ebx
  1030dc:	5e                   	pop    %esi
  1030dd:	5f                   	pop    %edi
  1030de:	5d                   	pop    %ebp
  1030df:	90                   	nop
  1030e0:	c3                   	ret    
  1030e1:	eb 0d                	jmp    1030f0 <kill>
  1030e3:	90                   	nop
  1030e4:	90                   	nop
  1030e5:	90                   	nop
  1030e6:	90                   	nop
  1030e7:	90                   	nop
  1030e8:	90                   	nop
  1030e9:	90                   	nop
  1030ea:	90                   	nop
  1030eb:	90                   	nop
  1030ec:	90                   	nop
  1030ed:	90                   	nop
  1030ee:	90                   	nop
  1030ef:	90                   	nop

001030f0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  1030f0:	55                   	push   %ebp
  1030f1:	89 e5                	mov    %esp,%ebp
  1030f3:	53                   	push   %ebx
  1030f4:	83 ec 14             	sub    $0x14,%esp
  1030f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
  1030fa:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  103101:	e8 1a 0d 00 00       	call   103e20 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  103106:	8b 15 64 e1 10 00    	mov    0x10e164,%edx

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
  10310c:	b8 d8 e1 10 00       	mov    $0x10e1d8,%eax
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  103111:	39 da                	cmp    %ebx,%edx
  103113:	75 0f                	jne    103124 <kill+0x34>
  103115:	eb 60                	jmp    103177 <kill+0x87>
  103117:	90                   	nop
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103118:	05 84 00 00 00       	add    $0x84,%eax
  10311d:	3d 54 02 11 00       	cmp    $0x110254,%eax
  103122:	74 3c                	je     103160 <kill+0x70>
    if(p->pid == pid){
  103124:	8b 50 10             	mov    0x10(%eax),%edx
  103127:	39 da                	cmp    %ebx,%edx
  103129:	75 ed                	jne    103118 <kill+0x28>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  10312b:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
  10312f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  103136:	74 18                	je     103150 <kill+0x60>
        p->state = RUNNABLE;
      release(&ptable.lock);
  103138:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  10313f:	e8 8c 0c 00 00       	call   103dd0 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  103144:	83 c4 14             	add    $0x14,%esp
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
  103147:	31 c0                	xor    %eax,%eax
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  103149:	5b                   	pop    %ebx
  10314a:	5d                   	pop    %ebp
  10314b:	c3                   	ret    
  10314c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
  103150:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  103157:	eb df                	jmp    103138 <kill+0x48>
  103159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  103160:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  103167:	e8 64 0c 00 00       	call   103dd0 <release>
  return -1;
}
  10316c:	83 c4 14             	add    $0x14,%esp
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  10316f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
  103174:	5b                   	pop    %ebx
  103175:	5d                   	pop    %ebp
  103176:	c3                   	ret    
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  103177:	b8 54 e1 10 00       	mov    $0x10e154,%eax
  10317c:	eb ad                	jmp    10312b <kill+0x3b>
  10317e:	66 90                	xchg   %ax,%ax

00103180 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  103180:	55                   	push   %ebp
  103181:	89 e5                	mov    %esp,%ebp
  103183:	53                   	push   %ebx
  103184:	83 ec 14             	sub    $0x14,%esp
  103187:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
  10318a:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  103191:	e8 8a 0c 00 00       	call   103e20 <acquire>
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
  103196:	b8 54 e1 10 00       	mov    $0x10e154,%eax
  10319b:	eb 0f                	jmp    1031ac <wakeup+0x2c>
  10319d:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1031a0:	05 84 00 00 00       	add    $0x84,%eax
  1031a5:	3d 54 02 11 00       	cmp    $0x110254,%eax
  1031aa:	74 24                	je     1031d0 <wakeup+0x50>
    if(p->state == SLEEPING && p->chan == chan)
  1031ac:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  1031b0:	75 ee                	jne    1031a0 <wakeup+0x20>
  1031b2:	3b 58 20             	cmp    0x20(%eax),%ebx
  1031b5:	75 e9                	jne    1031a0 <wakeup+0x20>
      p->state = RUNNABLE;
  1031b7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1031be:	05 84 00 00 00       	add    $0x84,%eax
  1031c3:	3d 54 02 11 00       	cmp    $0x110254,%eax
  1031c8:	75 e2                	jne    1031ac <wakeup+0x2c>
  1031ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  1031d0:	c7 45 08 20 e1 10 00 	movl   $0x10e120,0x8(%ebp)
}
  1031d7:	83 c4 14             	add    $0x14,%esp
  1031da:	5b                   	pop    %ebx
  1031db:	5d                   	pop    %ebp
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  1031dc:	e9 ef 0b 00 00       	jmp    103dd0 <release>
  1031e1:	eb 0d                	jmp    1031f0 <forkret>
  1031e3:	90                   	nop
  1031e4:	90                   	nop
  1031e5:	90                   	nop
  1031e6:	90                   	nop
  1031e7:	90                   	nop
  1031e8:	90                   	nop
  1031e9:	90                   	nop
  1031ea:	90                   	nop
  1031eb:	90                   	nop
  1031ec:	90                   	nop
  1031ed:	90                   	nop
  1031ee:	90                   	nop
  1031ef:	90                   	nop

001031f0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  1031f0:	55                   	push   %ebp
  1031f1:	89 e5                	mov    %esp,%ebp
  1031f3:	83 ec 18             	sub    $0x18,%esp
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
  1031f6:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  1031fd:	e8 ce 0b 00 00       	call   103dd0 <release>
  
  // Return to "caller", actually trapret (see allocproc).
}
  103202:	c9                   	leave  
  103203:	c3                   	ret    
  103204:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10320a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103210 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  103210:	55                   	push   %ebp
  103211:	89 e5                	mov    %esp,%ebp
  103213:	53                   	push   %ebx
  103214:	83 ec 14             	sub    $0x14,%esp
  int intena;

  if(!holding(&ptable.lock))
  103217:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  10321e:	e8 ed 0a 00 00       	call   103d10 <holding>
  103223:	85 c0                	test   %eax,%eax
  103225:	74 4d                	je     103274 <sched+0x64>
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
  103227:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10322d:	83 b8 ac 00 00 00 01 	cmpl   $0x1,0xac(%eax)
  103234:	75 62                	jne    103298 <sched+0x88>
    panic("sched locks");
  if(proc->state == RUNNING)
  103236:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10323d:	83 7a 0c 04          	cmpl   $0x4,0xc(%edx)
  103241:	74 49                	je     10328c <sched+0x7c>

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103243:	9c                   	pushf  
  103244:	59                   	pop    %ecx
    panic("sched running");
  if(readeflags()&FL_IF)
  103245:	80 e5 02             	and    $0x2,%ch
  103248:	75 36                	jne    103280 <sched+0x70>
    panic("sched interruptible");
  intena = cpu->intena;
  10324a:	8b 98 b0 00 00 00    	mov    0xb0(%eax),%ebx
  swtch(&proc->context, cpu->scheduler);
  103250:	83 c2 1c             	add    $0x1c,%edx
  103253:	8b 40 04             	mov    0x4(%eax),%eax
  103256:	89 14 24             	mov    %edx,(%esp)
  103259:	89 44 24 04          	mov    %eax,0x4(%esp)
  10325d:	e8 5a 0e 00 00       	call   1040bc <swtch>
  cpu->intena = intena;
  103262:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103268:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  10326e:	83 c4 14             	add    $0x14,%esp
  103271:	5b                   	pop    %ebx
  103272:	5d                   	pop    %ebp
  103273:	c3                   	ret    
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  103274:	c7 04 24 5e 6c 10 00 	movl   $0x106c5e,(%esp)
  10327b:	e8 f0 d6 ff ff       	call   100970 <panic>
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  103280:	c7 04 24 8a 6c 10 00 	movl   $0x106c8a,(%esp)
  103287:	e8 e4 d6 ff ff       	call   100970 <panic>
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  10328c:	c7 04 24 7c 6c 10 00 	movl   $0x106c7c,(%esp)
  103293:	e8 d8 d6 ff ff       	call   100970 <panic>
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  103298:	c7 04 24 70 6c 10 00 	movl   $0x106c70,(%esp)
  10329f:	e8 cc d6 ff ff       	call   100970 <panic>
  1032a4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1032aa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001032b0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  1032b0:	55                   	push   %ebp
  1032b1:	89 e5                	mov    %esp,%ebp
  1032b3:	56                   	push   %esi
  1032b4:	53                   	push   %ebx
  1032b5:	83 ec 10             	sub    $0x10,%esp
  if(proc == 0)
  1032b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  1032be:	8b 75 08             	mov    0x8(%ebp),%esi
  1032c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
  1032c4:	85 c0                	test   %eax,%eax
  1032c6:	0f 84 a1 00 00 00    	je     10336d <sleep+0xbd>
    panic("sleep");

  if(lk == 0)
  1032cc:	85 db                	test   %ebx,%ebx
  1032ce:	0f 84 8d 00 00 00    	je     103361 <sleep+0xb1>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
  1032d4:	81 fb 20 e1 10 00    	cmp    $0x10e120,%ebx
  1032da:	74 5c                	je     103338 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
  1032dc:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  1032e3:	e8 38 0b 00 00       	call   103e20 <acquire>
    release(lk);
  1032e8:	89 1c 24             	mov    %ebx,(%esp)
  1032eb:	e8 e0 0a 00 00       	call   103dd0 <release>
  }

  // Go to sleep.
  proc->chan = chan;
  1032f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032f6:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  1032f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1032ff:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  103306:	e8 05 ff ff ff       	call   103210 <sched>

  // Tidy up.
  proc->chan = 0;
  10330b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103311:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
  103318:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  10331f:	e8 ac 0a 00 00       	call   103dd0 <release>
    acquire(lk);
  103324:	89 5d 08             	mov    %ebx,0x8(%ebp)
  }
}
  103327:	83 c4 10             	add    $0x10,%esp
  10332a:	5b                   	pop    %ebx
  10332b:	5e                   	pop    %esi
  10332c:	5d                   	pop    %ebp
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  10332d:	e9 ee 0a 00 00       	jmp    103e20 <acquire>
  103332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  103338:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  10333b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103341:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  103348:	e8 c3 fe ff ff       	call   103210 <sched>

  // Tidy up.
  proc->chan = 0;
  10334d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103353:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}
  10335a:	83 c4 10             	add    $0x10,%esp
  10335d:	5b                   	pop    %ebx
  10335e:	5e                   	pop    %esi
  10335f:	5d                   	pop    %ebp
  103360:	c3                   	ret    
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");
  103361:	c7 04 24 a4 6c 10 00 	movl   $0x106ca4,(%esp)
  103368:	e8 03 d6 ff ff       	call   100970 <panic>
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");
  10336d:	c7 04 24 9e 6c 10 00 	movl   $0x106c9e,(%esp)
  103374:	e8 f7 d5 ff ff       	call   100970 <panic>
  103379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103380 <yield>:
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  103380:	55                   	push   %ebp
  103381:	89 e5                	mov    %esp,%ebp
  103383:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
  103386:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  10338d:	e8 8e 0a 00 00       	call   103e20 <acquire>
  proc->state = RUNNABLE;
  103392:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103398:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
  10339f:	e8 6c fe ff ff       	call   103210 <sched>
  release(&ptable.lock);
  1033a4:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  1033ab:	e8 20 0a 00 00       	call   103dd0 <release>
}
  1033b0:	c9                   	leave  
  1033b1:	c3                   	ret    
  1033b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1033b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001033c0 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  1033c0:	55                   	push   %ebp
  1033c1:	89 e5                	mov    %esp,%ebp
  1033c3:	53                   	push   %ebx
  1033c4:	83 ec 14             	sub    $0x14,%esp
  1033c7:	90                   	nop
}

static inline void
sti(void)
{
  asm volatile("sti");
  1033c8:	fb                   	sti    
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
  1033c9:	bb 54 e1 10 00       	mov    $0x10e154,%ebx
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
  1033ce:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  1033d5:	e8 46 0a 00 00       	call   103e20 <acquire>
  1033da:	eb 12                	jmp    1033ee <scheduler+0x2e>
  1033dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1033e0:	81 c3 84 00 00 00    	add    $0x84,%ebx
  1033e6:	81 fb 54 02 11 00    	cmp    $0x110254,%ebx
  1033ec:	74 5a                	je     103448 <scheduler+0x88>
      if(p->state != RUNNABLE)
  1033ee:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
  1033f2:	75 ec                	jne    1033e0 <scheduler+0x20>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
  1033f4:	65 89 1d 04 00 00 00 	mov    %ebx,%gs:0x4
      switchuvm(p);
  1033fb:	89 1c 24             	mov    %ebx,(%esp)
  1033fe:	e8 9d 31 00 00       	call   1065a0 <switchuvm>
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  103403:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
  103409:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103410:	81 c3 84 00 00 00    	add    $0x84,%ebx
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  103416:	8b 40 1c             	mov    0x1c(%eax),%eax
  103419:	89 44 24 04          	mov    %eax,0x4(%esp)
  10341d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103423:	83 c0 04             	add    $0x4,%eax
  103426:	89 04 24             	mov    %eax,(%esp)
  103429:	e8 8e 0c 00 00       	call   1040bc <swtch>
      switchkvm();
  10342e:	e8 fd 2a 00 00       	call   105f30 <switchkvm>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103433:	81 fb 54 02 11 00    	cmp    $0x110254,%ebx
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
  103439:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  103440:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103444:	75 a8                	jne    1033ee <scheduler+0x2e>
  103446:	66 90                	xchg   %ax,%ax

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
  103448:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  10344f:	e8 7c 09 00 00       	call   103dd0 <release>

  }
  103454:	e9 6f ff ff ff       	jmp    1033c8 <scheduler+0x8>
  103459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103460 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103460:	55                   	push   %ebp
  103461:	89 e5                	mov    %esp,%ebp
  103463:	53                   	push   %ebx
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  103464:	bb 54 e1 10 00       	mov    $0x10e154,%ebx

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103469:	83 ec 24             	sub    $0x24,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  10346c:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  103473:	e8 a8 09 00 00       	call   103e20 <acquire>
  103478:	31 c0                	xor    %eax,%eax
  10347a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103480:	81 fb 54 02 11 00    	cmp    $0x110254,%ebx
  103486:	72 30                	jb     1034b8 <wait+0x58>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
  103488:	85 c0                	test   %eax,%eax
  10348a:	74 5c                	je     1034e8 <wait+0x88>
  10348c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103492:	8b 50 24             	mov    0x24(%eax),%edx
  103495:	85 d2                	test   %edx,%edx
  103497:	75 4f                	jne    1034e8 <wait+0x88>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  103499:	bb 54 e1 10 00       	mov    $0x10e154,%ebx
  10349e:	89 04 24             	mov    %eax,(%esp)
  1034a1:	c7 44 24 04 20 e1 10 	movl   $0x10e120,0x4(%esp)
  1034a8:	00 
  1034a9:	e8 02 fe ff ff       	call   1032b0 <sleep>
  1034ae:	31 c0                	xor    %eax,%eax

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1034b0:	81 fb 54 02 11 00    	cmp    $0x110254,%ebx
  1034b6:	73 d0                	jae    103488 <wait+0x28>
      if(p->parent != proc)
  1034b8:	8b 53 14             	mov    0x14(%ebx),%edx
  1034bb:	65 3b 15 04 00 00 00 	cmp    %gs:0x4,%edx
  1034c2:	74 0c                	je     1034d0 <wait+0x70>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1034c4:	81 c3 84 00 00 00    	add    $0x84,%ebx
  1034ca:	eb b4                	jmp    103480 <wait+0x20>
  1034cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
  1034d0:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
  1034d4:	74 29                	je     1034ff <wait+0x9f>
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
  1034d6:	b8 01 00 00 00       	mov    $0x1,%eax
  1034db:	90                   	nop
  1034dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1034e0:	eb e2                	jmp    1034c4 <wait+0x64>
  1034e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
  1034e8:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  1034ef:	e8 dc 08 00 00       	call   103dd0 <release>
  1034f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
  1034f9:	83 c4 24             	add    $0x24,%esp
  1034fc:	5b                   	pop    %ebx
  1034fd:	5d                   	pop    %ebp
  1034fe:	c3                   	ret    
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
  1034ff:	8b 43 10             	mov    0x10(%ebx),%eax
        kfree(p->kstack);
  103502:	8b 53 08             	mov    0x8(%ebx),%edx
  103505:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103508:	89 14 24             	mov    %edx,(%esp)
  10350b:	e8 d0 ed ff ff       	call   1022e0 <kfree>
        p->kstack = 0;
        if (p->pgdir != p->parent->pgdir) {
  103510:	8b 4b 14             	mov    0x14(%ebx),%ecx
  103513:	8b 53 04             	mov    0x4(%ebx),%edx
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
  103516:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        if (p->pgdir != p->parent->pgdir) {
  10351d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103520:	3b 51 04             	cmp    0x4(%ecx),%edx
  103523:	74 0b                	je     103530 <wait+0xd0>
          freevm(p->pgdir);
  103525:	89 14 24             	mov    %edx,(%esp)
  103528:	e8 a3 2d 00 00       	call   1062d0 <freevm>
  10352d:	8b 45 f4             	mov    -0xc(%ebp),%eax
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
  103530:	89 45 f4             	mov    %eax,-0xc(%ebp)
        kfree(p->kstack);
        p->kstack = 0;
        if (p->pgdir != p->parent->pgdir) {
          freevm(p->pgdir);
        }
        p->state = UNUSED;
  103533:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->pid = 0;
  10353a:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
  103541:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
  103548:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
  10354c:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        release(&ptable.lock);
  103553:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  10355a:	e8 71 08 00 00       	call   103dd0 <release>
        return pid;
  10355f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103562:	eb 95                	jmp    1034f9 <wait+0x99>
  103564:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10356a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103570 <exit>:
  return pid;
}

void
exit(void)
{
  103570:	55                   	push   %ebp
  103571:	89 e5                	mov    %esp,%ebp
  103573:	56                   	push   %esi
  103574:	53                   	push   %ebx
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  103575:	31 db                	xor    %ebx,%ebx
  return pid;
}

void
exit(void)
{
  103577:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
  10357a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103581:	3b 15 c8 98 10 00    	cmp    0x1098c8,%edx
  103587:	0f 84 04 01 00 00    	je     103691 <exit+0x121>
  10358d:	8d 76 00             	lea    0x0(%esi),%esi
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
  103590:	8d 73 08             	lea    0x8(%ebx),%esi
  103593:	8b 44 b2 08          	mov    0x8(%edx,%esi,4),%eax
  103597:	85 c0                	test   %eax,%eax
  103599:	74 1d                	je     1035b8 <exit+0x48>
      fileclose(proc->ofile[fd]);
  10359b:	89 04 24             	mov    %eax,(%esp)
  10359e:	e8 2d da ff ff       	call   100fd0 <fileclose>
      proc->ofile[fd] = 0;
  1035a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1035a9:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
  1035b0:	00 
  1035b1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
  1035b8:	83 c3 01             	add    $0x1,%ebx
  1035bb:	83 fb 10             	cmp    $0x10,%ebx
  1035be:	75 d0                	jne    103590 <exit+0x20>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
  1035c0:	8b 42 68             	mov    0x68(%edx),%eax
  1035c3:	89 04 24             	mov    %eax,(%esp)
  1035c6:	e8 05 e3 ff ff       	call   1018d0 <iput>
  proc->cwd = 0;
  1035cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1035d1:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
  1035d8:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  1035df:	e8 3c 08 00 00       	call   103e20 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  1035e4:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  return pid;
}

void
exit(void)
  1035eb:	b8 54 e1 10 00       	mov    $0x10e154,%eax
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  1035f0:	8b 51 14             	mov    0x14(%ecx),%edx
  1035f3:	eb 0f                	jmp    103604 <exit+0x94>
  1035f5:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1035f8:	05 84 00 00 00       	add    $0x84,%eax
  1035fd:	3d 54 02 11 00       	cmp    $0x110254,%eax
  103602:	74 1e                	je     103622 <exit+0xb2>
    if(p->state == SLEEPING && p->chan == chan)
  103604:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  103608:	75 ee                	jne    1035f8 <exit+0x88>
  10360a:	3b 50 20             	cmp    0x20(%eax),%edx
  10360d:	75 e9                	jne    1035f8 <exit+0x88>
      p->state = RUNNABLE;
  10360f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103616:	05 84 00 00 00       	add    $0x84,%eax
  10361b:	3d 54 02 11 00       	cmp    $0x110254,%eax
  103620:	75 e2                	jne    103604 <exit+0x94>
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  103622:	8b 1d c8 98 10 00    	mov    0x1098c8,%ebx
  103628:	ba 54 e1 10 00       	mov    $0x10e154,%edx
  10362d:	eb 0f                	jmp    10363e <exit+0xce>
  10362f:	90                   	nop

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103630:	81 c2 84 00 00 00    	add    $0x84,%edx
  103636:	81 fa 54 02 11 00    	cmp    $0x110254,%edx
  10363c:	74 3a                	je     103678 <exit+0x108>
    if(p->parent == proc){
  10363e:	3b 4a 14             	cmp    0x14(%edx),%ecx
  103641:	75 ed                	jne    103630 <exit+0xc0>
      p->parent = initproc;
      if(p->state == ZOMBIE)
  103643:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  103647:	89 5a 14             	mov    %ebx,0x14(%edx)
      if(p->state == ZOMBIE)
  10364a:	75 e4                	jne    103630 <exit+0xc0>
  10364c:	b8 54 e1 10 00       	mov    $0x10e154,%eax
  103651:	eb 11                	jmp    103664 <exit+0xf4>
  103653:	90                   	nop
  103654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103658:	05 84 00 00 00       	add    $0x84,%eax
  10365d:	3d 54 02 11 00       	cmp    $0x110254,%eax
  103662:	74 cc                	je     103630 <exit+0xc0>
    if(p->state == SLEEPING && p->chan == chan)
  103664:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  103668:	75 ee                	jne    103658 <exit+0xe8>
  10366a:	3b 58 20             	cmp    0x20(%eax),%ebx
  10366d:	75 e9                	jne    103658 <exit+0xe8>
      p->state = RUNNABLE;
  10366f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  103676:	eb e0                	jmp    103658 <exit+0xe8>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  103678:	c7 41 0c 05 00 00 00 	movl   $0x5,0xc(%ecx)
  10367f:	90                   	nop
  sched();
  103680:	e8 8b fb ff ff       	call   103210 <sched>
  panic("zombie exit");
  103685:	c7 04 24 c2 6c 10 00 	movl   $0x106cc2,(%esp)
  10368c:	e8 df d2 ff ff       	call   100970 <panic>
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  103691:	c7 04 24 b5 6c 10 00 	movl   $0x106cb5,(%esp)
  103698:	e8 d3 d2 ff ff       	call   100970 <panic>
  10369d:	8d 76 00             	lea    0x0(%esi),%esi

001036a0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  1036a0:	55                   	push   %ebp
  1036a1:	89 e5                	mov    %esp,%ebp
  1036a3:	53                   	push   %ebx
  1036a4:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  1036a7:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  1036ae:	e8 6d 07 00 00       	call   103e20 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
  1036b3:	8b 1d 60 e1 10 00    	mov    0x10e160,%ebx
  1036b9:	85 db                	test   %ebx,%ebx
  1036bb:	0f 84 ad 00 00 00    	je     10376e <allocproc+0xce>
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
  1036c1:	bb d8 e1 10 00       	mov    $0x10e1d8,%ebx
  1036c6:	eb 12                	jmp    1036da <allocproc+0x3a>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1036c8:	81 c3 84 00 00 00    	add    $0x84,%ebx
  1036ce:	81 fb 54 02 11 00    	cmp    $0x110254,%ebx
  1036d4:	0f 84 7e 00 00 00    	je     103758 <allocproc+0xb8>
    if(p->state == UNUSED)
  1036da:	8b 4b 0c             	mov    0xc(%ebx),%ecx
  1036dd:	85 c9                	test   %ecx,%ecx
  1036df:	75 e7                	jne    1036c8 <allocproc+0x28>
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  1036e1:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
  1036e8:	a1 24 93 10 00       	mov    0x109324,%eax
  1036ed:	89 43 10             	mov    %eax,0x10(%ebx)
  1036f0:	83 c0 01             	add    $0x1,%eax
  1036f3:	a3 24 93 10 00       	mov    %eax,0x109324
  release(&ptable.lock);
  1036f8:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  1036ff:	e8 cc 06 00 00       	call   103dd0 <release>

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
  103704:	e8 97 eb ff ff       	call   1022a0 <kalloc>
  103709:	85 c0                	test   %eax,%eax
  10370b:	89 43 08             	mov    %eax,0x8(%ebx)
  10370e:	74 68                	je     103778 <allocproc+0xd8>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  103710:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
  103716:	89 53 18             	mov    %edx,0x18(%ebx)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
  103719:	c7 80 b0 0f 00 00 10 	movl   $0x105010,0xfb0(%eax)
  103720:	50 10 00 

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  103723:	05 9c 0f 00 00       	add    $0xf9c,%eax
  103728:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
  10372b:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  103732:	00 
  103733:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10373a:	00 
  10373b:	89 04 24             	mov    %eax,(%esp)
  10373e:	e8 7d 07 00 00       	call   103ec0 <memset>
  p->context->eip = (uint)forkret;
  103743:	8b 43 1c             	mov    0x1c(%ebx),%eax
  103746:	c7 40 10 f0 31 10 00 	movl   $0x1031f0,0x10(%eax)

  return p;
}
  10374d:	89 d8                	mov    %ebx,%eax
  10374f:	83 c4 14             	add    $0x14,%esp
  103752:	5b                   	pop    %ebx
  103753:	5d                   	pop    %ebp
  103754:	c3                   	ret    
  103755:	8d 76 00             	lea    0x0(%esi),%esi

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  103758:	31 db                	xor    %ebx,%ebx
  10375a:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  103761:	e8 6a 06 00 00       	call   103dd0 <release>
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}
  103766:	89 d8                	mov    %ebx,%eax
  103768:	83 c4 14             	add    $0x14,%esp
  10376b:	5b                   	pop    %ebx
  10376c:	5d                   	pop    %ebp
  10376d:	c3                   	ret    
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;
  10376e:	bb 54 e1 10 00       	mov    $0x10e154,%ebx
  103773:	e9 69 ff ff ff       	jmp    1036e1 <allocproc+0x41>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
  103778:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  10377f:	31 db                	xor    %ebx,%ebx
    return 0;
  103781:	eb ca                	jmp    10374d <allocproc+0xad>
  103783:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103789:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103790 <clone>:
  return pid;
}

int
clone(void)
{
  103790:	55                   	push   %ebp
  103791:	89 e5                	mov    %esp,%ebp
  103793:	57                   	push   %edi
  103794:	56                   	push   %esi
  char* stack;
  int i, pid, size;
  struct proc *np;
  cprintf("a\n");
  // Allocate process.
  if((np = allocproc()) == 0)
  103795:	be ff ff ff ff       	mov    $0xffffffff,%esi
  return pid;
}

int
clone(void)
{
  10379a:	53                   	push   %ebx
  10379b:	83 ec 2c             	sub    $0x2c,%esp
  char* stack;
  int i, pid, size;
  struct proc *np;
  cprintf("a\n");
  10379e:	c7 04 24 ce 6c 10 00 	movl   $0x106cce,(%esp)
  1037a5:	e8 d6 cd ff ff       	call   100580 <cprintf>
  // Allocate process.
  if((np = allocproc()) == 0)
  1037aa:	e8 f1 fe ff ff       	call   1036a0 <allocproc>
  1037af:	85 c0                	test   %eax,%eax
  1037b1:	89 c3                	mov    %eax,%ebx
  1037b3:	0f 84 1a 02 00 00    	je     1039d3 <clone+0x243>
    return -1;

  // Point page dir at parent's page dir (shared memory)
  np->pgdir = proc->pgdir;
  1037b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  // This might be an issue later.
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  1037bf:	b9 13 00 00 00       	mov    $0x13,%ecx
  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Point page dir at parent's page dir (shared memory)
  np->pgdir = proc->pgdir;
  1037c4:	8b 40 04             	mov    0x4(%eax),%eax
  1037c7:	89 43 04             	mov    %eax,0x4(%ebx)
  // This might be an issue later.
  np->sz = proc->sz;
  1037ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1037d0:	8b 00                	mov    (%eax),%eax
  1037d2:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
  1037d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1037da:	89 43 14             	mov    %eax,0x14(%ebx)
  *np->tf = *proc->tf;
  1037dd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  1037e4:	8b 43 18             	mov    0x18(%ebx),%eax
  1037e7:	8b 72 18             	mov    0x18(%edx),%esi
  1037ea:	89 c7                	mov    %eax,%edi
  1037ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  
  if(argint(1, &size) < 0 || size <= 0 || argptr(0, &stack, size) < 0) {
  1037ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1037f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1037f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037fc:	e8 5f 09 00 00       	call   104160 <argint>
  103801:	85 c0                	test   %eax,%eax
  103803:	0f 88 d4 01 00 00    	js     1039dd <clone+0x24d>
  103809:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10380c:	85 c0                	test   %eax,%eax
  10380e:	0f 8e c9 01 00 00    	jle    1039dd <clone+0x24d>
  103814:	89 44 24 08          	mov    %eax,0x8(%esp)
  103818:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  10381b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10381f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  103826:	e8 75 09 00 00       	call   1041a0 <argptr>
  10382b:	85 c0                	test   %eax,%eax
  10382d:	0f 88 aa 01 00 00    	js     1039dd <clone+0x24d>
    return -1;
  }
//   cprintf("stack inside %d\n", stack[0]);

  // Clear %eax so that clone returns 0 in the child.
  np->tf->eax = 0;
  103833:	8b 43 18             	mov    0x18(%ebx),%eax
  103836:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  //memmove(stack, proc->pstack - size, size);
  char *s = (char *) proc->pstack - size;
  10383d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  char *d = (char *) stack;
  103843:	8b 75 e4             	mov    -0x1c(%ebp),%esi

  // Clear %eax so that clone returns 0 in the child.
  np->tf->eax = 0;

  //memmove(stack, proc->pstack - size, size);
  char *s = (char *) proc->pstack - size;
  103846:	8b 48 7c             	mov    0x7c(%eax),%ecx
  char *d = (char *) stack;
  103849:	31 c0                	xor    %eax,%eax

  // Clear %eax so that clone returns 0 in the child.
  np->tf->eax = 0;

  //memmove(stack, proc->pstack - size, size);
  char *s = (char *) proc->pstack - size;
  10384b:	2b 4d e0             	sub    -0x20(%ebp),%ecx
  10384e:	66 90                	xchg   %ax,%ax
  char *d = (char *) stack;
  for (i = 0; i < 4096; i++) {
    *d++ = *s++;
  103850:	0f b6 14 01          	movzbl (%ecx,%eax,1),%edx
  103854:	88 14 06             	mov    %dl,(%esi,%eax,1)
  np->tf->eax = 0;

  //memmove(stack, proc->pstack - size, size);
  char *s = (char *) proc->pstack - size;
  char *d = (char *) stack;
  for (i = 0; i < 4096; i++) {
  103857:	83 c0 01             	add    $0x1,%eax
  10385a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  10385f:	75 ef                	jne    103850 <clone+0xc0>
  uint k;
  for (j = (uint *)stack, k =0; k < size/10 - 1; j++, k++) {
    cprintf("%x\n" , *j);
  }*/

  int offset = (uint)proc->pstack - (uint)proc->tf->esp;
  103861:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103867:	8b 50 18             	mov    0x18(%eax),%edx
  10386a:	8b 70 7c             	mov    0x7c(%eax),%esi
  cprintf("offset = %x, size = %x\n", offset, size);
  10386d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  uint k;
  for (j = (uint *)stack, k =0; k < size/10 - 1; j++, k++) {
    cprintf("%x\n" , *j);
  }*/

  int offset = (uint)proc->pstack - (uint)proc->tf->esp;
  103870:	2b 72 44             	sub    0x44(%edx),%esi
  cprintf("offset = %x, size = %x\n", offset, size);
  103873:	c7 04 24 d1 6c 10 00 	movl   $0x106cd1,(%esp)
  10387a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10387e:	89 74 24 04          	mov    %esi,0x4(%esp)
  103882:	e8 f9 cc ff ff       	call   100580 <cprintf>
  cprintf("%x %x %x\n", proc->pstack, stack, proc->tf->esp);
  103887:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10388d:	8b 50 18             	mov    0x18(%eax),%edx
  103890:	8b 52 44             	mov    0x44(%edx),%edx
  103893:	89 54 24 0c          	mov    %edx,0xc(%esp)
  103897:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10389a:	89 54 24 08          	mov    %edx,0x8(%esp)
  10389e:	8b 40 7c             	mov    0x7c(%eax),%eax
  1038a1:	c7 04 24 e9 6c 10 00 	movl   $0x106ce9,(%esp)
  1038a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1038ac:	e8 cf cc ff ff       	call   100580 <cprintf>
  np->tf->esp = (uint)stack + PGSIZE;
  1038b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1038b4:	8b 43 18             	mov    0x18(%ebx),%eax
  1038b7:	81 c2 00 10 00 00    	add    $0x1000,%edx
  1038bd:	89 50 44             	mov    %edx,0x44(%eax)
  cprintf("PGSIZE:%x ALMOST NEW ESP:%x\n", PGSIZE, np->tf->esp);
  1038c0:	8b 43 18             	mov    0x18(%ebx),%eax
  1038c3:	8b 40 44             	mov    0x44(%eax),%eax
  1038c6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1038cd:	00 
  1038ce:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1038d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1038d9:	e8 a2 cc ff ff       	call   100580 <cprintf>
  np->tf->esp -= offset;
  1038de:	8b 43 18             	mov    0x18(%ebx),%eax
  1038e1:	29 70 44             	sub    %esi,0x44(%eax)
  cprintf("PGSIZE:%x NEW ESP:%x\n", PGSIZE, np->tf->esp);

  cprintf("Child esp points to: %x\n", *(uint *)np->tf->esp);
  cprintf("Child esp + 4 points to: %x\n", *((uint *)np->tf->esp + 4));
  cprintf("Child esp + 8 points to: %x\n", *((uint *)np->tf->esp + 8));
  cprintf("Parent esp points to: %x\n", *(uint *)proc->tf->esp);
  1038e4:	31 f6                	xor    %esi,%esi
  cprintf("offset = %x, size = %x\n", offset, size);
  cprintf("%x %x %x\n", proc->pstack, stack, proc->tf->esp);
  np->tf->esp = (uint)stack + PGSIZE;
  cprintf("PGSIZE:%x ALMOST NEW ESP:%x\n", PGSIZE, np->tf->esp);
  np->tf->esp -= offset;
  cprintf("PGSIZE:%x NEW ESP:%x\n", PGSIZE, np->tf->esp);
  1038e6:	8b 43 18             	mov    0x18(%ebx),%eax
  1038e9:	8b 40 44             	mov    0x44(%eax),%eax
  1038ec:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1038f3:	00 
  1038f4:	c7 04 24 10 6d 10 00 	movl   $0x106d10,(%esp)
  1038fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1038ff:	e8 7c cc ff ff       	call   100580 <cprintf>

  cprintf("Child esp points to: %x\n", *(uint *)np->tf->esp);
  103904:	8b 43 18             	mov    0x18(%ebx),%eax
  103907:	8b 40 44             	mov    0x44(%eax),%eax
  10390a:	8b 00                	mov    (%eax),%eax
  10390c:	c7 04 24 26 6d 10 00 	movl   $0x106d26,(%esp)
  103913:	89 44 24 04          	mov    %eax,0x4(%esp)
  103917:	e8 64 cc ff ff       	call   100580 <cprintf>
  cprintf("Child esp + 4 points to: %x\n", *((uint *)np->tf->esp + 4));
  10391c:	8b 43 18             	mov    0x18(%ebx),%eax
  10391f:	8b 40 44             	mov    0x44(%eax),%eax
  103922:	8b 40 10             	mov    0x10(%eax),%eax
  103925:	c7 04 24 3f 6d 10 00 	movl   $0x106d3f,(%esp)
  10392c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103930:	e8 4b cc ff ff       	call   100580 <cprintf>
  cprintf("Child esp + 8 points to: %x\n", *((uint *)np->tf->esp + 8));
  103935:	8b 43 18             	mov    0x18(%ebx),%eax
  103938:	8b 40 44             	mov    0x44(%eax),%eax
  10393b:	8b 40 20             	mov    0x20(%eax),%eax
  10393e:	c7 04 24 5c 6d 10 00 	movl   $0x106d5c,(%esp)
  103945:	89 44 24 04          	mov    %eax,0x4(%esp)
  103949:	e8 32 cc ff ff       	call   100580 <cprintf>
  cprintf("Parent esp points to: %x\n", *(uint *)proc->tf->esp);
  10394e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103954:	8b 40 18             	mov    0x18(%eax),%eax
  103957:	8b 40 44             	mov    0x44(%eax),%eax
  10395a:	8b 00                	mov    (%eax),%eax
  10395c:	c7 04 24 79 6d 10 00 	movl   $0x106d79,(%esp)
  103963:	89 44 24 04          	mov    %eax,0x4(%esp)
  103967:	e8 14 cc ff ff       	call   100580 <cprintf>
  10396c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103973:	90                   	nop
  103974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  
// esp needs to point at the same relative spot in it's own copy of the stack.

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
  103978:	8b 44 b2 28          	mov    0x28(%edx,%esi,4),%eax
  10397c:	85 c0                	test   %eax,%eax
  10397e:	74 13                	je     103993 <clone+0x203>
      np->ofile[i] = filedup(proc->ofile[i]);
  103980:	89 04 24             	mov    %eax,(%esp)
  103983:	e8 78 d5 ff ff       	call   100f00 <filedup>
  103988:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
  10398c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
//   cprintf("childstack: %x\n", stack);

  
// esp needs to point at the same relative spot in it's own copy of the stack.

  for(i = 0; i < NOFILE; i++)
  103993:	83 c6 01             	add    $0x1,%esi
  103996:	83 fe 10             	cmp    $0x10,%esi
  103999:	75 dd                	jne    103978 <clone+0x1e8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  10399b:	8b 42 68             	mov    0x68(%edx),%eax
  10399e:	89 04 24             	mov    %eax,(%esp)
  1039a1:	e8 5a d7 ff ff       	call   101100 <idup>

  pid = np->pid;
  1039a6:	8b 73 10             	mov    0x10(%ebx),%esi
  np->state = RUNNABLE;
  1039a9:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
// esp needs to point at the same relative spot in it's own copy of the stack.

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1039b0:	89 43 68             	mov    %eax,0x68(%ebx)

  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  1039b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1039b9:	83 c3 6c             	add    $0x6c,%ebx
  1039bc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  1039c3:	00 
  1039c4:	89 1c 24             	mov    %ebx,(%esp)
  1039c7:	83 c0 6c             	add    $0x6c,%eax
  1039ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1039ce:	e8 8d 06 00 00       	call   104060 <safestrcpy>
  return pid;
}
  1039d3:	83 c4 2c             	add    $0x2c,%esp
  1039d6:	89 f0                	mov    %esi,%eax
  1039d8:	5b                   	pop    %ebx
  1039d9:	5e                   	pop    %esi
  1039da:	5f                   	pop    %edi
  1039db:	5d                   	pop    %ebp
  1039dc:	c3                   	ret    
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  
  if(argint(1, &size) < 0 || size <= 0 || argptr(0, &stack, size) < 0) {
    kfree(np->kstack);
  1039dd:	8b 43 08             	mov    0x8(%ebx),%eax
    np->kstack = 0;
    np->state = UNUSED;
  1039e0:	83 ce ff             	or     $0xffffffff,%esi
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  
  if(argint(1, &size) < 0 || size <= 0 || argptr(0, &stack, size) < 0) {
    kfree(np->kstack);
  1039e3:	89 04 24             	mov    %eax,(%esp)
  1039e6:	e8 f5 e8 ff ff       	call   1022e0 <kfree>
    np->kstack = 0;
  1039eb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
  1039f2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
  1039f9:	eb d8                	jmp    1039d3 <clone+0x243>
  1039fb:	90                   	nop
  1039fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103a00 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  103a00:	55                   	push   %ebp
  103a01:	89 e5                	mov    %esp,%ebp
  103a03:	57                   	push   %edi
  103a04:	56                   	push   %esi
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  103a05:	be ff ff ff ff       	mov    $0xffffffff,%esi
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  103a0a:	53                   	push   %ebx
  103a0b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  103a0e:	e8 8d fc ff ff       	call   1036a0 <allocproc>
  103a13:	85 c0                	test   %eax,%eax
  103a15:	89 c3                	mov    %eax,%ebx
  103a17:	0f 84 be 00 00 00    	je     103adb <fork+0xdb>
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
  103a1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103a23:	8b 10                	mov    (%eax),%edx
  103a25:	89 54 24 04          	mov    %edx,0x4(%esp)
  103a29:	8b 40 04             	mov    0x4(%eax),%eax
  103a2c:	89 04 24             	mov    %eax,(%esp)
  103a2f:	e8 1c 29 00 00       	call   106350 <copyuvm>
  103a34:	85 c0                	test   %eax,%eax
  103a36:	89 43 04             	mov    %eax,0x4(%ebx)
  103a39:	0f 84 a6 00 00 00    	je     103ae5 <fork+0xe5>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  103a3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  np->parent = proc;
  *np->tf = *proc->tf;
  103a45:	b9 13 00 00 00       	mov    $0x13,%ecx
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  103a4a:	8b 00                	mov    (%eax),%eax
  103a4c:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
  103a4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103a54:	89 43 14             	mov    %eax,0x14(%ebx)
  *np->tf = *proc->tf;
  103a57:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103a5e:	8b 43 18             	mov    0x18(%ebx),%eax
  103a61:	8b 72 18             	mov    0x18(%edx),%esi
  103a64:	89 c7                	mov    %eax,%edi
  103a66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
  103a68:	31 f6                	xor    %esi,%esi
  103a6a:	8b 43 18             	mov    0x18(%ebx),%eax
  103a6d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  103a74:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103a7b:	90                   	nop
  103a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
  103a80:	8b 44 b2 28          	mov    0x28(%edx,%esi,4),%eax
  103a84:	85 c0                	test   %eax,%eax
  103a86:	74 13                	je     103a9b <fork+0x9b>
      np->ofile[i] = filedup(proc->ofile[i]);
  103a88:	89 04 24             	mov    %eax,(%esp)
  103a8b:	e8 70 d4 ff ff       	call   100f00 <filedup>
  103a90:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
  103a94:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
  103a9b:	83 c6 01             	add    $0x1,%esi
  103a9e:	83 fe 10             	cmp    $0x10,%esi
  103aa1:	75 dd                	jne    103a80 <fork+0x80>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  103aa3:	8b 42 68             	mov    0x68(%edx),%eax
  103aa6:	89 04 24             	mov    %eax,(%esp)
  103aa9:	e8 52 d6 ff ff       	call   101100 <idup>
 
  pid = np->pid;
  103aae:	8b 73 10             	mov    0x10(%ebx),%esi
  np->state = RUNNABLE;
  103ab1:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  103ab8:	89 43 68             	mov    %eax,0x68(%ebx)
 
  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  103abb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103ac1:	83 c3 6c             	add    $0x6c,%ebx
  103ac4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  103acb:	00 
  103acc:	89 1c 24             	mov    %ebx,(%esp)
  103acf:	83 c0 6c             	add    $0x6c,%eax
  103ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
  103ad6:	e8 85 05 00 00       	call   104060 <safestrcpy>
  return pid;
}
  103adb:	83 c4 1c             	add    $0x1c,%esp
  103ade:	89 f0                	mov    %esi,%eax
  103ae0:	5b                   	pop    %ebx
  103ae1:	5e                   	pop    %esi
  103ae2:	5f                   	pop    %edi
  103ae3:	5d                   	pop    %ebp
  103ae4:	c3                   	ret    
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
  103ae5:	8b 43 08             	mov    0x8(%ebx),%eax
  103ae8:	89 04 24             	mov    %eax,(%esp)
  103aeb:	e8 f0 e7 ff ff       	call   1022e0 <kfree>
    np->kstack = 0;
  103af0:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
  103af7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
  103afe:	eb db                	jmp    103adb <fork+0xdb>

00103b00 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  103b00:	55                   	push   %ebp
  103b01:	89 e5                	mov    %esp,%ebp
  103b03:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
  103b06:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  103b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  uint sz;
  
  sz = proc->sz;
  103b10:	8b 02                	mov    (%edx),%eax
  if(n > 0){
  103b12:	83 f9 00             	cmp    $0x0,%ecx
  103b15:	7f 19                	jg     103b30 <growproc+0x30>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
  103b17:	75 39                	jne    103b52 <growproc+0x52>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  103b19:	89 02                	mov    %eax,(%edx)
  switchuvm(proc);
  103b1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103b21:	89 04 24             	mov    %eax,(%esp)
  103b24:	e8 77 2a 00 00       	call   1065a0 <switchuvm>
  103b29:	31 c0                	xor    %eax,%eax
  return 0;
}
  103b2b:	c9                   	leave  
  103b2c:	c3                   	ret    
  103b2d:	8d 76 00             	lea    0x0(%esi),%esi
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
  103b30:	01 c1                	add    %eax,%ecx
  103b32:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103b36:	89 44 24 04          	mov    %eax,0x4(%esp)
  103b3a:	8b 42 04             	mov    0x4(%edx),%eax
  103b3d:	89 04 24             	mov    %eax,(%esp)
  103b40:	e8 cb 28 00 00       	call   106410 <allocuvm>
  103b45:	85 c0                	test   %eax,%eax
  103b47:	74 27                	je     103b70 <growproc+0x70>
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
  103b49:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103b50:	eb c7                	jmp    103b19 <growproc+0x19>
  103b52:	01 c1                	add    %eax,%ecx
  103b54:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  103b5c:	8b 42 04             	mov    0x4(%edx),%eax
  103b5f:	89 04 24             	mov    %eax,(%esp)
  103b62:	e8 d9 26 00 00       	call   106240 <deallocuvm>
  103b67:	85 c0                	test   %eax,%eax
  103b69:	75 de                	jne    103b49 <growproc+0x49>
  103b6b:	90                   	nop
  103b6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
  103b70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  103b75:	c9                   	leave  
  103b76:	c3                   	ret    
  103b77:	89 f6                	mov    %esi,%esi
  103b79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103b80 <userinit>:
}

// Set up first user process.
void
userinit(void)
{
  103b80:	55                   	push   %ebp
  103b81:	89 e5                	mov    %esp,%ebp
  103b83:	53                   	push   %ebx
  103b84:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  103b87:	e8 14 fb ff ff       	call   1036a0 <allocproc>
  103b8c:	89 c3                	mov    %eax,%ebx
  initproc = p;
  103b8e:	a3 c8 98 10 00       	mov    %eax,0x1098c8
  if((p->pgdir = setupkvm()) == 0)
  103b93:	e8 78 25 00 00       	call   106110 <setupkvm>
  103b98:	85 c0                	test   %eax,%eax
  103b9a:	89 43 04             	mov    %eax,0x4(%ebx)
  103b9d:	0f 84 b6 00 00 00    	je     103c59 <userinit+0xd9>
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  103ba3:	89 04 24             	mov    %eax,(%esp)
  103ba6:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
  103bad:	00 
  103bae:	c7 44 24 04 70 97 10 	movl   $0x109770,0x4(%esp)
  103bb5:	00 
  103bb6:	e8 f5 25 00 00       	call   1061b0 <inituvm>
  p->sz = PGSIZE;
  103bbb:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
  103bc1:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
  103bc8:	00 
  103bc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103bd0:	00 
  103bd1:	8b 43 18             	mov    0x18(%ebx),%eax
  103bd4:	89 04 24             	mov    %eax,(%esp)
  103bd7:	e8 e4 02 00 00       	call   103ec0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  103bdc:	8b 43 18             	mov    0x18(%ebx),%eax
  103bdf:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  103be5:	8b 43 18             	mov    0x18(%ebx),%eax
  103be8:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
  103bee:	8b 43 18             	mov    0x18(%ebx),%eax
  103bf1:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103bf5:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
  103bf9:	8b 43 18             	mov    0x18(%ebx),%eax
  103bfc:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103c00:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
  103c04:	8b 43 18             	mov    0x18(%ebx),%eax
  103c07:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
  103c0e:	8b 43 18             	mov    0x18(%ebx),%eax
  103c11:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
  103c18:	8b 43 18             	mov    0x18(%ebx),%eax
  103c1b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
  103c22:	8d 43 6c             	lea    0x6c(%ebx),%eax
  103c25:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  103c2c:	00 
  103c2d:	c7 44 24 04 ac 6d 10 	movl   $0x106dac,0x4(%esp)
  103c34:	00 
  103c35:	89 04 24             	mov    %eax,(%esp)
  103c38:	e8 23 04 00 00       	call   104060 <safestrcpy>
  p->cwd = namei("/");
  103c3d:	c7 04 24 b5 6d 10 00 	movl   $0x106db5,(%esp)
  103c44:	e8 57 e2 ff ff       	call   101ea0 <namei>

  p->state = RUNNABLE;
  103c49:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");
  103c50:	89 43 68             	mov    %eax,0x68(%ebx)

  p->state = RUNNABLE;
}
  103c53:	83 c4 14             	add    $0x14,%esp
  103c56:	5b                   	pop    %ebx
  103c57:	5d                   	pop    %ebp
  103c58:	c3                   	ret    
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  103c59:	c7 04 24 93 6d 10 00 	movl   $0x106d93,(%esp)
  103c60:	e8 0b cd ff ff       	call   100970 <panic>
  103c65:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103c69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103c70 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
  103c70:	55                   	push   %ebp
  103c71:	89 e5                	mov    %esp,%ebp
  103c73:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
  103c76:	c7 44 24 04 b7 6d 10 	movl   $0x106db7,0x4(%esp)
  103c7d:	00 
  103c7e:	c7 04 24 20 e1 10 00 	movl   $0x10e120,(%esp)
  103c85:	e8 06 00 00 00       	call   103c90 <initlock>
}
  103c8a:	c9                   	leave  
  103c8b:	c3                   	ret    
  103c8c:	90                   	nop
  103c8d:	90                   	nop
  103c8e:	90                   	nop
  103c8f:	90                   	nop

00103c90 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  103c90:	55                   	push   %ebp
  103c91:	89 e5                	mov    %esp,%ebp
  103c93:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
  103c96:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
  103c99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
  103c9f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
  lk->cpu = 0;
  103ca2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
  103ca9:	5d                   	pop    %ebp
  103caa:	c3                   	ret    
  103cab:	90                   	nop
  103cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103cb0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  103cb0:	55                   	push   %ebp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  103cb1:	31 c0                	xor    %eax,%eax
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  103cb3:	89 e5                	mov    %esp,%ebp
  103cb5:	53                   	push   %ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  103cb6:	8b 55 08             	mov    0x8(%ebp),%edx
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  103cb9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  103cbc:	83 ea 08             	sub    $0x8,%edx
  103cbf:	90                   	nop
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
  103cc0:	8d 8a 00 00 f0 ff    	lea    -0x100000(%edx),%ecx
  103cc6:	81 f9 fe ff ef ff    	cmp    $0xffeffffe,%ecx
  103ccc:	77 1a                	ja     103ce8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
  103cce:	8b 4a 04             	mov    0x4(%edx),%ecx
  103cd1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  103cd4:	83 c0 01             	add    $0x1,%eax
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  103cd7:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  103cd9:	83 f8 0a             	cmp    $0xa,%eax
  103cdc:	75 e2                	jne    103cc0 <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
  103cde:	5b                   	pop    %ebx
  103cdf:	5d                   	pop    %ebp
  103ce0:	c3                   	ret    
  103ce1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  103ce8:	83 f8 09             	cmp    $0x9,%eax
  103ceb:	7f f1                	jg     103cde <getcallerpcs+0x2e>
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  103ced:	8d 14 83             	lea    (%ebx,%eax,4),%edx
  }
  for(; i < 10; i++)
  103cf0:	83 c0 01             	add    $0x1,%eax
    pcs[i] = 0;
  103cf3:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  103cf9:	83 c2 04             	add    $0x4,%edx
  103cfc:	83 f8 0a             	cmp    $0xa,%eax
  103cff:	75 ef                	jne    103cf0 <getcallerpcs+0x40>
    pcs[i] = 0;
}
  103d01:	5b                   	pop    %ebx
  103d02:	5d                   	pop    %ebp
  103d03:	c3                   	ret    
  103d04:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103d0a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103d10 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103d10:	55                   	push   %ebp
  return lock->locked && lock->cpu == cpu;
  103d11:	31 c0                	xor    %eax,%eax
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103d13:	89 e5                	mov    %esp,%ebp
  103d15:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
  103d18:	8b 0a                	mov    (%edx),%ecx
  103d1a:	85 c9                	test   %ecx,%ecx
  103d1c:	74 10                	je     103d2e <holding+0x1e>
  103d1e:	8b 42 08             	mov    0x8(%edx),%eax
  103d21:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103d28:	0f 94 c0             	sete   %al
  103d2b:	0f b6 c0             	movzbl %al,%eax
}
  103d2e:	5d                   	pop    %ebp
  103d2f:	c3                   	ret    

00103d30 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
  103d30:	55                   	push   %ebp
  103d31:	89 e5                	mov    %esp,%ebp
  103d33:	53                   	push   %ebx

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103d34:	9c                   	pushf  
  103d35:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103d36:	fa                   	cli    
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103d37:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103d3e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103d44:	8d 48 01             	lea    0x1(%eax),%ecx
  103d47:	85 c0                	test   %eax,%eax
  103d49:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103d4f:	75 12                	jne    103d63 <pushcli+0x33>
    cpu->intena = eflags & FL_IF;
  103d51:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103d57:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103d5d:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  103d63:	5b                   	pop    %ebx
  103d64:	5d                   	pop    %ebp
  103d65:	c3                   	ret    
  103d66:	8d 76 00             	lea    0x0(%esi),%esi
  103d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103d70 <popcli>:

void
popcli(void)
{
  103d70:	55                   	push   %ebp
  103d71:	89 e5                	mov    %esp,%ebp
  103d73:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103d76:	9c                   	pushf  
  103d77:	58                   	pop    %eax
  if(readeflags()&FL_IF)
  103d78:	f6 c4 02             	test   $0x2,%ah
  103d7b:	75 43                	jne    103dc0 <popcli+0x50>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
  103d7d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103d84:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103d8a:	83 e8 01             	sub    $0x1,%eax
  103d8d:	85 c0                	test   %eax,%eax
  103d8f:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
  103d95:	78 1d                	js     103db4 <popcli+0x44>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
  103d97:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103d9d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
  103da3:	85 d2                	test   %edx,%edx
  103da5:	75 0b                	jne    103db2 <popcli+0x42>
  103da7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  103dad:	85 c0                	test   %eax,%eax
  103daf:	74 01                	je     103db2 <popcli+0x42>
}

static inline void
sti(void)
{
  asm volatile("sti");
  103db1:	fb                   	sti    
    sti();
}
  103db2:	c9                   	leave  
  103db3:	c3                   	ret    
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
    panic("popcli");
  103db4:	c7 04 24 17 6e 10 00 	movl   $0x106e17,(%esp)
  103dbb:	e8 b0 cb ff ff       	call   100970 <panic>

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  103dc0:	c7 04 24 00 6e 10 00 	movl   $0x106e00,(%esp)
  103dc7:	e8 a4 cb ff ff       	call   100970 <panic>
  103dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103dd0 <release>:
}

// Release the lock.
void
release(struct spinlock *lk)
{
  103dd0:	55                   	push   %ebp
  103dd1:	89 e5                	mov    %esp,%ebp
  103dd3:	83 ec 18             	sub    $0x18,%esp
  103dd6:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103dd9:	8b 0a                	mov    (%edx),%ecx
  103ddb:	85 c9                	test   %ecx,%ecx
  103ddd:	74 0c                	je     103deb <release+0x1b>
  103ddf:	8b 42 08             	mov    0x8(%edx),%eax
  103de2:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103de9:	74 0d                	je     103df8 <release+0x28>
// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");
  103deb:	c7 04 24 1e 6e 10 00 	movl   $0x106e1e,(%esp)
  103df2:	e8 79 cb ff ff       	call   100970 <panic>
  103df7:	90                   	nop

  lk->pcs[0] = 0;
  103df8:	c7 42 0c 00 00 00 00 	movl   $0x0,0xc(%edx)
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103dff:	31 c0                	xor    %eax,%eax
  lk->cpu = 0;
  103e01:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
  103e08:	f0 87 02             	lock xchg %eax,(%edx)
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
}
  103e0b:	c9                   	leave  
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
  103e0c:	e9 5f ff ff ff       	jmp    103d70 <popcli>
  103e11:	eb 0d                	jmp    103e20 <acquire>
  103e13:	90                   	nop
  103e14:	90                   	nop
  103e15:	90                   	nop
  103e16:	90                   	nop
  103e17:	90                   	nop
  103e18:	90                   	nop
  103e19:	90                   	nop
  103e1a:	90                   	nop
  103e1b:	90                   	nop
  103e1c:	90                   	nop
  103e1d:	90                   	nop
  103e1e:	90                   	nop
  103e1f:	90                   	nop

00103e20 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  103e20:	55                   	push   %ebp
  103e21:	89 e5                	mov    %esp,%ebp
  103e23:	53                   	push   %ebx
  103e24:	83 ec 14             	sub    $0x14,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103e27:	9c                   	pushf  
  103e28:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103e29:	fa                   	cli    
{
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103e2a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103e31:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103e37:	8d 48 01             	lea    0x1(%eax),%ecx
  103e3a:	85 c0                	test   %eax,%eax
  103e3c:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103e42:	75 12                	jne    103e56 <acquire+0x36>
    cpu->intena = eflags & FL_IF;
  103e44:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103e4a:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103e50:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
  103e56:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103e59:	8b 1a                	mov    (%edx),%ebx
  103e5b:	85 db                	test   %ebx,%ebx
  103e5d:	74 0c                	je     103e6b <acquire+0x4b>
  103e5f:	8b 42 08             	mov    0x8(%edx),%eax
  103e62:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103e69:	74 45                	je     103eb0 <acquire+0x90>
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103e6b:	b9 01 00 00 00       	mov    $0x1,%ecx
  103e70:	eb 09                	jmp    103e7b <acquire+0x5b>
  103e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
  103e78:	8b 55 08             	mov    0x8(%ebp),%edx
  103e7b:	89 c8                	mov    %ecx,%eax
  103e7d:	f0 87 02             	lock xchg %eax,(%edx)
  103e80:	85 c0                	test   %eax,%eax
  103e82:	75 f4                	jne    103e78 <acquire+0x58>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
  103e84:	8b 45 08             	mov    0x8(%ebp),%eax
  103e87:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103e8e:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
  103e91:	8b 45 08             	mov    0x8(%ebp),%eax
  103e94:	83 c0 0c             	add    $0xc,%eax
  103e97:	89 44 24 04          	mov    %eax,0x4(%esp)
  103e9b:	8d 45 08             	lea    0x8(%ebp),%eax
  103e9e:	89 04 24             	mov    %eax,(%esp)
  103ea1:	e8 0a fe ff ff       	call   103cb0 <getcallerpcs>
}
  103ea6:	83 c4 14             	add    $0x14,%esp
  103ea9:	5b                   	pop    %ebx
  103eaa:	5d                   	pop    %ebp
  103eab:	c3                   	ret    
  103eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");
  103eb0:	c7 04 24 26 6e 10 00 	movl   $0x106e26,(%esp)
  103eb7:	e8 b4 ca ff ff       	call   100970 <panic>
  103ebc:	90                   	nop
  103ebd:	90                   	nop
  103ebe:	90                   	nop
  103ebf:	90                   	nop

00103ec0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
  103ec0:	55                   	push   %ebp
  103ec1:	89 e5                	mov    %esp,%ebp
  103ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  103ec6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  103ec7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  103ecd:	89 d7                	mov    %edx,%edi
  103ecf:	fc                   	cld    
  103ed0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  103ed2:	89 d0                	mov    %edx,%eax
  103ed4:	5f                   	pop    %edi
  103ed5:	5d                   	pop    %ebp
  103ed6:	c3                   	ret    
  103ed7:	89 f6                	mov    %esi,%esi
  103ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103ee0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
  103ee0:	55                   	push   %ebp
  103ee1:	89 e5                	mov    %esp,%ebp
  103ee3:	57                   	push   %edi
  103ee4:	56                   	push   %esi
  103ee5:	53                   	push   %ebx
  103ee6:	8b 55 10             	mov    0x10(%ebp),%edx
  103ee9:	8b 75 08             	mov    0x8(%ebp),%esi
  103eec:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103eef:	85 d2                	test   %edx,%edx
  103ef1:	74 2d                	je     103f20 <memcmp+0x40>
    if(*s1 != *s2)
  103ef3:	0f b6 1e             	movzbl (%esi),%ebx
  103ef6:	0f b6 0f             	movzbl (%edi),%ecx
  103ef9:	38 cb                	cmp    %cl,%bl
  103efb:	75 2b                	jne    103f28 <memcmp+0x48>
      return *s1 - *s2;
  103efd:	83 ea 01             	sub    $0x1,%edx
  103f00:	31 c0                	xor    %eax,%eax
  103f02:	eb 18                	jmp    103f1c <memcmp+0x3c>
  103f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
  103f08:	0f b6 5c 06 01       	movzbl 0x1(%esi,%eax,1),%ebx
  103f0d:	83 ea 01             	sub    $0x1,%edx
  103f10:	0f b6 4c 07 01       	movzbl 0x1(%edi,%eax,1),%ecx
  103f15:	83 c0 01             	add    $0x1,%eax
  103f18:	38 cb                	cmp    %cl,%bl
  103f1a:	75 0c                	jne    103f28 <memcmp+0x48>
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103f1c:	85 d2                	test   %edx,%edx
  103f1e:	75 e8                	jne    103f08 <memcmp+0x28>
  103f20:	31 c0                	xor    %eax,%eax
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
  103f22:	5b                   	pop    %ebx
  103f23:	5e                   	pop    %esi
  103f24:	5f                   	pop    %edi
  103f25:	5d                   	pop    %ebp
  103f26:	c3                   	ret    
  103f27:	90                   	nop
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
  103f28:	0f b6 c3             	movzbl %bl,%eax
  103f2b:	0f b6 c9             	movzbl %cl,%ecx
  103f2e:	29 c8                	sub    %ecx,%eax
    s1++, s2++;
  }

  return 0;
}
  103f30:	5b                   	pop    %ebx
  103f31:	5e                   	pop    %esi
  103f32:	5f                   	pop    %edi
  103f33:	5d                   	pop    %ebp
  103f34:	c3                   	ret    
  103f35:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103f39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103f40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
  103f40:	55                   	push   %ebp
  103f41:	89 e5                	mov    %esp,%ebp
  103f43:	57                   	push   %edi
  103f44:	56                   	push   %esi
  103f45:	53                   	push   %ebx
  103f46:	8b 45 08             	mov    0x8(%ebp),%eax
  103f49:	8b 75 0c             	mov    0xc(%ebp),%esi
  103f4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
  103f4f:	39 c6                	cmp    %eax,%esi
  103f51:	73 2d                	jae    103f80 <memmove+0x40>
  103f53:	8d 3c 1e             	lea    (%esi,%ebx,1),%edi
  103f56:	39 f8                	cmp    %edi,%eax
  103f58:	73 26                	jae    103f80 <memmove+0x40>
    s += n;
    d += n;
    while(n-- > 0)
  103f5a:	85 db                	test   %ebx,%ebx
  103f5c:	74 1d                	je     103f7b <memmove+0x3b>

  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
  103f5e:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  103f61:	31 d2                	xor    %edx,%edx
  103f63:	90                   	nop
  103f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
      *--d = *--s;
  103f68:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  103f6d:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  103f71:	83 ea 01             	sub    $0x1,%edx
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103f74:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  103f77:	85 c9                	test   %ecx,%ecx
  103f79:	75 ed                	jne    103f68 <memmove+0x28>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
  103f7b:	5b                   	pop    %ebx
  103f7c:	5e                   	pop    %esi
  103f7d:	5f                   	pop    %edi
  103f7e:	5d                   	pop    %ebp
  103f7f:	c3                   	ret    
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103f80:	31 d2                	xor    %edx,%edx
      *--d = *--s;
  } else
    while(n-- > 0)
  103f82:	85 db                	test   %ebx,%ebx
  103f84:	74 f5                	je     103f7b <memmove+0x3b>
  103f86:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
  103f88:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  103f8c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  103f8f:	83 c2 01             	add    $0x1,%edx
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
  103f92:	39 d3                	cmp    %edx,%ebx
  103f94:	75 f2                	jne    103f88 <memmove+0x48>
      *d++ = *s++;

  return dst;
}
  103f96:	5b                   	pop    %ebx
  103f97:	5e                   	pop    %esi
  103f98:	5f                   	pop    %edi
  103f99:	5d                   	pop    %ebp
  103f9a:	c3                   	ret    
  103f9b:	90                   	nop
  103f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103fa0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  103fa0:	55                   	push   %ebp
  103fa1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
  103fa3:	5d                   	pop    %ebp

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
  103fa4:	e9 97 ff ff ff       	jmp    103f40 <memmove>
  103fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103fb0 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
  103fb0:	55                   	push   %ebp
  103fb1:	89 e5                	mov    %esp,%ebp
  103fb3:	57                   	push   %edi
  103fb4:	56                   	push   %esi
  103fb5:	53                   	push   %ebx
  103fb6:	8b 7d 10             	mov    0x10(%ebp),%edi
  103fb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103fbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  while(n > 0 && *p && *p == *q)
  103fbf:	85 ff                	test   %edi,%edi
  103fc1:	74 3d                	je     104000 <strncmp+0x50>
  103fc3:	0f b6 01             	movzbl (%ecx),%eax
  103fc6:	84 c0                	test   %al,%al
  103fc8:	75 18                	jne    103fe2 <strncmp+0x32>
  103fca:	eb 3c                	jmp    104008 <strncmp+0x58>
  103fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103fd0:	83 ef 01             	sub    $0x1,%edi
  103fd3:	74 2b                	je     104000 <strncmp+0x50>
    n--, p++, q++;
  103fd5:	83 c1 01             	add    $0x1,%ecx
  103fd8:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103fdb:	0f b6 01             	movzbl (%ecx),%eax
  103fde:	84 c0                	test   %al,%al
  103fe0:	74 26                	je     104008 <strncmp+0x58>
  103fe2:	0f b6 33             	movzbl (%ebx),%esi
  103fe5:	89 f2                	mov    %esi,%edx
  103fe7:	38 d0                	cmp    %dl,%al
  103fe9:	74 e5                	je     103fd0 <strncmp+0x20>
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
  103feb:	81 e6 ff 00 00 00    	and    $0xff,%esi
  103ff1:	0f b6 c0             	movzbl %al,%eax
  103ff4:	29 f0                	sub    %esi,%eax
}
  103ff6:	5b                   	pop    %ebx
  103ff7:	5e                   	pop    %esi
  103ff8:	5f                   	pop    %edi
  103ff9:	5d                   	pop    %ebp
  103ffa:	c3                   	ret    
  103ffb:	90                   	nop
  103ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  104000:	31 c0                	xor    %eax,%eax
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
  104002:	5b                   	pop    %ebx
  104003:	5e                   	pop    %esi
  104004:	5f                   	pop    %edi
  104005:	5d                   	pop    %ebp
  104006:	c3                   	ret    
  104007:	90                   	nop
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  104008:	0f b6 33             	movzbl (%ebx),%esi
  10400b:	eb de                	jmp    103feb <strncmp+0x3b>
  10400d:	8d 76 00             	lea    0x0(%esi),%esi

00104010 <strncpy>:
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
{
  104010:	55                   	push   %ebp
  104011:	89 e5                	mov    %esp,%ebp
  104013:	8b 45 08             	mov    0x8(%ebp),%eax
  104016:	56                   	push   %esi
  104017:	8b 4d 10             	mov    0x10(%ebp),%ecx
  10401a:	53                   	push   %ebx
  10401b:	8b 75 0c             	mov    0xc(%ebp),%esi
  10401e:	89 c3                	mov    %eax,%ebx
  104020:	eb 09                	jmp    10402b <strncpy+0x1b>
  104022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  104028:	83 c6 01             	add    $0x1,%esi
  10402b:	83 e9 01             	sub    $0x1,%ecx
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  10402e:	8d 51 01             	lea    0x1(%ecx),%edx
{
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  104031:	85 d2                	test   %edx,%edx
  104033:	7e 0c                	jle    104041 <strncpy+0x31>
  104035:	0f b6 16             	movzbl (%esi),%edx
  104038:	88 13                	mov    %dl,(%ebx)
  10403a:	83 c3 01             	add    $0x1,%ebx
  10403d:	84 d2                	test   %dl,%dl
  10403f:	75 e7                	jne    104028 <strncpy+0x18>
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  104041:	31 d2                	xor    %edx,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  104043:	85 c9                	test   %ecx,%ecx
  104045:	7e 0c                	jle    104053 <strncpy+0x43>
  104047:	90                   	nop
    *s++ = 0;
  104048:	c6 04 13 00          	movb   $0x0,(%ebx,%edx,1)
  10404c:	83 c2 01             	add    $0x1,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  10404f:	39 ca                	cmp    %ecx,%edx
  104051:	75 f5                	jne    104048 <strncpy+0x38>
    *s++ = 0;
  return os;
}
  104053:	5b                   	pop    %ebx
  104054:	5e                   	pop    %esi
  104055:	5d                   	pop    %ebp
  104056:	c3                   	ret    
  104057:	89 f6                	mov    %esi,%esi
  104059:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104060 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
  104060:	55                   	push   %ebp
  104061:	89 e5                	mov    %esp,%ebp
  104063:	8b 55 10             	mov    0x10(%ebp),%edx
  104066:	56                   	push   %esi
  104067:	8b 45 08             	mov    0x8(%ebp),%eax
  10406a:	53                   	push   %ebx
  10406b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *os;
  
  os = s;
  if(n <= 0)
  10406e:	85 d2                	test   %edx,%edx
  104070:	7e 1f                	jle    104091 <safestrcpy+0x31>
  104072:	89 c1                	mov    %eax,%ecx
  104074:	eb 05                	jmp    10407b <safestrcpy+0x1b>
  104076:	66 90                	xchg   %ax,%ax
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
  104078:	83 c6 01             	add    $0x1,%esi
  10407b:	83 ea 01             	sub    $0x1,%edx
  10407e:	85 d2                	test   %edx,%edx
  104080:	7e 0c                	jle    10408e <safestrcpy+0x2e>
  104082:	0f b6 1e             	movzbl (%esi),%ebx
  104085:	88 19                	mov    %bl,(%ecx)
  104087:	83 c1 01             	add    $0x1,%ecx
  10408a:	84 db                	test   %bl,%bl
  10408c:	75 ea                	jne    104078 <safestrcpy+0x18>
    ;
  *s = 0;
  10408e:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
  104091:	5b                   	pop    %ebx
  104092:	5e                   	pop    %esi
  104093:	5d                   	pop    %ebp
  104094:	c3                   	ret    
  104095:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104099:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001040a0 <strlen>:

int
strlen(const char *s)
{
  1040a0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
  1040a1:	31 c0                	xor    %eax,%eax
  return os;
}

int
strlen(const char *s)
{
  1040a3:	89 e5                	mov    %esp,%ebp
  1040a5:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
  1040a8:	80 3a 00             	cmpb   $0x0,(%edx)
  1040ab:	74 0c                	je     1040b9 <strlen+0x19>
  1040ad:	8d 76 00             	lea    0x0(%esi),%esi
  1040b0:	83 c0 01             	add    $0x1,%eax
  1040b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  1040b7:	75 f7                	jne    1040b0 <strlen+0x10>
    ;
  return n;
}
  1040b9:	5d                   	pop    %ebp
  1040ba:	c3                   	ret    
  1040bb:	90                   	nop

001040bc <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
  1040bc:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
  1040c0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
  1040c4:	55                   	push   %ebp
  pushl %ebx
  1040c5:	53                   	push   %ebx
  pushl %esi
  1040c6:	56                   	push   %esi
  pushl %edi
  1040c7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
  1040c8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
  1040ca:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
  1040cc:	5f                   	pop    %edi
  popl %esi
  1040cd:	5e                   	pop    %esi
  popl %ebx
  1040ce:	5b                   	pop    %ebx
  popl %ebp
  1040cf:	5d                   	pop    %ebp
  ret
  1040d0:	c3                   	ret    
  1040d1:	90                   	nop
  1040d2:	90                   	nop
  1040d3:	90                   	nop
  1040d4:	90                   	nop
  1040d5:	90                   	nop
  1040d6:	90                   	nop
  1040d7:	90                   	nop
  1040d8:	90                   	nop
  1040d9:	90                   	nop
  1040da:	90                   	nop
  1040db:	90                   	nop
  1040dc:	90                   	nop
  1040dd:	90                   	nop
  1040de:	90                   	nop
  1040df:	90                   	nop

001040e0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  1040e0:	55                   	push   %ebp
  1040e1:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
  1040e3:	8b 55 08             	mov    0x8(%ebp),%edx
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  1040e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(addr >= p->sz || addr+4 > p->sz)
  1040e9:	8b 12                	mov    (%edx),%edx
  1040eb:	39 c2                	cmp    %eax,%edx
  1040ed:	77 09                	ja     1040f8 <fetchint+0x18>
    return -1;
  *ip = *(int*)(addr);
  return 0;
  1040ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1040f4:	5d                   	pop    %ebp
  1040f5:	c3                   	ret    
  1040f6:	66 90                	xchg   %ax,%ax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1040f8:	8d 48 04             	lea    0x4(%eax),%ecx
  1040fb:	39 ca                	cmp    %ecx,%edx
  1040fd:	72 f0                	jb     1040ef <fetchint+0xf>
    return -1;
  *ip = *(int*)(addr);
  1040ff:	8b 10                	mov    (%eax),%edx
  104101:	8b 45 10             	mov    0x10(%ebp),%eax
  104104:	89 10                	mov    %edx,(%eax)
  104106:	31 c0                	xor    %eax,%eax
  return 0;
}
  104108:	5d                   	pop    %ebp
  104109:	c3                   	ret    
  10410a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00104110 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  104110:	55                   	push   %ebp
  104111:	89 e5                	mov    %esp,%ebp
  104113:	8b 45 08             	mov    0x8(%ebp),%eax
  104116:	8b 55 0c             	mov    0xc(%ebp),%edx
  104119:	53                   	push   %ebx
  char *s, *ep;

  if(addr >= p->sz)
  10411a:	39 10                	cmp    %edx,(%eax)
  10411c:	77 0a                	ja     104128 <fetchstr+0x18>
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  10411e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    if(*s == 0)
      return s - *pp;
  return -1;
}
  104123:	5b                   	pop    %ebx
  104124:	5d                   	pop    %ebp
  104125:	c3                   	ret    
  104126:	66 90                	xchg   %ax,%ax
{
  char *s, *ep;

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  104128:	8b 4d 10             	mov    0x10(%ebp),%ecx
  10412b:	89 11                	mov    %edx,(%ecx)
  ep = (char*)p->sz;
  10412d:	8b 18                	mov    (%eax),%ebx
  for(s = *pp; s < ep; s++)
  10412f:	39 da                	cmp    %ebx,%edx
  104131:	73 eb                	jae    10411e <fetchstr+0xe>
    if(*s == 0)
  104133:	31 c0                	xor    %eax,%eax
  104135:	89 d1                	mov    %edx,%ecx
  104137:	80 3a 00             	cmpb   $0x0,(%edx)
  10413a:	74 e7                	je     104123 <fetchstr+0x13>
  10413c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  104140:	83 c1 01             	add    $0x1,%ecx
  104143:	39 cb                	cmp    %ecx,%ebx
  104145:	76 d7                	jbe    10411e <fetchstr+0xe>
    if(*s == 0)
  104147:	80 39 00             	cmpb   $0x0,(%ecx)
  10414a:	75 f4                	jne    104140 <fetchstr+0x30>
  10414c:	89 c8                	mov    %ecx,%eax
  10414e:	29 d0                	sub    %edx,%eax
  104150:	eb d1                	jmp    104123 <fetchstr+0x13>
  104152:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  104159:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104160 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  104160:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  104166:	55                   	push   %ebp
  104167:	89 e5                	mov    %esp,%ebp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  104169:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10416c:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  10416f:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  104171:	8b 52 44             	mov    0x44(%edx),%edx
  104174:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  104178:	39 c2                	cmp    %eax,%edx
  10417a:	72 0c                	jb     104188 <argint+0x28>
    return -1;
  *ip = *(int*)(addr);
  10417c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  104181:	5d                   	pop    %ebp
  104182:	c3                   	ret    
  104183:	90                   	nop
  104184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  104188:	8d 4a 04             	lea    0x4(%edx),%ecx
  10418b:	39 c8                	cmp    %ecx,%eax
  10418d:	72 ed                	jb     10417c <argint+0x1c>
    return -1;
  *ip = *(int*)(addr);
  10418f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104192:	8b 12                	mov    (%edx),%edx
  104194:	89 10                	mov    %edx,(%eax)
  104196:	31 c0                	xor    %eax,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  104198:	5d                   	pop    %ebp
  104199:	c3                   	ret    
  10419a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001041a0 <argptr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1041a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
  1041a6:	55                   	push   %ebp
  1041a7:	89 e5                	mov    %esp,%ebp

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1041a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1041ac:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1041af:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1041b1:	8b 52 44             	mov    0x44(%edx),%edx
  1041b4:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1041b8:	39 c2                	cmp    %eax,%edx
  1041ba:	73 07                	jae    1041c3 <argptr+0x23>
  1041bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  1041bf:	39 c8                	cmp    %ecx,%eax
  1041c1:	73 0d                	jae    1041d0 <argptr+0x30>
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
    return -1;
  *pp = (char*)i;
  return 0;
  1041c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1041c8:	5d                   	pop    %ebp
  1041c9:	c3                   	ret    
  1041ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  1041d0:	8b 12                	mov    (%edx),%edx
{
  int i;
  
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
  1041d2:	39 c2                	cmp    %eax,%edx
  1041d4:	73 ed                	jae    1041c3 <argptr+0x23>
  1041d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  1041d9:	01 d1                	add    %edx,%ecx
  1041db:	39 c1                	cmp    %eax,%ecx
  1041dd:	77 e4                	ja     1041c3 <argptr+0x23>
    return -1;
  *pp = (char*)i;
  1041df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1041e2:	89 10                	mov    %edx,(%eax)
  1041e4:	31 c0                	xor    %eax,%eax
  return 0;
}
  1041e6:	5d                   	pop    %ebp
  1041e7:	c3                   	ret    
  1041e8:	90                   	nop
  1041e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001041f0 <argstr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1041f0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
  1041f7:	55                   	push   %ebp
  1041f8:	89 e5                	mov    %esp,%ebp
  1041fa:	53                   	push   %ebx

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1041fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1041fe:	8b 42 18             	mov    0x18(%edx),%eax
  104201:	8b 40 44             	mov    0x44(%eax),%eax
  104204:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  104208:	8b 0a                	mov    (%edx),%ecx
  10420a:	39 c8                	cmp    %ecx,%eax
  10420c:	73 07                	jae    104215 <argstr+0x25>
  10420e:	8d 58 04             	lea    0x4(%eax),%ebx
  104211:	39 d9                	cmp    %ebx,%ecx
  104213:	73 0b                	jae    104220 <argstr+0x30>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  104215:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  10421a:	5b                   	pop    %ebx
  10421b:	5d                   	pop    %ebp
  10421c:	c3                   	ret    
  10421d:	8d 76 00             	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  104220:	8b 18                	mov    (%eax),%ebx
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  char *s, *ep;

  if(addr >= p->sz)
  104222:	39 cb                	cmp    %ecx,%ebx
  104224:	73 ef                	jae    104215 <argstr+0x25>
    return -1;
  *pp = (char*)addr;
  104226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  104229:	89 d8                	mov    %ebx,%eax
  10422b:	89 19                	mov    %ebx,(%ecx)
  ep = (char*)p->sz;
  10422d:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
  10422f:	39 d3                	cmp    %edx,%ebx
  104231:	73 e2                	jae    104215 <argstr+0x25>
    if(*s == 0)
  104233:	80 3b 00             	cmpb   $0x0,(%ebx)
  104236:	75 12                	jne    10424a <argstr+0x5a>
  104238:	eb 1e                	jmp    104258 <argstr+0x68>
  10423a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104240:	80 38 00             	cmpb   $0x0,(%eax)
  104243:	90                   	nop
  104244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104248:	74 0e                	je     104258 <argstr+0x68>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  10424a:	83 c0 01             	add    $0x1,%eax
  10424d:	39 c2                	cmp    %eax,%edx
  10424f:	90                   	nop
  104250:	77 ee                	ja     104240 <argstr+0x50>
  104252:	eb c1                	jmp    104215 <argstr+0x25>
  104254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
      return s - *pp;
  104258:	29 d8                	sub    %ebx,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  10425a:	5b                   	pop    %ebx
  10425b:	5d                   	pop    %ebp
  10425c:	c3                   	ret    
  10425d:	8d 76 00             	lea    0x0(%esi),%esi

00104260 <syscall>:
[SYS_clone]   sys_clone,
};

void
syscall(void)
{
  104260:	55                   	push   %ebp
  104261:	89 e5                	mov    %esp,%ebp
  104263:	53                   	push   %ebx
  104264:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
  104267:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10426e:	8b 5a 18             	mov    0x18(%edx),%ebx
  104271:	8b 43 1c             	mov    0x1c(%ebx),%eax
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
  104274:	83 f8 16             	cmp    $0x16,%eax
  104277:	77 17                	ja     104290 <syscall+0x30>
  104279:	8b 0c 85 60 6e 10 00 	mov    0x106e60(,%eax,4),%ecx
  104280:	85 c9                	test   %ecx,%ecx
  104282:	74 0c                	je     104290 <syscall+0x30>
    proc->tf->eax = syscalls[num]();
  104284:	ff d1                	call   *%ecx
  104286:	89 43 1c             	mov    %eax,0x1c(%ebx)
  else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
  104289:	83 c4 14             	add    $0x14,%esp
  10428c:	5b                   	pop    %ebx
  10428d:	5d                   	pop    %ebp
  10428e:	c3                   	ret    
  10428f:	90                   	nop

  num = proc->tf->eax;
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
    proc->tf->eax = syscalls[num]();
  else {
    cprintf("%d %s: unknown sys call %d\n",
  104290:	8b 4a 10             	mov    0x10(%edx),%ecx
  104293:	83 c2 6c             	add    $0x6c,%edx
  104296:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10429a:	89 54 24 08          	mov    %edx,0x8(%esp)
  10429e:	c7 04 24 2e 6e 10 00 	movl   $0x106e2e,(%esp)
  1042a5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  1042a9:	e8 d2 c2 ff ff       	call   100580 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  1042ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1042b4:	8b 40 18             	mov    0x18(%eax),%eax
  1042b7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
  1042be:	83 c4 14             	add    $0x14,%esp
  1042c1:	5b                   	pop    %ebx
  1042c2:	5d                   	pop    %ebp
  1042c3:	c3                   	ret    
  1042c4:	90                   	nop
  1042c5:	90                   	nop
  1042c6:	90                   	nop
  1042c7:	90                   	nop
  1042c8:	90                   	nop
  1042c9:	90                   	nop
  1042ca:	90                   	nop
  1042cb:	90                   	nop
  1042cc:	90                   	nop
  1042cd:	90                   	nop
  1042ce:	90                   	nop
  1042cf:	90                   	nop

001042d0 <sys_pipe>:
  return exec(path, argv);
}

int
sys_pipe(void)
{
  1042d0:	55                   	push   %ebp
  1042d1:	89 e5                	mov    %esp,%ebp
  1042d3:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  1042d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return exec(path, argv);
}

int
sys_pipe(void)
{
  1042d9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  1042dc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  1042df:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  1042e6:	00 
  1042e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1042eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1042f2:	e8 a9 fe ff ff       	call   1041a0 <argptr>
  1042f7:	85 c0                	test   %eax,%eax
  1042f9:	79 15                	jns    104310 <sys_pipe+0x40>
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  1042fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
}
  104300:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  104303:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104306:	89 ec                	mov    %ebp,%esp
  104308:	5d                   	pop    %ebp
  104309:	c3                   	ret    
  10430a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
  104310:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104313:	89 44 24 04          	mov    %eax,0x4(%esp)
  104317:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10431a:	89 04 24             	mov    %eax,(%esp)
  10431d:	e8 1e ec ff ff       	call   102f40 <pipealloc>
  104322:	85 c0                	test   %eax,%eax
  104324:	78 d5                	js     1042fb <sys_pipe+0x2b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  104326:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  104329:	31 c0                	xor    %eax,%eax
  10432b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104338:	8b 5c 82 28          	mov    0x28(%edx,%eax,4),%ebx
  10433c:	85 db                	test   %ebx,%ebx
  10433e:	74 28                	je     104368 <sys_pipe+0x98>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104340:	83 c0 01             	add    $0x1,%eax
  104343:	83 f8 10             	cmp    $0x10,%eax
  104346:	75 f0                	jne    104338 <sys_pipe+0x68>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
  104348:	89 0c 24             	mov    %ecx,(%esp)
  10434b:	e8 80 cc ff ff       	call   100fd0 <fileclose>
    fileclose(wf);
  104350:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104353:	89 04 24             	mov    %eax,(%esp)
  104356:	e8 75 cc ff ff       	call   100fd0 <fileclose>
  10435b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104360:	eb 9e                	jmp    104300 <sys_pipe+0x30>
  104362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  104368:	8d 58 08             	lea    0x8(%eax),%ebx
  10436b:	89 4c 9a 08          	mov    %ecx,0x8(%edx,%ebx,4)
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  10436f:	8b 75 ec             	mov    -0x14(%ebp),%esi
  104372:	31 d2                	xor    %edx,%edx
  104374:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  10437b:	90                   	nop
  10437c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104380:	83 7c 91 28 00       	cmpl   $0x0,0x28(%ecx,%edx,4)
  104385:	74 19                	je     1043a0 <sys_pipe+0xd0>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104387:	83 c2 01             	add    $0x1,%edx
  10438a:	83 fa 10             	cmp    $0x10,%edx
  10438d:	75 f1                	jne    104380 <sys_pipe+0xb0>
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
  10438f:	c7 44 99 08 00 00 00 	movl   $0x0,0x8(%ecx,%ebx,4)
  104396:	00 
  104397:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10439a:	eb ac                	jmp    104348 <sys_pipe+0x78>
  10439c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1043a0:	89 74 91 28          	mov    %esi,0x28(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
  1043a4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1043a7:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
  1043a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043ac:	89 50 04             	mov    %edx,0x4(%eax)
  1043af:	31 c0                	xor    %eax,%eax
  return 0;
  1043b1:	e9 4a ff ff ff       	jmp    104300 <sys_pipe+0x30>
  1043b6:	8d 76 00             	lea    0x0(%esi),%esi
  1043b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001043c0 <sys_exec>:
  return 0;
}

int
sys_exec(void)
{
  1043c0:	55                   	push   %ebp
  1043c1:	89 e5                	mov    %esp,%ebp
  1043c3:	81 ec b8 00 00 00    	sub    $0xb8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  1043c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 0;
}

int
sys_exec(void)
{
  1043cc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1043cf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1043d2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  1043d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1043d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1043e0:	e8 0b fe ff ff       	call   1041f0 <argstr>
  1043e5:	85 c0                	test   %eax,%eax
  1043e7:	79 17                	jns    104400 <sys_exec+0x40>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv))
  1043e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
}
  1043ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1043f1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1043f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1043f7:	89 ec                	mov    %ebp,%esp
  1043f9:	5d                   	pop    %ebp
  1043fa:	c3                   	ret    
  1043fb:	90                   	nop
  1043fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  104400:	8d 45 e0             	lea    -0x20(%ebp),%eax
  104403:	89 44 24 04          	mov    %eax,0x4(%esp)
  104407:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10440e:	e8 4d fd ff ff       	call   104160 <argint>
  104413:	85 c0                	test   %eax,%eax
  104415:	78 d2                	js     1043e9 <sys_exec+0x29>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  104417:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  10441d:	31 f6                	xor    %esi,%esi
  10441f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  104426:	00 
  104427:	31 db                	xor    %ebx,%ebx
  104429:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104430:	00 
  104431:	89 3c 24             	mov    %edi,(%esp)
  104434:	e8 87 fa ff ff       	call   103ec0 <memset>
  104439:	eb 2c                	jmp    104467 <sys_exec+0xa7>
  10443b:	90                   	nop
  10443c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
  104440:	89 44 24 04          	mov    %eax,0x4(%esp)
  104444:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10444a:	8d 14 b7             	lea    (%edi,%esi,4),%edx
  10444d:	89 54 24 08          	mov    %edx,0x8(%esp)
  104451:	89 04 24             	mov    %eax,(%esp)
  104454:	e8 b7 fc ff ff       	call   104110 <fetchstr>
  104459:	85 c0                	test   %eax,%eax
  10445b:	78 8c                	js     1043e9 <sys_exec+0x29>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  10445d:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
  104460:	83 fb 20             	cmp    $0x20,%ebx

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  104463:	89 de                	mov    %ebx,%esi
    if(i >= NELEM(argv))
  104465:	74 82                	je     1043e9 <sys_exec+0x29>
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
  104467:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10446a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10446e:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  104475:	03 45 e0             	add    -0x20(%ebp),%eax
  104478:	89 44 24 04          	mov    %eax,0x4(%esp)
  10447c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104482:	89 04 24             	mov    %eax,(%esp)
  104485:	e8 56 fc ff ff       	call   1040e0 <fetchint>
  10448a:	85 c0                	test   %eax,%eax
  10448c:	0f 88 57 ff ff ff    	js     1043e9 <sys_exec+0x29>
      return -1;
    if(uarg == 0){
  104492:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104495:	85 c0                	test   %eax,%eax
  104497:	75 a7                	jne    104440 <sys_exec+0x80>
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  104499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
  10449c:	c7 84 9d 5c ff ff ff 	movl   $0x0,-0xa4(%ebp,%ebx,4)
  1044a3:	00 00 00 00 
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  1044a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1044ab:	89 04 24             	mov    %eax,(%esp)
  1044ae:	e8 3d c5 ff ff       	call   1009f0 <exec>
  1044b3:	e9 36 ff ff ff       	jmp    1043ee <sys_exec+0x2e>
  1044b8:	90                   	nop
  1044b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001044c0 <sys_chdir>:
  return 0;
}

int
sys_chdir(void)
{
  1044c0:	55                   	push   %ebp
  1044c1:	89 e5                	mov    %esp,%ebp
  1044c3:	53                   	push   %ebx
  1044c4:	83 ec 24             	sub    $0x24,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  1044c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1044ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1044ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1044d5:	e8 16 fd ff ff       	call   1041f0 <argstr>
  1044da:	85 c0                	test   %eax,%eax
  1044dc:	79 12                	jns    1044f0 <sys_chdir+0x30>
    return -1;
  }
  iunlock(ip);
  iput(proc->cwd);
  proc->cwd = ip;
  return 0;
  1044de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1044e3:	83 c4 24             	add    $0x24,%esp
  1044e6:	5b                   	pop    %ebx
  1044e7:	5d                   	pop    %ebp
  1044e8:	c3                   	ret    
  1044e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
sys_chdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  1044f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044f3:	89 04 24             	mov    %eax,(%esp)
  1044f6:	e8 a5 d9 ff ff       	call   101ea0 <namei>
  1044fb:	85 c0                	test   %eax,%eax
  1044fd:	89 c3                	mov    %eax,%ebx
  1044ff:	74 dd                	je     1044de <sys_chdir+0x1e>
    return -1;
  ilock(ip);
  104501:	89 04 24             	mov    %eax,(%esp)
  104504:	e8 f7 d6 ff ff       	call   101c00 <ilock>
  if(ip->type != T_DIR){
  104509:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10450e:	75 26                	jne    104536 <sys_chdir+0x76>
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  104510:	89 1c 24             	mov    %ebx,(%esp)
  104513:	e8 a8 d2 ff ff       	call   1017c0 <iunlock>
  iput(proc->cwd);
  104518:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10451e:	8b 40 68             	mov    0x68(%eax),%eax
  104521:	89 04 24             	mov    %eax,(%esp)
  104524:	e8 a7 d3 ff ff       	call   1018d0 <iput>
  proc->cwd = ip;
  104529:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10452f:	89 58 68             	mov    %ebx,0x68(%eax)
  104532:	31 c0                	xor    %eax,%eax
  return 0;
  104534:	eb ad                	jmp    1044e3 <sys_chdir+0x23>

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
    return -1;
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
  104536:	89 1c 24             	mov    %ebx,(%esp)
  104539:	e8 d2 d5 ff ff       	call   101b10 <iunlockput>
  10453e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104543:	eb 9e                	jmp    1044e3 <sys_chdir+0x23>
  104545:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104549:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104550 <create>:
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104550:	55                   	push   %ebp
  104551:	89 e5                	mov    %esp,%ebp
  104553:	83 ec 58             	sub    $0x58,%esp
  104556:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  104559:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10455c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  10455f:	8d 75 d6             	lea    -0x2a(%ebp),%esi
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104562:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  104565:	31 db                	xor    %ebx,%ebx
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104567:	89 7d fc             	mov    %edi,-0x4(%ebp)
  10456a:	89 d7                	mov    %edx,%edi
  10456c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  10456f:	89 74 24 04          	mov    %esi,0x4(%esp)
  104573:	89 04 24             	mov    %eax,(%esp)
  104576:	e8 05 d9 ff ff       	call   101e80 <nameiparent>
  10457b:	85 c0                	test   %eax,%eax
  10457d:	74 47                	je     1045c6 <create+0x76>
    return 0;
  ilock(dp);
  10457f:	89 04 24             	mov    %eax,(%esp)
  104582:	89 45 bc             	mov    %eax,-0x44(%ebp)
  104585:	e8 76 d6 ff ff       	call   101c00 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
  10458a:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10458d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  104590:	89 44 24 08          	mov    %eax,0x8(%esp)
  104594:	89 74 24 04          	mov    %esi,0x4(%esp)
  104598:	89 14 24             	mov    %edx,(%esp)
  10459b:	e8 20 d1 ff ff       	call   1016c0 <dirlookup>
  1045a0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1045a3:	85 c0                	test   %eax,%eax
  1045a5:	89 c3                	mov    %eax,%ebx
  1045a7:	74 3f                	je     1045e8 <create+0x98>
    iunlockput(dp);
  1045a9:	89 14 24             	mov    %edx,(%esp)
  1045ac:	e8 5f d5 ff ff       	call   101b10 <iunlockput>
    ilock(ip);
  1045b1:	89 1c 24             	mov    %ebx,(%esp)
  1045b4:	e8 47 d6 ff ff       	call   101c00 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
  1045b9:	66 83 ff 02          	cmp    $0x2,%di
  1045bd:	75 19                	jne    1045d8 <create+0x88>
  1045bf:	66 83 7b 10 02       	cmpw   $0x2,0x10(%ebx)
  1045c4:	75 12                	jne    1045d8 <create+0x88>
  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);
  return ip;
}
  1045c6:	89 d8                	mov    %ebx,%eax
  1045c8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1045cb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1045ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1045d1:	89 ec                	mov    %ebp,%esp
  1045d3:	5d                   	pop    %ebp
  1045d4:	c3                   	ret    
  1045d5:	8d 76 00             	lea    0x0(%esi),%esi
  if((ip = dirlookup(dp, name, &off)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
  1045d8:	89 1c 24             	mov    %ebx,(%esp)
  1045db:	31 db                	xor    %ebx,%ebx
  1045dd:	e8 2e d5 ff ff       	call   101b10 <iunlockput>
    return 0;
  1045e2:	eb e2                	jmp    1045c6 <create+0x76>
  1045e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

  if((ip = ialloc(dp->dev, type)) == 0)
  1045e8:	0f bf c7             	movswl %di,%eax
  1045eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1045ef:	8b 02                	mov    (%edx),%eax
  1045f1:	89 55 bc             	mov    %edx,-0x44(%ebp)
  1045f4:	89 04 24             	mov    %eax,(%esp)
  1045f7:	e8 34 d5 ff ff       	call   101b30 <ialloc>
  1045fc:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1045ff:	85 c0                	test   %eax,%eax
  104601:	89 c3                	mov    %eax,%ebx
  104603:	0f 84 b7 00 00 00    	je     1046c0 <create+0x170>
    panic("create: ialloc");

  ilock(ip);
  104609:	89 55 bc             	mov    %edx,-0x44(%ebp)
  10460c:	89 04 24             	mov    %eax,(%esp)
  10460f:	e8 ec d5 ff ff       	call   101c00 <ilock>
  ip->major = major;
  104614:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
  104618:	66 89 43 12          	mov    %ax,0x12(%ebx)
  ip->minor = minor;
  10461c:	0f b7 4d c0          	movzwl -0x40(%ebp),%ecx
  ip->nlink = 1;
  104620:	66 c7 43 16 01 00    	movw   $0x1,0x16(%ebx)
  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");

  ilock(ip);
  ip->major = major;
  ip->minor = minor;
  104626:	66 89 4b 14          	mov    %cx,0x14(%ebx)
  ip->nlink = 1;
  iupdate(ip);
  10462a:	89 1c 24             	mov    %ebx,(%esp)
  10462d:	e8 8e ce ff ff       	call   1014c0 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
  104632:	66 83 ff 01          	cmp    $0x1,%di
  104636:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104639:	74 2d                	je     104668 <create+0x118>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
  10463b:	8b 43 04             	mov    0x4(%ebx),%eax
  10463e:	89 14 24             	mov    %edx,(%esp)
  104641:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104644:	89 74 24 04          	mov    %esi,0x4(%esp)
  104648:	89 44 24 08          	mov    %eax,0x8(%esp)
  10464c:	e8 cf d3 ff ff       	call   101a20 <dirlink>
  104651:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104654:	85 c0                	test   %eax,%eax
  104656:	78 74                	js     1046cc <create+0x17c>
    panic("create: dirlink");

  iunlockput(dp);
  104658:	89 14 24             	mov    %edx,(%esp)
  10465b:	e8 b0 d4 ff ff       	call   101b10 <iunlockput>
  return ip;
  104660:	e9 61 ff ff ff       	jmp    1045c6 <create+0x76>
  104665:	8d 76 00             	lea    0x0(%esi),%esi
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
  104668:	66 83 42 16 01       	addw   $0x1,0x16(%edx)
    iupdate(dp);
  10466d:	89 14 24             	mov    %edx,(%esp)
  104670:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104673:	e8 48 ce ff ff       	call   1014c0 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
  104678:	8b 43 04             	mov    0x4(%ebx),%eax
  10467b:	c7 44 24 04 cc 6e 10 	movl   $0x106ecc,0x4(%esp)
  104682:	00 
  104683:	89 1c 24             	mov    %ebx,(%esp)
  104686:	89 44 24 08          	mov    %eax,0x8(%esp)
  10468a:	e8 91 d3 ff ff       	call   101a20 <dirlink>
  10468f:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104692:	85 c0                	test   %eax,%eax
  104694:	78 1e                	js     1046b4 <create+0x164>
  104696:	8b 42 04             	mov    0x4(%edx),%eax
  104699:	c7 44 24 04 cb 6e 10 	movl   $0x106ecb,0x4(%esp)
  1046a0:	00 
  1046a1:	89 1c 24             	mov    %ebx,(%esp)
  1046a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1046a8:	e8 73 d3 ff ff       	call   101a20 <dirlink>
  1046ad:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1046b0:	85 c0                	test   %eax,%eax
  1046b2:	79 87                	jns    10463b <create+0xeb>
      panic("create dots");
  1046b4:	c7 04 24 ce 6e 10 00 	movl   $0x106ece,(%esp)
  1046bb:	e8 b0 c2 ff ff       	call   100970 <panic>
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");
  1046c0:	c7 04 24 bc 6e 10 00 	movl   $0x106ebc,(%esp)
  1046c7:	e8 a4 c2 ff ff       	call   100970 <panic>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");
  1046cc:	c7 04 24 da 6e 10 00 	movl   $0x106eda,(%esp)
  1046d3:	e8 98 c2 ff ff       	call   100970 <panic>
  1046d8:	90                   	nop
  1046d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001046e0 <sys_mknod>:
  return 0;
}

int
sys_mknod(void)
{
  1046e0:	55                   	push   %ebp
  1046e1:	89 e5                	mov    %esp,%ebp
  1046e3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  1046e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1046e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1046f4:	e8 f7 fa ff ff       	call   1041f0 <argstr>
  1046f9:	85 c0                	test   %eax,%eax
  1046fb:	79 0b                	jns    104708 <sys_mknod+0x28>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  return 0;
  1046fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104702:	c9                   	leave  
  104703:	c3                   	ret    
  104704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
  104708:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10470b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10470f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104716:	e8 45 fa ff ff       	call   104160 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10471b:	85 c0                	test   %eax,%eax
  10471d:	78 de                	js     1046fd <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
  10471f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104722:	89 44 24 04          	mov    %eax,0x4(%esp)
  104726:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10472d:	e8 2e fa ff ff       	call   104160 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  104732:	85 c0                	test   %eax,%eax
  104734:	78 c7                	js     1046fd <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
  104736:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
  10473a:	ba 03 00 00 00       	mov    $0x3,%edx
  10473f:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
  104743:	89 04 24             	mov    %eax,(%esp)
  104746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104749:	e8 02 fe ff ff       	call   104550 <create>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10474e:	85 c0                	test   %eax,%eax
  104750:	74 ab                	je     1046fd <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  104752:	89 04 24             	mov    %eax,(%esp)
  104755:	e8 b6 d3 ff ff       	call   101b10 <iunlockput>
  10475a:	31 c0                	xor    %eax,%eax
  return 0;
}
  10475c:	c9                   	leave  
  10475d:	c3                   	ret    
  10475e:	66 90                	xchg   %ax,%ax

00104760 <sys_mkdir>:
  return fd;
}

int
sys_mkdir(void)
{
  104760:	55                   	push   %ebp
  104761:	89 e5                	mov    %esp,%ebp
  104763:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  104766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104769:	89 44 24 04          	mov    %eax,0x4(%esp)
  10476d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104774:	e8 77 fa ff ff       	call   1041f0 <argstr>
  104779:	85 c0                	test   %eax,%eax
  10477b:	79 0b                	jns    104788 <sys_mkdir+0x28>
    return -1;
  iunlockput(ip);
  return 0;
  10477d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104782:	c9                   	leave  
  104783:	c3                   	ret    
  104784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_mkdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  104788:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10478f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104792:	31 c9                	xor    %ecx,%ecx
  104794:	ba 01 00 00 00       	mov    $0x1,%edx
  104799:	e8 b2 fd ff ff       	call   104550 <create>
  10479e:	85 c0                	test   %eax,%eax
  1047a0:	74 db                	je     10477d <sys_mkdir+0x1d>
    return -1;
  iunlockput(ip);
  1047a2:	89 04 24             	mov    %eax,(%esp)
  1047a5:	e8 66 d3 ff ff       	call   101b10 <iunlockput>
  1047aa:	31 c0                	xor    %eax,%eax
  return 0;
}
  1047ac:	c9                   	leave  
  1047ad:	c3                   	ret    
  1047ae:	66 90                	xchg   %ax,%ax

001047b0 <sys_link>:
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1047b0:	55                   	push   %ebp
  1047b1:	89 e5                	mov    %esp,%ebp
  1047b3:	83 ec 48             	sub    $0x48,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1047b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1047b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1047bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1047bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1047c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1047c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1047cd:	e8 1e fa ff ff       	call   1041f0 <argstr>
  1047d2:	85 c0                	test   %eax,%eax
  1047d4:	79 12                	jns    1047e8 <sys_link+0x38>
bad:
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return -1;
  1047d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1047db:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1047de:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1047e1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1047e4:	89 ec                	mov    %ebp,%esp
  1047e6:	5d                   	pop    %ebp
  1047e7:	c3                   	ret    
sys_link(void)
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1047e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1047eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1047ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1047f6:	e8 f5 f9 ff ff       	call   1041f0 <argstr>
  1047fb:	85 c0                	test   %eax,%eax
  1047fd:	78 d7                	js     1047d6 <sys_link+0x26>
    return -1;
  if((ip = namei(old)) == 0)
  1047ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104802:	89 04 24             	mov    %eax,(%esp)
  104805:	e8 96 d6 ff ff       	call   101ea0 <namei>
  10480a:	85 c0                	test   %eax,%eax
  10480c:	89 c3                	mov    %eax,%ebx
  10480e:	74 c6                	je     1047d6 <sys_link+0x26>
    return -1;
  ilock(ip);
  104810:	89 04 24             	mov    %eax,(%esp)
  104813:	e8 e8 d3 ff ff       	call   101c00 <ilock>
  if(ip->type == T_DIR){
  104818:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10481d:	0f 84 86 00 00 00    	je     1048a9 <sys_link+0xf9>
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  104823:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
  104828:	8d 7d d2             	lea    -0x2e(%ebp),%edi
  if(ip->type == T_DIR){
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  iupdate(ip);
  10482b:	89 1c 24             	mov    %ebx,(%esp)
  10482e:	e8 8d cc ff ff       	call   1014c0 <iupdate>
  iunlock(ip);
  104833:	89 1c 24             	mov    %ebx,(%esp)
  104836:	e8 85 cf ff ff       	call   1017c0 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
  10483b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10483e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104842:	89 04 24             	mov    %eax,(%esp)
  104845:	e8 36 d6 ff ff       	call   101e80 <nameiparent>
  10484a:	85 c0                	test   %eax,%eax
  10484c:	89 c6                	mov    %eax,%esi
  10484e:	74 44                	je     104894 <sys_link+0xe4>
    goto bad;
  ilock(dp);
  104850:	89 04 24             	mov    %eax,(%esp)
  104853:	e8 a8 d3 ff ff       	call   101c00 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
  104858:	8b 06                	mov    (%esi),%eax
  10485a:	3b 03                	cmp    (%ebx),%eax
  10485c:	75 2e                	jne    10488c <sys_link+0xdc>
  10485e:	8b 43 04             	mov    0x4(%ebx),%eax
  104861:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104865:	89 34 24             	mov    %esi,(%esp)
  104868:	89 44 24 08          	mov    %eax,0x8(%esp)
  10486c:	e8 af d1 ff ff       	call   101a20 <dirlink>
  104871:	85 c0                	test   %eax,%eax
  104873:	78 17                	js     10488c <sys_link+0xdc>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
  104875:	89 34 24             	mov    %esi,(%esp)
  104878:	e8 93 d2 ff ff       	call   101b10 <iunlockput>
  iput(ip);
  10487d:	89 1c 24             	mov    %ebx,(%esp)
  104880:	e8 4b d0 ff ff       	call   1018d0 <iput>
  104885:	31 c0                	xor    %eax,%eax
  return 0;
  104887:	e9 4f ff ff ff       	jmp    1047db <sys_link+0x2b>

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
  10488c:	89 34 24             	mov    %esi,(%esp)
  10488f:	e8 7c d2 ff ff       	call   101b10 <iunlockput>
  iunlockput(dp);
  iput(ip);
  return 0;

bad:
  ilock(ip);
  104894:	89 1c 24             	mov    %ebx,(%esp)
  104897:	e8 64 d3 ff ff       	call   101c00 <ilock>
  ip->nlink--;
  10489c:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
  1048a1:	89 1c 24             	mov    %ebx,(%esp)
  1048a4:	e8 17 cc ff ff       	call   1014c0 <iupdate>
  iunlockput(ip);
  1048a9:	89 1c 24             	mov    %ebx,(%esp)
  1048ac:	e8 5f d2 ff ff       	call   101b10 <iunlockput>
  1048b1:	83 c8 ff             	or     $0xffffffff,%eax
  return -1;
  1048b4:	e9 22 ff ff ff       	jmp    1047db <sys_link+0x2b>
  1048b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001048c0 <sys_open>:
  return ip;
}

int
sys_open(void)
{
  1048c0:	55                   	push   %ebp
  1048c1:	89 e5                	mov    %esp,%ebp
  1048c3:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  1048c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return ip;
}

int
sys_open(void)
{
  1048c9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  1048cc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  1048cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1048da:	e8 11 f9 ff ff       	call   1041f0 <argstr>
  1048df:	85 c0                	test   %eax,%eax
  1048e1:	79 15                	jns    1048f8 <sys_open+0x38>

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  1048e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
}
  1048e8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  1048eb:	8b 75 fc             	mov    -0x4(%ebp),%esi
  1048ee:	89 ec                	mov    %ebp,%esp
  1048f0:	5d                   	pop    %ebp
  1048f1:	c3                   	ret    
  1048f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  1048f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1048fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104906:	e8 55 f8 ff ff       	call   104160 <argint>
  10490b:	85 c0                	test   %eax,%eax
  10490d:	78 d4                	js     1048e3 <sys_open+0x23>
    return -1;
  if(omode & O_CREATE){
  10490f:	f6 45 f1 02          	testb  $0x2,-0xf(%ebp)
  104913:	74 63                	je     104978 <sys_open+0xb8>
    if((ip = create(path, T_FILE, 0, 0)) == 0)
  104915:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104918:	31 c9                	xor    %ecx,%ecx
  10491a:	ba 02 00 00 00       	mov    $0x2,%edx
  10491f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104926:	e8 25 fc ff ff       	call   104550 <create>
  10492b:	85 c0                	test   %eax,%eax
  10492d:	89 c3                	mov    %eax,%ebx
  10492f:	74 b2                	je     1048e3 <sys_open+0x23>
      iunlockput(ip);
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
  104931:	e8 1a c6 ff ff       	call   100f50 <filealloc>
  104936:	85 c0                	test   %eax,%eax
  104938:	89 c6                	mov    %eax,%esi
  10493a:	74 24                	je     104960 <sys_open+0xa0>
  10493c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104943:	31 c0                	xor    %eax,%eax
  104945:	8d 76 00             	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104948:	8b 4c 82 28          	mov    0x28(%edx,%eax,4),%ecx
  10494c:	85 c9                	test   %ecx,%ecx
  10494e:	74 58                	je     1049a8 <sys_open+0xe8>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104950:	83 c0 01             	add    $0x1,%eax
  104953:	83 f8 10             	cmp    $0x10,%eax
  104956:	75 f0                	jne    104948 <sys_open+0x88>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
  104958:	89 34 24             	mov    %esi,(%esp)
  10495b:	e8 70 c6 ff ff       	call   100fd0 <fileclose>
    iunlockput(ip);
  104960:	89 1c 24             	mov    %ebx,(%esp)
  104963:	e8 a8 d1 ff ff       	call   101b10 <iunlockput>
  104968:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  10496d:	e9 76 ff ff ff       	jmp    1048e8 <sys_open+0x28>
  104972:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
  if(omode & O_CREATE){
    if((ip = create(path, T_FILE, 0, 0)) == 0)
      return -1;
  } else {
    if((ip = namei(path)) == 0)
  104978:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10497b:	89 04 24             	mov    %eax,(%esp)
  10497e:	e8 1d d5 ff ff       	call   101ea0 <namei>
  104983:	85 c0                	test   %eax,%eax
  104985:	89 c3                	mov    %eax,%ebx
  104987:	0f 84 56 ff ff ff    	je     1048e3 <sys_open+0x23>
      return -1;
    ilock(ip);
  10498d:	89 04 24             	mov    %eax,(%esp)
  104990:	e8 6b d2 ff ff       	call   101c00 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
  104995:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10499a:	75 95                	jne    104931 <sys_open+0x71>
  10499c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  10499f:	85 f6                	test   %esi,%esi
  1049a1:	74 8e                	je     104931 <sys_open+0x71>
  1049a3:	eb bb                	jmp    104960 <sys_open+0xa0>
  1049a5:	8d 76 00             	lea    0x0(%esi),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1049a8:	89 74 82 28          	mov    %esi,0x28(%edx,%eax,4)
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  1049ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1049af:	89 1c 24             	mov    %ebx,(%esp)
  1049b2:	e8 09 ce ff ff       	call   1017c0 <iunlock>

  f->type = FD_INODE;
  1049b7:	c7 06 02 00 00 00    	movl   $0x2,(%esi)
  f->ip = ip;
  1049bd:	89 5e 10             	mov    %ebx,0x10(%esi)
  f->off = 0;
  1049c0:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)
  f->readable = !(omode & O_WRONLY);
  1049c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1049ca:	83 f2 01             	xor    $0x1,%edx
  1049cd:	83 e2 01             	and    $0x1,%edx
  1049d0:	88 56 08             	mov    %dl,0x8(%esi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  1049d3:	f6 45 f0 03          	testb  $0x3,-0x10(%ebp)
  1049d7:	0f 95 46 09          	setne  0x9(%esi)
  return fd;
  1049db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1049de:	e9 05 ff ff ff       	jmp    1048e8 <sys_open+0x28>
  1049e3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1049e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001049f0 <sys_unlink>:
  return 1;
}

int
sys_unlink(void)
{
  1049f0:	55                   	push   %ebp
  1049f1:	89 e5                	mov    %esp,%ebp
  1049f3:	83 ec 78             	sub    $0x78,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  1049f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 1;
}

int
sys_unlink(void)
{
  1049f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1049fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1049ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  104a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104a0d:	e8 de f7 ff ff       	call   1041f0 <argstr>
  104a12:	85 c0                	test   %eax,%eax
  104a14:	79 12                	jns    104a28 <sys_unlink+0x38>
  iunlockput(dp);

  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return 0;
  104a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104a1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  104a1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104a21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104a24:	89 ec                	mov    %ebp,%esp
  104a26:	5d                   	pop    %ebp
  104a27:	c3                   	ret    
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
    return -1;
  if((dp = nameiparent(path, name)) == 0)
  104a28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104a2b:	8d 5d d2             	lea    -0x2e(%ebp),%ebx
  104a2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104a32:	89 04 24             	mov    %eax,(%esp)
  104a35:	e8 46 d4 ff ff       	call   101e80 <nameiparent>
  104a3a:	85 c0                	test   %eax,%eax
  104a3c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  104a3f:	74 d5                	je     104a16 <sys_unlink+0x26>
    return -1;
  ilock(dp);
  104a41:	89 04 24             	mov    %eax,(%esp)
  104a44:	e8 b7 d1 ff ff       	call   101c00 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0){
  104a49:	c7 44 24 04 cc 6e 10 	movl   $0x106ecc,0x4(%esp)
  104a50:	00 
  104a51:	89 1c 24             	mov    %ebx,(%esp)
  104a54:	e8 37 cc ff ff       	call   101690 <namecmp>
  104a59:	85 c0                	test   %eax,%eax
  104a5b:	0f 84 a4 00 00 00    	je     104b05 <sys_unlink+0x115>
  104a61:	c7 44 24 04 cb 6e 10 	movl   $0x106ecb,0x4(%esp)
  104a68:	00 
  104a69:	89 1c 24             	mov    %ebx,(%esp)
  104a6c:	e8 1f cc ff ff       	call   101690 <namecmp>
  104a71:	85 c0                	test   %eax,%eax
  104a73:	0f 84 8c 00 00 00    	je     104b05 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }

  if((ip = dirlookup(dp, name, &off)) == 0){
  104a79:	8d 45 e0             	lea    -0x20(%ebp),%eax
  104a7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  104a80:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104a83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104a87:	89 04 24             	mov    %eax,(%esp)
  104a8a:	e8 31 cc ff ff       	call   1016c0 <dirlookup>
  104a8f:	85 c0                	test   %eax,%eax
  104a91:	89 c6                	mov    %eax,%esi
  104a93:	74 70                	je     104b05 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }
  ilock(ip);
  104a95:	89 04 24             	mov    %eax,(%esp)
  104a98:	e8 63 d1 ff ff       	call   101c00 <ilock>

  if(ip->nlink < 1)
  104a9d:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  104aa2:	0f 8e 0e 01 00 00    	jle    104bb6 <sys_unlink+0x1c6>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
  104aa8:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  104aad:	75 71                	jne    104b20 <sys_unlink+0x130>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
  104aaf:	83 7e 18 20          	cmpl   $0x20,0x18(%esi)
  104ab3:	76 6b                	jbe    104b20 <sys_unlink+0x130>
  104ab5:	8d 7d b2             	lea    -0x4e(%ebp),%edi
  104ab8:	bb 20 00 00 00       	mov    $0x20,%ebx
  104abd:	8d 76 00             	lea    0x0(%esi),%esi
  104ac0:	eb 0e                	jmp    104ad0 <sys_unlink+0xe0>
  104ac2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104ac8:	83 c3 10             	add    $0x10,%ebx
  104acb:	3b 5e 18             	cmp    0x18(%esi),%ebx
  104ace:	73 50                	jae    104b20 <sys_unlink+0x130>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  104ad0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  104ad7:	00 
  104ad8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  104adc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104ae0:	89 34 24             	mov    %esi,(%esp)
  104ae3:	e8 d8 c8 ff ff       	call   1013c0 <readi>
  104ae8:	83 f8 10             	cmp    $0x10,%eax
  104aeb:	0f 85 ad 00 00 00    	jne    104b9e <sys_unlink+0x1ae>
      panic("isdirempty: readi");
    if(de.inum != 0)
  104af1:	66 83 7d b2 00       	cmpw   $0x0,-0x4e(%ebp)
  104af6:	74 d0                	je     104ac8 <sys_unlink+0xd8>
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
  104af8:	89 34 24             	mov    %esi,(%esp)
  104afb:	90                   	nop
  104afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104b00:	e8 0b d0 ff ff       	call   101b10 <iunlockput>
    iunlockput(dp);
  104b05:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104b08:	89 04 24             	mov    %eax,(%esp)
  104b0b:	e8 00 d0 ff ff       	call   101b10 <iunlockput>
  104b10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104b15:	e9 01 ff ff ff       	jmp    104a1b <sys_unlink+0x2b>
  104b1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  memset(&de, 0, sizeof(de));
  104b20:	8d 5d c2             	lea    -0x3e(%ebp),%ebx
  104b23:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  104b2a:	00 
  104b2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104b32:	00 
  104b33:	89 1c 24             	mov    %ebx,(%esp)
  104b36:	e8 85 f3 ff ff       	call   103ec0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  104b3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104b3e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  104b45:	00 
  104b46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104b4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  104b4e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104b51:	89 04 24             	mov    %eax,(%esp)
  104b54:	e8 f7 c9 ff ff       	call   101550 <writei>
  104b59:	83 f8 10             	cmp    $0x10,%eax
  104b5c:	75 4c                	jne    104baa <sys_unlink+0x1ba>
    panic("unlink: writei");
  if(ip->type == T_DIR){
  104b5e:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  104b63:	74 27                	je     104b8c <sys_unlink+0x19c>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
  104b65:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104b68:	89 04 24             	mov    %eax,(%esp)
  104b6b:	e8 a0 cf ff ff       	call   101b10 <iunlockput>

  ip->nlink--;
  104b70:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
  iupdate(ip);
  104b75:	89 34 24             	mov    %esi,(%esp)
  104b78:	e8 43 c9 ff ff       	call   1014c0 <iupdate>
  iunlockput(ip);
  104b7d:	89 34 24             	mov    %esi,(%esp)
  104b80:	e8 8b cf ff ff       	call   101b10 <iunlockput>
  104b85:	31 c0                	xor    %eax,%eax
  return 0;
  104b87:	e9 8f fe ff ff       	jmp    104a1b <sys_unlink+0x2b>

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
  104b8c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104b8f:	66 83 68 16 01       	subw   $0x1,0x16(%eax)
    iupdate(dp);
  104b94:	89 04 24             	mov    %eax,(%esp)
  104b97:	e8 24 c9 ff ff       	call   1014c0 <iupdate>
  104b9c:	eb c7                	jmp    104b65 <sys_unlink+0x175>
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
  104b9e:	c7 04 24 fc 6e 10 00 	movl   $0x106efc,(%esp)
  104ba5:	e8 c6 bd ff ff       	call   100970 <panic>
    return -1;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  104baa:	c7 04 24 0e 6f 10 00 	movl   $0x106f0e,(%esp)
  104bb1:	e8 ba bd ff ff       	call   100970 <panic>
    return -1;
  }
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  104bb6:	c7 04 24 ea 6e 10 00 	movl   $0x106eea,(%esp)
  104bbd:	e8 ae bd ff ff       	call   100970 <panic>
  104bc2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  104bc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104bd0 <T.67>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  104bd0:	55                   	push   %ebp
  104bd1:	89 e5                	mov    %esp,%ebp
  104bd3:	83 ec 28             	sub    $0x28,%esp
  104bd6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  104bd9:	89 c3                	mov    %eax,%ebx
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  104bdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  104bde:	89 75 fc             	mov    %esi,-0x4(%ebp)
  104be1:	89 d6                	mov    %edx,%esi
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  104be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  104be7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104bee:	e8 6d f5 ff ff       	call   104160 <argint>
  104bf3:	85 c0                	test   %eax,%eax
  104bf5:	79 11                	jns    104c08 <T.67+0x38>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  104bf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  104bfc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  104bff:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104c02:	89 ec                	mov    %ebp,%esp
  104c04:	5d                   	pop    %ebp
  104c05:	c3                   	ret    
  104c06:	66 90                	xchg   %ax,%ax
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
  104c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c0b:	83 f8 0f             	cmp    $0xf,%eax
  104c0e:	77 e7                	ja     104bf7 <T.67+0x27>
  104c10:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104c17:	8b 54 82 28          	mov    0x28(%edx,%eax,4),%edx
  104c1b:	85 d2                	test   %edx,%edx
  104c1d:	74 d8                	je     104bf7 <T.67+0x27>
    return -1;
  if(pfd)
  104c1f:	85 db                	test   %ebx,%ebx
  104c21:	74 02                	je     104c25 <T.67+0x55>
    *pfd = fd;
  104c23:	89 03                	mov    %eax,(%ebx)
  if(pf)
  104c25:	31 c0                	xor    %eax,%eax
  104c27:	85 f6                	test   %esi,%esi
  104c29:	74 d1                	je     104bfc <T.67+0x2c>
    *pf = f;
  104c2b:	89 16                	mov    %edx,(%esi)
  104c2d:	eb cd                	jmp    104bfc <T.67+0x2c>
  104c2f:	90                   	nop

00104c30 <sys_dup>:
  return -1;
}

int
sys_dup(void)
{
  104c30:	55                   	push   %ebp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104c31:	31 c0                	xor    %eax,%eax
  return -1;
}

int
sys_dup(void)
{
  104c33:	89 e5                	mov    %esp,%ebp
  104c35:	53                   	push   %ebx
  104c36:	83 ec 24             	sub    $0x24,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104c39:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104c3c:	e8 8f ff ff ff       	call   104bd0 <T.67>
  104c41:	85 c0                	test   %eax,%eax
  104c43:	79 13                	jns    104c58 <sys_dup+0x28>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104c45:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
}
  104c4a:	89 d8                	mov    %ebx,%eax
  104c4c:	83 c4 24             	add    $0x24,%esp
  104c4f:	5b                   	pop    %ebx
  104c50:	5d                   	pop    %ebp
  104c51:	c3                   	ret    
  104c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
  104c58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104c5b:	31 db                	xor    %ebx,%ebx
  104c5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104c63:	eb 0b                	jmp    104c70 <sys_dup+0x40>
  104c65:	8d 76 00             	lea    0x0(%esi),%esi
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104c68:	83 c3 01             	add    $0x1,%ebx
  104c6b:	83 fb 10             	cmp    $0x10,%ebx
  104c6e:	74 d5                	je     104c45 <sys_dup+0x15>
    if(proc->ofile[fd] == 0){
  104c70:	8b 4c 98 28          	mov    0x28(%eax,%ebx,4),%ecx
  104c74:	85 c9                	test   %ecx,%ecx
  104c76:	75 f0                	jne    104c68 <sys_dup+0x38>
      proc->ofile[fd] = f;
  104c78:	89 54 98 28          	mov    %edx,0x28(%eax,%ebx,4)
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  104c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c7f:	89 04 24             	mov    %eax,(%esp)
  104c82:	e8 79 c2 ff ff       	call   100f00 <filedup>
  return fd;
  104c87:	eb c1                	jmp    104c4a <sys_dup+0x1a>
  104c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104c90 <sys_read>:
}

int
sys_read(void)
{
  104c90:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104c91:	31 c0                	xor    %eax,%eax
  return fd;
}

int
sys_read(void)
{
  104c93:	89 e5                	mov    %esp,%ebp
  104c95:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104c98:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104c9b:	e8 30 ff ff ff       	call   104bd0 <T.67>
  104ca0:	85 c0                	test   %eax,%eax
  104ca2:	79 0c                	jns    104cb0 <sys_read+0x20>
    return -1;
  return fileread(f, p, n);
  104ca4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104ca9:	c9                   	leave  
  104caa:	c3                   	ret    
  104cab:	90                   	nop
  104cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104cb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  104cb7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104cbe:	e8 9d f4 ff ff       	call   104160 <argint>
  104cc3:	85 c0                	test   %eax,%eax
  104cc5:	78 dd                	js     104ca4 <sys_read+0x14>
  104cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  104cd5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104cd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  104cdc:	e8 bf f4 ff ff       	call   1041a0 <argptr>
  104ce1:	85 c0                	test   %eax,%eax
  104ce3:	78 bf                	js     104ca4 <sys_read+0x14>
    return -1;
  return fileread(f, p, n);
  104ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ce8:	89 44 24 08          	mov    %eax,0x8(%esp)
  104cec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104cef:	89 44 24 04          	mov    %eax,0x4(%esp)
  104cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104cf6:	89 04 24             	mov    %eax,(%esp)
  104cf9:	e8 02 c1 ff ff       	call   100e00 <fileread>
}
  104cfe:	c9                   	leave  
  104cff:	c3                   	ret    

00104d00 <sys_write>:

int
sys_write(void)
{
  104d00:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104d01:	31 c0                	xor    %eax,%eax
  return fileread(f, p, n);
}

int
sys_write(void)
{
  104d03:	89 e5                	mov    %esp,%ebp
  104d05:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104d08:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104d0b:	e8 c0 fe ff ff       	call   104bd0 <T.67>
  104d10:	85 c0                	test   %eax,%eax
  104d12:	79 0c                	jns    104d20 <sys_write+0x20>
    return -1;
  return filewrite(f, p, n);
  104d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104d19:	c9                   	leave  
  104d1a:	c3                   	ret    
  104d1b:	90                   	nop
  104d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104d20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104d23:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d27:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104d2e:	e8 2d f4 ff ff       	call   104160 <argint>
  104d33:	85 c0                	test   %eax,%eax
  104d35:	78 dd                	js     104d14 <sys_write+0x14>
  104d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d41:	89 44 24 08          	mov    %eax,0x8(%esp)
  104d45:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d4c:	e8 4f f4 ff ff       	call   1041a0 <argptr>
  104d51:	85 c0                	test   %eax,%eax
  104d53:	78 bf                	js     104d14 <sys_write+0x14>
    return -1;
  return filewrite(f, p, n);
  104d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d58:	89 44 24 08          	mov    %eax,0x8(%esp)
  104d5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d66:	89 04 24             	mov    %eax,(%esp)
  104d69:	e8 e2 bf ff ff       	call   100d50 <filewrite>
}
  104d6e:	c9                   	leave  
  104d6f:	c3                   	ret    

00104d70 <sys_fstat>:
  return 0;
}

int
sys_fstat(void)
{
  104d70:	55                   	push   %ebp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104d71:	31 c0                	xor    %eax,%eax
  return 0;
}

int
sys_fstat(void)
{
  104d73:	89 e5                	mov    %esp,%ebp
  104d75:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104d78:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104d7b:	e8 50 fe ff ff       	call   104bd0 <T.67>
  104d80:	85 c0                	test   %eax,%eax
  104d82:	79 0c                	jns    104d90 <sys_fstat+0x20>
    return -1;
  return filestat(f, st);
  104d84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104d89:	c9                   	leave  
  104d8a:	c3                   	ret    
  104d8b:	90                   	nop
  104d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_fstat(void)
{
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104d90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104d93:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  104d9a:	00 
  104d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104da6:	e8 f5 f3 ff ff       	call   1041a0 <argptr>
  104dab:	85 c0                	test   %eax,%eax
  104dad:	78 d5                	js     104d84 <sys_fstat+0x14>
    return -1;
  return filestat(f, st);
  104daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104db2:	89 44 24 04          	mov    %eax,0x4(%esp)
  104db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104db9:	89 04 24             	mov    %eax,(%esp)
  104dbc:	e8 ef c0 ff ff       	call   100eb0 <filestat>
}
  104dc1:	c9                   	leave  
  104dc2:	c3                   	ret    
  104dc3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104dc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104dd0 <sys_close>:
  return filewrite(f, p, n);
}

int
sys_close(void)
{
  104dd0:	55                   	push   %ebp
  104dd1:	89 e5                	mov    %esp,%ebp
  104dd3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
  104dd6:	8d 55 f0             	lea    -0x10(%ebp),%edx
  104dd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104ddc:	e8 ef fd ff ff       	call   104bd0 <T.67>
  104de1:	89 c2                	mov    %eax,%edx
  104de3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104de8:	85 d2                	test   %edx,%edx
  104dea:	78 1e                	js     104e0a <sys_close+0x3a>
    return -1;
  proc->ofile[fd] = 0;
  104dec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104df2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104df5:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
  104dfc:	00 
  fileclose(f);
  104dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e00:	89 04 24             	mov    %eax,(%esp)
  104e03:	e8 c8 c1 ff ff       	call   100fd0 <fileclose>
  104e08:	31 c0                	xor    %eax,%eax
  return 0;
}
  104e0a:	c9                   	leave  
  104e0b:	c3                   	ret    
  104e0c:	90                   	nop
  104e0d:	90                   	nop
  104e0e:	90                   	nop
  104e0f:	90                   	nop

00104e10 <sys_getpid>:
}

int
sys_getpid(void)
{
  return proc->pid;
  104e10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return kill(pid);
}

int
sys_getpid(void)
{
  104e16:	55                   	push   %ebp
  104e17:	89 e5                	mov    %esp,%ebp
  return proc->pid;
}
  104e19:	5d                   	pop    %ebp
}

int
sys_getpid(void)
{
  return proc->pid;
  104e1a:	8b 40 10             	mov    0x10(%eax),%eax
}
  104e1d:	c3                   	ret    
  104e1e:	66 90                	xchg   %ax,%ax

00104e20 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since boot.
int
sys_uptime(void)
{
  104e20:	55                   	push   %ebp
  104e21:	89 e5                	mov    %esp,%ebp
  104e23:	53                   	push   %ebx
  104e24:	83 ec 14             	sub    $0x14,%esp
  uint xticks;
  
  acquire(&tickslock);
  104e27:	c7 04 24 60 02 11 00 	movl   $0x110260,(%esp)
  104e2e:	e8 ed ef ff ff       	call   103e20 <acquire>
  xticks = ticks;
  104e33:	8b 1d a0 0a 11 00    	mov    0x110aa0,%ebx
  release(&tickslock);
  104e39:	c7 04 24 60 02 11 00 	movl   $0x110260,(%esp)
  104e40:	e8 8b ef ff ff       	call   103dd0 <release>
  return xticks;
}
  104e45:	83 c4 14             	add    $0x14,%esp
  104e48:	89 d8                	mov    %ebx,%eax
  104e4a:	5b                   	pop    %ebx
  104e4b:	5d                   	pop    %ebp
  104e4c:	c3                   	ret    
  104e4d:	8d 76 00             	lea    0x0(%esi),%esi

00104e50 <sys_sleep>:
  return addr;
}

int
sys_sleep(void)
{
  104e50:	55                   	push   %ebp
  104e51:	89 e5                	mov    %esp,%ebp
  104e53:	53                   	push   %ebx
  104e54:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
  104e57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104e5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  104e5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104e65:	e8 f6 f2 ff ff       	call   104160 <argint>
  104e6a:	89 c2                	mov    %eax,%edx
  104e6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104e71:	85 d2                	test   %edx,%edx
  104e73:	78 59                	js     104ece <sys_sleep+0x7e>
    return -1;
  acquire(&tickslock);
  104e75:	c7 04 24 60 02 11 00 	movl   $0x110260,(%esp)
  104e7c:	e8 9f ef ff ff       	call   103e20 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104e81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  104e84:	8b 1d a0 0a 11 00    	mov    0x110aa0,%ebx
  while(ticks - ticks0 < n){
  104e8a:	85 d2                	test   %edx,%edx
  104e8c:	75 22                	jne    104eb0 <sys_sleep+0x60>
  104e8e:	eb 48                	jmp    104ed8 <sys_sleep+0x88>
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  104e90:	c7 44 24 04 60 02 11 	movl   $0x110260,0x4(%esp)
  104e97:	00 
  104e98:	c7 04 24 a0 0a 11 00 	movl   $0x110aa0,(%esp)
  104e9f:	e8 0c e4 ff ff       	call   1032b0 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104ea4:	a1 a0 0a 11 00       	mov    0x110aa0,%eax
  104ea9:	29 d8                	sub    %ebx,%eax
  104eab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104eae:	73 28                	jae    104ed8 <sys_sleep+0x88>
    if(proc->killed){
  104eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104eb6:	8b 40 24             	mov    0x24(%eax),%eax
  104eb9:	85 c0                	test   %eax,%eax
  104ebb:	74 d3                	je     104e90 <sys_sleep+0x40>
      release(&tickslock);
  104ebd:	c7 04 24 60 02 11 00 	movl   $0x110260,(%esp)
  104ec4:	e8 07 ef ff ff       	call   103dd0 <release>
  104ec9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
  104ece:	83 c4 24             	add    $0x24,%esp
  104ed1:	5b                   	pop    %ebx
  104ed2:	5d                   	pop    %ebp
  104ed3:	c3                   	ret    
  104ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104ed8:	c7 04 24 60 02 11 00 	movl   $0x110260,(%esp)
  104edf:	e8 ec ee ff ff       	call   103dd0 <release>
  return 0;
}
  104ee4:	83 c4 24             	add    $0x24,%esp
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104ee7:	31 c0                	xor    %eax,%eax
  return 0;
}
  104ee9:	5b                   	pop    %ebx
  104eea:	5d                   	pop    %ebp
  104eeb:	c3                   	ret    
  104eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104ef0 <sys_sbrk>:
  return proc->pid;
}

int
sys_sbrk(void)
{
  104ef0:	55                   	push   %ebp
  104ef1:	89 e5                	mov    %esp,%ebp
  104ef3:	53                   	push   %ebx
  104ef4:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
  104ef7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104efa:	89 44 24 04          	mov    %eax,0x4(%esp)
  104efe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104f05:	e8 56 f2 ff ff       	call   104160 <argint>
  104f0a:	85 c0                	test   %eax,%eax
  104f0c:	79 12                	jns    104f20 <sys_sbrk+0x30>
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
  104f0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104f13:	83 c4 24             	add    $0x24,%esp
  104f16:	5b                   	pop    %ebx
  104f17:	5d                   	pop    %ebp
  104f18:	c3                   	ret    
  104f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104f20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104f26:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
  104f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f2b:	89 04 24             	mov    %eax,(%esp)
  104f2e:	e8 cd eb ff ff       	call   103b00 <growproc>
  104f33:	89 c2                	mov    %eax,%edx
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104f35:	89 d8                	mov    %ebx,%eax
  if(growproc(n) < 0)
  104f37:	85 d2                	test   %edx,%edx
  104f39:	79 d8                	jns    104f13 <sys_sbrk+0x23>
  104f3b:	eb d1                	jmp    104f0e <sys_sbrk+0x1e>
  104f3d:	8d 76 00             	lea    0x0(%esi),%esi

00104f40 <sys_kill>:
  return wait();
}

int
sys_kill(void)
{
  104f40:	55                   	push   %ebp
  104f41:	89 e5                	mov    %esp,%ebp
  104f43:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
  104f46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104f49:	89 44 24 04          	mov    %eax,0x4(%esp)
  104f4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104f54:	e8 07 f2 ff ff       	call   104160 <argint>
  104f59:	89 c2                	mov    %eax,%edx
  104f5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104f60:	85 d2                	test   %edx,%edx
  104f62:	78 0b                	js     104f6f <sys_kill+0x2f>
    return -1;
  return kill(pid);
  104f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f67:	89 04 24             	mov    %eax,(%esp)
  104f6a:	e8 81 e1 ff ff       	call   1030f0 <kill>
}
  104f6f:	c9                   	leave  
  104f70:	c3                   	ret    
  104f71:	eb 0d                	jmp    104f80 <sys_wait>
  104f73:	90                   	nop
  104f74:	90                   	nop
  104f75:	90                   	nop
  104f76:	90                   	nop
  104f77:	90                   	nop
  104f78:	90                   	nop
  104f79:	90                   	nop
  104f7a:	90                   	nop
  104f7b:	90                   	nop
  104f7c:	90                   	nop
  104f7d:	90                   	nop
  104f7e:	90                   	nop
  104f7f:	90                   	nop

00104f80 <sys_wait>:
  return 0;  // not reached
}

int
sys_wait(void)
{
  104f80:	55                   	push   %ebp
  104f81:	89 e5                	mov    %esp,%ebp
  104f83:	83 ec 08             	sub    $0x8,%esp
  return wait();
}
  104f86:	c9                   	leave  
}

int
sys_wait(void)
{
  return wait();
  104f87:	e9 d4 e4 ff ff       	jmp    103460 <wait>
  104f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104f90 <sys_exit>:
  return clone();
}

int
sys_exit(void)
{
  104f90:	55                   	push   %ebp
  104f91:	89 e5                	mov    %esp,%ebp
  104f93:	83 ec 08             	sub    $0x8,%esp
  exit();
  104f96:	e8 d5 e5 ff ff       	call   103570 <exit>
  return 0;  // not reached
}
  104f9b:	31 c0                	xor    %eax,%eax
  104f9d:	c9                   	leave  
  104f9e:	c3                   	ret    
  104f9f:	90                   	nop

00104fa0 <sys_clone>:
  return fork();
}

int
sys_clone(void)
{
  104fa0:	55                   	push   %ebp
  104fa1:	89 e5                	mov    %esp,%ebp
  104fa3:	83 ec 08             	sub    $0x8,%esp
  return clone();
}
  104fa6:	c9                   	leave  
}

int
sys_clone(void)
{
  return clone();
  104fa7:	e9 e4 e7 ff ff       	jmp    103790 <clone>
  104fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104fb0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  104fb0:	55                   	push   %ebp
  104fb1:	89 e5                	mov    %esp,%ebp
  104fb3:	83 ec 08             	sub    $0x8,%esp
  return fork();
}
  104fb6:	c9                   	leave  
#include "proc.h"

int
sys_fork(void)
{
  return fork();
  104fb7:	e9 44 ea ff ff       	jmp    103a00 <fork>
  104fbc:	90                   	nop
  104fbd:	90                   	nop
  104fbe:	90                   	nop
  104fbf:	90                   	nop

00104fc0 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
  104fc0:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  104fc1:	ba 43 00 00 00       	mov    $0x43,%edx
  104fc6:	89 e5                	mov    %esp,%ebp
  104fc8:	83 ec 18             	sub    $0x18,%esp
  104fcb:	b8 34 00 00 00       	mov    $0x34,%eax
  104fd0:	ee                   	out    %al,(%dx)
  104fd1:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
  104fd6:	b2 40                	mov    $0x40,%dl
  104fd8:	ee                   	out    %al,(%dx)
  104fd9:	b8 2e 00 00 00       	mov    $0x2e,%eax
  104fde:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
  104fdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104fe6:	e8 f5 db ff ff       	call   102be0 <picenable>
}
  104feb:	c9                   	leave  
  104fec:	c3                   	ret    
  104fed:	90                   	nop
  104fee:	90                   	nop
  104fef:	90                   	nop

00104ff0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
  104ff0:	1e                   	push   %ds
  pushl %es
  104ff1:	06                   	push   %es
  pushl %fs
  104ff2:	0f a0                	push   %fs
  pushl %gs
  104ff4:	0f a8                	push   %gs
  pushal
  104ff6:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
  104ff7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
  104ffb:	8e d8                	mov    %eax,%ds
  movw %ax, %es
  104ffd:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
  104fff:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
  105003:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
  105005:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
  105007:	54                   	push   %esp
  call trap
  105008:	e8 43 00 00 00       	call   105050 <trap>
  addl $4, %esp
  10500d:	83 c4 04             	add    $0x4,%esp

00105010 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
  105010:	61                   	popa   
  popl %gs
  105011:	0f a9                	pop    %gs
  popl %fs
  105013:	0f a1                	pop    %fs
  popl %es
  105015:	07                   	pop    %es
  popl %ds
  105016:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
  105017:	83 c4 08             	add    $0x8,%esp
  iret
  10501a:	cf                   	iret   
  10501b:	90                   	nop
  10501c:	90                   	nop
  10501d:	90                   	nop
  10501e:	90                   	nop
  10501f:	90                   	nop

00105020 <idtinit>:
  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  105020:	55                   	push   %ebp
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  pd[1] = (uint)p;
  105021:	b8 a0 02 11 00       	mov    $0x1102a0,%eax
  105026:	89 e5                	mov    %esp,%ebp
  105028:	83 ec 10             	sub    $0x10,%esp
static inline void
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  10502b:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
  105031:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
  105035:	c1 e8 10             	shr    $0x10,%eax
  105038:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
  10503c:	8d 45 fa             	lea    -0x6(%ebp),%eax
  10503f:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
  105042:	c9                   	leave  
  105043:	c3                   	ret    
  105044:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10504a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00105050 <trap>:

void
trap(struct trapframe *tf)
{
  105050:	55                   	push   %ebp
  105051:	89 e5                	mov    %esp,%ebp
  105053:	56                   	push   %esi
  105054:	53                   	push   %ebx
  105055:	83 ec 20             	sub    $0x20,%esp
  105058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
  10505b:	8b 43 30             	mov    0x30(%ebx),%eax
  10505e:	83 f8 40             	cmp    $0x40,%eax
  105061:	0f 84 c9 00 00 00    	je     105130 <trap+0xe0>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  105067:	8d 50 e0             	lea    -0x20(%eax),%edx
  10506a:	83 fa 1f             	cmp    $0x1f,%edx
  10506d:	0f 86 b5 00 00 00    	jbe    105128 <trap+0xd8>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
  105073:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10507a:	85 d2                	test   %edx,%edx
  10507c:	0f 84 f6 01 00 00    	je     105278 <trap+0x228>
  105082:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
  105086:	0f 84 ec 01 00 00    	je     105278 <trap+0x228>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
  10508c:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
  10508f:	8b 4a 10             	mov    0x10(%edx),%ecx
  105092:	83 c2 6c             	add    $0x6c,%edx
  105095:	89 74 24 1c          	mov    %esi,0x1c(%esp)
  105099:	8b 73 38             	mov    0x38(%ebx),%esi
  10509c:	89 74 24 18          	mov    %esi,0x18(%esp)
  1050a0:	65 8b 35 00 00 00 00 	mov    %gs:0x0,%esi
  1050a7:	0f b6 36             	movzbl (%esi),%esi
  1050aa:	89 74 24 14          	mov    %esi,0x14(%esp)
  1050ae:	8b 73 34             	mov    0x34(%ebx),%esi
  1050b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1050b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  1050b9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  1050bd:	89 74 24 10          	mov    %esi,0x10(%esp)
  1050c1:	c7 04 24 78 6f 10 00 	movl   $0x106f78,(%esp)
  1050c8:	e8 b3 b4 ff ff       	call   100580 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
  1050cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1050d3:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  1050da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  1050e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1050e6:	85 c0                	test   %eax,%eax
  1050e8:	74 34                	je     10511e <trap+0xce>
  1050ea:	8b 50 24             	mov    0x24(%eax),%edx
  1050ed:	85 d2                	test   %edx,%edx
  1050ef:	74 10                	je     105101 <trap+0xb1>
  1050f1:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
  1050f5:	83 e2 03             	and    $0x3,%edx
  1050f8:	83 fa 03             	cmp    $0x3,%edx
  1050fb:	0f 84 5f 01 00 00    	je     105260 <trap+0x210>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105101:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
  105105:	0f 84 2d 01 00 00    	je     105238 <trap+0x1e8>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  10510b:	8b 40 24             	mov    0x24(%eax),%eax
  10510e:	85 c0                	test   %eax,%eax
  105110:	74 0c                	je     10511e <trap+0xce>
  105112:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  105116:	83 e0 03             	and    $0x3,%eax
  105119:	83 f8 03             	cmp    $0x3,%eax
  10511c:	74 34                	je     105152 <trap+0x102>
    exit();
}
  10511e:	83 c4 20             	add    $0x20,%esp
  105121:	5b                   	pop    %ebx
  105122:	5e                   	pop    %esi
  105123:	5d                   	pop    %ebp
  105124:	c3                   	ret    
  105125:	8d 76 00             	lea    0x0(%esi),%esi
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  105128:	ff 24 95 c8 6f 10 00 	jmp    *0x106fc8(,%edx,4)
  10512f:	90                   	nop

void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
  105130:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  105136:	8b 70 24             	mov    0x24(%eax),%esi
  105139:	85 f6                	test   %esi,%esi
  10513b:	75 23                	jne    105160 <trap+0x110>
      exit();
    proc->tf = tf;
  10513d:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
  105140:	e8 1b f1 ff ff       	call   104260 <syscall>
    if(proc->killed)
  105145:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10514b:	8b 48 24             	mov    0x24(%eax),%ecx
  10514e:	85 c9                	test   %ecx,%ecx
  105150:	74 cc                	je     10511e <trap+0xce>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
  105152:	83 c4 20             	add    $0x20,%esp
  105155:	5b                   	pop    %ebx
  105156:	5e                   	pop    %esi
  105157:	5d                   	pop    %ebp
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  105158:	e9 13 e4 ff ff       	jmp    103570 <exit>
  10515d:	8d 76 00             	lea    0x0(%esi),%esi
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
      exit();
  105160:	e8 0b e4 ff ff       	call   103570 <exit>
  105165:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10516b:	eb d0                	jmp    10513d <trap+0xed>
  10516d:	8d 76 00             	lea    0x0(%esi),%esi
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
  105170:	e8 eb ce ff ff       	call   102060 <ideintr>
    lapiceoi();
  105175:	e8 26 d3 ff ff       	call   1024a0 <lapiceoi>
    break;
  10517a:	e9 61 ff ff ff       	jmp    1050e0 <trap+0x90>
  10517f:	90                   	nop
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
  105180:	8b 43 38             	mov    0x38(%ebx),%eax
  105183:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105187:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  10518b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10518f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  105195:	0f b6 00             	movzbl (%eax),%eax
  105198:	c7 04 24 20 6f 10 00 	movl   $0x106f20,(%esp)
  10519f:	89 44 24 04          	mov    %eax,0x4(%esp)
  1051a3:	e8 d8 b3 ff ff       	call   100580 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
  1051a8:	e8 f3 d2 ff ff       	call   1024a0 <lapiceoi>
    break;
  1051ad:	e9 2e ff ff ff       	jmp    1050e0 <trap+0x90>
  1051b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1051b8:	90                   	nop
  1051b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
  1051c0:	e8 ab 01 00 00       	call   105370 <uartintr>
  1051c5:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  1051c8:	e8 d3 d2 ff ff       	call   1024a0 <lapiceoi>
  1051cd:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  1051d0:	e9 0b ff ff ff       	jmp    1050e0 <trap+0x90>
  1051d5:	8d 76 00             	lea    0x0(%esi),%esi
  1051d8:	90                   	nop
  1051d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
  1051e0:	e8 9b d2 ff ff       	call   102480 <kbdintr>
  1051e5:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  1051e8:	e8 b3 d2 ff ff       	call   1024a0 <lapiceoi>
  1051ed:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  1051f0:	e9 eb fe ff ff       	jmp    1050e0 <trap+0x90>
  1051f5:	8d 76 00             	lea    0x0(%esi),%esi
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
  1051f8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1051fe:	80 38 00             	cmpb   $0x0,(%eax)
  105201:	0f 85 6e ff ff ff    	jne    105175 <trap+0x125>
      acquire(&tickslock);
  105207:	c7 04 24 60 02 11 00 	movl   $0x110260,(%esp)
  10520e:	e8 0d ec ff ff       	call   103e20 <acquire>
      ticks++;
  105213:	83 05 a0 0a 11 00 01 	addl   $0x1,0x110aa0
      wakeup(&ticks);
  10521a:	c7 04 24 a0 0a 11 00 	movl   $0x110aa0,(%esp)
  105221:	e8 5a df ff ff       	call   103180 <wakeup>
      release(&tickslock);
  105226:	c7 04 24 60 02 11 00 	movl   $0x110260,(%esp)
  10522d:	e8 9e eb ff ff       	call   103dd0 <release>
  105232:	e9 3e ff ff ff       	jmp    105175 <trap+0x125>
  105237:	90                   	nop
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105238:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
  10523c:	0f 85 c9 fe ff ff    	jne    10510b <trap+0xbb>
  105242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    yield();
  105248:	e8 33 e1 ff ff       	call   103380 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  10524d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  105253:	85 c0                	test   %eax,%eax
  105255:	0f 85 b0 fe ff ff    	jne    10510b <trap+0xbb>
  10525b:	e9 be fe ff ff       	jmp    10511e <trap+0xce>

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  105260:	e8 0b e3 ff ff       	call   103570 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105265:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10526b:	85 c0                	test   %eax,%eax
  10526d:	0f 85 8e fe ff ff    	jne    105101 <trap+0xb1>
  105273:	e9 a6 fe ff ff       	jmp    10511e <trap+0xce>
  105278:	0f 20 d2             	mov    %cr2,%edx
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
  10527b:	89 54 24 10          	mov    %edx,0x10(%esp)
  10527f:	8b 53 38             	mov    0x38(%ebx),%edx
  105282:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105286:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  10528d:	0f b6 12             	movzbl (%edx),%edx
  105290:	89 44 24 04          	mov    %eax,0x4(%esp)
  105294:	c7 04 24 44 6f 10 00 	movl   $0x106f44,(%esp)
  10529b:	89 54 24 08          	mov    %edx,0x8(%esp)
  10529f:	e8 dc b2 ff ff       	call   100580 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
  1052a4:	c7 04 24 bb 6f 10 00 	movl   $0x106fbb,(%esp)
  1052ab:	e8 c0 b6 ff ff       	call   100970 <panic>

001052b0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  1052b0:	55                   	push   %ebp
  1052b1:	31 c0                	xor    %eax,%eax
  1052b3:	89 e5                	mov    %esp,%ebp
  1052b5:	ba a0 02 11 00       	mov    $0x1102a0,%edx
  1052ba:	83 ec 18             	sub    $0x18,%esp
  1052bd:	8d 76 00             	lea    0x0(%esi),%esi
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  1052c0:	8b 0c 85 28 93 10 00 	mov    0x109328(,%eax,4),%ecx
  1052c7:	66 89 0c c5 a0 02 11 	mov    %cx,0x1102a0(,%eax,8)
  1052ce:	00 
  1052cf:	c1 e9 10             	shr    $0x10,%ecx
  1052d2:	66 c7 44 c2 02 08 00 	movw   $0x8,0x2(%edx,%eax,8)
  1052d9:	c6 44 c2 04 00       	movb   $0x0,0x4(%edx,%eax,8)
  1052de:	c6 44 c2 05 8e       	movb   $0x8e,0x5(%edx,%eax,8)
  1052e3:	66 89 4c c2 06       	mov    %cx,0x6(%edx,%eax,8)
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
  1052e8:	83 c0 01             	add    $0x1,%eax
  1052eb:	3d 00 01 00 00       	cmp    $0x100,%eax
  1052f0:	75 ce                	jne    1052c0 <tvinit+0x10>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  1052f2:	a1 28 94 10 00       	mov    0x109428,%eax
  
  initlock(&tickslock, "time");
  1052f7:	c7 44 24 04 c0 6f 10 	movl   $0x106fc0,0x4(%esp)
  1052fe:	00 
  1052ff:	c7 04 24 60 02 11 00 	movl   $0x110260,(%esp)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  105306:	66 c7 05 a2 04 11 00 	movw   $0x8,0x1104a2
  10530d:	08 00 
  10530f:	66 a3 a0 04 11 00    	mov    %ax,0x1104a0
  105315:	c1 e8 10             	shr    $0x10,%eax
  105318:	c6 05 a4 04 11 00 00 	movb   $0x0,0x1104a4
  10531f:	c6 05 a5 04 11 00 ef 	movb   $0xef,0x1104a5
  105326:	66 a3 a6 04 11 00    	mov    %ax,0x1104a6
  
  initlock(&tickslock, "time");
  10532c:	e8 5f e9 ff ff       	call   103c90 <initlock>
}
  105331:	c9                   	leave  
  105332:	c3                   	ret    
  105333:	90                   	nop
  105334:	90                   	nop
  105335:	90                   	nop
  105336:	90                   	nop
  105337:	90                   	nop
  105338:	90                   	nop
  105339:	90                   	nop
  10533a:	90                   	nop
  10533b:	90                   	nop
  10533c:	90                   	nop
  10533d:	90                   	nop
  10533e:	90                   	nop
  10533f:	90                   	nop

00105340 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
  105340:	a1 cc 98 10 00       	mov    0x1098cc,%eax
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
  105345:	55                   	push   %ebp
  105346:	89 e5                	mov    %esp,%ebp
  if(!uart)
  105348:	85 c0                	test   %eax,%eax
  10534a:	75 0c                	jne    105358 <uartgetc+0x18>
    return -1;
  if(!(inb(COM1+5) & 0x01))
    return -1;
  return inb(COM1+0);
  10534c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  105351:	5d                   	pop    %ebp
  105352:	c3                   	ret    
  105353:	90                   	nop
  105354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105358:	ba fd 03 00 00       	mov    $0x3fd,%edx
  10535d:	ec                   	in     (%dx),%al
static int
uartgetc(void)
{
  if(!uart)
    return -1;
  if(!(inb(COM1+5) & 0x01))
  10535e:	a8 01                	test   $0x1,%al
  105360:	74 ea                	je     10534c <uartgetc+0xc>
  105362:	b2 f8                	mov    $0xf8,%dl
  105364:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
  105365:	0f b6 c0             	movzbl %al,%eax
}
  105368:	5d                   	pop    %ebp
  105369:	c3                   	ret    
  10536a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00105370 <uartintr>:

void
uartintr(void)
{
  105370:	55                   	push   %ebp
  105371:	89 e5                	mov    %esp,%ebp
  105373:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
  105376:	c7 04 24 40 53 10 00 	movl   $0x105340,(%esp)
  10537d:	e8 5e b4 ff ff       	call   1007e0 <consoleintr>
}
  105382:	c9                   	leave  
  105383:	c3                   	ret    
  105384:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10538a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00105390 <uartputc>:
    uartputc(*p);
}

void
uartputc(int c)
{
  105390:	55                   	push   %ebp
  105391:	89 e5                	mov    %esp,%ebp
  105393:	56                   	push   %esi
  105394:	be fd 03 00 00       	mov    $0x3fd,%esi
  105399:	53                   	push   %ebx
  int i;

  if(!uart)
  10539a:	31 db                	xor    %ebx,%ebx
    uartputc(*p);
}

void
uartputc(int c)
{
  10539c:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(!uart)
  10539f:	8b 15 cc 98 10 00    	mov    0x1098cc,%edx
  1053a5:	85 d2                	test   %edx,%edx
  1053a7:	75 1e                	jne    1053c7 <uartputc+0x37>
  1053a9:	eb 2c                	jmp    1053d7 <uartputc+0x47>
  1053ab:	90                   	nop
  1053ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1053b0:	83 c3 01             	add    $0x1,%ebx
    microdelay(10);
  1053b3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1053ba:	e8 01 d1 ff ff       	call   1024c0 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1053bf:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  1053c5:	74 07                	je     1053ce <uartputc+0x3e>
  1053c7:	89 f2                	mov    %esi,%edx
  1053c9:	ec                   	in     (%dx),%al
  1053ca:	a8 20                	test   $0x20,%al
  1053cc:	74 e2                	je     1053b0 <uartputc+0x20>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1053ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
  1053d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1053d6:	ee                   	out    %al,(%dx)
    microdelay(10);
  outb(COM1+0, c);
}
  1053d7:	83 c4 10             	add    $0x10,%esp
  1053da:	5b                   	pop    %ebx
  1053db:	5e                   	pop    %esi
  1053dc:	5d                   	pop    %ebp
  1053dd:	c3                   	ret    
  1053de:	66 90                	xchg   %ax,%ax

001053e0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
  1053e0:	55                   	push   %ebp
  1053e1:	31 c9                	xor    %ecx,%ecx
  1053e3:	89 e5                	mov    %esp,%ebp
  1053e5:	89 c8                	mov    %ecx,%eax
  1053e7:	57                   	push   %edi
  1053e8:	bf fa 03 00 00       	mov    $0x3fa,%edi
  1053ed:	56                   	push   %esi
  1053ee:	89 fa                	mov    %edi,%edx
  1053f0:	53                   	push   %ebx
  1053f1:	83 ec 1c             	sub    $0x1c,%esp
  1053f4:	ee                   	out    %al,(%dx)
  1053f5:	bb fb 03 00 00       	mov    $0x3fb,%ebx
  1053fa:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  1053ff:	89 da                	mov    %ebx,%edx
  105401:	ee                   	out    %al,(%dx)
  105402:	b8 0c 00 00 00       	mov    $0xc,%eax
  105407:	b2 f8                	mov    $0xf8,%dl
  105409:	ee                   	out    %al,(%dx)
  10540a:	be f9 03 00 00       	mov    $0x3f9,%esi
  10540f:	89 c8                	mov    %ecx,%eax
  105411:	89 f2                	mov    %esi,%edx
  105413:	ee                   	out    %al,(%dx)
  105414:	b8 03 00 00 00       	mov    $0x3,%eax
  105419:	89 da                	mov    %ebx,%edx
  10541b:	ee                   	out    %al,(%dx)
  10541c:	b2 fc                	mov    $0xfc,%dl
  10541e:	89 c8                	mov    %ecx,%eax
  105420:	ee                   	out    %al,(%dx)
  105421:	b8 01 00 00 00       	mov    $0x1,%eax
  105426:	89 f2                	mov    %esi,%edx
  105428:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105429:	b2 fd                	mov    $0xfd,%dl
  10542b:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
  10542c:	3c ff                	cmp    $0xff,%al
  10542e:	74 55                	je     105485 <uartinit+0xa5>
    return;
  uart = 1;
  105430:	c7 05 cc 98 10 00 01 	movl   $0x1,0x1098cc
  105437:	00 00 00 
  10543a:	89 fa                	mov    %edi,%edx
  10543c:	ec                   	in     (%dx),%al
  10543d:	b2 f8                	mov    $0xf8,%dl
  10543f:	ec                   	in     (%dx),%al
  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  105440:	bb 48 70 10 00       	mov    $0x107048,%ebx

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  105445:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10544c:	e8 8f d7 ff ff       	call   102be0 <picenable>
  ioapicenable(IRQ_COM1, 0);
  105451:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105458:	00 
  105459:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  105460:	e8 2b cd ff ff       	call   102190 <ioapicenable>
  105465:	b8 78 00 00 00       	mov    $0x78,%eax
  10546a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
  105470:	0f be c0             	movsbl %al,%eax
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  105473:	83 c3 01             	add    $0x1,%ebx
    uartputc(*p);
  105476:	89 04 24             	mov    %eax,(%esp)
  105479:	e8 12 ff ff ff       	call   105390 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  10547e:	0f b6 03             	movzbl (%ebx),%eax
  105481:	84 c0                	test   %al,%al
  105483:	75 eb                	jne    105470 <uartinit+0x90>
    uartputc(*p);
}
  105485:	83 c4 1c             	add    $0x1c,%esp
  105488:	5b                   	pop    %ebx
  105489:	5e                   	pop    %esi
  10548a:	5f                   	pop    %edi
  10548b:	5d                   	pop    %ebp
  10548c:	c3                   	ret    
  10548d:	90                   	nop
  10548e:	90                   	nop
  10548f:	90                   	nop

00105490 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
  105490:	6a 00                	push   $0x0
  pushl $0
  105492:	6a 00                	push   $0x0
  jmp alltraps
  105494:	e9 57 fb ff ff       	jmp    104ff0 <alltraps>

00105499 <vector1>:
.globl vector1
vector1:
  pushl $0
  105499:	6a 00                	push   $0x0
  pushl $1
  10549b:	6a 01                	push   $0x1
  jmp alltraps
  10549d:	e9 4e fb ff ff       	jmp    104ff0 <alltraps>

001054a2 <vector2>:
.globl vector2
vector2:
  pushl $0
  1054a2:	6a 00                	push   $0x0
  pushl $2
  1054a4:	6a 02                	push   $0x2
  jmp alltraps
  1054a6:	e9 45 fb ff ff       	jmp    104ff0 <alltraps>

001054ab <vector3>:
.globl vector3
vector3:
  pushl $0
  1054ab:	6a 00                	push   $0x0
  pushl $3
  1054ad:	6a 03                	push   $0x3
  jmp alltraps
  1054af:	e9 3c fb ff ff       	jmp    104ff0 <alltraps>

001054b4 <vector4>:
.globl vector4
vector4:
  pushl $0
  1054b4:	6a 00                	push   $0x0
  pushl $4
  1054b6:	6a 04                	push   $0x4
  jmp alltraps
  1054b8:	e9 33 fb ff ff       	jmp    104ff0 <alltraps>

001054bd <vector5>:
.globl vector5
vector5:
  pushl $0
  1054bd:	6a 00                	push   $0x0
  pushl $5
  1054bf:	6a 05                	push   $0x5
  jmp alltraps
  1054c1:	e9 2a fb ff ff       	jmp    104ff0 <alltraps>

001054c6 <vector6>:
.globl vector6
vector6:
  pushl $0
  1054c6:	6a 00                	push   $0x0
  pushl $6
  1054c8:	6a 06                	push   $0x6
  jmp alltraps
  1054ca:	e9 21 fb ff ff       	jmp    104ff0 <alltraps>

001054cf <vector7>:
.globl vector7
vector7:
  pushl $0
  1054cf:	6a 00                	push   $0x0
  pushl $7
  1054d1:	6a 07                	push   $0x7
  jmp alltraps
  1054d3:	e9 18 fb ff ff       	jmp    104ff0 <alltraps>

001054d8 <vector8>:
.globl vector8
vector8:
  pushl $8
  1054d8:	6a 08                	push   $0x8
  jmp alltraps
  1054da:	e9 11 fb ff ff       	jmp    104ff0 <alltraps>

001054df <vector9>:
.globl vector9
vector9:
  pushl $0
  1054df:	6a 00                	push   $0x0
  pushl $9
  1054e1:	6a 09                	push   $0x9
  jmp alltraps
  1054e3:	e9 08 fb ff ff       	jmp    104ff0 <alltraps>

001054e8 <vector10>:
.globl vector10
vector10:
  pushl $10
  1054e8:	6a 0a                	push   $0xa
  jmp alltraps
  1054ea:	e9 01 fb ff ff       	jmp    104ff0 <alltraps>

001054ef <vector11>:
.globl vector11
vector11:
  pushl $11
  1054ef:	6a 0b                	push   $0xb
  jmp alltraps
  1054f1:	e9 fa fa ff ff       	jmp    104ff0 <alltraps>

001054f6 <vector12>:
.globl vector12
vector12:
  pushl $12
  1054f6:	6a 0c                	push   $0xc
  jmp alltraps
  1054f8:	e9 f3 fa ff ff       	jmp    104ff0 <alltraps>

001054fd <vector13>:
.globl vector13
vector13:
  pushl $13
  1054fd:	6a 0d                	push   $0xd
  jmp alltraps
  1054ff:	e9 ec fa ff ff       	jmp    104ff0 <alltraps>

00105504 <vector14>:
.globl vector14
vector14:
  pushl $14
  105504:	6a 0e                	push   $0xe
  jmp alltraps
  105506:	e9 e5 fa ff ff       	jmp    104ff0 <alltraps>

0010550b <vector15>:
.globl vector15
vector15:
  pushl $0
  10550b:	6a 00                	push   $0x0
  pushl $15
  10550d:	6a 0f                	push   $0xf
  jmp alltraps
  10550f:	e9 dc fa ff ff       	jmp    104ff0 <alltraps>

00105514 <vector16>:
.globl vector16
vector16:
  pushl $0
  105514:	6a 00                	push   $0x0
  pushl $16
  105516:	6a 10                	push   $0x10
  jmp alltraps
  105518:	e9 d3 fa ff ff       	jmp    104ff0 <alltraps>

0010551d <vector17>:
.globl vector17
vector17:
  pushl $17
  10551d:	6a 11                	push   $0x11
  jmp alltraps
  10551f:	e9 cc fa ff ff       	jmp    104ff0 <alltraps>

00105524 <vector18>:
.globl vector18
vector18:
  pushl $0
  105524:	6a 00                	push   $0x0
  pushl $18
  105526:	6a 12                	push   $0x12
  jmp alltraps
  105528:	e9 c3 fa ff ff       	jmp    104ff0 <alltraps>

0010552d <vector19>:
.globl vector19
vector19:
  pushl $0
  10552d:	6a 00                	push   $0x0
  pushl $19
  10552f:	6a 13                	push   $0x13
  jmp alltraps
  105531:	e9 ba fa ff ff       	jmp    104ff0 <alltraps>

00105536 <vector20>:
.globl vector20
vector20:
  pushl $0
  105536:	6a 00                	push   $0x0
  pushl $20
  105538:	6a 14                	push   $0x14
  jmp alltraps
  10553a:	e9 b1 fa ff ff       	jmp    104ff0 <alltraps>

0010553f <vector21>:
.globl vector21
vector21:
  pushl $0
  10553f:	6a 00                	push   $0x0
  pushl $21
  105541:	6a 15                	push   $0x15
  jmp alltraps
  105543:	e9 a8 fa ff ff       	jmp    104ff0 <alltraps>

00105548 <vector22>:
.globl vector22
vector22:
  pushl $0
  105548:	6a 00                	push   $0x0
  pushl $22
  10554a:	6a 16                	push   $0x16
  jmp alltraps
  10554c:	e9 9f fa ff ff       	jmp    104ff0 <alltraps>

00105551 <vector23>:
.globl vector23
vector23:
  pushl $0
  105551:	6a 00                	push   $0x0
  pushl $23
  105553:	6a 17                	push   $0x17
  jmp alltraps
  105555:	e9 96 fa ff ff       	jmp    104ff0 <alltraps>

0010555a <vector24>:
.globl vector24
vector24:
  pushl $0
  10555a:	6a 00                	push   $0x0
  pushl $24
  10555c:	6a 18                	push   $0x18
  jmp alltraps
  10555e:	e9 8d fa ff ff       	jmp    104ff0 <alltraps>

00105563 <vector25>:
.globl vector25
vector25:
  pushl $0
  105563:	6a 00                	push   $0x0
  pushl $25
  105565:	6a 19                	push   $0x19
  jmp alltraps
  105567:	e9 84 fa ff ff       	jmp    104ff0 <alltraps>

0010556c <vector26>:
.globl vector26
vector26:
  pushl $0
  10556c:	6a 00                	push   $0x0
  pushl $26
  10556e:	6a 1a                	push   $0x1a
  jmp alltraps
  105570:	e9 7b fa ff ff       	jmp    104ff0 <alltraps>

00105575 <vector27>:
.globl vector27
vector27:
  pushl $0
  105575:	6a 00                	push   $0x0
  pushl $27
  105577:	6a 1b                	push   $0x1b
  jmp alltraps
  105579:	e9 72 fa ff ff       	jmp    104ff0 <alltraps>

0010557e <vector28>:
.globl vector28
vector28:
  pushl $0
  10557e:	6a 00                	push   $0x0
  pushl $28
  105580:	6a 1c                	push   $0x1c
  jmp alltraps
  105582:	e9 69 fa ff ff       	jmp    104ff0 <alltraps>

00105587 <vector29>:
.globl vector29
vector29:
  pushl $0
  105587:	6a 00                	push   $0x0
  pushl $29
  105589:	6a 1d                	push   $0x1d
  jmp alltraps
  10558b:	e9 60 fa ff ff       	jmp    104ff0 <alltraps>

00105590 <vector30>:
.globl vector30
vector30:
  pushl $0
  105590:	6a 00                	push   $0x0
  pushl $30
  105592:	6a 1e                	push   $0x1e
  jmp alltraps
  105594:	e9 57 fa ff ff       	jmp    104ff0 <alltraps>

00105599 <vector31>:
.globl vector31
vector31:
  pushl $0
  105599:	6a 00                	push   $0x0
  pushl $31
  10559b:	6a 1f                	push   $0x1f
  jmp alltraps
  10559d:	e9 4e fa ff ff       	jmp    104ff0 <alltraps>

001055a2 <vector32>:
.globl vector32
vector32:
  pushl $0
  1055a2:	6a 00                	push   $0x0
  pushl $32
  1055a4:	6a 20                	push   $0x20
  jmp alltraps
  1055a6:	e9 45 fa ff ff       	jmp    104ff0 <alltraps>

001055ab <vector33>:
.globl vector33
vector33:
  pushl $0
  1055ab:	6a 00                	push   $0x0
  pushl $33
  1055ad:	6a 21                	push   $0x21
  jmp alltraps
  1055af:	e9 3c fa ff ff       	jmp    104ff0 <alltraps>

001055b4 <vector34>:
.globl vector34
vector34:
  pushl $0
  1055b4:	6a 00                	push   $0x0
  pushl $34
  1055b6:	6a 22                	push   $0x22
  jmp alltraps
  1055b8:	e9 33 fa ff ff       	jmp    104ff0 <alltraps>

001055bd <vector35>:
.globl vector35
vector35:
  pushl $0
  1055bd:	6a 00                	push   $0x0
  pushl $35
  1055bf:	6a 23                	push   $0x23
  jmp alltraps
  1055c1:	e9 2a fa ff ff       	jmp    104ff0 <alltraps>

001055c6 <vector36>:
.globl vector36
vector36:
  pushl $0
  1055c6:	6a 00                	push   $0x0
  pushl $36
  1055c8:	6a 24                	push   $0x24
  jmp alltraps
  1055ca:	e9 21 fa ff ff       	jmp    104ff0 <alltraps>

001055cf <vector37>:
.globl vector37
vector37:
  pushl $0
  1055cf:	6a 00                	push   $0x0
  pushl $37
  1055d1:	6a 25                	push   $0x25
  jmp alltraps
  1055d3:	e9 18 fa ff ff       	jmp    104ff0 <alltraps>

001055d8 <vector38>:
.globl vector38
vector38:
  pushl $0
  1055d8:	6a 00                	push   $0x0
  pushl $38
  1055da:	6a 26                	push   $0x26
  jmp alltraps
  1055dc:	e9 0f fa ff ff       	jmp    104ff0 <alltraps>

001055e1 <vector39>:
.globl vector39
vector39:
  pushl $0
  1055e1:	6a 00                	push   $0x0
  pushl $39
  1055e3:	6a 27                	push   $0x27
  jmp alltraps
  1055e5:	e9 06 fa ff ff       	jmp    104ff0 <alltraps>

001055ea <vector40>:
.globl vector40
vector40:
  pushl $0
  1055ea:	6a 00                	push   $0x0
  pushl $40
  1055ec:	6a 28                	push   $0x28
  jmp alltraps
  1055ee:	e9 fd f9 ff ff       	jmp    104ff0 <alltraps>

001055f3 <vector41>:
.globl vector41
vector41:
  pushl $0
  1055f3:	6a 00                	push   $0x0
  pushl $41
  1055f5:	6a 29                	push   $0x29
  jmp alltraps
  1055f7:	e9 f4 f9 ff ff       	jmp    104ff0 <alltraps>

001055fc <vector42>:
.globl vector42
vector42:
  pushl $0
  1055fc:	6a 00                	push   $0x0
  pushl $42
  1055fe:	6a 2a                	push   $0x2a
  jmp alltraps
  105600:	e9 eb f9 ff ff       	jmp    104ff0 <alltraps>

00105605 <vector43>:
.globl vector43
vector43:
  pushl $0
  105605:	6a 00                	push   $0x0
  pushl $43
  105607:	6a 2b                	push   $0x2b
  jmp alltraps
  105609:	e9 e2 f9 ff ff       	jmp    104ff0 <alltraps>

0010560e <vector44>:
.globl vector44
vector44:
  pushl $0
  10560e:	6a 00                	push   $0x0
  pushl $44
  105610:	6a 2c                	push   $0x2c
  jmp alltraps
  105612:	e9 d9 f9 ff ff       	jmp    104ff0 <alltraps>

00105617 <vector45>:
.globl vector45
vector45:
  pushl $0
  105617:	6a 00                	push   $0x0
  pushl $45
  105619:	6a 2d                	push   $0x2d
  jmp alltraps
  10561b:	e9 d0 f9 ff ff       	jmp    104ff0 <alltraps>

00105620 <vector46>:
.globl vector46
vector46:
  pushl $0
  105620:	6a 00                	push   $0x0
  pushl $46
  105622:	6a 2e                	push   $0x2e
  jmp alltraps
  105624:	e9 c7 f9 ff ff       	jmp    104ff0 <alltraps>

00105629 <vector47>:
.globl vector47
vector47:
  pushl $0
  105629:	6a 00                	push   $0x0
  pushl $47
  10562b:	6a 2f                	push   $0x2f
  jmp alltraps
  10562d:	e9 be f9 ff ff       	jmp    104ff0 <alltraps>

00105632 <vector48>:
.globl vector48
vector48:
  pushl $0
  105632:	6a 00                	push   $0x0
  pushl $48
  105634:	6a 30                	push   $0x30
  jmp alltraps
  105636:	e9 b5 f9 ff ff       	jmp    104ff0 <alltraps>

0010563b <vector49>:
.globl vector49
vector49:
  pushl $0
  10563b:	6a 00                	push   $0x0
  pushl $49
  10563d:	6a 31                	push   $0x31
  jmp alltraps
  10563f:	e9 ac f9 ff ff       	jmp    104ff0 <alltraps>

00105644 <vector50>:
.globl vector50
vector50:
  pushl $0
  105644:	6a 00                	push   $0x0
  pushl $50
  105646:	6a 32                	push   $0x32
  jmp alltraps
  105648:	e9 a3 f9 ff ff       	jmp    104ff0 <alltraps>

0010564d <vector51>:
.globl vector51
vector51:
  pushl $0
  10564d:	6a 00                	push   $0x0
  pushl $51
  10564f:	6a 33                	push   $0x33
  jmp alltraps
  105651:	e9 9a f9 ff ff       	jmp    104ff0 <alltraps>

00105656 <vector52>:
.globl vector52
vector52:
  pushl $0
  105656:	6a 00                	push   $0x0
  pushl $52
  105658:	6a 34                	push   $0x34
  jmp alltraps
  10565a:	e9 91 f9 ff ff       	jmp    104ff0 <alltraps>

0010565f <vector53>:
.globl vector53
vector53:
  pushl $0
  10565f:	6a 00                	push   $0x0
  pushl $53
  105661:	6a 35                	push   $0x35
  jmp alltraps
  105663:	e9 88 f9 ff ff       	jmp    104ff0 <alltraps>

00105668 <vector54>:
.globl vector54
vector54:
  pushl $0
  105668:	6a 00                	push   $0x0
  pushl $54
  10566a:	6a 36                	push   $0x36
  jmp alltraps
  10566c:	e9 7f f9 ff ff       	jmp    104ff0 <alltraps>

00105671 <vector55>:
.globl vector55
vector55:
  pushl $0
  105671:	6a 00                	push   $0x0
  pushl $55
  105673:	6a 37                	push   $0x37
  jmp alltraps
  105675:	e9 76 f9 ff ff       	jmp    104ff0 <alltraps>

0010567a <vector56>:
.globl vector56
vector56:
  pushl $0
  10567a:	6a 00                	push   $0x0
  pushl $56
  10567c:	6a 38                	push   $0x38
  jmp alltraps
  10567e:	e9 6d f9 ff ff       	jmp    104ff0 <alltraps>

00105683 <vector57>:
.globl vector57
vector57:
  pushl $0
  105683:	6a 00                	push   $0x0
  pushl $57
  105685:	6a 39                	push   $0x39
  jmp alltraps
  105687:	e9 64 f9 ff ff       	jmp    104ff0 <alltraps>

0010568c <vector58>:
.globl vector58
vector58:
  pushl $0
  10568c:	6a 00                	push   $0x0
  pushl $58
  10568e:	6a 3a                	push   $0x3a
  jmp alltraps
  105690:	e9 5b f9 ff ff       	jmp    104ff0 <alltraps>

00105695 <vector59>:
.globl vector59
vector59:
  pushl $0
  105695:	6a 00                	push   $0x0
  pushl $59
  105697:	6a 3b                	push   $0x3b
  jmp alltraps
  105699:	e9 52 f9 ff ff       	jmp    104ff0 <alltraps>

0010569e <vector60>:
.globl vector60
vector60:
  pushl $0
  10569e:	6a 00                	push   $0x0
  pushl $60
  1056a0:	6a 3c                	push   $0x3c
  jmp alltraps
  1056a2:	e9 49 f9 ff ff       	jmp    104ff0 <alltraps>

001056a7 <vector61>:
.globl vector61
vector61:
  pushl $0
  1056a7:	6a 00                	push   $0x0
  pushl $61
  1056a9:	6a 3d                	push   $0x3d
  jmp alltraps
  1056ab:	e9 40 f9 ff ff       	jmp    104ff0 <alltraps>

001056b0 <vector62>:
.globl vector62
vector62:
  pushl $0
  1056b0:	6a 00                	push   $0x0
  pushl $62
  1056b2:	6a 3e                	push   $0x3e
  jmp alltraps
  1056b4:	e9 37 f9 ff ff       	jmp    104ff0 <alltraps>

001056b9 <vector63>:
.globl vector63
vector63:
  pushl $0
  1056b9:	6a 00                	push   $0x0
  pushl $63
  1056bb:	6a 3f                	push   $0x3f
  jmp alltraps
  1056bd:	e9 2e f9 ff ff       	jmp    104ff0 <alltraps>

001056c2 <vector64>:
.globl vector64
vector64:
  pushl $0
  1056c2:	6a 00                	push   $0x0
  pushl $64
  1056c4:	6a 40                	push   $0x40
  jmp alltraps
  1056c6:	e9 25 f9 ff ff       	jmp    104ff0 <alltraps>

001056cb <vector65>:
.globl vector65
vector65:
  pushl $0
  1056cb:	6a 00                	push   $0x0
  pushl $65
  1056cd:	6a 41                	push   $0x41
  jmp alltraps
  1056cf:	e9 1c f9 ff ff       	jmp    104ff0 <alltraps>

001056d4 <vector66>:
.globl vector66
vector66:
  pushl $0
  1056d4:	6a 00                	push   $0x0
  pushl $66
  1056d6:	6a 42                	push   $0x42
  jmp alltraps
  1056d8:	e9 13 f9 ff ff       	jmp    104ff0 <alltraps>

001056dd <vector67>:
.globl vector67
vector67:
  pushl $0
  1056dd:	6a 00                	push   $0x0
  pushl $67
  1056df:	6a 43                	push   $0x43
  jmp alltraps
  1056e1:	e9 0a f9 ff ff       	jmp    104ff0 <alltraps>

001056e6 <vector68>:
.globl vector68
vector68:
  pushl $0
  1056e6:	6a 00                	push   $0x0
  pushl $68
  1056e8:	6a 44                	push   $0x44
  jmp alltraps
  1056ea:	e9 01 f9 ff ff       	jmp    104ff0 <alltraps>

001056ef <vector69>:
.globl vector69
vector69:
  pushl $0
  1056ef:	6a 00                	push   $0x0
  pushl $69
  1056f1:	6a 45                	push   $0x45
  jmp alltraps
  1056f3:	e9 f8 f8 ff ff       	jmp    104ff0 <alltraps>

001056f8 <vector70>:
.globl vector70
vector70:
  pushl $0
  1056f8:	6a 00                	push   $0x0
  pushl $70
  1056fa:	6a 46                	push   $0x46
  jmp alltraps
  1056fc:	e9 ef f8 ff ff       	jmp    104ff0 <alltraps>

00105701 <vector71>:
.globl vector71
vector71:
  pushl $0
  105701:	6a 00                	push   $0x0
  pushl $71
  105703:	6a 47                	push   $0x47
  jmp alltraps
  105705:	e9 e6 f8 ff ff       	jmp    104ff0 <alltraps>

0010570a <vector72>:
.globl vector72
vector72:
  pushl $0
  10570a:	6a 00                	push   $0x0
  pushl $72
  10570c:	6a 48                	push   $0x48
  jmp alltraps
  10570e:	e9 dd f8 ff ff       	jmp    104ff0 <alltraps>

00105713 <vector73>:
.globl vector73
vector73:
  pushl $0
  105713:	6a 00                	push   $0x0
  pushl $73
  105715:	6a 49                	push   $0x49
  jmp alltraps
  105717:	e9 d4 f8 ff ff       	jmp    104ff0 <alltraps>

0010571c <vector74>:
.globl vector74
vector74:
  pushl $0
  10571c:	6a 00                	push   $0x0
  pushl $74
  10571e:	6a 4a                	push   $0x4a
  jmp alltraps
  105720:	e9 cb f8 ff ff       	jmp    104ff0 <alltraps>

00105725 <vector75>:
.globl vector75
vector75:
  pushl $0
  105725:	6a 00                	push   $0x0
  pushl $75
  105727:	6a 4b                	push   $0x4b
  jmp alltraps
  105729:	e9 c2 f8 ff ff       	jmp    104ff0 <alltraps>

0010572e <vector76>:
.globl vector76
vector76:
  pushl $0
  10572e:	6a 00                	push   $0x0
  pushl $76
  105730:	6a 4c                	push   $0x4c
  jmp alltraps
  105732:	e9 b9 f8 ff ff       	jmp    104ff0 <alltraps>

00105737 <vector77>:
.globl vector77
vector77:
  pushl $0
  105737:	6a 00                	push   $0x0
  pushl $77
  105739:	6a 4d                	push   $0x4d
  jmp alltraps
  10573b:	e9 b0 f8 ff ff       	jmp    104ff0 <alltraps>

00105740 <vector78>:
.globl vector78
vector78:
  pushl $0
  105740:	6a 00                	push   $0x0
  pushl $78
  105742:	6a 4e                	push   $0x4e
  jmp alltraps
  105744:	e9 a7 f8 ff ff       	jmp    104ff0 <alltraps>

00105749 <vector79>:
.globl vector79
vector79:
  pushl $0
  105749:	6a 00                	push   $0x0
  pushl $79
  10574b:	6a 4f                	push   $0x4f
  jmp alltraps
  10574d:	e9 9e f8 ff ff       	jmp    104ff0 <alltraps>

00105752 <vector80>:
.globl vector80
vector80:
  pushl $0
  105752:	6a 00                	push   $0x0
  pushl $80
  105754:	6a 50                	push   $0x50
  jmp alltraps
  105756:	e9 95 f8 ff ff       	jmp    104ff0 <alltraps>

0010575b <vector81>:
.globl vector81
vector81:
  pushl $0
  10575b:	6a 00                	push   $0x0
  pushl $81
  10575d:	6a 51                	push   $0x51
  jmp alltraps
  10575f:	e9 8c f8 ff ff       	jmp    104ff0 <alltraps>

00105764 <vector82>:
.globl vector82
vector82:
  pushl $0
  105764:	6a 00                	push   $0x0
  pushl $82
  105766:	6a 52                	push   $0x52
  jmp alltraps
  105768:	e9 83 f8 ff ff       	jmp    104ff0 <alltraps>

0010576d <vector83>:
.globl vector83
vector83:
  pushl $0
  10576d:	6a 00                	push   $0x0
  pushl $83
  10576f:	6a 53                	push   $0x53
  jmp alltraps
  105771:	e9 7a f8 ff ff       	jmp    104ff0 <alltraps>

00105776 <vector84>:
.globl vector84
vector84:
  pushl $0
  105776:	6a 00                	push   $0x0
  pushl $84
  105778:	6a 54                	push   $0x54
  jmp alltraps
  10577a:	e9 71 f8 ff ff       	jmp    104ff0 <alltraps>

0010577f <vector85>:
.globl vector85
vector85:
  pushl $0
  10577f:	6a 00                	push   $0x0
  pushl $85
  105781:	6a 55                	push   $0x55
  jmp alltraps
  105783:	e9 68 f8 ff ff       	jmp    104ff0 <alltraps>

00105788 <vector86>:
.globl vector86
vector86:
  pushl $0
  105788:	6a 00                	push   $0x0
  pushl $86
  10578a:	6a 56                	push   $0x56
  jmp alltraps
  10578c:	e9 5f f8 ff ff       	jmp    104ff0 <alltraps>

00105791 <vector87>:
.globl vector87
vector87:
  pushl $0
  105791:	6a 00                	push   $0x0
  pushl $87
  105793:	6a 57                	push   $0x57
  jmp alltraps
  105795:	e9 56 f8 ff ff       	jmp    104ff0 <alltraps>

0010579a <vector88>:
.globl vector88
vector88:
  pushl $0
  10579a:	6a 00                	push   $0x0
  pushl $88
  10579c:	6a 58                	push   $0x58
  jmp alltraps
  10579e:	e9 4d f8 ff ff       	jmp    104ff0 <alltraps>

001057a3 <vector89>:
.globl vector89
vector89:
  pushl $0
  1057a3:	6a 00                	push   $0x0
  pushl $89
  1057a5:	6a 59                	push   $0x59
  jmp alltraps
  1057a7:	e9 44 f8 ff ff       	jmp    104ff0 <alltraps>

001057ac <vector90>:
.globl vector90
vector90:
  pushl $0
  1057ac:	6a 00                	push   $0x0
  pushl $90
  1057ae:	6a 5a                	push   $0x5a
  jmp alltraps
  1057b0:	e9 3b f8 ff ff       	jmp    104ff0 <alltraps>

001057b5 <vector91>:
.globl vector91
vector91:
  pushl $0
  1057b5:	6a 00                	push   $0x0
  pushl $91
  1057b7:	6a 5b                	push   $0x5b
  jmp alltraps
  1057b9:	e9 32 f8 ff ff       	jmp    104ff0 <alltraps>

001057be <vector92>:
.globl vector92
vector92:
  pushl $0
  1057be:	6a 00                	push   $0x0
  pushl $92
  1057c0:	6a 5c                	push   $0x5c
  jmp alltraps
  1057c2:	e9 29 f8 ff ff       	jmp    104ff0 <alltraps>

001057c7 <vector93>:
.globl vector93
vector93:
  pushl $0
  1057c7:	6a 00                	push   $0x0
  pushl $93
  1057c9:	6a 5d                	push   $0x5d
  jmp alltraps
  1057cb:	e9 20 f8 ff ff       	jmp    104ff0 <alltraps>

001057d0 <vector94>:
.globl vector94
vector94:
  pushl $0
  1057d0:	6a 00                	push   $0x0
  pushl $94
  1057d2:	6a 5e                	push   $0x5e
  jmp alltraps
  1057d4:	e9 17 f8 ff ff       	jmp    104ff0 <alltraps>

001057d9 <vector95>:
.globl vector95
vector95:
  pushl $0
  1057d9:	6a 00                	push   $0x0
  pushl $95
  1057db:	6a 5f                	push   $0x5f
  jmp alltraps
  1057dd:	e9 0e f8 ff ff       	jmp    104ff0 <alltraps>

001057e2 <vector96>:
.globl vector96
vector96:
  pushl $0
  1057e2:	6a 00                	push   $0x0
  pushl $96
  1057e4:	6a 60                	push   $0x60
  jmp alltraps
  1057e6:	e9 05 f8 ff ff       	jmp    104ff0 <alltraps>

001057eb <vector97>:
.globl vector97
vector97:
  pushl $0
  1057eb:	6a 00                	push   $0x0
  pushl $97
  1057ed:	6a 61                	push   $0x61
  jmp alltraps
  1057ef:	e9 fc f7 ff ff       	jmp    104ff0 <alltraps>

001057f4 <vector98>:
.globl vector98
vector98:
  pushl $0
  1057f4:	6a 00                	push   $0x0
  pushl $98
  1057f6:	6a 62                	push   $0x62
  jmp alltraps
  1057f8:	e9 f3 f7 ff ff       	jmp    104ff0 <alltraps>

001057fd <vector99>:
.globl vector99
vector99:
  pushl $0
  1057fd:	6a 00                	push   $0x0
  pushl $99
  1057ff:	6a 63                	push   $0x63
  jmp alltraps
  105801:	e9 ea f7 ff ff       	jmp    104ff0 <alltraps>

00105806 <vector100>:
.globl vector100
vector100:
  pushl $0
  105806:	6a 00                	push   $0x0
  pushl $100
  105808:	6a 64                	push   $0x64
  jmp alltraps
  10580a:	e9 e1 f7 ff ff       	jmp    104ff0 <alltraps>

0010580f <vector101>:
.globl vector101
vector101:
  pushl $0
  10580f:	6a 00                	push   $0x0
  pushl $101
  105811:	6a 65                	push   $0x65
  jmp alltraps
  105813:	e9 d8 f7 ff ff       	jmp    104ff0 <alltraps>

00105818 <vector102>:
.globl vector102
vector102:
  pushl $0
  105818:	6a 00                	push   $0x0
  pushl $102
  10581a:	6a 66                	push   $0x66
  jmp alltraps
  10581c:	e9 cf f7 ff ff       	jmp    104ff0 <alltraps>

00105821 <vector103>:
.globl vector103
vector103:
  pushl $0
  105821:	6a 00                	push   $0x0
  pushl $103
  105823:	6a 67                	push   $0x67
  jmp alltraps
  105825:	e9 c6 f7 ff ff       	jmp    104ff0 <alltraps>

0010582a <vector104>:
.globl vector104
vector104:
  pushl $0
  10582a:	6a 00                	push   $0x0
  pushl $104
  10582c:	6a 68                	push   $0x68
  jmp alltraps
  10582e:	e9 bd f7 ff ff       	jmp    104ff0 <alltraps>

00105833 <vector105>:
.globl vector105
vector105:
  pushl $0
  105833:	6a 00                	push   $0x0
  pushl $105
  105835:	6a 69                	push   $0x69
  jmp alltraps
  105837:	e9 b4 f7 ff ff       	jmp    104ff0 <alltraps>

0010583c <vector106>:
.globl vector106
vector106:
  pushl $0
  10583c:	6a 00                	push   $0x0
  pushl $106
  10583e:	6a 6a                	push   $0x6a
  jmp alltraps
  105840:	e9 ab f7 ff ff       	jmp    104ff0 <alltraps>

00105845 <vector107>:
.globl vector107
vector107:
  pushl $0
  105845:	6a 00                	push   $0x0
  pushl $107
  105847:	6a 6b                	push   $0x6b
  jmp alltraps
  105849:	e9 a2 f7 ff ff       	jmp    104ff0 <alltraps>

0010584e <vector108>:
.globl vector108
vector108:
  pushl $0
  10584e:	6a 00                	push   $0x0
  pushl $108
  105850:	6a 6c                	push   $0x6c
  jmp alltraps
  105852:	e9 99 f7 ff ff       	jmp    104ff0 <alltraps>

00105857 <vector109>:
.globl vector109
vector109:
  pushl $0
  105857:	6a 00                	push   $0x0
  pushl $109
  105859:	6a 6d                	push   $0x6d
  jmp alltraps
  10585b:	e9 90 f7 ff ff       	jmp    104ff0 <alltraps>

00105860 <vector110>:
.globl vector110
vector110:
  pushl $0
  105860:	6a 00                	push   $0x0
  pushl $110
  105862:	6a 6e                	push   $0x6e
  jmp alltraps
  105864:	e9 87 f7 ff ff       	jmp    104ff0 <alltraps>

00105869 <vector111>:
.globl vector111
vector111:
  pushl $0
  105869:	6a 00                	push   $0x0
  pushl $111
  10586b:	6a 6f                	push   $0x6f
  jmp alltraps
  10586d:	e9 7e f7 ff ff       	jmp    104ff0 <alltraps>

00105872 <vector112>:
.globl vector112
vector112:
  pushl $0
  105872:	6a 00                	push   $0x0
  pushl $112
  105874:	6a 70                	push   $0x70
  jmp alltraps
  105876:	e9 75 f7 ff ff       	jmp    104ff0 <alltraps>

0010587b <vector113>:
.globl vector113
vector113:
  pushl $0
  10587b:	6a 00                	push   $0x0
  pushl $113
  10587d:	6a 71                	push   $0x71
  jmp alltraps
  10587f:	e9 6c f7 ff ff       	jmp    104ff0 <alltraps>

00105884 <vector114>:
.globl vector114
vector114:
  pushl $0
  105884:	6a 00                	push   $0x0
  pushl $114
  105886:	6a 72                	push   $0x72
  jmp alltraps
  105888:	e9 63 f7 ff ff       	jmp    104ff0 <alltraps>

0010588d <vector115>:
.globl vector115
vector115:
  pushl $0
  10588d:	6a 00                	push   $0x0
  pushl $115
  10588f:	6a 73                	push   $0x73
  jmp alltraps
  105891:	e9 5a f7 ff ff       	jmp    104ff0 <alltraps>

00105896 <vector116>:
.globl vector116
vector116:
  pushl $0
  105896:	6a 00                	push   $0x0
  pushl $116
  105898:	6a 74                	push   $0x74
  jmp alltraps
  10589a:	e9 51 f7 ff ff       	jmp    104ff0 <alltraps>

0010589f <vector117>:
.globl vector117
vector117:
  pushl $0
  10589f:	6a 00                	push   $0x0
  pushl $117
  1058a1:	6a 75                	push   $0x75
  jmp alltraps
  1058a3:	e9 48 f7 ff ff       	jmp    104ff0 <alltraps>

001058a8 <vector118>:
.globl vector118
vector118:
  pushl $0
  1058a8:	6a 00                	push   $0x0
  pushl $118
  1058aa:	6a 76                	push   $0x76
  jmp alltraps
  1058ac:	e9 3f f7 ff ff       	jmp    104ff0 <alltraps>

001058b1 <vector119>:
.globl vector119
vector119:
  pushl $0
  1058b1:	6a 00                	push   $0x0
  pushl $119
  1058b3:	6a 77                	push   $0x77
  jmp alltraps
  1058b5:	e9 36 f7 ff ff       	jmp    104ff0 <alltraps>

001058ba <vector120>:
.globl vector120
vector120:
  pushl $0
  1058ba:	6a 00                	push   $0x0
  pushl $120
  1058bc:	6a 78                	push   $0x78
  jmp alltraps
  1058be:	e9 2d f7 ff ff       	jmp    104ff0 <alltraps>

001058c3 <vector121>:
.globl vector121
vector121:
  pushl $0
  1058c3:	6a 00                	push   $0x0
  pushl $121
  1058c5:	6a 79                	push   $0x79
  jmp alltraps
  1058c7:	e9 24 f7 ff ff       	jmp    104ff0 <alltraps>

001058cc <vector122>:
.globl vector122
vector122:
  pushl $0
  1058cc:	6a 00                	push   $0x0
  pushl $122
  1058ce:	6a 7a                	push   $0x7a
  jmp alltraps
  1058d0:	e9 1b f7 ff ff       	jmp    104ff0 <alltraps>

001058d5 <vector123>:
.globl vector123
vector123:
  pushl $0
  1058d5:	6a 00                	push   $0x0
  pushl $123
  1058d7:	6a 7b                	push   $0x7b
  jmp alltraps
  1058d9:	e9 12 f7 ff ff       	jmp    104ff0 <alltraps>

001058de <vector124>:
.globl vector124
vector124:
  pushl $0
  1058de:	6a 00                	push   $0x0
  pushl $124
  1058e0:	6a 7c                	push   $0x7c
  jmp alltraps
  1058e2:	e9 09 f7 ff ff       	jmp    104ff0 <alltraps>

001058e7 <vector125>:
.globl vector125
vector125:
  pushl $0
  1058e7:	6a 00                	push   $0x0
  pushl $125
  1058e9:	6a 7d                	push   $0x7d
  jmp alltraps
  1058eb:	e9 00 f7 ff ff       	jmp    104ff0 <alltraps>

001058f0 <vector126>:
.globl vector126
vector126:
  pushl $0
  1058f0:	6a 00                	push   $0x0
  pushl $126
  1058f2:	6a 7e                	push   $0x7e
  jmp alltraps
  1058f4:	e9 f7 f6 ff ff       	jmp    104ff0 <alltraps>

001058f9 <vector127>:
.globl vector127
vector127:
  pushl $0
  1058f9:	6a 00                	push   $0x0
  pushl $127
  1058fb:	6a 7f                	push   $0x7f
  jmp alltraps
  1058fd:	e9 ee f6 ff ff       	jmp    104ff0 <alltraps>

00105902 <vector128>:
.globl vector128
vector128:
  pushl $0
  105902:	6a 00                	push   $0x0
  pushl $128
  105904:	68 80 00 00 00       	push   $0x80
  jmp alltraps
  105909:	e9 e2 f6 ff ff       	jmp    104ff0 <alltraps>

0010590e <vector129>:
.globl vector129
vector129:
  pushl $0
  10590e:	6a 00                	push   $0x0
  pushl $129
  105910:	68 81 00 00 00       	push   $0x81
  jmp alltraps
  105915:	e9 d6 f6 ff ff       	jmp    104ff0 <alltraps>

0010591a <vector130>:
.globl vector130
vector130:
  pushl $0
  10591a:	6a 00                	push   $0x0
  pushl $130
  10591c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
  105921:	e9 ca f6 ff ff       	jmp    104ff0 <alltraps>

00105926 <vector131>:
.globl vector131
vector131:
  pushl $0
  105926:	6a 00                	push   $0x0
  pushl $131
  105928:	68 83 00 00 00       	push   $0x83
  jmp alltraps
  10592d:	e9 be f6 ff ff       	jmp    104ff0 <alltraps>

00105932 <vector132>:
.globl vector132
vector132:
  pushl $0
  105932:	6a 00                	push   $0x0
  pushl $132
  105934:	68 84 00 00 00       	push   $0x84
  jmp alltraps
  105939:	e9 b2 f6 ff ff       	jmp    104ff0 <alltraps>

0010593e <vector133>:
.globl vector133
vector133:
  pushl $0
  10593e:	6a 00                	push   $0x0
  pushl $133
  105940:	68 85 00 00 00       	push   $0x85
  jmp alltraps
  105945:	e9 a6 f6 ff ff       	jmp    104ff0 <alltraps>

0010594a <vector134>:
.globl vector134
vector134:
  pushl $0
  10594a:	6a 00                	push   $0x0
  pushl $134
  10594c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
  105951:	e9 9a f6 ff ff       	jmp    104ff0 <alltraps>

00105956 <vector135>:
.globl vector135
vector135:
  pushl $0
  105956:	6a 00                	push   $0x0
  pushl $135
  105958:	68 87 00 00 00       	push   $0x87
  jmp alltraps
  10595d:	e9 8e f6 ff ff       	jmp    104ff0 <alltraps>

00105962 <vector136>:
.globl vector136
vector136:
  pushl $0
  105962:	6a 00                	push   $0x0
  pushl $136
  105964:	68 88 00 00 00       	push   $0x88
  jmp alltraps
  105969:	e9 82 f6 ff ff       	jmp    104ff0 <alltraps>

0010596e <vector137>:
.globl vector137
vector137:
  pushl $0
  10596e:	6a 00                	push   $0x0
  pushl $137
  105970:	68 89 00 00 00       	push   $0x89
  jmp alltraps
  105975:	e9 76 f6 ff ff       	jmp    104ff0 <alltraps>

0010597a <vector138>:
.globl vector138
vector138:
  pushl $0
  10597a:	6a 00                	push   $0x0
  pushl $138
  10597c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
  105981:	e9 6a f6 ff ff       	jmp    104ff0 <alltraps>

00105986 <vector139>:
.globl vector139
vector139:
  pushl $0
  105986:	6a 00                	push   $0x0
  pushl $139
  105988:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
  10598d:	e9 5e f6 ff ff       	jmp    104ff0 <alltraps>

00105992 <vector140>:
.globl vector140
vector140:
  pushl $0
  105992:	6a 00                	push   $0x0
  pushl $140
  105994:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
  105999:	e9 52 f6 ff ff       	jmp    104ff0 <alltraps>

0010599e <vector141>:
.globl vector141
vector141:
  pushl $0
  10599e:	6a 00                	push   $0x0
  pushl $141
  1059a0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
  1059a5:	e9 46 f6 ff ff       	jmp    104ff0 <alltraps>

001059aa <vector142>:
.globl vector142
vector142:
  pushl $0
  1059aa:	6a 00                	push   $0x0
  pushl $142
  1059ac:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
  1059b1:	e9 3a f6 ff ff       	jmp    104ff0 <alltraps>

001059b6 <vector143>:
.globl vector143
vector143:
  pushl $0
  1059b6:	6a 00                	push   $0x0
  pushl $143
  1059b8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
  1059bd:	e9 2e f6 ff ff       	jmp    104ff0 <alltraps>

001059c2 <vector144>:
.globl vector144
vector144:
  pushl $0
  1059c2:	6a 00                	push   $0x0
  pushl $144
  1059c4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
  1059c9:	e9 22 f6 ff ff       	jmp    104ff0 <alltraps>

001059ce <vector145>:
.globl vector145
vector145:
  pushl $0
  1059ce:	6a 00                	push   $0x0
  pushl $145
  1059d0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
  1059d5:	e9 16 f6 ff ff       	jmp    104ff0 <alltraps>

001059da <vector146>:
.globl vector146
vector146:
  pushl $0
  1059da:	6a 00                	push   $0x0
  pushl $146
  1059dc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
  1059e1:	e9 0a f6 ff ff       	jmp    104ff0 <alltraps>

001059e6 <vector147>:
.globl vector147
vector147:
  pushl $0
  1059e6:	6a 00                	push   $0x0
  pushl $147
  1059e8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
  1059ed:	e9 fe f5 ff ff       	jmp    104ff0 <alltraps>

001059f2 <vector148>:
.globl vector148
vector148:
  pushl $0
  1059f2:	6a 00                	push   $0x0
  pushl $148
  1059f4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
  1059f9:	e9 f2 f5 ff ff       	jmp    104ff0 <alltraps>

001059fe <vector149>:
.globl vector149
vector149:
  pushl $0
  1059fe:	6a 00                	push   $0x0
  pushl $149
  105a00:	68 95 00 00 00       	push   $0x95
  jmp alltraps
  105a05:	e9 e6 f5 ff ff       	jmp    104ff0 <alltraps>

00105a0a <vector150>:
.globl vector150
vector150:
  pushl $0
  105a0a:	6a 00                	push   $0x0
  pushl $150
  105a0c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
  105a11:	e9 da f5 ff ff       	jmp    104ff0 <alltraps>

00105a16 <vector151>:
.globl vector151
vector151:
  pushl $0
  105a16:	6a 00                	push   $0x0
  pushl $151
  105a18:	68 97 00 00 00       	push   $0x97
  jmp alltraps
  105a1d:	e9 ce f5 ff ff       	jmp    104ff0 <alltraps>

00105a22 <vector152>:
.globl vector152
vector152:
  pushl $0
  105a22:	6a 00                	push   $0x0
  pushl $152
  105a24:	68 98 00 00 00       	push   $0x98
  jmp alltraps
  105a29:	e9 c2 f5 ff ff       	jmp    104ff0 <alltraps>

00105a2e <vector153>:
.globl vector153
vector153:
  pushl $0
  105a2e:	6a 00                	push   $0x0
  pushl $153
  105a30:	68 99 00 00 00       	push   $0x99
  jmp alltraps
  105a35:	e9 b6 f5 ff ff       	jmp    104ff0 <alltraps>

00105a3a <vector154>:
.globl vector154
vector154:
  pushl $0
  105a3a:	6a 00                	push   $0x0
  pushl $154
  105a3c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
  105a41:	e9 aa f5 ff ff       	jmp    104ff0 <alltraps>

00105a46 <vector155>:
.globl vector155
vector155:
  pushl $0
  105a46:	6a 00                	push   $0x0
  pushl $155
  105a48:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
  105a4d:	e9 9e f5 ff ff       	jmp    104ff0 <alltraps>

00105a52 <vector156>:
.globl vector156
vector156:
  pushl $0
  105a52:	6a 00                	push   $0x0
  pushl $156
  105a54:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
  105a59:	e9 92 f5 ff ff       	jmp    104ff0 <alltraps>

00105a5e <vector157>:
.globl vector157
vector157:
  pushl $0
  105a5e:	6a 00                	push   $0x0
  pushl $157
  105a60:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
  105a65:	e9 86 f5 ff ff       	jmp    104ff0 <alltraps>

00105a6a <vector158>:
.globl vector158
vector158:
  pushl $0
  105a6a:	6a 00                	push   $0x0
  pushl $158
  105a6c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
  105a71:	e9 7a f5 ff ff       	jmp    104ff0 <alltraps>

00105a76 <vector159>:
.globl vector159
vector159:
  pushl $0
  105a76:	6a 00                	push   $0x0
  pushl $159
  105a78:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
  105a7d:	e9 6e f5 ff ff       	jmp    104ff0 <alltraps>

00105a82 <vector160>:
.globl vector160
vector160:
  pushl $0
  105a82:	6a 00                	push   $0x0
  pushl $160
  105a84:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
  105a89:	e9 62 f5 ff ff       	jmp    104ff0 <alltraps>

00105a8e <vector161>:
.globl vector161
vector161:
  pushl $0
  105a8e:	6a 00                	push   $0x0
  pushl $161
  105a90:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
  105a95:	e9 56 f5 ff ff       	jmp    104ff0 <alltraps>

00105a9a <vector162>:
.globl vector162
vector162:
  pushl $0
  105a9a:	6a 00                	push   $0x0
  pushl $162
  105a9c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
  105aa1:	e9 4a f5 ff ff       	jmp    104ff0 <alltraps>

00105aa6 <vector163>:
.globl vector163
vector163:
  pushl $0
  105aa6:	6a 00                	push   $0x0
  pushl $163
  105aa8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
  105aad:	e9 3e f5 ff ff       	jmp    104ff0 <alltraps>

00105ab2 <vector164>:
.globl vector164
vector164:
  pushl $0
  105ab2:	6a 00                	push   $0x0
  pushl $164
  105ab4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
  105ab9:	e9 32 f5 ff ff       	jmp    104ff0 <alltraps>

00105abe <vector165>:
.globl vector165
vector165:
  pushl $0
  105abe:	6a 00                	push   $0x0
  pushl $165
  105ac0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
  105ac5:	e9 26 f5 ff ff       	jmp    104ff0 <alltraps>

00105aca <vector166>:
.globl vector166
vector166:
  pushl $0
  105aca:	6a 00                	push   $0x0
  pushl $166
  105acc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
  105ad1:	e9 1a f5 ff ff       	jmp    104ff0 <alltraps>

00105ad6 <vector167>:
.globl vector167
vector167:
  pushl $0
  105ad6:	6a 00                	push   $0x0
  pushl $167
  105ad8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
  105add:	e9 0e f5 ff ff       	jmp    104ff0 <alltraps>

00105ae2 <vector168>:
.globl vector168
vector168:
  pushl $0
  105ae2:	6a 00                	push   $0x0
  pushl $168
  105ae4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
  105ae9:	e9 02 f5 ff ff       	jmp    104ff0 <alltraps>

00105aee <vector169>:
.globl vector169
vector169:
  pushl $0
  105aee:	6a 00                	push   $0x0
  pushl $169
  105af0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
  105af5:	e9 f6 f4 ff ff       	jmp    104ff0 <alltraps>

00105afa <vector170>:
.globl vector170
vector170:
  pushl $0
  105afa:	6a 00                	push   $0x0
  pushl $170
  105afc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
  105b01:	e9 ea f4 ff ff       	jmp    104ff0 <alltraps>

00105b06 <vector171>:
.globl vector171
vector171:
  pushl $0
  105b06:	6a 00                	push   $0x0
  pushl $171
  105b08:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
  105b0d:	e9 de f4 ff ff       	jmp    104ff0 <alltraps>

00105b12 <vector172>:
.globl vector172
vector172:
  pushl $0
  105b12:	6a 00                	push   $0x0
  pushl $172
  105b14:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
  105b19:	e9 d2 f4 ff ff       	jmp    104ff0 <alltraps>

00105b1e <vector173>:
.globl vector173
vector173:
  pushl $0
  105b1e:	6a 00                	push   $0x0
  pushl $173
  105b20:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
  105b25:	e9 c6 f4 ff ff       	jmp    104ff0 <alltraps>

00105b2a <vector174>:
.globl vector174
vector174:
  pushl $0
  105b2a:	6a 00                	push   $0x0
  pushl $174
  105b2c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
  105b31:	e9 ba f4 ff ff       	jmp    104ff0 <alltraps>

00105b36 <vector175>:
.globl vector175
vector175:
  pushl $0
  105b36:	6a 00                	push   $0x0
  pushl $175
  105b38:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
  105b3d:	e9 ae f4 ff ff       	jmp    104ff0 <alltraps>

00105b42 <vector176>:
.globl vector176
vector176:
  pushl $0
  105b42:	6a 00                	push   $0x0
  pushl $176
  105b44:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
  105b49:	e9 a2 f4 ff ff       	jmp    104ff0 <alltraps>

00105b4e <vector177>:
.globl vector177
vector177:
  pushl $0
  105b4e:	6a 00                	push   $0x0
  pushl $177
  105b50:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
  105b55:	e9 96 f4 ff ff       	jmp    104ff0 <alltraps>

00105b5a <vector178>:
.globl vector178
vector178:
  pushl $0
  105b5a:	6a 00                	push   $0x0
  pushl $178
  105b5c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
  105b61:	e9 8a f4 ff ff       	jmp    104ff0 <alltraps>

00105b66 <vector179>:
.globl vector179
vector179:
  pushl $0
  105b66:	6a 00                	push   $0x0
  pushl $179
  105b68:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
  105b6d:	e9 7e f4 ff ff       	jmp    104ff0 <alltraps>

00105b72 <vector180>:
.globl vector180
vector180:
  pushl $0
  105b72:	6a 00                	push   $0x0
  pushl $180
  105b74:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
  105b79:	e9 72 f4 ff ff       	jmp    104ff0 <alltraps>

00105b7e <vector181>:
.globl vector181
vector181:
  pushl $0
  105b7e:	6a 00                	push   $0x0
  pushl $181
  105b80:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
  105b85:	e9 66 f4 ff ff       	jmp    104ff0 <alltraps>

00105b8a <vector182>:
.globl vector182
vector182:
  pushl $0
  105b8a:	6a 00                	push   $0x0
  pushl $182
  105b8c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
  105b91:	e9 5a f4 ff ff       	jmp    104ff0 <alltraps>

00105b96 <vector183>:
.globl vector183
vector183:
  pushl $0
  105b96:	6a 00                	push   $0x0
  pushl $183
  105b98:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
  105b9d:	e9 4e f4 ff ff       	jmp    104ff0 <alltraps>

00105ba2 <vector184>:
.globl vector184
vector184:
  pushl $0
  105ba2:	6a 00                	push   $0x0
  pushl $184
  105ba4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
  105ba9:	e9 42 f4 ff ff       	jmp    104ff0 <alltraps>

00105bae <vector185>:
.globl vector185
vector185:
  pushl $0
  105bae:	6a 00                	push   $0x0
  pushl $185
  105bb0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
  105bb5:	e9 36 f4 ff ff       	jmp    104ff0 <alltraps>

00105bba <vector186>:
.globl vector186
vector186:
  pushl $0
  105bba:	6a 00                	push   $0x0
  pushl $186
  105bbc:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
  105bc1:	e9 2a f4 ff ff       	jmp    104ff0 <alltraps>

00105bc6 <vector187>:
.globl vector187
vector187:
  pushl $0
  105bc6:	6a 00                	push   $0x0
  pushl $187
  105bc8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
  105bcd:	e9 1e f4 ff ff       	jmp    104ff0 <alltraps>

00105bd2 <vector188>:
.globl vector188
vector188:
  pushl $0
  105bd2:	6a 00                	push   $0x0
  pushl $188
  105bd4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
  105bd9:	e9 12 f4 ff ff       	jmp    104ff0 <alltraps>

00105bde <vector189>:
.globl vector189
vector189:
  pushl $0
  105bde:	6a 00                	push   $0x0
  pushl $189
  105be0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
  105be5:	e9 06 f4 ff ff       	jmp    104ff0 <alltraps>

00105bea <vector190>:
.globl vector190
vector190:
  pushl $0
  105bea:	6a 00                	push   $0x0
  pushl $190
  105bec:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
  105bf1:	e9 fa f3 ff ff       	jmp    104ff0 <alltraps>

00105bf6 <vector191>:
.globl vector191
vector191:
  pushl $0
  105bf6:	6a 00                	push   $0x0
  pushl $191
  105bf8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
  105bfd:	e9 ee f3 ff ff       	jmp    104ff0 <alltraps>

00105c02 <vector192>:
.globl vector192
vector192:
  pushl $0
  105c02:	6a 00                	push   $0x0
  pushl $192
  105c04:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
  105c09:	e9 e2 f3 ff ff       	jmp    104ff0 <alltraps>

00105c0e <vector193>:
.globl vector193
vector193:
  pushl $0
  105c0e:	6a 00                	push   $0x0
  pushl $193
  105c10:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
  105c15:	e9 d6 f3 ff ff       	jmp    104ff0 <alltraps>

00105c1a <vector194>:
.globl vector194
vector194:
  pushl $0
  105c1a:	6a 00                	push   $0x0
  pushl $194
  105c1c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
  105c21:	e9 ca f3 ff ff       	jmp    104ff0 <alltraps>

00105c26 <vector195>:
.globl vector195
vector195:
  pushl $0
  105c26:	6a 00                	push   $0x0
  pushl $195
  105c28:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
  105c2d:	e9 be f3 ff ff       	jmp    104ff0 <alltraps>

00105c32 <vector196>:
.globl vector196
vector196:
  pushl $0
  105c32:	6a 00                	push   $0x0
  pushl $196
  105c34:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
  105c39:	e9 b2 f3 ff ff       	jmp    104ff0 <alltraps>

00105c3e <vector197>:
.globl vector197
vector197:
  pushl $0
  105c3e:	6a 00                	push   $0x0
  pushl $197
  105c40:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
  105c45:	e9 a6 f3 ff ff       	jmp    104ff0 <alltraps>

00105c4a <vector198>:
.globl vector198
vector198:
  pushl $0
  105c4a:	6a 00                	push   $0x0
  pushl $198
  105c4c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
  105c51:	e9 9a f3 ff ff       	jmp    104ff0 <alltraps>

00105c56 <vector199>:
.globl vector199
vector199:
  pushl $0
  105c56:	6a 00                	push   $0x0
  pushl $199
  105c58:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
  105c5d:	e9 8e f3 ff ff       	jmp    104ff0 <alltraps>

00105c62 <vector200>:
.globl vector200
vector200:
  pushl $0
  105c62:	6a 00                	push   $0x0
  pushl $200
  105c64:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
  105c69:	e9 82 f3 ff ff       	jmp    104ff0 <alltraps>

00105c6e <vector201>:
.globl vector201
vector201:
  pushl $0
  105c6e:	6a 00                	push   $0x0
  pushl $201
  105c70:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
  105c75:	e9 76 f3 ff ff       	jmp    104ff0 <alltraps>

00105c7a <vector202>:
.globl vector202
vector202:
  pushl $0
  105c7a:	6a 00                	push   $0x0
  pushl $202
  105c7c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
  105c81:	e9 6a f3 ff ff       	jmp    104ff0 <alltraps>

00105c86 <vector203>:
.globl vector203
vector203:
  pushl $0
  105c86:	6a 00                	push   $0x0
  pushl $203
  105c88:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
  105c8d:	e9 5e f3 ff ff       	jmp    104ff0 <alltraps>

00105c92 <vector204>:
.globl vector204
vector204:
  pushl $0
  105c92:	6a 00                	push   $0x0
  pushl $204
  105c94:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
  105c99:	e9 52 f3 ff ff       	jmp    104ff0 <alltraps>

00105c9e <vector205>:
.globl vector205
vector205:
  pushl $0
  105c9e:	6a 00                	push   $0x0
  pushl $205
  105ca0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
  105ca5:	e9 46 f3 ff ff       	jmp    104ff0 <alltraps>

00105caa <vector206>:
.globl vector206
vector206:
  pushl $0
  105caa:	6a 00                	push   $0x0
  pushl $206
  105cac:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
  105cb1:	e9 3a f3 ff ff       	jmp    104ff0 <alltraps>

00105cb6 <vector207>:
.globl vector207
vector207:
  pushl $0
  105cb6:	6a 00                	push   $0x0
  pushl $207
  105cb8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
  105cbd:	e9 2e f3 ff ff       	jmp    104ff0 <alltraps>

00105cc2 <vector208>:
.globl vector208
vector208:
  pushl $0
  105cc2:	6a 00                	push   $0x0
  pushl $208
  105cc4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
  105cc9:	e9 22 f3 ff ff       	jmp    104ff0 <alltraps>

00105cce <vector209>:
.globl vector209
vector209:
  pushl $0
  105cce:	6a 00                	push   $0x0
  pushl $209
  105cd0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
  105cd5:	e9 16 f3 ff ff       	jmp    104ff0 <alltraps>

00105cda <vector210>:
.globl vector210
vector210:
  pushl $0
  105cda:	6a 00                	push   $0x0
  pushl $210
  105cdc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
  105ce1:	e9 0a f3 ff ff       	jmp    104ff0 <alltraps>

00105ce6 <vector211>:
.globl vector211
vector211:
  pushl $0
  105ce6:	6a 00                	push   $0x0
  pushl $211
  105ce8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
  105ced:	e9 fe f2 ff ff       	jmp    104ff0 <alltraps>

00105cf2 <vector212>:
.globl vector212
vector212:
  pushl $0
  105cf2:	6a 00                	push   $0x0
  pushl $212
  105cf4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
  105cf9:	e9 f2 f2 ff ff       	jmp    104ff0 <alltraps>

00105cfe <vector213>:
.globl vector213
vector213:
  pushl $0
  105cfe:	6a 00                	push   $0x0
  pushl $213
  105d00:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
  105d05:	e9 e6 f2 ff ff       	jmp    104ff0 <alltraps>

00105d0a <vector214>:
.globl vector214
vector214:
  pushl $0
  105d0a:	6a 00                	push   $0x0
  pushl $214
  105d0c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
  105d11:	e9 da f2 ff ff       	jmp    104ff0 <alltraps>

00105d16 <vector215>:
.globl vector215
vector215:
  pushl $0
  105d16:	6a 00                	push   $0x0
  pushl $215
  105d18:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
  105d1d:	e9 ce f2 ff ff       	jmp    104ff0 <alltraps>

00105d22 <vector216>:
.globl vector216
vector216:
  pushl $0
  105d22:	6a 00                	push   $0x0
  pushl $216
  105d24:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
  105d29:	e9 c2 f2 ff ff       	jmp    104ff0 <alltraps>

00105d2e <vector217>:
.globl vector217
vector217:
  pushl $0
  105d2e:	6a 00                	push   $0x0
  pushl $217
  105d30:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
  105d35:	e9 b6 f2 ff ff       	jmp    104ff0 <alltraps>

00105d3a <vector218>:
.globl vector218
vector218:
  pushl $0
  105d3a:	6a 00                	push   $0x0
  pushl $218
  105d3c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
  105d41:	e9 aa f2 ff ff       	jmp    104ff0 <alltraps>

00105d46 <vector219>:
.globl vector219
vector219:
  pushl $0
  105d46:	6a 00                	push   $0x0
  pushl $219
  105d48:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
  105d4d:	e9 9e f2 ff ff       	jmp    104ff0 <alltraps>

00105d52 <vector220>:
.globl vector220
vector220:
  pushl $0
  105d52:	6a 00                	push   $0x0
  pushl $220
  105d54:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
  105d59:	e9 92 f2 ff ff       	jmp    104ff0 <alltraps>

00105d5e <vector221>:
.globl vector221
vector221:
  pushl $0
  105d5e:	6a 00                	push   $0x0
  pushl $221
  105d60:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
  105d65:	e9 86 f2 ff ff       	jmp    104ff0 <alltraps>

00105d6a <vector222>:
.globl vector222
vector222:
  pushl $0
  105d6a:	6a 00                	push   $0x0
  pushl $222
  105d6c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
  105d71:	e9 7a f2 ff ff       	jmp    104ff0 <alltraps>

00105d76 <vector223>:
.globl vector223
vector223:
  pushl $0
  105d76:	6a 00                	push   $0x0
  pushl $223
  105d78:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
  105d7d:	e9 6e f2 ff ff       	jmp    104ff0 <alltraps>

00105d82 <vector224>:
.globl vector224
vector224:
  pushl $0
  105d82:	6a 00                	push   $0x0
  pushl $224
  105d84:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
  105d89:	e9 62 f2 ff ff       	jmp    104ff0 <alltraps>

00105d8e <vector225>:
.globl vector225
vector225:
  pushl $0
  105d8e:	6a 00                	push   $0x0
  pushl $225
  105d90:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
  105d95:	e9 56 f2 ff ff       	jmp    104ff0 <alltraps>

00105d9a <vector226>:
.globl vector226
vector226:
  pushl $0
  105d9a:	6a 00                	push   $0x0
  pushl $226
  105d9c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
  105da1:	e9 4a f2 ff ff       	jmp    104ff0 <alltraps>

00105da6 <vector227>:
.globl vector227
vector227:
  pushl $0
  105da6:	6a 00                	push   $0x0
  pushl $227
  105da8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
  105dad:	e9 3e f2 ff ff       	jmp    104ff0 <alltraps>

00105db2 <vector228>:
.globl vector228
vector228:
  pushl $0
  105db2:	6a 00                	push   $0x0
  pushl $228
  105db4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
  105db9:	e9 32 f2 ff ff       	jmp    104ff0 <alltraps>

00105dbe <vector229>:
.globl vector229
vector229:
  pushl $0
  105dbe:	6a 00                	push   $0x0
  pushl $229
  105dc0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
  105dc5:	e9 26 f2 ff ff       	jmp    104ff0 <alltraps>

00105dca <vector230>:
.globl vector230
vector230:
  pushl $0
  105dca:	6a 00                	push   $0x0
  pushl $230
  105dcc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
  105dd1:	e9 1a f2 ff ff       	jmp    104ff0 <alltraps>

00105dd6 <vector231>:
.globl vector231
vector231:
  pushl $0
  105dd6:	6a 00                	push   $0x0
  pushl $231
  105dd8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
  105ddd:	e9 0e f2 ff ff       	jmp    104ff0 <alltraps>

00105de2 <vector232>:
.globl vector232
vector232:
  pushl $0
  105de2:	6a 00                	push   $0x0
  pushl $232
  105de4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
  105de9:	e9 02 f2 ff ff       	jmp    104ff0 <alltraps>

00105dee <vector233>:
.globl vector233
vector233:
  pushl $0
  105dee:	6a 00                	push   $0x0
  pushl $233
  105df0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
  105df5:	e9 f6 f1 ff ff       	jmp    104ff0 <alltraps>

00105dfa <vector234>:
.globl vector234
vector234:
  pushl $0
  105dfa:	6a 00                	push   $0x0
  pushl $234
  105dfc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
  105e01:	e9 ea f1 ff ff       	jmp    104ff0 <alltraps>

00105e06 <vector235>:
.globl vector235
vector235:
  pushl $0
  105e06:	6a 00                	push   $0x0
  pushl $235
  105e08:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
  105e0d:	e9 de f1 ff ff       	jmp    104ff0 <alltraps>

00105e12 <vector236>:
.globl vector236
vector236:
  pushl $0
  105e12:	6a 00                	push   $0x0
  pushl $236
  105e14:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
  105e19:	e9 d2 f1 ff ff       	jmp    104ff0 <alltraps>

00105e1e <vector237>:
.globl vector237
vector237:
  pushl $0
  105e1e:	6a 00                	push   $0x0
  pushl $237
  105e20:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
  105e25:	e9 c6 f1 ff ff       	jmp    104ff0 <alltraps>

00105e2a <vector238>:
.globl vector238
vector238:
  pushl $0
  105e2a:	6a 00                	push   $0x0
  pushl $238
  105e2c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
  105e31:	e9 ba f1 ff ff       	jmp    104ff0 <alltraps>

00105e36 <vector239>:
.globl vector239
vector239:
  pushl $0
  105e36:	6a 00                	push   $0x0
  pushl $239
  105e38:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
  105e3d:	e9 ae f1 ff ff       	jmp    104ff0 <alltraps>

00105e42 <vector240>:
.globl vector240
vector240:
  pushl $0
  105e42:	6a 00                	push   $0x0
  pushl $240
  105e44:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
  105e49:	e9 a2 f1 ff ff       	jmp    104ff0 <alltraps>

00105e4e <vector241>:
.globl vector241
vector241:
  pushl $0
  105e4e:	6a 00                	push   $0x0
  pushl $241
  105e50:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
  105e55:	e9 96 f1 ff ff       	jmp    104ff0 <alltraps>

00105e5a <vector242>:
.globl vector242
vector242:
  pushl $0
  105e5a:	6a 00                	push   $0x0
  pushl $242
  105e5c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
  105e61:	e9 8a f1 ff ff       	jmp    104ff0 <alltraps>

00105e66 <vector243>:
.globl vector243
vector243:
  pushl $0
  105e66:	6a 00                	push   $0x0
  pushl $243
  105e68:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
  105e6d:	e9 7e f1 ff ff       	jmp    104ff0 <alltraps>

00105e72 <vector244>:
.globl vector244
vector244:
  pushl $0
  105e72:	6a 00                	push   $0x0
  pushl $244
  105e74:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
  105e79:	e9 72 f1 ff ff       	jmp    104ff0 <alltraps>

00105e7e <vector245>:
.globl vector245
vector245:
  pushl $0
  105e7e:	6a 00                	push   $0x0
  pushl $245
  105e80:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
  105e85:	e9 66 f1 ff ff       	jmp    104ff0 <alltraps>

00105e8a <vector246>:
.globl vector246
vector246:
  pushl $0
  105e8a:	6a 00                	push   $0x0
  pushl $246
  105e8c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
  105e91:	e9 5a f1 ff ff       	jmp    104ff0 <alltraps>

00105e96 <vector247>:
.globl vector247
vector247:
  pushl $0
  105e96:	6a 00                	push   $0x0
  pushl $247
  105e98:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
  105e9d:	e9 4e f1 ff ff       	jmp    104ff0 <alltraps>

00105ea2 <vector248>:
.globl vector248
vector248:
  pushl $0
  105ea2:	6a 00                	push   $0x0
  pushl $248
  105ea4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
  105ea9:	e9 42 f1 ff ff       	jmp    104ff0 <alltraps>

00105eae <vector249>:
.globl vector249
vector249:
  pushl $0
  105eae:	6a 00                	push   $0x0
  pushl $249
  105eb0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
  105eb5:	e9 36 f1 ff ff       	jmp    104ff0 <alltraps>

00105eba <vector250>:
.globl vector250
vector250:
  pushl $0
  105eba:	6a 00                	push   $0x0
  pushl $250
  105ebc:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
  105ec1:	e9 2a f1 ff ff       	jmp    104ff0 <alltraps>

00105ec6 <vector251>:
.globl vector251
vector251:
  pushl $0
  105ec6:	6a 00                	push   $0x0
  pushl $251
  105ec8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
  105ecd:	e9 1e f1 ff ff       	jmp    104ff0 <alltraps>

00105ed2 <vector252>:
.globl vector252
vector252:
  pushl $0
  105ed2:	6a 00                	push   $0x0
  pushl $252
  105ed4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
  105ed9:	e9 12 f1 ff ff       	jmp    104ff0 <alltraps>

00105ede <vector253>:
.globl vector253
vector253:
  pushl $0
  105ede:	6a 00                	push   $0x0
  pushl $253
  105ee0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
  105ee5:	e9 06 f1 ff ff       	jmp    104ff0 <alltraps>

00105eea <vector254>:
.globl vector254
vector254:
  pushl $0
  105eea:	6a 00                	push   $0x0
  pushl $254
  105eec:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
  105ef1:	e9 fa f0 ff ff       	jmp    104ff0 <alltraps>

00105ef6 <vector255>:
.globl vector255
vector255:
  pushl $0
  105ef6:	6a 00                	push   $0x0
  pushl $255
  105ef8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
  105efd:	e9 ee f0 ff ff       	jmp    104ff0 <alltraps>
  105f02:	90                   	nop
  105f03:	90                   	nop
  105f04:	90                   	nop
  105f05:	90                   	nop
  105f06:	90                   	nop
  105f07:	90                   	nop
  105f08:	90                   	nop
  105f09:	90                   	nop
  105f0a:	90                   	nop
  105f0b:	90                   	nop
  105f0c:	90                   	nop
  105f0d:	90                   	nop
  105f0e:	90                   	nop
  105f0f:	90                   	nop

00105f10 <vmenable>:
}

// Turn on paging.
void
vmenable(void)
{
  105f10:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105f11:	a1 d0 98 10 00       	mov    0x1098d0,%eax
  105f16:	89 e5                	mov    %esp,%ebp
  105f18:	0f 22 d8             	mov    %eax,%cr3

static inline uint
rcr0(void)
{
  uint val;
  asm volatile("movl %%cr0,%0" : "=r" (val));
  105f1b:	0f 20 c0             	mov    %cr0,%eax
}

static inline void
lcr0(uint val)
{
  asm volatile("movl %0,%%cr0" : : "r" (val));
  105f1e:	0d 00 00 00 80       	or     $0x80000000,%eax
  105f23:	0f 22 c0             	mov    %eax,%cr0

  switchkvm(); // load kpgdir into cr3
  cr0 = rcr0();
  cr0 |= CR0_PG;
  lcr0(cr0);
}
  105f26:	5d                   	pop    %ebp
  105f27:	c3                   	ret    
  105f28:	90                   	nop
  105f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00105f30 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  105f30:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105f31:	a1 d0 98 10 00       	mov    0x1098d0,%eax
  105f36:	89 e5                	mov    %esp,%ebp
  105f38:	0f 22 d8             	mov    %eax,%cr3
  lcr3(PADDR(kpgdir));   // switch to the kernel page table
}
  105f3b:	5d                   	pop    %ebp
  105f3c:	c3                   	ret    
  105f3d:	8d 76 00             	lea    0x0(%esi),%esi

00105f40 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105f40:	55                   	push   %ebp
  105f41:	89 e5                	mov    %esp,%ebp
  105f43:	83 ec 28             	sub    $0x28,%esp
  105f46:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  105f49:	89 d3                	mov    %edx,%ebx
  105f4b:	c1 eb 16             	shr    $0x16,%ebx
  105f4e:	8d 1c 98             	lea    (%eax,%ebx,4),%ebx
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105f51:	89 75 fc             	mov    %esi,-0x4(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
  105f54:	8b 33                	mov    (%ebx),%esi
  105f56:	f7 c6 01 00 00 00    	test   $0x1,%esi
  105f5c:	74 22                	je     105f80 <walkpgdir+0x40>
    pgtab = (pte_t*)PTE_ADDR(*pde);
  105f5e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105f64:	c1 ea 0a             	shr    $0xa,%edx
  105f67:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  105f6d:	8d 04 16             	lea    (%esi,%edx,1),%eax
}
  105f70:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  105f73:	8b 75 fc             	mov    -0x4(%ebp),%esi
  105f76:	89 ec                	mov    %ebp,%esp
  105f78:	5d                   	pop    %ebp
  105f79:	c3                   	ret    
  105f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105f80:	85 c9                	test   %ecx,%ecx
  105f82:	75 04                	jne    105f88 <walkpgdir+0x48>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105f84:	31 c0                	xor    %eax,%eax
  105f86:	eb e8                	jmp    105f70 <walkpgdir+0x30>

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105f88:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105f8b:	90                   	nop
  105f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105f90:	e8 0b c3 ff ff       	call   1022a0 <kalloc>
  105f95:	85 c0                	test   %eax,%eax
  105f97:	89 c6                	mov    %eax,%esi
  105f99:	74 e9                	je     105f84 <walkpgdir+0x44>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
  105f9b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105fa2:	00 
  105fa3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105faa:	00 
  105fab:	89 04 24             	mov    %eax,(%esp)
  105fae:	e8 0d df ff ff       	call   103ec0 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  105fb3:	89 f0                	mov    %esi,%eax
  105fb5:	83 c8 07             	or     $0x7,%eax
  105fb8:	89 03                	mov    %eax,(%ebx)
  105fba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105fbd:	eb a5                	jmp    105f64 <walkpgdir+0x24>
  105fbf:	90                   	nop

00105fc0 <uva2ka>:
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105fc0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105fc1:	31 c9                	xor    %ecx,%ecx
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105fc3:	89 e5                	mov    %esp,%ebp
  105fc5:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105fc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  105fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  105fce:	e8 6d ff ff ff       	call   105f40 <walkpgdir>
  if((*pte & PTE_P) == 0)
  105fd3:	8b 00                	mov    (%eax),%eax
  105fd5:	a8 01                	test   $0x1,%al
  105fd7:	75 07                	jne    105fe0 <uva2ka+0x20>
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)PTE_ADDR(*pte);
  105fd9:	31 c0                	xor    %eax,%eax
}
  105fdb:	c9                   	leave  
  105fdc:	c3                   	ret    
  105fdd:	8d 76 00             	lea    0x0(%esi),%esi
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
  105fe0:	a8 04                	test   $0x4,%al
  105fe2:	74 f5                	je     105fd9 <uva2ka+0x19>
    return 0;
  return (char*)PTE_ADDR(*pte);
  105fe4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
  105fe9:	c9                   	leave  
  105fea:	c3                   	ret    
  105feb:	90                   	nop
  105fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00105ff0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  105ff0:	55                   	push   %ebp
  105ff1:	89 e5                	mov    %esp,%ebp
  105ff3:	57                   	push   %edi
  105ff4:	56                   	push   %esi
  105ff5:	53                   	push   %ebx
  105ff6:	83 ec 2c             	sub    $0x2c,%esp
  105ff9:	8b 7d 14             	mov    0x14(%ebp),%edi
  105ffc:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  105fff:	85 ff                	test   %edi,%edi
  106001:	74 75                	je     106078 <copyout+0x88>
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  106003:	8b 45 10             	mov    0x10(%ebp),%eax
  106006:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106009:	eb 3a                	jmp    106045 <copyout+0x55>
  10600b:	90                   	nop
  10600c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
  106010:	89 f3                	mov    %esi,%ebx
  106012:	29 d3                	sub    %edx,%ebx
  106014:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  10601a:	39 fb                	cmp    %edi,%ebx
  10601c:	76 02                	jbe    106020 <copyout+0x30>
  10601e:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
  106020:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  106024:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  106027:	29 f2                	sub    %esi,%edx
  106029:	8d 14 10             	lea    (%eax,%edx,1),%edx
  10602c:	89 14 24             	mov    %edx,(%esp)
  10602f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  106033:	e8 08 df ff ff       	call   103f40 <memmove>
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  106038:	29 df                	sub    %ebx,%edi
  10603a:	74 3c                	je     106078 <copyout+0x88>
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
  10603c:	01 5d e4             	add    %ebx,-0x1c(%ebp)
    va = va0 + PGSIZE;
  10603f:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
  106045:	89 d6                	mov    %edx,%esi
  106047:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
  10604d:	89 74 24 04          	mov    %esi,0x4(%esp)
  106051:	8b 4d 08             	mov    0x8(%ebp),%ecx
  106054:	89 0c 24             	mov    %ecx,(%esp)
  106057:	89 55 e0             	mov    %edx,-0x20(%ebp)
  10605a:	e8 61 ff ff ff       	call   105fc0 <uva2ka>
    if(pa0 == 0)
  10605f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  106062:	85 c0                	test   %eax,%eax
  106064:	75 aa                	jne    106010 <copyout+0x20>
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
  106066:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  106069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
  10606e:	5b                   	pop    %ebx
  10606f:	5e                   	pop    %esi
  106070:	5f                   	pop    %edi
  106071:	5d                   	pop    %ebp
  106072:	c3                   	ret    
  106073:	90                   	nop
  106074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  106078:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  10607b:	31 c0                	xor    %eax,%eax
  }
  return 0;
}
  10607d:	5b                   	pop    %ebx
  10607e:	5e                   	pop    %esi
  10607f:	5f                   	pop    %edi
  106080:	5d                   	pop    %ebp
  106081:	c3                   	ret    
  106082:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  106089:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106090 <mappages>:
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  106090:	55                   	push   %ebp
  106091:	89 e5                	mov    %esp,%ebp
  106093:	57                   	push   %edi
  106094:	56                   	push   %esi
  106095:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  106096:	89 d3                	mov    %edx,%ebx
  last = PGROUNDDOWN(la + size - 1);
  106098:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  10609c:	83 ec 2c             	sub    $0x2c,%esp
  10609f:	8b 75 08             	mov    0x8(%ebp),%esi
  1060a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  1060a5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = PGROUNDDOWN(la + size - 1);
  1060ab:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  1060b1:	83 4d 0c 01          	orl    $0x1,0xc(%ebp)
  1060b5:	eb 1d                	jmp    1060d4 <mappages+0x44>
  1060b7:	90                   	nop
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
  1060b8:	f6 00 01             	testb  $0x1,(%eax)
  1060bb:	75 45                	jne    106102 <mappages+0x72>
      panic("remap");
    *pte = pa | perm | PTE_P;
  1060bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  1060c0:	09 f2                	or     %esi,%edx
    if(a == last)
  1060c2:	39 fb                	cmp    %edi,%ebx
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  1060c4:	89 10                	mov    %edx,(%eax)
    if(a == last)
  1060c6:	74 30                	je     1060f8 <mappages+0x68>
      break;
    a += PGSIZE;
  1060c8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
  1060ce:	81 c6 00 10 00 00    	add    $0x1000,%esi
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
  1060d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1060d7:	b9 01 00 00 00       	mov    $0x1,%ecx
  1060dc:	89 da                	mov    %ebx,%edx
  1060de:	e8 5d fe ff ff       	call   105f40 <walkpgdir>
    if(pte == 0)
  1060e3:	85 c0                	test   %eax,%eax
  1060e5:	75 d1                	jne    1060b8 <mappages+0x28>
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  1060e7:	83 c4 2c             	add    $0x2c,%esp
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  1060ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  1060ef:	5b                   	pop    %ebx
  1060f0:	5e                   	pop    %esi
  1060f1:	5f                   	pop    %edi
  1060f2:	5d                   	pop    %ebp
  1060f3:	c3                   	ret    
  1060f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1060f8:	83 c4 2c             	add    $0x2c,%esp
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
  1060fb:	31 c0                	xor    %eax,%eax
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  1060fd:	5b                   	pop    %ebx
  1060fe:	5e                   	pop    %esi
  1060ff:	5f                   	pop    %edi
  106100:	5d                   	pop    %ebp
  106101:	c3                   	ret    
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
  106102:	c7 04 24 50 70 10 00 	movl   $0x107050,(%esp)
  106109:	e8 62 a8 ff ff       	call   100970 <panic>
  10610e:	66 90                	xchg   %ax,%ax

00106110 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
  106110:	55                   	push   %ebp
  106111:	89 e5                	mov    %esp,%ebp
  106113:	56                   	push   %esi
  106114:	53                   	push   %ebx
  106115:	83 ec 10             	sub    $0x10,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
  106118:	e8 83 c1 ff ff       	call   1022a0 <kalloc>
  10611d:	85 c0                	test   %eax,%eax
  10611f:	89 c6                	mov    %eax,%esi
  106121:	74 50                	je     106173 <setupkvm+0x63>
    return 0;
  memset(pgdir, 0, PGSIZE);
  106123:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10612a:	00 
  10612b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  106132:	00 
  106133:	89 04 24             	mov    %eax,(%esp)
  106136:	e8 85 dd ff ff       	call   103ec0 <memset>
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  10613b:	b8 70 97 10 00       	mov    $0x109770,%eax
  106140:	3d 40 97 10 00       	cmp    $0x109740,%eax
  106145:	76 2c                	jbe    106173 <setupkvm+0x63>
  {(void*)0xFE000000, 0,               PTE_W},  // device mappings
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
  106147:	bb 40 97 10 00       	mov    $0x109740,%ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  10614c:	8b 13                	mov    (%ebx),%edx
  10614e:	8b 4b 04             	mov    0x4(%ebx),%ecx
  106151:	8b 43 08             	mov    0x8(%ebx),%eax
  106154:	89 14 24             	mov    %edx,(%esp)
  106157:	29 d1                	sub    %edx,%ecx
  106159:	89 44 24 04          	mov    %eax,0x4(%esp)
  10615d:	89 f0                	mov    %esi,%eax
  10615f:	e8 2c ff ff ff       	call   106090 <mappages>
  106164:	85 c0                	test   %eax,%eax
  106166:	78 18                	js     106180 <setupkvm+0x70>

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  106168:	83 c3 0c             	add    $0xc,%ebx
  10616b:	81 fb 70 97 10 00    	cmp    $0x109770,%ebx
  106171:	75 d9                	jne    10614c <setupkvm+0x3c>
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
      return 0;

  return pgdir;
}
  106173:	83 c4 10             	add    $0x10,%esp
  106176:	89 f0                	mov    %esi,%eax
  106178:	5b                   	pop    %ebx
  106179:	5e                   	pop    %esi
  10617a:	5d                   	pop    %ebp
  10617b:	c3                   	ret    
  10617c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  106180:	31 f6                	xor    %esi,%esi
      return 0;

  return pgdir;
}
  106182:	83 c4 10             	add    $0x10,%esp
  106185:	89 f0                	mov    %esi,%eax
  106187:	5b                   	pop    %ebx
  106188:	5e                   	pop    %esi
  106189:	5d                   	pop    %ebp
  10618a:	c3                   	ret    
  10618b:	90                   	nop
  10618c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00106190 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
  106190:	55                   	push   %ebp
  106191:	89 e5                	mov    %esp,%ebp
  106193:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
  106196:	e8 75 ff ff ff       	call   106110 <setupkvm>
  10619b:	a3 d0 98 10 00       	mov    %eax,0x1098d0
}
  1061a0:	c9                   	leave  
  1061a1:	c3                   	ret    
  1061a2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1061a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001061b0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  1061b0:	55                   	push   %ebp
  1061b1:	89 e5                	mov    %esp,%ebp
  1061b3:	83 ec 38             	sub    $0x38,%esp
  1061b6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1061b9:	8b 75 10             	mov    0x10(%ebp),%esi
  1061bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1061bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  1061c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  1061c5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  1061c8:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  1061ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  1061d1:	77 53                	ja     106226 <inituvm+0x76>
    panic("inituvm: more than a page");
  mem = kalloc();
  1061d3:	e8 c8 c0 ff ff       	call   1022a0 <kalloc>
  memset(mem, 0, PGSIZE);
  1061d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1061df:	00 
  1061e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1061e7:	00 
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  1061e8:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
  1061ea:	89 04 24             	mov    %eax,(%esp)
  1061ed:	e8 ce dc ff ff       	call   103ec0 <memset>
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  1061f2:	b9 00 10 00 00       	mov    $0x1000,%ecx
  1061f7:	31 d2                	xor    %edx,%edx
  1061f9:	89 1c 24             	mov    %ebx,(%esp)
  1061fc:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  106203:	00 
  106204:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106207:	e8 84 fe ff ff       	call   106090 <mappages>
  memmove(mem, init, sz);
  10620c:	89 75 10             	mov    %esi,0x10(%ebp)
}
  10620f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106212:	89 7d 0c             	mov    %edi,0xc(%ebp)
}
  106215:	8b 7d fc             	mov    -0x4(%ebp),%edi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106218:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  10621b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10621e:	89 ec                	mov    %ebp,%esp
  106220:	5d                   	pop    %ebp
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106221:	e9 1a dd ff ff       	jmp    103f40 <memmove>
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  106226:	c7 04 24 56 70 10 00 	movl   $0x107056,(%esp)
  10622d:	e8 3e a7 ff ff       	call   100970 <panic>
  106232:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  106239:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106240 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106240:	55                   	push   %ebp
  106241:	89 e5                	mov    %esp,%ebp
  106243:	57                   	push   %edi
  106244:	56                   	push   %esi
  106245:	53                   	push   %ebx
  106246:	83 ec 2c             	sub    $0x2c,%esp
  106249:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  10624c:	39 75 10             	cmp    %esi,0x10(%ebp)
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  10624f:	8b 7d 08             	mov    0x8(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;
  106252:	89 f0                	mov    %esi,%eax
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  106254:	73 59                	jae    1062af <deallocuvm+0x6f>
    return oldsz;

  a = PGROUNDUP(newsz);
  106256:	8b 5d 10             	mov    0x10(%ebp),%ebx
  106259:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  10625f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
  106265:	39 de                	cmp    %ebx,%esi
  106267:	76 43                	jbe    1062ac <deallocuvm+0x6c>
  106269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
  106270:	31 c9                	xor    %ecx,%ecx
  106272:	89 da                	mov    %ebx,%edx
  106274:	89 f8                	mov    %edi,%eax
  106276:	e8 c5 fc ff ff       	call   105f40 <walkpgdir>
    if(pte && (*pte & PTE_P) != 0){
  10627b:	85 c0                	test   %eax,%eax
  10627d:	74 23                	je     1062a2 <deallocuvm+0x62>
  10627f:	8b 10                	mov    (%eax),%edx
  106281:	f6 c2 01             	test   $0x1,%dl
  106284:	74 1c                	je     1062a2 <deallocuvm+0x62>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
  106286:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  10628c:	74 29                	je     1062b7 <deallocuvm+0x77>
        panic("kfree");
      kfree((char*)pa);
  10628e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106291:	89 14 24             	mov    %edx,(%esp)
  106294:	e8 47 c0 ff ff       	call   1022e0 <kfree>
      *pte = 0;
  106299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10629c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
  1062a2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  1062a8:	39 de                	cmp    %ebx,%esi
  1062aa:	77 c4                	ja     106270 <deallocuvm+0x30>
        panic("kfree");
      kfree((char*)pa);
      *pte = 0;
    }
  }
  return newsz;
  1062ac:	8b 45 10             	mov    0x10(%ebp),%eax
}
  1062af:	83 c4 2c             	add    $0x2c,%esp
  1062b2:	5b                   	pop    %ebx
  1062b3:	5e                   	pop    %esi
  1062b4:	5f                   	pop    %edi
  1062b5:	5d                   	pop    %ebp
  1062b6:	c3                   	ret    
  for(; a  < oldsz; a += PGSIZE){
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(pte && (*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
  1062b7:	c7 04 24 3e 69 10 00 	movl   $0x10693e,(%esp)
  1062be:	e8 ad a6 ff ff       	call   100970 <panic>
  1062c3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1062c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001062d0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
  1062d0:	55                   	push   %ebp
  1062d1:	89 e5                	mov    %esp,%ebp
  1062d3:	56                   	push   %esi
  1062d4:	53                   	push   %ebx
  1062d5:	83 ec 10             	sub    $0x10,%esp
  1062d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint i;

  if(pgdir == 0)
  1062db:	85 db                	test   %ebx,%ebx
  1062dd:	74 59                	je     106338 <freevm+0x68>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  1062df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1062e6:	00 
  1062e7:	31 f6                	xor    %esi,%esi
  1062e9:	c7 44 24 04 00 00 0a 	movl   $0xa0000,0x4(%esp)
  1062f0:	00 
  1062f1:	89 1c 24             	mov    %ebx,(%esp)
  1062f4:	e8 47 ff ff ff       	call   106240 <deallocuvm>
  1062f9:	eb 10                	jmp    10630b <freevm+0x3b>
  1062fb:	90                   	nop
  1062fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(i = 0; i < NPDENTRIES; i++){
  106300:	83 c6 01             	add    $0x1,%esi
  106303:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106309:	74 1f                	je     10632a <freevm+0x5a>
    if(pgdir[i] & PTE_P)
  10630b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  10630e:	a8 01                	test   $0x1,%al
  106310:	74 ee                	je     106300 <freevm+0x30>
      kfree((char*)PTE_ADDR(pgdir[i]));
  106312:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106317:	83 c6 01             	add    $0x1,%esi
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  10631a:	89 04 24             	mov    %eax,(%esp)
  10631d:	e8 be bf ff ff       	call   1022e0 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106322:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106328:	75 e1                	jne    10630b <freevm+0x3b>
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  10632a:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  10632d:	83 c4 10             	add    $0x10,%esp
  106330:	5b                   	pop    %ebx
  106331:	5e                   	pop    %esi
  106332:	5d                   	pop    %ebp
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  106333:	e9 a8 bf ff ff       	jmp    1022e0 <kfree>
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  106338:	c7 04 24 70 70 10 00 	movl   $0x107070,(%esp)
  10633f:	e8 2c a6 ff ff       	call   100970 <panic>
  106344:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10634a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00106350 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
  106350:	55                   	push   %ebp
  106351:	89 e5                	mov    %esp,%ebp
  106353:	57                   	push   %edi
  106354:	56                   	push   %esi
  106355:	53                   	push   %ebx
  106356:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
  106359:	e8 b2 fd ff ff       	call   106110 <setupkvm>
  10635e:	85 c0                	test   %eax,%eax
  106360:	89 c6                	mov    %eax,%esi
  106362:	0f 84 84 00 00 00    	je     1063ec <copyuvm+0x9c>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  106368:	8b 45 0c             	mov    0xc(%ebp),%eax
  10636b:	85 c0                	test   %eax,%eax
  10636d:	74 7d                	je     1063ec <copyuvm+0x9c>
  10636f:	31 db                	xor    %ebx,%ebx
  106371:	eb 47                	jmp    1063ba <copyuvm+0x6a>
  106373:	90                   	nop
  106374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)pa, PGSIZE);
  106378:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  10637e:	89 54 24 04          	mov    %edx,0x4(%esp)
  106382:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  106389:	00 
  10638a:	89 04 24             	mov    %eax,(%esp)
  10638d:	e8 ae db ff ff       	call   103f40 <memmove>
    if(mappages(d, (void*)i, PGSIZE, PADDR(mem), PTE_W|PTE_U) < 0)
  106392:	b9 00 10 00 00       	mov    $0x1000,%ecx
  106397:	89 da                	mov    %ebx,%edx
  106399:	89 f0                	mov    %esi,%eax
  10639b:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  1063a2:	00 
  1063a3:	89 3c 24             	mov    %edi,(%esp)
  1063a6:	e8 e5 fc ff ff       	call   106090 <mappages>
  1063ab:	85 c0                	test   %eax,%eax
  1063ad:	78 33                	js     1063e2 <copyuvm+0x92>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  1063af:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  1063b5:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
  1063b8:	76 32                	jbe    1063ec <copyuvm+0x9c>
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
  1063ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1063bd:	31 c9                	xor    %ecx,%ecx
  1063bf:	89 da                	mov    %ebx,%edx
  1063c1:	e8 7a fb ff ff       	call   105f40 <walkpgdir>
  1063c6:	85 c0                	test   %eax,%eax
  1063c8:	74 2c                	je     1063f6 <copyuvm+0xa6>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
  1063ca:	8b 10                	mov    (%eax),%edx
  1063cc:	f6 c2 01             	test   $0x1,%dl
  1063cf:	74 31                	je     106402 <copyuvm+0xb2>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
  1063d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1063d4:	e8 c7 be ff ff       	call   1022a0 <kalloc>
  1063d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1063dc:	85 c0                	test   %eax,%eax
  1063de:	89 c7                	mov    %eax,%edi
  1063e0:	75 96                	jne    106378 <copyuvm+0x28>
      goto bad;
  }
  return d;

bad:
  freevm(d);
  1063e2:	89 34 24             	mov    %esi,(%esp)
  1063e5:	31 f6                	xor    %esi,%esi
  1063e7:	e8 e4 fe ff ff       	call   1062d0 <freevm>
  return 0;
}
  1063ec:	83 c4 2c             	add    $0x2c,%esp
  1063ef:	89 f0                	mov    %esi,%eax
  1063f1:	5b                   	pop    %ebx
  1063f2:	5e                   	pop    %esi
  1063f3:	5f                   	pop    %edi
  1063f4:	5d                   	pop    %ebp
  1063f5:	c3                   	ret    

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
      panic("copyuvm: pte should exist");
  1063f6:	c7 04 24 81 70 10 00 	movl   $0x107081,(%esp)
  1063fd:	e8 6e a5 ff ff       	call   100970 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
  106402:	c7 04 24 9b 70 10 00 	movl   $0x10709b,(%esp)
  106409:	e8 62 a5 ff ff       	call   100970 <panic>
  10640e:	66 90                	xchg   %ax,%ax

00106410 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106410:	55                   	push   %ebp
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106411:	31 c0                	xor    %eax,%eax

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106413:	89 e5                	mov    %esp,%ebp
  106415:	57                   	push   %edi
  106416:	56                   	push   %esi
  106417:	53                   	push   %ebx
  106418:	83 ec 2c             	sub    $0x2c,%esp
  10641b:	8b 75 10             	mov    0x10(%ebp),%esi
  10641e:	8b 7d 08             	mov    0x8(%ebp),%edi
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106421:	81 fe 00 00 0a 00    	cmp    $0xa0000,%esi
  106427:	0f 87 8e 00 00 00    	ja     1064bb <allocuvm+0xab>
    return 0;
  if(newsz < oldsz)
    return oldsz;
  10642d:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *mem;
  uint a;

  if(newsz > USERTOP)
    return 0;
  if(newsz < oldsz)
  106430:	39 c6                	cmp    %eax,%esi
  106432:	0f 82 83 00 00 00    	jb     1064bb <allocuvm+0xab>
    return oldsz;

  a = PGROUNDUP(oldsz);
  106438:	89 c3                	mov    %eax,%ebx
  10643a:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  106440:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
  106446:	39 de                	cmp    %ebx,%esi
  106448:	77 47                	ja     106491 <allocuvm+0x81>
  10644a:	eb 7c                	jmp    1064c8 <allocuvm+0xb8>
  10644c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
  106450:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  106457:	00 
  106458:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10645f:	00 
  106460:	89 04 24             	mov    %eax,(%esp)
  106463:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106466:	e8 55 da ff ff       	call   103ec0 <memset>
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  10646b:	b9 00 10 00 00       	mov    $0x1000,%ecx
  106470:	89 f8                	mov    %edi,%eax
  106472:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  106479:	00 
  10647a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10647d:	89 14 24             	mov    %edx,(%esp)
  106480:	89 da                	mov    %ebx,%edx
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  106482:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  106488:	e8 03 fc ff ff       	call   106090 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  10648d:	39 de                	cmp    %ebx,%esi
  10648f:	76 37                	jbe    1064c8 <allocuvm+0xb8>
    mem = kalloc();
  106491:	e8 0a be ff ff       	call   1022a0 <kalloc>
    if(mem == 0){
  106496:	85 c0                	test   %eax,%eax
  106498:	75 b6                	jne    106450 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
  10649a:	c7 04 24 b5 70 10 00 	movl   $0x1070b5,(%esp)
  1064a1:	e8 da a0 ff ff       	call   100580 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
  1064a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1064a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  1064ad:	89 3c 24             	mov    %edi,(%esp)
  1064b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1064b4:	e8 87 fd ff ff       	call   106240 <deallocuvm>
  1064b9:	31 c0                	xor    %eax,%eax
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
}
  1064bb:	83 c4 2c             	add    $0x2c,%esp
  1064be:	5b                   	pop    %ebx
  1064bf:	5e                   	pop    %esi
  1064c0:	5f                   	pop    %edi
  1064c1:	5d                   	pop    %ebp
  1064c2:	c3                   	ret    
  1064c3:	90                   	nop
  1064c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1064c8:	83 c4 2c             	add    $0x2c,%esp
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
  1064cb:	89 f0                	mov    %esi,%eax
}
  1064cd:	5b                   	pop    %ebx
  1064ce:	5e                   	pop    %esi
  1064cf:	5f                   	pop    %edi
  1064d0:	5d                   	pop    %ebp
  1064d1:	c3                   	ret    
  1064d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1064d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001064e0 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
  1064e0:	55                   	push   %ebp
  1064e1:	89 e5                	mov    %esp,%ebp
  1064e3:	57                   	push   %edi
  1064e4:	56                   	push   %esi
  1064e5:	53                   	push   %ebx
  1064e6:	83 ec 3c             	sub    $0x3c,%esp
  1064e9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
  1064ec:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
  1064f2:	0f 85 96 00 00 00    	jne    10658e <loaduvm+0xae>
    panic("loaduvm: addr must be page aligned");
  1064f8:	8b 75 18             	mov    0x18(%ebp),%esi
  1064fb:	31 db                	xor    %ebx,%ebx
  for(i = 0; i < sz; i += PGSIZE){
  1064fd:	85 f6                	test   %esi,%esi
  1064ff:	74 77                	je     106578 <loaduvm+0x98>
  106501:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  106504:	eb 13                	jmp    106519 <loaduvm+0x39>
  106506:	66 90                	xchg   %ax,%ax
  106508:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  10650e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  106514:	39 5d 18             	cmp    %ebx,0x18(%ebp)
  106517:	76 5f                	jbe    106578 <loaduvm+0x98>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
  106519:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10651c:	31 c9                	xor    %ecx,%ecx
  10651e:	8b 45 08             	mov    0x8(%ebp),%eax
  106521:	01 da                	add    %ebx,%edx
  106523:	e8 18 fa ff ff       	call   105f40 <walkpgdir>
  106528:	85 c0                	test   %eax,%eax
  10652a:	74 56                	je     106582 <loaduvm+0xa2>
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
  10652c:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
  106532:	8b 00                	mov    (%eax),%eax
    if(sz - i < PGSIZE)
  106534:	ba 00 10 00 00       	mov    $0x1000,%edx
  106539:	77 02                	ja     10653d <loaduvm+0x5d>
  10653b:	89 f2                	mov    %esi,%edx
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  10653d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106541:	8b 7d 14             	mov    0x14(%ebp),%edi
  106544:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  106549:	89 44 24 04          	mov    %eax,0x4(%esp)
  10654d:	8d 0c 3b             	lea    (%ebx,%edi,1),%ecx
  106550:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  106554:	8b 45 10             	mov    0x10(%ebp),%eax
  106557:	89 04 24             	mov    %eax,(%esp)
  10655a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10655d:	e8 5e ae ff ff       	call   1013c0 <readi>
  106562:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106565:	39 d0                	cmp    %edx,%eax
  106567:	74 9f                	je     106508 <loaduvm+0x28>
      return -1;
  }
  return 0;
}
  106569:	83 c4 3c             	add    $0x3c,%esp
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  10656c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return -1;
  }
  return 0;
}
  106571:	5b                   	pop    %ebx
  106572:	5e                   	pop    %esi
  106573:	5f                   	pop    %edi
  106574:	5d                   	pop    %ebp
  106575:	c3                   	ret    
  106576:	66 90                	xchg   %ax,%ax
  106578:	83 c4 3c             	add    $0x3c,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
  10657b:	31 c0                	xor    %eax,%eax
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
      return -1;
  }
  return 0;
}
  10657d:	5b                   	pop    %ebx
  10657e:	5e                   	pop    %esi
  10657f:	5f                   	pop    %edi
  106580:	5d                   	pop    %ebp
  106581:	c3                   	ret    

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
  106582:	c7 04 24 cd 70 10 00 	movl   $0x1070cd,(%esp)
  106589:	e8 e2 a3 ff ff       	call   100970 <panic>
{
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  10658e:	c7 04 24 00 71 10 00 	movl   $0x107100,(%esp)
  106595:	e8 d6 a3 ff ff       	call   100970 <panic>
  10659a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001065a0 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  1065a0:	55                   	push   %ebp
  1065a1:	89 e5                	mov    %esp,%ebp
  1065a3:	53                   	push   %ebx
  1065a4:	83 ec 14             	sub    $0x14,%esp
  1065a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
  1065aa:	e8 81 d7 ff ff       	call   103d30 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
  1065af:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1065b5:	8d 50 08             	lea    0x8(%eax),%edx
  1065b8:	89 d1                	mov    %edx,%ecx
  1065ba:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
  1065c1:	c1 e9 10             	shr    $0x10,%ecx
  1065c4:	c1 ea 18             	shr    $0x18,%edx
  1065c7:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  1065cd:	c6 80 a5 00 00 00 99 	movb   $0x99,0xa5(%eax)
  1065d4:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  1065da:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
  1065e1:	67 00 
  1065e3:	c6 80 a6 00 00 00 40 	movb   $0x40,0xa6(%eax)
  cpu->gdt[SEG_TSS].s = 0;
  1065ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1065f0:	80 a0 a5 00 00 00 ef 	andb   $0xef,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
  1065f7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1065fd:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  106603:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  106609:	8b 50 08             	mov    0x8(%eax),%edx
  10660c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  106612:	81 c2 00 10 00 00    	add    $0x1000,%edx
  106618:	89 50 0c             	mov    %edx,0xc(%eax)
}

static inline void
ltr(ushort sel)
{
  asm volatile("ltr %0" : : "r" (sel));
  10661b:	b8 30 00 00 00       	mov    $0x30,%eax
  106620:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
  106623:	8b 43 04             	mov    0x4(%ebx),%eax
  106626:	85 c0                	test   %eax,%eax
  106628:	74 0d                	je     106637 <switchuvm+0x97>
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  10662a:	0f 22 d8             	mov    %eax,%cr3
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
}
  10662d:	83 c4 14             	add    $0x14,%esp
  106630:	5b                   	pop    %ebx
  106631:	5d                   	pop    %ebp
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
  106632:	e9 39 d7 ff ff       	jmp    103d70 <popcli>
  cpu->gdt[SEG_TSS].s = 0;
  cpu->ts.ss0 = SEG_KDATA << 3;
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  106637:	c7 04 24 eb 70 10 00 	movl   $0x1070eb,(%esp)
  10663e:	e8 2d a3 ff ff       	call   100970 <panic>
  106643:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  106649:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106650 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once at boot time on each CPU.
void
seginit(void)
{
  106650:	55                   	push   %ebp
  106651:	89 e5                	mov    %esp,%ebp
  106653:	83 ec 18             	sub    $0x18,%esp

  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  106656:	e8 25 bf ff ff       	call   102580 <cpunum>
  10665b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  106661:	05 20 db 10 00       	add    $0x10db20,%eax
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  106666:	8d 90 b4 00 00 00    	lea    0xb4(%eax),%edx
  10666c:	66 89 90 8a 00 00 00 	mov    %dx,0x8a(%eax)
  106673:	89 d1                	mov    %edx,%ecx
  106675:	c1 ea 18             	shr    $0x18,%edx
  106678:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)
  10667e:	c1 e9 10             	shr    $0x10,%ecx

  lgdt(c->gdt, sizeof(c->gdt));
  106681:	8d 50 70             	lea    0x70(%eax),%edx
  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  106684:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
  10668a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
  106690:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
  106694:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
  106698:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
  10669c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  1066a0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
  1066a7:	ff ff 
  1066a9:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
  1066b0:	00 00 
  1066b2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
  1066b9:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
  1066c0:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
  1066c7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  1066ce:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
  1066d5:	ff ff 
  1066d7:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
  1066de:	00 00 
  1066e0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
  1066e7:	c6 80 95 00 00 00 fa 	movb   $0xfa,0x95(%eax)
  1066ee:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
  1066f5:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
  1066fc:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
  106703:	ff ff 
  106705:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
  10670c:	00 00 
  10670e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
  106715:	c6 80 9d 00 00 00 f2 	movb   $0xf2,0x9d(%eax)
  10671c:	c6 80 9e 00 00 00 cf 	movb   $0xcf,0x9e(%eax)
  106723:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  10672a:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
  106731:	00 00 
  106733:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
  106739:	c6 80 8d 00 00 00 92 	movb   $0x92,0x8d(%eax)
  106740:	c6 80 8e 00 00 00 c0 	movb   $0xc0,0x8e(%eax)
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  106747:	66 c7 45 f2 37 00    	movw   $0x37,-0xe(%ebp)
  pd[1] = (uint)p;
  10674d:	66 89 55 f4          	mov    %dx,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
  106751:	c1 ea 10             	shr    $0x10,%edx
  106754:	66 89 55 f6          	mov    %dx,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
  106758:	8d 55 f2             	lea    -0xe(%ebp),%edx
  10675b:	0f 01 12             	lgdtl  (%edx)
}

static inline void
loadgs(ushort v)
{
  asm volatile("movw %0, %%gs" : : "r" (v));
  10675e:	ba 18 00 00 00       	mov    $0x18,%edx
  106763:	8e ea                	mov    %edx,%gs

  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);
  
  // Initialize cpu-local storage.
  cpu = c;
  106765:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
  10676b:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  106772:	00 00 00 00 
}
  106776:	c9                   	leave  
  106777:	c3                   	ret    
