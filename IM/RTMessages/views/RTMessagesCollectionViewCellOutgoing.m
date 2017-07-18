//
//  RTMessagesCollectionViewCellOutgoing.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesCollectionViewCellOutgoing.h"

@implementation RTMessagesCollectionViewCellOutgoing

- (void)awakeFromNib {
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentRight;
    self.cellBottomLabel.textAlignment = NSTextAlignmentRight;
    
//    [self.contentView addSubview:self.indicatorView];
//    [self setupIndicatorViewConstraints];
}

//- (UIActivityIndicatorView *)indicatorView {
//    if (!_indicatorView) {
//        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _indicatorView.hidesWhenStopped = YES;
//        [_indicatorView startAnimating];
//        _indicatorView.translatesAutoresizingMaskIntoConstraints = YES;
//    }
//    return _indicatorView;
//}

- (void)setupIndicatorViewConstraints {
//    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.messageBubbleImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-8.0f];
//    [self.contentView addConstraint:rightConstraint];
    
//    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.messageBubbleImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
//    [self.contentView addConstraint:centerYConstraint];
    
}

@end
