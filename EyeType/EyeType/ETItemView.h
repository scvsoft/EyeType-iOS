//
//  ETOptionView.h
//  EyeType
//
//  Created by scvsoft on 12/14/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETItemView : UIView

- (id)initWithOptionText:(NSString *)option inX:(int)x Y:(int)y useBold:(BOOL)useBold;

// change the UI from the item to show it as selected
- (void)select;

// change the UI from the item to show it as deselected
- (void)deselect;

// change the UI from the item to show it as selected inactive
- (void)inactiveSelected;

// change the UI from the item to show it as selected inactive
- (void)inactive;

//return the item text
- (NSString *)description;

//return the color for the item when it is selected
- (UIColor *)textColorSelected;

//return the estimated size for an item with an specific text
+ (CGSize)estimatedSizeForText:(NSString *)text;
@end
