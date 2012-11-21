//
//  ETRect.m
//  EyeType
//
//  Created by scvsoft on 11/21/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETRect.h"

@interface ETRect(){
    cv::Rect area;
}

@end

@implementation ETRect

- (id)initWithRect:(cv::Rect)rect
{
    self = [super init];
    if (self) {
        area = rect;
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        int x = [aDecoder decodeInt64ForKey:@"x"];
        int y = [aDecoder decodeInt64ForKey:@"y"];
        int w = [aDecoder decodeInt64ForKey:@"w"];
        int h = [aDecoder decodeInt64ForKey:@"h"];
        area = cv::Rect(cv::Point(x,y),cv::Size(w,h));
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt64:area.x forKey:@"x"];
    [aCoder encodeInt64:area.y forKey:@"y"];
    [aCoder encodeInt64:area.width forKey:@"w"];
    [aCoder encodeInt64:area.height forKey:@"h"];
}

- (cv::Rect)rect{
    return  area;
}

@end
