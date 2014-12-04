//
//  Section.h
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface Section : NSObject

- (instancetype)initWithXmlElement:(GDataXMLElement *)e;

@property(readonly) NSString *title;

@property(readonly) NSArray *rows;
@end
