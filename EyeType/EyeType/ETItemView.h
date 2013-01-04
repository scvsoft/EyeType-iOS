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
- (void)select;
- (void)deselect;
- (NSString *)text;
+ (CGSize)estimatedSizeForText:(NSString *)text;
- (UIColor *)textColorSelected;
- (void)hideBorder;
- (void)inactive;

@end
