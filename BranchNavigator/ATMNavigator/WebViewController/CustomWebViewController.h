//
//  CustomWebViewController.h
//  ATMNavigator
//
//  Created by goodcore2 on 5/9/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPRevealSideViewController.h"

@interface CustomWebViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *webAddress;



@end
