//
//  WebRtcCallViewController.h
//  IM
//
//  Created by 郭志伟 on 15-4-1.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebRtcCallViewController : UIViewController

@property(nonatomic, strong) NSString *uid;
@property(nonatomic, strong) NSURL *serverUrl;
@property(nonatomic, strong) NSString *talkingUid;

@end
