//assembly bare metal
.global start
start:
	//release peripheral reset for iobank0
	
	ldr r0, =rst_clr  //loads atomic register address to clear iobank0 bit into r0 register
	mov r1, #0x20  //load 1 to bit 5
	str r1, [r0, #0x0] //store bitmask to atomic register address to clear bit 5
	
	//check if reset is done
rst:
	ldr r0, =rst_done //loads reset_done register address into r0 register
	ldr r1, [r0, #0x0] //stores reset_done register value in r1 register
	mov r2, #0x20 //load 1 to bit 5
	and r1,r1,r2 //isolate bit 5 of reset_done register
	beq rst //if bit 5 is 0, which means reset is not done so control passes to rst label to again check if bit is 1 then we proceed further
	
	//setting up gpio register here we are using gpio21
	
	ldr r0, =gp21_ctrl //stores gpio21_ctrl register address into register 0
	mov r1, #5 //decimal 5 to select sio in ctrl register
	str r1, [r0] //store decimal 5 in ctrl register to configure gpio21 as sio 
	ldr r0, =sio_base //loads sio_base address into register r0
	mov r1, #0x1 // load 1 in r1 register
	lsl r1,r1, #21 //move bit over to align with gpio21
	str r1, [r0, #0x20] //offset 0x20 so it makes it output_enable register, we store r1(bit21) to make gpio21 as output pin
	
	//loop to blink led connected to gp21
	
led_loop:
	str r1, [r0, #0x14] //offset 0x14 so it makes it output_set register, we store r1(bit21) to set gpio21 pin
	ldr r3, =big_num //loads countdown number
	bl delay //calls delay subroutine
	
	str r1, [r0, #0x18] //offset 0x18 so it makes it output_clr register, we store r1(bit21) to clear gpio21 pin
	ldr r3, =big_num //loads countdown number
	bl delay //calls delay subroutine
	
	b led_loop //calls led_loop again
	
delay:
	sub r3, #1 //substract 1 from register 3
	bne delay //loop back to delay if not zero
	bx lr //return from subroutine
	
data:
	.equ rst_clr, 0x4000f000 //atomic register address to clear iobank0 bit of reset_base register 0x4000c000 + 0x3000
	
	.equ rst_done, 0x4000c008 //reset_done register address to check if reset bit is cleared or not
	
	.equ gp21_ctrl, 0x400140ac //gp21_ctrl register address to set gp2 as sio
	
	.equ sio_base, 0xd0000000 //sio_base register address
	
	.equ big_num, 0x00f00000 //big number
