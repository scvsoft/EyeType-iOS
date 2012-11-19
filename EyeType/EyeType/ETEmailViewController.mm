//
//  ETEmailViewController.m
//  EyeType
//
//  Created by scvsoft on 11/13/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETEmailViewController.h"

@interface ETEmailViewController ()

@end

@implementation ETEmailViewController

- (void)send{
    //call the methods that load the view values
    [self view];
    
    //this method MUST be executed with the delay because the compose need
    //the delay to charge the message body
    [self performSelector:@selector(throwSendAction:) withObject:self.view afterDelay:0.4];
}

//this method looking for the send button from the email compose and execute the action associated
- (void)throwSendAction:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]])
    {
        UIButton *button = (UIButton *)view;
        if ([button.titleLabel.text isEqualToString:@"Send"])
        {
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    NSArray *subviews = [view subviews];
    if (subviews) {
        for (UIView *view in subviews)
        {
            [self throwSendAction:view];
        }
    }
}

@end
