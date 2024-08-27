---
title: MIT 6.s081 Lab3 Page Table
date: 2023-01-11 12:42:53
tags:
---

## 页表结构推导

RICS-V架构，2^39bit内存可用，2^37Byte。每页是4096Byte，2^12 Byte

逻辑上，页表需要2^27个pte，以映射全部物理地址(pte是页表中对以应一个物理内存地址的信息存储单元)。

每个pte包含64bit（44bit PNN，一些Flag）。以下为pte结构：

![截屏2023-01-11 13.57.28](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-11%2013.57.28.png)

但是，2^27个pte需要内存：2^27 * 2^6 bit = 2^29 bit = 2^27byte = 2^10 * 2^10 * 2^9 byte = 512MB。若存储全部进程的pte则需要占用大量内存。因此使用三级页表结构：

一个页表页，包含512个pte。512^3=(2^9)^3，因此理论上可以使用三级页表表示全部的物理地址。当一块虚拟地址没有被使用，则相应的页表不会被初始化，则不需要使用内存。

![截屏2023-01-11 13.30.54](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-11%2013.30.54.png)

根据虚拟地址，获取相应pte (若该虚拟地址未被初始化，则进行相应的页表初始化)：

```
// pagetable 根页表
// va 虚拟地址
// alloc是否初始化
pte_t* walk(pagetable_t pagetable, uint64 va, int alloc){
  if(va >= MAXVA)
    panic("walk");

	// 三级页表
  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) { //已经分配
      pagetable = (pagetable_t)PTE2PA(*pte); //跳转到下一级页表
    } else { // 为分配此级页表
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0) //分配一页，并跳转到下一级页表
        return 0;
      memset(pagetable, 0, PGSIZE); //初始化页
      *pte = PA2PTE(pagetable) | PTE_V; 
    }
  }
  return &pagetable[PX(0, va)];
}
```

## 内核地址空间



## 进程地址空间



## Lab结果

![截屏2023-01-13 15.03.29](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-13%2015.03.29.png)

