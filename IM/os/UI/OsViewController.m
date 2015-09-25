//
//  OsViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsViewController.h"
#import "AppDelegate.h"
#import "OsNavigationTableViewCell.h"
#import "AppDelegate.h"
#import "LogLevel.h"
#import "OsOrgTableViewCell.h"
#import "OsOrgItemTableViewCell.h"
#import "OsItem.h"
#import "RosterItemReqMsgTableViewController.h"
#import "RTChatViewController.h"
#import "DetailTableViewController.h"
#import <MJRefresh.h>

@interface OsViewController () <OsNavigationTableViewCellDelegate, OsOrgItemTableViewCellDelegate> {
    
    __weak IBOutlet UIActivityIndicatorView *m_indicatorView;
    __weak IBOutlet UITableView *m_tableView;
    NSMutableArray         *m_navigationCellData;
    NSArray                *m_curSubOrgs;
    NSArray                *m_curOrgItems;
}

@end

@implementation OsViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    m_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [m_tableView registerClass:[OsNavigationTableViewCell class] forCellReuseIdentifier:@"OsNavigationTableViewCell"];

    [m_indicatorView startAnimating];
    
    m_tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [USER.osMgr syncOrgStructWithWithToken:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
            [m_tableView.header endRefreshing];
            if (finished) {
                OsOrg *rootOrg = [USER.osMgr rootOrg];
                if (!rootOrg) {
                    DDLogError(@"ERROR: get root org.");
                    return;
                }
                m_navigationCellData = [[NSMutableArray alloc] initWithArray:@[rootOrg]];
                [self getData];
                [m_tableView reloadData];
                
            } else {
                [m_indicatorView stopAnimating];
            }
        }];
    }];
    OsOrg *rootOrg = [USER.osMgr rootOrg];
    if (!rootOrg) {
        DDLogError(@"ERROR: get root org.");
        return;
    }
    m_navigationCellData = [[NSMutableArray alloc] initWithArray:@[rootOrg]];
    [self getData];
    [m_tableView reloadData];

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma UITableView delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (m_navigationCellData.count == 0) {
        return 0;
    }
    NSInteger count = 0;
    if (m_curSubOrgs.count == 0 || m_curOrgItems.count == 0) {
         count = 1 + m_curOrgItems.count + m_curSubOrgs.count;
        return count;
    }
    count = 1 + m_curOrgItems.count + m_curSubOrgs.count + 1;
    return count;
}

- (void)getData {
    OsOrg *curOrg = [m_navigationCellData lastObject];
    m_curSubOrgs = [USER.osMgr getSubOrgs:curOrg.jgbm];
    m_curOrgItems = [USER.osMgr getOrgItemsByJgbm:curOrg.jgbm];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 60;
    }
    
    if ([self hasSeporator]) {
        if (indexPath.row == m_curSubOrgs.count + 1) {
            return 20;
        }
    }
    if (indexPath.row < m_curSubOrgs.count + 1) {
        return 44;
    }
    
    return 60;
}
    


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        OsNavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OsNavigationTableViewCell" forIndexPath:indexPath];
        cell.delgate = self;
        [cell setCollectionData:m_navigationCellData];
        return cell;
    }
    
    BOOL hasSeporator = [self hasSeporator];
    if (hasSeporator) {
        if (indexPath.row == m_curSubOrgs.count + 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"separatorCell" forIndexPath:indexPath];
            return cell;
        }
    }
    
    if (indexPath.row < m_curSubOrgs.count + 1) {
        NSInteger index = indexPath.row - 1;
        OsOrg *org = [m_curSubOrgs objectAtIndex:index];
        OsOrgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OsOrgCell" forIndexPath:indexPath];
        cell.textLabel.text = org.jgmc;
        return cell;
    }

    if (indexPath.row > hasSeporator ? m_curSubOrgs.count + 1 : m_curSubOrgs.count) {
        OsOrgItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OsOrgItemCell" forIndexPath:indexPath];
        NSInteger index = hasSeporator ? indexPath.row - 1 - 1 - m_curSubOrgs.count : indexPath.row - 1 - m_curSubOrgs.count;
        OsItem *item = [m_curOrgItems objectAtIndex:index];
        cell.avatarImagView.image = [USER.avatarMgr getAvatarImageByUid:item.uid];
        cell.nameLbl.text = item.name;
        cell.item = item;
        cell.delegate = self;
        if ([USER.rosterMgr exsitsItemByUid:item.uid] || [USER.uid isEqualToString:item.uid]) {
            cell.addbtn.hidden = YES;
        } else {
            cell.addbtn.hidden = NO;
        }
        return cell;
    }
    return nil;
}

- (BOOL) hasSeporator {
    BOOL hasSeporator = YES;
    if (m_curOrgItems.count == 0 || m_curSubOrgs.count == 0) {
        hasSeporator = NO;
    }
    return hasSeporator;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < m_curSubOrgs.count + 1) {
        NSInteger index = indexPath.row - 1;
        OsOrg *org = [m_curSubOrgs objectAtIndex:index];
        [m_navigationCellData addObject:org];
        [self getData];
        [m_tableView reloadData];
        return;
    }
    
    BOOL hasSeporator = [self hasSeporator];
    if (indexPath.row > hasSeporator ? m_curSubOrgs.count + 1 : m_curSubOrgs.count) {
        NSInteger index = hasSeporator ? indexPath.row - 1 - 1 - m_curSubOrgs.count : indexPath.row - 1 - m_curSubOrgs.count;
        OsItem *item = [m_curOrgItems objectAtIndex:index];
        if ([item.uid isEqualToString:USER.uid]) {
            return;
        }
        RTChatViewController *vc = [[RTChatViewController alloc] init];
        vc.talkingId = item.uid;
        vc.talkingname = item.name;
        vc.chatMsgType = ChatMessageTypeNormal;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - <OsNavigationTableViewCell>
- (void)OsNavigationTableViewCell:(OsNavigationTableViewCell *)cell tappedAtIndex:(NSInteger)index {
    m_navigationCellData = [[NSMutableArray alloc] initWithArray:[m_navigationCellData subarrayWithRange:NSMakeRange(0, index + 1)]];
    [self getData];
    [m_tableView reloadData];
}


#pragma mark - <OsOrgItemTableViewCellDelegate>
- (void)OsOrgItemTableViewCell:(OsOrgItemTableViewCell *)cell orgItem:(OsItem *)item {
    RosterItemReqMsgTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RosterItemReqMsgTableViewController"];
    vc.itemInfo = @{@"uname":item.uid, @"name":item.name};
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)OsOrgItemTableViewCell:(OsOrgItemTableViewCell *)cell avatarDidSelectWithItem:(OsItem *)item {
    DetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTableViewController"];
    vc.uid = item.uid;
    vc.name = item.name;
    vc.navigationItem.title = item.name;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
