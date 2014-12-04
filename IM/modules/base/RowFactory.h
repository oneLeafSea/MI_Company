//
//  RowFactory.h
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Row.h"
#import "GDataXMLNode.h"

@interface RowFactory : NSObject

+ (Row *)produceRow:(GDataXMLElement *)e error:(NSError **)error;

@end
