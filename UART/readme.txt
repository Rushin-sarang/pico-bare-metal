to do list uart

1) bring iobank out of reset
	- reset register addr = 0x4000c000
	  to clear bit5 we use atomic register so we need to
		set bit5 at addr + 0x3000 to deassert iobank

2) check if iobank is deasserted
	- reset register addr = 0x4000c000
	  offset of reset_done register = 0x8
	  check bit5 of this register if it set then reset is done
		if bit is not set check it again till it sets

3) first reset uart
	- reset register addr = 0x4000c000
	  to set bit 22 we use atomic register so we need to
		set bit22 at addr + 0x2000 to reset 
	
4) now bring uart out of reset
	- we need to clear atomic bit mask of reset
		we need to set bit22 at addr + 0x3000 to deassert uart0 reset

5) check if reset is deasserted
	- reset register addr = 0x4000c000
	  offset of reset_done register = 0x8
	  check bit22 of this register if it is set then reset is done
		if bit is not set check it again till it sets

6) set the peripheral clock crystal oscillator
	- clocks_base addr = 0x40008000
	  to set peripheral clock we need to access clk_peri_ctrl register 0x48 offset
		we need to set bit11 (enable) and bit7 (xosc_clksrc) to set crystal oscillator

7) enable uart receive and transmit
	- uart0_base addr = 0x40034000
	  to enable uart0 we need to access uart0_ctrl register (offset 0x030)
	   we need to set bit9 (to enblr rx) bit8(en tx) bit1 (to en whole uart0)
	
8) set baud rate of uart
	- uart0_base addr = 0x40034000
	  required baud rate : 115200
	  
	  baud rate divisor = peripheral clk / (16 * baudrate)
	  integer divisor = UARTIBRD
	  fractional divisor = UARTFBRD

	  periclk = 12 * 10^6
	  baudrate = req = 115200
	  so baudrate divisor = 6.51
	  interger divisor = 6 = UARTIBRD
	  fractional divisor = (.51 * 64) + 0.5 = 33 = UARTFBRD
	  
	  to set baudrate we need to access UARTIBRD and UARTFBRD registers
	  store value we get from calc of UARTIBRD to (base addr + 0x024)
	  store value we get from calc of UARTFBRD to (base addr + 0x028)
	
9)set word length
	- uart0_base addr = 0x40034000
	  to set word length we need to access UARTLCR_H (offset 0x02c)
		we need to set bit6-5 for word length 8bits
		we need to set bit4 to enable fifo
		
10) config gpio pins to use as uart
	- io0bank_base addr = 0x40014000
	  we are using gpio0 as uart tx and gpio1 as uart rx
		we need to store 2 in gpio0 (0x04) and in gpio1 (0x0c) to configure uart gpio

11) code input subroutine
	- uart0_base addr = 0x40034000
	  first we read flag reg (offset 0x018)
	  check if RX FIFO is empty(ie if bit4 is high or not), if it isn't we check again
	  if bit4 is high then,
		load uart data reg (offset 0x00) to r0

12) code output subroutine
	- uart0_base addr = 0x40034000
	  first we read flag reg (offset 0x018)
	  check if TX FIFO is full(ie if bit5 is high or not), if it isn't we check again
	  if bit5 is high then,
		we store data to uart data reg (offset 0x00)