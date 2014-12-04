//
//  JRReqCheckDictVersionParam.h
//  WH
//
//  Created by guozw on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRReqParam.h"

@interface JRReqCheckDictVersionParam : JRReqParam
- (instancetype) initWithToken:(NSString *)token key:(NSString *)key iv:(NSString *)iv;
@end
