---
title: Distributed-sys-mp1-design
date: 2023-09-24 20:46:26
tags:
---

# MP1 Design Doc

## Introduction

In modern social networking applications, user login, mutual following, viewing lists, and timelines are among the common functionalities. In this project, I have created a simple social networking application called SNS from skeleton, showcasing the fundamental principles and operations of these features.

## Detailed Design

### Login

For a successful login, the client needs to connect to the server and obtain a stub. The client sends its username to the server, and if the server responds with "OK," the login is successful.

```
➜  mp1 ./tsc -u test

========= TINY SNS CLIENT =========
 Command Lists and Format:
 FOLLOW <username>
 UNFOLLOW <username>
 LIST
 TIMELINE
=====================================
Cmd> 
```



On the server-side, it starts by traversing the client database (client_db) to determine if the client is already logged in. If not, it creates a new Client object and initializes it. Subsequently, it creates a timeline file locally named "username.txt." If it detects that the user is already logged in, it returns a "deny" status.

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-09-25%2023.26.07.png" alt="图片替换文本" width="300" align="bottom" />

The timeline file has the following format:

```
[username2] [msg2] [timestamp2]
[username1] [msg1] [timestamp1]
...

Where the most recent information is stored at the top.
```

### Follow

On the client-side, a request is constructed with the username set as the user's name and the arg set as username2. The request is then sent to the server. If an "OK" response is received, it returns IStatus::SUCCESS; otherwise, it returns an error code.

```
========= TINY SNS CLIENT =========
 Command Lists and Format:
 FOLLOW <username>
 UNFOLLOW <username>
 LIST
 TIMELINE
=====================================
Cmd> FOLLOW default
Command completed successfully
Cmd> 
```



On the server-side, it begins by searching for username and username2 in the client database (client_db). If username2 cannot be found, it returns "NO_TARGET" in msg. If username is equal to username2, it returns "Can't follow self" since users cannot follow themselves. If the user is already following username2, it returns "RE-FOLLOW." Subsequently, the server establishes a direct relationship between username and username2 and returns "OK."

<img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2023-09-25%2023.20.06.png" alt="图片替换文本" width="400" align="bottom" />

### Unfollow

On the client-side, a request is constructed with the username set as the user's name and the arg set as username2. The request is then sent to the server. If an "OK" response is received, it returns IStatus::SUCCESS; otherwise, it returns an error code.

```
========= TINY SNS CLIENT =========
 Command Lists and Format:
 FOLLOW <username>
 UNFOLLOW <username>
 LIST
 TIMELINE
=====================================
Cmd> FOLLOW default
Command completed successfully
Cmd> UNFOLLOW default
Command completed successfully
Cmd> 
```



On the server-side, it begins by searching for username and username2 in the client database (client_db). If username2 cannot be found, it returns "NO_TARGET." Otherwise, it removes the relationship between the two users and returns "OK."

### List

On the server-side, it constructs a ListReply. It iterates through the client database, adding all usernames to the ListReply. Then, it locates username and iterates through its followers, adding them all to the ListReply too.

```
========= TINY SNS CLIENT =========
 Command Lists and Format:
 FOLLOW <username>
 UNFOLLOW <username>
 LIST
 TIMELINE
=====================================
Cmd> LIST
Command completed successfully
All users: lhz, default, 
Followers: 
Cmd> LIST
Command completed successfully
All users: lhz, default, 
Followers: lhz, 
Cmd> 
```



### Timeline

On the client-side, it begins by establishing a stream connection. It constructs a message request with the message set as "join_timeline." Afterward, two threads are started: read and write. The read thread continuously reads messages from the stream, while the write thread constantly reads user input and sends it to the server by stream.

```
User:
========= TINY SNS CLIENT =========
 Command Lists and Format:
 FOLLOW <username>
 UNFOLLOW <username>
 LIST
 TIMELINE
=====================================
Cmd> TIMELINE
Command completed successfully
Now you are in the timeline
p1
p2
p3
```

```
Follower:
========= TINY SNS CLIENT =========
 Command Lists and Format:
 FOLLOW <username>
 UNFOLLOW <username>
 LIST
 TIMELINE
=====================================
Cmd> FOLLOW default
Command completed successfully
Cmd> TIMELINE
Command completed successfully
Now you are in the timeline
default (Sun Sep 24 22:31:15 2023) >> p1
default (Sun Sep 24 22:31:16 2023) >> p2
default (Sun Sep 24 22:31:17 2023) >> p3
```

On the server-side, upon receiving the "join_timeline" request, it saves the stream in the client database. It then reads up to 20 lines from the current user's timeline file, parses them into messages, and sends them to the client. When the server receives a message, it iterates through all followers, individually checking if their stream is not null. If it's not null, the server sends the message directly to the client through the stream. The message is then saved at the top of the follower's timeline file.

<img src="/Users/lhz/Desktop/截屏2023-09-25 23.33.01.png" alt="图片替换文本" width="350" align="bottom" />





