
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
  100045:	e8 f6 28 00 00       	call   102940 <main>

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
#include "proc.h"
#include "thread.h"

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

00100080 <lock_holding>:
}

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
  100080:	55                   	push   %ebp
  100081:	89 e5                	mov    %esp,%ebp
  100083:	8b 45 08             	mov    0x8(%ebp),%eax
  return lock->locked;
}
  100086:	5d                   	pop    %ebp
}

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
  100087:	8b 00                	mov    (%eax),%eax
  return lock->locked;
}
  100089:	c3                   	ret    
  10008a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00100090 <thread_create>:

int
thread_create(void *(*start_routine)(void*), void *arg) {
  100090:	55                   	push   %ebp
  return 0;
}
  100091:	31 c0                	xor    %eax,%eax
{
  return lock->locked;
}

int
thread_create(void *(*start_routine)(void*), void *arg) {
  100093:	89 e5                	mov    %esp,%ebp
  return 0;
}
  100095:	5d                   	pop    %ebp
  100096:	c3                   	ret    
  100097:	89 f6                	mov    %esi,%esi
  100099:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001000a0 <lock_release>:
}

// Release the lock.
void
lock_release(struct lock_t *lock)
{
  1000a0:	55                   	push   %ebp
  1000a1:	89 e5                	mov    %esp,%ebp
  1000a3:	83 ec 18             	sub    $0x18,%esp
  1000a6:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
  return lock->locked;
  1000a9:	8b 02                	mov    (%edx),%eax
  1000ab:	85 c0                	test   %eax,%eax
  1000ad:	74 07                	je     1000b6 <lock_release+0x16>
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  1000af:	31 c0                	xor    %eax,%eax
  1000b1:	f0 87 02             	lock xchg %eax,(%edx)
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lock->locked, 0);

}
  1000b4:	c9                   	leave  
  1000b5:	c3                   	ret    
// Release the lock.
void
lock_release(struct lock_t *lock)
{
  if(!lock_holding(lock))
    panic("release");
  1000b6:	c7 04 24 c0 66 10 00 	movl   $0x1066c0,(%esp)
  1000bd:	e8 ee 08 00 00       	call   1009b0 <panic>
  1000c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1000c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001000d0 <lock_acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
lock_acquire(struct lock_t *lock)
{
  1000d0:	55                   	push   %ebp
  1000d1:	89 e5                	mov    %esp,%ebp
  1000d3:	83 ec 18             	sub    $0x18,%esp
  1000d6:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
lock_holding(struct lock_t *lock)
{
  return lock->locked;
  1000d9:	8b 0a                	mov    (%edx),%ecx
  1000db:	85 c9                	test   %ecx,%ecx
  1000dd:	75 14                	jne    1000f3 <lock_acquire+0x23>
  1000df:	b9 01 00 00 00       	mov    $0x1,%ecx
  1000e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1000e8:	89 c8                	mov    %ecx,%eax
  1000ea:	f0 87 02             	lock xchg %eax,(%edx)
    panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lock->locked, 1) != 0)
  1000ed:	85 c0                	test   %eax,%eax
  1000ef:	75 f7                	jne    1000e8 <lock_acquire+0x18>
    ;

}
  1000f1:	c9                   	leave  
  1000f2:	c3                   	ret    
// other CPUs to waste time spinning to acquire it.
void
lock_acquire(struct lock_t *lock)
{
  if(lock_holding(lock))
    panic("acquire");
  1000f3:	c7 04 24 c8 66 10 00 	movl   $0x1066c8,(%esp)
  1000fa:	e8 b1 08 00 00       	call   1009b0 <panic>
  1000ff:	90                   	nop

00100100 <brelse>:
}

// Release the buffer b.
void
brelse(struct buf *b)
{
  100100:	55                   	push   %ebp
  100101:	89 e5                	mov    %esp,%ebp
  100103:	53                   	push   %ebx
  100104:	83 ec 14             	sub    $0x14,%esp
  100107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((b->flags & B_BUSY) == 0)
  10010a:	f6 03 01             	testb  $0x1,(%ebx)
  10010d:	74 57                	je     100166 <brelse+0x66>
    panic("brelse");

  acquire(&bcache.lock);
  10010f:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  100116:	e8 45 3c 00 00       	call   103d60 <acquire>

  b->next->prev = b->prev;
  10011b:	8b 43 10             	mov    0x10(%ebx),%eax
  10011e:	8b 53 0c             	mov    0xc(%ebx),%edx
  100121:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
  100124:	8b 43 0c             	mov    0xc(%ebx),%eax
  100127:	8b 53 10             	mov    0x10(%ebx),%edx
  10012a:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
  10012d:	a1 14 9e 10 00       	mov    0x109e14,%eax
  b->prev = &bcache.head;
  100132:	c7 43 0c 04 9e 10 00 	movl   $0x109e04,0xc(%ebx)

  acquire(&bcache.lock);

  b->next->prev = b->prev;
  b->prev->next = b->next;
  b->next = bcache.head.next;
  100139:	89 43 10             	mov    %eax,0x10(%ebx)
  b->prev = &bcache.head;
  bcache.head.next->prev = b;
  10013c:	a1 14 9e 10 00       	mov    0x109e14,%eax
  100141:	89 58 0c             	mov    %ebx,0xc(%eax)
  bcache.head.next = b;
  100144:	89 1d 14 9e 10 00    	mov    %ebx,0x109e14

  b->flags &= ~B_BUSY;
  10014a:	83 23 fe             	andl   $0xfffffffe,(%ebx)
  wakeup(b);
  10014d:	89 1c 24             	mov    %ebx,(%esp)
  100150:	e8 6b 30 00 00       	call   1031c0 <wakeup>

  release(&bcache.lock);
  100155:	c7 45 08 e0 88 10 00 	movl   $0x1088e0,0x8(%ebp)
}
  10015c:	83 c4 14             	add    $0x14,%esp
  10015f:	5b                   	pop    %ebx
  100160:	5d                   	pop    %ebp
  bcache.head.next = b;

  b->flags &= ~B_BUSY;
  wakeup(b);

  release(&bcache.lock);
  100161:	e9 aa 3b 00 00       	jmp    103d10 <release>
// Release the buffer b.
void
brelse(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("brelse");
  100166:	c7 04 24 d0 66 10 00 	movl   $0x1066d0,(%esp)
  10016d:	e8 3e 08 00 00       	call   1009b0 <panic>
  100172:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  100179:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100180 <bwrite>:
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  100180:	55                   	push   %ebp
  100181:	89 e5                	mov    %esp,%ebp
  100183:	83 ec 18             	sub    $0x18,%esp
  100186:	8b 45 08             	mov    0x8(%ebp),%eax
  if((b->flags & B_BUSY) == 0)
  100189:	8b 10                	mov    (%eax),%edx
  10018b:	f6 c2 01             	test   $0x1,%dl
  10018e:	74 0e                	je     10019e <bwrite+0x1e>
    panic("bwrite");
  b->flags |= B_DIRTY;
  100190:	83 ca 04             	or     $0x4,%edx
  100193:	89 10                	mov    %edx,(%eax)
  iderw(b);
  100195:	89 45 08             	mov    %eax,0x8(%ebp)
}
  100198:	c9                   	leave  
bwrite(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("bwrite");
  b->flags |= B_DIRTY;
  iderw(b);
  100199:	e9 32 1e 00 00       	jmp    101fd0 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if((b->flags & B_BUSY) == 0)
    panic("bwrite");
  10019e:	c7 04 24 d7 66 10 00 	movl   $0x1066d7,(%esp)
  1001a5:	e8 06 08 00 00       	call   1009b0 <panic>
  1001aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001001b0 <bread>:
}

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
  1001b0:	55                   	push   %ebp
  1001b1:	89 e5                	mov    %esp,%ebp
  1001b3:	57                   	push   %edi
  1001b4:	56                   	push   %esi
  1001b5:	53                   	push   %ebx
  1001b6:	83 ec 1c             	sub    $0x1c,%esp
  1001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  1001bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
static struct buf*
bget(uint dev, uint sector)
{
  struct buf *b;

  acquire(&bcache.lock);
  1001bf:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  1001c6:	e8 95 3b 00 00       	call   103d60 <acquire>

 loop:
  // Try for cached block.
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
  1001cb:	8b 1d 14 9e 10 00    	mov    0x109e14,%ebx
  1001d1:	81 fb 04 9e 10 00    	cmp    $0x109e04,%ebx
  1001d7:	75 12                	jne    1001eb <bread+0x3b>
  1001d9:	eb 35                	jmp    100210 <bread+0x60>
  1001db:	90                   	nop
  1001dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1001e0:	8b 5b 10             	mov    0x10(%ebx),%ebx
  1001e3:	81 fb 04 9e 10 00    	cmp    $0x109e04,%ebx
  1001e9:	74 25                	je     100210 <bread+0x60>
    if(b->dev == dev && b->sector == sector){
  1001eb:	3b 73 04             	cmp    0x4(%ebx),%esi
  1001ee:	66 90                	xchg   %ax,%ax
  1001f0:	75 ee                	jne    1001e0 <bread+0x30>
  1001f2:	3b 7b 08             	cmp    0x8(%ebx),%edi
  1001f5:	75 e9                	jne    1001e0 <bread+0x30>
      if(!(b->flags & B_BUSY)){
  1001f7:	8b 03                	mov    (%ebx),%eax
  1001f9:	a8 01                	test   $0x1,%al
  1001fb:	74 64                	je     100261 <bread+0xb1>
        b->flags |= B_BUSY;
        release(&bcache.lock);
        return b;
      }
      sleep(b, &bcache.lock);
  1001fd:	c7 44 24 04 e0 88 10 	movl   $0x1088e0,0x4(%esp)
  100204:	00 
  100205:	89 1c 24             	mov    %ebx,(%esp)
  100208:	e8 d3 30 00 00       	call   1032e0 <sleep>
  10020d:	eb bc                	jmp    1001cb <bread+0x1b>
  10020f:	90                   	nop
      goto loop;
    }
  }

  // Allocate fresh block.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
  100210:	8b 1d 10 9e 10 00    	mov    0x109e10,%ebx
  100216:	81 fb 04 9e 10 00    	cmp    $0x109e04,%ebx
  10021c:	75 0d                	jne    10022b <bread+0x7b>
  10021e:	eb 54                	jmp    100274 <bread+0xc4>
  100220:	8b 5b 0c             	mov    0xc(%ebx),%ebx
  100223:	81 fb 04 9e 10 00    	cmp    $0x109e04,%ebx
  100229:	74 49                	je     100274 <bread+0xc4>
    if((b->flags & B_BUSY) == 0){
  10022b:	f6 03 01             	testb  $0x1,(%ebx)
  10022e:	66 90                	xchg   %ax,%ax
  100230:	75 ee                	jne    100220 <bread+0x70>
      b->dev = dev;
  100232:	89 73 04             	mov    %esi,0x4(%ebx)
      b->sector = sector;
  100235:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = B_BUSY;
  100238:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
      release(&bcache.lock);
  10023e:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  100245:	e8 c6 3a 00 00       	call   103d10 <release>
bread(uint dev, uint sector)
{
  struct buf *b;

  b = bget(dev, sector);
  if(!(b->flags & B_VALID))
  10024a:	f6 03 02             	testb  $0x2,(%ebx)
  10024d:	75 08                	jne    100257 <bread+0xa7>
    iderw(b);
  10024f:	89 1c 24             	mov    %ebx,(%esp)
  100252:	e8 79 1d 00 00       	call   101fd0 <iderw>
  return b;
}
  100257:	83 c4 1c             	add    $0x1c,%esp
  10025a:	89 d8                	mov    %ebx,%eax
  10025c:	5b                   	pop    %ebx
  10025d:	5e                   	pop    %esi
  10025e:	5f                   	pop    %edi
  10025f:	5d                   	pop    %ebp
  100260:	c3                   	ret    
 loop:
  // Try for cached block.
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    if(b->dev == dev && b->sector == sector){
      if(!(b->flags & B_BUSY)){
        b->flags |= B_BUSY;
  100261:	83 c8 01             	or     $0x1,%eax
  100264:	89 03                	mov    %eax,(%ebx)
        release(&bcache.lock);
  100266:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  10026d:	e8 9e 3a 00 00       	call   103d10 <release>
  100272:	eb d6                	jmp    10024a <bread+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
  100274:	c7 04 24 de 66 10 00 	movl   $0x1066de,(%esp)
  10027b:	e8 30 07 00 00       	call   1009b0 <panic>

00100280 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
  100280:	55                   	push   %ebp
  100281:	89 e5                	mov    %esp,%ebp
  100283:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
  100286:	c7 44 24 04 ef 66 10 	movl   $0x1066ef,0x4(%esp)
  10028d:	00 
  10028e:	c7 04 24 e0 88 10 00 	movl   $0x1088e0,(%esp)
  100295:	e8 36 39 00 00       	call   103bd0 <initlock>
  // head.next is most recently used.
  struct buf head;
} bcache;

void
binit(void)
  10029a:	ba 04 9e 10 00       	mov    $0x109e04,%edx
  10029f:	b8 14 89 10 00       	mov    $0x108914,%eax
  struct buf *b;

  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  1002a4:	c7 05 10 9e 10 00 04 	movl   $0x109e04,0x109e10
  1002ab:	9e 10 00 
  bcache.head.next = &bcache.head;
  1002ae:	c7 05 14 9e 10 00 04 	movl   $0x109e04,0x109e14
  1002b5:	9e 10 00 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
  1002b8:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
  1002bb:	c7 40 0c 04 9e 10 00 	movl   $0x109e04,0xc(%eax)
    b->dev = -1;
  1002c2:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
  1002c9:	8b 15 14 9e 10 00    	mov    0x109e14,%edx
  1002cf:	89 42 0c             	mov    %eax,0xc(%edx)
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
  1002d2:	89 c2                	mov    %eax,%edx
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  1002d4:	a3 14 9e 10 00       	mov    %eax,0x109e14
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
  1002d9:	05 18 02 00 00       	add    $0x218,%eax
  1002de:	3d 04 9e 10 00       	cmp    $0x109e04,%eax
  1002e3:	75 d3                	jne    1002b8 <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
  1002e5:	c9                   	leave  
  1002e6:	c3                   	ret    
  1002e7:	90                   	nop
  1002e8:	90                   	nop
  1002e9:	90                   	nop
  1002ea:	90                   	nop
  1002eb:	90                   	nop
  1002ec:	90                   	nop
  1002ed:	90                   	nop
  1002ee:	90                   	nop
  1002ef:	90                   	nop

001002f0 <consoleinit>:
  return n;
}

void
consoleinit(void)
{
  1002f0:	55                   	push   %ebp
  1002f1:	89 e5                	mov    %esp,%ebp
  1002f3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
  1002f6:	c7 44 24 04 f6 66 10 	movl   $0x1066f6,0x4(%esp)
  1002fd:	00 
  1002fe:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100305:	e8 c6 38 00 00       	call   103bd0 <initlock>
  initlock(&input.lock, "input");
  10030a:	c7 44 24 04 fe 66 10 	movl   $0x1066fe,0x4(%esp)
  100311:	00 
  100312:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  100319:	e8 b2 38 00 00       	call   103bd0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  picenable(IRQ_KBD);
  10031e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
consoleinit(void)
{
  initlock(&cons.lock, "console");
  initlock(&input.lock, "input");

  devsw[CONSOLE].write = consolewrite;
  100325:	c7 05 8c aa 10 00 d0 	movl   $0x1004d0,0x10aa8c
  10032c:	04 10 00 
  devsw[CONSOLE].read = consoleread;
  10032f:	c7 05 88 aa 10 00 20 	movl   $0x100720,0x10aa88
  100336:	07 10 00 
  cons.locking = 1;
  100339:	c7 05 74 78 10 00 01 	movl   $0x1,0x107874
  100340:	00 00 00 

  picenable(IRQ_KBD);
  100343:	e8 d8 28 00 00       	call   102c20 <picenable>
  ioapicenable(IRQ_KBD, 0);
  100348:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10034f:	00 
  100350:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  100357:	e8 74 1e 00 00       	call   1021d0 <ioapicenable>
}
  10035c:	c9                   	leave  
  10035d:	c3                   	ret    
  10035e:	66 90                	xchg   %ax,%ax

00100360 <consputc>:
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
{
  100360:	55                   	push   %ebp
  100361:	89 e5                	mov    %esp,%ebp
  100363:	57                   	push   %edi
  100364:	56                   	push   %esi
  100365:	89 c6                	mov    %eax,%esi
  100367:	53                   	push   %ebx
  100368:	83 ec 1c             	sub    $0x1c,%esp
  if(panicked){
  10036b:	83 3d 20 78 10 00 00 	cmpl   $0x0,0x107820
  100372:	74 03                	je     100377 <consputc+0x17>
}

static inline void
cli(void)
{
  asm volatile("cli");
  100374:	fa                   	cli    
  100375:	eb fe                	jmp    100375 <consputc+0x15>
    cli();
    for(;;)
      ;
  }

  if(c == BACKSPACE){
  100377:	3d 00 01 00 00       	cmp    $0x100,%eax
  10037c:	0f 84 a0 00 00 00    	je     100422 <consputc+0xc2>
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  100382:	89 04 24             	mov    %eax,(%esp)
  100385:	e8 46 4f 00 00       	call   1052d0 <uartputc>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  10038a:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
  10038f:	b8 0e 00 00 00       	mov    $0xe,%eax
  100394:	89 ca                	mov    %ecx,%edx
  100396:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  100397:	bf d5 03 00 00       	mov    $0x3d5,%edi
  10039c:	89 fa                	mov    %edi,%edx
  10039e:	ec                   	in     (%dx),%al
{
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
  10039f:	0f b6 d8             	movzbl %al,%ebx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1003a2:	89 ca                	mov    %ecx,%edx
  1003a4:	c1 e3 08             	shl    $0x8,%ebx
  1003a7:	b8 0f 00 00 00       	mov    $0xf,%eax
  1003ac:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  1003ad:	89 fa                	mov    %edi,%edx
  1003af:	ec                   	in     (%dx),%al
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);
  1003b0:	0f b6 c0             	movzbl %al,%eax
  1003b3:	09 c3                	or     %eax,%ebx

  if(c == '\n')
  1003b5:	83 fe 0a             	cmp    $0xa,%esi
  1003b8:	0f 84 ee 00 00 00    	je     1004ac <consputc+0x14c>
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
  1003be:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  1003c4:	0f 84 cb 00 00 00    	je     100495 <consputc+0x135>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  1003ca:	66 81 e6 ff 00       	and    $0xff,%si
  1003cf:	66 81 ce 00 07       	or     $0x700,%si
  1003d4:	66 89 b4 1b 00 80 0b 	mov    %si,0xb8000(%ebx,%ebx,1)
  1003db:	00 
  1003dc:	83 c3 01             	add    $0x1,%ebx
  
  if((pos/80) >= 24){  // Scroll up.
  1003df:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
  1003e5:	8d 8c 1b 00 80 0b 00 	lea    0xb8000(%ebx,%ebx,1),%ecx
  1003ec:	7f 5d                	jg     10044b <consputc+0xeb>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1003ee:	be d4 03 00 00       	mov    $0x3d4,%esi
  1003f3:	b8 0e 00 00 00       	mov    $0xe,%eax
  1003f8:	89 f2                	mov    %esi,%edx
  1003fa:	ee                   	out    %al,(%dx)
  1003fb:	bf d5 03 00 00       	mov    $0x3d5,%edi
  100400:	89 d8                	mov    %ebx,%eax
  100402:	c1 f8 08             	sar    $0x8,%eax
  100405:	89 fa                	mov    %edi,%edx
  100407:	ee                   	out    %al,(%dx)
  100408:	b8 0f 00 00 00       	mov    $0xf,%eax
  10040d:	89 f2                	mov    %esi,%edx
  10040f:	ee                   	out    %al,(%dx)
  100410:	89 d8                	mov    %ebx,%eax
  100412:	89 fa                	mov    %edi,%edx
  100414:	ee                   	out    %al,(%dx)
  
  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
  100415:	66 c7 01 20 07       	movw   $0x720,(%ecx)
  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  cgaputc(c);
}
  10041a:	83 c4 1c             	add    $0x1c,%esp
  10041d:	5b                   	pop    %ebx
  10041e:	5e                   	pop    %esi
  10041f:	5f                   	pop    %edi
  100420:	5d                   	pop    %ebp
  100421:	c3                   	ret    
    for(;;)
      ;
  }

  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  100422:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  100429:	e8 a2 4e 00 00       	call   1052d0 <uartputc>
  10042e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  100435:	e8 96 4e 00 00       	call   1052d0 <uartputc>
  10043a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  100441:	e8 8a 4e 00 00       	call   1052d0 <uartputc>
  100446:	e9 3f ff ff ff       	jmp    10038a <consputc+0x2a>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
    pos -= 80;
  10044b:	83 eb 50             	sub    $0x50,%ebx
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
  10044e:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
  100455:	00 
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  100456:	8d b4 1b 00 80 0b 00 	lea    0xb8000(%ebx,%ebx,1),%esi
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
  10045d:	c7 44 24 04 a0 80 0b 	movl   $0xb80a0,0x4(%esp)
  100464:	00 
  100465:	c7 04 24 00 80 0b 00 	movl   $0xb8000,(%esp)
  10046c:	e8 0f 3a 00 00       	call   103e80 <memmove>
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  100471:	b8 80 07 00 00       	mov    $0x780,%eax
  100476:	29 d8                	sub    %ebx,%eax
  100478:	01 c0                	add    %eax,%eax
  10047a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10047e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100485:	00 
  100486:	89 34 24             	mov    %esi,(%esp)
  100489:	e8 72 39 00 00       	call   103e00 <memset>
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
  10048e:	89 f1                	mov    %esi,%ecx
  100490:	e9 59 ff ff ff       	jmp    1003ee <consputc+0x8e>
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
    if(pos > 0) --pos;
  100495:	85 db                	test   %ebx,%ebx
  100497:	8d 8c 1b 00 80 0b 00 	lea    0xb8000(%ebx,%ebx,1),%ecx
  10049e:	0f 8e 4a ff ff ff    	jle    1003ee <consputc+0x8e>
  1004a4:	83 eb 01             	sub    $0x1,%ebx
  1004a7:	e9 33 ff ff ff       	jmp    1003df <consputc+0x7f>
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  1004ac:	89 da                	mov    %ebx,%edx
  1004ae:	89 d8                	mov    %ebx,%eax
  1004b0:	b9 50 00 00 00       	mov    $0x50,%ecx
  1004b5:	83 c3 50             	add    $0x50,%ebx
  1004b8:	c1 fa 1f             	sar    $0x1f,%edx
  1004bb:	f7 f9                	idiv   %ecx
  1004bd:	29 d3                	sub    %edx,%ebx
  1004bf:	e9 1b ff ff ff       	jmp    1003df <consputc+0x7f>
  1004c4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1004ca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001004d0 <consolewrite>:
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
  1004d0:	55                   	push   %ebp
  1004d1:	89 e5                	mov    %esp,%ebp
  1004d3:	57                   	push   %edi
  1004d4:	56                   	push   %esi
  1004d5:	53                   	push   %ebx
  1004d6:	83 ec 1c             	sub    $0x1c,%esp
  int i;

  iunlock(ip);
  1004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
  1004dc:	8b 75 10             	mov    0x10(%ebp),%esi
  1004df:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  iunlock(ip);
  1004e2:	89 04 24             	mov    %eax,(%esp)
  1004e5:	e8 16 13 00 00       	call   101800 <iunlock>
  acquire(&cons.lock);
  1004ea:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  1004f1:	e8 6a 38 00 00       	call   103d60 <acquire>
  for(i = 0; i < n; i++)
  1004f6:	85 f6                	test   %esi,%esi
  1004f8:	7e 16                	jle    100510 <consolewrite+0x40>
  1004fa:	31 db                	xor    %ebx,%ebx
  1004fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    consputc(buf[i] & 0xff);
  100500:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
  100504:	83 c3 01             	add    $0x1,%ebx
    consputc(buf[i] & 0xff);
  100507:	e8 54 fe ff ff       	call   100360 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
  10050c:	39 de                	cmp    %ebx,%esi
  10050e:	7f f0                	jg     100500 <consolewrite+0x30>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
  100510:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100517:	e8 f4 37 00 00       	call   103d10 <release>
  ilock(ip);
  10051c:	8b 45 08             	mov    0x8(%ebp),%eax
  10051f:	89 04 24             	mov    %eax,(%esp)
  100522:	e8 19 17 00 00       	call   101c40 <ilock>

  return n;
}
  100527:	83 c4 1c             	add    $0x1c,%esp
  10052a:	89 f0                	mov    %esi,%eax
  10052c:	5b                   	pop    %ebx
  10052d:	5e                   	pop    %esi
  10052e:	5f                   	pop    %edi
  10052f:	5d                   	pop    %ebp
  100530:	c3                   	ret    
  100531:	eb 0d                	jmp    100540 <printint>
  100533:	90                   	nop
  100534:	90                   	nop
  100535:	90                   	nop
  100536:	90                   	nop
  100537:	90                   	nop
  100538:	90                   	nop
  100539:	90                   	nop
  10053a:	90                   	nop
  10053b:	90                   	nop
  10053c:	90                   	nop
  10053d:	90                   	nop
  10053e:	90                   	nop
  10053f:	90                   	nop

00100540 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
  100540:	55                   	push   %ebp
  100541:	89 e5                	mov    %esp,%ebp
  100543:	57                   	push   %edi
  100544:	56                   	push   %esi
  100545:	89 d6                	mov    %edx,%esi
  100547:	53                   	push   %ebx
  100548:	83 ec 1c             	sub    $0x1c,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
  10054b:	85 c9                	test   %ecx,%ecx
  10054d:	74 04                	je     100553 <printint+0x13>
  10054f:	85 c0                	test   %eax,%eax
  100551:	78 55                	js     1005a8 <printint+0x68>
    x = -xx;
  else
    x = xx;
  100553:	31 ff                	xor    %edi,%edi
  100555:	31 c9                	xor    %ecx,%ecx
  100557:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  10055a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  i = 0;
  do{
    buf[i++] = digits[x % base];
  100560:	31 d2                	xor    %edx,%edx
  100562:	f7 f6                	div    %esi
  100564:	0f b6 92 1e 67 10 00 	movzbl 0x10671e(%edx),%edx
  10056b:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
  10056e:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
  100571:	85 c0                	test   %eax,%eax
  100573:	75 eb                	jne    100560 <printint+0x20>

  if(sign)
  100575:	85 ff                	test   %edi,%edi
  100577:	74 08                	je     100581 <printint+0x41>
    buf[i++] = '-';
  100579:	c6 44 0d d8 2d       	movb   $0x2d,-0x28(%ebp,%ecx,1)
  10057e:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
  100581:	8d 71 ff             	lea    -0x1(%ecx),%esi
  100584:	01 f3                	add    %esi,%ebx
  100586:	66 90                	xchg   %ax,%ax
    consputc(buf[i]);
  100588:	0f be 03             	movsbl (%ebx),%eax
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
  10058b:	83 ee 01             	sub    $0x1,%esi
  10058e:	83 eb 01             	sub    $0x1,%ebx
    consputc(buf[i]);
  100591:	e8 ca fd ff ff       	call   100360 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
  100596:	83 fe ff             	cmp    $0xffffffff,%esi
  100599:	75 ed                	jne    100588 <printint+0x48>
    consputc(buf[i]);
}
  10059b:	83 c4 1c             	add    $0x1c,%esp
  10059e:	5b                   	pop    %ebx
  10059f:	5e                   	pop    %esi
  1005a0:	5f                   	pop    %edi
  1005a1:	5d                   	pop    %ebp
  1005a2:	c3                   	ret    
  1005a3:	90                   	nop
  1005a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  1005a8:	f7 d8                	neg    %eax
  1005aa:	bf 01 00 00 00       	mov    $0x1,%edi
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
  1005af:	eb a4                	jmp    100555 <printint+0x15>
  1005b1:	eb 0d                	jmp    1005c0 <cprintf>
  1005b3:	90                   	nop
  1005b4:	90                   	nop
  1005b5:	90                   	nop
  1005b6:	90                   	nop
  1005b7:	90                   	nop
  1005b8:	90                   	nop
  1005b9:	90                   	nop
  1005ba:	90                   	nop
  1005bb:	90                   	nop
  1005bc:	90                   	nop
  1005bd:	90                   	nop
  1005be:	90                   	nop
  1005bf:	90                   	nop

001005c0 <cprintf>:
}

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
  1005c0:	55                   	push   %ebp
  1005c1:	89 e5                	mov    %esp,%ebp
  1005c3:	57                   	push   %edi
  1005c4:	56                   	push   %esi
  1005c5:	53                   	push   %ebx
  1005c6:	83 ec 2c             	sub    $0x2c,%esp
  int i, c, state, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
  1005c9:	8b 3d 74 78 10 00    	mov    0x107874,%edi
  if(locking)
  1005cf:	85 ff                	test   %edi,%edi
  1005d1:	0f 85 31 01 00 00    	jne    100708 <cprintf+0x148>
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  1005d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1005da:	0f b6 01             	movzbl (%ecx),%eax
  1005dd:	85 c0                	test   %eax,%eax
  1005df:	0f 84 93 00 00 00    	je     100678 <cprintf+0xb8>

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  1005e5:	8d 75 0c             	lea    0xc(%ebp),%esi
  1005e8:	31 db                	xor    %ebx,%ebx
  1005ea:	eb 3f                	jmp    10062b <cprintf+0x6b>
  1005ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
  1005f0:	83 fa 25             	cmp    $0x25,%edx
  1005f3:	0f 84 b7 00 00 00    	je     1006b0 <cprintf+0xf0>
  1005f9:	83 fa 64             	cmp    $0x64,%edx
  1005fc:	0f 84 8e 00 00 00    	je     100690 <cprintf+0xd0>
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
  100602:	b8 25 00 00 00       	mov    $0x25,%eax
  100607:	89 55 e0             	mov    %edx,-0x20(%ebp)
  10060a:	e8 51 fd ff ff       	call   100360 <consputc>
      consputc(c);
  10060f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100612:	89 d0                	mov    %edx,%eax
  100614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  100618:	e8 43 fd ff ff       	call   100360 <consputc>
  10061d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  100620:	83 c3 01             	add    $0x1,%ebx
  100623:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
  100627:	85 c0                	test   %eax,%eax
  100629:	74 4d                	je     100678 <cprintf+0xb8>
    if(c != '%'){
  10062b:	83 f8 25             	cmp    $0x25,%eax
  10062e:	75 e8                	jne    100618 <cprintf+0x58>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
  100630:	83 c3 01             	add    $0x1,%ebx
  100633:	0f b6 14 19          	movzbl (%ecx,%ebx,1),%edx
    if(c == 0)
  100637:	85 d2                	test   %edx,%edx
  100639:	74 3d                	je     100678 <cprintf+0xb8>
      break;
    switch(c){
  10063b:	83 fa 70             	cmp    $0x70,%edx
  10063e:	74 12                	je     100652 <cprintf+0x92>
  100640:	7e ae                	jle    1005f0 <cprintf+0x30>
  100642:	83 fa 73             	cmp    $0x73,%edx
  100645:	8d 76 00             	lea    0x0(%esi),%esi
  100648:	74 7e                	je     1006c8 <cprintf+0x108>
  10064a:	83 fa 78             	cmp    $0x78,%edx
  10064d:	8d 76 00             	lea    0x0(%esi),%esi
  100650:	75 b0                	jne    100602 <cprintf+0x42>
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
  100652:	8b 06                	mov    (%esi),%eax
  100654:	31 c9                	xor    %ecx,%ecx
  100656:	ba 10 00 00 00       	mov    $0x10,%edx
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  10065b:	83 c3 01             	add    $0x1,%ebx
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
  10065e:	83 c6 04             	add    $0x4,%esi
  100661:	e8 da fe ff ff       	call   100540 <printint>
  100666:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if(locking)
    acquire(&cons.lock);

  argp = (uint*)(void*)(&fmt + 1);
  state = 0;
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
  100669:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
  10066d:	85 c0                	test   %eax,%eax
  10066f:	75 ba                	jne    10062b <cprintf+0x6b>
  100671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      consputc(c);
      break;
    }
  }

  if(locking)
  100678:	85 ff                	test   %edi,%edi
  10067a:	74 0c                	je     100688 <cprintf+0xc8>
    release(&cons.lock);
  10067c:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  100683:	e8 88 36 00 00       	call   103d10 <release>
}
  100688:	83 c4 2c             	add    $0x2c,%esp
  10068b:	5b                   	pop    %ebx
  10068c:	5e                   	pop    %esi
  10068d:	5f                   	pop    %edi
  10068e:	5d                   	pop    %ebp
  10068f:	c3                   	ret    
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      printint(*argp++, 10, 1);
  100690:	8b 06                	mov    (%esi),%eax
  100692:	b9 01 00 00 00       	mov    $0x1,%ecx
  100697:	ba 0a 00 00 00       	mov    $0xa,%edx
  10069c:	83 c6 04             	add    $0x4,%esi
  10069f:	e8 9c fe ff ff       	call   100540 <printint>
  1006a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
  1006a7:	e9 74 ff ff ff       	jmp    100620 <cprintf+0x60>
  1006ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
  1006b0:	b8 25 00 00 00       	mov    $0x25,%eax
  1006b5:	e8 a6 fc ff ff       	call   100360 <consputc>
  1006ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
  1006bd:	e9 5e ff ff ff       	jmp    100620 <cprintf+0x60>
  1006c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
  1006c8:	8b 16                	mov    (%esi),%edx
  1006ca:	b8 04 67 10 00       	mov    $0x106704,%eax
  1006cf:	83 c6 04             	add    $0x4,%esi
  1006d2:	85 d2                	test   %edx,%edx
  1006d4:	0f 44 d0             	cmove  %eax,%edx
        s = "(null)";
      for(; *s; s++)
  1006d7:	0f b6 02             	movzbl (%edx),%eax
  1006da:	84 c0                	test   %al,%al
  1006dc:	0f 84 3e ff ff ff    	je     100620 <cprintf+0x60>
  1006e2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  1006e5:	89 d3                	mov    %edx,%ebx
  1006e7:	90                   	nop
        consputc(*s);
  1006e8:	0f be c0             	movsbl %al,%eax
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
  1006eb:	83 c3 01             	add    $0x1,%ebx
        consputc(*s);
  1006ee:	e8 6d fc ff ff       	call   100360 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
  1006f3:	0f b6 03             	movzbl (%ebx),%eax
  1006f6:	84 c0                	test   %al,%al
  1006f8:	75 ee                	jne    1006e8 <cprintf+0x128>
  1006fa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  1006fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  100700:	e9 1b ff ff ff       	jmp    100620 <cprintf+0x60>
  100705:	8d 76 00             	lea    0x0(%esi),%esi
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);
  100708:	c7 04 24 40 78 10 00 	movl   $0x107840,(%esp)
  10070f:	e8 4c 36 00 00       	call   103d60 <acquire>
  100714:	e9 be fe ff ff       	jmp    1005d7 <cprintf+0x17>
  100719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00100720 <consoleread>:
  release(&input.lock);
}

int
consoleread(struct inode *ip, char *dst, int n)
{
  100720:	55                   	push   %ebp
  100721:	89 e5                	mov    %esp,%ebp
  100723:	57                   	push   %edi
  100724:	56                   	push   %esi
  100725:	53                   	push   %ebx
  100726:	83 ec 3c             	sub    $0x3c,%esp
  100729:	8b 5d 10             	mov    0x10(%ebp),%ebx
  10072c:	8b 7d 08             	mov    0x8(%ebp),%edi
  10072f:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
  100732:	89 3c 24             	mov    %edi,(%esp)
  100735:	e8 c6 10 00 00       	call   101800 <iunlock>
  target = n;
  10073a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&input.lock);
  10073d:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  100744:	e8 17 36 00 00       	call   103d60 <acquire>
  while(n > 0){
  100749:	85 db                	test   %ebx,%ebx
  10074b:	7f 2c                	jg     100779 <consoleread+0x59>
  10074d:	e9 c0 00 00 00       	jmp    100812 <consoleread+0xf2>
  100752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(input.r == input.w){
      if(proc->killed){
  100758:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10075e:	8b 40 24             	mov    0x24(%eax),%eax
  100761:	85 c0                	test   %eax,%eax
  100763:	75 5b                	jne    1007c0 <consoleread+0xa0>
        release(&input.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
  100765:	c7 44 24 04 20 a0 10 	movl   $0x10a020,0x4(%esp)
  10076c:	00 
  10076d:	c7 04 24 d4 a0 10 00 	movl   $0x10a0d4,(%esp)
  100774:	e8 67 2b 00 00       	call   1032e0 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
  100779:	a1 d4 a0 10 00       	mov    0x10a0d4,%eax
  10077e:	3b 05 d8 a0 10 00    	cmp    0x10a0d8,%eax
  100784:	74 d2                	je     100758 <consoleread+0x38>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
  100786:	89 c2                	mov    %eax,%edx
  100788:	83 e2 7f             	and    $0x7f,%edx
  10078b:	0f b6 8a 54 a0 10 00 	movzbl 0x10a054(%edx),%ecx
  100792:	0f be d1             	movsbl %cl,%edx
  100795:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  100798:	8d 50 01             	lea    0x1(%eax),%edx
    if(c == C('D')){  // EOF
  10079b:	83 7d d4 04          	cmpl   $0x4,-0x2c(%ebp)
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
  10079f:	89 15 d4 a0 10 00    	mov    %edx,0x10a0d4
    if(c == C('D')){  // EOF
  1007a5:	74 3a                	je     1007e1 <consoleread+0xc1>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
  1007a7:	88 0e                	mov    %cl,(%esi)
    --n;
  1007a9:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
  1007ac:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  1007b0:	74 39                	je     1007eb <consoleread+0xcb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
  1007b2:	85 db                	test   %ebx,%ebx
  1007b4:	7e 35                	jle    1007eb <consoleread+0xcb>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
  1007b6:	83 c6 01             	add    $0x1,%esi
  1007b9:	eb be                	jmp    100779 <consoleread+0x59>
  1007bb:	90                   	nop
  1007bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
        release(&input.lock);
  1007c0:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  1007c7:	e8 44 35 00 00       	call   103d10 <release>
        ilock(ip);
  1007cc:	89 3c 24             	mov    %edi,(%esp)
  1007cf:	e8 6c 14 00 00       	call   101c40 <ilock>
  }
  release(&input.lock);
  ilock(ip);

  return target - n;
}
  1007d4:	83 c4 3c             	add    $0x3c,%esp
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
        release(&input.lock);
        ilock(ip);
  1007d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&input.lock);
  ilock(ip);

  return target - n;
}
  1007dc:	5b                   	pop    %ebx
  1007dd:	5e                   	pop    %esi
  1007de:	5f                   	pop    %edi
  1007df:	5d                   	pop    %ebp
  1007e0:	c3                   	ret    
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
  1007e1:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  1007e4:	76 05                	jbe    1007eb <consoleread+0xcb>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
  1007e6:	a3 d4 a0 10 00       	mov    %eax,0x10a0d4
  1007eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007ee:	29 d8                	sub    %ebx,%eax
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
  1007f0:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  1007f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1007fa:	e8 11 35 00 00       	call   103d10 <release>
  ilock(ip);
  1007ff:	89 3c 24             	mov    %edi,(%esp)
  100802:	e8 39 14 00 00       	call   101c40 <ilock>
  100807:	8b 45 e0             	mov    -0x20(%ebp),%eax

  return target - n;
}
  10080a:	83 c4 3c             	add    $0x3c,%esp
  10080d:	5b                   	pop    %ebx
  10080e:	5e                   	pop    %esi
  10080f:	5f                   	pop    %edi
  100810:	5d                   	pop    %ebp
  100811:	c3                   	ret    
  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
  100812:	31 c0                	xor    %eax,%eax
  100814:	eb da                	jmp    1007f0 <consoleread+0xd0>
  100816:	8d 76 00             	lea    0x0(%esi),%esi
  100819:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100820 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
  100820:	55                   	push   %ebp
  100821:	89 e5                	mov    %esp,%ebp
  100823:	57                   	push   %edi
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
  100824:	bf 50 a0 10 00       	mov    $0x10a050,%edi

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
  100829:	56                   	push   %esi
  10082a:	53                   	push   %ebx
  10082b:	83 ec 1c             	sub    $0x1c,%esp
  10082e:	8b 75 08             	mov    0x8(%ebp),%esi
  int c;

  acquire(&input.lock);
  100831:	c7 04 24 20 a0 10 00 	movl   $0x10a020,(%esp)
  100838:	e8 23 35 00 00       	call   103d60 <acquire>
  10083d:	8d 76 00             	lea    0x0(%esi),%esi
  while((c = getc()) >= 0){
  100840:	ff d6                	call   *%esi
  100842:	85 c0                	test   %eax,%eax
  100844:	89 c3                	mov    %eax,%ebx
  100846:	0f 88 9c 00 00 00    	js     1008e8 <consoleintr+0xc8>
    switch(c){
  10084c:	83 fb 10             	cmp    $0x10,%ebx
  10084f:	90                   	nop
  100850:	0f 84 1a 01 00 00    	je     100970 <consoleintr+0x150>
  100856:	0f 8f a4 00 00 00    	jg     100900 <consoleintr+0xe0>
  10085c:	83 fb 08             	cmp    $0x8,%ebx
  10085f:	90                   	nop
  100860:	0f 84 a8 00 00 00    	je     10090e <consoleintr+0xee>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
  100866:	85 db                	test   %ebx,%ebx
  100868:	74 d6                	je     100840 <consoleintr+0x20>
  10086a:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  10086f:	89 c2                	mov    %eax,%edx
  100871:	2b 15 d4 a0 10 00    	sub    0x10a0d4,%edx
  100877:	83 fa 7f             	cmp    $0x7f,%edx
  10087a:	77 c4                	ja     100840 <consoleintr+0x20>
        c = (c == '\r') ? '\n' : c;
  10087c:	83 fb 0d             	cmp    $0xd,%ebx
  10087f:	0f 84 f8 00 00 00    	je     10097d <consoleintr+0x15d>
        input.buf[input.e++ % INPUT_BUF] = c;
  100885:	89 c2                	mov    %eax,%edx
  100887:	83 c0 01             	add    $0x1,%eax
  10088a:	83 e2 7f             	and    $0x7f,%edx
  10088d:	88 5c 3a 04          	mov    %bl,0x4(%edx,%edi,1)
  100891:	a3 dc a0 10 00       	mov    %eax,0x10a0dc
        consputc(c);
  100896:	89 d8                	mov    %ebx,%eax
  100898:	e8 c3 fa ff ff       	call   100360 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
  10089d:	83 fb 04             	cmp    $0x4,%ebx
  1008a0:	0f 84 f3 00 00 00    	je     100999 <consoleintr+0x179>
  1008a6:	83 fb 0a             	cmp    $0xa,%ebx
  1008a9:	0f 84 ea 00 00 00    	je     100999 <consoleintr+0x179>
  1008af:	8b 15 d4 a0 10 00    	mov    0x10a0d4,%edx
  1008b5:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  1008ba:	83 ea 80             	sub    $0xffffff80,%edx
  1008bd:	39 d0                	cmp    %edx,%eax
  1008bf:	0f 85 7b ff ff ff    	jne    100840 <consoleintr+0x20>
          input.w = input.e;
  1008c5:	a3 d8 a0 10 00       	mov    %eax,0x10a0d8
          wakeup(&input.r);
  1008ca:	c7 04 24 d4 a0 10 00 	movl   $0x10a0d4,(%esp)
  1008d1:	e8 ea 28 00 00       	call   1031c0 <wakeup>
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
  1008d6:	ff d6                	call   *%esi
  1008d8:	85 c0                	test   %eax,%eax
  1008da:	89 c3                	mov    %eax,%ebx
  1008dc:	0f 89 6a ff ff ff    	jns    10084c <consoleintr+0x2c>
  1008e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        }
      }
      break;
    }
  }
  release(&input.lock);
  1008e8:	c7 45 08 20 a0 10 00 	movl   $0x10a020,0x8(%ebp)
}
  1008ef:	83 c4 1c             	add    $0x1c,%esp
  1008f2:	5b                   	pop    %ebx
  1008f3:	5e                   	pop    %esi
  1008f4:	5f                   	pop    %edi
  1008f5:	5d                   	pop    %ebp
        }
      }
      break;
    }
  }
  release(&input.lock);
  1008f6:	e9 15 34 00 00       	jmp    103d10 <release>
  1008fb:	90                   	nop
  1008fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
    switch(c){
  100900:	83 fb 15             	cmp    $0x15,%ebx
  100903:	74 57                	je     10095c <consoleintr+0x13c>
  100905:	83 fb 7f             	cmp    $0x7f,%ebx
  100908:	0f 85 58 ff ff ff    	jne    100866 <consoleintr+0x46>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
  10090e:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  100913:	3b 05 d8 a0 10 00    	cmp    0x10a0d8,%eax
  100919:	0f 84 21 ff ff ff    	je     100840 <consoleintr+0x20>
        input.e--;
  10091f:	83 e8 01             	sub    $0x1,%eax
  100922:	a3 dc a0 10 00       	mov    %eax,0x10a0dc
        consputc(BACKSPACE);
  100927:	b8 00 01 00 00       	mov    $0x100,%eax
  10092c:	e8 2f fa ff ff       	call   100360 <consputc>
  100931:	e9 0a ff ff ff       	jmp    100840 <consoleintr+0x20>
  100936:	66 90                	xchg   %ax,%ax
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
  100938:	83 e8 01             	sub    $0x1,%eax
  10093b:	89 c2                	mov    %eax,%edx
  10093d:	83 e2 7f             	and    $0x7f,%edx
  100940:	80 ba 54 a0 10 00 0a 	cmpb   $0xa,0x10a054(%edx)
  100947:	0f 84 f3 fe ff ff    	je     100840 <consoleintr+0x20>
        input.e--;
  10094d:	a3 dc a0 10 00       	mov    %eax,0x10a0dc
        consputc(BACKSPACE);
  100952:	b8 00 01 00 00       	mov    $0x100,%eax
  100957:	e8 04 fa ff ff       	call   100360 <consputc>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
  10095c:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  100961:	3b 05 d8 a0 10 00    	cmp    0x10a0d8,%eax
  100967:	75 cf                	jne    100938 <consoleintr+0x118>
  100969:	e9 d2 fe ff ff       	jmp    100840 <consoleintr+0x20>
  10096e:	66 90                	xchg   %ax,%ax

  acquire(&input.lock);
  while((c = getc()) >= 0){
    switch(c){
    case C('P'):  // Process listing.
      procdump();
  100970:	e8 eb 26 00 00       	call   103060 <procdump>
  100975:	8d 76 00             	lea    0x0(%esi),%esi
      break;
  100978:	e9 c3 fe ff ff       	jmp    100840 <consoleintr+0x20>
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
  10097d:	89 c2                	mov    %eax,%edx
  10097f:	83 c0 01             	add    $0x1,%eax
  100982:	83 e2 7f             	and    $0x7f,%edx
  100985:	c6 44 3a 04 0a       	movb   $0xa,0x4(%edx,%edi,1)
  10098a:	a3 dc a0 10 00       	mov    %eax,0x10a0dc
        consputc(c);
  10098f:	b8 0a 00 00 00       	mov    $0xa,%eax
  100994:	e8 c7 f9 ff ff       	call   100360 <consputc>
  100999:	a1 dc a0 10 00       	mov    0x10a0dc,%eax
  10099e:	e9 22 ff ff ff       	jmp    1008c5 <consoleintr+0xa5>
  1009a3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1009a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001009b0 <panic>:
    release(&cons.lock);
}

void
panic(char *s)
{
  1009b0:	55                   	push   %ebp
  1009b1:	89 e5                	mov    %esp,%ebp
  1009b3:	56                   	push   %esi
  1009b4:	53                   	push   %ebx
  1009b5:	83 ec 40             	sub    $0x40,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
  1009b8:	fa                   	cli    
  int i;
  uint pcs[10];
  
  cli();
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  1009b9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  1009bf:	8d 75 d0             	lea    -0x30(%ebp),%esi
  1009c2:	31 db                	xor    %ebx,%ebx
{
  int i;
  uint pcs[10];
  
  cli();
  cons.locking = 0;
  1009c4:	c7 05 74 78 10 00 00 	movl   $0x0,0x107874
  1009cb:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
  1009ce:	0f b6 00             	movzbl (%eax),%eax
  1009d1:	c7 04 24 0b 67 10 00 	movl   $0x10670b,(%esp)
  1009d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009dc:	e8 df fb ff ff       	call   1005c0 <cprintf>
  cprintf(s);
  1009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1009e4:	89 04 24             	mov    %eax,(%esp)
  1009e7:	e8 d4 fb ff ff       	call   1005c0 <cprintf>
  cprintf("\n");
  1009ec:	c7 04 24 16 6b 10 00 	movl   $0x106b16,(%esp)
  1009f3:	e8 c8 fb ff ff       	call   1005c0 <cprintf>
  getcallerpcs(&s, pcs);
  1009f8:	8d 45 08             	lea    0x8(%ebp),%eax
  1009fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  1009ff:	89 04 24             	mov    %eax,(%esp)
  100a02:	e8 e9 31 00 00       	call   103bf0 <getcallerpcs>
  100a07:	90                   	nop
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
  100a08:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
  100a0b:	83 c3 01             	add    $0x1,%ebx
    cprintf(" %p", pcs[i]);
  100a0e:	c7 04 24 1a 67 10 00 	movl   $0x10671a,(%esp)
  100a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a19:	e8 a2 fb ff ff       	call   1005c0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
  100a1e:	83 fb 0a             	cmp    $0xa,%ebx
  100a21:	75 e5                	jne    100a08 <panic+0x58>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
  100a23:	c7 05 20 78 10 00 01 	movl   $0x1,0x107820
  100a2a:	00 00 00 
  100a2d:	eb fe                	jmp    100a2d <panic+0x7d>
  100a2f:	90                   	nop

00100a30 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
  100a30:	55                   	push   %ebp
  100a31:	89 e5                	mov    %esp,%ebp
  100a33:	57                   	push   %edi
  100a34:	56                   	push   %esi
  100a35:	53                   	push   %ebx
  100a36:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
  100a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  100a3f:	89 04 24             	mov    %eax,(%esp)
  100a42:	e8 99 14 00 00       	call   101ee0 <namei>
  100a47:	85 c0                	test   %eax,%eax
  100a49:	89 c7                	mov    %eax,%edi
  100a4b:	0f 84 25 01 00 00    	je     100b76 <exec+0x146>
    return -1;
  ilock(ip);
  100a51:	89 04 24             	mov    %eax,(%esp)
  100a54:	e8 e7 11 00 00       	call   101c40 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
  100a59:	8d 45 94             	lea    -0x6c(%ebp),%eax
  100a5c:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
  100a63:	00 
  100a64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100a6b:	00 
  100a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a70:	89 3c 24             	mov    %edi,(%esp)
  100a73:	e8 78 09 00 00       	call   1013f0 <readi>
  100a78:	83 f8 33             	cmp    $0x33,%eax
  100a7b:	0f 86 cf 01 00 00    	jbe    100c50 <exec+0x220>
    goto bad;
  if(elf.magic != ELF_MAGIC)
  100a81:	81 7d 94 7f 45 4c 46 	cmpl   $0x464c457f,-0x6c(%ebp)
  100a88:	0f 85 c2 01 00 00    	jne    100c50 <exec+0x220>
  100a8e:	66 90                	xchg   %ax,%ax
    goto bad;

  if((pgdir = setupkvm()) == 0)
  100a90:	e8 bb 55 00 00       	call   106050 <setupkvm>
  100a95:	85 c0                	test   %eax,%eax
  100a97:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
  100a9d:	0f 84 ad 01 00 00    	je     100c50 <exec+0x220>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100aa3:	66 83 7d c0 00       	cmpw   $0x0,-0x40(%ebp)
  100aa8:	8b 75 b0             	mov    -0x50(%ebp),%esi
  100aab:	0f 84 bb 02 00 00    	je     100d6c <exec+0x33c>
  100ab1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  100ab8:	00 00 00 
  100abb:	31 db                	xor    %ebx,%ebx
  100abd:	eb 13                	jmp    100ad2 <exec+0xa2>
  100abf:	90                   	nop
  100ac0:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
  100ac4:	83 c3 01             	add    $0x1,%ebx
  100ac7:	39 d8                	cmp    %ebx,%eax
  100ac9:	0f 8e b9 00 00 00    	jle    100b88 <exec+0x158>
  100acf:	83 c6 20             	add    $0x20,%esi
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
  100ad2:	8d 55 c8             	lea    -0x38(%ebp),%edx
  100ad5:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
  100adc:	00 
  100add:	89 74 24 08          	mov    %esi,0x8(%esp)
  100ae1:	89 54 24 04          	mov    %edx,0x4(%esp)
  100ae5:	89 3c 24             	mov    %edi,(%esp)
  100ae8:	e8 03 09 00 00       	call   1013f0 <readi>
  100aed:	83 f8 20             	cmp    $0x20,%eax
  100af0:	75 6e                	jne    100b60 <exec+0x130>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
  100af2:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  100af6:	75 c8                	jne    100ac0 <exec+0x90>
      continue;
    if(ph.memsz < ph.filesz)
  100af8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100afb:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  100afe:	66 90                	xchg   %ax,%ax
  100b00:	72 5e                	jb     100b60 <exec+0x130>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.va + ph.memsz)) == 0)
  100b02:	03 45 d0             	add    -0x30(%ebp),%eax
  100b05:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  100b0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  100b0f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100b15:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b19:	89 04 24             	mov    %eax,(%esp)
  100b1c:	e8 2f 58 00 00       	call   106350 <allocuvm>
  100b21:	85 c0                	test   %eax,%eax
  100b23:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
  100b29:	74 35                	je     100b60 <exec+0x130>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.va, ip, ph.offset, ph.filesz) < 0)
  100b2b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100b2e:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  100b34:	89 7c 24 08          	mov    %edi,0x8(%esp)
  100b38:	89 44 24 10          	mov    %eax,0x10(%esp)
  100b3c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  100b3f:	89 14 24             	mov    %edx,(%esp)
  100b42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100b46:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100b49:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4d:	e8 ce 58 00 00       	call   106420 <loaduvm>
  100b52:	85 c0                	test   %eax,%eax
  100b54:	0f 89 66 ff ff ff    	jns    100ac0 <exec+0x90>
  100b5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  100b60:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  100b66:	89 04 24             	mov    %eax,(%esp)
  100b69:	e8 a2 56 00 00       	call   106210 <freevm>
  if(ip)
  100b6e:	85 ff                	test   %edi,%edi
  100b70:	0f 85 da 00 00 00    	jne    100c50 <exec+0x220>
    iunlockput(ip);
  100b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
  100b7b:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  100b81:	5b                   	pop    %ebx
  100b82:	5e                   	pop    %esi
  100b83:	5f                   	pop    %edi
  100b84:	5d                   	pop    %ebp
  100b85:	c3                   	ret    
  100b86:	66 90                	xchg   %ax,%ax
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100b88:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100b8e:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  100b94:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  100b9a:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
    if((sz = allocuvm(pgdir, sz, ph.va + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.va, ip, ph.offset, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  100ba0:	89 3c 24             	mov    %edi,(%esp)
  100ba3:	e8 a8 0f 00 00       	call   101b50 <iunlockput>
  ip = 0;

  // Allocate a one-page stack at the next page boundary
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
  100ba8:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
  100bae:	89 74 24 08          	mov    %esi,0x8(%esp)
  100bb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100bb6:	89 0c 24             	mov    %ecx,(%esp)
  100bb9:	e8 92 57 00 00       	call   106350 <allocuvm>
  100bbe:	85 c0                	test   %eax,%eax
  100bc0:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
  100bc6:	74 7f                	je     100c47 <exec+0x217>
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  100bcb:	8b 02                	mov    (%edx),%eax
  100bcd:	85 c0                	test   %eax,%eax
  100bcf:	0f 84 78 01 00 00    	je     100d4d <exec+0x31d>
  100bd5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  100bd8:	31 f6                	xor    %esi,%esi
  100bda:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100be0:	eb 28                	jmp    100c0a <exec+0x1da>
  100be2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  100be8:	89 9c b5 10 ff ff ff 	mov    %ebx,-0xf0(%ebp,%esi,4)
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
  100bef:	8b 45 0c             	mov    0xc(%ebp),%eax
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100bf2:	83 c6 01             	add    $0x1,%esi
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  100bf5:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
  100bfb:	8d 3c b0             	lea    (%eax,%esi,4),%edi
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100bfe:	8b 04 b0             	mov    (%eax,%esi,4),%eax
  100c01:	85 c0                	test   %eax,%eax
  100c03:	74 5d                	je     100c62 <exec+0x232>
    if(argc >= MAXARG)
  100c05:	83 fe 20             	cmp    $0x20,%esi
  100c08:	74 3d                	je     100c47 <exec+0x217>
      goto bad;
    sp -= strlen(argv[argc]) + 1;
  100c0a:	89 04 24             	mov    %eax,(%esp)
  100c0d:	e8 ce 33 00 00       	call   103fe0 <strlen>
  100c12:	f7 d0                	not    %eax
  100c14:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
  100c17:	8b 07                	mov    (%edi),%eax
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp &= ~3;
  100c19:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
  100c1c:	89 04 24             	mov    %eax,(%esp)
  100c1f:	e8 bc 33 00 00       	call   103fe0 <strlen>
  100c24:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
  100c2a:	83 c0 01             	add    $0x1,%eax
  100c2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100c31:	8b 07                	mov    (%edi),%eax
  100c33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100c37:	89 0c 24             	mov    %ecx,(%esp)
  100c3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  100c3e:	e8 ed 52 00 00       	call   105f30 <copyout>
  100c43:	85 c0                	test   %eax,%eax
  100c45:	79 a1                	jns    100be8 <exec+0x1b8>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip)
    iunlockput(ip);
  100c47:	31 ff                	xor    %edi,%edi
  100c49:	e9 12 ff ff ff       	jmp    100b60 <exec+0x130>
  100c4e:	66 90                	xchg   %ax,%ax
  100c50:	89 3c 24             	mov    %edi,(%esp)
  100c53:	e8 f8 0e 00 00       	call   101b50 <iunlockput>
  100c58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100c5d:	e9 19 ff ff ff       	jmp    100b7b <exec+0x14b>
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100c62:	8d 4e 03             	lea    0x3(%esi),%ecx
  100c65:	8d 3c b5 04 00 00 00 	lea    0x4(,%esi,4),%edi
  100c6c:	8d 04 b5 10 00 00 00 	lea    0x10(,%esi,4),%eax
    sp &= ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
  100c73:	c7 84 8d 04 ff ff ff 	movl   $0x0,-0xfc(%ebp,%ecx,4)
  100c7a:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c7e:	89 d9                	mov    %ebx,%ecx

  sp -= (3+argc+1) * 4;
  100c80:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
  100c82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100c86:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c8c:	29 f9                	sub    %edi,%ecx
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  100c8e:	c7 85 04 ff ff ff ff 	movl   $0xffffffff,-0xfc(%ebp)
  100c95:	ff ff ff 
  ustack[1] = argc;
  100c98:	89 b5 08 ff ff ff    	mov    %esi,-0xf8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
  100c9e:	89 8d 0c ff ff ff    	mov    %ecx,-0xf4(%ebp)

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
  100ca4:	89 54 24 08          	mov    %edx,0x8(%esp)
  100ca8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  100cac:	89 04 24             	mov    %eax,(%esp)
  100caf:	e8 7c 52 00 00       	call   105f30 <copyout>
  100cb4:	85 c0                	test   %eax,%eax
  100cb6:	78 8f                	js     100c47 <exec+0x217>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
  100cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  100cbb:	0f b6 11             	movzbl (%ecx),%edx
  100cbe:	84 d2                	test   %dl,%dl
  100cc0:	74 16                	je     100cd8 <exec+0x2a8>
  100cc2:	89 c8                	mov    %ecx,%eax
  100cc4:	83 c0 01             	add    $0x1,%eax
  100cc7:	90                   	nop
    if(*s == '/')
  100cc8:	80 fa 2f             	cmp    $0x2f,%dl
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
  100ccb:	0f b6 10             	movzbl (%eax),%edx
    if(*s == '/')
  100cce:	0f 44 c8             	cmove  %eax,%ecx
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
  100cd1:	83 c0 01             	add    $0x1,%eax
  100cd4:	84 d2                	test   %dl,%dl
  100cd6:	75 f0                	jne    100cc8 <exec+0x298>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
  100cd8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100cde:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100ce2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  100ce9:	00 
  100cea:	83 c0 6c             	add    $0x6c,%eax
  100ced:	89 04 24             	mov    %eax,(%esp)
  100cf0:	e8 ab 32 00 00       	call   103fa0 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  100cf5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  proc->pgdir = pgdir;
  100cfb:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));

  // Commit to the user image.
  oldpgdir = proc->pgdir;
  100d01:	8b 70 04             	mov    0x4(%eax),%esi
  proc->pgdir = pgdir;
  100d04:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
  100d07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100d0d:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  100d13:	89 08                	mov    %ecx,(%eax)
  proc->tf->eip = elf.entry;  // main
  100d15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100d1b:	8b 55 ac             	mov    -0x54(%ebp),%edx
  100d1e:	8b 40 18             	mov    0x18(%eax),%eax
  100d21:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
  100d24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100d2a:	8b 40 18             	mov    0x18(%eax),%eax
  100d2d:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(proc);
  100d30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  100d36:	89 04 24             	mov    %eax,(%esp)
  100d39:	e8 a2 57 00 00       	call   1064e0 <switchuvm>
  freevm(oldpgdir);
  100d3e:	89 34 24             	mov    %esi,(%esp)
  100d41:	e8 ca 54 00 00       	call   106210 <freevm>
  100d46:	31 c0                	xor    %eax,%eax

  return 0;
  100d48:	e9 2e fe ff ff       	jmp    100b7b <exec+0x14b>
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;

  // Push argument strings, prepare rest of stack in ustack.
  sp = sz;
  for(argc = 0; argv[argc]; argc++) {
  100d4d:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
  100d53:	b0 10                	mov    $0x10,%al
  100d55:	bf 04 00 00 00       	mov    $0x4,%edi
  100d5a:	b9 03 00 00 00       	mov    $0x3,%ecx
  100d5f:	31 f6                	xor    %esi,%esi
  100d61:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
  100d67:	e9 07 ff ff ff       	jmp    100c73 <exec+0x243>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
  100d6c:	be 00 10 00 00       	mov    $0x1000,%esi
  100d71:	31 db                	xor    %ebx,%ebx
  100d73:	e9 28 fe ff ff       	jmp    100ba0 <exec+0x170>
  100d78:	90                   	nop
  100d79:	90                   	nop
  100d7a:	90                   	nop
  100d7b:	90                   	nop
  100d7c:	90                   	nop
  100d7d:	90                   	nop
  100d7e:	90                   	nop
  100d7f:	90                   	nop

00100d80 <filewrite>:
}

// Write to file f.  Addr is kernel address.
int
filewrite(struct file *f, char *addr, int n)
{
  100d80:	55                   	push   %ebp
  100d81:	89 e5                	mov    %esp,%ebp
  100d83:	83 ec 38             	sub    $0x38,%esp
  100d86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100d89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100d8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100d8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  100d92:	89 7d fc             	mov    %edi,-0x4(%ebp)
  100d95:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->writable == 0)
  100d98:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
  100d9c:	74 5a                	je     100df8 <filewrite+0x78>
    return -1;
  if(f->type == FD_PIPE)
  100d9e:	8b 03                	mov    (%ebx),%eax
  100da0:	83 f8 01             	cmp    $0x1,%eax
  100da3:	74 5b                	je     100e00 <filewrite+0x80>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
  100da5:	83 f8 02             	cmp    $0x2,%eax
  100da8:	75 6d                	jne    100e17 <filewrite+0x97>
    ilock(f->ip);
  100daa:	8b 43 10             	mov    0x10(%ebx),%eax
  100dad:	89 04 24             	mov    %eax,(%esp)
  100db0:	e8 8b 0e 00 00       	call   101c40 <ilock>
    if((r = writei(f->ip, addr, f->off, n)) > 0)
  100db5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  100db9:	8b 43 14             	mov    0x14(%ebx),%eax
  100dbc:	89 74 24 04          	mov    %esi,0x4(%esp)
  100dc0:	89 44 24 08          	mov    %eax,0x8(%esp)
  100dc4:	8b 43 10             	mov    0x10(%ebx),%eax
  100dc7:	89 04 24             	mov    %eax,(%esp)
  100dca:	e8 c1 07 00 00       	call   101590 <writei>
  100dcf:	85 c0                	test   %eax,%eax
  100dd1:	7e 03                	jle    100dd6 <filewrite+0x56>
      f->off += r;
  100dd3:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
  100dd6:	8b 53 10             	mov    0x10(%ebx),%edx
  100dd9:	89 14 24             	mov    %edx,(%esp)
  100ddc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100ddf:	e8 1c 0a 00 00       	call   101800 <iunlock>
    return r;
  100de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("filewrite");
}
  100de7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100dea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100ded:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100df0:	89 ec                	mov    %ebp,%esp
  100df2:	5d                   	pop    %ebp
  100df3:	c3                   	ret    
  100df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((r = writei(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
  100df8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100dfd:	eb e8                	jmp    100de7 <filewrite+0x67>
  100dff:	90                   	nop
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100e00:	8b 43 0c             	mov    0xc(%ebx),%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
}
  100e03:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100e06:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100e09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100e0c:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
}
  100e0f:	89 ec                	mov    %ebp,%esp
  100e11:	5d                   	pop    %ebp
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
  100e12:	e9 d9 1f 00 00       	jmp    102df0 <pipewrite>
    if((r = writei(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("filewrite");
  100e17:	c7 04 24 2f 67 10 00 	movl   $0x10672f,(%esp)
  100e1e:	e8 8d fb ff ff       	call   1009b0 <panic>
  100e23:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100e30 <fileread>:
}

// Read from file f.  Addr is kernel address.
int
fileread(struct file *f, char *addr, int n)
{
  100e30:	55                   	push   %ebp
  100e31:	89 e5                	mov    %esp,%ebp
  100e33:	83 ec 38             	sub    $0x38,%esp
  100e36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  100e39:	8b 5d 08             	mov    0x8(%ebp),%ebx
  100e3c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  100e3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  100e42:	89 7d fc             	mov    %edi,-0x4(%ebp)
  100e45:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
  100e48:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
  100e4c:	74 5a                	je     100ea8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
  100e4e:	8b 03                	mov    (%ebx),%eax
  100e50:	83 f8 01             	cmp    $0x1,%eax
  100e53:	74 5b                	je     100eb0 <fileread+0x80>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
  100e55:	83 f8 02             	cmp    $0x2,%eax
  100e58:	75 6d                	jne    100ec7 <fileread+0x97>
    ilock(f->ip);
  100e5a:	8b 43 10             	mov    0x10(%ebx),%eax
  100e5d:	89 04 24             	mov    %eax,(%esp)
  100e60:	e8 db 0d 00 00       	call   101c40 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
  100e65:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  100e69:	8b 43 14             	mov    0x14(%ebx),%eax
  100e6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  100e70:	89 44 24 08          	mov    %eax,0x8(%esp)
  100e74:	8b 43 10             	mov    0x10(%ebx),%eax
  100e77:	89 04 24             	mov    %eax,(%esp)
  100e7a:	e8 71 05 00 00       	call   1013f0 <readi>
  100e7f:	85 c0                	test   %eax,%eax
  100e81:	7e 03                	jle    100e86 <fileread+0x56>
      f->off += r;
  100e83:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
  100e86:	8b 53 10             	mov    0x10(%ebx),%edx
  100e89:	89 14 24             	mov    %edx,(%esp)
  100e8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100e8f:	e8 6c 09 00 00       	call   101800 <iunlock>
    return r;
  100e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("fileread");
}
  100e97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100e9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100e9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  100ea0:	89 ec                	mov    %ebp,%esp
  100ea2:	5d                   	pop    %ebp
  100ea3:	c3                   	ret    
  100ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
  100ea8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100ead:	eb e8                	jmp    100e97 <fileread+0x67>
  100eaf:	90                   	nop
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100eb0:	8b 43 0c             	mov    0xc(%ebx),%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
  100eb3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  100eb6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  100eb9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100ebc:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
  100ebf:	89 ec                	mov    %ebp,%esp
  100ec1:	5d                   	pop    %ebp
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  100ec2:	e9 29 1e 00 00       	jmp    102cf0 <piperead>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
  100ec7:	c7 04 24 39 67 10 00 	movl   $0x106739,(%esp)
  100ece:	e8 dd fa ff ff       	call   1009b0 <panic>
  100ed3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100ee0 <filestat>:
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  100ee0:	55                   	push   %ebp
  if(f->type == FD_INODE){
  100ee1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  100ee6:	89 e5                	mov    %esp,%ebp
  100ee8:	53                   	push   %ebx
  100ee9:	83 ec 14             	sub    $0x14,%esp
  100eec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
  100eef:	83 3b 02             	cmpl   $0x2,(%ebx)
  100ef2:	74 0c                	je     100f00 <filestat+0x20>
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
  }
  return -1;
}
  100ef4:	83 c4 14             	add    $0x14,%esp
  100ef7:	5b                   	pop    %ebx
  100ef8:	5d                   	pop    %ebp
  100ef9:	c3                   	ret    
  100efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
  100f00:	8b 43 10             	mov    0x10(%ebx),%eax
  100f03:	89 04 24             	mov    %eax,(%esp)
  100f06:	e8 35 0d 00 00       	call   101c40 <ilock>
    stati(f->ip, st);
  100f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  100f0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100f12:	8b 43 10             	mov    0x10(%ebx),%eax
  100f15:	89 04 24             	mov    %eax,(%esp)
  100f18:	e8 e3 01 00 00       	call   101100 <stati>
    iunlock(f->ip);
  100f1d:	8b 43 10             	mov    0x10(%ebx),%eax
  100f20:	89 04 24             	mov    %eax,(%esp)
  100f23:	e8 d8 08 00 00       	call   101800 <iunlock>
    return 0;
  }
  return -1;
}
  100f28:	83 c4 14             	add    $0x14,%esp
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
  100f2b:	31 c0                	xor    %eax,%eax
    return 0;
  }
  return -1;
}
  100f2d:	5b                   	pop    %ebx
  100f2e:	5d                   	pop    %ebp
  100f2f:	c3                   	ret    

00100f30 <filedup>:
}

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
  100f30:	55                   	push   %ebp
  100f31:	89 e5                	mov    %esp,%ebp
  100f33:	53                   	push   %ebx
  100f34:	83 ec 14             	sub    $0x14,%esp
  100f37:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
  100f3a:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f41:	e8 1a 2e 00 00       	call   103d60 <acquire>
  if(f->ref < 1)
  100f46:	8b 43 04             	mov    0x4(%ebx),%eax
  100f49:	85 c0                	test   %eax,%eax
  100f4b:	7e 1a                	jle    100f67 <filedup+0x37>
    panic("filedup");
  f->ref++;
  100f4d:	83 c0 01             	add    $0x1,%eax
  100f50:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
  100f53:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f5a:	e8 b1 2d 00 00       	call   103d10 <release>
  return f;
}
  100f5f:	89 d8                	mov    %ebx,%eax
  100f61:	83 c4 14             	add    $0x14,%esp
  100f64:	5b                   	pop    %ebx
  100f65:	5d                   	pop    %ebp
  100f66:	c3                   	ret    
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
  100f67:	c7 04 24 42 67 10 00 	movl   $0x106742,(%esp)
  100f6e:	e8 3d fa ff ff       	call   1009b0 <panic>
  100f73:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  100f79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00100f80 <filealloc>:
}

// Allocate a file structure.
struct file*
filealloc(void)
{
  100f80:	55                   	push   %ebp
  100f81:	89 e5                	mov    %esp,%ebp
  100f83:	53                   	push   %ebx
  initlock(&ftable.lock, "ftable");
}

// Allocate a file structure.
struct file*
filealloc(void)
  100f84:	bb 2c a1 10 00       	mov    $0x10a12c,%ebx
{
  100f89:	83 ec 14             	sub    $0x14,%esp
  struct file *f;

  acquire(&ftable.lock);
  100f8c:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100f93:	e8 c8 2d 00 00       	call   103d60 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
  100f98:	8b 15 18 a1 10 00    	mov    0x10a118,%edx
  100f9e:	85 d2                	test   %edx,%edx
  100fa0:	75 11                	jne    100fb3 <filealloc+0x33>
  100fa2:	eb 4a                	jmp    100fee <filealloc+0x6e>
  100fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
  100fa8:	83 c3 18             	add    $0x18,%ebx
  100fab:	81 fb 74 aa 10 00    	cmp    $0x10aa74,%ebx
  100fb1:	74 25                	je     100fd8 <filealloc+0x58>
    if(f->ref == 0){
  100fb3:	8b 43 04             	mov    0x4(%ebx),%eax
  100fb6:	85 c0                	test   %eax,%eax
  100fb8:	75 ee                	jne    100fa8 <filealloc+0x28>
      f->ref = 1;
  100fba:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
  100fc1:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100fc8:	e8 43 2d 00 00       	call   103d10 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
  100fcd:	89 d8                	mov    %ebx,%eax
  100fcf:	83 c4 14             	add    $0x14,%esp
  100fd2:	5b                   	pop    %ebx
  100fd3:	5d                   	pop    %ebp
  100fd4:	c3                   	ret    
  100fd5:	8d 76 00             	lea    0x0(%esi),%esi
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
  100fd8:	31 db                	xor    %ebx,%ebx
  100fda:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  100fe1:	e8 2a 2d 00 00       	call   103d10 <release>
  return 0;
}
  100fe6:	89 d8                	mov    %ebx,%eax
  100fe8:	83 c4 14             	add    $0x14,%esp
  100feb:	5b                   	pop    %ebx
  100fec:	5d                   	pop    %ebp
  100fed:	c3                   	ret    
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
  100fee:	bb 14 a1 10 00       	mov    $0x10a114,%ebx
  100ff3:	eb c5                	jmp    100fba <filealloc+0x3a>
  100ff5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  100ff9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101000 <fileclose>:
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
  101000:	55                   	push   %ebp
  101001:	89 e5                	mov    %esp,%ebp
  101003:	83 ec 38             	sub    $0x38,%esp
  101006:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  101009:	8b 5d 08             	mov    0x8(%ebp),%ebx
  10100c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10100f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct file ff;

  acquire(&ftable.lock);
  101012:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  101019:	e8 42 2d 00 00       	call   103d60 <acquire>
  if(f->ref < 1)
  10101e:	8b 43 04             	mov    0x4(%ebx),%eax
  101021:	85 c0                	test   %eax,%eax
  101023:	0f 8e 9c 00 00 00    	jle    1010c5 <fileclose+0xc5>
    panic("fileclose");
  if(--f->ref > 0){
  101029:	83 e8 01             	sub    $0x1,%eax
  10102c:	85 c0                	test   %eax,%eax
  10102e:	89 43 04             	mov    %eax,0x4(%ebx)
  101031:	74 1d                	je     101050 <fileclose+0x50>
    release(&ftable.lock);
  101033:	c7 45 08 e0 a0 10 00 	movl   $0x10a0e0,0x8(%ebp)
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
}
  10103a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10103d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101040:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101043:	89 ec                	mov    %ebp,%esp
  101045:	5d                   	pop    %ebp

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
  101046:	e9 c5 2c 00 00       	jmp    103d10 <release>
  10104b:	90                   	nop
  10104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  }
  ff = *f;
  101050:	8b 43 0c             	mov    0xc(%ebx),%eax
  101053:	8b 7b 10             	mov    0x10(%ebx),%edi
  101056:	89 45 e0             	mov    %eax,-0x20(%ebp)
  101059:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  10105d:	88 45 e7             	mov    %al,-0x19(%ebp)
  101060:	8b 33                	mov    (%ebx),%esi
  f->ref = 0;
  101062:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
  101069:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
  10106f:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  101076:	e8 95 2c 00 00       	call   103d10 <release>
  
  if(ff.type == FD_PIPE)
  10107b:	83 fe 01             	cmp    $0x1,%esi
  10107e:	74 30                	je     1010b0 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
  101080:	83 fe 02             	cmp    $0x2,%esi
  101083:	74 13                	je     101098 <fileclose+0x98>
    iput(ff.ip);
}
  101085:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  101088:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10108b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  10108e:	89 ec                	mov    %ebp,%esp
  101090:	5d                   	pop    %ebp
  101091:	c3                   	ret    
  101092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
  101098:	89 7d 08             	mov    %edi,0x8(%ebp)
}
  10109b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10109e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1010a1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1010a4:	89 ec                	mov    %ebp,%esp
  1010a6:	5d                   	pop    %ebp
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE)
    iput(ff.ip);
  1010a7:	e9 64 08 00 00       	jmp    101910 <iput>
  1010ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
  
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  1010b0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  1010b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1010bb:	89 04 24             	mov    %eax,(%esp)
  1010be:	e8 1d 1e 00 00       	call   102ee0 <pipeclose>
  1010c3:	eb c0                	jmp    101085 <fileclose+0x85>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  1010c5:	c7 04 24 4a 67 10 00 	movl   $0x10674a,(%esp)
  1010cc:	e8 df f8 ff ff       	call   1009b0 <panic>
  1010d1:	eb 0d                	jmp    1010e0 <fileinit>
  1010d3:	90                   	nop
  1010d4:	90                   	nop
  1010d5:	90                   	nop
  1010d6:	90                   	nop
  1010d7:	90                   	nop
  1010d8:	90                   	nop
  1010d9:	90                   	nop
  1010da:	90                   	nop
  1010db:	90                   	nop
  1010dc:	90                   	nop
  1010dd:	90                   	nop
  1010de:	90                   	nop
  1010df:	90                   	nop

001010e0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
  1010e0:	55                   	push   %ebp
  1010e1:	89 e5                	mov    %esp,%ebp
  1010e3:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
  1010e6:	c7 44 24 04 54 67 10 	movl   $0x106754,0x4(%esp)
  1010ed:	00 
  1010ee:	c7 04 24 e0 a0 10 00 	movl   $0x10a0e0,(%esp)
  1010f5:	e8 d6 2a 00 00       	call   103bd0 <initlock>
}
  1010fa:	c9                   	leave  
  1010fb:	c3                   	ret    
  1010fc:	90                   	nop
  1010fd:	90                   	nop
  1010fe:	90                   	nop
  1010ff:	90                   	nop

00101100 <stati>:
}

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
  101100:	55                   	push   %ebp
  101101:	89 e5                	mov    %esp,%ebp
  101103:	8b 55 08             	mov    0x8(%ebp),%edx
  101106:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
  101109:	8b 0a                	mov    (%edx),%ecx
  10110b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
  10110e:	8b 4a 04             	mov    0x4(%edx),%ecx
  101111:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
  101114:	0f b7 4a 10          	movzwl 0x10(%edx),%ecx
  101118:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
  10111b:	0f b7 4a 16          	movzwl 0x16(%edx),%ecx
  10111f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
  101123:	8b 52 18             	mov    0x18(%edx),%edx
  101126:	89 50 10             	mov    %edx,0x10(%eax)
}
  101129:	5d                   	pop    %ebp
  10112a:	c3                   	ret    
  10112b:	90                   	nop
  10112c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00101130 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
  101130:	55                   	push   %ebp
  101131:	89 e5                	mov    %esp,%ebp
  101133:	53                   	push   %ebx
  101134:	83 ec 14             	sub    $0x14,%esp
  101137:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
  10113a:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101141:	e8 1a 2c 00 00       	call   103d60 <acquire>
  ip->ref++;
  101146:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
  10114a:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101151:	e8 ba 2b 00 00       	call   103d10 <release>
  return ip;
}
  101156:	89 d8                	mov    %ebx,%eax
  101158:	83 c4 14             	add    $0x14,%esp
  10115b:	5b                   	pop    %ebx
  10115c:	5d                   	pop    %ebp
  10115d:	c3                   	ret    
  10115e:	66 90                	xchg   %ax,%ax

00101160 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
{
  101160:	55                   	push   %ebp
  101161:	89 e5                	mov    %esp,%ebp
  101163:	57                   	push   %edi
  101164:	89 d7                	mov    %edx,%edi
  101166:	56                   	push   %esi
}

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
  101167:	31 f6                	xor    %esi,%esi
{
  101169:	53                   	push   %ebx
  10116a:	89 c3                	mov    %eax,%ebx
  10116c:	83 ec 2c             	sub    $0x2c,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
  10116f:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101176:	e8 e5 2b 00 00       	call   103d60 <acquire>
}

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
  10117b:	b8 14 ab 10 00       	mov    $0x10ab14,%eax
  101180:	eb 14                	jmp    101196 <iget+0x36>
  101182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
  101188:	85 f6                	test   %esi,%esi
  10118a:	74 3c                	je     1011c8 <iget+0x68>

  acquire(&icache.lock);

  // Try for cached inode.
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
  10118c:	83 c0 50             	add    $0x50,%eax
  10118f:	3d b4 ba 10 00       	cmp    $0x10bab4,%eax
  101194:	74 42                	je     1011d8 <iget+0x78>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
  101196:	8b 48 08             	mov    0x8(%eax),%ecx
  101199:	85 c9                	test   %ecx,%ecx
  10119b:	7e eb                	jle    101188 <iget+0x28>
  10119d:	39 18                	cmp    %ebx,(%eax)
  10119f:	75 e7                	jne    101188 <iget+0x28>
  1011a1:	39 78 04             	cmp    %edi,0x4(%eax)
  1011a4:	75 e2                	jne    101188 <iget+0x28>
      ip->ref++;
  1011a6:	83 c1 01             	add    $0x1,%ecx
  1011a9:	89 48 08             	mov    %ecx,0x8(%eax)
      release(&icache.lock);
  1011ac:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1011b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1011b6:	e8 55 2b 00 00       	call   103d10 <release>
      return ip;
  1011bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);

  return ip;
}
  1011be:	83 c4 2c             	add    $0x2c,%esp
  1011c1:	5b                   	pop    %ebx
  1011c2:	5e                   	pop    %esi
  1011c3:	5f                   	pop    %edi
  1011c4:	5d                   	pop    %ebp
  1011c5:	c3                   	ret    
  1011c6:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
  1011c8:	85 c9                	test   %ecx,%ecx
  1011ca:	0f 44 f0             	cmove  %eax,%esi

  acquire(&icache.lock);

  // Try for cached inode.
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
  1011cd:	83 c0 50             	add    $0x50,%eax
  1011d0:	3d b4 ba 10 00       	cmp    $0x10bab4,%eax
  1011d5:	75 bf                	jne    101196 <iget+0x36>
  1011d7:	90                   	nop
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Allocate fresh inode.
  if(empty == 0)
  1011d8:	85 f6                	test   %esi,%esi
  1011da:	74 29                	je     101205 <iget+0xa5>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
  1011dc:	89 1e                	mov    %ebx,(%esi)
  ip->inum = inum;
  1011de:	89 7e 04             	mov    %edi,0x4(%esi)
  ip->ref = 1;
  1011e1:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->flags = 0;
  1011e8:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
  release(&icache.lock);
  1011ef:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1011f6:	e8 15 2b 00 00       	call   103d10 <release>

  return ip;
}
  1011fb:	83 c4 2c             	add    $0x2c,%esp
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);
  1011fe:	89 f0                	mov    %esi,%eax

  return ip;
}
  101200:	5b                   	pop    %ebx
  101201:	5e                   	pop    %esi
  101202:	5f                   	pop    %edi
  101203:	5d                   	pop    %ebp
  101204:	c3                   	ret    
      empty = ip;
  }

  // Allocate fresh inode.
  if(empty == 0)
    panic("iget: no inodes");
  101205:	c7 04 24 5b 67 10 00 	movl   $0x10675b,(%esp)
  10120c:	e8 9f f7 ff ff       	call   1009b0 <panic>
  101211:	eb 0d                	jmp    101220 <readsb>
  101213:	90                   	nop
  101214:	90                   	nop
  101215:	90                   	nop
  101216:	90                   	nop
  101217:	90                   	nop
  101218:	90                   	nop
  101219:	90                   	nop
  10121a:	90                   	nop
  10121b:	90                   	nop
  10121c:	90                   	nop
  10121d:	90                   	nop
  10121e:	90                   	nop
  10121f:	90                   	nop

00101220 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
static void
readsb(int dev, struct superblock *sb)
{
  101220:	55                   	push   %ebp
  101221:	89 e5                	mov    %esp,%ebp
  101223:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
  101226:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10122d:	00 
static void itrunc(struct inode*);

// Read the super block.
static void
readsb(int dev, struct superblock *sb)
{
  10122e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  101231:	89 75 fc             	mov    %esi,-0x4(%ebp)
  101234:	89 d6                	mov    %edx,%esi
  struct buf *bp;
  
  bp = bread(dev, 1);
  101236:	89 04 24             	mov    %eax,(%esp)
  101239:	e8 72 ef ff ff       	call   1001b0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
  10123e:	89 34 24             	mov    %esi,(%esp)
  101241:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
  101248:	00 
static void
readsb(int dev, struct superblock *sb)
{
  struct buf *bp;
  
  bp = bread(dev, 1);
  101249:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
  10124b:	83 c0 18             	add    $0x18,%eax
  10124e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101252:	e8 29 2c 00 00       	call   103e80 <memmove>
  brelse(bp);
  101257:	89 1c 24             	mov    %ebx,(%esp)
  10125a:	e8 a1 ee ff ff       	call   100100 <brelse>
}
  10125f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  101262:	8b 75 fc             	mov    -0x4(%ebp),%esi
  101265:	89 ec                	mov    %ebp,%esp
  101267:	5d                   	pop    %ebp
  101268:	c3                   	ret    
  101269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00101270 <balloc>:
// Blocks. 

// Allocate a disk block.
static uint
balloc(uint dev)
{
  101270:	55                   	push   %ebp
  101271:	89 e5                	mov    %esp,%ebp
  101273:	57                   	push   %edi
  101274:	56                   	push   %esi
  101275:	53                   	push   %ebx
  101276:	83 ec 3c             	sub    $0x3c,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  101279:	8d 55 dc             	lea    -0x24(%ebp),%edx
// Blocks. 

// Allocate a disk block.
static uint
balloc(uint dev)
{
  10127c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  10127f:	e8 9c ff ff ff       	call   101220 <readsb>
  for(b = 0; b < sb.size; b += BPB){
  101284:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101287:	85 c0                	test   %eax,%eax
  101289:	0f 84 9c 00 00 00    	je     10132b <balloc+0xbb>
  10128f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    bp = bread(dev, BBLOCK(b, sb.ninodes));
  101296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101299:	31 db                	xor    %ebx,%ebx
  10129b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10129e:	c1 e8 03             	shr    $0x3,%eax
  1012a1:	c1 fa 0c             	sar    $0xc,%edx
  1012a4:	8d 44 10 03          	lea    0x3(%eax,%edx,1),%eax
  1012a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1012ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1012af:	89 04 24             	mov    %eax,(%esp)
  1012b2:	e8 f9 ee ff ff       	call   1001b0 <bread>
  1012b7:	89 c6                	mov    %eax,%esi
  1012b9:	eb 10                	jmp    1012cb <balloc+0x5b>
  1012bb:	90                   	nop
  1012bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(bi = 0; bi < BPB; bi++){
  1012c0:	83 c3 01             	add    $0x1,%ebx
  1012c3:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  1012c9:	74 45                	je     101310 <balloc+0xa0>
      m = 1 << (bi % 8);
  1012cb:	89 d9                	mov    %ebx,%ecx
  1012cd:	b8 01 00 00 00       	mov    $0x1,%eax
  1012d2:	83 e1 07             	and    $0x7,%ecx
  1012d5:	d3 e0                	shl    %cl,%eax
  1012d7:	89 c1                	mov    %eax,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
  1012d9:	89 d8                	mov    %ebx,%eax
  1012db:	c1 f8 03             	sar    $0x3,%eax
  1012de:	0f b6 54 06 18       	movzbl 0x18(%esi,%eax,1),%edx
  1012e3:	0f b6 fa             	movzbl %dl,%edi
  1012e6:	85 cf                	test   %ecx,%edi
  1012e8:	75 d6                	jne    1012c0 <balloc+0x50>
        bp->data[bi/8] |= m;  // Mark block in use on disk.
  1012ea:	09 d1                	or     %edx,%ecx
  1012ec:	88 4c 06 18          	mov    %cl,0x18(%esi,%eax,1)
        bwrite(bp);
  1012f0:	89 34 24             	mov    %esi,(%esp)
  1012f3:	e8 88 ee ff ff       	call   100180 <bwrite>
        brelse(bp);
  1012f8:	89 34 24             	mov    %esi,(%esp)
  1012fb:	e8 00 ee ff ff       	call   100100 <brelse>
  101300:	8b 45 d4             	mov    -0x2c(%ebp),%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
  101303:	83 c4 3c             	add    $0x3c,%esp
    for(bi = 0; bi < BPB; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use on disk.
        bwrite(bp);
        brelse(bp);
  101306:	8d 04 03             	lea    (%ebx,%eax,1),%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
  101309:	5b                   	pop    %ebx
  10130a:	5e                   	pop    %esi
  10130b:	5f                   	pop    %edi
  10130c:	5d                   	pop    %ebp
  10130d:	c3                   	ret    
  10130e:	66 90                	xchg   %ax,%ax
        bwrite(bp);
        brelse(bp);
        return b + bi;
      }
    }
    brelse(bp);
  101310:	89 34 24             	mov    %esi,(%esp)
  101313:	e8 e8 ed ff ff       	call   100100 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
  101318:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
  10131f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  101322:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  101325:	0f 87 6b ff ff ff    	ja     101296 <balloc+0x26>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
  10132b:	c7 04 24 6b 67 10 00 	movl   $0x10676b,(%esp)
  101332:	e8 79 f6 ff ff       	call   1009b0 <panic>
  101337:	89 f6                	mov    %esi,%esi
  101339:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101340 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
  101340:	55                   	push   %ebp
  101341:	89 e5                	mov    %esp,%ebp
  101343:	83 ec 38             	sub    $0x38,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
  101346:	83 fa 0b             	cmp    $0xb,%edx

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
  101349:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  10134c:	89 c3                	mov    %eax,%ebx
  10134e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  101351:	89 7d fc             	mov    %edi,-0x4(%ebp)
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
  101354:	77 1a                	ja     101370 <bmap+0x30>
    if((addr = ip->addrs[bn]) == 0)
  101356:	8d 7a 04             	lea    0x4(%edx),%edi
  101359:	8b 44 b8 0c          	mov    0xc(%eax,%edi,4),%eax
  10135d:	85 c0                	test   %eax,%eax
  10135f:	74 5f                	je     1013c0 <bmap+0x80>
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
  101361:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  101364:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101367:	8b 7d fc             	mov    -0x4(%ebp),%edi
  10136a:	89 ec                	mov    %ebp,%esp
  10136c:	5d                   	pop    %ebp
  10136d:	c3                   	ret    
  10136e:	66 90                	xchg   %ax,%ax
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
  101370:	8d 7a f4             	lea    -0xc(%edx),%edi

  if(bn < NINDIRECT){
  101373:	83 ff 7f             	cmp    $0x7f,%edi
  101376:	77 64                	ja     1013dc <bmap+0x9c>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
  101378:	8b 40 4c             	mov    0x4c(%eax),%eax
  10137b:	85 c0                	test   %eax,%eax
  10137d:	74 51                	je     1013d0 <bmap+0x90>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  10137f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101383:	8b 03                	mov    (%ebx),%eax
  101385:	89 04 24             	mov    %eax,(%esp)
  101388:	e8 23 ee ff ff       	call   1001b0 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  10138d:	8d 7c b8 18          	lea    0x18(%eax,%edi,4),%edi

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
  101391:	89 c6                	mov    %eax,%esi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
  101393:	8b 07                	mov    (%edi),%eax
  101395:	85 c0                	test   %eax,%eax
  101397:	75 17                	jne    1013b0 <bmap+0x70>
      a[bn] = addr = balloc(ip->dev);
  101399:	8b 03                	mov    (%ebx),%eax
  10139b:	e8 d0 fe ff ff       	call   101270 <balloc>
  1013a0:	89 07                	mov    %eax,(%edi)
      bwrite(bp);
  1013a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1013a5:	89 34 24             	mov    %esi,(%esp)
  1013a8:	e8 d3 ed ff ff       	call   100180 <bwrite>
  1013ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    }
    brelse(bp);
  1013b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1013b3:	89 34 24             	mov    %esi,(%esp)
  1013b6:	e8 45 ed ff ff       	call   100100 <brelse>
    return addr;
  1013bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1013be:	eb a1                	jmp    101361 <bmap+0x21>
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
  1013c0:	8b 03                	mov    (%ebx),%eax
  1013c2:	e8 a9 fe ff ff       	call   101270 <balloc>
  1013c7:	89 44 bb 0c          	mov    %eax,0xc(%ebx,%edi,4)
  1013cb:	eb 94                	jmp    101361 <bmap+0x21>
  1013cd:	8d 76 00             	lea    0x0(%esi),%esi
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
  1013d0:	8b 03                	mov    (%ebx),%eax
  1013d2:	e8 99 fe ff ff       	call   101270 <balloc>
  1013d7:	89 43 4c             	mov    %eax,0x4c(%ebx)
  1013da:	eb a3                	jmp    10137f <bmap+0x3f>
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
  1013dc:	c7 04 24 81 67 10 00 	movl   $0x106781,(%esp)
  1013e3:	e8 c8 f5 ff ff       	call   1009b0 <panic>
  1013e8:	90                   	nop
  1013e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001013f0 <readi>:
}

// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
  1013f0:	55                   	push   %ebp
  1013f1:	89 e5                	mov    %esp,%ebp
  1013f3:	83 ec 38             	sub    $0x38,%esp
  1013f6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1013f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  1013fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1013ff:	8b 4d 14             	mov    0x14(%ebp),%ecx
  101402:	89 7d fc             	mov    %edi,-0x4(%ebp)
  101405:	8b 75 10             	mov    0x10(%ebp),%esi
  101408:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
  10140b:	66 83 7b 10 03       	cmpw   $0x3,0x10(%ebx)
  101410:	74 1e                	je     101430 <readi+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
  101412:	8b 43 18             	mov    0x18(%ebx),%eax
  101415:	39 f0                	cmp    %esi,%eax
  101417:	73 3f                	jae    101458 <readi+0x68>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
  101419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10141e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  101421:	8b 75 f8             	mov    -0x8(%ebp),%esi
  101424:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101427:	89 ec                	mov    %ebp,%esp
  101429:	5d                   	pop    %ebp
  10142a:	c3                   	ret    
  10142b:	90                   	nop
  10142c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
  101430:	0f b7 43 12          	movzwl 0x12(%ebx),%eax
  101434:	66 83 f8 09          	cmp    $0x9,%ax
  101438:	77 df                	ja     101419 <readi+0x29>
  10143a:	98                   	cwtl   
  10143b:	8b 04 c5 80 aa 10 00 	mov    0x10aa80(,%eax,8),%eax
  101442:	85 c0                	test   %eax,%eax
  101444:	74 d3                	je     101419 <readi+0x29>
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  101446:	89 4d 10             	mov    %ecx,0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}
  101449:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10144c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10144f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  101452:	89 ec                	mov    %ebp,%esp
  101454:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  101455:	ff e0                	jmp    *%eax
  101457:	90                   	nop
  }

  if(off > ip->size || off + n < off)
  101458:	89 ca                	mov    %ecx,%edx
  10145a:	01 f2                	add    %esi,%edx
  10145c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  10145f:	72 b8                	jb     101419 <readi+0x29>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
  101461:	89 c2                	mov    %eax,%edx
  101463:	29 f2                	sub    %esi,%edx
  101465:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  101468:	0f 42 ca             	cmovb  %edx,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  10146b:	85 c9                	test   %ecx,%ecx
  10146d:	74 7e                	je     1014ed <readi+0xfd>
  10146f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
  101476:	89 7d e0             	mov    %edi,-0x20(%ebp)
  101479:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  10147c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  101480:	89 f2                	mov    %esi,%edx
  101482:	89 d8                	mov    %ebx,%eax
  101484:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  101487:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  10148c:	e8 af fe ff ff       	call   101340 <bmap>
  101491:	89 44 24 04          	mov    %eax,0x4(%esp)
  101495:	8b 03                	mov    (%ebx),%eax
  101497:	89 04 24             	mov    %eax,(%esp)
  10149a:	e8 11 ed ff ff       	call   1001b0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
  10149f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1014a2:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  1014a5:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  1014a7:	89 f0                	mov    %esi,%eax
  1014a9:	25 ff 01 00 00       	and    $0x1ff,%eax
  1014ae:	29 c7                	sub    %eax,%edi
  1014b0:	39 cf                	cmp    %ecx,%edi
  1014b2:	0f 47 f9             	cmova  %ecx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
  1014b5:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  1014b9:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
  1014bb:	89 7c 24 08          	mov    %edi,0x8(%esp)
  1014bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1014c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1014c6:	89 04 24             	mov    %eax,(%esp)
  1014c9:	89 55 d8             	mov    %edx,-0x28(%ebp)
  1014cc:	e8 af 29 00 00       	call   103e80 <memmove>
    brelse(bp);
  1014d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1014d4:	89 14 24             	mov    %edx,(%esp)
  1014d7:	e8 24 ec ff ff       	call   100100 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
  1014dc:	01 7d e4             	add    %edi,-0x1c(%ebp)
  1014df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1014e2:	01 7d e0             	add    %edi,-0x20(%ebp)
  1014e5:	39 55 dc             	cmp    %edx,-0x24(%ebp)
  1014e8:	77 96                	ja     101480 <readi+0x90>
  1014ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
  1014ed:	89 c8                	mov    %ecx,%eax
  1014ef:	e9 2a ff ff ff       	jmp    10141e <readi+0x2e>
  1014f4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1014fa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00101500 <iupdate>:
}

// Copy inode, which has changed, from memory to disk.
void
iupdate(struct inode *ip)
{
  101500:	55                   	push   %ebp
  101501:	89 e5                	mov    %esp,%ebp
  101503:	56                   	push   %esi
  101504:	53                   	push   %ebx
  101505:	83 ec 10             	sub    $0x10,%esp
  101508:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
  10150b:	8b 43 04             	mov    0x4(%ebx),%eax
  10150e:	c1 e8 03             	shr    $0x3,%eax
  101511:	83 c0 02             	add    $0x2,%eax
  101514:	89 44 24 04          	mov    %eax,0x4(%esp)
  101518:	8b 03                	mov    (%ebx),%eax
  10151a:	89 04 24             	mov    %eax,(%esp)
  10151d:	e8 8e ec ff ff       	call   1001b0 <bread>
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  101522:	0f b7 53 10          	movzwl 0x10(%ebx),%edx
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
  101526:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  101528:	8b 43 04             	mov    0x4(%ebx),%eax
  10152b:	83 e0 07             	and    $0x7,%eax
  10152e:	c1 e0 06             	shl    $0x6,%eax
  101531:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
  dip->type = ip->type;
  101535:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
  101538:	0f b7 53 12          	movzwl 0x12(%ebx),%edx
  10153c:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
  101540:	0f b7 53 14          	movzwl 0x14(%ebx),%edx
  101544:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
  101548:	0f b7 53 16          	movzwl 0x16(%ebx),%edx
  10154c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
  101550:	8b 53 18             	mov    0x18(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  101553:	83 c3 1c             	add    $0x1c,%ebx
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  101556:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  101559:	83 c0 0c             	add    $0xc,%eax
  10155c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101560:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
  101567:	00 
  101568:	89 04 24             	mov    %eax,(%esp)
  10156b:	e8 10 29 00 00       	call   103e80 <memmove>
  bwrite(bp);
  101570:	89 34 24             	mov    %esi,(%esp)
  101573:	e8 08 ec ff ff       	call   100180 <bwrite>
  brelse(bp);
  101578:	89 75 08             	mov    %esi,0x8(%ebp)
}
  10157b:	83 c4 10             	add    $0x10,%esp
  10157e:	5b                   	pop    %ebx
  10157f:	5e                   	pop    %esi
  101580:	5d                   	pop    %ebp
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  bwrite(bp);
  brelse(bp);
  101581:	e9 7a eb ff ff       	jmp    100100 <brelse>
  101586:	8d 76 00             	lea    0x0(%esi),%esi
  101589:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101590 <writei>:
}

// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
  101590:	55                   	push   %ebp
  101591:	89 e5                	mov    %esp,%ebp
  101593:	83 ec 38             	sub    $0x38,%esp
  101596:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  101599:	8b 5d 08             	mov    0x8(%ebp),%ebx
  10159c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10159f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  1015a2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  1015a5:	8b 75 10             	mov    0x10(%ebp),%esi
  1015a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
  1015ab:	66 83 7b 10 03       	cmpw   $0x3,0x10(%ebx)
  1015b0:	74 1e                	je     1015d0 <writei+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
  1015b2:	39 73 18             	cmp    %esi,0x18(%ebx)
  1015b5:	73 41                	jae    1015f8 <writei+0x68>

  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
  1015b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1015bc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1015bf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1015c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1015c5:	89 ec                	mov    %ebp,%esp
  1015c7:	5d                   	pop    %ebp
  1015c8:	c3                   	ret    
  1015c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
  1015d0:	0f b7 43 12          	movzwl 0x12(%ebx),%eax
  1015d4:	66 83 f8 09          	cmp    $0x9,%ax
  1015d8:	77 dd                	ja     1015b7 <writei+0x27>
  1015da:	98                   	cwtl   
  1015db:	8b 04 c5 84 aa 10 00 	mov    0x10aa84(,%eax,8),%eax
  1015e2:	85 c0                	test   %eax,%eax
  1015e4:	74 d1                	je     1015b7 <writei+0x27>
      return -1;
    return devsw[ip->major].write(ip, src, n);
  1015e6:	89 4d 10             	mov    %ecx,0x10(%ebp)
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
  1015e9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  1015ec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  1015ef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1015f2:	89 ec                	mov    %ebp,%esp
  1015f4:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  1015f5:	ff e0                	jmp    *%eax
  1015f7:	90                   	nop
  }

  if(off > ip->size || off + n < off)
  1015f8:	89 c8                	mov    %ecx,%eax
  1015fa:	01 f0                	add    %esi,%eax
  1015fc:	72 b9                	jb     1015b7 <writei+0x27>
    return -1;
  if(off + n > MAXFILE*BSIZE)
  1015fe:	3d 00 18 01 00       	cmp    $0x11800,%eax
  101603:	76 07                	jbe    10160c <writei+0x7c>
    n = MAXFILE*BSIZE - off;
  101605:	b9 00 18 01 00       	mov    $0x11800,%ecx
  10160a:	29 f1                	sub    %esi,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  10160c:	85 c9                	test   %ecx,%ecx
  10160e:	0f 84 91 00 00 00    	je     1016a5 <writei+0x115>
  101614:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
  10161b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  10161e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  101621:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  101628:	89 f2                	mov    %esi,%edx
  10162a:	89 d8                	mov    %ebx,%eax
  10162c:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  10162f:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  101634:	e8 07 fd ff ff       	call   101340 <bmap>
  101639:	89 44 24 04          	mov    %eax,0x4(%esp)
  10163d:	8b 03                	mov    (%ebx),%eax
  10163f:	89 04 24             	mov    %eax,(%esp)
  101642:	e8 69 eb ff ff       	call   1001b0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
  101647:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10164a:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
  10164d:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
  10164f:	89 f0                	mov    %esi,%eax
  101651:	25 ff 01 00 00       	and    $0x1ff,%eax
  101656:	29 c7                	sub    %eax,%edi
  101658:	39 cf                	cmp    %ecx,%edi
  10165a:	0f 47 f9             	cmova  %ecx,%edi
    memmove(bp->data + off%BSIZE, src, m);
  10165d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  101661:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  101664:	8d 44 02 18          	lea    0x18(%edx,%eax,1),%eax
  101668:	89 04 24             	mov    %eax,(%esp)
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  10166b:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(bp->data + off%BSIZE, src, m);
  10166d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  101671:	89 55 d8             	mov    %edx,-0x28(%ebp)
  101674:	e8 07 28 00 00       	call   103e80 <memmove>
    bwrite(bp);
  101679:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10167c:	89 14 24             	mov    %edx,(%esp)
  10167f:	e8 fc ea ff ff       	call   100180 <bwrite>
    brelse(bp);
  101684:	8b 55 d8             	mov    -0x28(%ebp),%edx
  101687:	89 14 24             	mov    %edx,(%esp)
  10168a:	e8 71 ea ff ff       	call   100100 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    n = MAXFILE*BSIZE - off;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
  10168f:	01 7d e4             	add    %edi,-0x1c(%ebp)
  101692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101695:	01 7d e0             	add    %edi,-0x20(%ebp)
  101698:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10169b:	77 8b                	ja     101628 <writei+0x98>
    memmove(bp->data + off%BSIZE, src, m);
    bwrite(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
  10169d:	3b 73 18             	cmp    0x18(%ebx),%esi
  1016a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1016a3:	77 07                	ja     1016ac <writei+0x11c>
    ip->size = off;
    iupdate(ip);
  }
  return n;
  1016a5:	89 c8                	mov    %ecx,%eax
  1016a7:	e9 10 ff ff ff       	jmp    1015bc <writei+0x2c>
    bwrite(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
    ip->size = off;
  1016ac:	89 73 18             	mov    %esi,0x18(%ebx)
    iupdate(ip);
  1016af:	89 1c 24             	mov    %ebx,(%esp)
  1016b2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1016b5:	e8 46 fe ff ff       	call   101500 <iupdate>
  1016ba:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  }
  return n;
  1016bd:	89 c8                	mov    %ecx,%eax
  1016bf:	e9 f8 fe ff ff       	jmp    1015bc <writei+0x2c>
  1016c4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1016ca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001016d0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
  1016d0:	55                   	push   %ebp
  1016d1:	89 e5                	mov    %esp,%ebp
  1016d3:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
  1016d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1016d9:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  1016e0:	00 
  1016e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1016e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1016e8:	89 04 24             	mov    %eax,(%esp)
  1016eb:	e8 00 28 00 00       	call   103ef0 <strncmp>
}
  1016f0:	c9                   	leave  
  1016f1:	c3                   	ret    
  1016f2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1016f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101700 <dirlookup>:
// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
  101700:	55                   	push   %ebp
  101701:	89 e5                	mov    %esp,%ebp
  101703:	57                   	push   %edi
  101704:	56                   	push   %esi
  101705:	53                   	push   %ebx
  101706:	83 ec 3c             	sub    $0x3c,%esp
  101709:	8b 45 08             	mov    0x8(%ebp),%eax
  10170c:	8b 55 10             	mov    0x10(%ebp),%edx
  10170f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  101712:	89 45 dc             	mov    %eax,-0x24(%ebp)
  101715:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  uint off, inum;
  struct buf *bp;
  struct dirent *de;

  if(dp->type != T_DIR)
  101718:	66 83 78 10 01       	cmpw   $0x1,0x10(%eax)
  10171d:	0f 85 d0 00 00 00    	jne    1017f3 <dirlookup+0xf3>
    panic("dirlookup not DIR");
  101723:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  for(off = 0; off < dp->size; off += BSIZE){
  10172a:	8b 48 18             	mov    0x18(%eax),%ecx
  10172d:	85 c9                	test   %ecx,%ecx
  10172f:	0f 84 b4 00 00 00    	je     1017e9 <dirlookup+0xe9>
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
  101735:	8b 55 e0             	mov    -0x20(%ebp),%edx
  101738:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10173b:	c1 ea 09             	shr    $0x9,%edx
  10173e:	e8 fd fb ff ff       	call   101340 <bmap>
  101743:	89 44 24 04          	mov    %eax,0x4(%esp)
  101747:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10174a:	8b 01                	mov    (%ecx),%eax
  10174c:	89 04 24             	mov    %eax,(%esp)
  10174f:	e8 5c ea ff ff       	call   1001b0 <bread>
  101754:	89 45 e4             	mov    %eax,-0x1c(%ebp)

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
  101757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
  10175a:	83 c0 18             	add    $0x18,%eax
  10175d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  101760:	89 c6                	mov    %eax,%esi

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
// Caller must have already locked dp.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
  101762:	81 c7 18 02 00 00    	add    $0x218,%edi
  101768:	eb 0d                	jmp    101777 <dirlookup+0x77>
  10176a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
        de < (struct dirent*)(bp->data + BSIZE);
        de++){
  101770:	83 c6 10             	add    $0x10,%esi
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
    bp = bread(dp->dev, bmap(dp, off / BSIZE));
    for(de = (struct dirent*)bp->data;
  101773:	39 fe                	cmp    %edi,%esi
  101775:	74 51                	je     1017c8 <dirlookup+0xc8>
        de < (struct dirent*)(bp->data + BSIZE);
        de++){
      if(de->inum == 0)
  101777:	66 83 3e 00          	cmpw   $0x0,(%esi)
  10177b:	74 f3                	je     101770 <dirlookup+0x70>
        continue;
      if(namecmp(name, de->name) == 0){
  10177d:	8d 46 02             	lea    0x2(%esi),%eax
  101780:	89 44 24 04          	mov    %eax,0x4(%esp)
  101784:	89 1c 24             	mov    %ebx,(%esp)
  101787:	e8 44 ff ff ff       	call   1016d0 <namecmp>
  10178c:	85 c0                	test   %eax,%eax
  10178e:	75 e0                	jne    101770 <dirlookup+0x70>
        // entry matches path element
        if(poff)
  101790:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  101793:	85 d2                	test   %edx,%edx
  101795:	74 0e                	je     1017a5 <dirlookup+0xa5>
          *poff = off + (uchar*)de - bp->data;
  101797:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10179a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10179d:	8d 04 06             	lea    (%esi,%eax,1),%eax
  1017a0:	2b 45 d8             	sub    -0x28(%ebp),%eax
  1017a3:	89 02                	mov    %eax,(%edx)
        inum = de->inum;
        brelse(bp);
  1017a5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
        continue;
      if(namecmp(name, de->name) == 0){
        // entry matches path element
        if(poff)
          *poff = off + (uchar*)de - bp->data;
        inum = de->inum;
  1017a8:	0f b7 1e             	movzwl (%esi),%ebx
        brelse(bp);
  1017ab:	89 0c 24             	mov    %ecx,(%esp)
  1017ae:	e8 4d e9 ff ff       	call   100100 <brelse>
        return iget(dp->dev, inum);
  1017b3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1017b6:	89 da                	mov    %ebx,%edx
  1017b8:	8b 01                	mov    (%ecx),%eax
      }
    }
    brelse(bp);
  }
  return 0;
}
  1017ba:	83 c4 3c             	add    $0x3c,%esp
  1017bd:	5b                   	pop    %ebx
  1017be:	5e                   	pop    %esi
  1017bf:	5f                   	pop    %edi
  1017c0:	5d                   	pop    %ebp
        // entry matches path element
        if(poff)
          *poff = off + (uchar*)de - bp->data;
        inum = de->inum;
        brelse(bp);
        return iget(dp->dev, inum);
  1017c1:	e9 9a f9 ff ff       	jmp    101160 <iget>
  1017c6:	66 90                	xchg   %ax,%ax
      }
    }
    brelse(bp);
  1017c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1017cb:	89 04 24             	mov    %eax,(%esp)
  1017ce:	e8 2d e9 ff ff       	call   100100 <brelse>
  struct dirent *de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += BSIZE){
  1017d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1017d6:	81 45 e0 00 02 00 00 	addl   $0x200,-0x20(%ebp)
  1017dd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1017e0:	39 4a 18             	cmp    %ecx,0x18(%edx)
  1017e3:	0f 87 4c ff ff ff    	ja     101735 <dirlookup+0x35>
      }
    }
    brelse(bp);
  }
  return 0;
}
  1017e9:	83 c4 3c             	add    $0x3c,%esp
  1017ec:	31 c0                	xor    %eax,%eax
  1017ee:	5b                   	pop    %ebx
  1017ef:	5e                   	pop    %esi
  1017f0:	5f                   	pop    %edi
  1017f1:	5d                   	pop    %ebp
  1017f2:	c3                   	ret    
  uint off, inum;
  struct buf *bp;
  struct dirent *de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
  1017f3:	c7 04 24 94 67 10 00 	movl   $0x106794,(%esp)
  1017fa:	e8 b1 f1 ff ff       	call   1009b0 <panic>
  1017ff:	90                   	nop

00101800 <iunlock>:
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  101800:	55                   	push   %ebp
  101801:	89 e5                	mov    %esp,%ebp
  101803:	53                   	push   %ebx
  101804:	83 ec 14             	sub    $0x14,%esp
  101807:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
  10180a:	85 db                	test   %ebx,%ebx
  10180c:	74 36                	je     101844 <iunlock+0x44>
  10180e:	f6 43 0c 01          	testb  $0x1,0xc(%ebx)
  101812:	74 30                	je     101844 <iunlock+0x44>
  101814:	8b 43 08             	mov    0x8(%ebx),%eax
  101817:	85 c0                	test   %eax,%eax
  101819:	7e 29                	jle    101844 <iunlock+0x44>
    panic("iunlock");

  acquire(&icache.lock);
  10181b:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101822:	e8 39 25 00 00       	call   103d60 <acquire>
  ip->flags &= ~I_BUSY;
  101827:	83 63 0c fe          	andl   $0xfffffffe,0xc(%ebx)
  wakeup(ip);
  10182b:	89 1c 24             	mov    %ebx,(%esp)
  10182e:	e8 8d 19 00 00       	call   1031c0 <wakeup>
  release(&icache.lock);
  101833:	c7 45 08 e0 aa 10 00 	movl   $0x10aae0,0x8(%ebp)
}
  10183a:	83 c4 14             	add    $0x14,%esp
  10183d:	5b                   	pop    %ebx
  10183e:	5d                   	pop    %ebp
    panic("iunlock");

  acquire(&icache.lock);
  ip->flags &= ~I_BUSY;
  wakeup(ip);
  release(&icache.lock);
  10183f:	e9 cc 24 00 00       	jmp    103d10 <release>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
    panic("iunlock");
  101844:	c7 04 24 a6 67 10 00 	movl   $0x1067a6,(%esp)
  10184b:	e8 60 f1 ff ff       	call   1009b0 <panic>

00101850 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
  101850:	55                   	push   %ebp
  101851:	89 e5                	mov    %esp,%ebp
  101853:	57                   	push   %edi
  101854:	56                   	push   %esi
  101855:	89 c6                	mov    %eax,%esi
  101857:	53                   	push   %ebx
  101858:	89 d3                	mov    %edx,%ebx
  10185a:	83 ec 2c             	sub    $0x2c,%esp
static void
bzero(int dev, int bno)
{
  struct buf *bp;
  
  bp = bread(dev, bno);
  10185d:	89 54 24 04          	mov    %edx,0x4(%esp)
  101861:	89 04 24             	mov    %eax,(%esp)
  101864:	e8 47 e9 ff ff       	call   1001b0 <bread>
  memset(bp->data, 0, BSIZE);
  101869:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  101870:	00 
  101871:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101878:	00 
static void
bzero(int dev, int bno)
{
  struct buf *bp;
  
  bp = bread(dev, bno);
  101879:	89 c7                	mov    %eax,%edi
  memset(bp->data, 0, BSIZE);
  10187b:	83 c0 18             	add    $0x18,%eax
  10187e:	89 04 24             	mov    %eax,(%esp)
  101881:	e8 7a 25 00 00       	call   103e00 <memset>
  bwrite(bp);
  101886:	89 3c 24             	mov    %edi,(%esp)
  101889:	e8 f2 e8 ff ff       	call   100180 <bwrite>
  brelse(bp);
  10188e:	89 3c 24             	mov    %edi,(%esp)
  101891:	e8 6a e8 ff ff       	call   100100 <brelse>
  struct superblock sb;
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  101896:	89 f0                	mov    %esi,%eax
  101898:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10189b:	e8 80 f9 ff ff       	call   101220 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  1018a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1018a3:	89 da                	mov    %ebx,%edx
  1018a5:	c1 ea 0c             	shr    $0xc,%edx
  1018a8:	89 34 24             	mov    %esi,(%esp)
  bi = b % BPB;
  m = 1 << (bi % 8);
  1018ab:	be 01 00 00 00       	mov    $0x1,%esi
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  1018b0:	c1 e8 03             	shr    $0x3,%eax
  1018b3:	8d 44 10 03          	lea    0x3(%eax,%edx,1),%eax
  1018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1018bb:	e8 f0 e8 ff ff       	call   1001b0 <bread>
  bi = b % BPB;
  1018c0:	89 da                	mov    %ebx,%edx
  m = 1 << (bi % 8);
  1018c2:	89 d9                	mov    %ebx,%ecx

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  1018c4:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
  1018ca:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
  1018cd:	c1 fa 03             	sar    $0x3,%edx
  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  m = 1 << (bi % 8);
  1018d0:	d3 e6                	shl    %cl,%esi
  if((bp->data[bi/8] & m) == 0)
  1018d2:	0f b6 4c 10 18       	movzbl 0x18(%eax,%edx,1),%ecx
  int bi, m;

  bzero(dev, b);

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  1018d7:	89 c7                	mov    %eax,%edi
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
  1018d9:	0f b6 c1             	movzbl %cl,%eax
  1018dc:	85 f0                	test   %esi,%eax
  1018de:	74 22                	je     101902 <bfree+0xb2>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;  // Mark block free on disk.
  1018e0:	89 f0                	mov    %esi,%eax
  1018e2:	f7 d0                	not    %eax
  1018e4:	21 c8                	and    %ecx,%eax
  1018e6:	88 44 17 18          	mov    %al,0x18(%edi,%edx,1)
  bwrite(bp);
  1018ea:	89 3c 24             	mov    %edi,(%esp)
  1018ed:	e8 8e e8 ff ff       	call   100180 <bwrite>
  brelse(bp);
  1018f2:	89 3c 24             	mov    %edi,(%esp)
  1018f5:	e8 06 e8 ff ff       	call   100100 <brelse>
}
  1018fa:	83 c4 2c             	add    $0x2c,%esp
  1018fd:	5b                   	pop    %ebx
  1018fe:	5e                   	pop    %esi
  1018ff:	5f                   	pop    %edi
  101900:	5d                   	pop    %ebp
  101901:	c3                   	ret    
  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb.ninodes));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
  101902:	c7 04 24 ae 67 10 00 	movl   $0x1067ae,(%esp)
  101909:	e8 a2 f0 ff ff       	call   1009b0 <panic>
  10190e:	66 90                	xchg   %ax,%ax

00101910 <iput>:
}

// Caller holds reference to unlocked ip.  Drop reference.
void
iput(struct inode *ip)
{
  101910:	55                   	push   %ebp
  101911:	89 e5                	mov    %esp,%ebp
  101913:	57                   	push   %edi
  101914:	56                   	push   %esi
  101915:	53                   	push   %ebx
  101916:	83 ec 2c             	sub    $0x2c,%esp
  101919:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&icache.lock);
  10191c:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101923:	e8 38 24 00 00       	call   103d60 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
  101928:	8b 46 08             	mov    0x8(%esi),%eax
  10192b:	83 f8 01             	cmp    $0x1,%eax
  10192e:	0f 85 a1 00 00 00    	jne    1019d5 <iput+0xc5>
  101934:	8b 56 0c             	mov    0xc(%esi),%edx
  101937:	f6 c2 02             	test   $0x2,%dl
  10193a:	0f 84 95 00 00 00    	je     1019d5 <iput+0xc5>
  101940:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  101945:	0f 85 8a 00 00 00    	jne    1019d5 <iput+0xc5>
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
  10194b:	f6 c2 01             	test   $0x1,%dl
  10194e:	66 90                	xchg   %ax,%ax
  101950:	0f 85 f8 00 00 00    	jne    101a4e <iput+0x13e>
      panic("iput busy");
    ip->flags |= I_BUSY;
  101956:	83 ca 01             	or     $0x1,%edx
    release(&icache.lock);
  101959:	89 f3                	mov    %esi,%ebx
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
  10195b:	89 56 0c             	mov    %edx,0xc(%esi)
  release(&icache.lock);
}

// Caller holds reference to unlocked ip.  Drop reference.
void
iput(struct inode *ip)
  10195e:	8d 7e 30             	lea    0x30(%esi),%edi
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
  101961:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101968:	e8 a3 23 00 00       	call   103d10 <release>
  10196d:	eb 08                	jmp    101977 <iput+0x67>
  10196f:	90                   	nop
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
  101970:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
  101973:	39 fb                	cmp    %edi,%ebx
  101975:	74 1c                	je     101993 <iput+0x83>
    if(ip->addrs[i]){
  101977:	8b 53 1c             	mov    0x1c(%ebx),%edx
  10197a:	85 d2                	test   %edx,%edx
  10197c:	74 f2                	je     101970 <iput+0x60>
      bfree(ip->dev, ip->addrs[i]);
  10197e:	8b 06                	mov    (%esi),%eax
  101980:	e8 cb fe ff ff       	call   101850 <bfree>
      ip->addrs[i] = 0;
  101985:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
  10198c:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
  10198f:	39 fb                	cmp    %edi,%ebx
  101991:	75 e4                	jne    101977 <iput+0x67>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
  101993:	8b 46 4c             	mov    0x4c(%esi),%eax
  101996:	85 c0                	test   %eax,%eax
  101998:	75 56                	jne    1019f0 <iput+0xe0>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  10199a:	c7 46 18 00 00 00 00 	movl   $0x0,0x18(%esi)
  iupdate(ip);
  1019a1:	89 34 24             	mov    %esi,(%esp)
  1019a4:	e8 57 fb ff ff       	call   101500 <iupdate>
    if(ip->flags & I_BUSY)
      panic("iput busy");
    ip->flags |= I_BUSY;
    release(&icache.lock);
    itrunc(ip);
    ip->type = 0;
  1019a9:	66 c7 46 10 00 00    	movw   $0x0,0x10(%esi)
    iupdate(ip);
  1019af:	89 34 24             	mov    %esi,(%esp)
  1019b2:	e8 49 fb ff ff       	call   101500 <iupdate>
    acquire(&icache.lock);
  1019b7:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  1019be:	e8 9d 23 00 00       	call   103d60 <acquire>
    ip->flags = 0;
  1019c3:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
    wakeup(ip);
  1019ca:	89 34 24             	mov    %esi,(%esp)
  1019cd:	e8 ee 17 00 00       	call   1031c0 <wakeup>
  1019d2:	8b 46 08             	mov    0x8(%esi),%eax
  }
  ip->ref--;
  1019d5:	83 e8 01             	sub    $0x1,%eax
  1019d8:	89 46 08             	mov    %eax,0x8(%esi)
  release(&icache.lock);
  1019db:	c7 45 08 e0 aa 10 00 	movl   $0x10aae0,0x8(%ebp)
}
  1019e2:	83 c4 2c             	add    $0x2c,%esp
  1019e5:	5b                   	pop    %ebx
  1019e6:	5e                   	pop    %esi
  1019e7:	5f                   	pop    %edi
  1019e8:	5d                   	pop    %ebp
    acquire(&icache.lock);
    ip->flags = 0;
    wakeup(ip);
  }
  ip->ref--;
  release(&icache.lock);
  1019e9:	e9 22 23 00 00       	jmp    103d10 <release>
  1019ee:	66 90                	xchg   %ax,%ax
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  1019f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019f4:	8b 06                	mov    (%esi),%eax
    a = (uint*)bp->data;
  1019f6:	31 db                	xor    %ebx,%ebx
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  1019f8:	89 04 24             	mov    %eax,(%esp)
  1019fb:	e8 b0 e7 ff ff       	call   1001b0 <bread>
    a = (uint*)bp->data;
  101a00:	89 c7                	mov    %eax,%edi
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
  101a02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
  101a05:	83 c7 18             	add    $0x18,%edi
  101a08:	31 c0                	xor    %eax,%eax
  101a0a:	eb 11                	jmp    101a1d <iput+0x10d>
  101a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(j = 0; j < NINDIRECT; j++){
  101a10:	83 c3 01             	add    $0x1,%ebx
  101a13:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  101a19:	89 d8                	mov    %ebx,%eax
  101a1b:	74 10                	je     101a2d <iput+0x11d>
      if(a[j])
  101a1d:	8b 14 87             	mov    (%edi,%eax,4),%edx
  101a20:	85 d2                	test   %edx,%edx
  101a22:	74 ec                	je     101a10 <iput+0x100>
        bfree(ip->dev, a[j]);
  101a24:	8b 06                	mov    (%esi),%eax
  101a26:	e8 25 fe ff ff       	call   101850 <bfree>
  101a2b:	eb e3                	jmp    101a10 <iput+0x100>
    }
    brelse(bp);
  101a2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101a30:	89 04 24             	mov    %eax,(%esp)
  101a33:	e8 c8 e6 ff ff       	call   100100 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
  101a38:	8b 56 4c             	mov    0x4c(%esi),%edx
  101a3b:	8b 06                	mov    (%esi),%eax
  101a3d:	e8 0e fe ff ff       	call   101850 <bfree>
    ip->addrs[NDIRECT] = 0;
  101a42:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  101a49:	e9 4c ff ff ff       	jmp    10199a <iput+0x8a>
{
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode is no longer used: truncate and free inode.
    if(ip->flags & I_BUSY)
      panic("iput busy");
  101a4e:	c7 04 24 c1 67 10 00 	movl   $0x1067c1,(%esp)
  101a55:	e8 56 ef ff ff       	call   1009b0 <panic>
  101a5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00101a60 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
  101a60:	55                   	push   %ebp
  101a61:	89 e5                	mov    %esp,%ebp
  101a63:	57                   	push   %edi
  101a64:	56                   	push   %esi
  101a65:	53                   	push   %ebx
  101a66:	83 ec 2c             	sub    $0x2c,%esp
  101a69:	8b 75 08             	mov    0x8(%ebp),%esi
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
  101a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  101a6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  101a76:	00 
  101a77:	89 34 24             	mov    %esi,(%esp)
  101a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a7e:	e8 7d fc ff ff       	call   101700 <dirlookup>
  101a83:	85 c0                	test   %eax,%eax
  101a85:	0f 85 89 00 00 00    	jne    101b14 <dirlink+0xb4>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101a8b:	8b 56 18             	mov    0x18(%esi),%edx
  101a8e:	85 d2                	test   %edx,%edx
  101a90:	0f 84 8d 00 00 00    	je     101b23 <dirlink+0xc3>
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
    return -1;
  101a96:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101a99:	31 db                	xor    %ebx,%ebx
  101a9b:	eb 0b                	jmp    101aa8 <dirlink+0x48>
  101a9d:	8d 76 00             	lea    0x0(%esi),%esi
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101aa0:	83 c3 10             	add    $0x10,%ebx
  101aa3:	39 5e 18             	cmp    %ebx,0x18(%esi)
  101aa6:	76 24                	jbe    101acc <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101aa8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101aaf:	00 
  101ab0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101ab4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  101ab8:	89 34 24             	mov    %esi,(%esp)
  101abb:	e8 30 f9 ff ff       	call   1013f0 <readi>
  101ac0:	83 f8 10             	cmp    $0x10,%eax
  101ac3:	75 65                	jne    101b2a <dirlink+0xca>
      panic("dirlink read");
    if(de.inum == 0)
  101ac5:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
  101aca:	75 d4                	jne    101aa0 <dirlink+0x40>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  101acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  101acf:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101ad6:	00 
  101ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101adb:	8d 45 da             	lea    -0x26(%ebp),%eax
  101ade:	89 04 24             	mov    %eax,(%esp)
  101ae1:	e8 6a 24 00 00       	call   103f50 <strncpy>
  de.inum = inum;
  101ae6:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101ae9:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  101af0:	00 
  101af1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  101af5:	89 7c 24 04          	mov    %edi,0x4(%esp)
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  101af9:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  101afd:	89 34 24             	mov    %esi,(%esp)
  101b00:	e8 8b fa ff ff       	call   101590 <writei>
  101b05:	83 f8 10             	cmp    $0x10,%eax
  101b08:	75 2c                	jne    101b36 <dirlink+0xd6>
    panic("dirlink");
  101b0a:	31 c0                	xor    %eax,%eax
  
  return 0;
}
  101b0c:	83 c4 2c             	add    $0x2c,%esp
  101b0f:	5b                   	pop    %ebx
  101b10:	5e                   	pop    %esi
  101b11:	5f                   	pop    %edi
  101b12:	5d                   	pop    %ebp
  101b13:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
  101b14:	89 04 24             	mov    %eax,(%esp)
  101b17:	e8 f4 fd ff ff       	call   101910 <iput>
  101b1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  101b21:	eb e9                	jmp    101b0c <dirlink+0xac>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
  101b23:	8d 7d d8             	lea    -0x28(%ebp),%edi
  101b26:	31 db                	xor    %ebx,%ebx
  101b28:	eb a2                	jmp    101acc <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
  101b2a:	c7 04 24 cb 67 10 00 	movl   $0x1067cb,(%esp)
  101b31:	e8 7a ee ff ff       	call   1009b0 <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
  101b36:	c7 04 24 62 6d 10 00 	movl   $0x106d62,(%esp)
  101b3d:	e8 6e ee ff ff       	call   1009b0 <panic>
  101b42:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  101b49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101b50 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  101b50:	55                   	push   %ebp
  101b51:	89 e5                	mov    %esp,%ebp
  101b53:	53                   	push   %ebx
  101b54:	83 ec 14             	sub    $0x14,%esp
  101b57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
  101b5a:	89 1c 24             	mov    %ebx,(%esp)
  101b5d:	e8 9e fc ff ff       	call   101800 <iunlock>
  iput(ip);
  101b62:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  101b65:	83 c4 14             	add    $0x14,%esp
  101b68:	5b                   	pop    %ebx
  101b69:	5d                   	pop    %ebp
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
  101b6a:	e9 a1 fd ff ff       	jmp    101910 <iput>
  101b6f:	90                   	nop

00101b70 <ialloc>:
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101b70:	55                   	push   %ebp
  101b71:	89 e5                	mov    %esp,%ebp
  101b73:	57                   	push   %edi
  101b74:	56                   	push   %esi
  101b75:	53                   	push   %ebx
  101b76:	83 ec 3c             	sub    $0x3c,%esp
  101b79:	0f b7 45 0c          	movzwl 0xc(%ebp),%eax
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101b7d:	8d 55 dc             	lea    -0x24(%ebp),%edx
static struct inode* iget(uint dev, uint inum);

// Allocate a new inode with the given type on device dev.
struct inode*
ialloc(uint dev, short type)
{
  101b80:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  101b84:	8b 45 08             	mov    0x8(%ebp),%eax
  101b87:	e8 94 f6 ff ff       	call   101220 <readsb>
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101b8c:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
  101b90:	0f 86 96 00 00 00    	jbe    101c2c <ialloc+0xbc>
  101b96:	be 01 00 00 00       	mov    $0x1,%esi
  101b9b:	bb 01 00 00 00       	mov    $0x1,%ebx
  101ba0:	eb 18                	jmp    101bba <ialloc+0x4a>
  101ba2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101ba8:	83 c3 01             	add    $0x1,%ebx
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101bab:	89 3c 24             	mov    %edi,(%esp)
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101bae:	89 de                	mov    %ebx,%esi
      dip->type = type;
      bwrite(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  101bb0:	e8 4b e5 ff ff       	call   100100 <brelse>
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){  // loop over inode blocks
  101bb5:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  101bb8:	76 72                	jbe    101c2c <ialloc+0xbc>
    bp = bread(dev, IBLOCK(inum));
  101bba:	89 f0                	mov    %esi,%eax
  101bbc:	c1 e8 03             	shr    $0x3,%eax
  101bbf:	83 c0 02             	add    $0x2,%eax
  101bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc9:	89 04 24             	mov    %eax,(%esp)
  101bcc:	e8 df e5 ff ff       	call   1001b0 <bread>
  101bd1:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
  101bd3:	89 f0                	mov    %esi,%eax
  101bd5:	83 e0 07             	and    $0x7,%eax
  101bd8:	c1 e0 06             	shl    $0x6,%eax
  101bdb:	8d 54 07 18          	lea    0x18(%edi,%eax,1),%edx
    if(dip->type == 0){  // a free inode
  101bdf:	66 83 3a 00          	cmpw   $0x0,(%edx)
  101be3:	75 c3                	jne    101ba8 <ialloc+0x38>
      memset(dip, 0, sizeof(*dip));
  101be5:	89 14 24             	mov    %edx,(%esp)
  101be8:	89 55 d0             	mov    %edx,-0x30(%ebp)
  101beb:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
  101bf2:	00 
  101bf3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101bfa:	00 
  101bfb:	e8 00 22 00 00       	call   103e00 <memset>
      dip->type = type;
  101c00:	8b 55 d0             	mov    -0x30(%ebp),%edx
  101c03:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101c07:	66 89 02             	mov    %ax,(%edx)
      bwrite(bp);   // mark it allocated on the disk
  101c0a:	89 3c 24             	mov    %edi,(%esp)
  101c0d:	e8 6e e5 ff ff       	call   100180 <bwrite>
      brelse(bp);
  101c12:	89 3c 24             	mov    %edi,(%esp)
  101c15:	e8 e6 e4 ff ff       	call   100100 <brelse>
      return iget(dev, inum);
  101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1d:	89 f2                	mov    %esi,%edx
  101c1f:	e8 3c f5 ff ff       	call   101160 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
  101c24:	83 c4 3c             	add    $0x3c,%esp
  101c27:	5b                   	pop    %ebx
  101c28:	5e                   	pop    %esi
  101c29:	5f                   	pop    %edi
  101c2a:	5d                   	pop    %ebp
  101c2b:	c3                   	ret    
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
  101c2c:	c7 04 24 d8 67 10 00 	movl   $0x1067d8,(%esp)
  101c33:	e8 78 ed ff ff       	call   1009b0 <panic>
  101c38:	90                   	nop
  101c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00101c40 <ilock>:
}

// Lock the given inode.
void
ilock(struct inode *ip)
{
  101c40:	55                   	push   %ebp
  101c41:	89 e5                	mov    %esp,%ebp
  101c43:	56                   	push   %esi
  101c44:	53                   	push   %ebx
  101c45:	83 ec 10             	sub    $0x10,%esp
  101c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
  101c4b:	85 db                	test   %ebx,%ebx
  101c4d:	0f 84 e5 00 00 00    	je     101d38 <ilock+0xf8>
  101c53:	8b 4b 08             	mov    0x8(%ebx),%ecx
  101c56:	85 c9                	test   %ecx,%ecx
  101c58:	0f 8e da 00 00 00    	jle    101d38 <ilock+0xf8>
    panic("ilock");

  acquire(&icache.lock);
  101c5e:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101c65:	e8 f6 20 00 00       	call   103d60 <acquire>
  while(ip->flags & I_BUSY)
  101c6a:	8b 43 0c             	mov    0xc(%ebx),%eax
  101c6d:	a8 01                	test   $0x1,%al
  101c6f:	74 1e                	je     101c8f <ilock+0x4f>
  101c71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sleep(ip, &icache.lock);
  101c78:	c7 44 24 04 e0 aa 10 	movl   $0x10aae0,0x4(%esp)
  101c7f:	00 
  101c80:	89 1c 24             	mov    %ebx,(%esp)
  101c83:	e8 58 16 00 00       	call   1032e0 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
  101c88:	8b 43 0c             	mov    0xc(%ebx),%eax
  101c8b:	a8 01                	test   $0x1,%al
  101c8d:	75 e9                	jne    101c78 <ilock+0x38>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  101c8f:	83 c8 01             	or     $0x1,%eax
  101c92:	89 43 0c             	mov    %eax,0xc(%ebx)
  release(&icache.lock);
  101c95:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101c9c:	e8 6f 20 00 00       	call   103d10 <release>

  if(!(ip->flags & I_VALID)){
  101ca1:	f6 43 0c 02          	testb  $0x2,0xc(%ebx)
  101ca5:	74 09                	je     101cb0 <ilock+0x70>
    brelse(bp);
    ip->flags |= I_VALID;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
  101ca7:	83 c4 10             	add    $0x10,%esp
  101caa:	5b                   	pop    %ebx
  101cab:	5e                   	pop    %esi
  101cac:	5d                   	pop    %ebp
  101cad:	c3                   	ret    
  101cae:	66 90                	xchg   %ax,%ax
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
  release(&icache.lock);

  if(!(ip->flags & I_VALID)){
    bp = bread(ip->dev, IBLOCK(ip->inum));
  101cb0:	8b 43 04             	mov    0x4(%ebx),%eax
  101cb3:	c1 e8 03             	shr    $0x3,%eax
  101cb6:	83 c0 02             	add    $0x2,%eax
  101cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cbd:	8b 03                	mov    (%ebx),%eax
  101cbf:	89 04 24             	mov    %eax,(%esp)
  101cc2:	e8 e9 e4 ff ff       	call   1001b0 <bread>
  101cc7:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
  101cc9:	8b 43 04             	mov    0x4(%ebx),%eax
  101ccc:	83 e0 07             	and    $0x7,%eax
  101ccf:	c1 e0 06             	shl    $0x6,%eax
  101cd2:	8d 44 06 18          	lea    0x18(%esi,%eax,1),%eax
    ip->type = dip->type;
  101cd6:	0f b7 10             	movzwl (%eax),%edx
  101cd9:	66 89 53 10          	mov    %dx,0x10(%ebx)
    ip->major = dip->major;
  101cdd:	0f b7 50 02          	movzwl 0x2(%eax),%edx
  101ce1:	66 89 53 12          	mov    %dx,0x12(%ebx)
    ip->minor = dip->minor;
  101ce5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
  101ce9:	66 89 53 14          	mov    %dx,0x14(%ebx)
    ip->nlink = dip->nlink;
  101ced:	0f b7 50 06          	movzwl 0x6(%eax),%edx
  101cf1:	66 89 53 16          	mov    %dx,0x16(%ebx)
    ip->size = dip->size;
  101cf5:	8b 50 08             	mov    0x8(%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101cf8:	83 c0 0c             	add    $0xc,%eax
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
  101cfb:	89 53 18             	mov    %edx,0x18(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
  101cfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d02:	8d 43 1c             	lea    0x1c(%ebx),%eax
  101d05:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
  101d0c:	00 
  101d0d:	89 04 24             	mov    %eax,(%esp)
  101d10:	e8 6b 21 00 00       	call   103e80 <memmove>
    brelse(bp);
  101d15:	89 34 24             	mov    %esi,(%esp)
  101d18:	e8 e3 e3 ff ff       	call   100100 <brelse>
    ip->flags |= I_VALID;
  101d1d:	83 4b 0c 02          	orl    $0x2,0xc(%ebx)
    if(ip->type == 0)
  101d21:	66 83 7b 10 00       	cmpw   $0x0,0x10(%ebx)
  101d26:	0f 85 7b ff ff ff    	jne    101ca7 <ilock+0x67>
      panic("ilock: no type");
  101d2c:	c7 04 24 f0 67 10 00 	movl   $0x1067f0,(%esp)
  101d33:	e8 78 ec ff ff       	call   1009b0 <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
  101d38:	c7 04 24 ea 67 10 00 	movl   $0x1067ea,(%esp)
  101d3f:	e8 6c ec ff ff       	call   1009b0 <panic>
  101d44:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101d4a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00101d50 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
  101d50:	55                   	push   %ebp
  101d51:	89 e5                	mov    %esp,%ebp
  101d53:	57                   	push   %edi
  101d54:	56                   	push   %esi
  101d55:	53                   	push   %ebx
  101d56:	89 c3                	mov    %eax,%ebx
  101d58:	83 ec 2c             	sub    $0x2c,%esp
  101d5b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  101d5e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
  101d61:	80 38 2f             	cmpb   $0x2f,(%eax)
  101d64:	0f 84 14 01 00 00    	je     101e7e <namex+0x12e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
  101d6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  101d70:	8b 40 68             	mov    0x68(%eax),%eax
  101d73:	89 04 24             	mov    %eax,(%esp)
  101d76:	e8 b5 f3 ff ff       	call   101130 <idup>
  101d7b:	89 c7                	mov    %eax,%edi
  101d7d:	eb 04                	jmp    101d83 <namex+0x33>
  101d7f:	90                   	nop
{
  char *s;
  int len;

  while(*path == '/')
    path++;
  101d80:	83 c3 01             	add    $0x1,%ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
  101d83:	0f b6 03             	movzbl (%ebx),%eax
  101d86:	3c 2f                	cmp    $0x2f,%al
  101d88:	74 f6                	je     101d80 <namex+0x30>
    path++;
  if(*path == 0)
  101d8a:	84 c0                	test   %al,%al
  101d8c:	75 1a                	jne    101da8 <namex+0x58>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
  101d8e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  101d91:	85 db                	test   %ebx,%ebx
  101d93:	0f 85 0d 01 00 00    	jne    101ea6 <namex+0x156>
    iput(ip);
    return 0;
  }
  return ip;
}
  101d99:	83 c4 2c             	add    $0x2c,%esp
  101d9c:	89 f8                	mov    %edi,%eax
  101d9e:	5b                   	pop    %ebx
  101d9f:	5e                   	pop    %esi
  101da0:	5f                   	pop    %edi
  101da1:	5d                   	pop    %ebp
  101da2:	c3                   	ret    
  101da3:	90                   	nop
  101da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101da8:	3c 2f                	cmp    $0x2f,%al
  101daa:	0f 84 94 00 00 00    	je     101e44 <namex+0xf4>
  101db0:	89 de                	mov    %ebx,%esi
  101db2:	eb 08                	jmp    101dbc <namex+0x6c>
  101db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101db8:	3c 2f                	cmp    $0x2f,%al
  101dba:	74 0a                	je     101dc6 <namex+0x76>
    path++;
  101dbc:	83 c6 01             	add    $0x1,%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
  101dbf:	0f b6 06             	movzbl (%esi),%eax
  101dc2:	84 c0                	test   %al,%al
  101dc4:	75 f2                	jne    101db8 <namex+0x68>
  101dc6:	89 f2                	mov    %esi,%edx
  101dc8:	29 da                	sub    %ebx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
  101dca:	83 fa 0d             	cmp    $0xd,%edx
  101dcd:	7e 79                	jle    101e48 <namex+0xf8>
    memmove(name, s, DIRSIZ);
  101dcf:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
  101dd6:	00 
  101dd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101dde:	89 04 24             	mov    %eax,(%esp)
  101de1:	e8 9a 20 00 00       	call   103e80 <memmove>
  101de6:	eb 03                	jmp    101deb <namex+0x9b>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
    path++;
  101de8:	83 c6 01             	add    $0x1,%esi
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101deb:	80 3e 2f             	cmpb   $0x2f,(%esi)
  101dee:	74 f8                	je     101de8 <namex+0x98>
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
  101df0:	85 f6                	test   %esi,%esi
  101df2:	74 9a                	je     101d8e <namex+0x3e>
    ilock(ip);
  101df4:	89 3c 24             	mov    %edi,(%esp)
  101df7:	e8 44 fe ff ff       	call   101c40 <ilock>
    if(ip->type != T_DIR){
  101dfc:	66 83 7f 10 01       	cmpw   $0x1,0x10(%edi)
  101e01:	75 67                	jne    101e6a <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
  101e03:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101e06:	85 c0                	test   %eax,%eax
  101e08:	74 0c                	je     101e16 <namex+0xc6>
  101e0a:	80 3e 00             	cmpb   $0x0,(%esi)
  101e0d:	8d 76 00             	lea    0x0(%esi),%esi
  101e10:	0f 84 7e 00 00 00    	je     101e94 <namex+0x144>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
  101e16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  101e1d:	00 
  101e1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101e21:	89 3c 24             	mov    %edi,(%esp)
  101e24:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e28:	e8 d3 f8 ff ff       	call   101700 <dirlookup>
  101e2d:	85 c0                	test   %eax,%eax
  101e2f:	89 c3                	mov    %eax,%ebx
  101e31:	74 37                	je     101e6a <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
  101e33:	89 3c 24             	mov    %edi,(%esp)
  101e36:	89 df                	mov    %ebx,%edi
  101e38:	89 f3                	mov    %esi,%ebx
  101e3a:	e8 11 fd ff ff       	call   101b50 <iunlockput>
  101e3f:	e9 3f ff ff ff       	jmp    101d83 <namex+0x33>
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
  101e44:	89 de                	mov    %ebx,%esi
  101e46:	31 d2                	xor    %edx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
  101e48:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  101e50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101e53:	89 04 24             	mov    %eax,(%esp)
  101e56:	89 55 dc             	mov    %edx,-0x24(%ebp)
  101e59:	e8 22 20 00 00       	call   103e80 <memmove>
    name[len] = 0;
  101e5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101e61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101e64:	c6 04 10 00          	movb   $0x0,(%eax,%edx,1)
  101e68:	eb 81                	jmp    101deb <namex+0x9b>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
  101e6a:	89 3c 24             	mov    %edi,(%esp)
  101e6d:	31 ff                	xor    %edi,%edi
  101e6f:	e8 dc fc ff ff       	call   101b50 <iunlockput>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101e74:	83 c4 2c             	add    $0x2c,%esp
  101e77:	89 f8                	mov    %edi,%eax
  101e79:	5b                   	pop    %ebx
  101e7a:	5e                   	pop    %esi
  101e7b:	5f                   	pop    %edi
  101e7c:	5d                   	pop    %ebp
  101e7d:	c3                   	ret    
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  101e7e:	ba 01 00 00 00       	mov    $0x1,%edx
  101e83:	b8 01 00 00 00       	mov    $0x1,%eax
  101e88:	e8 d3 f2 ff ff       	call   101160 <iget>
  101e8d:	89 c7                	mov    %eax,%edi
  101e8f:	e9 ef fe ff ff       	jmp    101d83 <namex+0x33>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
  101e94:	89 3c 24             	mov    %edi,(%esp)
  101e97:	e8 64 f9 ff ff       	call   101800 <iunlock>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
  101e9c:	83 c4 2c             	add    $0x2c,%esp
  101e9f:	89 f8                	mov    %edi,%eax
  101ea1:	5b                   	pop    %ebx
  101ea2:	5e                   	pop    %esi
  101ea3:	5f                   	pop    %edi
  101ea4:	5d                   	pop    %ebp
  101ea5:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
  101ea6:	89 3c 24             	mov    %edi,(%esp)
  101ea9:	31 ff                	xor    %edi,%edi
  101eab:	e8 60 fa ff ff       	call   101910 <iput>
    return 0;
  101eb0:	e9 e4 fe ff ff       	jmp    101d99 <namex+0x49>
  101eb5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101ec0 <nameiparent>:
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101ec0:	55                   	push   %ebp
  return namex(path, 1, name);
  101ec1:	ba 01 00 00 00       	mov    $0x1,%edx
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
  101ec6:	89 e5                	mov    %esp,%ebp
  101ec8:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
  101ecb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  101ece:	8b 45 08             	mov    0x8(%ebp),%eax
}
  101ed1:	c9                   	leave  
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
  101ed2:	e9 79 fe ff ff       	jmp    101d50 <namex>
  101ed7:	89 f6                	mov    %esi,%esi
  101ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101ee0 <namei>:
  return ip;
}

struct inode*
namei(char *path)
{
  101ee0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101ee1:	31 d2                	xor    %edx,%edx
  return ip;
}

struct inode*
namei(char *path)
{
  101ee3:	89 e5                	mov    %esp,%ebp
  101ee5:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
  101ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  101eeb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
  101eee:	e8 5d fe ff ff       	call   101d50 <namex>
}
  101ef3:	c9                   	leave  
  101ef4:	c3                   	ret    
  101ef5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101ef9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00101f00 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
  101f00:	55                   	push   %ebp
  101f01:	89 e5                	mov    %esp,%ebp
  101f03:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
  101f06:	c7 44 24 04 ff 67 10 	movl   $0x1067ff,0x4(%esp)
  101f0d:	00 
  101f0e:	c7 04 24 e0 aa 10 00 	movl   $0x10aae0,(%esp)
  101f15:	e8 b6 1c 00 00       	call   103bd0 <initlock>
}
  101f1a:	c9                   	leave  
  101f1b:	c3                   	ret    
  101f1c:	90                   	nop
  101f1d:	90                   	nop
  101f1e:	90                   	nop
  101f1f:	90                   	nop

00101f20 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  101f20:	55                   	push   %ebp
  101f21:	89 e5                	mov    %esp,%ebp
  101f23:	56                   	push   %esi
  101f24:	89 c6                	mov    %eax,%esi
  101f26:	83 ec 14             	sub    $0x14,%esp
  if(b == 0)
  101f29:	85 c0                	test   %eax,%eax
  101f2b:	0f 84 8d 00 00 00    	je     101fbe <idestart+0x9e>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  101f31:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101f36:	66 90                	xchg   %ax,%ax
  101f38:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  101f39:	25 c0 00 00 00       	and    $0xc0,%eax
  101f3e:	83 f8 40             	cmp    $0x40,%eax
  101f41:	75 f5                	jne    101f38 <idestart+0x18>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  101f43:	ba f6 03 00 00       	mov    $0x3f6,%edx
  101f48:	31 c0                	xor    %eax,%eax
  101f4a:	ee                   	out    %al,(%dx)
  101f4b:	ba f2 01 00 00       	mov    $0x1f2,%edx
  101f50:	b8 01 00 00 00       	mov    $0x1,%eax
  101f55:	ee                   	out    %al,(%dx)
    panic("idestart");

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, 1);  // number of sectors
  outb(0x1f3, b->sector & 0xff);
  101f56:	8b 4e 08             	mov    0x8(%esi),%ecx
  101f59:	b2 f3                	mov    $0xf3,%dl
  101f5b:	89 c8                	mov    %ecx,%eax
  101f5d:	ee                   	out    %al,(%dx)
  101f5e:	89 c8                	mov    %ecx,%eax
  101f60:	b2 f4                	mov    $0xf4,%dl
  101f62:	c1 e8 08             	shr    $0x8,%eax
  101f65:	ee                   	out    %al,(%dx)
  101f66:	89 c8                	mov    %ecx,%eax
  101f68:	b2 f5                	mov    $0xf5,%dl
  101f6a:	c1 e8 10             	shr    $0x10,%eax
  101f6d:	ee                   	out    %al,(%dx)
  101f6e:	8b 46 04             	mov    0x4(%esi),%eax
  101f71:	c1 e9 18             	shr    $0x18,%ecx
  101f74:	b2 f6                	mov    $0xf6,%dl
  101f76:	83 e1 0f             	and    $0xf,%ecx
  101f79:	83 e0 01             	and    $0x1,%eax
  101f7c:	c1 e0 04             	shl    $0x4,%eax
  101f7f:	09 c8                	or     %ecx,%eax
  101f81:	83 c8 e0             	or     $0xffffffe0,%eax
  101f84:	ee                   	out    %al,(%dx)
  outb(0x1f4, (b->sector >> 8) & 0xff);
  outb(0x1f5, (b->sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
  101f85:	f6 06 04             	testb  $0x4,(%esi)
  101f88:	75 16                	jne    101fa0 <idestart+0x80>
  101f8a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  101f8f:	b8 20 00 00 00       	mov    $0x20,%eax
  101f94:	ee                   	out    %al,(%dx)
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
  101f95:	83 c4 14             	add    $0x14,%esp
  101f98:	5e                   	pop    %esi
  101f99:	5d                   	pop    %ebp
  101f9a:	c3                   	ret    
  101f9b:	90                   	nop
  101f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101fa0:	b2 f7                	mov    $0xf7,%dl
  101fa2:	b8 30 00 00 00       	mov    $0x30,%eax
  101fa7:	ee                   	out    %al,(%dx)
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
  101fa8:	b9 80 00 00 00       	mov    $0x80,%ecx
  101fad:	83 c6 18             	add    $0x18,%esi
  101fb0:	ba f0 01 00 00       	mov    $0x1f0,%edx
  101fb5:	fc                   	cld    
  101fb6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  101fb8:	83 c4 14             	add    $0x14,%esp
  101fbb:	5e                   	pop    %esi
  101fbc:	5d                   	pop    %ebp
  101fbd:	c3                   	ret    
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  101fbe:	c7 04 24 06 68 10 00 	movl   $0x106806,(%esp)
  101fc5:	e8 e6 e9 ff ff       	call   1009b0 <panic>
  101fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00101fd0 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
  101fd0:	55                   	push   %ebp
  101fd1:	89 e5                	mov    %esp,%ebp
  101fd3:	53                   	push   %ebx
  101fd4:	83 ec 14             	sub    $0x14,%esp
  101fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!(b->flags & B_BUSY))
  101fda:	8b 03                	mov    (%ebx),%eax
  101fdc:	a8 01                	test   $0x1,%al
  101fde:	0f 84 90 00 00 00    	je     102074 <iderw+0xa4>
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
  101fe4:	83 e0 06             	and    $0x6,%eax
  101fe7:	83 f8 02             	cmp    $0x2,%eax
  101fea:	0f 84 9c 00 00 00    	je     10208c <iderw+0xbc>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
  101ff0:	8b 53 04             	mov    0x4(%ebx),%edx
  101ff3:	85 d2                	test   %edx,%edx
  101ff5:	74 0d                	je     102004 <iderw+0x34>
  101ff7:	a1 b8 78 10 00       	mov    0x1078b8,%eax
  101ffc:	85 c0                	test   %eax,%eax
  101ffe:	0f 84 7c 00 00 00    	je     102080 <iderw+0xb0>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);
  102004:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  10200b:	e8 50 1d 00 00       	call   103d60 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  102010:	ba b4 78 10 00       	mov    $0x1078b4,%edx
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);

  // Append b to idequeue.
  b->qnext = 0;
  102015:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  10201c:	a1 b4 78 10 00       	mov    0x1078b4,%eax
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  102021:	85 c0                	test   %eax,%eax
  102023:	74 0d                	je     102032 <iderw+0x62>
  102025:	8d 76 00             	lea    0x0(%esi),%esi
  102028:	8d 50 14             	lea    0x14(%eax),%edx
  10202b:	8b 40 14             	mov    0x14(%eax),%eax
  10202e:	85 c0                	test   %eax,%eax
  102030:	75 f6                	jne    102028 <iderw+0x58>
    ;
  *pp = b;
  102032:	89 1a                	mov    %ebx,(%edx)
  
  // Start disk if necessary.
  if(idequeue == b)
  102034:	39 1d b4 78 10 00    	cmp    %ebx,0x1078b4
  10203a:	75 14                	jne    102050 <iderw+0x80>
  10203c:	eb 2d                	jmp    10206b <iderw+0x9b>
  10203e:	66 90                	xchg   %ax,%ax
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  102040:	c7 44 24 04 80 78 10 	movl   $0x107880,0x4(%esp)
  102047:	00 
  102048:	89 1c 24             	mov    %ebx,(%esp)
  10204b:	e8 90 12 00 00       	call   1032e0 <sleep>
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
  102050:	8b 03                	mov    (%ebx),%eax
  102052:	83 e0 06             	and    $0x6,%eax
  102055:	83 f8 02             	cmp    $0x2,%eax
  102058:	75 e6                	jne    102040 <iderw+0x70>
    sleep(b, &idelock);
  }

  release(&idelock);
  10205a:	c7 45 08 80 78 10 00 	movl   $0x107880,0x8(%ebp)
}
  102061:	83 c4 14             	add    $0x14,%esp
  102064:	5b                   	pop    %ebx
  102065:	5d                   	pop    %ebp
  // Assuming will not sleep too long: ignore proc->killed.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }

  release(&idelock);
  102066:	e9 a5 1c 00 00       	jmp    103d10 <release>
    ;
  *pp = b;
  
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  10206b:	89 d8                	mov    %ebx,%eax
  10206d:	e8 ae fe ff ff       	call   101f20 <idestart>
  102072:	eb dc                	jmp    102050 <iderw+0x80>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  102074:	c7 04 24 0f 68 10 00 	movl   $0x10680f,(%esp)
  10207b:	e8 30 e9 ff ff       	call   1009b0 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
  102080:	c7 04 24 38 68 10 00 	movl   $0x106838,(%esp)
  102087:	e8 24 e9 ff ff       	call   1009b0 <panic>
  struct buf **pp;

  if(!(b->flags & B_BUSY))
    panic("iderw: buf not busy");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  10208c:	c7 04 24 23 68 10 00 	movl   $0x106823,(%esp)
  102093:	e8 18 e9 ff ff       	call   1009b0 <panic>
  102098:	90                   	nop
  102099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001020a0 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
  1020a0:	55                   	push   %ebp
  1020a1:	89 e5                	mov    %esp,%ebp
  1020a3:	57                   	push   %edi
  1020a4:	53                   	push   %ebx
  1020a5:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  // Take first buffer off queue.
  acquire(&idelock);
  1020a8:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  1020af:	e8 ac 1c 00 00       	call   103d60 <acquire>
  if((b = idequeue) == 0){
  1020b4:	8b 1d b4 78 10 00    	mov    0x1078b4,%ebx
  1020ba:	85 db                	test   %ebx,%ebx
  1020bc:	74 2d                	je     1020eb <ideintr+0x4b>
    release(&idelock);
    // cprintf("spurious IDE interrupt\n");
    return;
  }
  idequeue = b->qnext;
  1020be:	8b 43 14             	mov    0x14(%ebx),%eax
  1020c1:	a3 b4 78 10 00       	mov    %eax,0x1078b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
  1020c6:	8b 0b                	mov    (%ebx),%ecx
  1020c8:	f6 c1 04             	test   $0x4,%cl
  1020cb:	74 33                	je     102100 <ideintr+0x60>
    insl(0x1f0, b->data, 512/4);
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
  1020cd:	83 c9 02             	or     $0x2,%ecx
  1020d0:	83 e1 fb             	and    $0xfffffffb,%ecx
  1020d3:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
  1020d5:	89 1c 24             	mov    %ebx,(%esp)
  1020d8:	e8 e3 10 00 00       	call   1031c0 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
  1020dd:	a1 b4 78 10 00       	mov    0x1078b4,%eax
  1020e2:	85 c0                	test   %eax,%eax
  1020e4:	74 05                	je     1020eb <ideintr+0x4b>
    idestart(idequeue);
  1020e6:	e8 35 fe ff ff       	call   101f20 <idestart>

  release(&idelock);
  1020eb:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  1020f2:	e8 19 1c 00 00       	call   103d10 <release>
}
  1020f7:	83 c4 10             	add    $0x10,%esp
  1020fa:	5b                   	pop    %ebx
  1020fb:	5f                   	pop    %edi
  1020fc:	5d                   	pop    %ebp
  1020fd:	c3                   	ret    
  1020fe:	66 90                	xchg   %ax,%ax
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102100:	ba f7 01 00 00       	mov    $0x1f7,%edx
  102105:	8d 76 00             	lea    0x0(%esi),%esi
  102108:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  102109:	0f b6 c0             	movzbl %al,%eax
  10210c:	89 c7                	mov    %eax,%edi
  10210e:	81 e7 c0 00 00 00    	and    $0xc0,%edi
  102114:	83 ff 40             	cmp    $0x40,%edi
  102117:	75 ef                	jne    102108 <ideintr+0x68>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
  102119:	a8 21                	test   $0x21,%al
  10211b:	75 b0                	jne    1020cd <ideintr+0x2d>
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
  10211d:	8d 7b 18             	lea    0x18(%ebx),%edi
  102120:	b9 80 00 00 00       	mov    $0x80,%ecx
  102125:	ba f0 01 00 00       	mov    $0x1f0,%edx
  10212a:	fc                   	cld    
  10212b:	f3 6d                	rep insl (%dx),%es:(%edi)
  10212d:	8b 0b                	mov    (%ebx),%ecx
  10212f:	eb 9c                	jmp    1020cd <ideintr+0x2d>
  102131:	eb 0d                	jmp    102140 <ideinit>
  102133:	90                   	nop
  102134:	90                   	nop
  102135:	90                   	nop
  102136:	90                   	nop
  102137:	90                   	nop
  102138:	90                   	nop
  102139:	90                   	nop
  10213a:	90                   	nop
  10213b:	90                   	nop
  10213c:	90                   	nop
  10213d:	90                   	nop
  10213e:	90                   	nop
  10213f:	90                   	nop

00102140 <ideinit>:
  return 0;
}

void
ideinit(void)
{
  102140:	55                   	push   %ebp
  102141:	89 e5                	mov    %esp,%ebp
  102143:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
  102146:	c7 44 24 04 56 68 10 	movl   $0x106856,0x4(%esp)
  10214d:	00 
  10214e:	c7 04 24 80 78 10 00 	movl   $0x107880,(%esp)
  102155:	e8 76 1a 00 00       	call   103bd0 <initlock>
  picenable(IRQ_IDE);
  10215a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  102161:	e8 ba 0a 00 00       	call   102c20 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
  102166:	a1 00 c1 10 00       	mov    0x10c100,%eax
  10216b:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  102172:	83 e8 01             	sub    $0x1,%eax
  102175:	89 44 24 04          	mov    %eax,0x4(%esp)
  102179:	e8 52 00 00 00       	call   1021d0 <ioapicenable>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  10217e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  102183:	90                   	nop
  102184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102188:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
  102189:	25 c0 00 00 00       	and    $0xc0,%eax
  10218e:	83 f8 40             	cmp    $0x40,%eax
  102191:	75 f5                	jne    102188 <ideinit+0x48>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102193:	ba f6 01 00 00       	mov    $0x1f6,%edx
  102198:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  10219d:	ee                   	out    %al,(%dx)
  10219e:	31 c9                	xor    %ecx,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  1021a0:	b2 f7                	mov    $0xf7,%dl
  1021a2:	eb 0f                	jmp    1021b3 <ideinit+0x73>
  1021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
  1021a8:	83 c1 01             	add    $0x1,%ecx
  1021ab:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  1021b1:	74 0f                	je     1021c2 <ideinit+0x82>
  1021b3:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
  1021b4:	84 c0                	test   %al,%al
  1021b6:	74 f0                	je     1021a8 <ideinit+0x68>
      havedisk1 = 1;
  1021b8:	c7 05 b8 78 10 00 01 	movl   $0x1,0x1078b8
  1021bf:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  1021c2:	ba f6 01 00 00       	mov    $0x1f6,%edx
  1021c7:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  1021cc:	ee                   	out    %al,(%dx)
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
  1021cd:	c9                   	leave  
  1021ce:	c3                   	ret    
  1021cf:	90                   	nop

001021d0 <ioapicenable>:
}

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
  1021d0:	8b 15 04 bb 10 00    	mov    0x10bb04,%edx
  }
}

void
ioapicenable(int irq, int cpunum)
{
  1021d6:	55                   	push   %ebp
  1021d7:	89 e5                	mov    %esp,%ebp
  1021d9:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!ismp)
  1021dc:	85 d2                	test   %edx,%edx
  1021de:	74 31                	je     102211 <ioapicenable+0x41>
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021e0:	8b 15 b4 ba 10 00    	mov    0x10bab4,%edx
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  1021e6:	8d 48 20             	lea    0x20(%eax),%ecx
  1021e9:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021ed:	89 02                	mov    %eax,(%edx)
  ioapic->data = data;
  1021ef:	8b 15 b4 ba 10 00    	mov    0x10bab4,%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021f5:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
  1021f8:	89 4a 10             	mov    %ecx,0x10(%edx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1021fb:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  102201:	8b 55 0c             	mov    0xc(%ebp),%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  102204:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
  102206:	a1 b4 ba 10 00       	mov    0x10bab4,%eax

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
  10220b:	c1 e2 18             	shl    $0x18,%edx

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  10220e:	89 50 10             	mov    %edx,0x10(%eax)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
  102211:	5d                   	pop    %ebp
  102212:	c3                   	ret    
  102213:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  102219:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102220 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
  102220:	55                   	push   %ebp
  102221:	89 e5                	mov    %esp,%ebp
  102223:	56                   	push   %esi
  102224:	53                   	push   %ebx
  102225:	83 ec 10             	sub    $0x10,%esp
  int i, id, maxintr;

  if(!ismp)
  102228:	8b 0d 04 bb 10 00    	mov    0x10bb04,%ecx
  10222e:	85 c9                	test   %ecx,%ecx
  102230:	0f 84 9e 00 00 00    	je     1022d4 <ioapicinit+0xb4>
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  102236:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
  10223d:	00 00 00 
  return ioapic->data;
  102240:	8b 35 10 00 c0 fe    	mov    0xfec00010,%esi
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  102246:	bb 00 00 c0 fe       	mov    $0xfec00000,%ebx
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  10224b:	c7 05 00 00 c0 fe 00 	movl   $0x0,0xfec00000
  102252:	00 00 00 
  return ioapic->data;
  102255:	a1 10 00 c0 fe       	mov    0xfec00010,%eax
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  10225a:	0f b6 15 00 bb 10 00 	movzbl 0x10bb00,%edx
  int i, id, maxintr;

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  102261:	c7 05 b4 ba 10 00 00 	movl   $0xfec00000,0x10bab4
  102268:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  10226b:	c1 ee 10             	shr    $0x10,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  10226e:	c1 e8 18             	shr    $0x18,%eax

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  102271:	81 e6 ff 00 00 00    	and    $0xff,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
  102277:	39 c2                	cmp    %eax,%edx
  102279:	74 12                	je     10228d <ioapicinit+0x6d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
  10227b:	c7 04 24 5c 68 10 00 	movl   $0x10685c,(%esp)
  102282:	e8 39 e3 ff ff       	call   1005c0 <cprintf>
  102287:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
  10228d:	ba 10 00 00 00       	mov    $0x10,%edx
  102292:	31 c0                	xor    %eax,%eax
  102294:	eb 08                	jmp    10229e <ioapicinit+0x7e>
  102296:	66 90                	xchg   %ax,%ax

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  102298:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  10229e:	89 13                	mov    %edx,(%ebx)
  ioapic->data = data;
  1022a0:	8b 1d b4 ba 10 00    	mov    0x10bab4,%ebx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
  1022a6:	8d 48 20             	lea    0x20(%eax),%ecx
  1022a9:	81 c9 00 00 01 00    	or     $0x10000,%ecx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  1022af:	83 c0 01             	add    $0x1,%eax

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
  1022b2:	89 4b 10             	mov    %ecx,0x10(%ebx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1022b5:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx
  1022bb:	8d 5a 01             	lea    0x1(%edx),%ebx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  1022be:	83 c2 02             	add    $0x2,%edx
  1022c1:	39 c6                	cmp    %eax,%esi
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  1022c3:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
  1022c5:	8b 0d b4 ba 10 00    	mov    0x10bab4,%ecx
  1022cb:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
  1022d2:	7d c4                	jge    102298 <ioapicinit+0x78>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
  1022d4:	83 c4 10             	add    $0x10,%esp
  1022d7:	5b                   	pop    %ebx
  1022d8:	5e                   	pop    %esi
  1022d9:	5d                   	pop    %ebp
  1022da:	c3                   	ret    
  1022db:	90                   	nop
  1022dc:	90                   	nop
  1022dd:	90                   	nop
  1022de:	90                   	nop
  1022df:	90                   	nop

001022e0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  1022e0:	55                   	push   %ebp
  1022e1:	89 e5                	mov    %esp,%ebp
  1022e3:	53                   	push   %ebx
  1022e4:	83 ec 14             	sub    $0x14,%esp
  struct run *r;

  acquire(&kmem.lock);
  1022e7:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  1022ee:	e8 6d 1a 00 00       	call   103d60 <acquire>
  r = kmem.freelist;
  1022f3:	8b 1d f4 ba 10 00    	mov    0x10baf4,%ebx
  if(r)
  1022f9:	85 db                	test   %ebx,%ebx
  1022fb:	74 07                	je     102304 <kalloc+0x24>
    kmem.freelist = r->next;
  1022fd:	8b 03                	mov    (%ebx),%eax
  1022ff:	a3 f4 ba 10 00       	mov    %eax,0x10baf4
  release(&kmem.lock);
  102304:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  10230b:	e8 00 1a 00 00       	call   103d10 <release>
  return (char*)r;
}
  102310:	89 d8                	mov    %ebx,%eax
  102312:	83 c4 14             	add    $0x14,%esp
  102315:	5b                   	pop    %ebx
  102316:	5d                   	pop    %ebp
  102317:	c3                   	ret    
  102318:	90                   	nop
  102319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102320 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
  102320:	55                   	push   %ebp
  102321:	89 e5                	mov    %esp,%ebp
  102323:	53                   	push   %ebx
  102324:	83 ec 14             	sub    $0x14,%esp
  102327:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
  10232a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  102330:	75 52                	jne    102384 <kfree+0x64>
  102332:	81 fb ff ff ff 00    	cmp    $0xffffff,%ebx
  102338:	77 4a                	ja     102384 <kfree+0x64>
  10233a:	81 fb a4 e8 10 00    	cmp    $0x10e8a4,%ebx
  102340:	72 42                	jb     102384 <kfree+0x64>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
  102342:	89 1c 24             	mov    %ebx,(%esp)
  102345:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10234c:	00 
  10234d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  102354:	00 
  102355:	e8 a6 1a 00 00       	call   103e00 <memset>

  acquire(&kmem.lock);
  10235a:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  102361:	e8 fa 19 00 00       	call   103d60 <acquire>
  r = (struct run*)v;
  r->next = kmem.freelist;
  102366:	a1 f4 ba 10 00       	mov    0x10baf4,%eax
  10236b:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  10236d:	89 1d f4 ba 10 00    	mov    %ebx,0x10baf4
  release(&kmem.lock);
  102373:	c7 45 08 c0 ba 10 00 	movl   $0x10bac0,0x8(%ebp)
}
  10237a:	83 c4 14             	add    $0x14,%esp
  10237d:	5b                   	pop    %ebx
  10237e:	5d                   	pop    %ebp

  acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
  10237f:	e9 8c 19 00 00       	jmp    103d10 <release>
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || (uint)v >= PHYSTOP) 
    panic("kfree");
  102384:	c7 04 24 8e 68 10 00 	movl   $0x10688e,(%esp)
  10238b:	e8 20 e6 ff ff       	call   1009b0 <panic>

00102390 <kinit>:
extern char end[]; // first address after kernel loaded from ELF file

// Initialize free list of physical pages.
void
kinit(void)
{
  102390:	55                   	push   %ebp
  102391:	89 e5                	mov    %esp,%ebp
  102393:	53                   	push   %ebx
  102394:	83 ec 14             	sub    $0x14,%esp
  char *p;

  initlock(&kmem.lock, "kmem");
  102397:	c7 44 24 04 94 68 10 	movl   $0x106894,0x4(%esp)
  10239e:	00 
  10239f:	c7 04 24 c0 ba 10 00 	movl   $0x10bac0,(%esp)
  1023a6:	e8 25 18 00 00       	call   103bd0 <initlock>
  p = (char*)PGROUNDUP((uint)end);
  1023ab:	ba a3 f8 10 00       	mov    $0x10f8a3,%edx
  1023b0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  1023b6:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
  1023bc:	81 fb 00 00 00 01    	cmp    $0x1000000,%ebx
  1023c2:	76 08                	jbe    1023cc <kinit+0x3c>
  1023c4:	eb 1b                	jmp    1023e1 <kinit+0x51>
  1023c6:	66 90                	xchg   %ax,%ax
  1023c8:	89 da                	mov    %ebx,%edx
  1023ca:	89 c3                	mov    %eax,%ebx
    kfree(p);
  1023cc:	89 14 24             	mov    %edx,(%esp)
  1023cf:	e8 4c ff ff ff       	call   102320 <kfree>
{
  char *p;

  initlock(&kmem.lock, "kmem");
  p = (char*)PGROUNDUP((uint)end);
  for(; p + PGSIZE <= (char*)PHYSTOP; p += PGSIZE)
  1023d4:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  1023da:	3d 00 00 00 01       	cmp    $0x1000000,%eax
  1023df:	76 e7                	jbe    1023c8 <kinit+0x38>
    kfree(p);
}
  1023e1:	83 c4 14             	add    $0x14,%esp
  1023e4:	5b                   	pop    %ebx
  1023e5:	5d                   	pop    %ebp
  1023e6:	c3                   	ret    
  1023e7:	90                   	nop
  1023e8:	90                   	nop
  1023e9:	90                   	nop
  1023ea:	90                   	nop
  1023eb:	90                   	nop
  1023ec:	90                   	nop
  1023ed:	90                   	nop
  1023ee:	90                   	nop
  1023ef:	90                   	nop

001023f0 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
  1023f0:	55                   	push   %ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  1023f1:	ba 64 00 00 00       	mov    $0x64,%edx
  1023f6:	89 e5                	mov    %esp,%ebp
  1023f8:	ec                   	in     (%dx),%al
  1023f9:	89 c2                	mov    %eax,%edx
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
  1023fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102400:	83 e2 01             	and    $0x1,%edx
  102403:	74 41                	je     102446 <kbdgetc+0x56>
  102405:	ba 60 00 00 00       	mov    $0x60,%edx
  10240a:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
  10240b:	0f b6 c0             	movzbl %al,%eax

  if(data == 0xE0){
  10240e:	3d e0 00 00 00       	cmp    $0xe0,%eax
  102413:	0f 84 7f 00 00 00    	je     102498 <kbdgetc+0xa8>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
  102419:	84 c0                	test   %al,%al
  10241b:	79 2b                	jns    102448 <kbdgetc+0x58>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
  10241d:	8b 15 bc 78 10 00    	mov    0x1078bc,%edx
  102423:	89 c1                	mov    %eax,%ecx
  102425:	83 e1 7f             	and    $0x7f,%ecx
  102428:	f6 c2 40             	test   $0x40,%dl
  10242b:	0f 44 c1             	cmove  %ecx,%eax
    shift &= ~(shiftcode[data] | E0ESC);
  10242e:	0f b6 80 a0 68 10 00 	movzbl 0x1068a0(%eax),%eax
  102435:	83 c8 40             	or     $0x40,%eax
  102438:	0f b6 c0             	movzbl %al,%eax
  10243b:	f7 d0                	not    %eax
  10243d:	21 d0                	and    %edx,%eax
  10243f:	a3 bc 78 10 00       	mov    %eax,0x1078bc
  102444:	31 c0                	xor    %eax,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102446:	5d                   	pop    %ebp
  102447:	c3                   	ret    
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
  102448:	8b 0d bc 78 10 00    	mov    0x1078bc,%ecx
  10244e:	f6 c1 40             	test   $0x40,%cl
  102451:	74 05                	je     102458 <kbdgetc+0x68>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
  102453:	0c 80                	or     $0x80,%al
    shift &= ~E0ESC;
  102455:	83 e1 bf             	and    $0xffffffbf,%ecx
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  102458:	0f b6 90 a0 68 10 00 	movzbl 0x1068a0(%eax),%edx
  10245f:	09 ca                	or     %ecx,%edx
  102461:	0f b6 88 a0 69 10 00 	movzbl 0x1069a0(%eax),%ecx
  102468:	31 ca                	xor    %ecx,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
  10246a:	89 d1                	mov    %edx,%ecx
  10246c:	83 e1 03             	and    $0x3,%ecx
  10246f:	8b 0c 8d a0 6a 10 00 	mov    0x106aa0(,%ecx,4),%ecx
    data |= 0x80;
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  102476:	89 15 bc 78 10 00    	mov    %edx,0x1078bc
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
  10247c:	83 e2 08             	and    $0x8,%edx
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  10247f:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
  if(shift & CAPSLOCK){
  102483:	74 c1                	je     102446 <kbdgetc+0x56>
    if('a' <= c && c <= 'z')
  102485:	8d 50 9f             	lea    -0x61(%eax),%edx
  102488:	83 fa 19             	cmp    $0x19,%edx
  10248b:	77 1b                	ja     1024a8 <kbdgetc+0xb8>
      c += 'A' - 'a';
  10248d:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  102490:	5d                   	pop    %ebp
  102491:	c3                   	ret    
  102492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if((st & KBS_DIB) == 0)
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
  102498:	30 c0                	xor    %al,%al
  10249a:	83 0d bc 78 10 00 40 	orl    $0x40,0x1078bc
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
  1024a1:	5d                   	pop    %ebp
  1024a2:	c3                   	ret    
  1024a3:	90                   	nop
  1024a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
  1024a8:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
  1024ab:	8d 50 20             	lea    0x20(%eax),%edx
  1024ae:	83 f9 19             	cmp    $0x19,%ecx
  1024b1:	0f 46 c2             	cmovbe %edx,%eax
  }
  return c;
}
  1024b4:	5d                   	pop    %ebp
  1024b5:	c3                   	ret    
  1024b6:	8d 76 00             	lea    0x0(%esi),%esi
  1024b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001024c0 <kbdintr>:

void
kbdintr(void)
{
  1024c0:	55                   	push   %ebp
  1024c1:	89 e5                	mov    %esp,%ebp
  1024c3:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
  1024c6:	c7 04 24 f0 23 10 00 	movl   $0x1023f0,(%esp)
  1024cd:	e8 4e e3 ff ff       	call   100820 <consoleintr>
}
  1024d2:	c9                   	leave  
  1024d3:	c3                   	ret    
  1024d4:	90                   	nop
  1024d5:	90                   	nop
  1024d6:	90                   	nop
  1024d7:	90                   	nop
  1024d8:	90                   	nop
  1024d9:	90                   	nop
  1024da:	90                   	nop
  1024db:	90                   	nop
  1024dc:	90                   	nop
  1024dd:	90                   	nop
  1024de:	90                   	nop
  1024df:	90                   	nop

001024e0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
  1024e0:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
}

// Acknowledge interrupt.
void
lapiceoi(void)
{
  1024e5:	55                   	push   %ebp
  1024e6:	89 e5                	mov    %esp,%ebp
  if(lapic)
  1024e8:	85 c0                	test   %eax,%eax
  1024ea:	74 12                	je     1024fe <lapiceoi+0x1e>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1024ec:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  1024f3:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1024f6:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1024fb:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
  1024fe:	5d                   	pop    %ebp
  1024ff:	c3                   	ret    

00102500 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
  102500:	55                   	push   %ebp
  102501:	89 e5                	mov    %esp,%ebp
}
  102503:	5d                   	pop    %ebp
  102504:	c3                   	ret    
  102505:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102509:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102510 <lapicstartap>:

// Start additional processor running bootstrap code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
  102510:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102511:	ba 70 00 00 00       	mov    $0x70,%edx
  102516:	89 e5                	mov    %esp,%ebp
  102518:	b8 0f 00 00 00       	mov    $0xf,%eax
  10251d:	53                   	push   %ebx
  10251e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  102521:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
  102525:	ee                   	out    %al,(%dx)
  102526:	b8 0a 00 00 00       	mov    $0xa,%eax
  10252b:	b2 71                	mov    $0x71,%dl
  10252d:	ee                   	out    %al,(%dx)
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  wrv[1] = addr >> 4;
  10252e:	89 c8                	mov    %ecx,%eax
  102530:	c1 e8 04             	shr    $0x4,%eax
  102533:	66 a3 69 04 00 00    	mov    %ax,0x469
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102539:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10253e:	c1 e3 18             	shl    $0x18,%ebx
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (ushort*)(0x40<<4 | 0x67);  // Warm reset vector
  wrv[0] = 0;
  102541:	66 c7 05 67 04 00 00 	movw   $0x0,0x467
  102548:	00 00 

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  10254a:	c1 e9 0c             	shr    $0xc,%ecx
  10254d:	80 cd 06             	or     $0x6,%ch
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102550:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102556:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10255b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10255e:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
  102565:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102568:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10256d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102570:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
  102577:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10257a:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10257f:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102582:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102588:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10258d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102590:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  102596:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10259b:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10259e:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
  1025a4:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1025a9:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1025ac:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
  1025b2:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  1025b7:	5b                   	pop    %ebx
  1025b8:	5d                   	pop    %ebp

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
  1025b9:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
  1025bc:	c3                   	ret    
  1025bd:	8d 76 00             	lea    0x0(%esi),%esi

001025c0 <cpunum>:
  lapicw(TPR, 0);
}

int
cpunum(void)
{
  1025c0:	55                   	push   %ebp
  1025c1:	89 e5                	mov    %esp,%ebp
  1025c3:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  1025c6:	9c                   	pushf  
  1025c7:	58                   	pop    %eax
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
  1025c8:	f6 c4 02             	test   $0x2,%ah
  1025cb:	74 12                	je     1025df <cpunum+0x1f>
    static int n;
    if(n++ == 0)
  1025cd:	a1 c0 78 10 00       	mov    0x1078c0,%eax
  1025d2:	8d 50 01             	lea    0x1(%eax),%edx
  1025d5:	85 c0                	test   %eax,%eax
  1025d7:	89 15 c0 78 10 00    	mov    %edx,0x1078c0
  1025dd:	74 19                	je     1025f8 <cpunum+0x38>
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if(lapic)
  1025df:	8b 15 f8 ba 10 00    	mov    0x10baf8,%edx
  1025e5:	31 c0                	xor    %eax,%eax
  1025e7:	85 d2                	test   %edx,%edx
  1025e9:	74 06                	je     1025f1 <cpunum+0x31>
    return lapic[ID]>>24;
  1025eb:	8b 42 20             	mov    0x20(%edx),%eax
  1025ee:	c1 e8 18             	shr    $0x18,%eax
  return 0;
}
  1025f1:	c9                   	leave  
  1025f2:	c3                   	ret    
  1025f3:	90                   	nop
  1025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
    static int n;
    if(n++ == 0)
      cprintf("cpu called from %x with interrupts enabled\n",
  1025f8:	8b 45 04             	mov    0x4(%ebp),%eax
  1025fb:	c7 04 24 b0 6a 10 00 	movl   $0x106ab0,(%esp)
  102602:	89 44 24 04          	mov    %eax,0x4(%esp)
  102606:	e8 b5 df ff ff       	call   1005c0 <cprintf>
  10260b:	eb d2                	jmp    1025df <cpunum+0x1f>
  10260d:	8d 76 00             	lea    0x0(%esi),%esi

00102610 <lapicinit>:
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(int c)
{
  102610:	55                   	push   %ebp
  102611:	89 e5                	mov    %esp,%ebp
  102613:	83 ec 18             	sub    $0x18,%esp
  cprintf("lapicinit: %d 0x%x\n", c, lapic);
  102616:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10261b:	c7 04 24 dc 6a 10 00 	movl   $0x106adc,(%esp)
  102622:	89 44 24 08          	mov    %eax,0x8(%esp)
  102626:	8b 45 08             	mov    0x8(%ebp),%eax
  102629:	89 44 24 04          	mov    %eax,0x4(%esp)
  10262d:	e8 8e df ff ff       	call   1005c0 <cprintf>
  if(!lapic) 
  102632:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102637:	85 c0                	test   %eax,%eax
  102639:	0f 84 0a 01 00 00    	je     102749 <lapicinit+0x139>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  10263f:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
  102646:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102649:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10264e:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102651:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
  102658:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10265b:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102660:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102663:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
  10266a:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
  10266d:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102672:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102675:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
  10267c:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
  10267f:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102684:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102687:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
  10268e:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  102691:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102696:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102699:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
  1026a0:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  1026a3:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026a8:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
  1026ab:	8b 50 30             	mov    0x30(%eax),%edx
  1026ae:	c1 ea 10             	shr    $0x10,%edx
  1026b1:	80 fa 03             	cmp    $0x3,%dl
  1026b4:	0f 87 96 00 00 00    	ja     102750 <lapicinit+0x140>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026ba:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
  1026c1:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026c4:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026c9:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026cc:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  1026d3:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026d6:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026db:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026de:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
  1026e5:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026e8:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026ed:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  1026f0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
  1026f7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  1026fa:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  1026ff:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102702:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
  102709:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  10270c:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102711:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102714:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
  10271b:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
  10271e:	8b 0d f8 ba 10 00    	mov    0x10baf8,%ecx
  102724:	8b 41 20             	mov    0x20(%ecx),%eax
  102727:	8d 91 00 03 00 00    	lea    0x300(%ecx),%edx
  10272d:	8d 76 00             	lea    0x0(%esi),%esi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
  102730:	8b 02                	mov    (%edx),%eax
  102732:	f6 c4 10             	test   $0x10,%ah
  102735:	75 f9                	jne    102730 <lapicinit+0x120>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102737:	c7 81 80 00 00 00 00 	movl   $0x0,0x80(%ecx)
  10273e:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
  102741:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  102746:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
  102749:	c9                   	leave  
  10274a:	c3                   	ret    
  10274b:	90                   	nop
  10274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
  102750:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
  102757:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
  10275a:	a1 f8 ba 10 00       	mov    0x10baf8,%eax
  10275f:	8b 50 20             	mov    0x20(%eax),%edx
  102762:	e9 53 ff ff ff       	jmp    1026ba <lapicinit+0xaa>
  102767:	90                   	nop
  102768:	90                   	nop
  102769:	90                   	nop
  10276a:	90                   	nop
  10276b:	90                   	nop
  10276c:	90                   	nop
  10276d:	90                   	nop
  10276e:	90                   	nop
  10276f:	90                   	nop

00102770 <mpmain>:
// Common CPU setup code.
// Bootstrap CPU comes here from mainc().
// Other CPUs jump here from bootother.S.
static void
mpmain(void)
{
  102770:	55                   	push   %ebp
  102771:	89 e5                	mov    %esp,%ebp
  102773:	53                   	push   %ebx
  102774:	83 ec 14             	sub    $0x14,%esp
  if(cpunum() != mpbcpu()){
  102777:	e8 44 fe ff ff       	call   1025c0 <cpunum>
  10277c:	89 c3                	mov    %eax,%ebx
  10277e:	e8 ed 01 00 00       	call   102970 <mpbcpu>
  102783:	39 c3                	cmp    %eax,%ebx
  102785:	74 16                	je     10279d <mpmain+0x2d>
    seginit();
  102787:	e8 04 3e 00 00       	call   106590 <seginit>
  10278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    lapicinit(cpunum());
  102790:	e8 2b fe ff ff       	call   1025c0 <cpunum>
  102795:	89 04 24             	mov    %eax,(%esp)
  102798:	e8 73 fe ff ff       	call   102610 <lapicinit>
  }
  vmenable();        // turn on paging
  10279d:	e8 ae 36 00 00       	call   105e50 <vmenable>
  cprintf("cpu%d: starting\n", cpu->id);
  1027a2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1027a8:	0f b6 00             	movzbl (%eax),%eax
  1027ab:	c7 04 24 f0 6a 10 00 	movl   $0x106af0,(%esp)
  1027b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1027b6:	e8 05 de ff ff       	call   1005c0 <cprintf>
  idtinit();       // load idt register
  1027bb:	e8 a0 27 00 00       	call   104f60 <idtinit>
  xchg(&cpu->booted, 1); // tell bootothers() we're up
  1027c0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  1027c7:	b8 01 00 00 00       	mov    $0x1,%eax
  1027cc:	f0 87 82 a8 00 00 00 	lock xchg %eax,0xa8(%edx)
  scheduler();     // start running processes
  1027d3:	e8 18 0c 00 00       	call   1033f0 <scheduler>
  1027d8:	90                   	nop
  1027d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001027e0 <mainc>:

// Set up hardware and software.
// Runs only on the boostrap processor.
void
mainc(void)
{
  1027e0:	55                   	push   %ebp
  1027e1:	89 e5                	mov    %esp,%ebp
  1027e3:	53                   	push   %ebx
  1027e4:	83 ec 14             	sub    $0x14,%esp
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  1027e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1027ed:	0f b6 00             	movzbl (%eax),%eax
  1027f0:	c7 04 24 01 6b 10 00 	movl   $0x106b01,(%esp)
  1027f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1027fb:	e8 c0 dd ff ff       	call   1005c0 <cprintf>
  picinit();       // interrupt controller
  102800:	e8 4b 04 00 00       	call   102c50 <picinit>
  ioapicinit();    // another interrupt controller
  102805:	e8 16 fa ff ff       	call   102220 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
  10280a:	e8 e1 da ff ff       	call   1002f0 <consoleinit>
  10280f:	90                   	nop
  uartinit();      // serial port
  102810:	e8 0b 2b 00 00       	call   105320 <uartinit>
  kvmalloc();      // initialize the kernel page table
  102815:	e8 b6 38 00 00       	call   1060d0 <kvmalloc>
  pinit();         // process table
  10281a:	e8 91 13 00 00       	call   103bb0 <pinit>
  10281f:	90                   	nop
  tvinit();        // trap vectors
  102820:	e8 cb 29 00 00       	call   1051f0 <tvinit>
  binit();         // buffer cache
  102825:	e8 56 da ff ff       	call   100280 <binit>
  fileinit();      // file table
  10282a:	e8 b1 e8 ff ff       	call   1010e0 <fileinit>
  10282f:	90                   	nop
  iinit();         // inode cache
  102830:	e8 cb f6 ff ff       	call   101f00 <iinit>
  ideinit();       // disk
  102835:	e8 06 f9 ff ff       	call   102140 <ideinit>
  if(!ismp)
  10283a:	a1 04 bb 10 00       	mov    0x10bb04,%eax
  10283f:	85 c0                	test   %eax,%eax
  102841:	0f 84 ae 00 00 00    	je     1028f5 <mainc+0x115>
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  102847:	e8 74 12 00 00       	call   103ac0 <userinit>

  // Write bootstrap code to unused memory at 0x7000.
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);
  10284c:	c7 44 24 08 6a 00 00 	movl   $0x6a,0x8(%esp)
  102853:	00 
  102854:	c7 44 24 04 9c 77 10 	movl   $0x10779c,0x4(%esp)
  10285b:	00 
  10285c:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
  102863:	e8 18 16 00 00       	call   103e80 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
  102868:	69 05 00 c1 10 00 bc 	imul   $0xbc,0x10c100,%eax
  10286f:	00 00 00 
  102872:	05 20 bb 10 00       	add    $0x10bb20,%eax
  102877:	3d 20 bb 10 00       	cmp    $0x10bb20,%eax
  10287c:	76 6d                	jbe    1028eb <mainc+0x10b>
  10287e:	bb 20 bb 10 00       	mov    $0x10bb20,%ebx
  102883:	90                   	nop
  102884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(c == cpus+cpunum())  // We've started already.
  102888:	e8 33 fd ff ff       	call   1025c0 <cpunum>
  10288d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  102893:	05 20 bb 10 00       	add    $0x10bb20,%eax
  102898:	39 d8                	cmp    %ebx,%eax
  10289a:	74 36                	je     1028d2 <mainc+0xf2>
      continue;

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
  10289c:	e8 3f fa ff ff       	call   1022e0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpmain;
  1028a1:	c7 05 f8 6f 00 00 70 	movl   $0x102770,0x6ff8
  1028a8:	27 10 00 

    // Tell bootother.S what stack to use and the address of mpmain;
    // it expects to find these two addresses stored just before
    // its first instruction.
    stack = kalloc();
    *(void**)(code-4) = stack + KSTACKSIZE;
  1028ab:	05 00 10 00 00       	add    $0x1000,%eax
  1028b0:	a3 fc 6f 00 00       	mov    %eax,0x6ffc
    *(void**)(code-8) = mpmain;

    lapicstartap(c->id, (uint)code);
  1028b5:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
  1028bc:	00 
  1028bd:	0f b6 03             	movzbl (%ebx),%eax
  1028c0:	89 04 24             	mov    %eax,(%esp)
  1028c3:	e8 48 fc ff ff       	call   102510 <lapicstartap>

    // Wait for cpu to finish mpmain()
    while(c->booted == 0)
  1028c8:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
  1028ce:	85 c0                	test   %eax,%eax
  1028d0:	74 f6                	je     1028c8 <mainc+0xe8>
  // The linker has placed the image of bootother.S in
  // _binary_bootother_start.
  code = (uchar*)0x7000;
  memmove(code, _binary_bootother_start, (uint)_binary_bootother_size);

  for(c = cpus; c < cpus+ncpu; c++){
  1028d2:	69 05 00 c1 10 00 bc 	imul   $0xbc,0x10c100,%eax
  1028d9:	00 00 00 
  1028dc:	81 c3 bc 00 00 00    	add    $0xbc,%ebx
  1028e2:	05 20 bb 10 00       	add    $0x10bb20,%eax
  1028e7:	39 c3                	cmp    %eax,%ebx
  1028e9:	72 9d                	jb     102888 <mainc+0xa8>
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
}
  1028eb:	83 c4 14             	add    $0x14,%esp
  1028ee:	5b                   	pop    %ebx
  1028ef:	5d                   	pop    %ebp
    timerinit();   // uniprocessor timer
  userinit();      // first user process
  bootothers();    // start other processors

  // Finish setting up this processor in mpmain.
  mpmain();
  1028f0:	e9 7b fe ff ff       	jmp    102770 <mpmain>
  binit();         // buffer cache
  fileinit();      // file table
  iinit();         // inode cache
  ideinit();       // disk
  if(!ismp)
    timerinit();   // uniprocessor timer
  1028f5:	e8 06 26 00 00       	call   104f00 <timerinit>
  1028fa:	e9 48 ff ff ff       	jmp    102847 <mainc+0x67>
  1028ff:	90                   	nop

00102900 <jmpkstack>:
  jmpkstack();       // call mainc() on a properly-allocated stack 
}

void
jmpkstack(void)
{
  102900:	55                   	push   %ebp
  102901:	89 e5                	mov    %esp,%ebp
  102903:	83 ec 18             	sub    $0x18,%esp
  char *kstack, *top;
  
  kstack = kalloc();
  102906:	e8 d5 f9 ff ff       	call   1022e0 <kalloc>
  if(kstack == 0)
  10290b:	85 c0                	test   %eax,%eax
  10290d:	74 19                	je     102928 <jmpkstack+0x28>
    panic("jmpkstack kalloc");
  top = kstack + PGSIZE;
  asm volatile("movl %0,%%esp; call mainc" : : "r" (top));
  10290f:	05 00 10 00 00       	add    $0x1000,%eax
  102914:	89 c4                	mov    %eax,%esp
  102916:	e8 c5 fe ff ff       	call   1027e0 <mainc>
  panic("jmpkstack");
  10291b:	c7 04 24 29 6b 10 00 	movl   $0x106b29,(%esp)
  102922:	e8 89 e0 ff ff       	call   1009b0 <panic>
  102927:	90                   	nop
{
  char *kstack, *top;
  
  kstack = kalloc();
  if(kstack == 0)
    panic("jmpkstack kalloc");
  102928:	c7 04 24 18 6b 10 00 	movl   $0x106b18,(%esp)
  10292f:	e8 7c e0 ff ff       	call   1009b0 <panic>
  102934:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10293a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00102940 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
  102940:	55                   	push   %ebp
  102941:	89 e5                	mov    %esp,%ebp
  102943:	83 e4 f0             	and    $0xfffffff0,%esp
  102946:	83 ec 10             	sub    $0x10,%esp
  mpinit();        // collect info about this machine
  102949:	e8 b2 00 00 00       	call   102a00 <mpinit>
  lapicinit(mpbcpu());
  10294e:	e8 1d 00 00 00       	call   102970 <mpbcpu>
  102953:	89 04 24             	mov    %eax,(%esp)
  102956:	e8 b5 fc ff ff       	call   102610 <lapicinit>
  seginit();       // set up segments
  10295b:	e8 30 3c 00 00       	call   106590 <seginit>
  kinit();         // initialize memory allocator
  102960:	e8 2b fa ff ff       	call   102390 <kinit>
  jmpkstack();       // call mainc() on a properly-allocated stack 
  102965:	e8 96 ff ff ff       	call   102900 <jmpkstack>
  10296a:	90                   	nop
  10296b:	90                   	nop
  10296c:	90                   	nop
  10296d:	90                   	nop
  10296e:	90                   	nop
  10296f:	90                   	nop

00102970 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  102970:	a1 c4 78 10 00       	mov    0x1078c4,%eax
  102975:	55                   	push   %ebp
  102976:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
}
  102978:	5d                   	pop    %ebp
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
  102979:	2d 20 bb 10 00       	sub    $0x10bb20,%eax
  10297e:	c1 f8 02             	sar    $0x2,%eax
  102981:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
  return bcpu-cpus;
}
  102987:	c3                   	ret    
  102988:	90                   	nop
  102989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102990 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102990:	55                   	push   %ebp
  102991:	89 e5                	mov    %esp,%ebp
  102993:	56                   	push   %esi
  102994:	53                   	push   %ebx
  uchar *e, *p;

  e = addr+len;
  102995:	8d 34 10             	lea    (%eax,%edx,1),%esi
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uchar *addr, int len)
{
  102998:	83 ec 10             	sub    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  10299b:	39 f0                	cmp    %esi,%eax
  10299d:	73 42                	jae    1029e1 <mpsearch1+0x51>
  10299f:	89 c3                	mov    %eax,%ebx
  1029a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  1029a8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  1029af:	00 
  1029b0:	c7 44 24 04 33 6b 10 	movl   $0x106b33,0x4(%esp)
  1029b7:	00 
  1029b8:	89 1c 24             	mov    %ebx,(%esp)
  1029bb:	e8 60 14 00 00       	call   103e20 <memcmp>
  1029c0:	85 c0                	test   %eax,%eax
  1029c2:	75 16                	jne    1029da <mpsearch1+0x4a>
  1029c4:	31 d2                	xor    %edx,%edx
  1029c6:	66 90                	xchg   %ax,%ax
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
  1029c8:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  1029cc:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  1029cf:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  1029d1:	83 f8 10             	cmp    $0x10,%eax
  1029d4:	75 f2                	jne    1029c8 <mpsearch1+0x38>
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  1029d6:	84 d2                	test   %dl,%dl
  1029d8:	74 10                	je     1029ea <mpsearch1+0x5a>
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  1029da:	83 c3 10             	add    $0x10,%ebx
  1029dd:	39 de                	cmp    %ebx,%esi
  1029df:	77 c7                	ja     1029a8 <mpsearch1+0x18>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  1029e1:	83 c4 10             	add    $0x10,%esp
mpsearch1(uchar *addr, int len)
{
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
  1029e4:	31 c0                	xor    %eax,%eax
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
  1029e6:	5b                   	pop    %ebx
  1029e7:	5e                   	pop    %esi
  1029e8:	5d                   	pop    %ebp
  1029e9:	c3                   	ret    
  1029ea:	83 c4 10             	add    $0x10,%esp
  uchar *e, *p;

  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  1029ed:	89 d8                	mov    %ebx,%eax
  return 0;
}
  1029ef:	5b                   	pop    %ebx
  1029f0:	5e                   	pop    %esi
  1029f1:	5d                   	pop    %ebp
  1029f2:	c3                   	ret    
  1029f3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1029f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102a00 <mpinit>:
  return conf;
}

void
mpinit(void)
{
  102a00:	55                   	push   %ebp
  102a01:	89 e5                	mov    %esp,%ebp
  102a03:	57                   	push   %edi
  102a04:	56                   	push   %esi
  102a05:	53                   	push   %ebx
  102a06:	83 ec 1c             	sub    $0x1c,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  102a09:	0f b6 05 0f 04 00 00 	movzbl 0x40f,%eax
  102a10:	0f b6 15 0e 04 00 00 	movzbl 0x40e,%edx
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  102a17:	c7 05 c4 78 10 00 20 	movl   $0x10bb20,0x1078c4
  102a1e:	bb 10 00 
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar*)0x400;
  if((p = ((bda[0x0F]<<8)|bda[0x0E]) << 4)){
  102a21:	c1 e0 08             	shl    $0x8,%eax
  102a24:	09 d0                	or     %edx,%eax
  102a26:	c1 e0 04             	shl    $0x4,%eax
  102a29:	85 c0                	test   %eax,%eax
  102a2b:	75 1b                	jne    102a48 <mpinit+0x48>
    if((mp = mpsearch1((uchar*)p, 1024)))
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
  102a2d:	0f b6 05 14 04 00 00 	movzbl 0x414,%eax
  102a34:	0f b6 15 13 04 00 00 	movzbl 0x413,%edx
  102a3b:	c1 e0 08             	shl    $0x8,%eax
  102a3e:	09 d0                	or     %edx,%eax
  102a40:	c1 e0 0a             	shl    $0xa,%eax
  102a43:	2d 00 04 00 00       	sub    $0x400,%eax
  102a48:	ba 00 04 00 00       	mov    $0x400,%edx
  102a4d:	e8 3e ff ff ff       	call   102990 <mpsearch1>
  102a52:	85 c0                	test   %eax,%eax
  102a54:	89 c6                	mov    %eax,%esi
  102a56:	0f 84 94 01 00 00    	je     102bf0 <mpinit+0x1f0>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102a5c:	8b 5e 04             	mov    0x4(%esi),%ebx
  102a5f:	85 db                	test   %ebx,%ebx
  102a61:	74 1c                	je     102a7f <mpinit+0x7f>
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
  102a63:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  102a6a:	00 
  102a6b:	c7 44 24 04 38 6b 10 	movl   $0x106b38,0x4(%esp)
  102a72:	00 
  102a73:	89 1c 24             	mov    %ebx,(%esp)
  102a76:	e8 a5 13 00 00       	call   103e20 <memcmp>
  102a7b:	85 c0                	test   %eax,%eax
  102a7d:	74 09                	je     102a88 <mpinit+0x88>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102a7f:	83 c4 1c             	add    $0x1c,%esp
  102a82:	5b                   	pop    %ebx
  102a83:	5e                   	pop    %esi
  102a84:	5f                   	pop    %edi
  102a85:	5d                   	pop    %ebp
  102a86:	c3                   	ret    
  102a87:	90                   	nop
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
    return 0;
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
  102a88:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
  102a8c:	3c 04                	cmp    $0x4,%al
  102a8e:	74 04                	je     102a94 <mpinit+0x94>
  102a90:	3c 01                	cmp    $0x1,%al
  102a92:	75 eb                	jne    102a7f <mpinit+0x7f>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102a94:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102a98:	85 ff                	test   %edi,%edi
  102a9a:	74 15                	je     102ab1 <mpinit+0xb1>
  102a9c:	31 d2                	xor    %edx,%edx
  102a9e:	31 c0                	xor    %eax,%eax
    sum += addr[i];
  102aa0:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102aa4:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
  102aa7:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
  102aa9:	39 c7                	cmp    %eax,%edi
  102aab:	7f f3                	jg     102aa0 <mpinit+0xa0>
  conf = (struct mpconf*)mp->physaddr;
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
  102aad:	84 d2                	test   %dl,%dl
  102aaf:	75 ce                	jne    102a7f <mpinit+0x7f>
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  102ab1:	c7 05 04 bb 10 00 01 	movl   $0x1,0x10bb04
  102ab8:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
  102abb:	8b 43 24             	mov    0x24(%ebx),%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102abe:	8d 7b 2c             	lea    0x2c(%ebx),%edi

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  102ac1:	a3 f8 ba 10 00       	mov    %eax,0x10baf8
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102ac6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
  102aca:	01 c3                	add    %eax,%ebx
  102acc:	39 df                	cmp    %ebx,%edi
  102ace:	72 29                	jb     102af9 <mpinit+0xf9>
  102ad0:	eb 52                	jmp    102b24 <mpinit+0x124>
  102ad2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case MPIOINTR:
    case MPLINTR:
      p += 8;
      continue;
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
  102ad8:	0f b6 c0             	movzbl %al,%eax
  102adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  102adf:	c7 04 24 58 6b 10 00 	movl   $0x106b58,(%esp)
  102ae6:	e8 d5 da ff ff       	call   1005c0 <cprintf>
      ismp = 0;
  102aeb:	c7 05 04 bb 10 00 00 	movl   $0x0,0x10bb04
  102af2:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102af5:	39 fb                	cmp    %edi,%ebx
  102af7:	76 1e                	jbe    102b17 <mpinit+0x117>
    switch(*p){
  102af9:	0f b6 07             	movzbl (%edi),%eax
  102afc:	3c 04                	cmp    $0x4,%al
  102afe:	77 d8                	ja     102ad8 <mpinit+0xd8>
  102b00:	0f b6 c0             	movzbl %al,%eax
  102b03:	ff 24 85 78 6b 10 00 	jmp    *0x106b78(,%eax,4)
  102b0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
  102b10:	83 c7 08             	add    $0x8,%edi
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
  102b13:	39 fb                	cmp    %edi,%ebx
  102b15:	77 e2                	ja     102af9 <mpinit+0xf9>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
  102b17:	a1 04 bb 10 00       	mov    0x10bb04,%eax
  102b1c:	85 c0                	test   %eax,%eax
  102b1e:	0f 84 a4 00 00 00    	je     102bc8 <mpinit+0x1c8>
    lapic = 0;
    ioapicid = 0;
    return;
  }

  if(mp->imcrp){
  102b24:	80 7e 0c 00          	cmpb   $0x0,0xc(%esi)
  102b28:	0f 84 51 ff ff ff    	je     102a7f <mpinit+0x7f>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102b2e:	ba 22 00 00 00       	mov    $0x22,%edx
  102b33:	b8 70 00 00 00       	mov    $0x70,%eax
  102b38:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  102b39:	b2 23                	mov    $0x23,%dl
  102b3b:	ec                   	in     (%dx),%al
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  102b3c:	83 c8 01             	or     $0x1,%eax
  102b3f:	ee                   	out    %al,(%dx)
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102b40:	83 c4 1c             	add    $0x1c,%esp
  102b43:	5b                   	pop    %ebx
  102b44:	5e                   	pop    %esi
  102b45:	5f                   	pop    %edi
  102b46:	5d                   	pop    %ebp
  102b47:	c3                   	ret    
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu != proc->apicid){
  102b48:	0f b6 57 01          	movzbl 0x1(%edi),%edx
  102b4c:	a1 00 c1 10 00       	mov    0x10c100,%eax
  102b51:	39 c2                	cmp    %eax,%edx
  102b53:	74 23                	je     102b78 <mpinit+0x178>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
  102b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b59:	89 54 24 08          	mov    %edx,0x8(%esp)
  102b5d:	c7 04 24 3d 6b 10 00 	movl   $0x106b3d,(%esp)
  102b64:	e8 57 da ff ff       	call   1005c0 <cprintf>
        ismp = 0;
  102b69:	a1 00 c1 10 00       	mov    0x10c100,%eax
  102b6e:	c7 05 04 bb 10 00 00 	movl   $0x0,0x10bb04
  102b75:	00 00 00 
      }
      if(proc->flags & MPBOOT)
  102b78:	f6 47 03 02          	testb  $0x2,0x3(%edi)
  102b7c:	74 12                	je     102b90 <mpinit+0x190>
        bcpu = &cpus[ncpu];
  102b7e:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
  102b84:	81 c2 20 bb 10 00    	add    $0x10bb20,%edx
  102b8a:	89 15 c4 78 10 00    	mov    %edx,0x1078c4
      cpus[ncpu].id = ncpu;
  102b90:	69 d0 bc 00 00 00    	imul   $0xbc,%eax,%edx
      ncpu++;
      p += sizeof(struct mpproc);
  102b96:	83 c7 14             	add    $0x14,%edi
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
        ismp = 0;
      }
      if(proc->flags & MPBOOT)
        bcpu = &cpus[ncpu];
      cpus[ncpu].id = ncpu;
  102b99:	88 82 20 bb 10 00    	mov    %al,0x10bb20(%edx)
      ncpu++;
  102b9f:	83 c0 01             	add    $0x1,%eax
  102ba2:	a3 00 c1 10 00       	mov    %eax,0x10c100
      p += sizeof(struct mpproc);
      continue;
  102ba7:	e9 49 ff ff ff       	jmp    102af5 <mpinit+0xf5>
  102bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102bb0:	0f b6 47 01          	movzbl 0x1(%edi),%eax
      p += sizeof(struct mpioapic);
  102bb4:	83 c7 08             	add    $0x8,%edi
      ncpu++;
      p += sizeof(struct mpproc);
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
  102bb7:	a2 00 bb 10 00       	mov    %al,0x10bb00
      p += sizeof(struct mpioapic);
      continue;
  102bbc:	e9 34 ff ff ff       	jmp    102af5 <mpinit+0xf5>
  102bc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ismp = 0;
    }
  }
  if(!ismp){
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
  102bc8:	c7 05 00 c1 10 00 01 	movl   $0x1,0x10c100
  102bcf:	00 00 00 
    lapic = 0;
  102bd2:	c7 05 f8 ba 10 00 00 	movl   $0x0,0x10baf8
  102bd9:	00 00 00 
    ioapicid = 0;
  102bdc:	c6 05 00 bb 10 00 00 	movb   $0x0,0x10bb00
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102be3:	83 c4 1c             	add    $0x1c,%esp
  102be6:	5b                   	pop    %ebx
  102be7:	5e                   	pop    %esi
  102be8:	5f                   	pop    %edi
  102be9:	5d                   	pop    %ebp
  102bea:	c3                   	ret    
  102beb:	90                   	nop
  102bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102bf0:	ba 00 00 01 00       	mov    $0x10000,%edx
  102bf5:	b8 00 00 0f 00       	mov    $0xf0000,%eax
  102bfa:	e8 91 fd ff ff       	call   102990 <mpsearch1>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102bff:	85 c0                	test   %eax,%eax
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1((uchar*)p-1024, 1024)))
      return mp;
  }
  return mpsearch1((uchar*)0xF0000, 0x10000);
  102c01:	89 c6                	mov    %eax,%esi
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
  102c03:	0f 85 53 fe ff ff    	jne    102a5c <mpinit+0x5c>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
  102c09:	83 c4 1c             	add    $0x1c,%esp
  102c0c:	5b                   	pop    %ebx
  102c0d:	5e                   	pop    %esi
  102c0e:	5f                   	pop    %edi
  102c0f:	5d                   	pop    %ebp
  102c10:	c3                   	ret    
  102c11:	90                   	nop
  102c12:	90                   	nop
  102c13:	90                   	nop
  102c14:	90                   	nop
  102c15:	90                   	nop
  102c16:	90                   	nop
  102c17:	90                   	nop
  102c18:	90                   	nop
  102c19:	90                   	nop
  102c1a:	90                   	nop
  102c1b:	90                   	nop
  102c1c:	90                   	nop
  102c1d:	90                   	nop
  102c1e:	90                   	nop
  102c1f:	90                   	nop

00102c20 <picenable>:
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102c20:	55                   	push   %ebp
  picsetmask(irqmask & ~(1<<irq));
  102c21:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
  102c26:	89 e5                	mov    %esp,%ebp
  102c28:	ba 21 00 00 00       	mov    $0x21,%edx
  picsetmask(irqmask & ~(1<<irq));
  102c2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102c30:	d3 c0                	rol    %cl,%eax
  102c32:	66 23 05 20 73 10 00 	and    0x107320,%ax
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
  irqmask = mask;
  102c39:	66 a3 20 73 10 00    	mov    %ax,0x107320
  102c3f:	ee                   	out    %al,(%dx)
  102c40:	66 c1 e8 08          	shr    $0x8,%ax
  102c44:	b2 a1                	mov    $0xa1,%dl
  102c46:	ee                   	out    %al,(%dx)

void
picenable(int irq)
{
  picsetmask(irqmask & ~(1<<irq));
}
  102c47:	5d                   	pop    %ebp
  102c48:	c3                   	ret    
  102c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102c50 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
  102c50:	55                   	push   %ebp
  102c51:	b9 21 00 00 00       	mov    $0x21,%ecx
  102c56:	89 e5                	mov    %esp,%ebp
  102c58:	83 ec 0c             	sub    $0xc,%esp
  102c5b:	89 1c 24             	mov    %ebx,(%esp)
  102c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102c63:	89 ca                	mov    %ecx,%edx
  102c65:	89 74 24 04          	mov    %esi,0x4(%esp)
  102c69:	89 7c 24 08          	mov    %edi,0x8(%esp)
  102c6d:	ee                   	out    %al,(%dx)
  102c6e:	bb a1 00 00 00       	mov    $0xa1,%ebx
  102c73:	89 da                	mov    %ebx,%edx
  102c75:	ee                   	out    %al,(%dx)
  102c76:	be 11 00 00 00       	mov    $0x11,%esi
  102c7b:	b2 20                	mov    $0x20,%dl
  102c7d:	89 f0                	mov    %esi,%eax
  102c7f:	ee                   	out    %al,(%dx)
  102c80:	b8 20 00 00 00       	mov    $0x20,%eax
  102c85:	89 ca                	mov    %ecx,%edx
  102c87:	ee                   	out    %al,(%dx)
  102c88:	b8 04 00 00 00       	mov    $0x4,%eax
  102c8d:	ee                   	out    %al,(%dx)
  102c8e:	bf 03 00 00 00       	mov    $0x3,%edi
  102c93:	89 f8                	mov    %edi,%eax
  102c95:	ee                   	out    %al,(%dx)
  102c96:	b1 a0                	mov    $0xa0,%cl
  102c98:	89 f0                	mov    %esi,%eax
  102c9a:	89 ca                	mov    %ecx,%edx
  102c9c:	ee                   	out    %al,(%dx)
  102c9d:	b8 28 00 00 00       	mov    $0x28,%eax
  102ca2:	89 da                	mov    %ebx,%edx
  102ca4:	ee                   	out    %al,(%dx)
  102ca5:	b8 02 00 00 00       	mov    $0x2,%eax
  102caa:	ee                   	out    %al,(%dx)
  102cab:	89 f8                	mov    %edi,%eax
  102cad:	ee                   	out    %al,(%dx)
  102cae:	be 68 00 00 00       	mov    $0x68,%esi
  102cb3:	b2 20                	mov    $0x20,%dl
  102cb5:	89 f0                	mov    %esi,%eax
  102cb7:	ee                   	out    %al,(%dx)
  102cb8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  102cbd:	89 d8                	mov    %ebx,%eax
  102cbf:	ee                   	out    %al,(%dx)
  102cc0:	89 f0                	mov    %esi,%eax
  102cc2:	89 ca                	mov    %ecx,%edx
  102cc4:	ee                   	out    %al,(%dx)
  102cc5:	89 d8                	mov    %ebx,%eax
  102cc7:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);             // read IRR by default

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
  102cc8:	0f b7 05 20 73 10 00 	movzwl 0x107320,%eax
  102ccf:	66 83 f8 ff          	cmp    $0xffffffff,%ax
  102cd3:	74 0a                	je     102cdf <picinit+0x8f>
  102cd5:	b2 21                	mov    $0x21,%dl
  102cd7:	ee                   	out    %al,(%dx)
  102cd8:	66 c1 e8 08          	shr    $0x8,%ax
  102cdc:	b2 a1                	mov    $0xa1,%dl
  102cde:	ee                   	out    %al,(%dx)
    picsetmask(irqmask);
}
  102cdf:	8b 1c 24             	mov    (%esp),%ebx
  102ce2:	8b 74 24 04          	mov    0x4(%esp),%esi
  102ce6:	8b 7c 24 08          	mov    0x8(%esp),%edi
  102cea:	89 ec                	mov    %ebp,%esp
  102cec:	5d                   	pop    %ebp
  102ced:	c3                   	ret    
  102cee:	90                   	nop
  102cef:	90                   	nop

00102cf0 <piperead>:
  return n;
}

int
piperead(struct pipe *p, char *addr, int n)
{
  102cf0:	55                   	push   %ebp
  102cf1:	89 e5                	mov    %esp,%ebp
  102cf3:	57                   	push   %edi
  102cf4:	56                   	push   %esi
  102cf5:	53                   	push   %ebx
  102cf6:	83 ec 1c             	sub    $0x1c,%esp
  102cf9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102cfc:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  acquire(&p->lock);
  102cff:	89 1c 24             	mov    %ebx,(%esp)
  102d02:	e8 59 10 00 00       	call   103d60 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102d07:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102d0d:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102d13:	75 58                	jne    102d6d <piperead+0x7d>
  102d15:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102d1b:	85 f6                	test   %esi,%esi
  102d1d:	74 4e                	je     102d6d <piperead+0x7d>
    if(proc->killed){
  102d1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102d25:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
  102d2b:	8b 48 24             	mov    0x24(%eax),%ecx
  102d2e:	85 c9                	test   %ecx,%ecx
  102d30:	74 21                	je     102d53 <piperead+0x63>
  102d32:	e9 99 00 00 00       	jmp    102dd0 <piperead+0xe0>
  102d37:	90                   	nop
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102d38:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
  102d3e:	85 c0                	test   %eax,%eax
  102d40:	74 2b                	je     102d6d <piperead+0x7d>
    if(proc->killed){
  102d42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102d48:	8b 50 24             	mov    0x24(%eax),%edx
  102d4b:	85 d2                	test   %edx,%edx
  102d4d:	0f 85 7d 00 00 00    	jne    102dd0 <piperead+0xe0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  102d53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102d57:	89 34 24             	mov    %esi,(%esp)
  102d5a:	e8 81 05 00 00       	call   1032e0 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
  102d5f:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102d65:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102d6b:	74 cb                	je     102d38 <piperead+0x48>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d6d:	85 ff                	test   %edi,%edi
  102d6f:	7e 76                	jle    102de7 <piperead+0xf7>
    if(p->nread == p->nwrite)
  102d71:	31 f6                	xor    %esi,%esi
  102d73:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
  102d79:	75 0d                	jne    102d88 <piperead+0x98>
  102d7b:	eb 6a                	jmp    102de7 <piperead+0xf7>
  102d7d:	8d 76 00             	lea    0x0(%esi),%esi
  102d80:	39 93 38 02 00 00    	cmp    %edx,0x238(%ebx)
  102d86:	74 22                	je     102daa <piperead+0xba>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102d88:	89 d0                	mov    %edx,%eax
  102d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  102d8d:	83 c2 01             	add    $0x1,%edx
  102d90:	25 ff 01 00 00       	and    $0x1ff,%eax
  102d95:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
  102d9a:	88 04 31             	mov    %al,(%ecx,%esi,1)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102d9d:	83 c6 01             	add    $0x1,%esi
  102da0:	39 f7                	cmp    %esi,%edi
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  102da2:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102da8:	7f d6                	jg     102d80 <piperead+0x90>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  102daa:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  102db0:	89 04 24             	mov    %eax,(%esp)
  102db3:	e8 08 04 00 00       	call   1031c0 <wakeup>
  release(&p->lock);
  102db8:	89 1c 24             	mov    %ebx,(%esp)
  102dbb:	e8 50 0f 00 00       	call   103d10 <release>
  return i;
}
  102dc0:	83 c4 1c             	add    $0x1c,%esp
  102dc3:	89 f0                	mov    %esi,%eax
  102dc5:	5b                   	pop    %ebx
  102dc6:	5e                   	pop    %esi
  102dc7:	5f                   	pop    %edi
  102dc8:	5d                   	pop    %ebp
  102dc9:	c3                   	ret    
  102dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
      release(&p->lock);
  102dd0:	be ff ff ff ff       	mov    $0xffffffff,%esi
  102dd5:	89 1c 24             	mov    %ebx,(%esp)
  102dd8:	e8 33 0f 00 00       	call   103d10 <release>
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
  102ddd:	83 c4 1c             	add    $0x1c,%esp
  102de0:	89 f0                	mov    %esi,%eax
  102de2:	5b                   	pop    %ebx
  102de3:	5e                   	pop    %esi
  102de4:	5f                   	pop    %edi
  102de5:	5d                   	pop    %ebp
  102de6:	c3                   	ret    
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
  102de7:	31 f6                	xor    %esi,%esi
  102de9:	eb bf                	jmp    102daa <piperead+0xba>
  102deb:	90                   	nop
  102dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00102df0 <pipewrite>:
    release(&p->lock);
}

int
pipewrite(struct pipe *p, char *addr, int n)
{
  102df0:	55                   	push   %ebp
  102df1:	89 e5                	mov    %esp,%ebp
  102df3:	57                   	push   %edi
  102df4:	56                   	push   %esi
  102df5:	53                   	push   %ebx
  102df6:	83 ec 3c             	sub    $0x3c,%esp
  102df9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
  102dfc:	89 1c 24             	mov    %ebx,(%esp)
  102dff:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
  102e05:	e8 56 0f 00 00       	call   103d60 <acquire>
  for(i = 0; i < n; i++){
  102e0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  102e0d:	85 c9                	test   %ecx,%ecx
  102e0f:	0f 8e 8d 00 00 00    	jle    102ea2 <pipewrite+0xb2>
  102e15:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102e1b:	8d bb 38 02 00 00    	lea    0x238(%ebx),%edi
  102e21:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  102e28:	eb 37                	jmp    102e61 <pipewrite+0x71>
  102e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
  102e30:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102e36:	85 c0                	test   %eax,%eax
  102e38:	74 7e                	je     102eb8 <pipewrite+0xc8>
  102e3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  102e40:	8b 50 24             	mov    0x24(%eax),%edx
  102e43:	85 d2                	test   %edx,%edx
  102e45:	75 71                	jne    102eb8 <pipewrite+0xc8>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
  102e47:	89 34 24             	mov    %esi,(%esp)
  102e4a:	e8 71 03 00 00       	call   1031c0 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
  102e4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102e53:	89 3c 24             	mov    %edi,(%esp)
  102e56:	e8 85 04 00 00       	call   1032e0 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
  102e5b:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
  102e61:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
  102e67:	81 c2 00 02 00 00    	add    $0x200,%edx
  102e6d:	39 d0                	cmp    %edx,%eax
  102e6f:	74 bf                	je     102e30 <pipewrite+0x40>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  102e71:	89 c2                	mov    %eax,%edx
  102e73:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102e76:	83 c0 01             	add    $0x1,%eax
  102e79:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  102e7f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e82:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e85:	0f b6 0c 0a          	movzbl (%edx,%ecx,1),%ecx
  102e89:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e8c:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
  102e90:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
  102e96:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  102e9a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  102e9d:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  102ea0:	7f bf                	jg     102e61 <pipewrite+0x71>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  102ea2:	89 34 24             	mov    %esi,(%esp)
  102ea5:	e8 16 03 00 00       	call   1031c0 <wakeup>
  release(&p->lock);
  102eaa:	89 1c 24             	mov    %ebx,(%esp)
  102ead:	e8 5e 0e 00 00       	call   103d10 <release>
  return n;
  102eb2:	eb 13                	jmp    102ec7 <pipewrite+0xd7>
  102eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
  102eb8:	89 1c 24             	mov    %ebx,(%esp)
  102ebb:	e8 50 0e 00 00       	call   103d10 <release>
  102ec0:	c7 45 10 ff ff ff ff 	movl   $0xffffffff,0x10(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
  102ec7:	8b 45 10             	mov    0x10(%ebp),%eax
  102eca:	83 c4 3c             	add    $0x3c,%esp
  102ecd:	5b                   	pop    %ebx
  102ece:	5e                   	pop    %esi
  102ecf:	5f                   	pop    %edi
  102ed0:	5d                   	pop    %ebp
  102ed1:	c3                   	ret    
  102ed2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  102ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00102ee0 <pipeclose>:
  return -1;
}

void
pipeclose(struct pipe *p, int writable)
{
  102ee0:	55                   	push   %ebp
  102ee1:	89 e5                	mov    %esp,%ebp
  102ee3:	83 ec 18             	sub    $0x18,%esp
  102ee6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  102ee9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  102eec:	89 75 fc             	mov    %esi,-0x4(%ebp)
  102eef:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
  102ef2:	89 1c 24             	mov    %ebx,(%esp)
  102ef5:	e8 66 0e 00 00       	call   103d60 <acquire>
  if(writable){
  102efa:	85 f6                	test   %esi,%esi
  102efc:	74 42                	je     102f40 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
  102efe:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
void
pipeclose(struct pipe *p, int writable)
{
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
  102f04:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
  102f0b:	00 00 00 
    wakeup(&p->nread);
  102f0e:	89 04 24             	mov    %eax,(%esp)
  102f11:	e8 aa 02 00 00       	call   1031c0 <wakeup>
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
  102f16:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
  102f1c:	85 c0                	test   %eax,%eax
  102f1e:	75 0a                	jne    102f2a <pipeclose+0x4a>
  102f20:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
  102f26:	85 f6                	test   %esi,%esi
  102f28:	74 36                	je     102f60 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102f2a:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  102f2d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  102f30:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102f33:	89 ec                	mov    %ebp,%esp
  102f35:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
  102f36:	e9 d5 0d 00 00       	jmp    103d10 <release>
  102f3b:	90                   	nop
  102f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  102f40:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
  102f46:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
  102f4d:	00 00 00 
    wakeup(&p->nwrite);
  102f50:	89 04 24             	mov    %eax,(%esp)
  102f53:	e8 68 02 00 00       	call   1031c0 <wakeup>
  102f58:	eb bc                	jmp    102f16 <pipeclose+0x36>
  102f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
  102f60:	89 1c 24             	mov    %ebx,(%esp)
  102f63:	e8 a8 0d 00 00       	call   103d10 <release>
    kfree((char*)p);
  } else
    release(&p->lock);
}
  102f68:	8b 75 fc             	mov    -0x4(%ebp),%esi
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102f6b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  } else
    release(&p->lock);
}
  102f6e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  102f71:	89 ec                	mov    %ebp,%esp
  102f73:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  102f74:	e9 a7 f3 ff ff       	jmp    102320 <kfree>
  102f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00102f80 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
  102f80:	55                   	push   %ebp
  102f81:	89 e5                	mov    %esp,%ebp
  102f83:	57                   	push   %edi
  102f84:	56                   	push   %esi
  102f85:	53                   	push   %ebx
  102f86:	83 ec 1c             	sub    $0x1c,%esp
  102f89:	8b 75 08             	mov    0x8(%ebp),%esi
  102f8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
  102f8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  102f95:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
  102f9b:	e8 e0 df ff ff       	call   100f80 <filealloc>
  102fa0:	85 c0                	test   %eax,%eax
  102fa2:	89 06                	mov    %eax,(%esi)
  102fa4:	0f 84 9c 00 00 00    	je     103046 <pipealloc+0xc6>
  102faa:	e8 d1 df ff ff       	call   100f80 <filealloc>
  102faf:	85 c0                	test   %eax,%eax
  102fb1:	89 03                	mov    %eax,(%ebx)
  102fb3:	0f 84 7f 00 00 00    	je     103038 <pipealloc+0xb8>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
  102fb9:	e8 22 f3 ff ff       	call   1022e0 <kalloc>
  102fbe:	85 c0                	test   %eax,%eax
  102fc0:	89 c7                	mov    %eax,%edi
  102fc2:	74 74                	je     103038 <pipealloc+0xb8>
    goto bad;
  p->readopen = 1;
  102fc4:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
  102fcb:	00 00 00 
  p->writeopen = 1;
  102fce:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
  102fd5:	00 00 00 
  p->nwrite = 0;
  102fd8:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
  102fdf:	00 00 00 
  p->nread = 0;
  102fe2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
  102fe9:	00 00 00 
  initlock(&p->lock, "pipe");
  102fec:	89 04 24             	mov    %eax,(%esp)
  102fef:	c7 44 24 04 8c 6b 10 	movl   $0x106b8c,0x4(%esp)
  102ff6:	00 
  102ff7:	e8 d4 0b 00 00       	call   103bd0 <initlock>
  (*f0)->type = FD_PIPE;
  102ffc:	8b 06                	mov    (%esi),%eax
  102ffe:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
  103004:	8b 06                	mov    (%esi),%eax
  103006:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
  10300a:	8b 06                	mov    (%esi),%eax
  10300c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
  103010:	8b 06                	mov    (%esi),%eax
  103012:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
  103015:	8b 03                	mov    (%ebx),%eax
  103017:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
  10301d:	8b 03                	mov    (%ebx),%eax
  10301f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
  103023:	8b 03                	mov    (%ebx),%eax
  103025:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
  103029:	8b 03                	mov    (%ebx),%eax
  10302b:	89 78 0c             	mov    %edi,0xc(%eax)
  10302e:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
  103030:	83 c4 1c             	add    $0x1c,%esp
  103033:	5b                   	pop    %ebx
  103034:	5e                   	pop    %esi
  103035:	5f                   	pop    %edi
  103036:	5d                   	pop    %ebp
  103037:	c3                   	ret    
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
  103038:	8b 06                	mov    (%esi),%eax
  10303a:	85 c0                	test   %eax,%eax
  10303c:	74 08                	je     103046 <pipealloc+0xc6>
    fileclose(*f0);
  10303e:	89 04 24             	mov    %eax,(%esp)
  103041:	e8 ba df ff ff       	call   101000 <fileclose>
  if(*f1)
  103046:	8b 13                	mov    (%ebx),%edx
  103048:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10304d:	85 d2                	test   %edx,%edx
  10304f:	74 df                	je     103030 <pipealloc+0xb0>
    fileclose(*f1);
  103051:	89 14 24             	mov    %edx,(%esp)
  103054:	e8 a7 df ff ff       	call   101000 <fileclose>
  103059:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10305e:	eb d0                	jmp    103030 <pipealloc+0xb0>

00103060 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  103060:	55                   	push   %ebp
  103061:	89 e5                	mov    %esp,%ebp
  103063:	57                   	push   %edi
  103064:	56                   	push   %esi
  103065:	53                   	push   %ebx

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
  103066:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
{
  10306b:	83 ec 4c             	sub    $0x4c,%esp
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  10306e:	8d 7d c0             	lea    -0x40(%ebp),%edi
  103071:	eb 4b                	jmp    1030be <procdump+0x5e>
  103073:	90                   	nop
  103074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  103078:	8b 04 85 70 6c 10 00 	mov    0x106c70(,%eax,4),%eax
  10307f:	85 c0                	test   %eax,%eax
  103081:	74 47                	je     1030ca <procdump+0x6a>
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
  103083:	8b 53 10             	mov    0x10(%ebx),%edx
  103086:	8d 4b 6c             	lea    0x6c(%ebx),%ecx
  103089:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10308d:	89 44 24 08          	mov    %eax,0x8(%esp)
  103091:	c7 04 24 95 6b 10 00 	movl   $0x106b95,(%esp)
  103098:	89 54 24 04          	mov    %edx,0x4(%esp)
  10309c:	e8 1f d5 ff ff       	call   1005c0 <cprintf>
    if(p->state == SLEEPING){
  1030a1:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
  1030a5:	74 31                	je     1030d8 <procdump+0x78>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  1030a7:	c7 04 24 16 6b 10 00 	movl   $0x106b16,(%esp)
  1030ae:	e8 0d d5 ff ff       	call   1005c0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1030b3:	83 c3 7c             	add    $0x7c,%ebx
  1030b6:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  1030bc:	74 5a                	je     103118 <procdump+0xb8>
    if(p->state == UNUSED)
  1030be:	8b 43 0c             	mov    0xc(%ebx),%eax
  1030c1:	85 c0                	test   %eax,%eax
  1030c3:	74 ee                	je     1030b3 <procdump+0x53>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
  1030c5:	83 f8 05             	cmp    $0x5,%eax
  1030c8:	76 ae                	jbe    103078 <procdump+0x18>
  1030ca:	b8 91 6b 10 00       	mov    $0x106b91,%eax
  1030cf:	eb b2                	jmp    103083 <procdump+0x23>
  1030d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
  1030d8:	8b 43 1c             	mov    0x1c(%ebx),%eax
  1030db:	31 f6                	xor    %esi,%esi
  1030dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1030e1:	8b 40 0c             	mov    0xc(%eax),%eax
  1030e4:	83 c0 08             	add    $0x8,%eax
  1030e7:	89 04 24             	mov    %eax,(%esp)
  1030ea:	e8 01 0b 00 00       	call   103bf0 <getcallerpcs>
  1030ef:	90                   	nop
      for(i=0; i<10 && pc[i] != 0; i++)
  1030f0:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  1030f3:	85 c0                	test   %eax,%eax
  1030f5:	74 b0                	je     1030a7 <procdump+0x47>
  1030f7:	83 c6 01             	add    $0x1,%esi
        cprintf(" %p", pc[i]);
  1030fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030fe:	c7 04 24 1a 67 10 00 	movl   $0x10671a,(%esp)
  103105:	e8 b6 d4 ff ff       	call   1005c0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
  10310a:	83 fe 0a             	cmp    $0xa,%esi
  10310d:	75 e1                	jne    1030f0 <procdump+0x90>
  10310f:	eb 96                	jmp    1030a7 <procdump+0x47>
  103111:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
  103118:	83 c4 4c             	add    $0x4c,%esp
  10311b:	5b                   	pop    %ebx
  10311c:	5e                   	pop    %esi
  10311d:	5f                   	pop    %edi
  10311e:	5d                   	pop    %ebp
  10311f:	90                   	nop
  103120:	c3                   	ret    
  103121:	eb 0d                	jmp    103130 <kill>
  103123:	90                   	nop
  103124:	90                   	nop
  103125:	90                   	nop
  103126:	90                   	nop
  103127:	90                   	nop
  103128:	90                   	nop
  103129:	90                   	nop
  10312a:	90                   	nop
  10312b:	90                   	nop
  10312c:	90                   	nop
  10312d:	90                   	nop
  10312e:	90                   	nop
  10312f:	90                   	nop

00103130 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  103130:	55                   	push   %ebp
  103131:	89 e5                	mov    %esp,%ebp
  103133:	53                   	push   %ebx
  103134:	83 ec 14             	sub    $0x14,%esp
  103137:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
  10313a:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103141:	e8 1a 0c 00 00       	call   103d60 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  103146:	8b 15 64 c1 10 00    	mov    0x10c164,%edx

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
  10314c:	b8 d0 c1 10 00       	mov    $0x10c1d0,%eax
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  103151:	39 da                	cmp    %ebx,%edx
  103153:	75 0d                	jne    103162 <kill+0x32>
  103155:	eb 60                	jmp    1031b7 <kill+0x87>
  103157:	90                   	nop
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103158:	83 c0 7c             	add    $0x7c,%eax
  10315b:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  103160:	74 3e                	je     1031a0 <kill+0x70>
    if(p->pid == pid){
  103162:	8b 50 10             	mov    0x10(%eax),%edx
  103165:	39 da                	cmp    %ebx,%edx
  103167:	75 ef                	jne    103158 <kill+0x28>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  103169:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
  10316d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
  103174:	74 1a                	je     103190 <kill+0x60>
        p->state = RUNNABLE;
      release(&ptable.lock);
  103176:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10317d:	e8 8e 0b 00 00       	call   103d10 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  103182:	83 c4 14             	add    $0x14,%esp
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
  103185:	31 c0                	xor    %eax,%eax
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
  103187:	5b                   	pop    %ebx
  103188:	5d                   	pop    %ebp
  103189:	c3                   	ret    
  10318a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
  103190:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  103197:	eb dd                	jmp    103176 <kill+0x46>
  103199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  1031a0:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1031a7:	e8 64 0b 00 00       	call   103d10 <release>
  return -1;
}
  1031ac:	83 c4 14             	add    $0x14,%esp
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  1031af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
  1031b4:	5b                   	pop    %ebx
  1031b5:	5d                   	pop    %ebp
  1031b6:	c3                   	ret    
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
  1031b7:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  1031bc:	eb ab                	jmp    103169 <kill+0x39>
  1031be:	66 90                	xchg   %ax,%ax

001031c0 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  1031c0:	55                   	push   %ebp
  1031c1:	89 e5                	mov    %esp,%ebp
  1031c3:	53                   	push   %ebx
  1031c4:	83 ec 14             	sub    $0x14,%esp
  1031c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
  1031ca:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1031d1:	e8 8a 0b 00 00       	call   103d60 <acquire>
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
  1031d6:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  1031db:	eb 0d                	jmp    1031ea <wakeup+0x2a>
  1031dd:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1031e0:	83 c0 7c             	add    $0x7c,%eax
  1031e3:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  1031e8:	74 1e                	je     103208 <wakeup+0x48>
    if(p->state == SLEEPING && p->chan == chan)
  1031ea:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  1031ee:	75 f0                	jne    1031e0 <wakeup+0x20>
  1031f0:	3b 58 20             	cmp    0x20(%eax),%ebx
  1031f3:	75 eb                	jne    1031e0 <wakeup+0x20>
      p->state = RUNNABLE;
  1031f5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1031fc:	83 c0 7c             	add    $0x7c,%eax
  1031ff:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  103204:	75 e4                	jne    1031ea <wakeup+0x2a>
  103206:	66 90                	xchg   %ax,%ax
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  103208:	c7 45 08 20 c1 10 00 	movl   $0x10c120,0x8(%ebp)
}
  10320f:	83 c4 14             	add    $0x14,%esp
  103212:	5b                   	pop    %ebx
  103213:	5d                   	pop    %ebp
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
  103214:	e9 f7 0a 00 00       	jmp    103d10 <release>
  103219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103220 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  103220:	55                   	push   %ebp
  103221:	89 e5                	mov    %esp,%ebp
  103223:	83 ec 18             	sub    $0x18,%esp
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
  103226:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10322d:	e8 de 0a 00 00       	call   103d10 <release>
  
  // Return to "caller", actually trapret (see allocproc).
}
  103232:	c9                   	leave  
  103233:	c3                   	ret    
  103234:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10323a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103240 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  103240:	55                   	push   %ebp
  103241:	89 e5                	mov    %esp,%ebp
  103243:	53                   	push   %ebx
  103244:	83 ec 14             	sub    $0x14,%esp
  int intena;

  if(!holding(&ptable.lock))
  103247:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10324e:	e8 fd 09 00 00       	call   103c50 <holding>
  103253:	85 c0                	test   %eax,%eax
  103255:	74 4d                	je     1032a4 <sched+0x64>
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
  103257:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10325d:	83 b8 ac 00 00 00 01 	cmpl   $0x1,0xac(%eax)
  103264:	75 62                	jne    1032c8 <sched+0x88>
    panic("sched locks");
  if(proc->state == RUNNING)
  103266:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10326d:	83 7a 0c 04          	cmpl   $0x4,0xc(%edx)
  103271:	74 49                	je     1032bc <sched+0x7c>

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103273:	9c                   	pushf  
  103274:	59                   	pop    %ecx
    panic("sched running");
  if(readeflags()&FL_IF)
  103275:	80 e5 02             	and    $0x2,%ch
  103278:	75 36                	jne    1032b0 <sched+0x70>
    panic("sched interruptible");
  intena = cpu->intena;
  10327a:	8b 98 b0 00 00 00    	mov    0xb0(%eax),%ebx
  swtch(&proc->context, cpu->scheduler);
  103280:	83 c2 1c             	add    $0x1c,%edx
  103283:	8b 40 04             	mov    0x4(%eax),%eax
  103286:	89 14 24             	mov    %edx,(%esp)
  103289:	89 44 24 04          	mov    %eax,0x4(%esp)
  10328d:	e8 6a 0d 00 00       	call   103ffc <swtch>
  cpu->intena = intena;
  103292:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103298:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  10329e:	83 c4 14             	add    $0x14,%esp
  1032a1:	5b                   	pop    %ebx
  1032a2:	5d                   	pop    %ebp
  1032a3:	c3                   	ret    
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  1032a4:	c7 04 24 9e 6b 10 00 	movl   $0x106b9e,(%esp)
  1032ab:	e8 00 d7 ff ff       	call   1009b0 <panic>
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  1032b0:	c7 04 24 ca 6b 10 00 	movl   $0x106bca,(%esp)
  1032b7:	e8 f4 d6 ff ff       	call   1009b0 <panic>
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  1032bc:	c7 04 24 bc 6b 10 00 	movl   $0x106bbc,(%esp)
  1032c3:	e8 e8 d6 ff ff       	call   1009b0 <panic>
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  1032c8:	c7 04 24 b0 6b 10 00 	movl   $0x106bb0,(%esp)
  1032cf:	e8 dc d6 ff ff       	call   1009b0 <panic>
  1032d4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1032da:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001032e0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  1032e0:	55                   	push   %ebp
  1032e1:	89 e5                	mov    %esp,%ebp
  1032e3:	56                   	push   %esi
  1032e4:	53                   	push   %ebx
  1032e5:	83 ec 10             	sub    $0x10,%esp
  if(proc == 0)
  1032e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  1032ee:	8b 75 08             	mov    0x8(%ebp),%esi
  1032f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(proc == 0)
  1032f4:	85 c0                	test   %eax,%eax
  1032f6:	0f 84 a1 00 00 00    	je     10339d <sleep+0xbd>
    panic("sleep");

  if(lk == 0)
  1032fc:	85 db                	test   %ebx,%ebx
  1032fe:	0f 84 8d 00 00 00    	je     103391 <sleep+0xb1>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
  103304:	81 fb 20 c1 10 00    	cmp    $0x10c120,%ebx
  10330a:	74 5c                	je     103368 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
  10330c:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103313:	e8 48 0a 00 00       	call   103d60 <acquire>
    release(lk);
  103318:	89 1c 24             	mov    %ebx,(%esp)
  10331b:	e8 f0 09 00 00       	call   103d10 <release>
  }

  // Go to sleep.
  proc->chan = chan;
  103320:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103326:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  103329:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10332f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  103336:	e8 05 ff ff ff       	call   103240 <sched>

  // Tidy up.
  proc->chan = 0;
  10333b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103341:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
  103348:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10334f:	e8 bc 09 00 00       	call   103d10 <release>
    acquire(lk);
  103354:	89 5d 08             	mov    %ebx,0x8(%ebp)
  }
}
  103357:	83 c4 10             	add    $0x10,%esp
  10335a:	5b                   	pop    %ebx
  10335b:	5e                   	pop    %esi
  10335c:	5d                   	pop    %ebp
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  10335d:	e9 fe 09 00 00       	jmp    103d60 <acquire>
  103362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  103368:	89 70 20             	mov    %esi,0x20(%eax)
  proc->state = SLEEPING;
  10336b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103371:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
  103378:	e8 c3 fe ff ff       	call   103240 <sched>

  // Tidy up.
  proc->chan = 0;
  10337d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103383:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}
  10338a:	83 c4 10             	add    $0x10,%esp
  10338d:	5b                   	pop    %ebx
  10338e:	5e                   	pop    %esi
  10338f:	5d                   	pop    %ebp
  103390:	c3                   	ret    
{
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");
  103391:	c7 04 24 e4 6b 10 00 	movl   $0x106be4,(%esp)
  103398:	e8 13 d6 ff ff       	call   1009b0 <panic>
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");
  10339d:	c7 04 24 de 6b 10 00 	movl   $0x106bde,(%esp)
  1033a4:	e8 07 d6 ff ff       	call   1009b0 <panic>
  1033a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

001033b0 <yield>:
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  1033b0:	55                   	push   %ebp
  1033b1:	89 e5                	mov    %esp,%ebp
  1033b3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
  1033b6:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1033bd:	e8 9e 09 00 00       	call   103d60 <acquire>
  proc->state = RUNNABLE;
  1033c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1033c8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
  1033cf:	e8 6c fe ff ff       	call   103240 <sched>
  release(&ptable.lock);
  1033d4:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1033db:	e8 30 09 00 00       	call   103d10 <release>
}
  1033e0:	c9                   	leave  
  1033e1:	c3                   	ret    
  1033e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1033e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001033f0 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  1033f0:	55                   	push   %ebp
  1033f1:	89 e5                	mov    %esp,%ebp
  1033f3:	53                   	push   %ebx
  1033f4:	83 ec 14             	sub    $0x14,%esp
  1033f7:	90                   	nop
}

static inline void
sti(void)
{
  asm volatile("sti");
  1033f8:	fb                   	sti    
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
  1033f9:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
  1033fe:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103405:	e8 56 09 00 00       	call   103d60 <acquire>
  10340a:	eb 0f                	jmp    10341b <scheduler+0x2b>
  10340c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103410:	83 c3 7c             	add    $0x7c,%ebx
  103413:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103419:	74 5d                	je     103478 <scheduler+0x88>
      if(p->state != RUNNABLE)
  10341b:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
  10341f:	90                   	nop
  103420:	75 ee                	jne    103410 <scheduler+0x20>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
  103422:	65 89 1d 04 00 00 00 	mov    %ebx,%gs:0x4
      switchuvm(p);
  103429:	89 1c 24             	mov    %ebx,(%esp)
  10342c:	e8 af 30 00 00       	call   1064e0 <switchuvm>
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  103431:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
  103437:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  10343e:	83 c3 7c             	add    $0x7c,%ebx
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
  103441:	8b 40 1c             	mov    0x1c(%eax),%eax
  103444:	89 44 24 04          	mov    %eax,0x4(%esp)
  103448:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10344e:	83 c0 04             	add    $0x4,%eax
  103451:	89 04 24             	mov    %eax,(%esp)
  103454:	e8 a3 0b 00 00       	call   103ffc <swtch>
      switchkvm();
  103459:	e8 12 2a 00 00       	call   105e70 <switchkvm>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  10345e:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
  103464:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  10346b:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  10346f:	75 aa                	jne    10341b <scheduler+0x2b>
  103471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
  103478:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10347f:	e8 8c 08 00 00       	call   103d10 <release>

  }
  103484:	e9 6f ff ff ff       	jmp    1033f8 <scheduler+0x8>
  103489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103490 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103490:	55                   	push   %ebp
  103491:	89 e5                	mov    %esp,%ebp
  103493:	53                   	push   %ebx
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  103494:	bb 54 c1 10 00       	mov    $0x10c154,%ebx

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  103499:	83 ec 24             	sub    $0x24,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  10349c:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1034a3:	e8 b8 08 00 00       	call   103d60 <acquire>
  1034a8:	31 c0                	xor    %eax,%eax
  1034aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1034b0:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  1034b6:	72 30                	jb     1034e8 <wait+0x58>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
  1034b8:	85 c0                	test   %eax,%eax
  1034ba:	74 5c                	je     103518 <wait+0x88>
  1034bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1034c2:	8b 50 24             	mov    0x24(%eax),%edx
  1034c5:	85 d2                	test   %edx,%edx
  1034c7:	75 4f                	jne    103518 <wait+0x88>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  1034c9:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  1034ce:	89 04 24             	mov    %eax,(%esp)
  1034d1:	c7 44 24 04 20 c1 10 	movl   $0x10c120,0x4(%esp)
  1034d8:	00 
  1034d9:	e8 02 fe ff ff       	call   1032e0 <sleep>
  1034de:	31 c0                	xor    %eax,%eax

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1034e0:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  1034e6:	73 d0                	jae    1034b8 <wait+0x28>
      if(p->parent != proc)
  1034e8:	8b 53 14             	mov    0x14(%ebx),%edx
  1034eb:	65 3b 15 04 00 00 00 	cmp    %gs:0x4,%edx
  1034f2:	74 0c                	je     103500 <wait+0x70>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  1034f4:	83 c3 7c             	add    $0x7c,%ebx
  1034f7:	eb b7                	jmp    1034b0 <wait+0x20>
  1034f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
  103500:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
  103504:	74 29                	je     10352f <wait+0x9f>
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
  103506:	b8 01 00 00 00       	mov    $0x1,%eax
  10350b:	90                   	nop
  10350c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103510:	eb e2                	jmp    1034f4 <wait+0x64>
  103512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
  103518:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10351f:	e8 ec 07 00 00       	call   103d10 <release>
  103524:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
  103529:	83 c4 24             	add    $0x24,%esp
  10352c:	5b                   	pop    %ebx
  10352d:	5d                   	pop    %ebp
  10352e:	c3                   	ret    
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
  10352f:	8b 43 10             	mov    0x10(%ebx),%eax
        kfree(p->kstack);
  103532:	8b 53 08             	mov    0x8(%ebx),%edx
  103535:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103538:	89 14 24             	mov    %edx,(%esp)
  10353b:	e8 e0 ed ff ff       	call   102320 <kfree>
        p->kstack = 0;
        if (p->pgdir != p->parent->pgdir) {
  103540:	8b 4b 14             	mov    0x14(%ebx),%ecx
  103543:	8b 53 04             	mov    0x4(%ebx),%edx
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
  103546:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        if (p->pgdir != p->parent->pgdir) {
  10354d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103550:	3b 51 04             	cmp    0x4(%ecx),%edx
  103553:	74 0b                	je     103560 <wait+0xd0>
          freevm(p->pgdir);
  103555:	89 14 24             	mov    %edx,(%esp)
  103558:	e8 b3 2c 00 00       	call   106210 <freevm>
  10355d:	8b 45 f4             	mov    -0xc(%ebp),%eax
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
  103560:	89 45 f4             	mov    %eax,-0xc(%ebp)
        kfree(p->kstack);
        p->kstack = 0;
        if (p->pgdir != p->parent->pgdir) {
          freevm(p->pgdir);
        }
        p->state = UNUSED;
  103563:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->pid = 0;
  10356a:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
  103571:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
  103578:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
  10357c:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        release(&ptable.lock);
  103583:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10358a:	e8 81 07 00 00       	call   103d10 <release>
        return pid;
  10358f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103592:	eb 95                	jmp    103529 <wait+0x99>
  103594:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10359a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001035a0 <exit>:
  return pid;
}

void
exit(void)
{
  1035a0:	55                   	push   %ebp
  1035a1:	89 e5                	mov    %esp,%ebp
  1035a3:	56                   	push   %esi
  1035a4:	53                   	push   %ebx
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  1035a5:	31 db                	xor    %ebx,%ebx
  return pid;
}

void
exit(void)
{
  1035a7:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
  1035aa:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  1035b1:	3b 15 c8 78 10 00    	cmp    0x1078c8,%edx
  1035b7:	0f 84 fe 00 00 00    	je     1036bb <exit+0x11b>
  1035bd:	8d 76 00             	lea    0x0(%esi),%esi
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
  1035c0:	8d 73 08             	lea    0x8(%ebx),%esi
  1035c3:	8b 44 b2 08          	mov    0x8(%edx,%esi,4),%eax
  1035c7:	85 c0                	test   %eax,%eax
  1035c9:	74 1d                	je     1035e8 <exit+0x48>
      fileclose(proc->ofile[fd]);
  1035cb:	89 04 24             	mov    %eax,(%esp)
  1035ce:	e8 2d da ff ff       	call   101000 <fileclose>
      proc->ofile[fd] = 0;
  1035d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1035d9:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
  1035e0:	00 
  1035e1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
  1035e8:	83 c3 01             	add    $0x1,%ebx
  1035eb:	83 fb 10             	cmp    $0x10,%ebx
  1035ee:	75 d0                	jne    1035c0 <exit+0x20>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
  1035f0:	8b 42 68             	mov    0x68(%edx),%eax
  1035f3:	89 04 24             	mov    %eax,(%esp)
  1035f6:	e8 15 e3 ff ff       	call   101910 <iput>
  proc->cwd = 0;
  1035fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103601:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
  103608:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  10360f:	e8 4c 07 00 00       	call   103d60 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  103614:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  return pid;
}

void
exit(void)
  10361b:	b9 54 e0 10 00       	mov    $0x10e054,%ecx
  103620:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  103625:	8b 53 14             	mov    0x14(%ebx),%edx
  103628:	eb 10                	jmp    10363a <exit+0x9a>
  10362a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103630:	83 c0 7c             	add    $0x7c,%eax
  103633:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  103638:	74 1c                	je     103656 <exit+0xb6>
    if(p->state == SLEEPING && p->chan == chan)
  10363a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  10363e:	75 f0                	jne    103630 <exit+0x90>
  103640:	3b 50 20             	cmp    0x20(%eax),%edx
  103643:	75 eb                	jne    103630 <exit+0x90>
      p->state = RUNNABLE;
  103645:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  10364c:	83 c0 7c             	add    $0x7c,%eax
  10364f:	3d 54 e0 10 00       	cmp    $0x10e054,%eax
  103654:	75 e4                	jne    10363a <exit+0x9a>
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  103656:	8b 35 c8 78 10 00    	mov    0x1078c8,%esi
  10365c:	ba 54 c1 10 00       	mov    $0x10c154,%edx
  103661:	eb 10                	jmp    103673 <exit+0xd3>
  103663:	90                   	nop
  103664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
  103668:	83 c2 7c             	add    $0x7c,%edx
  10366b:	81 fa 54 e0 10 00    	cmp    $0x10e054,%edx
  103671:	74 30                	je     1036a3 <exit+0x103>
    if(p->parent == proc){
  103673:	3b 5a 14             	cmp    0x14(%edx),%ebx
  103676:	75 f0                	jne    103668 <exit+0xc8>
      p->parent = initproc;
      if(p->state == ZOMBIE)
  103678:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
  10367c:	89 72 14             	mov    %esi,0x14(%edx)
      if(p->state == ZOMBIE)
  10367f:	75 e7                	jne    103668 <exit+0xc8>
  103681:	b8 54 c1 10 00       	mov    $0x10c154,%eax
  103686:	eb 07                	jmp    10368f <exit+0xef>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  103688:	83 c0 7c             	add    $0x7c,%eax
  10368b:	39 c1                	cmp    %eax,%ecx
  10368d:	74 d9                	je     103668 <exit+0xc8>
    if(p->state == SLEEPING && p->chan == chan)
  10368f:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  103693:	75 f3                	jne    103688 <exit+0xe8>
  103695:	3b 70 20             	cmp    0x20(%eax),%esi
  103698:	75 ee                	jne    103688 <exit+0xe8>
      p->state = RUNNABLE;
  10369a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  1036a1:	eb e5                	jmp    103688 <exit+0xe8>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  1036a3:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
  1036aa:	e8 91 fb ff ff       	call   103240 <sched>
  panic("zombie exit");
  1036af:	c7 04 24 02 6c 10 00 	movl   $0x106c02,(%esp)
  1036b6:	e8 f5 d2 ff ff       	call   1009b0 <panic>
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");
  1036bb:	c7 04 24 f5 6b 10 00 	movl   $0x106bf5,(%esp)
  1036c2:	e8 e9 d2 ff ff       	call   1009b0 <panic>
  1036c7:	89 f6                	mov    %esi,%esi
  1036c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001036d0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  1036d0:	55                   	push   %ebp
  1036d1:	89 e5                	mov    %esp,%ebp
  1036d3:	53                   	push   %ebx
  1036d4:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  1036d7:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  1036de:	e8 7d 06 00 00       	call   103d60 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
  1036e3:	8b 1d 60 c1 10 00    	mov    0x10c160,%ebx
  1036e9:	85 db                	test   %ebx,%ebx
  1036eb:	0f 84 a5 00 00 00    	je     103796 <allocproc+0xc6>
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
  1036f1:	bb d0 c1 10 00       	mov    $0x10c1d0,%ebx
  1036f6:	eb 0b                	jmp    103703 <allocproc+0x33>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  1036f8:	83 c3 7c             	add    $0x7c,%ebx
  1036fb:	81 fb 54 e0 10 00    	cmp    $0x10e054,%ebx
  103701:	74 7d                	je     103780 <allocproc+0xb0>
    if(p->state == UNUSED)
  103703:	8b 4b 0c             	mov    0xc(%ebx),%ecx
  103706:	85 c9                	test   %ecx,%ecx
  103708:	75 ee                	jne    1036f8 <allocproc+0x28>
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  10370a:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
  103711:	a1 24 73 10 00       	mov    0x107324,%eax
  103716:	89 43 10             	mov    %eax,0x10(%ebx)
  103719:	83 c0 01             	add    $0x1,%eax
  10371c:	a3 24 73 10 00       	mov    %eax,0x107324
  release(&ptable.lock);
  103721:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103728:	e8 e3 05 00 00       	call   103d10 <release>

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
  10372d:	e8 ae eb ff ff       	call   1022e0 <kalloc>
  103732:	85 c0                	test   %eax,%eax
  103734:	89 43 08             	mov    %eax,0x8(%ebx)
  103737:	74 67                	je     1037a0 <allocproc+0xd0>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  103739:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
  10373f:	89 53 18             	mov    %edx,0x18(%ebx)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
  103742:	c7 80 b0 0f 00 00 50 	movl   $0x104f50,0xfb0(%eax)
  103749:	4f 10 00 

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  10374c:	05 9c 0f 00 00       	add    $0xf9c,%eax
  103751:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
  103754:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  10375b:	00 
  10375c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103763:	00 
  103764:	89 04 24             	mov    %eax,(%esp)
  103767:	e8 94 06 00 00       	call   103e00 <memset>
  p->context->eip = (uint)forkret;
  10376c:	8b 43 1c             	mov    0x1c(%ebx),%eax
  10376f:	c7 40 10 20 32 10 00 	movl   $0x103220,0x10(%eax)

  return p;
}
  103776:	89 d8                	mov    %ebx,%eax
  103778:	83 c4 14             	add    $0x14,%esp
  10377b:	5b                   	pop    %ebx
  10377c:	5d                   	pop    %ebp
  10377d:	c3                   	ret    
  10377e:	66 90                	xchg   %ax,%ax

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  103780:	31 db                	xor    %ebx,%ebx
  103782:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103789:	e8 82 05 00 00       	call   103d10 <release>
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}
  10378e:	89 d8                	mov    %ebx,%eax
  103790:	83 c4 14             	add    $0x14,%esp
  103793:	5b                   	pop    %ebx
  103794:	5d                   	pop    %ebp
  103795:	c3                   	ret    
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;
  103796:	bb 54 c1 10 00       	mov    $0x10c154,%ebx
  10379b:	e9 6a ff ff ff       	jmp    10370a <allocproc+0x3a>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack if possible.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
  1037a0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  1037a7:	31 db                	xor    %ebx,%ebx
    return 0;
  1037a9:	eb cb                	jmp    103776 <allocproc+0xa6>
  1037ab:	90                   	nop
  1037ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

001037b0 <clone>:
  return pid;
}

int
clone(void)
{
  1037b0:	55                   	push   %ebp
  1037b1:	89 e5                	mov    %esp,%ebp
  1037b3:	57                   	push   %edi
  1037b4:	56                   	push   %esi
  char* stack;
  int i, pid, size;
  struct proc *np;
  cprintf("a\n");
  // Allocate process.
  if((np = allocproc()) == 0)
  1037b5:	be ff ff ff ff       	mov    $0xffffffff,%esi
  return pid;
}

int
clone(void)
{
  1037ba:	53                   	push   %ebx
  1037bb:	83 ec 2c             	sub    $0x2c,%esp
  char* stack;
  int i, pid, size;
  struct proc *np;
  cprintf("a\n");
  1037be:	c7 04 24 0e 6c 10 00 	movl   $0x106c0e,(%esp)
  1037c5:	e8 f6 cd ff ff       	call   1005c0 <cprintf>
  // Allocate process.
  if((np = allocproc()) == 0)
  1037ca:	e8 01 ff ff ff       	call   1036d0 <allocproc>
  1037cf:	85 c0                	test   %eax,%eax
  1037d1:	89 c3                	mov    %eax,%ebx
  1037d3:	0f 84 3a 01 00 00    	je     103913 <clone+0x163>
    return -1;

  //Point page dir at parent's page dir (shared memory)
  np->pgdir = proc->pgdir;
  1037d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  //This might be an issue later.
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  1037df:	b9 13 00 00 00       	mov    $0x13,%ecx
  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  //Point page dir at parent's page dir (shared memory)
  np->pgdir = proc->pgdir;
  1037e4:	8b 40 04             	mov    0x4(%eax),%eax
  1037e7:	89 43 04             	mov    %eax,0x4(%ebx)
  //This might be an issue later.
  np->sz = proc->sz;
  1037ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1037f0:	8b 00                	mov    (%eax),%eax
  1037f2:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
  1037f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1037fa:	89 43 14             	mov    %eax,0x14(%ebx)
  *np->tf = *proc->tf;
  1037fd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103804:	8b 43 18             	mov    0x18(%ebx),%eax
  103807:	8b 72 18             	mov    0x18(%edx),%esi
  10380a:	89 c7                	mov    %eax,%edi
  10380c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  
  if(argint(1, &size) < 0 || size <= 0 || argptr(0, &stack, size) < 0) {
  10380e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  103811:	89 44 24 04          	mov    %eax,0x4(%esp)
  103815:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10381c:	e8 7f 08 00 00       	call   1040a0 <argint>
  103821:	85 c0                	test   %eax,%eax
  103823:	0f 88 f4 00 00 00    	js     10391d <clone+0x16d>
  103829:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10382c:	85 c0                	test   %eax,%eax
  10382e:	0f 8e e9 00 00 00    	jle    10391d <clone+0x16d>
  103834:	89 44 24 08          	mov    %eax,0x8(%esp)
  103838:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  10383b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10383f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  103846:	e8 95 08 00 00       	call   1040e0 <argptr>
  10384b:	85 c0                	test   %eax,%eax
  10384d:	0f 88 ca 00 00 00    	js     10391d <clone+0x16d>
    np->state = UNUSED;
    return -1;
  }
//   cprintf("stack inside %d\n", stack[0]);

  cprintf("esp: %d\n", proc->tf->esp);
  103853:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  // Clear %eax so that clone returns 0 in the child.
  np->tf->eax = 0;
  np->tf->esp = (uint)stack;
  np->context->eip = proc->context->eip;
  np->tf->eip = proc->tf->eip;
  103859:	31 f6                	xor    %esi,%esi
    np->state = UNUSED;
    return -1;
  }
//   cprintf("stack inside %d\n", stack[0]);

  cprintf("esp: %d\n", proc->tf->esp);
  10385b:	8b 40 18             	mov    0x18(%eax),%eax
  10385e:	8b 40 44             	mov    0x44(%eax),%eax
  103861:	c7 04 24 11 6c 10 00 	movl   $0x106c11,(%esp)
  103868:	89 44 24 04          	mov    %eax,0x4(%esp)
  10386c:	e8 4f cd ff ff       	call   1005c0 <cprintf>

  // Clear %eax so that clone returns 0 in the child.
  np->tf->eax = 0;
  103871:	8b 43 18             	mov    0x18(%ebx),%eax
  103874:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  np->tf->esp = (uint)stack;
  10387b:	8b 43 18             	mov    0x18(%ebx),%eax
  10387e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103881:	89 50 44             	mov    %edx,0x44(%eax)
  np->context->eip = proc->context->eip;
  103884:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10388b:	8b 43 1c             	mov    0x1c(%ebx),%eax
  10388e:	8b 52 1c             	mov    0x1c(%edx),%edx
  103891:	8b 52 10             	mov    0x10(%edx),%edx
  103894:	89 50 10             	mov    %edx,0x10(%eax)
  np->tf->eip = proc->tf->eip;
  103897:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10389e:	8b 43 18             	mov    0x18(%ebx),%eax
  1038a1:	8b 52 18             	mov    0x18(%edx),%edx
  1038a4:	8b 52 38             	mov    0x38(%edx),%edx
  1038a7:	89 50 38             	mov    %edx,0x38(%eax)
  1038aa:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  1038b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
/*  stack[0] = proc->tf->eip;*/
/*  stack += 4;*/
  
  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
  1038b8:	8b 44 b2 28          	mov    0x28(%edx,%esi,4),%eax
  1038bc:	85 c0                	test   %eax,%eax
  1038be:	74 13                	je     1038d3 <clone+0x123>
      np->ofile[i] = filedup(proc->ofile[i]);
  1038c0:	89 04 24             	mov    %eax,(%esp)
  1038c3:	e8 68 d6 ff ff       	call   100f30 <filedup>
  1038c8:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
  1038cc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  np->context->eip = proc->context->eip;
  np->tf->eip = proc->tf->eip;
/*  stack[0] = proc->tf->eip;*/
/*  stack += 4;*/
  
  for(i = 0; i < NOFILE; i++)
  1038d3:	83 c6 01             	add    $0x1,%esi
  1038d6:	83 fe 10             	cmp    $0x10,%esi
  1038d9:	75 dd                	jne    1038b8 <clone+0x108>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1038db:	8b 42 68             	mov    0x68(%edx),%eax
  1038de:	89 04 24             	mov    %eax,(%esp)
  1038e1:	e8 4a d8 ff ff       	call   101130 <idup>

  pid = np->pid;
  1038e6:	8b 73 10             	mov    0x10(%ebx),%esi
  np->state = RUNNABLE;
  1038e9:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
/*  stack += 4;*/
  
  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1038f0:	89 43 68             	mov    %eax,0x68(%ebx)

  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  1038f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1038f9:	83 c3 6c             	add    $0x6c,%ebx
  1038fc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  103903:	00 
  103904:	89 1c 24             	mov    %ebx,(%esp)
  103907:	83 c0 6c             	add    $0x6c,%eax
  10390a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10390e:	e8 8d 06 00 00       	call   103fa0 <safestrcpy>
  return pid;
}
  103913:	83 c4 2c             	add    $0x2c,%esp
  103916:	89 f0                	mov    %esi,%eax
  103918:	5b                   	pop    %ebx
  103919:	5e                   	pop    %esi
  10391a:	5f                   	pop    %edi
  10391b:	5d                   	pop    %ebp
  10391c:	c3                   	ret    
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  
  if(argint(1, &size) < 0 || size <= 0 || argptr(0, &stack, size) < 0) {
    kfree(np->kstack);
  10391d:	8b 43 08             	mov    0x8(%ebx),%eax
    np->kstack = 0;
    np->state = UNUSED;
  103920:	be ff ff ff ff       	mov    $0xffffffff,%esi
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  
  if(argint(1, &size) < 0 || size <= 0 || argptr(0, &stack, size) < 0) {
    kfree(np->kstack);
  103925:	89 04 24             	mov    %eax,(%esp)
  103928:	e8 f3 e9 ff ff       	call   102320 <kfree>
    np->kstack = 0;
  10392d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
  103934:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
  10393b:	eb d6                	jmp    103913 <clone+0x163>
  10393d:	8d 76 00             	lea    0x0(%esi),%esi

00103940 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  103940:	55                   	push   %ebp
  103941:	89 e5                	mov    %esp,%ebp
  103943:	57                   	push   %edi
  103944:	56                   	push   %esi
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  103945:	be ff ff ff ff       	mov    $0xffffffff,%esi
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  10394a:	53                   	push   %ebx
  10394b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
  10394e:	e8 7d fd ff ff       	call   1036d0 <allocproc>
  103953:	85 c0                	test   %eax,%eax
  103955:	89 c3                	mov    %eax,%ebx
  103957:	0f 84 be 00 00 00    	je     103a1b <fork+0xdb>
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
  10395d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103963:	8b 10                	mov    (%eax),%edx
  103965:	89 54 24 04          	mov    %edx,0x4(%esp)
  103969:	8b 40 04             	mov    0x4(%eax),%eax
  10396c:	89 04 24             	mov    %eax,(%esp)
  10396f:	e8 1c 29 00 00       	call   106290 <copyuvm>
  103974:	85 c0                	test   %eax,%eax
  103976:	89 43 04             	mov    %eax,0x4(%ebx)
  103979:	0f 84 a6 00 00 00    	je     103a25 <fork+0xe5>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  10397f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  np->parent = proc;
  *np->tf = *proc->tf;
  103985:	b9 13 00 00 00       	mov    $0x13,%ecx
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  10398a:	8b 00                	mov    (%eax),%eax
  10398c:	89 03                	mov    %eax,(%ebx)
  np->parent = proc;
  10398e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103994:	89 43 14             	mov    %eax,0x14(%ebx)
  *np->tf = *proc->tf;
  103997:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  10399e:	8b 43 18             	mov    0x18(%ebx),%eax
  1039a1:	8b 72 18             	mov    0x18(%edx),%esi
  1039a4:	89 c7                	mov    %eax,%edi
  1039a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
  1039a8:	31 f6                	xor    %esi,%esi
  1039aa:	8b 43 18             	mov    0x18(%ebx),%eax
  1039ad:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  1039b4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  1039bb:	90                   	nop
  1039bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
  1039c0:	8b 44 b2 28          	mov    0x28(%edx,%esi,4),%eax
  1039c4:	85 c0                	test   %eax,%eax
  1039c6:	74 13                	je     1039db <fork+0x9b>
      np->ofile[i] = filedup(proc->ofile[i]);
  1039c8:	89 04 24             	mov    %eax,(%esp)
  1039cb:	e8 60 d5 ff ff       	call   100f30 <filedup>
  1039d0:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
  1039d4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
  1039db:	83 c6 01             	add    $0x1,%esi
  1039de:	83 fe 10             	cmp    $0x10,%esi
  1039e1:	75 dd                	jne    1039c0 <fork+0x80>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1039e3:	8b 42 68             	mov    0x68(%edx),%eax
  1039e6:	89 04 24             	mov    %eax,(%esp)
  1039e9:	e8 42 d7 ff ff       	call   101130 <idup>
 
  pid = np->pid;
  1039ee:	8b 73 10             	mov    0x10(%ebx),%esi
  np->state = RUNNABLE;
  1039f1:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
  1039f8:	89 43 68             	mov    %eax,0x68(%ebx)
 
  pid = np->pid;
  np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
  1039fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103a01:	83 c3 6c             	add    $0x6c,%ebx
  103a04:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  103a0b:	00 
  103a0c:	89 1c 24             	mov    %ebx,(%esp)
  103a0f:	83 c0 6c             	add    $0x6c,%eax
  103a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  103a16:	e8 85 05 00 00       	call   103fa0 <safestrcpy>
  return pid;
}
  103a1b:	83 c4 1c             	add    $0x1c,%esp
  103a1e:	89 f0                	mov    %esi,%eax
  103a20:	5b                   	pop    %ebx
  103a21:	5e                   	pop    %esi
  103a22:	5f                   	pop    %edi
  103a23:	5d                   	pop    %ebp
  103a24:	c3                   	ret    
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
  103a25:	8b 43 08             	mov    0x8(%ebx),%eax
  103a28:	89 04 24             	mov    %eax,(%esp)
  103a2b:	e8 f0 e8 ff ff       	call   102320 <kfree>
    np->kstack = 0;
  103a30:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
  103a37:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
  103a3e:	eb db                	jmp    103a1b <fork+0xdb>

00103a40 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  103a40:	55                   	push   %ebp
  103a41:	89 e5                	mov    %esp,%ebp
  103a43:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
  103a46:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  103a4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  uint sz;
  
  sz = proc->sz;
  103a50:	8b 02                	mov    (%edx),%eax
  if(n > 0){
  103a52:	83 f9 00             	cmp    $0x0,%ecx
  103a55:	7f 19                	jg     103a70 <growproc+0x30>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
  103a57:	75 39                	jne    103a92 <growproc+0x52>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  103a59:	89 02                	mov    %eax,(%edx)
  switchuvm(proc);
  103a5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  103a61:	89 04 24             	mov    %eax,(%esp)
  103a64:	e8 77 2a 00 00       	call   1064e0 <switchuvm>
  103a69:	31 c0                	xor    %eax,%eax
  return 0;
}
  103a6b:	c9                   	leave  
  103a6c:	c3                   	ret    
  103a6d:	8d 76 00             	lea    0x0(%esi),%esi
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
  103a70:	01 c1                	add    %eax,%ecx
  103a72:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  103a7a:	8b 42 04             	mov    0x4(%edx),%eax
  103a7d:	89 04 24             	mov    %eax,(%esp)
  103a80:	e8 cb 28 00 00       	call   106350 <allocuvm>
  103a85:	85 c0                	test   %eax,%eax
  103a87:	74 27                	je     103ab0 <growproc+0x70>
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
  103a89:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  103a90:	eb c7                	jmp    103a59 <growproc+0x19>
  103a92:	01 c1                	add    %eax,%ecx
  103a94:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  103a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  103a9c:	8b 42 04             	mov    0x4(%edx),%eax
  103a9f:	89 04 24             	mov    %eax,(%esp)
  103aa2:	e8 d9 26 00 00       	call   106180 <deallocuvm>
  103aa7:	85 c0                	test   %eax,%eax
  103aa9:	75 de                	jne    103a89 <growproc+0x49>
  103aab:	90                   	nop
  103aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
  103ab0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  103ab5:	c9                   	leave  
  103ab6:	c3                   	ret    
  103ab7:	89 f6                	mov    %esi,%esi
  103ab9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103ac0 <userinit>:
}

// Set up first user process.
void
userinit(void)
{
  103ac0:	55                   	push   %ebp
  103ac1:	89 e5                	mov    %esp,%ebp
  103ac3:	53                   	push   %ebx
  103ac4:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  103ac7:	e8 04 fc ff ff       	call   1036d0 <allocproc>
  103acc:	89 c3                	mov    %eax,%ebx
  initproc = p;
  103ace:	a3 c8 78 10 00       	mov    %eax,0x1078c8
  if((p->pgdir = setupkvm()) == 0)
  103ad3:	e8 78 25 00 00       	call   106050 <setupkvm>
  103ad8:	85 c0                	test   %eax,%eax
  103ada:	89 43 04             	mov    %eax,0x4(%ebx)
  103add:	0f 84 b6 00 00 00    	je     103b99 <userinit+0xd9>
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  103ae3:	89 04 24             	mov    %eax,(%esp)
  103ae6:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
  103aed:	00 
  103aee:	c7 44 24 04 70 77 10 	movl   $0x107770,0x4(%esp)
  103af5:	00 
  103af6:	e8 f5 25 00 00       	call   1060f0 <inituvm>
  p->sz = PGSIZE;
  103afb:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
  103b01:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
  103b08:	00 
  103b09:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103b10:	00 
  103b11:	8b 43 18             	mov    0x18(%ebx),%eax
  103b14:	89 04 24             	mov    %eax,(%esp)
  103b17:	e8 e4 02 00 00       	call   103e00 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  103b1c:	8b 43 18             	mov    0x18(%ebx),%eax
  103b1f:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  103b25:	8b 43 18             	mov    0x18(%ebx),%eax
  103b28:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
  103b2e:	8b 43 18             	mov    0x18(%ebx),%eax
  103b31:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103b35:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
  103b39:	8b 43 18             	mov    0x18(%ebx),%eax
  103b3c:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
  103b40:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
  103b44:	8b 43 18             	mov    0x18(%ebx),%eax
  103b47:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
  103b4e:	8b 43 18             	mov    0x18(%ebx),%eax
  103b51:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
  103b58:	8b 43 18             	mov    0x18(%ebx),%eax
  103b5b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
  103b62:	8d 43 6c             	lea    0x6c(%ebx),%eax
  103b65:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  103b6c:	00 
  103b6d:	c7 44 24 04 33 6c 10 	movl   $0x106c33,0x4(%esp)
  103b74:	00 
  103b75:	89 04 24             	mov    %eax,(%esp)
  103b78:	e8 23 04 00 00       	call   103fa0 <safestrcpy>
  p->cwd = namei("/");
  103b7d:	c7 04 24 3c 6c 10 00 	movl   $0x106c3c,(%esp)
  103b84:	e8 57 e3 ff ff       	call   101ee0 <namei>

  p->state = RUNNABLE;
  103b89:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");
  103b90:	89 43 68             	mov    %eax,0x68(%ebx)

  p->state = RUNNABLE;
}
  103b93:	83 c4 14             	add    $0x14,%esp
  103b96:	5b                   	pop    %ebx
  103b97:	5d                   	pop    %ebp
  103b98:	c3                   	ret    
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  103b99:	c7 04 24 1a 6c 10 00 	movl   $0x106c1a,(%esp)
  103ba0:	e8 0b ce ff ff       	call   1009b0 <panic>
  103ba5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103ba9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103bb0 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
  103bb0:	55                   	push   %ebp
  103bb1:	89 e5                	mov    %esp,%ebp
  103bb3:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
  103bb6:	c7 44 24 04 3e 6c 10 	movl   $0x106c3e,0x4(%esp)
  103bbd:	00 
  103bbe:	c7 04 24 20 c1 10 00 	movl   $0x10c120,(%esp)
  103bc5:	e8 06 00 00 00       	call   103bd0 <initlock>
}
  103bca:	c9                   	leave  
  103bcb:	c3                   	ret    
  103bcc:	90                   	nop
  103bcd:	90                   	nop
  103bce:	90                   	nop
  103bcf:	90                   	nop

00103bd0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  103bd0:	55                   	push   %ebp
  103bd1:	89 e5                	mov    %esp,%ebp
  103bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
  103bd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
  103bd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
  103bdf:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
  lk->cpu = 0;
  103be2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
  103be9:	5d                   	pop    %ebp
  103bea:	c3                   	ret    
  103beb:	90                   	nop
  103bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103bf0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  103bf0:	55                   	push   %ebp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  103bf1:	31 c0                	xor    %eax,%eax
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  103bf3:	89 e5                	mov    %esp,%ebp
  103bf5:	53                   	push   %ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  103bf6:	8b 55 08             	mov    0x8(%ebp),%edx
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  103bf9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  103bfc:	83 ea 08             	sub    $0x8,%edx
  103bff:	90                   	nop
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
  103c00:	8d 8a 00 00 f0 ff    	lea    -0x100000(%edx),%ecx
  103c06:	81 f9 fe ff ef ff    	cmp    $0xffeffffe,%ecx
  103c0c:	77 1a                	ja     103c28 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
  103c0e:	8b 4a 04             	mov    0x4(%edx),%ecx
  103c11:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  103c14:	83 c0 01             	add    $0x1,%eax
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  103c17:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
  103c19:	83 f8 0a             	cmp    $0xa,%eax
  103c1c:	75 e2                	jne    103c00 <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
  103c1e:	5b                   	pop    %ebx
  103c1f:	5d                   	pop    %ebp
  103c20:	c3                   	ret    
  103c21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  103c28:	83 f8 09             	cmp    $0x9,%eax
  103c2b:	7f f1                	jg     103c1e <getcallerpcs+0x2e>
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  103c2d:	8d 14 83             	lea    (%ebx,%eax,4),%edx
  }
  for(; i < 10; i++)
  103c30:	83 c0 01             	add    $0x1,%eax
    pcs[i] = 0;
  103c33:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    if(ebp == 0 || ebp < (uint*)0x100000 || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
  103c39:	83 c2 04             	add    $0x4,%edx
  103c3c:	83 f8 0a             	cmp    $0xa,%eax
  103c3f:	75 ef                	jne    103c30 <getcallerpcs+0x40>
    pcs[i] = 0;
}
  103c41:	5b                   	pop    %ebx
  103c42:	5d                   	pop    %ebp
  103c43:	c3                   	ret    
  103c44:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  103c4a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00103c50 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103c50:	55                   	push   %ebp
  return lock->locked && lock->cpu == cpu;
  103c51:	31 c0                	xor    %eax,%eax
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  103c53:	89 e5                	mov    %esp,%ebp
  103c55:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
  103c58:	8b 0a                	mov    (%edx),%ecx
  103c5a:	85 c9                	test   %ecx,%ecx
  103c5c:	74 10                	je     103c6e <holding+0x1e>
  103c5e:	8b 42 08             	mov    0x8(%edx),%eax
  103c61:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103c68:	0f 94 c0             	sete   %al
  103c6b:	0f b6 c0             	movzbl %al,%eax
}
  103c6e:	5d                   	pop    %ebp
  103c6f:	c3                   	ret    

00103c70 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
  103c70:	55                   	push   %ebp
  103c71:	89 e5                	mov    %esp,%ebp
  103c73:	53                   	push   %ebx

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103c74:	9c                   	pushf  
  103c75:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103c76:	fa                   	cli    
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103c77:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103c7e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103c84:	8d 48 01             	lea    0x1(%eax),%ecx
  103c87:	85 c0                	test   %eax,%eax
  103c89:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103c8f:	75 12                	jne    103ca3 <pushcli+0x33>
    cpu->intena = eflags & FL_IF;
  103c91:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103c97:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103c9d:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
}
  103ca3:	5b                   	pop    %ebx
  103ca4:	5d                   	pop    %ebp
  103ca5:	c3                   	ret    
  103ca6:	8d 76 00             	lea    0x0(%esi),%esi
  103ca9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103cb0 <popcli>:

void
popcli(void)
{
  103cb0:	55                   	push   %ebp
  103cb1:	89 e5                	mov    %esp,%ebp
  103cb3:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103cb6:	9c                   	pushf  
  103cb7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
  103cb8:	f6 c4 02             	test   $0x2,%ah
  103cbb:	75 43                	jne    103d00 <popcli+0x50>
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
  103cbd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103cc4:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103cca:	83 e8 01             	sub    $0x1,%eax
  103ccd:	85 c0                	test   %eax,%eax
  103ccf:	89 82 ac 00 00 00    	mov    %eax,0xac(%edx)
  103cd5:	78 1d                	js     103cf4 <popcli+0x44>
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
  103cd7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103cdd:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
  103ce3:	85 d2                	test   %edx,%edx
  103ce5:	75 0b                	jne    103cf2 <popcli+0x42>
  103ce7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  103ced:	85 c0                	test   %eax,%eax
  103cef:	74 01                	je     103cf2 <popcli+0x42>
}

static inline void
sti(void)
{
  asm volatile("sti");
  103cf1:	fb                   	sti    
    sti();
}
  103cf2:	c9                   	leave  
  103cf3:	c3                   	ret    
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
    panic("popcli");
  103cf4:	c7 04 24 9f 6c 10 00 	movl   $0x106c9f,(%esp)
  103cfb:	e8 b0 cc ff ff       	call   1009b0 <panic>

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  103d00:	c7 04 24 88 6c 10 00 	movl   $0x106c88,(%esp)
  103d07:	e8 a4 cc ff ff       	call   1009b0 <panic>
  103d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103d10 <release>:
}

// Release the lock.
void
release(struct spinlock *lk)
{
  103d10:	55                   	push   %ebp
  103d11:	89 e5                	mov    %esp,%ebp
  103d13:	83 ec 18             	sub    $0x18,%esp
  103d16:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103d19:	8b 0a                	mov    (%edx),%ecx
  103d1b:	85 c9                	test   %ecx,%ecx
  103d1d:	74 0c                	je     103d2b <release+0x1b>
  103d1f:	8b 42 08             	mov    0x8(%edx),%eax
  103d22:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103d29:	74 0d                	je     103d38 <release+0x28>
// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");
  103d2b:	c7 04 24 c0 66 10 00 	movl   $0x1066c0,(%esp)
  103d32:	e8 79 cc ff ff       	call   1009b0 <panic>
  103d37:	90                   	nop

  lk->pcs[0] = 0;
  103d38:	c7 42 0c 00 00 00 00 	movl   $0x0,0xc(%edx)
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103d3f:	31 c0                	xor    %eax,%eax
  lk->cpu = 0;
  103d41:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
  103d48:	f0 87 02             	lock xchg %eax,(%edx)
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
}
  103d4b:	c9                   	leave  
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
  103d4c:	e9 5f ff ff ff       	jmp    103cb0 <popcli>
  103d51:	eb 0d                	jmp    103d60 <acquire>
  103d53:	90                   	nop
  103d54:	90                   	nop
  103d55:	90                   	nop
  103d56:	90                   	nop
  103d57:	90                   	nop
  103d58:	90                   	nop
  103d59:	90                   	nop
  103d5a:	90                   	nop
  103d5b:	90                   	nop
  103d5c:	90                   	nop
  103d5d:	90                   	nop
  103d5e:	90                   	nop
  103d5f:	90                   	nop

00103d60 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  103d60:	55                   	push   %ebp
  103d61:	89 e5                	mov    %esp,%ebp
  103d63:	53                   	push   %ebx
  103d64:	83 ec 14             	sub    $0x14,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
  103d67:	9c                   	pushf  
  103d68:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
  103d69:	fa                   	cli    
{
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
  103d6a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103d71:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
  103d77:	8d 48 01             	lea    0x1(%eax),%ecx
  103d7a:	85 c0                	test   %eax,%eax
  103d7c:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
  103d82:	75 12                	jne    103d96 <acquire+0x36>
    cpu->intena = eflags & FL_IF;
  103d84:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  103d8a:	81 e3 00 02 00 00    	and    $0x200,%ebx
  103d90:	89 98 b0 00 00 00    	mov    %ebx,0xb0(%eax)
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
  103d96:	8b 55 08             	mov    0x8(%ebp),%edx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
  103d99:	8b 1a                	mov    (%edx),%ebx
  103d9b:	85 db                	test   %ebx,%ebx
  103d9d:	74 0c                	je     103dab <acquire+0x4b>
  103d9f:	8b 42 08             	mov    0x8(%edx),%eax
  103da2:	65 3b 05 00 00 00 00 	cmp    %gs:0x0,%eax
  103da9:	74 45                	je     103df0 <acquire+0x90>
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
  103dab:	b9 01 00 00 00       	mov    $0x1,%ecx
  103db0:	eb 09                	jmp    103dbb <acquire+0x5b>
  103db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
  103db8:	8b 55 08             	mov    0x8(%ebp),%edx
  103dbb:	89 c8                	mov    %ecx,%eax
  103dbd:	f0 87 02             	lock xchg %eax,(%edx)
  103dc0:	85 c0                	test   %eax,%eax
  103dc2:	75 f4                	jne    103db8 <acquire+0x58>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
  103dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  103dc7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  103dce:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
  103dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  103dd4:	83 c0 0c             	add    $0xc,%eax
  103dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  103ddb:	8d 45 08             	lea    0x8(%ebp),%eax
  103dde:	89 04 24             	mov    %eax,(%esp)
  103de1:	e8 0a fe ff ff       	call   103bf0 <getcallerpcs>
}
  103de6:	83 c4 14             	add    $0x14,%esp
  103de9:	5b                   	pop    %ebx
  103dea:	5d                   	pop    %ebp
  103deb:	c3                   	ret    
  103dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");
  103df0:	c7 04 24 c8 66 10 00 	movl   $0x1066c8,(%esp)
  103df7:	e8 b4 cb ff ff       	call   1009b0 <panic>
  103dfc:	90                   	nop
  103dfd:	90                   	nop
  103dfe:	90                   	nop
  103dff:	90                   	nop

00103e00 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
  103e00:	55                   	push   %ebp
  103e01:	89 e5                	mov    %esp,%ebp
  103e03:	8b 55 08             	mov    0x8(%ebp),%edx
  103e06:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  103e07:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  103e0d:	89 d7                	mov    %edx,%edi
  103e0f:	fc                   	cld    
  103e10:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  103e12:	89 d0                	mov    %edx,%eax
  103e14:	5f                   	pop    %edi
  103e15:	5d                   	pop    %ebp
  103e16:	c3                   	ret    
  103e17:	89 f6                	mov    %esi,%esi
  103e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103e20 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
  103e20:	55                   	push   %ebp
  103e21:	89 e5                	mov    %esp,%ebp
  103e23:	57                   	push   %edi
  103e24:	56                   	push   %esi
  103e25:	53                   	push   %ebx
  103e26:	8b 55 10             	mov    0x10(%ebp),%edx
  103e29:	8b 75 08             	mov    0x8(%ebp),%esi
  103e2c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103e2f:	85 d2                	test   %edx,%edx
  103e31:	74 2d                	je     103e60 <memcmp+0x40>
    if(*s1 != *s2)
  103e33:	0f b6 1e             	movzbl (%esi),%ebx
  103e36:	0f b6 0f             	movzbl (%edi),%ecx
  103e39:	38 cb                	cmp    %cl,%bl
  103e3b:	75 2b                	jne    103e68 <memcmp+0x48>
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103e3d:	83 ea 01             	sub    $0x1,%edx
  103e40:	31 c0                	xor    %eax,%eax
  103e42:	eb 18                	jmp    103e5c <memcmp+0x3c>
  103e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s1 != *s2)
  103e48:	0f b6 5c 06 01       	movzbl 0x1(%esi,%eax,1),%ebx
  103e4d:	83 ea 01             	sub    $0x1,%edx
  103e50:	0f b6 4c 07 01       	movzbl 0x1(%edi,%eax,1),%ecx
  103e55:	83 c0 01             	add    $0x1,%eax
  103e58:	38 cb                	cmp    %cl,%bl
  103e5a:	75 0c                	jne    103e68 <memcmp+0x48>
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
  103e5c:	85 d2                	test   %edx,%edx
  103e5e:	75 e8                	jne    103e48 <memcmp+0x28>
  103e60:	31 c0                	xor    %eax,%eax
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
  103e62:	5b                   	pop    %ebx
  103e63:	5e                   	pop    %esi
  103e64:	5f                   	pop    %edi
  103e65:	5d                   	pop    %ebp
  103e66:	c3                   	ret    
  103e67:	90                   	nop
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
  103e68:	0f b6 c3             	movzbl %bl,%eax
  103e6b:	0f b6 c9             	movzbl %cl,%ecx
  103e6e:	29 c8                	sub    %ecx,%eax
    s1++, s2++;
  }

  return 0;
}
  103e70:	5b                   	pop    %ebx
  103e71:	5e                   	pop    %esi
  103e72:	5f                   	pop    %edi
  103e73:	5d                   	pop    %ebp
  103e74:	c3                   	ret    
  103e75:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103e80 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
  103e80:	55                   	push   %ebp
  103e81:	89 e5                	mov    %esp,%ebp
  103e83:	57                   	push   %edi
  103e84:	56                   	push   %esi
  103e85:	53                   	push   %ebx
  103e86:	8b 45 08             	mov    0x8(%ebp),%eax
  103e89:	8b 75 0c             	mov    0xc(%ebp),%esi
  103e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
  103e8f:	39 c6                	cmp    %eax,%esi
  103e91:	73 2d                	jae    103ec0 <memmove+0x40>
  103e93:	8d 3c 1e             	lea    (%esi,%ebx,1),%edi
  103e96:	39 f8                	cmp    %edi,%eax
  103e98:	73 26                	jae    103ec0 <memmove+0x40>
    s += n;
    d += n;
    while(n-- > 0)
  103e9a:	85 db                	test   %ebx,%ebx
  103e9c:	74 1d                	je     103ebb <memmove+0x3b>

  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
  103e9e:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  103ea1:	31 d2                	xor    %edx,%edx
  103ea3:	90                   	nop
  103ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
      *--d = *--s;
  103ea8:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  103ead:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  103eb1:	83 ea 01             	sub    $0x1,%edx
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103eb4:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  103eb7:	85 c9                	test   %ecx,%ecx
  103eb9:	75 ed                	jne    103ea8 <memmove+0x28>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
  103ebb:	5b                   	pop    %ebx
  103ebc:	5e                   	pop    %esi
  103ebd:	5f                   	pop    %edi
  103ebe:	5d                   	pop    %ebp
  103ebf:	c3                   	ret    
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
  103ec0:	31 d2                	xor    %edx,%edx
      *--d = *--s;
  } else
    while(n-- > 0)
  103ec2:	85 db                	test   %ebx,%ebx
  103ec4:	74 f5                	je     103ebb <memmove+0x3b>
  103ec6:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
  103ec8:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  103ecc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  103ecf:	83 c2 01             	add    $0x1,%edx
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
  103ed2:	39 d3                	cmp    %edx,%ebx
  103ed4:	75 f2                	jne    103ec8 <memmove+0x48>
      *d++ = *s++;

  return dst;
}
  103ed6:	5b                   	pop    %ebx
  103ed7:	5e                   	pop    %esi
  103ed8:	5f                   	pop    %edi
  103ed9:	5d                   	pop    %ebp
  103eda:	c3                   	ret    
  103edb:	90                   	nop
  103edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00103ee0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  103ee0:	55                   	push   %ebp
  103ee1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
  103ee3:	5d                   	pop    %ebp

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
  103ee4:	e9 97 ff ff ff       	jmp    103e80 <memmove>
  103ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00103ef0 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
  103ef0:	55                   	push   %ebp
  103ef1:	89 e5                	mov    %esp,%ebp
  103ef3:	57                   	push   %edi
  103ef4:	56                   	push   %esi
  103ef5:	53                   	push   %ebx
  103ef6:	8b 7d 10             	mov    0x10(%ebp),%edi
  103ef9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103efc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  while(n > 0 && *p && *p == *q)
  103eff:	85 ff                	test   %edi,%edi
  103f01:	74 3d                	je     103f40 <strncmp+0x50>
  103f03:	0f b6 01             	movzbl (%ecx),%eax
  103f06:	84 c0                	test   %al,%al
  103f08:	75 18                	jne    103f22 <strncmp+0x32>
  103f0a:	eb 3c                	jmp    103f48 <strncmp+0x58>
  103f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103f10:	83 ef 01             	sub    $0x1,%edi
  103f13:	74 2b                	je     103f40 <strncmp+0x50>
    n--, p++, q++;
  103f15:	83 c1 01             	add    $0x1,%ecx
  103f18:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103f1b:	0f b6 01             	movzbl (%ecx),%eax
  103f1e:	84 c0                	test   %al,%al
  103f20:	74 26                	je     103f48 <strncmp+0x58>
  103f22:	0f b6 33             	movzbl (%ebx),%esi
  103f25:	89 f2                	mov    %esi,%edx
  103f27:	38 d0                	cmp    %dl,%al
  103f29:	74 e5                	je     103f10 <strncmp+0x20>
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
  103f2b:	81 e6 ff 00 00 00    	and    $0xff,%esi
  103f31:	0f b6 c0             	movzbl %al,%eax
  103f34:	29 f0                	sub    %esi,%eax
}
  103f36:	5b                   	pop    %ebx
  103f37:	5e                   	pop    %esi
  103f38:	5f                   	pop    %edi
  103f39:	5d                   	pop    %ebp
  103f3a:	c3                   	ret    
  103f3b:	90                   	nop
  103f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103f40:	31 c0                	xor    %eax,%eax
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
  103f42:	5b                   	pop    %ebx
  103f43:	5e                   	pop    %esi
  103f44:	5f                   	pop    %edi
  103f45:	5d                   	pop    %ebp
  103f46:	c3                   	ret    
  103f47:	90                   	nop
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
  103f48:	0f b6 33             	movzbl (%ebx),%esi
  103f4b:	eb de                	jmp    103f2b <strncmp+0x3b>
  103f4d:	8d 76 00             	lea    0x0(%esi),%esi

00103f50 <strncpy>:
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
{
  103f50:	55                   	push   %ebp
  103f51:	89 e5                	mov    %esp,%ebp
  103f53:	8b 45 08             	mov    0x8(%ebp),%eax
  103f56:	56                   	push   %esi
  103f57:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103f5a:	53                   	push   %ebx
  103f5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  103f5e:	89 c3                	mov    %eax,%ebx
  103f60:	eb 09                	jmp    103f6b <strncpy+0x1b>
  103f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  103f68:	83 c6 01             	add    $0x1,%esi
  103f6b:	83 e9 01             	sub    $0x1,%ecx
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  103f6e:	8d 51 01             	lea    0x1(%ecx),%edx
{
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
  103f71:	85 d2                	test   %edx,%edx
  103f73:	7e 0c                	jle    103f81 <strncpy+0x31>
  103f75:	0f b6 16             	movzbl (%esi),%edx
  103f78:	88 13                	mov    %dl,(%ebx)
  103f7a:	83 c3 01             	add    $0x1,%ebx
  103f7d:	84 d2                	test   %dl,%dl
  103f7f:	75 e7                	jne    103f68 <strncpy+0x18>
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
  103f81:	31 d2                	xor    %edx,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  103f83:	85 c9                	test   %ecx,%ecx
  103f85:	7e 0c                	jle    103f93 <strncpy+0x43>
  103f87:	90                   	nop
    *s++ = 0;
  103f88:	c6 04 13 00          	movb   $0x0,(%ebx,%edx,1)
  103f8c:	83 c2 01             	add    $0x1,%edx
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
  103f8f:	39 ca                	cmp    %ecx,%edx
  103f91:	75 f5                	jne    103f88 <strncpy+0x38>
    *s++ = 0;
  return os;
}
  103f93:	5b                   	pop    %ebx
  103f94:	5e                   	pop    %esi
  103f95:	5d                   	pop    %ebp
  103f96:	c3                   	ret    
  103f97:	89 f6                	mov    %esi,%esi
  103f99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103fa0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
  103fa0:	55                   	push   %ebp
  103fa1:	89 e5                	mov    %esp,%ebp
  103fa3:	8b 55 10             	mov    0x10(%ebp),%edx
  103fa6:	56                   	push   %esi
  103fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  103faa:	53                   	push   %ebx
  103fab:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *os;
  
  os = s;
  if(n <= 0)
  103fae:	85 d2                	test   %edx,%edx
  103fb0:	7e 1f                	jle    103fd1 <safestrcpy+0x31>
  103fb2:	89 c1                	mov    %eax,%ecx
  103fb4:	eb 05                	jmp    103fbb <safestrcpy+0x1b>
  103fb6:	66 90                	xchg   %ax,%ax
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
  103fb8:	83 c6 01             	add    $0x1,%esi
  103fbb:	83 ea 01             	sub    $0x1,%edx
  103fbe:	85 d2                	test   %edx,%edx
  103fc0:	7e 0c                	jle    103fce <safestrcpy+0x2e>
  103fc2:	0f b6 1e             	movzbl (%esi),%ebx
  103fc5:	88 19                	mov    %bl,(%ecx)
  103fc7:	83 c1 01             	add    $0x1,%ecx
  103fca:	84 db                	test   %bl,%bl
  103fcc:	75 ea                	jne    103fb8 <safestrcpy+0x18>
    ;
  *s = 0;
  103fce:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
  103fd1:	5b                   	pop    %ebx
  103fd2:	5e                   	pop    %esi
  103fd3:	5d                   	pop    %ebp
  103fd4:	c3                   	ret    
  103fd5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103fd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00103fe0 <strlen>:

int
strlen(const char *s)
{
  103fe0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
  103fe1:	31 c0                	xor    %eax,%eax
  return os;
}

int
strlen(const char *s)
{
  103fe3:	89 e5                	mov    %esp,%ebp
  103fe5:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
  103fe8:	80 3a 00             	cmpb   $0x0,(%edx)
  103feb:	74 0c                	je     103ff9 <strlen+0x19>
  103fed:	8d 76 00             	lea    0x0(%esi),%esi
  103ff0:	83 c0 01             	add    $0x1,%eax
  103ff3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  103ff7:	75 f7                	jne    103ff0 <strlen+0x10>
    ;
  return n;
}
  103ff9:	5d                   	pop    %ebp
  103ffa:	c3                   	ret    
  103ffb:	90                   	nop

00103ffc <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
  103ffc:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
  104000:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
  104004:	55                   	push   %ebp
  pushl %ebx
  104005:	53                   	push   %ebx
  pushl %esi
  104006:	56                   	push   %esi
  pushl %edi
  104007:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
  104008:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
  10400a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
  10400c:	5f                   	pop    %edi
  popl %esi
  10400d:	5e                   	pop    %esi
  popl %ebx
  10400e:	5b                   	pop    %ebx
  popl %ebp
  10400f:	5d                   	pop    %ebp
  ret
  104010:	c3                   	ret    
  104011:	90                   	nop
  104012:	90                   	nop
  104013:	90                   	nop
  104014:	90                   	nop
  104015:	90                   	nop
  104016:	90                   	nop
  104017:	90                   	nop
  104018:	90                   	nop
  104019:	90                   	nop
  10401a:	90                   	nop
  10401b:	90                   	nop
  10401c:	90                   	nop
  10401d:	90                   	nop
  10401e:	90                   	nop
  10401f:	90                   	nop

00104020 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  104020:	55                   	push   %ebp
  104021:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
  104023:	8b 55 08             	mov    0x8(%ebp),%edx
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  104026:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(addr >= p->sz || addr+4 > p->sz)
  104029:	8b 12                	mov    (%edx),%edx
  10402b:	39 c2                	cmp    %eax,%edx
  10402d:	77 09                	ja     104038 <fetchint+0x18>
    return -1;
  *ip = *(int*)(addr);
  return 0;
  10402f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104034:	5d                   	pop    %ebp
  104035:	c3                   	ret    
  104036:	66 90                	xchg   %ax,%ax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  104038:	8d 48 04             	lea    0x4(%eax),%ecx
  10403b:	39 ca                	cmp    %ecx,%edx
  10403d:	72 f0                	jb     10402f <fetchint+0xf>
    return -1;
  *ip = *(int*)(addr);
  10403f:	8b 10                	mov    (%eax),%edx
  104041:	8b 45 10             	mov    0x10(%ebp),%eax
  104044:	89 10                	mov    %edx,(%eax)
  104046:	31 c0                	xor    %eax,%eax
  return 0;
}
  104048:	5d                   	pop    %ebp
  104049:	c3                   	ret    
  10404a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00104050 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  104050:	55                   	push   %ebp
  104051:	89 e5                	mov    %esp,%ebp
  104053:	8b 45 08             	mov    0x8(%ebp),%eax
  104056:	8b 55 0c             	mov    0xc(%ebp),%edx
  104059:	53                   	push   %ebx
  char *s, *ep;

  if(addr >= p->sz)
  10405a:	39 10                	cmp    %edx,(%eax)
  10405c:	77 0a                	ja     104068 <fetchstr+0x18>
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  10405e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    if(*s == 0)
      return s - *pp;
  return -1;
}
  104063:	5b                   	pop    %ebx
  104064:	5d                   	pop    %ebp
  104065:	c3                   	ret    
  104066:	66 90                	xchg   %ax,%ax
{
  char *s, *ep;

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  104068:	8b 4d 10             	mov    0x10(%ebp),%ecx
  10406b:	89 11                	mov    %edx,(%ecx)
  ep = (char*)p->sz;
  10406d:	8b 18                	mov    (%eax),%ebx
  for(s = *pp; s < ep; s++)
  10406f:	39 da                	cmp    %ebx,%edx
  104071:	73 eb                	jae    10405e <fetchstr+0xe>
    if(*s == 0)
  104073:	31 c0                	xor    %eax,%eax
  104075:	89 d1                	mov    %edx,%ecx
  104077:	80 3a 00             	cmpb   $0x0,(%edx)
  10407a:	74 e7                	je     104063 <fetchstr+0x13>
  10407c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  104080:	83 c1 01             	add    $0x1,%ecx
  104083:	39 cb                	cmp    %ecx,%ebx
  104085:	76 d7                	jbe    10405e <fetchstr+0xe>
    if(*s == 0)
  104087:	80 39 00             	cmpb   $0x0,(%ecx)
  10408a:	75 f4                	jne    104080 <fetchstr+0x30>
  10408c:	89 c8                	mov    %ecx,%eax
  10408e:	29 d0                	sub    %edx,%eax
  104090:	eb d1                	jmp    104063 <fetchstr+0x13>
  104092:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  104099:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001040a0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1040a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  1040a6:	55                   	push   %ebp
  1040a7:	89 e5                	mov    %esp,%ebp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1040a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1040ac:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1040af:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1040b1:	8b 52 44             	mov    0x44(%edx),%edx
  1040b4:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1040b8:	39 c2                	cmp    %eax,%edx
  1040ba:	72 0c                	jb     1040c8 <argint+0x28>
    return -1;
  *ip = *(int*)(addr);
  1040bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  1040c1:	5d                   	pop    %ebp
  1040c2:	c3                   	ret    
  1040c3:	90                   	nop
  1040c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1040c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  1040cb:	39 c8                	cmp    %ecx,%eax
  1040cd:	72 ed                	jb     1040bc <argint+0x1c>
    return -1;
  *ip = *(int*)(addr);
  1040cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1040d2:	8b 12                	mov    (%edx),%edx
  1040d4:	89 10                	mov    %edx,(%eax)
  1040d6:	31 c0                	xor    %eax,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
}
  1040d8:	5d                   	pop    %ebp
  1040d9:	c3                   	ret    
  1040da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001040e0 <argptr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1040e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
  1040e6:	55                   	push   %ebp
  1040e7:	89 e5                	mov    %esp,%ebp

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1040e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1040ec:	8b 50 18             	mov    0x18(%eax),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1040ef:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  1040f1:	8b 52 44             	mov    0x44(%edx),%edx
  1040f4:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  1040f8:	39 c2                	cmp    %eax,%edx
  1040fa:	73 07                	jae    104103 <argptr+0x23>
  1040fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  1040ff:	39 c8                	cmp    %ecx,%eax
  104101:	73 0d                	jae    104110 <argptr+0x30>
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
    return -1;
  *pp = (char*)i;
  return 0;
  104103:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104108:	5d                   	pop    %ebp
  104109:	c3                   	ret    
  10410a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  104110:	8b 12                	mov    (%edx),%edx
{
  int i;
  
  if(argint(n, &i) < 0)
    return -1;
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
  104112:	39 c2                	cmp    %eax,%edx
  104114:	73 ed                	jae    104103 <argptr+0x23>
  104116:	8b 4d 10             	mov    0x10(%ebp),%ecx
  104119:	01 d1                	add    %edx,%ecx
  10411b:	39 c1                	cmp    %eax,%ecx
  10411d:	77 e4                	ja     104103 <argptr+0x23>
    return -1;
  *pp = (char*)i;
  10411f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104122:	89 10                	mov    %edx,(%eax)
  104124:	31 c0                	xor    %eax,%eax
  return 0;
}
  104126:	5d                   	pop    %ebp
  104127:	c3                   	ret    
  104128:	90                   	nop
  104129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104130 <argstr>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  104130:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
  104137:	55                   	push   %ebp
  104138:	89 e5                	mov    %esp,%ebp
  10413a:	53                   	push   %ebx

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
  10413b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10413e:	8b 42 18             	mov    0x18(%edx),%eax
  104141:	8b 40 44             	mov    0x44(%eax),%eax
  104144:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
  104148:	8b 0a                	mov    (%edx),%ecx
  10414a:	39 c8                	cmp    %ecx,%eax
  10414c:	73 07                	jae    104155 <argstr+0x25>
  10414e:	8d 58 04             	lea    0x4(%eax),%ebx
  104151:	39 d9                	cmp    %ebx,%ecx
  104153:	73 0b                	jae    104160 <argstr+0x30>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  104155:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  10415a:	5b                   	pop    %ebx
  10415b:	5d                   	pop    %ebp
  10415c:	c3                   	ret    
  10415d:	8d 76 00             	lea    0x0(%esi),%esi
int
fetchint(struct proc *p, uint addr, int *ip)
{
  if(addr >= p->sz || addr+4 > p->sz)
    return -1;
  *ip = *(int*)(addr);
  104160:	8b 18                	mov    (%eax),%ebx
int
fetchstr(struct proc *p, uint addr, char **pp)
{
  char *s, *ep;

  if(addr >= p->sz)
  104162:	39 cb                	cmp    %ecx,%ebx
  104164:	73 ef                	jae    104155 <argstr+0x25>
    return -1;
  *pp = (char*)addr;
  104166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  104169:	89 d8                	mov    %ebx,%eax
  10416b:	89 19                	mov    %ebx,(%ecx)
  ep = (char*)p->sz;
  10416d:	8b 12                	mov    (%edx),%edx
  for(s = *pp; s < ep; s++)
  10416f:	39 d3                	cmp    %edx,%ebx
  104171:	73 e2                	jae    104155 <argstr+0x25>
    if(*s == 0)
  104173:	80 3b 00             	cmpb   $0x0,(%ebx)
  104176:	75 12                	jne    10418a <argstr+0x5a>
  104178:	eb 1e                	jmp    104198 <argstr+0x68>
  10417a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104180:	80 38 00             	cmpb   $0x0,(%eax)
  104183:	90                   	nop
  104184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104188:	74 0e                	je     104198 <argstr+0x68>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
  10418a:	83 c0 01             	add    $0x1,%eax
  10418d:	39 c2                	cmp    %eax,%edx
  10418f:	90                   	nop
  104190:	77 ee                	ja     104180 <argstr+0x50>
  104192:	eb c1                	jmp    104155 <argstr+0x25>
  104194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s == 0)
      return s - *pp;
  104198:	29 d8                	sub    %ebx,%eax
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(proc, addr, pp);
}
  10419a:	5b                   	pop    %ebx
  10419b:	5d                   	pop    %ebp
  10419c:	c3                   	ret    
  10419d:	8d 76 00             	lea    0x0(%esi),%esi

001041a0 <syscall>:
[SYS_clone]   sys_clone,
};

void
syscall(void)
{
  1041a0:	55                   	push   %ebp
  1041a1:	89 e5                	mov    %esp,%ebp
  1041a3:	53                   	push   %ebx
  1041a4:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
  1041a7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  1041ae:	8b 5a 18             	mov    0x18(%edx),%ebx
  1041b1:	8b 43 1c             	mov    0x1c(%ebx),%eax
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
  1041b4:	83 f8 16             	cmp    $0x16,%eax
  1041b7:	77 17                	ja     1041d0 <syscall+0x30>
  1041b9:	8b 0c 85 e0 6c 10 00 	mov    0x106ce0(,%eax,4),%ecx
  1041c0:	85 c9                	test   %ecx,%ecx
  1041c2:	74 0c                	je     1041d0 <syscall+0x30>
    proc->tf->eax = syscalls[num]();
  1041c4:	ff d1                	call   *%ecx
  1041c6:	89 43 1c             	mov    %eax,0x1c(%ebx)
  else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  }
}
  1041c9:	83 c4 14             	add    $0x14,%esp
  1041cc:	5b                   	pop    %ebx
  1041cd:	5d                   	pop    %ebp
  1041ce:	c3                   	ret    
  1041cf:	90                   	nop

  num = proc->tf->eax;
  if(num >= 0 && num < NELEM(syscalls) && syscalls[num])
    proc->tf->eax = syscalls[num]();
  else {
    cprintf("%d %s: unknown sys call %d\n",
  1041d0:	8b 4a 10             	mov    0x10(%edx),%ecx
  1041d3:	83 c2 6c             	add    $0x6c,%edx
  1041d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1041da:	89 54 24 08          	mov    %edx,0x8(%esp)
  1041de:	c7 04 24 a6 6c 10 00 	movl   $0x106ca6,(%esp)
  1041e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  1041e9:	e8 d2 c3 ff ff       	call   1005c0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
  1041ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1041f4:	8b 40 18             	mov    0x18(%eax),%eax
  1041f7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
  1041fe:	83 c4 14             	add    $0x14,%esp
  104201:	5b                   	pop    %ebx
  104202:	5d                   	pop    %ebp
  104203:	c3                   	ret    
  104204:	90                   	nop
  104205:	90                   	nop
  104206:	90                   	nop
  104207:	90                   	nop
  104208:	90                   	nop
  104209:	90                   	nop
  10420a:	90                   	nop
  10420b:	90                   	nop
  10420c:	90                   	nop
  10420d:	90                   	nop
  10420e:	90                   	nop
  10420f:	90                   	nop

00104210 <sys_pipe>:
  return exec(path, argv);
}

int
sys_pipe(void)
{
  104210:	55                   	push   %ebp
  104211:	89 e5                	mov    %esp,%ebp
  104213:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  104216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return exec(path, argv);
}

int
sys_pipe(void)
{
  104219:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  10421c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
  10421f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  104226:	00 
  104227:	89 44 24 04          	mov    %eax,0x4(%esp)
  10422b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104232:	e8 a9 fe ff ff       	call   1040e0 <argptr>
  104237:	85 c0                	test   %eax,%eax
  104239:	79 15                	jns    104250 <sys_pipe+0x40>
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  10423b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
}
  104240:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  104243:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104246:	89 ec                	mov    %ebp,%esp
  104248:	5d                   	pop    %ebp
  104249:	c3                   	ret    
  10424a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
  104250:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104253:	89 44 24 04          	mov    %eax,0x4(%esp)
  104257:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10425a:	89 04 24             	mov    %eax,(%esp)
  10425d:	e8 1e ed ff ff       	call   102f80 <pipealloc>
  104262:	85 c0                	test   %eax,%eax
  104264:	78 d5                	js     10423b <sys_pipe+0x2b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  104266:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  104269:	31 c0                	xor    %eax,%eax
  10426b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104278:	8b 5c 82 28          	mov    0x28(%edx,%eax,4),%ebx
  10427c:	85 db                	test   %ebx,%ebx
  10427e:	74 28                	je     1042a8 <sys_pipe+0x98>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104280:	83 c0 01             	add    $0x1,%eax
  104283:	83 f8 10             	cmp    $0x10,%eax
  104286:	75 f0                	jne    104278 <sys_pipe+0x68>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
    fileclose(rf);
  104288:	89 0c 24             	mov    %ecx,(%esp)
  10428b:	e8 70 cd ff ff       	call   101000 <fileclose>
    fileclose(wf);
  104290:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104293:	89 04 24             	mov    %eax,(%esp)
  104296:	e8 65 cd ff ff       	call   101000 <fileclose>
  10429b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  1042a0:	eb 9e                	jmp    104240 <sys_pipe+0x30>
  1042a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1042a8:	8d 58 08             	lea    0x8(%eax),%ebx
  1042ab:	89 4c 9a 08          	mov    %ecx,0x8(%edx,%ebx,4)
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
  1042af:	8b 75 ec             	mov    -0x14(%ebp),%esi
  1042b2:	31 d2                	xor    %edx,%edx
  1042b4:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
  1042bb:	90                   	nop
  1042bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  1042c0:	83 7c 91 28 00       	cmpl   $0x0,0x28(%ecx,%edx,4)
  1042c5:	74 19                	je     1042e0 <sys_pipe+0xd0>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  1042c7:	83 c2 01             	add    $0x1,%edx
  1042ca:	83 fa 10             	cmp    $0x10,%edx
  1042cd:	75 f1                	jne    1042c0 <sys_pipe+0xb0>
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      proc->ofile[fd0] = 0;
  1042cf:	c7 44 99 08 00 00 00 	movl   $0x0,0x8(%ecx,%ebx,4)
  1042d6:	00 
  1042d7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1042da:	eb ac                	jmp    104288 <sys_pipe+0x78>
  1042dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1042e0:	89 74 91 28          	mov    %esi,0x28(%ecx,%edx,4)
      proc->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
  1042e4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1042e7:	89 01                	mov    %eax,(%ecx)
  fd[1] = fd1;
  1042e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042ec:	89 50 04             	mov    %edx,0x4(%eax)
  1042ef:	31 c0                	xor    %eax,%eax
  return 0;
  1042f1:	e9 4a ff ff ff       	jmp    104240 <sys_pipe+0x30>
  1042f6:	8d 76 00             	lea    0x0(%esi),%esi
  1042f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104300 <sys_exec>:
  return 0;
}

int
sys_exec(void)
{
  104300:	55                   	push   %ebp
  104301:	89 e5                	mov    %esp,%ebp
  104303:	81 ec b8 00 00 00    	sub    $0xb8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  104309:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 0;
}

int
sys_exec(void)
{
  10430c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  10430f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  104312:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  104315:	89 44 24 04          	mov    %eax,0x4(%esp)
  104319:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104320:	e8 0b fe ff ff       	call   104130 <argstr>
  104325:	85 c0                	test   %eax,%eax
  104327:	79 17                	jns    104340 <sys_exec+0x40>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv))
  104329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
}
  10432e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  104331:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104334:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104337:	89 ec                	mov    %ebp,%esp
  104339:	5d                   	pop    %ebp
  10433a:	c3                   	ret    
  10433b:	90                   	nop
  10433c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
  104340:	8d 45 e0             	lea    -0x20(%ebp),%eax
  104343:	89 44 24 04          	mov    %eax,0x4(%esp)
  104347:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10434e:	e8 4d fd ff ff       	call   1040a0 <argint>
  104353:	85 c0                	test   %eax,%eax
  104355:	78 d2                	js     104329 <sys_exec+0x29>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  104357:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  10435d:	31 f6                	xor    %esi,%esi
  10435f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  104366:	00 
  104367:	31 db                	xor    %ebx,%ebx
  104369:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104370:	00 
  104371:	89 3c 24             	mov    %edi,(%esp)
  104374:	e8 87 fa ff ff       	call   103e00 <memset>
  104379:	eb 2c                	jmp    1043a7 <sys_exec+0xa7>
  10437b:	90                   	nop
  10437c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
  104380:	89 44 24 04          	mov    %eax,0x4(%esp)
  104384:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10438a:	8d 14 b7             	lea    (%edi,%esi,4),%edx
  10438d:	89 54 24 08          	mov    %edx,0x8(%esp)
  104391:	89 04 24             	mov    %eax,(%esp)
  104394:	e8 b7 fc ff ff       	call   104050 <fetchstr>
  104399:	85 c0                	test   %eax,%eax
  10439b:	78 8c                	js     104329 <sys_exec+0x29>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  10439d:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
  1043a0:	83 fb 20             	cmp    $0x20,%ebx

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
  1043a3:	89 de                	mov    %ebx,%esi
    if(i >= NELEM(argv))
  1043a5:	74 82                	je     104329 <sys_exec+0x29>
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
  1043a7:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1043aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  1043ae:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  1043b5:	03 45 e0             	add    -0x20(%ebp),%eax
  1043b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1043bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1043c2:	89 04 24             	mov    %eax,(%esp)
  1043c5:	e8 56 fc ff ff       	call   104020 <fetchint>
  1043ca:	85 c0                	test   %eax,%eax
  1043cc:	0f 88 57 ff ff ff    	js     104329 <sys_exec+0x29>
      return -1;
    if(uarg == 0){
  1043d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043d5:	85 c0                	test   %eax,%eax
  1043d7:	75 a7                	jne    104380 <sys_exec+0x80>
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  1043d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
  1043dc:	c7 84 9d 5c ff ff ff 	movl   $0x0,-0xa4(%ebp,%ebx,4)
  1043e3:	00 00 00 00 
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
  1043e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1043eb:	89 04 24             	mov    %eax,(%esp)
  1043ee:	e8 3d c6 ff ff       	call   100a30 <exec>
  1043f3:	e9 36 ff ff ff       	jmp    10432e <sys_exec+0x2e>
  1043f8:	90                   	nop
  1043f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104400 <sys_chdir>:
  return 0;
}

int
sys_chdir(void)
{
  104400:	55                   	push   %ebp
  104401:	89 e5                	mov    %esp,%ebp
  104403:	53                   	push   %ebx
  104404:	83 ec 24             	sub    $0x24,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  104407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10440a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10440e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104415:	e8 16 fd ff ff       	call   104130 <argstr>
  10441a:	85 c0                	test   %eax,%eax
  10441c:	79 12                	jns    104430 <sys_chdir+0x30>
    return -1;
  }
  iunlock(ip);
  iput(proc->cwd);
  proc->cwd = ip;
  return 0;
  10441e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104423:	83 c4 24             	add    $0x24,%esp
  104426:	5b                   	pop    %ebx
  104427:	5d                   	pop    %ebp
  104428:	c3                   	ret    
  104429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
sys_chdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  104430:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104433:	89 04 24             	mov    %eax,(%esp)
  104436:	e8 a5 da ff ff       	call   101ee0 <namei>
  10443b:	85 c0                	test   %eax,%eax
  10443d:	89 c3                	mov    %eax,%ebx
  10443f:	74 dd                	je     10441e <sys_chdir+0x1e>
    return -1;
  ilock(ip);
  104441:	89 04 24             	mov    %eax,(%esp)
  104444:	e8 f7 d7 ff ff       	call   101c40 <ilock>
  if(ip->type != T_DIR){
  104449:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10444e:	75 26                	jne    104476 <sys_chdir+0x76>
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  104450:	89 1c 24             	mov    %ebx,(%esp)
  104453:	e8 a8 d3 ff ff       	call   101800 <iunlock>
  iput(proc->cwd);
  104458:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10445e:	8b 40 68             	mov    0x68(%eax),%eax
  104461:	89 04 24             	mov    %eax,(%esp)
  104464:	e8 a7 d4 ff ff       	call   101910 <iput>
  proc->cwd = ip;
  104469:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10446f:	89 58 68             	mov    %ebx,0x68(%eax)
  104472:	31 c0                	xor    %eax,%eax
  return 0;
  104474:	eb ad                	jmp    104423 <sys_chdir+0x23>

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
    return -1;
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
  104476:	89 1c 24             	mov    %ebx,(%esp)
  104479:	e8 d2 d6 ff ff       	call   101b50 <iunlockput>
  10447e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104483:	eb 9e                	jmp    104423 <sys_chdir+0x23>
  104485:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104489:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104490 <create>:
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  104490:	55                   	push   %ebp
  104491:	89 e5                	mov    %esp,%ebp
  104493:	83 ec 58             	sub    $0x58,%esp
  104496:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  104499:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10449c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  10449f:	8d 75 d6             	lea    -0x2a(%ebp),%esi
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  1044a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  1044a5:	31 db                	xor    %ebx,%ebx
  return 0;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  1044a7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  1044aa:	89 d7                	mov    %edx,%edi
  1044ac:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
  1044af:	89 74 24 04          	mov    %esi,0x4(%esp)
  1044b3:	89 04 24             	mov    %eax,(%esp)
  1044b6:	e8 05 da ff ff       	call   101ec0 <nameiparent>
  1044bb:	85 c0                	test   %eax,%eax
  1044bd:	74 47                	je     104506 <create+0x76>
    return 0;
  ilock(dp);
  1044bf:	89 04 24             	mov    %eax,(%esp)
  1044c2:	89 45 bc             	mov    %eax,-0x44(%ebp)
  1044c5:	e8 76 d7 ff ff       	call   101c40 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
  1044ca:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1044cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1044d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1044d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  1044d8:	89 14 24             	mov    %edx,(%esp)
  1044db:	e8 20 d2 ff ff       	call   101700 <dirlookup>
  1044e0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1044e3:	85 c0                	test   %eax,%eax
  1044e5:	89 c3                	mov    %eax,%ebx
  1044e7:	74 3f                	je     104528 <create+0x98>
    iunlockput(dp);
  1044e9:	89 14 24             	mov    %edx,(%esp)
  1044ec:	e8 5f d6 ff ff       	call   101b50 <iunlockput>
    ilock(ip);
  1044f1:	89 1c 24             	mov    %ebx,(%esp)
  1044f4:	e8 47 d7 ff ff       	call   101c40 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
  1044f9:	66 83 ff 02          	cmp    $0x2,%di
  1044fd:	75 19                	jne    104518 <create+0x88>
  1044ff:	66 83 7b 10 02       	cmpw   $0x2,0x10(%ebx)
  104504:	75 12                	jne    104518 <create+0x88>
  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);
  return ip;
}
  104506:	89 d8                	mov    %ebx,%eax
  104508:	8b 75 f8             	mov    -0x8(%ebp),%esi
  10450b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10450e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104511:	89 ec                	mov    %ebp,%esp
  104513:	5d                   	pop    %ebp
  104514:	c3                   	ret    
  104515:	8d 76 00             	lea    0x0(%esi),%esi
  if((ip = dirlookup(dp, name, &off)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
  104518:	89 1c 24             	mov    %ebx,(%esp)
  10451b:	31 db                	xor    %ebx,%ebx
  10451d:	e8 2e d6 ff ff       	call   101b50 <iunlockput>
    return 0;
  104522:	eb e2                	jmp    104506 <create+0x76>
  104524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

  if((ip = ialloc(dp->dev, type)) == 0)
  104528:	0f bf c7             	movswl %di,%eax
  10452b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10452f:	8b 02                	mov    (%edx),%eax
  104531:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104534:	89 04 24             	mov    %eax,(%esp)
  104537:	e8 34 d6 ff ff       	call   101b70 <ialloc>
  10453c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10453f:	85 c0                	test   %eax,%eax
  104541:	89 c3                	mov    %eax,%ebx
  104543:	0f 84 b7 00 00 00    	je     104600 <create+0x170>
    panic("create: ialloc");

  ilock(ip);
  104549:	89 55 bc             	mov    %edx,-0x44(%ebp)
  10454c:	89 04 24             	mov    %eax,(%esp)
  10454f:	e8 ec d6 ff ff       	call   101c40 <ilock>
  ip->major = major;
  104554:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
  104558:	66 89 43 12          	mov    %ax,0x12(%ebx)
  ip->minor = minor;
  10455c:	0f b7 4d c0          	movzwl -0x40(%ebp),%ecx
  ip->nlink = 1;
  104560:	66 c7 43 16 01 00    	movw   $0x1,0x16(%ebx)
  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");

  ilock(ip);
  ip->major = major;
  ip->minor = minor;
  104566:	66 89 4b 14          	mov    %cx,0x14(%ebx)
  ip->nlink = 1;
  iupdate(ip);
  10456a:	89 1c 24             	mov    %ebx,(%esp)
  10456d:	e8 8e cf ff ff       	call   101500 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
  104572:	66 83 ff 01          	cmp    $0x1,%di
  104576:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104579:	74 2d                	je     1045a8 <create+0x118>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
  10457b:	8b 43 04             	mov    0x4(%ebx),%eax
  10457e:	89 14 24             	mov    %edx,(%esp)
  104581:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104584:	89 74 24 04          	mov    %esi,0x4(%esp)
  104588:	89 44 24 08          	mov    %eax,0x8(%esp)
  10458c:	e8 cf d4 ff ff       	call   101a60 <dirlink>
  104591:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104594:	85 c0                	test   %eax,%eax
  104596:	78 74                	js     10460c <create+0x17c>
    panic("create: dirlink");

  iunlockput(dp);
  104598:	89 14 24             	mov    %edx,(%esp)
  10459b:	e8 b0 d5 ff ff       	call   101b50 <iunlockput>
  return ip;
  1045a0:	e9 61 ff ff ff       	jmp    104506 <create+0x76>
  1045a5:	8d 76 00             	lea    0x0(%esi),%esi
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
  1045a8:	66 83 42 16 01       	addw   $0x1,0x16(%edx)
    iupdate(dp);
  1045ad:	89 14 24             	mov    %edx,(%esp)
  1045b0:	89 55 bc             	mov    %edx,-0x44(%ebp)
  1045b3:	e8 48 cf ff ff       	call   101500 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
  1045b8:	8b 43 04             	mov    0x4(%ebx),%eax
  1045bb:	c7 44 24 04 4c 6d 10 	movl   $0x106d4c,0x4(%esp)
  1045c2:	00 
  1045c3:	89 1c 24             	mov    %ebx,(%esp)
  1045c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1045ca:	e8 91 d4 ff ff       	call   101a60 <dirlink>
  1045cf:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1045d2:	85 c0                	test   %eax,%eax
  1045d4:	78 1e                	js     1045f4 <create+0x164>
  1045d6:	8b 42 04             	mov    0x4(%edx),%eax
  1045d9:	c7 44 24 04 4b 6d 10 	movl   $0x106d4b,0x4(%esp)
  1045e0:	00 
  1045e1:	89 1c 24             	mov    %ebx,(%esp)
  1045e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1045e8:	e8 73 d4 ff ff       	call   101a60 <dirlink>
  1045ed:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1045f0:	85 c0                	test   %eax,%eax
  1045f2:	79 87                	jns    10457b <create+0xeb>
      panic("create dots");
  1045f4:	c7 04 24 4e 6d 10 00 	movl   $0x106d4e,(%esp)
  1045fb:	e8 b0 c3 ff ff       	call   1009b0 <panic>
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");
  104600:	c7 04 24 3c 6d 10 00 	movl   $0x106d3c,(%esp)
  104607:	e8 a4 c3 ff ff       	call   1009b0 <panic>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");
  10460c:	c7 04 24 5a 6d 10 00 	movl   $0x106d5a,(%esp)
  104613:	e8 98 c3 ff ff       	call   1009b0 <panic>
  104618:	90                   	nop
  104619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104620 <sys_mknod>:
  return 0;
}

int
sys_mknod(void)
{
  104620:	55                   	push   %ebp
  104621:	89 e5                	mov    %esp,%ebp
  104623:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  104626:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104629:	89 44 24 04          	mov    %eax,0x4(%esp)
  10462d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104634:	e8 f7 fa ff ff       	call   104130 <argstr>
  104639:	85 c0                	test   %eax,%eax
  10463b:	79 0b                	jns    104648 <sys_mknod+0x28>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  return 0;
  10463d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104642:	c9                   	leave  
  104643:	c3                   	ret    
  104644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
  104648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10464b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10464f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104656:	e8 45 fa ff ff       	call   1040a0 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10465b:	85 c0                	test   %eax,%eax
  10465d:	78 de                	js     10463d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
  10465f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104662:	89 44 24 04          	mov    %eax,0x4(%esp)
  104666:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10466d:	e8 2e fa ff ff       	call   1040a0 <argint>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  104672:	85 c0                	test   %eax,%eax
  104674:	78 c7                	js     10463d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
  104676:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
  10467a:	ba 03 00 00 00       	mov    $0x3,%edx
  10467f:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
  104683:	89 04 24             	mov    %eax,(%esp)
  104686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104689:	e8 02 fe ff ff       	call   104490 <create>
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  if((len=argstr(0, &path)) < 0 ||
  10468e:	85 c0                	test   %eax,%eax
  104690:	74 ab                	je     10463d <sys_mknod+0x1d>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0)
    return -1;
  iunlockput(ip);
  104692:	89 04 24             	mov    %eax,(%esp)
  104695:	e8 b6 d4 ff ff       	call   101b50 <iunlockput>
  10469a:	31 c0                	xor    %eax,%eax
  return 0;
}
  10469c:	c9                   	leave  
  10469d:	c3                   	ret    
  10469e:	66 90                	xchg   %ax,%ax

001046a0 <sys_mkdir>:
  return fd;
}

int
sys_mkdir(void)
{
  1046a0:	55                   	push   %ebp
  1046a1:	89 e5                	mov    %esp,%ebp
  1046a3:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  1046a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1046a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1046b4:	e8 77 fa ff ff       	call   104130 <argstr>
  1046b9:	85 c0                	test   %eax,%eax
  1046bb:	79 0b                	jns    1046c8 <sys_mkdir+0x28>
    return -1;
  iunlockput(ip);
  return 0;
  1046bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  1046c2:	c9                   	leave  
  1046c3:	c3                   	ret    
  1046c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_mkdir(void)
{
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  1046c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1046cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046d2:	31 c9                	xor    %ecx,%ecx
  1046d4:	ba 01 00 00 00       	mov    $0x1,%edx
  1046d9:	e8 b2 fd ff ff       	call   104490 <create>
  1046de:	85 c0                	test   %eax,%eax
  1046e0:	74 db                	je     1046bd <sys_mkdir+0x1d>
    return -1;
  iunlockput(ip);
  1046e2:	89 04 24             	mov    %eax,(%esp)
  1046e5:	e8 66 d4 ff ff       	call   101b50 <iunlockput>
  1046ea:	31 c0                	xor    %eax,%eax
  return 0;
}
  1046ec:	c9                   	leave  
  1046ed:	c3                   	ret    
  1046ee:	66 90                	xchg   %ax,%ax

001046f0 <sys_link>:
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1046f0:	55                   	push   %ebp
  1046f1:	89 e5                	mov    %esp,%ebp
  1046f3:	83 ec 48             	sub    $0x48,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  1046f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
  1046f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  1046fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1046ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  104702:	89 44 24 04          	mov    %eax,0x4(%esp)
  104706:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10470d:	e8 1e fa ff ff       	call   104130 <argstr>
  104712:	85 c0                	test   %eax,%eax
  104714:	79 12                	jns    104728 <sys_link+0x38>
bad:
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return -1;
  104716:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10471b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10471e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104721:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104724:	89 ec                	mov    %ebp,%esp
  104726:	5d                   	pop    %ebp
  104727:	c3                   	ret    
sys_link(void)
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
  104728:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  10472b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10472f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104736:	e8 f5 f9 ff ff       	call   104130 <argstr>
  10473b:	85 c0                	test   %eax,%eax
  10473d:	78 d7                	js     104716 <sys_link+0x26>
    return -1;
  if((ip = namei(old)) == 0)
  10473f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104742:	89 04 24             	mov    %eax,(%esp)
  104745:	e8 96 d7 ff ff       	call   101ee0 <namei>
  10474a:	85 c0                	test   %eax,%eax
  10474c:	89 c3                	mov    %eax,%ebx
  10474e:	74 c6                	je     104716 <sys_link+0x26>
    return -1;
  ilock(ip);
  104750:	89 04 24             	mov    %eax,(%esp)
  104753:	e8 e8 d4 ff ff       	call   101c40 <ilock>
  if(ip->type == T_DIR){
  104758:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  10475d:	0f 84 86 00 00 00    	je     1047e9 <sys_link+0xf9>
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  104763:	66 83 43 16 01       	addw   $0x1,0x16(%ebx)
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
  104768:	8d 7d d2             	lea    -0x2e(%ebp),%edi
  if(ip->type == T_DIR){
    iunlockput(ip);
    return -1;
  }
  ip->nlink++;
  iupdate(ip);
  10476b:	89 1c 24             	mov    %ebx,(%esp)
  10476e:	e8 8d cd ff ff       	call   101500 <iupdate>
  iunlock(ip);
  104773:	89 1c 24             	mov    %ebx,(%esp)
  104776:	e8 85 d0 ff ff       	call   101800 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
  10477b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10477e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104782:	89 04 24             	mov    %eax,(%esp)
  104785:	e8 36 d7 ff ff       	call   101ec0 <nameiparent>
  10478a:	85 c0                	test   %eax,%eax
  10478c:	89 c6                	mov    %eax,%esi
  10478e:	74 44                	je     1047d4 <sys_link+0xe4>
    goto bad;
  ilock(dp);
  104790:	89 04 24             	mov    %eax,(%esp)
  104793:	e8 a8 d4 ff ff       	call   101c40 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
  104798:	8b 06                	mov    (%esi),%eax
  10479a:	3b 03                	cmp    (%ebx),%eax
  10479c:	75 2e                	jne    1047cc <sys_link+0xdc>
  10479e:	8b 43 04             	mov    0x4(%ebx),%eax
  1047a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  1047a5:	89 34 24             	mov    %esi,(%esp)
  1047a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1047ac:	e8 af d2 ff ff       	call   101a60 <dirlink>
  1047b1:	85 c0                	test   %eax,%eax
  1047b3:	78 17                	js     1047cc <sys_link+0xdc>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
  1047b5:	89 34 24             	mov    %esi,(%esp)
  1047b8:	e8 93 d3 ff ff       	call   101b50 <iunlockput>
  iput(ip);
  1047bd:	89 1c 24             	mov    %ebx,(%esp)
  1047c0:	e8 4b d1 ff ff       	call   101910 <iput>
  1047c5:	31 c0                	xor    %eax,%eax
  return 0;
  1047c7:	e9 4f ff ff ff       	jmp    10471b <sys_link+0x2b>

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
  1047cc:	89 34 24             	mov    %esi,(%esp)
  1047cf:	e8 7c d3 ff ff       	call   101b50 <iunlockput>
  iunlockput(dp);
  iput(ip);
  return 0;

bad:
  ilock(ip);
  1047d4:	89 1c 24             	mov    %ebx,(%esp)
  1047d7:	e8 64 d4 ff ff       	call   101c40 <ilock>
  ip->nlink--;
  1047dc:	66 83 6b 16 01       	subw   $0x1,0x16(%ebx)
  iupdate(ip);
  1047e1:	89 1c 24             	mov    %ebx,(%esp)
  1047e4:	e8 17 cd ff ff       	call   101500 <iupdate>
  iunlockput(ip);
  1047e9:	89 1c 24             	mov    %ebx,(%esp)
  1047ec:	e8 5f d3 ff ff       	call   101b50 <iunlockput>
  1047f1:	83 c8 ff             	or     $0xffffffff,%eax
  return -1;
  1047f4:	e9 22 ff ff ff       	jmp    10471b <sys_link+0x2b>
  1047f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104800 <sys_open>:
  return ip;
}

int
sys_open(void)
{
  104800:	55                   	push   %ebp
  104801:	89 e5                	mov    %esp,%ebp
  104803:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  104806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return ip;
}

int
sys_open(void)
{
  104809:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  10480c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  10480f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104813:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10481a:	e8 11 f9 ff ff       	call   104130 <argstr>
  10481f:	85 c0                	test   %eax,%eax
  104821:	79 15                	jns    104838 <sys_open+0x38>

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  104823:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
}
  104828:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  10482b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  10482e:	89 ec                	mov    %ebp,%esp
  104830:	5d                   	pop    %ebp
  104831:	c3                   	ret    
  104832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
  104838:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10483b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10483f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104846:	e8 55 f8 ff ff       	call   1040a0 <argint>
  10484b:	85 c0                	test   %eax,%eax
  10484d:	78 d4                	js     104823 <sys_open+0x23>
    return -1;
  if(omode & O_CREATE){
  10484f:	f6 45 f1 02          	testb  $0x2,-0xf(%ebp)
  104853:	74 63                	je     1048b8 <sys_open+0xb8>
    if((ip = create(path, T_FILE, 0, 0)) == 0)
  104855:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104858:	31 c9                	xor    %ecx,%ecx
  10485a:	ba 02 00 00 00       	mov    $0x2,%edx
  10485f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104866:	e8 25 fc ff ff       	call   104490 <create>
  10486b:	85 c0                	test   %eax,%eax
  10486d:	89 c3                	mov    %eax,%ebx
  10486f:	74 b2                	je     104823 <sys_open+0x23>
      iunlockput(ip);
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
  104871:	e8 0a c7 ff ff       	call   100f80 <filealloc>
  104876:	85 c0                	test   %eax,%eax
  104878:	89 c6                	mov    %eax,%esi
  10487a:	74 24                	je     1048a0 <sys_open+0xa0>
  10487c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104883:	31 c0                	xor    %eax,%eax
  104885:	8d 76 00             	lea    0x0(%esi),%esi
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
  104888:	8b 4c 82 28          	mov    0x28(%edx,%eax,4),%ecx
  10488c:	85 c9                	test   %ecx,%ecx
  10488e:	74 58                	je     1048e8 <sys_open+0xe8>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104890:	83 c0 01             	add    $0x1,%eax
  104893:	83 f8 10             	cmp    $0x10,%eax
  104896:	75 f0                	jne    104888 <sys_open+0x88>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
  104898:	89 34 24             	mov    %esi,(%esp)
  10489b:	e8 60 c7 ff ff       	call   101000 <fileclose>
    iunlockput(ip);
  1048a0:	89 1c 24             	mov    %ebx,(%esp)
  1048a3:	e8 a8 d2 ff ff       	call   101b50 <iunlockput>
  1048a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  1048ad:	e9 76 ff ff ff       	jmp    104828 <sys_open+0x28>
  1048b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
  if(omode & O_CREATE){
    if((ip = create(path, T_FILE, 0, 0)) == 0)
      return -1;
  } else {
    if((ip = namei(path)) == 0)
  1048b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048bb:	89 04 24             	mov    %eax,(%esp)
  1048be:	e8 1d d6 ff ff       	call   101ee0 <namei>
  1048c3:	85 c0                	test   %eax,%eax
  1048c5:	89 c3                	mov    %eax,%ebx
  1048c7:	0f 84 56 ff ff ff    	je     104823 <sys_open+0x23>
      return -1;
    ilock(ip);
  1048cd:	89 04 24             	mov    %eax,(%esp)
  1048d0:	e8 6b d3 ff ff       	call   101c40 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
  1048d5:	66 83 7b 10 01       	cmpw   $0x1,0x10(%ebx)
  1048da:	75 95                	jne    104871 <sys_open+0x71>
  1048dc:	8b 75 f0             	mov    -0x10(%ebp),%esi
  1048df:	85 f6                	test   %esi,%esi
  1048e1:	74 8e                	je     104871 <sys_open+0x71>
  1048e3:	eb bb                	jmp    1048a0 <sys_open+0xa0>
  1048e5:	8d 76 00             	lea    0x0(%esi),%esi
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
  1048e8:	89 74 82 28          	mov    %esi,0x28(%edx,%eax,4)
    if(f)
      fileclose(f);
    iunlockput(ip);
    return -1;
  }
  iunlock(ip);
  1048ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1048ef:	89 1c 24             	mov    %ebx,(%esp)
  1048f2:	e8 09 cf ff ff       	call   101800 <iunlock>

  f->type = FD_INODE;
  1048f7:	c7 06 02 00 00 00    	movl   $0x2,(%esi)
  f->ip = ip;
  1048fd:	89 5e 10             	mov    %ebx,0x10(%esi)
  f->off = 0;
  104900:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)
  f->readable = !(omode & O_WRONLY);
  104907:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10490a:	83 f2 01             	xor    $0x1,%edx
  10490d:	83 e2 01             	and    $0x1,%edx
  104910:	88 56 08             	mov    %dl,0x8(%esi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  104913:	f6 45 f0 03          	testb  $0x3,-0x10(%ebp)
  104917:	0f 95 46 09          	setne  0x9(%esi)
  return fd;
  10491b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10491e:	e9 05 ff ff ff       	jmp    104828 <sys_open+0x28>
  104923:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104929:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104930 <sys_unlink>:
  return 1;
}

int
sys_unlink(void)
{
  104930:	55                   	push   %ebp
  104931:	89 e5                	mov    %esp,%ebp
  104933:	83 ec 78             	sub    $0x78,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  104936:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 1;
}

int
sys_unlink(void)
{
  104939:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  10493c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  10493f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
  104942:	89 44 24 04          	mov    %eax,0x4(%esp)
  104946:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10494d:	e8 de f7 ff ff       	call   104130 <argstr>
  104952:	85 c0                	test   %eax,%eax
  104954:	79 12                	jns    104968 <sys_unlink+0x38>
  iunlockput(dp);

  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  return 0;
  104956:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  10495b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10495e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  104961:	8b 7d fc             	mov    -0x4(%ebp),%edi
  104964:	89 ec                	mov    %ebp,%esp
  104966:	5d                   	pop    %ebp
  104967:	c3                   	ret    
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
    return -1;
  if((dp = nameiparent(path, name)) == 0)
  104968:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10496b:	8d 5d d2             	lea    -0x2e(%ebp),%ebx
  10496e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104972:	89 04 24             	mov    %eax,(%esp)
  104975:	e8 46 d5 ff ff       	call   101ec0 <nameiparent>
  10497a:	85 c0                	test   %eax,%eax
  10497c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  10497f:	74 d5                	je     104956 <sys_unlink+0x26>
    return -1;
  ilock(dp);
  104981:	89 04 24             	mov    %eax,(%esp)
  104984:	e8 b7 d2 ff ff       	call   101c40 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0){
  104989:	c7 44 24 04 4c 6d 10 	movl   $0x106d4c,0x4(%esp)
  104990:	00 
  104991:	89 1c 24             	mov    %ebx,(%esp)
  104994:	e8 37 cd ff ff       	call   1016d0 <namecmp>
  104999:	85 c0                	test   %eax,%eax
  10499b:	0f 84 a4 00 00 00    	je     104a45 <sys_unlink+0x115>
  1049a1:	c7 44 24 04 4b 6d 10 	movl   $0x106d4b,0x4(%esp)
  1049a8:	00 
  1049a9:	89 1c 24             	mov    %ebx,(%esp)
  1049ac:	e8 1f cd ff ff       	call   1016d0 <namecmp>
  1049b1:	85 c0                	test   %eax,%eax
  1049b3:	0f 84 8c 00 00 00    	je     104a45 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }

  if((ip = dirlookup(dp, name, &off)) == 0){
  1049b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1049bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  1049c0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1049c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1049c7:	89 04 24             	mov    %eax,(%esp)
  1049ca:	e8 31 cd ff ff       	call   101700 <dirlookup>
  1049cf:	85 c0                	test   %eax,%eax
  1049d1:	89 c6                	mov    %eax,%esi
  1049d3:	74 70                	je     104a45 <sys_unlink+0x115>
    iunlockput(dp);
    return -1;
  }
  ilock(ip);
  1049d5:	89 04 24             	mov    %eax,(%esp)
  1049d8:	e8 63 d2 ff ff       	call   101c40 <ilock>

  if(ip->nlink < 1)
  1049dd:	66 83 7e 16 00       	cmpw   $0x0,0x16(%esi)
  1049e2:	0f 8e 0e 01 00 00    	jle    104af6 <sys_unlink+0x1c6>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
  1049e8:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  1049ed:	75 71                	jne    104a60 <sys_unlink+0x130>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
  1049ef:	83 7e 18 20          	cmpl   $0x20,0x18(%esi)
  1049f3:	76 6b                	jbe    104a60 <sys_unlink+0x130>
  1049f5:	8d 7d b2             	lea    -0x4e(%ebp),%edi
  1049f8:	bb 20 00 00 00       	mov    $0x20,%ebx
  1049fd:	8d 76 00             	lea    0x0(%esi),%esi
  104a00:	eb 0e                	jmp    104a10 <sys_unlink+0xe0>
  104a02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104a08:	83 c3 10             	add    $0x10,%ebx
  104a0b:	3b 5e 18             	cmp    0x18(%esi),%ebx
  104a0e:	73 50                	jae    104a60 <sys_unlink+0x130>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  104a10:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  104a17:	00 
  104a18:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  104a1c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  104a20:	89 34 24             	mov    %esi,(%esp)
  104a23:	e8 c8 c9 ff ff       	call   1013f0 <readi>
  104a28:	83 f8 10             	cmp    $0x10,%eax
  104a2b:	0f 85 ad 00 00 00    	jne    104ade <sys_unlink+0x1ae>
      panic("isdirempty: readi");
    if(de.inum != 0)
  104a31:	66 83 7d b2 00       	cmpw   $0x0,-0x4e(%ebp)
  104a36:	74 d0                	je     104a08 <sys_unlink+0xd8>
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
  104a38:	89 34 24             	mov    %esi,(%esp)
  104a3b:	90                   	nop
  104a3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  104a40:	e8 0b d1 ff ff       	call   101b50 <iunlockput>
    iunlockput(dp);
  104a45:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104a48:	89 04 24             	mov    %eax,(%esp)
  104a4b:	e8 00 d1 ff ff       	call   101b50 <iunlockput>
  104a50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  104a55:	e9 01 ff ff ff       	jmp    10495b <sys_unlink+0x2b>
  104a5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  memset(&de, 0, sizeof(de));
  104a60:	8d 5d c2             	lea    -0x3e(%ebp),%ebx
  104a63:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  104a6a:	00 
  104a6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104a72:	00 
  104a73:	89 1c 24             	mov    %ebx,(%esp)
  104a76:	e8 85 f3 ff ff       	call   103e00 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
  104a7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a7e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  104a85:	00 
  104a86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104a8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  104a8e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104a91:	89 04 24             	mov    %eax,(%esp)
  104a94:	e8 f7 ca ff ff       	call   101590 <writei>
  104a99:	83 f8 10             	cmp    $0x10,%eax
  104a9c:	75 4c                	jne    104aea <sys_unlink+0x1ba>
    panic("unlink: writei");
  if(ip->type == T_DIR){
  104a9e:	66 83 7e 10 01       	cmpw   $0x1,0x10(%esi)
  104aa3:	74 27                	je     104acc <sys_unlink+0x19c>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
  104aa5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104aa8:	89 04 24             	mov    %eax,(%esp)
  104aab:	e8 a0 d0 ff ff       	call   101b50 <iunlockput>

  ip->nlink--;
  104ab0:	66 83 6e 16 01       	subw   $0x1,0x16(%esi)
  iupdate(ip);
  104ab5:	89 34 24             	mov    %esi,(%esp)
  104ab8:	e8 43 ca ff ff       	call   101500 <iupdate>
  iunlockput(ip);
  104abd:	89 34 24             	mov    %esi,(%esp)
  104ac0:	e8 8b d0 ff ff       	call   101b50 <iunlockput>
  104ac5:	31 c0                	xor    %eax,%eax
  return 0;
  104ac7:	e9 8f fe ff ff       	jmp    10495b <sys_unlink+0x2b>

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
  104acc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104acf:	66 83 68 16 01       	subw   $0x1,0x16(%eax)
    iupdate(dp);
  104ad4:	89 04 24             	mov    %eax,(%esp)
  104ad7:	e8 24 ca ff ff       	call   101500 <iupdate>
  104adc:	eb c7                	jmp    104aa5 <sys_unlink+0x175>
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
  104ade:	c7 04 24 7c 6d 10 00 	movl   $0x106d7c,(%esp)
  104ae5:	e8 c6 be ff ff       	call   1009b0 <panic>
    return -1;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  104aea:	c7 04 24 8e 6d 10 00 	movl   $0x106d8e,(%esp)
  104af1:	e8 ba be ff ff       	call   1009b0 <panic>
    return -1;
  }
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  104af6:	c7 04 24 6a 6d 10 00 	movl   $0x106d6a,(%esp)
  104afd:	e8 ae be ff ff       	call   1009b0 <panic>
  104b02:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  104b09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104b10 <T.67>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  104b10:	55                   	push   %ebp
  104b11:	89 e5                	mov    %esp,%ebp
  104b13:	83 ec 28             	sub    $0x28,%esp
  104b16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  104b19:	89 c3                	mov    %eax,%ebx
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  104b1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
  104b1e:	89 75 fc             	mov    %esi,-0x4(%ebp)
  104b21:	89 d6                	mov    %edx,%esi
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
  104b23:	89 44 24 04          	mov    %eax,0x4(%esp)
  104b27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104b2e:	e8 6d f5 ff ff       	call   1040a0 <argint>
  104b33:	85 c0                	test   %eax,%eax
  104b35:	79 11                	jns    104b48 <T.67+0x38>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  104b37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  104b3c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  104b3f:	8b 75 fc             	mov    -0x4(%ebp),%esi
  104b42:	89 ec                	mov    %ebp,%esp
  104b44:	5d                   	pop    %ebp
  104b45:	c3                   	ret    
  104b46:	66 90                	xchg   %ax,%ax
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
  104b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b4b:	83 f8 0f             	cmp    $0xf,%eax
  104b4e:	77 e7                	ja     104b37 <T.67+0x27>
  104b50:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104b57:	8b 54 82 28          	mov    0x28(%edx,%eax,4),%edx
  104b5b:	85 d2                	test   %edx,%edx
  104b5d:	74 d8                	je     104b37 <T.67+0x27>
    return -1;
  if(pfd)
  104b5f:	85 db                	test   %ebx,%ebx
  104b61:	74 02                	je     104b65 <T.67+0x55>
    *pfd = fd;
  104b63:	89 03                	mov    %eax,(%ebx)
  if(pf)
  104b65:	31 c0                	xor    %eax,%eax
  104b67:	85 f6                	test   %esi,%esi
  104b69:	74 d1                	je     104b3c <T.67+0x2c>
    *pf = f;
  104b6b:	89 16                	mov    %edx,(%esi)
  104b6d:	eb cd                	jmp    104b3c <T.67+0x2c>
  104b6f:	90                   	nop

00104b70 <sys_dup>:
  return -1;
}

int
sys_dup(void)
{
  104b70:	55                   	push   %ebp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104b71:	31 c0                	xor    %eax,%eax
  return -1;
}

int
sys_dup(void)
{
  104b73:	89 e5                	mov    %esp,%ebp
  104b75:	53                   	push   %ebx
  104b76:	83 ec 24             	sub    $0x24,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
  104b79:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104b7c:	e8 8f ff ff ff       	call   104b10 <T.67>
  104b81:	85 c0                	test   %eax,%eax
  104b83:	79 13                	jns    104b98 <sys_dup+0x28>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104b85:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
}
  104b8a:	89 d8                	mov    %ebx,%eax
  104b8c:	83 c4 24             	add    $0x24,%esp
  104b8f:	5b                   	pop    %ebx
  104b90:	5d                   	pop    %ebp
  104b91:	c3                   	ret    
  104b92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
  104b98:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104b9b:	31 db                	xor    %ebx,%ebx
  104b9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104ba3:	eb 0b                	jmp    104bb0 <sys_dup+0x40>
  104ba5:	8d 76 00             	lea    0x0(%esi),%esi
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
  104ba8:	83 c3 01             	add    $0x1,%ebx
  104bab:	83 fb 10             	cmp    $0x10,%ebx
  104bae:	74 d5                	je     104b85 <sys_dup+0x15>
    if(proc->ofile[fd] == 0){
  104bb0:	8b 4c 98 28          	mov    0x28(%eax,%ebx,4),%ecx
  104bb4:	85 c9                	test   %ecx,%ecx
  104bb6:	75 f0                	jne    104ba8 <sys_dup+0x38>
      proc->ofile[fd] = f;
  104bb8:	89 54 98 28          	mov    %edx,0x28(%eax,%ebx,4)
  
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  104bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bbf:	89 04 24             	mov    %eax,(%esp)
  104bc2:	e8 69 c3 ff ff       	call   100f30 <filedup>
  return fd;
  104bc7:	eb c1                	jmp    104b8a <sys_dup+0x1a>
  104bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00104bd0 <sys_read>:
}

int
sys_read(void)
{
  104bd0:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104bd1:	31 c0                	xor    %eax,%eax
  return fd;
}

int
sys_read(void)
{
  104bd3:	89 e5                	mov    %esp,%ebp
  104bd5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104bd8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104bdb:	e8 30 ff ff ff       	call   104b10 <T.67>
  104be0:	85 c0                	test   %eax,%eax
  104be2:	79 0c                	jns    104bf0 <sys_read+0x20>
    return -1;
  return fileread(f, p, n);
  104be4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104be9:	c9                   	leave  
  104bea:	c3                   	ret    
  104beb:	90                   	nop
  104bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104bf0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  104bf7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104bfe:	e8 9d f4 ff ff       	call   1040a0 <argint>
  104c03:	85 c0                	test   %eax,%eax
  104c05:	78 dd                	js     104be4 <sys_read+0x14>
  104c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c11:	89 44 24 08          	mov    %eax,0x8(%esp)
  104c15:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104c18:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c1c:	e8 bf f4 ff ff       	call   1040e0 <argptr>
  104c21:	85 c0                	test   %eax,%eax
  104c23:	78 bf                	js     104be4 <sys_read+0x14>
    return -1;
  return fileread(f, p, n);
  104c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c28:	89 44 24 08          	mov    %eax,0x8(%esp)
  104c2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c36:	89 04 24             	mov    %eax,(%esp)
  104c39:	e8 f2 c1 ff ff       	call   100e30 <fileread>
}
  104c3e:	c9                   	leave  
  104c3f:	c3                   	ret    

00104c40 <sys_write>:

int
sys_write(void)
{
  104c40:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104c41:	31 c0                	xor    %eax,%eax
  return fileread(f, p, n);
}

int
sys_write(void)
{
  104c43:	89 e5                	mov    %esp,%ebp
  104c45:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104c48:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104c4b:	e8 c0 fe ff ff       	call   104b10 <T.67>
  104c50:	85 c0                	test   %eax,%eax
  104c52:	79 0c                	jns    104c60 <sys_write+0x20>
    return -1;
  return filewrite(f, p, n);
  104c54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104c59:	c9                   	leave  
  104c5a:	c3                   	ret    
  104c5b:	90                   	nop
  104c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
  104c60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104c63:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c67:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  104c6e:	e8 2d f4 ff ff       	call   1040a0 <argint>
  104c73:	85 c0                	test   %eax,%eax
  104c75:	78 dd                	js     104c54 <sys_write+0x14>
  104c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c7a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c81:	89 44 24 08          	mov    %eax,0x8(%esp)
  104c85:	8d 45 ec             	lea    -0x14(%ebp),%eax
  104c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  104c8c:	e8 4f f4 ff ff       	call   1040e0 <argptr>
  104c91:	85 c0                	test   %eax,%eax
  104c93:	78 bf                	js     104c54 <sys_write+0x14>
    return -1;
  return filewrite(f, p, n);
  104c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c98:	89 44 24 08          	mov    %eax,0x8(%esp)
  104c9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  104ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ca6:	89 04 24             	mov    %eax,(%esp)
  104ca9:	e8 d2 c0 ff ff       	call   100d80 <filewrite>
}
  104cae:	c9                   	leave  
  104caf:	c3                   	ret    

00104cb0 <sys_fstat>:
  return 0;
}

int
sys_fstat(void)
{
  104cb0:	55                   	push   %ebp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104cb1:	31 c0                	xor    %eax,%eax
  return 0;
}

int
sys_fstat(void)
{
  104cb3:	89 e5                	mov    %esp,%ebp
  104cb5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104cb8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  104cbb:	e8 50 fe ff ff       	call   104b10 <T.67>
  104cc0:	85 c0                	test   %eax,%eax
  104cc2:	79 0c                	jns    104cd0 <sys_fstat+0x20>
    return -1;
  return filestat(f, st);
  104cc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104cc9:	c9                   	leave  
  104cca:	c3                   	ret    
  104ccb:	90                   	nop
  104ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_fstat(void)
{
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
  104cd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  104cd3:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  104cda:	00 
  104cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  104cdf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ce6:	e8 f5 f3 ff ff       	call   1040e0 <argptr>
  104ceb:	85 c0                	test   %eax,%eax
  104ced:	78 d5                	js     104cc4 <sys_fstat+0x14>
    return -1;
  return filestat(f, st);
  104cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  104cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104cf9:	89 04 24             	mov    %eax,(%esp)
  104cfc:	e8 df c1 ff ff       	call   100ee0 <filestat>
}
  104d01:	c9                   	leave  
  104d02:	c3                   	ret    
  104d03:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00104d10 <sys_close>:
  return filewrite(f, p, n);
}

int
sys_close(void)
{
  104d10:	55                   	push   %ebp
  104d11:	89 e5                	mov    %esp,%ebp
  104d13:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
  104d16:	8d 55 f0             	lea    -0x10(%ebp),%edx
  104d19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104d1c:	e8 ef fd ff ff       	call   104b10 <T.67>
  104d21:	89 c2                	mov    %eax,%edx
  104d23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104d28:	85 d2                	test   %edx,%edx
  104d2a:	78 1e                	js     104d4a <sys_close+0x3a>
    return -1;
  proc->ofile[fd] = 0;
  104d2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104d35:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
  104d3c:	00 
  fileclose(f);
  104d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d40:	89 04 24             	mov    %eax,(%esp)
  104d43:	e8 b8 c2 ff ff       	call   101000 <fileclose>
  104d48:	31 c0                	xor    %eax,%eax
  return 0;
}
  104d4a:	c9                   	leave  
  104d4b:	c3                   	ret    
  104d4c:	90                   	nop
  104d4d:	90                   	nop
  104d4e:	90                   	nop
  104d4f:	90                   	nop

00104d50 <sys_getpid>:
}

int
sys_getpid(void)
{
  return proc->pid;
  104d50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  return kill(pid);
}

int
sys_getpid(void)
{
  104d56:	55                   	push   %ebp
  104d57:	89 e5                	mov    %esp,%ebp
  return proc->pid;
}
  104d59:	5d                   	pop    %ebp
}

int
sys_getpid(void)
{
  return proc->pid;
  104d5a:	8b 40 10             	mov    0x10(%eax),%eax
}
  104d5d:	c3                   	ret    
  104d5e:	66 90                	xchg   %ax,%ax

00104d60 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since boot.
int
sys_uptime(void)
{
  104d60:	55                   	push   %ebp
  104d61:	89 e5                	mov    %esp,%ebp
  104d63:	53                   	push   %ebx
  104d64:	83 ec 14             	sub    $0x14,%esp
  uint xticks;
  
  acquire(&tickslock);
  104d67:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104d6e:	e8 ed ef ff ff       	call   103d60 <acquire>
  xticks = ticks;
  104d73:	8b 1d a0 e8 10 00    	mov    0x10e8a0,%ebx
  release(&tickslock);
  104d79:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104d80:	e8 8b ef ff ff       	call   103d10 <release>
  return xticks;
}
  104d85:	83 c4 14             	add    $0x14,%esp
  104d88:	89 d8                	mov    %ebx,%eax
  104d8a:	5b                   	pop    %ebx
  104d8b:	5d                   	pop    %ebp
  104d8c:	c3                   	ret    
  104d8d:	8d 76 00             	lea    0x0(%esi),%esi

00104d90 <sys_sleep>:
  return addr;
}

int
sys_sleep(void)
{
  104d90:	55                   	push   %ebp
  104d91:	89 e5                	mov    %esp,%ebp
  104d93:	53                   	push   %ebx
  104d94:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
  104d97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104da5:	e8 f6 f2 ff ff       	call   1040a0 <argint>
  104daa:	89 c2                	mov    %eax,%edx
  104dac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104db1:	85 d2                	test   %edx,%edx
  104db3:	78 59                	js     104e0e <sys_sleep+0x7e>
    return -1;
  acquire(&tickslock);
  104db5:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104dbc:	e8 9f ef ff ff       	call   103d60 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104dc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  104dc4:	8b 1d a0 e8 10 00    	mov    0x10e8a0,%ebx
  while(ticks - ticks0 < n){
  104dca:	85 d2                	test   %edx,%edx
  104dcc:	75 22                	jne    104df0 <sys_sleep+0x60>
  104dce:	eb 48                	jmp    104e18 <sys_sleep+0x88>
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  104dd0:	c7 44 24 04 60 e0 10 	movl   $0x10e060,0x4(%esp)
  104dd7:	00 
  104dd8:	c7 04 24 a0 e8 10 00 	movl   $0x10e8a0,(%esp)
  104ddf:	e8 fc e4 ff ff       	call   1032e0 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
  104de4:	a1 a0 e8 10 00       	mov    0x10e8a0,%eax
  104de9:	29 d8                	sub    %ebx,%eax
  104deb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104dee:	73 28                	jae    104e18 <sys_sleep+0x88>
    if(proc->killed){
  104df0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104df6:	8b 40 24             	mov    0x24(%eax),%eax
  104df9:	85 c0                	test   %eax,%eax
  104dfb:	74 d3                	je     104dd0 <sys_sleep+0x40>
      release(&tickslock);
  104dfd:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104e04:	e8 07 ef ff ff       	call   103d10 <release>
  104e09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
  104e0e:	83 c4 24             	add    $0x24,%esp
  104e11:	5b                   	pop    %ebx
  104e12:	5d                   	pop    %ebp
  104e13:	c3                   	ret    
  104e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104e18:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  104e1f:	e8 ec ee ff ff       	call   103d10 <release>
  return 0;
}
  104e24:	83 c4 24             	add    $0x24,%esp
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  104e27:	31 c0                	xor    %eax,%eax
  return 0;
}
  104e29:	5b                   	pop    %ebx
  104e2a:	5d                   	pop    %ebp
  104e2b:	c3                   	ret    
  104e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104e30 <sys_sbrk>:
  return proc->pid;
}

int
sys_sbrk(void)
{
  104e30:	55                   	push   %ebp
  104e31:	89 e5                	mov    %esp,%ebp
  104e33:	53                   	push   %ebx
  104e34:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
  104e37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  104e3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104e45:	e8 56 f2 ff ff       	call   1040a0 <argint>
  104e4a:	85 c0                	test   %eax,%eax
  104e4c:	79 12                	jns    104e60 <sys_sbrk+0x30>
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
  104e4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  104e53:	83 c4 24             	add    $0x24,%esp
  104e56:	5b                   	pop    %ebx
  104e57:	5d                   	pop    %ebp
  104e58:	c3                   	ret    
  104e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104e60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  104e66:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
  104e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e6b:	89 04 24             	mov    %eax,(%esp)
  104e6e:	e8 cd eb ff ff       	call   103a40 <growproc>
  104e73:	89 c2                	mov    %eax,%edx
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  104e75:	89 d8                	mov    %ebx,%eax
  if(growproc(n) < 0)
  104e77:	85 d2                	test   %edx,%edx
  104e79:	79 d8                	jns    104e53 <sys_sbrk+0x23>
  104e7b:	eb d1                	jmp    104e4e <sys_sbrk+0x1e>
  104e7d:	8d 76 00             	lea    0x0(%esi),%esi

00104e80 <sys_kill>:
  return wait();
}

int
sys_kill(void)
{
  104e80:	55                   	push   %ebp
  104e81:	89 e5                	mov    %esp,%ebp
  104e83:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
  104e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  104e89:	89 44 24 04          	mov    %eax,0x4(%esp)
  104e8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104e94:	e8 07 f2 ff ff       	call   1040a0 <argint>
  104e99:	89 c2                	mov    %eax,%edx
  104e9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104ea0:	85 d2                	test   %edx,%edx
  104ea2:	78 0b                	js     104eaf <sys_kill+0x2f>
    return -1;
  return kill(pid);
  104ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ea7:	89 04 24             	mov    %eax,(%esp)
  104eaa:	e8 81 e2 ff ff       	call   103130 <kill>
}
  104eaf:	c9                   	leave  
  104eb0:	c3                   	ret    
  104eb1:	eb 0d                	jmp    104ec0 <sys_wait>
  104eb3:	90                   	nop
  104eb4:	90                   	nop
  104eb5:	90                   	nop
  104eb6:	90                   	nop
  104eb7:	90                   	nop
  104eb8:	90                   	nop
  104eb9:	90                   	nop
  104eba:	90                   	nop
  104ebb:	90                   	nop
  104ebc:	90                   	nop
  104ebd:	90                   	nop
  104ebe:	90                   	nop
  104ebf:	90                   	nop

00104ec0 <sys_wait>:
  return 0;  // not reached
}

int
sys_wait(void)
{
  104ec0:	55                   	push   %ebp
  104ec1:	89 e5                	mov    %esp,%ebp
  104ec3:	83 ec 08             	sub    $0x8,%esp
  return wait();
}
  104ec6:	c9                   	leave  
}

int
sys_wait(void)
{
  return wait();
  104ec7:	e9 c4 e5 ff ff       	jmp    103490 <wait>
  104ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104ed0 <sys_exit>:
  return clone();
}

int
sys_exit(void)
{
  104ed0:	55                   	push   %ebp
  104ed1:	89 e5                	mov    %esp,%ebp
  104ed3:	83 ec 08             	sub    $0x8,%esp
  exit();
  104ed6:	e8 c5 e6 ff ff       	call   1035a0 <exit>
  return 0;  // not reached
}
  104edb:	31 c0                	xor    %eax,%eax
  104edd:	c9                   	leave  
  104ede:	c3                   	ret    
  104edf:	90                   	nop

00104ee0 <sys_clone>:
  return fork();
}

int
sys_clone(void)
{
  104ee0:	55                   	push   %ebp
  104ee1:	89 e5                	mov    %esp,%ebp
  104ee3:	83 ec 08             	sub    $0x8,%esp
  return clone();
}
  104ee6:	c9                   	leave  
}

int
sys_clone(void)
{
  return clone();
  104ee7:	e9 c4 e8 ff ff       	jmp    1037b0 <clone>
  104eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00104ef0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  104ef0:	55                   	push   %ebp
  104ef1:	89 e5                	mov    %esp,%ebp
  104ef3:	83 ec 08             	sub    $0x8,%esp
  return fork();
}
  104ef6:	c9                   	leave  
#include "proc.h"

int
sys_fork(void)
{
  return fork();
  104ef7:	e9 44 ea ff ff       	jmp    103940 <fork>
  104efc:	90                   	nop
  104efd:	90                   	nop
  104efe:	90                   	nop
  104eff:	90                   	nop

00104f00 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
  104f00:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  104f01:	ba 43 00 00 00       	mov    $0x43,%edx
  104f06:	89 e5                	mov    %esp,%ebp
  104f08:	83 ec 18             	sub    $0x18,%esp
  104f0b:	b8 34 00 00 00       	mov    $0x34,%eax
  104f10:	ee                   	out    %al,(%dx)
  104f11:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
  104f16:	b2 40                	mov    $0x40,%dl
  104f18:	ee                   	out    %al,(%dx)
  104f19:	b8 2e 00 00 00       	mov    $0x2e,%eax
  104f1e:	ee                   	out    %al,(%dx)
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
  picenable(IRQ_TIMER);
  104f1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104f26:	e8 f5 dc ff ff       	call   102c20 <picenable>
}
  104f2b:	c9                   	leave  
  104f2c:	c3                   	ret    
  104f2d:	90                   	nop
  104f2e:	90                   	nop
  104f2f:	90                   	nop

00104f30 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
  104f30:	1e                   	push   %ds
  pushl %es
  104f31:	06                   	push   %es
  pushl %fs
  104f32:	0f a0                	push   %fs
  pushl %gs
  104f34:	0f a8                	push   %gs
  pushal
  104f36:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
  104f37:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
  104f3b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
  104f3d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
  104f3f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
  104f43:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
  104f45:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
  104f47:	54                   	push   %esp
  call trap
  104f48:	e8 43 00 00 00       	call   104f90 <trap>
  addl $4, %esp
  104f4d:	83 c4 04             	add    $0x4,%esp

00104f50 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
  104f50:	61                   	popa   
  popl %gs
  104f51:	0f a9                	pop    %gs
  popl %fs
  104f53:	0f a1                	pop    %fs
  popl %es
  104f55:	07                   	pop    %es
  popl %ds
  104f56:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
  104f57:	83 c4 08             	add    $0x8,%esp
  iret
  104f5a:	cf                   	iret   
  104f5b:	90                   	nop
  104f5c:	90                   	nop
  104f5d:	90                   	nop
  104f5e:	90                   	nop
  104f5f:	90                   	nop

00104f60 <idtinit>:
  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  104f60:	55                   	push   %ebp
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  pd[1] = (uint)p;
  104f61:	b8 a0 e0 10 00       	mov    $0x10e0a0,%eax
  104f66:	89 e5                	mov    %esp,%ebp
  104f68:	83 ec 10             	sub    $0x10,%esp
static inline void
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  104f6b:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
  104f71:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
  104f75:	c1 e8 10             	shr    $0x10,%eax
  104f78:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
  104f7c:	8d 45 fa             	lea    -0x6(%ebp),%eax
  104f7f:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
  104f82:	c9                   	leave  
  104f83:	c3                   	ret    
  104f84:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  104f8a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00104f90 <trap>:

void
trap(struct trapframe *tf)
{
  104f90:	55                   	push   %ebp
  104f91:	89 e5                	mov    %esp,%ebp
  104f93:	56                   	push   %esi
  104f94:	53                   	push   %ebx
  104f95:	83 ec 20             	sub    $0x20,%esp
  104f98:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
  104f9b:	8b 43 30             	mov    0x30(%ebx),%eax
  104f9e:	83 f8 40             	cmp    $0x40,%eax
  104fa1:	0f 84 c9 00 00 00    	je     105070 <trap+0xe0>
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  104fa7:	8d 50 e0             	lea    -0x20(%eax),%edx
  104faa:	83 fa 1f             	cmp    $0x1f,%edx
  104fad:	0f 86 b5 00 00 00    	jbe    105068 <trap+0xd8>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
  104fb3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
  104fba:	85 d2                	test   %edx,%edx
  104fbc:	0f 84 f6 01 00 00    	je     1051b8 <trap+0x228>
  104fc2:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
  104fc6:	0f 84 ec 01 00 00    	je     1051b8 <trap+0x228>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
  104fcc:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
  104fcf:	8b 4a 10             	mov    0x10(%edx),%ecx
  104fd2:	83 c2 6c             	add    $0x6c,%edx
  104fd5:	89 74 24 1c          	mov    %esi,0x1c(%esp)
  104fd9:	8b 73 38             	mov    0x38(%ebx),%esi
  104fdc:	89 74 24 18          	mov    %esi,0x18(%esp)
  104fe0:	65 8b 35 00 00 00 00 	mov    %gs:0x0,%esi
  104fe7:	0f b6 36             	movzbl (%esi),%esi
  104fea:	89 74 24 14          	mov    %esi,0x14(%esp)
  104fee:	8b 73 34             	mov    0x34(%ebx),%esi
  104ff1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104ff5:	89 54 24 08          	mov    %edx,0x8(%esp)
  104ff9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104ffd:	89 74 24 10          	mov    %esi,0x10(%esp)
  105001:	c7 04 24 f8 6d 10 00 	movl   $0x106df8,(%esp)
  105008:	e8 b3 b5 ff ff       	call   1005c0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
  10500d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  105013:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  10501a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  105020:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  105026:	85 c0                	test   %eax,%eax
  105028:	74 34                	je     10505e <trap+0xce>
  10502a:	8b 50 24             	mov    0x24(%eax),%edx
  10502d:	85 d2                	test   %edx,%edx
  10502f:	74 10                	je     105041 <trap+0xb1>
  105031:	0f b7 53 3c          	movzwl 0x3c(%ebx),%edx
  105035:	83 e2 03             	and    $0x3,%edx
  105038:	83 fa 03             	cmp    $0x3,%edx
  10503b:	0f 84 5f 01 00 00    	je     1051a0 <trap+0x210>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105041:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
  105045:	0f 84 2d 01 00 00    	je     105178 <trap+0x1e8>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  10504b:	8b 40 24             	mov    0x24(%eax),%eax
  10504e:	85 c0                	test   %eax,%eax
  105050:	74 0c                	je     10505e <trap+0xce>
  105052:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  105056:	83 e0 03             	and    $0x3,%eax
  105059:	83 f8 03             	cmp    $0x3,%eax
  10505c:	74 34                	je     105092 <trap+0x102>
    exit();
}
  10505e:	83 c4 20             	add    $0x20,%esp
  105061:	5b                   	pop    %ebx
  105062:	5e                   	pop    %esi
  105063:	5d                   	pop    %ebp
  105064:	c3                   	ret    
  105065:	8d 76 00             	lea    0x0(%esi),%esi
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  105068:	ff 24 95 48 6e 10 00 	jmp    *0x106e48(,%edx,4)
  10506f:	90                   	nop

void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
  105070:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  105076:	8b 70 24             	mov    0x24(%eax),%esi
  105079:	85 f6                	test   %esi,%esi
  10507b:	75 23                	jne    1050a0 <trap+0x110>
      exit();
    proc->tf = tf;
  10507d:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
  105080:	e8 1b f1 ff ff       	call   1041a0 <syscall>
    if(proc->killed)
  105085:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  10508b:	8b 48 24             	mov    0x24(%eax),%ecx
  10508e:	85 c9                	test   %ecx,%ecx
  105090:	74 cc                	je     10505e <trap+0xce>
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
  105092:	83 c4 20             	add    $0x20,%esp
  105095:	5b                   	pop    %ebx
  105096:	5e                   	pop    %esi
  105097:	5d                   	pop    %ebp
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  105098:	e9 03 e5 ff ff       	jmp    1035a0 <exit>
  10509d:	8d 76 00             	lea    0x0(%esi),%esi
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
      exit();
  1050a0:	e8 fb e4 ff ff       	call   1035a0 <exit>
  1050a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1050ab:	eb d0                	jmp    10507d <trap+0xed>
  1050ad:	8d 76 00             	lea    0x0(%esi),%esi
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
  1050b0:	e8 eb cf ff ff       	call   1020a0 <ideintr>
    lapiceoi();
  1050b5:	e8 26 d4 ff ff       	call   1024e0 <lapiceoi>
    break;
  1050ba:	e9 61 ff ff ff       	jmp    105020 <trap+0x90>
  1050bf:	90                   	nop
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
  1050c0:	8b 43 38             	mov    0x38(%ebx),%eax
  1050c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1050c7:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
  1050cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1050cf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1050d5:	0f b6 00             	movzbl (%eax),%eax
  1050d8:	c7 04 24 a0 6d 10 00 	movl   $0x106da0,(%esp)
  1050df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1050e3:	e8 d8 b4 ff ff       	call   1005c0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
  1050e8:	e8 f3 d3 ff ff       	call   1024e0 <lapiceoi>
    break;
  1050ed:	e9 2e ff ff ff       	jmp    105020 <trap+0x90>
  1050f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1050f8:	90                   	nop
  1050f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
  105100:	e8 ab 01 00 00       	call   1052b0 <uartintr>
  105105:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  105108:	e8 d3 d3 ff ff       	call   1024e0 <lapiceoi>
  10510d:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  105110:	e9 0b ff ff ff       	jmp    105020 <trap+0x90>
  105115:	8d 76 00             	lea    0x0(%esi),%esi
  105118:	90                   	nop
  105119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
  105120:	e8 9b d3 ff ff       	call   1024c0 <kbdintr>
  105125:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
  105128:	e8 b3 d3 ff ff       	call   1024e0 <lapiceoi>
  10512d:	8d 76 00             	lea    0x0(%esi),%esi
    break;
  105130:	e9 eb fe ff ff       	jmp    105020 <trap+0x90>
  105135:	8d 76 00             	lea    0x0(%esi),%esi
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
  105138:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10513e:	80 38 00             	cmpb   $0x0,(%eax)
  105141:	0f 85 6e ff ff ff    	jne    1050b5 <trap+0x125>
      acquire(&tickslock);
  105147:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  10514e:	e8 0d ec ff ff       	call   103d60 <acquire>
      ticks++;
  105153:	83 05 a0 e8 10 00 01 	addl   $0x1,0x10e8a0
      wakeup(&ticks);
  10515a:	c7 04 24 a0 e8 10 00 	movl   $0x10e8a0,(%esp)
  105161:	e8 5a e0 ff ff       	call   1031c0 <wakeup>
      release(&tickslock);
  105166:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
  10516d:	e8 9e eb ff ff       	call   103d10 <release>
  105172:	e9 3e ff ff ff       	jmp    1050b5 <trap+0x125>
  105177:	90                   	nop
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  105178:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
  10517c:	0f 85 c9 fe ff ff    	jne    10504b <trap+0xbb>
  105182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    yield();
  105188:	e8 23 e2 ff ff       	call   1033b0 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
  10518d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  105193:	85 c0                	test   %eax,%eax
  105195:	0f 85 b0 fe ff ff    	jne    10504b <trap+0xbb>
  10519b:	e9 be fe ff ff       	jmp    10505e <trap+0xce>

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
  1051a0:	e8 fb e3 ff ff       	call   1035a0 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
  1051a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  1051ab:	85 c0                	test   %eax,%eax
  1051ad:	0f 85 8e fe ff ff    	jne    105041 <trap+0xb1>
  1051b3:	e9 a6 fe ff ff       	jmp    10505e <trap+0xce>
  1051b8:	0f 20 d2             	mov    %cr2,%edx
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
  1051bb:	89 54 24 10          	mov    %edx,0x10(%esp)
  1051bf:	8b 53 38             	mov    0x38(%ebx),%edx
  1051c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1051c6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  1051cd:	0f b6 12             	movzbl (%edx),%edx
  1051d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1051d4:	c7 04 24 c4 6d 10 00 	movl   $0x106dc4,(%esp)
  1051db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1051df:	e8 dc b3 ff ff       	call   1005c0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
  1051e4:	c7 04 24 3b 6e 10 00 	movl   $0x106e3b,(%esp)
  1051eb:	e8 c0 b7 ff ff       	call   1009b0 <panic>

001051f0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  1051f0:	55                   	push   %ebp
  1051f1:	31 c0                	xor    %eax,%eax
  1051f3:	89 e5                	mov    %esp,%ebp
  1051f5:	ba a0 e0 10 00       	mov    $0x10e0a0,%edx
  1051fa:	83 ec 18             	sub    $0x18,%esp
  1051fd:	8d 76 00             	lea    0x0(%esi),%esi
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  105200:	8b 0c 85 28 73 10 00 	mov    0x107328(,%eax,4),%ecx
  105207:	66 89 0c c5 a0 e0 10 	mov    %cx,0x10e0a0(,%eax,8)
  10520e:	00 
  10520f:	c1 e9 10             	shr    $0x10,%ecx
  105212:	66 c7 44 c2 02 08 00 	movw   $0x8,0x2(%edx,%eax,8)
  105219:	c6 44 c2 04 00       	movb   $0x0,0x4(%edx,%eax,8)
  10521e:	c6 44 c2 05 8e       	movb   $0x8e,0x5(%edx,%eax,8)
  105223:	66 89 4c c2 06       	mov    %cx,0x6(%edx,%eax,8)
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
  105228:	83 c0 01             	add    $0x1,%eax
  10522b:	3d 00 01 00 00       	cmp    $0x100,%eax
  105230:	75 ce                	jne    105200 <tvinit+0x10>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  105232:	a1 28 74 10 00       	mov    0x107428,%eax
  
  initlock(&tickslock, "time");
  105237:	c7 44 24 04 40 6e 10 	movl   $0x106e40,0x4(%esp)
  10523e:	00 
  10523f:	c7 04 24 60 e0 10 00 	movl   $0x10e060,(%esp)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  105246:	66 c7 05 a2 e2 10 00 	movw   $0x8,0x10e2a2
  10524d:	08 00 
  10524f:	66 a3 a0 e2 10 00    	mov    %ax,0x10e2a0
  105255:	c1 e8 10             	shr    $0x10,%eax
  105258:	c6 05 a4 e2 10 00 00 	movb   $0x0,0x10e2a4
  10525f:	c6 05 a5 e2 10 00 ef 	movb   $0xef,0x10e2a5
  105266:	66 a3 a6 e2 10 00    	mov    %ax,0x10e2a6
  
  initlock(&tickslock, "time");
  10526c:	e8 5f e9 ff ff       	call   103bd0 <initlock>
}
  105271:	c9                   	leave  
  105272:	c3                   	ret    
  105273:	90                   	nop
  105274:	90                   	nop
  105275:	90                   	nop
  105276:	90                   	nop
  105277:	90                   	nop
  105278:	90                   	nop
  105279:	90                   	nop
  10527a:	90                   	nop
  10527b:	90                   	nop
  10527c:	90                   	nop
  10527d:	90                   	nop
  10527e:	90                   	nop
  10527f:	90                   	nop

00105280 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
  105280:	a1 cc 78 10 00       	mov    0x1078cc,%eax
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
  105285:	55                   	push   %ebp
  105286:	89 e5                	mov    %esp,%ebp
  if(!uart)
  105288:	85 c0                	test   %eax,%eax
  10528a:	75 0c                	jne    105298 <uartgetc+0x18>
    return -1;
  if(!(inb(COM1+5) & 0x01))
    return -1;
  return inb(COM1+0);
  10528c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  105291:	5d                   	pop    %ebp
  105292:	c3                   	ret    
  105293:	90                   	nop
  105294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105298:	ba fd 03 00 00       	mov    $0x3fd,%edx
  10529d:	ec                   	in     (%dx),%al
static int
uartgetc(void)
{
  if(!uart)
    return -1;
  if(!(inb(COM1+5) & 0x01))
  10529e:	a8 01                	test   $0x1,%al
  1052a0:	74 ea                	je     10528c <uartgetc+0xc>
  1052a2:	b2 f8                	mov    $0xf8,%dl
  1052a4:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
  1052a5:	0f b6 c0             	movzbl %al,%eax
}
  1052a8:	5d                   	pop    %ebp
  1052a9:	c3                   	ret    
  1052aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001052b0 <uartintr>:

void
uartintr(void)
{
  1052b0:	55                   	push   %ebp
  1052b1:	89 e5                	mov    %esp,%ebp
  1052b3:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
  1052b6:	c7 04 24 80 52 10 00 	movl   $0x105280,(%esp)
  1052bd:	e8 5e b5 ff ff       	call   100820 <consoleintr>
}
  1052c2:	c9                   	leave  
  1052c3:	c3                   	ret    
  1052c4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1052ca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

001052d0 <uartputc>:
    uartputc(*p);
}

void
uartputc(int c)
{
  1052d0:	55                   	push   %ebp
  1052d1:	89 e5                	mov    %esp,%ebp
  1052d3:	56                   	push   %esi
  1052d4:	be fd 03 00 00       	mov    $0x3fd,%esi
  1052d9:	53                   	push   %ebx
  int i;

  if(!uart)
  1052da:	31 db                	xor    %ebx,%ebx
    uartputc(*p);
}

void
uartputc(int c)
{
  1052dc:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(!uart)
  1052df:	8b 15 cc 78 10 00    	mov    0x1078cc,%edx
  1052e5:	85 d2                	test   %edx,%edx
  1052e7:	75 1e                	jne    105307 <uartputc+0x37>
  1052e9:	eb 2c                	jmp    105317 <uartputc+0x47>
  1052eb:	90                   	nop
  1052ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1052f0:	83 c3 01             	add    $0x1,%ebx
    microdelay(10);
  1052f3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1052fa:	e8 01 d2 ff ff       	call   102500 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
  1052ff:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
  105305:	74 07                	je     10530e <uartputc+0x3e>
  105307:	89 f2                	mov    %esi,%edx
  105309:	ec                   	in     (%dx),%al
  10530a:	a8 20                	test   $0x20,%al
  10530c:	74 e2                	je     1052f0 <uartputc+0x20>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  10530e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  105313:	8b 45 08             	mov    0x8(%ebp),%eax
  105316:	ee                   	out    %al,(%dx)
    microdelay(10);
  outb(COM1+0, c);
}
  105317:	83 c4 10             	add    $0x10,%esp
  10531a:	5b                   	pop    %ebx
  10531b:	5e                   	pop    %esi
  10531c:	5d                   	pop    %ebp
  10531d:	c3                   	ret    
  10531e:	66 90                	xchg   %ax,%ax

00105320 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
  105320:	55                   	push   %ebp
  105321:	31 c9                	xor    %ecx,%ecx
  105323:	89 e5                	mov    %esp,%ebp
  105325:	89 c8                	mov    %ecx,%eax
  105327:	57                   	push   %edi
  105328:	bf fa 03 00 00       	mov    $0x3fa,%edi
  10532d:	56                   	push   %esi
  10532e:	89 fa                	mov    %edi,%edx
  105330:	53                   	push   %ebx
  105331:	83 ec 1c             	sub    $0x1c,%esp
  105334:	ee                   	out    %al,(%dx)
  105335:	bb fb 03 00 00       	mov    $0x3fb,%ebx
  10533a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  10533f:	89 da                	mov    %ebx,%edx
  105341:	ee                   	out    %al,(%dx)
  105342:	b8 0c 00 00 00       	mov    $0xc,%eax
  105347:	b2 f8                	mov    $0xf8,%dl
  105349:	ee                   	out    %al,(%dx)
  10534a:	be f9 03 00 00       	mov    $0x3f9,%esi
  10534f:	89 c8                	mov    %ecx,%eax
  105351:	89 f2                	mov    %esi,%edx
  105353:	ee                   	out    %al,(%dx)
  105354:	b8 03 00 00 00       	mov    $0x3,%eax
  105359:	89 da                	mov    %ebx,%edx
  10535b:	ee                   	out    %al,(%dx)
  10535c:	b2 fc                	mov    $0xfc,%dl
  10535e:	89 c8                	mov    %ecx,%eax
  105360:	ee                   	out    %al,(%dx)
  105361:	b8 01 00 00 00       	mov    $0x1,%eax
  105366:	89 f2                	mov    %esi,%edx
  105368:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  105369:	b2 fd                	mov    $0xfd,%dl
  10536b:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
  10536c:	3c ff                	cmp    $0xff,%al
  10536e:	74 55                	je     1053c5 <uartinit+0xa5>
    return;
  uart = 1;
  105370:	c7 05 cc 78 10 00 01 	movl   $0x1,0x1078cc
  105377:	00 00 00 
  10537a:	89 fa                	mov    %edi,%edx
  10537c:	ec                   	in     (%dx),%al
  10537d:	b2 f8                	mov    $0xf8,%dl
  10537f:	ec                   	in     (%dx),%al
  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  105380:	bb c8 6e 10 00       	mov    $0x106ec8,%ebx

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
  105385:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10538c:	e8 8f d8 ff ff       	call   102c20 <picenable>
  ioapicenable(IRQ_COM1, 0);
  105391:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105398:	00 
  105399:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1053a0:	e8 2b ce ff ff       	call   1021d0 <ioapicenable>
  1053a5:	b8 78 00 00 00       	mov    $0x78,%eax
  1053aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
  1053b0:	0f be c0             	movsbl %al,%eax
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  1053b3:	83 c3 01             	add    $0x1,%ebx
    uartputc(*p);
  1053b6:	89 04 24             	mov    %eax,(%esp)
  1053b9:	e8 12 ff ff ff       	call   1052d0 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
  1053be:	0f b6 03             	movzbl (%ebx),%eax
  1053c1:	84 c0                	test   %al,%al
  1053c3:	75 eb                	jne    1053b0 <uartinit+0x90>
    uartputc(*p);
}
  1053c5:	83 c4 1c             	add    $0x1c,%esp
  1053c8:	5b                   	pop    %ebx
  1053c9:	5e                   	pop    %esi
  1053ca:	5f                   	pop    %edi
  1053cb:	5d                   	pop    %ebp
  1053cc:	c3                   	ret    
  1053cd:	90                   	nop
  1053ce:	90                   	nop
  1053cf:	90                   	nop

001053d0 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
  1053d0:	6a 00                	push   $0x0
  pushl $0
  1053d2:	6a 00                	push   $0x0
  jmp alltraps
  1053d4:	e9 57 fb ff ff       	jmp    104f30 <alltraps>

001053d9 <vector1>:
.globl vector1
vector1:
  pushl $0
  1053d9:	6a 00                	push   $0x0
  pushl $1
  1053db:	6a 01                	push   $0x1
  jmp alltraps
  1053dd:	e9 4e fb ff ff       	jmp    104f30 <alltraps>

001053e2 <vector2>:
.globl vector2
vector2:
  pushl $0
  1053e2:	6a 00                	push   $0x0
  pushl $2
  1053e4:	6a 02                	push   $0x2
  jmp alltraps
  1053e6:	e9 45 fb ff ff       	jmp    104f30 <alltraps>

001053eb <vector3>:
.globl vector3
vector3:
  pushl $0
  1053eb:	6a 00                	push   $0x0
  pushl $3
  1053ed:	6a 03                	push   $0x3
  jmp alltraps
  1053ef:	e9 3c fb ff ff       	jmp    104f30 <alltraps>

001053f4 <vector4>:
.globl vector4
vector4:
  pushl $0
  1053f4:	6a 00                	push   $0x0
  pushl $4
  1053f6:	6a 04                	push   $0x4
  jmp alltraps
  1053f8:	e9 33 fb ff ff       	jmp    104f30 <alltraps>

001053fd <vector5>:
.globl vector5
vector5:
  pushl $0
  1053fd:	6a 00                	push   $0x0
  pushl $5
  1053ff:	6a 05                	push   $0x5
  jmp alltraps
  105401:	e9 2a fb ff ff       	jmp    104f30 <alltraps>

00105406 <vector6>:
.globl vector6
vector6:
  pushl $0
  105406:	6a 00                	push   $0x0
  pushl $6
  105408:	6a 06                	push   $0x6
  jmp alltraps
  10540a:	e9 21 fb ff ff       	jmp    104f30 <alltraps>

0010540f <vector7>:
.globl vector7
vector7:
  pushl $0
  10540f:	6a 00                	push   $0x0
  pushl $7
  105411:	6a 07                	push   $0x7
  jmp alltraps
  105413:	e9 18 fb ff ff       	jmp    104f30 <alltraps>

00105418 <vector8>:
.globl vector8
vector8:
  pushl $8
  105418:	6a 08                	push   $0x8
  jmp alltraps
  10541a:	e9 11 fb ff ff       	jmp    104f30 <alltraps>

0010541f <vector9>:
.globl vector9
vector9:
  pushl $0
  10541f:	6a 00                	push   $0x0
  pushl $9
  105421:	6a 09                	push   $0x9
  jmp alltraps
  105423:	e9 08 fb ff ff       	jmp    104f30 <alltraps>

00105428 <vector10>:
.globl vector10
vector10:
  pushl $10
  105428:	6a 0a                	push   $0xa
  jmp alltraps
  10542a:	e9 01 fb ff ff       	jmp    104f30 <alltraps>

0010542f <vector11>:
.globl vector11
vector11:
  pushl $11
  10542f:	6a 0b                	push   $0xb
  jmp alltraps
  105431:	e9 fa fa ff ff       	jmp    104f30 <alltraps>

00105436 <vector12>:
.globl vector12
vector12:
  pushl $12
  105436:	6a 0c                	push   $0xc
  jmp alltraps
  105438:	e9 f3 fa ff ff       	jmp    104f30 <alltraps>

0010543d <vector13>:
.globl vector13
vector13:
  pushl $13
  10543d:	6a 0d                	push   $0xd
  jmp alltraps
  10543f:	e9 ec fa ff ff       	jmp    104f30 <alltraps>

00105444 <vector14>:
.globl vector14
vector14:
  pushl $14
  105444:	6a 0e                	push   $0xe
  jmp alltraps
  105446:	e9 e5 fa ff ff       	jmp    104f30 <alltraps>

0010544b <vector15>:
.globl vector15
vector15:
  pushl $0
  10544b:	6a 00                	push   $0x0
  pushl $15
  10544d:	6a 0f                	push   $0xf
  jmp alltraps
  10544f:	e9 dc fa ff ff       	jmp    104f30 <alltraps>

00105454 <vector16>:
.globl vector16
vector16:
  pushl $0
  105454:	6a 00                	push   $0x0
  pushl $16
  105456:	6a 10                	push   $0x10
  jmp alltraps
  105458:	e9 d3 fa ff ff       	jmp    104f30 <alltraps>

0010545d <vector17>:
.globl vector17
vector17:
  pushl $17
  10545d:	6a 11                	push   $0x11
  jmp alltraps
  10545f:	e9 cc fa ff ff       	jmp    104f30 <alltraps>

00105464 <vector18>:
.globl vector18
vector18:
  pushl $0
  105464:	6a 00                	push   $0x0
  pushl $18
  105466:	6a 12                	push   $0x12
  jmp alltraps
  105468:	e9 c3 fa ff ff       	jmp    104f30 <alltraps>

0010546d <vector19>:
.globl vector19
vector19:
  pushl $0
  10546d:	6a 00                	push   $0x0
  pushl $19
  10546f:	6a 13                	push   $0x13
  jmp alltraps
  105471:	e9 ba fa ff ff       	jmp    104f30 <alltraps>

00105476 <vector20>:
.globl vector20
vector20:
  pushl $0
  105476:	6a 00                	push   $0x0
  pushl $20
  105478:	6a 14                	push   $0x14
  jmp alltraps
  10547a:	e9 b1 fa ff ff       	jmp    104f30 <alltraps>

0010547f <vector21>:
.globl vector21
vector21:
  pushl $0
  10547f:	6a 00                	push   $0x0
  pushl $21
  105481:	6a 15                	push   $0x15
  jmp alltraps
  105483:	e9 a8 fa ff ff       	jmp    104f30 <alltraps>

00105488 <vector22>:
.globl vector22
vector22:
  pushl $0
  105488:	6a 00                	push   $0x0
  pushl $22
  10548a:	6a 16                	push   $0x16
  jmp alltraps
  10548c:	e9 9f fa ff ff       	jmp    104f30 <alltraps>

00105491 <vector23>:
.globl vector23
vector23:
  pushl $0
  105491:	6a 00                	push   $0x0
  pushl $23
  105493:	6a 17                	push   $0x17
  jmp alltraps
  105495:	e9 96 fa ff ff       	jmp    104f30 <alltraps>

0010549a <vector24>:
.globl vector24
vector24:
  pushl $0
  10549a:	6a 00                	push   $0x0
  pushl $24
  10549c:	6a 18                	push   $0x18
  jmp alltraps
  10549e:	e9 8d fa ff ff       	jmp    104f30 <alltraps>

001054a3 <vector25>:
.globl vector25
vector25:
  pushl $0
  1054a3:	6a 00                	push   $0x0
  pushl $25
  1054a5:	6a 19                	push   $0x19
  jmp alltraps
  1054a7:	e9 84 fa ff ff       	jmp    104f30 <alltraps>

001054ac <vector26>:
.globl vector26
vector26:
  pushl $0
  1054ac:	6a 00                	push   $0x0
  pushl $26
  1054ae:	6a 1a                	push   $0x1a
  jmp alltraps
  1054b0:	e9 7b fa ff ff       	jmp    104f30 <alltraps>

001054b5 <vector27>:
.globl vector27
vector27:
  pushl $0
  1054b5:	6a 00                	push   $0x0
  pushl $27
  1054b7:	6a 1b                	push   $0x1b
  jmp alltraps
  1054b9:	e9 72 fa ff ff       	jmp    104f30 <alltraps>

001054be <vector28>:
.globl vector28
vector28:
  pushl $0
  1054be:	6a 00                	push   $0x0
  pushl $28
  1054c0:	6a 1c                	push   $0x1c
  jmp alltraps
  1054c2:	e9 69 fa ff ff       	jmp    104f30 <alltraps>

001054c7 <vector29>:
.globl vector29
vector29:
  pushl $0
  1054c7:	6a 00                	push   $0x0
  pushl $29
  1054c9:	6a 1d                	push   $0x1d
  jmp alltraps
  1054cb:	e9 60 fa ff ff       	jmp    104f30 <alltraps>

001054d0 <vector30>:
.globl vector30
vector30:
  pushl $0
  1054d0:	6a 00                	push   $0x0
  pushl $30
  1054d2:	6a 1e                	push   $0x1e
  jmp alltraps
  1054d4:	e9 57 fa ff ff       	jmp    104f30 <alltraps>

001054d9 <vector31>:
.globl vector31
vector31:
  pushl $0
  1054d9:	6a 00                	push   $0x0
  pushl $31
  1054db:	6a 1f                	push   $0x1f
  jmp alltraps
  1054dd:	e9 4e fa ff ff       	jmp    104f30 <alltraps>

001054e2 <vector32>:
.globl vector32
vector32:
  pushl $0
  1054e2:	6a 00                	push   $0x0
  pushl $32
  1054e4:	6a 20                	push   $0x20
  jmp alltraps
  1054e6:	e9 45 fa ff ff       	jmp    104f30 <alltraps>

001054eb <vector33>:
.globl vector33
vector33:
  pushl $0
  1054eb:	6a 00                	push   $0x0
  pushl $33
  1054ed:	6a 21                	push   $0x21
  jmp alltraps
  1054ef:	e9 3c fa ff ff       	jmp    104f30 <alltraps>

001054f4 <vector34>:
.globl vector34
vector34:
  pushl $0
  1054f4:	6a 00                	push   $0x0
  pushl $34
  1054f6:	6a 22                	push   $0x22
  jmp alltraps
  1054f8:	e9 33 fa ff ff       	jmp    104f30 <alltraps>

001054fd <vector35>:
.globl vector35
vector35:
  pushl $0
  1054fd:	6a 00                	push   $0x0
  pushl $35
  1054ff:	6a 23                	push   $0x23
  jmp alltraps
  105501:	e9 2a fa ff ff       	jmp    104f30 <alltraps>

00105506 <vector36>:
.globl vector36
vector36:
  pushl $0
  105506:	6a 00                	push   $0x0
  pushl $36
  105508:	6a 24                	push   $0x24
  jmp alltraps
  10550a:	e9 21 fa ff ff       	jmp    104f30 <alltraps>

0010550f <vector37>:
.globl vector37
vector37:
  pushl $0
  10550f:	6a 00                	push   $0x0
  pushl $37
  105511:	6a 25                	push   $0x25
  jmp alltraps
  105513:	e9 18 fa ff ff       	jmp    104f30 <alltraps>

00105518 <vector38>:
.globl vector38
vector38:
  pushl $0
  105518:	6a 00                	push   $0x0
  pushl $38
  10551a:	6a 26                	push   $0x26
  jmp alltraps
  10551c:	e9 0f fa ff ff       	jmp    104f30 <alltraps>

00105521 <vector39>:
.globl vector39
vector39:
  pushl $0
  105521:	6a 00                	push   $0x0
  pushl $39
  105523:	6a 27                	push   $0x27
  jmp alltraps
  105525:	e9 06 fa ff ff       	jmp    104f30 <alltraps>

0010552a <vector40>:
.globl vector40
vector40:
  pushl $0
  10552a:	6a 00                	push   $0x0
  pushl $40
  10552c:	6a 28                	push   $0x28
  jmp alltraps
  10552e:	e9 fd f9 ff ff       	jmp    104f30 <alltraps>

00105533 <vector41>:
.globl vector41
vector41:
  pushl $0
  105533:	6a 00                	push   $0x0
  pushl $41
  105535:	6a 29                	push   $0x29
  jmp alltraps
  105537:	e9 f4 f9 ff ff       	jmp    104f30 <alltraps>

0010553c <vector42>:
.globl vector42
vector42:
  pushl $0
  10553c:	6a 00                	push   $0x0
  pushl $42
  10553e:	6a 2a                	push   $0x2a
  jmp alltraps
  105540:	e9 eb f9 ff ff       	jmp    104f30 <alltraps>

00105545 <vector43>:
.globl vector43
vector43:
  pushl $0
  105545:	6a 00                	push   $0x0
  pushl $43
  105547:	6a 2b                	push   $0x2b
  jmp alltraps
  105549:	e9 e2 f9 ff ff       	jmp    104f30 <alltraps>

0010554e <vector44>:
.globl vector44
vector44:
  pushl $0
  10554e:	6a 00                	push   $0x0
  pushl $44
  105550:	6a 2c                	push   $0x2c
  jmp alltraps
  105552:	e9 d9 f9 ff ff       	jmp    104f30 <alltraps>

00105557 <vector45>:
.globl vector45
vector45:
  pushl $0
  105557:	6a 00                	push   $0x0
  pushl $45
  105559:	6a 2d                	push   $0x2d
  jmp alltraps
  10555b:	e9 d0 f9 ff ff       	jmp    104f30 <alltraps>

00105560 <vector46>:
.globl vector46
vector46:
  pushl $0
  105560:	6a 00                	push   $0x0
  pushl $46
  105562:	6a 2e                	push   $0x2e
  jmp alltraps
  105564:	e9 c7 f9 ff ff       	jmp    104f30 <alltraps>

00105569 <vector47>:
.globl vector47
vector47:
  pushl $0
  105569:	6a 00                	push   $0x0
  pushl $47
  10556b:	6a 2f                	push   $0x2f
  jmp alltraps
  10556d:	e9 be f9 ff ff       	jmp    104f30 <alltraps>

00105572 <vector48>:
.globl vector48
vector48:
  pushl $0
  105572:	6a 00                	push   $0x0
  pushl $48
  105574:	6a 30                	push   $0x30
  jmp alltraps
  105576:	e9 b5 f9 ff ff       	jmp    104f30 <alltraps>

0010557b <vector49>:
.globl vector49
vector49:
  pushl $0
  10557b:	6a 00                	push   $0x0
  pushl $49
  10557d:	6a 31                	push   $0x31
  jmp alltraps
  10557f:	e9 ac f9 ff ff       	jmp    104f30 <alltraps>

00105584 <vector50>:
.globl vector50
vector50:
  pushl $0
  105584:	6a 00                	push   $0x0
  pushl $50
  105586:	6a 32                	push   $0x32
  jmp alltraps
  105588:	e9 a3 f9 ff ff       	jmp    104f30 <alltraps>

0010558d <vector51>:
.globl vector51
vector51:
  pushl $0
  10558d:	6a 00                	push   $0x0
  pushl $51
  10558f:	6a 33                	push   $0x33
  jmp alltraps
  105591:	e9 9a f9 ff ff       	jmp    104f30 <alltraps>

00105596 <vector52>:
.globl vector52
vector52:
  pushl $0
  105596:	6a 00                	push   $0x0
  pushl $52
  105598:	6a 34                	push   $0x34
  jmp alltraps
  10559a:	e9 91 f9 ff ff       	jmp    104f30 <alltraps>

0010559f <vector53>:
.globl vector53
vector53:
  pushl $0
  10559f:	6a 00                	push   $0x0
  pushl $53
  1055a1:	6a 35                	push   $0x35
  jmp alltraps
  1055a3:	e9 88 f9 ff ff       	jmp    104f30 <alltraps>

001055a8 <vector54>:
.globl vector54
vector54:
  pushl $0
  1055a8:	6a 00                	push   $0x0
  pushl $54
  1055aa:	6a 36                	push   $0x36
  jmp alltraps
  1055ac:	e9 7f f9 ff ff       	jmp    104f30 <alltraps>

001055b1 <vector55>:
.globl vector55
vector55:
  pushl $0
  1055b1:	6a 00                	push   $0x0
  pushl $55
  1055b3:	6a 37                	push   $0x37
  jmp alltraps
  1055b5:	e9 76 f9 ff ff       	jmp    104f30 <alltraps>

001055ba <vector56>:
.globl vector56
vector56:
  pushl $0
  1055ba:	6a 00                	push   $0x0
  pushl $56
  1055bc:	6a 38                	push   $0x38
  jmp alltraps
  1055be:	e9 6d f9 ff ff       	jmp    104f30 <alltraps>

001055c3 <vector57>:
.globl vector57
vector57:
  pushl $0
  1055c3:	6a 00                	push   $0x0
  pushl $57
  1055c5:	6a 39                	push   $0x39
  jmp alltraps
  1055c7:	e9 64 f9 ff ff       	jmp    104f30 <alltraps>

001055cc <vector58>:
.globl vector58
vector58:
  pushl $0
  1055cc:	6a 00                	push   $0x0
  pushl $58
  1055ce:	6a 3a                	push   $0x3a
  jmp alltraps
  1055d0:	e9 5b f9 ff ff       	jmp    104f30 <alltraps>

001055d5 <vector59>:
.globl vector59
vector59:
  pushl $0
  1055d5:	6a 00                	push   $0x0
  pushl $59
  1055d7:	6a 3b                	push   $0x3b
  jmp alltraps
  1055d9:	e9 52 f9 ff ff       	jmp    104f30 <alltraps>

001055de <vector60>:
.globl vector60
vector60:
  pushl $0
  1055de:	6a 00                	push   $0x0
  pushl $60
  1055e0:	6a 3c                	push   $0x3c
  jmp alltraps
  1055e2:	e9 49 f9 ff ff       	jmp    104f30 <alltraps>

001055e7 <vector61>:
.globl vector61
vector61:
  pushl $0
  1055e7:	6a 00                	push   $0x0
  pushl $61
  1055e9:	6a 3d                	push   $0x3d
  jmp alltraps
  1055eb:	e9 40 f9 ff ff       	jmp    104f30 <alltraps>

001055f0 <vector62>:
.globl vector62
vector62:
  pushl $0
  1055f0:	6a 00                	push   $0x0
  pushl $62
  1055f2:	6a 3e                	push   $0x3e
  jmp alltraps
  1055f4:	e9 37 f9 ff ff       	jmp    104f30 <alltraps>

001055f9 <vector63>:
.globl vector63
vector63:
  pushl $0
  1055f9:	6a 00                	push   $0x0
  pushl $63
  1055fb:	6a 3f                	push   $0x3f
  jmp alltraps
  1055fd:	e9 2e f9 ff ff       	jmp    104f30 <alltraps>

00105602 <vector64>:
.globl vector64
vector64:
  pushl $0
  105602:	6a 00                	push   $0x0
  pushl $64
  105604:	6a 40                	push   $0x40
  jmp alltraps
  105606:	e9 25 f9 ff ff       	jmp    104f30 <alltraps>

0010560b <vector65>:
.globl vector65
vector65:
  pushl $0
  10560b:	6a 00                	push   $0x0
  pushl $65
  10560d:	6a 41                	push   $0x41
  jmp alltraps
  10560f:	e9 1c f9 ff ff       	jmp    104f30 <alltraps>

00105614 <vector66>:
.globl vector66
vector66:
  pushl $0
  105614:	6a 00                	push   $0x0
  pushl $66
  105616:	6a 42                	push   $0x42
  jmp alltraps
  105618:	e9 13 f9 ff ff       	jmp    104f30 <alltraps>

0010561d <vector67>:
.globl vector67
vector67:
  pushl $0
  10561d:	6a 00                	push   $0x0
  pushl $67
  10561f:	6a 43                	push   $0x43
  jmp alltraps
  105621:	e9 0a f9 ff ff       	jmp    104f30 <alltraps>

00105626 <vector68>:
.globl vector68
vector68:
  pushl $0
  105626:	6a 00                	push   $0x0
  pushl $68
  105628:	6a 44                	push   $0x44
  jmp alltraps
  10562a:	e9 01 f9 ff ff       	jmp    104f30 <alltraps>

0010562f <vector69>:
.globl vector69
vector69:
  pushl $0
  10562f:	6a 00                	push   $0x0
  pushl $69
  105631:	6a 45                	push   $0x45
  jmp alltraps
  105633:	e9 f8 f8 ff ff       	jmp    104f30 <alltraps>

00105638 <vector70>:
.globl vector70
vector70:
  pushl $0
  105638:	6a 00                	push   $0x0
  pushl $70
  10563a:	6a 46                	push   $0x46
  jmp alltraps
  10563c:	e9 ef f8 ff ff       	jmp    104f30 <alltraps>

00105641 <vector71>:
.globl vector71
vector71:
  pushl $0
  105641:	6a 00                	push   $0x0
  pushl $71
  105643:	6a 47                	push   $0x47
  jmp alltraps
  105645:	e9 e6 f8 ff ff       	jmp    104f30 <alltraps>

0010564a <vector72>:
.globl vector72
vector72:
  pushl $0
  10564a:	6a 00                	push   $0x0
  pushl $72
  10564c:	6a 48                	push   $0x48
  jmp alltraps
  10564e:	e9 dd f8 ff ff       	jmp    104f30 <alltraps>

00105653 <vector73>:
.globl vector73
vector73:
  pushl $0
  105653:	6a 00                	push   $0x0
  pushl $73
  105655:	6a 49                	push   $0x49
  jmp alltraps
  105657:	e9 d4 f8 ff ff       	jmp    104f30 <alltraps>

0010565c <vector74>:
.globl vector74
vector74:
  pushl $0
  10565c:	6a 00                	push   $0x0
  pushl $74
  10565e:	6a 4a                	push   $0x4a
  jmp alltraps
  105660:	e9 cb f8 ff ff       	jmp    104f30 <alltraps>

00105665 <vector75>:
.globl vector75
vector75:
  pushl $0
  105665:	6a 00                	push   $0x0
  pushl $75
  105667:	6a 4b                	push   $0x4b
  jmp alltraps
  105669:	e9 c2 f8 ff ff       	jmp    104f30 <alltraps>

0010566e <vector76>:
.globl vector76
vector76:
  pushl $0
  10566e:	6a 00                	push   $0x0
  pushl $76
  105670:	6a 4c                	push   $0x4c
  jmp alltraps
  105672:	e9 b9 f8 ff ff       	jmp    104f30 <alltraps>

00105677 <vector77>:
.globl vector77
vector77:
  pushl $0
  105677:	6a 00                	push   $0x0
  pushl $77
  105679:	6a 4d                	push   $0x4d
  jmp alltraps
  10567b:	e9 b0 f8 ff ff       	jmp    104f30 <alltraps>

00105680 <vector78>:
.globl vector78
vector78:
  pushl $0
  105680:	6a 00                	push   $0x0
  pushl $78
  105682:	6a 4e                	push   $0x4e
  jmp alltraps
  105684:	e9 a7 f8 ff ff       	jmp    104f30 <alltraps>

00105689 <vector79>:
.globl vector79
vector79:
  pushl $0
  105689:	6a 00                	push   $0x0
  pushl $79
  10568b:	6a 4f                	push   $0x4f
  jmp alltraps
  10568d:	e9 9e f8 ff ff       	jmp    104f30 <alltraps>

00105692 <vector80>:
.globl vector80
vector80:
  pushl $0
  105692:	6a 00                	push   $0x0
  pushl $80
  105694:	6a 50                	push   $0x50
  jmp alltraps
  105696:	e9 95 f8 ff ff       	jmp    104f30 <alltraps>

0010569b <vector81>:
.globl vector81
vector81:
  pushl $0
  10569b:	6a 00                	push   $0x0
  pushl $81
  10569d:	6a 51                	push   $0x51
  jmp alltraps
  10569f:	e9 8c f8 ff ff       	jmp    104f30 <alltraps>

001056a4 <vector82>:
.globl vector82
vector82:
  pushl $0
  1056a4:	6a 00                	push   $0x0
  pushl $82
  1056a6:	6a 52                	push   $0x52
  jmp alltraps
  1056a8:	e9 83 f8 ff ff       	jmp    104f30 <alltraps>

001056ad <vector83>:
.globl vector83
vector83:
  pushl $0
  1056ad:	6a 00                	push   $0x0
  pushl $83
  1056af:	6a 53                	push   $0x53
  jmp alltraps
  1056b1:	e9 7a f8 ff ff       	jmp    104f30 <alltraps>

001056b6 <vector84>:
.globl vector84
vector84:
  pushl $0
  1056b6:	6a 00                	push   $0x0
  pushl $84
  1056b8:	6a 54                	push   $0x54
  jmp alltraps
  1056ba:	e9 71 f8 ff ff       	jmp    104f30 <alltraps>

001056bf <vector85>:
.globl vector85
vector85:
  pushl $0
  1056bf:	6a 00                	push   $0x0
  pushl $85
  1056c1:	6a 55                	push   $0x55
  jmp alltraps
  1056c3:	e9 68 f8 ff ff       	jmp    104f30 <alltraps>

001056c8 <vector86>:
.globl vector86
vector86:
  pushl $0
  1056c8:	6a 00                	push   $0x0
  pushl $86
  1056ca:	6a 56                	push   $0x56
  jmp alltraps
  1056cc:	e9 5f f8 ff ff       	jmp    104f30 <alltraps>

001056d1 <vector87>:
.globl vector87
vector87:
  pushl $0
  1056d1:	6a 00                	push   $0x0
  pushl $87
  1056d3:	6a 57                	push   $0x57
  jmp alltraps
  1056d5:	e9 56 f8 ff ff       	jmp    104f30 <alltraps>

001056da <vector88>:
.globl vector88
vector88:
  pushl $0
  1056da:	6a 00                	push   $0x0
  pushl $88
  1056dc:	6a 58                	push   $0x58
  jmp alltraps
  1056de:	e9 4d f8 ff ff       	jmp    104f30 <alltraps>

001056e3 <vector89>:
.globl vector89
vector89:
  pushl $0
  1056e3:	6a 00                	push   $0x0
  pushl $89
  1056e5:	6a 59                	push   $0x59
  jmp alltraps
  1056e7:	e9 44 f8 ff ff       	jmp    104f30 <alltraps>

001056ec <vector90>:
.globl vector90
vector90:
  pushl $0
  1056ec:	6a 00                	push   $0x0
  pushl $90
  1056ee:	6a 5a                	push   $0x5a
  jmp alltraps
  1056f0:	e9 3b f8 ff ff       	jmp    104f30 <alltraps>

001056f5 <vector91>:
.globl vector91
vector91:
  pushl $0
  1056f5:	6a 00                	push   $0x0
  pushl $91
  1056f7:	6a 5b                	push   $0x5b
  jmp alltraps
  1056f9:	e9 32 f8 ff ff       	jmp    104f30 <alltraps>

001056fe <vector92>:
.globl vector92
vector92:
  pushl $0
  1056fe:	6a 00                	push   $0x0
  pushl $92
  105700:	6a 5c                	push   $0x5c
  jmp alltraps
  105702:	e9 29 f8 ff ff       	jmp    104f30 <alltraps>

00105707 <vector93>:
.globl vector93
vector93:
  pushl $0
  105707:	6a 00                	push   $0x0
  pushl $93
  105709:	6a 5d                	push   $0x5d
  jmp alltraps
  10570b:	e9 20 f8 ff ff       	jmp    104f30 <alltraps>

00105710 <vector94>:
.globl vector94
vector94:
  pushl $0
  105710:	6a 00                	push   $0x0
  pushl $94
  105712:	6a 5e                	push   $0x5e
  jmp alltraps
  105714:	e9 17 f8 ff ff       	jmp    104f30 <alltraps>

00105719 <vector95>:
.globl vector95
vector95:
  pushl $0
  105719:	6a 00                	push   $0x0
  pushl $95
  10571b:	6a 5f                	push   $0x5f
  jmp alltraps
  10571d:	e9 0e f8 ff ff       	jmp    104f30 <alltraps>

00105722 <vector96>:
.globl vector96
vector96:
  pushl $0
  105722:	6a 00                	push   $0x0
  pushl $96
  105724:	6a 60                	push   $0x60
  jmp alltraps
  105726:	e9 05 f8 ff ff       	jmp    104f30 <alltraps>

0010572b <vector97>:
.globl vector97
vector97:
  pushl $0
  10572b:	6a 00                	push   $0x0
  pushl $97
  10572d:	6a 61                	push   $0x61
  jmp alltraps
  10572f:	e9 fc f7 ff ff       	jmp    104f30 <alltraps>

00105734 <vector98>:
.globl vector98
vector98:
  pushl $0
  105734:	6a 00                	push   $0x0
  pushl $98
  105736:	6a 62                	push   $0x62
  jmp alltraps
  105738:	e9 f3 f7 ff ff       	jmp    104f30 <alltraps>

0010573d <vector99>:
.globl vector99
vector99:
  pushl $0
  10573d:	6a 00                	push   $0x0
  pushl $99
  10573f:	6a 63                	push   $0x63
  jmp alltraps
  105741:	e9 ea f7 ff ff       	jmp    104f30 <alltraps>

00105746 <vector100>:
.globl vector100
vector100:
  pushl $0
  105746:	6a 00                	push   $0x0
  pushl $100
  105748:	6a 64                	push   $0x64
  jmp alltraps
  10574a:	e9 e1 f7 ff ff       	jmp    104f30 <alltraps>

0010574f <vector101>:
.globl vector101
vector101:
  pushl $0
  10574f:	6a 00                	push   $0x0
  pushl $101
  105751:	6a 65                	push   $0x65
  jmp alltraps
  105753:	e9 d8 f7 ff ff       	jmp    104f30 <alltraps>

00105758 <vector102>:
.globl vector102
vector102:
  pushl $0
  105758:	6a 00                	push   $0x0
  pushl $102
  10575a:	6a 66                	push   $0x66
  jmp alltraps
  10575c:	e9 cf f7 ff ff       	jmp    104f30 <alltraps>

00105761 <vector103>:
.globl vector103
vector103:
  pushl $0
  105761:	6a 00                	push   $0x0
  pushl $103
  105763:	6a 67                	push   $0x67
  jmp alltraps
  105765:	e9 c6 f7 ff ff       	jmp    104f30 <alltraps>

0010576a <vector104>:
.globl vector104
vector104:
  pushl $0
  10576a:	6a 00                	push   $0x0
  pushl $104
  10576c:	6a 68                	push   $0x68
  jmp alltraps
  10576e:	e9 bd f7 ff ff       	jmp    104f30 <alltraps>

00105773 <vector105>:
.globl vector105
vector105:
  pushl $0
  105773:	6a 00                	push   $0x0
  pushl $105
  105775:	6a 69                	push   $0x69
  jmp alltraps
  105777:	e9 b4 f7 ff ff       	jmp    104f30 <alltraps>

0010577c <vector106>:
.globl vector106
vector106:
  pushl $0
  10577c:	6a 00                	push   $0x0
  pushl $106
  10577e:	6a 6a                	push   $0x6a
  jmp alltraps
  105780:	e9 ab f7 ff ff       	jmp    104f30 <alltraps>

00105785 <vector107>:
.globl vector107
vector107:
  pushl $0
  105785:	6a 00                	push   $0x0
  pushl $107
  105787:	6a 6b                	push   $0x6b
  jmp alltraps
  105789:	e9 a2 f7 ff ff       	jmp    104f30 <alltraps>

0010578e <vector108>:
.globl vector108
vector108:
  pushl $0
  10578e:	6a 00                	push   $0x0
  pushl $108
  105790:	6a 6c                	push   $0x6c
  jmp alltraps
  105792:	e9 99 f7 ff ff       	jmp    104f30 <alltraps>

00105797 <vector109>:
.globl vector109
vector109:
  pushl $0
  105797:	6a 00                	push   $0x0
  pushl $109
  105799:	6a 6d                	push   $0x6d
  jmp alltraps
  10579b:	e9 90 f7 ff ff       	jmp    104f30 <alltraps>

001057a0 <vector110>:
.globl vector110
vector110:
  pushl $0
  1057a0:	6a 00                	push   $0x0
  pushl $110
  1057a2:	6a 6e                	push   $0x6e
  jmp alltraps
  1057a4:	e9 87 f7 ff ff       	jmp    104f30 <alltraps>

001057a9 <vector111>:
.globl vector111
vector111:
  pushl $0
  1057a9:	6a 00                	push   $0x0
  pushl $111
  1057ab:	6a 6f                	push   $0x6f
  jmp alltraps
  1057ad:	e9 7e f7 ff ff       	jmp    104f30 <alltraps>

001057b2 <vector112>:
.globl vector112
vector112:
  pushl $0
  1057b2:	6a 00                	push   $0x0
  pushl $112
  1057b4:	6a 70                	push   $0x70
  jmp alltraps
  1057b6:	e9 75 f7 ff ff       	jmp    104f30 <alltraps>

001057bb <vector113>:
.globl vector113
vector113:
  pushl $0
  1057bb:	6a 00                	push   $0x0
  pushl $113
  1057bd:	6a 71                	push   $0x71
  jmp alltraps
  1057bf:	e9 6c f7 ff ff       	jmp    104f30 <alltraps>

001057c4 <vector114>:
.globl vector114
vector114:
  pushl $0
  1057c4:	6a 00                	push   $0x0
  pushl $114
  1057c6:	6a 72                	push   $0x72
  jmp alltraps
  1057c8:	e9 63 f7 ff ff       	jmp    104f30 <alltraps>

001057cd <vector115>:
.globl vector115
vector115:
  pushl $0
  1057cd:	6a 00                	push   $0x0
  pushl $115
  1057cf:	6a 73                	push   $0x73
  jmp alltraps
  1057d1:	e9 5a f7 ff ff       	jmp    104f30 <alltraps>

001057d6 <vector116>:
.globl vector116
vector116:
  pushl $0
  1057d6:	6a 00                	push   $0x0
  pushl $116
  1057d8:	6a 74                	push   $0x74
  jmp alltraps
  1057da:	e9 51 f7 ff ff       	jmp    104f30 <alltraps>

001057df <vector117>:
.globl vector117
vector117:
  pushl $0
  1057df:	6a 00                	push   $0x0
  pushl $117
  1057e1:	6a 75                	push   $0x75
  jmp alltraps
  1057e3:	e9 48 f7 ff ff       	jmp    104f30 <alltraps>

001057e8 <vector118>:
.globl vector118
vector118:
  pushl $0
  1057e8:	6a 00                	push   $0x0
  pushl $118
  1057ea:	6a 76                	push   $0x76
  jmp alltraps
  1057ec:	e9 3f f7 ff ff       	jmp    104f30 <alltraps>

001057f1 <vector119>:
.globl vector119
vector119:
  pushl $0
  1057f1:	6a 00                	push   $0x0
  pushl $119
  1057f3:	6a 77                	push   $0x77
  jmp alltraps
  1057f5:	e9 36 f7 ff ff       	jmp    104f30 <alltraps>

001057fa <vector120>:
.globl vector120
vector120:
  pushl $0
  1057fa:	6a 00                	push   $0x0
  pushl $120
  1057fc:	6a 78                	push   $0x78
  jmp alltraps
  1057fe:	e9 2d f7 ff ff       	jmp    104f30 <alltraps>

00105803 <vector121>:
.globl vector121
vector121:
  pushl $0
  105803:	6a 00                	push   $0x0
  pushl $121
  105805:	6a 79                	push   $0x79
  jmp alltraps
  105807:	e9 24 f7 ff ff       	jmp    104f30 <alltraps>

0010580c <vector122>:
.globl vector122
vector122:
  pushl $0
  10580c:	6a 00                	push   $0x0
  pushl $122
  10580e:	6a 7a                	push   $0x7a
  jmp alltraps
  105810:	e9 1b f7 ff ff       	jmp    104f30 <alltraps>

00105815 <vector123>:
.globl vector123
vector123:
  pushl $0
  105815:	6a 00                	push   $0x0
  pushl $123
  105817:	6a 7b                	push   $0x7b
  jmp alltraps
  105819:	e9 12 f7 ff ff       	jmp    104f30 <alltraps>

0010581e <vector124>:
.globl vector124
vector124:
  pushl $0
  10581e:	6a 00                	push   $0x0
  pushl $124
  105820:	6a 7c                	push   $0x7c
  jmp alltraps
  105822:	e9 09 f7 ff ff       	jmp    104f30 <alltraps>

00105827 <vector125>:
.globl vector125
vector125:
  pushl $0
  105827:	6a 00                	push   $0x0
  pushl $125
  105829:	6a 7d                	push   $0x7d
  jmp alltraps
  10582b:	e9 00 f7 ff ff       	jmp    104f30 <alltraps>

00105830 <vector126>:
.globl vector126
vector126:
  pushl $0
  105830:	6a 00                	push   $0x0
  pushl $126
  105832:	6a 7e                	push   $0x7e
  jmp alltraps
  105834:	e9 f7 f6 ff ff       	jmp    104f30 <alltraps>

00105839 <vector127>:
.globl vector127
vector127:
  pushl $0
  105839:	6a 00                	push   $0x0
  pushl $127
  10583b:	6a 7f                	push   $0x7f
  jmp alltraps
  10583d:	e9 ee f6 ff ff       	jmp    104f30 <alltraps>

00105842 <vector128>:
.globl vector128
vector128:
  pushl $0
  105842:	6a 00                	push   $0x0
  pushl $128
  105844:	68 80 00 00 00       	push   $0x80
  jmp alltraps
  105849:	e9 e2 f6 ff ff       	jmp    104f30 <alltraps>

0010584e <vector129>:
.globl vector129
vector129:
  pushl $0
  10584e:	6a 00                	push   $0x0
  pushl $129
  105850:	68 81 00 00 00       	push   $0x81
  jmp alltraps
  105855:	e9 d6 f6 ff ff       	jmp    104f30 <alltraps>

0010585a <vector130>:
.globl vector130
vector130:
  pushl $0
  10585a:	6a 00                	push   $0x0
  pushl $130
  10585c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
  105861:	e9 ca f6 ff ff       	jmp    104f30 <alltraps>

00105866 <vector131>:
.globl vector131
vector131:
  pushl $0
  105866:	6a 00                	push   $0x0
  pushl $131
  105868:	68 83 00 00 00       	push   $0x83
  jmp alltraps
  10586d:	e9 be f6 ff ff       	jmp    104f30 <alltraps>

00105872 <vector132>:
.globl vector132
vector132:
  pushl $0
  105872:	6a 00                	push   $0x0
  pushl $132
  105874:	68 84 00 00 00       	push   $0x84
  jmp alltraps
  105879:	e9 b2 f6 ff ff       	jmp    104f30 <alltraps>

0010587e <vector133>:
.globl vector133
vector133:
  pushl $0
  10587e:	6a 00                	push   $0x0
  pushl $133
  105880:	68 85 00 00 00       	push   $0x85
  jmp alltraps
  105885:	e9 a6 f6 ff ff       	jmp    104f30 <alltraps>

0010588a <vector134>:
.globl vector134
vector134:
  pushl $0
  10588a:	6a 00                	push   $0x0
  pushl $134
  10588c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
  105891:	e9 9a f6 ff ff       	jmp    104f30 <alltraps>

00105896 <vector135>:
.globl vector135
vector135:
  pushl $0
  105896:	6a 00                	push   $0x0
  pushl $135
  105898:	68 87 00 00 00       	push   $0x87
  jmp alltraps
  10589d:	e9 8e f6 ff ff       	jmp    104f30 <alltraps>

001058a2 <vector136>:
.globl vector136
vector136:
  pushl $0
  1058a2:	6a 00                	push   $0x0
  pushl $136
  1058a4:	68 88 00 00 00       	push   $0x88
  jmp alltraps
  1058a9:	e9 82 f6 ff ff       	jmp    104f30 <alltraps>

001058ae <vector137>:
.globl vector137
vector137:
  pushl $0
  1058ae:	6a 00                	push   $0x0
  pushl $137
  1058b0:	68 89 00 00 00       	push   $0x89
  jmp alltraps
  1058b5:	e9 76 f6 ff ff       	jmp    104f30 <alltraps>

001058ba <vector138>:
.globl vector138
vector138:
  pushl $0
  1058ba:	6a 00                	push   $0x0
  pushl $138
  1058bc:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
  1058c1:	e9 6a f6 ff ff       	jmp    104f30 <alltraps>

001058c6 <vector139>:
.globl vector139
vector139:
  pushl $0
  1058c6:	6a 00                	push   $0x0
  pushl $139
  1058c8:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
  1058cd:	e9 5e f6 ff ff       	jmp    104f30 <alltraps>

001058d2 <vector140>:
.globl vector140
vector140:
  pushl $0
  1058d2:	6a 00                	push   $0x0
  pushl $140
  1058d4:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
  1058d9:	e9 52 f6 ff ff       	jmp    104f30 <alltraps>

001058de <vector141>:
.globl vector141
vector141:
  pushl $0
  1058de:	6a 00                	push   $0x0
  pushl $141
  1058e0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
  1058e5:	e9 46 f6 ff ff       	jmp    104f30 <alltraps>

001058ea <vector142>:
.globl vector142
vector142:
  pushl $0
  1058ea:	6a 00                	push   $0x0
  pushl $142
  1058ec:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
  1058f1:	e9 3a f6 ff ff       	jmp    104f30 <alltraps>

001058f6 <vector143>:
.globl vector143
vector143:
  pushl $0
  1058f6:	6a 00                	push   $0x0
  pushl $143
  1058f8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
  1058fd:	e9 2e f6 ff ff       	jmp    104f30 <alltraps>

00105902 <vector144>:
.globl vector144
vector144:
  pushl $0
  105902:	6a 00                	push   $0x0
  pushl $144
  105904:	68 90 00 00 00       	push   $0x90
  jmp alltraps
  105909:	e9 22 f6 ff ff       	jmp    104f30 <alltraps>

0010590e <vector145>:
.globl vector145
vector145:
  pushl $0
  10590e:	6a 00                	push   $0x0
  pushl $145
  105910:	68 91 00 00 00       	push   $0x91
  jmp alltraps
  105915:	e9 16 f6 ff ff       	jmp    104f30 <alltraps>

0010591a <vector146>:
.globl vector146
vector146:
  pushl $0
  10591a:	6a 00                	push   $0x0
  pushl $146
  10591c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
  105921:	e9 0a f6 ff ff       	jmp    104f30 <alltraps>

00105926 <vector147>:
.globl vector147
vector147:
  pushl $0
  105926:	6a 00                	push   $0x0
  pushl $147
  105928:	68 93 00 00 00       	push   $0x93
  jmp alltraps
  10592d:	e9 fe f5 ff ff       	jmp    104f30 <alltraps>

00105932 <vector148>:
.globl vector148
vector148:
  pushl $0
  105932:	6a 00                	push   $0x0
  pushl $148
  105934:	68 94 00 00 00       	push   $0x94
  jmp alltraps
  105939:	e9 f2 f5 ff ff       	jmp    104f30 <alltraps>

0010593e <vector149>:
.globl vector149
vector149:
  pushl $0
  10593e:	6a 00                	push   $0x0
  pushl $149
  105940:	68 95 00 00 00       	push   $0x95
  jmp alltraps
  105945:	e9 e6 f5 ff ff       	jmp    104f30 <alltraps>

0010594a <vector150>:
.globl vector150
vector150:
  pushl $0
  10594a:	6a 00                	push   $0x0
  pushl $150
  10594c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
  105951:	e9 da f5 ff ff       	jmp    104f30 <alltraps>

00105956 <vector151>:
.globl vector151
vector151:
  pushl $0
  105956:	6a 00                	push   $0x0
  pushl $151
  105958:	68 97 00 00 00       	push   $0x97
  jmp alltraps
  10595d:	e9 ce f5 ff ff       	jmp    104f30 <alltraps>

00105962 <vector152>:
.globl vector152
vector152:
  pushl $0
  105962:	6a 00                	push   $0x0
  pushl $152
  105964:	68 98 00 00 00       	push   $0x98
  jmp alltraps
  105969:	e9 c2 f5 ff ff       	jmp    104f30 <alltraps>

0010596e <vector153>:
.globl vector153
vector153:
  pushl $0
  10596e:	6a 00                	push   $0x0
  pushl $153
  105970:	68 99 00 00 00       	push   $0x99
  jmp alltraps
  105975:	e9 b6 f5 ff ff       	jmp    104f30 <alltraps>

0010597a <vector154>:
.globl vector154
vector154:
  pushl $0
  10597a:	6a 00                	push   $0x0
  pushl $154
  10597c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
  105981:	e9 aa f5 ff ff       	jmp    104f30 <alltraps>

00105986 <vector155>:
.globl vector155
vector155:
  pushl $0
  105986:	6a 00                	push   $0x0
  pushl $155
  105988:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
  10598d:	e9 9e f5 ff ff       	jmp    104f30 <alltraps>

00105992 <vector156>:
.globl vector156
vector156:
  pushl $0
  105992:	6a 00                	push   $0x0
  pushl $156
  105994:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
  105999:	e9 92 f5 ff ff       	jmp    104f30 <alltraps>

0010599e <vector157>:
.globl vector157
vector157:
  pushl $0
  10599e:	6a 00                	push   $0x0
  pushl $157
  1059a0:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
  1059a5:	e9 86 f5 ff ff       	jmp    104f30 <alltraps>

001059aa <vector158>:
.globl vector158
vector158:
  pushl $0
  1059aa:	6a 00                	push   $0x0
  pushl $158
  1059ac:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
  1059b1:	e9 7a f5 ff ff       	jmp    104f30 <alltraps>

001059b6 <vector159>:
.globl vector159
vector159:
  pushl $0
  1059b6:	6a 00                	push   $0x0
  pushl $159
  1059b8:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
  1059bd:	e9 6e f5 ff ff       	jmp    104f30 <alltraps>

001059c2 <vector160>:
.globl vector160
vector160:
  pushl $0
  1059c2:	6a 00                	push   $0x0
  pushl $160
  1059c4:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
  1059c9:	e9 62 f5 ff ff       	jmp    104f30 <alltraps>

001059ce <vector161>:
.globl vector161
vector161:
  pushl $0
  1059ce:	6a 00                	push   $0x0
  pushl $161
  1059d0:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
  1059d5:	e9 56 f5 ff ff       	jmp    104f30 <alltraps>

001059da <vector162>:
.globl vector162
vector162:
  pushl $0
  1059da:	6a 00                	push   $0x0
  pushl $162
  1059dc:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
  1059e1:	e9 4a f5 ff ff       	jmp    104f30 <alltraps>

001059e6 <vector163>:
.globl vector163
vector163:
  pushl $0
  1059e6:	6a 00                	push   $0x0
  pushl $163
  1059e8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
  1059ed:	e9 3e f5 ff ff       	jmp    104f30 <alltraps>

001059f2 <vector164>:
.globl vector164
vector164:
  pushl $0
  1059f2:	6a 00                	push   $0x0
  pushl $164
  1059f4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
  1059f9:	e9 32 f5 ff ff       	jmp    104f30 <alltraps>

001059fe <vector165>:
.globl vector165
vector165:
  pushl $0
  1059fe:	6a 00                	push   $0x0
  pushl $165
  105a00:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
  105a05:	e9 26 f5 ff ff       	jmp    104f30 <alltraps>

00105a0a <vector166>:
.globl vector166
vector166:
  pushl $0
  105a0a:	6a 00                	push   $0x0
  pushl $166
  105a0c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
  105a11:	e9 1a f5 ff ff       	jmp    104f30 <alltraps>

00105a16 <vector167>:
.globl vector167
vector167:
  pushl $0
  105a16:	6a 00                	push   $0x0
  pushl $167
  105a18:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
  105a1d:	e9 0e f5 ff ff       	jmp    104f30 <alltraps>

00105a22 <vector168>:
.globl vector168
vector168:
  pushl $0
  105a22:	6a 00                	push   $0x0
  pushl $168
  105a24:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
  105a29:	e9 02 f5 ff ff       	jmp    104f30 <alltraps>

00105a2e <vector169>:
.globl vector169
vector169:
  pushl $0
  105a2e:	6a 00                	push   $0x0
  pushl $169
  105a30:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
  105a35:	e9 f6 f4 ff ff       	jmp    104f30 <alltraps>

00105a3a <vector170>:
.globl vector170
vector170:
  pushl $0
  105a3a:	6a 00                	push   $0x0
  pushl $170
  105a3c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
  105a41:	e9 ea f4 ff ff       	jmp    104f30 <alltraps>

00105a46 <vector171>:
.globl vector171
vector171:
  pushl $0
  105a46:	6a 00                	push   $0x0
  pushl $171
  105a48:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
  105a4d:	e9 de f4 ff ff       	jmp    104f30 <alltraps>

00105a52 <vector172>:
.globl vector172
vector172:
  pushl $0
  105a52:	6a 00                	push   $0x0
  pushl $172
  105a54:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
  105a59:	e9 d2 f4 ff ff       	jmp    104f30 <alltraps>

00105a5e <vector173>:
.globl vector173
vector173:
  pushl $0
  105a5e:	6a 00                	push   $0x0
  pushl $173
  105a60:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
  105a65:	e9 c6 f4 ff ff       	jmp    104f30 <alltraps>

00105a6a <vector174>:
.globl vector174
vector174:
  pushl $0
  105a6a:	6a 00                	push   $0x0
  pushl $174
  105a6c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
  105a71:	e9 ba f4 ff ff       	jmp    104f30 <alltraps>

00105a76 <vector175>:
.globl vector175
vector175:
  pushl $0
  105a76:	6a 00                	push   $0x0
  pushl $175
  105a78:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
  105a7d:	e9 ae f4 ff ff       	jmp    104f30 <alltraps>

00105a82 <vector176>:
.globl vector176
vector176:
  pushl $0
  105a82:	6a 00                	push   $0x0
  pushl $176
  105a84:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
  105a89:	e9 a2 f4 ff ff       	jmp    104f30 <alltraps>

00105a8e <vector177>:
.globl vector177
vector177:
  pushl $0
  105a8e:	6a 00                	push   $0x0
  pushl $177
  105a90:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
  105a95:	e9 96 f4 ff ff       	jmp    104f30 <alltraps>

00105a9a <vector178>:
.globl vector178
vector178:
  pushl $0
  105a9a:	6a 00                	push   $0x0
  pushl $178
  105a9c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
  105aa1:	e9 8a f4 ff ff       	jmp    104f30 <alltraps>

00105aa6 <vector179>:
.globl vector179
vector179:
  pushl $0
  105aa6:	6a 00                	push   $0x0
  pushl $179
  105aa8:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
  105aad:	e9 7e f4 ff ff       	jmp    104f30 <alltraps>

00105ab2 <vector180>:
.globl vector180
vector180:
  pushl $0
  105ab2:	6a 00                	push   $0x0
  pushl $180
  105ab4:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
  105ab9:	e9 72 f4 ff ff       	jmp    104f30 <alltraps>

00105abe <vector181>:
.globl vector181
vector181:
  pushl $0
  105abe:	6a 00                	push   $0x0
  pushl $181
  105ac0:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
  105ac5:	e9 66 f4 ff ff       	jmp    104f30 <alltraps>

00105aca <vector182>:
.globl vector182
vector182:
  pushl $0
  105aca:	6a 00                	push   $0x0
  pushl $182
  105acc:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
  105ad1:	e9 5a f4 ff ff       	jmp    104f30 <alltraps>

00105ad6 <vector183>:
.globl vector183
vector183:
  pushl $0
  105ad6:	6a 00                	push   $0x0
  pushl $183
  105ad8:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
  105add:	e9 4e f4 ff ff       	jmp    104f30 <alltraps>

00105ae2 <vector184>:
.globl vector184
vector184:
  pushl $0
  105ae2:	6a 00                	push   $0x0
  pushl $184
  105ae4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
  105ae9:	e9 42 f4 ff ff       	jmp    104f30 <alltraps>

00105aee <vector185>:
.globl vector185
vector185:
  pushl $0
  105aee:	6a 00                	push   $0x0
  pushl $185
  105af0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
  105af5:	e9 36 f4 ff ff       	jmp    104f30 <alltraps>

00105afa <vector186>:
.globl vector186
vector186:
  pushl $0
  105afa:	6a 00                	push   $0x0
  pushl $186
  105afc:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
  105b01:	e9 2a f4 ff ff       	jmp    104f30 <alltraps>

00105b06 <vector187>:
.globl vector187
vector187:
  pushl $0
  105b06:	6a 00                	push   $0x0
  pushl $187
  105b08:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
  105b0d:	e9 1e f4 ff ff       	jmp    104f30 <alltraps>

00105b12 <vector188>:
.globl vector188
vector188:
  pushl $0
  105b12:	6a 00                	push   $0x0
  pushl $188
  105b14:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
  105b19:	e9 12 f4 ff ff       	jmp    104f30 <alltraps>

00105b1e <vector189>:
.globl vector189
vector189:
  pushl $0
  105b1e:	6a 00                	push   $0x0
  pushl $189
  105b20:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
  105b25:	e9 06 f4 ff ff       	jmp    104f30 <alltraps>

00105b2a <vector190>:
.globl vector190
vector190:
  pushl $0
  105b2a:	6a 00                	push   $0x0
  pushl $190
  105b2c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
  105b31:	e9 fa f3 ff ff       	jmp    104f30 <alltraps>

00105b36 <vector191>:
.globl vector191
vector191:
  pushl $0
  105b36:	6a 00                	push   $0x0
  pushl $191
  105b38:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
  105b3d:	e9 ee f3 ff ff       	jmp    104f30 <alltraps>

00105b42 <vector192>:
.globl vector192
vector192:
  pushl $0
  105b42:	6a 00                	push   $0x0
  pushl $192
  105b44:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
  105b49:	e9 e2 f3 ff ff       	jmp    104f30 <alltraps>

00105b4e <vector193>:
.globl vector193
vector193:
  pushl $0
  105b4e:	6a 00                	push   $0x0
  pushl $193
  105b50:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
  105b55:	e9 d6 f3 ff ff       	jmp    104f30 <alltraps>

00105b5a <vector194>:
.globl vector194
vector194:
  pushl $0
  105b5a:	6a 00                	push   $0x0
  pushl $194
  105b5c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
  105b61:	e9 ca f3 ff ff       	jmp    104f30 <alltraps>

00105b66 <vector195>:
.globl vector195
vector195:
  pushl $0
  105b66:	6a 00                	push   $0x0
  pushl $195
  105b68:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
  105b6d:	e9 be f3 ff ff       	jmp    104f30 <alltraps>

00105b72 <vector196>:
.globl vector196
vector196:
  pushl $0
  105b72:	6a 00                	push   $0x0
  pushl $196
  105b74:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
  105b79:	e9 b2 f3 ff ff       	jmp    104f30 <alltraps>

00105b7e <vector197>:
.globl vector197
vector197:
  pushl $0
  105b7e:	6a 00                	push   $0x0
  pushl $197
  105b80:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
  105b85:	e9 a6 f3 ff ff       	jmp    104f30 <alltraps>

00105b8a <vector198>:
.globl vector198
vector198:
  pushl $0
  105b8a:	6a 00                	push   $0x0
  pushl $198
  105b8c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
  105b91:	e9 9a f3 ff ff       	jmp    104f30 <alltraps>

00105b96 <vector199>:
.globl vector199
vector199:
  pushl $0
  105b96:	6a 00                	push   $0x0
  pushl $199
  105b98:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
  105b9d:	e9 8e f3 ff ff       	jmp    104f30 <alltraps>

00105ba2 <vector200>:
.globl vector200
vector200:
  pushl $0
  105ba2:	6a 00                	push   $0x0
  pushl $200
  105ba4:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
  105ba9:	e9 82 f3 ff ff       	jmp    104f30 <alltraps>

00105bae <vector201>:
.globl vector201
vector201:
  pushl $0
  105bae:	6a 00                	push   $0x0
  pushl $201
  105bb0:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
  105bb5:	e9 76 f3 ff ff       	jmp    104f30 <alltraps>

00105bba <vector202>:
.globl vector202
vector202:
  pushl $0
  105bba:	6a 00                	push   $0x0
  pushl $202
  105bbc:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
  105bc1:	e9 6a f3 ff ff       	jmp    104f30 <alltraps>

00105bc6 <vector203>:
.globl vector203
vector203:
  pushl $0
  105bc6:	6a 00                	push   $0x0
  pushl $203
  105bc8:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
  105bcd:	e9 5e f3 ff ff       	jmp    104f30 <alltraps>

00105bd2 <vector204>:
.globl vector204
vector204:
  pushl $0
  105bd2:	6a 00                	push   $0x0
  pushl $204
  105bd4:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
  105bd9:	e9 52 f3 ff ff       	jmp    104f30 <alltraps>

00105bde <vector205>:
.globl vector205
vector205:
  pushl $0
  105bde:	6a 00                	push   $0x0
  pushl $205
  105be0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
  105be5:	e9 46 f3 ff ff       	jmp    104f30 <alltraps>

00105bea <vector206>:
.globl vector206
vector206:
  pushl $0
  105bea:	6a 00                	push   $0x0
  pushl $206
  105bec:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
  105bf1:	e9 3a f3 ff ff       	jmp    104f30 <alltraps>

00105bf6 <vector207>:
.globl vector207
vector207:
  pushl $0
  105bf6:	6a 00                	push   $0x0
  pushl $207
  105bf8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
  105bfd:	e9 2e f3 ff ff       	jmp    104f30 <alltraps>

00105c02 <vector208>:
.globl vector208
vector208:
  pushl $0
  105c02:	6a 00                	push   $0x0
  pushl $208
  105c04:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
  105c09:	e9 22 f3 ff ff       	jmp    104f30 <alltraps>

00105c0e <vector209>:
.globl vector209
vector209:
  pushl $0
  105c0e:	6a 00                	push   $0x0
  pushl $209
  105c10:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
  105c15:	e9 16 f3 ff ff       	jmp    104f30 <alltraps>

00105c1a <vector210>:
.globl vector210
vector210:
  pushl $0
  105c1a:	6a 00                	push   $0x0
  pushl $210
  105c1c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
  105c21:	e9 0a f3 ff ff       	jmp    104f30 <alltraps>

00105c26 <vector211>:
.globl vector211
vector211:
  pushl $0
  105c26:	6a 00                	push   $0x0
  pushl $211
  105c28:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
  105c2d:	e9 fe f2 ff ff       	jmp    104f30 <alltraps>

00105c32 <vector212>:
.globl vector212
vector212:
  pushl $0
  105c32:	6a 00                	push   $0x0
  pushl $212
  105c34:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
  105c39:	e9 f2 f2 ff ff       	jmp    104f30 <alltraps>

00105c3e <vector213>:
.globl vector213
vector213:
  pushl $0
  105c3e:	6a 00                	push   $0x0
  pushl $213
  105c40:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
  105c45:	e9 e6 f2 ff ff       	jmp    104f30 <alltraps>

00105c4a <vector214>:
.globl vector214
vector214:
  pushl $0
  105c4a:	6a 00                	push   $0x0
  pushl $214
  105c4c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
  105c51:	e9 da f2 ff ff       	jmp    104f30 <alltraps>

00105c56 <vector215>:
.globl vector215
vector215:
  pushl $0
  105c56:	6a 00                	push   $0x0
  pushl $215
  105c58:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
  105c5d:	e9 ce f2 ff ff       	jmp    104f30 <alltraps>

00105c62 <vector216>:
.globl vector216
vector216:
  pushl $0
  105c62:	6a 00                	push   $0x0
  pushl $216
  105c64:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
  105c69:	e9 c2 f2 ff ff       	jmp    104f30 <alltraps>

00105c6e <vector217>:
.globl vector217
vector217:
  pushl $0
  105c6e:	6a 00                	push   $0x0
  pushl $217
  105c70:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
  105c75:	e9 b6 f2 ff ff       	jmp    104f30 <alltraps>

00105c7a <vector218>:
.globl vector218
vector218:
  pushl $0
  105c7a:	6a 00                	push   $0x0
  pushl $218
  105c7c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
  105c81:	e9 aa f2 ff ff       	jmp    104f30 <alltraps>

00105c86 <vector219>:
.globl vector219
vector219:
  pushl $0
  105c86:	6a 00                	push   $0x0
  pushl $219
  105c88:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
  105c8d:	e9 9e f2 ff ff       	jmp    104f30 <alltraps>

00105c92 <vector220>:
.globl vector220
vector220:
  pushl $0
  105c92:	6a 00                	push   $0x0
  pushl $220
  105c94:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
  105c99:	e9 92 f2 ff ff       	jmp    104f30 <alltraps>

00105c9e <vector221>:
.globl vector221
vector221:
  pushl $0
  105c9e:	6a 00                	push   $0x0
  pushl $221
  105ca0:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
  105ca5:	e9 86 f2 ff ff       	jmp    104f30 <alltraps>

00105caa <vector222>:
.globl vector222
vector222:
  pushl $0
  105caa:	6a 00                	push   $0x0
  pushl $222
  105cac:	68 de 00 00 00       	push   $0xde
  jmp alltraps
  105cb1:	e9 7a f2 ff ff       	jmp    104f30 <alltraps>

00105cb6 <vector223>:
.globl vector223
vector223:
  pushl $0
  105cb6:	6a 00                	push   $0x0
  pushl $223
  105cb8:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
  105cbd:	e9 6e f2 ff ff       	jmp    104f30 <alltraps>

00105cc2 <vector224>:
.globl vector224
vector224:
  pushl $0
  105cc2:	6a 00                	push   $0x0
  pushl $224
  105cc4:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
  105cc9:	e9 62 f2 ff ff       	jmp    104f30 <alltraps>

00105cce <vector225>:
.globl vector225
vector225:
  pushl $0
  105cce:	6a 00                	push   $0x0
  pushl $225
  105cd0:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
  105cd5:	e9 56 f2 ff ff       	jmp    104f30 <alltraps>

00105cda <vector226>:
.globl vector226
vector226:
  pushl $0
  105cda:	6a 00                	push   $0x0
  pushl $226
  105cdc:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
  105ce1:	e9 4a f2 ff ff       	jmp    104f30 <alltraps>

00105ce6 <vector227>:
.globl vector227
vector227:
  pushl $0
  105ce6:	6a 00                	push   $0x0
  pushl $227
  105ce8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
  105ced:	e9 3e f2 ff ff       	jmp    104f30 <alltraps>

00105cf2 <vector228>:
.globl vector228
vector228:
  pushl $0
  105cf2:	6a 00                	push   $0x0
  pushl $228
  105cf4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
  105cf9:	e9 32 f2 ff ff       	jmp    104f30 <alltraps>

00105cfe <vector229>:
.globl vector229
vector229:
  pushl $0
  105cfe:	6a 00                	push   $0x0
  pushl $229
  105d00:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
  105d05:	e9 26 f2 ff ff       	jmp    104f30 <alltraps>

00105d0a <vector230>:
.globl vector230
vector230:
  pushl $0
  105d0a:	6a 00                	push   $0x0
  pushl $230
  105d0c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
  105d11:	e9 1a f2 ff ff       	jmp    104f30 <alltraps>

00105d16 <vector231>:
.globl vector231
vector231:
  pushl $0
  105d16:	6a 00                	push   $0x0
  pushl $231
  105d18:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
  105d1d:	e9 0e f2 ff ff       	jmp    104f30 <alltraps>

00105d22 <vector232>:
.globl vector232
vector232:
  pushl $0
  105d22:	6a 00                	push   $0x0
  pushl $232
  105d24:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
  105d29:	e9 02 f2 ff ff       	jmp    104f30 <alltraps>

00105d2e <vector233>:
.globl vector233
vector233:
  pushl $0
  105d2e:	6a 00                	push   $0x0
  pushl $233
  105d30:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
  105d35:	e9 f6 f1 ff ff       	jmp    104f30 <alltraps>

00105d3a <vector234>:
.globl vector234
vector234:
  pushl $0
  105d3a:	6a 00                	push   $0x0
  pushl $234
  105d3c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
  105d41:	e9 ea f1 ff ff       	jmp    104f30 <alltraps>

00105d46 <vector235>:
.globl vector235
vector235:
  pushl $0
  105d46:	6a 00                	push   $0x0
  pushl $235
  105d48:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
  105d4d:	e9 de f1 ff ff       	jmp    104f30 <alltraps>

00105d52 <vector236>:
.globl vector236
vector236:
  pushl $0
  105d52:	6a 00                	push   $0x0
  pushl $236
  105d54:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
  105d59:	e9 d2 f1 ff ff       	jmp    104f30 <alltraps>

00105d5e <vector237>:
.globl vector237
vector237:
  pushl $0
  105d5e:	6a 00                	push   $0x0
  pushl $237
  105d60:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
  105d65:	e9 c6 f1 ff ff       	jmp    104f30 <alltraps>

00105d6a <vector238>:
.globl vector238
vector238:
  pushl $0
  105d6a:	6a 00                	push   $0x0
  pushl $238
  105d6c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
  105d71:	e9 ba f1 ff ff       	jmp    104f30 <alltraps>

00105d76 <vector239>:
.globl vector239
vector239:
  pushl $0
  105d76:	6a 00                	push   $0x0
  pushl $239
  105d78:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
  105d7d:	e9 ae f1 ff ff       	jmp    104f30 <alltraps>

00105d82 <vector240>:
.globl vector240
vector240:
  pushl $0
  105d82:	6a 00                	push   $0x0
  pushl $240
  105d84:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
  105d89:	e9 a2 f1 ff ff       	jmp    104f30 <alltraps>

00105d8e <vector241>:
.globl vector241
vector241:
  pushl $0
  105d8e:	6a 00                	push   $0x0
  pushl $241
  105d90:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
  105d95:	e9 96 f1 ff ff       	jmp    104f30 <alltraps>

00105d9a <vector242>:
.globl vector242
vector242:
  pushl $0
  105d9a:	6a 00                	push   $0x0
  pushl $242
  105d9c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
  105da1:	e9 8a f1 ff ff       	jmp    104f30 <alltraps>

00105da6 <vector243>:
.globl vector243
vector243:
  pushl $0
  105da6:	6a 00                	push   $0x0
  pushl $243
  105da8:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
  105dad:	e9 7e f1 ff ff       	jmp    104f30 <alltraps>

00105db2 <vector244>:
.globl vector244
vector244:
  pushl $0
  105db2:	6a 00                	push   $0x0
  pushl $244
  105db4:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
  105db9:	e9 72 f1 ff ff       	jmp    104f30 <alltraps>

00105dbe <vector245>:
.globl vector245
vector245:
  pushl $0
  105dbe:	6a 00                	push   $0x0
  pushl $245
  105dc0:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
  105dc5:	e9 66 f1 ff ff       	jmp    104f30 <alltraps>

00105dca <vector246>:
.globl vector246
vector246:
  pushl $0
  105dca:	6a 00                	push   $0x0
  pushl $246
  105dcc:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
  105dd1:	e9 5a f1 ff ff       	jmp    104f30 <alltraps>

00105dd6 <vector247>:
.globl vector247
vector247:
  pushl $0
  105dd6:	6a 00                	push   $0x0
  pushl $247
  105dd8:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
  105ddd:	e9 4e f1 ff ff       	jmp    104f30 <alltraps>

00105de2 <vector248>:
.globl vector248
vector248:
  pushl $0
  105de2:	6a 00                	push   $0x0
  pushl $248
  105de4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
  105de9:	e9 42 f1 ff ff       	jmp    104f30 <alltraps>

00105dee <vector249>:
.globl vector249
vector249:
  pushl $0
  105dee:	6a 00                	push   $0x0
  pushl $249
  105df0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
  105df5:	e9 36 f1 ff ff       	jmp    104f30 <alltraps>

00105dfa <vector250>:
.globl vector250
vector250:
  pushl $0
  105dfa:	6a 00                	push   $0x0
  pushl $250
  105dfc:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
  105e01:	e9 2a f1 ff ff       	jmp    104f30 <alltraps>

00105e06 <vector251>:
.globl vector251
vector251:
  pushl $0
  105e06:	6a 00                	push   $0x0
  pushl $251
  105e08:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
  105e0d:	e9 1e f1 ff ff       	jmp    104f30 <alltraps>

00105e12 <vector252>:
.globl vector252
vector252:
  pushl $0
  105e12:	6a 00                	push   $0x0
  pushl $252
  105e14:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
  105e19:	e9 12 f1 ff ff       	jmp    104f30 <alltraps>

00105e1e <vector253>:
.globl vector253
vector253:
  pushl $0
  105e1e:	6a 00                	push   $0x0
  pushl $253
  105e20:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
  105e25:	e9 06 f1 ff ff       	jmp    104f30 <alltraps>

00105e2a <vector254>:
.globl vector254
vector254:
  pushl $0
  105e2a:	6a 00                	push   $0x0
  pushl $254
  105e2c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
  105e31:	e9 fa f0 ff ff       	jmp    104f30 <alltraps>

00105e36 <vector255>:
.globl vector255
vector255:
  pushl $0
  105e36:	6a 00                	push   $0x0
  pushl $255
  105e38:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
  105e3d:	e9 ee f0 ff ff       	jmp    104f30 <alltraps>
  105e42:	90                   	nop
  105e43:	90                   	nop
  105e44:	90                   	nop
  105e45:	90                   	nop
  105e46:	90                   	nop
  105e47:	90                   	nop
  105e48:	90                   	nop
  105e49:	90                   	nop
  105e4a:	90                   	nop
  105e4b:	90                   	nop
  105e4c:	90                   	nop
  105e4d:	90                   	nop
  105e4e:	90                   	nop
  105e4f:	90                   	nop

00105e50 <vmenable>:
}

// Turn on paging.
void
vmenable(void)
{
  105e50:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105e51:	a1 d0 78 10 00       	mov    0x1078d0,%eax
  105e56:	89 e5                	mov    %esp,%ebp
  105e58:	0f 22 d8             	mov    %eax,%cr3

static inline uint
rcr0(void)
{
  uint val;
  asm volatile("movl %%cr0,%0" : "=r" (val));
  105e5b:	0f 20 c0             	mov    %cr0,%eax
}

static inline void
lcr0(uint val)
{
  asm volatile("movl %0,%%cr0" : : "r" (val));
  105e5e:	0d 00 00 00 80       	or     $0x80000000,%eax
  105e63:	0f 22 c0             	mov    %eax,%cr0

  switchkvm(); // load kpgdir into cr3
  cr0 = rcr0();
  cr0 |= CR0_PG;
  lcr0(cr0);
}
  105e66:	5d                   	pop    %ebp
  105e67:	c3                   	ret    
  105e68:	90                   	nop
  105e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00105e70 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  105e70:	55                   	push   %ebp
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  105e71:	a1 d0 78 10 00       	mov    0x1078d0,%eax
  105e76:	89 e5                	mov    %esp,%ebp
  105e78:	0f 22 d8             	mov    %eax,%cr3
  lcr3(PADDR(kpgdir));   // switch to the kernel page table
}
  105e7b:	5d                   	pop    %ebp
  105e7c:	c3                   	ret    
  105e7d:	8d 76 00             	lea    0x0(%esi),%esi

00105e80 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105e80:	55                   	push   %ebp
  105e81:	89 e5                	mov    %esp,%ebp
  105e83:	83 ec 28             	sub    $0x28,%esp
  105e86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  105e89:	89 d3                	mov    %edx,%ebx
  105e8b:	c1 eb 16             	shr    $0x16,%ebx
  105e8e:	8d 1c 98             	lea    (%eax,%ebx,4),%ebx
// Return the address of the PTE in page table pgdir
// that corresponds to linear address va.  If create!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int create)
{
  105e91:	89 75 fc             	mov    %esi,-0x4(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
  105e94:	8b 33                	mov    (%ebx),%esi
  105e96:	f7 c6 01 00 00 00    	test   $0x1,%esi
  105e9c:	74 22                	je     105ec0 <walkpgdir+0x40>
    pgtab = (pte_t*)PTE_ADDR(*pde);
  105e9e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105ea4:	c1 ea 0a             	shr    $0xa,%edx
  105ea7:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  105ead:	8d 04 16             	lea    (%esi,%edx,1),%eax
}
  105eb0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  105eb3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  105eb6:	89 ec                	mov    %ebp,%esp
  105eb8:	5d                   	pop    %ebp
  105eb9:	c3                   	ret    
  105eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105ec0:	85 c9                	test   %ecx,%ecx
  105ec2:	75 04                	jne    105ec8 <walkpgdir+0x48>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
  105ec4:	31 c0                	xor    %eax,%eax
  105ec6:	eb e8                	jmp    105eb0 <walkpgdir+0x30>

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)PTE_ADDR(*pde);
  } else {
    if(!create || (pgtab = (pte_t*)kalloc()) == 0)
  105ec8:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105ecb:	90                   	nop
  105ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105ed0:	e8 0b c4 ff ff       	call   1022e0 <kalloc>
  105ed5:	85 c0                	test   %eax,%eax
  105ed7:	89 c6                	mov    %eax,%esi
  105ed9:	74 e9                	je     105ec4 <walkpgdir+0x44>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
  105edb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105ee2:	00 
  105ee3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105eea:	00 
  105eeb:	89 04 24             	mov    %eax,(%esp)
  105eee:	e8 0d df ff ff       	call   103e00 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
  105ef3:	89 f0                	mov    %esi,%eax
  105ef5:	83 c8 07             	or     $0x7,%eax
  105ef8:	89 03                	mov    %eax,(%ebx)
  105efa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105efd:	eb a5                	jmp    105ea4 <walkpgdir+0x24>
  105eff:	90                   	nop

00105f00 <uva2ka>:
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105f00:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105f01:	31 c9                	xor    %ecx,%ecx
}

// Map user virtual address to kernel physical address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
  105f03:	89 e5                	mov    %esp,%ebp
  105f05:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  105f08:	8b 55 0c             	mov    0xc(%ebp),%edx
  105f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  105f0e:	e8 6d ff ff ff       	call   105e80 <walkpgdir>
  if((*pte & PTE_P) == 0)
  105f13:	8b 00                	mov    (%eax),%eax
  105f15:	a8 01                	test   $0x1,%al
  105f17:	75 07                	jne    105f20 <uva2ka+0x20>
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)PTE_ADDR(*pte);
  105f19:	31 c0                	xor    %eax,%eax
}
  105f1b:	c9                   	leave  
  105f1c:	c3                   	ret    
  105f1d:	8d 76 00             	lea    0x0(%esi),%esi
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
  105f20:	a8 04                	test   $0x4,%al
  105f22:	74 f5                	je     105f19 <uva2ka+0x19>
    return 0;
  return (char*)PTE_ADDR(*pte);
  105f24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
  105f29:	c9                   	leave  
  105f2a:	c3                   	ret    
  105f2b:	90                   	nop
  105f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00105f30 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  105f30:	55                   	push   %ebp
  105f31:	89 e5                	mov    %esp,%ebp
  105f33:	57                   	push   %edi
  105f34:	56                   	push   %esi
  105f35:	53                   	push   %ebx
  105f36:	83 ec 2c             	sub    $0x2c,%esp
  105f39:	8b 5d 14             	mov    0x14(%ebp),%ebx
  105f3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  105f3f:	85 db                	test   %ebx,%ebx
  105f41:	74 75                	je     105fb8 <copyout+0x88>
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  105f43:	8b 45 10             	mov    0x10(%ebp),%eax
  105f46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105f49:	eb 39                	jmp    105f84 <copyout+0x54>
  105f4b:	90                   	nop
  105f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
  105f50:	89 f7                	mov    %esi,%edi
  105f52:	29 d7                	sub    %edx,%edi
  105f54:	81 c7 00 10 00 00    	add    $0x1000,%edi
  105f5a:	39 df                	cmp    %ebx,%edi
  105f5c:	0f 47 fb             	cmova  %ebx,%edi
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
  105f5f:	29 f2                	sub    %esi,%edx
  105f61:	89 7c 24 08          	mov    %edi,0x8(%esp)
  105f65:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  105f68:	8d 14 10             	lea    (%eax,%edx,1),%edx
  105f6b:	89 14 24             	mov    %edx,(%esp)
  105f6e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  105f72:	e8 09 df ff ff       	call   103e80 <memmove>
{
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
  105f77:	29 fb                	sub    %edi,%ebx
  105f79:	74 3d                	je     105fb8 <copyout+0x88>
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
  105f7b:	01 7d e4             	add    %edi,-0x1c(%ebp)
    va = va0 + PGSIZE;
  105f7e:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
  char *buf, *pa0;
  uint n, va0;
  
  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
  105f84:	89 d6                	mov    %edx,%esi
  105f86:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
  105f8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  105f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  105f93:	89 0c 24             	mov    %ecx,(%esp)
  105f96:	89 55 e0             	mov    %edx,-0x20(%ebp)
  105f99:	e8 62 ff ff ff       	call   105f00 <uva2ka>
    if(pa0 == 0)
  105f9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105fa1:	85 c0                	test   %eax,%eax
  105fa3:	75 ab                	jne    105f50 <copyout+0x20>
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
  105fa5:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  105fa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
  105fad:	5b                   	pop    %ebx
  105fae:	5e                   	pop    %esi
  105faf:	5f                   	pop    %edi
  105fb0:	5d                   	pop    %ebp
  105fb1:	c3                   	ret    
  105fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  105fb8:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  105fbb:	31 c0                	xor    %eax,%eax
  }
  return 0;
}
  105fbd:	5b                   	pop    %ebx
  105fbe:	5e                   	pop    %esi
  105fbf:	5f                   	pop    %edi
  105fc0:	5d                   	pop    %ebp
  105fc1:	c3                   	ret    
  105fc2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  105fc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00105fd0 <mappages>:
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  105fd0:	55                   	push   %ebp
  105fd1:	89 e5                	mov    %esp,%ebp
  105fd3:	57                   	push   %edi
  105fd4:	56                   	push   %esi
  105fd5:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  105fd6:	89 d3                	mov    %edx,%ebx
  last = PGROUNDDOWN(la + size - 1);
  105fd8:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
// Create PTEs for linear addresses starting at la that refer to
// physical addresses starting at pa. la and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *la, uint size, uint pa, int perm)
{
  105fdc:	83 ec 2c             	sub    $0x2c,%esp
  105fdf:	8b 75 08             	mov    0x8(%ebp),%esi
  105fe2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *a, *last;
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  105fe5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = PGROUNDDOWN(la + size - 1);
  105feb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  105ff1:	83 4d 0c 01          	orl    $0x1,0xc(%ebp)
  105ff5:	eb 1d                	jmp    106014 <mappages+0x44>
  105ff7:	90                   	nop
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
  105ff8:	f6 00 01             	testb  $0x1,(%eax)
  105ffb:	75 45                	jne    106042 <mappages+0x72>
      panic("remap");
    *pte = pa | perm | PTE_P;
  105ffd:	8b 55 0c             	mov    0xc(%ebp),%edx
  106000:	09 f2                	or     %esi,%edx
    if(a == last)
  106002:	39 fb                	cmp    %edi,%ebx
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
  106004:	89 10                	mov    %edx,(%eax)
    if(a == last)
  106006:	74 30                	je     106038 <mappages+0x68>
      break;
    a += PGSIZE;
  106008:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
  10600e:	81 c6 00 10 00 00    	add    $0x1000,%esi
  pte_t *pte;
  
  a = PGROUNDDOWN(la);
  last = PGROUNDDOWN(la + size - 1);
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
  106014:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106017:	b9 01 00 00 00       	mov    $0x1,%ecx
  10601c:	89 da                	mov    %ebx,%edx
  10601e:	e8 5d fe ff ff       	call   105e80 <walkpgdir>
    if(pte == 0)
  106023:	85 c0                	test   %eax,%eax
  106025:	75 d1                	jne    105ff8 <mappages+0x28>
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  106027:	83 c4 2c             	add    $0x2c,%esp
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  10602a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
  10602f:	5b                   	pop    %ebx
  106030:	5e                   	pop    %esi
  106031:	5f                   	pop    %edi
  106032:	5d                   	pop    %ebp
  106033:	c3                   	ret    
  106034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  106038:	83 c4 2c             	add    $0x2c,%esp
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
  10603b:	31 c0                	xor    %eax,%eax
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
  10603d:	5b                   	pop    %ebx
  10603e:	5e                   	pop    %esi
  10603f:	5f                   	pop    %edi
  106040:	5d                   	pop    %ebp
  106041:	c3                   	ret    
  for(;;){
    pte = walkpgdir(pgdir, a, 1);
    if(pte == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
  106042:	c7 04 24 d0 6e 10 00 	movl   $0x106ed0,(%esp)
  106049:	e8 62 a9 ff ff       	call   1009b0 <panic>
  10604e:	66 90                	xchg   %ax,%ax

00106050 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
  106050:	55                   	push   %ebp
  106051:	89 e5                	mov    %esp,%ebp
  106053:	56                   	push   %esi
  106054:	53                   	push   %ebx
  106055:	83 ec 10             	sub    $0x10,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
  106058:	e8 83 c2 ff ff       	call   1022e0 <kalloc>
  10605d:	85 c0                	test   %eax,%eax
  10605f:	89 c6                	mov    %eax,%esi
  106061:	74 50                	je     1060b3 <setupkvm+0x63>
    return 0;
  memset(pgdir, 0, PGSIZE);
  106063:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10606a:	00 
  10606b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  106072:	00 
  106073:	89 04 24             	mov    %eax,(%esp)
  106076:	e8 85 dd ff ff       	call   103e00 <memset>
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  10607b:	b8 70 77 10 00       	mov    $0x107770,%eax
  106080:	3d 40 77 10 00       	cmp    $0x107740,%eax
  106085:	76 2c                	jbe    1060b3 <setupkvm+0x63>
  {(void*)0xFE000000, 0,               PTE_W},  // device mappings
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
  106087:	bb 40 77 10 00       	mov    $0x107740,%ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  10608c:	8b 13                	mov    (%ebx),%edx
  10608e:	8b 4b 04             	mov    0x4(%ebx),%ecx
  106091:	8b 43 08             	mov    0x8(%ebx),%eax
  106094:	89 14 24             	mov    %edx,(%esp)
  106097:	29 d1                	sub    %edx,%ecx
  106099:	89 44 24 04          	mov    %eax,0x4(%esp)
  10609d:	89 f0                	mov    %esi,%eax
  10609f:	e8 2c ff ff ff       	call   105fd0 <mappages>
  1060a4:	85 c0                	test   %eax,%eax
  1060a6:	78 18                	js     1060c0 <setupkvm+0x70>

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
  1060a8:	83 c3 0c             	add    $0xc,%ebx
  1060ab:	81 fb 70 77 10 00    	cmp    $0x107770,%ebx
  1060b1:	75 d9                	jne    10608c <setupkvm+0x3c>
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
      return 0;

  return pgdir;
}
  1060b3:	83 c4 10             	add    $0x10,%esp
  1060b6:	89 f0                	mov    %esi,%eax
  1060b8:	5b                   	pop    %ebx
  1060b9:	5e                   	pop    %esi
  1060ba:	5d                   	pop    %ebp
  1060bb:	c3                   	ret    
  1060bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  k = kmap;
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->p, k->e - k->p, (uint)k->p, k->perm) < 0)
  1060c0:	31 f6                	xor    %esi,%esi
      return 0;

  return pgdir;
}
  1060c2:	83 c4 10             	add    $0x10,%esp
  1060c5:	89 f0                	mov    %esi,%eax
  1060c7:	5b                   	pop    %ebx
  1060c8:	5e                   	pop    %esi
  1060c9:	5d                   	pop    %ebp
  1060ca:	c3                   	ret    
  1060cb:	90                   	nop
  1060cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

001060d0 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
  1060d0:	55                   	push   %ebp
  1060d1:	89 e5                	mov    %esp,%ebp
  1060d3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
  1060d6:	e8 75 ff ff ff       	call   106050 <setupkvm>
  1060db:	a3 d0 78 10 00       	mov    %eax,0x1078d0
}
  1060e0:	c9                   	leave  
  1060e1:	c3                   	ret    
  1060e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1060e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

001060f0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  1060f0:	55                   	push   %ebp
  1060f1:	89 e5                	mov    %esp,%ebp
  1060f3:	83 ec 38             	sub    $0x38,%esp
  1060f6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  1060f9:	8b 75 10             	mov    0x10(%ebp),%esi
  1060fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1060ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  106102:	8b 7d 0c             	mov    0xc(%ebp),%edi
  106105:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  106108:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
  10610e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *mem;
  
  if(sz >= PGSIZE)
  106111:	77 53                	ja     106166 <inituvm+0x76>
    panic("inituvm: more than a page");
  mem = kalloc();
  106113:	e8 c8 c1 ff ff       	call   1022e0 <kalloc>
  memset(mem, 0, PGSIZE);
  106118:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10611f:	00 
  106120:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  106127:	00 
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  106128:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
  10612a:	89 04 24             	mov    %eax,(%esp)
  10612d:	e8 ce dc ff ff       	call   103e00 <memset>
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  106132:	b9 00 10 00 00       	mov    $0x1000,%ecx
  106137:	31 d2                	xor    %edx,%edx
  106139:	89 1c 24             	mov    %ebx,(%esp)
  10613c:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  106143:	00 
  106144:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106147:	e8 84 fe ff ff       	call   105fd0 <mappages>
  memmove(mem, init, sz);
  10614c:	89 75 10             	mov    %esi,0x10(%ebp)
}
  10614f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106152:	89 7d 0c             	mov    %edi,0xc(%ebp)
}
  106155:	8b 7d fc             	mov    -0x4(%ebp),%edi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106158:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  10615b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  10615e:	89 ec                	mov    %ebp,%esp
  106160:	5d                   	pop    %ebp
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
  106161:	e9 1a dd ff ff       	jmp    103e80 <memmove>
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;
  
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  106166:	c7 04 24 d6 6e 10 00 	movl   $0x106ed6,(%esp)
  10616d:	e8 3e a8 ff ff       	call   1009b0 <panic>
  106172:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  106179:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106180 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106180:	55                   	push   %ebp
  106181:	89 e5                	mov    %esp,%ebp
  106183:	57                   	push   %edi
  106184:	56                   	push   %esi
  106185:	53                   	push   %ebx
  106186:	83 ec 2c             	sub    $0x2c,%esp
  106189:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  10618c:	39 75 10             	cmp    %esi,0x10(%ebp)
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  10618f:	8b 7d 08             	mov    0x8(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;
  106192:	89 f0                	mov    %esi,%eax
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
  106194:	73 59                	jae    1061ef <deallocuvm+0x6f>
    return oldsz;

  a = PGROUNDUP(newsz);
  106196:	8b 5d 10             	mov    0x10(%ebp),%ebx
  106199:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  10619f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
  1061a5:	39 de                	cmp    %ebx,%esi
  1061a7:	76 43                	jbe    1061ec <deallocuvm+0x6c>
  1061a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
  1061b0:	31 c9                	xor    %ecx,%ecx
  1061b2:	89 da                	mov    %ebx,%edx
  1061b4:	89 f8                	mov    %edi,%eax
  1061b6:	e8 c5 fc ff ff       	call   105e80 <walkpgdir>
    if(pte && (*pte & PTE_P) != 0){
  1061bb:	85 c0                	test   %eax,%eax
  1061bd:	74 23                	je     1061e2 <deallocuvm+0x62>
  1061bf:	8b 10                	mov    (%eax),%edx
  1061c1:	f6 c2 01             	test   $0x1,%dl
  1061c4:	74 1c                	je     1061e2 <deallocuvm+0x62>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
  1061c6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  1061cc:	74 29                	je     1061f7 <deallocuvm+0x77>
        panic("kfree");
      kfree((char*)pa);
  1061ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1061d1:	89 14 24             	mov    %edx,(%esp)
  1061d4:	e8 47 c1 ff ff       	call   102320 <kfree>
      *pte = 0;
  1061d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1061dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
  1061e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  1061e8:	39 de                	cmp    %ebx,%esi
  1061ea:	77 c4                	ja     1061b0 <deallocuvm+0x30>
        panic("kfree");
      kfree((char*)pa);
      *pte = 0;
    }
  }
  return newsz;
  1061ec:	8b 45 10             	mov    0x10(%ebp),%eax
}
  1061ef:	83 c4 2c             	add    $0x2c,%esp
  1061f2:	5b                   	pop    %ebx
  1061f3:	5e                   	pop    %esi
  1061f4:	5f                   	pop    %edi
  1061f5:	5d                   	pop    %ebp
  1061f6:	c3                   	ret    
  for(; a  < oldsz; a += PGSIZE){
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(pte && (*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
  1061f7:	c7 04 24 8e 68 10 00 	movl   $0x10688e,(%esp)
  1061fe:	e8 ad a7 ff ff       	call   1009b0 <panic>
  106203:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  106209:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106210 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
  106210:	55                   	push   %ebp
  106211:	89 e5                	mov    %esp,%ebp
  106213:	56                   	push   %esi
  106214:	53                   	push   %ebx
  106215:	83 ec 10             	sub    $0x10,%esp
  106218:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint i;

  if(pgdir == 0)
  10621b:	85 db                	test   %ebx,%ebx
  10621d:	74 59                	je     106278 <freevm+0x68>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  10621f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  106226:	00 
  106227:	31 f6                	xor    %esi,%esi
  106229:	c7 44 24 04 00 00 0a 	movl   $0xa0000,0x4(%esp)
  106230:	00 
  106231:	89 1c 24             	mov    %ebx,(%esp)
  106234:	e8 47 ff ff ff       	call   106180 <deallocuvm>
  106239:	eb 10                	jmp    10624b <freevm+0x3b>
  10623b:	90                   	nop
  10623c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(i = 0; i < NPDENTRIES; i++){
  106240:	83 c6 01             	add    $0x1,%esi
  106243:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106249:	74 1f                	je     10626a <freevm+0x5a>
    if(pgdir[i] & PTE_P)
  10624b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  10624e:	a8 01                	test   $0x1,%al
  106250:	74 ee                	je     106240 <freevm+0x30>
      kfree((char*)PTE_ADDR(pgdir[i]));
  106252:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106257:	83 c6 01             	add    $0x1,%esi
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  10625a:	89 04 24             	mov    %eax,(%esp)
  10625d:	e8 be c0 ff ff       	call   102320 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
  106262:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  106268:	75 e1                	jne    10624b <freevm+0x3b>
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  10626a:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
  10626d:	83 c4 10             	add    $0x10,%esp
  106270:	5b                   	pop    %ebx
  106271:	5e                   	pop    %esi
  106272:	5d                   	pop    %ebp
  deallocuvm(pgdir, USERTOP, 0);
  for(i = 0; i < NPDENTRIES; i++){
    if(pgdir[i] & PTE_P)
      kfree((char*)PTE_ADDR(pgdir[i]));
  }
  kfree((char*)pgdir);
  106273:	e9 a8 c0 ff ff       	jmp    102320 <kfree>
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  106278:	c7 04 24 f0 6e 10 00 	movl   $0x106ef0,(%esp)
  10627f:	e8 2c a7 ff ff       	call   1009b0 <panic>
  106284:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  10628a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00106290 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
  106290:	55                   	push   %ebp
  106291:	89 e5                	mov    %esp,%ebp
  106293:	57                   	push   %edi
  106294:	56                   	push   %esi
  106295:	53                   	push   %ebx
  106296:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
  106299:	e8 b2 fd ff ff       	call   106050 <setupkvm>
  10629e:	85 c0                	test   %eax,%eax
  1062a0:	89 c6                	mov    %eax,%esi
  1062a2:	0f 84 84 00 00 00    	je     10632c <copyuvm+0x9c>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  1062a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062ab:	85 c0                	test   %eax,%eax
  1062ad:	74 7d                	je     10632c <copyuvm+0x9c>
  1062af:	31 db                	xor    %ebx,%ebx
  1062b1:	eb 47                	jmp    1062fa <copyuvm+0x6a>
  1062b3:	90                   	nop
  1062b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)pa, PGSIZE);
  1062b8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  1062be:	89 54 24 04          	mov    %edx,0x4(%esp)
  1062c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1062c9:	00 
  1062ca:	89 04 24             	mov    %eax,(%esp)
  1062cd:	e8 ae db ff ff       	call   103e80 <memmove>
    if(mappages(d, (void*)i, PGSIZE, PADDR(mem), PTE_W|PTE_U) < 0)
  1062d2:	b9 00 10 00 00       	mov    $0x1000,%ecx
  1062d7:	89 da                	mov    %ebx,%edx
  1062d9:	89 f0                	mov    %esi,%eax
  1062db:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  1062e2:	00 
  1062e3:	89 3c 24             	mov    %edi,(%esp)
  1062e6:	e8 e5 fc ff ff       	call   105fd0 <mappages>
  1062eb:	85 c0                	test   %eax,%eax
  1062ed:	78 33                	js     106322 <copyuvm+0x92>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
  1062ef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  1062f5:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
  1062f8:	76 32                	jbe    10632c <copyuvm+0x9c>
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
  1062fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1062fd:	31 c9                	xor    %ecx,%ecx
  1062ff:	89 da                	mov    %ebx,%edx
  106301:	e8 7a fb ff ff       	call   105e80 <walkpgdir>
  106306:	85 c0                	test   %eax,%eax
  106308:	74 2c                	je     106336 <copyuvm+0xa6>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
  10630a:	8b 10                	mov    (%eax),%edx
  10630c:	f6 c2 01             	test   $0x1,%dl
  10630f:	74 31                	je     106342 <copyuvm+0xb2>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
  106311:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  106314:	e8 c7 bf ff ff       	call   1022e0 <kalloc>
  106319:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10631c:	85 c0                	test   %eax,%eax
  10631e:	89 c7                	mov    %eax,%edi
  106320:	75 96                	jne    1062b8 <copyuvm+0x28>
      goto bad;
  }
  return d;

bad:
  freevm(d);
  106322:	89 34 24             	mov    %esi,(%esp)
  106325:	31 f6                	xor    %esi,%esi
  106327:	e8 e4 fe ff ff       	call   106210 <freevm>
  return 0;
}
  10632c:	83 c4 2c             	add    $0x2c,%esp
  10632f:	89 f0                	mov    %esi,%eax
  106331:	5b                   	pop    %ebx
  106332:	5e                   	pop    %esi
  106333:	5f                   	pop    %edi
  106334:	5d                   	pop    %ebp
  106335:	c3                   	ret    

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
      panic("copyuvm: pte should exist");
  106336:	c7 04 24 01 6f 10 00 	movl   $0x106f01,(%esp)
  10633d:	e8 6e a6 ff ff       	call   1009b0 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
  106342:	c7 04 24 1b 6f 10 00 	movl   $0x106f1b,(%esp)
  106349:	e8 62 a6 ff ff       	call   1009b0 <panic>
  10634e:	66 90                	xchg   %ax,%ax

00106350 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106350:	55                   	push   %ebp
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106351:	31 c0                	xor    %eax,%eax

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  106353:	89 e5                	mov    %esp,%ebp
  106355:	57                   	push   %edi
  106356:	56                   	push   %esi
  106357:	53                   	push   %ebx
  106358:	83 ec 2c             	sub    $0x2c,%esp
  10635b:	8b 75 10             	mov    0x10(%ebp),%esi
  10635e:	8b 7d 08             	mov    0x8(%ebp),%edi
  char *mem;
  uint a;

  if(newsz > USERTOP)
  106361:	81 fe 00 00 0a 00    	cmp    $0xa0000,%esi
  106367:	0f 87 8e 00 00 00    	ja     1063fb <allocuvm+0xab>
    return 0;
  if(newsz < oldsz)
    return oldsz;
  10636d:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *mem;
  uint a;

  if(newsz > USERTOP)
    return 0;
  if(newsz < oldsz)
  106370:	39 c6                	cmp    %eax,%esi
  106372:	0f 82 83 00 00 00    	jb     1063fb <allocuvm+0xab>
    return oldsz;

  a = PGROUNDUP(oldsz);
  106378:	89 c3                	mov    %eax,%ebx
  10637a:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  106380:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
  106386:	39 de                	cmp    %ebx,%esi
  106388:	77 47                	ja     1063d1 <allocuvm+0x81>
  10638a:	eb 7c                	jmp    106408 <allocuvm+0xb8>
  10638c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
  106390:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  106397:	00 
  106398:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10639f:	00 
  1063a0:	89 04 24             	mov    %eax,(%esp)
  1063a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1063a6:	e8 55 da ff ff       	call   103e00 <memset>
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  1063ab:	b9 00 10 00 00       	mov    $0x1000,%ecx
  1063b0:	89 f8                	mov    %edi,%eax
  1063b2:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
  1063b9:	00 
  1063ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1063bd:	89 14 24             	mov    %edx,(%esp)
  1063c0:	89 da                	mov    %ebx,%edx
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  1063c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  1063c8:	e8 03 fc ff ff       	call   105fd0 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
  1063cd:	39 de                	cmp    %ebx,%esi
  1063cf:	76 37                	jbe    106408 <allocuvm+0xb8>
    mem = kalloc();
  1063d1:	e8 0a bf ff ff       	call   1022e0 <kalloc>
    if(mem == 0){
  1063d6:	85 c0                	test   %eax,%eax
  1063d8:	75 b6                	jne    106390 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
  1063da:	c7 04 24 35 6f 10 00 	movl   $0x106f35,(%esp)
  1063e1:	e8 da a1 ff ff       	call   1005c0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
  1063e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  1063ed:	89 3c 24             	mov    %edi,(%esp)
  1063f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1063f4:	e8 87 fd ff ff       	call   106180 <deallocuvm>
  1063f9:	31 c0                	xor    %eax,%eax
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
}
  1063fb:	83 c4 2c             	add    $0x2c,%esp
  1063fe:	5b                   	pop    %ebx
  1063ff:	5e                   	pop    %esi
  106400:	5f                   	pop    %edi
  106401:	5d                   	pop    %ebp
  106402:	c3                   	ret    
  106403:	90                   	nop
  106404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  106408:	83 c4 2c             	add    $0x2c,%esp
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, PADDR(mem), PTE_W|PTE_U);
  }
  return newsz;
  10640b:	89 f0                	mov    %esi,%eax
}
  10640d:	5b                   	pop    %ebx
  10640e:	5e                   	pop    %esi
  10640f:	5f                   	pop    %edi
  106410:	5d                   	pop    %ebp
  106411:	c3                   	ret    
  106412:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  106419:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106420 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
  106420:	55                   	push   %ebp
  106421:	89 e5                	mov    %esp,%ebp
  106423:	57                   	push   %edi
  106424:	56                   	push   %esi
  106425:	53                   	push   %ebx
  106426:	83 ec 2c             	sub    $0x2c,%esp
  106429:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
  10642c:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
  106432:	0f 85 96 00 00 00    	jne    1064ce <loaduvm+0xae>
    panic("loaduvm: addr must be page aligned");
  106438:	8b 75 18             	mov    0x18(%ebp),%esi
  10643b:	31 db                	xor    %ebx,%ebx
  for(i = 0; i < sz; i += PGSIZE){
  10643d:	85 f6                	test   %esi,%esi
  10643f:	75 18                	jne    106459 <loaduvm+0x39>
  106441:	eb 75                	jmp    1064b8 <loaduvm+0x98>
  106443:	90                   	nop
  106444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  106448:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  10644e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  106454:	39 5d 18             	cmp    %ebx,0x18(%ebp)
  106457:	76 5f                	jbe    1064b8 <loaduvm+0x98>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
  106459:	8b 45 08             	mov    0x8(%ebp),%eax
  10645c:	31 c9                	xor    %ecx,%ecx
  10645e:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
  106461:	e8 1a fa ff ff       	call   105e80 <walkpgdir>
  106466:	85 c0                	test   %eax,%eax
  106468:	74 58                	je     1064c2 <loaduvm+0xa2>
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
  10646a:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
  106470:	ba 00 10 00 00       	mov    $0x1000,%edx
  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
  106475:	8b 00                	mov    (%eax),%eax
    if(sz - i < PGSIZE)
  106477:	0f 42 d6             	cmovb  %esi,%edx
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  10647a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10647e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  106481:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  106486:	89 44 24 04          	mov    %eax,0x4(%esp)
  10648a:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
  10648d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  106491:	8b 45 10             	mov    0x10(%ebp),%eax
  106494:	89 04 24             	mov    %eax,(%esp)
  106497:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10649a:	e8 51 af ff ff       	call   1013f0 <readi>
  10649f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1064a2:	39 d0                	cmp    %edx,%eax
  1064a4:	74 a2                	je     106448 <loaduvm+0x28>
      return -1;
  }
  return 0;
}
  1064a6:	83 c4 2c             	add    $0x2c,%esp
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
  1064a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return -1;
  }
  return 0;
}
  1064ae:	5b                   	pop    %ebx
  1064af:	5e                   	pop    %esi
  1064b0:	5f                   	pop    %edi
  1064b1:	5d                   	pop    %ebp
  1064b2:	c3                   	ret    
  1064b3:	90                   	nop
  1064b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1064b8:	83 c4 2c             	add    $0x2c,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
  1064bb:	31 c0                	xor    %eax,%eax
      n = PGSIZE;
    if(readi(ip, (char*)pa, offset+i, n) != n)
      return -1;
  }
  return 0;
}
  1064bd:	5b                   	pop    %ebx
  1064be:	5e                   	pop    %esi
  1064bf:	5f                   	pop    %edi
  1064c0:	5d                   	pop    %ebp
  1064c1:	c3                   	ret    

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
  1064c2:	c7 04 24 4d 6f 10 00 	movl   $0x106f4d,(%esp)
  1064c9:	e8 e2 a4 ff ff       	call   1009b0 <panic>
{
  uint i, pa, n;
  pte_t *pte;

  if((uint)addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  1064ce:	c7 04 24 80 6f 10 00 	movl   $0x106f80,(%esp)
  1064d5:	e8 d6 a4 ff ff       	call   1009b0 <panic>
  1064da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

001064e0 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  1064e0:	55                   	push   %ebp
  1064e1:	89 e5                	mov    %esp,%ebp
  1064e3:	53                   	push   %ebx
  1064e4:	83 ec 14             	sub    $0x14,%esp
  1064e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
  1064ea:	e8 81 d7 ff ff       	call   103c70 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
  1064ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  1064f5:	8d 50 08             	lea    0x8(%eax),%edx
  1064f8:	89 d1                	mov    %edx,%ecx
  1064fa:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
  106501:	c1 e9 10             	shr    $0x10,%ecx
  106504:	c1 ea 18             	shr    $0x18,%edx
  106507:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
  10650d:	c6 80 a5 00 00 00 99 	movb   $0x99,0xa5(%eax)
  106514:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  10651a:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
  106521:	67 00 
  106523:	c6 80 a6 00 00 00 40 	movb   $0x40,0xa6(%eax)
  cpu->gdt[SEG_TSS].s = 0;
  10652a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  106530:	80 a0 a5 00 00 00 ef 	andb   $0xef,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
  106537:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  10653d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  106543:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  106549:	8b 50 08             	mov    0x8(%eax),%edx
  10654c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  106552:	81 c2 00 10 00 00    	add    $0x1000,%edx
  106558:	89 50 0c             	mov    %edx,0xc(%eax)
}

static inline void
ltr(ushort sel)
{
  asm volatile("ltr %0" : : "r" (sel));
  10655b:	b8 30 00 00 00       	mov    $0x30,%eax
  106560:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
  106563:	8b 43 04             	mov    0x4(%ebx),%eax
  106566:	85 c0                	test   %eax,%eax
  106568:	74 0d                	je     106577 <switchuvm+0x97>
}

static inline void
lcr3(uint val) 
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
  10656a:	0f 22 d8             	mov    %eax,%cr3
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
}
  10656d:	83 c4 14             	add    $0x14,%esp
  106570:	5b                   	pop    %ebx
  106571:	5d                   	pop    %ebp
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  lcr3(PADDR(p->pgdir));  // switch to new address space
  popcli();
  106572:	e9 39 d7 ff ff       	jmp    103cb0 <popcli>
  cpu->gdt[SEG_TSS].s = 0;
  cpu->ts.ss0 = SEG_KDATA << 3;
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
  ltr(SEG_TSS << 3);
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
  106577:	c7 04 24 6b 6f 10 00 	movl   $0x106f6b,(%esp)
  10657e:	e8 2d a4 ff ff       	call   1009b0 <panic>
  106583:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  106589:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00106590 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once at boot time on each CPU.
void
seginit(void)
{
  106590:	55                   	push   %ebp
  106591:	89 e5                	mov    %esp,%ebp
  106593:	83 ec 18             	sub    $0x18,%esp

  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  106596:	e8 25 c0 ff ff       	call   1025c0 <cpunum>
  10659b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
  1065a1:	05 20 bb 10 00       	add    $0x10bb20,%eax
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  1065a6:	8d 90 b4 00 00 00    	lea    0xb4(%eax),%edx
  1065ac:	66 89 90 8a 00 00 00 	mov    %dx,0x8a(%eax)
  1065b3:	89 d1                	mov    %edx,%ecx
  1065b5:	c1 ea 18             	shr    $0x18,%edx
  1065b8:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)
  1065be:	c1 e9 10             	shr    $0x10,%ecx

  lgdt(c->gdt, sizeof(c->gdt));
  1065c1:	8d 50 70             	lea    0x70(%eax),%edx
  // Map virtual addresses to linear addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  1065c4:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
  1065ca:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
  1065d0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
  1065d4:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
  1065d8:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
  1065dc:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
  1065e0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
  1065e7:	ff ff 
  1065e9:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
  1065f0:	00 00 
  1065f2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
  1065f9:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
  106600:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
  106607:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
  10660e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
  106615:	ff ff 
  106617:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
  10661e:	00 00 
  106620:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
  106627:	c6 80 95 00 00 00 fa 	movb   $0xfa,0x95(%eax)
  10662e:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
  106635:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
  10663c:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
  106643:	ff ff 
  106645:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
  10664c:	00 00 
  10664e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
  106655:	c6 80 9d 00 00 00 f2 	movb   $0xf2,0x9d(%eax)
  10665c:	c6 80 9e 00 00 00 cf 	movb   $0xcf,0x9e(%eax)
  106663:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
  10666a:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
  106671:	00 00 
  106673:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
  106679:	c6 80 8d 00 00 00 92 	movb   $0x92,0x8d(%eax)
  106680:	c6 80 8e 00 00 00 c0 	movb   $0xc0,0x8e(%eax)
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  106687:	66 c7 45 f2 37 00    	movw   $0x37,-0xe(%ebp)
  pd[1] = (uint)p;
  10668d:	66 89 55 f4          	mov    %dx,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
  106691:	c1 ea 10             	shr    $0x10,%edx
  106694:	66 89 55 f6          	mov    %dx,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
  106698:	8d 55 f2             	lea    -0xe(%ebp),%edx
  10669b:	0f 01 12             	lgdtl  (%edx)
}

static inline void
loadgs(ushort v)
{
  asm volatile("movw %0, %%gs" : : "r" (v));
  10669e:	ba 18 00 00 00       	mov    $0x18,%edx
  1066a3:	8e ea                	mov    %edx,%gs

  lgdt(c->gdt, sizeof(c->gdt));
  loadgs(SEG_KCPU << 3);
  
  // Initialize cpu-local storage.
  cpu = c;
  1066a5:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
  1066ab:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
  1066b2:	00 00 00 00 
}
  1066b6:	c9                   	leave  
  1066b7:	c3                   	ret    
