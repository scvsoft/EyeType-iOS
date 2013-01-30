//
//  ETImageScrollView.m
//  EyeType
//
//  Created by Hernan on 1/16/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import "ETImageScrollView.h"

@interface ETImageScrollView() <UIScrollViewDelegate> {
    UIImageView *_imageView;
}

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ETImageScrollView

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }

    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    
    _imageView.frame = frameToCenter;
}

- (void) displayImage: (UIImage *) image {
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    self.imageView = [[UIImageView alloc] initWithImage: image];
    [self addSubview: self.imageView];
  
    // Uncomment the next line to allow zooming (not requried by default)
//    [self configureForImageSize: image.size];
}

- (void) configureForImageSize: (CGSize) imageSize {
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds: imageSize];
    self.zoomScale = self.minimumZoomScale;
}

- (void) setMaxMinZoomScalesForCurrentBounds: (CGSize) imageSize {
    CGSize boundsSize = self.bounds.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    
    BOOL imagePortrait = imageSize.height > imageSize.width;
    BOOL devicePotrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == devicePotrait ? xScale : MIN(xScale, yScale);
    
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    minScale = MIN(minScale, maxScale);
    
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = maxScale;
}

#pragma mark - UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView: (UIScrollView *) scrollView {
    return _imageView;
}

@end

