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
    int sensitivity;
}

- (cv::Rect)maximizeArea:(cv::Rect)area;
- (bool)detectActionInMat:(cv::Mat)mat;

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
        
        [self setSensitivity:DEFAULT_SENSITIVITY];
        if([defaults integerForKey:@"sensitivity"]){
            [self setSensitivity:[defaults integerForKey:@"sensitivity"]];
        }
        
        self.inputType = (ETInputModelType)0;
        if([defaults integerForKey:@"inputType"]){
            self.inputType = (ETInputModelType)[defaults integerForKey:@"inputType"];
        }
    }
    
    return self;
}

- (void)setSensitivity:(int)value{
    sensitivity = (5 - value) * 25;
}

- (int)sensitivity{
    return 5 - (sensitivity / 25);
}

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[ETBlinkDetector alloc] init];
    });
    return _sharedObject;
}

- (cv::Rect)maximizeArea:(cv::Rect)area{
    int deltaW = OPTIMUS_SIZE.width - area.width;
    int deltaH = OPTIMUS_SIZE.height - area.height;
    
    int x = area.x - (deltaW / 2);
    int y = area.y - (deltaH / 2);
    
    return cv::Rect(x > 0 ? x:0, y > 0 ? y:0, OPTIMUS_SIZE.width, OPTIMUS_SIZE.height);
}

- (void)setAreaOK:(cv::Rect)area{
    areaOK =  area;//[self maximizeArea:area];
}

- (void)setAreaCancel:(cv::Rect)area{
    areaCancel = area;//[self maximizeArea:area];
}

- (cv::Rect)areaOK{
    return areaOK;
}

- (cv::Rect)areaCancel{
    return areaCancel;
}

- (cv::Mat)matOK{
    return processedImageOK;
}

- (cv::Mat)matCancel{
    return processedImageCancel;
}

- (bool)detectActionInAreaOK{
    return [self detectActionInMat:processedImageOK];
}

- (bool)detectActionInAreaCancel{
    return [self detectActionInMat:processedImageCancel];
}

- (bool)detectActionInMat:(cv::Mat)matROI{
    bool blink = NO;
    int totalMovement = 0;

    int cols = matROI.cols;
    int channels = matROI.channels();
    uint8_t* pixelPtr = (uint8_t*)matROI.data;
    for(int row=0; row<matROI.rows; row++){
        for(int col=0; col<cols; col++){
            int indexC1 = (row * cols * channels) + (col * channels);
            totalMovement += pixelPtr[indexC1]; // G
        }
    }

    if (totalMovement > sensitivity && totalMovement < MAXIMUM_MOVEMENT) {
        blink = YES;
    }
    
    return blink;
}

- (void)prepareMatrixForAnalysis:(const cv::Mat&)inputImage{
    cv::Mat inputCopy;
    inputImage.copyTo(inputCopy);
    if (previousImageOK.empty()) {
        previousImageOK = cv::Mat(inputCopy, areaOK);
        previousImageCancel = cv::Mat(inputCopy, areaCancel);
    }
    
    inputImage.copyTo(inputCopy);
    processedImageOK = cv::Mat(inputCopy, areaOK);
    cv::subtract(previousImageOK, processedImageOK, processedImageOK);
    cv::cvtColor(processedImageOK, processedImageOK, CV_BGRA2GRAY);
    cv::threshold(processedImageOK, processedImageOK,20,1,cv::THRESH_BINARY);
    
    processedImageCancel = cv::Mat(inputCopy, areaCancel);
    cv::subtract(previousImageCancel, processedImageCancel, processedImageCancel);
    cv::cvtColor(processedImageCancel, processedImageCancel, CV_BGRA2GRAY);
    cv::threshold(processedImageCancel, processedImageCancel,20,1,cv::THRESH_BINARY);
    
    inputImage.copyTo(inputCopy);
    previousImageOK = cv::Mat(inputCopy, areaOK);
    previousImageCancel = cv::Mat(inputCopy, areaCancel);
}



- (void)resetData{
    previousImageOK = cv::Mat();
    processedImageOK = cv::Mat();
    
    previousImageCancel = cv::Mat();
    processedImageCancel = cv::Mat();
}

@end
