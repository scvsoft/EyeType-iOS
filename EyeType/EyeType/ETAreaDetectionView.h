//
//  ETAreaDetectionView.h
//  EyeType
//
//  Created by scvsoft on 11/27/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ETAreaDetectionViewDelegate;

@interface ETAreaDetectionView : UIView
@property (nonatomic,assign) id<ETAreaDetectionViewDelegate> delegate;
@end

@protocol ETAreaDetectionViewDelegate <NSObject>

- (void)areaDetectionView:(ETAreaDetectionView *)sender didDetectArea:(cv::Rect)area;

@end