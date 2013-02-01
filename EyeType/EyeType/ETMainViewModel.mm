//
//  ETViewModel.mm
//  EyeType
//
//  Created by scvsoft on 10/31/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMainViewModel.h"
#import "ETMenuValue.h"
#import "OrderedDictionary.h"
#import "ETEmailSender.h"

#define INTERVAL_FOR_PAUSE 1.5

@interface ETMainViewModel()

@property (strong,nonatomic) NSMutableDictionary *menus;
@property (strong,nonatomic) NSMutableArray *menuNavigation;
@property (assign, nonatomic) BOOL writingSubject;
@property (assign, nonatomic) NSTimeInterval lastActionTime;
@property (strong, nonatomic) NSMutableDictionary *contactsEmailList;
@property (strong, nonatomic) NSString *selectedOption;
@property (copy, nonatomic) NSString *email;

@end

@implementation ETMainViewModel

@synthesize delegate;
@synthesize delayTime;
@synthesize message;
@synthesize subject;
@synthesize ableToDetect;
@synthesize textColor;
@synthesize menus;
@synthesize menuNavigation;
@synthesize paused;
@synthesize lastActionTime;
@synthesize contactsEmailList;
@synthesize selectedOption;

- (id)initWithDelegate:(id<ETMainViewModelDelegate>)Delegate{
    self = [super init];
    if (self) {
        self.delegate = Delegate;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.delayTime = 0;
        if([defaults floatForKey:@"delay"]){
            self.delayTime = [defaults floatForKey:@"delay"];
        }
        
        self.subject = @"";
        if ([defaults objectForKey:@"subject"] > 0) {
            self.subject = [defaults objectForKey:@"subject"];
        }
        
        self.email = @"";
        if ([defaults objectForKey:@"email"] > 0) {
            self.email = [defaults objectForKey:@"email"];
        }
        
        if([defaults objectForKey:@"textColor"]){
            NSData *colorData = [defaults objectForKey:@"textColor"];
            self.textColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        }
        
        self.message = @"";
        self.lastActionTime = 0;
    }
    
    return self;
}

- (void)initializeMenus{
    [self loadMenus];
    
    self.menuNavigation = [NSMutableArray array];
    ETMenuValue *mainMenu = [self.menus objectForKey:@"MAIN"];
    [self.menuNavigation addObject:mainMenu];
}

- (NSArray *)currentValues{
    if ([[self currentMenu] returnOptions]) {
        return [[self currentMenu] availableValues:nil];
    }else{
        return [[self currentMenu] availableValues:self.selectedOption];
    }
}

- (BOOL)isReturningOptions{
    if ([[self.menus objectForKey:@"CONTACTS"] isEqual:[self currentMenu]]) {
        return NO;
    }
    
    return [[self currentMenu] returnOptions];
}

-(void)activateDetection{
    self.ableToDetect = YES;
}

- (float)delayTime{
    float delay = delayTime;
    if ([[self currentMenu] returnOptions]) {
        delay = MAX(delay, 1.);
    }
    
    return delay;
}

- (bool)isAbleToStart{
    int WOK = [[ETBlinkDetector sharedInstance] areaOK].width;
    int WCA = [[ETBlinkDetector sharedInstance] areaCancel].width;
    bool result = ((WOK > 0 &&  WCA > 0) || (WOK > 0 && [[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeOneSource)) && (self.delayTime > 0  && self.delayTime != NSNotFound);
    return  result;
}

- (void)executeCancelAction{
    self.ableToDetect = NO;
    [self back];
    [self.delegate viewModelDidDetectCancelAction:self];
}

- (void)executeOKAction{
    if (!paused) {
        ETMenuValue *menu = [self currentMenu];
        self.ableToDetect = NO;
        NSString *option = [self.delegate viewModelGetCurrentValue];
        if ([self isReturningOptions]) {
            self.selectedOption = option;
        }
        id value = [menu.menu objectForKey:option];
        if ([value isKindOfClass:[NSString class]] || !menu.returnOptions){
            [self performSelector:menu.menuActionSelector withObject:nil afterDelay:0.];
        }
        else if(option != nil){
            self.selectedOption = option;
            [menu selectCurrentOption];
            [self.delegate ViewModelDidLoadNewMenu];
        }
    } else
        [self actionInPause];
    
    [self.delegate viewModelDidDetectOKAction:self];
    [[ETBlinkDetector sharedInstance] resetData];
}

- (void)actionInPause{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.lastActionTime;
    if (interval < INTERVAL_FOR_PAUSE) {
        [self resume];
    }
    
    self.lastActionTime = now;
}

- (BOOL)movementDetectorWillStart{
    return self.ableToDetect;
}

//This method is fired after proccessed the current frame, in there  you can do changes to the outputFrame
- (cv::Mat)movementDetector:(ETMovementDetector *)detector DidFinishWithMat:(cv::Mat)outputFrame{
    //add a rectagle green for section OK
    cv::rectangle(outputFrame, [[ETBlinkDetector sharedInstance] areaOK], [self.textColor scalarFromColor]);
    if ([[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeTwoSources) {
        //add a rectagle red for section Cancel
        cv::rectangle(outputFrame, [[ETBlinkDetector sharedInstance] areaCancel], [[UIColor ETRed] scalarFromColor]);
    }
    
    return outputFrame;
}

#pragma mark - Email Methods

- (void)cancelEmail{
    [self resetMenus];
    [self.delegate viewModel:self didSelectCharacter:self.message];
}

- (NSArray *)getContactsEmail{
    NSMutableArray *selected = [NSMutableArray array];
    for (NSString *name in self.selectedContacts) {
         NSString *firstLetter = [name substringToIndex:1];
         ETMenuValue *contactsMenu = [self.menus objectForKey:@"CONTACTS"];
        int emailIndex = [[contactsMenu.menu objectForKey:firstLetter] indexOfObject:name];
        NSMutableArray *emails = [self.contactsEmailList objectForKey:firstLetter];
        NSString *email = [emails objectAtIndex:emailIndex];
        [selected addObject:email];
    }
    
    return selected;
}

- (void)sendEmail{
    NSArray *recipients = [self getContactsEmail];
    if ([recipients count] <= 0) {
        [self.delegate viewModel:self didFoundError:@"There aren't any recipient selected, please choose at least one"];
    } else if ([subject length] <= 0){
        [self.delegate viewModel:self didFoundError:@"The subject can't be blank"];
    } else{
        [ETEmailSender sendEmailTo:recipients replyTo:self.email subject:self.subject body:self.message];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    self.message = self.subject = @"";
    [self.selectedContacts removeAllObjects];
    [self.delegate viewModel:self didSelectCharacter:self.message];
    [self resetMenus];
}

#pragma mark - Menu methods

//This method reset the menu navigation
- (void)resetMenus{
    //remove all the menus less the first one (Main Menu)
    while ([self.menuNavigation count] > 1) {
        [self back];
    }
}

- (void)loadMenus{
    NSString *back = [[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeOneSource ? @"BACK":nil;
    NSMutableArray *numbersList = [[NSMutableArray alloc] initWithObjects:@"DELETE",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0", nil];
    NSMutableArray *lettersList = [[NSMutableArray alloc] initWithObjects:@"DELETE",@"E",@"T",@"A",@"O",@"I",@"N",@"S",@"R",@"H",@"L",@"D",@"C",@"U",@"M",@"F",@"P",@"G",@"W",@"Y",@"B",@"V",@"K",@"X",@"J",@"Q",@"Z", nil];
    
    if (back != nil) {
        [numbersList insertObject:back atIndex:1];
        [lettersList insertObject:back atIndex:1];
    }
    
    self.menus = [[NSMutableDictionary alloc] init];
    ETMenuValue *spellMenu = [[ETMenuValue alloc] init];
    spellMenu.title = @"Write a message";
    spellMenu.menuActionSelector = @selector(spellMenuAction);
    [spellMenu.menu setObject:lettersList forKey:@"LETTERS"];
    [spellMenu.menu setObject:numbersList forKey:@"NUMBERS"];
    [spellMenu.menu setObject:@"SPACE" forKey:@"SPACE"];
    [spellMenu.menu setObject:@"DELETE" forKey:@"DELETE"];
    [spellMenu.menu setObject:back forKey:back];
    
    self.selectedContacts = [[NSMutableArray alloc] init];
    [self loadContacts];
    
    ETMenuValue *emailMenu = [[ETMenuValue alloc] init];
    emailMenu.title = @"Write a email";
    emailMenu.menuActionSelector = @selector(emailMenuAction);
    [emailMenu.menu setObject:@"SPELL" forKey:@"SUBJECT"];
    [emailMenu.menu setObject:@"CONTACTS" forKey:@"SELECT ADDRESS"];
    [emailMenu.menu setObject:@"SEND" forKey:@"SEND"];
    [emailMenu.menu setObject:@"CANCEL" forKey:@"CANCEL"];
    [emailMenu.menu setObject:back forKey:back];
    
    ETMenuValue *mainMenu = [[ETMenuValue alloc] init];
    mainMenu.title = @"Main Menu";
    mainMenu.menuActionSelector = @selector(mainMenuAction);
    [mainMenu.menu setObject:@"SPELL" forKey:@"SPELL"];
    [mainMenu.menu setObject:@"EMAIL" forKey:@"SEND EMAIL"];
    [mainMenu.menu setObject:@"CLEAR" forKey:@"CLEAR"];
    [mainMenu.menu setObject:@"PAUSE" forKey:@"PAUSE"];
    
    [self.menus setObject:mainMenu forKey:@"MAIN"];
    [self.menus setObject:spellMenu forKey:@"SPELL"];
    [self.menus setObject:emailMenu forKey:@"EMAIL"];
}

- (void)setWritingSubject:(BOOL)writingSubject{
    _writingSubject = writingSubject;
    if (self.writingSubject) {
        if ([self.subject length] == 0) {
            self.subject = @"";
        }
        
        [self.delegate viewModel:self didSelectCharacter:self.subject];
    } else{
        [self.delegate viewModel:self didSelectCharacter:self.message];
    }
}

- (void)mainMenuAction{
    ETMenuValue *menu = [self currentMenu];
    [self setWritingSubject:NO];
    
    if ([[self selectedOption] isEqualToString:@"SPELL"]) {
        [self.menuNavigation addObject:[self.menus objectForKey:[self selectedOption]]];
        [self.delegate ViewModelDidLoadNewMenu];
    } else if ([[self selectedOption] isEqualToString:@"CLEAR"]) {
        [self writeMessageAction:[self selectedOption]];
    }else if([[self selectedOption] isEqualToString:@"BACK"]){
        [self back];
    } else if ([[self selectedOption] isEqualToString:@"SEND EMAIL"]) {
        NSString *value = [menu.menu objectForKey:[self selectedOption]];
        [self.menuNavigation addObject:[self.menus objectForKey:value]];
        [self.delegate ViewModelDidLoadNewMenu];
    } else if ([[self selectedOption] isEqualToString:@"PAUSE"]) {
        self.paused = YES;
        [self.delegate viewModelDidEnterInPause];
    }
}

- (void)emailMenuAction{
    ETMenuValue *menu = [self currentMenu];
    if([[self selectedOption] isEqualToString:@"BACK"]){
        [self back];
    } else if ([[self selectedOption] isEqualToString:@"SEND"]) {
        [self sendEmail];
    } else if ([[self selectedOption] isEqualToString:@"CANCEL"]){
        [self.delegate viewModelWillCancelEmail];
    } else if([[self selectedOption] isEqualToString:@"SELECT ADDRESS"]){
        NSString *value = [menu.menu objectForKey:[self selectedOption]];
        [self.menuNavigation addObject:[self.menus objectForKey:value]];
        [self.delegate ViewModelDidLoadNewMenu];
        NSString *text = [self.selectedContacts componentsJoinedByString:@", "];
        [self.delegate viewModel:self didSelectCharacter:text];
        
    } else if ([[self selectedOption] isEqualToString:@"SUBJECT"]){
        [self setWritingSubject:YES];
        NSString *value = [menu.menu objectForKey:[self selectedOption]];
        [self.menuNavigation addObject:[self.menus objectForKey:value]];
        [self.delegate ViewModelDidLoadNewMenu];
    }
}

- (void)spellMenuAction{
    NSString *value = [self.delegate viewModelGetCurrentValue];
    if ([[self selectedOption] isEqualToString:@"LETTERS"] || [[self selectedOption] isEqualToString:@"NUMBERS"]) {
        [self writeMessageAction:value];
    } else if([[self selectedOption] isEqualToString:@"BACK"]){
        if (self.writingSubject) {
            [self setWritingSubject:NO];
        }
        [self back];
    } else if ([[self selectedOption] isEqualToString:@"SPACE"]) {
        [self writeMessageAction:value];
    } else if ([[self selectedOption] isEqualToString:@"DELETE"]){
        [self writeMessageAction:value];
    }
}

- (void)contactsMenuAction{
    NSString *value = [self.delegate viewModelGetCurrentValue];
    if([[self selectedOption] isEqualToString:@"BACK"]){
        [self.delegate viewModel:self didSelectCharacter:@""];
        [self back];
    } else  if([value length] > 0){
        if ([value isEqualToString:@"REMOVE"]) {
            [self.selectedContacts removeLastObject];
            NSString *text = [self.selectedContacts componentsJoinedByString:@", "];
            [self.delegate viewModel:self didSelectCharacter:text];
        } else if([value isEqualToString:@"BACK"]){
            [self back];
        } else if (![self.selectedContacts containsObject:value]) {
            [self.selectedContacts addObject:value];
            NSString *text = [self.selectedContacts componentsJoinedByString:@", "];
            [self.delegate viewModel:self didSelectCharacter:text];
            [self back];
        }
        
        self.selectedOption = @"CONTACTS";
    }
}

- (void)writeMessageAction:(NSString*)value{
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
    }else if ([value isEqualToString:@"DELETE"]) {
        if ([text length] > 0) {
            text = [text substringToIndex:[text length] - 1];
        }
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

- (void)loadContacts{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            [self loadContacts];
        });
        return;
    }

    ETMenuValue *contactsMenu = [[ETMenuValue alloc] init];
    contactsMenu.title = @"Choose contacts";
    contactsMenu.menuActionSelector = @selector(contactsMenuAction);
    [contactsMenu.menu setValue:@"BACK" forKey:@"BACK"];
    
    self.contactsEmailList = [[NSMutableDictionary alloc] init];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    if (allPeople) {
        CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(allPeople), allPeople);
        CFRelease(allPeople);
        CFArraySortValues(peopleMutable,
                          CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                          (CFComparatorFunction) ABPersonComparePeopleByName,
                          (void *)kABPersonSortByFirstName);
        
        [contactsMenu.menu setValue:@"REMOVE" forKey:@"REMOVE"];
        
        for (int x = 0; x < CFArrayGetCount(peopleMutable); x++) {
            @try {
                ABRecordRef person = CFArrayGetValueAtIndex(peopleMutable, x);
                
                // person's name
                CFStringRef cfName = ABRecordCopyCompositeName(person);
                
                // get the email addresses and add to list
                ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
                NSArray *emails = (__bridge id)ABMultiValueCopyArrayOfAllValues(multi);
                
                NSString *personName = nil;
                if (cfName==NULL || CFStringGetLength(cfName)==0) {
                    if ([emails count] > 0) {
                        personName = [emails objectAtIndex:0];
                    }
                } else{
                    personName = [NSString stringWithString:(__bridge NSString *) cfName];
                }

                NSString *firstLetter = [[personName substringToIndex:1] uppercaseString];
                NSMutableArray *names = [contactsMenu.menu objectForKey:firstLetter];
                NSMutableArray *emailsList = [self.contactsEmailList objectForKey:firstLetter];
                
                if ([emails count] > 0) {
                    NSString *email = [emails objectAtIndex:0];
                    if (names == nil) {
                        names = [NSMutableArray arrayWithObjects:@"BACK",personName,nil];
                        emailsList = [NSMutableArray arrayWithObjects:@"BACK",email,nil];
                    } else{
                        [names addObject:personName];
                        [emailsList addObject:email];
                    }
                    
                    [contactsMenu.menu setValue:names forKey:firstLetter];
                    [self.contactsEmailList setValue:emailsList forKey:firstLetter];
                }
            } @catch (id e) {
                
            }
        }
        
        CFRelease(peopleMutable);
        CFRelease(addressBook);
    }
    
    [self.menus setValue:contactsMenu forKey:@"CONTACTS"];
}

//This method go back a level in the menu navigation
- (void)back{
    if([[self currentMenu] returnOptions] && [self.menuNavigation count] > 1){
        [[self currentMenu] reset];
        [self.menuNavigation removeLastObject];
    }
    
    [[self currentMenu] reset];
    [self.delegate ViewModelDidCloseMenu];
}

- (ETMenuValue *)currentMenu{
    return [self.menuNavigation lastObject];
}

- (void) resume {
    self.paused = NO;
    [self.delegate viewModelDidLeavePause];
    self.lastActionTime = 0;
}

@end
