---
title: MITOSIS note
date: 2023-01-14 13:40:31
tags:
---

[MITOSIS Repo](https://github.com/ProjectMitosisOS)

## Remote Fork(C/R)

现有容器只能通过C/R的方法进行远程Fork。这种方法需要父进程首先需要*checkpoints* its states，并将state储存到文件里。在通过remote file copy或distributed file system将文件复制到子进程。子进程根据文件信息对夫进程进行恢复。由于C/R需要复制全部内存信息，因此很慢。例如需要对1G内存进行拷贝，C/R甚至比冷启动还要慢2.7倍。

## MITOSIS

MITOSIS【maɪˈtoʊsɪs】通过RDMA模拟本地Fork来实现高效的远程分叉（具有类似COW机制）。

![截屏2023-01-16 11.36.26](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-16%2011.36.26.png)

首先，我们将父对象的Metadata(例如页表)复制到一个压缩描述符来派生子对象。Note:不将父进程的内存页复制到描述符中。然后通过RDMA将描述符复制到子进程以恢复父进程的Metadata。子进程的“远程内存访问”会触发页面错误，内核将读区读取远程页面。避免了传输整个容器状态。同时，MITOSIS直接使用单边RDMA Read来读取远程物理内存，绕过所有软件开销。

### MITOSIS和C/R fork的比较

![截屏2023-01-14 13.40.51](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-14%2013.40.51.png)

**MITOSIS由以下四个模块组成：**

The *fork orchestrator* rehearsals the remote fork execution；准备fork和进行fork，使用rpc进行校验

The *network daemon* manages a scalable RDMA connection pool；单侧RDMA，维护RDMA连接pool

Extend OS’s *virtual memory subsystems* to utilize the remote memory with RDMA ；远程内存访问

*Fallback daemon* provides RPC handlers to restore rare remote memory accesses that cannot utilize RDMA；恢复机制，回退到RPC

## 1）准备fork和进行fork

### 1.fork_prepare

准备fork，使用一个结构体保存：

- CPU寄存器状态（用于恢复运行状态）
- cGroup和Namespace（用于进行容器化）
- 页表和虚拟内存区（用于远程内存访问）
- 打开文件信息（重新打开文件，使用CRIU）

保存这些信息，结构体很小，大概是KB级别

### 2.fork_resume

fork_resume从父进程获取descriptor，并恢复执行状态。

使用oneside RDMA获取descriptor。首先子进程通过RPC向父进程发一个authentication RPC，若认证通过，则父进程会返回descriptor’s stored address和payload。之后子进程就可以使用oneside RDMA获取descriptor。

获取到descriptor后，恢复容器状态。(1)设置cgroups和命名空间以匹配父操作系统的设置 (2)切换:用父进程的CPU寄存器、页表和I/O描述符替换调用方的CPU寄存器。此外引入SOCK以完成快速容器恢复。

## 2）单侧RDMA

RDMA：有三种QP类型

RDMA连接消耗较大，速度较慢。因此使用无连接的oneside RDMA。因此改进RDMA连接（DCT-dynamic connected transport），DCT保留了RC的功能，并进一步提供了一种无连接的方式:单个DCQP可以与不同的节点通信。

目标节点只需要创建一个DC，该DC由节点的RDMA地址和12B DC key标识。在知道key后，子节点可以在没有连接的情况下向相应的目标发送单侧RDMA请求，硬件会承载数据处理连接，速度极快(1μs以内).

基于DCT，网络守护进程管理一个小型内核空间DCQP池，用于处理来自子进程的RDMA请求。通常，每个cpu一个DCQP就足以充分利用RDMA。但是，仅使用DCT是不够的，因为孩子需要提前知道DCT key才能与父母通信。因此，MITOSIS实现了一个内核空间"fast RPC"来引导DCT。fast是一个基于ud的RPC，支持无连接。使用RPC，我们在RPC请求中装载与父对象关联的DCT键，以查询父对象的描述符。为了节省CPU资源，我们只部署了两个内核线程来处理rpc.

## 3）Virtual memory management

为了提高resume效率，直接将子节点映射页面的页表项(PTE)设置为父节点的物理地址(PA)。使用一个PTE中的remote bit来进行区分（remote bit位于PTE未被利用的高位）。在resume过程中，系统会设置remote bit并清除present bit，当子进程访问里该PTE，就会进入缺页中断，从而出发RDMA远程读取。

![截屏2023-01-16 13.18.22](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-16%2013.18.22.png)

如果错误页没有映射到父页，例如堆栈增长，我们就像处理普通的页错误一样在本地处理它。
否则，检查故障虚拟地址VA (virtual address)是否映射了远端PA。使用单边RDMA将远程page读到本地页。大多数子页面都可以通过RDMA恢复。在错过映射的情况下，则使用RPC映射。

RPC：每个节点有一个回退守护进程，该守护进程生成内核线程来处理子节点的页请求（包含父节点标识符和请求的虚拟地址）。回退逻辑: 在检查请求的有效性之后，守护进程线程将代表父进程加载页面。如果加载成功，我们将把结果发回给子进程。

**Access control and isolation**

我们需要拒绝对不再属于父节点的映射页的访问，并正确隔离对不同容器的访问。

直接暴露父节点的物理内存可以提高远程fork的速度。然而，我们需要拒绝对不再属于父节点的映射页的访问，并正确隔离对不同容器的访问。由于我们以cpu旁路的方式通过单边RDMA公开内存，因此只能利用RNIC进行控制。

MITOSIS用一种基于连接的内存访问控制方法。将不同的RDMA连接分配到父虚拟内存区域(VMA)的不同部分，例如，每个VMA一个连接。如果映射的物理页不再属于父页，我们将破坏与该页的VMA相关的连接。因此，child对页面的访问将被RNIC拒绝。所有连接都在内核中进行管理，以防止恶意用户访问错误的远程容器内存。

为了实现基于连接的访问控制，每个连接在创建和存储时都必须高效。幸运的是，DCQP很好地满足了这些要求。在子端，每个连接(DC key)只消耗12B ，不同的DC连接可以共享相同的DCQP。parent-side DC target consumes 144B。

![截屏2023-01-16 13.34.56](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-01-16%2013.34.56.png)

图片表示了基于dct的访问控制。在准备分叉时，MITOSIS从目标池中选择一个DC目标分配给每个parent VMA。pool在启动时初始化，并在后台定期填充。这些目标的DC key被装载在父进程的描述符中，以便子进程在恢复过程中可以将它们记录在VMA中。在读取父节点的page时，子节点将使用与页面VMA对应的key来发出RDMA请求。使用此方案，如果parent想要拒绝对该页的访问，它可以销毁相应的DC目标。



## Pre-fetching and caching

此处似乎有一定优化空间？可以采用计数法提升cache命中率。



