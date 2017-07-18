//
//  RosterItemAddReqDetailTableViewController.h
//  IM
//
//  Created by 郭志伟 on 15-1-23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RosterItemAddRequest.h"

@protocol RosterItemAddReqDetailTableViewControllerDelegate;

@interface RosterItemAddReqDetailTableViewController : UITableViewController

@property(nonatomic) RosterItemAddRequest *req;

@property id<RosterItemAddReqDetailTableViewControllerDelegate> delegate;

@end

@protocol RosterItemAddReqDetailTableViewControllerDelegate <NSObject>

- (void)RosterItemAddReqDetailTableViewControllerChanged;

@end
