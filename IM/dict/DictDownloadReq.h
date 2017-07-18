//
//  DictDownloadReq.h
//  WH
//
//  Created by guozw on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "DictRequest.h"

@interface DictDownloadReq : DictRequest



@property(nonatomic) NSDictionary *dictItem;
@property(nonatomic) NSString     *user;
@end
