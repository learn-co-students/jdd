//
//  UserPactsViewController.m
//  stakes
//
//  Created by Jeremy Feld on 3/29/16.
//  Copyright © 2016 Jeremy Feld. All rights reserved.
//

#import "UserPactsViewController.h"
#import "JDDDataSource.h"
#import "JDDUser.h"
#import "JDDPact.h"
#import <FZAccordionTableView/FZAccordionTableView.h>
#import "PactAccordionHeaderView.h"
#import "JDDDataSource.h"
#import "UserPactCellView.h"
#import "PactDetailViewController.h"
#import "LoginViewController.h"

@interface UserPactsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) JDDDataSource *dataSource;
@property (nonatomic, strong) JDDUser * currentUser;
@property (nonatomic, strong) JDDPact * currentOpenPact;
@property (nonatomic, strong) NSString *pactOAUTH;

@end

@implementation UserPactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource= [JDDDataSource sharedDataSource];
    
    NSLog(@"%@",self.dataSource.currentUser);
    
    NSLog(@"%lu",self.dataSource.currentUser.pacts.count);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowMultipleSectionsOpen = NO;
    self.tableView.keepOneSectionOpen = NO;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), nil];
    self.tableView.scrollEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserPactCellView" bundle:nil] forCellReuseIdentifier:@"basicCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PactAccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:accordionHeaderReuseIdentifier];
    
    [self setupSwipeGestureRecognizer];
    
//    [self perform
//     accessibilityElementDidBecomeFocused:@"login" sender:self];
}
//
//-(void)displayLoginController:(LoginViewController *)login {
//    [self addChildViewController:login];
////    login.view.frame = [self frameForLoginViewController];
//    
//}

#pragma gestureRecognizers for segues
-(void)setupSwipeGestureRecognizer {
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightGestureHappened:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:swipe];
}

-(void)swipeRightGestureHappened:(UISwipeGestureRecognizer *)swipeGestureRight{
    
    NSLog(@"Right Gesture Recognizer is happeneing!");
    
    [self performSegueWithIdentifier:@"segueToSmackTalkVC" sender:self];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < -(self.view.frame.size.height/6)) {
        
        [self performSegueWithIdentifier:@"segueToCreatePact" sender:self];
        
    }
}

#pragma stuff for tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 550;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserPactCellView * cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.pact = self.dataSource.currentUser.pacts[indexPath.section];
    
    
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.currentUser.pacts.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    PactAccordionHeaderView *viewThing = [tableView dequeueReusableHeaderFooterViewWithIdentifier:accordionHeaderReuseIdentifier];
    
    JDDPact *currentPact = self.dataSource.currentUser.pacts[section];
    
    viewThing.pact = currentPact;
    
    return viewThing;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // get selected pact
    // create pact message vc
    // pass pact to message vc
    // show message vc -
    
//    self showViewController:<#(nonnull UIViewController *)#> sender:<#(nullable id)#>
    
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueToSmackTalkVC"]) {
        
        // identify open pact and send it to the next VC.
        
    } else if ([segue.identifier isEqualToString:@"segueToCreatePact"]) {
        
        // don't do anything
        
    }
    
    
    // I think this stuff should be in the viewDidLoad w/ alert controllers.
    
//    LoginViewController *login = segue.destinationViewController;
//    
//    login.oauthtoken = self.pactOAUTH;
//
//    this is crashing the app... should this be here?
    
}



@end
