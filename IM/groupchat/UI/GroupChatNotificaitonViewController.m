//
//  GroupChatNotificaitonViewController.m
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatNotificaitonViewController.h"
#import "GroupChatNotificaitonCell.h"

@implementation GroupChatNotificaitonViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"群消息";
    [self.tableView registerClass:[GroupChatNotificaitonCell class] forCellReuseIdentifier:@"GroupChatNotificaitonCell"];
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChatNotificaitonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupChatNotificaitonCell" forIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

@end
