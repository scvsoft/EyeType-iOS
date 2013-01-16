//
//  ETOptionView.m
//  EyeType
//
//  Created by scvsoft on 12/14/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETItemView.h"
#import <QuartzCore/QuartzCore.h>

#define VIEW_HEIGHT 90

@interface ETItemView(){
    UIColor *_textColorSelected;
    int originX, originY;
}

@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, assign) BOOL bold;

@end

#define FONT_FAMILY @"Calibri"
#define FONT_FAMILY_BOLD @"Calibri-Bold"
#define FONT_SIZE 32.

@implementation ETItemView
@synthesize textLabel;

- (id)initWithOptionText:(NSString *)option inX:(int)x Y:(int)y useBold:(BOOL)useBold
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 2;
        self.bold = useBold;
        originX = x;
        originY = y;
        
        self.textLabel = [[UILabel alloc] init];
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.textLabel setFont:[UIFont fontWithName:FONT_FAMILY size:FONT_SIZE]];
        [self.textLabel setTextAlignment:NSTextAlignmentCenter];
        
        if ([[option lowercaseString] isEqualToString:@"back"]) {
            [self setBackText];
        } else{
            [self setNormalText:option];
        }
        
        [self.textLabel setTextColor:[self textColorNormal]];
        _textColorSelected = [self textColorSelected];
    }
    
    return self;
}

- (void)setNormalText:(NSString *)text{
    CGSize estimatedSize = [ETItemView estimatedSizeForText:text];
    self.frame = CGRectMake(originX, originY, estimatedSize.width, estimatedSize.height);
    
    [self.textLabel setText:text];
    self.textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self addSubview:self.textLabel];
}

- (void)setBackText{
    [self.textLabel setText:@"BACK"];
    [self.textLabel setTextColor:[self textColorNormal]];
    CGSize estimatedSize = [ETItemView estimatedSizeForText:self.textLabel.text];
    self.frame = CGRectMake(originX, originY, estimatedSize.width + 24, estimatedSize.height);
    
    self.textLabel.frame = CGRectMake(12, 0, self.frame.size.width, self.frame.size.height);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowRed.png"]];
    imageView.frame = CGRectMake(6, (estimatedSize.height / 2) - 10, imageView.frame.size.width, imageView.frame.size.height);
    
    [self addSubview:self.textLabel];
    [self addSubview:imageView];
}

- (NSString *)description{
    return self.textLabel.text;
}

- (void)select{
    self.layer.borderColor = [_textColorSelected CGColor];
    self.layer.borderWidth = 3.0f;
    self.textLabel.textColor = _textColorSelected;
    
    if (self.bold) {
        [self.textLabel setFont:[UIFont fontWithName:FONT_FAMILY_BOLD size:FONT_SIZE]];
        CGRect frame = self.textLabel.frame;
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 5, frame.size.width, frame.size.height);
    }
}

- (void)deselect{
    self.layer.borderColor = [[UIColor clearColor] CGColor];
    self.layer.borderWidth = 3.0f;
    [self.textLabel setFont:[UIFont fontWithName:FONT_FAMILY size:FONT_SIZE]];
    self.textLabel.textColor = [self textColorNormal];
    CGRect frame = self.textLabel.frame;
    frame.origin.y = 0;
    self.textLabel.frame = frame;
}

- (void)inactiveSelected{
    self.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.textLabel setTextColor:[UIColor ETYellow]];
}

- (void)inactive{
    if ([[self.textLabel.text lowercaseString] isEqualToString:@"back"]) {
        [self.textLabel setTextColor:[UIColor ETRed]];
    } else{
        [self.textLabel setTextColor:[UIColor ETGrey]];
    }
}

- (UIColor *)textColorNormal{
    UIColor *color = [UIColor whiteColor];
    if ([[self.textLabel.text lowercaseString] isEqualToString:@"back"]) {
        color = [UIColor ETRed];
    }
    
    return color;
}

- (UIColor *)textColorSelected{
    UIColor *color = [UIColor whiteColor];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"textColor"]){
        NSData *colorData = [defaults objectForKey:@"textColor"];
        color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    
    if ([[self.textLabel.text lowercaseString] isEqualToString:@"back"]) {
        color = [UIColor ETRed];
    }
    
    return color;
}

+ (CGSize)estimatedSizeForText:(NSString *)text {
    CGSize maximumLabelSize = CGSizeMake(300, VIEW_HEIGHT);
    
    CGSize estimatedSize = [text sizeWithFont:[UIFont fontWithName:FONT_FAMILY size:FONT_SIZE]
                            constrainedToSize:maximumLabelSize
                                lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize customSize = CGSizeMake(estimatedSize.width + 20, estimatedSize.height);
    return customSize;
}

@end
