//
//  NSMutableData+InputStream.m
//  WH
//
//  Created by 郭志伟 on 14-10-12.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "NSMutableData+stream.h"

@implementation NSMutableData (stream)

- (NSData *)left:(NSUInteger)len {
    if (self.length < len) {
        return nil;
    }
    
    NSData *data = [self subdataWithRange:NSMakeRange(0, len)];
    return data;
}

- (NSData *)right:(NSUInteger)len {
    if (self.length < len) {
        return nil;
    }
    
    NSData *data = [self subdataWithRange:NSMakeRange(self.length - len, len)];
    return data;
}
- (NSData *)mid:(NSUInteger)loc length:(NSUInteger)len {
    return [self subdataWithRange:NSMakeRange(loc, len)];
}

- (void)popLen:(NSUInteger)len {
    [self replaceBytesInRange:NSMakeRange(0, len) withBytes:NULL length:0];
}
@end
