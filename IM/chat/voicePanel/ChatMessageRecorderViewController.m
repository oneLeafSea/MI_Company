//
//  ChatMessageRecorderViewController.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageRecorderViewController.h"

@interface ChatMessageRecorderViewController ()

@end

@implementation ChatMessageRecorderViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _recorderView = [[ChatMessageRecorderPanelView alloc] initWithFrame:CGRectZero];
        _recorderView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:_recorderView];
    
    NSDictionary *viewsDictory = NSDictionaryOfVariableBindings(_recorderView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_recorderView]|" options:0 metrics:nil views:viewsDictory]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_recorderView]|" options:0 metrics:nil views:viewsDictory]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
