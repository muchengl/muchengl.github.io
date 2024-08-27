---
title: MapRedece lab
date: 2023-08-27 09:39:55
tags:
---

## Why Map Reduce

When we need to figure out how many word in a great amount of web pages, the easist way is load file one by one and count up the words in them. The way may very slow and we can't get the answer  in a resonable time. So, one better solution is load all files into memory, and then count the word in them in one time. But this approach may need a very big memory. Normal computer will not have such a high config in most of time. To balance the conflict of "one by one" and "load in on time", MapReduce algorithm was posted by Jeff Dean when he worked in google.

The whole process of MapReduce is in the graph below:

1. Split files into some small part
2. Send these splits to workers, and workers will make the map process
3. Map: count up the number of each word in split
   1. like this: Word1 number1 Word2 number2 Word1 number3

![](/Users/lhz/Library/Application Support/typora-user-images/截屏2023-08-27 09.42.55.png)
