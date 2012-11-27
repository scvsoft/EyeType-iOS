//
//  ETMovementDetectorSingleArea.m
//  EyeType
//
//  Created by scvsoft on 11/22/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMovementDetectorSingleArea.h"

@implementation ETMovementDetectorSingleArea

- (void)proccess:(cv::Mat)inputMat{
    [[ETBlinkDetector sharedInstance] prepareMatrixForAnalysis:inputMat];
    bool blinkOK =[[ETBlinkDetector sharedInstance] detectActionInAreaOK];

    if (blinkOK) {
        [self.delegate movementDetector:self didMovementDetected:ETMovementSection1];
    }
}

@end
