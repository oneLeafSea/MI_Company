//
//  ChatMesssageBox.m
//  IM
//
//  Created by 郭志伟 on 15-1-14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMesssageBox.h"


@interface ChatMesssageBox() {
    NSMutableDictionary *m_msgBox;
    dispatch_queue_t m_queue;
}
@end

@implementation ChatMesssageBox

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_msgBox = [[NSMutableDictionary alloc] init];
        m_queue = dispatch_queue_create("cn.com.rooten.im.chatmessagebox.queue", NULL);
    }
    return self;
}

- (void)putMsgId:(NSString *)msgid callback:(void(^)(BOOL finished, id arguments)) callback {
    dispatch_async(m_queue, ^{
        [m_msgBox setObject:callback forKey:msgid];
    });
}

- (void)notifyMsgId:(NSString *)msgid finished:(BOOL)finished argument:(id)argument {
    dispatch_async(m_queue, ^{
        void (^callback)(BOOL,id) = [m_msgBox objectForKey:msgid];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(finished, argument);
            }
        });
        [m_msgBox removeObjectForKey:msgid];
    });
}

@end
