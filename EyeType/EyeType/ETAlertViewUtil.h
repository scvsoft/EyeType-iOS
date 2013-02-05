//
//  ETAlertViewUtil.h
//  EyeType
//
//  Created by deby on 2/4/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETAlertViewUtil : NSObject

+ (void) alertViewWithTitle: (NSString *) title message: (NSString *) message;
+ (void) alertViewWithTitle: (NSString *) title message: (NSString *) message withDelegate: (id) delegate cancelButtonTitle: (NSString *) cancelButtonTitle otherButtonTitle: (NSString *) otherButtonTitle;

@end
