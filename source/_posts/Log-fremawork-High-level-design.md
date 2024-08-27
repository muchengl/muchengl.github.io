---
title: Log framework High level design
date: 2022-12-06 20:57:07
tags: Go
---

为了提升go语言的熟练程度，使用go语言编写一个easy log framework. This is the high level design for this framework.

## Requirement Analysis

### 1. Log levels

​	ERROR > WARN > INFO > DEBUG > TRACE

### 2. Basic requirement

用户需要在每个需要使用日志的类中声明一个EasyLog对象。利用工厂模式声明，工厂方法可选一下几种参数：

- 
