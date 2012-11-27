//
//  ETMovementDetector.m
//  EyeType
//
//  Created by scvsoft on 11/22/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMovementDetector.h"

@implementation ETMovementDetector

- (cv::Mat)detectAction:(cv::Mat)sourceMat{
    [self.delegate movementDetectorWillStart];
    [self proccess:sourceMat];
    sourceMat = [self.delegate movementDetector:self DidFinishWithMat:sourceMat];
    
    return sourceMat;
}

- (void)proccess:(cv::Mat)inputMat{
    NSException *exception = [NSException exceptionWithName: @"NotImplemented"
                                                     reason: @"Not implemented"
                                                   userInfo: nil];
    @throw exception;
}

@end
