
;CodeVisionAVR C Compiler V2.05.0 Professional
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega128
;Program type             : Application
;Clock frequency          : 14.745600 MHz
;Memory model             : Small
;Optimize for             : Size
;(s)printf features       : float, width, precision
;(s)scanf features        : int, width
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

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _TIMER2_OVERFLOW=R5
	.DEF _PACKET_BUFF_IDX=R4
	.DEF _TIMER0_OVERFLOW=R6
	.DEF _VELOCITY_BUFF_IDX=R9
	.DEF _SRF02_CONVERTING_FLAG=R8
	.DEF _SRF02_WAIT_FLAG=R11
	.DEF _CHECK_GETS=R10

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
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer2_comp
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer1_compb
	JMP  0x00
	JMP  _timer0_comp
	JMP  0x00
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

_0x7D:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0xE0,0xE2,0xE4,0xE6
	.DB  0xE8,0xEA,0xEC,0xEE,0x0,0x0,0x0,0x0
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
_0x86:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
_0x0:
	.DB  0x3C,0x25,0x64,0x2C,0x25,0x64,0x3E,0x0
	.DB  0x3C,0x25,0x2E,0x32,0x66,0x2C,0x25,0x2E
	.DB  0x66,0x32,0x3E,0x0
_0x2000000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0
_0x2080060:
	.DB  0x1
_0x2080000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x08
	.DW  0x04
	.DW  _0x86*2

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
;
;#define bps_115200 0x0007
;
;#define POLYNORMIAL 0xA001
;
;#define CHARACTER3_5 60 // 0.03msec
;#define TRUE 0
;#define FALSE 1
;
;#define R 0x01
;#define L 0x02
;#define START 1
;#define STOP 2
;
;#define Length 0.29
;#define Gearratio 25
;
;//////////US/////////////////
;#define Inches 0x50
;#define Centimeters 0x51
;#define microSec 0x52
;
;#define tau 0.1 //LOWPASS_FILTER
;#define ts 0.7//SAMPLING CYCLE
;
;#define CommandReg 0
;#define Unused 1
;#define RangeHighByte 2
;#define RangeLowByte 3
;
;#define TWI_START 0x08
;#define MT_REPEATED_START 0x10
;#define MT_SLAW_ACK 0x18
;#define MT_DATA_ACK 0x28
;#define MT_SLAR_ACK 0x40
;#define MT_DATA_NACK 0x58
;
;//////////////////////integer////////////////
;unsigned char TIMER2_OVERFLOW = 0;
;unsigned char PACKET_BUFF[100] = {0,};
;unsigned char PACKET_BUFF_IDX = 0;
;
;unsigned int TIMER0_OVERFLOW = 0;
;unsigned char VELOCITY_BUFF[20] = {0,};
;unsigned char VELOCITY_BUFF_IDX = 0;
;
;///////////////FLAG//////////////////////
;unsigned char SRF02_CONVERTING_FLAG = 0;
;unsigned char SRF02_WAIT_FLAG = 0;
;unsigned char CHECK_GETS = 0;
;
;////////////////init function/////////////
;void usart1_init(int bps)
; 0000 0039 {

	.CSEG
_usart1_init:
; 0000 003A     UCSR1A = 0x00;
;	bps -> Y+0
	LDI  R30,LOW(0)
	STS  155,R30
; 0000 003B     UCSR1B = (1<<RXEN1)|(1<<TXEN1)|(1<<RXCIE1); // RXCIE1 bit is recevie interrupt allow
	LDI  R30,LOW(152)
	STS  154,R30
; 0000 003C     UCSR1C = (1<<UCSZ11)|(1<<UCSZ10);
	LDI  R30,LOW(6)
	STS  157,R30
; 0000 003D     UCSR1C &= ~(1<<UMSEL1);
	LDS  R30,157
	ANDI R30,0xBF
	STS  157,R30
; 0000 003E 
; 0000 003F     UBRR1H = (unsigned char)((bps>>8)  & 0x00ff);
	LD   R30,Y
	LDD  R31,Y+1
	CALL __ASRW8
	STS  152,R30
; 0000 0040     UBRR1L = (unsigned char)(bps & 0x00ff);
	LD   R30,Y
	STS  153,R30
; 0000 0041 }
	RJMP _0x20A000C
;
;void usart0_init(int bps)
; 0000 0044 {
_usart0_init:
; 0000 0045     UCSR0A = 0x00;
;	bps -> Y+0
	LDI  R30,LOW(0)
	OUT  0xB,R30
; 0000 0046     UCSR0B = (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0); // RXCIE1 bit is recevie interrupt allow
	LDI  R30,LOW(152)
	OUT  0xA,R30
; 0000 0047     UCSR0C = (1<<UCSZ01)|(1<<UCSZ00);
	LDI  R30,LOW(6)
	STS  149,R30
; 0000 0048     UCSR0C &= ~(1<<UMSEL0);
	LDS  R30,149
	ANDI R30,0xBF
	STS  149,R30
; 0000 0049 
; 0000 004A     UBRR0H = (unsigned char)((bps>>8)  & 0x00ff);
	LD   R30,Y
	LDD  R31,Y+1
	CALL __ASRW8
	STS  144,R30
; 0000 004B     UBRR0L = (unsigned char)(bps & 0x00ff);
	LD   R30,Y
	OUT  0x9,R30
; 0000 004C }
_0x20A000C:
	ADIW R28,2
	RET
;
;void timer0_init(void)
; 0000 004F {
; 0000 0050     TCCR0 = (1<<WGM01)|(1<<CS02)|(1<<CS01)|(1<<CS00); // CTC모드, 1024분주
; 0000 0051     OCR0 = 40;
; 0000 0052     TIMSK = (1<<OCIE2)|(1<<OCIE0);
; 0000 0053 }
;
;void timer1_init(void)
; 0000 0056 {
; 0000 0057     // TCCR1A = (1<<COM1B0);
; 0000 0058     TCCR1B = (1<<WGM13)|(1<<WGM12)|(1<<CS12)|(1<<CS10);; // WGM bit setting
; 0000 0059 
; 0000 005A     OCR1B = 1008;
; 0000 005B     ICR1 = 1200;//1200; //664
; 0000 005C     TIMSK |= (1<<OCIE1B);
; 0000 005D }
;
;void timer2_init(void)
; 0000 0060 {
_timer2_init:
; 0000 0061     //TIMER2
; 0000 0062     TCCR2 = (1<<WGM21)|(1<<CS21)|(1<<CS20);// CTC모드, 1분주
	LDI  R30,LOW(11)
	OUT  0x25,R30
; 0000 0063 
; 0000 0064     OCR2 = 100;
	LDI  R30,LOW(100)
	OUT  0x23,R30
; 0000 0065     TIMSK = (1<<OCIE2)|(1<<OCIE0);
	LDI  R30,LOW(130)
	OUT  0x37,R30
; 0000 0066     //TIMSK = (1<<OCIE2);
; 0000 0067 }
	RET
;
;void TWI_Init(){
; 0000 0069 void TWI_Init(){
; 0000 006A     TWBR = 10;
; 0000 006B     TWSR = 0;
; 0000 006C     TWCR = 0;
; 0000 006D }
;
;
;////////////////////USART RTX/////////////////////////////////
;void putch_USART1(char data)
; 0000 0072 {
_putch_USART1:
; 0000 0073     while(!(UCSR1A & (1<<UDRE1))); // UDRE flag is USART Data Register Empty
;	data -> Y+0
_0x3:
	LDS  R30,155
	ANDI R30,LOW(0x20)
	BREQ _0x3
; 0000 0074     UDR1 = data;
	LD   R30,Y
	STS  156,R30
; 0000 0075 }
	RJMP _0x20A000B
;
;//USART 문자열 송신
;void puts_USART1(char *str,char IDX)
; 0000 0079 {
_puts_USART1:
; 0000 007A     unsigned char i = 0;
; 0000 007B 
; 0000 007C     for(i = 0;i<IDX;i++)
	ST   -Y,R17
;	*str -> Y+2
;	IDX -> Y+1
;	i -> R17
	LDI  R17,0
	LDI  R17,LOW(0)
_0x7:
	LDD  R30,Y+1
	CP   R17,R30
	BRSH _0x8
; 0000 007D     {
; 0000 007E         putch_USART1(*(str+i));
	CALL SUBOPT_0x0
	LD   R30,X
	ST   -Y,R30
	RCALL _putch_USART1
; 0000 007F     }
	SUBI R17,-1
	RJMP _0x7
_0x8:
; 0000 0080 
; 0000 0081     for(i = 0; i<IDX; i++)
	LDI  R17,LOW(0)
_0xA:
	LDD  R30,Y+1
	CP   R17,R30
	BRSH _0xB
; 0000 0082     {
; 0000 0083         *(str+i) = 0;
	CALL SUBOPT_0x0
	LDI  R30,LOW(0)
	ST   X,R30
; 0000 0084     }
	SUBI R17,-1
	RJMP _0xA
_0xB:
; 0000 0085 }
	LDD  R17,Y+0
	ADIW R28,4
	RET
;
;// void puts_USART1(char *str,char IDX)
;// {
;//     unsigned char i = 0;
;
;//     while(*str != 0)
;//     {
;//         putch_USART1(*(str+i));
;//         i++;
;//     }
;
;//     for(i = 0; i<IDX; i++)
;//     {
;//         *(str+i) = 0;
;//     }
;// }
;
;/////////////////////////////////////MOTOR///////////////////////////////////////
;void puts_Modbus1(char *str,char IDX)
; 0000 0099 {
; 0000 009A     unsigned char i = 0;
; 0000 009B     UCSR0B &= ~(1<<RXEN0);
;	*str -> Y+2
;	IDX -> Y+1
;	i -> R17
; 0000 009C     if(TIMER2_OVERFLOW>0)
; 0000 009D     {
; 0000 009E         for(i = 0;i<IDX-1;i++) putch_USART1(*(str+i));
; 0000 00A0 for(i = 0; i<IDX; i++) *(str+i) = 0;
; 0000 00A1 }
; 0000 00A2     UCSR0B |= (1<<RXEN0);
; 0000 00A3 }
;
;void putch_USART0(char data)
; 0000 00A6 {
_putch_USART0:
; 0000 00A7     while(!(UCSR0A & (1<<UDRE0))); // UDRE flag is USART Data Register Empty
;	data -> Y+0
_0x13:
	SBIS 0xB,5
	RJMP _0x13
; 0000 00A8     UDR0 = data;
	LD   R30,Y
	OUT  0xC,R30
; 0000 00A9 }
_0x20A000B:
	ADIW R28,1
	RET
;
;void puts_USART0(char *str,char IDX)
; 0000 00AC {
; 0000 00AD     //PACKET_BUFF[PACKET_BUFF_IDX] = 0;
; 0000 00AE     unsigned char i = 0;
; 0000 00AF     for(i = 0;i<IDX-1;i++)
;	*str -> Y+2
;	IDX -> Y+1
;	i -> R17
; 0000 00B0     {
; 0000 00B1         putch_USART1(*(str+i));
; 0000 00B2     }
; 0000 00B3 
; 0000 00B4     for(i = 0; i<IDX; i++)
; 0000 00B5     {
; 0000 00B6         *(str+i) = 0;
; 0000 00B7     }
; 0000 00B8 }
;
;///////////////////////Modbus///////////////////////////////////////
;unsigned short CRC16(unsigned char *puchMsg, int usDataLen)
; 0000 00BC {
_CRC16:
; 0000 00BD     int i;
; 0000 00BE     unsigned short crc, flag;
; 0000 00BF     crc = 0xffff;
	CALL __SAVELOCR6
;	*puchMsg -> Y+8
;	usDataLen -> Y+6
;	i -> R16,R17
;	crc -> R18,R19
;	flag -> R20,R21
	__GETWRN 18,19,-1
; 0000 00C0 
; 0000 00C1     while(usDataLen--){
_0x1C:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SBIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	ADIW R30,1
	BREQ _0x1E
; 0000 00C2         crc ^= *puchMsg++;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LD   R30,X+
	STD  Y+8,R26
	STD  Y+8+1,R27
	LDI  R31,0
	__EORWRR 18,19,30,31
; 0000 00C3 
; 0000 00C4         for (i=0; i<8; i++){
	__GETWRN 16,17,0
_0x20:
	__CPWRN 16,17,8
	BRGE _0x21
; 0000 00C5             flag = crc & 0x0001;
	MOVW R30,R18
	ANDI R30,LOW(0x1)
	ANDI R31,HIGH(0x1)
	MOVW R20,R30
; 0000 00C6             crc >>= 1;
	LSR  R19
	ROR  R18
; 0000 00C7             if(flag) crc ^= POLYNORMIAL;
	MOV  R0,R20
	OR   R0,R21
	BREQ _0x22
	LDI  R30,LOW(40961)
	LDI  R31,HIGH(40961)
	__EORWRR 18,19,30,31
; 0000 00C8         }
_0x22:
	__ADDWRN 16,17,1
	RJMP _0x20
_0x21:
; 0000 00C9     }
	RJMP _0x1C
_0x1E:
; 0000 00CA     return crc;
	MOVW R30,R18
	CALL __LOADLOCR6
	ADIW R28,10
	RET
; 0000 00CB }
;
;int RTU_WriteOperate0(char device_address,int starting_address,int data)
; 0000 00CE {
_RTU_WriteOperate0:
; 0000 00CF     char protocol[8];
; 0000 00D0     unsigned short crc16;
; 0000 00D1     int i=0;
; 0000 00D2     //PACKET_BUFF_IDX = 0;
; 0000 00D3 
; 0000 00D4     protocol[0]=device_address;
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
; 0000 00D5     protocol[1]=0x06;
	LDI  R30,LOW(6)
	STD  Y+5,R30
; 0000 00D6     protocol[2]=((starting_address>>8)  & 0x00ff);
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	CALL __ASRW8
	STD  Y+6,R30
; 0000 00D7     protocol[3]=((starting_address)     & 0x00ff);
	LDD  R30,Y+14
	STD  Y+7,R30
; 0000 00D8     protocol[4]=((data>>8)              & 0x00ff);
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	CALL __ASRW8
	STD  Y+8,R30
; 0000 00D9     protocol[5]=((data)                 & 0x00ff);
	LDD  R30,Y+12
	STD  Y+9,R30
; 0000 00DA     protocol[6]=0;
	LDI  R30,LOW(0)
	STD  Y+10,R30
; 0000 00DB     protocol[7]=0;
	STD  Y+11,R30
; 0000 00DC 
; 0000 00DD     crc16 = CRC16(protocol, 6);
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
; 0000 00DE 
; 0000 00DF     protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
	MOVW R30,R16
	STD  Y+10,R30
; 0000 00E0     protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
	__PUTBSR 17,11
; 0000 00E1 
; 0000 00E2 
; 0000 00E3     for(i=0;i<8;i++)
	__GETWRN 18,19,0
_0x24:
	__CPWRN 18,19,8
	BRGE _0x25
; 0000 00E4     {
; 0000 00E5         putch_USART0(*(protocol+i));
	MOVW R26,R28
	ADIW R26,4
	ADD  R26,R18
	ADC  R27,R19
	LD   R30,X
	ST   -Y,R30
	RCALL _putch_USART0
; 0000 00E6     }
	__ADDWRN 18,19,1
	RJMP _0x24
_0x25:
; 0000 00E7 }
	CALL __LOADLOCR4
	ADIW R28,17
	RET
;
;int RTU_WriteOperate1(char device_address,int starting_address,int data)
; 0000 00EA {
; 0000 00EB     char protocol[8];
; 0000 00EC     unsigned short crc16;
; 0000 00ED     int i=0;
; 0000 00EE    // PACKET_BUFF_IDX = 0;
; 0000 00EF 
; 0000 00F0     protocol[0]=device_address;
;	device_address -> Y+16
;	starting_address -> Y+14
;	data -> Y+12
;	protocol -> Y+4
;	crc16 -> R16,R17
;	i -> R18,R19
; 0000 00F1     protocol[1]=0x06;
; 0000 00F2     protocol[2]=((starting_address>>8)  & 0x00ff);
; 0000 00F3     protocol[3]=((starting_address)     & 0x00ff);
; 0000 00F4     protocol[4]=((data>>8)              & 0x00ff);
; 0000 00F5     protocol[5]=((data)                 & 0x00ff);
; 0000 00F6     protocol[6]=0;
; 0000 00F7     protocol[7]=0;
; 0000 00F8 
; 0000 00F9     crc16 = CRC16(protocol, 6);
; 0000 00FA 
; 0000 00FB     protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
; 0000 00FC     protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
; 0000 00FD 
; 0000 00FE 
; 0000 00FF     for(i=0;i<8;i++)
; 0000 0100     {
; 0000 0101         putch_USART1(*(protocol+i));
; 0000 0102     }
; 0000 0103 }
;
;int RTU_ReedOperate0(char device_address,int starting_address,int data)
; 0000 0106 {
; 0000 0107     char protocol[8];
; 0000 0108     unsigned short crc16;
; 0000 0109     int i=0;
; 0000 010A     //PACKET_BUFF_IDX = 0;
; 0000 010B 
; 0000 010C     protocol[0]=device_address;
;	device_address -> Y+16
;	starting_address -> Y+14
;	data -> Y+12
;	protocol -> Y+4
;	crc16 -> R16,R17
;	i -> R18,R19
; 0000 010D     protocol[1]=0x03;
; 0000 010E     protocol[2]=((starting_address>>8)  & 0x00ff);
; 0000 010F     protocol[3]=((starting_address)     & 0x00ff);
; 0000 0110     protocol[4]=((data>>8)              & 0x00ff);
; 0000 0111     protocol[5]=((data)                 & 0x00ff);
; 0000 0112     protocol[6]=0;
; 0000 0113     protocol[7]=0;
; 0000 0114 
; 0000 0115     crc16 = CRC16(protocol, 6);
; 0000 0116 
; 0000 0117     protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
; 0000 0118     protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
; 0000 0119 
; 0000 011A 
; 0000 011B     for(i=0;i<8;i++)
; 0000 011C     {
; 0000 011D         putch_USART0(*(protocol+i));
; 0000 011E     }
; 0000 011F }
;
;void Make_MSPEED(float* _velocity, float* _angularV, int* R_RPM, int* L_RPM)
; 0000 0122 {
_Make_MSPEED:
; 0000 0123     float VelocityR = 0;
; 0000 0124     float VelocityL = 0;
; 0000 0125 
; 0000 0126     if(*_velocity>=0){
	SBIW R28,8
	CALL SUBOPT_0x1
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
	CALL SUBOPT_0x2
	TST  R23
	BRMI _0x2C
; 0000 0127         *_angularV = -(*_angularV);
	CALL SUBOPT_0x3
	CALL __ANEGF1
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL __PUTDP1
; 0000 0128     }
; 0000 0129 
; 0000 012A     VelocityR = *_velocity+(*_angularV*Length)/4;
_0x2C:
	CALL SUBOPT_0x2
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x3
	CALL SUBOPT_0x4
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDF12
	CALL SUBOPT_0x5
; 0000 012B     VelocityL = *_velocity-(*_angularV*Length)/4;
	CALL SUBOPT_0x2
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x3
	CALL SUBOPT_0x4
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL SUBOPT_0x6
	CALL __PUTD1S0
; 0000 012C 
; 0000 012D     *R_RPM = (int)(152.788*VelocityR*Gearratio);
	CALL SUBOPT_0x7
	CALL SUBOPT_0x8
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ST   X+,R30
	ST   X,R31
; 0000 012E     *L_RPM = (int)(152.788*VelocityL*Gearratio);
	CALL SUBOPT_0x9
	CALL SUBOPT_0x8
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ST   X+,R30
	ST   X,R31
; 0000 012F 
; 0000 0130     if( ((*R_RPM<300)&&(*R_RPM>-300))&&((*L_RPM<300)&&(*L_RPM>-300))){
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __GETW1P
	CPI  R30,LOW(0x12C)
	LDI  R26,HIGH(0x12C)
	CPC  R31,R26
	BRGE _0x2E
	MOVW R26,R30
	LDI  R30,LOW(65236)
	LDI  R31,HIGH(65236)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x2F
_0x2E:
	RJMP _0x30
_0x2F:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	CPI  R30,LOW(0x12C)
	LDI  R26,HIGH(0x12C)
	CPC  R31,R26
	BRGE _0x31
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	MOVW R26,R30
	LDI  R30,LOW(65236)
	LDI  R31,HIGH(65236)
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x32
_0x31:
	RJMP _0x30
_0x32:
	RJMP _0x33
_0x30:
	RJMP _0x2D
_0x33:
; 0000 0131         *R_RPM = 0;
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL SUBOPT_0xA
; 0000 0132         *L_RPM = 0;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL SUBOPT_0xA
; 0000 0133     }
; 0000 0134 }
_0x2D:
	RJMP _0x20A000A
;void oper_Disapath(int velocityR, int velocityL, int p_velocity_R, int p_velocity_L)
; 0000 0136 {
; 0000 0137     if((p_velocity_R==0) && (velocityR != 0))
;	velocityR -> Y+6
;	velocityL -> Y+4
;	p_velocity_R -> Y+2
;	p_velocity_L -> Y+0
; 0000 0138     {
; 0000 0139         RTU_WriteOperate0(R,(unsigned int)120,START);
; 0000 013A         delay_ms(5);
; 0000 013B     }
; 0000 013C     else if((p_velocity_R!=0) && (velocityR == 0))
; 0000 013D     {
; 0000 013E         RTU_WriteOperate0(R,(unsigned int)120,STOP);
; 0000 013F         delay_ms(5);
; 0000 0140     }
; 0000 0141     if((p_velocity_L==0) && (velocityL != 0))
; 0000 0142     {
; 0000 0143         RTU_WriteOperate0(L,(unsigned int)120,START);
; 0000 0144         delay_ms(5);
; 0000 0145     }
; 0000 0146     else if((p_velocity_L!=0) && (velocityL == 0))
; 0000 0147     {
; 0000 0148         RTU_WriteOperate0(L,(unsigned int)120,STOP);
; 0000 0149         delay_ms(5);
; 0000 014A     }
; 0000 014B }
;
;////////////////////////////////////TWI_Ultra_Sonic//////////////////////////////////////////////////
;
;unsigned char TWI_Read(unsigned char addr, unsigned char regAddr)
; 0000 0150 {
; 0000 0151     unsigned char Data;
; 0000 0152     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));//Start조건 전송
;	addr -> Y+2
;	regAddr -> Y+1
;	Data -> R17
; 0000 0153     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));
; 0000 0154 
; 0000 0155     TWDR = addr&(~0x01);                //쓰기 위한 주소 전송
; 0000 0156     TWCR = ((1<<TWINT)|(1<<TWEN));
; 0000 0157     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK));
; 0000 0158 
; 0000 0159     TWDR = regAddr;                     //Reg주소 전송
; 0000 015A     TWCR = ((1<<TWINT)|(1<<TWEN));
; 0000 015B     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
; 0000 015C 
; 0000 015D     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA)); //Repeated start 전송
; 0000 015E     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_REPEATED_START));
; 0000 015F 
; 0000 0160     TWDR = addr|0x01;                       //읽기 위한 주소 전송
; 0000 0161     TWCR = ((1<<TWINT)|(1<<TWEN));
; 0000 0162     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAR_ACK));
; 0000 0163 
; 0000 0164 
; 0000 0165     TWCR = ((1<<TWINT)|(1<<TWEN));
; 0000 0166     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_NACK));
; 0000 0167     Data = TWDR;                        //Data읽기
; 0000 0168 
; 0000 0169     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO));
; 0000 016A 
; 0000 016B     return Data;
; 0000 016C }
;
;void TWI_Write(unsigned char addr, unsigned char Data[],int NumberOfData)
; 0000 016F {
; 0000 0170     int i=0;
; 0000 0171 
; 0000 0172     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));
;	addr -> Y+6
;	Data -> Y+4
;	NumberOfData -> Y+2
;	i -> R16,R17
; 0000 0173     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));
; 0000 0174 
; 0000 0175     TWDR = addr&(~0x01);
; 0000 0176     TWCR = ((1<<TWINT)|(1<<TWEN));
; 0000 0177     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK));
; 0000 0178 
; 0000 0179     for(i=0;i<NumberOfData;i++){
; 0000 017A         TWDR = Data[i];
; 0000 017B         TWCR = ((1<<TWINT)|(1<<TWEN));
; 0000 017C         while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
; 0000 017D     }
; 0000 017E 
; 0000 017F     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO));
; 0000 0180 }
;
;void Start_SRF02_Conv(unsigned char Adress, unsigned char mode){
; 0000 0182 void Start_SRF02_Conv(unsigned char Adress, unsigned char mode){
; 0000 0183     unsigned char ConvMode[2] = {0x00,};
; 0000 0184     ConvMode[1] = mode;
;	Adress -> Y+3
;	mode -> Y+2
;	ConvMode -> Y+0
; 0000 0185     TWI_Write(Adress,ConvMode,2);
; 0000 0186 }
;
;unsigned int Get_SRF02_Range(unsigned char Adress)
; 0000 0189 {
; 0000 018A     unsigned int range;
; 0000 018B     unsigned char High = 0,Low = 0;
; 0000 018C 
; 0000 018D     High = TWI_Read(Adress, RangeHighByte);
;	Adress -> Y+4
;	range -> R16,R17
;	High -> R19
;	Low -> R18
; 0000 018E     if(High == 0xFF){
; 0000 018F         return 0;
; 0000 0190     }
; 0000 0191     Low = TWI_Read(Adress, RangeLowByte);
; 0000 0192     range = (High<<8)+Low;
; 0000 0193 
; 0000 0194     return range;
; 0000 0195 }
;
;/////////////////////ISR//////////////////////////////////
;
;interrupt [USART0_RXC] void usart0_rxc(void)
; 0000 019A {
_usart0_rxc:
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
; 0000 019B     if(((TCNT2 < CHARACTER3_5) && (TIMER2_OVERFLOW == 0)) || PACKET_BUFF_IDX == 0)
	IN   R30,0x24
	CPI  R30,LOW(0x3C)
	BRSH _0x74
	LDI  R30,LOW(0)
	CP   R30,R5
	BREQ _0x76
_0x74:
	LDI  R30,LOW(0)
	CP   R30,R4
	BRNE _0x73
_0x76:
; 0000 019C     {
; 0000 019D         PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
	CALL SUBOPT_0xB
; 0000 019E         PACKET_BUFF_IDX++;
; 0000 019F         TCNT2 = 0;
; 0000 01A0     }
; 0000 01A1     else {
	RJMP _0x78
_0x73:
; 0000 01A2         PACKET_BUFF_IDX = 0;
	CLR  R4
; 0000 01A3         PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
	CALL SUBOPT_0xB
; 0000 01A4         PACKET_BUFF_IDX++;
; 0000 01A5         TCNT2 = 0;
; 0000 01A6         TIMER2_OVERFLOW = 0;
	CLR  R5
; 0000 01A7     }
_0x78:
; 0000 01A8 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
;
;interrupt [USART1_RXC] void usart1_rxc(void)
; 0000 01AB {
_usart1_rxc:
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 01AC     unsigned char i = 0;
; 0000 01AD     i = UDR1;
	ST   -Y,R17
;	i -> R17
	LDI  R17,0
	LDS  R17,156
; 0000 01AE     if(i == '<'){
	CPI  R17,60
	BRNE _0x79
; 0000 01AF         VELOCITY_BUFF_IDX = 0;
	CLR  R9
; 0000 01B0         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
	CALL SUBOPT_0xC
; 0000 01B1         VELOCITY_BUFF_IDX++;
; 0000 01B2         CHECK_GETS = 1;
	LDI  R30,LOW(1)
	MOV  R10,R30
; 0000 01B3     }
; 0000 01B4     else if(i == '>'){
	RJMP _0x7A
_0x79:
	CPI  R17,62
	BRNE _0x7B
; 0000 01B5         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
	CALL SUBOPT_0xC
; 0000 01B6         VELOCITY_BUFF_IDX++;
; 0000 01B7         CHECK_GETS = 0;
	CLR  R10
; 0000 01B8     }
; 0000 01B9     else{
	RJMP _0x7C
_0x7B:
; 0000 01BA         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
	CALL SUBOPT_0xC
; 0000 01BB         VELOCITY_BUFF_IDX++;
; 0000 01BC     }
_0x7C:
_0x7A:
; 0000 01BD }
	LD   R17,Y+
	RJMP _0x85
;
;interrupt [TIM2_COMP] void timer2_comp(void)
; 0000 01C0 {
_timer2_comp:
	ST   -Y,R30
	IN   R30,SREG
; 0000 01C1     TIMER2_OVERFLOW++;
	INC  R5
; 0000 01C2 }
	OUT  SREG,R30
	LD   R30,Y+
	RETI
;
;interrupt [TIM0_COMP] void timer0_comp(void)
; 0000 01C5 {
_timer0_comp:
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 01C6     TIMER0_OVERFLOW++;
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
; 0000 01C7 }
_0x85:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	RETI
;
;interrupt [TIM1_COMPB] void timer1_compb(void)
; 0000 01CA {
_timer1_compb:
	ST   -Y,R30
; 0000 01CB     SRF02_CONVERTING_FLAG = 1;
	LDI  R30,LOW(1)
	MOV  R8,R30
; 0000 01CC }
	LD   R30,Y+
	RETI
;
;void main(void)
; 0000 01CF {
_main:
; 0000 01D0     float a_buff;
; 0000 01D1     float v_buff;
; 0000 01D2 
; 0000 01D3     int velocity = 0;
; 0000 01D4     int angularV = 0;
; 0000 01D5     int velocity_R = 0;
; 0000 01D6     int velocity_L = 0;
; 0000 01D7     int past_velocity_R = 0;
; 0000 01D8     int past_velocity_L = 0;
; 0000 01D9 
; 0000 01DA     float robot_position_x = 0;
; 0000 01DB     float robot_position_y = 0;
; 0000 01DC     unsigned char BUFF[100] = {0,};
; 0000 01DD 
; 0000 01DE     /////////////////Ultra sonic/////////////////////////
; 0000 01DF     unsigned char USID[10] = {0xE0, 0xE2, 0xE4, 0xE6, 0xE8, 0xEA, 0xEC, 0xEE};
; 0000 01E0     unsigned char us_range[10] = {0,};
; 0000 01E1     unsigned char pre_us_range[10] = {0,};
; 0000 01E2 
; 0000 01E3     usart1_init(bps_115200);
	SBIW R28,63
	SBIW R28,63
	SBIW R28,26
	LDI  R24,144
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0x7D*2)
	LDI  R31,HIGH(_0x7D*2)
	CALL __INITLOCB
;	a_buff -> Y+148
;	v_buff -> Y+144
;	velocity -> R16,R17
;	angularV -> R18,R19
;	velocity_R -> R20,R21
;	velocity_L -> Y+142
;	past_velocity_R -> Y+140
;	past_velocity_L -> Y+138
;	robot_position_x -> Y+134
;	robot_position_y -> Y+130
;	BUFF -> Y+30
;	USID -> Y+20
;	us_range -> Y+10
;	pre_us_range -> Y+0
	__GETWRN 16,17,0
	__GETWRN 18,19,0
	__GETWRN 20,21,0
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _usart1_init
; 0000 01E4     usart0_init(bps_115200);
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _usart0_init
; 0000 01E5     timer2_init();
	RCALL _timer2_init
; 0000 01E6     SREG |= 0x80;
	BSET 7
; 0000 01E7 
; 0000 01E8     delay_ms(5000);
	LDI  R30,LOW(5000)
	LDI  R31,HIGH(5000)
	CALL SUBOPT_0xD
; 0000 01E9 
; 0000 01EA     // SRF02_CONVERTING_FLAG = 0;
; 0000 01EB     while(1)
_0x7E:
; 0000 01EC     {
; 0000 01ED         // if(SRF02_WAIT_FLAG == 0){
; 0000 01EE         //     Start_SRF02_Conv(USID[0],Centimeters);
; 0000 01EF         //     TCNT1H = 0;
; 0000 01F0         //     TCNT1L = 0;
; 0000 01F1         //     SRF02_WAIT_FLAG = 1;
; 0000 01F2         // }
; 0000 01F3 
; 0000 01F4         if(CHECK_GETS == 0)
	TST  R10
	BREQ PC+3
	JMP _0x81
; 0000 01F5         {
; 0000 01F6             UCSR1B &= ~(1<<RXEN1);
	LDS  R30,154
	ANDI R30,0xEF
	STS  154,R30
; 0000 01F7             sscanf(VELOCITY_BUFF,"<%d,%d>", &velocity, &angularV);
	LDI  R30,LOW(_VELOCITY_BUFF)
	LDI  R31,HIGH(_VELOCITY_BUFF)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,0
	ST   -Y,R31
	ST   -Y,R30
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	CALL __PUTPARD1L
	PUSH R17
	PUSH R16
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	CALL __PUTPARD1L
	PUSH R19
	PUSH R18
	LDI  R24,8
	CALL _sscanf
	ADIW R28,12
	POP  R18
	POP  R19
	POP  R16
	POP  R17
; 0000 01F8             UCSR1B |=(1<<RXEN1);
	LDS  R30,154
	ORI  R30,0x10
	STS  154,R30
; 0000 01F9 
; 0000 01FA             v_buff = (float)velocity/1000;
	MOVW R30,R16
	CALL SUBOPT_0xE
	__PUTD1SX 144
; 0000 01FB             a_buff = (float)angularV/1000;
	MOVW R30,R18
	CALL SUBOPT_0xE
	__PUTD1SX 148
; 0000 01FC 
; 0000 01FD             Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);
	MOVW R30,R28
	SUBI R30,LOW(-(144))
	SBCI R31,HIGH(-(144))
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	SUBI R30,LOW(-(150))
	SBCI R31,HIGH(-(150))
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
	SUBI R30,LOW(-(148))
	SBCI R31,HIGH(-(148))
	ST   -Y,R31
	ST   -Y,R30
	RCALL _Make_MSPEED
	POP  R20
	POP  R21
; 0000 01FE 
; 0000 01FF             // if(SRF02_CONVERTING_FLAG == 1 && SRF02_WAIT_FLAG == 1){
; 0000 0200             //     us_range[0] = Get_SRF02_Range(0xE0);
; 0000 0201 
; 0000 0202             //     us_range[0] = ( tau * pre_us_range[0] + ts * us_range[0] ) / (tau + ts) ;
; 0000 0203 
; 0000 0204             //     SRF02_CONVERTING_FLAG = 0;
; 0000 0205             //     SRF02_WAIT_FLAG = 0;
; 0000 0206             // }
; 0000 0207 
; 0000 0208             sprintf(BUFF,"<%.2f,%.f2>", v_buff, a_buff);
	MOVW R30,R28
	ADIW R30,30
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,8
	ST   -Y,R31
	ST   -Y,R30
	__GETD1SX 148
	CALL __PUTPARD1
	__GETD1SX 156
	CALL __PUTPARD1
	LDI  R24,8
	CALL _sprintf
	ADIW R28,12
; 0000 0209             puts_USART1(BUFF,VELOCITY_BUFF_IDX);
	MOVW R30,R28
	ADIW R30,30
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R9
	RCALL _puts_USART1
; 0000 020A 
; 0000 020B             RTU_WriteOperate0(R,(unsigned int)121,(int)(velocity_R));
	LDI  R30,LOW(1)
	ST   -Y,R30
	LDI  R30,LOW(121)
	LDI  R31,HIGH(121)
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R21
	ST   -Y,R20
	CALL SUBOPT_0xF
; 0000 020C             delay_ms(3);
; 0000 020D 
; 0000 020E             RTU_WriteOperate0(L,(unsigned int)121,(int)-(velocity_L));
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R30,LOW(121)
	LDI  R31,HIGH(121)
	ST   -Y,R31
	ST   -Y,R30
	__GETW1SX 145
	CALL __ANEGW1
	CALL SUBOPT_0x10
; 0000 020F             delay_ms(3);
; 0000 0210 
; 0000 0211             RTU_WriteOperate0(R,(unsigned int)120,(int)(START));
	LDI  R30,LOW(1)
	CALL SUBOPT_0x11
; 0000 0212             delay_ms(3);
; 0000 0213 
; 0000 0214             RTU_WriteOperate0(L,(unsigned int)120,(int)(START));
	LDI  R30,LOW(2)
	CALL SUBOPT_0x11
; 0000 0215             delay_ms(3);
; 0000 0216         }
; 0000 0217     }
_0x81:
	RJMP _0x7E
; 0000 0218 }
_0x82:
	RJMP _0x82
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
	CALL SUBOPT_0x1
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
	CALL SUBOPT_0x13
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
	CALL SUBOPT_0x13
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
	CALL SUBOPT_0x14
	RJMP _0x200001C
_0x200001E:
	__GETD1S 12
	CALL __CPD10
	BRNE _0x200001F
	LDI  R19,LOW(0)
	CALL SUBOPT_0x14
	RJMP _0x2000020
_0x200001F:
	LDD  R19,Y+11
	CALL SUBOPT_0x15
	BREQ PC+2
	BRCC PC+3
	JMP  _0x2000021
	CALL SUBOPT_0x14
_0x2000022:
	CALL SUBOPT_0x15
	BRLO _0x2000024
	CALL SUBOPT_0x16
	CALL SUBOPT_0x17
	RJMP _0x2000022
_0x2000024:
	RJMP _0x2000025
_0x2000021:
_0x2000026:
	CALL SUBOPT_0x15
	BRSH _0x2000028
	CALL SUBOPT_0x16
	CALL SUBOPT_0x18
	CALL SUBOPT_0x19
	SUBI R19,LOW(1)
	RJMP _0x2000026
_0x2000028:
	CALL SUBOPT_0x14
_0x2000025:
	__GETD1S 12
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x19
	CALL SUBOPT_0x15
	BRLO _0x2000029
	CALL SUBOPT_0x16
	CALL SUBOPT_0x17
_0x2000029:
_0x2000020:
	LDI  R17,LOW(0)
_0x200002A:
	LDD  R30,Y+11
	CP   R30,R17
	BRLO _0x200002C
	__GETD2S 4
	CALL SUBOPT_0x1B
	CALL SUBOPT_0x1A
	CALL __PUTPARD1
	CALL _floor
	CALL SUBOPT_0x5
	CALL SUBOPT_0x7
	CALL SUBOPT_0x16
	CALL __DIVF21
	CALL __CFD1U
	MOV  R16,R30
	CALL SUBOPT_0x1C
	CALL SUBOPT_0x1D
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __CDF1
	__GETD2S 4
	CALL __MULF12
	CALL SUBOPT_0x16
	CALL SUBOPT_0x6
	CALL SUBOPT_0x19
	MOV  R30,R17
	SUBI R17,-1
	CPI  R30,0
	BRNE _0x200002A
	CALL SUBOPT_0x1C
	LDI  R30,LOW(46)
	ST   X,R30
	RJMP _0x200002A
_0x200002C:
	CALL SUBOPT_0x1E
	SBIW R30,1
	LDD  R26,Y+10
	STD  Z+0,R26
	CPI  R19,0
	BRGE _0x200002E
	NEG  R19
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(45)
	RJMP _0x200010E
_0x200002E:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(43)
_0x200010E:
	ST   X,R30
	CALL SUBOPT_0x1E
	CALL SUBOPT_0x1E
	SBIW R30,1
	MOVW R22,R30
	MOV  R26,R19
	LDI  R30,LOW(10)
	CALL __DIVB21
	SUBI R30,-LOW(48)
	MOVW R26,R22
	ST   X,R30
	CALL SUBOPT_0x1E
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
	CALL SUBOPT_0xA
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
	CALL SUBOPT_0x1F
_0x2000038:
	RJMP _0x2000035
_0x2000036:
	CPI  R30,LOW(0x1)
	BRNE _0x2000039
	CPI  R18,37
	BRNE _0x200003A
	CALL SUBOPT_0x1F
	RJMP _0x200010F
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
	CALL SUBOPT_0x20
	CALL SUBOPT_0x21
	CALL SUBOPT_0x20
	LDD  R26,Z+4
	ST   -Y,R26
	CALL SUBOPT_0x22
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
	CALL SUBOPT_0x23
	CALL __GETD1P
	CALL SUBOPT_0x24
	CALL SUBOPT_0x25
	LDD  R26,Y+13
	TST  R26
	BRMI _0x200005B
	LDD  R26,Y+21
	CPI  R26,LOW(0x2B)
	BREQ _0x200005D
	RJMP _0x200005E
_0x200005B:
	CALL SUBOPT_0x26
	CALL __ANEGF1
	CALL SUBOPT_0x24
	LDI  R30,LOW(45)
	STD  Y+21,R30
_0x200005D:
	SBRS R16,7
	RJMP _0x200005F
	LDD  R30,Y+21
	ST   -Y,R30
	CALL SUBOPT_0x22
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
	CALL SUBOPT_0x26
	CALL __PUTPARD1
	ST   -Y,R20
	LDD  R30,Y+19
	LDD  R31,Y+19+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _ftoa
	RJMP _0x2000063
_0x2000062:
	CALL SUBOPT_0x26
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
	CALL SUBOPT_0x27
	RJMP _0x2000064
_0x200005A:
	CPI  R30,LOW(0x73)
	BRNE _0x2000066
	CALL SUBOPT_0x25
	CALL SUBOPT_0x28
	CALL SUBOPT_0x27
	RJMP _0x2000067
_0x2000066:
	CPI  R30,LOW(0x70)
	BRNE _0x2000069
	CALL SUBOPT_0x25
	CALL SUBOPT_0x28
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
	CALL SUBOPT_0x29
	LDI  R17,LOW(10)
	RJMP _0x2000075
_0x2000074:
	__GETD1N 0x2710
	CALL SUBOPT_0x29
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
	CALL SUBOPT_0x29
	LDI  R17,LOW(8)
	RJMP _0x2000075
_0x200007A:
	__GETD1N 0x1000
	CALL SUBOPT_0x29
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
	CALL SUBOPT_0x25
	CALL SUBOPT_0x23
	ADIW R26,4
	CALL __GETD1P
	RJMP _0x2000110
_0x200007D:
	SBRS R16,2
	RJMP _0x200007F
	CALL SUBOPT_0x25
	CALL SUBOPT_0x28
	CALL __CWD1
	RJMP _0x2000110
_0x200007F:
	CALL SUBOPT_0x25
	CALL SUBOPT_0x28
	CLR  R22
	CLR  R23
_0x2000110:
	__PUTD1S 10
	SBRS R16,2
	RJMP _0x2000081
	LDD  R26,Y+13
	TST  R26
	BRPL _0x2000082
	CALL SUBOPT_0x26
	CALL __ANEGD1
	CALL SUBOPT_0x24
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
	CALL SUBOPT_0x1F
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
	CALL SUBOPT_0x2A
	BREQ _0x2000093
	SUBI R21,LOW(1)
_0x2000093:
	SUBI R17,LOW(1)
	SUBI R20,LOW(1)
_0x2000092:
	LDI  R30,LOW(48)
	ST   -Y,R30
	CALL SUBOPT_0x22
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
	CALL SUBOPT_0x1F
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
	CALL SUBOPT_0x2B
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
	BRSH _0x2000111
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
_0x2000111:
	LDI  R18,LOW(48)
_0x20000A9:
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x20000AF
	CALL SUBOPT_0x2A
	BREQ _0x20000B0
	SUBI R21,LOW(1)
_0x20000B0:
_0x20000AF:
_0x20000AE:
_0x20000A5:
	CALL SUBOPT_0x1F
	CPI  R21,0
	BREQ _0x20000B1
	SUBI R21,LOW(1)
_0x20000B1:
_0x20000AB:
	SUBI R19,LOW(1)
	CALL SUBOPT_0x2B
	CALL __MODD21U
	CALL SUBOPT_0x24
	LDD  R30,Y+20
	__GETD2S 16
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __DIVD21U
	CALL SUBOPT_0x29
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
	CALL SUBOPT_0x22
	RJMP _0x20000B3
_0x20000B5:
_0x20000B2:
_0x20000B6:
_0x2000054:
_0x200010F:
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
	CALL SUBOPT_0x2C
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
	CALL SUBOPT_0x2C
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
	MOVW R26,R28
	ADIW R26,10
	CALL SUBOPT_0x2D
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
	SBIW R28,5
	CALL __SAVELOCR6
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	STD  Y+8,R30
	STD  Y+8+1,R31
	MOV  R20,R30
_0x20000C4:
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ADIW R30,1
	STD  Y+17,R30
	STD  Y+17+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R19,R30
	CPI  R30,0
	BRNE PC+3
	JMP _0x20000C6
	CALL SUBOPT_0x2E
	BREQ _0x20000C7
_0x20000C8:
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	CALL SUBOPT_0x2F
	POP  R20
	MOV  R19,R30
	CPI  R30,0
	BREQ _0x20000CB
	CALL SUBOPT_0x2E
	BRNE _0x20000CC
_0x20000CB:
	RJMP _0x20000CA
_0x20000CC:
	CALL SUBOPT_0x30
	BRGE _0x20000CD
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x20000CD:
	RJMP _0x20000C8
_0x20000CA:
	MOV  R20,R19
	RJMP _0x20000CE
_0x20000C7:
	CPI  R19,37
	BREQ PC+3
	JMP _0x20000CF
	LDI  R21,LOW(0)
_0x20000D0:
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	LPM  R19,Z+
	STD  Y+17,R30
	STD  Y+17+1,R31
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
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	CALL SUBOPT_0x2F
	POP  R20
	MOV  R18,R30
	ST   -Y,R30
	CALL _isspace
	CPI  R30,0
	BREQ _0x20000D9
	CALL SUBOPT_0x30
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
	MOV  R20,R18
	CPI  R21,0
	BRNE _0x20000DD
	LDI  R21,LOW(255)
_0x20000DD:
	MOV  R30,R19
	CPI  R30,LOW(0x63)
	BRNE _0x20000E1
	CALL SUBOPT_0x31
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	CALL SUBOPT_0x2F
	POP  R20
	MOVW R26,R16
	ST   X,R30
	CALL SUBOPT_0x30
	BRGE _0x20000E2
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x20000E2:
	RJMP _0x20000E0
_0x20000E1:
	CPI  R30,LOW(0x73)
	BRNE _0x20000EB
	CALL SUBOPT_0x31
_0x20000E4:
	MOV  R30,R21
	SUBI R21,1
	CPI  R30,0
	BREQ _0x20000E6
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	CALL SUBOPT_0x2F
	POP  R20
	MOV  R19,R30
	CPI  R30,0
	BREQ _0x20000E8
	CALL SUBOPT_0x2E
	BREQ _0x20000E7
_0x20000E8:
	CALL SUBOPT_0x30
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
_0x20000EB:
	LDI  R30,LOW(1)
	STD  Y+10,R30
	MOV  R30,R19
	CPI  R30,LOW(0x64)
	BREQ _0x20000F0
	CPI  R30,LOW(0x69)
	BRNE _0x20000F1
_0x20000F0:
	LDI  R30,LOW(0)
	STD  Y+10,R30
	RJMP _0x20000F2
_0x20000F1:
	CPI  R30,LOW(0x75)
	BRNE _0x20000F3
_0x20000F2:
	LDI  R18,LOW(10)
	RJMP _0x20000EE
_0x20000F3:
	CPI  R30,LOW(0x78)
	BRNE _0x20000F4
	LDI  R18,LOW(16)
	RJMP _0x20000EE
_0x20000F4:
	CPI  R30,LOW(0x25)
	BRNE _0x20000F7
	RJMP _0x20000F6
_0x20000F7:
	RJMP _0x20A0006
_0x20000EE:
	LDI  R30,LOW(0)
	STD  Y+6,R30
	STD  Y+6+1,R30
_0x20000F8:
	MOV  R30,R21
	SUBI R21,1
	CPI  R30,0
	BRNE PC+3
	JMP _0x20000FA
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	CALL SUBOPT_0x2F
	POP  R20
	MOV  R19,R30
	CPI  R30,LOW(0x21)
	BRSH _0x20000FB
	CALL SUBOPT_0x30
	BRGE _0x20000FC
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x20000FC:
	RJMP _0x20000FD
_0x20000FB:
	LDD  R30,Y+10
	CPI  R30,0
	BRNE _0x20000FE
	CPI  R19,45
	BRNE _0x20000FF
	LDI  R30,LOW(255)
	STD  Y+10,R30
	RJMP _0x20000F8
_0x20000FF:
	LDI  R30,LOW(1)
	STD  Y+10,R30
_0x20000FE:
	CPI  R18,16
	BRNE _0x2000101
	ST   -Y,R19
	CALL _isxdigit
	CPI  R30,0
	BREQ _0x20000FD
	RJMP _0x2000103
_0x2000101:
	ST   -Y,R19
	CALL _isdigit
	CPI  R30,0
	BRNE _0x2000104
_0x20000FD:
	MOV  R20,R19
	RJMP _0x20000FA
_0x2000104:
_0x2000103:
	CPI  R19,97
	BRLO _0x2000105
	SUBI R19,LOW(87)
	RJMP _0x2000106
_0x2000105:
	CPI  R19,65
	BRLO _0x2000107
	SUBI R19,LOW(55)
	RJMP _0x2000108
_0x2000107:
	SUBI R19,LOW(48)
_0x2000108:
_0x2000106:
	MOV  R30,R18
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R31,0
	CALL __MULW12U
	MOVW R26,R30
	MOV  R30,R19
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x20000F8
_0x20000FA:
	CALL SUBOPT_0x31
	LDD  R30,Y+10
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R31,0
	SBRC R30,7
	SER  R31
	CALL __MULW12U
	MOVW R26,R16
	ST   X+,R30
	ST   X,R31
_0x20000E0:
	CALL SUBOPT_0x1E
	RJMP _0x2000109
_0x20000CF:
_0x20000F6:
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	CALL SUBOPT_0x2F
	POP  R20
	CP   R30,R19
	BREQ _0x200010A
	CALL SUBOPT_0x30
	BRGE _0x200010B
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x200010B:
_0x20000DC:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	SBIW R30,0
	BRNE _0x200010C
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0005
_0x200010C:
	RJMP _0x20000C6
_0x200010A:
_0x2000109:
_0x20000CE:
	RJMP _0x20000C4
_0x20000C6:
_0x20A0006:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
_0x20A0005:
	CALL __LOADLOCR6
	ADIW R28,19
	RET
_sscanf:
	PUSH R15
	MOV  R15,R24
	SBIW R28,3
	ST   -Y,R17
	ST   -Y,R16
	MOVW R26,R28
	ADIW R26,7
	CALL SUBOPT_0x2D
	SBIW R30,0
	BRNE _0x200010D
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0004
_0x200010D:
	MOVW R26,R28
	ADIW R26,1
	CALL __ADDW2R15
	MOVW R16,R26
	MOVW R26,R28
	ADIW R26,7
	CALL SUBOPT_0x2D
	STD  Y+3,R30
	STD  Y+3+1,R31
	MOVW R26,R28
	ADIW R26,5
	CALL SUBOPT_0x2D
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
	CALL SUBOPT_0x9
	CALL __PUTPARD1
	CALL _ftrunc
	CALL __PUTD1S0
    brne __floor1
__floor0:
	CALL SUBOPT_0x9
	RJMP _0x20A0003
__floor1:
    brtc __floor0
	CALL SUBOPT_0x9
	__GETD2N 0x3F800000
	CALL __SUBF12
_0x20A0003:
	ADIW R28,4
	RET

	.CSEG
_ftoa:
	SBIW R28,4
	RCALL SUBOPT_0x1
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
	RCALL SUBOPT_0x32
	__POINTW1FN _0x2080000,0
	RCALL SUBOPT_0x13
	RJMP _0x20A0002
_0x208000D:
	CPI  R30,LOW(0x7FFF)
	LDI  R26,HIGH(0x7FFF)
	CPC  R31,R26
	BRNE _0x208000C
	RCALL SUBOPT_0x32
	__POINTW1FN _0x2080000,1
	RCALL SUBOPT_0x13
	RJMP _0x20A0002
_0x208000C:
	LDD  R26,Y+12
	TST  R26
	BRPL _0x208000F
	__GETD1S 9
	CALL __ANEGF1
	RCALL SUBOPT_0x33
	RCALL SUBOPT_0x34
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
	RCALL SUBOPT_0x35
	RCALL SUBOPT_0x1B
	RCALL SUBOPT_0x36
	RJMP _0x2080011
_0x2080013:
	RCALL SUBOPT_0x37
	CALL __ADDF12
	RCALL SUBOPT_0x33
	LDI  R17,LOW(0)
	__GETD1N 0x3F800000
	RCALL SUBOPT_0x36
_0x2080014:
	RCALL SUBOPT_0x37
	CALL __CMPF12
	BRLO _0x2080016
	RCALL SUBOPT_0x35
	RCALL SUBOPT_0x18
	RCALL SUBOPT_0x36
	SUBI R17,-LOW(1)
	CPI  R17,39
	BRLO _0x2080017
	RCALL SUBOPT_0x32
	__POINTW1FN _0x2080000,5
	RCALL SUBOPT_0x13
	RJMP _0x20A0002
_0x2080017:
	RJMP _0x2080014
_0x2080016:
	CPI  R17,0
	BRNE _0x2080018
	RCALL SUBOPT_0x34
	LDI  R30,LOW(48)
	ST   X,R30
	RJMP _0x2080019
_0x2080018:
_0x208001A:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BREQ _0x208001C
	RCALL SUBOPT_0x35
	RCALL SUBOPT_0x1B
	RCALL SUBOPT_0x1A
	CALL __PUTPARD1
	CALL _floor
	RCALL SUBOPT_0x36
	RCALL SUBOPT_0x37
	CALL __DIVF21
	CALL __CFD1U
	MOV  R16,R30
	RCALL SUBOPT_0x34
	RCALL SUBOPT_0x1D
	LDI  R31,0
	RCALL SUBOPT_0x35
	CALL __CWD1
	CALL __CDF1
	CALL __MULF12
	RCALL SUBOPT_0x38
	RCALL SUBOPT_0x6
	RCALL SUBOPT_0x33
	RJMP _0x208001A
_0x208001C:
_0x2080019:
	LDD  R30,Y+8
	CPI  R30,0
	BREQ _0x20A0001
	RCALL SUBOPT_0x34
	LDI  R30,LOW(46)
	ST   X,R30
_0x208001E:
	LDD  R30,Y+8
	SUBI R30,LOW(1)
	STD  Y+8,R30
	SUBI R30,-LOW(1)
	BREQ _0x2080020
	RCALL SUBOPT_0x38
	RCALL SUBOPT_0x18
	RCALL SUBOPT_0x33
	__GETD1S 9
	CALL __CFD1U
	MOV  R16,R30
	RCALL SUBOPT_0x34
	RCALL SUBOPT_0x1D
	LDI  R31,0
	RCALL SUBOPT_0x38
	CALL __CWD1
	CALL __CDF1
	RCALL SUBOPT_0x6
	RCALL SUBOPT_0x33
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
_PACKET_BUFF:
	.BYTE 0x64
_VELOCITY_BUFF:
	.BYTE 0x14
__seed_G104:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x0:
	MOV  R30,R17
	LDI  R31,0
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADD  R26,R30
	ADC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1:
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2:
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	CALL __GETD1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x3:
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL __GETD1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x4:
	__GETD2N 0x3E947AE1
	CALL __MULF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x40800000
	CALL __DIVF21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x5:
	__PUTD1S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x6:
	CALL __SWAPD12
	CALL __SUBF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x7:
	__GETD1S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x8:
	__GETD2N 0x4318C9BA
	CALL __MULF12
	__GETD2N 0x41C80000
	CALL __MULF12
	CALL __CFD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x9:
	CALL __GETD1S0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xA:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0xB:
	MOV  R26,R4
	LDI  R27,0
	SUBI R26,LOW(-_PACKET_BUFF)
	SBCI R27,HIGH(-_PACKET_BUFF)
	IN   R30,0xC
	ST   X,R30
	INC  R4
	LDI  R30,LOW(0)
	OUT  0x24,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0xC:
	MOV  R30,R9
	LDI  R31,0
	SUBI R30,LOW(-_VELOCITY_BUFF)
	SBCI R31,HIGH(-_VELOCITY_BUFF)
	ST   Z,R17
	INC  R9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0xD:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0xE:
	CALL __CWD1
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x447A0000
	CALL __DIVF21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0xF:
	CALL _RTU_WriteOperate0
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	RJMP SUBOPT_0xD

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x10:
	ST   -Y,R31
	ST   -Y,R30
	RJMP SUBOPT_0xF

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x11:
	ST   -Y,R30
	LDI  R30,LOW(120)
	LDI  R31,HIGH(120)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	RJMP SUBOPT_0x10

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x12:
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x13:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _strcpyf

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:27 WORDS
SUBOPT_0x14:
	__GETD2S 4
	__GETD1N 0x41200000
	CALL __MULF12
	RJMP SUBOPT_0x5

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x15:
	RCALL SUBOPT_0x7
	__GETD2S 12
	CALL __CMPF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x16:
	__GETD2S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x17:
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	__PUTD1S 12
	SUBI R19,-LOW(1)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x18:
	__GETD1N 0x41200000
	CALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x19:
	__PUTD1S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x1A:
	__GETD2N 0x3F000000
	CALL __ADDF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x1B:
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1C:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,1
	STD  Y+8,R26
	STD  Y+8+1,R27
	SBIW R26,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1D:
	MOV  R30,R16
	SUBI R30,-LOW(48)
	ST   X,R30
	MOV  R30,R16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x1E:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x1F:
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
SUBOPT_0x20:
	__GETW1SX 90
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x21:
	SBIW R30,4
	__PUTW1SX 90
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x22:
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+11
	LDD  R31,Y+11+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:17 WORDS
SUBOPT_0x23:
	__GETW2SX 90
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x24:
	__PUTD1S 10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x25:
	RCALL SUBOPT_0x20
	RJMP SUBOPT_0x21

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x26:
	__GETD1S 10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x27:
	STD  Y+14,R30
	STD  Y+14+1,R31
	ST   -Y,R31
	ST   -Y,R30
	CALL _strlen
	MOV  R17,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x28:
	RCALL SUBOPT_0x23
	ADIW R26,4
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x29:
	__PUTD1S 16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x2A:
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
SUBOPT_0x2B:
	__GETD1S 16
	__GETD2S 10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2C:
	MOVW R26,R28
	ADIW R26,12
	CALL __ADDW2R15
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x2D:
	CALL __ADDW2R15
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2E:
	ST   -Y,R19
	CALL _isspace
	CPI  R30,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:22 WORDS
SUBOPT_0x2F:
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x30:
	LDD  R26,Y+11
	LDD  R27,Y+11+1
	LD   R26,X
	CPI  R26,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x31:
	LDD  R30,Y+15
	LDD  R31,Y+15+1
	SBIW R30,4
	STD  Y+15,R30
	STD  Y+15+1,R31
	LDD  R26,Y+15
	LDD  R27,Y+15+1
	ADIW R26,4
	LD   R16,X+
	LD   R17,X
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x32:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x33:
	__PUTD1S 9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x34:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,1
	STD  Y+6,R26
	STD  Y+6+1,R27
	SBIW R26,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x35:
	__GETD2S 2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x36:
	__PUTD1S 2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x37:
	__GETD1S 2
	__GETD2S 9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x38:
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

__MULW12U:
	MUL  R31,R26
	MOV  R31,R0
	MUL  R30,R27
	ADD  R31,R0
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
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

__PUTDP1:
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	RET

__GETD1S0:
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R22,Y+2
	LDD  R23,Y+3
	RET

__PUTD1S0:
	ST   Y,R30
	STD  Y+1,R31
	STD  Y+2,R22
	STD  Y+3,R23
	RET

__PUTPARD1L:
	LDI  R22,0
	LDI  R23,0
__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

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

__INITLOCB:
__INITLOCW:
	ADD  R26,R28
	ADC  R27,R29
__INITLOC0:
	LPM  R0,Z+
	ST   X+,R0
	DEC  R24
	BRNE __INITLOC0
	RET

;END OF CODE MARKER
__END_OF_CODE:
