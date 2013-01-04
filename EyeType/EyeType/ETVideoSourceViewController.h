//
//  ETVideoSourceViewController.h
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSource.h"
#import "GLESImageView.h"
#import "ETVideoSourceViewModel.h"

@interface ETVideoSourceViewController : UIViewController<VideoSourceDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) GLESImageView *imageView;
@property (nonatomic, strong) VideoSource * videoSource;
@property (nonatomic, strong) ETVideoSourceViewModel *model;

- (void)showLoading;
- (void)stopLoading;
@end
