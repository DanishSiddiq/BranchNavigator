//
//  BranchListViewController.h
//  ATMNavigator
//
//  Created by goodcore2 on 5/2/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

// custom controls
#import "PPRevealSideViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+AH3DPullRefresh.h"
#import "KGModal.h"
#import "GRAlertView.h"
#import "SVProgressHUD.h"

// application
#import "AppDelegate.h"
#import "BranchUpdateViewController.h"
#import "ContactListViewController.h"
#import "CustomImageView.h"
#import "ApplicationConstants.h"
#import "CustomAnnotation.h"
#import "ZoomedMapView.h"
#import "CustomWebViewController.h"

@interface BranchListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    SocketIO *socketIO;
}


@property (strong, nonatomic) AppDelegate *atmNavigatorDelegate;
@property (strong, nonatomic) BranchUpdateViewController  *branchUpdateViewController;

@property (strong, nonatomic) NSMutableArray  *preDefinedLocations;
@property (strong, nonatomic) NSMutableArray  *actualData;
@property (strong, nonatomic) NSMutableArray  *loadData;
@property (nonatomic) NSInteger  indexData;


@property (strong, nonatomic) UIView *navBarContainer;

@property (strong, nonatomic) UIView *branchListContainer;
@property (strong, nonatomic) UITableView  *tblBranchList;
@property (strong, nonatomic) MKMapView  *mapBranchList;
@property (strong, nonatomic) NSTimer *timerBranchList;

@property (strong, nonatomic) UIView *branchDetailContainer;

@property (strong, nonatomic) UIView *branchUpdateContainer;
@property (strong, nonatomic) UIView *branchDetailIconContainer;

// branch animated image
@property (strong, nonatomic) CustomImageView *imgViewBranch;
@property (strong, nonatomic) CustomImageView *prevSelectedImgView;
@property (strong, nonatomic) UIImageView *imgViewBranchATMStatus;
@property (nonatomic) CGRect moveFrame;


@property (strong, nonatomic) UIImageView *topImageView;
@property (strong, nonatomic) UIImageView *bottomImageView;

@end
