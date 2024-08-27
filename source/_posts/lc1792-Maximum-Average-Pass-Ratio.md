---
title: lc1792 Maximum Average Pass Ratio
date: 2023-02-19 14:45:42
tags:
---

## Question

There is a school that has classes of students and each class will be having a final exam. You are given a 2D integer array classes, where classes[i] = [passi, totali]. You know beforehand that in the ith class, there are totali total students, but only passi number of students will pass the exam.

You are also given an integer extraStudents. There are another extraStudents brilliant students that are guaranteed to pass the exam of any class they are assigned to. You want to assign each of the extraStudents students to a class in a way that maximizes the average pass ratio across all the classes.

The pass ratio of a class is equal to the number of students of the class that will pass the exam divided by the total number of students of the class. The average pass ratio is the sum of pass ratios of all the classes divided by the number of the classes.

Return the maximum possible average pass ratio after assigning the extraStudents students. Answers within 10-5 of the actual answer will be accepted.

```
Example 1:
Input: classes = [[1,2],[3,5],[2,2]], extraStudents = 2
Output: 0.78333
Explanation: You can assign the two extra students to the first class. The average pass ratio will be equal to (3/4 + 3/5 + 2/2) / 3 = 0.78333.

Example 2:
Input: classes = [[2,4],[3,9],[4,5],[2,10]], extraStudents = 4
Output: 0.53485

```



## Solution



```
class Solution {
    public double maxAverageRatio(int[][] classes, int extraStudents) {

        // So this is a two-dimensional array
        PriorityQueue<int[]> queue = new PriorityQueue<int[]>(
         (a, b) -> {
            long val1 = (long) (b[1] + 1) * b[1] * (a[1] - a[0]);
            long val2 = (long) (a[1] + 1) * a[1] * (b[1] - b[0]);
            if (val1 == val2) {
                return 0;
            }
            return val1 < val2 ? 1 : -1;
        }
        );

        for(int i=0;i<classes.length;i++){
            queue.add(classes[i]);
        }

        // while(!queue.isEmpty()){
        //     int[] item=queue.poll();
        //     System.out.println(item[0]+" "+item[1]);
        // }

        for(int i=0;i<extraStudents;i++){
            int[] item=queue.poll();
            item[0]++;
            item[1]++;
            queue.add(item);
        }

        double ans=0;
        while(!queue.isEmpty()){
            int[] item=queue.poll();
            ans+=((double)item[0])/((double)item[1]);
        }

        
        return ans/classes.length;

    }
}

// dp[i][j] The max pass ratio for first i class,first j extra student
// dp[i][j]=MAX{ dp[i-1][j-k]*(i-1)+(classes[i][0]+k)/(classes[i][1]+k)}
// Time complexity：O(l * extraStudents^2)
// This algorithm seems too complicated


// So Use a greedy idea.
// I define a priority queue
// And the queue storage the classes and sort them by pass ratio from small to big.

// I keep pulling classes from the head of the queue
// Adding a extra student to this class and push this class back to queue.

// When all extra student were used, the average pass retio has been maximized
// the time complexity is o(log(l)*extraStudentNum)



```



