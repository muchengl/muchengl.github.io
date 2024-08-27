---
title: lc1237  Find Positive Integer Solution for a Given Equation
date: 2023-02-18 14:13:59
tags:
---

## Question

Given a callable function f(x, y) with a hidden formula and a value z, reverse engineer the formula and return all positive integer pairs x and y where f(x,y) == z. You may return the pairs in any order.

While the exact formula is hidden, the function is monotonically increasing, i.e.:

f(x, y) < f(x + 1, y)
f(x, y) < f(x, y + 1)
The function interface is defined like this:

```
interface CustomFunction {
public:
  // Returns some positive integer f(x, y) for two positive integers x and y based on a formula.
  int f(int x, int y);
};
```


We will judge your solution as follows:

The judge has a list of 9 hidden implementations of CustomFunction, along with a way to generate an answer key of all valid pairs for a specific z.
The judge will receive two inputs: a function_id (to determine which implementation to test your code with), and the target z.
The judge will call your findSolution and compare your results with the answer key.
If your results match the answer key, your solution will be Accepted.

```
Example 1:
Input: function_id = 1, z = 5
Output: [[1,4],[2,3],[3,2],[4,1]]
Explanation: The hidden formula for function_id = 1 is f(x, y) = x + y.
The following positive integer values of x and y make f(x, y) equal to 5:
x=1, y=4 -> f(1, 4) = 1 + 4 = 5.
x=2, y=3 -> f(2, 3) = 2 + 3 = 5.
x=3, y=2 -> f(3, 2) = 3 + 2 = 5.
x=4, y=1 -> f(4, 1) = 4 + 1 = 5.

Example 2:
Input: function_id = 2, z = 5
Output: [[1,5],[5,1]]
Explanation: The hidden formula for function_id = 2 is f(x, y) = x * y.
The following positive integer values of x and y make f(x, y) equal to 5:
x=1, y=5 -> f(1, 5) = 1 * 5 = 5.
x=5, y=1 -> f(5, 1) = 5 * 1 = 5.
```



## Solution 01

So, can i call the funtion f like this?
customfunction.f(x,y);

Ok, the z ranges from 1 to 100. And x and y range from 1 to 1000.
So. That's not a huge amount of data.

The easy idea it to try each xy pairs. I need try a million time to get all pairs. 

Considering that  f is a incresing function for both x and y. I think i can use the dichotomy to find pairs. The time complexity of this solution is O(x log(y)); x times log y.

```java
class Solution {
    public List<List<Integer>> findSolution(CustomFunction customfunction, int z) {
        // customfunction.f(x,y);
        // z ranges from 1 to 100
        // 1 <= x, y <= 1000

        // the easy idea is try each x and y to get all pairs.
        // I only need to try a million times to get all answer
        // Let's consider that f is an increasing function. so i can do it by multiplying

        // for each x, Use the dichotomy to find y
        List<List<Integer>> ans=new ArrayList<>();

        for(int x=1;x<1000;x++){ // trying all possible x
            int l=1,r=1000;
            while(l<=r){ // for each x, using dichotomy to find the target y.
                int mid=(l+r)/2;
                if(customfunction.f(x,mid)==z){
                    List<Integer> item=new ArrayList<>();
                    item.add(x);
                    item.add(mid);
                    ans.add(item);
                    break;
                }
                else if(customfunction.f(x,mid)>z) r=mid-1;
                else l=mid+1;
            }

        }
        return ans;
    }
}
```

## solution 02

// x=500 y=100;  f's return value is  z.
// And than, x goes up to 501.
// x=501 y!=100-1000
// Beacuse function f is increasing. So y can't be a bigger number than 100.
// Based on this idea, i can reduce the time complexity to O(x+y)

```java
class Solution {
     public List<List<Integer>> findSolution(CustomFunction customfunction, int z) {
        List<List<Integer>> res = new ArrayList<List<Integer>>();
        int y=1000; // I'm defining y here as the maximum 1000
        for (int x = 1; x <= 1000 && y >= 1; x++) { // trying each x, and keep y bigger than 1
            while (y >= 1 && customfunction.f(x, y) > z) {  // Keep decreasing y to find the pair. In order to avoid pair nonexistence, y keeps decreasing to 1. I use the Judgment condition f(x,y)>z
                y--;
            }
          // At this time, judge whether f(x,y) equals z;
          // if it's true,add this pair the ans list.
            if (y >= 1 && customfunction.f(x, y) == z) {
                List<Integer> pair = new ArrayList<Integer>();
                pair.add(x);
                pair.add(y);
                res.add(pair);
            }
        }
        return res;
    }

}
```






