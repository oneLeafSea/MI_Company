//
//  GroupChatNotificaitonCell.m
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatNotificaitonCell.h"

@interface GroupChatNotificaitonCell()


@end

@implementation GroupChatNotificaitonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configureCell];
    }
    return self;
}

- (void)configureCell {
    self.avatarImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"groupchat_private"]];
    [self.contentView addSubview:self.avatarImgView];
    self.grpNamelabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.grpNamelabel];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.contentLabel];
    
    self.acceptButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.acceptButton setTitle:@"同意" forState:UIControlStateNormal];
    [self.contentView addSubview:self.acceptButton];
}

@end
