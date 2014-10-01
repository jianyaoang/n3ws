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
        
        [UIView transitionWithView:self.instagramTableView duration:1.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
         {
             [self.instagramTableView setSeparatorColor:[UIColor clearColor]];
             [self.instagramTableView reloadData];
         } completion:nil];
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

    UIImage *imageFromInstagram = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.instagram.imagesURL]]];
    CGSize resizeImage = CGSizeMake(320, 420);
    UIGraphicsBeginImageContext(resizeImage);
    [imageFromInstagram drawInRect:CGRectMake(0, 0, resizeImage.width, resizeImage.height)];
    UIImage *resizedImageFromInstagram = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.backgroundView = [[UIImageView alloc] initWithImage:resizedImageFromInstagram];
        cell.textLabel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.75];
        cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.75];
    });

    cell.textLabel.text = [NSString stringWithFormat:@"@%@",self.instagram.username];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:25];
    cell.textLabel.numberOfLines = 0;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.instagram.caption];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Instagram *instagramAccount = [self.instagramAccountsMutableArray objectAtIndex:indexPath.row];
    NSString *caption = instagramAccount.caption;
    CGFloat width = 320;
    UIFont *font = [UIFont systemFontOfSize:1];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:caption attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width,CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    rect = CGRectInset(rect, -320, -210);
    CGSize size = rect.size;
    return size.height;
    
}



@end
