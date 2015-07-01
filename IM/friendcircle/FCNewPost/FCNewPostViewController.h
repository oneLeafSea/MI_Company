//
//  FCNewPostViewController.h
//  IM
//
//  Created by 郭志伟 on 15/6/23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCNewPostViewController : UIViewController



@end


@protocol FCNewPostViewControllerDelegate <NSObject>

- (void)FCNewPostViewController:(FCNewPostViewController *)controller newPostSuccess:(BOOL)success;

@end