//
//  JSQVoiceMediaItem.h
//  IM
//
//  Created by 郭志伟 on 15-2-13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQMediaItem.h"

@interface JSQVoiceMediaItem : JSQMediaItem <JSQMessageMediaData>


@property (nonatomic, strong) NSString *filePath;

- (instancetype)initWithFilePath:(NSString *)filePath
                         isReady:(BOOL)isReady
                        duration:(double) duration
                        outgoing:(BOOL)maskAsOutgoing
                           msgId:(NSString *)msgId;

@property(nonatomic) BOOL isReady;
@property(nonatomic) BOOL playing;
@property(readonly, nonatomic) double duration;
@property(copy)     NSString *msgId;

@end
