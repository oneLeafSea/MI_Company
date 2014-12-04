//
//  Pages.h
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Page.h"
#import "GDataXMLNode.h"

@interface Pages : NSObject

- (instancetype)initWithXmlElement:(GDataXMLElement *)e;

@property BOOL              infiniteSwipe;
@property BOOL              swipeEnabled;
@property NSUInteger        selectedIndex;
@property(readonly) NSArray *pageArray;

@end
