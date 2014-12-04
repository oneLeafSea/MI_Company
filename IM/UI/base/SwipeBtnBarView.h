//
//  swipeBtnBarView.h
//  testPagesMgr
//
//  Created by 郭志伟 on 14-11-2.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeBtnBarView : UICollectionView

@property UIFont *labelFont;
@property NSUInteger leftRightMargin;

-(void)moveToIndex:(NSUInteger)index animated:(BOOL)animated;

@end
