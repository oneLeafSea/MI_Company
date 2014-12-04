//
//  MainCVC.m
//  dongrun_beijing
//
//  Created by 郭志伟 on 14-10-30.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "MainCVC.h"

@interface MainCVC() {
    
}
@end


@implementation MainCVC

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.highlighted = YES;
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"MainCVC" owner:self options:nil];
        
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
