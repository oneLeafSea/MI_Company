//
//  RTFileView.h
//  IM
//
//  Created by 郭志伟 on 15/7/17.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTFileView : UIView

@property(nonatomic, readonly) BOOL isOutgoing;
- (instancetype) initWithFrame:(CGRect)frame
                    isOutgoing:(BOOL)isOutgoing;


@property(nonatomic, readonly) UIImageView *imgView;
@property(nonatomic, readonly) UILabel     *fileNameLabel;
@property(nonatomic, readonly) UILabel     *fileSzLabel;
@property(nonatomic, readonly) UILabel     *statusLabel;
@property(nonatomic, readonly) UIProgressView *progressView;

@end
