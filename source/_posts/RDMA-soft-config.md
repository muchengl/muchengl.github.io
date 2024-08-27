---
title: RDMA-soft config
date: 2023-01-17 19:40:10
tags:
---

[modprobe](https://so.csdn.net/so/search?q=modprobe&spm=1001.2101.3001.7020) rdma_rxe

rxe_cfg start

ifconfig

rxe_cfg add ens33



我在运行于VMware中的ubuntu环境搭建了Soft-RoCE软件模拟环境，并成功测试了两台虚拟机器间的通信，但是MITOSIS似乎需要“A machine with Mellanox RDMA-capable IB NIC ”，RoCE和IB两种RDMA技术有一定区别，因此可能导致无法成功。

在MITOSIS的readme中有这么一句“In principle there is no difficult in supporting RoCE, but we have lack such NIC for testing. ”，意思应该是不支持RoCE？但是，我目前没有找到软件模拟IB的方式



IB（InfiniBand）：基于 InfiniBand 架构的 RDMA 技术，由 IBTA（InfiniBand Trade Association）提出。搭建基于 IB 技术的 RDMA 网络需要专用的 IB 网卡和 IB 交换机。

iWARP（Internet Wide Area RDMA Protocal）：基于 TCP/IP 协议的 RDMA 技术，由 IETF 标 准定义。iWARP 支持在标准以太网基础设施上使用 RDMA 技术，但服务器需要使用支持iWARP 的网卡。

RoCE（RDMA over Converged Ethernet）：基于以太网的 RDMA 技术，也是由 IBTA 提出。RoCE支持在标准以太网基础设施上使用RDMA技术，但是需要交换机支持无损以太网传输，需要服务器使用 RoCE 网卡。
