//
//  WebRtcRecvViewChatViewController.h
//  IM
//
//  Created by 郭志伟 on 15-3-30.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebRtcRecvViewChatViewController : UIViewController

@property(nonatomic, strong) NSURL *serverUrl;
@property(nonatomic, strong) NSString *uid;
@property(nonatomic, strong) NSString *rid;
@property(nonatomic, strong) NSString *talkingUid;

@end
