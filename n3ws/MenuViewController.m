//
//  MenuViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"MenuCell";
    
    switch (indexPath.row)
    {
        case 0:
            cellID = @"Headlines";
            break;
        case 1:
            cellID = @"Finance";
            break;
        case 2:
            cellID = @"Entertainment";
            break;
        case 3:
            cellID = @"Sports";
            break;
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
    
    if ([cellID isEqualToString:@"Headlines"])
    {
        cell.textLabel.text = @"Headlines";
    }
    else if ([cellID isEqualToString:@"Finance"])
    {
        cell.textLabel.text = @"Finance";
    }
    else if ([cellID isEqualToString:@"Entertainment"])
    {
        cell.textLabel.text = @"Entertainment";
    }
    else if ([cellID isEqualToString:@"Sports"])
    {
        cell.textLabel.text = @"Sports";
    }
    
    return cell;
}
@end
