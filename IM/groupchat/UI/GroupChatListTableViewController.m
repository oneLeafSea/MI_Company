//
//  GroupChatListTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatListTableViewController.h"
#import "AppDelegate.h"
#import "GroupChatListTableViewCell.h"
#import "GroupChat.h"
#import "RTChatViewController.h"
#import "MultiSelectViewController.h"
#import "UIColor+Theme.h"
#import "UIAlertController+Blocks.h"
#import "Utils.h"
#import "LogLevel.h"
#import "MBProgressHUD.h"
#import "UIView+toast.h"

@interface GroupChatListTableViewController () <MultiSelectViewControllerDelegate, UIAlertViewDelegate>
@property(nonatomic, strong) NSArray *selectedArray;

@end

@implementation GroupChatListTableViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = USER.groupChatMgr.grpChatList.grpChatList.count;
    return count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupChatListCell" forIndexPath:indexPath];

    NSArray *grpChatList = USER.groupChatMgr.grpChatList.grpChatList;
    GroupChat *grp = [grpChatList objectAtIndex:indexPath.row];
    cell.grpName.text = grp.gname;
    if (grp.type == GropuChatypePrivate) {
        cell.logoImgView.image = [UIImage imageNamed:@"groupchat_private"];
    } else if (grp.type == GropuChatypePublic) {
        cell.logoImgView.image = [UIImage imageNamed:@"groupchat_logo"];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RTChatViewController *vc = [[RTChatViewController alloc] init];
    NSArray *grpChatList = USER.groupChatMgr.grpChatList.grpChatList;
    GroupChat *grp = [grpChatList objectAtIndex:indexPath.row];
    vc.talkingId = grp.gid;
    vc.talkingname = grp.gname;
    vc.chatMsgType = ChatMessageTypeGroupChat;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)rightBarItemTapped:(id)sender {
    MultiSelectViewController *vc = [[MultiSelectViewController alloc]init];
//    NSArray *rosterItems = [USER.rosterMgr allRosterItems];
    NSArray *osItems = USER.osMgr.items;
    NSMutableArray *multiItems = [[NSMutableArray alloc] init];
    [osItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        OsItem *osItem = obj;
        MultiSelectItem *item = [[MultiSelectItem alloc] init];
        item.uid = osItem.uid;
        item.name = osItem.name;
        if ([item.uid isEqualToString:USER.uid]) {
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
    [self.navigationController presentViewController:navController animated:YES completion:nil];;
}

- (void)MultiSelectViewController:(MultiSelectViewController *)controller didConfirmWithSelectedItems:(NSArray *)selectedItems {
    if (selectedItems.count == 0) {
        return;
    }
    NSMutableArray *ma = [[NSMutableArray alloc] init];
    [selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MultiSelectItem *item = obj;
        [ma addObject:item.uid];
    }];
    self.selectedArray = ma;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"群组名称"
                                                    message:@"请填写群组名称"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *txtField = [alertView textFieldAtIndex:0];
        NSString *gname = [txtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (gname.length == 0) {
            [Utils alertWithTip:@"创建失败，群组名称不能为空！"];
            return;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        [USER.groupChatMgr createTempGroupWithGName:gname fname:USER.name token:USER.token signatrue:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(NSString *gid, BOOL finished) {
            
            if (finished) {
                [USER.groupChatMgr getGroupListWithToken:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
                    if (finished) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                        
                        [USER.groupChatMgr invitePeers:self.selectedArray toGid:gid gname:gname session:USER.session completion:^(BOOL finished) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBProgressHUD hideHUDForView:self.view.window animated:YES];
                                if (finished) {
                                    [Utils alertWithTip:@"创建并且发出邀请成功！"];
                                } else {
                                    [Utils alertWithTip:@"邀请失败！"];
                                }
                            });
                        }];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view.window animated:YES];
                            [Utils alertWithTip:@"更新群列表错误！"];
                        });
                        DDLogInfo(@"创建失败！");
                    }
                }];
                DDLogInfo(@"创建群成功！");
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view.window animated:YES];
                    [Utils alertWithTip:@"创建群组失败！"];
                });
                DDLogInfo(@"创建失败！");
            }
        }];
        
    }
}

@end
