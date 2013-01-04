//
//  ETVideoSourceViewController.m
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETVideoSourceViewController.h"

@interface ETVideoSourceViewController ()

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;

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
    self.videoSource.delegate = self;
}

- (void)showLoading{
    if (self.activityIndicator == nil) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    
    CGFloat x = self.containerView.frame.size.width / 2;
    CGFloat y = self.containerView.frame.size.height / 2;
    self.activityIndicator.center = CGPointMake(x, y);
    
    [self.containerView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopLoading{
    [self.activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
}

#pragma mark - VideoSourceDelegate

//The current frame is received as parameter
- (void) frameCaptured:(cv::Mat) frame{
    cv::Mat resultMat = [self.model processFrame:frame];
    
    if (self.containerView) {
        if ([self.activityIndicator isAnimating] && !resultMat.empty()){
            [self stopLoading];
        }
        
        [_imageView drawFrame:resultMat];
    }
}

@end
