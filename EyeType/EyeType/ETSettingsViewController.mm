//
//  ETSettingsViewController.mm
//  EyeType
//
//  Created by scvsoft on 10/30/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETSettingsViewController.h"
#import "GLESImageView.h"
#import "ETAreaDetectionView.h"

@interface ETSettingsViewController()
@property (nonatomic, strong) GLESImageView *imageView;
@property (nonatomic, strong) VideoSource * videoSource;
@property (nonatomic, strong) ETSettingsViewModel *model;
@property (nonatomic, assign) bool detectedArea;
@property (nonatomic, strong) ETAreaDetectionView *gesturesView;
@end

@implementation ETSettingsViewController
@synthesize delaySlider;@synthesize configurationView;
@synthesize imageView;
@synthesize videoSource;
@synthesize sensitivitySlider;
@synthesize delegate;
@synthesize colorPicker;
@synthesize inputModelSelector;
@synthesize gesturesView;
@synthesize areaNameLabel;

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
    
    // Init the default view (video view layer)
    self.imageView = [[GLESImageView alloc] initWithFrame:self.configurationView.bounds];
    [self.imageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.configurationView addSubview:self.imageView];
    CGRect frame = CGRectMake(0, 0, self.configurationView.frame.size.width, self.configurationView.frame.size.height);
    self.gesturesView = [[ETAreaDetectionView alloc] initWithFrame:frame];
    self.gesturesView.delegate = self.model;
    [self.configurationView addSubview:self.gesturesView];
    
    self.videoSource = [[VideoSource alloc] init];
    self.videoSource.delegate = self;
}

- (void)updateDelayTime{
    if ([self.model delayTime] != NSNotFound) {
        self.delaySlider.value = [self.model delayTime] * 4;
    }
}

- (void)updateViewFromModel{
    [self updateDelayTime];
    
    if ([self.model sensitivity] != NSNotFound) {
        self.sensitivitySlider.value = [self.model sensitivity];
    }
    
    [self.colorPicker selectRow:[self.model selectedColorIndex] inComponent:0 animated:NO];
    self.inputModelSelector.selectedSegmentIndex = [self.model inputType];
    
    self.areaNameLabel.text = [NSString stringWithFormat:@"Configuring Area %@",[self.model configuringAreaName]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateViewFromModel];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.detectedArea = NO;
    [self.videoSource startRunning];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.videoSource stopRunning];
}

- (void)viewDidUnload {
    [self setDelaySlider:nil];
    [self setConfigurationView:nil];
    [self setSensitivitySlider:nil];
    [self setColorPicker:nil];
    [self setInputModelSelector:nil];
    [self setAreaNameLabel:nil];
    [super viewDidUnload];
}

- (IBAction)sliderValueChange:(id)sender {
    [self.model setDelayTime:self.delaySlider.value];
    [self updateDelayTime];
}

- (IBAction)saveButtonAction:(id)sender {
    if ([self.model isAbleToSave]) {
        [self.model setInputModel:(ETInputModelType)self.inputModelSelector.selectedSegmentIndex];
        [self.model save];
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings incomplete" message:@"To continue set the action area" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}

-(void)viewModelDidFinishSave{
    [self.delegate settings:self didSaveColor:[self.model selectedColor] delay:[self.model delayTime]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)defaultSettingsAction:(id)sender {
    [self.model configureDefaultValues];
    [self updateDelayTime];
    
    [self updateViewFromModel];
}

- (IBAction)sensitivityValueChange:(id)sender {
    [self.model setSesitivity:self.sensitivitySlider.value];
}

- (IBAction)exitButtonAction:(id)sender {
    if ([self.model isAbleToSave]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings incomplete" message:@"To continue set the action area" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}

- (IBAction)inputModelValueChange:(id)sender {
    int index = ((UISegmentedControl *)sender).selectedSegmentIndex;
    [self.model setInputModel:(ETInputModelType)index];
    self.areaNameLabel.text = [NSString stringWithFormat:@"Configuring Area %@:",[self.model configuringAreaName]];
}

#pragma mark - VideoSourceDelegate

- (void) frameCaptured:(cv::Mat) frame{
    if (!self.detectedArea || self.model.areaSelected) {
        cv::Mat outputMat;
        frame.copyTo(outputMat);
        self.model.areaSelected = NO;
        if ([[self.model configuredAreaName] isEqualToString:@"OK"] && [self.model areaOK].size().width > 0) {
            cv::rectangle(outputMat, [self.model areaOK], cv::Scalar(0,255,0,255));
        } else if ([[self.model configuredAreaName] isEqualToString:@"CANCEL"] && [self.model areaCancel].size().width > 0) {
            cv::rectangle(outputMat, [self.model areaOK], cv::Scalar(0,255,0,255));
            cv::rectangle(outputMat, [self.model areaCancel], cv::Scalar(0,0,255,255));
        }
        
        [self.imageView drawFrame:outputMat];
    } else {
        [self.videoSource stopRunning];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Action %@ configured", [self.model configuredAreaName]] message:@"Are you ready to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}

-(void)viewModel:(ETSettingsViewModel*)model didConfigureArea:(cv::Rect)area{
    self.detectedArea = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.detectedArea = NO;
    [self.videoSource startRunning];
    
    if (buttonIndex == 0) {//NO
        [self.model removeConfiguredArea];
    }else{//YES
        self.areaNameLabel.text = [NSString stringWithFormat:@"Configuring Area %@",[self.model configuringAreaName]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate{
    return NO;
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
