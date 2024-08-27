---

title: Serverless服务快速启动方案
date: 2023-02-07 11:37:23
tags:
---

Version：2023-3-5

## 1. 问题综述

现尝试使用WASM、eBPF等技术优化Serverless服务。这一优化可以针对：实例启动速度、实例与外界交互能力、实例调度等方面。

逻辑上来说，一个Serverless实例的运行，必然经过以下几个步骤：
	1.获取待运行负载（负载可以是:WebAssembly、java字节码、go字节码等，是待运行的核心逻辑）
	2.实例加载负载，进行启动
	3.实例接受待处理数据，进行运算，并返回结果
	4.运行结束，实例销毁

**针对步骤1**，获取负载的常规方式是从对象存储服务下载负载，这一方法显然较慢。**AWS Lambda**对此提出了"预置并发"，这一服务可以在用户的虚拟子网中维持一个活跃的Lambda实例，从而避免冷启动。 **MITOSIS**某种意义上可以说是对"预置并发"进行了极致的优化，即使用RDMA从一个活跃的实例——Seed进行远程克隆，并使用COW渐进式的获取内存数据。**Faasm**针对此问题，则引入了一个KV数据库，存储各个server上实例的运行情况，从而实现了在已存在目标实例的server上处理任务，尽可能避免冷启动。这一优化是一种调度策略上的优化。

概括来说，步骤一的优化有三个方面：
	1.将实例负载存放比较“近”的地方，如保留一个活跃实例
	2.使用尽可能快速的方式获取负载，如RDMA
	3.避免冷启动，进行调度优化

**针对步骤2**，可以尝试优化启动速度本身，常见方式有优化编译产物、减小内存配置等，目前我们尝试采用的优化策略是使用WASM。（Faasm针对此步骤，使用了直接通过WASM runtime镜像启动的方法，优化了WASM容器启动的速度）

**针对步骤3**，原生WASM需使用WASI与系统交互，这一方法可能性能较差/适用范围较小。因此尝试采用WASM-eBPF工具，将部分运算下沉到eBPF虚拟机进行，从而获得serverless服务与外界更好的交互能力。

注：粗略估计，实际使用中Serverless服务绝大多数的对外交互都是网络交互，主要是读写数据。

**针对步骤4**，暂无优化措施

## 2. 加速Serverless启动的方案（运行状态恢复的三种路线）

由于原生MITOSIS对RDMA硬件有硬性要求，且需要修改内核，通用性相对较低。因此尝试利用WASM+eBPF+XDP等，实现一种更友好的Serverless快速启动策略，以下将这一策略称为MITOSIS-eBPF。（此处的mitosis取英文本身意思：有丝分裂，这是由于下列方案思路依然与原生mitosis类似，是从一个活跃实例快速分裂出大量子实例）

目前实现MITOSIS-eBPF有三种思路： 

### 1）在内核恢复进程

在内核恢复进程状态，这一思路与原生MITOSIS一致，需实现以下几点：

1. 对“被Fork进程”进行Metadata快照，并将此快照传递给“子进程”
2. 子进程需根据pte探知该Page是否在本地，若不在本地，则需要进行远程页获取
3. MITOSIS-eBPF需要能够读取指定进程的数据，从而通过rpc/XQUIC等方式传递给子进程

其中步骤二，原生MITOSIS的实现方式是利用pte中未被使用的高位作为标记，从而判断该page是否在本地。这一操作涉及内核修改，似乎无法通过eBPF实现，因此“在内核恢复进程”这一方案无法避免修改内核。

此外，XDP本身不具有完整的协议栈，无法保证数据传输的可靠。基于AF_XDP的成熟数据传输工具XQUIC，实现的是一个纯用户态的协议栈，因此似乎不适合对内核的Page进行传输。

### 2）在用户态WASM虚拟机中恢复进程（无COW）

以Faasm为例，Faasm会将容器快照保存在AWS S3中，收到相应请求时进行下载，并根据快照进行运行状态恢复。为了解决S3读取速度较慢的问题，可以在Faasm中添加一个类似MITOSIS的特性：即任意两个Faasm实例之间，可以进行容器状态拷贝。具体细节如下：

1. 当一个Faasm容器收到了“拷贝请求”后，对自身的容器状态进行快照。之后使用基于xdp (XQUIC)的数据传输方式将快照发送至发起“拷贝请求”的实例
2. Faasm被拷贝后，将快照缓存在内存中，下次被拷贝就不需要再次生成快照。同时之后其他Faasm实例都通过该fassm进行快照获取(可能需要在kv数据库中加入记录)。

在加速冷启动方面，Faasm本身有使用kv数据库寻找已存在目标负载的实例的机制。这一机制存在一个问题，若某一请求大量存在，则将会有大量wasm实例在同一server上启动。此时，“远程状态恢复”就可以帮助实现快速跨机器启动实例，或可以提升faasm的性能。

![截屏2023-03-01 20.41.43](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-03-01%2020.41.43.png)

这一方案仅仅针对Faasm或其他serverless平台进行拓展，无法形成通用解决方案，属于一个工程性问题。

### 3）在用户态WASM虚拟机中恢复进程（有COW）

**进一步研究**：https://muchengl.github.io/2023/03/09/User-space-page-fault-handling/

针对Faasm这一Serverless平台，Faasm中的Function实际运行在WASM虚拟机中。因此按照以下步骤进行远程Fork：

1. 子进程的WASM虚拟机初始化
2. 利用XQUIC，从“被Fork进程”获取“元数据”，在WASM虚拟机中进行状态恢复
3. 若子进程的WASM虚拟机遇到“缺页”，则利用XQUIC从进行远程页获取

这一方案的优势：

1. Faasm使用了Photo Faaslet快照+COW进行冷启动加速，因此“在WASM虚拟机中运用COW恢复进程状态”的可行性已知
2. 和MITOSIS思路完全一致，但全部在用户态完成，避免修改内核

这一方案的缺点：

1. 这一方案需要改WASM runtime的源代码，不是通用解决方案。

2. 由于用户态COW过程跨越了较多层，若Function涉及较多的远程页获取，可能会导致程序运行较慢，甚至有可能慢于原生Faasm的冷启动。

    



## 3. 在WASM虚拟机中COW恢复进程的可行性论证

### 1.Faasm怎么实现cow的，以及如何进行快照，并在WAVM里恢复运行状态

Faasm用了WARM里的AOT接口进行快照生成：

```c
aot_comp_context_t aot_create_comp_context(aot_comp_data_t comp_data, aot_comp_option_t option);
```

WAMR源代码分析：

***WAMR runtime(WAMR)的内存结构是分页的，且页是在内存上连续的片段，有明确的起始地址和Page size（数组），因此也许可以比较方便的进行远程页拷贝，需要改AOT的代码。***

```c
/**
 * Compiler context
 */
typedef struct AOTCompContext {
    AOTCompData *comp_data;      // 内存数据，是分页的

   	// Many llvm config data
		...
     
    /* Function contexts */
    AOTFuncContext **func_ctxes; // 函数context
    uint32 func_ctx_count;       // 程序计数器
    char **custom_sections_wp;
    uint32 custom_sections_count;

    /* 3rd-party toolchains */
    /* External llc compiler, if specified, wamrc will emit the llvm-ir file and
     * invoke the llc compiler to generate object file.
     * This can be used when we want to benefit from the optimization of other
     * LLVM based toolchains */
    const char *external_llc_compiler;
    const char *llc_compiler_flags;
    /* External asm compiler, if specified, wamrc will emit the text-based
     * assembly file (.s) and invoke the llc compiler to generate object file.
     * This will be useful when the upstream LLVM doesn't support to emit object
     * file for some architecture (such as arc) */
    const char *external_asm_compiler;
    const char *asm_compiler_flags;
} AOTCompContext;
```



```c
typedef struct AOTCompData {
    /* Import memories */
    uint32 import_memory_count;
    AOTImportMemory *import_memories;

    /* Memories */
    uint32 memory_count;
    AOTMemory *memories;
  
  	/*
  	typedef struct AOTMemory {
    	uint32 memory_flags;
    	uint32 num_bytes_per_page;
    	uint32 mem_init_page_count;
    	uint32 mem_max_page_count;
		} AOTMemory;
		
  	*/

    /* Memory init data info */
    uint32 mem_init_data_count;
    AOTMemInitData **mem_init_data_list;

    /* Import tables */
    uint32 import_table_count;
    AOTImportTable *import_tables;

    /* Tables */
    uint32 table_count;
    AOTTable *tables;

    /* Table init data info */
    uint32 table_init_data_count;
    AOTTableInitData **table_init_data_list;

    /* Import globals */
    uint32 import_global_count;
    AOTImportGlobal *import_globals;

    /* Globals */
    uint32 global_count;
    AOTGlobal *globals;

    /* Function types */
    uint32 func_type_count;
    AOTFuncType **func_types;

    /* Import functions */
    uint32 import_func_count;
    AOTImportFunc *import_funcs;

    /* Functions */
    uint32 func_count;
    AOTFunc **funcs;

    /* Custom name sections */
    const uint8 *name_section_buf;
    const uint8 *name_section_buf_end;
    uint8 *aot_name_section_buf;
    uint32 aot_name_section_size;

    uint32 global_data_size;

    uint32 start_func_index;
    uint32 malloc_func_index;
    uint32 free_func_index;
    uint32 retain_func_index;

    uint32 aux_data_end_global_index;
    uint32 aux_data_end;
    uint32 aux_heap_base_global_index;
    uint32 aux_heap_base;
    uint32 aux_stack_top_global_index;
    uint32 aux_stack_bottom;
    uint32 aux_stack_size;

    WASMModule *wasm_module;
#if WASM_ENABLE_DEBUG_AOT != 0
    dwar_extractor_handle_t extractor;
#endif
} AOTCompData;
```



### 2.ebpf高速网络通信方案
XQUIC







