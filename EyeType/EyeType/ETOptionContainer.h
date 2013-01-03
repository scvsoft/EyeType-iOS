//
//  ETOptionContainer.h
//  EyeType
//
//  Created by scvsoft on 12/14/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETItemView.h"

@interface ETOptionContainer : UIView<NSCopying> 
@property(nonatomic, assign) int currentX;
@property(nonatomic, assign) int currentY;
@property(nonatomic, assign) int currentViewTag;
@property(nonatomic, assign) int currentRow;
@property (nonatomic, strong) NSMutableArray *items;

- (void)addItemWithText:(NSString *)text;
- (void)selectNextItem;
- (void)resetSelectedValue;
- (void)resetValues;
- (CGFloat)containerHeight;
- (void)initialize;
- (NSString *)selectedText;
- (void)selectItem:(ETItemView *)item;
- (void)menuOff;
- (void)includeSeparator;
- (int)margin;
- (void)restartLoop;
@end
