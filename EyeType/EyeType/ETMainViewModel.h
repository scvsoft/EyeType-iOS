//
//  ETViewModel.h
//  EyeType
//
//  Created by scvsoft on 10/31/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETVideoSourceViewModel.h"
#import "ETEmailViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@protocol ETMainViewModelDelegate;

@interface ETMainViewModel : ETVideoSourceViewModel<MFMailComposeViewControllerDelegate>

@property (strong,nonatomic) NSMutableArray* optionsList;
@property (assign,nonatomic) id<ETMainViewModelDelegate> delegate;
@property (assign,nonatomic) float delayTime;
@property (strong,nonatomic) NSString *message;
@property (strong,nonatomic) NSString *subject;
@property (strong,nonatomic) NSMutableArray* selectedContacts;
@property (assign,nonatomic) bool ableToDetect;
@property (strong,nonatomic) UIColor *textColor;
@property (assign, nonatomic) BOOL paused;

- (id)initWithDelegate:(id<ETMainViewModelDelegate>)delegate;
- (bool)isAbleToStart;
- (void)executeOKAction;
- (void)executeCancelAction;
- (void)cancelEmail;
- (void)sendEmail;
- (void)back;
- (void)resetMenus;
- (NSArray *)currentValues;
- (BOOL)isReturningOptions;
- (void)activateDetection;
- (void)initializeMenus;
- (void)resume;
@end

@protocol ETMainViewModelDelegate <NSObject>

-(void)viewModel:(ETMainViewModel*)model didSelectCharacter:(NSString *)message;

-(void)viewModelDidDetectOKAction:(ETMainViewModel*)model;
-(void)viewModelDidDetectCancelAction:(ETMainViewModel*)model;
-(void)viewModelWillCancelEmail;
-(void)viewModelDidSendEmail;
-(void)viewModelDidEnterInPause;
-(void)viewModelDidLeavePause;
-(void)viewModel:(ETMainViewModel *)model didFoundError:(NSString *)errorMessage;
-(void)ViewModelDidLoadNewMenu;
-(void)ViewModelDidCloseMenu;
-(NSString *)viewModelGetCurrentValue;

@end