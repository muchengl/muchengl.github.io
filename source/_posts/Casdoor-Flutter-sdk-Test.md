---
title: Casdoor Flutter Sdk Test
date: 2022-11-22 11:05:19
tags: casdoor
---



## Step 1: Clone casdoor-flutter-example from Github

Link: https://github.com/casdoor/casdoor-flutter-example



## Step 2: Test in Chrome(Web)

Encountered a cross-domain problem. So the token could not be obtained.

```dart
// cross-domain code
// Post: localhost -> door.casdoor.com
final response = await _casdoor.requestOauthAccessToken(code);
```

Error:

![截屏2022-11-26 14.12.45](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2022-11-26%2014.12.45.png)

## Step 3: Test in Android Emulator

Android app can get a Token. But the automatic jump from browser back to App cannot be triggered. (Perhaps the emulator causes this bug)

Graphic：

![截屏2022-11-26 14.41.25](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2022-11-26%2014.41.25.png)

## Step 4: Test in IOS Emulator

Working well.

![截屏2022-11-26 15.38.58](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/%E6%88%AA%E5%B1%8F2022-11-26%2015.38.58.png)









