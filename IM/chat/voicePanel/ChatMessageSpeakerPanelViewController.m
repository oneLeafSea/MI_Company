//
//  ChatMessageSpeakerPanelViewController.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageSpeakerPanelViewController.h"


@interface ChatMessageSpeakerPanelViewController () {
    
}

@end

@implementation ChatMessageSpeakerPanelViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _speakerPanelView = [[ChatMessageSpeakerPanelView alloc] initWithFrame:CGRectZero];
        _speakerPanelView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:_speakerPanelView];
     NSDictionary *viewsDictory = NSDictionaryOfVariableBindings(_speakerPanelView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_speakerPanelView]|" options:0 metrics:nil views:viewsDictory]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_speakerPanelView]|" options:0 metrics:nil views:viewsDictory]];
}


@end
