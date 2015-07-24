//
//  RTChatModel.h
//  IM
//
//  Created by 郭志伟 on 15/7/21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTMessages.h"

@interface RTChatModel : NSObject

- (instancetype)initWithMsgs:(NSArray *)msgs;

@property(nonatomic, strong)NSMutableArray *messages;
@property (strong, nonatomic) RTMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) RTMessagesBubbleImage *incomingBubbleImageData;


@end
