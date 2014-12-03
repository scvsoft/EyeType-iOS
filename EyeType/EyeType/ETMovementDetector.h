//
//  ETMovementDetector.h
//  EyeType
//
//  Created by scvsoft on 11/22/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETBlinkDetector.h"

@protocol ETMovementDetectorDelegate;

typedef NS_ENUM(NSInteger, ETMovementSection) {
    ETMovementSection1 = 0,
    ETMovementSection2
};

@interface ETMovementDetector : NSObject

#ifdef __cplusplus
- (cv::Mat)detectAction:(cv::Mat)sourceMat;
- (void)proccess:(cv::Mat)inputMat;
#endif

@property (nonatomic,strong) id<ETMovementDetectorDelegate> delegate;

@end

@protocol ETMovementDetectorDelegate <NSObject>

- (void)movementDetector:(ETMovementDetector *)detector didMovementDetected:(ETMovementSection)section;
- (BOOL)movementDetectorWillStart;

#ifdef __cplusplus
- (cv::Mat)movementDetector:(ETMovementDetector *)detector DidFinishWithMat:(cv::Mat)sourceMat;
#endif

@end
