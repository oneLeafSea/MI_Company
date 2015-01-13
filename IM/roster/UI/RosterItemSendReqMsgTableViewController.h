//
//  RosterItemSendReqMsgTableViewController.h
//  IM
//
//  Created by 郭志伟 on 15-1-13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RosterItemSendReqMsgTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *nameIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *grpLabel;

@property (weak, nonatomic) IBOutlet UILabel *reqMsgLabel;

@property (nonatomic) NSDictionary *itemInfo;
@property (nonatomic) NSString *reqMsg;

@end
