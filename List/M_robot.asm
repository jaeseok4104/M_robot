
;CodeVisionAVR C Compiler V2.05.0 Professional
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega128
;Program type             : Application
;Clock frequency          : 14.745600 MHz
;Memory model             : Small
;Optimize for             : Size
;(s)printf features       : int, width
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
	.DEF _TIMER0_OVERFLOW=R7
	.DEF _VELOCITY_BUFF_IDX=R6
	.DEF _CHECK_GETS=R9

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
	JMP  0x00
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

_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

_0x39:
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
	.DB  0x0,0x0,0x0,0x0
_0x43:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0

__GLOBAL_INI_TBL:
	.DW  0x06
	.DW  0x04
	.DW  _0x43*2

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
;#define CHARACTER3_5 25
;
;#define R 0x01
;#define L 0x02
;
;unsigned char TIMER2_OVERFLOW = 0;
;unsigned char PACKET_BUFF[100] = {0,};
;unsigned char PACKET_BUFF_IDX = 0;
;
;unsigned char TIMER0_OVERFLOW = 0;
;unsigned char VELOCITY_BUFF[20] = {0,};
;unsigned char VELOCITY_BUFF_IDX = 0;
;unsigned char CHECK_GETS = 0;
;
;void usart1_init(int bps)
; 0000 0018 {

	.CSEG
_usart1_init:
; 0000 0019     UCSR1A = 0x00;
;	bps -> Y+0
	LDI  R30,LOW(0)
	STS  155,R30
; 0000 001A     UCSR1B = (1<<RXEN1)|(1<<TXEN1)|(1<<RXCIE1); // RXCIE1 bit is recevie interrupt allow
	LDI  R30,LOW(152)
	STS  154,R30
; 0000 001B     UCSR1C = (1<<UCSZ11)|(1<<UCSZ10);
	LDI  R30,LOW(6)
	STS  157,R30
; 0000 001C     UCSR1C &= ~(1<<UMSEL1);
	LDS  R30,157
	ANDI R30,0xBF
	STS  157,R30
; 0000 001D 
; 0000 001E     UBRR1H = (unsigned char)((bps>>8)  & 0x00ff);
	LD   R30,Y
	LDD  R31,Y+1
	CALL __ASRW8
	STS  152,R30
; 0000 001F     UBRR1L = (unsigned char)(bps & 0x00ff);
	LD   R30,Y
	STS  153,R30
; 0000 0020 }
	RJMP _0x2060002
;
;void usart0_init(int bps)
; 0000 0023 {
_usart0_init:
; 0000 0024     UCSR0A = 0x00;
;	bps -> Y+0
	LDI  R30,LOW(0)
	OUT  0xB,R30
; 0000 0025     UCSR0B = (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0); // RXCIE1 bit is recevie interrupt allow
	LDI  R30,LOW(152)
	OUT  0xA,R30
; 0000 0026     UCSR0C = (1<<UCSZ01)|(1<<UCSZ00);
	LDI  R30,LOW(6)
	STS  149,R30
; 0000 0027     UCSR0C &= ~(1<<UMSEL0);
	LDS  R30,149
	ANDI R30,0xBF
	STS  149,R30
; 0000 0028 
; 0000 0029     UBRR0H = (unsigned char)((bps>>8)  & 0x00ff);
	LD   R30,Y
	LDD  R31,Y+1
	CALL __ASRW8
	STS  144,R30
; 0000 002A     UBRR0L = (unsigned char)(bps & 0x00ff);
	LD   R30,Y
	OUT  0x9,R30
; 0000 002B }
_0x2060002:
	ADIW R28,2
	RET
;
;void timer2_init(void)
; 0000 002E {
_timer2_init:
; 0000 002F     //TIMER2
; 0000 0030     TCCR2 = (1<<WGM21)|(1<<CS22)|(1<<CS20);// CTC모드, 1024분주
	LDI  R30,LOW(13)
	OUT  0x25,R30
; 0000 0031 
; 0000 0032     OCR2 = 40;
	LDI  R30,LOW(40)
	OUT  0x23,R30
; 0000 0033     TIMSK = (1<<OCIE2)|(1<<OCIE0);
	LDI  R30,LOW(130)
	OUT  0x37,R30
; 0000 0034     //TIMSK = (1<<OCIE2);
; 0000 0035 }
	RET
;void timer0_init(void)
; 0000 0037 {
; 0000 0038     TCCR0 = (1<<WGM01)|(1<<CS02)|(1<<CS01)|(1<<CS00); // CTC모드, 1024분주
; 0000 0039     OCR0 = 40;
; 0000 003A     TIMSK = (1<<OCIE2)|(1<<OCIE0);
; 0000 003B }
;
;void putch_USART1(char data)
; 0000 003E {
_putch_USART1:
; 0000 003F     while(!(UCSR1A & (1<<UDRE1))); // UDRE flag is USART Data Register Empty
;	data -> Y+0
_0x3:
	LDS  R30,155
	ANDI R30,LOW(0x20)
	BREQ _0x3
; 0000 0040     UDR1 = data;
	LD   R30,Y
	STS  156,R30
; 0000 0041 }
	RJMP _0x2060001
;
;//USART 문자열 송신
;void puts_USART1(char *str,char IDX)
; 0000 0045 {
; 0000 0046     unsigned char i = 0;
; 0000 0047 
; 0000 0048     for(i = 0;i<IDX;i++)
;	*str -> Y+2
;	IDX -> Y+1
;	i -> R17
; 0000 0049     {
; 0000 004A         putch_USART1(*(str+i));
; 0000 004B     }
; 0000 004C 
; 0000 004D     for(i = 0; i<IDX; i++)
; 0000 004E     {
; 0000 004F         *(str+i) = 0;
; 0000 0050     }
; 0000 0051 }
;
;void puts_Modbus1(char *str,char IDX)
; 0000 0054 {
_puts_Modbus1:
; 0000 0055     unsigned char i = 0;
; 0000 0056     UCSR0B &= ~(1<<RXEN0);
	ST   -Y,R17
;	*str -> Y+2
;	IDX -> Y+1
;	i -> R17
	LDI  R17,0
	CBI  0xA,4
; 0000 0057     if(TIMER2_OVERFLOW>0)
	LDI  R30,LOW(0)
	CP   R30,R5
	BRSH _0xC
; 0000 0058     {
; 0000 0059         for(i = 0;i<IDX-1;i++) putch_USART1(*(str+i));
	LDI  R17,LOW(0)
_0xE:
	LDD  R30,Y+1
	LDI  R31,0
	SBIW R30,1
	MOV  R26,R17
	LDI  R27,0
	CP   R26,R30
	CPC  R27,R31
	BRGE _0xF
	CALL SUBOPT_0x0
	LD   R30,X
	ST   -Y,R30
	RCALL _putch_USART1
	SUBI R17,-1
	RJMP _0xE
_0xF:
; 0000 005B for(i = 0; i<IDX; i++) *(str+i) = 0;
	LDI  R17,LOW(0)
_0x11:
	LDD  R30,Y+1
	CP   R17,R30
	BRSH _0x12
	CALL SUBOPT_0x0
	LDI  R30,LOW(0)
	ST   X,R30
	SUBI R17,-1
	RJMP _0x11
_0x12:
; 0000 005C }
; 0000 005D     UCSR0B |= (1<<RXEN0);
_0xC:
	SBI  0xA,4
; 0000 005E }
	LDD  R17,Y+0
	ADIW R28,4
	RET
;
;void putch_USART0(char data)
; 0000 0061 {
_putch_USART0:
; 0000 0062     while(!(UCSR0A & (1<<UDRE0))); // UDRE flag is USART Data Register Empty
;	data -> Y+0
_0x13:
	SBIS 0xB,5
	RJMP _0x13
; 0000 0063     UDR0 = data;
	LD   R30,Y
	OUT  0xC,R30
; 0000 0064 }
_0x2060001:
	ADIW R28,1
	RET
;
;void puts_USART0(char *str,char IDX)
; 0000 0067 {
; 0000 0068     //PACKET_BUFF[PACKET_BUFF_IDX] = 0;
; 0000 0069     unsigned char i = 0;
; 0000 006A     for(i = 0;i<IDX-1;i++)
;	*str -> Y+2
;	IDX -> Y+1
;	i -> R17
; 0000 006B     {
; 0000 006C         putch_USART1(*(str+i));
; 0000 006D     }
; 0000 006E 
; 0000 006F     for(i = 0; i<IDX; i++)
; 0000 0070     {
; 0000 0071         *(str+i) = 0;
; 0000 0072     }
; 0000 0073 }
;
;unsigned short CRC16(unsigned char *puchMsg, int usDataLen)
; 0000 0076 {
_CRC16:
; 0000 0077     int i;
; 0000 0078     unsigned short crc, flag;
; 0000 0079     crc = 0xffff;
	CALL __SAVELOCR6
;	*puchMsg -> Y+8
;	usDataLen -> Y+6
;	i -> R16,R17
;	crc -> R18,R19
;	flag -> R20,R21
	__GETWRN 18,19,-1
; 0000 007A 
; 0000 007B     while(usDataLen--){
_0x1C:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	SBIW R30,1
	STD  Y+6,R30
	STD  Y+6+1,R31
	ADIW R30,1
	BREQ _0x1E
; 0000 007C         crc ^= *puchMsg++;
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LD   R30,X+
	STD  Y+8,R26
	STD  Y+8+1,R27
	LDI  R31,0
	__EORWRR 18,19,30,31
; 0000 007D 
; 0000 007E         for (i=0; i<8; i++){
	__GETWRN 16,17,0
_0x20:
	__CPWRN 16,17,8
	BRGE _0x21
; 0000 007F             flag = crc & 0x0001;
	MOVW R30,R18
	ANDI R30,LOW(0x1)
	ANDI R31,HIGH(0x1)
	MOVW R20,R30
; 0000 0080             crc >>= 1;
	LSR  R19
	ROR  R18
; 0000 0081             if(flag) crc ^= POLYNORMIAL;
	MOV  R0,R20
	OR   R0,R21
	BREQ _0x22
	LDI  R30,LOW(40961)
	LDI  R31,HIGH(40961)
	__EORWRR 18,19,30,31
; 0000 0082         }
_0x22:
	__ADDWRN 16,17,1
	RJMP _0x20
_0x21:
; 0000 0083     }
	RJMP _0x1C
_0x1E:
; 0000 0084     return crc;
	MOVW R30,R18
	CALL __LOADLOCR6
	ADIW R28,10
	RET
; 0000 0085 }
;
;int RTU_WriteOperate0(char device_address,int starting_address,int data)
; 0000 0088 {
_RTU_WriteOperate0:
; 0000 0089     char protocol[8];
; 0000 008A     unsigned short crc16;
; 0000 008B     int i=0;
; 0000 008C     //PACKET_BUFF_IDX = 0;
; 0000 008D 
; 0000 008E     protocol[0]=device_address;
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
; 0000 008F     protocol[1]=0x06;
	LDI  R30,LOW(6)
	STD  Y+5,R30
; 0000 0090     protocol[2]=((starting_address>>8)  & 0x00ff);
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	CALL __ASRW8
	STD  Y+6,R30
; 0000 0091     protocol[3]=((starting_address)     & 0x00ff);
	LDD  R30,Y+14
	STD  Y+7,R30
; 0000 0092     protocol[4]=((data>>8)              & 0x00ff);
	LDD  R30,Y+12
	LDD  R31,Y+12+1
	CALL __ASRW8
	STD  Y+8,R30
; 0000 0093     protocol[5]=((data)                 & 0x00ff);
	LDD  R30,Y+12
	STD  Y+9,R30
; 0000 0094     protocol[6]=0;
	LDI  R30,LOW(0)
	STD  Y+10,R30
; 0000 0095     protocol[7]=0;
	STD  Y+11,R30
; 0000 0096 
; 0000 0097     crc16 = CRC16(protocol, 6);
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
; 0000 0098 
; 0000 0099     protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
	MOVW R30,R16
	STD  Y+10,R30
; 0000 009A     protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
	__PUTBSR 17,11
; 0000 009B 
; 0000 009C 
; 0000 009D     for(i=0;i<8;i++)
	__GETWRN 18,19,0
_0x24:
	__CPWRN 18,19,8
	BRGE _0x25
; 0000 009E     {
; 0000 009F         putch_USART0(*(protocol+i));
	MOVW R26,R28
	ADIW R26,4
	ADD  R26,R18
	ADC  R27,R19
	LD   R30,X
	ST   -Y,R30
	RCALL _putch_USART0
; 0000 00A0     }
	__ADDWRN 18,19,1
	RJMP _0x24
_0x25:
; 0000 00A1 }
	CALL __LOADLOCR4
	ADIW R28,17
	RET
;
;int RTU_WriteOperate1(char device_address,int starting_address,int data)
; 0000 00A4 {
; 0000 00A5     char protocol[8];
; 0000 00A6     unsigned short crc16;
; 0000 00A7     int i=0;
; 0000 00A8    // PACKET_BUFF_IDX = 0;
; 0000 00A9 
; 0000 00AA     protocol[0]=device_address;
;	device_address -> Y+16
;	starting_address -> Y+14
;	data -> Y+12
;	protocol -> Y+4
;	crc16 -> R16,R17
;	i -> R18,R19
; 0000 00AB     protocol[1]=0x06;
; 0000 00AC     protocol[2]=((starting_address>>8)  & 0x00ff);
; 0000 00AD     protocol[3]=((starting_address)     & 0x00ff);
; 0000 00AE     protocol[4]=((data>>8)              & 0x00ff);
; 0000 00AF     protocol[5]=((data)                 & 0x00ff);
; 0000 00B0     protocol[6]=0;
; 0000 00B1     protocol[7]=0;
; 0000 00B2 
; 0000 00B3     crc16 = CRC16(protocol, 6);
; 0000 00B4 
; 0000 00B5     protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
; 0000 00B6     protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
; 0000 00B7 
; 0000 00B8 
; 0000 00B9     for(i=0;i<8;i++)
; 0000 00BA     {
; 0000 00BB         putch_USART1(*(protocol+i));
; 0000 00BC     }
; 0000 00BD }
;
;int RTU_ReedOperate0(char device_address,int starting_address,int data)
; 0000 00C0 {
; 0000 00C1     char protocol[8];
; 0000 00C2     unsigned short crc16;
; 0000 00C3     int i=0;
; 0000 00C4     //PACKET_BUFF_IDX = 0;
; 0000 00C5 
; 0000 00C6     protocol[0]=device_address;
;	device_address -> Y+16
;	starting_address -> Y+14
;	data -> Y+12
;	protocol -> Y+4
;	crc16 -> R16,R17
;	i -> R18,R19
; 0000 00C7     protocol[1]=0x03;
; 0000 00C8     protocol[2]=((starting_address>>8)  & 0x00ff);
; 0000 00C9     protocol[3]=((starting_address)     & 0x00ff);
; 0000 00CA     protocol[4]=((data>>8)              & 0x00ff);
; 0000 00CB     protocol[5]=((data)                 & 0x00ff);
; 0000 00CC     protocol[6]=0;
; 0000 00CD     protocol[7]=0;
; 0000 00CE 
; 0000 00CF     crc16 = CRC16(protocol, 6);
; 0000 00D0 
; 0000 00D1     protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
; 0000 00D2     protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
; 0000 00D3 
; 0000 00D4 
; 0000 00D5     for(i=0;i<8;i++)
; 0000 00D6     {
; 0000 00D7         putch_USART0(*(protocol+i));
; 0000 00D8     }
; 0000 00D9 }
;
;// interrupt [USART0_RXC] void usart0_rxc(void)
;// {
;//     unsigned char i = 0;
;
;//     i = UDR0;
;//     if(i == '<'){
;//         PACKET_BUFF_IDX = 0;
;//         PACKET_BUFF[PACKET_BUFF_IDX] = i;
;//         PACKET_BUFF_IDX++;
;//     }
;//     else if(i == '>'){
;//         PACKET_BUFF[PACKET_BUFF_IDX] = i;
;//         PACKET_BUFF_IDX+=2;
;//     }
;//     else{
;//         PACKET_BUFF[PACKET_BUFF_IDX] = i;
;//         PACKET_BUFF_IDX++;
;//     }
;// }
;
;interrupt [USART0_RXC] void usart0_rxc(void)
; 0000 00F0 {
_usart0_rxc:
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
; 0000 00F1     if(((TCNT2 < CHARACTER3_5) && (TIMER2_OVERFLOW == 0)) || PACKET_BUFF_IDX == 0)
	IN   R30,0x24
	CPI  R30,LOW(0x19)
	BRSH _0x2D
	LDI  R30,LOW(0)
	CP   R30,R5
	BREQ _0x2F
_0x2D:
	LDI  R30,LOW(0)
	CP   R30,R4
	BRNE _0x2C
_0x2F:
; 0000 00F2     {
; 0000 00F3         PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
	CALL SUBOPT_0x1
; 0000 00F4         PACKET_BUFF_IDX++;
; 0000 00F5         TCNT2 = 0;
; 0000 00F6     }
; 0000 00F7     else {
	RJMP _0x31
_0x2C:
; 0000 00F8         PACKET_BUFF_IDX = 0;
	CLR  R4
; 0000 00F9         PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
	CALL SUBOPT_0x1
; 0000 00FA         PACKET_BUFF_IDX++;
; 0000 00FB         TCNT2 = 0;
; 0000 00FC         TIMER2_OVERFLOW = 0;
	CLR  R5
; 0000 00FD     }
_0x31:
; 0000 00FE }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
;
;interrupt [USART1_RXC] void usart1_rxc(void)
; 0000 0101 {
_usart1_rxc:
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0102     unsigned char i = 0;
; 0000 0103     i = UDR1;
	ST   -Y,R17
;	i -> R17
	LDI  R17,0
	LDS  R17,156
; 0000 0104     if(i == '<'){
	CPI  R17,60
	BRNE _0x32
; 0000 0105         VELOCITY_BUFF_IDX = 0;
	CLR  R6
; 0000 0106         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
	CALL SUBOPT_0x2
; 0000 0107         VELOCITY_BUFF_IDX++;
; 0000 0108         CHECK_GETS = 1;
	LDI  R30,LOW(1)
	MOV  R9,R30
; 0000 0109     }
; 0000 010A     else if(i == '>'){
	RJMP _0x33
_0x32:
	CPI  R17,62
	BRNE _0x34
; 0000 010B         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
	CALL SUBOPT_0x2
; 0000 010C         VELOCITY_BUFF_IDX++;
; 0000 010D         CHECK_GETS = 0;
	CLR  R9
; 0000 010E     }
; 0000 010F     else{
	RJMP _0x35
_0x34:
; 0000 0110         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
	CALL SUBOPT_0x2
; 0000 0111         VELOCITY_BUFF_IDX++;
; 0000 0112     }
_0x35:
_0x33:
; 0000 0113 }
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	RETI
;
;// interrupt [USART1_RXC] void usart1_rxc(void)
;// {
;//     if(((TCNT0 < CHARACTER3_5) && (TIMER2_OVERFLOW == 0)) || VELOCITY_BUFF_IDX == 0)
;//     {
;//         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = UDR1;
;//         TCNT0 = 0;
;//         //PORTB.1 = ~PORTB.1;
;//     }
;//     else {
;//         VELOCITY_BUFF_IDX = 0;
;//         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = UDR0;
;//         VELOCITY_BUFF_IDX++;
;//         TCNT0 = 0;
;//         //PORTB.1 = ~PORTB.1;
;//         TIMER2_OVERFLOW = 0;
;
;//     }
;// }
;
;// interrupt [USART1_RXC] void usart1_rxc(void)
;// {
;//     if(((TCNT0 < CHARACTER3_5) && (TIMER2_OVERFLOW == 0)) || VELOCITY_BUFF_IDX == 0)
;//     {
;//         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = UDR1;
;//         TCNT0 = 0;
;//         //PORTB.1 = ~PORTB.1;
;//     }
;//     else {
;//         VELOCITY_BUFF_IDX = 0;
;//         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = UDR0;
;//         VELOCITY_BUFF_IDX++;
;//         TCNT0 = 0;
;//         //PORTB.1 = ~PORTB.1;
;//     }
;// }
;
;interrupt [TIM2_COMP] void timer2_comp(void)
; 0000 013A {
_timer2_comp:
	ST   -Y,R30
	IN   R30,SREG
; 0000 013B     if(TIMER2_OVERFLOW == 0) PORTB.1 = ~PORTB.1;
	TST  R5
	BRNE _0x36
	SBIS 0x18,1
	RJMP _0x37
	CBI  0x18,1
	RJMP _0x38
_0x37:
	SBI  0x18,1
_0x38:
; 0000 013C 
; 0000 013D     TIMER2_OVERFLOW++;
_0x36:
	INC  R5
; 0000 013E }
	RJMP _0x42
;
;interrupt [TIM0_COMP] void timer0_comp(void)
; 0000 0141 {
_timer0_comp:
	ST   -Y,R30
	IN   R30,SREG
; 0000 0142     TIMER0_OVERFLOW++;
	INC  R7
; 0000 0143 }
_0x42:
	OUT  SREG,R30
	LD   R30,Y+
	RETI
;
;void main(void)
; 0000 0146 {
_main:
; 0000 0147     int velocity_R = 0;
; 0000 0148     int velocity_L = 0;
; 0000 0149     unsigned char BUFF[100] = {0,};
; 0000 014A 
; 0000 014B     usart1_init(bps_115200);
	SBIW R28,63
	SBIW R28,37
	LDI  R24,100
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0x39*2)
	LDI  R31,HIGH(_0x39*2)
	CALL __INITLOCB
;	velocity_R -> R16,R17
;	velocity_L -> R18,R19
;	BUFF -> Y+0
	__GETWRN 16,17,0
	__GETWRN 18,19,0
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _usart1_init
; 0000 014C     usart0_init(bps_115200);
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _usart0_init
; 0000 014D     timer2_init();
	RCALL _timer2_init
; 0000 014E     SREG |= 0x80;
	BSET 7
; 0000 014F     DDRB.1 = 1;
	SBI  0x17,1
; 0000 0150     PORTB.1 = 0;
	CBI  0x18,1
; 0000 0151     //delay_ms(5000);
; 0000 0152     while(1)
_0x3E:
; 0000 0153     {
; 0000 0154         // if(CHECK_GETS == 0)
; 0000 0155         // {
; 0000 0156             // //UCSR1B &= ~(1<<RXEN1);
; 0000 0157             // sscanf(VELOCITY_BUFF,"<%d,%d>", &velocity_R, &velocity_L);
; 0000 0158             // sprintf(BUFF,"<%d,%d>", velocity_R, velocity_L);
; 0000 0159 
; 0000 015A             //puts_USART1(BUFF,VELOCITY_BUFF_IDX);
; 0000 015B 
; 0000 015C             //UCSR1B |=(1<<RXEN1);
; 0000 015D             RTU_WriteOperate0(R,(unsigned int)121,(int)(300));
	LDI  R30,LOW(1)
	ST   -Y,R30
	LDI  R30,LOW(121)
	LDI  R31,HIGH(121)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(300)
	LDI  R31,HIGH(300)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _RTU_WriteOperate0
; 0000 015E             puts_Modbus1(PACKET_BUFF,PACKET_BUFF_IDX);
	LDI  R30,LOW(_PACKET_BUFF)
	LDI  R31,HIGH(_PACKET_BUFF)
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R4
	RCALL _puts_Modbus1
; 0000 015F             delay_ms(50);
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 0160 
; 0000 0161             // RTU_WriteOperate0(L,(unsigned int)121,(int)-(velocity_L));
; 0000 0162             // delay_ms(5);
; 0000 0163 
; 0000 0164             // RTU_WriteOperate0(R,(unsigned int)120,(int)(1));
; 0000 0165             // delay_ms(5);
; 0000 0166 
; 0000 0167             // RTU_WriteOperate0(L,(unsigned int)120,(int)(1));
; 0000 0168             // delay_ms(5);
; 0000 0169         // }
; 0000 016A     }
	RJMP _0x3E
; 0000 016B }
_0x41:
	RJMP _0x41
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

	.CSEG

	.CSEG

	.DSEG
_PACKET_BUFF:
	.BYTE 0x64
_VELOCITY_BUFF:
	.BYTE 0x14

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

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x1:
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
SUBOPT_0x2:
	MOV  R30,R6
	LDI  R31,0
	SUBI R30,LOW(-_VELOCITY_BUFF)
	SBCI R31,HIGH(-_VELOCITY_BUFF)
	ST   Z,R17
	INC  R6
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

__ASRW8:
	MOV  R30,R31
	CLR  R31
	SBRC R30,7
	SER  R31
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
