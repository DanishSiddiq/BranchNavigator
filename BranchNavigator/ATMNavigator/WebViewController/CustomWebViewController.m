//
//  CustomWebViewController.m
//  ATMNavigator
//
//  Created by goodcore2 on 5/9/13.
//  Copyright (c) 2013 Postnik. All rights reserved.
//

#import "CustomWebViewController.h"

@interface CustomWebViewController ()

@end

@implementation CustomWebViewController

@synthesize webView, webAddress;

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
    
    [self.view setFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
    [webView setFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
    
    [self renderWebView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) renderWebView {
    
    NSURL *url = [NSURL URLWithString:webAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

@end
