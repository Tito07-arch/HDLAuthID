//
//  HDLAuthID.h
//  HDLAuthID
//
//  Created by Harden on 2019/4/1.
//

#import <Foundation/Foundation.h>

/**
 *  TouchID/FaceID 状态
 */
typedef NS_ENUM(NSUInteger, HDLAuthIDState){
    
    /**
     *  当前设备不支持TouchID/FaceID
     */
    HDLAuthIDStateNotSupport = 0,
    /**
     *  TouchID/FaceID 验证成功
     */
    HDLAuthIDStateSuccess = 1,
    
    /**
     *  TouchID/FaceID 验证失败
     */
    HDLAuthIDStateFail = 2,
    /**
     *  TouchID/FaceID 被用户手动取消
     */
    HDLAuthIDStateUserCancel = 3,
    /**
     *  用户不使用TouchID/FaceID,选择手动输入密码
     */
    HDLAuthIDStateInputPassword = 4,
    /**
     *  TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)
     */
    HDLAuthIDStateSystemCancel = 5,
    /**
     *  TouchID/FaceID 无法启动,因为用户没有设置密码
     */
    HDLAuthIDStatePasswordNotSet = 6,
    /**
     *  TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID
     */
    HDLAuthIDStateTouchIDNotSet = 7,
    /**
     *  TouchID/FaceID 无效
     */
    HDLAuthIDStateTouchIDNotAvailable = 8,
    /**
     *  TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)
     */
    HDLAuthIDStateTouchIDLockout = 9,
    /**
     *  当前软件被挂起并取消了授权 (如App进入了后台等)
     */
    HDLAuthIDStateAppCancel = 10,
    /**
     *  当前软件被挂起并取消了授权 (LAContext对象无效)
     */
    HDLAuthIDStateInvalidContext = 11,
    /**
     *  系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)
     */
    HDLAuthIDStateVersionNotSupport = 12,
    /**
     *  TouchID/FaceID 验证成功
     */
    HDLAuthIDStatePasswordSuccess = 13
};

@interface HDLAuthID : NSObject

typedef void (^HDLAuthIDStateBlock)(HDLAuthIDState state, NSError *error);

/**
 * 启动TouchID/FaceID进行验证
 * @param describe TouchID/FaceID显示的描述
 * @param block 回调状态的block
 */
- (void)showAuthIDWithDescribe:(NSString *)describe login:(NSString *)loginTitle block:(HDLAuthIDStateBlock)block;

/**
 * 多次验证错误，指纹/面容ID已被锁定，需要手动输入密码来解锁
 * @param describe TouchID/FaceID显示的描述
 */
- (void)showAuthIDByPasswordWithDescribe:(NSString *)describe block:(HDLAuthIDStateBlock)block;

- (BOOL)isTouchID;

@end
