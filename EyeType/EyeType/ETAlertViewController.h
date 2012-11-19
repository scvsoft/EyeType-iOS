//
//  ETAlertViewController.h
//  EyeType
//
//  Created by scvsoft on 11/10/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETVideoSourceViewController.h"
#import "ETAlertViewModel.h"

@protocol ETAlertDelegate;

@interface ETAlertViewController : ETVideoSourceViewController<ETAlertViewModelDelegate>
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIButton *OKButton;
@property (strong, nonatomic) IBOutlet UIButton *CancelButton;
@property (assign, nonatomic) id<ETAlertDelegate> delegate;
@property (assign, nonatomic) int actionCode;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)okButtonAction:(id)sender;
- (id)initWithDelegate:(id<ETAlertDelegate>)Delegate message:(NSString*)msg actionCode:(int)code;
@end

@protocol ETAlertDelegate <NSObject>
@optional
- (void)AlertDidApper;
- (void)AlertDidDisapper;
@required
- (void)AlertViewControllerDidOKActionExecute:(ETAlertViewController*)sender;
- (void)AlertViewControllerDidCancelActionExecute:(ETAlertViewController*)sender;

@end
