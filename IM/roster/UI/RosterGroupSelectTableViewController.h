//
//  RosterGroupSelectTableViewController.h
//  IM
//
//  Created by 郭志伟 on 15-1-13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RosterGroup.h"

@protocol RosterGroupSelectTableViewControllerDelegate;


@interface RosterGroupSelectTableViewController : UITableViewController

@property(weak) id<RosterGroupSelectTableViewControllerDelegate> delegate;
@property  NSUInteger selectedIndex;
@end


@protocol RosterGroupSelectTableViewControllerDelegate <NSObject>

- (void) RosterGroupSelectTableViewController:(RosterGroupSelectTableViewController *) controller didSelectedGrp:(RosterGroup *)grp;

@end