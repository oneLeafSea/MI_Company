//
//  RTMessagesCollectionViewCellIncoming.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesCollectionViewCellIncoming.h"

@implementation RTMessagesCollectionViewCellIncoming

- (void)awakeFromNib {
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
    self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;
}

@end
