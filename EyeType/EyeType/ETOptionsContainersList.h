//
//  ETOptionsContainersList.h
//  EyeType
//
//  Created by scvsoft on 12/19/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETOptionContainer.h"

@interface ETOptionsContainersList : UIView

//add a new menue to the list
- (void)addOptionContainer:(ETOptionContainer *)container;

//deselect the current item and select the next one
- (void)selectNextItem;

//close the current menu and return to the previous one
- (void)moveToPreviousMenu;

//return the text from the current item selected
- (NSString *)selectedText;

//remove all the menus
- (void)clear;

//turn on selected the first element from the current menu 
- (void)restartLoop;

@end
