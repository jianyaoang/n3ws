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

    self.menuTitles = [NSArray new];
    [self settingUpMenuTable];
}

-(void)settingUpMenuTable
{
    self.menuTitles = @[@"Home",@"Headlines", @"Finance", @"Entertainment", @"Sports"];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    return cell;
    
//    static NSString *cellID = @"MenuCell";
//    
//    switch (indexPath.row)
//    {
//        case 0:
//            cellID = @"Headlines";
//            break;
//        case 1:
//            cellID = @"Finance";
//            break;
//        case 2:
//            cellID = @"Entertainment";
//            break;
//        case 3:
//            cellID = @"Sports";
//            break;
//        default:
//            break;
//    }
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
//    
//    if ([cellID isEqualToString:@"Headlines"])
//    {
//        cell.textLabel.text = @"Headlines";
//    }
//    else if ([cellID isEqualToString:@"Finance"])
//    {
//        cell.textLabel.text = @"Finance";
//    }
//    else if ([cellID isEqualToString:@"Entertainment"])
//    {
//        cell.textLabel.text = @"Entertainment";
//    }
//    else if ([cellID isEqualToString:@"Sports"])
//    {
//        cell.textLabel.text = @"Sports";
//    }
//    
//    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [self.menuTitles objectAtIndex:indexPath.row];
    
    
//    UINavigationController *navigationController = segue.destinationViewController;
//    
//    HeadlinesViewController *hvc = [navigationController childViewControllers].firstObject;
//    
//    if ([hvc isKindOfClass:[HeadlinesViewController class]])
//    {
//        hvc.title = @"Headlines";
//    }
   
    
//        if ([viewController isKindOfClass:[HeadlinesViewController class]])
//        {
//            HeadlinesViewController *hvc = (HeadlinesViewController*)viewController;
//            hvc.title = @"Headlines";
//            [self.navigationController popToViewController:hvc animated:YES];
//        }
//        else if ([viewController isKindOfClass:[MainViewController class]])
//        {
//            MainViewController *mvc = (MainViewController*)viewController;
//            mvc.title = @"N3ws";
//            [self.navigationController popToViewController:mvc animated:YES];
//        }
}

@end
