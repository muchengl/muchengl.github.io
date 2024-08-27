---
title: lc1139 Largest 1-Bordered Square
date: 2023-02-17 17:35:42
tags:
---

Given a 2D grid of 0s and 1s, return the number of elements in the largest square subgrid that has all 1s on its border, or 0 if such a subgrid doesn't exist in the grid.

 ```
 Example 1:
 Input: grid = [[1,1,1],[1,0,1],[1,1,1]]
 Output: 9
 
 Example 2:
 Input: grid = [[1,1,0,0]]
 Output: 1
 ```



The easy idea is search from each point, and try each possible length of edge. But this idea need count the number of ones over and over again. So i think i can ：

1. storage the number of consecutive ones in the direction of vertical and horizontal for each points.

2. Than i need to search from each point. At this time, I can judge whether a square can be formed by storaged date.

    ```
    i use a array con[i][j][0] and con[i][j][1].
    
    con[i][j][0] 1 -
    con[i][j][1] 1 |
    
    *---*
    |   |
    |   |
    |   |
    *---P
    try 3
    if con[i-2][j][0]>=3 && con[i][j-2][1]>=3 
    	the square can be formed；
    	Update the area of the largest rectangle；
    ```

    



```
class Solution {
    public int largest1BorderedSquare(int[][] grid) {

        // con[i][j][0] number of 1 in the direction of y
        // The number of consecutive ones in the vertical direction
        // con[i][j][1] number of 1 in the direction of x
        // The number of consecutive ones in the horizontal direction

        int m=grid.length,n=grid[0].length;

        int[][][] con=new int[m][n][2];

        for(int i=0;i<m;i++){
            for(int j=0;j<n;j++){
                if(grid[i][j]==1){
                    if(i>0) con[i][j][1]=con[i-1][j][1]+1;
                    else con[i][j][1]=1;
                    if(j>0) con[i][j][0]=con[i][j-1][0]+1;
                    else con[i][j][0]=1;
                }
            }
        }

        //System.out.println(con[2][2][0]+" "+con[2][2][1]);
        //System.out.println(con[2][0][0]+" "+con[2][0][1]);
        //System.out.println(con[0][2][0]+" "+con[0][2][1]);

        int ans=0;
        for(int i=0;i<m;i++){
            for(int j=0;j<n;j++){
                // I need to go through the length of the edge from the largest to the smallest
                for(int k=Math.min(con[i][j][0],con[i][j][1]);k>0;k--){
                    
                    // *---k
                    // ｜   |
                    // ｜.  |
                    // ｜.  |
                    // k---p
                    if(con[i-k+1][j][0]>=k && con[i][j-k+1][1]>=k){
                        ans=Math.max(ans,k*k);
                        //System.out.println(i+" "+j+" "+k+" "+);
                        break;
                    }
                }
            }
        }

        return ans;



    }
}

```

