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

@interface ETSettingsViewController : UIViewController<VideoSourceDelegate, ETSettingsViewModelDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UISlider *delaySlider;
@property (strong, nonatomic) IBOutlet UITextField *delayLabel;
@property (strong, nonatomic) IBOutlet UIView *configurationView;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIPickerView *colorPicker;
@property (strong, nonatomic) IBOutlet UISlider *sensitivitySlider;
@property (assign, nonatomic) id<ETSettingsViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UISegmentedControl *inputModelSelector;

- (IBAction)sliderValueChange:(id)sender;
- (IBAction)OKButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)defaultSettingsAction:(id)sender;
- (IBAction)sensitivityValueChange:(id)sender;
- (IBAction)exitButtonAction:(id)sender;
- (IBAction)inputModelValueChange:(id)sender;

@end

@protocol ETSettingsViewControllerDelegate <NSObject>

- (void)settings:(ETSettingsViewController *)control didSaveColor:(UIColor *)color delay:(float)delay;

@end