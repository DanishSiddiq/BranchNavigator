//
//  BranchUpdateViewController.m
//  ATMNavigator
//
//  Created by goodcore2 on 5/3/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import "BranchUpdateViewController.h"

@interface BranchUpdateViewController ()

@end

@implementation BranchUpdateViewController

@synthesize actualData, tblBranchUpdate;
@synthesize branchUpdateContainer;
@synthesize isViewActive;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        actualData = [[NSMutableArray alloc] init];
        
        if([defaults objectForKey:USER_DEFAULT_BRANCH_UPDATES]){
            
            [actualData addObjectsFromArray:[defaults objectForKey:USER_DEFAULT_BRANCH_UPDATES]];
        }
        
        [self initializeBranchUpdateTable];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    isViewActive = NO;
}


-(void) viewWillAppear:(BOOL)animated{
    
    isViewActive = YES;
    
    UIButton *btnBranchUpdate = (UIButton *)[branchUpdateContainer viewWithTag:10];
    [btnBranchUpdate.layer removeAllAnimations];
    [btnBranchUpdate setAlpha:1.0];
}

- (void) viewWillDisappear:(BOOL)animated{
    
    isViewActive = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary *dictData = [packet dataAsJSON];
    [self updateView : dictData];
    
    if(!isViewActive){
        
        UIButton *btnBranchUpdate = (UIButton *)[branchUpdateContainer viewWithTag:10];
        [self blurAnimation:btnBranchUpdate];
    }
}

- (void) socketIO:(SocketIO *)socket failedToConnectWithError:(NSError *)error
{
    NSLog(@"failedToConnectWithError() %@", error);
}


/////////////////// VIEW SUPPORTED METHODS //////////////////
- (void) initializeBranchUpdateTable {
    
    tblBranchUpdate = [[UITableView alloc] initWithFrame:CGRectMake(0
                                                                    , 67
                                                                    , [UIScreen mainScreen].bounds.size.width
                                                                    , [UIScreen mainScreen].bounds.size.height-87)];
    [tblBranchUpdate setBackgroundColor:[UIColor whiteColor]];
    tblBranchUpdate.dataSource = self;
    tblBranchUpdate.delegate = self;
    [self.view addSubview:tblBranchUpdate];
    
}


- (void) updateView : (NSDictionary *) dictData{
    
    if([dictData count] > 0){
        
        // Insert the objects at the first positions in the rows array
        [actualData insertObject:dictData atIndex:0];
    
        NSArray *insertIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        [tblBranchUpdate insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    
        // persisting data at device for next time use aftet terminating app
        [self saveData];
    }
}


- (void) saveData {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setObject:actualData forKey:USER_DEFAULT_BRANCH_UPDATES];
    [userDefault synchronize];
}

///// Tbale view deleagtes

// UITABLEVIEW DELEGATES TO HANDLE DISPLAY OF REPEATING SECTION
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [actualData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
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
    UIView *parentView;
    UILabel *lblNews;
    Custombutton *btnURL;
    cell = [tableView dequeueReusableCellWithIdentifier:branchCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:branchCellIdentifier];
        [cell setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70)];
        [cell setBackgroundColor:[UIColor whiteColor]];
        

        CGRect parentFrame = cell.frame;
        parentFrame.size.height = 69;
        
        parentView = [[UIView alloc] initWithFrame:parentFrame];
        parentView.tag = 10;
        
        lblNews = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, 304, 35)];
        lblNews.numberOfLines = 2;
        [lblNews setBackgroundColor:[UIColor clearColor]];
        lblNews.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        [lblNews setTextColor:[UIColor colorWithRed:144/225.f green:144/225.f blue:144/225.f alpha:1.0]];
        lblNews.contentMode = UIViewContentModeBottomLeft;
        [lblNews setLineBreakMode:NSLineBreakByTruncatingTail];
        [lblNews adjustsFontSizeToFitWidth];
        lblNews.tag = 20;
        
        btnURL = [[Custombutton alloc] initWithFrame:CGRectMake(8, 40, 304, 20)];
        [btnURL setBackgroundColor:[UIColor clearColor]];
        btnURL.contentMode = UIViewContentModeTopLeft;
        [[btnURL titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
        [btnURL setTitleColor:[UIColor colorWithRed:64/255.0 green:143/255.0 blue:174/255.0 alpha:1.0]
                     forState:UIControlStateNormal & UIControlStateSelected];
        [btnURL addTarget:self action:@selector(btnPressedURL:) forControlEvents:UIControlEventTouchUpInside];
        btnURL.tag = 20;
        
        [parentView addSubview:lblNews];
        [parentView addSubview:btnURL];
        
        [cell.contentView addSubview:parentView];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else{
        
        lblNews = (UILabel *)[[cell.contentView viewWithTag:10] viewWithTag:20];
        btnURL  = (Custombutton *)[[cell.contentView viewWithTag:20] viewWithTag:30];
    }
    
    NSMutableDictionary *news = [actualData objectAtIndex:indexPath.row];
    
    lblNews.text = [[[news valueForKey:BRANCH_UPDATE] valueForKey:BRANCH_UPDATE_NEWS] objectAtIndex:0];;

    if([[[news valueForKey:BRANCH_UPDATE] valueForKey:BRANCH_UPDATE_URL] count] > 0){
        [btnURL setTitle:[[[news valueForKey:BRANCH_UPDATE] valueForKey:BRANCH_UPDATE_URL] objectAtIndex:0]
                forState:UIControlStateNormal & UIControlStateSelected];
        btnURL.rowIndex = indexPath.row;
        btnURL.url = [[[news valueForKey:BRANCH_UPDATE] valueForKey:BRANCH_UPDATE_URL] objectAtIndex:0];
        [btnURL setHidden:NO];
    }
    else{
        [btnURL setHidden:YES];
    }
    
    
    CGRect toFrame = parentView.frame;
    [parentView setFrame:CGRectMake(0, 70, [UIScreen mainScreen].bounds.size.width, 0)];
    [UIView animateWithDuration:1.5 animations:^{
        
        [parentView setFrame:toFrame];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (void) btnPressedURL : (Custombutton *) sender{
    
    CustomWebViewController *webViewController = [[CustomWebViewController alloc] initWithNibName:@"CustomWebViewController" bundle:nil];
    [webViewController setWebAddress:[sender url]];
    
    [self.revealSideViewController pushViewController:webViewController
                                          onDirection:PPRevealSideDirectionRight
                                           withOffset:20.0f
                                             animated:YES completion:^{
                                                 PPRSLog(@"This is the end!");
                                             }];
    
}


// aniamtion code
// 360
- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    
    // only attach animation. if not atatched earlier
    if([[view.layer animationKeys] count] == 0){
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * rotations * duration ];
        rotationAnimation.duration = duration;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = repeat;
        
        [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}

- (void)shakeView:(UIView *)viewToShake
{
    // only attach animation. if not atatched earlier
    if([[viewToShake.layer animationKeys] count] == 0){
        
        CGFloat t = 2.0;
        CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
        CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);
        
        viewToShake.transform = translateLeft;
        
        [UIView animateWithDuration:0.07
                              delay:0.0
                            options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat
                         animations:^{
                             [UIView setAnimationRepeatCount:HUGE_VALF];
                             viewToShake.transform = translateRight;
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 
                                 [UIView animateWithDuration:0.05
                                                       delay:0.0
                                                     options:UIViewAnimationOptionBeginFromCurrentState
                                                  animations:^{
                                                      
                                                      viewToShake.transform = CGAffineTransformIdentity;
                                                  }
                                                  completion:NULL];
                             }
                         }];
    }
}

- (void) blurAnimation : (UIView *) blurView{
    
    // only attach animation. if not atatched earlier
    if([[blurView.layer animationKeys] count] == 0){
    
        [UIView animateWithDuration:3.0
                              delay:0.0
                            options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat
                         animations:^{
                             [UIView setAnimationRepeatCount:HUGE_VALF];
                                 [blurView setAlpha:0.5];
                         }
                         completion:^(BOOL finished) {

                         }];
    }
}

@end
