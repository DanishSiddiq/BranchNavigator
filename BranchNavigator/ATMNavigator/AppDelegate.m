//
//  AppDelegate.m
//  ATMNavigator
//
//  Created by goodcore2 on 5/2/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import "AppDelegate.h"

#import "BranchListViewController.h"

@implementation AppDelegate

@synthesize revealSideViewController = _revealSideViewController;
@synthesize isAppStarted;
@synthesize locationManager, latestLocation, isLocationUpdated;
@synthesize hostReach, isNetworkAvailable;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self initializeCustomClasses];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    BranchListViewController *branchListViewController = [[BranchListViewController alloc] initWithNibName:@"BranchListViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:branchListViewController];
    _revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:nav];
    
    _revealSideViewController.delegate = self;
    
    self.window.rootViewController = _revealSideViewController;
    
    // Uncomment if you want to test (yeah that's not pretty) the PPReveal deallocating
    //[self performSelector:@selector(unloadRevealFromMemory) withObject:nil afterDelay:3.0];
    
    PP_RELEASE(branchListViewController);
    PP_RELEASE(nav);

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    // setting SDWebImageManager with out query string
    [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url)
     {
         if(url && url.scheme && url.host){
             url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
             return [url absoluteString];
         }
         return  @"";
     }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Initialization code
- (void) initializeCustomClasses {
    
    isAppStarted = YES;
    
    // reach ability
    isNetworkAvailable = YES;
    hostReach = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(internetAvailabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object: nil];
    [hostReach startNotifier];
    [self internetAvailabilityChanged: self];
    
    
    //location
    [self initializeLocationTracker];
    
}

- (void) initializeLocationTracker{
    
    // Start off with best tracking and Locations class will adjust as needed
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate         = self;
    locationManager.desiredAccuracy  = kCLLocationAccuracyBest;
    locationManager.distanceFilter   = 10;
    [locationManager startUpdatingLocation];
    [self controlTracking:YES];
}

- (void)controlTracking: (BOOL) on {
    
    if(on){
        isLocationUpdated = NO;
        [locationManager startUpdatingLocation];
    }
    else{
        
        [locationManager stopUpdatingLocation];
    }
    
}

#pragma mark - LocationManager delegate
- (void) locationManager: (CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    latestLocation = [locations objectAtIndex:0];    
    
    [self saveLocation];
    
    // once get update then disable it
    [self controlTracking:NO ];
    isLocationUpdated = YES;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    // once get update then disable it
    [self controlTracking:NO ];
    isLocationUpdated = NO;
}

- (void) saveLocation {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setObject:latestLocation forKey:USER_DEFAULT_LOCATION_COORDINATE];
    [userDefault synchronize];
}

#pragma mark - Reachibility delegate
- (void) internetAvailabilityChanged: (id) sender {
    
    Reachability *connectionMonitor = [Reachability reachabilityForInternetConnection];
    BOOL hasInternet = [connectionMonitor currentReachabilityStatus] != NotReachable;
    
    if (hasInternet){
        
        // if previously network was not connected
        if(!isNetworkAvailable){
            
            GRAlertView *alertView = [[GRAlertView alloc] initWithTitle:@"Network Connected"
                                                                message:@""
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            alertView.style = GRAlertStyleSuccess;
            [alertView show];
            
            
            [[NSNotificationCenter defaultCenter]   postNotificationName:NOTIFICATION_NETWORK_DISCONNECTED object:nil];
        }
    }
    else{
        
        // if previously network was available
        if(isNetworkAvailable){
            
            GRAlertView *alertView = [[GRAlertView alloc] initWithTitle:@"Cannot connect to network"
                                                                message:@""
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            alertView.style = GRAlertStyleWarning;
            [alertView show];
        }
    }
    
    isNetworkAvailable = hasInternet;
}



#pragma mark - PPRevealSideViewController delegate
- (void) pprevealSideViewController:(PPRevealSideViewController *)controller willPushController:(UIViewController *)pushedController {
    PPRSLog(@"%@", pushedController);
}

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didPushController:(UIViewController *)pushedController {
    PPRSLog(@"%@", pushedController);
}

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller willPopToController:(UIViewController *)centerController {
    PPRSLog(@"%@", centerController);
}

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController {
    PPRSLog(@"%@", centerController);
}

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didChangeCenterController:(UIViewController *)newCenterController {
    PPRSLog(@"%@", newCenterController);
}

- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateDirectionGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view {
    return NO;
}

- (PPRevealSideDirection)pprevealSideViewController:(PPRevealSideViewController*)controller directionsAllowedForPanningOnView:(UIView*)view {
    
    if ([view isKindOfClass:NSClassFromString(@"UIWebBrowserView")]) return PPRevealSideDirectionLeft | PPRevealSideDirectionRight;
    
    return PPRevealSideDirectionLeft | PPRevealSideDirectionRight | PPRevealSideDirectionTop | PPRevealSideDirectionBottom;
}


@end
