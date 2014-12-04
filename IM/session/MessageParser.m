//
//  MessageParser.m
//  WH
//
//  Created by 郭志伟 on 14-10-12.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "MessageParser.h"

#import "ObjCMongoDB.h"
#import "NSMutableData+stream.h"
#import "Message.h"
#import "DataConstants.h"

#import "Pkg.h"
#import "MessageFactory.h"

#import "LogLevel.h"


static const NSUInteger kCacheCapacity = 1024;

#define kCacheLen           (m_cache.length)    // catche长度
#define kCacheMinLen        4                   // catche最小长度

#define kHBLen              4                   // heartbeat长度
#define kHBValue            0                   // heartbeat数值

//#define kDataLenSz          4                   // 数据长度大小
//#define kDataUnavailable    UINT32_MAX          // 数据长度不可用
//
//#define KDataTypeSz         4                   // 数据类型大小
//#define KDataTypeLen        4                   // 数据类型长度
//#define KDataTypeNone       0                   // 没有数据类型
//
//static const NSString* kDataSyncTimeKey = @"servertime";       // 返回时间的key


#define kBsonDataLen        (m_parsingPkg.dataLen - KDataTypeSz)



typedef NS_ENUM(NSUInteger, MessageParserStatus) {
    MessageParserStatusParsing = 1,
    MessageParserStatusEnd     = 2
};


@interface MessageParser() {
    MessageParserFormatter m_formatter;
    NSMutableData          *m_cache;
    MessageParserStatus    m_status;
    Pkg                    *m_parsingPkg;
    MessageFactory         *m_factory;
}

@end

@implementation MessageParser

- (instancetype)initWithParserFormat:(MessageParserFormatter) formater {
    if (self = [super init]) {
        m_formatter = formater;
        if (m_formatter != MessageParserFormatterBson) {
            DDLogWarn(@"MessageParser only support bson fmt. Support other fmt in later version.");
            return nil;
        }
        m_cache = [[NSMutableData alloc]initWithCapacity:kCacheCapacity];
        m_status = MessageParserStatusEnd;
        
        m_factory = [[MessageFactory alloc]init];
        m_parsingPkg = [[Pkg alloc]init];
        m_parsingPkg.delegate = m_factory;
    }
    return self;
}

#if DEBUG
- (void)dealloc {
    DDLogInfo(@"%@ dealloc", NSStringFromClass([self class]));
}
#endif


- (void) parseBuf:(const uint8_t *)buf len:(NSUInteger)len {
    [m_cache appendBytes:buf length:len];
//    DDLogInfo(@"m_cache length is %lu (0)", (unsigned long)m_cache.length);
    if (m_status == MessageParserStatusEnd) {
        while (kCacheLen >= kCacheMinLen) {
            if ([self handleHB]) {
                continue;
            }
            [self handleCommonData];
        }
    } else if (m_status == MessageParserStatusParsing) {
        [self handleCommonData];
    }

}

/*

- (void)parseStream2:(NSInputStream *)stream {
    uint8_t buf[4];
    BOOL suc = [self readStream:stream buf:buf len:4];
    
    UInt32 *p  = (UInt32 *)buf;
    UInt32 dataLen = ntohl(p[0]);
    if (dataLen == 0) {
        [self handleHB];
        return;
    }
    
    if (dataLen < 4 || dataLen > 1024*1024*10) {
        // error
    }
    
    suc = [self readStream:stream buf:buf len:4];
    if (!suc) {
        return;
    }
    
    p  = (UInt32 *)buf;
    UInt32 dataType = ntohl(p[0]);
    
    UInt32 buflen = dataLen - 4;
    if (buflen > 0) {
        uint8_t *buf = malloc(buflen * sizeof(uint8_t));
        BOOL suc = [self readStream:stream buf:buf len:buflen];
        if (suc) {
            if (![self handleData:buf len:buflen]) {
                free(buf);
            }
        }
        
    } else {
        [self handleNoData:dataType];
    }
    
    
}
 


- (void)handleNoData:(UInt32) dataType {
    
}

- (BOOL)handleData:(uint8_t *)buf len:(UInt32)buflen {
    return YES;
}

- (BOOL)readStream:(NSInputStream *)stream buf:(uint8_t *)buf len:(int)len{
    NSInteger read = [stream read:buf maxLength:len];
    if (read == -1) {
        return NO;
    }
    
    NSInteger left = len - read;
    while (left > 0) {
        read = [stream read:(buf + len - left) maxLength:left];
        if (read == -1) {
            return NO; //false
        }
        left = left - read;
    }
    return YES;
}
 
*/

- (BOOL)handleHB {
    UInt32 dataLen = [self dataLen];
    if (dataLen == 0) {
        [m_cache popLen:kDataLenSz];
        DDLogInfo(@"<-- HeartBeat");

        if ([self.delegate respondsToSelector:@selector(parserHbRecved)]) {
            [self.delegate parserHbRecved];
        }
        [self resetParsingPkg];
        return YES;
    }
    return NO;
}

- (void)handleCommonData {
    if (kCacheLen < kCacheMinLen) {
        return;
    }
    if (m_status == MessageParserStatusEnd) {
        m_parsingPkg.dataLen = [self dataLen];
        [m_cache popLen:kDataLenSz];
        

        if (m_parsingPkg.dataLen > 1024 * 1024 * 4) {  // 测试没有测试到。
            DDLogError(@"fatal error in parser receiving data dataLen bigger than 4M bytes! pkgLen:%u", (unsigned int)m_parsingPkg.dataLen);
            [m_cache popLen:m_cache.length];
            [self.delegate parser:self Error:[self parserError]];
            return;
        }

        if (kCacheLen < kCacheMinLen) {
            m_status = MessageParserStatusParsing;
            return;
        }
        m_parsingPkg.dataType = [self dataType];
        [m_cache popLen:KDataTypeSz];

        DDLogWarn(@"dataLen:%d, dataTypye:%x", (unsigned int)m_parsingPkg.dataLen, (unsigned int)m_parsingPkg.dataType);
        if (kCacheLen >= kBsonDataLen) {
            m_parsingPkg.data = [m_cache left:kBsonDataLen];
            [m_cache popLen:kBsonDataLen];
            Message *newMsg = [self callPkgDelegate];
            [self tellDelegateNewMsg:newMsg];
            [self resetParsingPkg];
            
        } else {
            m_status = MessageParserStatusParsing;
        }
    } else {
        if (m_parsingPkg.dataType == KDataTypeNone) { 
            m_parsingPkg.dataType = [self dataType];
            [m_cache popLen:KDataTypeSz];
        }
        if (kCacheLen >= kBsonDataLen) {
            m_parsingPkg.data = [m_cache left:kBsonDataLen];
            [m_cache popLen:kBsonDataLen];
            Message *newMsg = [self callPkgDelegate];
            [self tellDelegateNewMsg:newMsg];
            [self resetParsingPkg];
        }
    }
    
}

- (void)resetParsingPkg {
    m_parsingPkg.dataLen = kDataUnavailable;
    m_parsingPkg.dataType = KDataTypeNone;
    m_parsingPkg.data = nil;
    m_status = MessageParserStatusEnd;
}


- (Message *)callPkgDelegate {
    Message *msg = nil;
    if ([m_parsingPkg.delegate respondsToSelector:@selector(parsePkgWithType:data:)]) {
        msg =[m_parsingPkg.delegate parsePkgWithType:m_parsingPkg.dataType data:m_parsingPkg.data];
    }
    return msg;
}

- (NSError *)parserError {
    NSError *err = [[NSError alloc]initWithDomain:@"MessageParser" code:1 userInfo:@{@"Description" : @"fatal error in parser receiving data, dataLen bigger than 4M bytes!"}];
    return err;

}

- (UInt32)dataLen {
    UInt32 len = kDataUnavailable;
    [m_cache getBytes:&len length:sizeof(UInt32)];
    len = ntohl(len);
    return len;
}

- (UInt32)dataType {
    UInt32 type = kDataUnavailable;
    [m_cache getBytes:&type length:sizeof(UInt32)];
    type = ntohl(type);
    return type;
}

- (void)tellDelegateNewMsg:(Message *)newMsg {
    if (newMsg && [self.delegate respondsToSelector:@selector(parser:message:)]) {
        [self.delegate parser:self message:newMsg];
    }
}

- (NSError *)genStreamError {
    NSError *error = [[NSError alloc]initWithDomain:@"MessageParser" code:MessageParserErrorStream userInfo:@{@"server disconnect":@"the end of the buffer was reached"}];
    return error;
}

@end
