---
title: MITOSIS test
date: 2023-02-02 20:41:24
tags:
---

服务器无root权限，需修改Kernel，因此用KVM，把device映射到KVM里。

## 服务器物理配置

![截屏2023-02-02 20.44.46](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-02-02%2020.44.46.png)

```
$ ifconfig
enp65s0f0np0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.9.2  netmask 255.255.255.0  broadcast 192.168.9.255
        inet6 fe80::e8a7:6d0b:c437:47a2  prefixlen 64  scopeid 0x20<link>
        ether 64:b3:79:00:01:5a  txqueuelen 1000  (Ethernet)
        RX packets 429758  bytes 103736820 (103.7 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 804262  bytes 138138879 (138.1 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp66s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.9.4  netmask 255.255.255.0  broadcast 192.168.9.255
        inet6 fe80::2dde:7d4f:df48:59ca  prefixlen 64  scopeid 0x20<link>
        ether e4:1d:2d:97:92:34  txqueuelen 1000  (Ethernet)
        RX packets 431116  bytes 104497752 (104.4 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 811031  bytes 138523138 (138.5 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp66s0d1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.9.14  netmask 255.255.255.0  broadcast 192.168.9.255
        inet6 fe80::c238:ad53:dfc8:2d14  prefixlen 64  scopeid 0x20<link>
        ether e4:1d:2d:97:92:35  txqueuelen 1000  (Ethernet)
        RX packets 434024  bytes 104743872 (104.7 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 791748  bytes 136537921 (136.5 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```



## KVM安装ubuntu18.04

教程：https://www.jianshu.com/p/d0e4ed80b8a1

下载ubuntu镜像：http://mirrors.zju.edu.cn/ubuntu-releases/16.04/

### 安装ubuntu：

```sh
virt-install --virt-type kvm  --name=ubuntu16-x86 --memory=2048,maxmemory=2048 --vcpus=2,maxvcpus=2 --os-type=linux --os-variant=ubuntu16.04 --network network=default --location=/home/hanzhong/ubuntu-16.04.7-server-amd64.iso --disk path=~/kvm/ubuntu16-x86.img,size=10 --graphics=none --check path_in_use=off --check all=off --extra-args='console=ttyS0'
```

出现权限不足报错，执行：chmod 755 ~，后重新执行命令安装

### ssh 登录虚拟机：

```sh
$ virsh list #获取目标虚拟机名
$ virsh domifaddr [id | name] #获取虚拟机信息
 Name       MAC address          Protocol     Address
-------------------------------------------------------------------------------
 vnet20     xx:xx:xx:xx:xx:xx    ipv4         192.168.122.116/24
 
$ ssh username@192.168.122.116
```



### 无法进入命令行问题修复

安装完毕后直接使用以下指令无法登录：

```sh
~$ virsh console ubuntu18
Connected to domain 'ubuntu18'
Escape character is ^] (Ctrl + ]) #卡在这里
```

在安装虚拟机时，应选择安装openSSH服务，从而可以使用ssh登录虚拟机。

https://blog.csdn.net/weixin_28730403/article/details/111975038
https://blog.csdn.net/qq_36885515/article/details/112367143



## RDMA网卡设备穿透到KVM

https://blog.csdn.net/zhongbeida_xue/article/details/103602105

1. lspci | grep Ethernet，获取host主机上的网卡列表

    ```sh
    $ lspci | grep Ethernet
    41:00.0 Ethernet controller: Broadcom Inc. and subsidiaries BCM57414 NetXtreme-E 10Gb/25Gb RDMA Ethernet Controller (rev 01)
    41:00.1 Ethernet controller: Broadcom Inc. and subsidiaries BCM57414 NetXtreme-E 10Gb/25Gb RDMA Ethernet Controller (rev 01)
    42:00.0 Ethernet controller: Mellanox Technologies MT27500 Family [ConnectX-3]
    ```

2. vim pci-01.xml ，建立直连设备定义文件

    ```xml
    <hostdev mode='subsystem' type='pci' managed='yes'>
            <source>
                    <address domain='0x0000' bus='0x41' slot='0x00' function='0x0'/>
            </source>
    </hostdev>
    ```

3. virsh attach-device [kvm-name] [config.xml]，进行设备直连
    在虚拟机内执行lspci，可以发现出现了，因此RDMA直连接已生效

    ```sh
    07:00.0 Ethernet controller: Broadcom Inc. and subsidiaries BCM57414 NetXtreme-E 10Gb/25Gb RDMA Ethernet Controller (rev 01)
    ```

    

## 安装MITOSIS core

1.安装rust

```sh
$ curl https://sh.rustup.rs -sSf | sh

$ rustup install nightly-2022-02-04  # 安装mitosis所需的工具链
$ rustup default nightly-2022-02-04-x86_64-unknown-linux-gnu

$ apt-get install clang-9
```









