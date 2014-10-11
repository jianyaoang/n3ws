//
//  WebNewsViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/30/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "WebNewsViewController.h"

@interface WebNewsViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *guardianButton;
@property (strong, nonatomic) IBOutlet UIWebView *newsWebView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSURLRequest *request;
@end

@implementation WebNewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNewsWebView];
    [self settingNavigationTitle];
    [self configureGuardianButtonImage];
}

#pragma mark - navigation Title
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

#pragma mark - configure news webview
-(void)configureNewsWebView
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@",self.news.webUrl];
        NSURL *newsURL = [NSURL URLWithString:urlString];
        self.request = [NSURLRequest requestWithURL:newsURL];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.newsWebView loadRequest:self.request];
    });
}

#pragma mark - webview delegate
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
        NSLog(@"error :: %@",error);
    }
    else
    {
        NSLog(@"news web loaded");
    }

}

#pragma mark - setting guardian button image
-(void)configureGuardianButtonImage
{
    UIImage *guardianButtonImage = [UIImage imageNamed:@"guardianBlack"];
    [self.guardianButton setImage:guardianButtonImage forState:UIControlStateNormal];
}

@end
