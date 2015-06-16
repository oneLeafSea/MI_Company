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

#import "FCItemTableViewCell.h"


@interface FriendCircleViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

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
}

#pragma mark -- tableview delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FCItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FCItemTableViewCell" forIndexPath:indexPath];
    cell.model = [self getCellModel];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FCItemTableViewCell heightForCellModel:[self getCellModel]];
}

- (FCItemTableViewCellModel *) getCellModel {
    FCICItemCellModel *commentsItemCellModel = [[FCICItemCellModel alloc] init];
    commentsItemCellModel.name = @"郭志伟";
    commentsItemCellModel.uid = @"gzw";
    commentsItemCellModel.content = @"太棒了！";
    commentsItemCellModel.repliedName = @"李维";
    commentsItemCellModel.repliedUid = @"liwei";
    
    
    FCIImagesitemCollectionViewCellModel *imgCollectionCellModel = [[FCIImagesitemCollectionViewCellModel alloc] init];
    imgCollectionCellModel.imgurl = [[NSURL alloc] initFileURLWithPath:@"http://a2.att.hudong.com/78/39/19300001363696131588399847654.jpg"] ;
    
    FCIImagesitemCollectionViewCellModel *imgCollectionCellModel1 = [[FCIImagesitemCollectionViewCellModel alloc] init];
    imgCollectionCellModel.imgurl = [[NSURL alloc] initFileURLWithPath:@"http://a2.att.hudong.com/78/39/19300001363696131588399847654.jpg"] ;
    
    FCIImagesitemCollectionViewCellModel *imgCollectionCellModel2 = [[FCIImagesitemCollectionViewCellModel alloc] init];
    imgCollectionCellModel.imgurl = [[NSURL alloc] initFileURLWithPath:@"http://a2.att.hudong.com/78/39/19300001363696131588399847654.jpg"] ;
    
    FCIImagesitemCollectionViewCellModel *imgCollectionCellModel3 = [[FCIImagesitemCollectionViewCellModel alloc] init];
    imgCollectionCellModel.imgurl = [[NSURL alloc] initFileURLWithPath:@"http://a2.att.hudong.com/78/39/19300001363696131588399847654.jpg"];
    
    FCIImagesitemCollectionViewCellModel *imgCollectionCellModel4 = [[FCIImagesitemCollectionViewCellModel alloc] init];
    imgCollectionCellModel.imgurl = [[NSURL alloc] initFileURLWithPath:@"http://a2.att.hudong.com/78/39/19300001363696131588399847654.jpg"];
    
    FCIImagesitemCollectionViewCellModel *imgCollectionCellModel5 = [[FCIImagesitemCollectionViewCellModel alloc] init];
    imgCollectionCellModel.imgurl = [[NSURL alloc] initFileURLWithPath:@"http://a2.att.hudong.com/78/39/19300001363696131588399847654.jpg"];
    
    FCIImagesitemCollectionViewCellModel *imgCollectionCellModel6 = [[FCIImagesitemCollectionViewCellModel alloc] init];
    imgCollectionCellModel.imgurl = [[NSURL alloc] initFileURLWithPath:@"http://a2.att.hudong.com/78/39/19300001363696131588399847654.jpg"];
    
    FCIImagesitemCollectionViewCellModel *imgCollectionCellModel7 = [[FCIImagesitemCollectionViewCellModel alloc] init];
    imgCollectionCellModel.imgurl = [[NSURL alloc] initFileURLWithPath:@"http://a2.att.hudong.com/78/39/19300001363696131588399847654.jpg"];
    
    
    FCItemImagesViewModel *imgsViewModel = [[FCItemImagesViewModel alloc] init];
    imgsViewModel.collectionCellModels = @[imgCollectionCellModel, imgCollectionCellModel1, imgCollectionCellModel2, imgCollectionCellModel3, imgCollectionCellModel4, imgCollectionCellModel5, imgCollectionCellModel6, imgCollectionCellModel7];
    
    FCItemCommentsViewModel *commentsViewModel = [[FCItemCommentsViewModel alloc] init];
    commentsViewModel.fcicItemCellModels = [[NSMutableArray alloc] initWithArray:@[commentsItemCellModel]];
//
    FCItemViewModel *itemViewModel = [[FCItemViewModel alloc] init];
    itemViewModel.commentsViewModel = commentsViewModel;
    itemViewModel.imgViewModel = imgsViewModel;
    itemViewModel.name = @"郭志伟";
    itemViewModel.position = @"苏州市";
    itemViewModel.time = [NSDate timeAgoSinceDate:[NSDate date]];
    itemViewModel.content = @"这是个测试这是个测试这是个测试这是个测试这是个测试这是个测试这是个测试这是个测试这是个测试这是个测试";
    itemViewModel.avatarImg = @"avatar_default";
    
    
    FCItemTableViewCellModel *itemCellModel = [[FCItemTableViewCellModel alloc] init];
    itemCellModel.itemViewModel = itemViewModel;
    return itemCellModel;
}

#pragma mark -- private method
- (void)setupConstraints {
    
}
@end
