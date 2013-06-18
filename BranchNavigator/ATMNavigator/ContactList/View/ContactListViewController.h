//
//  ContactListViewController.h
//  ATMNavigator
//
//  Created by goodcore2 on 5/3/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

// custom
#import "ApplicationConstants.h"
#import "Custombutton.h"

@interface ContactListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate
                                                        , MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) UITableView  *tblContactList;
@property (strong, nonatomic) NSMutableArray  *actualData;
@property (strong, nonatomic) NSMutableArray  *loadData;
@property (nonatomic) NSInteger  indexData;

@property (strong, nonatomic) NSTimer *timerBranchList;


// fancy work for showing ui
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end
