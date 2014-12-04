//
//  JRTextResponse.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRResponse.h"

@interface JRTextResponse : JRResponse

- (BOOL)handleResult:(NSString *) result;

@property(readonly) NSString *text;

@end
