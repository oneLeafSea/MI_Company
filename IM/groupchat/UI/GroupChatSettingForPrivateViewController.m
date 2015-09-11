//
//  GroupChatSettingForPrivateViewController.m
//  IM
//
//  Created by 郭志伟 on 15/9/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatSettingForPrivateViewController.h"
#import "AppDelegate.h"
#import "LogLevel.h"
#import "GroupChatItemListViewController.h"

@implementation GroupChatSettingForPrivateViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"群设置";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gcsfpCell"];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"chatmsg_ml"];
        cell.textLabel.text = @"成员列表";
    }
    
    if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"chatmsg_invite"];
        cell.textLabel.text = @"邀请";
    }
    
    if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"chatmsg_quit"];
        cell.textLabel.text = @"退出";
    }
    
    if (indexPath.row == 3) {
        cell.imageView.image = [UIImage imageNamed:@"chatmsg_del"];
        cell.textLabel.text = @"解散";
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GroupChatItemListViewController *vc = [sb instantiateViewControllerWithIdentifier:@"GroupChatItemListViewController"];
        vc.grp = self.grp;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (indexPath.row == 3) {
        [USER.groupChatMgr delGrpWithGid:self.grp.gid session:USER.session completion:^(BOOL finished) {
            if (finished) {
                [USER.groupChatMgr getGroupListWithToken:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
                    if (finished) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kGroupChatListChangedNotification object:self.grp.gid];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        });
                    }
                }];
                
            } else {
                DDLogInfo(@"删除失败！");
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}





@end
