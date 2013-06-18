//
//  AppDelegate.h
//  ATMNavigator
//
//  Created by goodcore2 on 5/2/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import <UIKit/UIKit.h>

// custom libraries
#import "PPRevealSideViewController.h"
#import "SDWebImageManager.h"
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>
#import "GRAlertView.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, PPRevealSideViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PPRevealSideViewController *revealSideViewController;


// reachabaility
@property (nonatomic, retain) Reachability *hostReach;
@property (nonatomic) BOOL isNetworkAvailable;

//location
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *latestLocation;
@property (nonatomic) BOOL isLocationUpdated;
- (void)controlTracking: (BOOL) on;

// first time loading
@property (nonatomic) BOOL isAppStarted;

@end
