//
//  ETMenuValue.m
//  EyeType
//
//  Created by scvsoft on 11/23/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMenuValue.h"

@interface ETMenuValue()
@property (nonatomic,assign) int currentValueIndex;
@property (nonatomic,strong) NSString *selectedOption;
@property (nonatomic,assign) BOOL returnOptions;

@end

@implementation ETMenuValue
@synthesize title;
@synthesize menu;
@synthesize currentValueIndex;
@synthesize selectedOption;
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
    currentValueIndex = NSNotFound;
    selectedOption = nil;
}

- (void)selectCurrentOption{
    self.returnOptions = NO;
}

- (NSString *)selectedOption{
    return selectedOption;
}

- (NSString *)currentValue{
    if(self.returnOptions){
        int index = [[self.menu allKeys] indexOfObject:selectedOption];
        if (index != NSNotFound && index < [[self.menu allKeys] count]) {
            return [self.menu keyAtIndex:index];
        }
    } else{
        if (selectedOption != nil && currentValueIndex != NSNotFound) {
            NSArray *values = [self.menu objectForKey:selectedOption];
            return [values objectAtIndex:currentValueIndex];
        }
    }
    
    return nil;
}

- (NSString *)nextValue{
    if(self.returnOptions){
        int index = [[self.menu allKeys] indexOfObject:selectedOption];
        if (index == NSNotFound || (index + 1) >= [[self.menu allKeys] count]) {
            index = 0;
        } else{
            index++;
        }
        selectedOption = [self.menu keyAtIndex:index];
        return selectedOption;
    } else{
        if (selectedOption != nil){
            NSArray *values = [self.menu objectForKey:selectedOption];
            if (currentValueIndex == NSNotFound || (currentValueIndex + 1) >= [values count]) {
                currentValueIndex = 0;
            } else{
                currentValueIndex++;
            }
            
            return [values objectAtIndex:currentValueIndex];
        }
    }
    
    return nil;
}


@end
