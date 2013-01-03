//
//  ETViewController.h
//  EyeType
//
//  Created by scvsoft on 11/16/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETVideoSourceViewController.h"
#import "GLESImageView.h"
#import "ETMainViewModel.h"
#import "ETSettingsViewController.h"
#import "ETAlertViewController.h"
#import "ETOptionsContainersList.h"
#import "ETValueContainer.h"

@interface ETMainViewController : ETVideoSourceViewController<ETMainViewModelDelegate, ETAlertDelegate, ETSettingsViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet ETValueContainer *valuesContainer;
@property (strong, nonatomic) IBOutlet ETOptionsContainersList *optionsContainers;
@property (strong, nonatomic) ETMainViewModel *model;

- (IBAction)configureButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)okButtonAction:(id)sender;

@end