//
//  ETHelpViewController.m
//  EyeType
//
//  Created by Hernan on 1/16/13.
//  Copyright (c) 2013 scvsoft. All rights reserved.
//

#import "ETHelpViewController.h"
#import "ETHelpInnerViewController.h"

@interface ETHelpViewController () <UIPageViewControllerDataSource> {
    NSArray *_images;
    id<ETHelpViewControllerDelegate> _delegate;
}

@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) id<ETHelpViewControllerDelegate> delegate;

@end

@implementation ETHelpViewController

- (id) initWithDelegate: (id<ETHelpViewControllerDelegate>) delegate {
    self = [super initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll
                    navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal
                                  options: nil];
    if (self) {
        self.delegate = delegate;
        self.images = [NSArray arrayWithObjects:
                       [UIImage imageNamed: @"0"],
                       [UIImage imageNamed: @"1"],
                       [UIImage imageNamed: @"2"],
                       [UIImage imageNamed: @"3"],
                       [UIImage imageNamed: @"4"],
                       [UIImage imageNamed: @"5"],
                       [UIImage imageNamed: @"6"],
                       [UIImage imageNamed: @"7"],
                       [UIImage imageNamed: @"8"],
                       [UIImage imageNamed: @"9"],
                       [UIImage imageNamed: @"10"],
                       [UIImage imageNamed: @"11"],
                       [UIImage imageNamed: @"12"],
                       [UIImage imageNamed: @"13"],
                       nil];
        
        ETHelpInnerViewController *vc = [ETHelpInnerViewController instanceWithImage: [self.images objectAtIndex: 0]];
        
        self.dataSource = self;
        [self setViewControllers: @[vc]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated: YES
                      completion: NULL];
    }
    
    return self;
}

- (void) viewDidLoad {
    UIImage *doneImage = [UIImage imageNamed: @"done"];
    UIButton *doneButton = [[UIButton alloc] initWithFrame: CGRectMake(900, 700, doneImage.size.width, doneImage.size.height)];
    [doneButton setImage: doneImage forState: UIControlStateNormal];
    [doneButton setImage: [UIImage imageNamed:@"done-pressed"] forState: UIControlStateHighlighted];
    [doneButton addTarget: self action: @selector(dismiss:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: doneButton];
}

- (void) dismiss: (id) sender {
    if (self.delegate) {
        [self.delegate helpViewControllerIsDone: self];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - UIPageViewControllerDataSource implementation

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.images count];
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (UIViewController *) pageViewController:(UIPageViewController *) pvc viewControllerBeforeViewController: (ETHelpInnerViewController *) vc
{
    NSInteger index = vc.index - 1;
    if (index < 0 || index >= [self.images count]) {
        return nil;
    }
    
    ETHelpInnerViewController *innerVC = [ETHelpInnerViewController instanceWithImage: [self.images objectAtIndex: index]];
    innerVC.index = index;
    return innerVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(ETHelpInnerViewController *) vc
{
    NSInteger index = vc.index + 1;
    if (index < 0 || index >= [self.images count]) {
        return nil;
    }

    ETHelpInnerViewController *innerVC = [ETHelpInnerViewController instanceWithImage: [self.images objectAtIndex: index]];
    innerVC.index = index;
    return innerVC;
}

@end

