//
//  BranchListViewController.m
//  ATMNavigator
//
//  Created by goodcore2 on 5/2/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import "BranchListViewController.h"

@interface BranchListViewController ()

@end

@implementation BranchListViewController

@synthesize atmNavigatorDelegate;
@synthesize topImageView, bottomImageView;
@synthesize navBarContainer, branchListContainer, branchDetailContainer, branchUpdateContainer, branchDetailIconContainer;
@synthesize tblBranchList;
@synthesize mapBranchList;
@synthesize timerBranchList , indexData;
@synthesize actualData, loadData;
@synthesize branchUpdateViewController;
@synthesize preDefinedLocations;

@synthesize imgViewBranch, prevSelectedImgView, moveFrame, imgViewBranchATMStatus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // views
    
    [self.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self registerViewControllerForLocalNotification];
    [self initializeViewContainer];
    [self initializeBranchDetailIconContainer];
    [self initializeBranchUpdateContainer];
    [self initializeBranchDetail];
    [self customizeNavigationBar];
    [self customizeSideBarNavigator];
    [self initializeSocketAndBranchUpdateController];
    [self initializeMapView];
    [self initializeBranchTable];
    [self initializeTopAndBottomImageSplit];
    
    // initialize properties
    
    // will be added in animation method and will also be remved from view on demand
    imgViewBranchATMStatus = [[UIImageView alloc] initWithFrame:CGRectMake(200, 170, 32, 32)];
    [imgViewBranchATMStatus setImage:[UIImage imageNamed:@"available"]];
    [[imgViewBranchATMStatus layer] setCornerRadius:15];
    
    [self intializeDataForPreDefinedLocations];
    
    indexData = 0;
    atmNavigatorDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    loadData = [[NSMutableArray alloc] init];
    actualData = [[NSMutableArray alloc] init];
    
}

- (void) registerViewControllerForLocalNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reConnectSocket)
                                                 name:NOTIFICATION_NETWORK_DISCONNECTED
                                               object:nil];
    
}

- (void) intializeDataForPreDefinedLocations {
    
    preDefinedLocations = [[NSMutableArray alloc] init];
    
    // karachi pakistan
    [preDefinedLocations addObject:    [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"Karachi", PREDEFINED_LOCATION_CITY
                                        ,@"Pakistan", PREDEFINED_LOCATION_COUNTRY
                                        ,@"+24.90000" , PREDEFINED_LOCATION_LATITUDE
                                        ,@"+67.15000", PREDEFINED_LOCATION_LONGITUDE, nil]];
    
    
    // Beijing, China
    [preDefinedLocations addObject:    [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"Beijing", PREDEFINED_LOCATION_CITY
                                        ,@"China", PREDEFINED_LOCATION_COUNTRY
                                        ,@"+39.91660" , PREDEFINED_LOCATION_LATITUDE
                                        ,@"+116.38330", PREDEFINED_LOCATION_LONGITUDE, nil]];
    
    // india
    [preDefinedLocations addObject:    [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"Singapore", PREDEFINED_LOCATION_CITY
                                        ,@"Singapore", PREDEFINED_LOCATION_COUNTRY
                                        ,@"1.300614" , PREDEFINED_LOCATION_LATITUDE
                                        ,@"103.845104", PREDEFINED_LOCATION_LONGITUDE, nil]];
    
    
    // Chittagong, Bangladesh                
    [preDefinedLocations addObject:    [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"Chittagong", PREDEFINED_LOCATION_CITY
                                        ,@"Bangladesh  ", PREDEFINED_LOCATION_COUNTRY
                                        ,@"+22.25000" , PREDEFINED_LOCATION_LATITUDE
                                        ,@"+91.83330", PREDEFINED_LOCATION_LONGITUDE, nil]];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];    
    
    
    if([atmNavigatorDelegate isAppStarted]){
     
        [atmNavigatorDelegate setIsAppStarted:NO];
        
        CGRect toFrameTopImge = CGRectMake(0
                                   , -([UIScreen mainScreen].bounds.size.height/2 + 90)
                                   , [UIScreen mainScreen].bounds.size.width
                                   , [UIScreen mainScreen].bounds.size.height/2 - 90);
        
        CGRect toFrameBottomImage = CGRectMake(0
                                   , [UIScreen mainScreen].bounds.size.height + 90
                                   , [UIScreen mainScreen].bounds.size.width
                                   , [UIScreen mainScreen].bounds.size.height/2 + 90);
        
        
        [UIView animateWithDuration:2.0 animations:^{
            
            [topImageView setFrame:toFrameTopImge];
        } completion:^(BOOL finished) {
            
            [topImageView removeFromSuperview];
            [topImageView setImage:nil];
            topImageView = nil;
            
            
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }];
        
        [UIView animateWithDuration:2.0 animations:^{
            
            [bottomImageView  setFrame:toFrameBottomImage];
        } completion:^(BOOL finished) {
            
            [bottomImageView  removeFromSuperview];            
            [bottomImageView setImage:nil];
            bottomImageView = nil;
            
            // load data at completion
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if([defaults objectForKey:USER_DEFAULT_BRANCH_LIST]){
                
                // getting previous location updates
                [actualData addObjectsFromArray:[defaults objectForKey:USER_DEFAULT_BRANCH_LIST]];
                [self updateTable];
            }
            else{                
                [self getLatestBranchList];
            }
            
            
            [branchUpdateContainer setHidden:NO];
            [branchUpdateContainer setAlpha:0.0];
            [UIView animateWithDuration:1.0
                                  delay:0.0
                                options:UIViewAnimationOptionTransitionNone
                             animations:^{
                                 [branchUpdateContainer setAlpha:1.0];
                             }
                             completion:nil];
        }];
    }
    
}

/////////////////// SOCKET SUPPORTED METHODS ////////////////
- (void) initializeSocketAndBranchUpdateController {
    
    
    branchUpdateViewController = [[BranchUpdateViewController alloc]
                                                              initWithNibName:@"BranchUpdateViewController" bundle:nil ];
    
    socketIO = [[SocketIO alloc] initWithDelegate:branchUpdateViewController];
    [socketIO connectToHost:@"branch-locator.herokuapp.com/" onPort:0];
    
    // for animating the button pas the reference of update button
    [branchUpdateViewController setBranchUpdateContainer:branchUpdateContainer];
    
    // no need right now
    //socketIO.useSecure = YES;
}

// once notification for re-connect issued then re-conenct the socket
- (void) reConnectSocket{
    
    [socketIO connectToHost:@"branch-locator.herokuapp.com/" onPort:0];
}


- (void) initializeTopAndBottomImageSplit {
    
    
    topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0
                                                                 , 0
                                                                 , [UIScreen mainScreen].bounds.size.width
                                                                 , [UIScreen mainScreen].bounds.size.height/2 - 90)];
    [topImageView setImage:[UIImage imageNamed:@"split-upper"]];
    [self.view addSubview:topImageView];
    
    
    bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0
                                                                    , [UIScreen mainScreen].bounds.size.height/2 - 90
                                                                    , [UIScreen mainScreen].bounds.size.width
                                                                    , [UIScreen mainScreen].bounds.size.height/2 + 90)];
    [bottomImageView setImage:[UIImage imageNamed:@"split-lower"]];
    [self.view addSubview:bottomImageView ];
    
}

- (void) initializeViewContainer {
    
    branchDetailContainer = [[UIView alloc] initWithFrame:CGRectMake(0
                                                                     , 0
                                                                     , [UIScreen mainScreen].bounds.size.width
                                                                     , [UIScreen mainScreen].bounds.size.height-92)];
    [branchDetailContainer setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_gradient"]]];
    [branchDetailContainer setHidden:YES];
    [self.view addSubview:branchDetailContainer];
    
    branchListContainer = [[UIView alloc] initWithFrame:CGRectMake(0
                                                                   , 0
                                                                   , [UIScreen mainScreen].bounds.size.width
                                                                   , [UIScreen mainScreen].bounds.size.height-137)];
    [branchListContainer setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:branchListContainer];
    
}

- (void) initializeBranchTable {
    
    tblBranchList = [[UITableView alloc] initWithFrame:CGRectMake(0
                                                                  , 0
                                                                  , [UIScreen mainScreen].bounds.size.width
                                                                  , [UIScreen mainScreen].bounds.size.height-137)];
    [tblBranchList setBackgroundColor:[UIColor whiteColor]];
    tblBranchList.dataSource = self;
    tblBranchList.delegate = self;
    [branchListContainer addSubview:tblBranchList];
    
    [self.branchListContainer bringSubviewToFront:tblBranchList];
    
    __weak typeof(self) weakSelf = self;
    // Set the pull to refresh handler block
    [tblBranchList setPullToRefreshHandler:^{
        [weakSelf getLatestBranchList];
    }];    
}

- (void) initializeMapView {
    mapBranchList = [[MKMapView alloc] initWithFrame:CGRectMake(0
                                                                , 0
                                                                , [UIScreen mainScreen].bounds.size.width
                                                                , [UIScreen mainScreen].bounds.size.height-130)];
    [mapBranchList showsUserLocation];
    mapBranchList.delegate = self;
    
    [mapBranchList setHidden:YES];
    [branchListContainer addSubview:mapBranchList];
}


- (void) initializeBranchDetail {
    
    // for animation
    imgViewBranch = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [imgViewBranch setContentMode:UIViewContentModeScaleAspectFill];
    [[imgViewBranch layer] setCornerRadius:75];
    [[imgViewBranch layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[imgViewBranch layer] setBorderWidth:1];
    [imgViewBranch setClipsToBounds:YES];
    [imgViewBranch setUserInteractionEnabled:YES];
    imgViewBranch.tag = 0;
    
    Custombutton *btnClearImgViewBranch = [[Custombutton alloc] initWithFrame:imgViewBranch.frame];
    [btnClearImgViewBranch addTarget:self action:@selector(btnPressedImgViewBranchInDetailView:) forControlEvents:UIControlEventTouchUpInside];
    [btnClearImgViewBranch setTag:10];
    [imgViewBranch addSubview:btnClearImgViewBranch];
    
    UIButton *btnViewBack = [[UIButton alloc] initWithFrame:CGRectMake(275, 6, 36, 36)];
    [btnViewBack setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal & UIControlStateSelected];
    [btnViewBack addTarget:self action:@selector(showBranchListFromDetail) forControlEvents:UIControlEventTouchUpInside];
    [btnViewBack setTag:10];
    [btnViewBack setHidden:YES];
    
    UILabel *lblBranchName = [[UILabel alloc] initWithFrame:CGRectMake(8, 225, 304, 25)];
    [lblBranchName setBackgroundColor:[UIColor clearColor]];
    lblBranchName.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    [lblBranchName setNumberOfLines:2];
    [lblBranchName setTextColor:[UIColor darkGrayColor]];
    lblBranchName.contentMode = UIViewContentModeBottomLeft;
    lblBranchName.textAlignment = NSTextAlignmentCenter;
    [lblBranchName adjustsFontSizeToFitWidth];
    [lblBranchName setHidden:YES];
    [lblBranchName setTag:20];
    
    UILabel *lblBranchAddress = [[UILabel alloc] initWithFrame:CGRectMake(8, 242, 304, 100)];
    [lblBranchAddress setBackgroundColor:[UIColor clearColor]];
    lblBranchAddress.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [lblBranchAddress setNumberOfLines:5];
    [lblBranchAddress setTextColor:[UIColor grayColor]];
    lblBranchAddress.contentMode = UIViewContentModeTopLeft;
    [lblBranchAddress adjustsFontSizeToFitWidth];
    [lblBranchAddress setHidden:YES];
    lblBranchAddress.textAlignment = NSTextAlignmentCenter;
    [lblBranchAddress setTag:30];
    
    [self.branchDetailContainer addSubview:btnViewBack];
    [self.branchDetailContainer addSubview:lblBranchName];
    [self.branchDetailContainer addSubview:lblBranchAddress];
    
}

- (void) initializeBranchDetailIconContainer {
    
    
    branchDetailIconContainer = [[UIView alloc] initWithFrame:CGRectMake(0
                                                                         , [UIScreen mainScreen].bounds.size.height-92
                                                                         , [UIScreen mainScreen].bounds.size.width
                                                                         , 72)];
    [branchDetailIconContainer setBackgroundColor:[UIColor colorWithRed:247/255.f green:247/255.f blue:247/255.f alpha:1.0]];
    [branchDetailIconContainer setHidden:YES];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 72)];
    [imgView setImage:[UIImage imageNamed:@"bottom_bar"]];
    [imgView setContentMode:UIViewContentModeScaleToFill];
    [branchUpdateContainer addSubview:imgView];
    
    UIButton *btnBranchCall = [[UIButton alloc] initWithFrame:CGRectMake(55, 25, 30, 30)];
    [btnBranchCall setBackgroundImage:[UIImage imageNamed:@"icon_call"] forState:UIControlStateNormal & UIControlStateSelected];
    [btnBranchCall addTarget:self action:@selector(btnPressedCall:) forControlEvents:UIControlEventTouchUpInside];
    [btnBranchCall setTag:10];
    
    
    UIButton *btnBranchMessage = [[UIButton alloc] initWithFrame:CGRectMake(115, 25, 30, 30)];
    [btnBranchMessage setBackgroundImage:[UIImage imageNamed:@"icon_sms"] forState:UIControlStateNormal & UIControlStateSelected];
    [btnBranchMessage addTarget:self action:@selector(btnPressedMessage:) forControlEvents:UIControlEventTouchUpInside];
    [btnBranchMessage setTag:20];
    
    UIButton *btnBranchMail = [[UIButton alloc] initWithFrame:CGRectMake(175, 25, 30, 30)];
    [btnBranchMail setBackgroundImage:[UIImage imageNamed:@"icon_mail"] forState:UIControlStateNormal & UIControlStateSelected];
    [btnBranchMail addTarget:self action:@selector(btnPressedMail:) forControlEvents:UIControlEventTouchUpInside];
    [btnBranchMail setTag:30];
    
    UIButton *btnBranchContacts = [[UIButton alloc] initWithFrame:CGRectMake(240, 25, 30, 30)];
    [[btnBranchContacts layer] setCornerRadius:15];
    [btnBranchContacts setBackgroundImage:[UIImage imageNamed:@"icon_contact"] forState:UIControlStateNormal & UIControlStateSelected];
    [btnBranchContacts addTarget:self action:@selector(btnPressedContactList:) forControlEvents:UIControlEventTouchUpInside];
    [btnBranchContacts setTag:40];
    
    [branchDetailIconContainer addSubview:imgView];
    [branchDetailIconContainer addSubview:btnBranchCall];
    [branchDetailIconContainer addSubview:btnBranchMessage];
    [branchDetailIconContainer addSubview:btnBranchMail];
    [branchDetailIconContainer addSubview:btnBranchContacts];
    
    [self.view addSubview:branchDetailIconContainer];
}


- (void) initializeBranchUpdateContainer {
    
    branchUpdateContainer = [[UIView alloc] initWithFrame:CGRectMake(0
                                                                     , [UIScreen mainScreen].bounds.size.height-137
                                                                     , [UIScreen mainScreen].bounds.size.width
                                                                     , 72)];
    [branchUpdateContainer setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 72)];
    [imgView setImage:[UIImage imageNamed:@"bottom_bar"]];
    [imgView setContentMode:UIViewContentModeScaleToFill];
    [branchUpdateContainer addSubview:imgView];
    
    UIButton *btnBranchUpdate = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 17, 21, 36, 34)];
    [[btnBranchUpdate titleLabel] setTextAlignment:NSTextAlignmentCenter];
    [btnBranchUpdate setBackgroundImage:[UIImage imageNamed:@"icon_update"] forState:UIControlStateNormal & UIControlStateSelected];
    [btnBranchUpdate setTag:10];
    
    UIButton *btnClearUpdate = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 72)];
    [btnClearUpdate setBackgroundColor:[UIColor clearColor]];
    [btnClearUpdate addTarget:self action:@selector(btnPressedBranchUpdate:) forControlEvents:UIControlEventTouchUpInside];
    
    [branchUpdateContainer addSubview:btnBranchUpdate];
    [branchUpdateContainer addSubview:btnClearUpdate];
    [self.view addSubview:branchUpdateContainer];
    
    
    [branchUpdateContainer setHidden:YES];
}

- (void) customizeNavigationBar {
    
    [[UINavigationBar appearance] setBackgroundImage: [UIImage imageNamed:@"titlebar_gray"] forBarMetrics:UIBarMetricsDefault];
    
    navBarContainer = [[UIView alloc] initWithFrame:CGRectMake(289, 7, 30, 30)];
    [navBarContainer setBackgroundColor:[UIColor clearColor]];
    
    UIButton *btnListView = [[UIButton alloc] initWithFrame:CGRectMake(0, 8, 18, 14)];
    [btnListView setBackgroundImage:[UIImage imageNamed:@"icon-list.png"] forState:UIControlStateNormal & UIControlStateSelected];
    [btnListView addTarget:self action:@selector(btnNavBarPressedSwitchView) forControlEvents:UIControlEventTouchUpInside];
    [btnListView setTag:10];

    UIButton *btnMapView = [[UIButton alloc] initWithFrame:CGRectMake(0, 4, 22, 22)];
    [btnMapView setBackgroundImage:[UIImage imageNamed:@"icon-map.png"] forState:UIControlStateNormal & UIControlStateSelected];
    [btnMapView addTarget:self action:@selector(btnNavBarPressedSwitchView) forControlEvents:UIControlEventTouchUpInside];
    [btnMapView setHidden:YES];
    [btnMapView setTag:20];
    
    [navBarContainer addSubview:btnMapView];
    [navBarContainer addSubview:btnListView];
    
    [self.navigationController.navigationBar addSubview:navBarContainer];
    
}

- (void) customizeSideBarNavigator {
    
    PPRevealSideInteractions inter = PPRevealSideInteractionNone;
    self.revealSideViewController.panInteractionsWhenClosed = inter;
}


//////////// selectors
- (void) btnPressedImgViewBranchInDetailView : (Custombutton *) sender{
    
    UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 290, [UIScreen mainScreen].bounds.size.height-100)];
    [imgMap setImage:prevSelectedImgView.image];
    
    [[KGModal sharedInstance] showWithContentView:imgMap andAnimated:YES];
}

- (void) btnPressedLocation : (UIButton *) sender {
    
    [[KGModal sharedInstance] hideAnimated:YES];
    
    [self fetchDataFromServer:[[preDefinedLocations objectAtIndex:[sender tag]] valueForKey:PREDEFINED_LOCATION_LATITUDE]
                    longitude:[[preDefinedLocations objectAtIndex:[sender tag]] valueForKey:PREDEFINED_LOCATION_LONGITUDE]
                     distance:sender.tag == 1 ? 2000 : 1000];
    
}

- (void) btnPressedCall : (UIButton *) sender {
    
    NSString *phoneNumber = [[loadData objectAtIndex:[imgViewBranch rowIndex]] valueForKey:BRANCH_CONTACT_NUMBER];
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", cleanedString]]];
    
}

// mail controller delegates
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) btnPressedMessage : (UIButton *) sender{
    
    if([MFMessageComposeViewController canSendText])
    {
        
        NSString *phoneNumber = [[loadData objectAtIndex:[imgViewBranch rowIndex]] valueForKey:BRANCH_CONTACT_NUMBER];
        NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
        
        MFMessageComposeViewController *messenger = [[MFMessageComposeViewController alloc] init];
        
        //1(234)567-8910
        messenger.recipients = [NSArray arrayWithObjects:cleanedString, nil];
        messenger.messageComposeDelegate = self;
        [self presentViewController:messenger animated:YES completion:nil];
    }
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
        [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) btnPressedMail : (UIButton *) sender{
    
    if ([MFMailComposeViewController canSendMail])
    {        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@" "];
        NSArray *toRecipients = [NSArray arrayWithObjects:[[loadData objectAtIndex:[imgViewBranch rowIndex]] valueForKey:BRANCH_CONTACT_MAIL], nil];
        [mailer setToRecipients:toRecipients];
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        mailer.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIColor colorWithRed:64/255.0 green:143/255.0 blue:174/255.0 alpha:1.0]
                                                    ,   UITextAttributeTextColor
                                                    ,   [UIColor clearColor]
                                                    ,   UITextAttributeTextShadowColor
                                                    ,   [NSValue valueWithUIOffset:UIOffsetMake(0, 0)]
                                                    ,   UITextAttributeTextShadowOffset
                                                    ,   [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0]
                                                    ,   UITextAttributeFont,
                                                    nil];
        
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) btnPressedContactList : (UIButton *) sender
{
    ContactListViewController *contactListViewController = [[ContactListViewController alloc] init];
    contactListViewController.actualData = [[actualData objectAtIndex:[imgViewBranch rowIndex]] valueForKey:BRANCH_CONTACTS];
    
    [self.revealSideViewController pushViewController:contactListViewController
                                          onDirection:PPRevealSideDirectionLeft
                                           withOffset:40.0f
                                             animated:YES completion:^{
        PPRSLog(@"This is the end!");
    }];
    
    PP_RELEASE(contactListViewController);
}

- (void) btnNavBarPressedSwitchView {
    
    if([mapBranchList isHidden]){
        
        [self updateMapView];
        
        [UIView transitionWithView:navBarContainer duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            [[navBarContainer viewWithTag:10] setHidden:YES];
                            [[navBarContainer viewWithTag:20] setHidden:NO];
                            
                        } completion:^(BOOL finished) {
                            if(finished){
                            }
                        }];
        
        [UIView transitionWithView:branchListContainer duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            [tblBranchList setHidden:YES];
                            [mapBranchList setHidden:NO];
                            
                        } completion:^(BOOL finished) {
                            if(finished){
                            }
                        }];
        
    }
    else{
        
        [UIView transitionWithView:navBarContainer duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            [[navBarContainer viewWithTag:10] setHidden:NO];
                            [[navBarContainer viewWithTag:20] setHidden:YES];
                            
                        } completion:^(BOOL finished) {
                            if(finished){
                            }
                        }];

        
        [UIView transitionWithView:branchListContainer duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            [mapBranchList setHidden:YES];
                            [tblBranchList setHidden:NO ];
                            
                        } completion:^(BOOL finished) {
                        }];
    }
}

- (void) btnPressedBranchUpdate : (UIButton *) sender {
    
    [self.revealSideViewController pushViewController:branchUpdateViewController
                                          onDirection:PPRevealSideDirectionBottom
                                           withOffset:66.0f
                                             animated:YES completion:^{
                                                 PPRSLog(@"This is the end!");
    }];
}

// server oriented methods
- (void) fetchDataFromServer : (NSString *) latitude longitude : (NSString *) longitude distance : (NSInteger)distance{
    
    if(![atmNavigatorDelegate isNetworkAvailable]){
        
        [tblBranchList refreshFinished];
        GRAlertView *alertView = [[GRAlertView alloc] initWithTitle:@"Cannot connect to network"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        alertView.style = GRAlertStyleWarning;
        [alertView show];
    }
    else{
        
        
        NSString *urlString = [NSString stringWithFormat:@"%@/branch/getList?lon=%@&lat=%@&dist=%d"
                               ,Server_URL
                               , longitude
                               , latitude
                               , distance];
        
        NSLog(@"server call: %@", urlString);
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        
        AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                            
                                                            [self populateData:JSON];
        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
                    [SVProgressHUD dismissWithError:@"Server not responded" afterDelay:2.0];
        }];
        [operation start];
        [SVProgressHUD showWithStatus:@"Loading Branches" maskType:SVProgressHUDMaskTypeClear];
    }
}


- (void) getLatestBranchList {
   
     if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized))
     {
         [atmNavigatorDelegate controlTracking:YES];
         [SVProgressHUD showWithStatus:@"Updating Location" maskType:SVProgressHUDMaskTypeClear];
         
         // wait for 1 sec
         [self performSelector:@selector(lookForLatestLoction) withObject:nil afterDelay:2.0];
     }
     else{
    
         [self setUpViewForPredefinedLocations];
    }
}

- (void) lookForLatestLoction {
    
    // need to dismiss the updating location progress
    [SVProgressHUD dismiss];
    
    if([atmNavigatorDelegate isLocationUpdated]){
        [self fetchDataFromServer:[NSString stringWithFormat:@"%f",atmNavigatorDelegate.latestLocation.coordinate.latitude]
                        longitude:[NSString stringWithFormat:@"%f", atmNavigatorDelegate.latestLocation.coordinate.longitude]
                         distance:1000];
    }
    else{
        // now ask for user preference
        [tblBranchList refreshFinished];
        
        
        GRAlertView *alertView = [[GRAlertView alloc] initWithTitle:@"Location Service not working properly"
                                           message:@"Please refresh again or look for predefine locations"
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@"Pre-Define", @"Cancel", nil];
        alertView.style = GRAlertStyleInfo;
        [alertView setTag:10];
        [alertView show];
        
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 10 is for predefinde locations popup
    if([alertView tag] == 10 && buttonIndex == 0){
        [self setUpViewForPredefinedLocations];
    }
}


- (void) setUpViewForPredefinedLocations {
    
    [tblBranchList refreshFinished];
    
    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 160)];
    
    NSInteger index = 0;
    for(NSMutableDictionary *preDefine in preDefinedLocations){
        
        UIButton *btnLocation = [[UIButton alloc] initWithFrame:CGRectMake(0, index * 40, 300, 40)];
        [btnLocation setBackgroundColor:[UIColor whiteColor]];
        [btnLocation setTag:index];
        [btnLocation addTarget:self action:@selector(btnPressedLocation:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 1)];
        [topLine setBackgroundColor:[UIColor blackColor]];
        
        UILabel *lblCityName = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 290, 15)];
        lblCityName.numberOfLines = 1;
        [lblCityName setBackgroundColor:[UIColor clearColor]];
        lblCityName.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        [lblCityName setTextColor:[UIColor colorWithRed:64/255.0 green:143/255.0 blue:174/255.0 alpha:1.0]];
        lblCityName.textAlignment = NSTextAlignmentCenter;
        [lblCityName setLineBreakMode:NSLineBreakByTruncatingTail];
        [lblCityName adjustsFontSizeToFitWidth];
        [lblCityName setText:[preDefine valueForKey:PREDEFINED_LOCATION_CITY]];
        
        
        UILabel *lblCountryName = [[UILabel alloc] initWithFrame:CGRectMake(8, 16, 290, 20)];
        lblCountryName.numberOfLines = 1;
        [lblCountryName setBackgroundColor:[UIColor clearColor]];
        lblCountryName.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        [lblCountryName setTextColor:[UIColor colorWithRed:64/255.0 green:143/255.0 blue:174/255.0 alpha:1.0]];
        lblCountryName.textAlignment = NSTextAlignmentCenter;
        [lblCountryName setLineBreakMode:NSLineBreakByTruncatingTail];
        [lblCountryName adjustsFontSizeToFitWidth];
        [lblCountryName setText:[preDefine valueForKey:PREDEFINED_LOCATION_COUNTRY]];
        
        [btnLocation addSubview:topLine];
        [btnLocation addSubview:lblCityName];
        [btnLocation addSubview:lblCountryName];
        
        [parentView addSubview:btnLocation];        
        index++;
    }
    
    
    [[KGModal sharedInstance] showWithContentView:parentView andAnimated:YES];
    [[KGModal sharedInstance] setTapOutsideToDismiss:NO];
}

- (void) populateData : (NSMutableArray *) JSON {
    
    
    if([JSON count] > 0){
        
        [SVProgressHUD dismiss];
        [actualData removeAllObjects];
        [actualData addObjectsFromArray:JSON];
        [self saveBranchList];
        
        // update views
        [self updateTable];
    }
    else{
        
        [SVProgressHUD dismissWithError:@"Data not available" afterDelay:2.0];
    }
    
    // hide un-necessary views
    [tblBranchList refreshFinished];
    
}

- (void) saveBranchList {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setObject:actualData forKey:USER_DEFAULT_BRANCH_LIST];
    [userDefault synchronize];
}


- (void) updateTable {
    
    [loadData removeAllObjects];
    [tblBranchList reloadData];
    timerBranchList = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(performTableUpdates:)
                                                     userInfo:nil
                                                      repeats:YES];
    
}
-(void)performTableUpdates:(NSTimer*)timer
{
    
    [self.view setUserInteractionEnabled:NO];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexData inSection:0];
    
    if(indexData < [actualData count])
    {
        
        [loadData addObject:[actualData objectAtIndex:indexData]];
        [tblBranchList beginUpdates];
        [tblBranchList insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tblBranchList endUpdates];
        
        if( [actualData count]-indexData == 1 )
        {
            indexData = 0;
            [timerBranchList invalidate];
            timerBranchList = nil;
            [self.view setUserInteractionEnabled:YES];
        }
        else{
            indexData++;
        }
    }
    else
    {
        indexData = 0;
        [timerBranchList invalidate];
        timerBranchList = nil;
        [self.view setUserInteractionEnabled:YES];
    }
}

- (void) updateMapView {
    
    // first remove obselete annotations
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
    for (id annotation in mapBranchList.annotations){        
        if (annotation != mapBranchList.userLocation){
            [toRemove addObject:annotation];
        }
    }
    [mapBranchList removeAnnotations:toRemove];
    
    NSInteger rowIndex = 0;
    for (NSMutableDictionary *branchInfo in actualData) {
        
        if([[branchInfo valueForKey:BRANCH_ATM_LOCATION] valueForKey:BRANCH_ATM_LATITUDE]
           && [[branchInfo valueForKey:BRANCH_ATM_LOCATION] valueForKey:BRANCH_ATM_LONGITUDE]){
            
            CustomAnnotation *annotation = [CustomAnnotation new];
            annotation.coordinate = (CLLocationCoordinate2D){
                    [[[branchInfo valueForKey:BRANCH_ATM_LOCATION] valueForKey:BRANCH_ATM_LATITUDE] doubleValue]
                ,   [[[branchInfo valueForKey:BRANCH_ATM_LOCATION] valueForKey:BRANCH_ATM_LONGITUDE] doubleValue]};
            
            [annotation setTitle:[branchInfo valueForKey:BRANCH_NAME]];
            [annotation setSubtitle:[branchInfo valueForKey:BRANCH_ADDRESS]];
            [annotation setTag:rowIndex];
            [mapBranchList addAnnotation:annotation];
        }
        
        // keep refernce to stream item
        rowIndex++;
    }
    
    ZoomedMapView *zoomMap = [[ZoomedMapView alloc] init];
    [zoomMap zoomMapViewToFitAnnotations:mapBranchList animated:NO];
}

////////////////////// MAP View Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    else if([annotation isKindOfClass:[CustomAnnotation class]]){
        static NSString *annotIdentifier = @"annot";
        
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotIdentifier];
        CustomImageView *imgViewBranchSecondary;
        
        if (!pin)
        {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotIdentifier];
            pin.canShowCallout = YES;
            
            imgViewBranchSecondary = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
            [[imgViewBranchSecondary layer] setCornerRadius:17];
            [[imgViewBranchSecondary layer] setBorderColor:[UIColor grayColor].CGColor];
            [[imgViewBranchSecondary layer] setBorderWidth:2];
            [imgViewBranchSecondary setContentMode:UIViewContentModeScaleAspectFill];
            [imgViewBranchSecondary setClipsToBounds:YES];
                        
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(viewWasTapped:)];
            [imgViewBranchSecondary addGestureRecognizer:tapRecognizer];
            [imgViewBranchSecondary setUserInteractionEnabled:YES];
            [tapRecognizer setDelegate:self];
            [pin setImage:[UIImage imageNamed:@"pin_annotation"]];
        }
        else
        {
            pin.annotation = annotation;
            imgViewBranchSecondary =  (CustomImageView *)[pin leftCalloutAccessoryView];
        }
        
        NSMutableDictionary *branchInfo = [actualData objectAtIndex:[(CustomAnnotation *)annotation tag]];
        NSURL *candidateURL = [NSURL URLWithString: [branchInfo valueForKey:BRANCH_IMAGE] ? [branchInfo valueForKey:BRANCH_IMAGE] : @""];
        
        imgViewBranchSecondary.rowIndex = [(CustomAnnotation *)annotation tag];
        if (candidateURL && candidateURL.scheme && candidateURL.host){
            
            [imgViewBranchSecondary setImageWithURL:candidateURL
                                   placeholderImage:[UIImage imageNamed:@"blue-circle.png"]
                                            success:^(UIImage *image) {
                                            }
                                            failure:^(NSError *error) {
                                            }
             ];
        }
        else{
            
            [imgViewBranchSecondary setImage:[UIImage imageNamed:@"blue-circle.png"]];
        }
        
        pin.leftCalloutAccessoryView  = imgViewBranchSecondary;
        
        return pin;
    }
    else{
        return nil;
    }
}

// UITABLEVIEW DELEGATES TO HANDLE DISPLAY OF REPEATING SECTION
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [loadData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *branchCellIdentifier = [NSString stringWithFormat:@"BranchCell"];
    UITableViewCell *cell;
    UILabel *lblBranchName, *lblBranchAddress;
    CustomImageView *imgViewBranchSecondary;
    UIImageView *bckGroundImage;
    cell = [tableView dequeueReusableCellWithIdentifier:branchCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:branchCellIdentifier];
        [cell setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70)];        
        
        bckGroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70)];
        [bckGroundImage setTag:100];
        [bckGroundImage setUserInteractionEnabled:NO];
        
        lblBranchName = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, 238, 28)];
        [lblBranchName setBackgroundColor:[UIColor clearColor]];
        lblBranchName.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        [lblBranchName setTextColor:[UIColor darkGrayColor]];
        lblBranchName.contentMode = UIViewContentModeBottomLeft;
        [lblBranchName setLineBreakMode:NSLineBreakByTruncatingTail];
        lblBranchName.tag = 10;
        
        lblBranchAddress = [[UILabel alloc] initWithFrame:CGRectMake(8, 30, 238, 28)];
        [lblBranchAddress setBackgroundColor:[UIColor clearColor]];
        [lblBranchAddress setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
        lblBranchAddress.numberOfLines = 2;
        lblBranchAddress.contentMode = UIViewContentModeTopLeft;
        [lblBranchAddress setLineBreakMode:NSLineBreakByTruncatingTail];
        [lblBranchAddress setTextColor:[UIColor grayColor]];
        lblBranchAddress.tag = 20;
        
        imgViewBranchSecondary = [[CustomImageView alloc] initWithFrame:CGRectMake(250, 7.5, 55, 55)];
        [imgViewBranchSecondary setContentMode:UIViewContentModeScaleAspectFill];
        [imgViewBranchSecondary setClipsToBounds:YES];
        [[imgViewBranchSecondary layer] setCornerRadius:27.5];
        [[imgViewBranchSecondary layer] setBorderColor:[UIColor grayColor].CGColor];
        [[imgViewBranchSecondary layer] setBorderWidth:1.25];
        imgViewBranchSecondary.tag = 30;

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(viewWasTapped:)];
        [imgViewBranchSecondary addGestureRecognizer:tapRecognizer];
        [imgViewBranchSecondary setUserInteractionEnabled:YES];
        [tapRecognizer setDelegate:self];        
        
        
        [cell.contentView addSubview:bckGroundImage];
        [cell.contentView addSubview:lblBranchName];
        [cell.contentView addSubview:lblBranchAddress];
        [cell.contentView addSubview:imgViewBranchSecondary];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else{
        
        lblBranchName = (UILabel *)[cell.contentView viewWithTag:10];
        lblBranchAddress = (UILabel *)[cell.contentView viewWithTag:20];
        imgViewBranchSecondary = (CustomImageView *)[cell.contentView viewWithTag:30];
        
        
        bckGroundImage = (UIImageView *)[cell.contentView viewWithTag:100];
    }
    
    NSMutableDictionary *currBranch = [loadData objectAtIndex:indexPath.row];

    lblBranchName.text = [currBranch valueForKey:BRANCH_NAME];
    lblBranchAddress.text = [currBranch valueForKey:BRANCH_ADDRESS];
    
    NSURL *candidateURL = [NSURL URLWithString: [currBranch valueForKey:BRANCH_IMAGE] ? [currBranch valueForKey:BRANCH_IMAGE] : @""];
    
    imgViewBranchSecondary.rowIndex = indexPath.row;
    if (candidateURL && candidateURL.scheme && candidateURL.host){
        
        [imgViewBranchSecondary setImageWithURL:candidateURL
                            placeholderImage:[UIImage imageNamed:@"blue-circle.png"]
                                     success:^(UIImage *image) {
                                     }
                                     failure:^(NSError *error) {
                                     }
         ];
    }
    else{
        
        [imgViewBranchSecondary setImage:[UIImage imageNamed:@"blue-circle.png"]];
    }
    
    
    [bckGroundImage setImage:nil];
    if(indexPath.row % 2 == 0){
        [bckGroundImage setImage:[UIImage imageNamed:@"row_odd"]];
    }
    else{
        [bckGroundImage setImage:[UIImage imageNamed:@"row_even"]];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    prevSelectedImgView = (CustomImageView *)touch.view;
    moveFrame = prevSelectedImgView.frame;
    imgViewBranch.image = [prevSelectedImgView image];
    imgViewBranch.rowIndex = [prevSelectedImgView rowIndex];
    

    // updating clear button frame
    CGRect frame = CGRectMake(0, 0, 150, 150);
    
    Custombutton *btnClear = (Custombutton *)[imgViewBranch viewWithTag:10];
    btnClear.frame = frame;
    btnClear.rowIndex = [prevSelectedImgView rowIndex];
    
    return YES;
}

- (void)viewWasTapped:(UITapGestureRecognizer *)recognizer
{
    
    NSMutableDictionary *selectedBranch = [loadData objectAtIndex:imgViewBranch.rowIndex];    
    CGPoint tapLocation = [recognizer locationInView:[self view]];
    
    moveFrame.origin.y = tapLocation.y - 40;
    [imgViewBranch setFrame:moveFrame];
    
    if([[selectedBranch valueForKey:BRANCH_ATM_AVALIABLE] isEqualToNumber:[NSNumber numberWithBool:YES]]){
        [imgViewBranchATMStatus setImage:[UIImage imageNamed:@"available"]];
    }
    else{
        [imgViewBranchATMStatus setImage:[UIImage imageNamed:@"not_available"]];
    }

    // hiding update bar and showing other content related to view
    [branchUpdateContainer setHidden:YES];
    [branchDetailIconContainer setHidden:NO];
    [branchDetailIconContainer setAlpha:0.0];
    [prevSelectedImgView setHidden:YES];
    
    
    // branch details
    UIButton *btnViewback = (UIButton *)[branchDetailContainer viewWithTag:10];
    UILabel *lblBranchName = (UILabel *)[branchDetailContainer viewWithTag:20];
    UILabel *lblBranchAddress = (UILabel *)[branchDetailContainer viewWithTag:30];
    
    [lblBranchName setText:[selectedBranch valueForKey:BRANCH_NAME]];
    [lblBranchAddress setText:[NSString stringWithFormat:@"%@\n%@"
                               , [selectedBranch valueForKey:BRANCH_ADDRESS]
                               , [selectedBranch valueForKey:BRANCH_OPERATING_HOUR] ] ];

    [btnViewback setHidden:NO];
    [lblBranchName setHidden:NO];
    [lblBranchAddress setHidden:NO];
    [btnViewback setAlpha:0.0];
    [lblBranchName setAlpha:0.0];
    [lblBranchAddress setAlpha:0.0];
    
    [UIView animateWithDuration:2.0
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         [branchDetailIconContainer setAlpha:1.0];
                         [btnViewback setAlpha:1.0];
                         [lblBranchName setAlpha:1.0];
                         [lblBranchAddress setAlpha:1.0];
                         
                     }
                     completion:^(BOOL finished) {
                     }];
    
    
    CGRect toFrame = CGRectMake(85, 55, 150, 150);
    [UIView transitionFromView:branchListContainer
                        toView:branchDetailContainer
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionShowHideTransitionViews
                    completion:^(BOOL finished) {
                        
                        [branchDetailContainer addSubview:imgViewBranch];
                        [UIView animateWithDuration:1.0 animations:^{
                            
                            imgViewBranch.frame = toFrame;
                            [[self navigationController] setNavigationBarHidden:YES animated:YES];
                            
                        } completion:^(BOOL finished) {
                            
                            // showing ATM avalablity
                            [branchDetailContainer addSubview:imgViewBranchATMStatus];
                            [imgViewBranchATMStatus setAlpha:0.0];
                            
                            [UIView animateWithDuration:0.5
                                                  delay:0.0
                                                options:UIViewAnimationOptionTransitionNone
                                             animations:^{
                                                 
                                                 [imgViewBranchATMStatus setAlpha:1.0];
                                             }
                                             completion:^(BOOL finished) {
                                             }];
                        }];
                        
                    } ];
}

- (void) showBranchListFromDetail {
    
    CGRect toFrame = moveFrame;
    
    // hiding detail icon bar

    [branchUpdateContainer setHidden:NO];
    [branchUpdateContainer setAlpha:0.0];
    
    [UIView animateWithDuration:1.5
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         [branchDetailIconContainer setAlpha:0.0];
                         [branchUpdateContainer setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                        [branchDetailIconContainer setHidden:YES];
                     }];

    [[branchDetailContainer viewWithTag:10] setHidden:YES];
    [[branchDetailContainer viewWithTag:20] setHidden:YES];
    [[branchDetailContainer viewWithTag:30] setHidden:YES];

    [imgViewBranchATMStatus removeFromSuperview];
    
    [self.view addSubview:imgViewBranch];
    [UIView transitionFromView:branchDetailContainer
                        toView:branchListContainer
                      duration:0.6
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionShowHideTransitionViews
                    completion:^(BOOL finished) {
                        
                        [UIView animateWithDuration:0.7 animations:^{
                            
                            imgViewBranch.frame = toFrame;
                            [[self navigationController] setNavigationBarHidden:NO animated:YES];
                            
                        } completion:^(BOOL finished) {
                            
                            [prevSelectedImgView setHidden:NO];
                            [prevSelectedImgView setAlpha:0.0];
                            [UIView animateWithDuration:0.4
                                                  delay:0.0
                                                options:UIViewAnimationOptionTransitionNone
                                             animations:^{
                                                 
                                                 [prevSelectedImgView setAlpha:1.0];
                                             }
                                             completion:^(BOOL finished) {
                                             }];

                            [imgViewBranch removeFromSuperview];
                        }];
                        
                    } ];
    
}

@end
