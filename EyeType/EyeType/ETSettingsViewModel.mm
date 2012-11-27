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
}

@property (nonatomic, strong) NSMutableDictionary *colors;
@end

@implementation ETSettingsViewModel
@synthesize colors;
@synthesize inputType;

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
    }
    
    return self;
}

- (void)configureDefaultValues{
    areaOK = cv::Rect(56,20,36,36);
    areaCancel = cv::Rect(106,20,36,36);
    
    delay = DEFAULT_DELAY;
    sensitivity = DEFAULT_SENSITIVITY;
    
    selectedColor = [UIColor redColor];
}

#pragma mark - opencv Methods

//The function detects the hand from input frame and draws a rectangle around the detected portion of the frame
- (std::vector<cv::Rect>)detectEyes:(cv::Mat&)img withCascade:(std::string *)cascadeFile{
    // Create a new Haar classifier
    static cv::CascadeClassifier cascade = cv::CascadeClassifier(*cascadeFile);
    
    std::vector<cv::Rect> objects;
    cascade.detectMultiScale(img, objects,1.1,1,0,MINIMUM_SIZE,MAXIMUM_SIZE);
    return objects;
}

- (bool)verifySize:(cv::Size)size{
    
    return size.width <= MAXIMUM_SIZE.width && size.height <= MAXIMUM_SIZE.height && size.width >= MINIMUM_SIZE.width && size.height >= MINIMUM_SIZE.height;
}

- (cv::Mat)identifyGestureOK:(cv::Mat&)inputMat{
    //initialize area
    areaOK = cv::Rect(0,0,0,0);
    inputMat.copyTo(outputMat);
    
    //it is left because the image was flip
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_righteye_2splits" ofType:@"xml"];
    std::string *cascade_file = new std::string([filePath UTF8String]);
    std::vector<cv::Rect> objects = [self detectEyes:inputMat withCascade:cascade_file];
    
    int minX = 9999;
    for (int i = 0; i < objects.size(); i++) {
        if(objects[i].x < minX && [self verifySize:objects[i].size()]){
            minX = objects[i].x;
            areaOK = objects[i];
        }
    }
    
    if (areaOK.width > 0) {
        [self.delegate viewModel:self didConfigureArea:areaOK];
        cv::rectangle(outputMat, areaOK, cv::Scalar(0,0,255,255));
    }
    
    return outputMat;
}

- (cv::Mat)identifyGestureCancel:(cv::Mat&)inputMat{
    //initialize area
    areaCancel = cv::Rect(0,0,0,0);
    inputMat.copyTo(outputMat);
    
    //it is right because the image was flip
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_lefteye_2splits" ofType:@"xml"];
    std::string *cascade_file = new std::string([filePath UTF8String]);
    std::vector<cv::Rect> objects = [self detectEyes:inputMat withCascade:cascade_file];
    
    int maxX = 0;
    for (int i = 0; i < objects.size(); i++) {
        if(objects[i].x > maxX && [self verifySize:objects[i].size()]){
            maxX = objects[i].x;
            areaCancel = objects[i];
        }
    }

    if (areaCancel.width > 0) {
        cv::Point p1,p2,p3,p4,p5;
        p1 = cv::Point(areaOK.x,areaOK.y);
        p2 = cv::Point(areaOK.x + areaOK.width,areaOK.y + areaOK.height);
        p3 = cv::Point(areaOK.x,areaOK.y + areaOK.height);
        p4 = cv::Point(areaOK.x + areaOK.width,areaOK.y);
        p5 = cv::Point(areaOK.x + (areaOK.width/ 2),areaOK.y +  (areaOK.height/ 2));
        
        if(!areaCancel.contains(p1) && !areaCancel.contains(p2) && !areaCancel.contains(p3) && !areaCancel.contains(p4) && !areaCancel.contains(p5)){
            [self.delegate viewModel:self didConfigureArea:areaCancel];
            cv::rectangle(outputMat, areaCancel, cv::Scalar(0,0,255,255));
        }
    }
    
    return outputMat;
}

- (float)delayTime{
    return delay;
}

- (int)sensitivity{
    return sensitivity;
}

- (void)setDelayTime:(float)value{
    int aux = (NSUInteger)(value + .5);
    delay = aux * .5;
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
    ETBlinkDetector *bd = [ETBlinkDetector sharedInstance];
    [bd setAreaCancel:areaCancel];
    [bd setAreaOK:areaOK];
    [bd setSensitivity:sensitivity];
    bd.inputType = inputType;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:delay forKey:@"delay"];
    [defaults setInteger:sensitivity forKey:@"sensitivity"];
    [defaults setInteger:inputType forKey:@"inputType"];
    
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
}
@end
