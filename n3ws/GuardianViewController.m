//
//  GuardianViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 10/11/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "GuardianViewController.h"

@interface GuardianViewController () <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *guardianWebView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation GuardianViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self settingNavigationTitle];
    [self configureWebView];

}

#pragma mark - navigation title
-(void)settingNavigationTitle
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"n3ws";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:25];
    [self.navigationItem setTitleView:titleLabel];
}

#pragma mark - guardian web
-(void)configureWebView
{
    NSURL *url = [NSURL URLWithString:@"http://www.theguardian.com/uk"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.guardianWebView loadRequest:request];
    });
}


-(void)webViewDidStartLoad:(UIWebView *)webView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
    });
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error)
    {
        NSLog(@"guardian web view error:%@", error);
    }
    else
    {
        NSLog(@"guardian web view loaded");
    }
}



@end
