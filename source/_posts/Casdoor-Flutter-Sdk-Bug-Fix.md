---
title: Casdoor Flutter Sdk Bug Fix
date: 2022-11-27 21:18:58
tags: Casdoor
---

## 1.安卓，不能跳转回app问题

安装了一个第三方浏览器，就解决问题了，因此sdk的代码本身应该是是正确的（原始浏览器不能跳转的问题暂不清楚原因，还需研究）  

## 2.Flutter web端存在跨域问题

![5DC1E696AFA5781CE5B8C30C59AEFA8F](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/5DC1E696AFA5781CE5B8C30C59AEFA8F.jpg)

![D306359D80BF70C7E5350EE14321E2DF](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/D306359D80BF70C7E5350EE14321E2DF.jpg)

这个问题网上有很多讨论，单从Flutter的角度来说，好像没有完美解决方案。 

> 这一块我不清楚我理解的对不对：
>
> 我研究了一下Casdoor js sdk的逻辑，使用了js sdk的项目里，我没有找到浏览器直接向Casdoor发送请求获取token的例子。 
>
> 1.casdoor-python-vue-sdk-example这个repo，token是通过后端的py程序获取的，应该不是浏览器直接向casdoor发请求。
>
> 2.casdoor-raw-js-example这个repo，是用node.js启动项目（并且启动了一个代理server，由这个server向Casdoor发送请求），也不是原生js在浏览器直接请求token。

但是Flutter-web就等于是编译出来一个静态web项目，原生运行在浏览器，浏览器中的原生js直接去请求其他域名下的casdoor必然遇到跨域问题

为解决这个问题，我目前想到了四种方法：

- 为Casdoor的token获取接口添加CORS跨域资源分享支持
- 用Flutter调用原生js代码，通过一些不太优美的原生js方式绕过跨域问题
- 在Flutter内置一个代理程序（类似casdoor-raw-js-example）.但是这样没有实际意义，因为这个代理必须在Dart环境下才能启动，对于用户而言没用。
- 调整Flutter web的逻辑，不再提供其直接获取token的功能。或告知用户，直接用Flutter web整合Casdoor会遇到跨域问题，建议结合后端使用



