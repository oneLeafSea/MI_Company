//
//  NSDate+Common.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Common)

+ (instancetype) Now;

/**
 * fmt the date format.
 * @param fmt if fmt is nil. return value fmt is yyyy-MM-dd HH:mm:ss.
 * @return return the specifial fmt value.
 **/

- (NSString *)formatWith:(NSString *)fmt;

@end
