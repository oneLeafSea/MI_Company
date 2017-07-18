//
//  FCNewPostViewController.m
//  IM
//
//  Created by 郭志伟 on 15/6/23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCNewPostViewController.h"
#import "FCNPTextTableViewCell.h"
#import "FCNPImagePickerTableViewCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "UIView+Toast.h"
#import "Utils.h"

@interface FCNewPostViewController() <UITableViewDelegate, UITableViewDataSource, FCNPImagePickerTableViewCellDelegate> {
    CGFloat _imgPickerCellHeigh;
}

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation FCNewPostViewController

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    self.navigationItem.title = @"发帖";
    [self setupTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnPressed)];
    _imgPickerCellHeigh = 111.0f;
}


- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[FCNPTextTableViewCell class] forCellReuseIdentifier:@"FCNPTextTableViewCell"];
    [self.tableView registerClass:[FCNPImagePickerTableViewCell class] forCellReuseIdentifier:@"FCNPImagePickerTableViewCell"];
}

- (void)rightBtnPressed {
    FCNPTextTableViewCell *txtCell = (FCNPTextTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    FCNPImagePickerTableViewCell *pickerCell = (FCNPImagePickerTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [txtCell.txtView resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    NSString *content = [Utils encodeBase64String:txtCell.text];
    [USER.fcMgr NewPostWithContent:content imgs:pickerCell.imgArray completion:^(BOOL finished) {
         [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        if (finished) {
            [self.view makeToast:@"上传成功."];
            [self.navigationController popViewControllerAnimated:YES];
            if ([self.delegate respondsToSelector:@selector(FCNewPostViewController:newPostSuccess:)]) {
                [self.delegate FCNewPostViewController:self newPostSuccess:YES];
            }
        } else {
            [self.view makeToast:@"上传失败."];
            if ([self.delegate respondsToSelector:@selector(FCNewPostViewController:newPostSuccess:)]) {
                [self.delegate FCNewPostViewController:self newPostSuccess:NO];
            }
        }
       
    }];
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        FCNPTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FCNPTextTableViewCell" forIndexPath:indexPath];
        cell.maxCharacterCount = 200;
        return cell;
    }
    
    if (indexPath.row == 1) {
        FCNPImagePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FCNPImagePickerTableViewCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.naviController = self.navigationController;
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"demo"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 120.0f;
    }
    return _imgPickerCellHeigh;
}

- (void)imagePickerTableViewCell:(FCNPImagePickerTableViewCell *)cell heightShouldChanged:(CGFloat)height {
    _imgPickerCellHeigh = height;
    [self.tableView reloadData];
}


@end
