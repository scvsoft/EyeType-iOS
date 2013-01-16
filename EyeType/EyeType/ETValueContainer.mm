//
//  ETValueContainer.m
//  EyeType
//
//  Created by scvsoft on 12/19/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETValueContainer.h"

#define VISIBLE_WIDTH 309.f
#define CONTAINER_TAG 9999
#define MAXIMUM_LIST_HEIGHT 273
#define FONT_NAME @"Calibri"
#define FONT_SIZE_PREVIEW 90.

@interface ETValueContainer()

@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UILabel *selectedLabel;
@end

@implementation ETValueContainer
@synthesize scroll;

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
        
        [self setBackgroundColor:[UIColor colorWithWhite:0. alpha:.6]];
        self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, MAXIMUM_LIST_HEIGHT)];
        [self addSubview:self.scroll];
        [self.scroll setBackgroundColor:[UIColor colorWithWhite:0. alpha:.2]];
        self.selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MAXIMUM_LIST_HEIGHT, 0, MAXIMUM_LIST_HEIGHT)];
        [self.selectedLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.selectedLabel];
    }
    
    return self;
}

- (void)initialize{
    [super initialize];
    
    self.tag = CONTAINER_TAG;
}

- (void)addItemWithText:(NSString *)text{
    if (self.currentViewTag == NSNotFound) {
        self.currentViewTag = 0;
    } else{
        self.currentViewTag++;
    }
    
    CGSize estimatedSize = [ETItemView estimatedSizeForText:text];
    if (estimatedSize.width + self.currentX > VISIBLE_WIDTH) {
        self.currentX = 0;
        self.currentRow++;
        self.currentY = self.currentRow * estimatedSize.height;
    }
    
    ETItemView *itemView = [[ETItemView alloc] initWithOptionText:text inX:self.currentX Y:self.currentY useBold:YES];
    itemView.tag = self.currentViewTag;
    [self.scroll addSubview:itemView];
    [self.items addObject:itemView];
    
    self.currentX += itemView.frame.size.width;
}

- (void)resetValues{
    for (UIView *view in self.items) {
        [view removeFromSuperview];
    }
    
    [self initialize];
}

- (void)show{
    if (self.scroll.frame.size.width == 0) {
        [UIView animateWithDuration:.5 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, VISIBLE_WIDTH, self.frame.size.height);
            self.scroll.frame = CGRectMake(0, 0, VISIBLE_WIDTH, MAXIMUM_LIST_HEIGHT);
            self.selectedLabel.frame = CGRectMake(0, MAXIMUM_LIST_HEIGHT, VISIBLE_WIDTH, MAXIMUM_LIST_HEIGHT);
        }];
    }
}

- (void)hide{
    if (self.scroll.frame.size.width == VISIBLE_WIDTH) {
        [UIView animateWithDuration:.5 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 0, self.frame.size.height);
            self.scroll.frame = CGRectMake(0, 0, 0, MAXIMUM_LIST_HEIGHT);
            self.selectedLabel.frame = CGRectMake(0, MAXIMUM_LIST_HEIGHT, 0, MAXIMUM_LIST_HEIGHT);
            
            for (ETItemView *item in self.items) {
                [item removeFromSuperview];
            }
            [self.items removeAllObjects];
        }];
    }
}

- (BOOL)isVisible{
    return self.frame.size.width == VISIBLE_WIDTH;
}

- (void)selectItem:(ETItemView *)item{
    [super selectItem:item];
    if (item.frame.origin.y > self.scroll.frame.size.height) {
        self.scroll.contentSize = CGSizeMake(self.scroll.frame.size.width, item.frame.origin.y + item.frame.size.height);
        self.scroll.contentOffset = CGPointMake(0, self.scroll.contentSize.height - self.scroll.frame.size.height);
    } else{
        self.scroll.contentOffset = CGPointMake(0, 0);
    }
    
    CGSize maximumLabelSize = CGSizeMake(1000, self.selectedLabel.frame.size.height);
    
    CGSize estimatedSize = [item.description sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_PREVIEW]
                            constrainedToSize:maximumLabelSize
                                lineBreakMode:NSLineBreakByTruncatingTail];
    
    if (estimatedSize.width < self.selectedLabel.frame.size.width) {
        self.selectedLabel.text = item.description;
        [self.selectedLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_PREVIEW]];
        self.selectedLabel.textAlignment = NSTextAlignmentCenter;
        [self.selectedLabel setTextColor:[item textColorSelected]];
    } else {
        self.selectedLabel.text = @"";
    }

}

@end
