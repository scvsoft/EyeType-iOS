//
//  ETAlertViewController.m
//  EyeType
//
//  Created by scvsoft on 11/10/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETAlertViewController.h"
#import "TTTAttributedLabel.h"

@interface ETAlertViewController ()
@property (nonatomic,strong) NSString* message;
@property (nonatomic,strong) ETAlertViewModel *model;
@property (strong,nonatomic) NSTimer* timer;

@end

@implementation ETAlertViewController
@dynamic model;
@synthesize delegate,
            messageLabel,
            OKButton,
            CancelButton,
            message,
            actionCode;


- (id)initWithDelegate:(id<ETAlertDelegate>)Delegate message:(NSString*)msg actionCode:(int)code alertType:(ETAlertViewType)type
{
    self = [super init];
    if (self) {
        self.model = [[ETAlertViewModel alloc] initWithDelegate:self];
        if (type == ETAlertViewTypeOK) {
            self.model.currentValues = [NSMutableArray arrayWithObject:@"OK"];
        } else{
            self.model.currentValues = [NSMutableArray arrayWithObjects:@"OK", @"CANCEL", nil];
        }
        
        self.delegate = Delegate;
        self.message = msg;
        self.actionCode = code;
        self.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.messageLabel.text = message;
    if ([self.delegate respondsToSelector:@selector(AlertDidAppear)]) {
        [self.delegate AlertDidAppear];
    }
    
    [self startTimer];
    [self.separatorView setBackgroundColor:[UIColor ETSeparatorPatern]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.superview.bounds = CGRectMake(-50., -62., 648., 624.);
    [self loadOptions];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.videoSource startRunning];
    
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.videoSource stopRunning];
    if ([self.delegate respondsToSelector:@selector(AlertDidDisapper)]) {
        [self.delegate AlertDidDisapper];
    }
}

- (void)viewDidUnload {
    [self setMessageLabel:nil];
    [self setOKButton:nil];
    [self setCancelButton:nil];
    [self setSeparatorView:nil];
    [self setOptionContainer:nil];
    [super viewDidUnload];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.model executeOKAction];
}

- (IBAction)okButtonAction:(id)sender {
    [self.model executeCancelAction];
}

- (void)alertViewModelDidOKActionExecute{
    [self.delegate AlertViewControllerDidOKActionExecute:self];
}

- (void)alertViewModelDidCancelActionExecute{
    [self.delegate AlertViewControllerDidCancelActionExecute:self];
}

- (void)loadOptions{

    for (NSString *text in [self.model currentValues]) {
        [self.optionContainer addItemWithText:text];
    }
}

- (void)startTimer{
    if (![self.timer isValid]) {
        float delay = self.model.delayTime;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(nextValue) userInfo:nil repeats:YES];
    }
}

- (void)nextValue{
    self.OKButton.selected = NO;
    self.CancelButton.selected = NO;
    
    [self.optionContainer selectNextItem];
}

- (NSString *)viewModelGetCurrentValue{
    return [self.optionContainer selectedText];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationLandscapeRight == toInterfaceOrientation) {
        return YES;
    }
    return NO;
}

@end
