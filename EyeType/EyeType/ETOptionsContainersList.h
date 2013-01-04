//
//  ETOptionsContainersList.h
//  EyeType
//
//  Created by scvsoft on 12/19/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETOptionContainer.h"

@interface ETOptionsContainersList : UIView

- (void)addOptionContainer:(ETOptionContainer *)container;
- (void)selectNextItem;
- (void)moveToPreviousMenu;
- (NSString *)selectedText;
- (void)resetSelectedValue;
- (void)clear;
- (void)restartLoop;
@end
