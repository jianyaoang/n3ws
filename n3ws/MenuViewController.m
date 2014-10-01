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

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) Instagram *instagram;
@property (strong, nonatomic) NSMutableArray *instagramHeadlinesAccountsMutableArray;
@property (strong, nonatomic) NSMutableArray *instagramEntertainmentAccountsMutableArray;
@property (strong, nonatomic) NSData *data;
@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.instagramHeadlinesAccountsMutableArray = [NSMutableArray new];
    self.instagramEntertainmentAccountsMutableArray = [NSMutableArray new];
    
    self.menuTitles = [NSArray new];
    
    [self settingUpMenuTable];
    
    NSArray *headlinesID = @[@"217723373", @"1269598", @"21943587", @"247784713", @"1347193480"];
    NSArray *entertainmentID = @[@"12996727", @"1907035"];
    
    [self extractingHeadlinesInstagramAccountData:headlinesID];
    [self extractingEntertainmentInstagramAccountData:entertainmentID];
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

#pragma mark - Extract Instagram Headline info
-(void)extractingHeadlinesInstagramAccountData:(NSArray*)headlinesID
{
    for (NSString *headlineAccountID in headlinesID)
    {
        [self extractInstagramPhotosByID:headlineAccountID];
    }
}

-(void)extractInstagramPhotosByID:(NSString*)accountID
{
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
                
                NSString *testInstagramCaptionLimit = [accountInfo valueForKeyPath:@"caption.text"];
                NSRange stringRange = {0, MIN([testInstagramCaptionLimit length], 450)};
                // adjust the range to include dependent chars
                stringRange = [testInstagramCaptionLimit rangeOfComposedCharacterSequencesForRange:stringRange];
                // Now you can create the short string
                instagramAccount.caption = [testInstagramCaptionLimit substringWithRange:stringRange];
                
                [self.instagramHeadlinesAccountsMutableArray addObject:instagramAccount];
            }
        }
    }];
    [task resume];
}

#pragma mark - Entertainment Instagram Info
-(void)extractingEntertainmentInstagramAccountData:(NSArray*)entertainmentID
{
    for (NSString *entertainmentAccountID in entertainmentID)
    {
        [self extractEntertainmentInstagramPhotosByID:entertainmentAccountID];
    }
}

-(void)extractEntertainmentInstagramPhotosByID:(NSString*)accountID
{
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
                  
                  NSString *testInstagramCaptionLimit = [accountInfo valueForKeyPath:@"caption.text"];
                  NSRange stringRange = {0, MIN([testInstagramCaptionLimit length], 450)};
                  // adjust the range to include dependent chars
                  stringRange = [testInstagramCaptionLimit rangeOfComposedCharacterSequencesForRange:stringRange];
                  // Now you can create the short string
                  instagramAccount.caption = [testInstagramCaptionLimit substringWithRange:stringRange];
                  
                  [self.instagramEntertainmentAccountsMutableArray addObject:instagramAccount];
              }
          }
      }];
    [task resume];
}


#pragma mark - menu table
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

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *nav = segue.destinationViewController;
    HeadlinesViewController *hvc = [HeadlinesViewController new];
    
    if ([segue.identifier isEqualToString:@"Headlines"])
    {
        self.instagram = [self.instagramHeadlinesAccountsMutableArray objectAtIndex:indexPath.row];
        hvc = nav.viewControllers[0];
        
        hvc.instagram = self.instagram;
        hvc.instagramAccountsMutableArray = self.instagramHeadlinesAccountsMutableArray;
    }
    else if ([segue.identifier isEqualToString:@"Entertainment"])
    {
        self.instagram = [self.instagramEntertainmentAccountsMutableArray objectAtIndex:indexPath.row];
        hvc = nav.viewControllers[0];
        
        hvc.instagram = self.instagram;
        hvc.instagramAccountsMutableArray = self.instagramEntertainmentAccountsMutableArray;
    }
    else if ([segue.identifier isEqualToString:@"Food"])
    {
        hvc = nav.viewControllers[0];
        hvc.instagram = self.instagram;
    }
    else if ([segue.identifier isEqualToString:@"Travel"])
    {
        hvc = nav.viewControllers[0];
        hvc.instagram = self.instagram;
    }
    
}

@end
