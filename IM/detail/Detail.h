//
//  Detail.h
//  IM
//
//  Created by 郭志伟 on 15-3-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRListResponse.h"

@interface Detail : NSObject

- (instancetype)initWithResp:(JRListResponse *)resp;

@property (nonatomic) NSDictionary *data;
//@property(copy) NSString *uid;
//@property(copy) NSString *name;
//@property(copy) NSString *sex;
//@property(copy) NSString *age;
//@property(copy) NSString *birth;
//@property(copy) NSString *telephone;
//@property(copy) NSString *cellphone;
//@property(copy) NSString *email;
//@property(copy) NSString *address;
//@property(copy) NSString *position;

@end
