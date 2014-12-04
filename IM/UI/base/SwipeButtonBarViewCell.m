//
//  SwipeButtonBarViewCell.m
//  testPagesMgr
//
//  Created by 郭志伟 on 14-11-2.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "SwipeButtonBarViewCell.h"

@implementation SwipeButtonBarViewCell

- (void)awakeFromNib {
    // Initialization code
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.highlighted = YES;
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SwipeButtonBarViewCell" owner:self options:nil];
        
        if (arrayOfViews.count < 1) {
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

@end
