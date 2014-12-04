//
//  JRListResponse.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRResponse.h"

@interface JRListResponse : JRResponse

- (BOOL)handleResult:(NSArray *) result;

@property(readonly) NSArray *data;
@end
