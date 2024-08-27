---
title: CSCE611-OS-Project05-Thread
date: 2024-03-24 17:40:44
tags:
---

1.FIFO

在Scheduler里实现一个队列LinkedList，储存Threads。每次调用Resume，则将thread插入队尾。调用yield，则pop出第一个thread，并使用 Thread::dispatch_to(Thread * _thread) 切换。



为了实现终止thread，包含两个步骤，1.释放内存，2.从scheduler删除thread。为了获得当前thread的stack地址，我添加了一个Thread::Stack()函数。并修改：
```c++
static void thread_shutdown() {
    /* This function should be called when the thread returns from the thread function.
       It terminates the thread by releasing memory and any other resources held by the thread. 
       This is a bit complicated because the thread termination interacts with the scheduler.
     */
    Console::puts("thread_shutdown\n");

    MEMORY_POOL->release((long unsigned int) current_thread->Stack());
    SYSTEM_SCHEDULER->terminate(current_thread);
    
}
```





2.Enable Interrupt

在Thread里，Thread::thread_start函数里，添加if(!Machine::interrupts_enabled()) Machine::enable_interrupts();

在scheduler里，resume和yield前，调用Machine::disable_interrupts()，从而避免进行进程切换时发生中断。（最坏的情况时，进程主动切换时发生中断，切换终止，同时触发rr_schedule的进程切换，此是会产生错误的切换）





3.RR scheduler

- 为了控制是否启用rr scheduler，添加了一个scheduler_conf.H
- 添加eoq_timer，构造函数传入RRScheduler。每隔50ms，触发中断，EOQTimer::handle_interrupt调用scheduler的resume和yield
- 修改Interrupt实现，增加函数InterruptHandler::send_end_of_interrupt(REGS * _r)。在scheduler里，切换到下一个thread前，调用send_end_of_interrupt，表明当前中断处理结束，从而保证Interrupt可以继续处理中断。_
  _同时在InterruptHandler::dispatch_interrupt添加 if(int_no!=0) send_end_of_interrupt(_r);，表明时间中断，由timer发送结束信号，避免重复发送中断结束的信息。
- 缺点，scheduler不线程安全，Interrupt切换和thread本身的切换，可能冲突，导致队列里的内容不正确。经测试，单独启用RRScheduler，禁用thread本身切换，可以准确实现每隔50ms切换到下一个thread。





- 















4.Processes

- 将之前三个MP的Pool，移植到MP5

- 启用虚拟内存。实现Process类。在初始化Process时，为其声明两个vm_pool，kernel_mem_pool（3MB-4MB） 和 process_mempool（4MB-256MB）。kernel_mem_pool用于process的内部对象声明（例如Stack，需要直接映射），process_mem_pool在线程运行时用于给线程分配内存（因此具有新的页表，地址空间）。

  ```
  Process::Process(VMPool * vm_pool);
  ```

  

- 保留Thread，该Thread类似原有的Thread的设计。其中包含esp用于储存当前precess的stack地址，代码段等。包含push和set_context函数，以完成该process的context声明。
  此外，由于此时Thread之间属于不同的地址空间，因此需要在Thread里加入当前地址空间的页表地址（传入process）

  该类的构造函数设计：

  ```
  Thread::Thread(Thread_Function _tf, char * _stack, unsigned int _stack_size, Process * process);
  ```

  

- 为Process添加一个add_thread函数，用于向Process增加一个线程。此函数首先会停止中断，然后从kernel_vm_pool申请一块内存，用作stack。然后建立一个新的Thread对象，在本地的队列存储该Thread，同时并将改Thread对象add入scheduler的queue里（不设计“Thread level调度”）。

  ```
  Process::add_proces(Thread_Function _tf,int _stack_size)
  ```

  

- 当Scheduler处理Thread切换时，首先比较下一个Thread的page table与当前是否相同，不同的话则将新的page table load到寄存器。由于前4MB是直接映射到kernel pool，因此切换页表不会影响系统运行。



- 这样以来，就可以向一个Process里不断添加新的Thread，并且这些Thread具有相同的地址空间

- 测试，启动两个Process，process1包含Thread1和2，Process2包含Thread2和4。Thread会向地址为32MB+ThreadID的位置累加本线程的Tick。最终打印四个位置的Tick。
  ```c++
  unsigned long tick_addr = 32 MB;
  
  int id=1;
  unsigned long * addr = (unsigned long *)(tick_addr);
      
  unsigned long * addr = (unsigned long *)(tick_addr);
  addr[id]+=id;
  ```

  结构应该是，process1下的两个线程之间的tick相互可见，另外两个tick的位置是0。反之同理。测试结果（符合预期）：
  ```
  ====== FUN 3 ======
  TICK in Idx 1, Num: 92]
  TICK in Idx 2, Num: 0]
  TICK in Idx 3, Num: 300]
  TICK in Idx 4, Num: 0]
  
  ====== FUN 2 ======
  TICK in Idx 1, Num: 0]
  TICK in Idx 2, Num: 200]
  TICK in Idx 3, Num: 0]
  TICK in Idx 4, Num: 368]
  
  ====== FUN 4 ======
  TICK in Idx 1, Num: 0]
  TICK in Idx 2, Num: 200]
  TICK in Idx 3, Num: 0]
  TICK in Idx 4, Num: 400]
  
  ====== FUN 1 ======
  TICK in Idx 1, Num: 100]
  TICK in Idx 2, Num: 0]
  TICK in Idx 3, Num: 300]
  TICK in Idx 4, Num: 0]
  ```

  
