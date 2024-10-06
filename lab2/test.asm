
test.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <start>:
   0:	00000093          	li	ra,0
   4:	20002117          	auipc	sp,0x20002
   8:	ffc10113          	addi	sp,sp,-4 # 20002000 <_stack>
   c:	00000193          	li	gp,0
  10:	00000213          	li	tp,0
  14:	00000293          	li	t0,0
  18:	00000313          	li	t1,0
  1c:	00000393          	li	t2,0
  20:	00000413          	li	s0,0
  24:	00000493          	li	s1,0
  28:	00000513          	li	a0,0
  2c:	00000593          	li	a1,0
  30:	00000613          	li	a2,0
  34:	00000693          	li	a3,0
  38:	00000713          	li	a4,0
  3c:	00000793          	li	a5,0
  40:	00000813          	li	a6,0
  44:	00000893          	li	a7,0
  48:	00000913          	li	s2,0
  4c:	00000993          	li	s3,0
  50:	00000a13          	li	s4,0
  54:	00000a93          	li	s5,0
  58:	00000b13          	li	s6,0
  5c:	00000b93          	li	s7,0
  60:	00000c13          	li	s8,0
  64:	00000c93          	li	s9,0
  68:	00000d13          	li	s10,0
  6c:	00000d93          	li	s11,0
  70:	00000e13          	li	t3,0
  74:	00000e93          	li	t4,0
  78:	00000f13          	li	t5,0
  7c:	00000f93          	li	t6,0
  80:	00000517          	auipc	a0,0x0
  84:	0d850513          	addi	a0,a0,216 # 158 <_sidata>
  88:	20000597          	auipc	a1,0x20000
  8c:	f7858593          	addi	a1,a1,-136 # 20000000 <ram_word>
  90:	20000617          	auipc	a2,0x20000
  94:	f7c60613          	addi	a2,a2,-132 # 2000000c <_ebss>
  98:	00c5dc63          	bge	a1,a2,b0 <end_init_data>

0000009c <loop_init_data>:
  9c:	00052683          	lw	a3,0(a0)
  a0:	00d5a023          	sw	a3,0(a1)
  a4:	00450513          	addi	a0,a0,4
  a8:	00458593          	addi	a1,a1,4
  ac:	fec5c8e3          	blt	a1,a2,9c <loop_init_data>

000000b0 <end_init_data>:
  b0:	20000517          	auipc	a0,0x20000
  b4:	f5c50513          	addi	a0,a0,-164 # 2000000c <_ebss>
  b8:	20000597          	auipc	a1,0x20000
  bc:	f5458593          	addi	a1,a1,-172 # 2000000c <_ebss>
  c0:	00b55863          	bge	a0,a1,d0 <end_init_bss>

000000c4 <loop_init_bss>:
  c4:	00052023          	sw	zero,0(a0)
  c8:	00450513          	addi	a0,a0,4
  cc:	feb54ce3          	blt	a0,a1,c4 <loop_init_bss>

000000d0 <end_init_bss>:
  d0:	008000ef          	jal	d8 <main>

000000d4 <loop>:
  d4:	0000006f          	j	d4 <loop>

000000d8 <main>:
  d8:	200007b7          	lui	a5,0x20000
  dc:	0047a583          	lw	a1,4(a5) # 20000004 <gpio_oe>
  e0:	200006b7          	lui	a3,0x20000
  e4:	0006a783          	lw	a5,0(a3) # 20000000 <ram_word>
  e8:	fff00613          	li	a2,-1
  ec:	aabbd737          	lui	a4,0xaabbd
  f0:	00c5a023          	sw	a2,0(a1)
  f4:	cdd70713          	addi	a4,a4,-803 # aabbccdd <_stack+0x8abbacdd>
  f8:	00e7a023          	sw	a4,0(a5)
  fc:	01100713          	li	a4,17
 100:	00e780a3          	sb	a4,1(a5)
 104:	02200713          	li	a4,34
 108:	00e78123          	sb	a4,2(a5)
 10c:	03300713          	li	a4,51
 110:	00c78023          	sb	a2,0(a5)
 114:	00e781a3          	sb	a4,3(a5)
 118:	0006a703          	lw	a4,0(a3)
 11c:	332217b7          	lui	a5,0x33221
 120:	1ff78793          	addi	a5,a5,511 # 332211ff <_stack+0x1321f1ff>
 124:	00072703          	lw	a4,0(a4)
 128:	00f70c63          	beq	a4,a5,140 <main+0x68>
 12c:	200007b7          	lui	a5,0x20000
 130:	0087a783          	lw	a5,8(a5) # 20000008 <gpio_data>
 134:	0007a023          	sw	zero,0(a5)
 138:	00000513          	li	a0,0
 13c:	00008067          	ret
 140:	200007b7          	lui	a5,0x20000
 144:	0087a703          	lw	a4,8(a5) # 20000008 <gpio_data>
 148:	f00fe7b7          	lui	a5,0xf00fe
 14c:	00e78793          	addi	a5,a5,14 # f00fe00e <_stack+0xd00fc00e>
 150:	00f72023          	sw	a5,0(a4)
 154:	fe5ff06f          	j	138 <main+0x60>

Disassembly of section .data:

20000000 <ram_word>:
20000000:	0400                	.insn	2, 0x0400
20000002:	2000                	.insn	2, 0x2000

20000004 <gpio_oe>:
20000004:	0004                	.insn	2, 0x0004
20000006:	4000                	.insn	2, 0x4000

20000008 <gpio_data>:
20000008:	0000                	.insn	2, 0x
2000000a:	4000                	.insn	2, 0x4000

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes>:
   0:	1b41                	.insn	2, 0x1b41
   2:	0000                	.insn	2, 0x
   4:	7200                	.insn	2, 0x7200
   6:	7369                	.insn	2, 0x7369
   8:	01007663          	bgeu	zero,a6,14 <start+0x14>
   c:	0011                	.insn	2, 0x0011
   e:	0000                	.insn	2, 0x
  10:	1004                	.insn	2, 0x1004
  12:	7205                	.insn	2, 0x7205
  14:	3376                	.insn	2, 0x3376
  16:	6932                	.insn	2, 0x6932
  18:	7032                	.insn	2, 0x7032
  1a:	0031                	.insn	2, 0x0031

Disassembly of section .comment:

00000000 <.comment>:
   0:	3a434347          	.insn	4, 0x3a434347
   4:	2820                	.insn	2, 0x2820
   6:	39386367          	.insn	4, 0x39386367
   a:	6431                	.insn	2, 0x6431
   c:	6438                	.insn	2, 0x6438
   e:	20293263          	.insn	4, 0x20293263
  12:	3331                	.insn	2, 0x3331
  14:	322e                	.insn	2, 0x322e
  16:	302e                	.insn	2, 0x302e
	...
