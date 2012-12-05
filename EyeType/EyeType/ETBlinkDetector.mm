//
//  ETBlinkDetector.m
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETBlinkDetector.h"
#import "ETRect.h"

#define OPTIMUS_SIZE cv::Size(36,36)
#define MAXIMUM_MOVEMENT 200
#define DEFAULT_SENSITIVITY 2

@interface ETBlinkDetector() {
    cv::Rect areaOK;
    cv::Rect areaCancel;
    cv::Mat previousImageOK, previousImageCancel, outputMat, processedImageOK, processedImageCancel;
    int sensitivitySectionOK, sensitivitySectionCancel;
}

@end

@implementation ETBlinkDetector
@synthesize inputType;

- (id)init{
    self = [super init];
    if(self){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        areaOK = cv::Rect(0,0,0,0);
        if([defaults objectForKey:@"areaOK"]){
            NSData *areaOKData = [defaults objectForKey:@"areaOK"];
            ETRect *aux = [NSKeyedUnarchiver unarchiveObjectWithData:areaOKData];
            areaOK = [aux rect];
        }
        
        areaCancel = cv::Rect(0,0,0,0);
        if([defaults objectForKey:@"areaCancel"]){
            NSData *areaCancelData = [defaults objectForKey:@"areaCancel"];
            ETRect *aux = [NSKeyedUnarchiver unarchiveObjectWithData:areaCancelData];
            areaCancel = [aux rect];
        }
        
        [self setSensitivitySectionOK:DEFAULT_SENSITIVITY];
        if([defaults integerForKey:@"sensitivitySectionOK"]){
            [self setSensitivitySectionOK:[defaults integerForKey:@"sensitivitySectionOK"]];
        }
        
        [self setSensitivitySectionCancel:DEFAULT_SENSITIVITY];
        if([defaults integerForKey:@"sensitivitySectionCancel"]){
            [self setSensitivitySectionCancel:[defaults integerForKey:@"sensitivitySectionCancel"]];
        }
        
        self.inputType = (ETInputModelType)0;
        if([defaults integerForKey:@"inputType"]){
            self.inputType = (ETInputModelType)[defaults integerForKey:@"inputType"];
        }
    }
    
    return self;
}

- (void)setSensitivitySectionOK:(int)value{
    //modified value to adapt to movement quantity
    sensitivitySectionOK = (5 - value) * 25;
}

- (int)sensitivitySectionOK{
    //return the original value of sensitivity
    return 5 - (sensitivitySectionOK / 25);
}

- (void)setSensitivitySectionCancel:(int)value{
    //modified value to adapt to movement quantity
    sensitivitySectionCancel = (5 - value) * 25;
}

- (int)sensitivitySectionCancel{
    //return the original value of sensitivity
    return 5 - (sensitivitySectionCancel / 25);
}

+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[ETBlinkDetector alloc] init];
    });
    return _sharedObject;
}

- (void)setAreaOK:(cv::Rect)area {
    areaOK =  area;
}

- (void)setAreaCancel:(cv::Rect)area {
    areaCancel = area;
}

- (cv::Rect)areaOK {
    return areaOK;
}

- (cv::Rect)areaCancel {
    return areaCancel;
}

- (cv::Mat)matOK {
    return processedImageOK;
}

- (cv::Mat)matCancel {
    return processedImageCancel;
}

- (bool)detectActionInAreaOK {
    return [self detectActionInMat:processedImageOK withSensitivity:sensitivitySectionOK];
}

- (bool)detectActionInAreaCancel {
    return [self detectActionInMat:processedImageCancel withSensitivity:sensitivitySectionCancel];
}

//This method is the responsible of detect the movement
- (bool)detectActionInMat:(cv::Mat)matROI withSensitivity:(int)sensitivity{
    bool detectedMovement = NO;
    int movementQuantity = 0;

    int cols = matROI.cols;
    int channels = matROI.channels();
    uint8_t* pixelPtr = (uint8_t*)matROI.data;
    for(int row=0; row<matROI.rows; row++){
        for(int col=0; col<cols; col++){
            int indexC1 = (row * cols * channels) + (col * channels);
            movementQuantity += pixelPtr[indexC1]; // Gray
        }
    }
    
    //if movementQuantity is mayor that the minimum required (sensitivity) then a movement is detected
    if (movementQuantity > sensitivity && movementQuantity < MAXIMUM_MOVEMENT) {
        detectedMovement = YES;
    }
    
    return detectedMovement;
}

//Prepare the neccesary data to start the movement analysis
- (void)prepareMatrixForAnalysis:(const cv::Mat&)inputImage {
    cv::Mat inputCopy;
    inputImage.copyTo(inputCopy);
    
    //If the first time that the method is executed the previous images need be setted
    if (previousImageOK.empty()) {
        previousImageOK = cv::Mat(inputCopy, areaOK);
        previousImageCancel = cv::Mat(inputCopy, areaCancel);
    }
    
    //section "OK" is processed, return a binary matrix (processedImageOK)
    inputImage.copyTo(inputCopy);
    processedImageOK = cv::Mat(inputCopy, areaOK);
    cv::subtract(previousImageOK, processedImageOK, processedImageOK);
    cv::cvtColor(processedImageOK, processedImageOK, CV_BGRA2GRAY);
    cv::threshold(processedImageOK, processedImageOK,20,1,cv::THRESH_BINARY);
    
    //section "CANCEL" is processed, return a binary matrix (processedImageCancel)
    processedImageCancel = cv::Mat(inputCopy, areaCancel);
    cv::subtract(previousImageCancel, processedImageCancel, processedImageCancel);
    cv::cvtColor(processedImageCancel, processedImageCancel, CV_BGRA2GRAY);
    cv::threshold(processedImageCancel, processedImageCancel,20,1,cv::THRESH_BINARY);
    
    // set the current image as previuos images for the next analysis
    inputImage.copyTo(inputCopy);
    previousImageOK = cv::Mat(inputCopy, areaOK);
    previousImageCancel = cv::Mat(inputCopy, areaCancel);
}

//set the important values for analysis as empty
- (void)resetData {
    previousImageOK = cv::Mat();
    processedImageOK = cv::Mat();
    
    previousImageCancel = cv::Mat();
    processedImageCancel = cv::Mat();
}

@end
