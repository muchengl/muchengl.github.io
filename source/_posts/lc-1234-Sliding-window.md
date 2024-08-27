---
title: lc 1234 - Sliding window
date: 2023-02-13 15:05:27
tags:
---

## Puzzle

You are given a string s of length n containing only four kinds of characters: 'Q', 'W', 'E', and 'R'.

A string is said to be balanced if each of its characters appears n / 4 times where n is the length of the string.

Return the minimum length of the substring that can be replaced with any other string of the same length to make s balanced. If s is already balanced, return 0.

```
Input: s = "QWER"
Output: 0
Explanation: s is already balanced.

Input: s = "QQWE"
Output: 1
Explanation: We need to replace a 'Q' to 'R', so that "RQWE" (or "QRWE") is balanced.

Input: s = "QQQW"
Output: 2
Explanation: We can replace the first "QQ" to "ER". 
```

## My Answer

### Idea1 (fault)

// For each string, I can replace the entire string to solve the problem
// But that doesn't satisfy the problem that i need to find the minimum Length of the subString
// Assume the following：
// xxxx 【sub string】 xxxx
// For the strings on both sides, the balance has been reached

// so i only need to  rplace the 【sub string】, the section.
// it no need for me to know how to replace it ,or which kinds of characters in the 【sub string】
// So now the question becomes, how do you find a【sub string】which can keep two sides strings balanced. 

```
// dp[i][j] = true / false
// dp[0][n-1] =true
// dp[i][j]= true (  dp[i-2][j+2]==true && s[i-1]+s[i-2]+s[j+1]+s[j+2]==Q+W+E+R )
// dp[i][j]= false 
```

However, the time complexity of this answer is o(n^2). And this state transition equation doesn't work.

## Idea2

Actually, it is no need to keep both side of sub string to be balanced. To keep the string balanced, the numer of each character in the string should equal to string's length/4. So , what i need to do is keep the num of each character in both side of the sub string less than string's length divided by 4.  As long as it's less than a quarter, I can complete the missing part in the sub string.

```java
   public boolean check(int[] con,int qtr){
        if(con['Q'-'A']<=qtr && con['W'-'A']<=qtr && con['E'-'A']<=qtr && con['R'-'A']<=qtr) return true;
        return false;
    }
```

To find the minimum sub string, i can maintain a array to storage each character's number. Usering to points to r,l to form a sliding window. The point r keep growing until the check return true. And than, point l begins to grow until the check return false. When l is growing, constantly update the size of the sliding window. The answer of this question is minimun window's size.

````java
 public int balancedString(String s) {

        int[] con=new int[26]; // QWER
        for(int i=0;i<s.length();i++){
            con[s.charAt(i)-'A']++;
        }
        int ans=s.length();
        int qtr=s.length()/4;

        int r=0,l=0;

        //if(check(con,qtr)) return 0;

        for(r=0;r<s.length();r++){
            con[s.charAt(r)-'A']--;

            while(l<s.length() && check(con,qtr)){
            
                ans=Math.min(ans,r-l+1);
                //System.out.println(r+" "+l);
                l++;
                con[s.charAt(l-1)-'A']++;
            }
            
        }
        
        return ans;
}
````





