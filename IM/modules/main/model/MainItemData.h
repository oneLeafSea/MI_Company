//
//  MainItemData.h
//  dongrun_beijing
//
//  Created by guozw on 14/11/6.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainItemData : NSObject

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imgName;

@property(readonly) NSString *name;
@property(readonly) NSString *imageName;

@end
