//
//  RTLocationMediaItem.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef void (^RTLocationMediaItemCompletionBlock)(void);

#import "RTMediaItem.h"

@interface RTLocationMediaItem : RTMediaItem  <RTMessageMediaData, MKAnnotation, NSCoding, NSCopying>

@property (copy, nonatomic) CLLocation *location;

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;

- (instancetype)initWithLocation:(CLLocation *)location;

- (void)setLocation:(CLLocation *)location withCompletionHandler:(RTLocationMediaItemCompletionBlock)completion;

- (void)setLocation:(CLLocation *)location
             region:(MKCoordinateRegion)region withCompletionHandler:(RTLocationMediaItemCompletionBlock)completion;

@end
