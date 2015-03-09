//
//  detailMgr.h
//  IM
//
//  Created by 郭志伟 on 15-3-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Detail.h"

@interface DetailMgr : NSObject

- (void)getDetailWithUid:(NSString *)uid
                   Token:(NSString *)token
               signature:(NSString *)signature
                     key:(NSString *)key
                      iv:(NSString *)iv
                     url:(NSString *)url
              completion:(void(^)(BOOL finished, Detail *d))completion;

@end
