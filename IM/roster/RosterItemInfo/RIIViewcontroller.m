//
//  RIIViewcontroller.m
//  IM
//
//  Created by 郭志伟 on 15/7/3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RIIViewcontroller.h"

#import <Masonry/Masonry.h>
#import <RKTabView.h>

#import "AppDelegate.h"
#import "RTChatViewController.h"
#import "RTSeparatorCell.h"

@interface RIIViewcontroller() <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    RKTabView  *_tabView;
    Detail  *_detail;
}
@end

@implementation RIIViewcontroller

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    self.navigationItem.title = self.talkingname;
    [self setupViews];
    [USER.detailMgr getDetailWithUid:self.talkingId Token:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished, Detail *d) {
        if (finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _detail = d;
                [_tableView reloadData];
            });
        }
    }];
}

- (void)setupViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
//    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tabView = [[RKTabView alloc] initWithFrame:CGRectZero];
    _tabView.enabledTabBackgrondColor = [UIColor whiteColor];
    _tabView.drawSeparators = YES;
    _tableView.estimatedRowHeight = 44.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = [[UIColor alloc] initWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    [self.view addSubview:_tableView];
    [self.view addSubview:_tabView];
   
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    RKTabItem *audioItem = [RKTabItem createButtonItemWithImage:[UIImage imageNamed:@"rii_chat"] target:self selector:@selector(audioChatTapped)];
    audioItem.titleString = @"语音";
    RKTabItem *toChatVCItem = [RKTabItem createButtonItemWithImage:[UIImage imageNamed:@"rii_chat"] target:self selector:@selector(toChatViewController)];
    toChatVCItem.titleString = @"信息";
    _tabView.tabItems = @[audioItem, toChatVCItem];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(_tabView.mas_top);
    }];

    [_tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}


- (void)audioChatTapped {
    [USER.webRtcMgr inviteUid:self.talkingId session:USER.session];
}

- (void)toChatViewController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RTChatViewController *vc = [[RTChatViewController alloc] init];
    vc.talkingId = self.talkingId;
    vc.talkingname = self.talkingname;
    [self.navigationController pushViewController:vc animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [self separatorCell];
        return cell;
    }
    
    if (indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"manInfo"];
        cell.imageView.image = [USER.avatarMgr getAvatarImageByUid:self.talkingId];
        cell.textLabel.text = self.talkingname;
        NSString *sex = [_detail.data objectForKey:@"sex"];
        cell.detailTextLabel.text = [sex isEqual:@"1"] ? @"男" : @"女";
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    }
    
    if (indexPath.row == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"signature"];
        cell.textLabel.text = @"个性签名";
        RosterItem* item = [USER.rosterMgr getItemByUid:self.talkingId];
        cell.detailTextLabel.text = item.sign;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    }
    
    if (indexPath.row == 3) {
        UITableViewCell *cell = [self separatorCell];
        return cell;
    }
    
    if (indexPath.row == 4) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tel"];
        cell.textLabel.text = @"手机";
        cell.detailTextLabel.text = [_detail.data objectForKey:@"cellphone"];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    }
    
    if (indexPath.row == 5) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"email"];
        cell.textLabel.text = @"邮箱";
        cell.detailTextLabel.text = [_detail.data objectForKey:@"email"];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    }
    
    if (indexPath.row == 6) {
        UITableViewCell *cell = [self separatorCell];
        return cell;
    }
    
    if (indexPath.row == 7) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"job"];
        cell.textLabel.text = @"职位";
        cell.detailTextLabel.text = [_detail.data objectForKey:@"position"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        return cell;
    }
    
    if (indexPath.row == 8) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"area"];
        cell.textLabel.text = @"区域";
        cell.detailTextLabel.text = [_detail.data objectForKey:@"address"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        return cell;
    }
    
    
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 6) {
        return 20.0f;
    }
    return 44.0f;
}

- (UITableViewCell *)separatorCell {
    RTSeparatorCell *cell = [[RTSeparatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"seprator"];
    return cell;
}


@end
