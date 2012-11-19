//
//  ETAlertViewModel.m
//  EyeType
//
//  Created by scvsoft on 11/10/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETAlertViewModel.h"
#import "ETBlinkDetector.h"

@interface ETAlertViewModel()
@property(nonatomic,strong) id<ETAlertViewModelDelegate> delegate;
@end

@implementation ETAlertViewModel
@synthesize delegate;

- (id)initWithDelegate:(id<ETAlertViewModelDelegate>)Delegate{
    self = [super init];
    if(self){
        self.delegate = Delegate;
    }
    
    return self;
}

- (void)executeOKAction{
     [self.delegate alertViewModelDidOKActionExecute];
}

- (void)executeCancelAction{
    [self.delegate alertViewModelDidCancelActionExecute];
}

- (cv::Mat)detectAction:(cv::Mat)sourceMat {
    [super detectAction:sourceMat];
    cv::Mat outputMat;
    sourceMat.copyTo(outputMat);
    cv::rectangle(outputMat, [[ETBlinkDetector sharedInstance] areaOK], cv::Scalar(0,255,0,255));
    cv::rectangle(outputMat, [[ETBlinkDetector sharedInstance] areaCancel], cv::Scalar(255,0,0,255));
    
    return outputMat;
}

@end
