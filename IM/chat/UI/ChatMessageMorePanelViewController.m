//
//  ChatMessageMorePanelViewController.m
//  IM
//
//  Created by 郭志伟 on 15-2-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageMorePanelViewController.h"
#import "ChatMessageMorePanelItemMode.h"
#import "ChatMessageMorePanelPageCollectionViewController.h"

static NSUInteger kPanelItemCountPerPage = 8;

@interface ChatMessageMorePanelViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    UIPageViewController *m_pageViewController;
    NSMutableArray  *m_collectionViewControllers;
    NSMutableArray *m_panelItems;
}

@end

@implementation ChatMessageMorePanelViewController

- (instancetype) initWithPanelItems:(NSArray *)panelItems {
    if (self = [super init]) {
        if (![self setup:panelItems]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup:(NSArray *) panelItems {
    m_collectionViewControllers = [[NSMutableArray alloc] init];
    kPanelItemCountPerPage = [ChatMessageMorePanelPageCollectionViewController getPanelItemCount];
    NSUInteger pageCount = panelItems.count / kPanelItemCountPerPage;
    NSUInteger left = panelItems.count % kPanelItemCountPerPage;
    if (left > 0) {
        pageCount++;
    }
    for (NSUInteger n = 0; n < pageCount; n++) {
        NSUInteger len = panelItems.count - n * kPanelItemCountPerPage;
        if (len > kPanelItemCountPerPage) {
            len = kPanelItemCountPerPage;
        }
        NSArray *items = [panelItems subarrayWithRange:NSMakeRange(n * kPanelItemCountPerPage, len)];
        ChatMessageMorePanelPageCollectionViewController *collectionViewController = [[ChatMessageMorePanelPageCollectionViewController alloc] initWithPanelItems:items];
        [m_collectionViewControllers addObject:collectionViewController];
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    m_pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    m_pageViewController.delegate = self;
    m_pageViewController.dataSource = self;
    [self addChildViewController:m_pageViewController];
    [self.view addSubview:m_pageViewController.view];
    [self setPageControllerConstraints];
    m_pageViewController.view.backgroundColor = [UIColor whiteColor];
    ChatMessageMorePanelPageCollectionViewController *controller = [m_collectionViewControllers objectAtIndex:0];
    [m_pageViewController setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self setColectionViewSize];
}

- (void)setColectionViewSize {
    for (ChatMessageMorePanelPageCollectionViewController *controller in m_collectionViewControllers) {
        controller.collectionView.frame = m_pageViewController.view.frame;
    }
}

- (void)setPageControllerConstraints {
    UIView *view = m_pageViewController.view;
    NSDictionary *viewsDictionary =
    NSDictionaryOfVariableBindings(view);
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:viewsDictionary]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [m_collectionViewControllers indexOfObject:viewController];
    ChatMessageMorePanelPageCollectionViewController *controller = nil;
    index--;
    if (index > 0) {
        controller = [m_collectionViewControllers objectAtIndex:index];
    } else {
        controller = nil;
    }
    return controller;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = [m_collectionViewControllers indexOfObject:viewController];
    index++;
    ChatMessageMorePanelPageCollectionViewController *controller = nil;
    if (index < m_collectionViewControllers.count) {
        controller = [m_collectionViewControllers objectAtIndex:index];
    } else {
        controller = nil;
    }
    return controller;
}

//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//    return m_collectionViewControllers.count;
//}
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
//    return 0;
//}


@end
