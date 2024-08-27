---
title: Cross-domain security in SSO
date: 2022-12-01 19:18:10
tags: Casdoor
---

由于Casdoor Flutter Sdk遇到了跨域问题，故调研Okta和Auth0的跨域问题的解决方案，方案初步整理如下：

## 解决策略

在单点登录系统中，Single-Page App需要从浏览器跨域访问SSO服务器。为支持这一需求，单点登录系统应支持配置“Allowed Web Origins”和“Allowed API”。SSO服务可以根据这两个配置对跨域请求进行校验。

> 定义：
> - **Single-Page App**：单页应用。为不包含后端的纯web页面
>
> - **Allowed Web Origins**：允许跨域访问的网络源(Web Origin)。尽管Single-Page App不包含后端，但其依然会挂在一个服务器上以支持用户访问，这个服务器的Host就是Web Origin
>
> -  **Allowed API**：支持跨域访问的API

以下为Okta和Auth0对两种配置的支持情况：

|           | Okta |       Auth0 |
| :-----: | :---: | :----------: |
| Allowed Web Origins | ✅ | ✅ |
| Allowed API | ✅ |  ⭕️ |

对于Js sdk，需对跨域访问的请求头进行配置：

```
referrer : Web Origin/path
origin : Web Origin
```

此外，需针对Token的存储模式提供安全保障，例如localstorage和设定过期策略。
（Okta和Auth0的整个跨域支持逻辑比较复杂，暂未弄清整个流程全部细节）

## Okta对跨域问题的支持

Okta跨域配置教程：https://developer.okta.com/docs/guides/enable-cors/main/

![截屏2022-12-01 19.50.59](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2022-12-01%2019.50.59.png)

Okta js sdk repo：https://github.com/okta/okta-auth-js
Okta js sdk教程：https://developer.okta.com/docs/guides/auth-js/main/

## Auth0对跨域问题的支持

Auth0 js sdk教程：https://auth0.com/docs/quickstart/spa/vanillajs/interactive

![截屏2022-12-01 19.48.51](https://github.com/muchengl/pic_storage/blob/main/uPic/截屏2022-12-01%2019.48.51.png?raw=true)

Auth0 js sdk: https://github.com/auth0/auth0.js/blob/master/src/web-auth/cross-origin-authentication.js

