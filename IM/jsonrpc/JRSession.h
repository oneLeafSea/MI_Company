//
//  JRSession.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRReqest.h"
#import "JRResponse.h"

@interface JRSession : NSObject

- (instancetype) initWithUrl:(NSURL *)url;

- (void) request:(JRReqest *)req
         success:(void(^)(JRReqest *request, JRResponse * resp))success
         failure:(void(^)(JRReqest *request, NSError *error))failure
          cancel:(void(^)(JRReqest *request))cancel;

- (void) cancel;
@end
