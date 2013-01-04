//
//  ETAlertViewModel.m
//  EyeType
//
//  Created by scvsoft on 11/10/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETAlertViewModel.h"

@interface ETAlertViewModel()
@property(nonatomic,strong) id<ETAlertViewModelDelegate> delegate;
@end

@implementation ETAlertViewModel
@synthesize delegate;
@synthesize delayTime;
@synthesize textColor;
@synthesize currentValues;

- (id)initWithDelegate:(id<ETAlertViewModelDelegate>)Delegate {
    self = [super init];
    if(self){
        self.delegate = Delegate;
        
        self.textColor = [UIColor redColor];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"textColor"]){
            NSData *colorData = [defaults objectForKey:@"textColor"];
            self.textColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        }
    }
    
    return self;
}

- (float)delayTime{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float delay = [defaults floatForKey:@"delay"];
    
    return MAX(delay, 1.);
}

- (void)executeOKAction {
    NSString* value = [self.delegate viewModelGetCurrentValue];
    if ([value isEqualToString:@"OK"]) {
        [self.delegate alertViewModelDidOKActionExecute];
    }else if ([value isEqualToString:@"CANCEL"]){
        [self.delegate alertViewModelDidCancelActionExecute];
    }
}

- (void)executeCancelAction {
    [self.delegate alertViewModelDidCancelActionExecute];
}

- (cv::Mat)movementDetector:(ETMovementDetector *)detector DidFinishWithMat:(cv::Mat)sourceMat {
    cv::rectangle(sourceMat, [[ETBlinkDetector sharedInstance] areaOK], [self.textColor scalarFromColor]);
    if ([[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeTwoSources) {
        cv::rectangle(sourceMat, [[ETBlinkDetector sharedInstance] areaCancel], [[UIColor ETRed] scalarFromColor]);
    }
    
    return sourceMat;
}

@end
