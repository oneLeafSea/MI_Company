//
//  ChatSettingTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-26.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatSettingTableViewController.h"
#import "RosterGroupSelectTableViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Utils.h"


@interface ChatSettingTableViewController () <RosterGroupSelectTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *signatrueLbl;

@end

@implementation ChatSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.avatarImageView.image = [USER.avatarMgr getAvatarImageByUid:self.rosterItem.uid];
    self.nameLbl.text = self.rosterItem.name;
    self.signatrueLbl.text = self.rosterItem.sign;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)delRosterItem:(id)sender {
    [APP_DELEGATE.user.rosterMgr delItemWithUid:self.rosterItem.uid];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 3) {
        RosterGroupSelectTableViewController *grpSelVc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterGroupSelect"];
        grpSelVc.delegate = self;
        [self.navigationController pushViewController:grpSelVc animated:YES];
    }
}

- (void) RosterGroupSelectTableViewController:(RosterGroupSelectTableViewController *) controller didSelectedGrp:(RosterGroup *)grp {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APP_DELEGATE.user.rosterMgr moveRosterItems:@[self.rosterItem] toGrpId:grp.gid key:APP_DELEGATE.user.key iv:APP_DELEGATE.user.iv url:APP_DELEGATE.user.imurl token:APP_DELEGATE.user.token completion:^(BOOL finished) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utils alertWithTip:finished ?@"移动成功！" : @"移动失败！"];
    }];
}

@end
