//
//  PwdMgr.h
//  IM
//
//  Created by 郭志伟 on 15-3-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PwdMgr : NSObject

+ (void) changePwdWithOldPwd:(NSString *)oldPwd
                     newPwd:(NSString *)newPwd
                      Token:(NSString *)token
                  signature:(NSString *)signature
                        key:(NSString *)key
                         iv:(NSString *)iv
                        url:(NSString *)url
                 completion:(void(^)(BOOL finished)) completion;

@end
