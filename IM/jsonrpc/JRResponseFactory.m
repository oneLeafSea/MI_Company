//
//  JRResponseFactory.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRResponseFactory.h"
#import "NSJSONSerialization+StrDictConverter.h"
#import "Encrypt.h"

#import "JRTextResponse.h"
#import "JRTableResponse.h"
#import "JRBinResponse.h"
#import "JRListResponse.h"
#import "JRErrorResponse.h"
#import "LogLevel.h"

static NSString *JRResponsFactorErrorDomain = @"JRResponseFactory Class";

static const NSString *kKeyTimestamp      = @"timestamp";
static const NSString *kKeyResult         = @"result";
static const NSString *kKeyType           = @"type";
static const NSString *kKeyResultInResult = @"result";
static const NSString *kKeyExt            = @"ext";

static const NSString *kTypeList          = @"list";
static const NSString *kTypeTable         = @"table";
static const NSString *kTypeText          = @"text";
static const NSString *kTypeBin           = @"bin";


@implementation JRResponseFactory

+ (JRResponse *)parseResponseObject:(NSDictionary *) respData key:(NSString *) key iv:(NSString *) iv error:(NSError **)error {
    
    JRResponse *resp = nil;
    
    NSString *timestamp = respData[kKeyTimestamp];
    NSString *result = respData[kKeyResult];
    
    if (![result isKindOfClass:[NSString class]]) {
        DDLogError(@"错误，返回的reslut");
        NSError *e = [JRResponseFactory genError:JRResponseFactoryParseErrorUnkownResp description:@"未知类型！"];
        if (e) {
             *error = e;
        }
        return nil;
    }
    
    NSError *err = nil;
    NSData   *decRes = [Encrypt decodeWithKey:key iv:iv base64Str:result error:&err];
    if (err) {
        *error = err;
        return nil;
    }
    
    NSString *decStr = [[NSString alloc]initWithData:decRes encoding:NSUTF8StringEncoding];
    NSLog(@"%@", decStr);
    NSDictionary *dictRes = [NSJSONSerialization objFromJsonString:decStr];
    JRResponseType type = [JRResponseFactory covertFromStr:dictRes[kKeyType]];
    NSDictionary *ext = dictRes[kKeyExt];
    
    // result里面的result
    NSObject *resultInResult = dictRes[kKeyResultInResult];
    
    switch (type) {
        case JRResponseTypeText:
        {
            JRTextResponse *txtResp = [[JRTextResponse alloc] initWithType:JRResponseTypeText ext:ext timestamp:timestamp];
            if ([resultInResult isKindOfClass:[NSString class]]) {
                NSString *ret = (NSString *)resultInResult;
                txtResp.text = ret;
                resp = txtResp;
            } else {
                *error = [JRResponseFactory genError:JRResponseFactoryParseErrorTextResp description:@"parse text response error not NSString class"];
            }
        }
            break;
        case JRResponseTypeBin:
        {
            JRBinResponse *binResp = [[JRBinResponse alloc] initWithType:JRResponseTypeBin ext:ext timestamp:timestamp];
            if ([resultInResult isKindOfClass:[NSString class]]) {
                NSString *ret = (NSString *)resultInResult;
                NSData   *data = [[NSData alloc] initWithBase64EncodedString:ret options:NSDataBase64DecodingIgnoreUnknownCharacters];
                BOOL suc = [binResp handleResult:data];
                if (suc) {
                    resp = binResp;
                } else {
                    *error = [JRResponseFactory genError:JRResponseFactoryParseErrorBinResp description:@"parse bin response error"];
                }
            } else {
                *error = [JRResponseFactory genError:JRResponseFactoryParseErrorBinResp description:@"parse bin response error not NSString class!"];
            }
            
        }
            break;
        case JRResponseTypeList:
        {
            JRListResponse *listResp = [[JRListResponse alloc] initWithType:JRResponseTypeList ext:ext timestamp:timestamp];
            if ([resultInResult isKindOfClass:[NSArray class]]) {
                NSArray *ret = (NSArray *)resultInResult;
                BOOL suc = [listResp handleResult:ret];
                if (suc) {
                    resp = listResp;
                } else {
                    *error = [JRResponseFactory genError:JRResponseFactoryParseErrorListResp description:@"parse list response error"];
                }
            } else {
                *error = [JRResponseFactory genError:JRResponseFactoryParseErrorListResp description:@"parse list response error not NSArray class!"];
            }
            
        }
            break;
        case JRResponseTypeTable:
        {
            JRTableResponse *tableResp = [[JRTableResponse alloc] initWithType:JRResponseTypeTable ext:ext timestamp:timestamp];
            if ([resultInResult isKindOfClass:[NSArray class]] || resultInResult == nil) {
                NSArray *ret = (NSArray *)resultInResult;
                tableResp.result = ret;
                resp = tableResp;
            } else {
                *error = [JRResponseFactory genError:JRResponseFactoryParseErrorTableResp description:@"parse table response error not NSArray class"];
            }
            
        }
            break;
        case JRResponseTypeError:
        {
            
            // 暂时没有数据。
            JRErrorResponse *errResp = [[JRErrorResponse alloc] initWithType:JRResponseTypeError ext:ext timestamp:timestamp];
            BOOL suc = [errResp handleResult:resultInResult];
            if (suc) {
                resp = errResp;
            } else {
                *error = [JRResponseFactory genError:JRResponseFactoryParseErrorErrorResp description:@"parse error response error"];
            }
        }
            break;
        default:
            break;
    }
    return resp;
}

+ (JRResponseType)covertFromStr:(NSString *)type {
    
    JRResponseType jrType = JRResponseTypeError;
    if ([type isEqualToString:@"list"]) {
        jrType =JRResponseTypeList;
    } else if ([type isEqualToString:@"table"]) {
        jrType = JRResponseTypeTable;
    } else if ([type isEqualToString:@"text"]) {
        jrType = JRResponseTypeText;
    } else if ([type isEqualToString:@"bin"]) {
        jrType = JRResponseTypeBin;
    } else {
        jrType = JRResponseTypeError;
    }
    return jrType;
    
}

+ (NSError *)genError:(NSInteger)errCode description:(NSString *)desp {
    NSError *err = [[NSError alloc] initWithDomain:JRResponsFactorErrorDomain code:errCode userInfo:@{@"description" : desp}];
    return err;
}

@end
