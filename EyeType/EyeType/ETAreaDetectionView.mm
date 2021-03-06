//
//  ETAreaDetectionView.m
//  EyeType
//
//  Created by scvsoft on 11/27/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETAreaDetectionView.h"
#define HORIZ_SWIPE_DRAG_MIN  12
#define VERT_SWIPE_DRAG_MAX    4
#define VIDEO_WIDTH 192
#define VIDEO_HEIGHT 144

@interface ETAreaDetectionView(){
    void *cacheBitmap;
    CGContextRef cacheContext;
    float hue;
}

@property (nonatomic,strong) NSMutableArray* points;

@end

@implementation ETAreaDetectionView
@synthesize points;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *initialTouch = [touches anyObject];
    self.points = [NSMutableArray array];
    [self.points addObject:[NSValue valueWithCGPoint:[initialTouch locationInView:self]]];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self.points addObject:[NSValue valueWithCGPoint:[touch locationInView:self]]];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    cv::Rect area = [self calculateArea];
    [self.delegate areaDetectionView:self didDetectArea:area];
    
    [self.points removeAllObjects];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.points removeAllObjects];
    [self setNeedsDisplay];
}

- (cv::Rect)calculateArea{
    if ([self.points count] >= 2) {
        float maxX = 0;
        float maxY = 0;
        float minX = NSNotFound;
        float minY = NSNotFound;
        for (NSValue *value in self.points) {
            CGPoint point = [value CGPointValue];
            if (point.x < minX && point.x >= 0) {
                minX = point.x;
            }
            if (point.y < minY && point.y >= 0) {
                minY = point.y;
            }
            if (point.x > maxX && point.x <= self.frame.size.width) {
                maxX = point.x;
            }
            if (point.y > maxY && point.y <= self.frame.size.height) {
                maxY = point.y;
            }
        }
        
        CGFloat deltaX = self.frame.size.width / VIDEO_WIDTH;
        CGFloat deltaY = self.frame.size.height / VIDEO_HEIGHT;
        
        return cv::Rect(cv::Point(minX/deltaX, minY/deltaY), cv::Point(maxX/deltaX, maxY/deltaY));
    }
    
    return cv::Rect(cv::Point(0,0),cv::Point(0,0));
}

- (void) drawRect:(CGRect)rect {
    if([self.points count] > 0){
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        hue += 0.005;
        if(hue > 1.0) hue = 0.0;
        UIColor *color = [UIColor colorWithHue:hue saturation:0.7 brightness:1.0 alpha:1.0];
        
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, 8);
        
        CGPoint point = [[self.points objectAtIndex:0] CGPointValue];
        CGContextMoveToPoint(context, point.x, point.y);
        for (NSValue *value in self.points) {
            point = [value CGPointValue];
            CGContextAddLineToPoint(context, point.x, point.y);
            CGContextMoveToPoint(context, point.x, point.y);
        }
        
        CGContextStrokePath(context);
    }
}

@end
