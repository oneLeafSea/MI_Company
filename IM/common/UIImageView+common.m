//
//  UIImageView+common.m
//  IM
//
//  Created by 郭志伟 on 15-3-31.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "UIImageView+common.h"

#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+URL.h"
#import "NSUUID+StringUUID.h"
#import "Encrypt.h"
#import "NSDate+Common.h"
#import "AppDelegate.h"

@implementation UIImageView (common)

- (void)circle {
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
}


- (void)rt_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)image {
    SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
    NSString *qid = [NSString stringWithFormat:@"%@|%@", [NSUUID uuid], [[NSDate Now] formatWith:nil]];
    NSString *key = USER.key;
    NSString *iv = USER.iv;
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[qid dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [manager setValue:[USER.token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [manager setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [manager setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];
    [self sd_setImageWithURL:url placeholderImage:image];
}

@end
