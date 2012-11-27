//
//  ETSettingsViewController.mm
//  EyeType
//
//  Created by scvsoft on 10/30/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETSettingsViewController.h"
#import "GLESImageView.h"

@interface ETSettingsViewController()
@property (nonatomic, strong) GLESImageView *imageView;
@property (nonatomic, strong) VideoSource * videoSource;
@property (nonatomic, strong) ETSettingsViewModel *model;
@property (nonatomic, assign) bool okActionSetting;
@property (nonatomic, assign) bool cancelActionSetting;
@property (nonatomic, assign) bool detectedArea;
@end

@implementation ETSettingsViewController
@synthesize delaySlider;
@synthesize delayLabel;
@synthesize configurationView;
@synthesize imageView;
@synthesize videoSource;
@synthesize okActionSetting;
@synthesize cancelActionSetting;
@synthesize sensitivitySlider;
@synthesize delegate;
@synthesize colorPicker;
@synthesize inputModelSelector;

- (id)init{
    self = [super init];
    if (self) {
        self.model = [[ETSettingsViewModel alloc] init];
        self.model.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if ([self.model delayTime] != NSNotFound) {
        self.delaySlider.value = [self.model delayTime] * 2;
        self.delayLabel.text = [NSString stringWithFormat:@"%.1f",[self.model delayTime]];
    }
    
    if ([self.model sensitivity] != NSNotFound) {
        self.sensitivitySlider.value = [self.model sensitivity];
    }
    
    // Init the default view (video view layer)
    self.imageView = [[GLESImageView alloc] initWithFrame:self.configurationView.bounds];
    [self.imageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.configurationView addSubview:self.imageView];
    
    self.videoSource = [[VideoSource alloc] init];
    self.videoSource.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.colorPicker selectRow:[self.model selectedColorIndex] inComponent:0 animated:NO];
    self.inputModelSelector.selectedSegmentIndex = [self.model inputType];
}

- (void)viewDidUnload {
    [self setDelaySlider:nil];
    [self setDelayLabel:nil];
    [self setConfigurationView:nil];
    [self setOkButton:nil];
    [self setCancelButton:nil];
    [self setSensitivitySlider:nil];
    [self setColorPicker:nil];
    [self setInputModelSelector:nil];
    [self setInputModelSelector:nil];
    [super viewDidUnload];
}

- (IBAction)sliderValueChange:(id)sender {
    [self.model setDelayTime:self.delaySlider.value];
    float aux = [self.model delayTime];
    self.delayLabel.text = [NSString stringWithFormat:@"%.1f",aux];
}

- (IBAction)OKButtonAction:(id)sender {
    self.okActionSetting = YES;
    self.okButton.userInteractionEnabled = NO;
    self.cancelButton.userInteractionEnabled = NO;
    self.detectedArea = NO;
    [self.videoSource startRunning];
}

- (IBAction)cancelButtonAction:(id)sender {
    self.cancelActionSetting = YES;
    self.okButton.userInteractionEnabled = NO;
    self.cancelButton.userInteractionEnabled = NO;
    self.detectedArea = NO;
    [self.videoSource startRunning];
}

- (IBAction)saveButtonAction:(id)sender {
    if ([self.model isAbleToSave]) {
        [self.model setInputModel:(ETInputModelType)self.inputModelSelector.selectedSegmentIndex];
        [self.model save];
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings incomplete" message:@"To continue set the action area" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

}

-(void)viewModelDidFinishSave{
    [self.delegate settings:self didSaveColor:[self.model selectedColor] delay:[self.model delayTime]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)defaultSettingsAction:(id)sender {
    [self.model configureDefaultValues];
    self.delaySlider.value = [self.model delayTime];
    self.delayLabel.text = [NSString stringWithFormat:@"%.1f",self.delaySlider.value * .5];
    
    self.sensitivitySlider.value = [self.model sensitivity];
}

- (IBAction)sensitivityValueChange:(id)sender {
    [self.model setSesitivity:self.sensitivitySlider.value];
}

- (IBAction)exitButtonAction:(id)sender {
    if ([self.model isAbleToSave]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings incomplete" message:@"To continue set the action area" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)inputModelValueChange:(id)sender {
    int index = ((UISegmentedControl *)sender).selectedSegmentIndex;
    [self.model setInputModel:(ETInputModelType)index];
}

#pragma mark - VideoSourceDelegate

- (void) frameCaptured:(cv::Mat) frame{
    if (!self.detectedArea) {
        if (self.okActionSetting) {
            cv::Mat outputMat = [self.model identifyGestureOK:frame];
            [self.imageView drawFrame:outputMat];
        }else if(self.cancelActionSetting){
            [self.imageView drawFrame:[self.model identifyGestureCancel:frame]];
        }
        
    } else {
        [self.videoSource stopRunning];
        NSString *action = self.okActionSetting ? @"OK" : @"CANCEL";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Action %@ configured", action] message:@"Are you ready to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
    }
}

-(void)viewModel:(ETSettingsViewModel*)model didConfigureArea:(cv::Rect)area{
    self.detectedArea = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {//NO
        if (self.okActionSetting) {
            [self OKButtonAction:nil];
        } else if(self.cancelActionSetting)
            [self cancelButtonAction:nil];
    }else{//YES
        self.okButton.userInteractionEnabled = YES;
        self.cancelButton.userInteractionEnabled = YES;
        self.okActionSetting = NO;
        self.cancelActionSetting = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationLandscapeLeft;
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.model colorsCount];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.model colorNameAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self.model selectColorAtIndex:row];
}

@end
