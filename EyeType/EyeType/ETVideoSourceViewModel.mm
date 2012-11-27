//
//  ETVideoSourceViewModel.m
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETVideoSourceViewModel.h"

@interface ETVideoSourceViewModel(){
    cv::Mat outputMat;
}

@end

@implementation ETVideoSourceViewModel
@synthesize movementDetector;

- (id)init{
    self = [super init];
    if (self) {
        [self configureMovementDetector];
    }
    
    return self;
}

- (void)configureMovementDetector{
    if ([[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeOneSource) {
        self.movementDetector = [[ETMovementDetectorSingleArea alloc] init];
        self.movementDetector.delegate = self;
    } else if([[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeTwoSources){
        self.movementDetector = [[ETMovementDetectorDualArea alloc] init];
        self.movementDetector.delegate = self;
    }
}

- (cv::Mat)processFrame:(cv::Mat)frame{
    bool isMainQueue = dispatch_get_current_queue() == dispatch_get_main_queue();
    if (isMainQueue)
    {
        outputMat = [self.movementDetector detectAction:frame];
    }
    else
    {
        dispatch_sync( dispatch_get_main_queue(),
                      ^{
                          outputMat = [self.movementDetector detectAction:frame];
                      });
    }
    
    return outputMat;
}

- (void)movementDetector:(ETMovementDetector *)detector didMovementDetected:(ETMovementSection)section{
    switch (section) {
        case ETMovementSection1:
            [self executeOKAction];
            break;
        case ETMovementSection2:
            [self executeCancelAction];
            break;
            
        default:
            break;
    }
}

- (void)executeOKAction{
    NSException *exception = [NSException exceptionWithName: @"NotImplemented"
                                                     reason: @"Not implemented"
                                                   userInfo: nil];
    @throw exception;
}

- (void)executeCancelAction{
    NSException *exception = [NSException exceptionWithName: @"NotImplemented"
                                                     reason: @"Not implemented"
                                                   userInfo: nil];
    @throw exception;
}

- (BOOL)movementDetectorWillStart{
    return YES;
}

- (cv::Mat)movementDetector:(ETMovementDetector *)detector DidFinishWithMat:(cv::Mat)sourceMat{
    return sourceMat;
}

@end
