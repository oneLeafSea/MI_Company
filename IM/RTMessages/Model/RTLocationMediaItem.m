//
//  RTLocationMediaItem.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTLocationMediaItem.h"

#import "RTMessagesMediaPlaceholderView.h"
#import "RTMessagesMediaViewBubbleImageMasker.h"

@interface RTLocationMediaItem ()

@property (strong, nonatomic) UIImage *cachedMapSnapshotImage;

@property (strong, nonatomic) UIImageView *cachedMapImageView;

- (void)createMapViewSnapshotForLocation:(CLLocation *)location
                        coordinateRegion:(MKCoordinateRegion)region
                   withCompletionHandler:(RTLocationMediaItemCompletionBlock)completion;

@end

@implementation RTLocationMediaItem

#pragma mark - Initialization

- (instancetype)initWithLocation:(CLLocation *)location {
    self = [super init];
    if (self) {
        [self setLocation:location withCompletionHandler:nil];
    }
    return self;
}

- (void)dealloc
{
    _location = nil;
    _cachedMapSnapshotImage = nil;
    _cachedMapImageView = nil;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedMapImageView = nil;
}


#pragma mark - Setters

- (void)setLocation:(CLLocation *)location
{
    [self setLocation:location withCompletionHandler:nil];
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedMapSnapshotImage = nil;
    _cachedMapImageView = nil;
}

#pragma mark - Map snapshot


- (void)setLocation:(CLLocation *)location withCompletionHandler:(RTLocationMediaItemCompletionBlock)completion
{
    [self setLocation:location region:MKCoordinateRegionMakeWithDistance(location.coordinate, 500.0, 500.0) withCompletionHandler:completion];
}

- (void)setLocation:(CLLocation *)location region:(MKCoordinateRegion)region withCompletionHandler:(RTLocationMediaItemCompletionBlock)completion
{
    _location = [location copy];
    _cachedMapSnapshotImage = nil;
    _cachedMapImageView = nil;
    
    if (_location == nil) {
        return;
    }
    
    [self createMapViewSnapshotForLocation:_location
                          coordinateRegion:region
                     withCompletionHandler:completion];
}

- (void)createMapViewSnapshotForLocation:(CLLocation *)location
                        coordinateRegion:(MKCoordinateRegion)region
                   withCompletionHandler:(RTLocationMediaItemCompletionBlock)completion
{
    NSParameterAssert(location != nil);
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = region;
    options.size = [self mediaViewDisplaySize];
    options.scale = [UIScreen mainScreen].scale;
    
    MKMapSnapshotter *snapShotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    [snapShotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
              completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                  if (error) {
                      NSLog(@"%s Error creating map snapshot: %@", __PRETTY_FUNCTION__, error);
                      return;
                  }
                  
                  MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
                  CGPoint coordinatePoint = [snapshot pointForCoordinate:location.coordinate];
                  UIImage *image = snapshot.image;
                  
                  UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
                  {
                      [image drawAtPoint:CGPointZero];
                      [pin.image drawAtPoint:coordinatePoint];
                      self.cachedMapSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
                  }
                  UIGraphicsEndImageContext();
                  
                  if (completion) {
                      dispatch_async(dispatch_get_main_queue(), completion);
                  }
              }];
}


#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.location == nil || self.cachedMapSnapshotImage == nil) {
        return nil;
    }
    
    if (self.cachedMapImageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.cachedMapSnapshotImage];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [RTMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedMapImageView = imageView;
    }
    
    return self.cachedMapImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    RTLocationMediaItem *locationItem = (RTLocationMediaItem *)object;
    
    return [self.location isEqual:locationItem.location];
}

- (NSUInteger)hash
{
    return super.hash ^ self.location.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: location=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.location, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CLLocation *location = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(location))];
        [self setLocation:location withCompletionHandler:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.location forKey:NSStringFromSelector(@selector(location))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    RTLocationMediaItem *copy = [[[self class] allocWithZone:zone] initWithLocation:self.location];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
