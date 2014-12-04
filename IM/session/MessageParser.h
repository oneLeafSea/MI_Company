//
//  MessageParser.h
//  WH
//
//  Created by 郭志伟 on 14-10-12.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@protocol MessageParserDelegate;

typedef NS_ENUM(NSUInteger, MessageParserFormatter) {
    MessageParserFormatterBson = 0,
    MessageParserFormatterXML = 1,
    MessageParserFormatterJson = 2
};

typedef NS_ENUM(NSUInteger, MessageParserError) {
    MessageParserErrorStream = 0
};

@interface MessageParser : NSObject

- (instancetype)initWithParserFormat:(MessageParserFormatter) formater;


- (void) parseBuf:(const uint8_t *)buf len:(NSUInteger)len;



@property (weak) id<MessageParserDelegate> delegate;
@end

@protocol MessageParserDelegate <NSObject>

- (void)parser:(MessageParser *)parser message:(Message *)msg;
- (void)parser:(MessageParser *)parser Error:(NSError *)err;
- (void)parserHbRecved;

@end