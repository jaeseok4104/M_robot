
;CodeVisionAVR C Compiler V2.05.0 Professional
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega128
;Program type             : Application
;Clock frequency          : 14.745600 MHz
;Memory model             : Small
;Optimize for             : Size
;(s)printf features       : float, width, precision
;(s)scanf features        : long, width
;External RAM size        : 0
;Data Stack size          : 1024 byte(s)
;Heap size                : 0 byte(s)
;Promote 'char' to 'int'  : Yes
;'char' is unsigned       : Yes
;8 bit enums              : No
;global 'const' stored in FLASH: Yes
;Enhanced core instructions    : On
;Smart register allocation     : On
;Automatic register allocation : On

	#pragma AVRPART ADMIN PART_NAME ATmega128
	#pragma AVRPART MEMORY PROG_FLASH 131072
	#pragma AVRPART MEMORY EEPROM 4096
	#pragma AVRPART MEMORY INT_SRAM SIZE 4351
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU RAMPZ=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU XMCRA=0x6D
	.EQU XMCRB=0x6C

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x10FF
	.EQU __DSTACK_SIZE=0x0400
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _hall_sensor_detection1
	JMP  _hall_sensor_detection2
	JMP  _hall_sensor_detection3
	JMP  _hall_sensor_detection4
	JMP  _timer2_comp
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer0_comp
	JMP  0x00
	JMP  0x00
	JMP  _timer0_ovf
	JMP  0x00
	JMP  _usart0_rxc
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _usart1_rxc
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

_0x3:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0
_0x0:
	.DB  0x3C,0x25,0x64,0x3E,0x0,0x25,0x2E,0x33
	.DB  0x66,0x2C,0x20,0x25,0x2E,0x33,0x66,0xA
	.DB  0x0
_0x80003:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
_0x2000000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0
_0x2080060:
	.DB  0x1
_0x2080000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x01
	.DW  __seed_G104
	.DW  _0x2080060*2

_0xFFFFFFFF:
	.DW  0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30
	STS  XMCRB,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

	OUT  RAMPZ,R24

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x500

	.CSEG
;#include <mega128.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif
;#include <stdio.h>
;#include <delay.h>
;#include <math.h>
;
;#include "TIMER.h"
;#include "RTU_USART.h"
;#include "ext_int.h"
;
;#define PREDICTION 0.3
;unsigned char TIMER2_OVERFLOW = 0;
;unsigned char PACKET_BUFF[100] = {0,};
;unsigned char PACKET_BUFF_IDX = 0;
;
;unsigned int TIMER0_OVERFLOW = 0;
;unsigned char VELOCITY_BUFF[20] = {0,};
;unsigned char VELOCITY_BUFF_IDX = 0;
;unsigned char CHECK_GETS = 0;
;
;long int TIMER1_OVERFLOW = 0;
;
;long int MOTORR_HALL = 0;
;long int MOTORL_HALL = 0;
;
;void main(void)
; 0000 001A {

	.CSEG
_main:
; 0000 001B     float a_buff;
; 0000 001C     float v_buff;
; 0000 001D 
; 0000 001E     int velocity = 0;
; 0000 001F     int angularV = 0;
; 0000 0020     int velocity_R = 0;
; 0000 0021     int velocity_L = 0;
; 0000 0022     int del_ms = 0;
; 0000 0023     float del_s = 0;
; 0000 0024     float diameter = 0;
; 0000 0025     int d_diameter = 0;
; 0000 0026 
; 0000 0027     int currentRPM_R = 0;
; 0000 0028     int currentRPM_L = 0;
; 0000 0029     float currentV_R = 0;
; 0000 002A     float currentV_L = 0;
; 0000 002B     int goal_current_R = 0;
; 0000 002C     int goal_current_L = 0;
; 0000 002D     float goal_currentV_R = 0;
; 0000 002E     float goal_currentV_L = 0;
; 0000 002F 
; 0000 0030 
; 0000 0031     float d_velocity = 0;
; 0000 0032     float d_angularV = 0;
; 0000 0033     float control_time = 0;
; 0000 0034     float g_velocity = 0;
; 0000 0035     float g_angularV = 0;
; 0000 0036 
; 0000 0037     float d_x = 0;
; 0000 0038     float d_y = 0;
; 0000 0039     float d_angular = 0;
; 0000 003A     int d_angular_circula = 0;
; 0000 003B     float g_x = 0;
; 0000 003C     float g_y = 0;
; 0000 003D     float g_angular = 0;
; 0000 003E     int g_angular_circula = 0;
; 0000 003F 
; 0000 0040     float TIMER1_TIME = 0;
; 0000 0041     float TIMER0_TIME = 0;
; 0000 0042     float TIMER0_TIME_print = 0;
; 0000 0043 
; 0000 0044     char rootine_test = 0;
; 0000 0045     char STOP_FLAG = 0;
; 0000 0046 
; 0000 0047 
; 0000 0048     float hall_x = 0;
; 0000 0049     float hall_y = 0;
; 0000 004A     float hall_angular = 0;
; 0000 004B     int hall_angular_circula = 0;
; 0000 004C     float hall_velocity = 0;
; 0000 004D 
; 0000 004E     float motorR_distance = 0;
; 0000 004F     float motorL_distance = 0;
; 0000 0050     float a = 0;
; 0000 0051 
; 0000 0052     unsigned char BUFF[500] = {0,};
; 0000 0053 
; 0000 0054     usart1_init(bps_115200);
	SBIW R28,63
	SBIW R28,63
	SUBI R29,2
	__GETWRN 24,25,630
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0x3*2)
	LDI  R31,HIGH(_0x3*2)
	CALL __INITLOCW
;	a_buff -> Y+634
;	v_buff -> Y+630
;	velocity -> R16,R17
;	angularV -> R18,R19
;	velocity_R -> R20,R21
;	velocity_L -> Y+628
;	del_ms -> Y+626
;	del_s -> Y+622
;	diameter -> Y+618
;	d_diameter -> Y+616
;	currentRPM_R -> Y+614
;	currentRPM_L -> Y+612
;	currentV_R -> Y+608
;	currentV_L -> Y+604
;	goal_current_R -> Y+602
;	goal_current_L -> Y+600
;	goal_currentV_R -> Y+596
;	goal_currentV_L -> Y+592
;	d_velocity -> Y+588
;	d_angularV -> Y+584
;	control_time -> Y+580
;	g_velocity -> Y+576
;	g_angularV -> Y+572
;	d_x -> Y+568
;	d_y -> Y+564
;	d_angular -> Y+560
;	d_angular_circula -> Y+558
;	g_x -> Y+554
;	g_y -> Y+550
;	g_angular -> Y+546
;	g_angular_circula -> Y+544
;	TIMER1_TIME -> Y+540
;	TIMER0_TIME -> Y+536
;	TIMER0_TIME_print -> Y+532
;	rootine_test -> Y+531
;	STOP_FLAG -> Y+530
;	hall_x -> Y+526
;	hall_y -> Y+522
;	hall_angular -> Y+518
;	hall_angular_circula -> Y+516
;	hall_velocity -> Y+512
;	motorR_distance -> Y+508
;	motorL_distance -> Y+504
;	a -> Y+500
;	BUFF -> Y+0
	__GETWRN 16,17,0
	__GETWRN 18,19,0
	__GETWRN 20,21,0
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	ST   -Y,R31
	ST   -Y,R30
	CALL _usart1_init
; 0000 0055     usart0_init(bps_115200);
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	ST   -Y,R31
	ST   -Y,R30
	CALL _usart0_init
; 0000 0056     timer2_init();
	RCALL _timer2_init
; 0000 0057     timer0_init();
	RCALL _timer0_init
; 0000 0058     timer1_init();
	RCALL _timer1_init
; 0000 0059     EXT_INT_init();
	CALL _EXT_INT_init
; 0000 005A     SREG |= 0x80;
	BSET 7
; 0000 005B     DDRB.1 = 1;
	SBI  0x17,1
; 0000 005C     DDRB.2 = 1;
	SBI  0x17,2
; 0000 005D     DDRB.3 = 1;
	SBI  0x17,3
; 0000 005E     delay_ms(5000);
	LDI  R30,LOW(5000)
	LDI  R31,HIGH(5000)
	CALL SUBOPT_0x0
; 0000 005F 
; 0000 0060     TIMER0_OVERFLOW = 0;
	CALL SUBOPT_0x1
; 0000 0061     TCNT0 = 0;
; 0000 0062 
; 0000 0063     while(1)
_0xA:
; 0000 0064     {
; 0000 0065         if(CHECK_GETS)
	LDS  R30,_CHECK_GETS
	CPI  R30,0
	BRNE PC+3
	JMP _0xD
; 0000 0066         {
; 0000 0067             UCSR1B &= ~(1<<RXEN1);
	LDS  R30,154
	ANDI R30,0xEF
	STS  154,R30
; 0000 0068             // sscanf(VELOCITY_BUFF,"<%d,%d,%d>", &velocity, &angularV, &del_ms);
; 0000 0069             sscanf(VELOCITY_BUFF,"<%d>", &d_diameter);
	LDI  R30,LOW(_VELOCITY_BUFF)
	LDI  R31,HIGH(_VELOCITY_BUFF)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,0
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	SUBI R30,LOW(-(620))
	SBCI R31,HIGH(-(620))
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	LDI  R24,4
	CALL _sscanf
	ADIW R28,8
; 0000 006A             if(!del_ms){
	__GETW1SX 626
	SBIW R30,0
	BRNE _0xE
; 0000 006B                 d_x = 0;
	LDI  R30,LOW(0)
	__CLRD1SX 568
; 0000 006C                 d_y = 0;
	__CLRD1SX 564
; 0000 006D                 d_angular = 0;
	__CLRD1SX 560
; 0000 006E             }
; 0000 006F 
; 0000 0070             if(d_diameter>0){
_0xE:
	__GETW2SX 616
	CALL __CPW02
	BRGE _0xF
; 0000 0071                 diameter = (float)(((float)d_diameter/100));
	CALL SUBOPT_0x2
; 0000 0072                 if((float)(MOTOR_CONT_MAX_SPEED*MOTOR_DRIVE_CEL_TIME)<diameter)
	CALL SUBOPT_0x3
	CALL __CMPF12
	BRSH _0x10
; 0000 0073                 {
; 0000 0074                     del_s = (float)((diameter + (MOTOR_DRIVE_CEL_TIME*MOTOR_CONT_MAX_SPEED))/MOTOR_CONT_MAX_SPEED);
	CALL SUBOPT_0x4
	CALL SUBOPT_0x5
; 0000 0075                     del_s -= MOTOR_DRIVE_CEL_TIME;
	RJMP _0x18
; 0000 0076                 }
; 0000 0077                 else del_s = (float)(((MOTOR_DRIVE_CEL_TIME*MOTOR_CONT_MAX_SPEED)+diameter)/MOTOR_CONT_MAX_SPEED);
_0x10:
	CALL SUBOPT_0x4
_0x18:
	__PUTD1SX 622
; 0000 0078                 del_ms = (int)(del_s*1000);
	CALL SUBOPT_0x6
; 0000 0079                 v_buff = MOTOR_CONT_MAX_SPEED;
	CALL SUBOPT_0x7
	RJMP _0x19
; 0000 007A 
; 0000 007B                 // v_buff = (float)velocity/1000;
; 0000 007C                 a_buff = (float)angularV/1000;
; 0000 007D             }
; 0000 007E             else{
_0xF:
; 0000 007F                 diameter = (float)(((float)d_diameter/100));
	CALL SUBOPT_0x2
; 0000 0080                 diameter = -diameter;
	CALL __ANEGF1
	__PUTD1SX 618
; 0000 0081                 if((float)(MOTOR_CONT_MAX_SPEED*MOTOR_DRIVE_CEL_TIME)<diameter)
	CALL SUBOPT_0x3
	CALL __CMPF12
	BRSH _0x13
; 0000 0082                 {
; 0000 0083                     del_s = (float)((diameter + (MOTOR_DRIVE_CEL_TIME*MOTOR_CONT_MAX_SPEED))/MOTOR_CONT_MAX_SPEED);
	CALL SUBOPT_0x4
	CALL SUBOPT_0x5
; 0000 0084                     del_s -= MOTOR_DRIVE_CEL_TIME;
	RJMP _0x1A
; 0000 0085                 }
; 0000 0086                 else del_s = (float)(((MOTOR_DRIVE_CEL_TIME*MOTOR_CONT_MAX_SPEED)+diameter)/MOTOR_CONT_MAX_SPEED);
_0x13:
	CALL SUBOPT_0x4
_0x1A:
	__PUTD1SX 622
; 0000 0087                 del_ms = (int)(del_s*1000);
	CALL SUBOPT_0x6
; 0000 0088                 v_buff = -MOTOR_CONT_MAX_SPEED;
	__GETD1N 0xBF000000
_0x19:
	__PUTD1SX 630
; 0000 0089 
; 0000 008A                 // v_buff = (float)velocity/1000;
; 0000 008B                 a_buff = (float)angularV/1000;
	MOVW R30,R18
	CALL SUBOPT_0x8
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x447A0000
	CALL __DIVF21
	__PUTD1SX 634
; 0000 008C             }
; 0000 008D 
; 0000 008E             TIMER0_TIME_print = 0;
	LDI  R30,LOW(0)
	__CLRD1SX 532
; 0000 008F             Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);
	MOVW R30,R28
	SUBI R30,LOW(-(630))
	SBCI R31,HIGH(-(630))
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	SUBI R30,LOW(-(636))
	SBCI R31,HIGH(-(636))
	ST   -Y,R31
	ST   -Y,R30
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R21
	PUSH R20
	MOVW R30,R28
	SUBI R30,LOW(-(634))
	SBCI R31,HIGH(-(634))
	ST   -Y,R31
	ST   -Y,R30
	CALL _Make_MSPEED
	POP  R20
	POP  R21
; 0000 0090 
; 0000 0091             oper_Disapath(velocity_R, velocity_L);
	ST   -Y,R21
	ST   -Y,R20
	__GETW1SX 630
	ST   -Y,R31
	ST   -Y,R30
	CALL _oper_Disapath
; 0000 0092 
; 0000 0093             TIMER1_TIME = 0;
	LDI  R30,LOW(0)
	__CLRD1SX 540
; 0000 0094             TIMER1_OVERFLOW = 0;
	CALL SUBOPT_0x9
; 0000 0095             TCNT1L = 0;
	OUT  0x2C,R30
; 0000 0096 
; 0000 0097             // rootine_test = 1;
; 0000 0098             STOP_FLAG = 1;
	LDI  R30,LOW(1)
	__PUTB1SX 530
; 0000 0099             CHECK_GETS = 0;
	LDI  R30,LOW(0)
	STS  _CHECK_GETS,R30
; 0000 009A             UCSR1B |=(1<<RXEN1);
	LDS  R30,154
	ORI  R30,0x10
	STS  154,R30
; 0000 009B         }
; 0000 009C 
; 0000 009D         // if(rootine_test == 0)
; 0000 009E         // {
; 0000 009F         //     v_buff = 0.15;
; 0000 00A0         //     a_buff = 0;
; 0000 00A1         //     if(d_x<0.95)
; 0000 00A2         //     {
; 0000 00A3         //         Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);
; 0000 00A4         //         oper_Disapath(velocity_R,velocity_L);
; 0000 00A5         //         STOP_FLAG = 1;
; 0000 00A6         //     }
; 0000 00A7         //     else{
; 0000 00A8         //         if(STOP_FLAG) a = TIMER0_TIME_print;
; 0000 00A9         //         if(TIMER0_TIME_print > a+2) rootine_test = 1;
; 0000 00AA         //         oper_Disapath(0,0);
; 0000 00AB         //         STOP_FLAG = 0;
; 0000 00AC         //     }
; 0000 00AD         // }
; 0000 00AE         // else if(rootine_test == 1)
; 0000 00AF         // {
; 0000 00B0         //     v_buff = 0;
; 0000 00B1         //     a_buff = -0.7;
; 0000 00B2         //     if(d_angular_circula<85)
; 0000 00B3         //     {
; 0000 00B4         //         Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);
; 0000 00B5         //         oper_Disapath(velocity_R,velocity_L);
; 0000 00B6         //         STOP_FLAG = 1;
; 0000 00B7         //     }
; 0000 00B8         //     else{
; 0000 00B9         //         if(STOP_FLAG) a = TIMER0_TIME_print;
; 0000 00BA         //         if(TIMER0_TIME_print > a+2) rootine_test = 2;
; 0000 00BB         //         oper_Disapath(0,0);
; 0000 00BC         //         STOP_FLAG = 0;
; 0000 00BD         //     }
; 0000 00BE         // }
; 0000 00BF         // else if(rootine_test == 2)
; 0000 00C0         // {
; 0000 00C1         //     v_buff = 0.15;
; 0000 00C2         //     a_buff = 0;
; 0000 00C3         //     if(d_y<0.95)
; 0000 00C4         //     {
; 0000 00C5         //         Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);
; 0000 00C6         //         oper_Disapath(velocity_R,velocity_L);
; 0000 00C7         //         STOP_FLAG = 1;
; 0000 00C8         //     }
; 0000 00C9         //     else{
; 0000 00CA         //         if(STOP_FLAG) a = TIMER0_TIME_print;
; 0000 00CB         //         if(TIMER0_TIME_print > a+2) rootine_test = 3;
; 0000 00CC         //         oper_Disapath(0,0);
; 0000 00CD         //         STOP_FLAG = 0;
; 0000 00CE         //     }
; 0000 00CF         // }
; 0000 00D0 
; 0000 00D1         TIMER1_TIME = (float)(TIMER1_OVERFLOW*255 +(int)TCNT1L)*0.0694444;
_0xD:
	LDS  R30,_TIMER1_OVERFLOW
	LDS  R31,_TIMER1_OVERFLOW+1
	LDS  R22,_TIMER1_OVERFLOW+2
	LDS  R23,_TIMER1_OVERFLOW+3
	__GETD2N 0xFF
	CALL __MULD12
	MOVW R26,R30
	MOVW R24,R22
	IN   R30,0x2C
	LDI  R31,0
	CALL __CWD1
	CALL __ADDD12
	CALL __CDF1
	__GETD2N 0x3D8E38DE
	CALL __MULF12
	__PUTD1SX 540
; 0000 00D2 
; 0000 00D3         if(del_ms<TIMER1_TIME)
	__GETW2SX 626
	CALL __CWD2
	CALL __CDF2
	CALL __CMPF12
	BRSH _0x15
; 0000 00D4         {
; 0000 00D5             oper_Disapath(0,0);
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R31
	ST   -Y,R30
	CALL _oper_Disapath
; 0000 00D6             TIMER1_OVERFLOW = 0;
	CALL SUBOPT_0x9
; 0000 00D7             v_buff = 0;
	__CLRD1SX 630
; 0000 00D8             a_buff = 0;
	LDI  R30,LOW(0)
	__CLRD1SX 634
; 0000 00D9             STOP_FLAG = 0;
	__PUTB1SX 530
; 0000 00DA         }
; 0000 00DB         // if(goal_currentV_R==0 && goal_currentV_L==0) TIMER0_TIME_print = 0;
; 0000 00DC 
; 0000 00DD         // delay_ms(5);
; 0000 00DE         // RTU_ReedOperate0(R, (unsigned int)2 ,(unsigned int)2);
; 0000 00DF         // delay_ms(5);
; 0000 00E0         // currentRPM_R = get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_R);
; 0000 00E1         // RTU_ReedOperate0(L, (unsigned int)2 ,(unsigned int)2);
; 0000 00E2         // delay_ms(5);
; 0000 00E3         // currentRPM_L = -get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_L);
; 0000 00E4 
; 0000 00E5         // // currentV_R = (float)(currentRPM_R/(60/(Pi*0.125)*Gearratio));
; 0000 00E6         // // currentV_L = (float)(currentRPM_L/(60/(Pi*0.125)*Gearratio));
; 0000 00E7 
; 0000 00E8         // // goal_currentV_R = (float)(goal_current_R/(60/(Pi*0.125)*Gearratio));
; 0000 00E9         // // goal_currentV_L = (float)(-goal_current_L/(60/(Pi*0.125)*Gearratio));
; 0000 00EA 
; 0000 00EB         // d_velocity = (currentV_R + currentV_L)/2;
; 0000 00EC         // d_angularV = (currentV_R-currentV_L)/Length;
; 0000 00ED         // g_velocity = (goal_currentV_R+goal_currentV_L)/2;
; 0000 00EE         // g_angularV = (goal_currentV_R-goal_currentV_L)/Length;
; 0000 00EF 
; 0000 00F0         control_time = ((TIMER0_OVERFLOW)*255 + TCNT0)*0.0000694444;
_0x15:
	LDS  R26,_TIMER0_OVERFLOW
	LDS  R27,_TIMER0_OVERFLOW+1
	LDI  R30,LOW(255)
	CALL __MULB1W2U
	MOVW R26,R30
	IN   R30,0x32
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	CLR  R22
	CLR  R23
	CALL __CDF1
	__GETD2N 0x3891A2AE
	CALL __MULF12
	__PUTD1SX 580
; 0000 00F1         TIMER0_OVERFLOW = 0;
	CALL SUBOPT_0x1
; 0000 00F2         TCNT0 = 0;
; 0000 00F3 
; 0000 00F4         // d_angular += control_time*d_angularV;
; 0000 00F5         // d_x += d_velocity*control_time*cos(d_angular);
; 0000 00F6         // d_y += d_velocity*control_time*sin(d_angular);
; 0000 00F7         // d_angular_circula = (int)(d_angular*Circular);
; 0000 00F8 
; 0000 00F9         // g_angular += control_time*g_angularV;
; 0000 00FA         // g_x += g_velocity*control_time*cos(g_angular);
; 0000 00FB         // g_y += g_velocity*control_time*sin(g_angular);
; 0000 00FC         // g_angular_circula = (int)(g_angular*Circular);
; 0000 00FD 
; 0000 00FE         // motorR_distance = (float)(MOTORR_HALL*0.1325*Pi/160);
; 0000 00FF         // motorL_distance = (float)(MOTORL_HALL*0.1325*Pi/160);
; 0000 0100         motorR_distance = (float)(MOTORR_HALL*0.4/160);
	LDS  R30,_MOTORR_HALL
	LDS  R31,_MOTORR_HALL+1
	LDS  R22,_MOTORR_HALL+2
	LDS  R23,_MOTORR_HALL+3
	CALL SUBOPT_0xA
	__PUTD1SX 508
; 0000 0101         motorL_distance = (float)(MOTORL_HALL*0.4/160);
	LDS  R30,_MOTORL_HALL
	LDS  R31,_MOTORL_HALL+1
	LDS  R22,_MOTORL_HALL+2
	LDS  R23,_MOTORL_HALL+3
	CALL SUBOPT_0xA
	__PUTD1SX 504
; 0000 0102 
; 0000 0103         TIMER0_TIME += control_time;
	__GETD1SX 580
	CALL SUBOPT_0xB
	CALL __ADDF12
	__PUTD1SX 536
; 0000 0104         if(TIMER0_TIME>0.01){
	CALL SUBOPT_0xB
	__GETD1N 0x3C23D70A
	CALL __CMPF12
	BREQ PC+2
	BRCC PC+3
	JMP  _0x16
; 0000 0105             TIMER0_TIME_print += TIMER0_TIME;
	CALL SUBOPT_0xC
	__GETD2SX 532
	CALL __ADDF12
	__PUTD1SX 532
; 0000 0106             MOTORR_HALL = 0;
	LDI  R30,LOW(0)
	STS  _MOTORR_HALL,R30
	STS  _MOTORR_HALL+1,R30
	STS  _MOTORR_HALL+2,R30
	STS  _MOTORR_HALL+3,R30
; 0000 0107             MOTORL_HALL = 0;
	STS  _MOTORL_HALL,R30
	STS  _MOTORL_HALL+1,R30
	STS  _MOTORL_HALL+2,R30
	STS  _MOTORL_HALL+3,R30
; 0000 0108 
; 0000 0109             hall_velocity = (float)((motorR_distance+motorL_distance)/(2*TIMER0_TIME));
	CALL SUBOPT_0xD
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0xC
	__GETD2N 0x40000000
	CALL __MULF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __DIVF21
	__PUTD1SX 512
; 0000 010A             hall_angular += (float)((motorR_distance-motorL_distance)/Length);
	__GETD2SX 504
	__GETD1SX 508
	CALL __SUBF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x3E8ED917
	CALL __DIVF21
	CALL SUBOPT_0xE
	CALL __ADDF12
	__PUTD1SX 518
; 0000 010B             hall_x += (float)((motorR_distance+motorL_distance)/2)*cos(hall_angular);
	CALL SUBOPT_0xD
	CALL SUBOPT_0xF
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x10
	CALL _cos
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __MULF12
	__GETD2SX 526
	CALL __ADDF12
	__PUTD1SX 526
; 0000 010C             hall_y += (float)((motorR_distance+motorL_distance)/2)*sin(hall_angular);
	CALL SUBOPT_0xD
	CALL SUBOPT_0xF
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x10
	CALL _sin
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __MULF12
	__GETD2SX 522
	CALL __ADDF12
	__PUTD1SX 522
; 0000 010D             hall_angular_circula = (int)(hall_angular*Circular);
	CALL SUBOPT_0xE
	__GETD1N 0x426528F6
	CALL SUBOPT_0x11
	__PUTW1SX 516
; 0000 010E             // sprintf(BUFF, "%f, %f, %f, %f\n", d_velocity, v_buff, d_angularV, a_buff);
; 0000 010F             // sprintf(BUFF, "%f, %f\n", currentV_L*control_time, motorL_distance);
; 0000 0110             // sprintf(BUFF, "%d, %d, %d\n", velocity, current_R, current_L);
; 0000 0111             // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f, %.3f, %d, %d\n", TIMER0_TIME_print, d_x, hall_x, d_y, hall_y, d_angular_circula, hall_angular_circula);
; 0000 0112             // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f, %4d, %4d, %.3f\n", d_x, hall_x, d_y, hall_y, d_angular_circula, hall_angular_circula, TIMER0_TIME_print);
; 0000 0113             // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f \n",TIMER0_TIME_print, g_velocity, d_velocity, hall_velocity);
; 0000 0114             // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f, %.3f, %d\n",TIMER0_TIME_print,g_velocity, hall_velocity, g_x, hall_x, del_ms);
; 0000 0115             // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f\n",TIMER0_TIME_print,g_velocity, d_velocity, hall_velocity,);
; 0000 0116             // sprintf(BUFF, "%.3f, %d, %d\n", TIMER0_TIME_print, MOTORR_HALL, MOTORL_HALL);
; 0000 0117             sprintf(BUFF, "%.3f, %.3f\n", TIMER0_TIME_print, hall_x);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,5
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0xC
	CALL __PUTPARD1
	__GETD1SX 534
	CALL __PUTPARD1
	LDI  R24,8
	CALL _sprintf
	ADIW R28,12
; 0000 0118 
; 0000 0119             // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f\n", d_velocity, g_velocity, v_buff, TIMER0_TIME_print);
; 0000 011A             // sprintf(BUFF, "%d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f\n", currentRPM_R, -currentRPM_L, goal_current_R, goal_current_L,
; 0000 011B             //                                                   currentV_R, currentV_L, goal_currentV_R, goal_currentV_L,
; 0000 011C             //                                                   d_velocity, g_velocity, d_x, g_x, TIMER0_TIME_print);
; 0000 011D             // sprintf(BUFF, "%d, %d, %d, %d\n", currentRPM_R, -currentRPM_L, goal_current_R, goal_current_L);
; 0000 011E             // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f\n", currentV_R, -currentV_L, v_buff, -_buff);
; 0000 011F             puts_USART1(BUFF);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	CALL _puts_USART1
; 0000 0120             TIMER0_TIME = 0;
	LDI  R30,LOW(0)
	__CLRD1SX 536
; 0000 0121         }
; 0000 0122     }
_0x16:
	RJMP _0xA
; 0000 0123 }
_0x17:
	RJMP _0x17
;#include <mega128.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif
;#include <stdio.h>
;#include <delay.h>
;#include <math.h>
;
;#include "TIMER.h"
;#include "RTU_USART.h"
;
;interrupt [TIM2_COMP] void timer2_comp(void)
; 0001 000A {

	.CSEG
_timer2_comp:
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
; 0001 000B     TIMER2_OVERFLOW++;
	LDS  R30,_TIMER2_OVERFLOW
	SUBI R30,-LOW(1)
	STS  _TIMER2_OVERFLOW,R30
; 0001 000C }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	RETI
;
;interrupt [TIM0_OVF] void timer0_ovf(void)
; 0001 000F {
_timer0_ovf:
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0001 0010     TIMER0_OVERFLOW++;
	LDI  R26,LOW(_TIMER0_OVERFLOW)
	LDI  R27,HIGH(_TIMER0_OVERFLOW)
	CALL SUBOPT_0x12
; 0001 0011 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
;
;
;interrupt [TIM1_COMPB] void timer0_comp(void)
; 0001 0015 {
_timer0_comp:
	CALL SUBOPT_0x13
; 0001 0016     TIMER1_OVERFLOW++;
	LDI  R26,LOW(_TIMER1_OVERFLOW)
	LDI  R27,HIGH(_TIMER1_OVERFLOW)
	CALL SUBOPT_0x14
; 0001 0017     TCNT1H = 0x00;
	LDI  R30,LOW(0)
	OUT  0x2D,R30
; 0001 0018     TCNT1L = 0x00;
	OUT  0x2C,R30
; 0001 0019 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R23,Y+
	LD   R22,Y+
	RETI
;
;void timer2_init(void)
; 0001 001C {
_timer2_init:
; 0001 001D     //TIMER2
; 0001 001E     TCCR2 = (1<<WGM21)|(1<<CS22)|(1<<CS20);// CTC모드, 1024분주
	LDI  R30,LOW(13)
	OUT  0x25,R30
; 0001 001F 
; 0001 0020     OCR2 = 40;
	LDI  R30,LOW(40)
	OUT  0x23,R30
; 0001 0021     TIMSK = (1<<OCIE2)|(1<<OCIE0);
	LDI  R30,LOW(130)
	RJMP _0x20A000E
; 0001 0022     //TIMSK = (1<<OCIE2);
; 0001 0023 }
;void timer0_init(void)
; 0001 0025 {
_timer0_init:
; 0001 0026     TCCR0 = (1<<CS02)|(1<<CS01)|(1<<CS00); // CTC모드, 1024분주
	LDI  R30,LOW(7)
	OUT  0x33,R30
; 0001 0027     TIMSK = (1<<OCIE2)|(1<<TOIE0);
	LDI  R30,LOW(129)
	RJMP _0x20A000E
; 0001 0028 }
;
;void timer1_init(void)
; 0001 002B {
_timer1_init:
; 0001 002C     // TCCR1A = (1<<COM1B0);
; 0001 002D     TCCR1B = (1<<WGM13)|(1<<WGM12)|(1<<CS12)|(1<<CS10);; // WGM bit setting
	LDI  R30,LOW(29)
	OUT  0x2E,R30
; 0001 002E 
; 0001 002F     OCR1B = 255;
	LDI  R30,LOW(255)
	LDI  R31,HIGH(255)
	OUT  0x28+1,R31
	OUT  0x28,R30
; 0001 0030     ICR1 = 1200;
	LDI  R30,LOW(1200)
	LDI  R31,HIGH(1200)
	OUT  0x26+1,R31
	OUT  0x26,R30
; 0001 0031     TIMSK |= (1<<OCIE1B);
	IN   R30,0x37
	ORI  R30,8
_0x20A000E:
	OUT  0x37,R30
; 0001 0032 }
	RET
;#include <mega128.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif
;#include <stdio.h>
;#include <delay.h>
;#include <math.h>
;
;#include "TIMER.h"
;#include "RTU_USART.h"
;
;interrupt [USART0_RXC] void usart0_rxc(void)
; 0002 000A {

	.CSEG
_usart0_rxc:
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
; 0002 000B     if(((TCNT2 < CHARACTER3_5) && (TIMER2_OVERFLOW == 0)) || PACKET_BUFF_IDX == 0)
	IN   R30,0x24
	CPI  R30,LOW(0x19)
	BRSH _0x40004
	LDS  R26,_TIMER2_OVERFLOW
	CPI  R26,LOW(0x0)
	BREQ _0x40006
_0x40004:
	LDS  R26,_PACKET_BUFF_IDX
	CPI  R26,LOW(0x0)
	BRNE _0x40003
_0x40006:
; 0002 000C     {
; 0002 000D         PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
	CALL SUBOPT_0x15
; 0002 000E         PACKET_BUFF_IDX++;
; 0002 000F         TCNT2 = 0;
; 0002 0010     }
; 0002 0011     else {
	RJMP _0x40008
_0x40003:
; 0002 0012         PACKET_BUFF_IDX = 0;
	LDI  R30,LOW(0)
	STS  _PACKET_BUFF_IDX,R30
; 0002 0013         PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
	CALL SUBOPT_0x15
; 0002 0014         PACKET_BUFF_IDX++;
; 0002 0015         TCNT2 = 0;
; 0002 0016         TIMER2_OVERFLOW = 0;
	LDI  R30,LOW(0)
	STS  _TIMER2_OVERFLOW,R30
; 0002 0017     }
_0x40008:
; 0002 0018 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
;
;interrupt [USART1_RXC] void usart1_rxc(void)
; 0002 001B {
_usart1_rxc:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0002 001C     unsigned char i = 0;
; 0002 001D     i = UDR1;
	ST   -Y,R17
;	i -> R17
	LDI  R17,0
	LDS  R17,156
; 0002 001E     if((i == '<') && (CHECK_GETS == 0)){
	CPI  R17,60
	BRNE _0x4000A
	LDS  R26,_CHECK_GETS
	CPI  R26,LOW(0x0)
	BREQ _0x4000B
_0x4000A:
	RJMP _0x40009
_0x4000B:
; 0002 001F         PORTB.3 = ~PORTB.3;
	SBIS 0x18,3
	RJMP _0x4000C
	CBI  0x18,3
	RJMP _0x4000D
_0x4000C:
	SBI  0x18,3
_0x4000D:
; 0002 0020         VELOCITY_BUFF_IDX = 0;
	LDI  R30,LOW(0)
	STS  _VELOCITY_BUFF_IDX,R30
; 0002 0021         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
	RJMP _0x40041
; 0002 0022         VELOCITY_BUFF_IDX++;
; 0002 0023     }
; 0002 0024     else if(i == '>' && (CHECK_GETS == 0)){
_0x40009:
	CPI  R17,62
	BRNE _0x40010
	LDS  R26,_CHECK_GETS
	CPI  R26,LOW(0x0)
	BREQ _0x40011
_0x40010:
	RJMP _0x4000F
_0x40011:
; 0002 0025         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
	LDS  R30,_VELOCITY_BUFF_IDX
	CALL SUBOPT_0x16
; 0002 0026         VELOCITY_BUFF_IDX++;
; 0002 0027         CHECK_GETS = 1;
	LDI  R30,LOW(1)
	STS  _CHECK_GETS,R30
; 0002 0028     }
; 0002 0029     else if(CHECK_GETS == 0){
	RJMP _0x40012
_0x4000F:
	LDS  R30,_CHECK_GETS
	CPI  R30,0
	BRNE _0x40013
; 0002 002A         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
_0x40041:
	LDS  R30,_VELOCITY_BUFF_IDX
	CALL SUBOPT_0x16
; 0002 002B         VELOCITY_BUFF_IDX++;
; 0002 002C     }
; 0002 002D }
_0x40013:
_0x40012:
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
;
;void usart1_init(int bps)
; 0002 0030 {
_usart1_init:
; 0002 0031     UCSR1A = 0x00;
;	bps -> Y+0
	LDI  R30,LOW(0)
	STS  155,R30
; 0002 0032     UCSR1B = (1<<RXEN1)|(1<<TXEN1)|(1<<RXCIE1); // RXCIE1 bit is recevie interrupt allow
	LDI  R30,LOW(152)
	STS  154,R30
; 0002 0033     UCSR1C = (1<<UCSZ11)|(1<<UCSZ10);
	LDI  R30,LOW(6)
	STS  157,R30
; 0002 0034     UCSR1C &= ~(1<<UMSEL1);
	LDS  R30,157
	ANDI R30,0xBF
	STS  157,R30
; 0002 0035 
; 0002 0036     UBRR1H = (unsigned char)((bps>>8)  & 0x00ff);
	LD   R30,Y
	LDD  R31,Y+1
	CALL __ASRW8
	STS  152,R30
; 0002 0037     UBRR1L = (unsigned char)(bps & 0x00ff);
	LD   R30,Y
	STS  153,R30
; 0002 0038 }
	RJMP _0x20A000D
;
;void usart0_init(int bps)
; 0002 003B {
_usart0_init:
; 0002 003C     UCSR0A = 0x00;
;	bps -> Y+0
	LDI  R30,LOW(0)
	OUT  0xB,R30
; 0002 003D     UCSR0B = (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0); // RXCIE1 bit is recevie interrupt allow
	LDI  R30,LOW(152)
	OUT  0xA,R30
; 0002 003E     UCSR0C = (1<<UCSZ01)|(1<<UCSZ00);
	LDI  R30,LOW(6)
	STS  149,R30
; 0002 003F     UCSR0C &= ~(1<<UMSEL0);
	LDS  R30,149
	ANDI R30,0xBF
	STS  149,R30
; 0002 0040 
; 0002 0041     UBRR0H = (unsigned char)((bps>>8)  & 0x00ff);
	LD   R30,Y
	LDD  R31,Y+1
	CALL __ASRW8
	STS  144,R30
; 0002 0042     UBRR0L = (unsigned char)(bps & 0x00ff);
	LD   R30,Y
	OUT  0x9,R30
; 0002 0043 }
_0x20A000D:
	ADIW R28,2
	RET
;
;void putch_USART1(char data)
; 0002 0046 {
_putch_USART1:
; 0002 0047     while(!(UCSR1A & (1<<UDRE1))); // UDRE flag is USART Data Register Empty
;	data -> Y+0
_0x40014:
	LDS  R30,155
	ANDI R30,LOW(0x20)
	BREQ _0x40014
; 0002 0048     UDR1 = data;
	LD   R30,Y
	STS  156,R30
; 0002 0049 }
	RJMP _0x20A000C
;
;void puts_USART1(char *str)
; 0002 004C {
_puts_USART1:
; 0002 004D     unsigned char i = 0;
; 0002 004E     unsigned char x = 0;
; 0002 004F     for(i = 0; str[i] ;i++){
	ST   -Y,R17
	ST   -Y,R16
;	*str -> Y+2
;	i -> R17
;	x -> R16
	LDI  R17,0
	LDI  R16,0
	LDI  R17,LOW(0)
_0x40018:
	CALL SUBOPT_0x17
	CPI  R30,0
	BREQ _0x40019
; 0002 0050         putch_USART1(str[i]);
	CALL SUBOPT_0x17
	ST   -Y,R30
	RCALL _putch_USART1
; 0002 0051     }
	SUBI R17,-1
	RJMP _0x40018
_0x40019:
; 0002 0052     for(x = 0; x<i; x++){
	LDI  R16,LOW(0)
_0x4001B:
	CP   R16,R17
	BRSH _0x4001C
; 0002 0053         *(str++) = 0;
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,1
	STD  Y+2,R26
	STD  Y+2+1,R27
	SBIW R26,1
	LDI  R30,LOW(0)
	ST   X,R30
; 0002 0054     }
	SUBI R16,-1
	RJMP _0x4001B
_0x4001C:
; 0002 0055 }
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20A000B
;
;void puts_Modbus1(char *str,char IDX)
; 0002 0058 {
; 0002 0059     unsigned char i = 0;
; 0002 005A     UCSR0B &= ~(1<<RXEN0);
;	*str -> Y+2
;	IDX -> Y+1
;	i -> R17
; 0002 005B     if(TIMER2_OVERFLOW>0)
; 0002 005C     {
; 0002 005D         for(i = 0;i<IDX;i++) putch_USART1(*(str+i));
; 0002 005E for(i = 0; i<IDX; i++) *(str+i) = 0;
; 0002 005F }
; 0002 0060     UCSR0B |= (1<<RXEN0);
; 0002 0061 }
;
;void putch_USART0(char data)
; 0002 0064 {
_putch_USART0:
; 0002 0065     while(!(UCSR0A & (1<<UDRE0))); // UDRE flag is USART Data Register Empty
;	data -> Y+0
_0x40024:
	SBIS 0xB,5
	RJMP _0x40024
; 0002 0066     UDR0 = data;
	LD   R30,Y
	OUT  0xC,R30
; 0002 0067 }
_0x20A000C:
	ADIW R28,1
	RET
;
;unsigned short CRC16(unsigned char *puchMsg, int usDataLen)
; 0002 006A {
_CRC16:
; 0002 006B     int i;
; 0002 006C     unsigned short crc, flag;
; 0002 006D     crc = 0xffff;
	CALL __SAVELOCR6
;	*puchMsg -> Y+8
;	usDataLen -> Y+6
;	i -> R16,R17
;	crc -> R18,R19
;	flag -> R20,R21
	__GETWRN 18,19,-1
; 0002 006E 
; 0002 006F     while(usDataLen--){
_0x40027:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SBIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	ADIW R30,1
	BREQ _0x40029
; 0002 0070         crc ^= *puchMsg++;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LD   R30,X+
	STD  Y+8,R26
	STD  Y+8+1,R27
	LDI  R31,0
	__EORWRR 18,19,30,31
; 0002 0071 
; 0002 0072         for (i=0; i<8; i++){
	__GETWRN 16,17,0
_0x4002B:
	__CPWRN 16,17,8
	BRGE _0x4002C
; 0002 0073             flag = crc & 0x0001;
	MOVW R30,R18
	ANDI R30,LOW(0x1)
	ANDI R31,HIGH(0x1)
	MOVW R20,R30
; 0002 0074             crc >>= 1;
	LSR  R19
	ROR  R18
; 0002 0075             if(flag) crc ^= POLYNORMIAL;
	MOV  R0,R20
	OR   R0,R21
	BREQ _0x4002D
	LDI  R30,LOW(40961)
	LDI  R31,HIGH(40961)
	__EORWRR 18,19,30,31
; 0002 0076         }
_0x4002D:
	__ADDWRN 16,17,1
	RJMP _0x4002B
_0x4002C:
; 0002 0077     }
	RJMP _0x40027
_0x40029:
; 0002 0078     return crc;
	MOVW R30,R18
	CALL __LOADLOCR6
	ADIW R28,10
	RET
; 0002 0079 }
;
;int RTU_WriteOperate0(char device_address,int starting_address,int data)
; 0002 007C {
_RTU_WriteOperate0:
; 0002 007D     char protocol[8];
; 0002 007E     unsigned short crc16;
; 0002 007F     int i=0;
; 0002 0080     //PACKET_BUFF_IDX = 0;
; 0002 0081 
; 0002 0082     protocol[0]=device_address;
	SBIW R28,8
	CALL __SAVELOCR4
;	device_address -> Y+16
;	starting_address -> Y+14
;	data -> Y+12
;	protocol -> Y+4
;	crc16 -> R16,R17
;	i -> R18,R19
	__GETWRN 18,19,0
	LDD  R30,Y+16
	STD  Y+4,R30
; 0002 0083     protocol[1]=0x06;
	LDI  R30,LOW(6)
	STD  Y+5,R30
; 0002 0084     protocol[2]=((starting_address>>8)  & 0x00ff);
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	CALL __ASRW8
	STD  Y+6,R30
; 0002 0085     protocol[3]=((starting_address)     & 0x00ff);
	LDD  R30,Y+14
	STD  Y+7,R30
; 0002 0086     protocol[4]=((data>>8)              & 0x00ff);
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	CALL __ASRW8
	STD  Y+8,R30
; 0002 0087     protocol[5]=((data)                 & 0x00ff);
	LDD  R30,Y+12
	STD  Y+9,R30
; 0002 0088     protocol[6]=0;
	LDI  R30,LOW(0)
	STD  Y+10,R30
; 0002 0089     protocol[7]=0;
	STD  Y+11,R30
; 0002 008A 
; 0002 008B     crc16 = CRC16(protocol, 6);
	MOVW R30,R28
	ADIW R30,4
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(6)
	LDI  R31,HIGH(6)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _CRC16
	MOVW R16,R30
; 0002 008C 
; 0002 008D     protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
	MOVW R30,R16
	STD  Y+10,R30
; 0002 008E     protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
	__PUTBSR 17,11
; 0002 008F 
; 0002 0090 
; 0002 0091     for(i=0;i<8;i++)
	__GETWRN 18,19,0
_0x4002F:
	__CPWRN 18,19,8
	BRGE _0x40030
; 0002 0092     {
; 0002 0093         putch_USART0(*(protocol+i));
	MOVW R26,R28
	ADIW R26,4
	ADD  R26,R18
	ADC  R27,R19
	LD   R30,X
	ST   -Y,R30
	RCALL _putch_USART0
; 0002 0094     }
	__ADDWRN 18,19,1
	RJMP _0x4002F
_0x40030:
; 0002 0095 }
	CALL __LOADLOCR4
	ADIW R28,17
	RET
;
;int RTU_ReedOperate0(char device_address,int starting_address,int data)
; 0002 0098 {
; 0002 0099     char protocol[8];
; 0002 009A     unsigned short crc16;
; 0002 009B     int i=0;
; 0002 009C     //PACKET_BUFF_IDX = 0;
; 0002 009D 
; 0002 009E     protocol[0]=device_address;
;	device_address -> Y+16
;	starting_address -> Y+14
;	data -> Y+12
;	protocol -> Y+4
;	crc16 -> R16,R17
;	i -> R18,R19
; 0002 009F     protocol[1]=0x04;
; 0002 00A0     protocol[2]=((starting_address>>8)  & 0x00ff);
; 0002 00A1     protocol[3]=((starting_address)     & 0x00ff);
; 0002 00A2     protocol[4]=((data>>8)              & 0x00ff);
; 0002 00A3     protocol[5]=((data)                 & 0x00ff);
; 0002 00A4     protocol[6]=0;
; 0002 00A5     protocol[7]=0;
; 0002 00A6 
; 0002 00A7     crc16 = CRC16(protocol, 6);
; 0002 00A8 
; 0002 00A9     protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
; 0002 00AA     protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
; 0002 00AB 
; 0002 00AC 
; 0002 00AD     for(i=0;i<8;i++)
; 0002 00AE     {
; 0002 00AF         putch_USART0(*(protocol+i));
; 0002 00B0     }
; 0002 00B1 }
;
;void Make_MSPEED(float* _velocity, float* _angularV, int* R_RPM, int* L_RPM)
; 0002 00B4 {
_Make_MSPEED:
; 0002 00B5     float VelocityR = 0;
; 0002 00B6     float VelocityL = 0;
; 0002 00B7 
; 0002 00B8     if(*_velocity>=0){
	SBIW R28,8
	CALL SUBOPT_0x18
	LDI  R30,LOW(0)
	STD  Y+2,R30
	STD  Y+3,R30
	STD  Y+4,R30
	STD  Y+5,R30
	STD  Y+6,R30
	STD  Y+7,R30
;	*_velocity -> Y+14
;	*_angularV -> Y+12
;	*R_RPM -> Y+10
;	*L_RPM -> Y+8
;	VelocityR -> Y+4
;	VelocityL -> Y+0
	CALL SUBOPT_0x19
	TST  R23
	BRMI _0x40034
; 0002 00B9         *_angularV = -(*_angularV);
	CALL SUBOPT_0x1A
	CALL __ANEGF1
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL __PUTDP1
; 0002 00BA     }
; 0002 00BB 
; 0002 00BC     VelocityR = *_velocity+(*_angularV*Length)/2;
_0x40034:
	CALL SUBOPT_0x19
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x1B
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDF12
	CALL SUBOPT_0x1C
; 0002 00BD     VelocityL = *_velocity-(*_angularV*Length)/2;
	CALL SUBOPT_0x19
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x1B
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL SUBOPT_0x1D
	CALL __PUTD1S0
; 0002 00BE 
; 0002 00BF     *R_RPM = (int)(VelocityR*(60/(0.4)*Gearratio));
	CALL SUBOPT_0x1E
	CALL SUBOPT_0x1F
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ST   X+,R30
	ST   X,R31
; 0002 00C0     *L_RPM = (int)(VelocityL*(60/(0.4)*Gearratio));
	CALL __GETD2S0
	CALL SUBOPT_0x1F
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ST   X+,R30
	ST   X,R31
; 0002 00C1 
; 0002 00C2     if( ((*R_RPM<300)&&(*R_RPM>-300))&&((*L_RPM<300)&&(*L_RPM>-300))){
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __GETW1P
	CPI  R30,LOW(0x12C)
	LDI  R26,HIGH(0x12C)
	CPC  R31,R26
	BRGE _0x40036
	MOVW R26,R30
	LDI  R30,LOW(65236)
	LDI  R31,HIGH(65236)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x40037
_0x40036:
	RJMP _0x40038
_0x40037:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	CPI  R30,LOW(0x12C)
	LDI  R26,HIGH(0x12C)
	CPC  R31,R26
	BRGE _0x40039
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	MOVW R26,R30
	LDI  R30,LOW(65236)
	LDI  R31,HIGH(65236)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x4003A
_0x40039:
	RJMP _0x40038
_0x4003A:
	RJMP _0x4003B
_0x40038:
	RJMP _0x40035
_0x4003B:
; 0002 00C3         *R_RPM = 0;
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL SUBOPT_0x20
; 0002 00C4         *L_RPM = 0;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL SUBOPT_0x20
; 0002 00C5     }
; 0002 00C6 }
_0x40035:
	JMP  _0x20A000A
;
;void oper_Disapath(int velocity_R, int velocity_L)
; 0002 00C9 {
_oper_Disapath:
; 0002 00CA     RTU_WriteOperate0(R,(unsigned int)121,(int)(velocity_R));
;	velocity_R -> Y+2
;	velocity_L -> Y+0
	LDI  R30,LOW(1)
	ST   -Y,R30
	LDI  R30,LOW(121)
	LDI  R31,HIGH(121)
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+5
	LDD  R31,Y+5+1
	CALL SUBOPT_0x21
; 0002 00CB     delay_ms(1);
; 0002 00CC 
; 0002 00CD     RTU_WriteOperate0(L,(unsigned int)121,(int)-(velocity_L));
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(121)
	LDI  R31,HIGH(121)
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+3
	LDD  R31,Y+3+1
	CALL __ANEGW1
	CALL SUBOPT_0x21
; 0002 00CE     delay_ms(1);
; 0002 00CF 
; 0002 00D0     RTU_WriteOperate0(R,(unsigned int)120,(int)(START));
	LDI  R30,LOW(1)
	CALL SUBOPT_0x22
; 0002 00D1     delay_ms(1);
; 0002 00D2 
; 0002 00D3     RTU_WriteOperate0(L,(unsigned int)120,(int)(START));
	LDI  R30,LOW(2)
	CALL SUBOPT_0x22
; 0002 00D4     delay_ms(1);
; 0002 00D5 }
_0x20A000B:
	ADIW R28,4
	RET
;
;int get_RPM(char *str,char IDX, int* goal)
; 0002 00D8 {
; 0002 00D9     unsigned char i = 0;
; 0002 00DA     unsigned int RPM = 0;
; 0002 00DB 
; 0002 00DC     if(PACKET_BUFF[1]!=0x07){
;	*str -> Y+7
;	IDX -> Y+6
;	*goal -> Y+4
;	i -> R17
;	RPM -> R18,R19
; 0002 00DD         RPM = (int)(PACKET_BUFF[5] << 8)+ (int)(PACKET_BUFF[6]);
; 0002 00DE         *goal = (int)(PACKET_BUFF[3] << 8) + (int)(PACKET_BUFF[4]);
; 0002 00DF         for(i = 0; i<IDX; i++) *(str+i) = 0;
; 0002 00E0 if(RPM == -1)RPM = 0;
; 0002 00E1         return RPM;
; 0002 00E2     }
; 0002 00E3 }
;#include "ext_int.h"
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif
;////2채배
;void EXT_INT_init(void)
; 0003 0004 {

	.CSEG
_EXT_INT_init:
; 0003 0005     EICRB = (1<<ISC50)|(1<<ISC60)|(1<<ISC70)|(1<<ISC40);
	LDI  R30,LOW(85)
	OUT  0x3A,R30
; 0003 0006     EIMSK = (1<<INT4)|(1<<INT5)|(1<<INT6)|(1<<INT7);
	LDI  R30,LOW(240)
	OUT  0x39,R30
; 0003 0007 
; 0003 0008     DDRE.4 = 0;
	CBI  0x2,4
; 0003 0009     DDRE.5 = 0;
	CBI  0x2,5
; 0003 000A     DDRE.6 = 0;
	CBI  0x2,6
; 0003 000B     DDRE.7 = 0;
	CBI  0x2,7
; 0003 000C }
	RET
;
;interrupt [EXT_INT4] void hall_sensor_detection1(void)
; 0003 000F {
_hall_sensor_detection1:
	CALL SUBOPT_0x23
; 0003 0010     if(RHALL_A != RHALL_B) MOTORR_HALL++;
	BREQ _0x6000B
	LDI  R26,LOW(_MOTORR_HALL)
	LDI  R27,HIGH(_MOTORR_HALL)
	CALL SUBOPT_0x14
	SBIW R30,1
	SBCI R22,0
	SBCI R23,0
; 0003 0011     else MOTORR_HALL--;
	RJMP _0x6000C
_0x6000B:
	CALL SUBOPT_0x24
; 0003 0012 }
_0x6000C:
	RJMP _0x60013
;
;interrupt [EXT_INT5] void hall_sensor_detection2(void)
; 0003 0015 {
_hall_sensor_detection2:
	CALL SUBOPT_0x23
; 0003 0016     if(RHALL_A != RHALL_B) MOTORR_HALL--;
	BREQ _0x6000D
	CALL SUBOPT_0x24
; 0003 0017     else MOTORR_HALL++;
	RJMP _0x6000E
_0x6000D:
	LDI  R26,LOW(_MOTORR_HALL)
	LDI  R27,HIGH(_MOTORR_HALL)
	CALL SUBOPT_0x14
	SBIW R30,1
	SBCI R22,0
	SBCI R23,0
; 0003 0018 }
_0x6000E:
	RJMP _0x60013
;
;interrupt [EXT_INT6] void hall_sensor_detection3(void)
; 0003 001B {
_hall_sensor_detection3:
	CALL SUBOPT_0x13
; 0003 001C     if(LHALL_B != LHALL_A) MOTORL_HALL--;
	LDI  R26,0
	SBIC 0x1,6
	LDI  R26,1
	LDI  R30,0
	SBIC 0x1,7
	LDI  R30,1
	CP   R30,R26
	BREQ _0x6000F
	CALL SUBOPT_0x25
; 0003 001D     else MOTORL_HALL++;
	RJMP _0x60010
_0x6000F:
	LDI  R26,LOW(_MOTORL_HALL)
	LDI  R27,HIGH(_MOTORL_HALL)
	CALL SUBOPT_0x14
	SBIW R30,1
	SBCI R22,0
	SBCI R23,0
; 0003 001E }
_0x60010:
	RJMP _0x60013
;
;interrupt [EXT_INT7] void hall_sensor_detection4(void)
; 0003 0021 {
_hall_sensor_detection4:
	CALL SUBOPT_0x13
; 0003 0022     if(LHALL_A != LHALL_B) MOTORL_HALL++;
	LDI  R26,0
	SBIC 0x1,7
	LDI  R26,1
	LDI  R30,0
	SBIC 0x1,6
	LDI  R30,1
	CP   R30,R26
	BREQ _0x60011
	LDI  R26,LOW(_MOTORL_HALL)
	LDI  R27,HIGH(_MOTORL_HALL)
	CALL SUBOPT_0x14
	SBIW R30,1
	SBCI R22,0
	SBCI R23,0
; 0003 0023     else MOTORL_HALL--;
	RJMP _0x60012
_0x60011:
	CALL SUBOPT_0x25
; 0003 0024 }
_0x60012:
_0x60013:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R23,Y+
	LD   R22,Y+
	RETI
;#include <PID_controller.h>
;
;int PID_Controller(int Goal, float now, float* integral, float* Err_previous)
; 0004 0004 {

	.CSEG
; 0004 0005     long int pErr = 0;
; 0004 0006     float dErr = 0;
; 0004 0007     long int MV = 0;
; 0004 0008     float Err = 0;
; 0004 0009     unsigned char BUFF[128]={0,};
; 0004 000A 
; 0004 000B     Err = Goal - now; //ERROR
;	Goal -> Y+152
;	now -> Y+148
;	*integral -> Y+146
;	*Err_previous -> Y+144
;	pErr -> Y+140
;	dErr -> Y+136
;	MV -> Y+132
;	Err -> Y+128
;	BUFF -> Y+0
; 0004 000C 
; 0004 000D     // pErr = (Kp*Err); // P
; 0004 000E     // *integral = *integral +(Ki * Err * Time); // I
; 0004 000F     // dErr = (Kd * (Err - *Err_previous)) / Time; // D
; 0004 0010     // MV = (long int)(pErr+ *integral + dErr);// PID Control Volume
; 0004 0011 
; 0004 0012     //sprintf(BUFF, "pErr=%d, integral=%d, dErr=%d, MV=%d  Err=%d\r\n", (int)pErr, *integral, dErr, MV, (int)Err);
; 0004 0013     //string_tx1(BUFF);
; 0004 0014 
; 0004 0015     *Err_previous = Err;
; 0004 0016 
; 0004 0017     return MV;
; 0004 0018 }
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_put_buff_G100:
	ST   -Y,R17
	ST   -Y,R16
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x2000010
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,4
	CALL __GETW1P
	MOVW R16,R30
	SBIW R30,0
	BREQ _0x2000012
	__CPWRN 16,17,2
	BRLO _0x2000013
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	__PUTW1SNS 2,4
_0x2000012:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL SUBOPT_0x12
	SBIW R30,1
	LDD  R26,Y+4
	STD  Z+0,R26
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	TST  R31
	BRMI _0x2000014
	CALL SUBOPT_0x12
_0x2000014:
_0x2000013:
	RJMP _0x2000015
_0x2000010:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	ST   X+,R30
	ST   X,R31
_0x2000015:
	LDD  R17,Y+1
	LDD  R16,Y+0
	RJMP _0x20A0007
__ftoe_G100:
	SBIW R28,4
	CALL SUBOPT_0x18
	LDI  R30,LOW(128)
	STD  Y+2,R30
	LDI  R30,LOW(63)
	STD  Y+3,R30
	CALL __SAVELOCR4
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	CPI  R30,LOW(0xFFFF)
	LDI  R26,HIGH(0xFFFF)
	CPC  R31,R26
	BRNE _0x2000019
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x2000000,0
	CALL SUBOPT_0x26
	RJMP _0x20A0009
_0x2000019:
	CPI  R30,LOW(0x7FFF)
	LDI  R26,HIGH(0x7FFF)
	CPC  R31,R26
	BRNE _0x2000018
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x2000000,1
	CALL SUBOPT_0x26
	RJMP _0x20A0009
_0x2000018:
	LDD  R26,Y+11
	CPI  R26,LOW(0x7)
	BRLO _0x200001B
	LDI  R30,LOW(6)
	STD  Y+11,R30
_0x200001B:
	LDD  R17,Y+11
_0x200001C:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BREQ _0x200001E
	CALL SUBOPT_0x27
	RJMP _0x200001C
_0x200001E:
	__GETD1S 12
	CALL __CPD10
	BRNE _0x200001F
	LDI  R19,LOW(0)
	CALL SUBOPT_0x27
	RJMP _0x2000020
_0x200001F:
	LDD  R19,Y+11
	CALL SUBOPT_0x28
	BREQ PC+2
	BRCC PC+3
	JMP  _0x2000021
	CALL SUBOPT_0x27
_0x2000022:
	CALL SUBOPT_0x28
	BRLO _0x2000024
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2A
	RJMP _0x2000022
_0x2000024:
	RJMP _0x2000025
_0x2000021:
_0x2000026:
	CALL SUBOPT_0x28
	BRSH _0x2000028
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2B
	CALL SUBOPT_0x2C
	SUBI R19,LOW(1)
	RJMP _0x2000026
_0x2000028:
	CALL SUBOPT_0x27
_0x2000025:
	__GETD1S 12
	CALL SUBOPT_0x2D
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x28
	BRLO _0x2000029
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2A
_0x2000029:
_0x2000020:
	LDI  R17,LOW(0)
_0x200002A:
	LDD  R30,Y+11
	CP   R30,R17
	BRLO _0x200002C
	CALL SUBOPT_0x1E
	CALL SUBOPT_0x2E
	CALL SUBOPT_0x2D
	CALL SUBOPT_0x2F
	CALL SUBOPT_0x1C
	__GETD1S 4
	CALL SUBOPT_0x29
	CALL __DIVF21
	CALL __CFD1U
	MOV  R16,R30
	CALL SUBOPT_0x30
	CALL SUBOPT_0x31
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __CDF1
	CALL SUBOPT_0x1E
	CALL __MULF12
	CALL SUBOPT_0x29
	CALL SUBOPT_0x1D
	CALL SUBOPT_0x2C
	MOV  R30,R17
	SUBI R17,-1
	CPI  R30,0
	BRNE _0x200002A
	CALL SUBOPT_0x30
	LDI  R30,LOW(46)
	ST   X,R30
	RJMP _0x200002A
_0x200002C:
	CALL SUBOPT_0x32
	SBIW R30,1
	LDD  R26,Y+10
	STD  Z+0,R26
	CPI  R19,0
	BRGE _0x200002E
	NEG  R19
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(45)
	RJMP _0x2000111
_0x200002E:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(43)
_0x2000111:
	ST   X,R30
	CALL SUBOPT_0x32
	CALL SUBOPT_0x32
	SBIW R30,1
	MOVW R22,R30
	MOV  R26,R19
	LDI  R30,LOW(10)
	CALL __DIVB21
	SUBI R30,-LOW(48)
	MOVW R26,R22
	ST   X,R30
	CALL SUBOPT_0x32
	SBIW R30,1
	MOVW R22,R30
	MOV  R26,R19
	LDI  R30,LOW(10)
	CALL __MODB21
	SUBI R30,-LOW(48)
	MOVW R26,R22
	ST   X,R30
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(0)
	ST   X,R30
_0x20A0009:
	CALL __LOADLOCR4
_0x20A000A:
	ADIW R28,16
	RET
__print_G100:
	SBIW R28,63
	SBIW R28,17
	CALL __SAVELOCR6
	LDI  R17,0
	__GETW1SX 88
	STD  Y+8,R30
	STD  Y+8+1,R31
	__GETW1SX 86
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CALL SUBOPT_0x20
_0x2000030:
	MOVW R26,R28
	SUBI R26,LOW(-(92))
	SBCI R27,HIGH(-(92))
	CALL SUBOPT_0x12
	SBIW R30,1
	LPM  R30,Z
	MOV  R18,R30
	CPI  R30,0
	BRNE PC+3
	JMP _0x2000032
	MOV  R30,R17
	CPI  R30,0
	BRNE _0x2000036
	CPI  R18,37
	BRNE _0x2000037
	LDI  R17,LOW(1)
	RJMP _0x2000038
_0x2000037:
	CALL SUBOPT_0x33
_0x2000038:
	RJMP _0x2000035
_0x2000036:
	CPI  R30,LOW(0x1)
	BRNE _0x2000039
	CPI  R18,37
	BRNE _0x200003A
	CALL SUBOPT_0x33
	RJMP _0x2000112
_0x200003A:
	LDI  R17,LOW(2)
	LDI  R30,LOW(0)
	STD  Y+21,R30
	LDI  R16,LOW(0)
	CPI  R18,45
	BRNE _0x200003B
	LDI  R16,LOW(1)
	RJMP _0x2000035
_0x200003B:
	CPI  R18,43
	BRNE _0x200003C
	LDI  R30,LOW(43)
	STD  Y+21,R30
	RJMP _0x2000035
_0x200003C:
	CPI  R18,32
	BRNE _0x200003D
	LDI  R30,LOW(32)
	STD  Y+21,R30
	RJMP _0x2000035
_0x200003D:
	RJMP _0x200003E
_0x2000039:
	CPI  R30,LOW(0x2)
	BRNE _0x200003F
_0x200003E:
	LDI  R21,LOW(0)
	LDI  R17,LOW(3)
	CPI  R18,48
	BRNE _0x2000040
	ORI  R16,LOW(128)
	RJMP _0x2000035
_0x2000040:
	RJMP _0x2000041
_0x200003F:
	CPI  R30,LOW(0x3)
	BRNE _0x2000042
_0x2000041:
	CPI  R18,48
	BRLO _0x2000044
	CPI  R18,58
	BRLO _0x2000045
_0x2000044:
	RJMP _0x2000043
_0x2000045:
	LDI  R26,LOW(10)
	MUL  R21,R26
	MOV  R21,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R21,R30
	RJMP _0x2000035
_0x2000043:
	LDI  R20,LOW(0)
	CPI  R18,46
	BRNE _0x2000046
	LDI  R17,LOW(4)
	RJMP _0x2000035
_0x2000046:
	RJMP _0x2000047
_0x2000042:
	CPI  R30,LOW(0x4)
	BRNE _0x2000049
	CPI  R18,48
	BRLO _0x200004B
	CPI  R18,58
	BRLO _0x200004C
_0x200004B:
	RJMP _0x200004A
_0x200004C:
	ORI  R16,LOW(32)
	LDI  R26,LOW(10)
	MUL  R20,R26
	MOV  R20,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R20,R30
	RJMP _0x2000035
_0x200004A:
_0x2000047:
	CPI  R18,108
	BRNE _0x200004D
	ORI  R16,LOW(2)
	LDI  R17,LOW(5)
	RJMP _0x2000035
_0x200004D:
	RJMP _0x200004E
_0x2000049:
	CPI  R30,LOW(0x5)
	BREQ PC+3
	JMP _0x2000035
_0x200004E:
	MOV  R30,R18
	CPI  R30,LOW(0x63)
	BRNE _0x2000053
	CALL SUBOPT_0x34
	CALL SUBOPT_0x35
	CALL SUBOPT_0x34
	LDD  R26,Z+4
	ST   -Y,R26
	CALL SUBOPT_0x36
	RJMP _0x2000054
_0x2000053:
	CPI  R30,LOW(0x45)
	BREQ _0x2000057
	CPI  R30,LOW(0x65)
	BRNE _0x2000058
_0x2000057:
	RJMP _0x2000059
_0x2000058:
	CPI  R30,LOW(0x66)
	BREQ PC+3
	JMP _0x200005A
_0x2000059:
	MOVW R30,R28
	ADIW R30,22
	STD  Y+14,R30
	STD  Y+14+1,R31
	CALL SUBOPT_0x37
	CALL __GETD1P
	CALL SUBOPT_0x38
	CALL SUBOPT_0x39
	LDD  R26,Y+13
	TST  R26
	BRMI _0x200005B
	LDD  R26,Y+21
	CPI  R26,LOW(0x2B)
	BREQ _0x200005D
	RJMP _0x200005E
_0x200005B:
	CALL SUBOPT_0x3A
	CALL __ANEGF1
	CALL SUBOPT_0x38
	LDI  R30,LOW(45)
	STD  Y+21,R30
_0x200005D:
	SBRS R16,7
	RJMP _0x200005F
	LDD  R30,Y+21
	ST   -Y,R30
	CALL SUBOPT_0x36
	RJMP _0x2000060
_0x200005F:
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	ADIW R30,1
	STD  Y+14,R30
	STD  Y+14+1,R31
	SBIW R30,1
	LDD  R26,Y+21
	STD  Z+0,R26
_0x2000060:
_0x200005E:
	SBRS R16,5
	LDI  R20,LOW(6)
	CPI  R18,102
	BRNE _0x2000062
	CALL SUBOPT_0x3A
	CALL __PUTPARD1
	ST   -Y,R20
	LDD  R30,Y+19
	LDD  R31,Y+19+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _ftoa
	RJMP _0x2000063
_0x2000062:
	CALL SUBOPT_0x3A
	CALL __PUTPARD1
	ST   -Y,R20
	ST   -Y,R18
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	ST   -Y,R31
	ST   -Y,R30
	RCALL __ftoe_G100
_0x2000063:
	MOVW R30,R28
	ADIW R30,22
	CALL SUBOPT_0x3B
	RJMP _0x2000064
_0x200005A:
	CPI  R30,LOW(0x73)
	BRNE _0x2000066
	CALL SUBOPT_0x39
	CALL SUBOPT_0x3C
	CALL SUBOPT_0x3B
	RJMP _0x2000067
_0x2000066:
	CPI  R30,LOW(0x70)
	BRNE _0x2000069
	CALL SUBOPT_0x39
	CALL SUBOPT_0x3C
	STD  Y+14,R30
	STD  Y+14+1,R31
	ST   -Y,R31
	ST   -Y,R30
	CALL _strlenf
	MOV  R17,R30
	ORI  R16,LOW(8)
_0x2000067:
	ANDI R16,LOW(127)
	CPI  R20,0
	BREQ _0x200006B
	CP   R20,R17
	BRLO _0x200006C
_0x200006B:
	RJMP _0x200006A
_0x200006C:
	MOV  R17,R20
_0x200006A:
_0x2000064:
	LDI  R20,LOW(0)
	LDI  R30,LOW(0)
	STD  Y+20,R30
	LDI  R19,LOW(0)
	RJMP _0x200006D
_0x2000069:
	CPI  R30,LOW(0x64)
	BREQ _0x2000070
	CPI  R30,LOW(0x69)
	BRNE _0x2000071
_0x2000070:
	ORI  R16,LOW(4)
	RJMP _0x2000072
_0x2000071:
	CPI  R30,LOW(0x75)
	BRNE _0x2000073
_0x2000072:
	LDI  R30,LOW(10)
	STD  Y+20,R30
	SBRS R16,1
	RJMP _0x2000074
	__GETD1N 0x3B9ACA00
	CALL SUBOPT_0x3D
	LDI  R17,LOW(10)
	RJMP _0x2000075
_0x2000074:
	__GETD1N 0x2710
	CALL SUBOPT_0x3D
	LDI  R17,LOW(5)
	RJMP _0x2000075
_0x2000073:
	CPI  R30,LOW(0x58)
	BRNE _0x2000077
	ORI  R16,LOW(8)
	RJMP _0x2000078
_0x2000077:
	CPI  R30,LOW(0x78)
	BREQ PC+3
	JMP _0x20000B6
_0x2000078:
	LDI  R30,LOW(16)
	STD  Y+20,R30
	SBRS R16,1
	RJMP _0x200007A
	__GETD1N 0x10000000
	CALL SUBOPT_0x3D
	LDI  R17,LOW(8)
	RJMP _0x2000075
_0x200007A:
	__GETD1N 0x1000
	CALL SUBOPT_0x3D
	LDI  R17,LOW(4)
_0x2000075:
	CPI  R20,0
	BREQ _0x200007B
	ANDI R16,LOW(127)
	RJMP _0x200007C
_0x200007B:
	LDI  R20,LOW(1)
_0x200007C:
	SBRS R16,1
	RJMP _0x200007D
	CALL SUBOPT_0x39
	CALL SUBOPT_0x37
	ADIW R26,4
	CALL __GETD1P
	RJMP _0x2000113
_0x200007D:
	SBRS R16,2
	RJMP _0x200007F
	CALL SUBOPT_0x39
	CALL SUBOPT_0x3C
	CALL __CWD1
	RJMP _0x2000113
_0x200007F:
	CALL SUBOPT_0x39
	CALL SUBOPT_0x3C
	CLR  R22
	CLR  R23
_0x2000113:
	__PUTD1S 10
	SBRS R16,2
	RJMP _0x2000081
	LDD  R26,Y+13
	TST  R26
	BRPL _0x2000082
	CALL SUBOPT_0x3A
	CALL __ANEGD1
	CALL SUBOPT_0x38
	LDI  R30,LOW(45)
	STD  Y+21,R30
_0x2000082:
	LDD  R30,Y+21
	CPI  R30,0
	BREQ _0x2000083
	SUBI R17,-LOW(1)
	SUBI R20,-LOW(1)
	RJMP _0x2000084
_0x2000083:
	ANDI R16,LOW(251)
_0x2000084:
_0x2000081:
	MOV  R19,R20
_0x200006D:
	SBRC R16,0
	RJMP _0x2000085
_0x2000086:
	CP   R17,R21
	BRSH _0x2000089
	CP   R19,R21
	BRLO _0x200008A
_0x2000089:
	RJMP _0x2000088
_0x200008A:
	SBRS R16,7
	RJMP _0x200008B
	SBRS R16,2
	RJMP _0x200008C
	ANDI R16,LOW(251)
	LDD  R18,Y+21
	SUBI R17,LOW(1)
	RJMP _0x200008D
_0x200008C:
	LDI  R18,LOW(48)
_0x200008D:
	RJMP _0x200008E
_0x200008B:
	LDI  R18,LOW(32)
_0x200008E:
	CALL SUBOPT_0x33
	SUBI R21,LOW(1)
	RJMP _0x2000086
_0x2000088:
_0x2000085:
_0x200008F:
	CP   R17,R20
	BRSH _0x2000091
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x2000092
	CALL SUBOPT_0x3E
	BREQ _0x2000093
	SUBI R21,LOW(1)
_0x2000093:
	SUBI R17,LOW(1)
	SUBI R20,LOW(1)
_0x2000092:
	LDI  R30,LOW(48)
	ST   -Y,R30
	CALL SUBOPT_0x36
	CPI  R21,0
	BREQ _0x2000094
	SUBI R21,LOW(1)
_0x2000094:
	SUBI R20,LOW(1)
	RJMP _0x200008F
_0x2000091:
	MOV  R19,R17
	LDD  R30,Y+20
	CPI  R30,0
	BRNE _0x2000095
_0x2000096:
	CPI  R19,0
	BREQ _0x2000098
	SBRS R16,3
	RJMP _0x2000099
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	LPM  R18,Z+
	STD  Y+14,R30
	STD  Y+14+1,R31
	RJMP _0x200009A
_0x2000099:
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	LD   R18,X+
	STD  Y+14,R26
	STD  Y+14+1,R27
_0x200009A:
	CALL SUBOPT_0x33
	CPI  R21,0
	BREQ _0x200009B
	SUBI R21,LOW(1)
_0x200009B:
	SUBI R19,LOW(1)
	RJMP _0x2000096
_0x2000098:
	RJMP _0x200009C
_0x2000095:
_0x200009E:
	CALL SUBOPT_0x3F
	CALL __DIVD21U
	MOV  R18,R30
	CPI  R18,10
	BRLO _0x20000A0
	SBRS R16,3
	RJMP _0x20000A1
	SUBI R18,-LOW(55)
	RJMP _0x20000A2
_0x20000A1:
	SUBI R18,-LOW(87)
_0x20000A2:
	RJMP _0x20000A3
_0x20000A0:
	SUBI R18,-LOW(48)
_0x20000A3:
	SBRC R16,4
	RJMP _0x20000A5
	CPI  R18,49
	BRSH _0x20000A7
	__GETD2S 16
	__CPD2N 0x1
	BRNE _0x20000A6
_0x20000A7:
	RJMP _0x20000A9
_0x20000A6:
	CP   R20,R19
	BRSH _0x2000114
	CP   R21,R19
	BRLO _0x20000AC
	SBRS R16,0
	RJMP _0x20000AD
_0x20000AC:
	RJMP _0x20000AB
_0x20000AD:
	LDI  R18,LOW(32)
	SBRS R16,7
	RJMP _0x20000AE
_0x2000114:
	LDI  R18,LOW(48)
_0x20000A9:
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x20000AF
	CALL SUBOPT_0x3E
	BREQ _0x20000B0
	SUBI R21,LOW(1)
_0x20000B0:
_0x20000AF:
_0x20000AE:
_0x20000A5:
	CALL SUBOPT_0x33
	CPI  R21,0
	BREQ _0x20000B1
	SUBI R21,LOW(1)
_0x20000B1:
_0x20000AB:
	SUBI R19,LOW(1)
	CALL SUBOPT_0x3F
	CALL __MODD21U
	CALL SUBOPT_0x38
	LDD  R30,Y+20
	__GETD2S 16
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __DIVD21U
	CALL SUBOPT_0x3D
	__GETD1S 16
	CALL __CPD10
	BREQ _0x200009F
	RJMP _0x200009E
_0x200009F:
_0x200009C:
	SBRS R16,0
	RJMP _0x20000B2
_0x20000B3:
	CPI  R21,0
	BREQ _0x20000B5
	SUBI R21,LOW(1)
	LDI  R30,LOW(32)
	ST   -Y,R30
	CALL SUBOPT_0x36
	RJMP _0x20000B3
_0x20000B5:
_0x20000B2:
_0x20000B6:
_0x2000054:
_0x2000112:
	LDI  R17,LOW(0)
_0x2000035:
	RJMP _0x2000030
_0x2000032:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CALL __GETW1P
	CALL __LOADLOCR6
	ADIW R28,63
	ADIW R28,31
	RET
_sprintf:
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	CALL __SAVELOCR4
	CALL SUBOPT_0x40
	SBIW R30,0
	BRNE _0x20000B7
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0008
_0x20000B7:
	MOVW R26,R28
	ADIW R26,6
	CALL __ADDW2R15
	MOVW R16,R26
	CALL SUBOPT_0x40
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
	MOVW R26,R28
	ADIW R26,10
	CALL SUBOPT_0x41
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(_put_buff_G100)
	LDI  R31,HIGH(_put_buff_G100)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,10
	ST   -Y,R31
	ST   -Y,R30
	RCALL __print_G100
	MOVW R18,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
	MOVW R30,R18
_0x20A0008:
	CALL __LOADLOCR4
	ADIW R28,10
	POP  R15
	RET
_get_buff_G100:
	ST   -Y,R17
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LDI  R30,LOW(0)
	ST   X,R30
	LDD  R26,Y+3
	LDD  R27,Y+3+1
	LD   R30,X
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x20000BF
	LDI  R30,LOW(0)
	ST   X,R30
	RJMP _0x20000C0
_0x20000BF:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	ADIW R26,1
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x20000C1
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	LDD  R26,Z+1
	LDD  R27,Z+2
	LD   R30,X
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x20000C2
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	ADIW R26,1
	CALL SUBOPT_0x12
_0x20000C2:
	RJMP _0x20000C3
_0x20000C1:
	LDI  R17,LOW(0)
_0x20000C3:
_0x20000C0:
	MOV  R30,R17
	LDD  R17,Y+0
_0x20A0007:
	ADIW R28,5
	RET
__scanf_G100:
	SBIW R28,8
	CALL __SAVELOCR6
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	STD  Y+10,R30
	STD  Y+10+1,R31
	STD  Y+13,R30
_0x20000C4:
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	ADIW R30,1
	STD  Y+20,R30
	STD  Y+20+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R19,R30
	CPI  R30,0
	BRNE PC+3
	JMP _0x20000C6
	CALL SUBOPT_0x42
	BREQ _0x20000C7
_0x20000C8:
	CALL SUBOPT_0x43
	MOV  R19,R30
	CPI  R30,0
	BREQ _0x20000CB
	CALL SUBOPT_0x42
	BRNE _0x20000CC
_0x20000CB:
	RJMP _0x20000CA
_0x20000CC:
	CALL SUBOPT_0x44
	BRGE _0x20000CD
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x20000CD:
	RJMP _0x20000C8
_0x20000CA:
	__PUTBSR 19,13
	RJMP _0x20000CE
_0x20000C7:
	CPI  R19,37
	BREQ PC+3
	JMP _0x20000CF
	LDI  R21,LOW(0)
_0x20000D0:
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	LPM  R19,Z+
	STD  Y+20,R30
	STD  Y+20+1,R31
	CPI  R19,48
	BRLO _0x20000D4
	CPI  R19,58
	BRLO _0x20000D3
_0x20000D4:
	RJMP _0x20000D2
_0x20000D3:
	LDI  R26,LOW(10)
	MUL  R21,R26
	MOV  R21,R0
	MOV  R30,R19
	SUBI R30,LOW(48)
	ADD  R21,R30
	RJMP _0x20000D0
_0x20000D2:
	CPI  R19,0
	BRNE _0x20000D6
	RJMP _0x20000C6
_0x20000D6:
_0x20000D7:
	CALL SUBOPT_0x43
	MOV  R18,R30
	ST   -Y,R30
	CALL _isspace
	CPI  R30,0
	BREQ _0x20000D9
	CALL SUBOPT_0x44
	BRGE _0x20000DA
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x20000DA:
	RJMP _0x20000D7
_0x20000D9:
	CPI  R18,0
	BRNE _0x20000DB
	RJMP _0x20000DC
_0x20000DB:
	__PUTBSR 18,13
	CPI  R21,0
	BRNE _0x20000DD
	LDI  R21,LOW(255)
_0x20000DD:
	LDI  R20,LOW(0)
	MOV  R30,R19
	CPI  R30,LOW(0x63)
	BRNE _0x20000E1
	CALL SUBOPT_0x45
	CALL SUBOPT_0x43
	MOVW R26,R16
	ST   X,R30
	CALL SUBOPT_0x44
	BRGE _0x20000E2
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x20000E2:
	RJMP _0x20000E0
_0x20000E1:
	CPI  R30,LOW(0x73)
	BRNE _0x20000E3
	CALL SUBOPT_0x45
_0x20000E4:
	MOV  R30,R21
	SUBI R21,1
	CPI  R30,0
	BREQ _0x20000E6
	CALL SUBOPT_0x43
	MOV  R19,R30
	CPI  R30,0
	BREQ _0x20000E8
	CALL SUBOPT_0x42
	BREQ _0x20000E7
_0x20000E8:
	CALL SUBOPT_0x44
	BRGE _0x20000EA
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x20000EA:
	RJMP _0x20000E6
_0x20000E7:
	PUSH R17
	PUSH R16
	__ADDWRN 16,17,1
	MOV  R30,R19
	POP  R26
	POP  R27
	ST   X,R30
	RJMP _0x20000E4
_0x20000E6:
	MOVW R26,R16
	LDI  R30,LOW(0)
	ST   X,R30
	RJMP _0x20000E0
_0x20000E3:
	CPI  R30,LOW(0x6C)
	BRNE _0x20000EC
	LDI  R20,LOW(1)
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	LPM  R19,Z+
	STD  Y+20,R30
	STD  Y+20+1,R31
_0x20000EC:
	LDI  R30,LOW(1)
	STD  Y+12,R30
	MOV  R30,R19
	CPI  R30,LOW(0x64)
	BREQ _0x20000F1
	CPI  R30,LOW(0x69)
	BRNE _0x20000F2
_0x20000F1:
	LDI  R30,LOW(0)
	STD  Y+12,R30
	RJMP _0x20000F3
_0x20000F2:
	CPI  R30,LOW(0x75)
	BRNE _0x20000F4
_0x20000F3:
	LDI  R18,LOW(10)
	RJMP _0x20000EF
_0x20000F4:
	CPI  R30,LOW(0x78)
	BRNE _0x20000F5
	LDI  R18,LOW(16)
	RJMP _0x20000EF
_0x20000F5:
	CPI  R30,LOW(0x25)
	BRNE _0x20000F8
	RJMP _0x20000F7
_0x20000F8:
	RJMP _0x20A0006
_0x20000EF:
	LDI  R30,LOW(0)
	__CLRD1S 6
_0x20000F9:
	MOV  R30,R21
	SUBI R21,1
	CPI  R30,0
	BRNE PC+3
	JMP _0x20000FB
	CALL SUBOPT_0x43
	MOV  R19,R30
	CPI  R30,LOW(0x21)
	BRSH _0x20000FC
	CALL SUBOPT_0x44
	BRGE _0x20000FD
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x20000FD:
	RJMP _0x20000FE
_0x20000FC:
	LDD  R30,Y+12
	CPI  R30,0
	BRNE _0x20000FF
	CPI  R19,45
	BRNE _0x2000100
	LDI  R30,LOW(255)
	STD  Y+12,R30
	RJMP _0x20000F9
_0x2000100:
	LDI  R30,LOW(1)
	STD  Y+12,R30
_0x20000FF:
	CPI  R18,16
	BRNE _0x2000102
	ST   -Y,R19
	CALL _isxdigit
	CPI  R30,0
	BREQ _0x20000FE
	RJMP _0x2000104
_0x2000102:
	ST   -Y,R19
	CALL _isdigit
	CPI  R30,0
	BRNE _0x2000105
_0x20000FE:
	__PUTBSR 19,13
	RJMP _0x20000FB
_0x2000105:
_0x2000104:
	CPI  R19,97
	BRLO _0x2000106
	SUBI R19,LOW(87)
	RJMP _0x2000107
_0x2000106:
	CPI  R19,65
	BRLO _0x2000108
	SUBI R19,LOW(55)
	RJMP _0x2000109
_0x2000108:
	SUBI R19,LOW(48)
_0x2000109:
_0x2000107:
	MOV  R30,R18
	__GETD2S 6
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __MULD12U
	MOVW R26,R30
	MOVW R24,R22
	MOV  R30,R19
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __ADDD12
	__PUTD1S 6
	RJMP _0x20000F9
_0x20000FB:
	LDD  R30,Y+12
	__GETD2S 6
	CALL __CBD1
	CALL __MULD12U
	__PUTD1S 6
	CPI  R20,0
	BREQ _0x200010A
	CALL SUBOPT_0x45
	__GETD1S 6
	MOVW R26,R16
	CALL __PUTDP1
	RJMP _0x200010B
_0x200010A:
	CALL SUBOPT_0x45
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	MOVW R26,R16
	ST   X+,R30
	ST   X,R31
_0x200010B:
_0x20000E0:
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	ADIW R30,1
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0x200010C
_0x20000CF:
_0x20000F7:
	CALL SUBOPT_0x43
	CP   R30,R19
	BREQ _0x200010D
	CALL SUBOPT_0x44
	BRGE _0x200010E
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x200010E:
_0x20000DC:
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	SBIW R30,0
	BRNE _0x200010F
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x200010F:
	RJMP _0x20000C6
_0x200010D:
_0x200010C:
_0x20000CE:
	RJMP _0x20000C4
_0x20000C6:
_0x20A0006:
	LDD  R30,Y+10
	LDD  R31,Y+10+1
_0x20A0005:
	CALL __LOADLOCR6
	ADIW R28,22
	RET
_sscanf:
	PUSH R15
	MOV  R15,R24
	SBIW R28,3
	ST   -Y,R17
	ST   -Y,R16
	MOVW R26,R28
	ADIW R26,7
	CALL SUBOPT_0x41
	SBIW R30,0
	BRNE _0x2000110
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0004
_0x2000110:
	MOVW R26,R28
	ADIW R26,1
	CALL __ADDW2R15
	MOVW R16,R26
	MOVW R26,R28
	ADIW R26,7
	CALL SUBOPT_0x41
	STD  Y+3,R30
	STD  Y+3+1,R31
	MOVW R26,R28
	ADIW R26,5
	CALL SUBOPT_0x41
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(_get_buff_G100)
	LDI  R31,HIGH(_get_buff_G100)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,8
	ST   -Y,R31
	ST   -Y,R30
	RCALL __scanf_G100
_0x20A0004:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,5
	POP  R15
	RET

	.CSEG
_ftrunc:
   ldd  r23,y+3
   ldd  r22,y+2
   ldd  r31,y+1
   ld   r30,y
   bst  r23,7
   lsl  r23
   sbrc r22,7
   sbr  r23,1
   mov  r25,r23
   subi r25,0x7e
   breq __ftrunc0
   brcs __ftrunc0
   cpi  r25,24
   brsh __ftrunc1
   clr  r26
   clr  r27
   clr  r24
__ftrunc2:
   sec
   ror  r24
   ror  r27
   ror  r26
   dec  r25
   brne __ftrunc2
   and  r30,r26
   and  r31,r27
   and  r22,r24
   rjmp __ftrunc1
__ftrunc0:
   clt
   clr  r23
   clr  r30
   clr  r31
   clr  r22
__ftrunc1:
   cbr  r22,0x80
   lsr  r23
   brcc __ftrunc3
   sbr  r22,0x80
__ftrunc3:
   bld  r23,7
   ld   r26,y+
   ld   r27,y+
   ld   r24,y+
   ld   r25,y+
   cp   r30,r26
   cpc  r31,r27
   cpc  r22,r24
   cpc  r23,r25
   bst  r25,7
   ret
_floor:
	CALL SUBOPT_0x46
	CALL __PUTPARD1
	CALL _ftrunc
	CALL __PUTD1S0
    brne __floor1
__floor0:
	CALL SUBOPT_0x46
	RJMP _0x20A0003
__floor1:
    brtc __floor0
	CALL SUBOPT_0x46
	__GETD2N 0x3F800000
	CALL __SUBF12
	RJMP _0x20A0003
_sin:
	SBIW R28,4
	ST   -Y,R17
	LDI  R17,0
	CALL SUBOPT_0x47
	__GETD1N 0x3E22F983
	CALL __MULF12
	CALL SUBOPT_0x48
	CALL SUBOPT_0x49
	CALL SUBOPT_0x2F
	CALL SUBOPT_0x47
	CALL SUBOPT_0x1D
	CALL SUBOPT_0x48
	CALL SUBOPT_0x47
	CALL SUBOPT_0x7
	CALL __CMPF12
	BREQ PC+2
	BRCC PC+3
	JMP  _0x2020017
	CALL SUBOPT_0x49
	__GETD2N 0x3F000000
	CALL __SUBF12
	CALL SUBOPT_0x48
	LDI  R17,LOW(1)
_0x2020017:
	CALL SUBOPT_0x47
	__GETD1N 0x3E800000
	CALL __CMPF12
	BREQ PC+2
	BRCC PC+3
	JMP  _0x2020018
	CALL SUBOPT_0x47
	CALL SUBOPT_0x7
	CALL __SUBF12
	CALL SUBOPT_0x48
_0x2020018:
	CPI  R17,0
	BREQ _0x2020019
	CALL SUBOPT_0x49
	CALL __ANEGF1
	CALL SUBOPT_0x48
_0x2020019:
	CALL SUBOPT_0x49
	CALL SUBOPT_0x47
	CALL __MULF12
	__PUTD1S 1
	__GETD2N 0x4226C4B1
	CALL __MULF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x422DE51D
	CALL SUBOPT_0x1D
	CALL SUBOPT_0x4A
	__GETD2N 0x4104534C
	CALL __ADDF12
	CALL SUBOPT_0x47
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	__GETD1S 1
	__GETD2N 0x3FDEED11
	CALL __ADDF12
	CALL SUBOPT_0x4A
	__GETD2N 0x3FA87B5E
	CALL __ADDF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __DIVF21
	LDD  R17,Y+0
	ADIW R28,9
	RET
_cos:
	CALL __GETD2S0
	__GETD1N 0x3FC90FDB
	CALL __SUBF12
	CALL __PUTPARD1
	RCALL _sin
_0x20A0003:
	ADIW R28,4
	RET

	.CSEG
_isdigit:
    ldi  r30,1
    ld   r31,y+
    cpi  r31,'0'
    brlo isdigit0
    cpi  r31,'9'+1
    brlo isdigit1
isdigit0:
    clr  r30
isdigit1:
    ret
_isspace:
    ldi  r30,1
    ld   r31,y+
    cpi  r31,' '
    breq isspace1
    cpi  r31,9
    brlo isspace0
    cpi  r31,13+1
    brlo isspace1
isspace0:
    clr  r30
isspace1:
    ret
_isxdigit:
    ldi  r30,1
    ld   r31,y+
    subi r31,0x30
    brcs isxdigit0
    cpi  r31,10
    brcs isxdigit1
    andi r31,0x5f
    subi r31,7
    cpi  r31,10
    brcs isxdigit0
    cpi  r31,16
    brcs isxdigit1
isxdigit0:
    clr  r30
isxdigit1:
    ret

	.CSEG
_strcpyf:
    ld   r30,y+
    ld   r31,y+
    ld   r26,y+
    ld   r27,y+
    movw r24,r26
strcpyf0:
	lpm  r0,z+
    st   x+,r0
    tst  r0
    brne strcpyf0
    movw r30,r24
    ret
_strlen:
    ld   r26,y+
    ld   r27,y+
    clr  r30
    clr  r31
strlen0:
    ld   r22,x+
    tst  r22
    breq strlen1
    adiw r30,1
    rjmp strlen0
strlen1:
    ret
_strlenf:
    clr  r26
    clr  r27
    ld   r30,y+
    ld   r31,y+
strlenf0:
	lpm  r0,z+
    tst  r0
    breq strlenf1
    adiw r26,1
    rjmp strlenf0
strlenf1:
    movw r30,r26
    ret

	.CSEG
_ftoa:
	SBIW R28,4
	RCALL SUBOPT_0x18
	LDI  R30,LOW(0)
	STD  Y+2,R30
	LDI  R30,LOW(63)
	STD  Y+3,R30
	ST   -Y,R17
	ST   -Y,R16
	LDD  R30,Y+11
	LDD  R31,Y+11+1
	CPI  R30,LOW(0xFFFF)
	LDI  R26,HIGH(0xFFFF)
	CPC  R31,R26
	BRNE _0x208000D
	RCALL SUBOPT_0x4B
	__POINTW1FN _0x2080000,0
	RCALL SUBOPT_0x26
	RJMP _0x20A0002
_0x208000D:
	CPI  R30,LOW(0x7FFF)
	LDI  R26,HIGH(0x7FFF)
	CPC  R31,R26
	BRNE _0x208000C
	RCALL SUBOPT_0x4B
	__POINTW1FN _0x2080000,1
	RCALL SUBOPT_0x26
	RJMP _0x20A0002
_0x208000C:
	LDD  R26,Y+12
	TST  R26
	BRPL _0x208000F
	__GETD1S 9
	CALL __ANEGF1
	RCALL SUBOPT_0x4C
	RCALL SUBOPT_0x4D
	LDI  R30,LOW(45)
	ST   X,R30
_0x208000F:
	LDD  R26,Y+8
	CPI  R26,LOW(0x7)
	BRLO _0x2080010
	LDI  R30,LOW(6)
	STD  Y+8,R30
_0x2080010:
	LDD  R17,Y+8
_0x2080011:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BREQ _0x2080013
	RCALL SUBOPT_0x4E
	RCALL SUBOPT_0x2E
	RCALL SUBOPT_0x4F
	RJMP _0x2080011
_0x2080013:
	RCALL SUBOPT_0x50
	CALL __ADDF12
	RCALL SUBOPT_0x4C
	LDI  R17,LOW(0)
	__GETD1N 0x3F800000
	RCALL SUBOPT_0x4F
_0x2080014:
	RCALL SUBOPT_0x50
	CALL __CMPF12
	BRLO _0x2080016
	RCALL SUBOPT_0x4E
	RCALL SUBOPT_0x2B
	RCALL SUBOPT_0x4F
	SUBI R17,-LOW(1)
	CPI  R17,39
	BRLO _0x2080017
	RCALL SUBOPT_0x4B
	__POINTW1FN _0x2080000,5
	RCALL SUBOPT_0x26
	RJMP _0x20A0002
_0x2080017:
	RJMP _0x2080014
_0x2080016:
	CPI  R17,0
	BRNE _0x2080018
	RCALL SUBOPT_0x4D
	LDI  R30,LOW(48)
	ST   X,R30
	RJMP _0x2080019
_0x2080018:
_0x208001A:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BREQ _0x208001C
	RCALL SUBOPT_0x4E
	RCALL SUBOPT_0x2E
	RCALL SUBOPT_0x2D
	RCALL SUBOPT_0x2F
	RCALL SUBOPT_0x4F
	RCALL SUBOPT_0x50
	CALL __DIVF21
	CALL __CFD1U
	MOV  R16,R30
	RCALL SUBOPT_0x4D
	RCALL SUBOPT_0x31
	LDI  R31,0
	RCALL SUBOPT_0x4E
	RCALL SUBOPT_0x8
	CALL __MULF12
	RCALL SUBOPT_0x51
	RCALL SUBOPT_0x1D
	RCALL SUBOPT_0x4C
	RJMP _0x208001A
_0x208001C:
_0x2080019:
	LDD  R30,Y+8
	CPI  R30,0
	BREQ _0x20A0001
	RCALL SUBOPT_0x4D
	LDI  R30,LOW(46)
	ST   X,R30
_0x208001E:
	LDD  R30,Y+8
	SUBI R30,LOW(1)
	STD  Y+8,R30
	SUBI R30,-LOW(1)
	BREQ _0x2080020
	RCALL SUBOPT_0x51
	RCALL SUBOPT_0x2B
	RCALL SUBOPT_0x4C
	__GETD1S 9
	CALL __CFD1U
	MOV  R16,R30
	RCALL SUBOPT_0x4D
	RCALL SUBOPT_0x31
	LDI  R31,0
	RCALL SUBOPT_0x51
	RCALL SUBOPT_0x8
	RCALL SUBOPT_0x1D
	RCALL SUBOPT_0x4C
	RJMP _0x208001E
_0x2080020:
_0x20A0001:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
_0x20A0002:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,13
	RET

	.DSEG

	.CSEG

	.DSEG
_TIMER1_OVERFLOW:
	.BYTE 0x4
_TIMER2_OVERFLOW:
	.BYTE 0x1
_PACKET_BUFF:
	.BYTE 0x64
_PACKET_BUFF_IDX:
	.BYTE 0x1
_TIMER0_OVERFLOW:
	.BYTE 0x2
_VELOCITY_BUFF:
	.BYTE 0x14
_VELOCITY_BUFF_IDX:
	.BYTE 0x1
_CHECK_GETS:
	.BYTE 0x1
_MOTORR_HALL:
	.BYTE 0x4
_MOTORL_HALL:
	.BYTE 0x4
__seed_G104:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x0:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x1:
	LDI  R30,LOW(0)
	STS  _TIMER0_OVERFLOW,R30
	STS  _TIMER0_OVERFLOW+1,R30
	OUT  0x32,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:28 WORDS
SUBOPT_0x2:
	__GETW1SX 616
	CALL __CWD1
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x42C80000
	CALL __DIVF21
	__PUTD1SX 618
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x3:
	__GETD2N 0x3EC00000
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:51 WORDS
SUBOPT_0x4:
	__GETD1SX 618
	RCALL SUBOPT_0x3
	CALL __ADDF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x3F000000
	CALL __DIVF21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:16 WORDS
SUBOPT_0x5:
	__PUTD1SX 622
	__GETD2N 0x3F400000
	CALL __SUBF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:16 WORDS
SUBOPT_0x6:
	__GETD2SX 622
	__GETD1N 0x447A0000
	CALL __MULF12
	CALL __CFD1
	__PUTW1SX 626
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x7:
	__GETD1N 0x3F000000
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x8:
	CALL __CWD1
	CALL __CDF1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x9:
	LDI  R30,LOW(0)
	STS  _TIMER1_OVERFLOW,R30
	STS  _TIMER1_OVERFLOW+1,R30
	STS  _TIMER1_OVERFLOW+2,R30
	STS  _TIMER1_OVERFLOW+3,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0xA:
	CALL __CDF1
	__GETD2N 0x3ECCCCCD
	CALL __MULF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x43200000
	CALL __DIVF21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xB:
	__GETD2SX 536
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0xC:
	__GETD1SX 536
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:29 WORDS
SUBOPT_0xD:
	__GETD1SX 504
	__GETD2SX 508
	CALL __ADDF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xE:
	__GETD2SX 518
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0xF:
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x40000000
	CALL __DIVF21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x10:
	__GETD1SX 518
	CALL __PUTPARD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x11:
	CALL __MULF12
	CALL __CFD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x12:
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x13:
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x14:
	CALL __GETD1P_INC
	__SUBD1N -1
	CALL __PUTDP1_DEC
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x15:
	LDS  R26,_PACKET_BUFF_IDX
	LDI  R27,0
	SUBI R26,LOW(-_PACKET_BUFF)
	SBCI R27,HIGH(-_PACKET_BUFF)
	IN   R30,0xC
	ST   X,R30
	LDS  R30,_PACKET_BUFF_IDX
	SUBI R30,-LOW(1)
	STS  _PACKET_BUFF_IDX,R30
	LDI  R30,LOW(0)
	OUT  0x24,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x16:
	LDI  R31,0
	SUBI R30,LOW(-_VELOCITY_BUFF)
	SBCI R31,HIGH(-_VELOCITY_BUFF)
	ST   Z,R17
	LDS  R30,_VELOCITY_BUFF_IDX
	SUBI R30,-LOW(1)
	STS  _VELOCITY_BUFF_IDX,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x17:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LD   R30,X
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x18:
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x19:
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	CALL __GETD1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1A:
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL __GETD1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x1B:
	__GETD2N 0x3E8ED917
	CALL __MULF12
	RJMP SUBOPT_0xF

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x1C:
	__PUTD1S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x1D:
	CALL __SWAPD12
	CALL __SUBF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x1E:
	__GETD2S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1F:
	__GETD1N 0x453B8000
	RJMP SUBOPT_0x11

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x20:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x21:
	ST   -Y,R31
	ST   -Y,R30
	CALL _RTU_WriteOperate0
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	RJMP SUBOPT_0x0

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x22:
	ST   -Y,R30
	LDI  R30,LOW(120)
	LDI  R31,HIGH(120)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	RJMP SUBOPT_0x21

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x23:
	RCALL SUBOPT_0x13
	LDI  R26,0
	SBIC 0x1,4
	LDI  R26,1
	LDI  R30,0
	SBIC 0x1,5
	LDI  R30,1
	CP   R30,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:8 WORDS
SUBOPT_0x24:
	LDI  R26,LOW(_MOTORR_HALL)
	LDI  R27,HIGH(_MOTORR_HALL)
	CALL __GETD1P_INC
	SBIW R30,1
	SBCI R22,0
	SBCI R23,0
	CALL __PUTDP1_DEC
	__SUBD1N -1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:8 WORDS
SUBOPT_0x25:
	LDI  R26,LOW(_MOTORL_HALL)
	LDI  R27,HIGH(_MOTORL_HALL)
	CALL __GETD1P_INC
	SBIW R30,1
	SBCI R22,0
	SBCI R23,0
	CALL __PUTDP1_DEC
	__SUBD1N -1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x26:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _strcpyf

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x27:
	RCALL SUBOPT_0x1E
	__GETD1N 0x41200000
	CALL __MULF12
	RJMP SUBOPT_0x1C

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x28:
	__GETD1S 4
	__GETD2S 12
	CALL __CMPF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x29:
	__GETD2S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x2A:
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	__PUTD1S 12
	SUBI R19,-LOW(1)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x2B:
	__GETD1N 0x41200000
	CALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2C:
	__PUTD1S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x2D:
	__GETD2N 0x3F000000
	CALL __ADDF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x2E:
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2F:
	CALL __PUTPARD1
	JMP  _floor

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x30:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,1
	STD  Y+8,R26
	STD  Y+8+1,R27
	SBIW R26,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x31:
	MOV  R30,R16
	SUBI R30,-LOW(48)
	ST   X,R30
	MOV  R30,R16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x32:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x33:
	ST   -Y,R18
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+11
	LDD  R31,Y+11+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x34:
	__GETW1SX 90
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x35:
	SBIW R30,4
	__PUTW1SX 90
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x36:
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+11
	LDD  R31,Y+11+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:17 WORDS
SUBOPT_0x37:
	__GETW2SX 90
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x38:
	__PUTD1S 10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x39:
	RCALL SUBOPT_0x34
	RJMP SUBOPT_0x35

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3A:
	__GETD1S 10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x3B:
	STD  Y+14,R30
	STD  Y+14+1,R31
	ST   -Y,R31
	ST   -Y,R30
	CALL _strlen
	MOV  R17,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x3C:
	RCALL SUBOPT_0x37
	ADIW R26,4
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x3D:
	__PUTD1S 16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x3E:
	ANDI R16,LOW(251)
	LDD  R30,Y+21
	ST   -Y,R30
	__GETW1SX 87
	ST   -Y,R31
	ST   -Y,R30
	__GETW1SX 91
	ICALL
	CPI  R21,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3F:
	__GETD1S 16
	__GETD2S 10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x40:
	MOVW R26,R28
	ADIW R26,12
	CALL __ADDW2R15
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x41:
	CALL __ADDW2R15
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x42:
	ST   -Y,R19
	CALL _isspace
	CPI  R30,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:42 WORDS
SUBOPT_0x43:
	MOVW R30,R28
	ADIW R30,13
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x44:
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	LD   R26,X
	CPI  R26,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x45:
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	SBIW R30,4
	STD  Y+18,R30
	STD  Y+18+1,R31
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	ADIW R26,4
	LD   R16,X+
	LD   R17,X
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x46:
	CALL __GETD1S0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x47:
	__GETD2S 5
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x48:
	__PUTD1S 5
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x49:
	__GETD1S 5
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x4A:
	__GETD2S 1
	CALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x4B:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x4C:
	__PUTD1S 9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x4D:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,1
	STD  Y+6,R26
	STD  Y+6+1,R27
	SBIW R26,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x4E:
	__GETD2S 2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x4F:
	__PUTD1S 2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x50:
	__GETD1S 2
	__GETD2S 9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x51:
	__GETD2S 9
	RET


	.CSEG
_delay_ms:
	ld   r30,y+
	ld   r31,y+
	adiw r30,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0xE66
	wdr
	sbiw r30,1
	brne __delay_ms0
__delay_ms1:
	ret

__ANEGF1:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __ANEGF10
	SUBI R23,0x80
__ANEGF10:
	RET

__ROUND_REPACK:
	TST  R21
	BRPL __REPACK
	CPI  R21,0x80
	BRNE __ROUND_REPACK0
	SBRS R30,0
	RJMP __REPACK
__ROUND_REPACK0:
	ADIW R30,1
	ADC  R22,R25
	ADC  R23,R25
	BRVS __REPACK1

__REPACK:
	LDI  R21,0x80
	EOR  R21,R23
	BRNE __REPACK0
	PUSH R21
	RJMP __ZERORES
__REPACK0:
	CPI  R21,0xFF
	BREQ __REPACK1
	LSL  R22
	LSL  R0
	ROR  R21
	ROR  R22
	MOV  R23,R21
	RET
__REPACK1:
	PUSH R21
	TST  R0
	BRMI __REPACK2
	RJMP __MAXRES
__REPACK2:
	RJMP __MINRES

__UNPACK:
	LDI  R21,0x80
	MOV  R1,R25
	AND  R1,R21
	LSL  R24
	ROL  R25
	EOR  R25,R21
	LSL  R21
	ROR  R24

__UNPACK1:
	LDI  R21,0x80
	MOV  R0,R23
	AND  R0,R21
	LSL  R22
	ROL  R23
	EOR  R23,R21
	LSL  R21
	ROR  R22
	RET

__CFD1U:
	SET
	RJMP __CFD1U0
__CFD1:
	CLT
__CFD1U0:
	PUSH R21
	RCALL __UNPACK1
	CPI  R23,0x80
	BRLO __CFD10
	CPI  R23,0xFF
	BRCC __CFD10
	RJMP __ZERORES
__CFD10:
	LDI  R21,22
	SUB  R21,R23
	BRPL __CFD11
	NEG  R21
	CPI  R21,8
	BRTC __CFD19
	CPI  R21,9
__CFD19:
	BRLO __CFD17
	SER  R30
	SER  R31
	SER  R22
	LDI  R23,0x7F
	BLD  R23,7
	RJMP __CFD15
__CFD17:
	CLR  R23
	TST  R21
	BREQ __CFD15
__CFD18:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R21
	BRNE __CFD18
	RJMP __CFD15
__CFD11:
	CLR  R23
__CFD12:
	CPI  R21,8
	BRLO __CFD13
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R23
	SUBI R21,8
	RJMP __CFD12
__CFD13:
	TST  R21
	BREQ __CFD15
__CFD14:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	DEC  R21
	BRNE __CFD14
__CFD15:
	TST  R0
	BRPL __CFD16
	RCALL __ANEGD1
__CFD16:
	POP  R21
	RET

__CDF1U:
	SET
	RJMP __CDF1U0
__CDF1:
	CLT
__CDF1U0:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __CDF10
	CLR  R0
	BRTS __CDF11
	TST  R23
	BRPL __CDF11
	COM  R0
	RCALL __ANEGD1
__CDF11:
	MOV  R1,R23
	LDI  R23,30
	TST  R1
__CDF12:
	BRMI __CDF13
	DEC  R23
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R1
	RJMP __CDF12
__CDF13:
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R1
	PUSH R21
	RCALL __REPACK
	POP  R21
__CDF10:
	RET

__SWAPACC:
	PUSH R20
	MOVW R20,R30
	MOVW R30,R26
	MOVW R26,R20
	MOVW R20,R22
	MOVW R22,R24
	MOVW R24,R20
	MOV  R20,R0
	MOV  R0,R1
	MOV  R1,R20
	POP  R20
	RET

__UADD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	RET

__NEGMAN1:
	COM  R30
	COM  R31
	COM  R22
	SUBI R30,-1
	SBCI R31,-1
	SBCI R22,-1
	RET

__SUBF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129
	LDI  R21,0x80
	EOR  R1,R21

	RJMP __ADDF120

__ADDF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129

__ADDF120:
	CPI  R23,0x80
	BREQ __ADDF128
__ADDF121:
	MOV  R21,R23
	SUB  R21,R25
	BRVS __ADDF1211
	BRPL __ADDF122
	RCALL __SWAPACC
	RJMP __ADDF121
__ADDF122:
	CPI  R21,24
	BRLO __ADDF123
	CLR  R26
	CLR  R27
	CLR  R24
__ADDF123:
	CPI  R21,8
	BRLO __ADDF124
	MOV  R26,R27
	MOV  R27,R24
	CLR  R24
	SUBI R21,8
	RJMP __ADDF123
__ADDF124:
	TST  R21
	BREQ __ADDF126
__ADDF125:
	LSR  R24
	ROR  R27
	ROR  R26
	DEC  R21
	BRNE __ADDF125
__ADDF126:
	MOV  R21,R0
	EOR  R21,R1
	BRMI __ADDF127
	RCALL __UADD12
	BRCC __ADDF129
	ROR  R22
	ROR  R31
	ROR  R30
	INC  R23
	BRVC __ADDF129
	RJMP __MAXRES
__ADDF128:
	RCALL __SWAPACC
__ADDF129:
	RCALL __REPACK
	POP  R21
	RET
__ADDF1211:
	BRCC __ADDF128
	RJMP __ADDF129
__ADDF127:
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	BREQ __ZERORES
	BRCC __ADDF1210
	COM  R0
	RCALL __NEGMAN1
__ADDF1210:
	TST  R22
	BRMI __ADDF129
	LSL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVC __ADDF1210

__ZERORES:
	CLR  R30
	CLR  R31
	CLR  R22
	CLR  R23
	POP  R21
	RET

__MINRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	SER  R23
	POP  R21
	RET

__MAXRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	LDI  R23,0x7F
	POP  R21
	RET

__MULF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BREQ __ZERORES
	CPI  R25,0x80
	BREQ __ZERORES
	EOR  R0,R1
	SEC
	ADC  R23,R25
	BRVC __MULF124
	BRLT __ZERORES
__MULF125:
	TST  R0
	BRMI __MINRES
	RJMP __MAXRES
__MULF124:
	PUSH R0
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R17
	CLR  R18
	CLR  R25
	MUL  R22,R24
	MOVW R20,R0
	MUL  R24,R31
	MOV  R19,R0
	ADD  R20,R1
	ADC  R21,R25
	MUL  R22,R27
	ADD  R19,R0
	ADC  R20,R1
	ADC  R21,R25
	MUL  R24,R30
	RCALL __MULF126
	MUL  R27,R31
	RCALL __MULF126
	MUL  R22,R26
	RCALL __MULF126
	MUL  R27,R30
	RCALL __MULF127
	MUL  R26,R31
	RCALL __MULF127
	MUL  R26,R30
	ADD  R17,R1
	ADC  R18,R25
	ADC  R19,R25
	ADC  R20,R25
	ADC  R21,R25
	MOV  R30,R19
	MOV  R31,R20
	MOV  R22,R21
	MOV  R21,R18
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	POP  R0
	TST  R22
	BRMI __MULF122
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	RJMP __MULF123
__MULF122:
	INC  R23
	BRVS __MULF125
__MULF123:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__MULF127:
	ADD  R17,R0
	ADC  R18,R1
	ADC  R19,R25
	RJMP __MULF128
__MULF126:
	ADD  R18,R0
	ADC  R19,R1
__MULF128:
	ADC  R20,R25
	ADC  R21,R25
	RET

__DIVF21:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BRNE __DIVF210
	TST  R1
__DIVF211:
	BRPL __DIVF219
	RJMP __MINRES
__DIVF219:
	RJMP __MAXRES
__DIVF210:
	CPI  R25,0x80
	BRNE __DIVF218
__DIVF217:
	RJMP __ZERORES
__DIVF218:
	EOR  R0,R1
	SEC
	SBC  R25,R23
	BRVC __DIVF216
	BRLT __DIVF217
	TST  R0
	RJMP __DIVF211
__DIVF216:
	MOV  R23,R25
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R1
	CLR  R17
	CLR  R18
	CLR  R19
	CLR  R20
	CLR  R21
	LDI  R25,32
__DIVF212:
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R20,R17
	BRLO __DIVF213
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R20,R17
	SEC
	RJMP __DIVF214
__DIVF213:
	CLC
__DIVF214:
	ROL  R21
	ROL  R18
	ROL  R19
	ROL  R1
	ROL  R26
	ROL  R27
	ROL  R24
	ROL  R20
	DEC  R25
	BRNE __DIVF212
	MOVW R30,R18
	MOV  R22,R1
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	TST  R22
	BRMI __DIVF215
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVS __DIVF217
__DIVF215:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__CMPF12:
	TST  R25
	BRMI __CMPF120
	TST  R23
	BRMI __CMPF121
	CP   R25,R23
	BRLO __CMPF122
	BRNE __CMPF121
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	BRLO __CMPF122
	BREQ __CMPF123
__CMPF121:
	CLZ
	CLC
	RET
__CMPF122:
	CLZ
	SEC
	RET
__CMPF123:
	SEZ
	CLC
	RET
__CMPF120:
	TST  R23
	BRPL __CMPF122
	CP   R25,R23
	BRLO __CMPF121
	BRNE __CMPF122
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	BRLO __CMPF122
	BREQ __CMPF123
	RJMP __CMPF121

__ADDW2R15:
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	RET

__ADDD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	ADC  R23,R25
	RET

__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
	RET

__ANEGD1:
	COM  R31
	COM  R22
	COM  R23
	NEG  R30
	SBCI R31,-1
	SBCI R22,-1
	SBCI R23,-1
	RET

__ASRW8:
	MOV  R30,R31
	CLR  R31
	SBRC R30,7
	SER  R31
	RET

__CBD1:
	MOV  R31,R30
	ADD  R31,R31
	SBC  R31,R31
	MOV  R22,R31
	MOV  R23,R31
	RET

__CWD1:
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	RET

__CWD2:
	MOV  R24,R27
	ADD  R24,R24
	SBC  R24,R24
	MOV  R25,R24
	RET

__MULD12U:
	MUL  R23,R26
	MOV  R23,R0
	MUL  R22,R27
	ADD  R23,R0
	MUL  R31,R24
	ADD  R23,R0
	MUL  R30,R25
	ADD  R23,R0
	MUL  R22,R26
	MOV  R22,R0
	ADD  R23,R1
	MUL  R31,R27
	ADD  R22,R0
	ADC  R23,R1
	MUL  R30,R24
	ADD  R22,R0
	ADC  R23,R1
	CLR  R24
	MUL  R31,R26
	MOV  R31,R0
	ADD  R22,R1
	ADC  R23,R24
	MUL  R30,R27
	ADD  R31,R0
	ADC  R22,R1
	ADC  R23,R24
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	ADC  R22,R24
	ADC  R23,R24
	RET

__MULB1W2U:
	MOV  R22,R30
	MUL  R22,R26
	MOVW R30,R0
	MUL  R22,R27
	ADD  R31,R0
	RET

__MULD12:
	RCALL __CHKSIGND
	RCALL __MULD12U
	BRTC __MULD121
	RCALL __ANEGD1
__MULD121:
	RET

__DIVB21U:
	CLR  R0
	LDI  R25,8
__DIVB21U1:
	LSL  R26
	ROL  R0
	SUB  R0,R30
	BRCC __DIVB21U2
	ADD  R0,R30
	RJMP __DIVB21U3
__DIVB21U2:
	SBR  R26,1
__DIVB21U3:
	DEC  R25
	BRNE __DIVB21U1
	MOV  R30,R26
	MOV  R26,R0
	RET

__DIVB21:
	RCALL __CHKSIGNB
	RCALL __DIVB21U
	BRTC __DIVB211
	NEG  R30
__DIVB211:
	RET

__DIVD21U:
	PUSH R19
	PUSH R20
	PUSH R21
	CLR  R0
	CLR  R1
	CLR  R20
	CLR  R21
	LDI  R19,32
__DIVD21U1:
	LSL  R26
	ROL  R27
	ROL  R24
	ROL  R25
	ROL  R0
	ROL  R1
	ROL  R20
	ROL  R21
	SUB  R0,R30
	SBC  R1,R31
	SBC  R20,R22
	SBC  R21,R23
	BRCC __DIVD21U2
	ADD  R0,R30
	ADC  R1,R31
	ADC  R20,R22
	ADC  R21,R23
	RJMP __DIVD21U3
__DIVD21U2:
	SBR  R26,1
__DIVD21U3:
	DEC  R19
	BRNE __DIVD21U1
	MOVW R30,R26
	MOVW R22,R24
	MOVW R26,R0
	MOVW R24,R20
	POP  R21
	POP  R20
	POP  R19
	RET

__MODB21:
	CLT
	SBRS R26,7
	RJMP __MODB211
	NEG  R26
	SET
__MODB211:
	SBRC R30,7
	NEG  R30
	RCALL __DIVB21U
	MOV  R30,R26
	BRTC __MODB212
	NEG  R30
__MODB212:
	RET

__MODD21U:
	RCALL __DIVD21U
	MOVW R30,R26
	MOVW R22,R24
	RET

__CHKSIGNB:
	CLT
	SBRS R30,7
	RJMP __CHKSB1
	NEG  R30
	SET
__CHKSB1:
	SBRS R26,7
	RJMP __CHKSB2
	NEG  R26
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSB2:
	RET

__CHKSIGND:
	CLT
	SBRS R23,7
	RJMP __CHKSD1
	RCALL __ANEGD1
	SET
__CHKSD1:
	SBRS R25,7
	RJMP __CHKSD2
	CLR  R0
	COM  R26
	COM  R27
	COM  R24
	COM  R25
	ADIW R26,1
	ADC  R24,R0
	ADC  R25,R0
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSD2:
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__GETD1P:
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X
	SBIW R26,3
	RET

__GETD1P_INC:
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X+
	RET

__PUTDP1:
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	RET

__PUTDP1_DEC:
	ST   -X,R23
	ST   -X,R22
	ST   -X,R31
	ST   -X,R30
	RET

__GETD1S0:
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R22,Y+2
	LDD  R23,Y+3
	RET

__GETD2S0:
	LD   R26,Y
	LDD  R27,Y+1
	LDD  R24,Y+2
	LDD  R25,Y+3
	RET

__PUTD1S0:
	ST   Y,R30
	STD  Y+1,R31
	STD  Y+2,R22
	STD  Y+3,R23
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__CDF2U:
	SET
	RJMP __CDF2U0
__CDF2:
	CLT
__CDF2U0:
	RCALL __SWAPD12
	RCALL __CDF1U0

__SWAPD12:
	MOV  R1,R24
	MOV  R24,R22
	MOV  R22,R1
	MOV  R1,R25
	MOV  R25,R23
	MOV  R23,R1

__SWAPW12:
	MOV  R1,R27
	MOV  R27,R31
	MOV  R31,R1

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
	RET

__CPD10:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	RET

__CPW02:
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__INITLOCW:
	ADD  R26,R28
	ADC  R27,R29
__INITLOC0:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __INITLOC0
	RET

;END OF CODE MARKER
__END_OF_CODE:
