//
//  ETMenuValue.m
//  EyeType
//
//  Created by scvsoft on 11/23/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMenuValue.h"

@interface ETMenuValue()
@property (nonatomic,assign) BOOL returnOptions;

@end

@implementation ETMenuValue
@synthesize title;
@synthesize menu;
@synthesize returnOptions;
@synthesize menuActionSelector;

- (id)init{
    self = [super init];
    if (self) {
        self.menu = [[OrderedDictionary alloc] init];
        self.returnOptions = YES;
    }
    
    return self;
}

- (BOOL)returnOptions{
    return returnOptions;
}

- (void)reset{
    self.returnOptions = YES;
}

- (void)selectCurrentOption{
    self.returnOptions = NO;
}

//Return a list with the all selectable options/values
- (NSArray *)availableValues:(NSString *)selectedOption{
    if (self.returnOptions) 
        return [self.menu allKeys];
    else
        return [self.menu objectForKey:selectedOption];
}

@end
