//
//  JSQVideoChatMediaItem.m
//  IM
//
//  Created by 郭志伟 on 15/4/24.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQVideoChatMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "UIColor+JSQMessages.h"

@interface JSQVideoChatMediaItem()
@property (strong, nonatomic) UIView *cachedPlaceholderView;
@end

@implementation JSQVideoChatMediaItem

- (instancetype)initWithTip:(NSString *)tip {
    self = [super init];
    if (self) {
        _tip = [tip copy];
    }
    return self;
}

- (void)dealloc {
    _tip = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing {
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
}

- (UIView *)mediaView {
    CGSize sz = [self mediaViewDisplaySize];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sz.width, sz.height)];
    UIColor *lightGrayColor = [UIColor jsq_messageBubbleLightGrayColor];
    UIColor *greenColor = [UIColor jsq_messageBubbleGreenColor];
    view.backgroundColor = self.appliesMediaViewMaskAsOutgoing ? lightGrayColor : greenColor;
    UIImage *img = [UIImage imageNamed:self.appliesMediaViewMaskAsOutgoing ? @"chatmsg_tel_black" : @"chatmsg_tel_white"];
    UIImageView *imgView = [[UIImageView alloc]initWithImage:img];
    [view addSubview:imgView];
    CGRect imgRt = CGRectMake(view.frame.origin.x + 15, (CGRectGetHeight(view.frame) - img.size.height) / 2, img.size.width, img.size.height);
    imgView.frame = imgRt;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(imgRt) + 20, 10, CGRectGetWidth(view.frame) - CGRectGetWidth(imgRt), CGRectGetHeight(imgRt))];
    if (!self.appliesMediaViewMaskAsOutgoing) {
        label.textColor = [UIColor whiteColor];
    }
    label.text = _tip;
    [view addSubview:label];
    [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:view isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    return view;
}

- (CGSize)mediaViewDisplaySize
{
    CGSize labelSize = [self.tip sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]}];
    return CGSizeMake(labelSize.width + 48 + 20, 44.0f);
}

- (UIView *)mediaPlaceholderView
{
    if (self.cachedPlaceholderView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIView *view = [JSQMessagesMediaPlaceholderView viewWithActivityIndicator];
        view.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:view isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedPlaceholderView = view;
    }
    
    return self.cachedPlaceholderView;
}

@end
