//
//  JRReqest.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRReqMethod.h"
#import "JRReqParam.h"

@interface JRReqest : NSObject

- (instancetype) initWithMethod:(JRReqMethod *) m param:(JRReqParam *) param;


@property (readonly) JRReqMethod     *method;
@property (readonly) JRReqParam      *param;
@property (readonly) NSString        *requestID;

@property (readonly) NSString        *key;
@property (readonly) NSString        *iv;

@end
