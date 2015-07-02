//
//  WelcomeViewController.m
//  IM
//
//  Created by 郭志伟 on 15/7/2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WelcomeViewController.h"
#import <Masonry.h>

#import "LoginNotification.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "LoginViewController.h"

@interface WelcomeViewController()

@property(nonatomic, strong) UIImageView *imgView;

@end

@implementation WelcomeViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginFail object:nil];
}

- (void)viewDidLoad {
    _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lauch"]];
    [self.view addSubview:_imgView];
    
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSucess:) name:kNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginFail:) name:kNotificationLoginFail object:nil];
    
}

- (void)handleLoginSucess:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *mainController = [storyboard instantiateViewControllerWithIdentifier:@"mainController"];
        [APP_DELEGATE changeRootViewController:mainController];
    });
}

- (void)handleLoginFail:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{ //LoginViewController
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [APP_DELEGATE changeRootViewController:loginVC];
    });
}

@end
