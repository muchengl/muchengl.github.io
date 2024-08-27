---
title: eBPF(XDP & sockopts)加速数据传输问题
date: 2023-02-27 17:50:33
tags:
---

Best choice is XQUIC！XQUIC Yes！

## 1）XDP网络加速方案

经研究，基于xdp进行serverless服务启动加速这一问题，可以分为两个子问题：

 	1. 如何在WASM runtime中远程恢复运行状态
 	2. 如何使用XDP进行高效的数据传输？(是否已经有类似的解决方案？)

我认为两个问题中，问题2优先级更高。因为事实上这一问题可以拓展为：通过 xdp + sockopts 实现通用的网络加速方案。

目前网络上暂没有找到类似的解决方案（具体参考第二节），如果我们可以完成这种方案，则该方案不仅可以用于serverless加速，还可以应用于很多很多场景，将具有很好的前景。

初步构想：由于xdp本身并不具备完整的协议栈，也不能保证数据包的完整性。该设施使用ebpf-xdp技术替换某种网络协议的底层，从而实现一种高速网络通信方案

![截屏2023-02-27 19.33.35](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-02-27%2019.33.35.png)

## 2）eBPF在网络加速中的实例

AF_XDP技术较新，且AF_XDP的设计主要是针对数据包进行处理，目前可以找到一些AF_XDP在网关等应用的使用实例。这是由于xdp的性质，1）截获网络数据包，2）并重定向包到用户态进行处理，3）最后将数据包传输出去。这一特性非常适合应用于网关应用。

此外XDP在黑名单处理和抵御DDos攻击等方面已有较多实践。

但目前暂时没有找到使用AF_XDP进行数据传输的实践。

以下是一些关于eBPF进行网络加速的应用实例：

### AF_XDP在B站CDN节点QUIC网关的应用和落地

原文地址：https://www.bilibili.com/read/cv20778694

类似的东西：https://knot-resolver.readthedocs.io/en/stable/daemon-bindings-net_xdpsrv.html

基于AF_XDP的QUIC网关，XDP程序对数据帧进行过滤，把发给quic-server的HTTP/3请求所对应的数据帧重定向到quic-server维护的xsk中。 

基于AF_XDP的QUIC网关与原生网关对比：

![截屏2023-02-27 17.52.21](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-02-27%2017.52.21.png)

基于AF_XDP的QUIC网关执行逻辑：

![截屏2023-02-27 20.01.25](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-02-27%2020.01.25.png)



### 2）lstio

介绍：https://istio.io/v1.15/blog/2022/merbridge/

lstio使用了sockopts进行了同机器下的网络通信加速。

原生网络传输路径：

![5](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/5.png)

使用sockopts进行跨机器加速：

![6](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/6.png)

使用sockopts进行同机器加速：

![截屏2023-02-27 18.52.48](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-02-27%2018.52.48.png)

