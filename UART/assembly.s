.global start
start:
	//bring iobank out of reset

	ldr r0, =reset_atomic_clr //atomic register for clearing reset (0x4000c000+0x3000) 
	mov r1, #0x20 //bitmask for bit5
	str r1, [r0]  //set bit5 at addr + 0x3000 to deaasert iobank

iobank_rst:
	// to check if iobank is deasserted

	ldr r0, =reset_base_reg //base reset addr
	mov r1, #0x20 
	ldr r2, [r0, #0x8] //reset_done reg value is stored in r2
	and r2, r2, r1 //isolate bit5 of reset_done reg
	beq iobank_rst //run loop again if reset is not cleared

reset_uart0:
    // to reset uart0

    ldr r0, =reset_atomic_set //atomic register for clearing reset (0x4000c000+0x2000)
    mov r1, #1
    lsl r1, r1, #22 //bitmask for bit22
    str r1, [r0] //set bit22 of reset reg using atomic reg

deassert_uart0_rst:
    //to bring uart0 out of reset
    ldr r0, =reset_atomic_clr 
    mov r1, #1
    lsl r1, r1, #22 //bitmask for bit22
    str r1, [r0] //set bit22 at addr + 0x3000 to deassert uart0 reset

rst_uart:
    //check if uart0 reset is desserte
    mov r2, r1 //copy r1 bitmask to r1
    ldr r0, =reset_base_reg
    ldr r1, [r0, #0x8] //load rst_clr reg into r1
    and r1, r1, r2
    beq rst_uart

set_peri_clk:
	// to set the peripheral clock, we are using crystal oscillator as peripheral clock
	ldr r0, =clk_peri_ctrl
	mov r1, #1
	lsl r1, r1, #11 //set bit11
	add r1, r1, #128 // adds bit7 so, bit11 and bit7 is set
	str r1, [r0] //stores bitmask into clk_peri_ctrl register 

enable_uart0:
	//to enable uart to recieve and transmit
	ldr r0, =uart0_ctrl_reg
	mov r1, #3
	lsl r1, r1, #8 //sets bit8 and bit9
	add r1, r1, #1 //adds bit1 so, bit1, bit8, bit9 is set
	str r1, [r0] //stores bitmask into uart0_ctrl_reg

set_baudrate:
	//to set baudrate of uart
	ldr r0, =UARTIBRD
	mov r1, #6
	str r1, [r0]  //stores 6 into UARTIBRD register
	ldr r0, =UARTFBRD
	mov r1, #33
	str r1, [r0] //stores 33 into UARTFBRD register

set_wordlength:
	//to set word length
	ldr r0, =UARTLCR_H
	mov r1, #112 //bitmask which sets bit4,5,6
	str r1, [r0] //stores our bitmask to set wordlength of 8 and enable fifo

config_gpio_pins:
	//to config gpio pins we are using as uart
	ldr r0, =GPIO0_CTRL
	mov r1, #2
	str r1, [r0] //stores 2 into gpio0 ctrl reg
	ldr r0, =GPIO1_CTRL
	mov r1, #2
	str r1, [r0] //stores 2 into gpio1 ctrl reg

loop:
	//our loop
	bl uart0_in
	bl uart0_out
	b loop

uart0_in:
	push {r1,r2,r3,lr}
uart0_in_loop:
	//input subroutine
	ldr r1, =uart0_base
	ldr r2, [r1, #0x018] //loads value of flag reg
	mov r3, #16 //bitmask for bit4
	and r2, r2, r3 
	bne uart0_in_loop //checks if bit4 is high or not
	ldr r0, [r1] //if bit4 is high then load uart data to r0
	pop {r1,r2,r3,pc} 

uart0_out:
	push {r1,r2,r3,lr}
uart0_out_loop:
	//output subroutine
	ldr r1, =uart0_base
	ldr r2, [r1, #0x018] //loads value of flag reg
	mov r3, #32 //bitmask for bit5
	and r2, r2, r3
	bne uart0_out_loop //checks if bit5 is high or not
	mov r2, #0xff //bitmask for 8 lowest bits
	and r0, r0, r2 //get rid of all except lowest 8 bits of data
	str r0, [r1] //store data into uart data reg
	pop {r1,r2,r3,pc}

    //address
data:
.equ reset_base_reg, 0x4000c000
.equ reset_atomic_clr, 0x4000f000
.equ reset_atomic_set, 0x4000e000
.equ clk_peri_ctrl, 0x40008048
.equ uart0_ctrl_reg, 0x40034030
.equ UARTIBRD, 0x40034024
.equ UARTFBRD, 0x40034028
.equ UARTLCR_H, 0x4003402c
.equ GPIO0_CTRL, 0x40014004
.equ GPIO1_CTRL, 0x4001400c
.equ uart0_base, 0x40034000