//
//  GLESImageView.h
//  GesturesRecognitionFramework
//
//  Created by scvsoft on 10/22/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface GLESImageView : UIView

- (void)drawFrame:(cv::Mat) bgraFrame;

@end
