//
//  GroupChatNotificaitonViewController.m
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatNotificaitonViewController.h"
#import "GroupChatNotificaitonCell.h"
#import "AppDelegate.h"
#import "GroupChatNoitificaiontCellModel.h"
#import <MBProgressHUD.h>
#import "UIView+Toast.h"
#import "Utils.h"

@interface GroupChatNotificaitonViewController()<GroupChatNotificaitonCellDelegate>

@property(nonatomic, strong) NSArray *cellModels;

@end

@implementation GroupChatNotificaitonViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(rightBartItemTapped:)];
    
    self.cellModels = [USER.groupChatMgr getNotificationCellModels];
    
    self.navigationItem.title = @"群消息";
    [self.tableView registerClass:[GroupChatNotificaitonCell class] forCellReuseIdentifier:@"GroupChatNotificaitonCell"];
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChatNotificaitonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupChatNotificaitonCell" forIndexPath:indexPath];
    GroupChatNoitificaiontCellModel *cellModel = [self.cellModels objectAtIndex:indexPath.row];
    cell.grpNamelabel.text = cellModel.gname;
    cell.contentLabel.text = cellModel.content;
    cell.tag = indexPath.row;
    cell.delegate =self;
    if (cellModel.processed) {
        cell.acceptButton.hidden = YES;
    } else {
        cell.acceptButton.hidden = NO;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellModels.count;
}


- (void)GroupChatNotificaitonCellAcceptBtnDidTapped:(GroupChatNotificaitonCell *)cell {
    NSInteger index = cell.tag;
    [MBProgressHUD showHUDAddedTo:self.tableView.window animated:YES];
    GroupChatNoitificaiontCellModel *model = [self.cellModels objectAtIndex:index];
    [USER.groupChatMgr acceptGrpWithGid:model.gid msgid:model.msgid session:USER.session completion:^(BOOL finished) {
        if (finished) {
            [USER.groupChatMgr getGroupListWithToken:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
                if (finished) {
                    [USER.groupChatMgr updateNotificationProcessedWithGid:model.gid];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.tableView.window animated:YES];
                        [Utils alertWithTip:@"已经加入该群。"];
                        self.cellModels = [USER.groupChatMgr getNotificationCellModels];
                        [self.tableView reloadData];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.tableView.window animated:YES];
                        [Utils alertWithTip:@"更新群组失败。"];
                    });
                }
                
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.tableView.window animated:YES];
                [Utils alertWithTip:@"群已经被解散。"];
            });
        }
        
    }];
}

- (void)rightBartItemTapped:(id)sender {
    [USER.groupChatMgr clearNotificationDb];
    self.cellModels = [USER.groupChatMgr getNotificationCellModels];
    [self.tableView reloadData];
}

@end
