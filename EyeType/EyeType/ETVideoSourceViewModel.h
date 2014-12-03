//
//  ETVideoSourceViewModel.h
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMovementDetector.h"
#import "ETMovementDetectorDualArea.h"
#import "ETMovementDetectorSingleArea.h"

@interface ETVideoSourceViewModel : NSObject<ETMovementDetectorDelegate>

@property(nonatomic,strong) ETMovementDetector* movementDetector;

#ifdef __cplusplus
- (cv::Mat)processFrame:(cv::Mat)frame;
#endif

- (void)executeOKAction;
- (void)executeCancelAction;
- (void)configureMovementDetector;

@end
