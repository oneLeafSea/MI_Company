//
//  FriendCircleViewController.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FriendCircleViewController.h"
#import <Masonry.h>
#import <DateTools.h>
#import <MJRefresh.h>
#import <SDWebImage/SDWebImageDownloader.h>


#import "FCItemTableViewCell.h"
#import "LogLevel.h"
#import "RTTextInputBar.h"
#import "AppDelegate.h"
#import "RTFileTransfer.h"
#import "NSUUID+StringUUID.h"
#import "NSString+URL.h"
#import "Utils.h"

#import "FCModel.h"
#import "FCNewPostViewController.h"


@interface FriendCircleViewController () <UITableViewDelegate, UITableViewDataSource, FCItemTableViewCellDelegate, RTTextInputBarDelegate, FCNewPostViewControllerDelegate> {
    FCModel *_model;
    
    NSString *_ssid;
    NSString *_sshfxxid;
    NSString *_replyName;
    NSString *_replyUid;
}

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) RTTextInputBar *inputBar;

@end

@implementation FriendCircleViewController

- (instancetype) init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"朋友圈";
    [self setupTableView];
    [self.view addSubview:self.inputBar];
    [USER.fcMgr resetNewNotifcatinFlag];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发帖" style:UIBarButtonItemStylePlain target:self action:@selector(rigthBtnTapped)];
    [USER.fcMgr getMsgsWithCur:1 pgSz:10 completion:^(BOOL finished, NSDictionary *result) {
        if (finished) {
            _model = [[FCModel alloc] initWithDict:result];
        }
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[FCItemTableViewCell class] forCellReuseIdentifier:@"FCItemTableViewCell"];
    [self.view addSubview:self.tableView];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1.0]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [USER.fcMgr getMsgsWithCur:1 pgSz:10 completion:^(BOOL finished, NSDictionary *result) {
            if (finished) {
                _model = [[FCModel alloc] initWithDict:result];
            }
            [self.tableView reloadData];
        }];
        [self.tableView.header endRefreshing];
    }];
    
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSInteger cur = _model.itemModels.count / 10 + 1;
        [USER.fcMgr getMsgsWithCur:cur pgSz:10 completion:^(BOOL finished, NSDictionary *result) {
            [_model appendItemsWithDict:result];
            [self.tableView reloadData];
            [self.tableView.footer endRefreshing];
        }];
    }];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

#pragma mar - overide
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark -- tableview delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _model.itemModels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    FCItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FCItemTableViewCell" forIndexPath:indexPath];
    FCItemTableViewCell* cell = [[FCItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault model:[_model.itemModels objectAtIndex:indexPath.row] reuseIdentifier:@"FCItemTableViewCell"];
    cell.model = [_model.itemModels objectAtIndex:indexPath.row];
    cell.curVC = self;
    cell.delegate = self;
   
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FCItemTableViewCell heightForCellModel:[_model.itemModels objectAtIndex:indexPath.row]];
}

//#pragma mark - getter
- (RTTextInputBar *)inputBar {
    if (!_inputBar) {
        _inputBar = [RTTextInputBar showInView:self.tableView];
        _inputBar.rtDelegate = self;
    }
    return _inputBar;
}

- (void)textInputBar:(RTTextInputBar *)inputBar didPressSendBtnWithText:(NSString *)txt {
    NSString *content = [Utils encodeBase64String:txt];
    [USER.fcMgr replyMsgWithId:_ssid replyId:_sshfxxid replyUid:_replyUid content:content completion:^(BOOL finished) {
        if (finished) {
            FCItemTableViewCellModel *model = [_model getItemModelByModelId:_ssid];
            FCICItemCellModel *cicm = [[FCICItemCellModel alloc] init];
            cicm.uid = USER.uid;
            cicm.content = txt;
            cicm.repliedUid = _replyUid;
            [model.itemViewModel.commentsViewModel.fcicItemCellModels addObject:cicm];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark -- private method
- (void)setupConstraints {
    
}

#pragma mark - FCItemTableViewCellDelegate
- (void)fcItemTableViewCell:(FCItemTableViewCell *)cell commentsDidTapped:(FCICItemCellModel *)model {
    DDLogInfo(@"cell tappped");
    if ([model.uid isEqualToString:USER.uid]) {
        return;
    }
    _ssid =  cell.model.itemViewModel.modelId;
    if (model.replied) {
        _sshfxxid = model.belongToId;
    } else {
        _sshfxxid = model.replyId;
    }
    _replyUid = model.uid;
    self.inputBar.textView.placeholder = [NSString stringWithFormat:@"回复%@", model.name];
    [self showTextInputbar];
    
}

- (void)fcItemTableViewCellCommentsRemark:(FCItemTableViewCell *)cell {
//    if ([cell.model.itemViewModel.uid isEqualToString:USER.uid]) {
//        return;
//    }
    _ssid =  cell.model.itemViewModel.modelId;
    _sshfxxid = nil;
    _replyUid = nil;
    self.inputBar.textView.placeholder = [NSString stringWithFormat:@"回复%@", cell.model.itemViewModel.name];
    [self showTextInputbar];
}


- (void)showTextInputbar {
    if (!self.inputBar.textView.isFirstResponder) {
        self.inputBar.textView.text = @"";
        [self.inputBar.textView becomeFirstResponder];
    }
}

#pragma mark - actions

- (void)rigthBtnTapped {
    FCNewPostViewController *postVC = [[FCNewPostViewController alloc] init];
    postVC.delegate = self;
    [self.navigationController pushViewController:postVC animated:YES];
}

#pragma mark - delegate
- (void)FCNewPostViewController:(FCNewPostViewController *)controller newPostSuccess:(BOOL)success {
    [USER.fcMgr getMsgsWithCur:1 pgSz:10 completion:^(BOOL finished, NSDictionary *result) {
        if (finished) {
            _model = [[FCModel alloc] initWithDict:result];
        }
        [self.tableView reloadData];
    }];
}

@end
