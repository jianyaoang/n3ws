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
@property (strong, nonatomic) NSMutableArray *instagramFoodAccountsMutableArray;
@property (strong, nonatomic) NSMutableArray *instagramTravelAccountsMutableArray;
@property (strong, nonatomic) NSData *data;
@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidemenu"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    self.instagramHeadlinesAccountsMutableArray = [NSMutableArray new];
    self.instagramEntertainmentAccountsMutableArray = [NSMutableArray new];
    self.instagramFoodAccountsMutableArray = [NSMutableArray new];
    self.instagramTravelAccountsMutableArray = [NSMutableArray new];
    
    self.menuTitles = [NSArray new];
    
    [self settingUpMenuTable];
    
    NSArray *headlinesID = @[@"21943587", @"188154866"];
    NSArray *entertainmentID = @[@"12996727", @"1907035"];
    NSArray *foodID = @[@"11798576", @"25872982", @"974702434", @"303633557"];
    NSArray *travelID = @[@"12485872", @"217653153", @"11227616"];
    
    [self extractingHeadlinesInstagramAccountData:headlinesID];
    [self extractingEntertainmentInstagramAccountData:entertainmentID];
    [self extractingFoodInstagramAccountData:foodID];
    [self extractingTravelInstagramAccountData:travelID];
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
                  NSRange stringRange = {0, MIN([testInstagramCaptionLimit length], 500)};
                  // adjust the range to include dependent chars
                  stringRange = [testInstagramCaptionLimit rangeOfComposedCharacterSequencesForRange:stringRange];
                  // Now you can create the short string
                  instagramAccount.caption = [testInstagramCaptionLimit substringWithRange:stringRange];
                  
                  [self.instagramHeadlinesAccountsMutableArray addObject:instagramAccount];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
              }
          }
      }];
        [task resume];

    });
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
                  NSRange stringRange = {0, MIN([testInstagramCaptionLimit length], 500)};
                  // adjust the range to include dependent chars
                  stringRange = [testInstagramCaptionLimit rangeOfComposedCharacterSequencesForRange:stringRange];
                  // Now you can create the short string
                  instagramAccount.caption = [testInstagramCaptionLimit substringWithRange:stringRange];
                  
                  [self.instagramEntertainmentAccountsMutableArray addObject:instagramAccount];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
              }
          }
      }];
        [task resume];

    });
}

#pragma mark - Food Instagram Info
-(void)extractingFoodInstagramAccountData:(NSArray*)foodID
{
    for (NSString *foodAccountID in foodID)
    {
        [self extractFoodInstagramPhotosByID:foodAccountID];
    }
}

-(void)extractFoodInstagramPhotosByID:(NSString*)accountID
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
                  NSRange stringRange = {0, MIN([testInstagramCaptionLimit length], 500)};
                  // adjust the range to include dependent chars
                  stringRange = [testInstagramCaptionLimit rangeOfComposedCharacterSequencesForRange:stringRange];
                  // Now you can create the short string
                  instagramAccount.caption = [testInstagramCaptionLimit substringWithRange:stringRange];
                  
                  [self.instagramFoodAccountsMutableArray addObject:instagramAccount];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
              }
          }
      }];
        [task resume];

    });
}

#pragma mark - Travel Instagram Info
-(void)extractingTravelInstagramAccountData:(NSArray*)foodID
{
    for (NSString *foodAccountID in foodID)
    {
        [self extractTravelInstagramPhotosByID:foodAccountID];
    }
}

-(void)extractTravelInstagramPhotosByID:(NSString*)accountID
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
              NSRange stringRange = {0, MIN([testInstagramCaptionLimit length], 500)};
              // adjust the range to include dependent chars
              stringRange = [testInstagramCaptionLimit rangeOfComposedCharacterSequencesForRange:stringRange];
              // Now you can create the short string
              instagramAccount.caption = [testInstagramCaptionLimit substringWithRange:stringRange];
              
              [self.instagramTravelAccountsMutableArray addObject:instagramAccount];
              
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.tableView reloadData];
              });
          }
      }
  }];
        [task resume];

    });
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
    UINavigationController *nav = segue.destinationViewController;
    HeadlinesViewController *hvc = [HeadlinesViewController new];
    
    if ([segue.identifier isEqualToString:@"Headlines"])
    {
        if (self.instagramHeadlinesAccountsMutableArray.count != 0)
        {
            self.instagram = [self.instagramHeadlinesAccountsMutableArray objectAtIndex:indexPath.row];
            hvc = nav.viewControllers[0];
            
            hvc.instagram = self.instagram;
            hvc.instagramAccountsMutableArray = self.instagramHeadlinesAccountsMutableArray;
        }
        else
        {
            UIAlertView *retrievingData = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Just a sec..we are searching headline news for you" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [retrievingData show];
        }
    }
    else if ([segue.identifier isEqualToString:@"Entertainment"])
    {
        if (self.instagramEntertainmentAccountsMutableArray.count != 0)
        {
            self.instagram = [self.instagramEntertainmentAccountsMutableArray objectAtIndex:indexPath.row];
            hvc = nav.viewControllers[0];
            
            hvc.instagram = self.instagram;
            hvc.instagramAccountsMutableArray = self.instagramEntertainmentAccountsMutableArray;
        }
        else
        {
            UIAlertView *retrievingData = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Just a sec..we are searching juicy entertainment news for you" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [retrievingData show];
        }
        
    }
    else if ([segue.identifier isEqualToString:@"Food"])
    {
        if (self.instagramFoodAccountsMutableArray.count != 0)
        {
            self.instagram = [self.instagramFoodAccountsMutableArray objectAtIndex:indexPath.row];
            hvc = nav.viewControllers[0];
            
            hvc.instagram = self.instagram;
            hvc.instagramAccountsMutableArray = self.instagramFoodAccountsMutableArray;
        }
        else
        {
            UIAlertView *retrievingData = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Just a sec..we are searching delicious news for you" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [retrievingData show];
        }

    }
    else if ([segue.identifier isEqualToString:@"Travel"])
    {
        if (self.instagramTravelAccountsMutableArray.count != 0)
        {
            self.instagram = [self.instagramTravelAccountsMutableArray objectAtIndex:indexPath.row];
            hvc = nav.viewControllers[0];
            
            hvc.instagram = self.instagram;
            hvc.instagramAccountsMutableArray = self.instagramTravelAccountsMutableArray;
        }
        else
        {
            UIAlertView *retrievingData = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Just a sec..we are retrieving info regarding the latest getaway" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [retrievingData show];
        }
        
    }
    
}

@end
