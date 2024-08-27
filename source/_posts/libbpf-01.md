---
title: libbpf spinglock & map
date: 2023-02-10 14:21:40
tags:
---

## minimal

1. bpf程序，这一代码会被加载进bpf虚拟机，由事件触发执行。

````c
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

char LICENSE[] SEC("license") = "Dual BSD/GPL";

int my_pid = 0;

//定义 ELF section
SEC("tp/syscalls/sys_enter_write")
int handle_tp(void *ctx)
{
  // globle变量，读取pid
	int pid = bpf_get_current_pid_tgid() >> 32;

	if (pid != my_pid)
		return 0;

  // 向pipe发送字符串
	bpf_printk("BPF triggered from PID %d.\n", pid);

	return 0;
}
````

2. 用户空间代码

```c
#include <stdio.h>
#include <unistd.h>
#include <sys/resource.h>
#include <bpf/libbpf.h>
#include "minimal.skel.h"

static int libbpf_print_fn(enum libbpf_print_level level, const char *format, va_list args)
{
	return vfprintf(stderr, format, args);
}

int main(int argc, char **argv)
{
	struct minimal_bpf *skel;
	int err;

	libbpf_set_strict_mode(LIBBPF_STRICT_ALL);
	/* Set up libbpf errors and debug info callback */
	libbpf_set_print(libbpf_print_fn);

	/* Open BPF application */
	skel = minimal_bpf__open();
	if (!skel) {
		fprintf(stderr, "Failed to open BPF skeleton\n");
		return 1;
	}

	/* ensure BPF program only handles write() syscalls from our process */
	skel->bss->my_pid = getpid();

	/* Load & verify BPF programs */
	err = minimal_bpf__load(skel);
	if (err) {
		fprintf(stderr, "Failed to load and verify BPF skeleton\n");
		goto cleanup;
	}

	/* Attach tracepoint handler */
	err = minimal_bpf__attach(skel);
	if (err) {
		fprintf(stderr, "Failed to attach BPF skeleton\n");
		goto cleanup;
	}

	printf("Successfully started! Please run `sudo cat /sys/kernel/debug/tracing/trace_pipe` "
	       "to see output of the BPF programs.\n");

	for (;;) {
		/* 触发bpf程序，用于测试 */
		fprintf(stderr, ".");
		sleep(1);
	}

cleanup:
	minimal_bpf__destroy(skel);
	return -err;
}

```

## bpf Spinlocks

https://libbpf.readthedocs.io/en/latest/program_types.html

https://libbpf.readthedocs.io/en/latest/program_types.html

spinglock目前无法用于tracking和sccket filter相关ELF

![截屏2023-02-10 18.15.29](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-02-10%2018.15.29.png)

https://www.edony.ink/deepinsight-of-ebpf-map/

