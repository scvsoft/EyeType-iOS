//
//  ETAlertViewController.m
//  EyeType
//
//  Created by scvsoft on 11/10/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETAlertViewController.h"

@interface ETAlertViewController ()
@property (nonatomic,strong) NSString* message;
@property (nonatomic,strong) ETAlertViewModel *model;
@end

@implementation ETAlertViewController
@synthesize delegate,
            messageLabel,
            OKButton,
            CancelButton,
            message,
            model,
            actionCode;


- (id)initWithDelegate:(id<ETAlertDelegate>)Delegate message:(NSString*)msg actionCode:(int)code
{
    self = [super init];
    if (self) {
        self.model = [[ETAlertViewModel alloc] initWithDelegate:self];
        self.delegate = Delegate;
        self.message = msg;
        self.actionCode = code;
        
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageLabel.text = message;
    [self.delegate AlertDidApper];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.videoSource startRunning];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.videoSource stopRunning];
    [self.delegate AlertDidDisapper];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMessageLabel:nil];
    [self setOKButton:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.delegate AlertViewControllerDidCancelActionExecute:self];
}

- (IBAction)okButtonAction:(id)sender {
    [self.delegate AlertViewControllerDidOKActionExecute:self];
}

- (void)alertViewModelDidOKActionExecute{
    [self okButtonAction:nil];
}

- (void)alertViewModelDidCancelActionExecute{
    [self cancelButtonAction:nil];
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

@end
