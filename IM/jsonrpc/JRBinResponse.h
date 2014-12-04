//
//  JRBinResponse.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRResponse.h"

@interface JRBinResponse : JRResponse


- (BOOL)handleResult:(NSData *) result;

@property(readonly) NSData *data;

@end
