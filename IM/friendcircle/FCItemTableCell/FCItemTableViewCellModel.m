//
//  FCItemTableViewCellModel.m
//  IM
//
//  Created by 郭志伟 on 15/6/12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCItemTableViewCellModel.h"
#import "AppDelegate.h"

@implementation FCItemTableViewCellModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        if (![self parseDict:dict]) {
            self = nil;
        }
    }
    return self;
}

//{
//    addr = "\U6c5f\U82cf\U7701\U82cf\U5dde\U5e02\U5434\U4e2d\U533a\U661f\U6d77\U8857";
//    cjr = xyy;
//    cjrjgbm = 000203;
//    cjsj = "2015-05-15 17:11:48.437211";
//    content = "\U805a\U9910ing";
//    id = "e1c11421-5ddc-4bc9-aa2f-66b66ab3630b";
//    imgnum = 1;
//    lat = "31.316027";
//    lon = "120.679872";
//}

- (BOOL)parseDict:(NSDictionary *)dict {
    self.itemViewModel = [[FCItemViewModel alloc] init];
    self.itemViewModel.position = [dict objectForKey:@"addr"];
    self.itemViewModel.uid = [dict objectForKey:@"cjr"];
    self.itemViewModel.org = [dict objectForKey:@"cjrjgbm"];
    self.itemViewModel.time = [dict objectForKey:@"cjsj"];
    self.itemViewModel.content = [dict objectForKey:@"content"];
    self.itemViewModel.modelId = [dict objectForKey:@"id"];
    self.itemViewModel.imgNum = [dict objectForKey:@"imgnum"];
    self.itemViewModel.lat = [dict objectForKey:@"lat"];
    self.itemViewModel.lon = [dict objectForKey:@"lon"];
    return YES;
}

@end
