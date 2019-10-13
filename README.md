# HDLAuthID

[![CI Status](https://img.shields.io/travis/Harden.L/HDLAuthID.svg?style=flat)](https://travis-ci.org/chasel/HDLAuthID)
[![Version](https://img.shields.io/cocoapods/v/HDLAuthID.svg?style=flat)](https://cocoapods.org/pods/HDLAuthID)
[![License](https://img.shields.io/cocoapods/l/HDLAuthID.svg?style=flat)](https://cocoapods.org/pods/HDLAuthID)
[![Platform](https://img.shields.io/cocoapods/p/HDLAuthID.svg?style=flat)](https://cocoapods.org/pods/HDLAuthID)

## description

指纹/脸部解锁

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### demo

```objective-c
 [[HDAccountManager sharedInstance] updateData];
    [[HDAccountManager sharedInstance] authTouchIDOrFaceID:^(HDTouchIDOrFaceIDState state, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
                       switch (state) {
                           case HDTouchIDOrFaceIDStateSuccess:
                           {
                               NSLog(@"验证成功！");
                              
                           }
                               break;
                           case HDTouchIDOrFaceIDStateTouchFail:
                           {
                               NSLog(@"指纹验证失败！");
                           }
                               break;
                           case HDTouchIDOrFaceIDStateFaceFail:
                           {
                               NSLog(@"面容验证失败！");
                           }
                               break;
                           case HDTouchIDOrFaceIDStateTouchIDLockout:
                           {
                               NSLog(@"指纹被锁定，请前往设置解锁！");
                           }
                               break;
                           default:
                               break;
                       }
                   });
    } decribe:@"请验证指纹或者面容"];
```

## Requirements

ios >= 8.0

## Installation

HDLAuthID is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HDLAuthID'
```

## Author

Harden.L, 363182580@qq.com

## License

HDLAuthID is available under the MIT license. See the LICENSE file for more info.
