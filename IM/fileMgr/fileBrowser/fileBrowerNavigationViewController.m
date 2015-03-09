//
//  fileBrowerNavigationViewController.m
//  IM
//
//  Created by 郭志伟 on 15-2-18.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "fileBrowerNavigationViewController.h"


@interface fileBrowerNavigationViewController () 

@end

@implementation fileBrowerNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)fileBrowserViewController:(fileBrowserViewController *)browserVc withSelectedPaths:(NSArray *)paths {
    if ([self.fileBrowserDelegate respondsToSelector:@selector(fileBrowerNavigationViewController:selectedPaths:)]) {
        [self.fileBrowserDelegate fileBrowerNavigationViewController:self selectedPaths:paths];
    }
}

@end
