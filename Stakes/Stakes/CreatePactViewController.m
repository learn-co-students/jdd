//
//  CreatePactViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "CreatePactViewController.h"
#import "JDDDataSource.h"
#import "JDDPact.h"
#import "Constants.h"
#import "UserDescriptionView.h"

@import Contacts;
@import ContactsUI;
@import MessageUI;

@interface CreatePactViewController () <CNContactPickerDelegate, MFMessageComposeViewControllerDelegate,UITextFieldDelegate, UITextViewDelegate> ;

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *HowOften;
@property (weak, nonatomic) IBOutlet UITextField *pactDescription;
@property (weak, nonatomic) IBOutlet UILabel *twitterShameLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *frequencyPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *timeIntervalPicker;
@property (weak, nonatomic) IBOutlet UITextView *twitterShamePost;
@property (weak, nonatomic) IBOutlet UITextField *pactTitle;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twitterOnboardingLabel;
@property (weak, nonatomic) IBOutlet UITextField *stakesTextView;
@property (nonatomic, assign) NSString * pactID;
@property (nonatomic,strong) NSMutableArray* FrequencyPickerDataSourceArray;
@property (nonatomic,strong) NSMutableArray* timeInterval;
@property (nonatomic,strong) NSString* timeIntervalString;
@property (nonatomic,strong) NSString* frequencyString;
@property (nonatomic, strong) NSMutableArray* contacts;
@property (nonatomic, strong) Firebase *pactReference;
@property (nonatomic, strong) JDDPact *createdPact;
@property (nonatomic, strong) NSMutableArray *contactsToShow;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIButton *RemoveInvitesButton;
@property (weak, nonatomic) IBOutlet UILabel *inviteFriendsLabel;
@property (weak, nonatomic) IBOutlet UIView *addFriendsView;
@property (weak, nonatomic) IBOutlet UIView *contactButtonView;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addFriendsConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsTopConstraint;

@end

@implementation CreatePactViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.dataSource = [JDDDataSource sharedDataSource];
    [self.RemoveInvitesButton setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    [self initializePickers];
    [self cleanScreenFromLabels];
    [self stylePactDescriptionView];
    [self styleTwitterPost];
    [self styleStakesView];
    self.twitterShamePost.delegate = self;
    [self.pactTitle becomeFirstResponder];
    self.stakesTextView.delegate = self;
    self.doneButton.layer.cornerRadius = 15;
    self.cancelButton.layer.cornerRadius = 15;
    self.pactTitle.delegate = self;
    self.contactsToShow = [[NSMutableArray alloc]init];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    CGFloat iphoneSize = [[UIScreen mainScreen] bounds].size.height;
    if (iphoneSize == 568) {
        self.buttonsTopConstraint.constant = 50;
        
    } else if (iphoneSize == 736) {
        
        self.buttonsTopConstraint.constant = 60;
    } else {
        self.buttonsTopConstraint.constant = 30;
    }
    
}

-(void)viewDidLayoutSubviews {
    [self styleTitleTextView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(nonnull NSString *)text {
    // Prevent crashing undo bug – see note below.
    
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return newLength <= 139;
    
}


-(void)cleanScreenFromLabels
{
    self.HowOften.alpha =0;
    self.twitterOnboardingLabel.alpha = 0;
    self.welcomeLabel.hidden = YES;
    self.topConstraint.constant = ([[UIScreen mainScreen] bounds].size.height/2)-40;
    if (self.dataSource.currentUser.pacts.count==0 || [self.dataSource.currentUser.pacts isEqual:nil] ) {
        self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@",self.dataSource.currentUser.displayName];
        self.welcomeLabel.hidden = NO;
    } else {
        self.welcomeLabel.text = [NSString stringWithFormat:@"Hi, %@",self.dataSource.currentUser.displayName];
        self.welcomeLabel.hidden = NO;
        
    }
    
    self.RemoveInvitesButton.hidden = YES;
    self.pactDescription.alpha = 0;
    self.stakesTextView.alpha = 0;
    self.twitterShamePost.alpha = 0;
    self.repeatSwitch.alpha = 0;
    self.shameSwitch.alpha = 0;
    self.addFriendsView.hidden = YES;
    self.contactButtonView.hidden = YES;
    self.pickerView.alpha = 0;
    self.twitterShameLabel.alpha = 0;
    self.repeatLabel.alpha = 0;
    self.repeatSwitch.on = NO;
    self.shameSwitch.on = NO;
    self.twitterShamePost.alpha = 0;
    
    self.descriptionLabel.alpha = 0;
    
}




-(void)dismissKeyboard   //dismiss Keyboard for tap gesture
{
    [self.stakesTextView resignFirstResponder];
    [self.twitterShamePost resignFirstResponder];
    [self.pactDescription resignFirstResponder];
    [self.pactTitle resignFirstResponder];
    if (self.stakesTextView.text.length >0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            CGFloat iphoneSize = [[UIScreen mainScreen] bounds].size.height;
            if (iphoneSize == 568) {
                if (self.topConstraint.constant == 0) {
                    self.topConstraint.constant = -50;
                } else {
                    self.topConstraint.constant = 0;
                }
                
            } else if (iphoneSize == 736) {
                
                self.buttonsTopConstraint.constant = 110;
            } else {
                
                self.buttonsTopConstraint.constant = 80;
            }
            
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
        }];
        
        if (self.shameSwitch.on) {
            CGFloat iphoneSize = [[UIScreen mainScreen] bounds].size.height;
            if (iphoneSize == 568) {
                self.buttonsTopConstraint.constant = 40;
            } else if (iphoneSize == 736) {
                
                self.buttonsTopConstraint.constant = 100;
                
            } else {
                
                self.buttonsTopConstraint.constant = 80;
            }
            
        }
        
    }
}




- (void)keyBoardWillShowForStakes:(NSNotification *)notification
{
    if (self.stakesTextView.isFirstResponder) {
        // grab some values from the notification
        NSTimeInterval keyboardAnimationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        NSInteger keyboardAnimationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [UIView animateKeyframesWithDuration:keyboardAnimationDuration delay:0.2 options:keyboardAnimationCurve animations:^{
            
            // Here is where you change something to make it animate!
            self.topConstraint.constant = -80;
        } completion:nil];
    }
}






- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.twitterShamePost = textView;
    self.twitterShamePost.text = @"";
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat iphoneSize = [[UIScreen mainScreen] bounds].size.height;
        if (iphoneSize == 568) {
            self.topConstraint.constant = -220;
            self.buttonsTopConstraint.constant = 70;
        } else {
            self.topConstraint.constant = -160;
        }
    }];
    
    
    
}



- (IBAction)stakeDetailTapped:(id)sender {//editing began
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillShowForStakes:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
}

- (IBAction)createPactTapped:(id)sender {
    
    if ([self isPactReady]) {
        
        NSDate *currentDate = [NSDate date];
        
        self.createdPact = [[JDDPact alloc]init];
        self.createdPact.title = self.pactTitle.text;
        self.createdPact.pactDescription = self.pactDescription.text;
        self.createdPact.stakes = self.stakesTextView.text;
        self.createdPact.twitterPost = self.twitterShamePost.text;
        self.createdPact.allowsShaming = self.shameSwitch.on;
        self.createdPact.repeating = self.repeatSwitch.on;
        self.createdPact.timeInterval = self.timeIntervalString;
        self.createdPact.checkInsPerTimeInterval = [self.frequencyString integerValue];
        if (!self.createdPact.timeInterval) {
            self.createdPact.timeInterval = @"day";
        }
        if (!self.createdPact.checkInsPerTimeInterval) {
            self.createdPact.checkInsPerTimeInterval = 1;
        }
        self.createdPact.dateOfCreation = currentDate;
        self.createdPact.isActive = NO;
        
        self.createdPact.usersToShowInApp = self.contactsToShow;
        
        
        [self sendPactToFirebase];
        
        [self establishCurrentUserWithBlock:^(BOOL completionBlock) {
            
            if (completionBlock) {
                
                [self methodToPullDownPactsFromFirebaseWithCompletionBlock:^(BOOL completionBlock) {
                    
                    if (completionBlock) {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            [self observeEventForUsersFromFirebaseWithCompletionBlock:^(BOOL block) {
                                
                                if (block) {
                                    
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        
                                        
                                        //[self dismissViewControllerAnimated:YES completion:nil];// We dont need this here
                                        
                                    }];
                                }
                            }];
                            
                        }];
                    }
                }];
                
                
            }
        }];
        
        
        
        [self sendMessageToInvites];
        
        
    } else {
        
        [self alertPactNotReady];
        
    }
    
}



-(BOOL)prefersStatusBarHidden
{
    return YES;
}




-(void)sendPactToFirebase{
    
    self.pactReference = [self.dataSource.firebaseRef childByAppendingPath:@"pacts"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'-'HH:mm'"];
    
    // this dictionary is creating with the users that will be added into the pact when it is created in firebase
    // this data is structured as such @{userID : NSNumber as BOOL whether they have accepted the pact or not}
    
    NSMutableDictionary * usersInPact = [[NSMutableDictionary alloc]initWithDictionary:@{}];
    
    NSLog(@"contacts to show are %@",self.contactsToShow);
    
    for (JDDUser *user in self.contactsToShow) {
        
        NSLog(@"contacts to show are %@",user.userID);
        
        if ([user.userID isEqualToString:self.dataSource.currentUser.userID]) {
            
            NSLog(@"%@ should be equal to %@",self.dataSource.currentUser.userID,user.userID);
            
            [usersInPact setValue:[NSNumber numberWithBool:YES] forKey:user.userID];
            
        } else {
            
            [usersInPact setValue:[NSNumber numberWithBool:NO] forKey:user.userID];
            
        }
    }
    
    NSLog(@"%@",usersInPact);
    
    // creation of the pactID
    Firebase *newPact = [self.pactReference childByAutoId];
    
    // parsing pact url to get pactID
    self.createdPact.pactID = [newPact.description stringByReplacingOccurrencesOfString:@"https://jddstakes.firebaseio.com/pacts/" withString:@""];
    
    NSLog(@"%@", self.createdPact.pactID);
    
    // adding chatroom for pact to JDDStakes
    [[self.dataSource.firebaseRef childByAppendingPath:@"chatrooms"]updateChildValues:@{
                                                                                        [NSString stringWithFormat:@"%@",self.createdPact.pactID]:[NSNumber numberWithBool:YES]
                                                                                        }];
    
    // creating the pact to be sent to Firebase using createDict method
    NSDictionary *finalPactDictionary = [self.dataSource createDictionaryToSendToFirebaseWithJDDPact:self.createdPact];
    
    // adding users
    [finalPactDictionary setValue:usersInPact forKey:@"users"];
    
    [newPact setValue:finalPactDictionary];
    
    [self sendPacttoUsers];
    
}

-(void)sendPacttoUsers{
    
    for (JDDUser *user in self.contactsToShow) {
        
        if ([user.userID isEqualToString:self.dataSource.currentUser.userID]) {
            
            Firebase *firebase = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@/pacts",user.userID]];
            
            [firebase updateChildValues:@{self.createdPact.pactID:[NSNumber numberWithBool:YES]}];
            
        } else {
            
            Firebase *firebase = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@/pacts",user.userID]];
            
            [firebase updateChildValues:@{self.createdPact.pactID:[NSNumber numberWithBool:NO]}];
            
        }
    }
    
}




//========================================================================================================================================
// Styling of the pact form
//========================================================================================================================================

-(void)styleTitleTextView
{
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 2;
    border.borderColor = [UIColor darkGrayColor].CGColor;
    border.frame = CGRectMake(0, self.pactTitle.frame.size.height - borderWidth, self.pactTitle.frame.size.width, self.pactTitle.frame.size.height);
    border.borderWidth = borderWidth;
    [self.pactTitle.layer addSublayer:border];
    self.pactTitle.layer.masksToBounds = YES;
    
    //    self.pactTitle.layer.borderWidth = 2;
    //    self.pactTitle.layer.borderColor = [UIColor blueColor].CGColor;
    
}

-(void)styleStakesView
{
    self.stakesTextView.layer.cornerRadius = 5;
    self.stakesTextView.layer.borderWidth = 1.0f;
    self.stakesTextView.layer.borderColor = [UIColor blackColor].CGColor;
}

-(void)styleTwitterPost
{
    self.twitterShamePost.layer.cornerRadius = 5;
    self.twitterShamePost.layer.borderWidth = 1.0f;
    self.twitterShamePost.layer.borderColor = [UIColor blackColor].CGColor;
}

-(void)stylePactDescriptionView
{
    self.pactDescription.layer.cornerRadius = 5;
    self.pactDescription.layer.borderWidth = 1.0f;
    self.pactDescription.layer.borderColor = [UIColor blackColor].CGColor;
}


//-(void)imageStyle
//{
//    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
//    self.profileImage.layer.borderWidth = 1.0f;
//    self.profileImage.layer.borderColor = [UIColor blackColor].CGColor;
//
//}


-(void)initializePickers {
    self.timeInterval = [NSMutableArray new];
    self.FrequencyPickerDataSourceArray = [NSMutableArray new];
    for (NSUInteger i = 1; i<51; i++) {
        NSString *number = [NSString stringWithFormat:@"%li",i];
        [self.FrequencyPickerDataSourceArray addObject:number];
    }
    
    self.timeInterval = [@[@"day",@"week",@"month",@"year"] mutableCopy];
    self.timeIntervalPicker.delegate =self;
    self.timeIntervalPicker.dataSource = self;
    self.frequencyPicker.delegate = self;
    self.frequencyPicker.dataSource =self;
    
}

//========================================================================================================================================
//buttons, contacts, and alerts
//========================================================================================================================================

-(void)alertPactNotReady
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Please finish filling your pact" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction: ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertMessagingNotAvailable
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Messaging is not available on this device" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:NO completion:nil];
                             [self dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction: ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.frequencyPicker) {
        return self.FrequencyPickerDataSourceArray.count;
    } else {
        return self.timeInterval.count;
    }
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.frequencyPicker) {
        //        self.frequencyString = self.FrequencyPickerDataSourceArray[row];
        return self.FrequencyPickerDataSourceArray[row];
    } else {
        //        self.timeIntervalString = self.timeInterval[row];
        return self.timeInterval[row];
    }
    
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.frequencyPicker) {
        self.frequencyString = self.FrequencyPickerDataSourceArray[row];
    } else if (pickerView == self.timeIntervalPicker) {
        self.timeIntervalString = self.timeInterval[row];
    }
}




- (IBAction)addFriendsButton:(id)sender {
    
    CNContactPickerViewController *contacts = [CNContactPickerViewController new];
    contacts.delegate = self;
    [self presentViewController:contacts animated:YES completion:nil];
    
    
}


- (IBAction)repeateToggleTapped:(id)sender {
    
}

- (IBAction)shameToggleTapped:(id)sender {
    
    if (self.shameSwitch.on) {
        self.twitterShamePost.text = @"I am a terrible friend and I disaapointed all my pact members";
        self.twitterShamePost.hidden = NO;
        self.twitterOnboardingLabel.alpha = 0;
        [UIView animateWithDuration:1 animations:^{
            self.twitterShamePost.alpha =1;
            
        } completion:nil];
        
    } else {
        self.twitterShamePost.hidden = YES;
        
    }
}



// this is the method that gets fired when user hits done in contact picker.
-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    
    if (![self.contactsToShow containsObject:self.dataSource.currentUser]) {
        
        [self.contactsToShow addObject:self.dataSource.currentUser];
        
    }
    
    // OBJECTIVE : for contacts in the CNContact array I want to check firebase to see if they exist. If YES, pull down info & create JDDUser. If no create JDDUser
    
    //may need an if statement to make sure this doesn't fire if contacts.count == 0
    self.contacts = [[NSMutableArray alloc]init];
    NSString *PhoneNumber = [[NSString alloc]init];
    
    for(CNContact *contact in contacts){
        
        if (contact.phoneNumbers.count >0)
        {
            
            
            for (NSInteger i = 0; i<contact.phoneNumbers.count; i++) {
                
                NSLog(@"label is %@",contact.phoneNumbers[i].label);
                
                
                if ([contact.phoneNumbers[i].label isEqual:@"_$!<Mobile>!$_"] || [contact.phoneNumbers[i].label isEqual:@"iPhone"] || !contact.phoneNumbers[i].label){
                    
                    
                    PhoneNumber = [self updateUIandFireBasewith:contact atIndex:i];
                    
                    
                } else if (contact.phoneNumbers.count ==1){
                    
                    PhoneNumber = [self updateUIandFireBasewith:contact atIndex:i];
                    
                }
            }
            
            
            
        } else {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self alertFinishFiling:@"This contact has no number registered"];
            }];
            
        }
    }
    
    if (self.contacts.count < contacts.count) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self alertFinishFiling:@"One of the members has no mobile number"];
            
            
        }];
        
    }
    if (self.contacts.count >0) {
        self.descriptionLabel.alpha = 0;
    }
    
}

-(NSString *)updateUIandFireBasewith:(CNContact *)contact atIndex:(NSInteger)i
{
    NSString *contactPhone = [[NSString alloc]init];
    
    CNLabeledValue<CNPhoneNumber*>* oneWeWant =contact.phoneNumbers[i];
    contactPhone = oneWeWant.value.stringValue;
    NSLog(@"The oneWeWant %@",contactPhone);
    
    contactPhone = [[contactPhone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                    componentsJoinedByString:@""]; // clean iPhone number
    [self.contacts addObject:contactPhone];
    //    }
    // query Firebase to see if the contactIphone exists
    Firebase *usersRef = [self.dataSource.firebaseRef childByAppendingPath:@"users"];
    
    [usersRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        if ([snapshot hasChild:contactPhone]) { // number exists in Firebase
            
            [[usersRef childByAppendingPath:[NSString stringWithFormat:@"%@",contactPhone]] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                
                JDDUser *contactToAdd =[self.dataSource useSnapShotAndCreateUser:snapshot];
                
                NSLog(@"user is: %@",contactToAdd.userID);
                
                [self.contactsToShow addObject:contactToAdd];
                
                NSLog(@"contactToShow: %@",self.contactsToShow);
                
                [self addUserToInviteScrollView:contactToAdd];
                
                
            }];
            
        } else {
            
            // need to create JDDUser
            
            JDDUser *newUser = [[JDDUser alloc]init];
            newUser.userID = contactPhone;
            newUser.displayName = contact.givenName;
            newUser.phoneNumber = contactPhone;
            
            NSMutableDictionary * dictionary = [self.dataSource createDictionaryToSendToFirebaseWithJDDUser:newUser];
            
            [[usersRef childByAppendingPath:contactPhone]setValue:dictionary]; //create user in Firebase
            
            [self.contactsToShow addObject: newUser]; // add user to contacts to show
            
            [self addUserToInviteScrollView:newUser];
            
            
        }
        
        
        [NSNotification notificationWithName:@"contactsReadyForCreatePactView" object:nil];
        [self didSelectedContactToInvite];
        
        
    }];
    
    return contactPhone;
}


- (IBAction)removeContactButton:(id)sender {
    UserDescriptionView *user4 = [[UserDescriptionView alloc]init];
    user4 = self.stackView.arrangedSubviews.lastObject; //assign the last object in the stackView
    [user4 removeFromSuperview]; // Find that object in the stackView and Remove it
    [self.contactsToShow removeLastObject]; // Remove the last object from the array
    if (self.contactsToShow.count ==1) {
        self.inviteFriendsLabel.hidden = NO;
        self.addFriendsConstraint.constant = 0;
        self.RemoveInvitesButton.hidden = YES;
        self.descriptionLabel.alpha = 1;
        self.pactDescription.alpha = 0;
        self.pickerView.alpha = 0;
        self.repeatLabel.alpha = 0;
        self.repeatSwitch.alpha = 0;
        self.stakesTextView.alpha = 0;
        self.twitterShamePost.alpha = 0;
        self.shameSwitch.alpha = 0;
        self.twitterShameLabel.alpha =0;
        self.HowOften.alpha = 0;
        self.twitterOnboardingLabel.alpha = 0;
    }
    
    
}

-(void)addUserToInviteScrollView: (JDDUser*)user {
    UserDescriptionView *view3 = [[UserDescriptionView alloc]init];
    view3.indicatorLabel.hidden = YES;
    view3.countOfCheckInsLabel.hidden = YES;
    view3.borderView.layer.borderWidth = 0.8;
    view3.user = user;
    
    if (self.stackView.arrangedSubviews.count == 0) {
        [self.stackView addArrangedSubview:view3];
        self.RemoveInvitesButton.hidden = NO;
        self.inviteFriendsLabel.hidden = YES;
        self.addFriendsConstraint.constant = 30;
        [view3.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor multiplier:0.25].active = YES;
        
        
    } else  {
        NSMutableArray *userIDsInStackView = [[NSMutableArray alloc]init];
        for (UserDescriptionView *viewToCompare in self.stackView.arrangedSubviews) {
            [userIDsInStackView addObject:viewToCompare.user.userID];
        }
        
        
        if ([userIDsInStackView containsObject:view3.user.userID]) {
            NSLog(@"Already have this user in the scrollView");
            [self alertUserAlreadyAdded:view3.user.displayName];
            
        } else {
            [self.stackView addArrangedSubview:view3];
            
        }
        
    }
    
    
}





-(void)alertUserAlreadyAdded:(NSString *)name
{
    NSString *message = [NSString stringWithFormat:@"You already added %@", name];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction: ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}







- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}





//========================================================================================================================================
// methods to check if all text fields are ready in the pact creation
//========================================================================================================================================

-(BOOL)isPactReady
{
    if ([self isGroupTitleSet] && [self didInviteFriends] && [self isPactDecribed] && [self isStakeDecided]) {
        
        NSLog(@"Pact is ready to go!!!");
        return YES;
    }
    
    return NO;
    
}




-(BOOL)isGroupTitleSet
{
    if (![self.pactTitle.text isEqualToString:@""] && self.pactTitle.text.length > 0 && self.pactTitle.text != nil) {
        NSLog(@"Group name title is set");
        return YES;
    }
    
    return NO;
}




-(BOOL)didInviteFriends
{
    if (self.contactsToShow.count > 1){
        NSLog(@"friends are invited");
        
        return YES;
    }
    
    return  NO;
}




-(BOOL)isPactDecribed
{
    if (self.pactDescription.text.length > 0 && self.pactDescription.text != nil && ![self.pactDescription.text isEqual:@""]) {
        NSLog(@"pact is described");
        return YES;
        
    }
    
    return NO;
}





-(BOOL)isStakeDecided
{
    if (self.stakesTextView.text.length > 0 && self.stakesTextView.text != nil && ![self.stakesTextView.text isEqual:@""]) {
        NSLog(@"Stakes are decided");
        return YES;
    }
    
    
    return  NO;
}







//========================================================================================================================================
// Dismiss keboards
//========================================================================================================================================



- (IBAction)dismissStakeKeyboard:(id)sender {
    self.topConstraint.constant = 0;
    self.stakesTextView = (UITextField*) sender;
    [self.stakesTextView resignFirstResponder];
    
    if (self.stakesTextView.text.length > 0) {
        self.twitterShameLabel.hidden = NO;
        self.shameSwitch.hidden = NO;
    }
}





- (IBAction)dismissDiscriptionKeyboard:(id)sender {
    self.pactDescription = (UITextField*) sender;
    [self.pactDescription resignFirstResponder];
}





- (IBAction)dismissTitleKeyboard:(id)sender {
    self.pactTitle = (UITextField*) sender;
    [self.pactTitle resignFirstResponder];
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    self.twitterShamePost = textView;
    self.topConstraint.constant = 0;
  
    CGFloat iphoneSize = [[UIScreen mainScreen] bounds].size.height;
    if (iphoneSize == 568) {
        self.buttonsTopConstraint.constant = 5;
    } else if (iphoneSize == 736) {
        
        self.buttonsTopConstraint.constant = 110;
        
    } else {
        
        self.buttonsTopConstraint.constant = 80;
    }
    
}







//========================================================================================================================================
//Messaging stuff
//========================================================================================================================================




-(void)sendMessageToInvites
{
    if (![MFMessageComposeViewController canSendText]) {
        [self alertMessagingNotAvailable];
    } else {
        
        MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
        composeVC.messageComposeDelegate = self;
        
        // Configure the fields of the interface.
        composeVC.recipients = self.contacts;
        composeVC.body = @"Hey - I just created a pact! Download pacts and let's track our progress: http://apple.co/1WlZ4U0 ";
        
        // Present the view controller modally.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentViewController:composeVC animated:YES completion:nil];
        });}
}





-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if(result == MessageComposeResultSent) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        
        
    } else {
        
        [self dismissViewControllerAnimated:NO completion:nil];
        
    }
}





-(void)establishCurrentUserWithBlock:(void(^)(BOOL))completionBlock {
    
    Firebase *ref = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",[[NSUserDefaults standardUserDefaults] stringForKey:UserIDKey]]];
    
    [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        self.dataSource.currentUser = [self.dataSource useSnapShotAndCreateUser:snapshot];
        
        completionBlock(YES);
        
    }];
    
}




-(void)methodToPullDownPactsFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {
    
    
    __block NSUInteger numberOfPactsInDataSource = self.dataSource.currentUser.pacts.count;
    
    self.dataSource.currentUser.pactsToShowInApp = [[NSMutableArray alloc]init];
    
    for (NSString *pactID in self.dataSource.currentUser.pacts) {
        
        [[self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"pacts/%@",pactID]] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshotForPacts) {
            
            JDDPact *currentPact = [self.dataSource useSnapShotAndCreatePact:snapshotForPacts];
            
            BOOL isUniquePact = YES;
            for (JDDPact *pact in self.dataSource.currentUser.pactsToShowInApp) {
                
                NSString *pactID = pact.pactID;
                NSString *currentPactID = currentPact.pactID;
                if (pactID && currentPactID) {
                    if ([pactID isEqualToString:currentPact.pactID]) {
                        isUniquePact = NO;
                    }
                }
                
            }
            
            if (isUniquePact) {
                [self.dataSource.currentUser.pactsToShowInApp addObject:[self.dataSource useSnapShotAndCreatePact:snapshotForPacts]];
            }
            
            numberOfPactsInDataSource--;
            
            if (numberOfPactsInDataSource == 0) {
                completionBlock(YES);
            }
            
        }];
        
    }
    
}





-(void)getAllUsersInPact:(JDDPact *)pact completion:(void (^)(BOOL success))completionBlock
{
    pact.usersToShowInApp = [[NSMutableArray alloc] init];
    __block NSUInteger remainingUsersToFetch = pact.users.count;
    
    // getting the userID information
    for (NSString *user in pact.users) {
        
        // querying firebase and creating user
        Firebase *ref = [self.dataSource.firebaseRef childByAppendingPath:[NSString stringWithFormat:@"users/%@",user]];
        
        [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            JDDUser *person = [self.dataSource useSnapShotAndCreateUser:snapshot];
            
            BOOL isUniqueUser = YES;
            
            for (JDDUser * pactUser in pact.usersToShowInApp){
                
                if ([pactUser.userID isEqualToString:person.userID]) {
                    isUniqueUser = NO;
                }
            }
            
            if (isUniqueUser) {
                [pact.usersToShowInApp addObject:person];
            }
            
            remainingUsersToFetch--;
            if(remainingUsersToFetch == 0) {
                completionBlock(YES);
            }
        }];
    }
}





// this method is populating the users in the pact so we can use Twitter info etc. in the UserPactVC. Everything is saved in
-(void)observeEventForUsersFromFirebaseWithCompletionBlock:(void(^)(BOOL))completionBlock {
    __block NSUInteger remainingPacts = self.dataSource.currentUser.pactsToShowInApp.count;
    
    for (JDDPact *pact in self.dataSource.currentUser.pactsToShowInApp) {
        
        [self getAllUsersInPact:pact completion:^(BOOL success) {
            remainingPacts--;
            
            if(remainingPacts == 0) {
                completionBlock(YES);
            }
        }];
        
    }
    
}




- (IBAction)pactTitleEditingEnd:(id)sender {
    if (self.pactTitle.text.length >1) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            
            CGFloat iphoneSize = [[UIScreen mainScreen] bounds].size.height;
            if (iphoneSize == 568) { //iphone 4"
                self.topConstraint.constant = 0;
            } else if (iphoneSize == 736) { //iphone 5.5"
                self.topConstraint.constant = 0;
                
                self.buttonsTopConstraint.constant = 150;
                
            } else { //iphoe 4.7"
                self.topConstraint.constant = 0;
                self.buttonsTopConstraint.constant = 120;
            }
            
            self.welcomeLabel.hidden = YES;
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            self.contactButtonView.hidden = NO;
            self.addFriendsView.hidden = NO;
            
        }];
        
        
    } else {
        [self alertFinishFiling:@"Please pick a pact name that is at least 3 characters"];
    }
    
    if ((self.dataSource.currentUser.pacts.count==0 || [self.dataSource.currentUser.pacts isEqual:nil]) && self.contacts.count == 0 && self.pactTitle.text.length >1) {
        
        [UIView animateWithDuration:1 animations:^{
            self.descriptionLabel.text = @"Please add friends to the pact by tapping the plus button";
            self.descriptionLabel.alpha = 1;
        } completion:nil];
        
        
    } else {
        self.descriptionLabel.hidden = YES;
    }
}




- (IBAction)didEndEditingPactDescription:(id)sender {
    
    if (self.pactDescription.text.length > 2) {
        [UIView animateWithDuration:1 animations:^{
            self.pickerView.alpha = 1;
            self.repeatLabel.alpha = 1;
            self.repeatSwitch.alpha = 1;
            self.HowOften.alpha =1;
            [self.view layoutIfNeeded];
            
        } completion:nil];
        
        [UIView animateWithDuration:1 delay:2 options:0 animations:^{
            self.stakesTextView.alpha = 1;
            
        } completion:nil];
        
    } else {
        [self alertFinishFiling:@"Please enter a pact description"];
        self.pickerView.alpha = 0;
        self.repeatLabel.alpha = 0;
        self.repeatSwitch.alpha = 0;
        self.HowOften.alpha = 0;
    }
    
}

- (IBAction)didEndStakeDescription:(id)sender {
    
    
    
    if (self.stakesTextView.text.length >2) {
        [UIView animateWithDuration:1 animations:^{
            self.shameSwitch.alpha = 1;
            self.twitterShameLabel.alpha =1;
            [self.view layoutIfNeeded];
            
            
        } completion:nil];
        
    }    else {
        [self.stakesTextView resignFirstResponder];
        [self alertFinishFiling:@"Please enter your stakes"];
        return;
    }
    
    if (!self.shameSwitch.on) {
        
        [UIView animateWithDuration:1 animations:^{
            self.twitterOnboardingLabel.text = @"Enable Twitter Shame to call out your friends on Twitter! This tweet will automatically post if you don't meet your check-in goals.";
            self.twitterOnboardingLabel.alpha = 1;
            [self.view layoutIfNeeded];
            
        } completion:nil];
        
        
    } else {
        self.descriptionLabel.hidden = YES;
    }
    
    CGFloat iphoneSize = [[UIScreen mainScreen] bounds].size.height;
    if (iphoneSize == 568) {
        self.topConstraint.constant = 0;
        self.buttonsTopConstraint.constant = 10;
    } else if (iphoneSize == 736) {
        
        self.buttonsTopConstraint.constant = 110;
        
    } else {
        
        self.buttonsTopConstraint.constant = 80;
    }
    
    
}



-(void)didSelectedContactToInvite
{
    
    if (self.contactsToShow.count >0) {
        [UIView animateWithDuration:1 animations:^{
            self.pactDescription.alpha = 1;
            self.descriptionLabel.alpha = 0;
        } completion:nil];
        
    } else {
        [self alertFinishFiling:@"Please add friends to your pact"];
        self.pactDescription.hidden = YES;
        
    }
    
}

-(void)alertFinishFiling: (NSString *)message
{
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction: ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    
    if(range.length + range.location > textField.text.length)
        
    {
        return NO;
    }
    
    if ([textField isEqual: self.pactTitle]) {
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 12;
    } else if ([textField isEqual:self.stakesTextView]) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 30;
    }
    
    return NO;
}
@end
