//
//  WebNewsViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/30/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "WebNewsViewController.h"

@interface WebNewsViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *newsWebView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSURLRequest *request;
@end

@implementation WebNewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNewsWebView];
}

#pragma mark - configure news webview
-(void)configureNewsWebView
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@",self.news.web_url];
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


@end
