//
//  ETSettingsViewModel.h
//  EyeType
//
//  Created by scvsoft on 11/1/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ETSettingsViewModelDelegate;

@interface ETSettingsViewModel : NSObject

@property (nonatomic, assign) id<ETSettingsViewModelDelegate> delegate;
- (void)configureDefaultValues;
- (cv::Mat)identifyGestureOK:(cv::Mat&)inputMat;
- (cv::Mat)identifyGestureCancel:(cv::Mat&)inputMat;

- (float)delayTime;
- (int)sensitivity;

- (void)setDelayTime:(float)delay;
- (void)setSesitivity:(float)value;
- (void)save;
- (bool)isAbleToSave;
- (NSString *)colorNameAtIndex:(int)index;
- (void)selectColorAtIndex:(int)index;
- (int)selectedColorIndex;
- (int)colorsCount;
- (UIColor *)selectedColor;

@end

@protocol ETSettingsViewModelDelegate <NSObject>

-(void)viewModel:(ETSettingsViewModel*)model didConfigureArea:(cv::Rect)area;
-(void)viewModelDidFinishSave;

@end
