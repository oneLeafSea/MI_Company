//
//  ModuleDefaultViewController.m
//  dongrun_beijing
//
//  Created by guozw on 14/11/6.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ModuleDefaultViewController.h"
#import "ModuleDefaultPageViewController.h"

@implementation PagesMgrViewController (ModuleDefaultViewController)

- (instancetype)initWithDefaultModule:(ModuleDefault *)md {
    NSArray *pageViewControllers = [PagesMgrViewController pageViewControllers:md];
    self = [[PagesMgrViewController alloc] initWithViewControllers:pageViewControllers];
    self.swipeEnabled = md.pages.swipeEnabled;
    self.infiniteSwipe = md.pages.infiniteSwipe;
//    self.title = md.name;
    self.navTitle = md.name;
    return self;
}


+ (NSArray *)pageViewControllers:(ModuleDefault *)md {
    if (!md.pages) {
        return nil;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (Page *p in md.pages.pageArray) {
        ModuleDefaultPageViewController *pvc = [[ModuleDefaultPageViewController alloc] initWithPage:p];
        [arr addObject:pvc];
    }
    return arr;
}

@end
