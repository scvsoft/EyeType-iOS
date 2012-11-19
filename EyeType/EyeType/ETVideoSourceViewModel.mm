//
//  ETVideoSourceViewModel.m
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETVideoSourceViewModel.h"
#import "ETBlinkDetector.h"

@interface ETVideoSourceViewModel(){
    cv::Mat outputMat;
}

@end

@implementation ETVideoSourceViewModel

- (cv::Mat)processFrame:(cv::Mat)frame{
    bool isMainQueue = dispatch_get_current_queue() == dispatch_get_main_queue();
    if (isMainQueue)
    {
        outputMat = [self detectAction:frame];
    }
    else
    {
        dispatch_sync( dispatch_get_main_queue(),
                      ^{
                          outputMat = [self detectAction:frame];
                      }
                      );
    }
    
    return outputMat;
}

- (void)executeOKAction{

}

- (void)executeCancelAction{
    
}

- (cv::Mat)detectAction:(cv::Mat)sourceMat{
    [[ETBlinkDetector sharedInstance] prepareMatrixForAnalysis:sourceMat];
    bool blinkOK =[[ETBlinkDetector sharedInstance] detectActionInAreaOK];
    bool blinkCancel = [[ETBlinkDetector sharedInstance] detectActionInAreaCancel];
    
    if (blinkOK != blinkCancel) {
        if (blinkOK) {
            [self executeOKAction];
        }
        
        if (blinkCancel) {
            [self executeCancelAction];
        }
    }
    
    return sourceMat;
}

@end
