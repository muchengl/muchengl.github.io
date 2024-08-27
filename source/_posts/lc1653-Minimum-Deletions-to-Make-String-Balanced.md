---
title: lc1653. Minimum Deletions to Make String Balanced
date: 2023-03-06 10:24:13
tags:
---

## Question

You are given a string s consisting only of characters 'a' and 'b'.

You can delete any number of characters in s to make s balanced. s is balanced if there is no pair of indices (i,j) such that i < j and s[i] = 'b' and s[j]= 'a'.

Return the minimum number of deletions needed to make s balanced.

```
Example 1:
Input: s = "aababbab"
Output: 2
Explanation: You can either:
Delete the characters at 0-indexed positions 2 and 6 ("aababbab" -> "aaabbb"), or
Delete the characters at 0-indexed positions 3 and 6 ("aababbab" -> "aabbbb").

Example 2:
Input: s = "bbaaaaabb"
Output: 2
Explanation: The only solution is to delete the first two characters.

```

- `1 <= s.length <= 105`
- `s[i]` is `'a'` or `'b'`.

## My solution

Very unfortunate, my solution is not the best solution.

```java
class Solution {
    public int minimumDeletions(String s) {
        // The first way is to delete b before a
        // The second option is to delete a after b
        // In some conditions, I need to combine the two ways.
        
        // aababbab
        // aaabbb
        // aabbbb

        // dp[i][1] end with a
        // dp[i][2] end with b

        // dp[i][1] = dp[i-1][1]                    (s[i]==a)
        // dp[i][1] = dp[i-1][1]+1                  (s[i]==b)
        // dp[i][2] = Min(dp[i-1][1],dp[i-1][2]+1)  (s[i]==a) 
        // dp[i][2] = Min(dp[i-1][1],dp[i-1][2])    (s[i]==b)

        // ans = Min(dp[i][1],dp[i][2])
      
        int dp[][]=new int[s.length()+1][3];
        for(int i=0;i<s.length();i++){
            char c=s.charAt(i);
            i++; //This avoids judging boundaries
            if(c=='a'){
                dp[i][1] = dp[i-1][1];
                dp[i][2] = Math.min(dp[i-1][1],dp[i-1][2]+1);
            }
            else{
                dp[i][1] = dp[i-1][1]+1;
                dp[i][2] = Math.min(dp[i-1][1],dp[i-1][2]);
            }

            i--;

        }
        return Math.min(dp[s.length()][1],dp[s.length()][2]);


    }
}
```



## Best solution

```java
class Solution {
    public int minimumDeletions(String s) {
        
        // Delete all b to the left of this point
        // Delete all a to the right of this point

        // I just need to know the number of a to the left of any point.
        // And i need to know the number of a and b in the whole string.
       

        int num_a=0,num_b=0;
        for(int i=0;i<s.length();i++){
            char c=s.charAt(i);
            if(c=='a') num_a++;
            
        }
        int con_a=0;
        int ans=num_a;
        for(int i=0;i<s.length();i++){
             char c=s.charAt(i);
            if(c=='a') num_a--;
            else num_b++;

            ans=Math.min(ans,num_a+num_b);

        }

        return ans;


    }
}
```



