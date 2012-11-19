//
//  ETViewModel.mm
//  EyeType
//
//  Created by scvsoft on 10/31/12.
//  Copyright (c) 2012 scvsoft. All rights reserved.
//

#import "ETMainViewModel.h"
#import "ETBlinkDetector.h"

@interface ETMainViewModel(){
    cv::Mat outputMat;
}

@property (nonatomic,strong) NSMutableArray *contactsList;
@property (nonatomic,assign) int currentContactIndex;
@property (strong,nonatomic) NSMutableArray* characterList;
@property (strong,nonatomic) NSMutableArray* numbersList;
@property (strong,nonatomic) NSMutableArray* lettersList;
@property (strong,nonatomic) NSMutableArray* commandsList;
@property (assign,nonatomic) int optionIndex;
@property (assign,nonatomic) int valueIndex;
@property (assign,nonatomic) bool optionSelected;


- (cv::Mat)detectAction:(cv::Mat)sourceMat;

@end

@implementation ETMainViewModel

@synthesize characterList;
@synthesize numbersList;
@synthesize lettersList;
@synthesize commandsList;
@synthesize valueIndex;
@synthesize optionIndex;
@synthesize delegate;
@synthesize delayTime;
@synthesize message;
@synthesize subject;
@synthesize selectingContacts;
@synthesize ableToDetect;

- (id)initWithDelegate:(id<ETMainViewModelDelegate>)Delegate{
    self = [super init];
    if (self) {
        self.delegate = Delegate;
        [self loadDefaultLists];
        self.delayTime = 1.5;
        self.selectedContacts = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)loadDefaultLists{
    self.optionSelected = NO;
    self.ableToDetect = NO;
    self.numbersList = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0", nil];
    self.lettersList = [[NSMutableArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    self.commandsList = [[NSMutableArray alloc] initWithObjects:@"BACKSPACE",@"SPACE",@"CLEAR",@"SEND BY EMAIL", nil];
    self.characterList = [[NSMutableArray alloc] initWithObjects:self.lettersList,self.numbersList,self.commandsList, nil];
    self.optionsList = [[NSMutableArray alloc] initWithObjects:@"Letters",@"Numbers",@"Commands", nil];
    self.valueIndex = NSNotFound;
    self.optionIndex = NSNotFound;
}

- (void)loadEmailContactsLists{
    self.optionSelected = NO;
    self.ableToDetect = NO;
    [self loadContacts];
    self.commandsList = [[NSMutableArray alloc] initWithObjects:@"DELETE LAST CONTACT",@"CLEAR",@"SEND",@"CANCEL EMAIL", nil];
    self.characterList = [[NSMutableArray alloc] initWithObjects:self.contactsList, self.commandsList, nil];
    self.optionsList = [[NSMutableArray alloc] initWithObjects:@"CONTACTS",@"COMMANDS", nil];
    self.valueIndex = NSNotFound;
    self.optionIndex = NSNotFound;
}

- (void)loadEmailTitleLists{
    self.optionSelected = NO;
    self.ableToDetect = NO;
    self.numbersList = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0", nil];
    self.lettersList = [[NSMutableArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    self.commandsList = [[NSMutableArray alloc] initWithObjects:@"BACKSPACE",@"SPACE",@"CLEAR",@"DONE",@"CANCEL EMAIL", nil];
    self.characterList = [[NSMutableArray alloc] initWithObjects:self.lettersList,self.numbersList,self.commandsList, nil];
    self.optionsList = [[NSMutableArray alloc] initWithObjects:@"Letters",@"Numbers",@"Commands", nil];
    self.valueIndex = NSNotFound;
    self.optionIndex = NSNotFound;
}

-(void)activateDetection{
    self.ableToDetect = YES;
}

- (NSString *)nextValue{
    [self performSelector:@selector(activateDetection) withObject:nil afterDelay:.3];
    if (self.optionSelected) {
        NSArray *list = [self.characterList objectAtIndex:optionIndex];
        if (self.valueIndex == NSNotFound || self.valueIndex >= ([list count]-1)) {
            self.valueIndex = 0;
        } else
            self.valueIndex++;
        
        NSString *value = [list objectAtIndex:self.valueIndex];
        
        return value;
    } else{
        if (self.optionIndex == NSNotFound || self.optionIndex >= ([self.optionsList count]-1)) {
            self.optionIndex = 0;
        } else
            self.optionIndex++;
        
        NSString *option = [self.optionsList objectAtIndex:self.optionIndex];
        
        return option;
    }
}

- (bool)isAbleToStart{
    int WOK = [[ETBlinkDetector sharedInstance] areaOK].width;
    int WCA = [[ETBlinkDetector sharedInstance] areaCancel].width;
    bool result = WOK > 0 &&  WCA > 0 && self.delayTime > 0;
    return  result;
}

- (void)executeOKAction{
    if(self.ableToDetect){
        self.ableToDetect = NO;
        if (self.optionSelected) {
            NSArray *list = [self.characterList objectAtIndex:optionIndex];
            NSString *value = [list objectAtIndex:self.valueIndex];
            
            switch (optionIndex) {
                case 0:
                    [self.delegate viewModel:self didSelectCharacter:value];
                    break;
                case 1:
                    if (self.selectingContacts) {
                        [self.delegate viewModel:self didSelectCommand:value];
                    } else{
                        [self.delegate viewModel:self didSelectCharacter:value];
                    }
                    break;
                case 2:
                    [self.delegate viewModel:self didSelectCommand:value];
                    break;
                    
                default:
                    break;
            }
            self.optionSelected = NO;
            self.optionIndex = NSNotFound;
            
        } else{
            NSString *option = [self.optionsList objectAtIndex:self.optionIndex];
            self.optionSelected = YES;
            [self.delegate viewModel:self didSelectOption:option];
            self.valueIndex = NSNotFound;
        }
        
        [[ETBlinkDetector sharedInstance] resetData];
    }
}

- (void)executeCancelAction{
    if(self.ableToDetect){
        self.ableToDetect = NO;
        self.optionSelected = NO;
        [self.delegate viewModelDidDetectCancelAction:self];
        self.valueIndex = NSNotFound;
        self.optionIndex = NSNotFound;
    }
}

- (cv::Mat)detectAction:(cv::Mat)sourceMat {
    if (self.ableToDetect) {
        [super detectAction:sourceMat];
    }
    sourceMat.copyTo(outputMat);
    
    
    cv::rectangle(outputMat, [[ETBlinkDetector sharedInstance] areaOK], cv::Scalar(0,255,0,255));
    cv::rectangle(outputMat, [[ETBlinkDetector sharedInstance] areaCancel], cv::Scalar(0,0,255,255));
    
    cv::Mat roi(outputMat, [[ETBlinkDetector sharedInstance] areaOK]);
    cv::cvtColor([[ETBlinkDetector sharedInstance] matOK], roi, CV_GRAY2BGRA);

    cv::Mat roi2(outputMat, [[ETBlinkDetector sharedInstance] areaCancel]);
    cv::cvtColor([[ETBlinkDetector sharedInstance] matCancel], roi2, CV_GRAY2BGRA);
    
    return outputMat;
}

#pragma mark - Email Methods

- (void)prepareEmail:(NSString *)Message{
    self.message = Message;
    [self loadEmailTitleLists];
}

- (void)subjectComplete:(NSString *)Subject{
    self.subject = Subject;
    self.selectingContacts = YES;
    [self loadEmailContactsLists];
}

- (void)cancelEmail{
    self.selectingContacts = NO;
    [self loadDefaultLists];
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
