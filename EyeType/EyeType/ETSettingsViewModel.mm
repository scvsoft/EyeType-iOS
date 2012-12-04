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
    int sensitivity;
    float delay;
    UIColor *selectedColor;
    NSString *configuringAreaName, *lastConfiguredArea;
}

@property (nonatomic, strong) NSMutableDictionary *colors;
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
        
        selectedColor = [UIColor redColor];
        if([defaults objectForKey:@"textColor"]){
            NSData *colorData = [defaults objectForKey:@"textColor"];
            selectedColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        }
        
        areaOK = [[ETBlinkDetector sharedInstance] areaOK];
        areaCancel = [[ETBlinkDetector sharedInstance] areaCancel];
        sensitivity = [[ETBlinkDetector sharedInstance] sensitivity];
        inputType = [[ETBlinkDetector sharedInstance] inputType];
        
        colors = [NSMutableDictionary dictionary];
        [colors setObject:[UIColor whiteColor] forKey:@"White"];
        [colors setObject:[UIColor blackColor] forKey:@"Black"];
        [colors setObject:[UIColor redColor] forKey:@"Red"];
        [colors setObject:[UIColor greenColor] forKey:@"Green"];
        [colors setObject:[UIColor blueColor] forKey:@"Blue"];
        [colors setObject:[UIColor grayColor] forKey:@"Gray"];
        [colors setObject:[UIColor orangeColor] forKey:@"Orange"];
        [colors setObject:[UIColor yellowColor] forKey:@"Yellow"];
        [colors setObject:[UIColor purpleColor] forKey:@"Purple"];
        configuringAreaName = @"OK";
        lastConfiguredArea = @"";
    }
    
    return self;
}

- (void)configureDefaultValues{
    inputType = ETInputModelTypeOneSource;
    areaOK = cv::Rect(56,20,100,36);
    configuringAreaName = @"OK";
    
    areaCancel = cv::Rect(0,0,0,0);
    
    [self setDelayTime:DEFAULT_DELAY];
    sensitivity = DEFAULT_SENSITIVITY;
    selectedColor = [UIColor greenColor];
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

- (int)sensitivity{
    return sensitivity;
}

- (void)removeConfiguredArea{
    configuringAreaName = lastConfiguredArea;
    if ([configuringAreaName isEqualToString:@"CANCEL"] || self.inputType == ETInputModelTypeOneSource ) {
        areaCancel = cv::Rect(0,0,0,0);
    } else if ([configuringAreaName isEqualToString:@"OK"]) {
        areaOK = cv::Rect(0,0,0,0);
    }
}

- (void)setSesitivity:(float)value{
    sensitivity = (NSUInteger)(value + .5);
}

- (bool)isAbleToSave{
    int WOK = areaOK.width;
    int WCA = areaCancel.width;
    bool result = (WOK > 0 &&  WCA > 0) || (WOK > 0 && inputType == ETInputModelTypeOneSource);
    return  result;
}

- (void)save{
    if (delay == NSNotFound) {
        [self setDelayTime:DEFAULT_DELAY];
    }
    
    if (sensitivity == NSNotFound) {
        sensitivity = DEFAULT_SENSITIVITY;
    }
    
    ETBlinkDetector *bd = [ETBlinkDetector sharedInstance];
    [bd setAreaCancel:areaCancel];
    [bd setAreaOK:areaOK];
    [bd setSensitivity:sensitivity];
    bd.inputType = inputType;
    [bd resetData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:delay forKey:@"delay"];
    [defaults setInteger:sensitivity forKey:@"sensitivity"];
    [defaults setInteger:(int)inputType forKey:@"inputType"];
    
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:selectedColor];
    [defaults setObject:colorData forKey:@"textColor"];
    
    ETRect *rectOK = [[ETRect alloc] initWithRect:areaOK];
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:rectOK];
    [defaults setObject:myEncodedObject forKey:@"areaOK"];
    
    ETRect *rectCancel = [[ETRect alloc] initWithRect:areaCancel];
    NSData *myEncodedObject2 = [NSKeyedArchiver archivedDataWithRootObject:rectCancel];
    [defaults setObject:myEncodedObject2 forKey:@"areaCancel"];
    
    [defaults synchronize];
    
    [self.delegate viewModelDidFinishSave];
}

- (NSString *)colorNameAtIndex:(int)index{
    NSString *key = [[colors allKeys] objectAtIndex:index];
    return key;
}

- (void)selectColorAtIndex:(int)index{
    NSString *key = [[colors allKeys] objectAtIndex:index];
    UIColor *color = [colors objectForKey:key];
    selectedColor = color;
}

- (int)selectedColorIndex{
    for (int i = 0; i < [colors count]; i++) {
        NSString *key = [[colors allKeys] objectAtIndex:i];
        if ([selectedColor isEqual:[colors objectForKey:key]]) {
            return i;
        }
    }
    
    return 0;
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
        configuringAreaName = @"OK";
    }
}

- (NSString *)configuringAreaName{
    return configuringAreaName;
}

- (NSString *)configuredAreaName{
    return lastConfiguredArea;
}

- (void)areaDetectionView:(ETAreaDetectionView *)sender didDetectArea:(cv::Rect)area{
    lastConfiguredArea = configuringAreaName;
    if (self.inputType == ETInputModelTypeOneSource || [configuringAreaName isEqualToString:@"OK"]) {
        areaOK = area;
        if(self.inputType != ETInputModelTypeOneSource )
            configuringAreaName = @"CANCEL";
    } else if (self.inputType == ETInputModelTypeTwoSources && [configuringAreaName isEqualToString:@"CANCEL"]){
        areaCancel = area;
        configuringAreaName = @"OK";
    }
    
    self.areaSelected = YES;
    [self.delegate viewModel:self didConfigureArea:area];
}

@end
