//
//  ETAlertViewModel.h
//  EyeType
//
//  Created by scvsoft on 11/10/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETVideoSourceViewModel.h"

@protocol ETAlertViewModelDelegate;

@interface ETAlertViewModel : ETVideoSourceViewModel

- (id)initWithDelegate:(id<ETAlertViewModelDelegate>)Delegate;

@end

@protocol ETAlertViewModelDelegate <NSObject>

- (void)alertViewModelDidOKActionExecute;
- (void)alertViewModelDidCancelActionExecute;

@end