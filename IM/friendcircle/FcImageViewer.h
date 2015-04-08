//
//  FcImageViewer.h
//  IM
//
//  Created by 郭志伟 on 15-3-23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FcImageViewerDelegate;

@interface FcImageViewer : UIView

@property (nonatomic, weak) id<FcImageViewerDelegate> delegate;
@property (nonatomic, assign) CGFloat backgroundScale;

- (void)showWithImageViews:(NSArray*)views selectedView:(UIImageView*)selectedView;

@end

@protocol FcImageViewerDelegate <NSObject>


@end