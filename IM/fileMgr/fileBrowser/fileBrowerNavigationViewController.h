//
//  fileBrowerNavigationViewController.h
//  IM
//
//  Created by 郭志伟 on 15-2-18.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fileBrowserViewController.h"

@protocol fileBrowerNavigationViewControllerDelegate;

@interface fileBrowerNavigationViewController : UINavigationController <fileBrowserViewControllerDelegate>

@property(nonatomic) NSString *filePath;

@property(weak) id<fileBrowerNavigationViewControllerDelegate> fileBrowserDelegate;

@end

@protocol fileBrowerNavigationViewControllerDelegate <NSObject>

- (void)fileBrowerNavigationViewController:(fileBrowerNavigationViewController *)fileBrowser selectedPaths:(NSArray *)paths;

@end