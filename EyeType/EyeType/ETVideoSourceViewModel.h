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

- (cv::Mat)processFrame:(cv::Mat)frame;
- (void)executeOKAction;
- (void)executeCancelAction;
- (void)configureMovementDetector;

@end
