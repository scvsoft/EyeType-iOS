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
@property (nonatomic, strong) VideoSource *videoSource;
@property (nonatomic, strong) ETSettingsViewModel *model;
@property (nonatomic, assign) bool detectedArea;
@property (nonatomic, strong) ETAreaDetectionView *gesturesView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray *colorsButtons;

@end

@implementation ETSettingsViewController
@synthesize delaySlider;
@synthesize configurationView;
@synthesize imageView;
@synthesize videoSource;
@synthesize sensitivitySlider;
@synthesize delegate;
@synthesize greenButton;
@synthesize lightGreenButton;
@synthesize lightBlueButton;
@synthesize purpleButton;
@synthesize gesturesView;
@synthesize colorsButtons;

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
    [self prepareUI];

    colorsButtons = [NSArray arrayWithObjects:self.greenButton, self.lightBlueButton, self.lightGreenButton, self.purpleButton, nil];


}

- (void)prepareUI{
    for (UIImageView *separator in self.separatorLines) {
        [separator setBackgroundColor:[UIColor ETSeparatorPatern]];
    }
    
    for (UILabel *label in self.labelsList) {
        CGFloat size = label.font.pointSize;
        [label setFont:[UIFont fontWithName:@"Calibri" size:size]];
    }
    
    for (UIButton *button in self.buttonsList) {
        CGFloat size = button.titleLabel.font.pointSize;
        [button.titleLabel setFont:[UIFont fontWithName:@"Calibri" size:size]];
    }
    
    self.selectedAreaCancelButton.userInteractionEnabled = self.model.inputType == ETInputModelTypeTwoSources;
    self.subjectTextField.text = self.model.defaultSubject;
    self.emailTextField.text = self.model.email;
    
    [self showLoading];
}

- (void)updateDelayTime{
    if ([self.model delayTime] != NSNotFound) {
        self.delaySlider.value = [self.model delayTime] * 4;
    }
}

- (void)updateViewFromModel{
    [self updateDelayTime];
    
    if ([self.model sensitivitySectionOK] != NSNotFound) {
        self.sensitivitySlider.value = [self.model sensitivitySectionOK];
    }
    if ([self.model sensitivitySectionCancel] != NSNotFound) {
        self.sensitivityCancelSlider.value = [self.model sensitivitySectionCancel];
    }
    
    for (UIButton *colorButton in self.colorsButtons) {
        if (colorButton.tag == [self.model selectedColorIndex]) {
            [colorButton setSelected:YES];
        } else {
            [colorButton setSelected:NO];
        }
    }
    
    switch ([self.model inputType]) {
        case 0:
            [self inputModelSingleSelected:nil];
            break;
        case 1:
            [self inputModelDualSelected:nil];
            break;
        default:
            break;
    }
}

- (void)setConfiguringArea{
    int configuringArea = [self.model configuringArea];
    UIColor *green = [UIColor ETGreen];
    switch (configuringArea) {
        case 0:
            [self.selectedAreaOkButton setSelected:YES];
            [self.selectedAreaCancelButton setSelected:NO];
            
            [self.selectedAreaOkButton.layer setBorderColor:[green CGColor]];
            [self.selectedAreaCancelButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
            
            [self.selectedAreaOkButton.layer setBorderWidth:2.];
            break;
        case 1:
            [self.selectedAreaOkButton setSelected:NO];
            [self.selectedAreaCancelButton setSelected:YES];
            
            [self.selectedAreaOkButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
            [self.selectedAreaCancelButton.layer setBorderColor:[green CGColor]];
            
            [self.selectedAreaCancelButton.layer setBorderWidth:2.];
            break;
        default:
            break;
    }
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
    [self setSensitivityCancelSlider:nil];
    [self setSubjectTextField:nil];
    [self setEmailTextField:nil];
    [self setSingleInputButton:nil];
    [self setDualInputButton:nil];
    [self setSeparatorLines:nil];
    [self setLabelsList:nil];
    [self setButtonsList:nil];
    [self setScroll:nil];
    [self setSelectedAreaOkButton:nil];
    [self setSelectedAreaCancelButton:nil];
    [super viewDidUnload];
}

- (IBAction)sliderValueChange:(id)sender {
    [self.model setDelayTime:self.delaySlider.value];
    [self updateDelayTime];
}

- (IBAction)saveButtonAction:(id)sender {
    if ([self actionAreaIsSet] && [self emailIsSet]) {
        [self.model save];
    }
}

- (BOOL) actionAreaIsSet {
    if ([self.model isActionAreaSet]) {
        [self.model setInputModel:self.singleInputButton.selected ? ETInputModelTypeOneSource:ETInputModelTypeTwoSources];
        return YES;
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings incomplete" message:@"To continue set the action area" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        return NO;
    }
}

- (BOOL) emailIsSet {
    if (![self.model isEmailSet]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings incomplete" message:@"To continue set an email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        return NO;
    } else {
        return YES;
    }
}

-(void)viewModelDidFinishSave{
    [self.delegate settingsDidSave: self];
}

- (IBAction)defaultSettingsAction:(id)sender {
    [self.model configureDefaultValues];
    [self updateDelayTime];
    
    [self updateViewFromModel];
}

- (IBAction)sensitivityValueChange:(id)sender {
    if (((UISlider *)sender).tag == 0) {
        [self.model setSensitivitySectionOK:self.sensitivitySlider.value];
    } else if(((UISlider *)sender).tag == 1) {
        [self.model setSensitivitySectionCancel:self.sensitivityCancelSlider.value];
    }
}

- (IBAction)exitButtonAction:(id)sender {
    if ([self.model isActionAreaSet]) {
        [self.delegate settingsWillClose];
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings incomplete" message:@"To continue set the action area" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}

- (IBAction)inputModelDualSelected:(id)sender{
    [self.model setInputModel:ETInputModelTypeTwoSources];
    self.dualInputButton.selected = YES;
    self.singleInputButton.selected = NO;
    [self.dualInputButton.layer setBorderColor:[[UIColor ETGreen] CGColor]];
    [self.singleInputButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
    
    [self.dualInputButton.layer setBorderWidth:2.];
    [self.model changeConfiguringArea];
    [self setConfiguringArea];
    
    self.selectedAreaCancelButton.userInteractionEnabled = YES;
}

- (IBAction)inputModelSingleSelected:(id)sender{
    [self.model setInputModel:ETInputModelTypeOneSource];
    self.dualInputButton.selected = NO;
    self.singleInputButton.selected = YES;
    [self.singleInputButton.layer setBorderColor:[[UIColor ETGreen] CGColor]];
    [self.dualInputButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
    
    [self.singleInputButton.layer setBorderWidth:2.];
    
    [self setConfiguringArea];
    self.selectedAreaCancelButton.userInteractionEnabled = NO;
}

- (IBAction)configureAreaOkAction:(id)sender {
    if (!self.selectedAreaOkButton.selected) {
        [self.model changeConfiguringArea];
        [self setConfiguringArea];
    }
}

- (IBAction)configureAreaCancelAction:(id)sender {
    if (!self.selectedAreaCancelButton.selected) {
        [self.model changeConfiguringArea];
        [self setConfiguringArea];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.subjectTextField) {
        self.model.defaultSubject = textField.text;
    } else if (textField == self.emailTextField) {
        self.model.email = textField.text;
    }

    [UIView animateWithDuration:.5 animations:^{
        self.scroll.contentOffset = CGPointMake(0, 0);
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:.5 animations:^{
        self.scroll.contentOffset = CGPointMake(0, 330);
    }];
}

#pragma mark - VideoSourceDelegate

- (void) frameCaptured:(cv::Mat) frame{
    if (!self.detectedArea || self.model.areaSelected) {
        cv::Mat outputMat;
        frame.copyTo(outputMat);
        self.model.areaSelected = NO;
        cv::Scalar okColor = [self.model.selectedColor scalarFromColor];
        if (self.model.inputType == ETInputModelTypeOneSource && [self.model areaOK].size().width > 0) {
            cv::rectangle(outputMat, [self.model areaOK], okColor);
        } else if (self.model.inputType == ETInputModelTypeTwoSources) {
            if ([self.model areaOK].size().width > 0) {
                cv::rectangle(outputMat, [self.model areaOK], okColor);
            }
            if ([self.model areaCancel].size().width > 0) {
                cv::rectangle(outputMat, [self.model areaCancel], [[UIColor ETRed] scalarFromColor]);
            }
        }
        
        if ([self.activityIndicator isAnimating] && !outputMat.empty()){
            [self stopLoading];
        }
        
        [self.imageView drawFrame:outputMat];
    } else {
        [self.videoSource stopRunning];
        NSString *area = [self.model configuredArea] == 0 ? @"OK" : @"CANCEL/BACK";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Action %@ configured", area] message:@"Are you ready to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
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
        [self setConfiguringArea];
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.model colorsCount];
}

- (IBAction) didSelectColor: (id) sender {
    for (UIButton *colorButton in colorsButtons) {
        [colorButton setSelected:NO];
    }
    [sender setSelected:YES];
    [self.model selectColorAtIndex:[sender tag]];
}

- (void)showLoading{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGFloat x = self.configurationView.frame.size.width / 2;
    CGFloat y = self.configurationView.frame.size.height / 2;
    self.activityIndicator.center = CGPointMake(x, y);
    
    [self.configurationView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopLoading{
    [self.activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
}

@end
