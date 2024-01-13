.global start
start:
	ldr r0, =rst_clr 
	mov r1, #0x20 
	str r1, [r0, #0x0]
		
rst:
	ldr r0, =rst_done 
	ldr r1, [r0, #0x0] 
	mov r2, #0x20
	and r1,r1,r2
	beq rst
	
	ldr r0, =gp21_ctrl 
	mov r1, #5 
	str r1, [r0]
	ldr r0, =sio_base
	mov r1, #0x1
	lsl r1,r1, #21
	str r1, [r0, #0x20]
	
led_loop:
	str r1, [r0, #0x14]
	ldr r3, =big_num
	bl delay
	
	str r1, [r0, #0x18]
	ldr r3, =big_num
	bl delay
	
	b led_loop
	
delay:
	sub r3, #1
	bne delay
	bx lr
	
data:
	.equ rst_clr, 0x4000f000
	.equ rst_done, 0x4000c008
	.equ gp21_ctrl, 0x400140ac
	.equ sio_base, 0xd0000000
	.equ big_num, 0x00f00000