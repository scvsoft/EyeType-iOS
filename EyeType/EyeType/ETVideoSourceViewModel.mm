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

//This method will decide based on the input type model which kind of movement detector initialize
- (void)configureMovementDetector{
    if ([[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeOneSource) {
        self.movementDetector = [[ETMovementDetectorSingleArea alloc] init];
        self.movementDetector.delegate = self;
    } else if([[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeTwoSources){
        self.movementDetector = [[ETMovementDetectorDualArea alloc] init];
        self.movementDetector.delegate = self;
    }
}

//This method is resposible of start detection, it return the frame proccessed
- (cv::Mat)processFrame:(cv::Mat)frame{
    bool isMainQueue = dispatch_get_current_queue() == dispatch_get_main_queue();
    if (isMainQueue)
        outputMat = [self.movementDetector detectAction:frame];
    else
        dispatch_sync( dispatch_get_main_queue(),
                      ^{
                          outputMat = [self.movementDetector detectAction:frame];
                      });
    
    return outputMat;
}

//this method is the resposible of decide what action should be executed
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

//This method must be overrided, it is executed when an action in the "OK" section is detected
- (void)executeOKAction{
    NSException *exception = [NSException exceptionWithName: @"NotImplemented"
                                                     reason: @"Not implemented"
                                                   userInfo: nil];
    @throw exception;
}

//This method must be overrided, it is executed when an action in the "OK" section is detected
- (void)executeCancelAction{
    NSException *exception = [NSException exceptionWithName: @"NotImplemented"
                                                     reason: @"Not implemented"
                                                   userInfo: nil];
    @throw exception;
}

//This method should be overrided
- (BOOL)movementDetectorWillStart{
    return YES;
}

//This method should be overrided
- (cv::Mat)movementDetector:(ETMovementDetector *)detector DidFinishWithMat:(cv::Mat)sourceMat{
    return sourceMat;
}

@end
