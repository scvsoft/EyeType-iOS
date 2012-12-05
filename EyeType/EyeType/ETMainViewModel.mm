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
@property (strong,nonatomic) NSMutableDictionary *menus;
@property (strong,nonatomic) NSMutableArray *menuNavigation;
@property (assign, nonatomic) BOOL writingSubject;
@property (assign, nonatomic) BOOL paused;
@property (assign, nonatomic) NSTimeInterval lastActionTime;

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
@synthesize menuNavigation;
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
        self.lastActionTime = 0;
        
        [self loadMenus];
        
        self.menuNavigation = [NSMutableArray array];
        ETMenuValue *mainMenu = [self.menus objectForKey:@"MAIN"];
        [self.menuNavigation addObject:mainMenu];
        [self.delegate viewModel:self didChangeTitle:mainMenu.title];
    }
    
    return self;
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
        NSString *option = [menu currentValue];
        id value = [menu.menu objectForKey:option];
        if ([value isKindOfClass:[NSString class]] || !menu.returnOptions)
            [self performSelector:menu.menuActionSelector withObject:nil afterDelay:0.];
        else if(option != nil)
            [menu selectCurrentOption];
    } else
        [self actionInPause];
    
    [self.delegate viewModelDidDetectOKAction:self];
    [[ETBlinkDetector sharedInstance] resetData];
}

- (void)actionInPause{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.lastActionTime;
    if (interval < INTERVAL_FOR_PAUSE) {
        self.paused = NO;
        [self.delegate viewModel:self didChangeTitle:[self currentMenu].title];
        [self.delegate viewModelDidLeavePause];
        self.lastActionTime = 0;
    }
    
    self.lastActionTime = now;
}

- (BOOL)movementDetectorWillStart{
    return self.ableToDetect;
}

//This method is fired after proccessed the current frame, in there  you can do changes to the outputFrame
- (cv::Mat)movementDetector:(ETMovementDetector *)detector DidFinishWithMat:(cv::Mat)outputFrame{
    //add a rectagle green for section OK
    cv::rectangle(outputFrame, [[ETBlinkDetector sharedInstance] areaOK], cv::Scalar(0,255,0,255));
    if ([[ETBlinkDetector sharedInstance] inputType] == ETInputModelTypeTwoSources) {
        //add a rectagle red for section Cancel
        cv::rectangle(outputFrame, [[ETBlinkDetector sharedInstance] areaCancel], cv::Scalar(0,0,255,255));
    }
    
    return outputFrame;
}

#pragma mark - Email Methods

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
    NSMutableArray *numbersList = [[NSMutableArray alloc] initWithObjects:@"",@"BACKSPACE",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0", nil];
    NSMutableArray *lettersList = [[NSMutableArray alloc] initWithObjects:@"",@"BACKSPACE",@"E",@"T",@"A",@"O",@"I",@"N",@"S",@"R",@"H",@"L",@"D",@"C",@"U",@"M",@"F",@"P",@"G",@"W",@"Y",@"B",@"V",@"K",@"X",@"J",@"Q",@"Z", nil];
    
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
    [spellMenu.menu setObject:@"BACKSPACE" forKey:@"BACKSPACE"];
    [spellMenu.menu setObject:back forKey:back];
    
    self.selectedContacts = [[NSMutableArray alloc] init];
    [self loadContacts];
    
    ETMenuValue *emailMenu = [[ETMenuValue alloc] init];
    emailMenu.title = @"Write a email";
    emailMenu.menuActionSelector = @selector(emailMenuAction);
    [emailMenu.menu setObject:@"SPELL" forKey:@"SUBJECT"];
    [emailMenu.menu setObject:self.contactsList forKey:@"SELECT ADDRESS"];
    [emailMenu.menu setObject:@"SEND" forKey:@"SEND"];
    [emailMenu.menu setObject:@"CANCEL" forKey:@"CANCEL"];
    [emailMenu.menu setObject:back forKey:back];
    
    ETMenuValue *mainMenu = [[ETMenuValue alloc] init];
    mainMenu.title = @"Main Menu";
    mainMenu.menuActionSelector = @selector(mainMenuAction);
    [mainMenu.menu setObject:@"SPELL" forKey:@"SPELL"];
    [mainMenu.menu setObject:@"CLEAR" forKey:@"CLEAR"];
    [mainMenu.menu setObject:@"EMAIL" forKey:@"SEND EMAIL"];
    [mainMenu.menu setObject:@"PAUSE" forKey:@"PAUSE"];
    
    [self.menus setObject:mainMenu forKey:@"MAIN"];
    [self.menus setObject:spellMenu forKey:@"SPELL"];
    [self.menus setObject:emailMenu forKey:@"EMAIL"];
}

- (void)mainMenuAction{
    ETMenuValue *menu = [self currentMenu];
    if ([[menu selectedOption] isEqualToString:@"SPELL"]) {
        self.writingSubject = NO;
        [self.delegate viewModel:self didChangeTitle:menu.title];
        [self.menuNavigation addObject:[self.menus objectForKey:[menu selectedOption]]];
    } else if ([[menu selectedOption] isEqualToString:@"CLEAR"]) {
        [self writeMessageAction:[menu selectedOption]];
    }else if([[menu selectedOption] isEqualToString:@"BACK"]){
        [self back];
    } else if ([[menu selectedOption] isEqualToString:@"SEND EMAIL"]) {
        self.subject = @"";
        [self.delegate viewModel:self didSelectCharacter:self.subject];
        [self.delegate viewModel:self didChangeTitle:menu.title];
        NSString *value = [menu.menu objectForKey:[menu selectedOption]];
        [self.menuNavigation addObject:[self.menus objectForKey:value]];
    } else if ([[menu selectedOption] isEqualToString:@"PAUSE"]) {
        self.paused = YES;
        [self.delegate viewModel:self didChangeTitle:@"PAUSE"];
        [self.delegate viewModelDidEnterInPause];
    }
}

- (void)emailMenuAction{
    ETMenuValue *menu = [self currentMenu];
    if([[menu selectedOption] isEqualToString:@"BACK"]){
        [self back];
    } else if ([[menu selectedOption] isEqualToString:@"SEND"]) {
        [self sendEmail];
    } else if ([[menu selectedOption] isEqualToString:@"CANCEL"]){
        [self.delegate viewModelWillCancelEmail];
    } else if([[menu selectedOption] isEqualToString:@"SELECT ADDRESS"]){
        NSString *value = [menu currentValue];
        if ([value isEqualToString:@"REMOVE"]) {
            if ([self.selectedContacts count] > 0) {
                [self.selectedContacts removeLastObject];
                NSString *text = [self.selectedContacts componentsJoinedByString:@", "];
                [self.delegate viewModel:self didSelectCharacter:text];
                [[self currentMenu] reStartValues];
            }
        } else if([value isEqualToString:@"BACK"]){
            [self back];
        }else if([value length] > 0){
            [self.selectedContacts addObject:value];
            NSString *text = [self.selectedContacts componentsJoinedByString:@", "];
            [self.delegate viewModel:self didSelectCharacter:text];
            [[self currentMenu] reStartValues];
        }
        
    } else if ([[menu selectedOption] isEqualToString:@"SUBJECT"]){
        self.writingSubject = YES;
        NSString *value = [menu.menu objectForKey:[menu selectedOption]];
        [self.delegate viewModel:self didChangeTitle:menu.title];
        [self.menuNavigation addObject:[self.menus objectForKey:value]];
    }
}

- (void)spellMenuAction{
    ETMenuValue *menu = [self currentMenu];
    NSString *value = [menu currentValue];
    if ([[menu selectedOption] isEqualToString:@"LETTERS"] || [[menu selectedOption] isEqualToString:@"NUMBERS"]) {
        [self writeMessageAction:value];
    } else if([[menu selectedOption] isEqualToString:@"BACK"]){
        [self back];
    } else if ([[menu selectedOption] isEqualToString:@"SPACE"]) {
        [self writeMessageAction:value];
    } else if ([[menu selectedOption] isEqualToString:@"BACKSPACE"]){
        [self writeMessageAction:value];
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
    }else if ([value isEqualToString:@"BACKSPACE"]) {
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
    [[self currentMenu] reStartValues];
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
    [self.contactsList insertObject:@"" atIndex:0];
    [self.contactsList insertObject:@"BACK" atIndex:1];//added option to back previous menu
    [self.contactsList insertObject:@"REMOVE" atIndex:2];//added option to remove the last added contact
}

- (NSString *)nextValue{
    [self performSelector:@selector(activateDetection) withObject:nil afterDelay:.3];
    NSString *value = @"";
    self.currentValues = [NSArray array];
    if (!self.paused) {
        ETMenuValue *menu = [self currentMenu];
        value = [menu nextValue];
        self.currentValues = [menu availableValues];
    } else
        value = @"2 BLINKS IN LESS THAN 1 SECOND TO ACTIVE THE APPLICATION";
    
    return value;
}

//This method go back a level in the menu navigation
- (void)back{
    if([[self currentMenu] returnOptions] && [self.menuNavigation count] > 1){
        [[self currentMenu] reset];
        [self.menuNavigation removeLastObject];
        [self.delegate viewModel:self didChangeTitle:[self currentMenu].title];
    }
    
    [[self currentMenu] reset];
}

- (ETMenuValue *)currentMenu{
    return [self.menuNavigation lastObject];
}

@end
