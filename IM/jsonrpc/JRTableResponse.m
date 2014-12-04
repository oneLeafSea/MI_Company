//
//  JRTableResponse.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRTableResponse.h"
#import "NSJSONSerialization+StrDictConverter.h"
#import "LogLevel.h"

@implementation JRTableResponse




#pragma mark - JRResponseDelegate

/**
[
 { "l":l_val                    // label
   "n":n_val                    // name
   "v":v_val                    // value
   "a":a_val                    // anchor
   "show":bool                  // visualable
  }
    ...
 ]
 **/
- (BOOL)handleResult:(NSArray *) result {
    return YES;
}


@end
