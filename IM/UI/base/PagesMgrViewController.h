//
//  PagesMgrViewController.h
//
//  Created by 郭志伟 on 14-11-2.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PagesMgrViewController;

@protocol SwipeContainerChildItem <NSObject>

@required

- (NSString *)nameForPageContainer:(PagesMgrViewController *)swipeContainer;

@optional

- (UIColor *)colorForPageContainer:(PagesMgrViewController *)swipeContainer;

@end

@interface PagesMgrViewController : UIViewController

-(instancetype)initWithViewControllers:(NSArray *)viewControllers currentIndex:(NSUInteger)currentIndex;
-(instancetype)initWithViewCurrentIndex:(NSUInteger)index viewControllers:(UIViewController *)firstViewController, ... NS_REQUIRES_NIL_TERMINATION;

-(instancetype)initWithViewControllers:(NSArray *)viewControllers;


@property(nonatomic, readonly)NSArray *pageContentViewControllers;
@property (readonly) NSUInteger currentIndex;
@property NSTimeInterval animationDuration;
@property BOOL swipeEnabled;
@property BOOL infiniteSwipe;
@property (nonatomic) NSString *navTitle;
@end
