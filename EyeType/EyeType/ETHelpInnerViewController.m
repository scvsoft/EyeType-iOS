//
//  ETHelpInnerViewController.m
//  EyeType
//
//  Created by Hernan on 1/16/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import "ETHelpInnerViewController.h"
#import "ETImageScrollView.h"

@interface ETHelpInnerViewController () {
    UIImage *_image;
    NSInteger _index;
}

@property (strong, nonatomic) UIImage *image;

@end

@implementation ETHelpInnerViewController

+ (ETHelpInnerViewController *) instanceWithImage: (UIImage *) anImage {
    return [[self alloc] initWithImage: anImage];
}

- (id) initWithImage: (UIImage *) anImage {
    self = [super initWithNibName: nil bundle: nil];
    if (self) {
        _index = 0;
        self.image = anImage;
    }
    
    return self;
}

- (void) loadView {
    self.view = [[ETImageScrollView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
}

- (void) viewWillAppear: (BOOL) animated {
    [(ETImageScrollView *) self.view displayImage: self.image];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end
