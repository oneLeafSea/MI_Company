//
//  FileBlocksMgr.h
//  IM
//
//  Created by 郭志伟 on 15-1-30.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileBlock.h"

@interface FileBlocksMgr : NSObject

- (instancetype)initWithFilePath:(NSString *) filePath
                          filesz:(unsigned long long)sz
                  defaultBlockSz:(NSUInteger)defaultBlockSz
                        fileName:(NSString *)fileName;

- (FileBlock *)getNotTranferedBlock;

- (BOOL)removeBlockInfo;

- (void)update;

- (BOOL) isEnd;

@end
