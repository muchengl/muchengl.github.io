---
title: MIT 6.s081 Lab2 System Call
date: 2023-01-10 15:48:20
tags:
---

## xv6系统用户态调用syscall过程分析

- /user/usys.S 是用户态进入内核态的汇编脚本，该文件由usys.pl生成

```
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo  # 将syscall的标识写入a7寄存器
 ecall               # 使用ecall指令，使用a7寄存器，进入内核态
 ret
```

- /kernal/syscall.c，该函数获取用户态传递的syscall id，并进行调用

```
void syscall(void) {
  int num;
  struct proc *p = myproc(); //获取进入内核态的进程

  num = p->trapframe->a7;    //获取需要执行的系统调用id，该id由usys.S写入了a7寄存器


  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) { # 使用syscall的函数指针调用
  
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num](); #将syscall返回值保存在a0寄存器，通过此方法将返回值传递给用户态
    
  } else {
    printf("%d %s: unknown sys call %d\n",
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}
```

- /kernal/sysproc.c，该文件是lab2中syscall的实现代码文件

```
//实现syscall,该函数需在syscall.c中声明
uint64 sys_trace(void){

		// 获取system call 参数
    int muskid;
    argint(0,&muskid);

    return trace(muskid); //do something and return
}
```



## 添加syscall流程

1. 在syscall.h中添加一个syscall id
    ```
    #define SYS_trace  22
    #define SYS_sysinfo  23
    ```

2. 在syscall.c中添加syscall的函数定义

    ```
    extern uint64 sys_trace(void);
    extern uint64 sys_sysinfo(void);
    ```

    ```
    [SYS_trace]   sys_trace,
    [SYS_sysinfo]   sys_sysinfo
    ```

3. 在sysproc中实现syscall函数
    ```
    uint64 sys_trace(void){
        int muskid;
    
        // 获取system call 参数
        argint(0,&muskid);
    
        return trace(muskid);
    }
    ```

4. 在/user/usys.pl加入系统调用声明
    ```
    entry("trace");
    entry("sysinfo");
    ```

这样以来，用户态向内核态传递syscall id(a7)，内核态根据id对相应的syscall进行调用，并将返回值储存在a0寄存器。



## Trace



## Sysinfo





![截屏2023-01-10 02.03.22](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-10%2002.03.22.png)









