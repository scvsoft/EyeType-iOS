//
//  ETRect.h
//  EyeType
//
//  Created by scvsoft on 11/21/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

@interface ETRect : NSObject

- (id)initWithRect:(cv::Rect)rect;
- (cv::Rect)rect;

@end
