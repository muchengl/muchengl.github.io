---
title: CSCE611-OS-Project03
date: 2024-02-23 21:36:58
tags:
---

Github Link: https://github.com/tamu-edu-students/CSCE410-611-Spring2024-Hanzhong_Liu

Files I modified: 

- cont_frame_pool.H/C
- page table.H/C
- copykernel.sh
  - Modified to fit Mac OS

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-02-23%20at%2021.44.43.png" alt="图片替换文本" width="200" align="bottom" />

**Step 1** Init memory pools:
We have two pools : kernel pool and process pool. Kernel pool is used for store infomations from kernel like page table. Process pool is to allocate memory to processes. When a page fault is triggered, the page fault handle will get a frame from process pool and map it from the address that fault happened.

![mp2-frame-memory.drawio (1)](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/mp2-frame-memory.drawio.png)

**Step 2** add page fault handle

```c++
		class PageFault_Handler : public ExceptionHandler {
    public:
        virtual void handle_exception(REGS * _regs) {
            PageTable::handle_fault(_regs);
        }
    } pagefault_handler;
    

    ExceptionHandler::register_handler(14, &pagefault_handler);
```

In this code, we add a handle for fault 14, which is page fault. The page fault will be processed by the static function PageTable::handle_fault().



**Step 3** Init paging

```c++
		PageTable::init_paging(&kernel_mem_pool,
                           &process_mem_pool,
                           4 MB); /* We share the first 4MB */
    
    PageTable pt;
    
    pt.load();
```

In this code, we first init the PageTable's static variables by pass two memory pools to it (init_paging). In init_paging, we, first apply one frame from kernel pool for page directory. Than, we map the first 4MB of memory to it physical address(use another frame as the first page table). This can help us able to access kernel pool's frames directly.

This is the menory structure:

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-02-23%20at%2022.05.15.png" alt="图片替换文本" width="400" align="bottom" />

After that, we use *pt.load* to anable paging:
```c++
void PageTable::load()
{
   // before we set the paging bit to 1, we must put the address of the page directory into CR3.
   current_page_table = this;
   write_cr3((unsigned long) page_directory);
}

void PageTable::enable_paging()
{   
   paging_enabled = 1;
   //  the paging bit of CR0(bit 31) when set to 1 enables paging
   write_cr0(read_cr0() | 0x80000000);
}
```

**Step 4** process page faluts

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-02-25%20at%2010.43.20.png" alt="图片替换文本" width="500" align="bottom" />



Firstly, get fault virtual memory address from cr2"

```c++
unsigned long faulting_address = read_cr2();
```

Get page dir index and page table index from address. pd_index is the top 10 bits and pt_index can get from bits from 12 to 22.

```c++
 unsigned long pd_index = faulting_address >> 22; // index in page dir
 unsigned long pt_index = (faulting_address >> 12) & 0b1111111111; // index in page table
```

For two level page table, may the page table is not exist. We can determine it by check the first bit of pd[pd_index].
```c++
 if (!(pd[pd_index] & 1)) {
 	// page table not exist
   // apply a new frame from kernel pool
   ......
 }
```

In the end, we apply a new frame from process pool and add it to page table.

```c++
 unsigned long new_frame = process_mem_pool->get_frames(1);
 pt[pt_index] = (new_frame * PAGE_SIZE) | 3;
```



**Result**:

![Screenshot 2024-02-23 at 22.22.42](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-02-23%20at%2022.22.42.png)
