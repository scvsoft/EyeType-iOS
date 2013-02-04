//
//  ETSettingsViewModel.h
//  EyeType
//
//  Created by scvsoft on 11/1/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETAreaDetectionView.h"
@protocol ETSettingsViewModelDelegate;

@interface ETSettingsViewModel : NSObject<ETAreaDetectionViewDelegate>

@property (nonatomic, assign) id<ETSettingsViewModelDelegate> delegate;
@property (nonatomic, assign) ETInputModelType inputType;
@property (nonatomic, assign) BOOL areaSelected;
@property (nonatomic, strong) NSString *defaultSubject;
@property (nonatomic, strong) NSString *email;

- (void)configureDefaultValues;

- (float)delayTime;
- (int)sensitivitySectionOK;
- (int)sensitivitySectionCancel;

- (void)setDelayTime:(float)delay;
- (void)setSensitivitySectionOK:(float)value;
- (void)setSensitivitySectionCancel:(float)value;

- (void)save;
- (bool)isActionAreaSet;
- (bool)isEmailSet;
- (void)selectColorAtIndex:(int)index;
- (int)selectedColorIndex;
- (int)colorsCount;
- (UIColor *)selectedColor;
- (void)setInputModel:(ETInputModelType)inputType;
- (cv::Rect)areaOK;
- (cv::Rect)areaCancel;
- (int)configuredArea;
- (int)configuringArea;
- (void)removeConfiguredArea;
- (void)changeConfiguringArea;
@end

@protocol ETSettingsViewModelDelegate <NSObject>

-(void)viewModel:(ETSettingsViewModel*)model didConfigureArea:(cv::Rect)area;
-(void)viewModelDidFinishSave;

@end
