//
//  ETViewModel.mm
//  EyeType
//
//  Created by scvsoft on 10/31/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMainViewModel.h"
#import "ETMenuValue.h"

#define INTERVAL_FOR_PAUSE 1.5

@interface ETMainViewModel()

@property (nonatomic,strong) NSMutableArray *contactsList;
@property (nonatomic,assign) int currentContactIndex;
@property (strong,nonatomic) NSMutableArray *menus;
@property (strong,nonatomic) ETMenuValue *currentMenu;
@property (assign, nonatomic) BOOL writingSubject;
@property (assign, nonatomic) BOOL paused;
@property (assign, nonatomic) NSTimeInterval lastActionTime;
- (void)mainMenuAction;
- (void)emailSubjectMenuAction;
- (void)contactsMenuAction;
- (void)prepareEmail;
- (void)subjectComplete;

@end

@implementation ETMainViewModel

@synthesize delegate;
@synthesize delayTime;
@synthesize message;
@synthesize subject;
@synthesize ableToDetect;
@synthesize textColor;
@synthesize currentValues;
@synthesize menus;
@synthesize currentMenu;
@synthesize paused;
@synthesize lastActionTime;

- (id)initWithDelegate:(id<ETMainViewModelDelegate>)Delegate{
    self = [super init];
    if (self) {
        self.delegate = Delegate;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.delayTime = 0;
        if([defaults floatForKey:@"delay"]){
            self.delayTime = [defaults floatForKey:@"delay"];
        }
        
        self.textColor = [UIColor redColor];
        if([defaults objectForKey:@"textColor"]){
            NSData *colorData = [defaults objectForKey:@"textColor"];
            self.textColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        }
        
        self.subject = @"";
        self.message = @"";
        
        [self resetMenus];
    }
    
    return self;
}

-(void)activateDetection{
    self.ableToDetect = YES;
}

- (NSString *)nextValue{
    [self performSelector:@selector(activateDetection) withObject:nil afterDelay:.3];
    NSString *value = @"";
    self.currentValues = [NSArray array];
    if (!self.paused) {
        value = [self.currentMenu nextValue];
        self.currentValues = [self.currentMenu availableValues];
    } else{
        value = @"PAUSE, TO ACTIVE THE APPLICATION 2 BLINKS IN LESS THAN 1 SECOND";
    }
    
    return value;
}

- (void)back{
    [self.currentMenu reset];
}

- (bool)isAbleToStart{
    int WOK = [[ETBlinkDetector sharedInstance] areaOK].width;
    int WCA = [[ETBlinkDetector sharedInstance] areaCancel].width;
    bool result = ((WOK > 0 &&  WCA > 0) || (WOK > 0 && [[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeOneSource)) && (self.delayTime > 0  && self.delayTime != NSNotFound);
    return  result;
}

- (void)executeOKAction{
    if (!paused) {
        if(self.ableToDetect){
            self.ableToDetect = NO;
            if(self.currentMenu.returnOptions){
                NSString *option = [self.currentMenu currentValue];
                [self executeMenuAction:option];
                [self.delegate viewModel:self didSelectCommand:option];
            }else{
                if ([self respondsToSelector:self.currentMenu.menuActionSelector]) {
                    [self performSelector:self.currentMenu.menuActionSelector];
                }
                
                [self.currentMenu reStartValues];
            }
        }
    } else{
        [self actionInPause];
    }
    
    [[ETBlinkDetector sharedInstance] resetData];
}

- (void)actionInPause{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.lastActionTime;
    if (interval < INTERVAL_FOR_PAUSE) {
        self.paused = NO;
        [self.delegate viewModelDidLeavePause];
    }
    
    self.lastActionTime = now;
}

- (void)executeMenuAction:(NSString*)action {
        id value = [self.currentMenu.menu objectForKey:action];
        if ([value isKindOfClass:[ETMenuValue class]]) {
            [self.currentMenu reset];
            self.currentMenu = value;
        } else if(value != nil){
            [self.currentMenu selectCurrentOption];
        }
}

- (void)executeCancelAction{
    if(self.ableToDetect){
        self.ableToDetect = NO;
        if(self.currentMenu.returnOptions){
            [self executeMenuAction:@"BACK"];
        }
        
        [self back];
        [self.delegate viewModelDidDetectCancelAction:self];
    }
}

- (void)mainMenuAction{
    self.writingSubject = NO;
    if ([[self.currentMenu selectedOption] isEqualToString:@"LETTERS"] || [[self.currentMenu selectedOption] isEqualToString:@"NUMBERS"]) {
        [self writeMessageAction];
    } else if([[self.currentMenu selectedOption] isEqualToString:@"COMMANDS"]){
         NSString *value = [self.currentMenu currentValue];
        if([value isEqualToString:@"BACK"]){
            [self back];
        } else if ([value isEqualToString:@"SEND BY EMAIL"]) {
            self.ableToDetect = NO;
            [self prepareEmail];
            
            [self.delegate viewModel:self didSelectCharacter:self.subject];
        } else if ([value isEqualToString:@"PAUSE"]) {
            self.paused = YES;
            [self.delegate viewModelDidEnterInPause];
        }
    }
}

- (void)emailSubjectMenuAction{
    self.writingSubject = YES;
    if ([[self.currentMenu selectedOption] isEqualToString:@"LETTERS"] || [[self.currentMenu selectedOption] isEqualToString:@"NUMBERS"]) {
        [self writeMessageAction];
    } else if([[self.currentMenu selectedOption] isEqualToString:@"COMMANDS"]){
        NSString *value = [self.currentMenu currentValue];
        if([value isEqualToString:@"BACK"]){
            [self back];
        } else if ([value isEqualToString:@"DONE"]) {
            [self subjectComplete];
            [self.delegate viewModel:self didSelectCharacter:@""];
        } else if ([value isEqualToString:@"CANCEL EMAIL"]){
            [self.delegate viewModelWillCancelEmail];
        }
    }
}

- (void)writeMessageAction{
    NSString *value = [self.currentMenu currentValue];
    NSString *text = @"";
    if (self.writingSubject) {
        text = self.subject ;
    } else{
        text = self.message;
    }
    if([value isEqualToString:@"SPACE"]){
        text = [text stringByAppendingString:@" "];
    }else if([value isEqualToString:@"BACK"]){
        [self back];
        return;
    }else if ([value isEqualToString:@"DELETE"] && [text length] > 0) {
        text = [text substringToIndex:[text length] - 1];
    }else if ([value isEqualToString:@"CLEAR"]) {
        text = @"";
    }else if (value != nil){
        text = [text stringByAppendingString:value];
    }
    
    if (self.writingSubject) {
        self.subject = text;
    } else{
        self.message = text;
    }
    
    [self.delegate viewModel:self didSelectCharacter:text];
}

- (void)contactsMenuAction{
     NSString *value = [self.currentMenu currentValue];
    if ([[self.currentMenu selectedOption] isEqualToString:@"CONTACTS"]) {
        if ([value isEqualToString:@"REMOVE"]) {
            if ([self.selectedContacts count] > 0) {
                [self.selectedContacts removeLastObject];
                NSString *text = [self.selectedContacts componentsJoinedByString:@", "];
                [self.delegate viewModel:self didSelectCharacter:text];
            }
        } else if([value isEqualToString:@"CLEAR"]){
            [self.selectedContacts removeAllObjects];
            [self.delegate viewModel:self didSelectCharacter:@""];
        }else{
            [self.selectedContacts addObject:value];
            NSString *text = [self.selectedContacts componentsJoinedByString:@", "];
            [self.delegate viewModel:self didSelectCharacter:text];
        }
    } else if([[self.currentMenu selectedOption] isEqualToString:@"SEND"]){
            [self sendEmail];
    } else if([[self.currentMenu selectedOption] isEqualToString:@"CANCEL EMAIL"]){
        [self.delegate viewModelWillCancelEmail];
    }
}

- (BOOL)movementDetectorWillStart{
    return self.ableToDetect;
}
- (cv::Mat)movementDetector:(ETMovementDetector *)detector DidFinishWithMat:(cv::Mat)sourceMat{
    cv::rectangle(sourceMat, [[ETBlinkDetector sharedInstance] areaOK], cv::Scalar(0,255,0,255));
    if ([[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeTwoSources) {
        cv::rectangle(sourceMat, [[ETBlinkDetector sharedInstance] areaCancel], cv::Scalar(0,0,255,255));
    }
    
    return sourceMat;
}

#pragma mark - Email Methods

- (void)prepareEmail{
    [self.currentMenu reset];
    self.subject = @"";
    
    //write email subject
    self.currentMenu = [self.menus objectAtIndex:1];
}

- (void)subjectComplete{
    [self.currentMenu reset];
    
    //write email reciepes
    self.currentMenu = [self.menus objectAtIndex:2];
    [self.delegate viewModel:self didChangeTitle:self.currentMenu.title];
}

- (void)cancelEmail{
    [self resetMenus];
    [self.delegate viewModel:self didSelectCharacter:self.message];
}

- (void)sendEmail{
    ETEmailViewController *mailComposeViewController = [[ETEmailViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setToRecipients:self.selectedContacts];
    [mailComposeViewController setSubject:self.subject];
    [mailComposeViewController setMessageBody:self.message isHTML:NO];
    
    [mailComposeViewController send];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    self.message = self.subject = @"";
    [self.delegate viewModel:self didSelectCharacter:self.message];
    [self resetMenus];
}

- (void)resetMenus{
    NSArray *numbersList = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"DELETE",@"CLEAR",@"BACK", nil];
    NSArray *lettersList = [[NSArray alloc] initWithObjects:@"E",@"T",@"A",@"O",@"I",@"N",@"S",@"R",@"H",@"L",@"D",@"C",@"U",@"M",@"F",@"P",@"G",@"W",@"Y",@"B",@"V",@"K",@"X",@"J",@"Q",@"Z",@"SPACE",@"DELETE",@"CLEAR",@"BACK", nil];
    
    self.menus = [[NSMutableArray alloc] init];
    ETMenuValue *mainMenu = [[ETMenuValue alloc] init];
    mainMenu.title = @"Write a message";
    mainMenu.menuActionSelector = @selector(mainMenuAction);
    [mainMenu.menu setObject:lettersList forKey:@"LETTERS"];
    [mainMenu.menu setObject:numbersList forKey:@"NUMBERS"];
    [mainMenu.menu setObject:[[NSArray alloc] initWithObjects:@"SEND BY EMAIL", @"PAUSE", @"BACK", nil] forKey:@"COMMANDS"];
    
    ETMenuValue *emailSubjectMenu = [[ETMenuValue alloc] init];
    emailSubjectMenu.title = @"Write a subject";
    emailSubjectMenu.menuActionSelector = @selector(emailSubjectMenuAction);
    [emailSubjectMenu.menu setObject:lettersList forKey:@"LETTERS"];
    [emailSubjectMenu.menu setObject:numbersList forKey:@"NUMBERS"];
    [emailSubjectMenu.menu setObject:[[NSArray alloc] initWithObjects:@"DONE",@"CANCEL EMAIL",@"BACK", nil] forKey:@"COMMANDS"];
    [emailSubjectMenu.menu setObject:mainMenu forKey:@"BACK"];
    
    self.selectedContacts = [[NSMutableArray alloc] init];
    [self loadContacts];
    
    ETMenuValue *emailContactsMenu = [[ETMenuValue alloc] init];
    emailContactsMenu.title = @"Chosse the recipies";
    emailContactsMenu.menuActionSelector = @selector(contactsMenuAction);
    [emailContactsMenu.menu setObject:self.contactsList forKey:@"CONTACTS"];
    [emailContactsMenu.menu setObject:@"SEND" forKey:@"SEND"];
    [emailContactsMenu.menu setObject:emailSubjectMenu forKey:@"BACK"];
    [emailContactsMenu.menu setObject:@"CANCEL EMAIL" forKey:@"CANCEL EMAIL"];
    
    
    [self.menus addObject:mainMenu];
    [self.menus addObject:emailSubjectMenu];
    [self.menus addObject:emailContactsMenu];
    
    self.currentMenu = [self.menus objectAtIndex:0];
    [self.delegate viewModel:self didChangeTitle:self.currentMenu.title];
}

- (void)loadContacts{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSMutableArray *nameMapping = [[NSMutableArray alloc] init];
    
	for (int x = 0; x < CFArrayGetCount(allPeople); x++) {
		@try {
			ABRecordRef person = CFArrayGetValueAtIndex(allPeople, x);
            
			// get the email addresses and add to list
			ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
			NSArray *emails = (__bridge id)ABMultiValueCopyArrayOfAllValues(multi);

            [nameMapping addObjectsFromArray:emails];
		} @catch (id e) {
            
		}
	}
    CFRelease(allPeople);
    self.contactsList = nameMapping;
    [self.contactsList addObject:@"REMOVE"];//added option to remove a selected contact
    [self.contactsList addObject:@"CLEAR"];//added option to remove all the selected contacts
}

@end
