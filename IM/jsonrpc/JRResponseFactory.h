//
//  JRResponseFactory.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRResponse.h"

typedef NS_ENUM(NSInteger, JRResponseFactoryParseError) {
    JRResponseFactoryParseErrorTextResp = 0,
    JRResponseFactoryParseErrorBinResp = 1,
    JRResponseFactoryParseErrorTableResp = 2,
    JRResponseFactoryParseErrorListResp = 3,
    JRResponseFactoryParseErrorErrorResp = 4,
    JRResponseFactoryParseErrorUnkownResp = 5
};


@protocol JRResponseFactoryDelegate;

@interface JRResponseFactory : NSObject

+ (JRResponse *)parseResponseObject:(NSDictionary *) respData key:(NSString *) key iv:(NSString *) iv error:(NSError **)error;

@end


@protocol JRResponseFactoryDelegate <NSObject>
@required
- (void)parseResult:(NSString *)result;

@end