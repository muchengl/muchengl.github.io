---
title: Best Time to Buy and Sell Stock
date: 2023-03-16 10:42:47
tags:
---

## Question 1

You are given an integer array prices where prices[i] is the price of a given stock on the i^th day.

On each day, you may decide to buy and/or sell the stock. You can only hold at most one share of the stock at any time. However, you can buy it then immediately sell it on the same day.

Find and return the maximum profit you can achieve.

```
Input: prices = [7,1,5,3,6,4]
Output: 7
Explanation: Buy on day 2 (price = 1) and sell on day 3 (price = 5), profit = 5-1 = 4.
Then buy on day 4 (price = 3) and sell on day 5 (price = 6), profit = 6-3 = 3.
Total profit is 4 + 3 = 7.
```

### Solution 01

dp(i,0) mains that the max profit i can get when i have no stock in day_i;
dp(i,1) mains that the max profit i can grt when i have a stock in day_i;

So,i can get this equation：
```
dp[i][0]=max{dp[i−1][0],dp[i−1][1]+prices[i]}
dp[i][1]=max{dp[i−1][1],dp[i−1][0]−prices[i]}
```

The time complexity of the solution is o(n).

### Solution 02

For this example: [1,2,3]. It is obvious that i need to buy stock on day_1 and sell it on day_3. However i can do this:
```
day 1: buy
day 2: sell and buy; profit: 1
day 3: sell; profit: 1
Total profit:2
```

The profit of this choice is the same as only buying and selling for one time. So i can get the ans by calculating all increasing subsequence.
```
ans=SUM{ prices[i]-prices[i-1] } (prices[i] > prices[i-1])
```

















