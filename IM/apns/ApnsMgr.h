//
//  ApnsMgr.h
//  IM
//
//  Created by 郭志伟 on 15-3-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApnsMgr : NSObject

+ (void)registerWithIOSToken:(NSString *)iosToken
                         uid:(NSString *)uid
                       Token:(NSString *)token
                   signature:(NSString *)signature
                         key:(NSString *)key
                          iv:(NSString *)iv
                         url:(NSString *)url
                  completion:(void(^)(BOOL finished))completion;
@end
