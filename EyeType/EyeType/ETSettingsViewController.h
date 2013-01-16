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

@interface ETSettingsViewController : UIViewController<VideoSourceDelegate, ETSettingsViewModelDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UISlider *delaySlider;
@property (strong, nonatomic) IBOutlet UIView *configurationView;
@property (strong, nonatomic) IBOutlet UIPickerView *colorPicker;
@property (strong, nonatomic) IBOutlet UISlider *sensitivitySlider;
@property (strong, nonatomic) IBOutlet UISlider *sensitivityCancelSlider;
@property (assign, nonatomic) id<ETSettingsViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UIButton *singleInputButton;
@property (strong, nonatomic) IBOutlet UIButton *dualInputButton;
@property (strong, nonatomic) IBOutlet UIButton *selectedAreaOkButton;
@property (strong, nonatomic) IBOutlet UIButton *selectedAreaCancelButton;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *separatorLines;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsList;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsList;
@property (strong, nonatomic) IBOutlet UIScrollView *scroll;

- (IBAction)sliderValueChange:(id)sender;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)defaultSettingsAction:(id)sender;
- (IBAction)sensitivityValueChange:(id)sender;
- (IBAction)exitButtonAction:(id)sender;
- (IBAction)inputModelDualSelected:(id)sender;
- (IBAction)inputModelSingleSelected:(id)sender;
- (IBAction)configureAreaOkAction:(id)sender;
- (IBAction)configureAreaCancelAction:(id)sender;

@end

@protocol ETSettingsViewControllerDelegate <NSObject>

- (void)settings:(ETSettingsViewController *)control didSaveColor:(UIColor *)color delay:(float)delay;
- (void)settingsWillClose;

@end