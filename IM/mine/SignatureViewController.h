//
//  SignatureViewController.h
//  IM
//
//  Created by 郭志伟 on 15/7/2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignatureViewControllerDelegate;

@interface SignatureViewController : UIViewController

@property(weak)id<SignatureViewControllerDelegate> delegate;

@end


@protocol SignatureViewControllerDelegate <NSObject>

- (void)signatureViewController:(SignatureViewController *)signVC DidChanged:(NSString *)txt;

@end