//
//  ETNotificationView.h
//  EyeType
//
//  Created by Hernan Saez on 2/4/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETNotificationView : UIView

- (void) showWithMessage: (NSString *) message delay: (float) delay duration: (float) duration fadeDuration: (float) fadeDuration;
- (void) showWithMessage: (NSString *) message;

@end

