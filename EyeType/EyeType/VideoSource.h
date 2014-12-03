//
//  VideoSource.h
//  GesturesRecognitionFramework
//
//  Created by scvsoft on 10/23/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

@protocol VideoSourceDelegate <NSObject>

#ifdef __cplusplus
- (void)frameCaptured:(cv::Mat) frame;
#endif

@end

@interface VideoSource : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

typedef NS_ENUM(NSInteger, VideoQuality) {
    VideoQualityLow,
    VideoQualityMedium,
    VideoQualityHigh
};

@property id<VideoSourceDelegate> delegate;
@property (nonatomic,assign) VideoQuality quality;
- (AVCaptureVideoOrientation) videoOrientation;
- (bool) hasMultipleCameras;
- (void) toggleCamera;

- (void) startRunning;
- (void) stopRunning;
- (BOOL)isRunning;

@end

//! A "fake" video source that does not perform video capture but generates a simple image.
//! It's interface is equal to real video source to let us test video-processing on iOS simulator too.
@interface DummyVideoSource : NSObject

@property id<VideoSourceDelegate> delegate;

- (id) initWithFrameSize:(CGSize) frameSize;

- (AVCaptureVideoOrientation) videoOrientation;
- (bool) hasMultipleCameras;
- (void) toggleCamera;

- (void) startRunning;
- (void) stopRunning;

@end
