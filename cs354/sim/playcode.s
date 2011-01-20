# test to see the byte order when the simulator runs.

.data
x: .asciiz "Go Badgers\n"

.text
__start:  lw $8, x
          done
