//
//  LoginViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-26.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginProcedures.h"
#import "MBProgressHUD.h"
#import "utils.h"
#import "Appdelegate.h"
#import "IMConf.h"

@interface LoginViewController ()<LoginProceduresDelegate> {
    LoginProcedures *m_loginProc;
}

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet UISwitch *lanSwitch;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _avatarImgView.layer.cornerRadius = 10.0;
    _avatarImgView.layer.masksToBounds = YES;
    _loginBtn.layer.cornerRadius = 5.0;
    _loginBtn.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBg:)];
    avatarTap.numberOfTapsRequired = 1;
    [_bgImgView addGestureRecognizer:avatarTap];
    BOOL isLan = [IMConf isLAN];
    self.lanSwitch.on = isLan;
   
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tapBg:(UIGestureRecognizer *)gestureRecognizer {
    [self.userTextField resignFirstResponder];
    [self.pwdTextField resignFirstResponder];
    
}
- (IBAction)switchTapped:(UISwitch *)sender {
    if (sender.on) {
        [IMConf setIPAndPort:@"10.22.1.47" port:8000];
        [IMConf setLAN:YES];
        
    } else {
        [IMConf setIPAndPort:@"218.4.226.210" port:48009];
        [IMConf setLAN:NO];
    }
}

- (IBAction)login:(id)sender {
    [self.userTextField resignFirstResponder];
    [self.pwdTextField resignFirstResponder];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍候";
    m_loginProc = [[LoginProcedures alloc] init];
    m_loginProc.delegate = self;
    if (![m_loginProc loginWithUserId:self.userTextField.text pwd:self.pwdTextField.text timeout:30]) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utils alertWithTip:@"请打开网络！"];
        m_loginProc = nil;

    }

}

- (void)loginProceduresWaitingSvrTime:(LoginProcedures *)proc {
    
}

- (void)loginProcedures:(LoginProcedures *)proc login:(BOOL)suc error:(NSString *)error {
    if (!suc) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utils alertWithTip:error];
        m_loginProc = nil;
    }
}

- (void)loginProcedures:(LoginProcedures *)proc recvPush:(BOOL)suc error:(NSString *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (suc) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *mainController = [storyboard instantiateViewControllerWithIdentifier:@"mainController"];
        [UIView beginAnimations:nil context:NULL];
        [self presentViewController:mainController animated:YES completion:nil];
        
        [UIView setAnimationDuration:0.8];
        [UIView setAnimationBeginsFromCurrentState:YES];
        //    [UIView setAnimationTransition:UIViewAnimationCurveEaseInOut forView:self.view cache:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView commitAnimations];
    } else {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utils alertWithTip:error];
    }
    m_loginProc = nil;
    
}

- (void)loginProcedures:(LoginProcedures *)proc getRoster:(BOOL)suc {
    if (!suc) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utils alertWithTip:@"获取名册失败！"];
        m_loginProc = nil;
    }
}

- (void)loginProceduresConnectFail:(LoginProcedures *)proc timeout:(BOOL)timeout error:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [Utils alertWithTip:timeout ?@"服务器已断开！":@"连接服务器错误！"];
    m_loginProc = nil;
}


@end
