//
//  MainViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

static NSString *const API = @"c1adfeb2360f7ffc9e7645ad1f32b378:16:69887340";

#import "MainViewController.h"
#import "WebNewsViewController.h"
#import "ANBlurredTableView.h"
#import <SWRevealViewController.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "EventTableViewCell.h"
#import "Instagram.h"
#import "Weather.h"
#import "News.h"
#import "Stock.h"
#import "Event.h"

@interface MainViewController () <CLLocationManagerDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeNumberLabel;
@property (strong, nonatomic) IBOutlet UIView *timeView;

@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *temperatureStatusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *temperatureImage;
@property (strong, nonatomic) IBOutlet UIImageView *wundergroundImage;

@property (strong, nonatomic) NSArray *newsImages;
@property (strong, nonatomic) NSMutableArray *headlineNews;
@property (strong, nonatomic) IBOutlet ANBlurredTableView *newsTableView;
@property (strong, nonatomic) UIRefreshControl *refreshNewsTable;

@property (strong, nonatomic) NSMutableArray *stockInfoMutableArray;

@property (strong, nonatomic) IBOutlet ANBlurredTableView *eventTableView;
@property (strong, nonatomic) NSMutableArray *eventMutableArray;
@property (strong, nonatomic) NSMutableArray *noEventMutableArray;

@property BOOL isGuardianConnectionErrorShown;
@property BOOL isConnectionErrorShown;

@property (strong, nonatomic) Weather *weather;
@property (strong, nonatomic) News *news;
@property (strong, nonatomic) Stock *stock;
@property (strong, nonatomic) Event *event;


@property (strong, nonatomic) NSURL *newsURL;
@property (strong, nonatomic) NSURLRequest *newsUrlRequest;

@property (strong, nonatomic) NSURL *weatherURL;
@property (strong, nonatomic) NSURLRequest *weatherUrlRequest;
@property (strong, nonatomic) NSURLConnection *connection;

@property (strong, nonatomic) NSData *theSavedWeatherData;
@property (strong, nonatomic) NSData *theSavedNewsData;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self settingNavigationTitle];
    
    self.isGuardianConnectionErrorShown = NO;
    self.isConnectionErrorShown = NO;
    
    self.weather = [Weather new];
    self.news = [News new];
    self.headlineNews = [NSMutableArray new];
    self.stockInfoMutableArray = [NSMutableArray new];
    self.eventMutableArray = [NSMutableArray new];
    self.noEventMutableArray = [NSMutableArray new];
    self.theSavedWeatherData = [NSData new];
    self.theSavedNewsData = [NSData new];
    
    [self configureBarButtonItemAbility];
    [self configureANBlurredTableView];
    [self configureInstagram];
    [self configureCLLocationManager];
    [self obtainAndDisplayTime];
    [self obtainNewsArticles];
    [self configureYahooFinanceAPI];
    [self accessEventStore];
}

#pragma mark - navigation Title
-(void)settingNavigationTitle
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"n3ws";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:25];
    [self.navigationItem setTitleView:titleLabel];
}

#pragma mark - event
-(void)accessEventStore
{
    self.event = [Event new];
    self.event.eventStore = [EKEventStore new];
    [self.event.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            NSLog(@"Granted access to retrieve events");
        }
        else
        {
            NSLog(@"Unable to retrieve events. Permission denied");
        }
    }];
    
    [self retrieveEventsInfo];
}

-(void)retrieveEventsInfo
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    
    NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
//    nowComponents.weekday = 1; // Sunday
//    nowComponents.weekOfMonth = 1;
//    nowComponents.hour = 7;
//    nowComponents.minute = 0;
//    nowComponents.second = 0;
    
    [nowComponents setWeek:[nowComponents week] +1]; // get a week from today
    [nowComponents setHour:7]; //7am
    [nowComponents setMinute:0];
    [nowComponents setSecond:0];
    
    NSDate *endDate = [gregorian dateFromComponents:nowComponents];
    
    NSArray *calendarArray = [self.event.eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSPredicate *fetchCalendarEvents = [self.event.eventStore predicateForEventsWithStartDate:[NSDate date] endDate:endDate calendars:calendarArray];
    NSArray *events = [self.event.eventStore eventsMatchingPredicate:fetchCalendarEvents];
    
    if (events.count == 0 )
    {
        self.event = [Event new];
        self.event.noEvents = @"No events for this week";
        
        [self.noEventMutableArray addObject:self.event];
    }
    
    [self.eventMutableArray removeAllObjects];
    for (EKEvent *event in events)
    {
        self.event = [Event new];
        self.event.eventTitle = event.title;
        self.event.eventEndDate = event.endDate;
        
        NSDateFormatter *eventStartDateFormat = [NSDateFormatter new];
        [eventStartDateFormat setDateFormat:@"MMM dd, yyyy HH:mm"];
        NSString *eventStartDateString = [eventStartDateFormat stringFromDate:event.startDate];
        self.event.formattedEventStartDate = eventStartDateString;
        
        self.event.eventLocation = event.location;
        self.event.eventNotes = event.notes;
        
        [self.eventMutableArray addObject:self.event];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.newsTableView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
         {
             [self.eventTableView reloadData];
         } completion:nil];
    });
}


#pragma mark - YQL
-(void)configureYahooFinanceAPI
{
    NSURL *stockURL = [NSURL URLWithString:@"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22AAPL+MSFT%22)&format=json&env=store://datatables.org/alltableswithkeys"];
    NSURLRequest *request = [NSURLRequest requestWithURL:stockURL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError)
         {
             NSLog(@"YQL Connection Error: %@",connectionError);
         }
         else
         {
             NSError *error;
             NSDictionary *mainStockInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
             
             NSDictionary *queryStock = [mainStockInfo valueForKeyPath:@"query.results.quote"];
             
             [self.stockInfoMutableArray removeAllObjects];
             for (NSDictionary *companies in queryStock)
             {
                 Stock *stock = [Stock new];
                 stock.name          = [companies valueForKeyPath:@"Name"];
                 stock.ask           = [companies valueForKeyPath:@"Ask"];
                 stock.symbol        = [companies valueForKeyPath:@"symbol"];
                 stock.percentChange = [companies valueForKeyPath:@"PercentChange"];
                 
                 [self.stockInfoMutableArray addObject:stock];
             }
             
         }
     }];
    
}

#pragma mark - Menu Bar Button Item
-(void)configureBarButtonItemAbility
{
    SWRevealViewController *revealVC = self.revealViewController;
    
    if (revealVC)
    {
        [self.menuBarButtonItem setImage:[UIImage imageNamed:@"menu2"]];
        [self.menuBarButtonItem setTarget:self.revealViewController];
        [self.menuBarButtonItem setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Instagram
-(void)configureInstagram
{
    Instagram *instagram = [Instagram new];
//    [instagram accessingInstagram];
    
        //accessToken = 258596838.0389991.12fd1cd16e60428fa56c32c286d15d01
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
       instagram.accessToken = [userDefaults objectForKey:@"accessToken"];
        
        if (instagram.accessToken == nil)
        {
            [SimpleAuth authorize:@"instagram" completion:^(id responseObject, NSError *error)
             {
                 if (!error)
                 {
                     instagram.accessToken = responseObject[@"credentials"][@"token"];
                     [userDefaults setObject:instagram.accessToken forKey:@"accessToken"];
                     [userDefaults synchronize];
                 }
                 else
                 {
                     instagram.loginErrorMessage = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Please login to Instagram account in order to use the following feature: Headlines, Entertainment, Food, Travel" delegate:self cancelButtonTitle:@"No Instagram Account" otherButtonTitles: @"Login Instagram", nil];
                     instagram.loginErrorMessage.delegate = self;
                     instagram.loginErrorMessage.tag = 1;
                     [instagram.loginErrorMessage show];
                 }
             }];
        }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            [self.navigationItem setLeftBarButtonItem:nil];
        }
        else if (buttonIndex == 1)
        {
            [self configureInstagram];
        }
    }
}

#pragma mark - CLLocation
-(void)configureCLLocationManager
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    float versionInt = [version floatValue];
    
    if (versionInt >= 8.0)
    {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.weather.userLatitudeCoordinate == 0 && self.weather.userLongitudeCoordinate == 00)
        {
            self.temperatureLabel.text = @"Unable to track location";
            self.temperatureLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:25];
            self.temperatureLabel.textAlignment = NSTextAlignmentRight;
            
            self.temperatureStatusLabel.text = @"Please configure location settings";
            self.temperatureStatusLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
            self.temperatureStatusLabel.textAlignment = NSTextAlignmentRight;
            
            self.temperatureImage.image = [UIImage imageNamed:@"cloudy"];
            self.wundergroundImage.image = [UIImage imageNamed:@"wunderground"];
        }
    });
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [CLLocation new];
    self.currentLocation = [locations lastObject];
    NSLog(@"current coordinates location -- latitude: %f, longitude: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
    self.weather.userLatitudeCoordinate = self.currentLocation.coordinate.latitude;
    self.weather.userLongitudeCoordinate = self.currentLocation.coordinate.longitude;
    
    [self obtainWeatherInfoForUserLocation];
    
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Time
-(void)obtainAndDisplayTime
{
    //    NSDate *today = [NSDate date];
    //
    //    NSDateFormatter *dateFormmatter = [NSDateFormatter new];
    //    [dateFormmatter setTimeStyle:NSDateFormatterShortStyle];
    //    [dateFormmatter setTimeZone:[NSTimeZone localTimeZone]];
    //
    //    NSString *currentTime = [dateFormmatter stringFromDate:today];
    //
    //    self.timeView.backgroundColor = [UIColor whiteColor];
    //    self.timeNumberLabel.text = currentTime;
    //    self.timeNumberLabel.textColor = [UIColor colorWithRed:0.11 green:0.60 blue:0.84 alpha:0.8];
    //    self.timeNumberLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:35];
    //    self.timeLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
    //    self.timeLabel.textColor = [UIColor colorWithRed:0.11 green:0.60 blue:0.84 alpha:0.8];
    //
    //    NSLog(@"this is the currentTime: %@",currentTime);
}

#pragma mark - news
-(void)obtainNewsArticles
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"http://content.guardianapis.com/search?page-size=15&section=world|technology|sport|business&api-key=cjj5325rskk27bs7s3nby8uc"];
        
        self.newsURL = [NSURL new];
        self.newsURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        self.newsUrlRequest = [NSURLRequest new];
        self.newsUrlRequest = [NSURLRequest requestWithURL:self.newsURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
        
        [NSURLConnection sendAsynchronousRequest:self.newsUrlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             if (connectionError)
             {
                 NSLog(@"connectionError guardian news api: %@", connectionError);
                 
                 UIAlertView *guardianConnectionError = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Yikes! We are facing a server side issue. We are terribly sorry. Please hit the refresh button in a few moments." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 
                 if (self.isGuardianConnectionErrorShown == NO)
                 {
                     [guardianConnectionError show];
                     self.isGuardianConnectionErrorShown = YES;
                 }
                 
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                     
                     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                     NSString *path = [[paths lastObject] stringByAppendingPathComponent:@"newsData"];
                     
                     if ([[NSFileManager defaultManager] fileExistsAtPath:path])
                     {
                         self.theSavedNewsData = [[NSData alloc] initWithContentsOfFile:path];
                     }
                     
                     NSError *error;
                     
                     NSDictionary *newsDetails = [NSJSONSerialization JSONObjectWithData:self.theSavedNewsData options:NSJSONReadingAllowFragments error:&error];
                     
                     //getting headlines
                     NSDictionary *headlines = [newsDetails valueForKeyPath:@"response.results"];
                     
                     [self.headlineNews removeAllObjects];
                     for (NSDictionary *results in headlines)
                     {
                         News *news = [News new];
                         news.webTitle = [results valueForKeyPath:@"webTitle"];
                         news.sectionName = [results valueForKeyPath:@"sectionName"];
                         news.webUrl = [results valueForKeyPath:@"webUrl"];
                         
                         [self.headlineNews addObject:news];
                     }
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [UIView transitionWithView:self.newsTableView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
                          {
                              [self.newsTableView reloadData];
                          } completion:nil];
                         
                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     });
                     
                 });
                 
             }
             else
             {
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                     
                     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                     
                     NSString *documentDirectory = [paths lastObject];
                     
                     NSString *newsDataPath = [documentDirectory stringByAppendingPathComponent:@"newsData"];
                     
                     NSLog(@"weatherDataPath == %@", newsDataPath);
                     
                     [data writeToFile:newsDataPath atomically:YES];
                     
                     NSError *error;
                     
                     NSDictionary *newsDetails = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                     
                     //getting headlines
                     NSDictionary *headlines = [newsDetails valueForKeyPath:@"response.results"];
                     
                     [self.headlineNews removeAllObjects];
                     for (NSDictionary *results in headlines)
                     {
                         News *news = [News new];
                         news.webTitle = [results valueForKeyPath:@"webTitle"];
                         news.sectionName = [results valueForKeyPath:@"sectionName"];
                         news.webUrl = [results valueForKeyPath:@"webUrl"];
                         
                         [self.headlineNews addObject:news];
                     }
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [UIView transitionWithView:self.newsTableView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
                          {
                              [self.newsTableView reloadData];
                          } completion:nil];
                         
                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     });
                     
                 });
             }
         }];
    });
}

#pragma mark - News TableView
-(void)configureANBlurredTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.refreshNewsTable = [UIRefreshControl new];
        self.refreshNewsTable.tintColor = [UIColor colorWithWhite:0.9 alpha:0.9];
        
        self.newsTableView.layer.borderWidth = 1.0;
        self.newsTableView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
        
        self.eventTableView.layer.borderWidth = 1.0;
        self.eventTableView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
        
        NSAttributedString *refreshMessage = [[NSAttributedString alloc] initWithString:@"Pull down to get news update" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        self.refreshNewsTable.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:refreshMessage];
        
        
        [self.eventTableView setBlurTintColor:[UIColor colorWithWhite:0.11 alpha:0.1]];
        [self.eventTableView setAnimateTintAlpha:YES];
        [self.eventTableView setStartTintAlpha:0.65f];
        [self.eventTableView setEndTintAlpha:0.75f];
        [self.eventTableView setBackgroundImage:[UIImage imageNamed:@"sky"]];
        
        [self.newsTableView setBlurTintColor:[UIColor colorWithWhite:0.11 alpha:0.1]];
        [self.newsTableView setAnimateTintAlpha:YES];
        [self.newsTableView setStartTintAlpha:0.75f];
        [self.newsTableView setEndTintAlpha:0.75f];
        [self.newsTableView setBackgroundImage:[UIImage imageNamed:@"dew"]];
    });
    
    [self.refreshNewsTable addTarget:self action:@selector(updateNewsTable) forControlEvents:UIControlEventValueChanged];
    [self.newsTableView addSubview:self.refreshNewsTable];
}

-(void)updateNewsTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self obtainNewsArticles];
        [self.refreshNewsTable endRefreshing];
    });
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.eventTableView)
    {
        if (self.eventMutableArray.count == 0)
        {
            return self.noEventMutableArray.count;
        }
        else
        {
            return self.eventMutableArray.count;
        }
    }
    else if (tableView == self.newsTableView)
    {
        return self.headlineNews.count;
    }
    else
    {
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.eventTableView)
    {
        
        if (self.eventMutableArray.count == 0)
        {
            self.event = [self.noEventMutableArray objectAtIndex:indexPath.row];
            EventTableViewCell *eventTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"EventCellID"];
            eventTableViewCell.eventTitleLabel.text = self.event.noEvents;
            eventTableViewCell.eventTitleLabel.textColor = [UIColor whiteColor];
            eventTableViewCell.eventTitleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:23];
            eventTableViewCell.eventTitleLabel.numberOfLines = 0;
            eventTableViewCell.eventStartDate.text = @"";
            eventTableViewCell.eventLocation.text = @"";
            
            eventTableViewCell.backgroundColor = [UIColor clearColor];
            return eventTableViewCell;
        }
        
        self.event = [self.eventMutableArray objectAtIndex:indexPath.row];
        EventTableViewCell *eventTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"EventCellID"];
        
        eventTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        eventTableViewCell.backgroundColor = [UIColor clearColor];
        
        eventTableViewCell.eventTitleLabel.text = self.event.eventTitle;
        eventTableViewCell.eventTitleLabel.textColor = [UIColor whiteColor];
        eventTableViewCell.eventTitleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:23];
        eventTableViewCell.eventTitleLabel.numberOfLines = 0;
        
        eventTableViewCell.eventStartDate.text = [NSString stringWithFormat:@"%@",self.event.formattedEventStartDate];
        eventTableViewCell.eventStartDate.textColor = [UIColor whiteColor];
        eventTableViewCell.eventStartDate.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        eventTableViewCell.eventStartDate.numberOfLines = 0;
        
        eventTableViewCell.eventLocation.text = self.event.eventLocation;
        eventTableViewCell.eventLocation.textColor = [UIColor whiteColor];
        eventTableViewCell.eventLocation.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        eventTableViewCell.eventLocation.numberOfLines = 0;
        
        return eventTableViewCell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
        News *news = [self.headlineNews objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = news.webTitle;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.text = news.sectionName;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
        
        if ([news.sectionName isEqualToString:@"Business"])
        {
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.73 green:0.34 blue:0.34 alpha:1];
        }
        else if ([news.sectionName isEqualToString:@"Technology"])
        {
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.12 green:0.64 blue:0.84 alpha:1];;
        }
        else if ([news.sectionName isEqualToString:@"World news"])
        {
            cell.detailTextLabel.textColor = [UIColor yellowColor];
        }
        else if ([news.sectionName isEqualToString:@"Sport"])
        {
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.79 green:0.45 blue:0.79 alpha:1];
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor redColor];
    cell.detailTextLabel.textColor = [UIColor redColor];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.newsTableView)
    {
        News *news = [self.headlineNews objectAtIndex:indexPath.row];
        NSString *headline = news.webTitle;
        CGFloat width = 280;
        UIFont *font = [UIFont systemFontOfSize:5];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:headline attributes:@{NSFontAttributeName: font}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){width,CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        rect = CGRectInset(rect, -100, -65);
        CGSize size = rect.size;
        return size.height;
    }
    else
    {
        return 130;
    }
}

#pragma mark - weather
-(void)obtainWeatherInfoForUserLocation
{
    [self userLatitudeCoordinate:self.weather.userLatitudeCoordinate userLongitudeCoordinate:self.weather.userLongitudeCoordinate];
}

-(void)userLatitudeCoordinate:(float)userLatitudeCoordinate userLongitudeCoordinate:(float)userLongitudeCoordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/72540bc830392f65/geolookup/conditions/q/%f,%f.json", userLatitudeCoordinate, userLongitudeCoordinate];
    
    self.weatherURL = [NSURL new];
    self.weatherURL = [NSURL URLWithString:urlString];
    
    self.weatherUrlRequest = [NSURLRequest new];
    self.weatherUrlRequest = [NSURLRequest requestWithURL:self.weatherURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:self.weatherUrlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError)
         {
             NSLog(@"connection Error: %@", connectionError);
             
             UIAlertView *connectionError = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Hmm..We are either facing a server side issue or we are unable to detect your location. Please configure your settings, while we check with our partner's server. Thanks!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             
             if (self.isConnectionErrorShown == NO)
             {
                 [connectionError show];
                 self.isConnectionErrorShown = YES;
             }
             
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *weatherPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"weatherData"];
             
             if ([[NSFileManager defaultManager] fileExistsAtPath:weatherPath])
             {
                 self.theSavedWeatherData = [[NSData alloc] initWithContentsOfFile:weatherPath];
             }
             
             NSError *error;
             NSDictionary *weatherTestForecastDetails = [NSJSONSerialization JSONObjectWithData:self.theSavedWeatherData options:NSJSONReadingAllowFragments error:&error];
             NSDictionary *current_observation = weatherTestForecastDetails[@"current_observation"];
             self.weather = [Weather new];
             self.weather.locationWeatherCelcius = [current_observation[@"temp_c"]floatValue];
             self.weather.weatherStatus = [current_observation valueForKeyPath:@"weather"];
             
            dispatch_async(dispatch_get_main_queue(), ^{
             
                 self.temperatureLabel.text = [NSString stringWithFormat:@"%@",self.weather.temperature_String];
                 self.temperatureLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:35];
                 self.temperatureLabel.textAlignment = NSTextAlignmentRight;
                
                if (self.weather.temperature_String == nil)
                {
                    self.temperatureStatusLabel.text = @"Hit refresh to get weather update";
                }
                 
                 self.temperatureStatusLabel.text = self.weather.weatherStatus;
                 self.temperatureStatusLabel.textAlignment = NSTextAlignmentRight;
                 self.temperatureStatusLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:22];
                 
                 self.wundergroundImage.image = [UIImage imageNamed:@"wunderground"];
                 
                 [self settingTemperatureImage];
             });
             
         }
         else
         {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                 
                 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                 
                 NSString *documentDirectory = [paths objectAtIndex:0];
                 
                 NSString *weatherDataPath = [documentDirectory stringByAppendingPathComponent:@"weatherData"];
                 
                 [data writeToFile:weatherDataPath atomically:YES];
                 
                 NSError *error;
                 
                 NSDictionary *weatherForecastDetails = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                 
                 NSDictionary *current_observation = weatherForecastDetails[@"current_observation"];
                 
                 self.weather = [Weather new];
                 self.weather.locationWeatherCelcius = [current_observation[@"temp_c"]floatValue];
                 self.weather.weatherStatus = [current_observation valueForKeyPath:@"weather"];
                 self.weather.temperature_String = [current_observation valueForKeyPath:@"temperature_string"];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     self.temperatureLabel.text = [NSString stringWithFormat:@"%@",self.weather.temperature_String];
                     self.temperatureLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:35];
                     self.temperatureLabel.textAlignment = NSTextAlignmentRight;
                     
                     
                     if (self.weather.temperature_String == nil)
                     {
                         self.temperatureStatusLabel.text = @"Hit refresh to get weather update";
                     }
                     
                     self.temperatureStatusLabel.text = self.weather.weatherStatus;
                     self.temperatureStatusLabel.textAlignment = NSTextAlignmentRight;
                     self.temperatureStatusLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:22];
                     
                     self.wundergroundImage.image = [UIImage imageNamed:@"wunderground"];
                     
                     [self settingTemperatureImage];
                 });
             });
         }
         
     }];
}

-(void)settingTemperatureImage
{
    if ([self.weather.weatherStatus isEqualToString:@"Partly Cloudy"] || [self.weather.weatherStatus isEqualToString:@"Mostly Cloudy"] || [self.weather.weatherStatus isEqualToString:@"Scattered Clouds"])
    {
        self.temperatureImage.image = [UIImage imageNamed:@"cloudy"];
    }
    else if ([self.weather.weatherStatus isEqualToString:@"Light Rain"] || [self.weather.weatherStatus isEqualToString:@"Drizzle"] || [self.weather.weatherStatus isEqualToString:@"Rain"] || [self.weather.weatherStatus isEqualToString:@"Thunderstorm"] || [self.weather.weatherStatus isEqualToString:@"Thuderstorms and Rain"] || [self.weather.weatherStatus isEqualToString:@"Rain Showers"] || [self.weather.weatherStatus isEqualToString:@"Rain mist"] || [self.weather.weatherStatus isEqualToString:@"Freezing Drizzle"] || [self.weather.weatherStatus isEqualToString:@"Freezing Rain"])
    {
        self.temperatureImage.image = [UIImage imageNamed:@"raining"];
    }
    else if ([self.weather.weatherStatus isEqualToString:@"Clear"])
    {
        self.temperatureImage.image = [UIImage imageNamed:@"clear"];
    }
    else if ([self.weather.weatherStatus isEqualToString:@"Snow"] || [self.weather.weatherStatus isEqualToString:@"Snow Grains"] || [self.weather.weatherStatus isEqualToString:@"Snow Showers"] || [self.weather.weatherStatus isEqualToString:@"Snow Blowing Snow Mist"] || [self.weather.weatherStatus isEqualToString:@"Thunderstorms and Snow"])
    {
        self.temperatureImage.image = [UIImage imageNamed:@"snow"];
    }
    else if ([self.weather.weatherStatus isEqualToString:@"Haze"])
    {
        self.temperatureImage.image = [UIImage imageNamed:@"haze1"];
    }
    else if (self.weather.userLatitudeCoordinate == 0 && self.weather.userLongitudeCoordinate == 0)
    {
        self.temperatureLabel.text = @"Unable to track location";
        self.temperatureLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:25];
        self.temperatureLabel.textAlignment = NSTextAlignmentRight;
        
        self.temperatureStatusLabel.text = @"Please configure location settings";
        self.temperatureStatusLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
        self.temperatureStatusLabel.textAlignment = NSTextAlignmentRight;
        
        self.temperatureImage.image = [UIImage imageNamed:@"cloudy"];
        self.wundergroundImage.image = [UIImage imageNamed:@"wunderground"];
    }
    else
    {
        self.temperatureImage.image = [UIImage imageNamed:@"defaultTemperatureImage"];
    }
}

#pragma mark - NSURLConnectionDelegate
-(NSCachedURLResponse*)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}


#pragma mark - refresh mainVC

- (IBAction)onRefreshButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    if (self.weather.userLatitudeCoordinate != 0 && self.weather.userLongitudeCoordinate != 0)
//    {
    
        [self configureCLLocationManager];
        [self obtainWeatherInfoForUserLocation];
//    }
    [self accessEventStore];
    [self obtainNewsArticles];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.newsTableView indexPathForSelectedRow];
    News *news = [self.headlineNews objectAtIndex:indexPath.row];
    WebNewsViewController *wnvc = segue.destinationViewController;
    wnvc.news = news;
}

@end
