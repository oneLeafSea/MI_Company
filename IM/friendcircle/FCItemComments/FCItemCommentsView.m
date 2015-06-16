//
//  FCItemCommentsView.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCItemCommentsView.h"

#import <Masonry/Masonry.h>

#import "FCICItemCell.h"
#import "FCICRemarkTableViewCell.h"
#import "FCICItemCellModel.h"
#import "FCConstants.h"

@interface FCItemCommentsView() <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView *tablview;
@end

@implementation FCItemCommentsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if ([self setup] == NO) {
            return nil;
        }
    }
    return self;
}



#pragma mark - tableview delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getCellCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.model.fcicItemCellModels.count) {
        FCICRemarkTableViewCell * rCell = [tableView dequeueReusableCellWithIdentifier:@"FCICRemarkTableViewCell" forIndexPath:indexPath];
        return rCell;
    }
    
    FCICItemCellModel *model = [self.model.fcicItemCellModels objectAtIndex:indexPath.row];
    FCICItemCell *itemCell = [tableView dequeueReusableCellWithIdentifier:@"FCICItemCell" forIndexPath:indexPath];
    itemCell.model = model;
    return itemCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == self.model.fcicItemCellModels.count) {
        if ([self.delegate respondsToSelector:@selector(fcItemCommentsViewRemarkCellTapped:)]) {
            [self.delegate fcItemCommentsViewRemarkCellTapped:self];
        }
        return;
    }
    [self.delegate fcItemCommentsView:self didSelectAt:indexPath.row];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.model.fcicItemCellModels.count) {
        return FC_COMMENTS_REMARK_HEIGHT;
    }
     FCICItemCellModel *model = [self.model.fcicItemCellModels objectAtIndex:indexPath.row];
    CGFloat h = [FCICItemCell cellHeighWithModel:model];
    return h;
}


#pragma mark - private method

- (BOOL)setup {
    self.tablview = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
    self.tablview.delegate = self;
    self.tablview.dataSource = self;
    self.tablview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tablview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tablview registerClass:[FCICItemCell class] forCellReuseIdentifier:@"FCICItemCell"];
    [self.tablview registerClass:[FCICRemarkTableViewCell class] forCellReuseIdentifier:@"FCICRemarkTableViewCell"];
    self.tablview.scrollEnabled = NO;
    [self addSubview:self.tablview];
    [self.tablview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    return YES;
}

- (NSInteger)getCellCount {
    return self.model.fcicItemCellModels.count + 1;
}

+ (CGFloat)heightForCommentsView:(FCItemCommentsViewModel *)model {
    __block CGFloat height =  0;
    [model.fcicItemCellModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FCICItemCellModel *item = obj;
        CGFloat h = [FCICItemCell cellHeighWithModel:item];
        height += h;
    }];
    height += FC_COMMENTS_REMARK_HEIGHT;
    return height;
}

@end
