//
//  NSString+AES.h
//  AGXMLRequest
//
//  Created by ansen on 2018/3/24.
//

#import <Foundation/Foundation.h>

@interface NSString (AES)
- (NSString *)encryptAES1key:(NSString *)key;
- (NSString *)decryptAES1key:(NSString *)key;

//url safe base64
- (NSString *)encryptWebSafeAES1key:(NSString *)key;
- (NSString *)decryptWebSafeAES1key:(NSString *)key;
@end
