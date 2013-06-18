//
//  ContactListViewController.m
//  ATMNavigator
//
//  Created by goodcore2 on 5/3/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import "ContactListViewController.h"

@interface ContactListViewController ()

@end

@implementation ContactListViewController

@synthesize tblContactList;
@synthesize actualData, loadData;
@synthesize timerBranchList, indexData;
@synthesize selectedIndexPath;

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
    
    [self.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    loadData = [[NSMutableArray alloc] init];
    indexData = 0;
    selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
    
    [self initializeTableList ];
    [self updateTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////   VIEW SUPPORTED METHODS
- (void) initializeTableList{
    
    tblContactList = [[UITableView alloc] initWithFrame:CGRectMake(0
                                                                   , 0
                                                                   , [UIScreen mainScreen].bounds.size.width
                                                                   , [UIScreen mainScreen].bounds.size.height)];
    [tblContactList setBackgroundColor:[UIColor whiteColor]];
    tblContactList.dataSource = self;
    tblContactList.delegate = self;
    
    [self.view addSubview:tblContactList];
}



- (void) updateTable {
    
    [loadData removeAllObjects];
    [tblContactList reloadData];
    timerBranchList = [NSTimer scheduledTimerWithTimeInterval:0.15f target:self selector:@selector(performTableUpdates:)
                                                     userInfo:nil
                                                      repeats:YES];
    
}
-(void)performTableUpdates:(NSTimer*)timer
{
    
    [self.view setUserInteractionEnabled:NO];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexData inSection:0];
    
    [loadData addObject:[actualData objectAtIndex:indexData]];
    [tblContactList beginUpdates];
    [tblContactList insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [tblContactList endUpdates];
    
    if(indexData < [actualData count])
    {
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


// UITABLEVIEW DELEGATES TO HANDLE DISPLAY OF REPEATING SECTION
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [loadData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 48.0;
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
    UILabel *lblDesignation, *lblName;
    Custombutton *btnCall, *btnMessage, *btnMail;
    UIImageView *bckGroundImage;
    cell = [tableView dequeueReusableCellWithIdentifier:branchCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:branchCellIdentifier];
        [cell setFrame:CGRectMake(0
                                  , 0
                                  , [UIScreen mainScreen].bounds.size.width
                                  , 48)];
        
        bckGroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 48)];
        [bckGroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [bckGroundImage setClipsToBounds:YES];
        [bckGroundImage setTag:100];
        [bckGroundImage setUserInteractionEnabled:NO];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, [UIScreen mainScreen].bounds.size.width -52, 20)];
        lblName.numberOfLines = 1;
        [lblName setBackgroundColor:[UIColor clearColor]];
        lblName.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        [lblName setTextColor:[UIColor darkGrayColor]];
        lblName.contentMode = UIViewContentModeTopLeft;
        [lblName setLineBreakMode:NSLineBreakByTruncatingTail];
        [lblName adjustsFontSizeToFitWidth];
        lblName.tag = 10;
        
        lblDesignation = [[UILabel alloc] initWithFrame:CGRectMake(8, 27, [UIScreen mainScreen].bounds.size.width -52, 16)];
        [lblDesignation setBackgroundColor:[UIColor clearColor]];
        [lblDesignation setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        lblDesignation.contentMode = UIViewContentModeTopLeft;
        [lblDesignation setTextAlignment:NSTextAlignmentLeft];
        [lblDesignation setLineBreakMode:NSLineBreakByTruncatingTail];
        [lblDesignation setTextColor:[UIColor grayColor]];
        [lblDesignation adjustsFontSizeToFitWidth];
        lblDesignation.tag = 20;
        
        btnCall = [[Custombutton alloc] initWithFrame:CGRectMake(65, 10, 30, 30)];
        [btnCall addTarget:self action:@selector(btnPressedCall:) forControlEvents:UIControlEventTouchUpInside];
        [btnCall setBackgroundImage:[UIImage imageNamed:@"icon_call" ] forState:UIControlStateNormal & UIControlStateSelected];
        [btnCall setUserInteractionEnabled:YES];
        btnCall.rowIndex = indexPath.row;
        [btnCall setHidden:YES];
        btnCall.tag = 30;
        
        btnMessage = [[Custombutton alloc] initWithFrame:CGRectMake(120, 10, 30, 30)];
        [btnMessage addTarget:self action:@selector(btnPressedMessage:) forControlEvents:UIControlEventTouchUpInside];
        [btnMessage setBackgroundImage:[UIImage imageNamed:@"icon_sms" ] forState:UIControlStateNormal & UIControlStateSelected];
        [btnMessage setUserInteractionEnabled:YES];
        btnMessage.rowIndex = indexPath.row;
        [btnMessage setHidden:YES];
        btnMessage.tag = 40;
        
        btnMail = [[Custombutton alloc] initWithFrame:CGRectMake(185, 10, 30, 30)];
        [btnMail addTarget:self action:@selector(btnPressedMail:) forControlEvents:UIControlEventTouchUpInside];
        [btnMail setBackgroundImage:[UIImage imageNamed:@"icon_mail" ] forState:UIControlStateNormal & UIControlStateSelected];
        [btnMail setUserInteractionEnabled:YES];
        btnMail.rowIndex = indexPath.row;
        [btnMail setHidden:YES];
        btnMail.tag = 50;
        
        [cell.contentView addSubview:bckGroundImage];
        [cell.contentView addSubview:lblDesignation];
        [cell.contentView addSubview:lblName];
        [cell.contentView addSubview:btnCall];
        [cell.contentView addSubview:btnMessage];
        [cell.contentView addSubview:btnMail];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else{
        
        lblName         = (UILabel *)[cell.contentView viewWithTag:10];
        lblDesignation  = (UILabel *)[cell.contentView viewWithTag:20];
        btnCall         = (Custombutton *)[cell.contentView viewWithTag:30];
        btnMessage      = (Custombutton *)[cell.contentView viewWithTag:40];
        btnMail         = (Custombutton *)[cell.contentView viewWithTag:50];
        
        
        bckGroundImage = (UIImageView *)[cell.contentView viewWithTag:100];
    }
    
    NSMutableDictionary *currBranch = [loadData objectAtIndex:indexPath.row];
    
    lblName.text = [currBranch valueForKey:BRANCH_CONTACT_NAME];
    lblDesignation.text = [currBranch valueForKey:BRANCH_CONTACT_DESIGNATION];
    btnCall.rowIndex = indexPath.row;
    btnMessage.rowIndex = indexPath.row;
    btnMail.rowIndex = indexPath.row;
    
    
    if(indexPath.row % 2 == 0){
        [bckGroundImage setImage:[UIImage imageNamed:@"row_odd"]];
    }
    else{
        [bckGroundImage setImage:[UIImage imageNamed:@"row_even"]];
    }    
    
    if ((selectedIndexPath != nil) && (selectedIndexPath.row == indexPath.row)){
        
        [lblName  setHidden:YES];
        [lblDesignation  setHidden:YES];

        [btnCall setHidden:NO];
        [btnMessage setHidden:NO];
        [btnMail setHidden:NO];
    }
    else{
        
        [lblName  setHidden:NO];
        [lblDesignation  setHidden:NO];
        
        [btnCall setHidden:YES];
        [btnMessage setHidden:YES];
        [btnMail setHidden:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (selectedIndexPath.row == indexPath.row) {
        
        selectedIndexPath = nil;
        [tblContactList reloadData];
    } else {
        
        selectedIndexPath = indexPath;
        [tblContactList reloadData];
        [tblContactList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// button selectors
- (void) btnPressedCall : (Custombutton *) sender{

    
    NSString *phoneNumber = [[loadData objectAtIndex:[sender rowIndex]] valueForKey:BRANCH_CONTACT_NUMBER];
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", cleanedString]]];
}

- (void) btnPressedMessage : (Custombutton *) sender{
    
    if([MFMessageComposeViewController canSendText])
    {
        
        NSString *phoneNumber = [[loadData objectAtIndex:[sender rowIndex]] valueForKey:BRANCH_CONTACT_NUMBER];
        NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
        
        MFMessageComposeViewController *messenger = [[MFMessageComposeViewController alloc] init];
        
        //1(234)567-8910
        messenger.recipients = [NSArray arrayWithObjects:cleanedString, nil];
        messenger.messageComposeDelegate = self;
        [self presentViewController:messenger animated:YES completion:nil];
    }
}

- (void) btnPressedMail : (Custombutton *) sender{
 
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        [mailer setSubject:@" "];
        mailer.mailComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObjects:[[loadData objectAtIndex:[sender rowIndex]] valueForKey:BRANCH_CONTACT_MAIL], nil];
        [mailer setToRecipients:toRecipients];
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        mailer.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIColor blackColor]
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


// mail controller delegates
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
