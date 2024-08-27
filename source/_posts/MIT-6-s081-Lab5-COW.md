---
title: MIT 6.s081 Lab5 COW
date: 2023-01-16 10:23:35
tags:
---

## Code

COW标志位，/rich.h。储存在保留位里

```
#define COW_FLAG (1L << 8)
```

复制内存的代码，在fork中有被调用

```
int
uvmcopy_u(pagetable_t old, pagetable_t new, uint64 sz)
{
    pte_t *pte;
    uint64 pa, i;
    int flags;

    for(i = 0; i < sz; i += PGSIZE){
        if((pte = walk(old, i, 0)) == 0)
            panic("uvmcopy: pte should exist");
        if((*pte & PTE_V) == 0)
            panic("uvmcopy: page not present");

        // 旧进程的物理内存
        pa = PTE2PA(*pte);

        // COW
        *pte = (*pte & ~PTE_W) | COW_FLAG;
        flags = PTE_FLAGS(*pte);

        if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){
            goto err;
        }
        con[getrefindex((uint64*)pa)]++;

    }
    return 0;

err:
uvmunmap(new, 0, i / PGSIZE, 1);
return -1;
}
```

处理内存非法访问（页）中断的代码

```
else if(r_scause() == 15){
//      printf("page\n");
        struct proc *p = myproc();

        /* 【xv6对页的操控粒度为Page】
         * 需要将当前虚拟地址所对应的page进行拷贝
         * 由于虚拟地址可能指向页的中间
         * 因此需要向下对其到页的边界
         * 从而将这一页全部都进行拷贝（COW）
         */
        uint64 va=PGROUNDDOWN(r_stval()); // 虚拟地址

        pte_t *pte; // pte
        pte = walk(p->pagetable, va, 0);

        if(*pte & COW_FLAG){ //是cow页面
            uint64 pa=PTE2PA(*pte); // 物理地址

            char *mem;
            //分配一页新内存
            if((mem = kalloc()) == 0)
                panic("uvmtrap: pte alloc exist");

            // 拷贝旧数据的值到新page
            memmove(mem, (char*)pa, PGSIZE);

            int flags = PTE_FLAGS(*pte);

            flags =flags | PTE_W;
            flags &= ~COW_FLAG;
//            *pte &=~PTE_V;
            // 进行内存映射
            mappages(p->pagetable, va, PGSIZE, (uint64)mem, flags);


            kfree((void*)pa);

        }

```

释放内存代码（引用计数）：

```
// derf.h
extern int con[];
extern int getrefindex(void*);
```

```
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP) {
      panic("kfree");
  }

  con[getrefindex(pa)]--;
  //printf("%d",con[(uint64)pa/PGSIZE]);
  if(con[getrefindex(pa)]>0){
      return;
  }

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
```

![截屏2023-01-16 10.31.45](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-16%2010.31.45.png)
