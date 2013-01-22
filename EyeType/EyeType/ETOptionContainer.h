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

//initialize the container's values
- (void)initialize;

//add a new item to the container
- (void)addItemWithText:(NSString *)text;

//deselect the current item and select the next one
- (void)selectNextItem;

- (CGFloat)containerHeight;

//return the text from the current item selected
- (NSString *)selectedText;

//turn on selected to the specified item
- (void)selectItem:(ETItemView *)item;

//change the UI of the menu to show it as inactive
- (void)menuOff;

//insert a separator line
- (void)includeSeparator;

//return the margin that the container should use
- (int)margin;

//return the margin left that the container should use
- (int)marginLeft;

//turn on selected the first element from the current menu 
- (void)restartLoop;

@end
