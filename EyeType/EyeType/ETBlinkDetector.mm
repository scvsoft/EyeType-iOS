//
//  ETBlinkDetector.m
//  EyeType
//
//  Created by scvsoft on 11/9/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETBlinkDetector.h"

#define OPTIMUS_SIZE cv::Size(36,36)

@interface ETBlinkDetector() {
    cv::Rect areaOK;
    cv::Rect areaCancel;
    cv::Mat previousImageOK, previousImageCancel, outputMat, processedImageOK, processedImageCancel;
}

- (cv::Rect)maximizeArea:(cv::Rect)area;
- (bool)detectActionInMat:(cv::Mat)mat;

@end

@implementation ETBlinkDetector

- (id)init{
    self = [super init];
    if(self){
        areaOK = cv::Rect(0,0,0,0);
        areaCancel = cv::Rect(0,0,0,0);
    }
    
    return self;
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
    areaOK =  [self maximizeArea:area];
}

- (void)setAreaCancel:(cv::Rect)area{
    areaCancel = [self maximizeArea:area];
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

    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    
    /// Find contours
    cv::findContours( matROI, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    
    int totalMovement = 0;
    /// Get the moments
    std::vector<cv::Moments> mu(contours.size() );
    for( int i = 0; i < contours.size(); i++ )
    {
        mu[i] = moments( contours[i], false );
        totalMovement += mu[i].m00;
    }
    
    if (totalMovement > 25) {
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
    cv::threshold(processedImageOK, processedImageOK,40,255,cv::THRESH_BINARY);
    
    processedImageCancel = cv::Mat(inputCopy, areaCancel);
    cv::subtract(previousImageCancel, processedImageCancel, processedImageCancel);
    cv::cvtColor(processedImageCancel, processedImageCancel, CV_BGRA2GRAY);
    cv::threshold(processedImageCancel, processedImageCancel,40,255,cv::THRESH_BINARY);
    
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
