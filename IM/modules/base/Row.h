//
//  Row.h
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface Row : NSObject {
@protected
    NSString *m_tag;
    NSString *m_type;
}

- (instancetype)initWithXmlElement:(GDataXMLElement *)e;

@property(readonly) NSString *tag;
@property NSString *title;
@property(readonly) NSString *type;
@property BOOL      disable;
@property           NSString *defaultValue;

@end
