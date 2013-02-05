//
//  ETSettingsViewModel.mm
//  EyeType
//
//  Created by scvsoft on 11/1/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETSettingsViewModel.h"
#import "ETRect.h"

#define MINIMUM_SIZE cv::Size(12,12)
#define MAXIMUM_SIZE cv::Size(36,36)

#define DEFAULT_DELAY 3
#define DEFAULT_SENSITIVITY 2

@interface ETSettingsViewModel(){
    cv::Mat outputMat;
    cv::Rect areaOK, areaCancel;
    int sensitivitySectionOK, sensitivitySectionCancel;
    float delay;
    UIColor *selectedColor;
    int configuringArea, lastConfiguredArea;
}

@property (nonatomic, strong) NSArray *colors;
@end

@implementation ETSettingsViewModel
@synthesize colors;
@synthesize inputType;
@synthesize areaSelected;

- (id)init{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        delay = NSNotFound;
        if ([defaults floatForKey:@"delay"]) {
            delay = [defaults floatForKey:@"delay"];
        }
        
        selectedColor = [UIColor ETGreen];
        if([defaults objectForKey:@"textColor"]){
            NSData *colorData = [defaults objectForKey:@"textColor"];
            selectedColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        }
        
        if([defaults objectForKey:@"subject"]){
            self.defaultSubject = [defaults objectForKey:@"subject"];
        }
        
        if([defaults objectForKey:@"email"]){
            self.email = [defaults objectForKey:@"email"];
        }        
        
        areaOK = [[ETBlinkDetector sharedInstance] areaOK];
        areaCancel = [[ETBlinkDetector sharedInstance] areaCancel];
        sensitivitySectionOK = [[ETBlinkDetector sharedInstance] sensitivitySectionOK];
        sensitivitySectionCancel = [[ETBlinkDetector sharedInstance] sensitivitySectionCancel];
        inputType = [[ETBlinkDetector sharedInstance] inputType];
        
        colors = [NSArray arrayWithObjects:[UIColor ETGreen], [UIColor ETLightBlue], [UIColor ETLightGreen], [UIColor ETPurple], nil];
        
        configuringArea = 0;
        lastConfiguredArea = NSNotFound;
    }
    
    return self;
}

- (void)configureDefaultValues{
    inputType = ETInputModelTypeOneSource;
    areaOK = cv::Rect(56,20,100,36);
    configuringArea = 0;
    
    areaCancel = cv::Rect(0,0,0,0);
    
    [self setDelayTime:DEFAULT_DELAY];
    sensitivitySectionOK = DEFAULT_SENSITIVITY;
    sensitivitySectionCancel = DEFAULT_SENSITIVITY;
    selectedColor = [UIColor ETGreen];
}

- (bool)verifySize:(cv::Size)size{
    return size.width <= MAXIMUM_SIZE.width && size.height <= MAXIMUM_SIZE.height && size.width >= MINIMUM_SIZE.width && size.height >= MINIMUM_SIZE.height;
}

- (cv::Rect)areaOK{
    return areaOK;
}

- (cv::Rect)areaCancel{
    return areaCancel;
}
- (float)delayTime{
    return delay;
}

- (void)setDelayTime:(float)value{
    int aux = (NSUInteger)(value + .5);
    delay = aux * .25;
}

- (int)sensitivitySectionOK{
    return sensitivitySectionOK;
}

- (int)sensitivitySectionCancel{
    return sensitivitySectionCancel;
}

- (void)setSensitivitySectionOK:(float)value{
    sensitivitySectionOK = (NSUInteger)(value + .5);
}

- (void)setSensitivitySectionCancel:(float)value{
    sensitivitySectionCancel = (NSUInteger)(value + .5);
}

- (void)removeConfiguredArea{
    configuringArea = lastConfiguredArea;
    if (configuringArea == 1) {
        areaCancel = cv::Rect(0,0,0,0);
    } else if (configuringArea == 0) {
        areaOK = cv::Rect(0,0,0,0);
        if (self.inputType == ETInputModelTypeOneSource ) {
            areaCancel = cv::Rect(0,0,0,0);
        }
    }
}

- (bool)isActionAreaSet {
    int WOK = areaOK.width;
    int WCA = areaCancel.width;
    bool result = (WOK > 0 &&  WCA > 0) || (WOK > 0 && inputType == ETInputModelTypeOneSource);
    return result;
}

- (bool)isEmailSet {
    return self.email.length > 0;
}

- (bool) isValidEmail {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" options:NSRegularExpressionCaseInsensitive error:NULL];
    return [regex numberOfMatchesInString: self.email options: 0 range: NSMakeRange(0, self.email.length)] > 0;
}

- (void)save{
    if (delay == NSNotFound) {
        [self setDelayTime:DEFAULT_DELAY];
    }
    
    if (sensitivitySectionOK == NSNotFound) {
        sensitivitySectionOK = DEFAULT_SENSITIVITY;
    }
    
    if (sensitivitySectionCancel == NSNotFound) {
        sensitivitySectionCancel = DEFAULT_SENSITIVITY;
    }
    
    ETBlinkDetector *bd = [ETBlinkDetector sharedInstance];
    [bd setAreaCancel:areaCancel];
    [bd setAreaOK:areaOK];
    [bd setSensitivitySectionCancel:sensitivitySectionCancel];
    [bd setSensitivitySectionOK:sensitivitySectionOK];
    bd.inputType = inputType;
    [bd resetData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:delay forKey:@"delay"];
    [defaults setInteger:sensitivitySectionOK forKey:@"sensitivitySectionOK"];
    [defaults setInteger:sensitivitySectionCancel forKey:@"sensitivitySectionCancel"];
    [defaults setInteger:(int)inputType forKey:@"inputType"];
    if ([self.defaultSubject length] > 0) {
        [defaults setObject:self.defaultSubject forKey:@"subject"];
    }
    [defaults setObject:self.email forKey:@"email"];
    
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:selectedColor];
    [defaults setObject:colorData forKey:@"textColor"];
    
    ETRect *rectOK = [[ETRect alloc] initWithRect:areaOK];
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:rectOK];
    [defaults setObject:myEncodedObject forKey:@"areaOK"];
    
    ETRect *rectCancel = [[ETRect alloc] initWithRect:areaCancel];
    NSData *myEncodedObject2 = [NSKeyedArchiver archivedDataWithRootObject:rectCancel];
    [defaults setObject:myEncodedObject2 forKey:@"areaCancel"];
    
    [defaults setBool: YES forKey: @"ableToStart"];
    
    [defaults synchronize];
    
    [self.delegate viewModelDidFinishSave];
}

- (void)selectColorAtIndex:(int)index{
    selectedColor = [colors objectAtIndex:index];
}

- (int)selectedColorIndex{    
    return [colors indexOfObject:selectedColor];
}

- (int)colorsCount{
    return [colors count];
}

- (UIColor *)selectedColor{
    return selectedColor;
}

- (void)setInputModel:(ETInputModelType)inputModelType{
    inputType = inputModelType;
    if (inputType == ETInputModelTypeOneSource) {
        configuringArea = 0;
    }
}

- (void)changeConfiguringArea{
    if (self.inputType == ETInputModelTypeOneSource){
        configuringArea = 0;
    } else if (self.inputType == ETInputModelTypeTwoSources && self.areaOK.size().width > 0 && self.areaOK.size().height > 0) {
        configuringArea = configuringArea == 0 ? 1:0;
    }
}

- (int)configuringArea{
    return configuringArea;
}

- (int)configuredArea{
    return lastConfiguredArea;
}

- (void)areaDetectionView:(ETAreaDetectionView *)sender didDetectArea:(cv::Rect)area{
    lastConfiguredArea = configuringArea;
    if (self.inputType == ETInputModelTypeOneSource || configuringArea == 0) {
        areaOK = area;
        if(self.inputType != ETInputModelTypeOneSource )
            configuringArea = 1;
    } else if (self.inputType == ETInputModelTypeTwoSources && configuringArea == 1){
        areaCancel = area;
        configuringArea = 0;
    }
    
    self.areaSelected = YES;
    [self.delegate viewModel:self didConfigureArea:area];
}

@end
