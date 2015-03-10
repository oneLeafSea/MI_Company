//
//  RosterViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterViewController.h"
#import "RosterItermTableViewCell.h"
#import "RosterSectionHeaderView.h"
#import "LogLevel.h"
#import "AppDelegate.h"
#import "RosterGroup.h"
#import "RosterSection.h"
#import "RosterItemSearchTableViewController.h"
#import "RosterNotification.h"
#import "ChatViewController.h"
#import "ReloginTipView.h"
#import "LoginNotification.h"
#import "GroupChatListTableViewController.h"
#import "OsViewController.h"
#import "PresenceNotification.h"
#import "PresenceMsg.h"
//organization structure
@interface RosterViewController () <RosterSectionHeaderViewDelegate, UITableViewDelegate> {
    NSMutableArray *m_Sections;
    NSArray *m_groups;
    __weak IBOutlet UITableView *m_table;
}

@end

@implementation RosterViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRosterChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPresenceNotification object:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    m_table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self initData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterGrpChanged) name:kRosterChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePresenceNotification:) name:kPresenceNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloging:) name:kNotificationReloging object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloginSucess:) name:kNotificationReloginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloginFail:) name:kNotificationReloginFail object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloging object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloginFail object:nil];
    
}

- (void)initData {
    m_groups = [APP_DELEGATE.user.rosterMgr grouplist];
    m_Sections = [[NSMutableArray alloc] init];
    for (int n = 0; n < m_groups.count; n++) {
        RosterSection *section = [[RosterSection alloc] init];
        [m_Sections addObject:section];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return m_groups.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    
    NSInteger index = section -1;
    RosterSection *sect = [m_Sections objectAtIndex:index];
    if (!sect.expand) {
        return 0;
    }
    RosterGroup *g = [m_groups objectAtIndex:(NSUInteger)index];
    return g.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerVw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6000, 0.5f)];
    footerVw.backgroundColor = [UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0f];
    return footerVw;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    NSInteger index = section - 1;
    RosterSectionHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"RosterSectionHeaderView" owner:self options:nil] objectAtIndex:0];
    RosterGroup *g = [m_groups objectAtIndex:(NSUInteger)index];
    headerView.groupNameLabel.text = g.name;
    headerView.tag = section;
    RosterSection *sect =[m_Sections objectAtIndex:index];
    headerView.arrowImagView.image = [UIImage imageNamed:sect.expand ? @"arrow_down":@"arrow_right"];
    headerView.delegate = self;
    NSInteger onlineCount = [self getOnlineFromGroup:g];
    headerView.statusLabel.text = [NSString stringWithFormat:@"%ld/%lu", (long)onlineCount, (unsigned long)g.items.count];
    return headerView;
}

- (NSInteger)getOnlineFromGroup:(RosterGroup *)g {
    __block NSInteger count = 0;
    [g.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RosterItem *item = obj;
        PresenceMsg *msg = [USER.presenceMgr getPresenceMsgByUid:item.uid];
        if (msg && [msg.show isEqualToString:kPresenceTypeOnline]) {
            count++;
        }
    }];
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        static NSString *grpChatCellId = @"groupChatCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:grpChatCellId forIndexPath:indexPath];
        return cell;
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        static NSString *osCellId = @"organizationStructureCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:osCellId forIndexPath:indexPath];
        return cell;
    }
    
    NSInteger index = indexPath.section - 1;
    static NSString *cellId = @"rosterItermCell";
    RosterItermTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    RosterGroup *g = [m_groups objectAtIndex:index];
    RosterItem* item = [g.items objectAtIndex:indexPath.row];
    cell.nameLabel.text = item.name;
    PresenceMsg *msg = [USER.presenceMgr getPresenceMsgByUid:item.uid];
    if (msg && [msg.show isEqualToString:kPresenceTypeOnline]) {
        cell.signatureLabel.text = [NSString stringWithFormat:@"[在线]%@", item.sign];
    } else {
        cell.signatureLabel.text = [NSString stringWithFormat:@"[离线]%@", item.sign];
    }
    
    cell.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:item.uid];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        GroupChatListTableViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"GroupChatListTableViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        OsViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"OsViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    NSInteger index = indexPath.section - 1;
    ChatViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    RosterGroup *g = [m_groups objectAtIndex:index];
    RosterItem* item = [g.items objectAtIndex:indexPath.row];
    vc.talkingId = item.uid;
    vc.talkingname = item.name;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)add:(id)sender {
    RosterItemSearchTableViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterItemSearchResultTableViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}

#pragma mark - RosterSectionHeaderViewDelegate
- (void)RosterSectionHeaderViewTapped:(RosterSectionHeaderView *)headerView tag:(NSInteger) tag {
    RosterSection *sect = [m_Sections objectAtIndex:tag - 1];
    sect.expand = !sect.expand;
    [m_table reloadSections:[NSIndexSet indexSetWithIndex:tag] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)RosterSectionHeaderViewGrpMgrTapped:(RosterSectionHeaderView *)headerView tag:(NSInteger)tag {
    [self performSegueWithIdentifier:@"roster2grpmgr" sender:self];
}

#pragma mark - Roster Notification handler
- (void) handleRosterGrpChanged {
    m_groups = [APP_DELEGATE.user.rosterMgr grouplist];
    [self initData];
    [m_table reloadData];
}


#pragma mark - handle Reloging tip view
- (void) handleReloging:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        ReloginTipView *reloginTipView = [[[NSBundle mainBundle] loadNibNamed:@"ReloginTipView" owner:self options:nil] objectAtIndex:0];
        reloginTipView.connErrLbl.hidden = YES;
        [reloginTipView.indicatorView startAnimating];
        self.navigationItem.titleView = reloginTipView;
    });
}

- (void) handleReloginSucess:(NSNotification *)notificaiton {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.titleView = nil;
    });
}

- (void) handleReloginFail:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        ReloginTipView *reloginTipView = [[[NSBundle mainBundle] loadNibNamed:@"ReloginTipView" owner:self options:nil] objectAtIndex:0];
        reloginTipView.connErrLbl.hidden = NO;
        reloginTipView.textLabel.hidden = YES;
        reloginTipView.indicatorView.hidden = YES;
        self.navigationItem.titleView = reloginTipView;
    });
}


#pragma mark - handle Presence notification.
- (void) handlePresenceNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initData];
        [m_table reloadData];
    });
}

@end
