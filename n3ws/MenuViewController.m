//
//  MenuViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "MenuViewController.h"
#import "HeadlinesViewController.h"
#import "MainViewController.h"
#import "Instagram.h"
#import "Section.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) Instagram *instagram;
@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic) Section *section;
@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidemenu"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    self.section = [Section new];

    self.menuTitles = [NSArray new];
    
    [self settingUpMenuTable];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - menu table
-(void)settingUpMenuTable
{
    self.menuTitles = @[@"Home", @"Headlines", @"Entertainment", @"Food", @"Travel"];
    
    self.tableView.backgroundColor = [UIColor clearColor];
//    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidemenu"]]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.separatorColor = [UIColor clearColor];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuTitles.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [self.menuTitles objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.textLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:22];
    cell.textLabel.textColor = [UIColor colorWithRed:0.19 green:0.19 blue:0.19 alpha:1];
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:0.12 green:0.63 blue:0.87 alpha:1];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    self.section.sectionName = [self.menuTitles objectAtIndex:indexPath.row];
    UINavigationController *nav = segue.destinationViewController;
    HeadlinesViewController *hvc = [HeadlinesViewController new];
    
    if ([segue.identifier isEqualToString:@"Headlines"])
    {
        if ([self.section.sectionName isEqualToString:@"Headlines"])
        {
            hvc = nav.viewControllers[0];
            
            hvc.section = self.section;
        }
    }
    else if ([segue.identifier isEqualToString:@"Entertainment"])
    {
        if ([self.section.sectionName isEqualToString:@"Entertainment"])
        {
            hvc = nav.viewControllers[0];
            
            hvc.section = self.section;
        }
    }
    else if ([segue.identifier isEqualToString:@"Food"])
    {
        if ([self.section.sectionName isEqualToString:@"Food"])
        {
            hvc = nav.viewControllers[0];
            
            hvc.section = self.section;
        }
    }
    else if ([segue.identifier isEqualToString:@"Travel"])
    {
        if ([self.section.sectionName isEqualToString:@"Travel"])
        {
            hvc = nav.viewControllers[0];
            
            hvc.section = self.section;
        }
    }
}

@end
