---
title: 823. Binary Trees With Factors
date: 2023-08-28 14:09:46
tags:
---

## Question

Given an array of unique integers, `arr`, where each integer `arr[i]` is strictly greater than `1`.

We make a binary tree using these integers, and each number may be used for any number of times. Each non-leaf node's value should be equal to the product of the values of its children.

Return *the number of binary trees we can make*. The answer may be too large so return the answer **modulo** `1^9 + 7`.



**Example 1:**

```
Input: arr = [2,4]
Output: 3
Explanation: We can make these trees: [2], [4], [4, 2, 2]
```

**Example 2:**

```
Input: arr = [2,4,5,10]
Output: 7
Explanation: We can make these trees: [2], [4], [5], [10], [4, 2, 2], [10, 2, 5], [10, 5, 2].
```

## Solution

In this question, it's easy to find that for each number n, it is a child question which has no connect with what the parent of this number is. So, we can use the memorized dfs to solve this problem.

In addition, for number n, i assume that this number can be devided into arr[i]*arr[j]; So dfs(n) = dfs(arr[i]) * dis(arr[j]). This is because for each legal child tree with arr[i] as the root, it can be combine with each legal child tree with arr[j] as the root. So, i can sort the arr, and find out all arr[i] and arr[j] pairs. 

There is a important point, when multiply two ints together and storage it into a long. These to Int number may over the limit. So, to get the right ans, i need to transfer in to long firstly. And that make the multiply.

My solution is as below: 

```java
class Solution {
    int mod = (int) 1e9 + 7;
    Map<Integer,Integer> con=new HashMap<>();

    public int numFactoredBinaryTrees(int[] arr) {
      
      Arrays.sort(arr);

      Set<Integer> arrSet = new HashSet<>();
      for(int i=0;i<arr.length;i++){
        arrSet.add(arr[i]);
      }

      int ans=0;
      for(int i=0;i<arr.length;i++){
        ans+=dfs(arr[i],arr,arrSet);
        ans %= mod;
      }
      return ans;

    }
    public int dfs(int nowNum,int[] arr,Set<Integer> arrSet){
      if(con.containsKey(nowNum)) return con.get(nowNum);
      
      long res=1;
      for(int i=0;i<arr.length;i++){
        if(arr[i]>=nowNum) break;

        int r=nowNum/arr[i];
        if(nowNum==arr[i]*r && arrSet.contains(r)){
          //System.out.println(nowNum+"->"+r+" "+arr[i]); 
          res+=((1l)*dfs(r,arr,arrSet)) * ((1l)*dfs(arr[i],arr,arrSet));
          res %= mod;
        }
      }

      res %= mod;
      con.put(nowNum,(int)res);
      //if(res != (int)res) System.out.println("error");
      return (int)res;
    }
}

// s1: sort
/*
4 2 2
  4
 /  \
2    2



*/
```



