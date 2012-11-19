//
//  ETVideoSourceViewModel.h
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETVideoSourceViewModel : NSObject

- (cv::Mat)processFrame:(cv::Mat)frame;
- (cv::Mat)detectAction:(cv::Mat)sourceMat;

- (void)executeOKAction;
- (void)executeCancelAction;

@end
