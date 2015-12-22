//
//  RecentViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RecentViewController.h"
#import "RecentChatMsgItemTableViewCell.h"
#import "ChatMessageNotification.h"
#import "ChatMessage.h"
#import "AppDelegate.h"
#import "LogLevel.h"
#import "RecentViewModle.h"
#import "RecentMsgItem.h"
#import "MessageConstants.h"
#import "RTChatViewController.h"
#import "RTMessagesTimestampFormatter.h"
#import "NSDate+Common.h"
#import "ChatMessageControllerInfo.h"
#import "RosterNotification.h"
#import "RecentRosterItemAddReqTableViewCell.h"
#import "Utils.h"
#import "loginNotification.h"
#import "ReloginTipView.h"
#import "AvatarNotifications.h"
#import "OsItem.h"
#import "PresenceMsg.h"
#import "UIColor+Hexadecimal.h"
#import "SearchPeopleViewController.h"
#import "DetailTableViewController.h"
#import "GroupNotification.h"
#import "GroupChatNotifyMsg.h"
#import "RecentGrpNotifyTableViewCell.h"
#import "NSDate+Common.h"
#import "GroupChatNotificaitonViewController.h"
#import "CWStatusBarNotification.h"
#import "GroupChatJoinMsg.h"

static NSString *kChatMessageTypeNomal = @"0";

@interface RecentViewController () <SearchPeopleViewControllerDelegate, RecentChatMsgItemTableViewCellDelegate>{
    
    __weak IBOutlet UITableView *m_tableView;
    RecentViewModle *m_modle;
}

@property(nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) CWStatusBarNotification *grpNotification;

@end

@implementation RecentViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageRecvNewMsg object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageSendNewMsg object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageControllerWillDismiss object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRosterItemAddRequest object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRosterItemAddReqControllerDismiss object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAvatarNotificationDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloging object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationReloginFail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGroupChatListChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGroupChatNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGroupJoinSuccess object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    m_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.grpNotification = [CWStatusBarNotification new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRecvNewMessage:) name:kChatMessageRecvNewMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSendNewMessage:) name:kChatMessageSendNewMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatMessageControllerDismiss:) name:kChatMessageControllerWillDismiss object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterItemAddReq:) name:kRosterItemAddRequest object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterItemAddReqControllerDismiss:) name:kRosterItemAddReqControllerDismiss object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAvatarDownloaded:) name:kAvatarNotificationDownloaded object:nil];
    [self initModelData];
    [self updateTabItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloging:) name:kNotificationReloging object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloginSucess:) name:kNotificationReloginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloginFail:) name:kNotificationReloginFail object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotReachable:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupListChangedNotification:) name:kGroupChatListChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupChatNotification:) name:kGroupChatNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupJoinNotification:) name:kGroupJoinSuccess object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
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
    m_tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchController.searchBar.scopeButtonTitles = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    RecentMsgItem *item = [m_modle.msgList objectAtIndex:indexPath.row];
    if (item.msgtype == IM_MESSAGE) {
        RecentChatMsgItemTableViewCell *chatCell = [tableView dequeueReusableCellWithIdentifier:@"RecentChatMsgItemCell" forIndexPath:indexPath];
        NSDictionary *cnt = [item dictContent];
        NSDictionary *body = [cnt objectForKey:@"body"];
        chatCell.tag = indexPath.row;
        chatCell.delegate = self;
        
        if ([item.ext isEqualToString:kChatMessageTypeNomal]) {
            NSString *name = [body objectForKey:@"fromname"];
            if ([item.from isEqualToString:APP_DELEGATE.user.uid]) {
                name = [APP_DELEGATE.user.rosterMgr getItemByUid:item.to].name;
                if (name == nil) {
                    OsItem *osItem = [USER.osMgr getItemInfoByUid:item.to];
                    name = osItem.name;
                }
            }
            chatCell.nameLbl.text = name;
        } else {
            GroupChat *grp = [USER.groupChatMgr getGrpChatByGid:item.to];
            chatCell.avatarImgView.userInteractionEnabled = NO;
            if (grp.type == GropuChatypePrivate) {
                chatCell.avatarImgView.image = [UIImage imageNamed:@"groupchat_private"];
            } else if (grp.type == GropuChatypePublic) {
                chatCell.avatarImgView.image = [UIImage imageNamed:@"groupchat_logo"];
            }
            chatCell.nameLbl.text = grp.gname;
        }
        
        if ([[body objectForKey:@"type"] isEqualToString:@"text"]) {
            NSString *content = [body objectForKey:@"content"];
            NSNumber *b64 = [body objectForKey:@"b64"];
            if ([b64 boolValue]) {
                content = [Utils decodeBase64String:content];
            }
            chatCell.lastMsgLbl.text = content;
        }
        
        if ([[body objectForKey:@"type"] isEqualToString:@"image"]) {
            chatCell.lastMsgLbl.text = @"[图片]";
        }
        
        if ([[body objectForKey:@"type"] isEqualToString:@"voice"]) {
            chatCell.lastMsgLbl.text = @"[音频]";
        }
        
        if ([[body objectForKey:@"type"] isEqualToString:@"file"]) {
            chatCell.lastMsgLbl.text = @"[文件]";
        }
        NSString *uid = item.from;
        if ([item.from isEqualToString:APP_DELEGATE.user.uid]) {
            uid = item.to;
        }
        
        if ([item.ext isEqualToString:kChatMessageTypeNomal]) {
             chatCell.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:uid];
        }
       
        
        NSInteger badge = [item.badge integerValue];
        if (badge != 0) {
            chatCell.badgeText = item.badge;
        } else {
            chatCell.badgeText = nil;
        }
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        NSDate *date = [dateFormat dateFromString:item.time];
        NSString *relativeDate = [[RTMessagesTimestampFormatter sharedFormatter] relativeDateForDate:date];
        NSString *time = [[RTMessagesTimestampFormatter sharedFormatter] timeForDate:date];
        chatCell.timeLbl.text = [NSString stringWithFormat:@"%@ %@", relativeDate, time];
        cell = chatCell;
        return cell;
    }
    
    if (item.msgtype == IM_ROSTER_ITEM_ADD_REQUEST) {
        RecentRosterItemAddReqTableViewCell *rosterReqCell = [tableView dequeueReusableCellWithIdentifier:@"rosterItemAddReqCell" forIndexPath:indexPath];
        NSData *contData = [item.content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *contenDict = [Utils dictFromJsonData:contData];
        NSString *msgStr = [contenDict objectForKey:@"msg"];
        NSData *msgData = [msgStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *msgDict = [Utils dictFromJsonData:msgData];
        rosterReqCell.msgLabel.text = [NSString stringWithFormat:@"%@ 请求加你为好友！", [msgDict objectForKey:@"req_name"]];
        NSInteger badge = [item.badge integerValue];
        if (badge != 0) {
            rosterReqCell.badgeText = item.badge;
        } else {
            rosterReqCell.badgeText = nil;
        }
        cell = rosterReqCell;
    }
    
    if (item.msgtype == IM_CHATROOM) {
        RecentGrpNotifyTableViewCell *notifyCell = [tableView dequeueReusableCellWithIdentifier:@"RecentGrpNotifyTableViewCell" forIndexPath:indexPath];
        notifyCell.msgLabel.text = item.content;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        NSDate *date = [dateFormat dateFromString:item.time];
        NSString *relativeDate = [[RTMessagesTimestampFormatter sharedFormatter] relativeDateForDate:date];
        notifyCell.timestampLabel.text = relativeDate;
        NSInteger badge = [item.badge integerValue];
        if (badge != 0) {
            notifyCell.badgeText = item.badge;
        } else {
            notifyCell.badgeText = nil;
        }
        cell = notifyCell;
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"unkown cell"];
        DDLogError(@"unkown cell");
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_modle.msgList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RecentMsgItem *item = [m_modle.msgList objectAtIndex:indexPath.row];
    if (item.msgtype == IM_MESSAGE) {
        RTChatViewController *vc = [[RTChatViewController alloc] init];
        
        NSDictionary *cnt = [item dictContent];
        NSDictionary *body = [cnt objectForKey:@"body"];
        if ([item.ext isEqualToString:kChatMessageTypeNomal]) {
            vc.talkingId = item.from;
            vc.talkingname = [body objectForKey:@"fromname"];
            if ([item.from isEqualToString:APP_DELEGATE.user.uid]) {
                vc.talkingname = [APP_DELEGATE.user.rosterMgr getItemByUid:item.to].name;
                vc.talkingId = item.to;
            }
        } else {
            vc.talkingId = item.to;
            GroupChat *grp = [USER.groupChatMgr getGrpChatByGid:item.to];
            vc.talkingname = grp.gname;
        }
        vc.chatMsgType = [item.ext intValue];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (item.msgtype == IM_ROSTER_ITEM_ADD_REQUEST) {
        UIViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterItemAddReqTableViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (item.msgtype == IM_CHATROOM) {
        [USER.recentMsg updateGrpChatNotifyBadge:@"0"];
        [self initModelData];
        [self updateTabItem];
        [m_tableView reloadData];
        GroupChatNotificaitonViewController *vc = [[GroupChatNotificaitonViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
    

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RecentMsgItem *item = [m_modle.msgList objectAtIndex:indexPath.row];
        if ([APP_DELEGATE.user.recentMsg delMsgItem:item]) {
            [self initModelData];
            [self updateTabItem];
            [m_tableView reloadData];
        }
    }
}

- (void)handleRecvNewMessage:(NSNotification *)notification {
    ChatMessage *msg = notification.object;
    if (!msg) {
        return;
    }
    
    if (![APP_DELEGATE.user.recentMsg updateRevcChatMsg:msg]) {
        DDLogWarn(@"WARN: update recv msg to recent tabel.");
    }
    [self initModelData];
    __block NSInteger sum = [APP_DELEGATE.user.recentMsg getMsgBadgeSum];
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tableView reloadData];
        if (sum > 0) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)sum]];
        }
    });
}

- (void)handleSendNewMessage:(NSNotification *)notificaiton {
    ChatMessage *msg = notificaiton.object;
    
    if (![APP_DELEGATE.user.recentMsg updateSendChatMsg:msg]) {
        DDLogWarn(@"WARN: update send msg to recent table.");
    }
    [self initModelData];
    [m_tableView reloadData];
}

- (void)handleChatMessageControllerDismiss:(NSNotification *)notification {
    ChatMessageControllerInfo *info = notification.object;
    [APP_DELEGATE.user.recentMsg updateChatMsgBadge:@"0" fromOrTo:info.talkingId chatmsgType:info.msgType];
    [self initModelData];
    [m_tableView reloadData];
    [self updateTabItem];
}

- (void)handleRosterItemAddReq: (NSNotification *)notification {
    RosterItemAddRequest *riar = notification.object;
    [APP_DELEGATE.user.recentMsg updateRosterItemAddReqMsg:riar];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initModelData];
        [m_tableView reloadData];
        [self updateTabItem];
    });
}

- (void)handleRosterItemAddReqControllerDismiss: (NSNotification *)notificaiton {
    [APP_DELEGATE.user.recentMsg updateRosterItemAddReqBadge:@"0"];
    [self initModelData];
    [m_tableView reloadData];
    [self updateTabItem];
}

- (void)initModelData {
    NSArray *data = [APP_DELEGATE.user.recentMsg loadDbData];
    m_modle = nil;
    m_modle = [[RecentViewModle alloc] initWithDbData:data];
}

- (void)updateTabItem {
    NSInteger sum = [APP_DELEGATE.user.recentMsg getMsgBadgeSum];
    
    [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue: sum > 0 ? [NSString stringWithFormat:@"%ld", (long)sum] : nil];

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

- (void)handleGroupListChangedNotification:(NSNotification *)notification {
    __block NSString *gid = notification.object;
    __block  RecentMsgItem *rmItem = nil;
    if ([gid isKindOfClass:[NSString class]]) {
        [m_modle.msgList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RecentMsgItem *item = obj;
            NSString *ID = item.from;
            if ([item.from isEqualToString:USER.uid]) {
                ID = item.to;
            }
            if ([item.ext isKindOfClass:[NSString class]] && [item.ext isEqualToString:[NSString stringWithFormat:@"%d", (unsigned int)ChatMessageTypeGroupChat]]) {
                rmItem = item;
                *stop = YES;
            }
        }];
        if (rmItem) {
            [USER.recentMsg delMsgItem:rmItem];
            [self initModelData];
            [self updateTabItem];
            [m_tableView reloadData];
        }
    }
}

- (void)handleGroupJoinNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        GroupChatJoinMsg *joinMsg = notification.object;
        OsItem *item = [USER.osMgr getItemInfoByUid:joinMsg.uid];
        GroupChat *g = [USER.groupChatMgr getGrpChatByGid:joinMsg.gid];
        [self.grpNotification displayNotificationWithMessage:[NSString stringWithFormat:@"%@加入%@群", item.name, g.gname] forDuration:4.0];
    });
}

- (void)handleGroupChatNotification:(NSNotification *)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        GroupChatNotifyMsg *msg = notification.object;
        if ([msg isKindOfClass:[GroupChatNotifyMsg class]]) {
            NSString *fromName = [USER.osMgr getItemInfoByUid:msg.from].name;
            if (msg.gname == nil) {
                msg.gname = [USER.groupChatMgr getGrpChatByGid:msg.gid].gname;
            }
            [USER.recentMsg updateGrpChatNotifyMsg:msg fromName:fromName];
            [self initModelData];
            [self updateTabItem];
            [m_tableView reloadData];
            [self showGroupNotification:msg fname:fromName];
        }
    });
}

- (void)showGroupNotification:(GroupChatNotifyMsg *)msg fname:(NSString *)fname {
    NSString *content = nil;
    if ([msg.notifytype isEqualToString:@"invent"]) {
        content = [NSString stringWithFormat:@"%@邀请你加入%@群", fname, msg.gname];
    } else if ([msg.notifytype isEqualToString:@"del"]) {
        content = [NSString stringWithFormat:@"%@解散了%@群", fname, msg.gname];
    } else if ([msg.notifytype isEqualToString:@"leave"]) {
        content = [NSString stringWithFormat:@"%@退出了%@群", fname, msg.gname];
    }
    if (content != nil) {
        [self.grpNotification displayNotificationWithMessage:content forDuration:4.0];
    }
}

//- (void)handleAppWillEnterForeground {
//    [m_tableView reloadData];
//}

#pragma mark - handle avatar notification
- (void)handleAvatarDownloaded:(NSNotification *)notification {
    [m_tableView reloadData];
}

#pragma mark - RecentChatMsgItemTableViewCellDelegate

- (void)RecentChatMsgItemTableViewCell:(RecentChatMsgItemTableViewCell *)cell avatarImgViewDidTapped:(UIImageView *)avatarImgView {
    RecentMsgItem *item = [m_modle.msgList objectAtIndex:cell.tag];
    if (item.msgtype == IM_MESSAGE) {
        NSDictionary *cnt = [item dictContent];
        NSDictionary *body = [cnt objectForKey:@"body"];
        if ([item.ext isEqualToString:kChatMessageTypeNomal]) {
            DetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTableViewController"];
            vc.uid = item.from;
            vc.name = [body objectForKey:@"fromname"];
            if ([item.from isEqualToString:APP_DELEGATE.user.uid]) {
                vc.name = [APP_DELEGATE.user.rosterMgr getItemByUid:item.to].name;
                vc.uid = item.to;
            }
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
