---
title: eBPF学习-01
date: 2023-01-19 14:08:05
tags:
---

## Prepare

安装eBPF教程（For ubuntu 18.04）：
https://blog.csdn.net/qq_33344148/article/details/123255679

在这里可以找到各个内核版本bcc的release，可以进行手工下载：
https://github.com/iovisor/bcc/releases/

eBPF BCC：
https://github.com/iovisor/bcc

Py BCC开发教程：
官方：https://github.com/iovisor/bcc/blob/master/docs/tutorial_bcc_python_developer.md
中文：https://blog.cyru1s.com/posts/ebpf-bcc.html

## Example-01

该代码对clone sys call进行追踪。

```python
from bcc import BPF
from bcc.utils import printb

# define BPF program
prog = """
int hello(void *ctx) {
    bpf_trace_printk("Hello, World!\\n");
    return 0;
}
"""

# load BPF program
b = BPF(text=prog)
# 添加探测点，追踪clone，可以添加多个探测点
b.attach_kprobe(event=b.get_syscall_fnname("clone"), fn_name="hello")

# header，表头
print("%-18s %-16s %-6s %s" % ("TIME(s)", "COMM", "PID", "MESSAGE"))

# format output
while 1:
    try:
      	# 从trace_pipe返回多个参数
        (task, pid, cpu, flags, ts, msg) = b.trace_fields()
    except ValueError:
        continue
    except KeyboardInterrupt:
        exit()
    printb(b"%-18.9f %-16s %-6d %s" % (ts, task, pid, msg))
```

## Example-02

该代码用于连续执行sync指令时进行打印

```py
from __future__ import print_function
from bcc import BPF
from bcc.utils import printb

# load BPF program
b = BPF(text="""
#include <uapi/linux/ptrace.h>

// 创建一个名为 last 的 BPF hash 映射
BPF_HASH(last);

int do_trace(struct pt_regs *ctx) {
    u64 ts, *tsp, delta, key = 0;

    // attempt to read stored timestamp
    // 读取存储的上一次时间戳
    tsp = last.lookup(&key);
    if (tsp != NULL) {
        // 计算过了多久
        delta = bpf_ktime_get_ns() - *tsp;
        // 小于1秒
        if (delta < 1000000000) {
            // output if time is less than 1 second
            bpf_trace_printk("%d\\n", delta / 1000000);
        }
        last.delete(&key);
    }

    // update stored timestamp
    // 更新时间戳
    ts = bpf_ktime_get_ns();
    last.update(&key, &ts);
    return 0;
}
""")

b.attach_kprobe(event=b.get_syscall_fnname("sync"), fn_name="do_trace")
print("Tracing for quick sync's... Ctrl-C to end")

# format output
start = 0
while 1:
    try:
        # 从trace pipe中读取数据，只有有数据时才会读取，否则阻塞
        (task, pid, cpu, flags, ts, ms) = b.trace_fields()
        if start == 0:
            start = ts
        ts = ts - start
        printb(b"At time %.2f s: multiple syncs detected, last %s ms ago" % (ts, ms))
    except KeyboardInterrupt:
        exit()

```

