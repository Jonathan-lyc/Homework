
bootother.o:     file format elf32-i386


Disassembly of section .text:

00000000 <start>:
#define CR0_PE    1

.code16           
.globl start
start:
  cli            
   0:	fa                   	cli    

  xorw    %ax,%ax
   1:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds
   3:	8e d8                	mov    %eax,%ds
  movw    %ax,%es
   5:	8e c0                	mov    %eax,%es
  movw    %ax,%ss
   7:	8e d0                	mov    %eax,%ss

  lgdt    gdtdesc
   9:	0f 01 16             	lgdtl  (%esi)
   c:	64 00 0f             	add    %cl,%fs:(%edi)
  movl    %cr0, %eax
   f:	20 c0                	and    %al,%al
  orl     $CR0_PE, %eax
  11:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
  15:	0f 22 c0             	mov    %eax,%cr0

  ljmp    $(SEG_KCODE<<3), $start32
  18:	ea 1d 00 08 00 66 b8 	ljmp   $0xb866,$0x8001d

0000001d <start32>:

.code32
start32:
  movw    $(SEG_KDATA<<3), %ax
  1d:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds
  21:	8e d8                	mov    %eax,%ds
  movw    %ax, %es
  23:	8e c0                	mov    %eax,%es
  movw    %ax, %ss
  25:	8e d0                	mov    %eax,%ss
  movw    $0, %ax
  27:	66 b8 00 00          	mov    $0x0,%ax
  movw    %ax, %fs
  2b:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs
  2d:	8e e8                	mov    %eax,%gs

  # switch to the stack allocated by bootothers()
  movl    start-4, %esp
  2f:	8b 25 fc ff ff ff    	mov    0xfffffffc,%esp

  # call mpmain()
  call	*(start-8)
  35:	ff 15 f8 ff ff ff    	call   *0xfffffff8

  movw    $0x8a00, %ax
  3b:	66 b8 00 8a          	mov    $0x8a00,%ax
  movw    %ax, %dx
  3f:	66 89 c2             	mov    %ax,%dx
  outw    %ax, %dx
  42:	66 ef                	out    %ax,(%dx)
  movw    $0x8ae0, %ax
  44:	66 b8 e0 8a          	mov    $0x8ae0,%ax
  outw    %ax, %dx
  48:	66 ef                	out    %ax,(%dx)

0000004a <spin>:
spin:
  jmp     spin
  4a:	eb fe                	jmp    4a <spin>

0000004c <gdt>:
	...
  54:	ff                   	(bad)  
  55:	ff 00                	incl   (%eax)
  57:	00 00                	add    %al,(%eax)
  59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
  60:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00000064 <gdtdesc>:
  64:	17                   	pop    %ss
  65:	00 4c 00 00          	add    %cl,0x0(%eax,%eax,1)
	...
