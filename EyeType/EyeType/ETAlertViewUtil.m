//
//  ETAlertViewUtil.m
//  EyeType
//
//  Created by deby on 2/4/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import "ETAlertViewUtil.h"

@implementation ETAlertViewUtil


+ (void) alertViewWithTitle: (NSString *) title message: (NSString *) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

+ (void) alertViewWithTitle: (NSString *) title message: (NSString *) message withDelegate: (id) delegate cancelButtonTitle: (NSString *) cancelButtonTitle otherButtonTitle: (NSString *) otherButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

@end
