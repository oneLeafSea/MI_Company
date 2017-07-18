//
//  Hb.h
//  WH
//
//  Created by guozw on 14-10-13.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutputStream.h"

@interface Hb : NSObject

- (instancetype)initWithOutputStream:(OutputStream *)stream;
- (void)start;
- (void)stop;
- (void)resetStick;
@end
