//
//  ETValueContainer.h
//  EyeType
//
//  Created by scvsoft on 12/19/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETOptionContainer.h"

@interface ETValueContainer : ETOptionContainer
//turn on visible the container
- (void)show;

//turn on hide the values container
- (void)hide;

//prepare the container to contain new values removing all the previous  
- (void)resetValues;

//return YES if the container is currently visible
- (BOOL)isVisible;

@end
