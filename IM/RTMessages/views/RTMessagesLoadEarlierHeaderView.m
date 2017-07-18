//
//  RTMessagesLoadEarlierHeaderView.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesLoadEarlierHeaderView.h"
#import "NSBundle+RTMessages.h"

const CGFloat kRTMessagesLoadEarlierHeaderViewHeight = 32.0f;

@interface RTMessagesLoadEarlierHeaderView()

@end

@implementation RTMessagesLoadEarlierHeaderView

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([RTMessagesLoadEarlierHeaderView class])
                          bundle:[NSBundle bundleForClass:[RTMessagesLoadEarlierHeaderView class]]];
}

+ (NSString *)headerReuseIdentifier {
    return NSStringFromClass([RTMessagesLoadEarlierHeaderView class]);
}

#pragma mark - Initialization
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.backgroundColor = [UIColor clearColor];
}


#pragma mark - Reusable view

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
}




@end
