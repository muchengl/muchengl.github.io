---
title: 853. Car Fleet
date: 2023-09-01 13:46:11
tags:
---

## Question

There are `n` cars going to the same destination along a one-lane road. The destination is `target` miles away.

You are given two integer array `position` and `speed`, both of length `n`, where `position[i]` is the position of the `ith` car and `speed[i]` is the speed of the `ith` car (in miles per hour).

A car can never pass another car ahead of it, but it can catch up to it and drive bumper to bumper **at the same speed**. The faster car will **slow down** to match the slower car's speed. The distance between these two cars is ignored (i.e., they are assumed to have the same position).

A **car fleet** is some non-empty set of cars driving at the same position and same speed. Note that a single car is also a car fleet.

If a car catches up to a car fleet right at the destination point, it will still be considered as one car fleet.

Return *the **number of car fleets** that will arrive at the destination*.

**Example 1:**

```
Input: target = 12, position = [10,8,0,5,3], speed = [2,4,1,1,3]
Output: 3
Explanation:
The cars starting at 10 (speed 2) and 8 (speed 4) become a fleet, meeting each other at 12.
The car starting at 0 does not catch up to any other car, so it is a fleet by itself.
The cars starting at 5 (speed 1) and 3 (speed 3) become a fleet, meeting each other at 6. The fleet moves at speed 1 until it reaches target.
Note that no other cars meet these fleets before the destination, so the answer is 3.
```



## Solution

Firstly, this problem give me some positions. These position a unsorted. So it is obvious that the first step should be sort these cars by position.

```java
				int[][] cars=new int[position.length][2];
        for(int i=0;i<position.length;i++){
            cars[i][0]=position[i];
            cars[i][1]=speed[i];
        }

        Arrays.sort(cars,(a,b)->(a[0]-b[0]));
```

And then, after the sort, we can fint that when there are two cars(first are is in i, second is in j, i<j). There are two situations:

1. First car need n time unit to array target and second car need m time unit to array target. If n<=m, these two cars will always become a car fleet.
2. First car need n time unit to array target and second car need m time unit to array target. If n>m, these two cars will not become a car fleet.

So, we can use a stack to record car fleets. If a new car's array time is small than peek in stack, we merge this car into peek fleet. On the contrary, the car can make up a new fleet. I just push this car into stack;

```java
class Solution {
    public int carFleet(int target, int[] position, int[] speed) {
       
        int[][] cars=new int[position.length][2];
        for(int i=0;i<position.length;i++){
            cars[i][0]=position[i];
            cars[i][1]=speed[i];
        }

        Arrays.sort(cars,(a,b)->(a[0]-b[0]));

        List<int[]> stack=new LinkedList<>();

        for(int i=0;i<cars.length;i++){
            if(stack.size()==0){
                stack.add(cars[i]);
                continue;
            }
            double time=((target-cars[i][0])*1.0) / (cars[i][1]*1.0);
            // stack.get(stack.size()-1)[1]
            while(stack.size()!=0 && ((target-stack.get(stack.size()-1)[0])*1.0) / (stack.get(stack.size()-1)[1]*1.0) <= time){
                stack.remove(stack.size()-1);
            }
            stack.add(cars[i]);
        }

        return stack.size();
    }
}
```

















