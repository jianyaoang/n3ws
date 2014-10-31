//
//  HeadlinesViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "HeadlinesViewController.h"
#import <SWRevealViewController.h>
#import "InstagramTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SAMCache/SAMCache.h>

@interface HeadlinesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (strong, nonatomic) IBOutlet UITableView *instagramTableView;
@property (strong, nonatomic) UIImage *cellBackgroundImage;
@property (strong, nonatomic) NSMutableArray *instagramMutableArray;
@property (strong, nonatomic) NSData *data;
@property BOOL isHeadlineConnectionErrorShown;
@property (strong, nonatomic) UIImageView *backgroundView;

@end

@implementation HeadlinesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.instagramMutableArray = [NSMutableArray new];
    [self retrieveAccounts];
    [self configureBarButtonItemAbility];
    
    self.isHeadlineConnectionErrorShown = NO;
    
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
        
        [UIView transitionWithView:self.instagramTableView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
         {
             [self.instagramTableView setSeparatorColor:[UIColor clearColor]];
            
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
    return self.instagramMutableArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.instagram = [self.instagramMutableArray objectAtIndex:indexPath.row];
    InstagramTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstagramInfoCell"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
//        UIImage *imageFromInstagram = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.instagram.imagesURL]]];
////        UIImage *imageFromInstagram = self.instagram.instagramImage;
////        UIImage *imageFromInstagram = [[SAMCache sharedCache] imageForKey:self.instagram.imageID];
//        CGSize resizeImage = CGSizeMake(320, 320);
//        UIGraphicsBeginImageContext(resizeImage);
//        [imageFromInstagram drawInRect:CGRectMake(0, 0, resizeImage.width, resizeImage.height)];
//        UIImage *resizedImageFromInstagram = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            

            UIImage *resizedImageFromInstagram = [[SAMCache sharedCache] imageForKey:self.instagram.imageID];
            if (resizedImageFromInstagram)
            {
                //            self.backgroundView.image = resizedImageFromInstagram;
                //            cell.backgroundView = self.backgroundView;
                cell.backgroundView = [[UIImageView alloc] initWithImage:resizedImageFromInstagram];
            }


            cell.instagramUsername.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
            cell.instagramCaption.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
            
            cell.instagramUsername.text = [NSString stringWithFormat:@"@%@", self.instagram.username];
            cell.instagramUsername.textColor = [UIColor whiteColor];
            cell.instagramUsername.font = [UIFont fontWithName:@"Helvetica Neue" size:18];
            
            cell.instagramCaption.text = [NSString stringWithFormat:@"%@",self.instagram.caption];
            cell.instagramCaption.numberOfLines = 0;
            cell.instagramCaption.textColor = [UIColor whiteColor];
            cell.instagramCaption.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Instagram *instagramAccount = [self.instagramMutableArray objectAtIndex:indexPath.row];
    NSString *caption = instagramAccount.caption;
    CGFloat width = 320;
    UIFont *font = [UIFont systemFontOfSize:0.3];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:caption attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width,CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    rect = CGRectInset(rect, -320, -163);
    CGSize size = rect.size;
    return size.height;
    
}

#pragma mark - Extract Instagram Info
-(void)retrieveAccounts
{
    if ([self.section.sectionName isEqualToString:@"Headlines"])
    {
        NSArray *headlinesID = @[@"21943587", @"188154866"];
        
        [self extractingHeadlinesInstagramAccountData:headlinesID];
    }
    else if ([self.section.sectionName isEqualToString:@"Entertainment"])
    {
        NSArray *entertainmentID = @[@"12996727",@"12411705"];

        [self extractingHeadlinesInstagramAccountData:entertainmentID];
    }
    else if ([self.section.sectionName isEqualToString:@"Food"])
    {
        NSArray *foodID = @[@"11798576", @"25872982", @"974702434", @"303633557"];
        
        [self extractingHeadlinesInstagramAccountData:foodID];
    }
    else if ([self.section.sectionName isEqualToString:@"Travel"])
    {
        NSArray *travelID = @[@"12485872", @"217653153", @"11227616"];

        [self extractingHeadlinesInstagramAccountData:travelID];
    }
}


-(void)extractingHeadlinesInstagramAccountData:(NSArray*)headlinesID
{
    for (NSString *headlineAccountID in headlinesID)
    {
        [self extractInstagramPhotosByID:headlineAccountID];
    }
}

-(void)extractInstagramPhotosByID:(NSString*)accountID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        self.instagram = [Instagram new];
        [self.instagram accessingInstagram];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?count=5&access_token=%@",accountID,self.instagram.accessToken];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
      {
          if (error)
          {
              NSLog(@"%@", error);
              
              UIAlertView *headlineConnectionError = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Error with connectivity." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
              
              if (self.isHeadlineConnectionErrorShown == NO)
              {
                  [headlineConnectionError show];
                  self.isHeadlineConnectionErrorShown = YES;
              }
          }
          else
          {
              self.data = [[NSData alloc] initWithContentsOfURL:location];
              
              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingAllowFragments error:&error];
              
              NSDictionary *data = [responseDictionary valueForKeyPath:@"data"];
              
              for (NSDictionary *accountInfo in data)
              {
                  Instagram *instagramAccount = [Instagram new];
                  instagramAccount.imagesURL = [accountInfo valueForKeyPath:@"images.standard_resolution.url"];
                  instagramAccount.username = [accountInfo valueForKeyPath:@"caption.from.username"];
                  instagramAccount.imageID = [accountInfo valueForKeyPath:@"id"];
                  
                  NSData *imageURLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:instagramAccount.imagesURL]];
                  UIImage *imageFromInstagram = [[UIImage alloc] initWithData:imageURLData];
                  CGSize resizeImage = CGSizeMake(320, 320);
                  UIGraphicsBeginImageContext(resizeImage);
                  [imageFromInstagram drawInRect:CGRectMake(0, 0, resizeImage.width, resizeImage.height)];
                  instagramAccount.instagramImage = UIGraphicsGetImageFromCurrentImageContext();
                  UIGraphicsEndImageContext();
                  
                  [[SAMCache sharedCache] setImage:instagramAccount.instagramImage forKey:instagramAccount.imageID];
                  
                  NSString *testInstagramCaptionLimit = [accountInfo valueForKeyPath:@"caption.text"];
                  NSRange stringRange = {0, MIN([testInstagramCaptionLimit length], 500)};
                  // adjust the range to include dependent chars
                  stringRange = [testInstagramCaptionLimit rangeOfComposedCharacterSequencesForRange:stringRange];
                  // Now you can create the short string
                  instagramAccount.caption = [testInstagramCaptionLimit substringWithRange:stringRange];
                  
                  [self.instagramMutableArray addObject:instagramAccount];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                      
                      [UIView transitionWithView:self.instagramTableView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
                       {
                            [self.instagramTableView reloadData];
                           
                       } completion:nil];
                      
                      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                  });
              }
          }
      }];
        [task resume];
        
    });
}

@end
