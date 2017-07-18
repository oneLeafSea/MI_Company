//
//  RTFileMediaItem.m
//  IM
//
//  Created by 郭志伟 on 15/7/17.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTFileMediaItem.h"
#import "RTFileView.h"

#import "RTMessagesMediaViewBubbleImageMasker.h"

@interface RTFileMediaItem()
@property(nonatomic, strong) RTFileView *fileView;
@end

@implementation RTFileMediaItem


- (void)dealloc {
    _fileView = nil;
}

- (UIView *)mediaView
{
    RTFileView *fileView = [[RTFileView alloc] initWithFrame:CGRectMake(0, 0, 245, 80) isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    
    [RTMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:fileView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    fileView.fileNameLabel.text = @"许洋洋.avi";
    fileView.fileSzLabel.text = @"1.5M";
    fileView.statusLabel.text = @"未下载";
    self.fileView = fileView;
    return self.fileView;
}

- (CGSize)mediaViewDisplaySize
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGSizeMake(315.0f, 225.0f);
    }
    
    return CGSizeMake(245.0f, 80.0f);
}

- (UIView *)mediaPlaceholderView {
    return [super mediaPlaceholderView];
}

- (NSUInteger)mediaHash
{
    return self.hash & self.fileView.hash;
}

@end
