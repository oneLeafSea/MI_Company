//
//  NSMutableData+InputStream.h
//  WH
//
//  Created by 郭志伟 on 14-10-12.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (stream)
- (NSData *)left:(NSUInteger)len;
- (NSData *)right:(NSUInteger)len;
- (NSData *)mid:(NSUInteger)loc length:(NSUInteger)len;
- (void)popLen:(NSUInteger)len;
@end
