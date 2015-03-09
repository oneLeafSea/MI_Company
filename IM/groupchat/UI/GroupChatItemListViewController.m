//
//  GroupChatItemListViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatItemListViewController.h"
#import "GroupChatItemListTableViewCell.h"
#import "AppDelegate.h"
#import "GroupChatItem.h"
#import "AvatarNotifications.h"

@interface GroupChatItemListViewController () {
    
    __weak IBOutlet UIActivityIndicatorView *m_indicator;
    __weak IBOutlet UITableView *m_tableView;
}

@end

@implementation GroupChatItemListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    m_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.grp.items.count == 0) {
        m_tableView.hidden = YES;
        [m_indicator startAnimating];
        [USER.groupChatMgr getGroupPeerListWithGid:self.grp.gid token:USER.token signatrue:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
            if (finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [m_tableView reloadData];
                    m_tableView.hidden = NO;
                });
            }
        }];
    } else {
        m_tableView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAvatarNotification:) name:kAvatarNotificationDownloaded object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAvatarNotificationDownloaded object:nil];
}



#pragma UITableView delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.grp.items.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChatItemListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupChatItemListCell" forIndexPath:indexPath];
    GroupChatItem *item = [self.grp.items objectAtIndex:indexPath.row];
    cell.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:item.uid];
    cell.nameLbl.text = item.name;
    if (item.rank == GroupChatItemRankAdmin) {
        cell.rankLbl.text = @"🐷";
    } else {
        cell.rankLbl.text = @"成员";
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)handleAvatarNotification:(NSNotification *)notification {
    [m_tableView reloadData];
}


@end
