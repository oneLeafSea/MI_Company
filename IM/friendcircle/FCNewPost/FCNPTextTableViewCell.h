//
//  FCNPTextTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15/6/23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTTextView.h"

@interface FCNPTextTableViewCell : UITableViewCell

@property(nonatomic, assign)NSUInteger maxCharacterCount;

@property(readonly) NSString *text;

@property(readonly) RTTextView *txtView;


@end
