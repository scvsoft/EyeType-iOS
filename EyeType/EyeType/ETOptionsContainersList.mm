//
//  ETOptionsContainersList.m
//  EyeType
//
//  Created by scvsoft on 12/19/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETOptionsContainersList.h"

@interface ETOptionsContainersList()

#define FIRST_CONTAINER_TAG 999

@property (strong,nonatomic) UIScrollView* scroll;
@property (strong,nonatomic) NSMutableArray *containers;

@end

@implementation ETOptionsContainersList
@synthesize scroll;
@synthesize containers;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.scroll = [[UIScrollView alloc] initWithFrame:self.frame];
        [self addSubview:self.scroll];
        self.containers = [NSMutableArray array];
    }
    return self;
}

- (void)addOptionContainer:(ETOptionContainer *)container{
    ETOptionContainer* currentContainer = [self.containers lastObject];
    [currentContainer menuOff];
    
    CGFloat currentHeigth = 0;
    int lastTag = FIRST_CONTAINER_TAG;
    for (ETOptionContainer* optionContainer in self.containers) {
        currentHeigth += [optionContainer containerHeight];
        lastTag = optionContainer.tag;
    }
    container.tag = lastTag + 1;
    container.frame = CGRectMake([container margin], currentHeigth, self.frame.size.width - [container margin], [container containerHeight]);
    if (currentContainer != nil) {
        [container includeSeparator];
    }
    
    [self.scroll addSubview:container];
    [self.containers addObject:container];
    
    CGFloat totalHeight = currentHeigth + [container containerHeight];
    if (totalHeight > self.frame.size.height) {
        [UIView animateWithDuration:.5 animations:^{
            self.scroll.contentSize = CGSizeMake(self.frame.size.width, totalHeight);
            CGFloat scrollHeight = self.frame.size.height;
            self.scroll.contentOffset = CGPointMake(0, totalHeight - scrollHeight);
        }];
    }
}

- (void)selectNextItem{
    ETOptionContainer *option = [self.containers lastObject];
    [option selectNextItem];
}

- (void)moveToPreviousMenu{
    if ([self.containers count] > 1) {
        __block ETOptionContainer *menu = [self.containers lastObject];
        [UIView animateWithDuration:.5 animations:^{
            menu.alpha = 0.;
            CGFloat currentMenusHeight = 0;
            for (ETOptionContainer* optionContainer in self.containers) {
                currentMenusHeight += [optionContainer containerHeight];
            }
            currentMenusHeight -= [menu containerHeight];
            if (self.scroll.frame.size.height >= currentMenusHeight) {
                self.scroll.contentOffset = CGPointMake(0, 0);
            } else{
                currentMenusHeight -= self.scroll.frame.size.height;
                self.scroll.contentOffset = CGPointMake(0, currentMenusHeight);
            }
            
        } completion:^(BOOL finished){
            [menu removeFromSuperview];
            [self.containers removeLastObject];
            [menu resetValues];
        }];
    }
}

- (NSString *)selectedText{
    ETOptionContainer *option = [self.containers lastObject];
    return [option selectedText];
}

- (void)resetSelectedValue{
    ETOptionContainer *option = [self.containers lastObject];
    [option resetSelectedValue];
}

- (void)clear{    
    [self.containers makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.containers removeAllObjects];
    
    self.scroll.contentOffset = CGPointMake(0,0);
}

- (void)restartLoop{
    ETOptionContainer *container = [self.containers lastObject];
    [container restartLoop];
}

@end
