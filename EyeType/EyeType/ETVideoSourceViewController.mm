//
//  ETVideoSourceViewController.m
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETVideoSourceViewController.h"

@interface ETVideoSourceViewController ()

@end

@implementation ETVideoSourceViewController
@dynamic model;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Init the default view (video view layer)
    if (self.containerView) {
        self.imageView = [[GLESImageView alloc] initWithFrame:self.containerView.bounds];
        [self.imageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [self.containerView addSubview:self.imageView];
    }

    self.videoSource = [[VideoSource alloc] init];
//    self.videoSource.quality = videoQualityMedium;
    self.videoSource.delegate = self;
}

#pragma mark - VideoSourceDelegate

- (void) frameCaptured:(cv::Mat) frame{
    cv::Mat resultMat = [self.model processFrame:frame];
    
    if (self.containerView) {
        [_imageView drawFrame:resultMat];
    }
}

@end
