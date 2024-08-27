---
title: CSCE611 OS Env Prepare (Macbook M-chip)
date: 2024-01-23 20:56:35
tags:
---

This assumes that you have at the very least set up developer tools and [Homebrew](https://brew.sh) on your machine.

## Step01, GCC Install

In the class, we need to build a unix-like kernel in X86 arch. Because MacBook with M2 chip is arm arch. So, we can't use the original gcc in homebrew. Fortunate, there is a **x86_64-elf-gcc** in home-brew repo:
```
➜  ~ brew search gcc
==> Formulae
aarch64-elf-gcc ✔                                            libgccjit
arm-none-eabi-gcc                                            nativeos/i386-elf-toolchain/i386-elf-gcc
gcc                                                          nativeos/i386-elf-toolchain/i386-elf-gcc@11.1
gcc@10                                                       nativeos/i386-elf-toolchain/i386-elf-gcc@11.2
gcc@11 ✔                                                     riscv64-elf-gcc
gcc@12 ✔                                                     x86_64-elf-gcc ✔
gcc@5                                                        ghc
gcc@6                                                        grc
gcc@7                                                        scc
gcc@8                                                        tcc
gcc@9                                                        ncc
i686-elf-gcc
```

Use **brew search gcc** in terminal, you can find "x86_64-elf-gcc". So, use "brew install x86_64-elf-gcc" to install it. Now, you can use "aarch64-elf-gcc" to compail the kernel.

All tool intalled by gcc will be store in this path: **/opt/homebrew/Cellar/**. So you should heve this "/opt/homebrew/Cellar/x86_64-elf-binutils/2.41_1/bin/x86_64-elf-ld".

## Step2, Tools Install

- Install wget `brew install wget`
- Install nasm: `brew install nasm`
- Install qemu and bochs: `brew install qemu bochs`

