//
//  NSString+AES.m
//  AGXMLRequest
//
//  Created by ansen on 2018/3/24.
//

#import "NSString+AES.h"
#import <CommonCrypto/CommonCrypto.h>
#import <GTMBase64/GTMBase64.h>

NSString *const kInitVector = @"gd20180324095516";
size_t const kKeySize = kCCKeySizeAES128;

@implementation NSString (AES)

- (NSString *)encryptAES1key:(NSString *)key {
    NSData *contentData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    //     为结束符'\\0' +1
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [kInitVector dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,          //指明加密算法
                                          kCCOptionPKCS7Padding,    //系统默认使用 CBC，然后指明使用 PKCS7Padding，Java中支持的是PKCS5Padding，在AES加密中是一样的，具体区别自行百度
                                          keyPtr,                   //私钥key，它是const void *key 定义的，所以可以byte也可以是字符串，字符串需要转成C语言字符串如上的keyPtr
                                          kKeySize,                 //密钥长度128
                                          initVector.bytes,         //初始向量也称偏移量，ECB模式下为NULL
                                          contentData.bytes,        //contentData加密内容
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        // 对加密后的数据进行 base64 编码
        return [[NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    free(encryptedBytes);
    return nil;
}

- (NSString *)decryptAES1key:(NSString *)key {
    // 把 base64 String 转换成 Data
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSUInteger dataLength = contentData.length;
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [kInitVector dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize] encoding:NSUTF8StringEncoding];
    }
    free(decryptedBytes);
    return nil;
}

- (NSString *)encryptWebSafeAES1key:(NSString *)key {
    NSData *contentData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    //     为结束符'\\0' +1
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [kInitVector dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,          //指明加密算法
                                          kCCOptionPKCS7Padding,    //系统默认使用 CBC，然后指明使用 PKCS7Padding，Java中支持的是PKCS5Padding，在AES加密中是一样的，具体区别自行百度
                                          keyPtr,                   //私钥key，它是const void *key 定义的，所以可以byte也可以是字符串，字符串需要转成C语言字符串如上的keyPtr
                                          kKeySize,                 //密钥长度128
                                          initVector.bytes,         //初始向量也称偏移量，ECB模式下为NULL
                                          contentData.bytes,        //contentData加密内容
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        // 对加密后的数据进行WebSafe base64 编码
        return [GTMBase64 stringByWebSafeEncodingBytes:encryptedBytes length:actualOutSize padded:YES];
    }
    free(encryptedBytes);
    return nil;
}

- (NSString *)decryptWebSafeAES1key:(NSString *)key {
    // 把 WebSafe base64 String 转换成 Data
    NSData *contentData = [GTMBase64 webSafeDecodeString:self];
    NSUInteger dataLength = contentData.length;
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [kInitVector dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize] encoding:NSUTF8StringEncoding];
    }
    free(decryptedBytes);
    return nil;
}

@end
