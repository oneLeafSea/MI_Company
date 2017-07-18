//
//  ChatMesssageBox.h
//  IM
//
//  Created by 郭志伟 on 15-1-14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMesssageBox : NSObject


- (void)putMsgId:(NSString *)msgid callback:(void(^)(BOOL finished, id arguments)) callback;

- (void)notifyMsgId:(NSString *)msgid finished:(BOOL)finished  argument:(id)argument;

@end
