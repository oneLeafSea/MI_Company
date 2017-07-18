//
//  RTPhotoMediaItem.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMediaItem.h"

typedef NS_ENUM(UInt32, RTPhotoMediaItemStatus) {
    RTPhotoMediaItemStatusUnkown,
    RTPhotoMediaItemStatusSending,
    RTPhotoMediaItemStatusSent,
    RTPhotoMediaItemStatusRecved,
    RTPhotoMediaItemStatusRecving,
    RTPhotoMediaItemStatusSendError,
    RTPhotoMediaItemStatusRecvError
};

@interface RTPhotoMediaItem : RTMediaItem

//- (instancetype)initWithUrl:(NSString *)url;

@property(nonatomic, assign)RTPhotoMediaItemStatus status;

@property(nonatomic, copy) NSURL *orgUrl;
@property(nonatomic, copy) NSURL *thumbUrl;

@end
