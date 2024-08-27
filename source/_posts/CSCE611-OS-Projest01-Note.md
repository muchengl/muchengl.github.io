---
title: CSCE611 OS Project01 Note
date: 2024-01-25 13:23:49
tags:
---

In this document, I describe the steps I took to add gdb debug support to the kernel in MacBook M2.

## 1) Environment preparation

Set up Bochs with  GDB support on MacBook M2:

**Step01**, download source code from bochs's GitHub releases: https://github.com/bochs-emu/Bochs/releases/tag/REL_2_7_FINAL

**Step02**, set the configure to enable GDB stub:


```shell
$ cd [Bochs' dir]
$ ./configure --enable-ne2000 \
            --enable-all-optimizations \
            --enable-cpu-level=6 \
            --enable-x86-64 \
            --enable-vmx=2 \
            --enable-pci \
            --enable-usb \
            --enable-usb-ohci \
            --enable-e1000 \
            --enable-disasm \
            --disable-debugger-gui \
            --with-sdl \
            --prefix=$HOME/opt/bochs \
            --enable-gdb-stub  # important, --enable-debugger is not work
```

**Step03**, prepare and make Bochs:

```shell
$ brew install sdl
$ make
```

**Step04**, install GDB:

Now, no native gdb is supposed in MacBook M2. So I installed another one : i386-elf-gdb

```shell
$ brew install i386-elf-gdb
```

## 2) Add debug support to the kernel

**Step05**, modify MP's makefile:

Add *-g* flag in makefile:

```makefile
AS=nasm

GCC=/opt/homebrew/Cellar/x86_64-elf-gcc/13.2.0/bin/x86_64-elf-gcc
LD=/opt/homebrew/Cellar/x86_64-elf-binutils/2.41_1/bin/x86_64-elf-ld

GCC_OPTIONS = -m32 -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -fno-exceptions -fno-rtti -fno-stack-protector -fleading-underscore -fno-asynchronous-unwind-tables

all: kernel.bin

clean:
	rm -f *.o *.bin

# ==== KERNEL ENTRY POINT ====
start.o: start.asm
	$(AS) -f elf -o start.o start.asm

# ==== UTILITIES ====
utils.o: utils.H utils.C
	$(GCC) $(GCC_OPTIONS) -g -c -o utils.o utils.C

# ==== DEVICES ====
console.o: console.H console.C
	$(GCC) $(GCC_OPTIONS) -g -c -o console.o console.C

# ==== KERNEL MAIN FILE ====
kernel.o: kernel.C
	$(GCC) $(GCC_OPTIONS) -g -c -o kernel.o kernel.C


kernel.bin: start.o kernel.o console.o utils.o linker.ld
	$(LD) -melf_i386 -T linker.ld -o kernel.bin start.o kernel.o console.o utils.o
```

Modify linker.ld, delete the first line *OUTPUT_FOTMAT('binary')*.

## Debug

**Step06**, start Bochs:

I did not install bochs. So I use the path to call its runnable file directly

```shell
$ /Users/lhz/bochs/bochs -f bochsrc.bxrc
```

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/start.png" alt="图片替换文本" width="800" align="bottom" />

**Step07**, start GDB and connect to Bochs:

```shell
$ i386-elf-gdb kernel.bin # start GDB
$ set architecture i386:x86-64:intel
$ target remote localhost:1234 # connect to bochs
```

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/connect.png" alt="图片替换文本" width="800" align="bottom" />

**Step08**, set breakpoint and debug in kernel:

```sh
$ b main() # set breakpoint
$ continue # stop at main(), the breakpoint
$ continue # enter main(), start console
```

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/running.png" alt="图片替换文本" width="800" align="bottom" />
