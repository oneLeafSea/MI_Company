//
//  fileBrowserViewController.h
//  IM
//
//  Created by 郭志伟 on 15-2-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol fileBrowserViewControllerDelegate;

@interface fileBrowserViewController : UIViewController

@property (nonatomic) NSString *filesPath;

@property(weak) id<fileBrowserViewControllerDelegate> delegate;

@end

@protocol fileBrowserViewControllerDelegate <NSObject>

- (void)fileBrowserViewController:(fileBrowserViewController *)browserVc withSelectedPaths:(NSArray *)paths;

@end
