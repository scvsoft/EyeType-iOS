//
//  ETSettingsViewController.h
//  EyeType
//
//  Created by scvsoft on 10/30/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSource.h"
#import "ETSettingsViewModel.h"

@protocol ETSettingsViewControllerDelegate;

@interface ETSettingsViewController : UIViewController<VideoSourceDelegate, ETSettingsViewModelDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UISlider *delaySlider;
@property (strong, nonatomic) IBOutlet UITextField *delayLabel;
@property (strong, nonatomic) IBOutlet UIView *configurationView;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) id<ETSettingsViewControllerDelegate> delegate;

- (IBAction)sliderValueChange:(id)sender;
- (IBAction)OKButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)defaultSettingsAction:(id)sender;

@end

@protocol ETSettingsViewControllerDelegate <NSObject>

- (void)modal:(ETSettingsViewController*)modal didConfigureDelayTime:(float)delay;

@end