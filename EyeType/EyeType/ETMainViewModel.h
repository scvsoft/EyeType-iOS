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
@property (assign,nonatomic) bool selectingContacts;
@property (assign,nonatomic) bool ableToDetect;

- (id)initWithDelegate:(id<ETMainViewModelDelegate>)delegate;
- (NSString *)nextValue;
- (bool)isAbleToStart;
- (void)prepareEmail:(NSString *)Message;
- (void)executeOKAction;
- (void)executeCancelAction;
- (void)subjectComplete:(NSString *)Subject;
- (void)cancelEmail;
- (void)sendEmail;

@end

@protocol ETMainViewModelDelegate <NSObject>

-(void)viewModel:(ETMainViewModel*)model didSelectCharacter:(NSString *)character;
-(void)viewModel:(ETMainViewModel*)model didSelectCommand:(NSString *)command;
-(void)viewModel:(ETMainViewModel*)model didSelectOption:(NSString *)option;

-(void)viewModelDidDetectCancelAction:(ETMainViewModel*)model;

@end