---
title: MIT 6.s081 Lab4 Trap
date: 2023-01-13 18:43:35
tags:
---

## RISC-V assembly

```
int g(int x) {
  return x+3;
}

int f(int x) {
  return g(x);
}

void main(void) {
  printf("%d %d\n", f(8)+1, 13);
  exit(0);
}
```

```
0000000000000000 <g>:
#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int g(int x) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  return x+3;
}
   6:	250d                	addiw	a0,a0,3
   8:	6422                	ld	s0,8(sp)
   a:	0141                	addi	sp,sp,16
   c:	8082                	ret

000000000000000e <f>:

int f(int x) {
   e:	1141                	addi	sp,sp,-16
  10:	e422                	sd	s0,8(sp)
  12:	0800                	addi	s0,sp,16
  return g(x);
}
  14:	250d                	addiw	a0,a0,3
  16:	6422                	ld	s0,8(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret

000000000000001c <main>:

void main(void) {
  1c:	1141                	addi	sp,sp,-16
  1e:	e406                	sd	ra,8(sp)
  20:	e022                	sd	s0,0(sp)
  22:	0800                	addi	s0,sp,16
  printf("%d %d\n", f(8)+1, 13);
  24:	4635                	li	a2,13
  26:	45b1                	li	a1,12
  28:	00000517          	auipc	a0,0x0
  2c:	7a850513          	addi	a0,a0,1960 # 7d0 <malloc+0xe8>
  30:	00000097          	auipc	ra,0x0
  34:	600080e7          	jalr	1536(ra) # 630 <printf>
  exit(0);
  38:	4501                	li	a0,0
  3a:	00000097          	auipc	ra,0x0
  3e:	28e080e7          	jalr	654(ra) # 2c8 <exit>

0000000000000042 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  42:	1141                	addi	sp,sp,-16
  44:	e406                	sd	ra,8(sp)
  46:	e022                	sd	s0,0(sp)
  48:	0800                	addi	s0,sp,16
  extern int main();
  main();
  4a:	00000097          	auipc	ra,0x0
  4e:	fd2080e7          	jalr	-46(ra) # 1c <main>
  exit(0);
  52:	4501                	li	a0,0
  54:	00000097          	auipc	ra,0x0
  58:	274080e7          	jalr	628(ra) # 2c8 <exit>

000000000000005c <strcpy>:
}
```

## RISC-V trap machinery

- stvec ：内核在这里写入它的trap处理程序的地址;RISC-V跳转到stvec中的地址来处理trap。
- sepc：当一个trap发生时，RISC-V将程序计数器保存在这里(因为pc会被stvec中的值覆盖)。sret (return from trap)指令将sepc复制到pc上。内核可以编写sepc来控制sret的位置。
- scause：RISC-V在这里放了一个数字来描述trap的原因。
- sscratch： trap处理程序代码使用sscratch来避免在 保存用户寄存器之前覆盖用户寄存器。
- sstatus：sstatus中的SIE位控制是否启用设备中断。如果内核清除了SIE, RISC-V将延迟设备中断，直到内核设置了SIE。SPP位表示trap来自用户模式还是管理模式，并控制sret返回哪种模式。

RISC-V中断发生过程：

1. 如果设备中断，且sstatus SIE位为清零，则无需执行以下操作
2. 通过清除sstatus中的SIE位来禁用中断。
3. Copy the pc to sepc.
4. 将当前模式(user或supervisor)保存在sstatus的SPP位中。
5. 设置原因以反映陷阱的原因。
6. Set the mode to supervisor
7. Copy stvec to the pc.
8. 在新的pc位置开始执行

## User Trap

用户中断当用户调用了ecall指令时发生（或发生了非法操作或硬件中断）。

用户发生中断：
step1: uservec
step2: usertrap

当中断返回：
step1: usertrapret
step2: userret

### 1. 发生中断

TRAMPOLINE page在程序初始化时放置，位于user虚拟地址的顶部，同时TRAMPOLINE在内核页表也被映射。且没有 PTE_U标志。因此trap handler在切换到内核page后可以继续执行。

![截屏2023-01-13 23.20.51](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-13%2023.20.51.png)

为了保存用户状态，uservec会将用户寄存器状态保存在TRAPFRAME（一个结构体）。TRAPFRAME 在 TRAMPOLINE之下。

```
struct trapframe {
  /*   0 */ uint64 kernel_satp;   // kernel page table
  /*   8 */ uint64 kernel_sp;     // top of process's kernel stack
  /*  16 */ uint64 kernel_trap;   // usertrap()
  /*  24 */ uint64 epc;           // saved user program counter
  /*  32 */ uint64 kernel_hartid; // saved kernel tp
  /*  40 */ uint64 ra;
  /*  48 */ uint64 sp;
  /*  56 */ uint64 gp;
  /*  64 */ uint64 tp;
  /*  72 */ uint64 t0;
  /*  80 */ uint64 t1;
  ......
};
```

TRAPFRAME中保存了内核page的信息和cpu信息，uservec从这里获取信息。然后执行usertrap。

 usertrap的工作是确定trap的原因, 运行trap并返回。usertrap首先会保存sepc（用户程序计数器）。如果该trap是一个系统调用，则usertrap调用sycall来处理它;如果设备中断，devintr;否则它是一个异常，内核会终止发生故障的进程。

系统调用路径在保存的用户程序计数器上增加了4，因为RISC-V在系统调用的情况下，用户代码需要在后续指令处恢复执行（不能反复执行sys call）。在退出过程中，usertrap检查进程是否已经被杀死或应该产生CPU(如果这个trap是一个定时器中断)。

### 2. 中断返回

返回第一步是运行usertrapret。然后执行userret。这俩恢复了一些寄存器状态，返回用户空间。

## initcode.S（如何调用sys call）

initcode.S将exec的参数放在寄存器a0和a1中，并将系统调用号放在a7中。系统调用号匹配syscalls数组中的条目，syscalls数组是一个函数指针(kernel/syscall.c:107)。调用指令被捕获到内核中，并导致uservec、usertrap和sycall执行。

```
 la a0, init
 la a1, argv
 li a7, SYS_exec
 ecall
```

Syscall (kernel/ Syscall .c:132) 从trapframe中保存的a7中获取系统调用号，并使用它索引到系统调用中。对于第一个系统调用，a7包含SYS_exec (ker- nel/ sycall .h:8)，导致调用系统调用实现函数SYS_exec。

当sys_exec返回时，系统调用将返回值记录在p->trapframe->a0中。这将导致对exec()的原始用户空间调用返回该值，因为RISC-V上的Ccall约定将返回值放在a0中。

系统调用通常返回负数表示错误，返回零或正数表示成功。如果系统调用号无效，系统调用将打印错误并返回−1。

## 

![截屏2023-01-15 00.09.58](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-15%2000.09.58.png)





