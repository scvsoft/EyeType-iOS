//
//  VideoSource.m
//  GesturesRecognitionFramework
//
//  Created by scvsoft on 10/23/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "VideoSource.h"

@interface VideoSource ()
{
    AVCaptureSession * session;
    NSArray * captureDevices;
    AVCaptureDeviceInput * captureInput;
    AVCaptureVideoDataOutput * captureOutput;
    int currentCameraIndex;
}

- (void)setVideoQuality;

@end

@implementation VideoSource
@synthesize delegate;
@synthesize quality;

- (void)setVideoQuality{
    if (quality == videoQualityLow) {
        [session setSessionPreset:AVCaptureSessionPresetLow];
    } else if (quality == videoQualityMedium) {
        [session setSessionPreset:AVCaptureSessionPresetMedium];
    } else if (quality == videoQualityHigh) {
        [session setSessionPreset:AVCaptureSessionPresetHigh];
    }
}

- (id) init
{
    if (self = [super init])
    {
        currentCameraIndex = 0;
        session = [[AVCaptureSession alloc] init];
        
        captureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        NSError * error;
        // Select a video device, make an input
        for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if ([d position] == AVCaptureDevicePositionFront) {
                captureInput = [AVCaptureDeviceInput deviceInputWithDevice:d error:&error];
                [session addInput:captureInput];
                if ( [session canAddInput:captureInput] )
                    [session addInput:captureInput];
                break;
            }
        }
        
        if (error)
        {
            NSLog(@"Couldn't create video input");
        }
        
        captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        captureOutput.alwaysDiscardsLateVideoFrames = YES;
        
        // Set the video output to store frame in BGRA (It is supposed to be faster)
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [captureOutput setVideoSettings:videoSettings];
        
        /*We create a serial queue to handle the processing of our frames*/
        dispatch_queue_t queue;
        queue = dispatch_queue_create("com.GestureRecognition.cameraQueue", NULL);
        [captureOutput setSampleBufferDelegate:self queue:queue];
        [session addOutput:captureOutput];
    }
    
    return self;
}

- (bool) hasMultipleCameras
{
    return [captureDevices count] > 1;
}

- (AVCaptureVideoOrientation) videoOrientation
{
    AVCaptureConnection * connection = [captureOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection)
        return [connection videoOrientation];
    
    NSLog(@"Warning  - cannot find AVCaptureConnection object");
    return AVCaptureVideoOrientationLandscapeRight;
}

- (void) toggleCamera
{
    currentCameraIndex++;
    int camerasCount = [captureDevices count];
    currentCameraIndex = currentCameraIndex % camerasCount;
    
    AVCaptureDevice *videoDevice = [captureDevices objectAtIndex:currentCameraIndex];
    
    [session beginConfiguration];
    
    if (captureInput)
    {
        [session removeInput:captureInput];
    }
    
    NSError * error;
    captureInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (error)
    {
        NSLog(@"Couldn't create video input");
    }
    
    [session addInput:captureInput];
    [self setVideoQuality];
    [session commitConfiguration];
}

- (void) startRunning
{
    [self setVideoQuality];
    [session startRunning];
}

- (void) stopRunning
{
    [session stopRunning];
}

- (BOOL)isRunning{
    return [session isRunning];
}

#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if (!delegate)
        return;
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t stride = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    cv::Mat frame(height, width, CV_8UC4, (void*)baseAddress, stride);
    
    if ([self videoOrientation] == AVCaptureVideoOrientationLandscapeLeft)
    {
        cv::flip(frame, frame, 0);
    }
    
    [delegate frameCaptured:frame];
    
	/*We unlock the  image buffer*/
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
} 
@end

