
.data
intro_msg:  .asciiz  "Arithmetic quiz:  enter each answer followed by a return.\n"
operators:     .byte  '+', '-', '*', '/'
operands:      .word  15, 4, -6, 12, 3
maxquestions:  .word  4   # constant -- number of questions in the quiz


# main program
.text
__start:   la   $t0, intro_msg
           puts $t0
	   li   $s0, 0    # $s0 is index into the array of operators
	   li   $s1, 0    # $s1 is index into the array of operands
	   li   $s2, 1    # $s2 is index into the array of operands
	   lw   $s3, maxquestions
           li   $s4, 0    # $s4 is the number of correct answers
main_loop:
           beq  $s0, $s3, no_more_questions
           # allocate space for parameters in AR for give_problem
           sub  $sp, $sp, 12   
           move $a0, $s0  # set up parameters for give_problem
           move $a1, $s1
           move $a2, $s2
           jal  give_problem

           # use return value from give_problem to calculate score
           add  $s4, $s4, $v0

           add  $s0, $s0, 1
           add  $s1, $s1, 1
           add  $s2, $s2, 1
           b    main_loop

no_more_questions:
           # allocate space for parameter in AR for print_summary
           sub  $sp, $sp, 4
           move $a0, $s4  # set up parameter for print_summary
           jal  print_summary
           done

