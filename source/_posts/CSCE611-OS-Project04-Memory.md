---
title: CSCE611-OS-Project04-Memory
date: 2024-03-18 10:45:35
tags:
---

Github Link: https://github.com/tamu-edu-students/CSCE410-611-Spring2024-Hanzhong_Liu

Files I modified: 

- page table.H/C
- vm_pool.H/C
- copykernel.sh
  - Modified to fit Mac OS

### Design

#### 1. Page Table

**i. Extension of page table manager**

For *register_pool()*, I used a linkedlist to store all VMPools in PageTable. In PageTable, I added a new variable:
```c++
// vm pools
static VMPool * pool_link_head;
```

This is the head of all vm_pools. In VMPool, there is a new variable *next_pool* which point to the next pool. By doing this, I realized the register_pool by adding the pool to the end of the linkedlist in VMPool's constructor.

```c++
void PageTable::register_pool(VMPool * _vm_pool)
{
   VMPool * node=pool_link_head;
   if(node == nullptr){
      pool_link_head = _vm_pool;
   }
   else{
      while(node->next_pool != nullptr){
         node=node->next_pool;
      }
      node->next_pool = _vm_pool;
   }
}
```

 For *free_page()*, first calculate the address of the page according to the page_no. Then, based on this address, find the corresponding page table. Set the corresponding pte value to 0. Then release the corresponding frame in the frame pool. Thus realize the release of memory.



**ii. Recursive page table lookup**

This is the menory structure:

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-02-23%20at%2022.05.15.png" alt="图片替换文本" width="350" align="bottom" />

process page faluts: 

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-02-25%20at%2010.43.20.png" alt="图片替换文本" width="500" align="bottom" />



Firstly, get fault virtual memory address from cr2"

```c++
unsigned long faulting_address = read_cr2();
```

Before fault handle, function need to check whether the address belong to a registed VMPool.

```c++
	 // check address in vm pool
   bool flag=false;

   VMPool * node = pool_link_head;

	 // no vm pool, so not make checking
   if(node == nullptr) flag =true;

   while(node != nullptr){
     	// first two pages, used to store memory usage information
      if(faulting_address >= node->base_address && faulting_address <= (node->base_address+PAGE_SIZE*2) ){
         flag=true;
         break;
      }

      // is_legitimate ?
      flag = flag || node->is_legitimate(faulting_address);

      node=node->next_pool;
   }
```



If address is legitimate, get page dir index and page table index from address. pd_index is the top 10 bits and pt_index can get from bits from 12 to 22.

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



#### 2.VM Pool

The `VMPool` class is responsible for managing a virtual memory pool, which includes allocating and releasing memory regions as well as checking the legitimacy of addresses. Here's a detailed breakdown of each function in the class:

1. **Constructor `VMPool`**: Initializes a virtual memory pool with a given base address, size, frame pool, and page table. It registers the pool with the page table and sets up the data structures for tracking used and free memory regions.

2. **`allocate(unsigned long _size)`**: The `allocate` method in the `VMPool` class is responsible for allocating a region of memory from the virtual memory pool. It uses two arrays (first to frames in frame_pool), `used_memory_info` and `free_memory_info`, to track the memory usage. Each entry in these arrays consists of a pair of values, representing the start and end addresses of a memory region. This is structure of `used_memory_info`:

   <img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-03-18%20at%2019.41.59.png" alt="图片替换文本" width="700" align="bottom" />



1. **`release(unsigned long _start_address)`**: Releases a region of previously allocated memory identified by its start address. It removes the region from the used memory info, adds it back to the free memory info, and releases the corresponding pages in the page table.

2. **`is_legitimate(unsigned long _address)`**: Checks whether a given address is part of a currently allocated region. It returns `true` if the address is within the range of an allocated block and `false` otherwise.

Additionally, the class has private member variables for storing the size of the pool, pointers to the frame pool and page table, and arrays for tracking used and free memory regions. It also defines a constant `PAGE_SIZE` for the page size and has a public member variable `base_address` for the base address of the pool.



### **Testing**:

**_TEST_PAGE_TABLE_ (Passed)** :

This test is designed to evaluate the implementation of page tables by accessing and writing to unmapped virtual memory. It determines the correctness of the page table implementation by verifying whether data can be accurately written to and read from virtual addresses.

```c++
#define FAULT_ADDR (4 * 1024 * 1024) // 4 MB, Address used to cause page faults in the test.
#define NACCESS ((1 MB) / 4) // (1 MB) / 4, Number of integer accesses (4 bytes each) starting from FAULT_ADDR.
```

I also extended this test from "(1 MB) / 4" to "(27 MB) / 4". This is because the physics address space it 32MB. The first 4MB is direct mapped and 15-16MB is the memory hole. So, there is total 27MB can be mapped. For "(27 MB) / 4", my code can pass the test too.

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-03-18%20at%2010.56.06.png" alt="图片替换文本" width="700" align="bottom" />



**_TEST_VM_POOL_ (Passed)** :

This test involves memory allocation and release operations. It tests the ability to correctly handle memory allocation and release requests, ensuring that memory is properly allocated when requested and correctly freed when no longer needed. 

```c++
int *arr = new int[size2 * i]; // allocate
delete[] arr; // release
```

My code prints out the IDs of the allocated memory frames and the frames released during the release process. Upon inspection, my vm_pool can correctly allocate and release frames.

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-03-18%20at%2010.54.45.png" alt="图片替换文本" width="700" align="bottom" />
