//
//  GLESImageView.h
//  GesturesRecognitionFramework
//
//  Created by scvsoft on 10/22/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

@interface GLESImageView : UIView

#ifdef __cplusplus
- (void)drawFrame:(cv::Mat) bgraFrame;
#endif

@end
