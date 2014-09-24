//
//  SportsViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "SportsViewController.h"
#import <SWRevealViewController.h>

@interface SportsViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;

@end

@implementation SportsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureBarButtonItemAbility];
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


@end
