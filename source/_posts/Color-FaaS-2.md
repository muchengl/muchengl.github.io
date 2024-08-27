---
title: Color-FaaS-2
date: 2023-10-27 14:26:45
tags:
---


# Color FaaS Doc Final

Designed By Hanzhong Liu, Xi Shi

All Videos: https://www.youtube.com/playlist?list=PLARUmtazqWjWrdYpJCU77CL7i0meZPqK9

Website & Bill Service: https://github.com/muchengl/tamu-sw-faas

Client: https://github.com/muchengl/Color-FaaS-Core

Function SDK: https://github.com/muchengl/Color-FaaS-SDK

Environment: https://drive.google.com/file/d/1UE5ZxRM66E4el5G-MV9gjSpM_WBBAFvZ/view?usp=drive_link

**Catalog**

[toc]

## **Introduction**

In this project, we have undertaken a significant redesign of our existing system, transitioning to a microservices architecture and incorporating multi-modal client interfaces. This iteration represents an evolution of our system, focusing on enhanced scalability, modularity, and user experience.

Our submission for this iteration includes:

1. **Requirements:** Detailed descriptions and UI sketches of all use cases, incorporating standard format narratives and sequence diagrams. Video recordings demonstrating the system in action for each defined use case, highlighting functionality and user interaction.
2. **Database Design:** We redesigned our DB based on MongoDB. Comprehensive outlines of data entities, relationships, and an entity-relationship diagram, accompanied by sample data.
3. **Architectural Design:** In-depth descriptions of client and server components, communication protocols, data formats, and an overarching system architecture diagram.
4. **Runnable System:** A fully functional system with a personalized and polished UI.
5. **Installation and Usage Manual:** A detailed Handbook covering installation procedures, usage instructions, and information on necessary libraries and frameworks.

## **User cases and UI design**

#### **User case **: Register & Login

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | User                                                         |
| Goal  | Register a new account and login to the platform             |
| Path  | 1.User visits the website landing page<br />2.System returns the html code of the page<br />3.User clicks "New User"<br />4.System display the form for registering a new user<br />5.User fill in the new user information and submit<br />6.System writes the new user information to the database. And jump back to the landing page<br />7.User enters the new user information and clicks Login<br />8.System checks whether the user exists. If yes, go to the home page |

UI of this User case:

VIdeo: https://youtu.be/bLijflOhaDs?si=2M6rCZVapOltcmfz

<img src="/Users/lhz/Desktop/SW/SW-final/Register.png" alt="图片替换文本" width="600" align="bottom" />

<img src="/Users/lhz/Desktop/SW/SW-final/login.png" alt="图片替换文本" width="800" align="bottom" />



#### **User case **: Development/Upload function

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | Developer                                                    |
| Goal  | A User want to deploy a application in cloud environment     |
| Path  | 1. User develop a func in his/her computer by a SDK and upload this function from the webpage<br />2. System saves the function file (in HDFS), and the function file is successfully created <br />3. User views the corresponding information in the function list |

UI of this User case

Video: https://youtu.be/zrBuOFd2jsk?si=BBQKRtWMwfU-F9Aj



<img src="/Users/lhz/Desktop/SW/SW-final/function.png" alt="图片替换文本" width="800" align="bottom" />



#### **User case **: Test Function via web page

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | User                                                         |
| Goal  | Test the function from platform's web page                   |
| Path  | 1. User enter the function test page<br />2. System return the web page to user<br />3. User test this function from web page.<br />4. System calls the function and returns the result and log |

UI of this User case:

Video: https://youtu.be/nybjcanzMko?si=rx2toB0qJ9R3zZx8

<img src="/Users/lhz/Desktop/SW/SW-final/test.png" alt="图片替换文本" width="700" align="bottom" />

<img src="/Users/lhz/Desktop/SW/SW-final/test02.png" alt="图片替换文本" width="700" align="bottom" />



#### **User case **: Test Functions via Public URL

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | User                                                         |
| Goal  | Test the function from platform's web page                   |
| Path  | 1. User enter the function test page<br />2. System return the web page to user<br />3. User copy the "public url" and test it in Browser<br />4. System calls the function and returns the result and log as JSON. Show it in Browser. |

Video: https://youtu.be/2_BJYx0JUBU?si=xXDeK_aF2hs8fj2u



#### **User case **: Test Functions in the Desktop Tool

There are two options to implement this Desktop tool, one is to write an **interactive command line**, and the other is to implement the program with UI. Since my project is a developer-oriented tool, I decided to implement an interactive command line program that more closely resembles a real-world product (like these tools in linux).

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | Developer                                                    |
| Goal  | Test functions in desktop tool                               |
| Path  | 1. User start the Desktop tool and login<br />2. System verifies that user information is correct<br />3. User enter list, history or test command to use different functions<br />4.System process the command and return the result<br />5.User see the output in screen. |

UI of this User case:

Video: https://youtu.be/Uq23_F1yW-k?si=FnUfgjdBmk0kwb4i

<img src="/Users/lhz/Desktop/SW/SW-final/tool01.png" alt="图片替换文本" width="300" align="bottom" />

<img src="/Users/lhz/Desktop/SW/SW-final/tool02.png" alt="图片替换文本" width="500" align="bottom" />

<img src="/Users/lhz/Desktop/SW/SW-final/tool03.png" alt="图片替换文本" width="500" align="bottom" />

#### **User case **: Manage tasks

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | Developer                                                    |
| Goal  | Trace  the running status of a Func                          |
| Path  | 1. User enter Task manage page<br />2. System return the manage page<br />3. User look at the running status, output and time of the function |

Video: https://youtu.be/dJ60XcTPhV0?si=MnkhJ3wmDE60XXmE

<img src="/Users/lhz/Desktop/SW/SW-final/tasks.png" alt="图片替换文本" width="700" align="bottom" />

#### **User case **: Top up user's account

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | Developer                                                    |
| Goal  | Top up                                                       |
| Path  | 1. User enter the account info page<br />2. System return the web page to user<br />3. User click "Recharge" button<br />4. System show the recharge form<br />5.User type info and click the button "Submit"<br />6.System add money to user's account |

UI of this User case:

Video: https://youtu.be/bL5l1LQHHrw?si=pWOBahXJLAHMEsHh

<img src="/Users/lhz/Desktop/SW/SW-final/recarge.png" alt="图片替换文本" width="800" align="bottom" />

#### **User case **: Pay the bill

| Items |                                                              |
| ----- | ------------------------------------------------------------ |
| Actor | Developer                                                    |
| Goal  | Pay the bill                                                 |
| Path  | 1. User enter the account info page<br />2. System return the web page to user<br />3. User click "Update Bill" button<br />4. System queries all unpaid records and generates a bill. Platform will show the bill in web page<br />5. User click "Pay" button<br />6. System deducts the fee and completes the payment |

UI of this User case:

Video: https://youtu.be/XO2TSqXJF0Y?si=Ozx1OBktopRhTn0i

<img src="/Users/lhz/Desktop/SW/SW-final/userdata.png" alt="图片替换文本" width="800" align="bottom" />



## **Architectural design**

#### **High Level Design**

This system comprises three microservices: **Website Service**, **Billing Service**, and **Execution Client**. The Website interact with the Execution Client and Billing Servers using the **Http RestFul API** protocol. The Website Service is responsible for user login, function upload, and function management. The Billing Server handles generating bills and processing user operations for recharge and payment. 

The Execution Client is a multi-instance service, allowing for the deployment of numerous instances to achieve horizontal scaling and enhance system performance. The clients will register its information in ZooKeeper. The Website can then retrieve the list of clients from ZooKeeper and subsequently dispatch function calls to these clients.

Core cluster may contains many servers, so it can process many tasks in the same time. A **Client** program will run in In these servers. When a task is sent to a Client, it will stand up a Executor to process this task. The communitetion bewteen Client and Executor will been held by **gPRC**. Because, Function files are very big, so worker will use LRU to cache some function instances.

As for the architecture of this system：

<img src="/Users/lhz/Desktop/SW/SW-final/arch.png" alt="图片替换文本" width="700" align="bottom" />

#### **Data Storage System**

In Website service and Bill service, we use **MongoDB** to store user's information. Website will provide user with functions include: add/update a Func, pay for the bill, trace Func status, debug function via webpage.

For function file storage, we use **HDFS** as the cloud storage system. User's function files will be uploaded to HDFS and got by Executor.

For cluster management, we use **ZooKeeper** as the information register system. All clients' info will be stored in ZooKeeper.

#### **Data format between services**

**User ↔ Website**

| Request                                              | Protocol | Data Type | Request Data                                     | Response Data                                           | URL               |
| ---------------------------------------------------- | -------- | --------- | ------------------------------------------------ | ------------------------------------------------------- | ----------------- |
| Login                                                | POST     | Form      | Username<br />Password                           | Redirect to the home page                               | /user             |
| Register new user                                    | POST     | Form      | Username<br />Password                           | register success: "ok"<br />fail to register: "fail"    | /add/user         |
| Upload a new function                                | POST     | Form      | FunctionName<br />Description<br />Function File | upload success: "ok"<br />fail to upload: "fail"        | /upload/func      |
| Update function's data                               | POST     | Json      | New FunctionName<br />New Description            | update success: "ok"<br />fail to update: "fail"        | /update/func      |
| Get user's function list                             | GET      | url       | User ID                                          | A json list contains all user's function                | /funcs            |
| Get user's function access history                   | GET      | url       | User ID                                          | A json list contains all user's function access history | /user/tasks       |
| Pay for the bill <br />(Forward to the Bill service) | POST     | Json      | User ID<br />Bill ID                             | pay success: "ok"<br />fail to pay: "fail"              | /pay/bill         |
| Top up<br />(Forward to the Bill service)            | POST     | Json      | User ID<br />Card Number<br />Amount of money    | success: "ok"<br />fail: "fail"                         | /user/add/balance |
| Update Bill<br />(Forward to the Bill service)       | GET      | Json      | User ID                                          | success: "ok"<br />fail: "fail"                         | /update/bills     |
| Get Bill List<br />(Forward to the Bill service)     | GET      | Json      | User ID                                          | A json list contains all user's bill history            | /bills            |
| Invoke a function                                    | POST/GET | Json      | Function ID<br />Task Input                      | A json of output and logs                               | /func/invoke      |

**Website ↔ Bill service**

| Request          | Protocol | Data Type | Request Data                                  | Response Data                                | URL               |
| ---------------- | -------- | --------- | --------------------------------------------- | -------------------------------------------- | ----------------- |
| Pay for the bill | POST     | Json      | User ID<br />Bill ID                          | pay success: "ok"<br />fail to pay: "fail"   | /pay/bill         |
| Top up           | POST     | Json      | User ID<br />Card Number<br />Amount of money | success: "ok"<br />fail: "fail"              | /user/add/balance |
| Update Bill      | GET      | Json      | User ID                                       | success: "ok"<br />fail: "fail"              | /update/bills     |
| Get Bill List    | GET      | Json      | User ID                                       | A json list contains all user's bill history | /bills            |



**Website ↔ Client**

| Request       | Protocol | Data Type | Request Data                                                 | Response Data                                   | URL          |
| ------------- | -------- | --------- | ------------------------------------------------------------ | ----------------------------------------------- | ------------ |
| Submit a task | POST     | Json      | TaskID          <br />FuncName        <br />FuncID          <br />FuncStorageType<br />TaskFuncPath     <br />TaskRunningMode <br />FuncType      <br />TaskCPUCore     <br />TaskMem        <br />TaskDiskSpace   <br />TaskMaxTime     <br />TaskInput | A JSON include:<br />status,<br />msg<br />logs | /func/invoke |



## **Database Design**

This FaaS platform's database(MongoDB) design encompasses multiple tables, intended to manage user information, bills, functions, function execution records, billing units, and account history details. Here's a detailed explanation of these tables:

1. **User Info Table**:
    - `User_ID`: A unique identifier for the user, of type Bigint.
    - `User_Email`: The email address of the user.
    - `User_Name`: The name of the user, which can be up to 20 characters.
    - `User_Password`: The password of the user, capped at 20 characters.
    - `User_Balance`: The balance in the user's account, of type Bigint.
2. **Bill Table**:
    - `Bill_ID`: A unique identifier for the bill.
    - `User_ID`: A unique identifier for the user, serving as an index.
    - `Bill_Date`: The date of the bill.
    - `Bill_Balance`: The amount of the bill.
    - `Bill_tasks`: A JSON document inclueds all unpaid function running records, supported by MongoDB
    - `Status`: The status of the bill, where 0 stands for unpaid and 1 for paid.
3. **Function Table**:
    - `Func_ID`: A unique identifier for the function.
    - `User_ID`: A unique identifier for the user.
    - `Func_Path`: The path to the function's code in object storage services like S3.
    - `Func_Explanation`: An explanation or description of the function.
    - `Func_Resource`: Resources required by the function, in JSON format, e.g., {"CPU":4,"MEM":1024m,"DISK":1024m}.
4. **Func Running Record Table**:
    - `ID`: A unique identifier for the execution record.
    - `Func_ID`: A unique identifier for the function.
    - `Running_Time`: Execution time, e.g., 100ms.
    - `Status`: Status of execution, where 0 stands for failure, 1 for success, and 2 for pending.
    - `Input`: Input data in JSON format.
    - `Running_Date`: The date of execution.
    - `Payment_Status`: Payment status, where 0 stands for unpaid and 1 for paid.
5. **Billing Unit Table**:
    - `Price`: The price, e.g., 0.01$/ms for functions.
6. **Account Info History Table**:
    - `ID`: A unique identifier for the record.
    - `Date`: The date.
    - `Type`: The action type (add fund or payment).
    - `Account_num`: Account number.
    - `Bill_ID`: The ID of the bill.
    - `Money`: The amount.
    - `User_ID`: A unique identifier for the user.

---

####  - User Info Table:

| Item          | Type   | Explanation/Sample Data |
| ------------- | ------ | ----------------------- |
| User_ID       | String |                         |
| User_Email    | String |                         |
| User_Name     | String |                         |
| User_Password | String |                         |
| User_Balance  | Bigint | 1000.0$                 |

#### - Bill Table

| Item         | Type   | Explanation/Sample Data                                      |
| ------------ | ------ | ------------------------------------------------------------ |
| Bill_ID      | String |                                                              |
| User_ID      | String | Index                                                        |
| Bill_Date    | String |                                                              |
| Bill_Balance | Bigint |                                                              |
| Bill_Tasks   | Task   | A JSON document inclueds all unpaid function running records, supported by MongoDB<br />{<br />    {taskID:1,...},<br />    {taskID:2,...}<br />} |
| Status       | int    | 0 unpay, 1 paid                                              |

#### - Function Table

| Item             | Type   | Explanation/Sample Data           |
| ---------------- | ------ | --------------------------------- |
| Func_ID          | String |                                   |
| User_ID          | String |                                   |
| Func_Args        | String | {"num1":int,"num2",int}           |
| Func_Path        | String | path of func's code in HDFS or S3 |
| Func_Explanation | String |                                   |

#### - Func Running Record

| tem            | Type   | Explanation/Sample Data       |
| -------------- | ------ | ----------------------------- |
| Running_ID     | String |                               |
| Func_ID        | String |                               |
| Running_Time   | String | Example: 100ms                |
| Status         | Int    | 0: fail, 1 success, 2 pending |
| Input          | String | A input json                  |
| Running_Date   | String |                               |
| Payment_Status | Int    | 0 unpay, 1 paid               |

#### - Billing Unit

| Item  | Type   | Explanation/Sample Data |
| ----- | ------ | ----------------------- |
| ID    | Bitint |                         |
| Price | float  | 0.0001$ / ms            |

#### - Account Info History

| Item        | Type   | Explanation/Sample Data |
| ----------- | ------ | ----------------------- |
| ID          | String |                         |
| Date        | String |                         |
| Type        | Int    | Payment or ADD          |
| Account_num | String |                         |
| Bill_ID     | Int    |                         |
| Money       | Bigint |                         |
| User_ID     | Bigint |                         |

#### - ER Graph

<img src="/Users/lhz/Desktop/SW/SW-final/ER.png" alt="图片替换文本" width="600" align="bottom" />

## **Handbook**

Website & Bill Service Code: https://github.com/muchengl/tamu-sw-faas

Client Code: https://github.com/muchengl/Color-FaaS-Core

Docker Environment: https://drive.google.com/file/d/1UE5ZxRM66E4el5G-MV9gjSpM_WBBAFvZ/view?usp=drive_link

#### **Environment**

This service includes a Website, Bill service, and Client. Both the Website and Bill service rely on a Java environment (Java 1.8+), while the Client is developed using Golang and requires Golang 1.21. Website and Bill service use Maven to manager all dependent environment. Client can use Golang's mod to get all dependents.

#### **Start Website and Bill Service**

Step 01: Download/Clone all code of project.

Step 02: Open the project with IDEA.

Step 03: Open **pom.xml** in project and init maven for both main-module and bill-module.

Step 04: Run project in IDEA. Website is in main module **com.tamu.faas.FaasApplication**. Bill is in bill module **com.tamu.faas.bill.BillApplication**

Step 05: com.tamu.faas.FaasApplication will use port 8080 and com.tamu.faas.bill.BillApplication will use 8081.

#### **Start Client Cluster** 

Client uses makefile to manager the project, you can use the follows commands to init and build the project:

```
➜ cd [client project's dir in your computer]
➜ make mod
---> make mod <---
go mod tidy
go mod download

➜ make build
---> make build <---
./build.sh
  ---> make clean <---
  ---> init dir <---
  ---> init files <---
  ---> make server <---
  ---> make client <---
  ---> make executor <---

```

And than, use the follows commands to start the client:
```
➜ ./output/startup.sh --client
```

If you see the following output, the client has started successfully (**only one client**, if you want to start many clients to form a cluster, you need to run muit-clients in many Containers/VMs):

<img src="/Users/lhz/Desktop/SW/SW-final/run-core.png" alt="图片替换文本" width="800" align="bottom" />

#### **Start Zookeeper and HDFS**

Start by docker-compose in project dir (May not work perfectly, may require manual installation) :

```
➜ cd [docker-compose's dir in your computer]
➜ docker-compose up -d
```

#### **Test the project**

Test the project by URL in your browser: http://localhost:8080/login

HDFS URL in browser: http://localhost:9870/

Test desktop tool:

```
➜ pip install prettytable requests
➜ python3 client.py
```

