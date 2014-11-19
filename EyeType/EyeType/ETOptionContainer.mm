//
//  ETOptionContainer.m
//  EyeType
//
//  Created by scvsoft on 12/14/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETOptionContainer.h"
#define SEPARATOR_HEIGHT 15
#define CONTAINER_MARGIN 30
#define CONTAINER_MARGIN_LEFT (CONTAINER_MARGIN + 10)

@interface ETOptionContainer()
@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,strong) ETItemView *selectedItem;
@property (nonatomic,assign) BOOL hasSeparator;
@end

@implementation ETOptionContainer

@synthesize currentX, currentY, currentViewTag, rowHeight, selectedItem, hasSeparator;

- (id)init{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (BOOL)isEqual:(id)object{
    if (object != nil && [object isKindOfClass:[self class]]) {
        ETOptionContainer *container = object;
        return container.tag == self.tag;
    }
    
    return NO;
}

- (int)margin{
    return CONTAINER_MARGIN;
}

- (int)marginLeft {
    return CONTAINER_MARGIN_LEFT;
}

- (id)copyWithZone:(NSZone *)zone{
    ETOptionContainer *container = [[ETOptionContainer alloc] init];
    for (ETItemView *item in self.items) {
        [container addSubview:item];
        [container.items addObject:item];
    }
    
    container.currentX = self.currentX;
    container.currentY = self.currentY;
    container.currentViewTag = self.currentViewTag;
    container.currentRow = self.currentRow;
    container.rowHeight = self.rowHeight;
    container.tag = self.tag;
    
    return container;
}

- (void)initialize{
    self.currentX = 0;
    self.currentY = 0;
    self.currentViewTag = NSNotFound;
    self.currentRow = 0;
    self.rowHeight = 0;
    self.items = [NSMutableArray array];
}

- (void)menuOff{
    for (ETItemView* item in self.items) {
        if (item.tag == self.currentViewTag) {
            [item inactiveSelected];
        }else{
            [item inactive];
        }
    }
}

- (void)includeSeparator{
    self.hasSeparator = YES;
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(-[self marginLeft], 0, self.frame.size.width + [self margin], SEPARATOR_HEIGHT)];
    UIImageView *image  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, separator.frame.size.width, 2)];
    image.backgroundColor = [UIColor ETSeparatorPatern];
    
    [separator addSubview:image];
    [self addSubview:separator];
    
    for (ETItemView *item in self.items) {
        item.frame = CGRectMake(item.frame.origin.x, item.frame.origin.y + SEPARATOR_HEIGHT, item.frame.size.width, item.frame.size.height);
    }
}

- (void)addItemWithText:(NSString *)text{
    if (self.currentViewTag == NSNotFound) {
        self.currentViewTag = 0;
        self.currentRow = 0;
    } else{
        self.currentViewTag++;
        self.currentRow++;
    }
    CGSize estimatedSize = [ETItemView estimatedSizeForText:text];
    self.rowHeight = estimatedSize.height;
    self.currentY = self.currentRow * self.rowHeight;
    ETItemView *itemView = [[ETItemView alloc] initWithOptionText:text inX:0 Y:self.currentY useBold:NO];
    itemView.tag = self.currentViewTag;
    [self addSubview:itemView];
    [self.items addObject:itemView];
}

- (void)selectNextItem{
    if (self.currentViewTag == NSNotFound || self.currentViewTag >= [self.items count] - 1) {
        self.currentViewTag = 0;
    } else{
        self.currentViewTag++;
    }
    
    for (ETItemView* item in self.items) {
        if (self.currentViewTag == item.tag) {
            [self selectItem:item];
        } else{
            [item deselect];
        }
    }
}

- (void)restartLoop{
    self.currentViewTag = NSNotFound;
}

- (void)selectItem:(ETItemView *)item{
    [item select];
    self.selectedItem = item;
}

- (CGFloat)containerHeight{
    int separatorHeight = self.hasSeparator ? SEPARATOR_HEIGHT : 0;
    return ((self.currentRow + 1) * self.rowHeight) + separatorHeight;
}

- (NSString *)selectedText{
    return self.selectedItem.description;
}

@end
