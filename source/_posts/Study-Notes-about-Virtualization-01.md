---
title: Study Notes about Virtualization 01
date: 2022-11-29 19:11:01
tags: Virtualization
---

## Docker runtime environment

![img_3faaf387af747fdecd5530e05bfceeb0](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/img_3faaf387af747fdecd5530e05bfceeb0.jpg)

Docker初始发展高度封闭，后期转向开放路线。此时Docker的运行依赖为Runc。Runc是一个实现了OCI（[Open Container Initiative](https://www.opencontainers.org/)）协议的组件。因此可以通过支持OCI协议，实现对Runc的替换，从而实现自己的Docker运行时依赖。

Userful Link：
Blog：https://xuanwo.io/2019/08/06/oci-intro/
OCI Repo：https://github.com/opencontainers/runtime-spec

## gVisor

[gVisor](https://cloud-atlas.readthedocs.io/zh_CN/latest/kubernetes/virtual/gvisor/gvisor_quickstart.html）)是一个谷歌的开源项目。实现了OCI协议，因此可以作为Docker的runtime。Docker存在安全问题，程序有可能逃逸出Container，从而威胁操作系统本身运行。因此需要一款更加安全的Runtime application。gVisor就是这样的一款app。

gVisor是一个sandbox，实现了一个“应用内核”——Sentry。原理是劫持了应用程序的全部sys call，利用Ptrace(or KVM)。Sentry劫持到sys call后，使用go语言模拟出了sys call的功能，从而实现了一个虚拟内核。隔离了程序和Host Kernel。

同时gVisor有一个Gofer模块，用于处理应用程序的IO。

![665372-20210108180022427-177964885](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/665372-20210108180022427-177964885.png)

## Learning Plan

- Step1: 学完go
- Step2: 看[Runc](https://github.com/opencontainers/runc)的代码，研究OCI怎么实现的
- Step3: 看[gVisor](https://cloud-atlas.readthedocs.io/zh_CN/latest/kubernetes/virtual/gvisor/gvisor_quickstart.html)的代码，研究实现细节
- Step4: 实现一个自己的Docker runtime，这个Runtime应该具有以下特点：
    - 使用go实现
    - 简单轻量，但具有完备的功能，可以完美的作为一个OJ系统的Sandbox
    - 利用Ptrace实现
    - 支持使用json自定义sys call的调用规则（Allow List），以及进行内存时间限制，~~并实现一套简易的对外交互接口([CRI](https://github.com/kubernetes/cri-api/blob/master/pkg/apis/runtime/v1/api.proto))~~
    - 支持OCI，可以作为Docker的runtime，支持K8S分发部署user code，从而可以作为OJ系统的评测集群Worker，
    - 严格保证高代码质量，保证高可读性，可维护性



​	
