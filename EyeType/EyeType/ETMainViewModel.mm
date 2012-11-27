//
//  ETViewModel.mm
//  EyeType
//
//  Created by scvsoft on 10/31/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMainViewModel.h"
#import "ETMenuValue.h"

@interface ETMainViewModel()

@property (nonatomic,strong) NSMutableArray *contactsList;
@property (nonatomic,assign) int currentContactIndex;
@property (strong,nonatomic) NSMutableArray *menus;
@property (strong,nonatomic) ETMenuValue *currentMenu;

- (void)mainMenuAction;
- (void)emailSubjectMenuAction;
- (void)contactsMenuAction;

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
        
        [self resetMenus];
    }
    
    return self;
}

-(void)activateDetection{
    self.ableToDetect = YES;
}

- (NSString *)nextValue{
    [self performSelector:@selector(activateDetection) withObject:nil afterDelay:.3];
    
    NSString *value = [self.currentMenu nextValue];
    return value;
}

- (void)back{
    [self.currentMenu reset];
}

- (bool)isAbleToStart{
    int WOK = [[ETBlinkDetector sharedInstance] areaOK].width;
    int WCA = [[ETBlinkDetector sharedInstance] areaCancel].width;
    bool result = (WOK > 0 &&  WCA > 0 && self.delayTime > 0) || (WOK > 0 && [[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeOneSource );
    return  result;
}

- (void)executeOKAction{
    if(self.ableToDetect){
        self.ableToDetect = NO;
        if(self.currentMenu.returnOptions){
            NSString *option = [self.currentMenu currentValue];
            id value = [self.currentMenu.menu objectForKey:option];
            if ([value isKindOfClass:[ETMenuValue class]]) {
                [self.currentMenu reset];
                self.currentMenu = value;
            } else{
                [self.currentMenu selectCurrentOption];
            }
        }
        else{
            if ([self respondsToSelector:self.currentMenu.menuActionSelector]) {
                [self performSelector:self.currentMenu.menuActionSelector];
            }
        }
        
        [[ETBlinkDetector sharedInstance] resetData];
    }
}

- (void)executeCancelAction{
    if(self.ableToDetect){
        self.ableToDetect = NO;
        [self.currentMenu reset];
        
        [self.delegate viewModelDidDetectCancelAction:self];
    }
}

- (void)mainMenuAction{
    if ([[self.currentMenu selectedOption] isEqualToString:@"LETTERS"] || [[self.currentMenu selectedOption] isEqualToString:@"NUMBERS"]) {
        [self.delegate viewModel:self didSelectCharacter:[self.currentMenu currentValue]];
    } else if([[self.currentMenu selectedOption] isEqualToString:@"COMMANDS"]){
        [self.delegate viewModel:self didSelectCommand:[self.currentMenu currentValue]];
    }
}

- (void)emailSubjectMenuAction{
    if ([[self.currentMenu selectedOption] isEqualToString:@"LETTERS"] || [[self.currentMenu selectedOption] isEqualToString:@"NUMBERS"]) {
        [self.delegate viewModel:self didSelectCharacter:[self.currentMenu currentValue]];
    } else if([[self.currentMenu selectedOption] isEqualToString:@"COMMANDS"]){
        [self.delegate viewModel:self didSelectCommand:[self.currentMenu currentValue]];
    }
}

- (void)contactsMenuAction{
    if ([[self.currentMenu selectedOption] isEqualToString:@"CONTACTS"]) {
        [self.selectedContacts addObject:[self.currentMenu currentValue]];
        [self.delegate viewModel:self didSelectCharacter:[self.currentMenu currentValue]];
    } else if([[self.currentMenu selectedOption] isEqualToString:@"COMMANDS"]){
        [self.delegate viewModel:self didSelectCommand:[self.currentMenu currentValue]];
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

- (void)prepareEmail:(NSString *)Message{
    self.message = Message;
    [self.currentMenu reset];
    
    //write email subject
    self.currentMenu = [self.menus objectAtIndex:1];
}

- (void)subjectComplete:(NSString *)Subject{
    self.subject = Subject;
    [self.currentMenu reset];
    
    //write email reciepes
    self.currentMenu = [self.menus objectAtIndex:2];
    [self.delegate viewModel:self didChangeTitle:self.currentMenu.title];
}

- (void)cancelEmail{
    [self resetMenus];
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
    [self resetMenus];
}

- (void)resetMenus{
    NSArray *numbersList = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0", nil];
    NSArray *lettersList = [[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    
    self.menus = [[NSMutableArray alloc] init];
    ETMenuValue *mainMenu = [[ETMenuValue alloc] init];
    mainMenu.title = @"Write a message";
    mainMenu.menuActionSelector = @selector(mainMenuAction);
    [mainMenu.menu setObject:lettersList forKey:@"LETTERS"];
    [mainMenu.menu setObject:numbersList forKey:@"NUMBERS"];
    [mainMenu.menu setObject:[[NSArray alloc] initWithObjects:@"BACKSPACE",@"SPACE",@"CLEAR",@"SEND BY EMAIL",@"BACK", nil] forKey:@"COMMANDS"];
    
    ETMenuValue *emailSubjectMenu = [[ETMenuValue alloc] init];
    emailSubjectMenu.title = @"Write a subject";
    emailSubjectMenu.menuActionSelector = @selector(emailSubjectMenuAction);
    [emailSubjectMenu.menu setObject:lettersList forKey:@"LETTERS"];
    [emailSubjectMenu.menu setObject:numbersList forKey:@"NUMBERS"];
    [emailSubjectMenu.menu setObject:[[NSArray alloc] initWithObjects:@"BACKSPACE",@"SPACE",@"CLEAR",@"DONE",@"CANCEL EMAIL",@"BACK", nil] forKey:@"COMMANDS"];
    [emailSubjectMenu.menu setObject:mainMenu forKey:@"BACK"];
    
    self.selectedContacts = [[NSMutableArray alloc] init];
    [self loadContacts];
    
    ETMenuValue *emailContactsMenu = [[ETMenuValue alloc] init];
    emailContactsMenu.title = @"Chosse the recipies";
    emailContactsMenu.menuActionSelector = @selector(contactsMenuAction);
    [emailContactsMenu.menu setObject:self.contactsList forKey:@"CONTACTS"];
    [emailContactsMenu.menu setObject:[[NSArray alloc] initWithObjects:@"DELETE LAST CONTACT",@"CLEAR",@"SEND",@"CANCEL EMAIL",@"BACK", nil] forKey:@"COMMANDS"];
    [emailContactsMenu.menu setObject:emailSubjectMenu forKey:@"BACK"];
    
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
}

@end
