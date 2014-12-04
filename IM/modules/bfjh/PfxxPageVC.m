//
//  PfxxPageVC.m
//  dongrun_beijing
//
//  Created by guozw on 14-11-3.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "PfxxPageVC.h"
#import "PagesMgrViewController.h"

@interface PfxxPageVC ()<SwipeContainerChildItem>

@end

typedef XLFormDescriptor Form;
typedef XLFormSectionDescriptor Sect;
typedef XLFormRowDescriptor Row;


@implementation PfxxPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) initializeForm:(Form *)form {
    Sect *section = [self newSectionWithTitle:@"基本信息"];
    Row *row = [self newTextWithTag:@"BFBH" Title:@"拜访编号:" Placeholder:nil];
    [section addFormRow:row];
    row = [self newTextWithTag:@"BFMD" Title:@"拜访目的:" Placeholder:nil];
    [section addFormRow:row];
    
    row = [self newTextWithTag:@"BFKH" Title:@"拜访客户:" Placeholder:nil];
    [section addFormRow:row];
    
    row = [self newTextWithTag:@"LXR" Title:@"联系人:" Placeholder:nil];
    [section addFormRow:row];
    [form addFormSection:section];
    
    
    section = [self newSectionWithTitle:@"其他"];
    row = [self newTextViewWithTag:@"BFNR" Title:@"拜访内容:" Placeholder:nil];
    [section addFormRow:row];
    
    row = [self newTextViewWithTag:@"BFBZ" Title:@"拜访备注:" Placeholder:nil];
    [section addFormRow:row];
    
    row = [self newTextViewWithTag:@"JHDP" Title:@"计划点评:" Placeholder:nil];
    [section addFormRow:row];
    
    [section addFormRow:row];
    row.value = @(123123123);
    row.disabled = YES;


    [form addFormSection:section];
    return YES;
}

- (BOOL) VerifyData {
    return YES;
}

- (BOOL) SaveData {
    return YES;
}

- (NSString *)nameForPageContainer:(PagesMgrViewController *)swipeContainer {
    return @"拜访信息";
}

@end
