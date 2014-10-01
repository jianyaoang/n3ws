//
//  HeadlinesViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "HeadlinesViewController.h"
#import <SWRevealViewController.h>

@interface HeadlinesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (strong, nonatomic) IBOutlet UITableView *instagramTableView;
@property (strong, nonatomic) UIImage *cellBackgroundImage;

@end

@implementation HeadlinesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureBarButtonItemAbility];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.instagramTableView setSeparatorColor:[UIColor blackColor]];
        [self.instagramTableView reloadData];
    });
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

#pragma mark - table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.instagramAccountsMutableArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.instagram = [self.instagramAccountsMutableArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstagramInfoCell"];

    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.instagram.imagesURL]]]];
    cell.textLabel.text = [NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n@%@",self.instagram.username];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:25];
    cell.textLabel.numberOfLines = 0;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.instagram.caption];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.75];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Instagram *instagramAccount = [self.instagramAccountsMutableArray objectAtIndex:indexPath.row];
    NSString *caption = instagramAccount.caption;
    CGFloat width = 320;
    UIFont *font = [UIFont systemFontOfSize:14];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:caption attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width,CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    rect = CGRectInset(rect, -320, -210);
    CGSize size = rect.size;
    return size.height;
    
}



@end
