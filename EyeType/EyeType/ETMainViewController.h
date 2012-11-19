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

@interface ETMainViewController : ETVideoSourceViewController<ETMainViewModelDelegate, ETSettingsViewControllerDelegate, ETAlertDelegate>

@property (strong, nonatomic) IBOutlet UILabel *charactersLabel;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) ETMainViewModel *model;

- (IBAction)configureButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)okButtonAction:(id)sender;

@end