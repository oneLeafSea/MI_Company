//
//  PwdChangeTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "PwdChangeTableViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "PwdMgr.h"
#import "MBProgressHUD.h"

@interface PwdChangeTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPwdTextField;

@property (weak, nonatomic) IBOutlet UITextField *theNewPwdTextField;

@property (weak, nonatomic) IBOutlet UITextField *confirmPwdTextField;

@end

@implementation PwdChangeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submit:(id)sender {
    NSString *oldPwd = self.oldPwdTextField.text;
    NSString *newPwd = self.theNewPwdTextField.text;
    NSString *confirmPwd = self.confirmPwdTextField.text;
    if (![oldPwd isEqualToString:USER.pwd]) {
        [Utils alertWithTip:@"原始密码不一致."];
        return;
    }
    if (newPwd.length == 0) {
        [Utils alertWithTip:@"新密码不能为空."];
        return;
    }
    if (confirmPwd.length == 0) {
        [Utils alertWithTip:@"确认密码不能为空."];
        return;
    }
    
    if (![self checkNewPwd:newPwd]) {
        [Utils alertWithTip:@"密码不符合规则."];
        return;
    }
    
    if (![newPwd isEqualToString:confirmPwd]) {
        [Utils alertWithTip:@"新密码和确认密码不一致."];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍候";
    [PwdMgr changePwdWithOldPwd:oldPwd newPwd:newPwd Token:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
        [hud hide:YES];
        [Utils alertWithTip:finished ? @"修改成功" : @"修改失败"];
    }];
    
}

- (BOOL)checkNewPwd:(NSString *)newPwd {
    if (newPwd.length < 6) {
        return NO;
    }
    return YES;
}


@end
