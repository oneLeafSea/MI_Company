//
//  JRMethod.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRReqMethod : NSObject

- (instancetype) initWithService:(const NSString *)svc;
- (NSString *)method;


+ (NSString *) Method:(NSString *)service;

@property(readonly) const NSString *service;

@end
