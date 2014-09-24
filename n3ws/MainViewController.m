//
//  MainViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "MainViewController.h"
#import <SWRevealViewController.h>
#import "Instagram.h"

@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureBarButtonItemAbility];
    [self configureInstagram];
}

-(void)configureBarButtonItemAbility
{
    SWRevealViewController *revealVC = self.revealViewController;
    
    if (revealVC)
    {
        [self.menuBarButtonItem setTarget:self.revealViewController];
        [self.menuBarButtonItem setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)configureInstagram
{
    Instagram *instagram = [Instagram new];
    
    [instagram accessingInstagram];
}




@end
