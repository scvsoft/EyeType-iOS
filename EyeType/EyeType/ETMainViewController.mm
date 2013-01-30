//
//  ETViewController.mm
//  EyeType
//
//  Created by scvsoft on 11/16/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMainViewController.h"
#import "ETOptionContainer.h"

@interface ETMainViewController ()

@property (strong,nonatomic) NSTimer* timer;
@property (strong,nonatomic) ETSettingsViewController* settings;
@property (strong,nonatomic) ETHelpViewController *help;
@property (strong,nonatomic) ETAlertViewController* alert;
@end

enum AlertActionCode{
    AlertActionCancelEmail = 0,
    AlertActionNotImplmented
};

@implementation ETMainViewController
@synthesize timer;
@synthesize settings;
@synthesize alert;
@synthesize model;
@synthesize optionsContainers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.model = [[ETMainViewModel alloc] initWithDelegate:self];
        self.settings = [[ETSettingsViewController alloc] init];
        self.settings.delegate = self;
    }
    
    return self;
}

- (void)clearMenus{
    [self.optionsContainers clear];
    [self.valuesContainer hide];
    [self.model initializeMenus];
}

- (void)viewDidLoad{
    [super viewDidLoad];
#ifdef DEBUG
    self.okButton.hidden = NO;
    self.cancelButton.hidden = NO;
#endif
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self clearMenus];
    [self loadPreview];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startDetect];
    [self disableApplicationAutoLock:YES];
    [self.messageTextView setFont:[UIFont fontWithName:@"Calibri" size:20.]];
    [self.model resume];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopDetect];
    [self disableApplicationAutoLock:NO];
}

//if disable is YES the application does not automatically suspend
- (void)disableApplicationAutoLock:(BOOL)disable{
    UIApplication *thisApp = [UIApplication sharedApplication];
    thisApp.idleTimerDisabled = disable;
}

- (void)viewDidUnload {
    [self.timer invalidate];
    [self setOkButton:nil];
    [self setCancelButton:nil];
    [self setMessageTextView:nil];
    [self setOptionsContainers:nil];
    [self setValuesContainer:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationLandscapeRight == toInterfaceOrientation) {
        return YES;
    }
    return NO;
}

- (void)nextValue{
    self.okButton.selected = NO;
    self.cancelButton.selected = NO;
    [self.model performSelector:@selector(activateDetection) withObject:nil afterDelay:.3];
    NSString *value = @"";
    if (!self.model.paused) {
        [self selectNextItem];
    } else
        value = @"2 BLINKS IN LESS THAN 1 SECOND TO ACTIVE THE APPLICATION";
}

- (void)selectNextItem{
    if ([self.valuesContainer isVisible]) {
        [self.valuesContainer selectNextItem];
    }else{
        [self.optionsContainers selectNextItem];
    }
}

- (void)loadPreview{
    if ([self.model isReturningOptions]) {
        ETOptionContainer *container = [[ETOptionContainer alloc] init];
        for (NSString *text in [self.model currentValues]) {
            [container addItemWithText:text];
        }
        
        [self.optionsContainers addOptionContainer:container];
    } else{
        [self.valuesContainer resetValues];
        for (NSString *text in self.model.currentValues) {
            [self.valuesContainer addItemWithText:text];
        }

        [self.valuesContainer show];
    }
}

- (void)startTimer{
    if (![self.timer isValid] && [self.videoSource isRunning]) {
        float delay = self.model.delayTime;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(nextValue) userInfo:nil repeats:YES];
    }
}

- (IBAction)configureButtonAction:(id)sender {
    [self presentViewController:self.settings animated:YES completion:nil];
}

- (IBAction)helpButtonAction:(id)sender {
    if (!self.help) {
        self.help = [[ETHelpViewController alloc] initWithDelegate: self];
    }
    
    [self presentViewController:self.help animated:YES completion:nil];
}

- (void)stopDetect{
    [self.timer invalidate];
    [self.videoSource stopRunning];
}

- (void)startDetect{
    if ([self.model isAbleToStart]) {
        [self.videoSource startRunning];
        [self startTimer];
    } else {
        if (self.help == nil) {
            self.help = [[ETHelpViewController alloc] initWithDelegate: self];
            [self presentViewController: self.help animated: YES completion: nil];
        }
        else {
            [self presentViewController: self.settings animated: YES completion: nil];
        }
    }
}

- (void)resetTimer{
    [self.timer invalidate];
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:.5];
}

#pragma mark - ETViewModelDelegate

-(void)viewModel:(ETMainViewModel*)model didSelectCharacter:(NSString *)message{
    self.okButton.selected = YES;
    self.messageTextView.text = message;
}

-(void)viewModelDidEnterInPause{
}

-(void)viewModelDidLeavePause{
    [self resetTimer];
}

- (void)viewModelWillCancelEmail{
    self.okButton.selected = YES;
    self.alert = [[ETAlertViewController alloc] initWithDelegate:self message:@"Would you like cancel the email?" actionCode:AlertActionCancelEmail alertType:ETAlertViewTypeOKCancel];
    
    [self presentViewController:self.alert animated:YES completion:nil];
}

-(void)viewModelDidDetectOKAction:(ETMainViewModel*)model{
    self.okButton.selected = YES;
    [self resetTimer];
    
    if ([self.valuesContainer isVisible]) {
        [self.valuesContainer restartLoop];
    }
}

-(void)viewModel:(ETMainViewModel *)model didFoundError:(NSString *)errorMessage{
    self.alert = [[ETAlertViewController alloc] initWithDelegate:self message:errorMessage actionCode:AlertActionCancelEmail alertType:ETAlertViewTypeOK];
    [self presentViewController:self.alert animated:YES completion:nil];
}

-(void)viewModelDidDetectCancelAction:(ETMainViewModel*)model{
    self.cancelButton.selected = YES;
    [self resetTimer];
}

-(void)ViewModelDidLoadNewMenu{
    [self loadPreview];
}

-(void)ViewModelDidCloseMenu{
    if ([self.valuesContainer isVisible]) {
        if ([self.model isReturningOptions]) {
            [self.valuesContainer hide];
        }else{
            [self loadPreview];
        }
    } else{
        [self.optionsContainers moveToPreviousMenu];
    }
}

- (NSString *)getCurrentValue{
    NSString *selectedText = nil;
    if ([self.valuesContainer isVisible]) {
        selectedText = [self.valuesContainer selectedText];
    } else{
        selectedText = [self.optionsContainers selectedText];
    }
    
    return selectedText;
}

- (NSString *)viewModelGetCurrentValue{
    return [self getCurrentValue];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.model executeCancelAction];
}

- (IBAction)okButtonAction:(id)sender {
    [self.model executeOKAction];
}

- (void)AlertDidAppear{
    [self stopDetect];
}

- (void)AlertDidDisapper{
    [self startDetect];
}

- (void)AlertViewControllerDidOKActionExecute:(ETAlertViewController*)sender{
    if (sender.actionCode == AlertActionCancelEmail) {
        [self.model cancelEmail];
    }
    
    [self.alert dismissViewControllerAnimated:YES completion:nil];
}

- (void)AlertViewControllerDidCancelActionExecute:(ETAlertViewController*)sender{
    [self.alert dismissViewControllerAnimated:YES completion:nil];
}

- (void)settings:(ETSettingsViewController *)control didSaveColor:(UIColor *)color delay:(float)delay{
    self.model.textColor = color;
    self.model.delayTime = delay;
    [self.model configureMovementDetector];
    
    [self.settings dismissModalViewControllerAnimated:YES];
    [self showLoading];
}

- (void)settingsWillClose{
    [self.settings dismissModalViewControllerAnimated:YES];
    [self showLoading];
}

#pragma mark - Help view controller delegate

- (void) helpViewControllerIsDone: (ETHelpViewController *) helpViewController {
    [helpViewController dismissViewControllerAnimated: YES completion: nil];
}

@end
