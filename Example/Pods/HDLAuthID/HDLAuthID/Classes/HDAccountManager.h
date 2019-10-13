//
//  HDAccountManager.h
//  HDLAuthID
//
//  Created by Harden.L on 2019/10/13.
//

#import <Foundation/Foundation.h>
#import "HDLAuthID.h"

/**
 *  TouchID/FaceID 状态
 */
typedef NS_ENUM(NSUInteger, HDTouchIDOrFaceIDState){
    
    /**
     *  当前设备不支持TouchID/FaceID
     */
    HDTouchIDOrFaceIDStateNotSupport = 0,
    /**
     *  TouchID/FaceID 验证成功
     */
    HDTouchIDOrFaceIDStateSuccess = 1,
    
    /**
     *  TouchID 验证失败
     */
    HDTouchIDOrFaceIDStateTouchFail = 2,
    /**
     *  FaceID  验证失败
     */
    HDTouchIDOrFaceIDStateFaceFail = 3,
    /**
     *  TouchID/FaceID 无法启动
     */
    HDTouchIDOrFaceIDStateTouchIDNotSet = 4,
    /**
     *  TouchID/FaceID 无效
     */
    HDTouchIDOrFaceIDStateTouchIDNotAvailable = 5,
    /**
     *  TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)
     */
    HDTouchIDOrFaceIDStateTouchIDLockout = 6,
    /**
     *  系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)
     */
    HDTouchIDOrFaceIDStateVersionNotSupport = 7,
    /**
     *  TouchID/FaceID 密码验证成功
     */
    HDTouchIDOrFaceIDStatePasswordSuccess = 8
};

typedef void (^HDTouchOrFaceIDStateBlock)(HDTouchIDOrFaceIDState state, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface HDAccountManager : NSObject

@property(nonatomic,assign,setter=isAuthIDOpen:)BOOL authIDOpen;//是否开启touchID和faceID验证（这个变量与账户同步）
@property(nonatomic,strong,readonly)NSString *authPassword;     //当前账户的密码
@property(nonatomic,strong,readonly)NSString *lastAccount;      //当前账户
@property(nonatomic,assign,setter=isCanAuth:,getter=bCanAuth)BOOL canAuth;      //已经可以验证了
@property(nonatomic,assign)NSInteger count;

/**
 * 创建一个账号管理器
 */
+ (HDAccountManager *)sharedInstance;

/**
 * 保存密码为TouchID或FaceID登录用
 * @param account 账号
 * @param password 密码
 */
- (void)saveAccount:(NSString *)account password:(NSString *)password;

/**
 * 刷新数据 app启动时和登录成功后都要调用一次此方法
 * app启动时，调用是为了检测要登录的账号信息
 * 登录成功后，调用是为了保存真实的账号信息
 */
- (void)updateData;

/**
 * app启动时做touchID或faceID登录用的方法
 * @param block touchID或faceID验证状态的回调
 */
- (void)authTouchIDOrFaceID:(HDTouchOrFaceIDStateBlock)block decribe:(NSString *)decribe;

/**
 * 设置界面做touchId或faceId验证用的方法
 * @param block touchID或faceID验证状态的回调
 */
- (void)authVerification:(HDTouchOrFaceIDStateBlock)block decribe:(NSString *)decribe;

/**
 * 验证密码
 * @param password 要验证的密码
 * @return YES 验证通过 NO 没有通过
 */
- (BOOL)passwordVerifiers:(NSString *)password;


@end

NS_ASSUME_NONNULL_END
