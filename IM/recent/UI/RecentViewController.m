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
#import "ChatViewController.h"
#import "JSQMessagesTimestampFormatter.h"
#import "NSDate+Common.h"
#import "ChatMessageControllerInfo.h"
#import "RosterNotification.h"
#import "RecentRosterItemAddReqTableViewCell.h"
#import "Utils.h"

@interface RecentViewController () {
    
    __weak IBOutlet UITableView *m_tableView;
    RecentViewModle *m_modle;
}

@end

@implementation RecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    m_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRecvNewMessage:) name:kChatMessageRecvNewMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSendNewMessage:) name:kChatMessageSendNewMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatMessageControllerDismiss:) name:kChatMessageControllerWillDismiss object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterItemAddReq:) name:kRosterItemAddRequest object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterItemAddReqControllerDismiss:) name:kRosterItemAddReqControllerDismiss object:nil];
    [self initModelData];
    [self updateTabItem];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSString *name = [body objectForKey:@"fromname"];
        if ([item.from isEqualToString:APP_DELEGATE.user.uid]) {
            name = [APP_DELEGATE.user.rosterMgr getItemByUid:item.to].name;
        }
        chatCell.nameLbl.text = name;
        chatCell.lastMsgLbl.text = [body objectForKey:@"content"];
        NSInteger badge = [item.badge integerValue];
        if (badge != 0) {
            chatCell.badgeText = item.badge;
        } else {
            chatCell.badgeText = nil;
        }
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dateFormat dateFromString:item.time];
        NSString *relativeDate = [[JSQMessagesTimestampFormatter sharedFormatter] relativeDateForDate:date];
        NSString *time = [[JSQMessagesTimestampFormatter sharedFormatter] timeForDate:date];
        chatCell.timeLbl.text = [NSString stringWithFormat:@"%@ %@", relativeDate, time];
        cell = chatCell;
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
        ChatViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ChatViewController"];
        
        NSDictionary *cnt = [item dictContent];
        NSDictionary *body = [cnt objectForKey:@"body"];
        vc.talkingId = item.from;
        vc.talkingname = [body objectForKey:@"fromname"];
        if ([item.from isEqualToString:APP_DELEGATE.user.uid]) {
            vc.talkingname = [APP_DELEGATE.user.rosterMgr getItemByUid:item.to].name;
            vc.talkingId = item.to;
            vc.chatMsgType = [item.ext intValue];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (item.msgtype == IM_ROSTER_ITEM_ADD_REQUEST) {
        UIViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterItemAddReqTableViewController"];
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

@end