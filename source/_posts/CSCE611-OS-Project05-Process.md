---
title: CSCE611-OS-Project05-Process
date: 2024-03-26 12:30:18
tags:
---

Github Link: https://github.com/tamu-edu-students/CSCE410-611-Spring2024-Hanzhong_Liu

Files I modified: 

1.**Scheduler and RR Scheduler**:

- Add rr_scheduler.C/H
- kernel.C : support rr_scheudler
- interrupt.C/H : enable interrupt
- thread.C/H: enable interrupt
- copykernel.sh: Modified to fit Mac OS

3.**Process**:

- Add process.C/H
- Add rr_scheduler.C/H
- kernel.C
- interrupt.C/H
- thread.C/H
- Add cont_frame_pool.C/H
- Add vm_pool.C/H
- Add page_table.C/H
- copykernel.sh: Modified to fit Mac OS



### 1. FIFO Scheduler

In the `Scheduler`, implement a queue using `LinkedList` to store `Threads`. Each time `Resume` is called, insert the thread at the end of the queue. When `yield` is called, pop the first thread from the queue and switch to it using `Thread::dispatch_to(Thread * _thread)`.

Design of LinkedList: 

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-03-29%20at%2019.42.01.png" alt="图片替换文本" width="750" align="bottom" />

1. `resume (append)`: This indicates that when a new thread is created or when a suspended thread is to be resumed, it is appended to the end of the queue.
2. `yield (pop)`: When function yield is called, scheduler will pop the first thread in ready queue and the use `Thread::dispatch_to` to start this thread.
3. Finally, `Thread::dispatch_to:` will use the low level `asm` code to set the current thread's stack to hardware to start the thread. 

To terminate a thread, two steps are involved: 1. releasing memory, and 2. removing the thread from the scheduler. To obtain the stack address of the current thread, I added a `Thread::Stack()` function.

```c++
static void thread_shutdown() {
    MEMORY_POOL->release((long unsigned int) current_thread->Stack());
    SYSTEM_SCHEDULER->terminate(current_thread);
}
```

**TEST:**

Launch the kernel, the output of threads shows on UI:

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-03-29%20at%2019.51.27.png" alt="图片替换文本" width="650" align="bottom" />

We can observe that threads are executed sequentially.

### 2.Enable Interrupt (bonus 1)

Within the `Thread` class, in the `Thread::thread_start` function, add `Machine::enable_interrupts();`.

In the scheduler, before `resume` and `yield`, call `Machine::disable_interrupts()` to prevent interrupts from occurring during a process switch. The worst-case scenario is when an interrupt occurs during an active process switch, causing the switch to terminate prematurely, and simultaneously triggering a process switch via `rr_schedule`, which would result in an erroneous switch.

The test for interrupt is in the RR Scheduler.

### 3.Round-Robin Scheduler (bonus 2)

To control the activation of the round-robin (RR) scheduler, a `scheduler_conf.H` file has been added. Additionally, an `eoq_timer` has been introduced, with its constructor taking an `RRScheduler`. Every 50ms, an interrupt is triggered, and `EOQTimer::handle_interrupt` calls the scheduler's `resume` and `yield` methods to implement thread preemption.

The implementation of `Interrupt` has been modified to add a function `InterruptHandler::send_end_of_interrupt(REGS * _r)`. In the scheduler, before switching to the next thread, `send_end_of_interrupt` is called to indicate the end of the current interrupt handling, ensuring that `Interrupt` can continue processing interrupts. Moreover, in `InterruptHandler::dispatch_interrupt`, `if(int_no!=0) send_end_of_interrupt(_r);` is added to indicate that the timer interrupt is handled by the scheduler, preventing the redundant sending of interrupt end signals.

**TEST: **

>  In the top of kernel.c, use `#define _ENABLE_RR_SCHEDULER_` to switch to RR_Scheduler.

According to the figure below, we can see that thread switching includes not only the switching of threads after the "BURST execution", but also periodic preemption switching

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-03-29%20at%2020.25.09.png" alt="图片替换文本" width="750" align="bottom" />



### 4.Processes (bonus 3)

After a discussion with the professor. In my operating system project, I have implemented a `kernel process system` with the following features and details:

- Ported the memory pool from previous assignments (MP2 to MP4) to the new project (MP5).

- Enabled virtual memory and implemented a `Process` class. During the initialization of a `Process`, two virtual memory pools are declared: `kernel_mem_pool` (3MB-4MB) for internal objects of the process (e.g., stack, which requires direct mapping) and `process_mem_pool` (4MB-256MB) for allocating memory to threads during runtime, providing them with new page tables and address spaces.
  
  ```c++
  Process::Process(unsigned long address_space_size);
  ```

  Within the constructor, the process initially switches to the `kernel_page_table` and `kernel_obj_pool`. It then uses the `new` operator to allocate memory for the process's page table and virtual memory pools, setting up the necessary environment for process execution.
  
- **Memory Management: ** 
  
  - Frame Pools: I used two frame pools: `kernel_frame_pool` and `process_frame_pool`
  - I utilized three virtual memory (VM) pools: `kernel_obj_pool`, `kernel_vm_pool`, and `process_vm_pool`:
    1. **`kernel_obj_pool`** (2MB - 3MB): This pool is reserved for kernel objects, such as the kernel page table. When the kernel needs to define a new object, like a new process, it switches to the `kernel_obj_pool` and uses the `new` operator to allocate memory for it.
    2. **`kernel_vm_pool`** (3MB - 4MB): This pool is used for the kernel stacks of threads. Each thread's kernel stack is allocated from this pool to ensure have a dedicated memory space.
    3. **`process_vm_pool`**(4MB - 256MB): This pool is used for the execution of processes. When a thread starts, the kernel sets `current_thread` to the thread's process VM pool, allowing the process to allocate objects within its own address space.
  
  
  ![Screenshot 2024-03-29 at 20.53.46](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-03-29%20at%2020.53.46.png)
  
- Retained the `Thread` class, similar to the original design, containing an `esp` attribute to store the current process's stack address, code segment, etc. It includes `push` and `set_context` functions to establish the context of the process. 
  Additionally, due to threads belonging to different address spaces, a page table address for the current address space is added to the `Thread` class (passed in from the process).

  The constructor and functions of the `Thread` class is designed as follows:

  ```c++
  Thread::Thread(Thread_Function _tf, char * _stack, unsigned int _stack_size);
  
  void Thread::set_process(Process * _process);
  
  void Thread::set_pt(PageTable * pt);
  ```

- **Thread Management:** Added an `add_thread` function to the `Process` class, allowing the addition of a new thread to the process. This function first disables interrupts, then switch to page table of current process, and then allocates memory from the `kernel_vm_pool` for the stack. It creates a new `Thread` object, and adds it to the scheduler's queue (without implementing "Thread level scheduling").

  ```c++
  Process::add_proces(Thread_Function _tf, int _stack_size)
  ```

- When the `RRScheduler` handles thread switching, it first compares the page table of the next thread with the current one. If they are different, the new page table is loaded into the register (pt->load()) and `current_pool` will be set to `process_vm_pool` of current process.. Since the first 4MB is directly mapped to the kernel pool, switching page tables does not affect system operation.
  ```c++
  Console::puts("Switch CURRENT_POOL \n"); 
  CURRENT_POOL = current_thread->process->process_pool;
  
  PageTable * pt_ = current_thread->pt;
  pt_->load();
  ```

- With this setup, multiple threads can be continuously added to a process, and these threads will share the same address space.



**TEST: **

For testing, two processes are started: `process1` contains `Thread1` and `Thread3`, while `process2` contains `Thread2` and `Thread4`. 

```c++
// 2 processes and 4 threads
process1.add_thread(fun1, 1024);
process2.add_thread(fun2, 1024);
process1.add_thread(fun3, 1024);
process2.add_thread(fun4, 1024);
```

In the test, each thread accumulates its ticks in the memory location at 32MB + ThreadID. The expected result is that the ticks for threads within the same process are visible to each other, while the other locations are 0. 

>addr[1]                 addr[2]                 addr[3]                addr[4]
>
>[thread1's tick]   [thread2's tick]   [thread3's tick]   [thread4's tick]

The test code and output (which meets expectations) is as follows:

  ```c++
  unsigned long tick_addr = 32 MB;
  
  void fun1() {
      Console::puts("Thread: "); Console::puti(Thread::CurrentThread()->ThreadId()); Console::puts("\n");
      Console::puts("FUN 1 INVOKED!\n");
      int id=1;
      unsigned long * addr = (unsigned long *)(tick_addr);
      addr[id]=0;
  
  		// _TERMINATING_FUNCTIONS_
  		for(int j = 0; j < 10; j++) {	
          Console::puts("FUN 1 IN BURST["); Console::puti(j); Console::puts("]\n");
          for (int i = 0; i < 10; i++) {
              Console::puts("FUN 1: TICK ["); Console::puti(i); Console::puts("]\n");
  
            	// add tick to memory
             	unsigned long * addr = (unsigned long *)(tick_addr);
              addr[id]+=id;
          }
          pass_on_CPU(thread2);
      }
  
      Console::puts("====== FUN 1 ======\n");
      for(int i=1;i<=4;i++){
          unsigned long * addr = (unsigned long *)(tick_addr);
          Console::puts("TICK in Idx "); 
          Console::puti(i); 
          Console::puts(", Num: "); 
          Console::puti(addr[i]);
          Console::puts("]\n");
      }
      return;
  }
  
  ```
**Test Output:**

  ```python
  # Thread 3 finished firstly. 
  # Got 92 ticks from Thread 1. (because thread 1 haven't stop, so not 100)
  # Get 300 ticks Thread 3(itself)
  # Got 0 ticks from Thread 2 and Thread 4. (since Thread 2 and Thread 4 belong to the different address sapce)
  ====== FUN 3 ======
  TICK in Idx 1, Num: 92
  TICK in Idx 2, Num: 0
  TICK in Idx 3, Num: 300
  TICK in Idx 4, Num: 0
  
  # Thread 2 finished. 
  # Got 368 ticks from Thread 4. (because thread 4 haven't stop, so not 400)
  # Got 200 ticks from Thread 2. (itself) 
  # Got 0 ticks from Thread 2 and Thread 4.
  ====== FUN 2 ======
  TICK in Idx 1, Num: 0
  TICK in Idx 2, Num: 200
  TICK in Idx 3, Num: 0
  TICK in Idx 4, Num: 368
  
  ====== FUN 4 ======
  TICK in Idx 1, Num: 0
  TICK in Idx 2, Num: 200
  TICK in Idx 3, Num: 0
  TICK in Idx 4, Num: 400
  
  ====== FUN 1 ======
  TICK in Idx 1, Num: 100
  TICK in Idx 2, Num: 0
  TICK in Idx 3, Num: 300
  TICK in Idx 4, Num: 0
  ```

So this test verified that Process1 and Process2 have different address Spaces. This test also verified the accuracy of Thread running (according to Tick number), thread switching and page table switching.

This proves that I have completed a basic kernel process.
