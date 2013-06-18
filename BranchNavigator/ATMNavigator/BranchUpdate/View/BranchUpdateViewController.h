//
//  BranchUpdateViewController.h
//  ATMNavigator
//
//  Created by goodcore2 on 5/3/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// third party
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "PPRevealSideViewController.h"


// other controllers
#import "CustomWebViewController.h"

// custom classes
#import "ApplicationConstants.h"
#import "Custombutton.h"

@interface BranchUpdateViewController : UIViewController <SocketIODelegate, UITableViewDataSource, UITableViewDelegate>
{
}


@property (strong, nonatomic) UITableView  *tblBranchUpdate;
@property (strong, nonatomic) NSMutableArray  *actualData;
@property (strong, nonatomic) UIView *branchUpdateContainer;


@property (nonatomic) BOOL isViewActive;

@end
