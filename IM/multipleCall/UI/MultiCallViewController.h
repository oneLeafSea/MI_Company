//
//  MultiCallViewController.h
//  IM
//
//  Created by 郭志伟 on 15/5/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiCallViewController : UIViewController

@property(nonatomic, strong)NSArray *talkingUids;

@property(nonatomic)BOOL     invited;

@property(nonatomic)NSString *roomId;

@end
