---
title: Color-FaaS
date: 2023-09-25 12:49:46
tags:
---

# Color FaaS Design Doc

Designed By Hanzhong Liu, Xi Shi

Video: https://www.youtube.com/watch?v=QDuIaaMpTBo

## High Level Design

### Requirements

I plan to design a FaaS platform called Color FaaS. Color FaaS will has the ability to process many kinds of task like AWS Lambda. The platform will include user registration, function creation and management, billing and payment.

**User case 1**: Development

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | Developer                                                    |
| Goal  | A User want to deploy a application in cloud environment     |
| Path  | 1. User must develop a func in his/her computer by a SDK and upload this function from the webpage<br />2. System saves the function file, and the function file is successfully created <br />3. User test this function from web browser.<br />4. System calls the function and returns the result |

**User case 2**: Pay the bill

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | Developer                                                    |
| Goal  | Pay the bill                                                 |
| Path  | 1. User login into the platftom<br />2. System verifies that user information is correct<br />3. User enter the account info page<br />4. System return the web page to user<br />5. User click "bill" button<br />6. System queries all unpaid records and generates a bill. Platform will show the bill in web page<br />7. User click "Pay" button<br />8. System redirects to the payment page<br />9. User enter all information in the payment form and submit<br />10. System deducts the fee and completes the payment |

**User case 3**: Manage function

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | Developer                                                    |
| Goal  | Trace  the running status of a Func                          |
| Path  | 1. User login into the platform<br />2. System verifies that user information is correct<br />3. User enter Task manage page<br />4. System return the manage page<br />5. User use search to find the target Func<br />6. System search from the database and return it to user<br />7. User look at the running status of the function |

### Architectural design

The system is divided into three layers: the website, the gateway, and the cluster. The website is primarily responsible for user interaction and needs to connect to the database to store user information. The gateway layer is a simplified implementation that can be replaced with gateways like AWS ELB (Elastic Load Balancer). The cluster is the core of the entire Color FaaS platform. Here, I have designed a decentralized resource scheduler and use Docker for handling user tasks.

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/2023-09-2716.58.19.png" alt="图片替换文本" width="500" align="bottom" />

In Website layer, we use Java Serverlet to develop a Web application.We also use Mysql to store user's information. Website will provide user with functions include: add/delete a Func, pay for the bill, trace Func status.

For GateWay, all request will be send to gateway, and gateway will write infomation about the task into DB. In the end, gateway will sent task to Core cluster.

Core cluster may contains many servers, so it can process many tasks in the same time. A **worker** program will run in In these servers. When a task is sent to a worker, it will stand up a Docker container and run this task in that container. Because, image of a container is very big, so worker will use LRU to cache some containers.



## Website Detail Design

### UI Design / Prototype

#### - Login page

![login](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/login.png)

#### - Register page

![register](/Users/lhz/Desktop/SW/register.png)

#### - Func manage page

From this page, user can Add, delete, or modify a function.

![register](/Users/lhz/Desktop/SW/func.png)

#### - Task manage page

This page shows all the user's functions running.

![截屏2023-10-01 11.43.41](/Users/lhz/Library/Application Support/typora-user-images/截屏2023-10-01 11.43.41.png)

#### - Account info page

This page shows the bill and account balance, and the user can pay the bill or top up the money.

![register](/Users/lhz/Desktop/SW/account.png)

### Database Design

####  - User Info Table:

| Item          | Type        | Explanation |
| ------------- | ----------- | ----------- |
| User_ID       | Bigint      |             |
| User_Email    | varchar(50) |             |
| User_Name     | Varchar(20) |             |
| User_Password | varchar(20) |             |
| User_Balance  | Bigint      |             |

#### - Bill Table

| Item         | Type     | Explanation                                                  |
| ------------ | -------- | ------------------------------------------------------------ |
| Bill_ID      | Bigint   |                                                              |
| User_ID      | Bigint   | Index                                                        |
| Bill_Date    | Datetime |                                                              |
| Bill_Balance | Bigint   |                                                              |
| Bill_Detail  | Text     | A JSON inclueds all unpaid function running records' ID {1,2,3} |
| Status       | int      | 0 unsay, 1 paid                                              |

#### - Function Table

| Item             | Type         | Explanation                        |
| ---------------- | ------------ | ---------------------------------- |
| Func_ID          | Bigint       |                                    |
| User_ID          | Bigint       |                                    |
| Func_Args        | JSON         | {"num1":int,"num2",int}            |
| Func_Path        | varchar(200) | path of func's code in OSS like S3 |
| Func_Explanation | varchar(500) |                                    |
| Func_Output      | Int          | 0=sync / 1=async                   |
| Func_Resource    | JSON         | {"CPU":4,"MEM":1024m,"DISK":1024m} |

#### - Func Running Record

| tem            | Type     | Explanation                   |
| -------------- | -------- | ----------------------------- |
| Running_ID     | Bigint   |                               |
| Func_ID        | Bigint   |                               |
| Running_Time   | Bigint   | Example: 100ms                |
| Status         | Int      | 0: fail, 1 success, 2 pending |
| Input          | Text     | A input json                  |
| Running_Date   | Datetime |                               |
| Payment_Status | Int      | 0 unsay, 1 paid               |

#### - Billing Unit

| Item          | Type   | Explanation       |
| ------------- | ------ | ----------------- |
| ID            | Bitint |                   |
| Resource_Type | Int    | CPU / MEM /  DISK |
| Price         | float  | Example: 0.01$/ms |

#### - Account Info History

| Item        | Type        | Explanation       |
| ----------- | ----------- | ----------------- |
| ID          | Bitint      |                   |
| Date        | Datetime    | CPU / MEM /  DISK |
| Type        | Int         |                   |
| Account_num | varchar(20) |                   |
| Bill_ID     | Int         |                   |
| Money       | Bigint      |                   |
| User_ID     | Bigint      |                   |

#### - ER

![](/Users/lhz/Desktop/SW/ER.jpg)

#### - SQL Code

```sql
create table Account_Info_History
(
    ID          bigint auto_increment
        primary key,
    Date        varchar(30) null,
    Type        int         null comment '1:money in, pay for a bill',
    Account_Num varchar(20) null comment 'for type 1',
    Bill_ID     bigint      null comment 'for type 2',
    Money       bigint      null comment 'for type 1, it is a positive num.',
    User_ID     bigint      null
);

create table Bill
(
    Bill_ID      bigint auto_increment
        primary key,
    User_ID      bigint   null,
    Bill_Date    datetime null,
    Bill_Balance double   null,
    Bill_Detail  text     null,
    Status       int      null comment '"0 unpay, 1paid"'
);

create index User_ID
    on Bill (User_ID);

create table Billing_Units
(
    ID            bigint auto_increment
        primary key,
    Resource_Type varchar(10) null,
    Price         double      null comment 'Example: 0.01$/ms'
);

create table Func_Running_Record
(
    Running_ID     bigint auto_increment
        primary key,
    Func_ID        bigint   null,
    Running_Time   int      null comment '100ms',
    Status         int      null comment '0: fail, 1 success, 2 pending',
    Input          text     null,
    Running_Date   datetime null,
    Payment_Status int      null comment '"0 unpay, 1 paid"'
);

create table Functions
(
    Func_ID            bigint auto_increment
        primary key,
    User_ID            bigint       null,
    Func_Args          text         null,
    Func_Path          varchar(300) null,
    Func_Explanation   varchar(500) null,
    Func_Output        int          null comment '0=sync / 1=async',
    Func_Resource_CPU  int          null,
    Func_Resource_Mem  int          null,
    Func_Resource_Disk int          null,
    Func_Name          varchar(50)  null
);

create index User_ID
    on Functions (User_ID);

create table User_Info
(
    User_ID       bigint auto_increment
        primary key,
    User_Email    varchar(50) null,
    User_Password varchar(50) null,
    User_Balance  bigint      null
);


```



## Core Cluster Detail Design

**In development! **

In core cluster, there are many servers. All servers will be managed by zookeeper. All nodes can perform the scheduling function. Zookeeper will elect a leader for scheduling.

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-09-30%2023.10.24.png" alt="图片替换文本" width="500" align="bottom" />



The worker nodes will regularly report resource usage to the master node, and the master node will use the progress of DRF algorithm based on resource usage information

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-09-30%2023.11.11.png" alt="图片替换文本" width="700" align="bottom" />



The following figure shows the module division of the whole scheduling system(For master):



<img src="/Users/lhz/Desktop/SW/f.png" alt="图片替换文本" width="500" align="bottom" />

