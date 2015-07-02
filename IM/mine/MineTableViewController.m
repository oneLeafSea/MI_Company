//
//  MineTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-28.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "MineTableViewController.h"
#import "AppDelegate.h"
#import "session.h"
#import "LoginNotification.h"
#import "SignatureViewController.h"

@interface MineTableViewController ()<SignatureViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *signLbl;
@property (weak, nonatomic) IBOutlet UILabel *sexLbl;
@property (weak, nonatomic) IBOutlet UILabel *positionLbl;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UILabel *telLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;

@property(nonatomic, strong) NSString *sign;

@end

@implementation MineTableViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionDied object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginSuccess object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:USER.uid];
    self.sign = [USER.rosterMgr signature];
    self.signLbl.text = self.sign;
    NSString *sex = [USER.mineDetail.data objectForKey:@"sex"];
    self.sexLbl.text = [sex isEqual:@"1"] ? @"男" : @"女";
    self.positionLbl.text = [USER.mineDetail.data objectForKey:@"position"];
    self.addressLbl.text = [USER.mineDetail.data objectForKey:@"address"];
    self.statusLbl.text = USER.session.isConnected ? @"在线" : @"离线";
    self.telLbl.text = [USER.mineDetail.data objectForKey:@"cellphone"];
    self.emailLbl.text = [USER.mineDetail.data objectForKey:@"email"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionDied:) name:kSessionDied object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSuccess:) name:kNotificationLoginSuccess object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        SignatureViewController *svc = [[SignatureViewController alloc] init];
        svc.delegate = self;
        [self.navigationController pushViewController:svc animated:YES];
    }
}

- (void)handleSessionDied:(NSNotification *)notificaiton {
    dispatch_async(dispatch_get_main_queue(), ^{
       self.statusLbl.text = @"离线";
    });
}

- (void)handleLoginSuccess:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLbl.text = @"在线";
    });
}

- (void)signatureViewController:(SignatureViewController *)signVC DidChanged:(NSString *)txt {
    self.sign = [txt copy];
    self.signLbl.text = self.sign;
    [self.tableView reloadData];
}

@end
