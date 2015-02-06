//
//  ChatViewMorePanelCellView.m
//  IM
//
//  Created by 郭志伟 on 15-2-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatViewMorePanelCellView.h"

@implementation ChatViewMorePanelCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.highlighted = YES;
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ChatViewMorePanelCellView" owner:self options:nil];
        
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
        {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        self.contentView.layer.cornerRadius = 10;
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 95, 116)];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:7.0/255.0f green:185.0/255.0f blue:155.0/255.0f alpha:0];
        self.selectedBackgroundView.layer.cornerRadius = 10;
    }
    return self;
}

@end
