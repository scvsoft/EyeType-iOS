//
//  ETAlertViewModel.m
//  EyeType
//
//  Created by scvsoft on 11/10/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETAlertViewModel.h"

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

- (cv::Mat)movementDetector:(ETMovementDetector *)detector DidFinishWithMat:(cv::Mat)sourceMat{
    cv::rectangle(sourceMat, [[ETBlinkDetector sharedInstance] areaOK], cv::Scalar(0,255,0,255));
    if ([[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeTwoSources) {
        cv::rectangle(sourceMat, [[ETBlinkDetector sharedInstance] areaCancel], cv::Scalar(0,0,255,255));
    }
    
    return sourceMat;
}

@end
