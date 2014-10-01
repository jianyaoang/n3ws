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

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *menuTitles;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    self.menuTitles = [NSArray new];
    
    [self settingUpMenuTable];
}

-(void)settingUpMenuTable
{
    self.menuTitles = @[@"Home", @"Headlines", @"Entertainment", @"Food", @"Travel"];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
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
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = [UIColor purpleColor];
    
    cell.backgroundColor = [UIColor blackColor];
    cell.contentView.backgroundColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    UINavigationController *destinationVC = (UINavigationController*)segue.destinationViewController;
    
    destinationVC.title = [self.menuTitles objectAtIndex:indexPath.row];
}

@end
