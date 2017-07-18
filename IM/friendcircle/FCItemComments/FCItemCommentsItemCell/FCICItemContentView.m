//
//  FCICItemContentView.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCICItemContentView.h"

@implementation FCICItemContentView


- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setText:(NSString *)text {
    _text = text;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    UIFont *font= [UIFont systemFontOfSize:13];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [self.text  drawInRect:rect withAttributes:attributes];
}

@end
