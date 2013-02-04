//
//  ETNotificationView.m
//  EyeType
//
//  Created by Hernan Saez on 2/4/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import "ETNotificationView.h"

#define DEFAULT_DELAY 0.0f
#define DEFAULT_DURATION 2.0f
#define DEFAULT_FADE_DURATION 1.0f

@interface ETNotificationView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation ETNotificationView

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.0f;
        
        self.label = [[UILabel alloc] initWithFrame: self.bounds];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        self.label.text = @"Your email was sent successfully";
        [self addSubview: self.label];
    }
    
    return self;
}

- (void) showWithMessage: (NSString *) message {
    [self showWithMessage: message delay: DEFAULT_DELAY duration: DEFAULT_DURATION fadeDuration: DEFAULT_FADE_DURATION];
}

- (void) showWithMessage: (NSString *) message delay: (float) delay duration: (float) duration fadeDuration: (float) fadeDuration {
    self.label.text = message;
    
    [UIView animateWithDuration: fadeDuration
                          delay: delay
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration: fadeDuration
                                               delay: duration
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations: ^{
                                              self.alpha = 0.0f;
                                          }
                                          completion: nil];
                     }];
}

@end

