//
//  GroupChatSettingForPrivateViewController.m
//  IM
//
//  Created by 郭志伟 on 15/9/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatSettingForPrivateViewController.h"

#import <MBProgressHUD.h>

#import "AppDelegate.h"
#import "LogLevel.h"
#import "GroupChatItemListViewController.h"
#import "MultiSelectViewController.h"
#import "UIColor+Theme.h"
#import "GroupChatItem.h"
#import "Utils.h"

@interface GroupChatSettingForPrivateViewController() <MultiSelectViewControllerDelegate>

@property(readonly) BOOL isCreator;

@end

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
    
    if (self.isCreator) {
        if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"chatmsg_invite"];
            cell.textLabel.text = @"邀请";
        }
        
        if (indexPath.row == 2) {
            cell.imageView.image = [UIImage imageNamed:@"chatmsg_del"];
            cell.textLabel.text = @"解散";
        }
    } else {
        if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"chatmsg_quit"];
            cell.textLabel.text = @"退出";
        }
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isCreator) {
        return 3;
    }
    return 2;
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
    
    if (self.isCreator) {
        if (indexPath.row == 1) {
            [self invitePeer];
            return;
        }
        
        if (indexPath.row == 2) {
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
                    DDLogInfo(@"解散失败！");
                }
            }];
        }
    } else {
        if (indexPath.row == 1) {
            [USER.groupChatMgr quitGrpWithGid:self.grp.gid session:USER.session completion:^(BOOL finished) {
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
                    DDLogInfo(@"退出失败！");
                }
            }];
        }

    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}


- (BOOL)isCreator {
    return [self.grp.creatorId isEqualToString:USER.uid];
}


- (void)invitePeer {
    [MBProgressHUD showHUDAddedTo:self.tableView.window animated:YES];
    [USER.groupChatMgr getGroupPeerListWithGid:self.grp.gid token:USER.token signatrue:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
        
        if (finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.tableView.window animated:YES];
                MultiSelectViewController *vc = [[MultiSelectViewController alloc]init];
                NSArray *osItems = USER.osMgr.items;
                NSMutableArray *multiItems = [[NSMutableArray alloc] init];
                [osItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    OsItem *osItem = obj;
                    MultiSelectItem *item = [[MultiSelectItem alloc] init];
                    item.uid = osItem.uid;
                    item.name = osItem.name;
                    if ([self hasOsItem:osItem]) {
                        return;
                    }
                    item.imageURL = [NSURL fileURLWithPath:[USER.avatarMgr.avatarPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", osItem.uid]]];
                    [multiItems addObject:item];
                }];
                vc.items = multiItems;
                vc.delegate = self;
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
                navController.navigationBar.barTintColor = [UIColor themeColor];
                navController.navigationBar.tintColor = [UIColor whiteColor];
                NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor],NSForegroundColorAttributeName,
                                                           nil];
                navController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;
                [self.navigationController presentViewController:navController animated:YES completion:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.tableView.window animated:YES];
                [Utils alertWithTip:@"获取群成员列表失败"];
            });
        }
    }];
    
    

}

- (BOOL)hasOsItem:(OsItem *)item {
    __block BOOL ret = NO;
    [self.grp.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GroupChatItem *gItem = obj;
        if ([gItem.uid isEqualToString:item.uid]) {
            ret = YES;
            *stop = YES;
        }
    }];
    return ret;
}

- (void)MultiSelectViewController:(MultiSelectViewController *)controller didConfirmWithSelectedItems:(NSArray *)selectedItems {
    NSMutableArray *ma = [[NSMutableArray alloc] init];
    [selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MultiSelectItem *item = obj;
        [ma addObject:item.uid];
    }];
    [MBProgressHUD showHUDAddedTo:self.tableView.window animated:YES];
    [USER.groupChatMgr invitePeers:ma toGid:self.grp.gid gname:self.grp.gname session:USER.session completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.tableView.window animated:YES];
            if (finished) {
                [Utils alertWithTip:@"发送邀请成功！"];
            } else {
                [Utils alertWithTip:@"邀请失败！"];
            }
        });
    }];
}

@end
