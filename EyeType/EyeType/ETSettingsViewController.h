//
//  ETSettingsViewController.h
//  EyeType
//
//  Created by scvsoft on 10/30/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "VideoSource.h"
#import "ETSettingsViewModel.h"

@protocol ETSettingsViewControllerDelegate;

@interface ETSettingsViewController : UIViewController<VideoSourceDelegate, ETSettingsViewModelDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UISlider *delaySlider;
@property (strong, nonatomic) IBOutlet UIView *configurationView;
@property (strong, nonatomic) IBOutlet UIPickerView *colorPicker;
@property (strong, nonatomic) IBOutlet UISlider *sensitivitySlider;
@property (strong, nonatomic) IBOutlet UISlider *sensitivityCancelSlider;
@property (assign, nonatomic) id<ETSettingsViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UISegmentedControl *inputModelSelector;
@property (strong, nonatomic) IBOutlet UILabel *areaNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;

- (IBAction)sliderValueChange:(id)sender;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)defaultSettingsAction:(id)sender;
- (IBAction)sensitivityValueChange:(id)sender;
- (IBAction)exitButtonAction:(id)sender;
- (IBAction)inputModelValueChange:(id)sender;

@end

@protocol ETSettingsViewControllerDelegate <NSObject>

- (void)settings:(ETSettingsViewController *)control didSaveColor:(UIColor *)color delay:(float)delay;

@end