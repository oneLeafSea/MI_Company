//
//  OsOrg.h
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OsOrg : NSObject

- (instancetype) initWithJgbm:(NSString *)jgbm
                         jgmc:(NSString *)jgmc
                         jgjc:(NSString *)jgjc
                       sjjgbm:(NSString *)sjjgbm
                           xh:(NSString *)xh;

@property(nonatomic) NSString *jgbm;
@property(nonatomic) NSString *jgmc;
@property(nonatomic) NSString *jgjc;
@property(nonatomic) NSString *sjjgbm;
@property(nonatomic) NSString *xh;

@end
