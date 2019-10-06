//
//  HDLAuthID.m
//  HDLAuthID
//
//  Created by Harden on 2019/4/1.
//

#import "HDLAuthID.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface HDLAuthID(){
    LAContext *_context;
    NSString *_describe;
}

@property(nonatomic,assign)HDLAuthIDStateBlock authBlock;

@end

@implementation HDLAuthID

- (void)showAuthIDWithDescribe:(NSString *)describe login:(NSString *)loginTitle block:(HDLAuthIDStateBlock)block {
    
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)");
            block(HDLAuthIDStateVersionNotSupport, nil);
        });
        
        return;
    }
    if (describe) {
        _describe = describe;
    }
    self->_authBlock = block;
    _context = [[LAContext alloc] init];
    // 认证失败提示信息，为 @"" 则不提示
    _context.localizedFallbackTitle = @"";
    NSError *error = nil;
    if (loginTitle) {
        if (@available(iOS 10.0, *)) {
            _context.localizedCancelTitle = loginTitle;
        }
    }
    
    // LAPolicyDeviceOwnerAuthenticationWithBiometrics: 用TouchID/FaceID验证
    // LAPolicyDeviceOwnerAuthentication: 用TouchID/FaceID或密码验证, 默认是错误两次或锁定后, 弹出输入密码界面（本案例使用）
    if ([_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [self loadDescribe];
        [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:_describe reply:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID/FaceID 验证成功");
                    block(HDLAuthIDStateSuccess, error);
                });
            }else if(error) {
                [self error:error block:block];
            }
        }];
        
    }else {
        if (!loginTitle) {
            if (error.code == -8) {
                [self showAuthIDByPasswordWithDescribe:nil block:block];
            } else {
                [self error:error block:block];
            }
        }
    }
}

- (void)showAuthIDByPasswordWithDescribe:(NSString *)describe block:(HDLAuthIDStateBlock)block{
    
    if (!_context) {
        _context = [[LAContext alloc] init];
        // 认证失败提示信息，为 @"" 则不提示
        _context.localizedFallbackTitle = @"";
    }
    NSError *error = nil;
    if(!describe) {
        describe = @"多次错误，指纹/面容ID已被锁定，请输入您的iphone密码来解锁";
    }
    if (@available(iOS 9.0, *)) {
        if ([_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
            [_context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:describe reply:^(BOOL success, NSError * _Nullable error) {
                
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"TouchID/FaceID 验证成功");
                        block(HDLAuthIDStatePasswordSuccess, error);
                    });
                }else if(error) {
                    [self error:error block:block];
                }
            }];
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"当前设备不支持TouchID/FaceID");
                block(HDLAuthIDStateNotSupport, error);
            });
            
        }
    }
}

- (void)loadDescribe {
    if(!_describe) {
        if (@available(iOS 11.0, *)){
            if (_context.biometryType == LABiometryTypeFaceID) {
                _describe = @"验证已有面容";
            }else {
                _describe = @"通过Home键验证已有指纹";
            }
        } else {
            _describe = @"通过Home键验证已有指纹";
        }
    }
}

- (void)error:(NSError *)error block:(HDLAuthIDStateBlock)block {
    if (@available(iOS 11.0, *)) {
        switch (error.code) {
            case LAErrorAuthenticationFailed:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID/FaceID 验证失败");
                    block(HDLAuthIDStateFail, error);
                });
                break;
            }
            case LAErrorUserCancel:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID/FaceID 被用户手动取消");
                    block(HDLAuthIDStateUserCancel, error);
                });
            }
                break;
            case LAErrorUserFallback:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"用户不使用TouchID/FaceID,选择手动输入密码");
                    block(HDLAuthIDStateInputPassword, error);
                });
            }
                break;
            case LAErrorSystemCancel:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                    block(HDLAuthIDStateSystemCancel, error);
                });
            }
                break;
            case LAErrorPasscodeNotSet:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID/FaceID 无法启动,因为用户没有设置密码");
                    block(HDLAuthIDStatePasswordNotSet, error);
                });
            }
                break;
                //case LAErrorTouchIDNotEnrolled:{
            case LAErrorBiometryNotEnrolled:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID");
                    block(HDLAuthIDStateTouchIDNotSet, error);
                });
            }
                break;
                //case LAErrorTouchIDNotAvailable:{
            case LAErrorBiometryNotAvailable:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID/FaceID 无效");
                    block(HDLAuthIDStateTouchIDNotAvailable, error);
                });
            }
                break;
                //case LAErrorTouchIDLockout:{
            case LAErrorBiometryLockout:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)");
                    block(HDLAuthIDStateTouchIDLockout, error);
                });
            }
                break;
            case LAErrorAppCancel:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                    block(HDLAuthIDStateAppCancel, error);
                });
            }
                break;
            case LAErrorInvalidContext:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                    block(HDLAuthIDStateInvalidContext, error);
                });
            }
                break;
            default:
                break;
        }
    } else {
        // iOS 11.0以下的版本只有 TouchID 认证
        switch (error.code) {
            case LAErrorAuthenticationFailed:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID 验证失败");
                    block(HDLAuthIDStateFail, error);
                });
                break;
            }
            case LAErrorUserCancel:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID 被用户手动取消");
                    block(HDLAuthIDStateUserCancel, error);
                });
            }
                break;
            case LAErrorUserFallback:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"用户不使用TouchID,选择手动输入密码");
                    block(HDLAuthIDStateInputPassword, error);
                });
            }
                break;
            case LAErrorSystemCancel:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                    block(HDLAuthIDStateSystemCancel, error);
                });
            }
                break;
            case LAErrorPasscodeNotSet:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID 无法启动,因为用户没有设置密码");
                    block(HDLAuthIDStatePasswordNotSet, error);
                });
            }
                break;
            case LAErrorTouchIDNotEnrolled:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID 无法启动,因为用户没有设置TouchID");
                    block(HDLAuthIDStateTouchIDNotSet, error);
                });
            }
                break;
                //case :{
            case LAErrorTouchIDNotAvailable:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID 无效");
                    block(HDLAuthIDStateTouchIDNotAvailable, error);
                });
            }
                break;
            case LAErrorTouchIDLockout:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)");
                    block(HDLAuthIDStateTouchIDLockout, error);
                });
            }
                break;
            case LAErrorAppCancel:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                    block(HDLAuthIDStateAppCancel, error);
                });
            }
                break;
            case LAErrorInvalidContext:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                    block(HDLAuthIDStateInvalidContext, error);
                });
            }
                break;
            default:
                break;
        }
    }
}

- (BOOL)isTouchID {
    _context = [[LAContext alloc] init];
    [_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    BOOL isTouchID = YES;
    if (@available(iOS 11.0, *)){
        if (_context.biometryType == LABiometryTypeFaceID) {
            isTouchID = NO;
        }
    }
    return isTouchID;
}

@end
