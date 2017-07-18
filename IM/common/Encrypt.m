//
//  Encrypt.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Encrypt.h"
#import "NSData+CommonCrypto.h"

@implementation Encrypt

+ (NSString *)encodeWithKey:(NSString *)key iv:(NSString *)iv data:(NSData *)data error:(NSError **)error {
    
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *ivData = [[NSData alloc] initWithBase64EncodedString:iv options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    
    NSData *aesData = [data AES256EncryptedDataUsingKey:keyData iv:ivData error:error];
    
    NSString *aesbase64Str = [aesData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return aesbase64Str;
}

+ (NSData *)decodeWithKey:(NSString *)key iv:(NSString *)iv base64Str:(NSString *)base64Str error:(NSError **)error {
    
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *ivData = [[NSData alloc] initWithBase64EncodedString:iv options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSData *decAesData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSData *decInfoData = [decAesData decryptedAES256DataUsingKey:keyData iv:ivData error:error];
    
    return decInfoData;
}



@end
