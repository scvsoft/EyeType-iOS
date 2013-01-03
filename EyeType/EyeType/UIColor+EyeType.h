//
//  UIColor+EyeType.h
//  EyeType
//
//  Created by scvsoft on 1/2/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColor_EyeType)

+ (UIColor *)ETGreen;
+ (UIColor *)ETRed;
+ (UIColor *)ETYellow;
+ (UIColor *)ETGrey;
+ (UIColor *)ETLightBlue;
+ (UIColor *)ETPurple;
+ (UIColor *)ETLightGreen;
+ (UIColor *)ETSeparatorPatern;

- (cv::Scalar)scalarFromColor;

@end
