//
//  WaitingViewController.m
//  dongrun_beijing
//
//  Created by guozw on 14/11/10.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "WaitingViewController.h"
#import "MBProgressHUD.h"

@interface WaitingViewController () {
    NSTimer *m_timer;
    NSUInteger m_dotCount;
}
@property MBProgressHUD *HUD;
@end

@implementation WaitingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    m_timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateTextLabel) userInfo:nil repeats:YES];
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTextLabel) userInfo:nil repeats:YES];
    [self.waintingActivityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
    [m_timer invalidate];
    [self.waintingActivityIndicator stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    self.HUD.labelText = @"正在登录";
//    self.HUD.labelColor = [UIColor blackColor];
//    self.HUD.detailsLabelText = @"点击取消";
//    self.HUD.color = [UIColor colorWithWhite:0 alpha:0.1];
//    [self.HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudWasCancelled)]];
}


- (void)hudWasCancelled {
    [self.HUD hide:YES];
}

-(void)singleTap:(UITapGestureRecognizer*)sender
{
    //do what you need.
}

               
- (void)updateTextLabel {
    m_dotCount++;
    m_dotCount %= 6;
    NSMutableString *txt = [[NSMutableString alloc] initWithString:@"请稍后，正在努力加载"];
    for (NSUInteger n = 0; n < m_dotCount; n++) {
        [txt appendString:@"."];
    }
    self.textLabel.text = txt;
}


@end
