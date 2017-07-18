//
//  RosterGrpMgrTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15-1-20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RosterGrpMgrTableViewCellDelegate;

@interface RosterGrpMgrTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *grpNameTextField;
@property (weak) id<RosterGrpMgrTableViewCellDelegate> delegate;

@end

@protocol RosterGrpMgrTableViewCellDelegate <NSObject>

- (void)RosterGrpMgrTableViewCellTextFieldDidEnd:(RosterGrpMgrTableViewCell *)cell tag:(NSInteger)tag;
- (void)RosterGrpMgrTableViewCellTextFieldChanged:(RosterGrpMgrTableViewCell *)cell tag:(NSInteger)tag;

@end
