//
//  RosterItemSearchTableViewController.m
//  IM
//
//  Created by 郭志伟 on 15-1-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemSearchTableViewController.h"
#import "AppDelegate.h"
#import "LogLevel.h"
#import "MBProgressHUD.h"
#import "RosterItemSearchResultTableViewController.h"

@interface RosterItemSearchTableViewController () {
    
    __weak IBOutlet UITextField *orgTextField;
    __weak IBOutlet UITextField *contentTextField;
}

@end

@implementation RosterItemSearchTableViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 44;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)seachBtnTapped:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    User *u = APP_DELEGATE.user;
    [u.rosterMgr searchRosterItemsWithContent:contentTextField.text curPage:0 pageSz:20 org:orgTextField.text key:u.key iv:u.iv url:APP_DELEGATE.user.imurl token:u.token completion:^(BOOL finished, NSArray *data, NSUInteger cur) {
        DDLogInfo(finished ? @"suc" : @"fail");
        if (finished) {
            RosterItemSearchResultTableViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"RosterItemSearchResult"];
            vc.searchResult = data;
            vc.content = [contentTextField.text copy];
            vc.curPage = cur;
            vc.pageSz = 20;
            [self.navigationController pushViewController:vc animated:YES];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}


@end
