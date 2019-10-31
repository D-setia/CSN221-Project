.data
	memory: .space 32
	length: .word 8
	start: .word 0
	gap: .word 7
	writeCount: .word 0
	phi: .word 1
	newLine: .asciiz "\n"
	
.text
	main:
		la $t0, memory   #save base address in $t0
		lw $t9, length   #load length of array in $t9
		lw $t8, phi
		lw $t7, start
		lw $t6, gap
		lw $t5, writeCount
		li $t4, 7 	#load MEMSIZE -1 in $t4
		
		jal initialiseArray
		
		li $s3, 35
		li $s4, 0
		
		mainLoop:
			div $s4, $t4
     			
     			mfhi $a0
     			mfhi $a1
     			jal memAccess
     			
     			jal printMemory
     			
     			addi $s4, $s4, 1
     			
     			blt $s4, $s3, mainLoop 
     			
     			
		#end program
		li $v0, 10
		syscall

	
	memAccess:
		addi $t5, $t5, 1
		div $t5, $t8
		mfhi $t3
		
		bnez $t3, case1
		bnez $t6, case2
		
		#start = (start + 1)%(MEMSIZE-1)
		addi $t7, $t7, 1
		div $t7, $t4
		mfhi $t7
		
		#memory[gap] = memory[MEMSIZE -1]
		lw $t3, 28($t0)
		move $t2, $t6
		sll $t2, $t2, 2
		add $t2, $t2, $t0
		sw $t3, ($t2)
		
		#gap = MEMSIZE - 1
		move $t6, $t4
		
		
		#memory[translate(logicalAddress)] = inp
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal translate
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		move $t2, $v0
		sll $t2, $t2, 2
		add $t2, $t2, $t0
		sw $a1, ($t2)
		
		j exitMemAccess
		
		case1:
			#memory[translate(logicalAddress)] = inp
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal translate
			lw $ra, 0($sp)
			addi $sp, $sp, 4
		
			move $t2, $v0
			sll $t2, $t2, 2
			add $t2, $t2, $t0
			sw $a1, ($t2)
			
			j exitMemAccess
		
		case2:
			#memory[gap] = memory[gap -1]
			move $t2, $t6
			subi $t2, $t2, 1
			sll $t2, $t2, 2
			add $t2, $t2, $t0
			lw $t3, ($t2)
			move $t2, $t6
			sll $t2, $t2, 2
			add $t2, $t2, $t0
			sw $t3, ($t2)
			
			#gap--
			subi $t6, $t6, 1
			
			
			#memory[translate(logicalAddress)] = inp
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal translate
			lw $ra, 0($sp)
			addi $sp, $sp, 4
		
			move $t2, $v0
			sll $t2, $t2, 2
			add $t2, $t2, $t0
			sw $a1, ($t2)
			
		
		exitMemAccess:
			jr $ra
	
	
	translate:
		add $v0, $a0, $t7
		div $v0, $t4
		
		mfhi $v0
		
		bge $v0, $t6, increasePhyAdd
		j exitTranslate
		
		increasePhyAdd:
			addi $v0, $v0, 1
		
		exitTranslate:
			jr $ra
	
	
	initialiseArray:
		li $s0, 0
		
		initLoop:
			mul $s1, $s0, 4
			add $t1, $t0, $s1
			sw $s0, ($t1)
			
			addi $s0, $s0, 1
			blt $s0, $t9, initLoop
			
		jr $ra
		
		
	printMemory:
		li $s0,0
		
		printLoop:
			mul $s1, $s0, 4
			add $t1, $t0, $s1
			lw $s2, ($t1)
			
			#print element
			li $v0, 1
			move $a0, $s2
			syscall
			
			#print newLIne
			li $v0, 4
			la $a0, newLine
			syscall
			
			addi $s0, $s0, 1
			blt $s0, $t9, printLoop
			
			
		#print newLIne
			li $v0, 4
			la $a0, newLine
			syscall
			
		jr $ra
