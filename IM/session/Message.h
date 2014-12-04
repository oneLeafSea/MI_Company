//
//  message.h
//  WH
//
//  Created by 郭志伟 on 14-10-12.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeMessage         = 0,
    MessageTypeRequest         = 1,
    MessageTypeResponse        = 2,
    MessageTypePush            = 3
};

@interface Message : NSObject

//- (instancetype)initWithType:(UInt32)type msgType:(UInt32)msgType;

@property(nonatomic, assign) UInt32             type;
@property(nonatomic)         UInt32             msgType;

@end

@interface Message (Tool)

- (NSString *)uuid;

- (NSData *)bsonData:(NSDictionary *)dict;

- (NSDictionary *)decodeBsonData:(NSData *)bsonData;

- (id)jsonDictFromString:(NSString *)jsonString;

- (NSData *)jsonDataFromDict:(NSDictionary *)dict;
- (NSData *)jsonDataFromArray:(NSArray *)array;

- (NSDictionary*)dictFromJsonData:(NSData *)data;
- (NSArray *)arrayFromJsonData:(NSData *)data;
@end
