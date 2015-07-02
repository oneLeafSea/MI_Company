//
//  SignatureViewController.m
//  IM
//
//  Created by 郭志伟 on 15/7/2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "SignatureViewController.h"

#import <Masonry/Masonry.h>

#import "FCNPTextTableViewCell.h"
#import "UIView+Toast.h"
#import "AppDelegate.h"
#import "JRSession.h"
#import "JRTextResponse.h"


@interface SignatureViewController()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation SignatureViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnTapped)];
}


- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[FCNPTextTableViewCell class] forCellReuseIdentifier:@"FCNPTextTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)rightBtnTapped {
    FCNPTextTableViewCell *cell = (FCNPTextTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell.text.length == 0) {
        [self.view makeToast:@"请输入内容。"];
        return;
    }
    [cell.txtView resignFirstResponder];
    __block NSString *txt = [cell.text copy];
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:USER.imurl]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:@"QID_IM_SET_ROSTER_SIGN" token:USER.token key:USER.key iv:USER.iv];
    [param.params setObject:txt forKey:@"sign"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTextResponse class]]) {
                JRTextResponse *txtResp = (JRTextResponse *)resp;
                if ([txtResp.text isEqualToString:@"1"]) {
                    [USER.presenceMgr postMsgWithPresenceType:kPresenceTypeOnline presenceShow:kPresenceShowOnline sign:txt];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.delegate respondsToSelector:@selector(signatureViewController:DidChanged:)]) {
                            [self.delegate signatureViewController:self DidChanged:txt];
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            
        } cancel:^(JRReqest *request) {

        }];
    });

    
}

#pragma makr - tableViewDelegate &datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        FCNPTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FCNPTextTableViewCell" forIndexPath:indexPath];
        cell.txtView.placeholder = @"写点你想说说的...";
        cell.maxCharacterCount = 120;
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"svc"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 120.0f;
    }
    return 44.0f;
}

@end
