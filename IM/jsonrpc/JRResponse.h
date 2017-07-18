//
//  JRResponse.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JRResponseDelegate;

typedef NS_ENUM(NSUInteger, JRResponseType) {
    JRResponseTypeList  = 0,
    JRResponseTypeTable = 1,
    JRResponseTypeError = 2,
    JRResponseTypeText  = 3,
    JRResponseTypeBin   = 4
};

@interface JRResponse : NSObject

- (instancetype)initWithType:(JRResponseType)type
                         ext:(NSDictionary *)ext
                   timestamp:(NSString *)timestamp;

@property(readonly)  NSDictionary           *ext;
@property(readonly)  JRResponseType         type;
@property(readonly)  NSString               *timestamp;


@end

