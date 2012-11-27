//
//  ETMovementDetector.h
//  EyeType
//
//  Created by scvsoft on 11/22/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

@protocol ETMovementDetectorDelegate;

enum ETMovementSection{
    ETMovementSection1 = 0,
    ETMovementSection2
};

@interface ETMovementDetector : NSObject

- (cv::Mat)detectAction:(cv::Mat)sourceMat;
- (void)proccess:(cv::Mat)inputMat;

@property (nonatomic,strong) id<ETMovementDetectorDelegate> delegate;

@end

@protocol ETMovementDetectorDelegate <NSObject>
- (void)movementDetector:(ETMovementDetector *)detector didMovementDetected:(ETMovementSection)section;
- (BOOL)movementDetectorWillStart;
- (cv::Mat)movementDetector:(ETMovementDetector *)detector DidFinishWithMat:(cv::Mat)sourceMat;

@end
