//
//  UIColor+EyeType.mm
//  EyeType
//
//  Created by scvsoft on 1/2/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import "UIColor+EyeType.h"

@implementation UIColor (UIColor_EyeType)

+ (UIColor *)ETGreen{
    return [UIColor colorWithRed:193.f/255.f green:1.f blue:0.f alpha:1.f];
}

+ (UIColor *)ETRed{
    return [UIColor redColor];
}

+ (UIColor *)ETYellow{
    CGFloat green = 188. / 255.;
    
    return [UIColor colorWithRed:1.f green:green blue:0.f alpha:1.f];
}

+ (UIColor *)ETGrey{
    CGFloat grey = (157. / 255.);
    return [UIColor colorWithRed:grey green:grey blue:grey alpha:1.];
}

+ (UIColor *)ETLightBlue{
    CGFloat red = 32./255.;
    CGFloat green = 172./255.;
    CGFloat blue = 1.;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.];
}

+ (UIColor *)ETPurple{
    CGFloat red = 208./255.;
    CGFloat green = 124./255.;
    CGFloat blue = 252./255.;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.];
}

+ (UIColor *)ETLightGreen{
    CGFloat red = 34./255.;
    CGFloat green = 242./255.;
    CGFloat blue = 193./255.;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.];
}

+ (UIColor *)ETSeparatorPatern{
    UIImage *separatorLine = [UIImage imageNamed:@"dashed-line.png"];
    return [UIColor colorWithPatternImage:separatorLine];
}

- (cv::Scalar)scalarFromColor{
    CGColorRef colorref = [self CGColor];
    
    const CGFloat *components = CGColorGetComponents(colorref);
    CGFloat red = components[0] * 255;
    CGFloat green = components[1] * 255;
    CGFloat blue = components[2] * 255;
    CGFloat alpha = components[3] * 255;
    
    return cv::Scalar(blue,green,red,alpha);
}

@end
