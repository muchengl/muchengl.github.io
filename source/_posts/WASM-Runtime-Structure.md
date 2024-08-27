---
title: WASMEdge Runtime Structure
date: 2023-03-16 11:31:14
tags:
---

Question：

拷贝数据粒度问题：

**Min：**Page （Mitosis）

Mixture：针对Function每次拷贝完整instance。针对memory等，则按页拷贝。

Instance：每次拷贝一个instance，例如一个FunctionInstance

Module ：每次拷贝一个module

**Max:** .wasm / .so （Faasm）

---





**Plan：**先用Tcp做测试，做好模块化，方便后面改quic。先做No COW

**Running Node：**

1.在TableInstance、FunctionInstance等.cpp文件，增加反序列化初始化函数（原始只有一个从Mod数据初始化的函数）。

```c++
instantiate(Module &Mod) //原始初始化函数
instantiate(String obj)  //反序列化初始化
  
instantiate_userfault()  //userfalut伪初始化
instantiate_userfault(String obj, fault_ref)  //userfault handle

```

2.在module.cpp，增加一个instantiate函数的重载，进行remote初始化runtime。此instantiate函数，调用第1条中的反序列化初始化函数进行初始化

**Memory Node：**

3.设计一个“镜像类”，用于"镜像"和"储存"序列化后的runtime数据。并设计一个network方法，用于监听网络请求，根据请求发送相应的runtime数据



```c++
std::vector<FunctionInstance *> FuncInsts; // 不需要postcopy,直接拷贝FuncSec即可
std::vector<TableInstance *> TabInsts;     // 不需要postcopy,直接拷贝TabSec即可
std::vector<MemoryInstance *> MemInsts;    // 需要PostCopy
std::vector<GlobalInstance *> GlobInsts;   // 直接拷贝 GlobSec
std::vector<ElementInstance *> ElemInsts;  // 直接拷贝 ElemSec
std::vector<DataInstance *> DataInsts;     // 需要PostCopy
```



### No COW

一次性拷贝：Store，Conf。之后直接执行

### COW

只拷贝Conf，拷贝Store的大小。然后进行userfault初始化。之后执行，遇到fault，则利用handle线程处理

## WASMEdge分析

1.wasm相关数据存储在Store中

2.一个wasm程序由多个modules组成

**启动流程：**

```c++
//待运行文件待路径
const auto InputPath = std::filesystem::absolute(SoName.value());

/*******************/ 
// 根据Config，初始化VM
// 需要包含全部cli参数

VM::VM VM(Conf);
	-> unsafeInitVM(); 
		-> unsafeLoadBuiltInHosts();     加载 BuiltInModInsts
			 unsafeRegisterBuiltInHosts(); 登记 ExecutorEngine.registerModule
			 	-> instantiate(StoreMgr, Mod, Name)
/*******************/ 
      
/*******************/    
// 初始化module，包含TableSec、FunctionSec	等		
// 根据module，初始化stack
      
VM.loadWasm(InputPath.u8string());
	-> LoaderEngine.parseModule(Path)
		-> FMgr.setPath(FilePath)
		-> module.loadModule()                  //读取文件，初始化module 
    																				//初始化 VM.Mod
		
VM.validate();
	-> ValidatorEngine.validate(*Mod.get())   //验证module
                                            //即上一步获得的 VM.Mod
	
VM.instantiate();
	-> ExecutorEngine.instantiateModule(StoreRef, *Mod.get())
			-> instantiate(StoreMgr, Mod)         //初始化StackManager + 初始化module中的参数（参考文档）
			-> 初始化 ActiveModInst                //后续使用ActiveModInst进行函数调用
    
/********************/


//初始化系统环境,WASI
WasiMod->getEnv().init(
      Dir.value(),
      InputPath.filename()
      Args.value(), Env.value());

//初始化输入参数
std::vector<ValVariant> FuncArgs;

//执行
VM.asyncExecute(FuncName, FuncArgs, FuncArgTypes);
	-> ExecutorEngine.invoke(*FuncInst, Params, ParamTypes)
		-> runFunction(StackMgr, FuncInst, Params) 
			FuncInst是一个指针，指向Stack中的函数位置

//End：输出执行结果
```

## Remote Migration steps

### Step1: VM init

这一步，需要从远端拷贝Conf。然后返序列化Conf进行初始化。

```c++
VM(const Configure &Conf):
  Conf(Conf)                                            // 给本地变量Conf赋值
  Stage(VMStage::Inited),                               // 默认Init参数，不用改
  LoaderEngine(Conf, &Executor::Executor::Intrinsics),  // 把Conf赋值给LoaderEngine    Loader
  ValidatorEngine(Conf),                                // 把Conf赋值给ValidatorEngine Validator
  ExecutorEngine(Conf, &Stat),                          // 把Conf赋值给ExecutorEngine  Executor
  Store(std::make_unique<Runtime::StoreManager>()),     // 把Store赋值为新实例化的StoreManager
  StoreRef(*Store.get())                                // 把StoreRef赋值为Store的指针
{
		unsafeLoadBuiltInHosts();                           // 加载Wasi？
    unsafeRegisterBuiltInHosts();                       // 在ExecutorEngine存储，StoreRef和WASI对象
}
```

### Stpe2: Module & Stack init

将以下三步：VM.loadWasm() -> VM.validate() -> VM.instantiate()

由本地读取文件从而实例化module，改为云端获取。需要拷贝很多个细小的变量，一个都不能漏掉

```c++
 	// 实例化 VM.Mod 
  // 1.Postcopy VM.Mod
  // 2.修改Stage Stage = VMStage::Loaded
 	VM.loadWasm(InputPath.u8string());

  // 验证VM.Mod
  // 1.修改Stage
	VM.validate();

  //  Stage = VMStage::Instantiated;
  //  实例化 ActiveModInst
  // 1.Postcopy StoreRef            (StoreMgr.registerModule)   初始化 StoreRef中的参数，
  //                                                            NamedMod，一个map，储存了所有Module
  // 2.Postcopy StackMgr            (StackManager StackMgr)     完整的进行反序列化（可能不用拷贝实际上）
  // 3.Postcopy ActiveModInst       (ActiveModInst)             完整的进行反序列化
  //                                                            (这个参数实际上Store中已经包含，因此可能不需要拷贝)
	VM.instantiate();
```

No COW：需要从远端拷贝module，直接反序列化

COW：先假初始化，遇到了page fault再从远端拷贝

**参考：**

module本地加载实现：**lib/loader/ast/module.cpp**

module定义： **include/ast/module.h**

StoreMgr、moduleInstance初始化：**lib/executor/instantiate/module.cpp**    
															lib/executor/instantiate/data.cpp



### moduleInstance实例化

```c++
// 定义
std::unique_ptr<Runtime::Instance::ModuleInstance> ModInst;

ModInst = std::make_unique<Runtime::Instance::ModuleInstance>(Name.value());

// 初始化 FuncType
ModInst->addFuncType(FuncType);

//初始化ImportSec
AST::ImportSection &ImportSec = Mod.getImportSection();
instantiate(StoreMgr, *ModInst, ImportSec)
  
  
//初始化FuncSec，CodeSec
const AST::FunctionSection &FuncSec = Mod.getFunctionSection();
const AST::CodeSection &CodeSec = Mod.getCodeSection();
instantiate(*ModInst, FuncSec, CodeSec);

//初始化 TabSec
AST::TableSection &TabSec = Mod.getTableSection();
instantiate(*ModInst, TabSec);

//初始化 MemSec
const AST::MemorySection &MemSec = Mod.getMemorySection();
instantiate(*ModInst, MemSec);
  
// 初始化 GlobSec

//初始化ExportSec
const AST::ExportSection &ExportSec = Mod.getExportSection();
instantiate(*ModInst, ExportSec);

//初始化ElemSec
instantiate(StackMgr, *ModInst, ElemSec)
  
//初始化   DataSec
instantiate(StackMgr, *ModInst, DataSec)
  
```



---





https://github.com/bytecodealliance/wasm-micro-runtime/blob/main/doc/memory_tune.md

![截屏2023-03-16 11.32.20](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-03-16%2011.32.20.png)





https://juejin.cn/post/6844904062148689933
