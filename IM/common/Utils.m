//
//  Utils.m
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSString *)documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}


+ (BOOL)EnsureDirExists:(NSString *)path {
    BOOL ret = YES;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:path])
        return ret;
    NSArray *components = [path pathComponents];
    if (components.count == 0)
        return NO;
    NSString *subPath = [components objectAtIndex:0];
    NSError *error = [[NSError alloc]init];
    for (NSInteger n = 1; n < components.count; n++) {
        subPath = [subPath stringByAppendingPathComponent:[components objectAtIndex:n]];
        if ([fileMgr fileExistsAtPath:subPath])
            continue;
        if ([[NSFileManager defaultManager]createDirectoryAtPath:subPath
                                     withIntermediateDirectories:NO
                                                      attributes:nil
                                                           error:&error]) {
            continue;
        }
        else {
            
            NSLog(@"%@", error.localizedDescription);
            ret = NO;
            break;
        }
        
    }
    return ret;
}

@end
