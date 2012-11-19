//
//  ETViewController.mm
//  EyeType
//
//  Created by scvsoft on 11/16/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMainViewController.h"

@interface ETMainViewController ()

@property (strong,nonatomic) NSTimer* timer;
@property (strong,nonatomic) ETSettingsViewController* settings;
@property (strong,nonatomic) ETAlertViewController* alert;
@end

enum AlertActionCode{
    AlertActionCancelEmail = 0
};

@implementation ETMainViewController
@synthesize charactersLabel;
@synthesize timer;
@synthesize settings;
@synthesize alert;
@synthesize model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.model = [[ETMainViewModel alloc] initWithDelegate:self];
        self.settings = [[ETSettingsViewController alloc] init];
    }
    
    return self;
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startDetect];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopDetect];
}

- (void)viewDidUnload {
    [self.timer invalidate];
    [self setOkButton:nil];
    [self setCancelButton:nil];
    [self setTitleLabel:nil];
    [self setMessageTextView:nil];
    [super viewDidUnload];
}

- (void)nextValue{
    self.okButton.selected = NO;
    self.cancelButton.selected = NO;
    self.charactersLabel.text = [self.model nextValue];
}

- (void)startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.model.delayTime target:self selector:@selector(nextValue) userInfo:nil repeats:YES];
}

- (IBAction)configureButtonAction:(id)sender {
    [self presentViewController:self.settings animated:YES completion:nil];
}

- (void)stopDetect{
    [self.timer invalidate];
    [self.videoSource stopRunning];
    self.charactersLabel.text = @"";
}

- (void)startDetect{
    if ([self.model isAbleToStart]) {
        [self.videoSource startRunning];
        [self startTimer];
    } else {
        [self presentViewController:self.settings animated:YES completion:nil];
    }
}

#pragma mark - ETViewModelDelegate

-(void)viewModel:(ETMainViewModel*)model didSelectCharacter:(NSString *)character{
    self.okButton.selected = YES;
    if(self.model.selectingContacts){
        if ([self.messageTextView.text length] > 0)
            self.messageTextView.text = [self.messageTextView.text stringByAppendingString:@", "];
        
        [self.model.selectedContacts addObject:character];
    }
    
    self.messageTextView.text = [self.messageTextView.text stringByAppendingString:character];
}

-(void)viewModel:(ETMainViewModel*)model didSelectCommand:(NSString *)command{
    self.okButton.selected = YES;
    if ([command isEqualToString:@"SPACE"]) {
        self.messageTextView.text = [self.messageTextView.text stringByAppendingString:@" "];
    } else if ([command isEqualToString:@"BACKSPACE"] && [self.messageTextView.text length] > 0) {
        self.messageTextView.text = [self.messageTextView.text substringToIndex:[self.messageTextView.text length] - 1];
    } else if ([command isEqualToString:@"CLEAR"]) {
        self.messageTextView.text = @"";
    } else if ([command isEqualToString:@"SEND BY EMAIL"]) {
        self.model.ableToDetect = NO;
        [self.model prepareEmail:self.messageTextView.text];
        self.messageTextView.text = @"";
    } else if ([command isEqualToString:@"SEND"]) {
        [self.model sendEmail];
        self.messageTextView.text = @"";
    } else if ([command isEqualToString:@"DONE"]) {
        [self.model subjectComplete:self.messageTextView.text];
        self.messageTextView.text = @"";
    } else if ([command isEqualToString:@"CANCEL EMAIL"]) {
        self.alert = [[ETAlertViewController alloc] initWithDelegate:self message:@"Would you like cancel the email?" actionCode:AlertActionCancelEmail];
        [self presentViewController:self.alert animated:YES completion:nil];
    }else if ([command isEqualToString:@"DELETE LAST CONTACT"]) {
        if ([self.messageTextView.text length] > 0) {
            NSArray *emails = [self.messageTextView.text componentsSeparatedByString:@", "];
            for (int index = 0; index < [emails count] - 1; index++) {
                if (index > 0)
                    self.messageTextView.text = [self.messageTextView.text stringByAppendingFormat:@", %@",[emails objectAtIndex:index]];
                else
                    self.messageTextView.text = [emails objectAtIndex:index];
            }
            
            [self.model.selectedContacts removeLastObject];
        }
    }
}

-(void)viewModel:(ETMainViewModel*)model didSelectOption:(NSString *)option{
    self.okButton.selected = YES;
}

-(void)viewModelDidDetectCancelAction:(ETMainViewModel*)model{
    self.cancelButton.selected = YES;
}

-(void)viewModel:(ETMainViewModel*)model didChangeTitle:(NSString *)title{
    self.titleLabel.text = title;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationLandscapeRight == toInterfaceOrientation) {
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

- (IBAction)cancelButtonAction:(id)sender {
    [self.model executeCancelAction];
}

- (IBAction)okButtonAction:(id)sender {
    [self.model executeOKAction];
}

- (void)AlertDidApper{
    [self stopDetect];
}

- (void)AlertDidDisapper{
    [self startDetect];
}

- (void)AlertViewControllerDidOKActionExecute:(ETAlertViewController*)sender{
    if (sender.actionCode == AlertActionCancelEmail) {
        [self.model cancelEmail];
        self.messageTextView.text = self.model.message;
        self.titleLabel.text = @"";
        [self.model.selectedContacts removeAllObjects];
    }
    
    [self.alert dismissViewControllerAnimated:YES completion:nil];
}

- (void)AlertViewControllerDidCancelActionExecute:(ETAlertViewController*)sender{
    [self.alert dismissViewControllerAnimated:YES completion:nil];
}

@end
