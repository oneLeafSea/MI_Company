//
//  JSQFileMediaItem.h
//  IM
//
//  Created by 郭志伟 on 15-2-17.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQMediaItem.h"

@interface JSQFileMediaItem : JSQMediaItem

@property (nonatomic, strong) NSString *filePath;

- (instancetype)initWithFilePath:(NSString *)filePath
                          fileSz:(unsigned long long)fileSz
                            uuid:(NSString *)uuid
                        fileName:(NSString *)fileName
                    isDownloaded:(BOOL)isDownloaded
                        outgoing:(BOOL)maskAsOutgoing;

@property(nonatomic) BOOL isDownloaded;
@property(nonatomic) unsigned long long fileSz;
@property(nonatomic) NSString *uuid;
@property(nonatomic) NSString *fileName;

@end
