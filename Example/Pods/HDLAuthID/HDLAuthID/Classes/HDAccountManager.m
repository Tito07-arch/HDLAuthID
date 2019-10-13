//
//  HDAccountManager.m
//  HDLAuthID
//
//  Created by Harden.L on 2019/10/13.
//

#import "HDAccountManager.h"

@interface HDAccountManager()

@property(nonatomic,strong)NSString *authPassword;
@property(nonatomic,strong)NSString *lastAccount;
@property(nonatomic,assign)NSInteger timeSp;

@end

static HDAccountManager *instance = nil;


@implementation HDAccountManager

+ (HDAccountManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HDAccountManager alloc] init];
        instance.count = 5;
    });
    return instance;
}

#pragma mark -- authPassword 保存AES密码用于TouchID或FaceID登录
NSString* const authIDPasswordKey = @"authPasswordKey";

- (void)saveAccount:(NSString *)account password:(NSString *)password {
    _lastAccount = account;
//    NSString *MD5Pass = [DataTypeConversion NSStringToMD5:[NSString stringWithFormat:@"%@{%@}",password,account]];
    _authPassword = password;
     NSString *safePass = [password encryptWebSafeAES1key:AUTHID_SECREY_KEY];
    NSString *passKey = [NSString stringWithFormat:@"%@_%@",account,authIDPasswordKey];
    [[NSUserDefaults standardUserDefaults] setObject:safePass forKey:passKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - authIDOpen  是否开启TouchID或FaceID
NSString* const authIDOpenKey = @"authOpenKey";

-(void)isAuthIDOpen:(BOOL)authIDOpen {
    _authIDOpen = authIDOpen;
    NSString *openKey = [NSString stringWithFormat:@"%@_%@",_lastAccount,authIDOpenKey];
    [[NSUserDefaults standardUserDefaults] setBool:_authIDOpen forKey:openKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(BOOL)bCanAuth {
    NSDate *datenow = [NSDate date];
    NSInteger timeSpNow =  (NSInteger)[datenow timeIntervalSince1970];
    NSLog(@"%ld",(timeSpNow - _timeSp));
    if (timeSpNow - _timeSp > 60 * 5 ) {
        return YES;
    }
    return NO;
}

-(void)isCanAuth:(BOOL)canAuth {
    if (!canAuth) {
        NSDate *datenow = [NSDate date];
        _timeSp = (NSInteger)[datenow timeIntervalSince1970];
    }else {
        _timeSp = 0;
    }
}


- (void)updateData {
    _lastAccount = [[NSUserDefaults standardUserDefaults] objectForKey:LOGINACCOUNT];
    
     NSString *openKey = [NSString stringWithFormat:@"%@_%@",_lastAccount,authIDOpenKey];
    _authIDOpen = [[NSUserDefaults standardUserDefaults] boolForKey:openKey];
    
    NSString *passKey = [NSString stringWithFormat:@"%@_%@",_lastAccount,authIDPasswordKey];
    NSString *safePass = [[NSUserDefaults standardUserDefaults] objectForKey:passKey];
    _authPassword = [safePass decryptWebSafeAES1key:AUTHID_SECREY_KEY];
    
    _count = 5;
    _timeSp = 0;
}

- (void)authTouchIDOrFaceID:(HDTouchOrFaceIDStateBlock)block decribe:(NSString *)decribe {
    HDLAuthID *authID = [[HDLAuthID alloc] init];
    BOOL isTouch = [authID isTouchID];
    [authID showAuthIDWithDescribe:decribe login:@"" block:^(HDLAuthIDState state, NSError *error) {
        HDTouchIDOrFaceIDState touchIDState = HDTouchIDOrFaceIDStateNotSupport;
        
        switch (state) {
            case HDLAuthIDStateSuccess:
            {
                touchIDState = HDTouchIDOrFaceIDStateSuccess;
               // [SoundManager playMusic:[Tools soundWihSoundKey:@"touch_success"]];
            }
                break;
            case HDLAuthIDStateTouchIDLockout:
            {
                touchIDState = HDTouchIDOrFaceIDStateTouchIDLockout;
            }
                break;
            case HDLAuthIDStateFail:
            {
                if(isTouch) {
                    touchIDState = HDTouchIDOrFaceIDStateTouchFail;
                }else {
                    touchIDState = HDTouchIDOrFaceIDStateFaceFail;
                }
            }
                break;
            default:
                break;
        }
        block(touchIDState,error);
    }];
}

- (void)authVerification:(HDTouchOrFaceIDStateBlock)block decribe:(NSString *)decribe {
    HDLAuthID *authID = [[HDLAuthID alloc] init];
    BOOL isTouch = [authID isTouchID];
    [authID showAuthIDWithDescribe:decribe login:nil block:^(HDLAuthIDState state, NSError *error) {
        
        if (state == HDLAuthIDStateNotSupport) { // 不支持TouchID/FaceID
            NSLog(@"对不起，当前设备不支持指纹/面容ID");
            block(HDTouchIDOrFaceIDStateNotSupport,error);
        } else if(state == HDLAuthIDStateFail) { // 认证失败
            NSLog(@"指纹/面容ID不正确，认证失败");
            if (isTouch){
                block(HDTouchIDOrFaceIDStateTouchFail,error);
            } else {
                block(HDTouchIDOrFaceIDStateFaceFail,error);
            }
            [self authVerification:block decribe:decribe];
        } else if(state == HDLAuthIDStateTouchIDLockout) {   // 多次错误，已被锁定
            NSLog(@"多次错误，指纹/面容ID已被锁定，请到手机解锁界面输入密码");
            [self authPassword:block describe:decribe];
        } else if (state == HDLAuthIDStateSuccess) { // TouchID/FaceID验证成功
            NSLog(@"认证成功！");
            block(HDTouchIDOrFaceIDStateSuccess,error);
        } else if (state == HDLAuthIDStatePasswordSuccess) {
            [self authVerification:block decribe:decribe];
        } else if (state == HDLAuthIDStatePasswordNotSet || state == HDLAuthIDStateTouchIDNotSet) {
            NSLog(@"TouchID/FaceID 未启动");
            block(HDTouchIDOrFaceIDStateTouchIDNotSet,error);
        } else {
            if (isTouch){
                block(HDTouchIDOrFaceIDStateTouchFail,error);
            } else {
                block(HDTouchIDOrFaceIDStateFaceFail,error);
            }
        }
        
    }];
}

//多次密码错误，调用系统密码输入界面
- (void)authPassword:(HDTouchOrFaceIDStateBlock)block describe:(NSString *)describe {
    HDLAuthID *authID = [[HDLAuthID alloc] init];
    [authID showAuthIDByPasswordWithDescribe:describe block:^(HDLAuthIDState state, NSError *error) {
        if (state == HDLAuthIDStatePasswordSuccess) {
            NSLog(@"密码解锁成功");
            //密码解锁成功，开始验证TouchID和FaceID
            [self authVerification:block decribe:describe];
        }
    }];
}

- (BOOL)passwordVerifiers:(NSString *)password {
//    NSString *MD5Pass = [DataTypeConversion NSStringToMD5:[NSString stringWithFormat:@"%@{%@}",password,_lastAccount]];
    if ([password isEqualToString:_authPassword]) {
        return YES;
    }
    return NO;
}


@end
