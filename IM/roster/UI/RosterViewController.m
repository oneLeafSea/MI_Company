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
#import "RTChatViewController.h"
#import "ReloginTipView.h"
#import "LoginNotification.h"
#import "GroupChatListTableViewController.h"
#import "OsViewController.h"
#import "PresenceNotification.h"
#import "PresenceMsg.h"
#import "PopMenu.h"
#import "MultiSelectViewController.h"
#import "RosterItem.h"
#import "MultiSelectItem.h"
#import "MultiCallClient.h"
#import "NSUUID+StringUUID.h"
#import "MultiCallViewController.h"
#import "RIIViewcontroller.h"
#import "RTChatViewController.h"
#import "UIColor+Hexadecimal.h"
#import "SearchPeopleViewController.h"
#import "DetailTableViewController.h"

@interface RosterViewController () <RosterSectionHeaderViewDelegate, UITableViewDelegate, MultiSelectViewControllerDelegate, SearchPeopleViewControllerDelegate, RosterItermTableViewCellDelegate> {
    NSMutableArray *m_Sections;
    NSArray *m_groups;
    __weak IBOutlet UITableView *m_table;
    
}
@property (nonatomic, strong) PopMenu *popMenu;

@property(nonatomic, strong) UISearchController *searchController;
@end

@implementation RosterViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRosterChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPresenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloging object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloginFail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarItem.title = @"联系人0";
    self.tabBarItem.image = [UIImage imageNamed:@"roster_un"];
    m_table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self initData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterGrpChanged) name:kRosterChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePresenceNotification:) name:kPresenceChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloging:) name:kNotificationReloging object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloginSucess:) name:kNotificationReloginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloginFail:) name:kNotificationReloginFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotReachable:) name:kReachabilityChangedNotification object:nil];
    
    SearchPeopleViewController *spVC = [[SearchPeopleViewController alloc] initWithOsItemArray:USER.osMgr.items];
    spVC.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:spVC];
    self.searchController.searchResultsUpdater = spVC;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.scopeButtonTitles =   @[@"联系人", @"通讯录"];
    self.searchController.searchBar.delegate = spVC;
    self.searchController.searchBar.barTintColor = [UIColor colorWithHex:@"#EFEFF4"];
    self.searchController.searchBar.layer.borderWidth = 1;
    
    self.searchController.searchBar.layer.borderColor = [[UIColor colorWithHex:@"#EFEFF4"] CGColor];
    self.searchController.searchBar.tintColor = [UIColor colorWithHex:@"#02C1D2"];
    m_table.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchController.searchBar.scopeButtonTitles = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
    
}

- (void)SearchPeopleViewController:(SearchPeopleViewController *)vc didSelectPeople:(OsItem *)item {
    [self.searchController dismissViewControllerAnimated:YES completion:^{
        self.searchController.searchBar.text = nil;
        RTChatViewController *chatVc = [[RTChatViewController alloc] init];
        chatVc.talkingId = item.uid;
        chatVc.talkingname = item.name;
        [self.navigationController pushViewController:chatVc animated:YES];
    }];
    
}

- (void)initData {
    m_groups = [APP_DELEGATE.user.rosterMgr grouplist];
    m_Sections = [[NSMutableArray alloc] init];
    for (int n = 0; n < m_groups.count; n++) {
        RosterSection *section = [[RosterSection alloc] init];
        [m_Sections addObject:section];
    }
}

- (void)updateData {
    m_groups = [APP_DELEGATE.user.rosterMgr grouplist];
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    for (int n = 0; n < m_groups.count; n++) {
        RosterSection *section = [[RosterSection alloc] init];
        RosterSection *oldSect = [m_Sections objectAtIndex:n];
        section.expand = oldSect.expand;
        [sections addObject:section];
    }
    m_Sections = sections;
}

- (UITableViewCell *)getRosterTitleCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rosterTitleCell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"联系人";
    cell.textLabel.textColor = [UIColor colorWithHex:@"#808080"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return m_groups.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
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
        if ([USER.presenceMgr isOnline:item.uid]) {
            count++;
        }
    }];
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        return 25;
    }
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
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        UITableViewCell *cell = [self getRosterTitleCell];
        return cell;
    }
    
    NSInteger index = indexPath.section - 1;
    static NSString *cellId = @"rosterItermCell";
    RosterItermTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    RosterGroup *g = [m_groups objectAtIndex:index];
    RosterItem* item = [g.items objectAtIndex:indexPath.row];
    cell.item = item;
    cell.delegate = self;
    cell.nameLabel.text = item.name;
    if ([USER.presenceMgr isOnline:item.uid]) {
        cell.signatureLabel.text = [NSString stringWithFormat:@"[在线]%@", item.sign];
        cell.maskView.hidden = YES;
    } else {
        cell.signatureLabel.text = [NSString stringWithFormat:@"[离线]%@", item.sign];
        cell.maskView.hidden = NO;
    }
    [self setDevceTypeImage:cell uid:item.uid];
    cell.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:item.uid];
    return cell;
}

- (void)setDevceTypeImage:(RosterItermTableViewCell *)cell uid:(NSString *)uid {
    NSArray *array = [USER.presenceMgr getPresenceMsgArrayByUid:uid];
    if (array.count == 0) {
        cell.deviceImageView.hidden = YES;
        cell.device1ImageView.hidden = YES;
        cell.device2ImageView.hidden = YES;
    }
    if (array.count == 1) {
        cell.deviceImageView.hidden = NO;
        cell.device1ImageView.hidden = YES;
        cell.device2ImageView.hidden = YES;
        PresenceMsg *notify = [array objectAtIndex:0];
        cell.deviceImageView.image = [UIImage imageNamed:[self getImageNameByFromRes:notify.from_res]];
    }
    
    if (array.count == 2) {
        cell.deviceImageView.hidden = NO;
        cell.device1ImageView.hidden = NO;
        cell.device2ImageView.hidden = YES;
        PresenceMsg *notify = [array objectAtIndex:0];
        cell.deviceImageView.image = [UIImage imageNamed:[self getImageNameByFromRes:notify.from_res]];
        notify = [array objectAtIndex:1];
        cell.device1ImageView.image = [UIImage imageNamed:[self getImageNameByFromRes:notify.from_res]];
    }
    
    if (array.count == 3) {
        cell.deviceImageView.hidden = NO;
        cell.device1ImageView.hidden = NO;
        cell.device2ImageView.hidden = NO;
        PresenceMsg *notify = [array objectAtIndex:0];
        cell.deviceImageView.image = [UIImage imageNamed:[self getImageNameByFromRes:notify.from_res]];
        notify = [array objectAtIndex:1];
        cell.device1ImageView.image = [UIImage imageNamed:[self getImageNameByFromRes:notify.from_res]];
        notify = [array objectAtIndex:2];
        cell.device2ImageView.image = [UIImage imageNamed:[self getImageNameByFromRes:notify.from_res]];
    }
}

- (NSString *)getImageNameByFromRes:(NSString *)fromRes {
    if ([fromRes isEqual:@"iphone"]) {
        return @"roster_device_iphone";
    }
    if ([fromRes isEqual:@"Android"]) {
        return @"roster_device_android";
    }
    
    if ([fromRes isEqual:@"PC"]) {
        return @"roster_device_pc";
    }
    return nil;
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
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        return;
    }
    
    NSInteger index = indexPath.section - 1;
    
    RTChatViewController *vc = [[RTChatViewController alloc] init];
    RosterGroup *g = [m_groups objectAtIndex:index];
    RosterItem* item = [g.items objectAtIndex:indexPath.row];
    vc.talkingId = item.uid;
    vc.talkingname = item.name;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)add:(id)sender {
    [self.popMenu showMenuOnView:self.view atPoint:CGPointZero];
}

- (PopMenu *)popMenu {
    if (!_popMenu) {
        NSMutableArray *popMenuItems = [[NSMutableArray alloc] initWithCapacity:3];
        [popMenuItems addObject:[[PopMenuItem alloc] initWithImage:[UIImage imageNamed:@"roster_multicall"] title:@"多人通话"]];
        [popMenuItems addObject:[[PopMenuItem alloc] initWithImage:[UIImage imageNamed:@"roster_add_friend"] title:@"添加好友"]];
        _popMenu = [[PopMenu alloc] initWithMenus:popMenuItems];
        typeof(self) __weak weakSelf = self;
        _popMenu.popMenuDidSlectedCompled = ^(NSInteger index, PopMenuItem *popMenuItems) {
            if (index == 0) {
                DDLogInfo(@"发起群聊。");
                [weakSelf showMultiSelectController];
            }else if (index == 1 ) {
                DDLogInfo(@"添加好友。");
                RosterItemSearchTableViewController *vc = [[weakSelf storyboard] instantiateViewControllerWithIdentifier:@"RosterItemSearchResultTableViewController"];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    return _popMenu;
}

- (void)showMultiSelectController {
    MultiSelectViewController *vc = [[MultiSelectViewController alloc]init];
    NSArray *rosterItems = [USER.rosterMgr allRosterItems];
    NSMutableArray *multiItems = [[NSMutableArray alloc] init];
    [rosterItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RosterItem *rItem = obj;
        if (![USER.presenceMgr isOnline:rItem.uid]) {
            return ;
        }
        MultiSelectItem *item = [[MultiSelectItem alloc] init];
        item.uid = rItem.uid;
        item.name = rItem.name;
        item.imageURL = [NSURL fileURLWithPath:[USER.avatarMgr.avatarPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", rItem.uid]]];
        [multiItems addObject:item];
    }];
    vc.items = multiItems;
    vc.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    navController.navigationBar.barTintColor = [UIColor colorWithRed:75 / 255.0f green:193 / 255.0f blue:210 / 255.0f alpha:1.0f];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               nil];
    navController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;
    [self.navigationController presentViewController:navController animated:YES completion:nil];;
}


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

- (void)handleNotReachable:(NSNotification *)notification {
    Reachability* noteObject = notification.object;
    if (noteObject.currentReachabilityStatus == NotReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ReloginTipView *reloginTipView = [[[NSBundle mainBundle] loadNibNamed:@"ReloginTipView" owner:self options:nil] objectAtIndex:0];
            reloginTipView.connErrLbl.hidden = NO;
            reloginTipView.textLabel.hidden = YES;
            reloginTipView.indicatorView.hidden = YES;
            self.navigationItem.titleView = reloginTipView;
        });
    }
}


#pragma mark - handle Presence notification.
- (void) handlePresenceNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateData];
        [m_table reloadData];
    });
}

#pragma mark - MultiSelectViewControllerDelegate
- (void)MultiSelectViewController:(MultiSelectViewController *)controller didConfirmWithSelectedItems:(NSArray *)selectedItems {
    NSMutableArray *uids = [[NSMutableArray alloc] init];
    [selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MultiSelectItem *item = obj;
        [uids addObject:item.uid];
    }];
    MultiCallViewController *vc = [[MultiCallViewController alloc] initWithNibName:@"MultiCallViewController" bundle:nil];
    vc.invited = NO;
    vc.talkingUids = uids;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - RosterItermTableViewCellDelegate
- (void)RosterItermTableViewCell:(RosterItermTableViewCell *)cell AvatarDidSelectedWithItem:(RosterItem *)item {
    DetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTableViewController"];
    vc.uid = item.uid;
    vc.name = item.name;
    vc.navigationItem.title = item.name;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
