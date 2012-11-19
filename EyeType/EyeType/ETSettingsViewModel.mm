//
//  ETSettingsViewModel.mm
//  EyeType
//
//  Created by scvsoft on 11/1/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETSettingsViewModel.h"
#import "ETBlinkDetector.h"

#define MINIMUM_SIZE cv::Size(12,12)
#define MAXIMUM_SIZE cv::Size(36,36)

@interface ETSettingsViewModel(){
    cv::Mat outputMat;
    cv::Rect areaOK;
}

@end

@implementation ETSettingsViewModel

- (void)configureDefaultValues{
    [[ETBlinkDetector sharedInstance] setAreaOK:cv::Rect(81,20,36,36)];
    [[ETBlinkDetector sharedInstance] setAreaCancel:cv::Rect(131,20,36,36)];
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
        [[ETBlinkDetector sharedInstance] setAreaOK:areaOK];
        [self.delegate viewModel:self didConfigureArea:areaOK];
        cv::rectangle(outputMat, areaOK, cv::Scalar(0,0,255,255));
    }
    
    return outputMat;
}

- (cv::Mat)identifyGestureCancel:(cv::Mat&)inputMat{
    //initialize area
    cv::Rect areaCancel = cv::Rect(0,0,0,0);
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
            [[ETBlinkDetector sharedInstance] setAreaCancel:areaCancel];
            [self.delegate viewModel:self didConfigureArea:areaCancel];
            cv::rectangle(outputMat, areaCancel, cv::Scalar(0,0,255,255));
        }
    }
    
    return outputMat;
}

@end
