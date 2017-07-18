//
//  RosterGrpMgrHeadView.h
//  IM
//
//  Created by 郭志伟 on 15-1-20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RosterGrpMgrHeadViewDelegate;

@interface RosterGrpMgrHeadView : UIView

@property(weak) id<RosterGrpMgrHeadViewDelegate> delegate;

@end

@protocol RosterGrpMgrHeadViewDelegate <NSObject>

- (void) RosterGrpMgrHeadViewTapped:(RosterGrpMgrHeadView *) headView;

@end
