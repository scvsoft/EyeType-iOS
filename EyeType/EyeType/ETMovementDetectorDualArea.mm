//
//  ETMovementDetectorDualArea.m
//  EyeType
//
//  Created by scvsoft on 11/22/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMovementDetectorDualArea.h"
#import "ETBlinkDetector.h"

@implementation ETMovementDetectorDualArea

- (void)proccess:(cv::Mat)inputMat{
    [[ETBlinkDetector sharedInstance] prepareMatrixForAnalysis:inputMat];
    bool blinkOK =[[ETBlinkDetector sharedInstance] detectActionInAreaOK];
    bool blinkCancel = [[ETBlinkDetector sharedInstance] detectActionInAreaCancel];
    
    if (blinkOK != blinkCancel) {
        if (blinkOK) {
            [self.delegate movementDetector:self didMovementDetected:ETMovementSection1];
        }
        
        if (blinkCancel) {
            [self.delegate movementDetector:self didMovementDetected:ETMovementSection2];
        }
    }
}

@end
