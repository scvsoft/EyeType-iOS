//
//  ETHelpViewController.h
//  EyeType
//
//  Created by Hernan on 1/16/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ETHelpViewController;

@protocol ETHelpViewControllerDelegate <NSObject>

- (void) helpViewControllerIsDone: (ETHelpViewController *) helpViewController;

@end

@interface ETHelpViewController : UIPageViewController

- (id) initWithDelegate: (id<ETHelpViewControllerDelegate>) delegate;

@end
