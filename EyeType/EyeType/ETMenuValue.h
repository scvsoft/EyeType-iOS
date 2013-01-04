//
//  ETMenuValue.h
//  EyeType
//
//  Created by scvsoft on 11/23/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "OrderedDictionary.h"

@interface ETMenuValue : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) OrderedDictionary* menu;
@property (nonatomic,assign) SEL menuActionSelector;

- (void)selectCurrentOption;
- (void)reset;
- (BOOL)returnOptions;
- (NSArray *)availableValues:(NSString *)optionSelected;

@end
