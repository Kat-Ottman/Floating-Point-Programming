			.text
			.align	2
			.global	main

/*
Dictionary:
x20		hit
x21		numDarts (iterations)
x22		float x
x23		float y
x24		counter
x25		projected pi
RAND_MAX = 2147483647, is an int
 */

 /* Print values
 			mov		x1,  x21					
			ldr		x0,  =test
			bl		printf

			fmov	d0,  d21					
			ldr		x0,  =test
			bl		printf
*/

Pi:			//finding approximation of pi based of hits and numDarts
			stp		x29, x30, [sp, -16] !
			scvtf	d3, x20						//convert hits into float for math
			scvtf	d4, x21						//convert numDarts into float for math
			fdiv	d0, d3, d4					//divide hits by numDarts, put in d0				
			fmov	d1, 4.0						//set up to multiply
			fmul	d25, d0, d1					//divide d0 by 4, put into d25
			ldp		x29, x30, [sp], 16
			ret

SquareRt:	//finding if point is within unit circle aka dart hit target
			stp		x29, x30, [sp, -16] !
			fmul	d1, d22, d22				//x*x, put into d1
			fmul	d0, d23, d23				//y*y, put into d0	
			fadd	d0, d0, d1					//add ^^
			fsqrt	d0, d0						//find sqrt
			fmov	d1, 1.0
			fcmp	d0, d1						//if sqrt >0
			bgt		1f							//go to 1 (forward)
			add		x20, x20, 1					//increment hits
1:			ldp		x29, x30, [sp], 16
			ret

Print:		//printing out values for user
			stp		x29, x30, [sp, -16] !
			mov		x1, x21						//setup for printing iterations
			ldr		x0, =exec
			bl		printf
			mov		x1, x20						//setup for printing hits
			ldr		x0, =hits
			bl		printf
			fmov	d0, d25						//setup for printing approximation of pi
			ldr		x0, =approx
			bl		printf
			ldp		x29, x30, [sp], 16
			ret

Randf:		//generating random number between 0 and 1
			stp		x29, x30, [sp, -16] !
			ldr		x0, =2147483647				//load RAND_MAX
			scvtf	d1, x0						//convert RAND_MAX to float
			bl		rand						//find random number and place in x0
			scvtf	d2, x0						//convert random number into float and place in
			fdiv	d0, d2, d1					//find float between 0 and 1
			ldp		x29, x30, [sp], 16
			ret

main:		//preserving registers & setting up numDarts
			stp		x29, x30, [sp, -16] !
			stp		x20, x21, [sp, -16] !
			stp		x22, x23, [sp, -16] !
			stp		x24, x25, [sp, -16] !

			mov		x21, x1						//move argv pointer to array into x21
			ldr		x21, [x21, 8]				//dereference to possible numDarts
			cbz		x21, Default				//check if argv[1] exists, else break to Bottom
			mov		x0,  x21					//set up for atoi
			bl		atoi 						//convert argv[1] to int
			//scvtf	d21, x0						//convert into to float and put in d21
			mov		x21, x0						//move atoi into x21
			
			mov		x0, xzr						//seed srand with time
			bl		time
			bl		srand 			

			bl		Top

Default:
			ldr		x21, =100000					//default numDarts
			//scvtf	d21, x0						//cast int to float and place in d21

Top:
			cmp		x24, x21					//compare counter with darts
			beq		Bottom						//if numDarts has been reached, go to Bottom

			bl		Randf						//generate x
			fmov	d22, d0						//move into d22
			bl		Randf						//generate y
			fmov	d23, d0						//move into d23
			bl		SquareRt					//see if dart hit target
			add		x24, x24, 1					//increment counter
			b		Top
					
Bottom:
			bl		Pi							//find value of pi approximation
			bl		Print						//print out values

			ldp		x24, x25, [sp], 16
			ldp		x22, x23, [sp], 16
			ldp		x20, x21, [sp], 16
			ldp		x29, x30, [sp], 16
			mov		x0, xzr
			ret

			.data

exec:		.asciz		"Executing: %d iterations. \n"
approx:		.asciz		"Approximation: %f \n"
hits:		.asciz		"Hits: %d \n"
test:		.asciz		"Testing: %f \n"

			.end