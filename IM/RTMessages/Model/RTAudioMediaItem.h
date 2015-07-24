//
//  RTAudioMediaItem.h
//  IM
//
//  Created by 郭志伟 on 15/7/20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMediaItem.h"

typedef NS_ENUM(UInt32, RTAudioMediaItemStatus) {
    RTAudioMediaItemStatusUnkown,
    RTAudioMediaItemStatusSending,
    RTAudioMediaItemtatusSent,
    RTAudioMediaItemStatusRecved,
    RTAudioMediaItemStatusRecving,
    RTAudioMediaItemStatusSendError,
    RTAudioMediaItemStatusRecvError
};

@interface RTAudioMediaItem : RTMediaItem

@property(nonatomic, assign) RTAudioMediaItemStatus status;

@property(nonatomic, copy) NSString *audioUrl;
@property(nonatomic, assign) CGFloat duration;
@property(nonatomic, assign) BOOL playing;


@end
