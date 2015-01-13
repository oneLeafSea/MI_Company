//
//  RosterSectionHeaderView.h
//  IM
//
//  Created by 郭志伟 on 15-1-8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RosterSectionHeaderViewDelegate;

@interface RosterSectionHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *arrowImagView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


@property (weak) id<RosterSectionHeaderViewDelegate> delegate;

@end

@protocol RosterSectionHeaderViewDelegate <NSObject>

- (void)RosterSectionHeaderViewTapped:(RosterSectionHeaderView *)headerView tag:(NSInteger) tag;

@end