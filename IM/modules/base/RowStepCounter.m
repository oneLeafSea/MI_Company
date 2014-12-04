//
//  RowStepCounter.m
//  testGData
//
//  Created by guozw on 14-11-5.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RowStepCounter.h"

@implementation RowStepCounter

- (instancetype) initWithXmlElement:(GDataXMLElement *)e {
    if (self = [super initWithXmlElement:e]) {
        if (![self setup:e]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup:(GDataXMLElement *)e {
    
    return YES;
}


@end
