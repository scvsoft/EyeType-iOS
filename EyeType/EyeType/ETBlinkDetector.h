//
//  ETBlinkDetector.h
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETBlinkDetector : NSObject

+ (id)sharedInstance;

- (bool)detectActionInAreaOK;
- (bool)detectActionInAreaCancel;
- (void)prepareMatrixForAnalysis:(const cv::Mat&)inputImage;
- (void)setAreaOK:(cv::Rect)area;
- (void)setAreaCancel:(cv::Rect)area;
- (cv::Rect)areaOK;
- (cv::Rect)areaCancel;
- (cv::Mat)matOK;
- (cv::Mat)matCancel;
- (void)resetData;
- (void)setSensivity:(int)value;
- (int)sensitivity;

@end
