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
#import "Instagram.h"
#import "Weather.h"
#import "News.h"
#import "Stock.h"
#import "Event.h"

@interface MainViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeNumberLabel;
@property (strong, nonatomic) IBOutlet UIView *timeView;

@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong, nonatomic) IBOutlet UIImageView *temperatureImage;

@property (strong, nonatomic) NSArray *newsImages;
@property (strong, nonatomic) NSMutableArray *headlineNews;
@property (strong, nonatomic) IBOutlet ANBlurredTableView *newsTableView;
@property (strong, nonatomic) UIRefreshControl *refreshNewsTable;

@property (strong, nonatomic) NSMutableArray *stockInfoMutableArray;

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
@property (strong, nonatomic) NSMutableArray *eventMutableArray;


@property (strong, nonatomic) Weather *weather;
@property (strong, nonatomic) News *news;
@property (strong, nonatomic) Stock *stock;
@property (strong, nonatomic) Event *event;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self settingNavigationTitle];
    
    self.weather = [Weather new];
    self.news = [News new];
    self.headlineNews = [NSMutableArray new];
    self.stockInfoMutableArray = [NSMutableArray new];
    self.eventMutableArray = [NSMutableArray new];
    
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
    titleLabel.font = [UIFont fontWithName:@"Cochin-Bold" size:25];
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
    [nowComponents setWeekday:1];
    [nowComponents setWeek:[nowComponents week] +1]; // get a week from today
    [nowComponents setHour:7]; //7am
    [nowComponents setMinute:0];
    [nowComponents setSecond:0];
    
    NSDate *endDate = [gregorian dateFromComponents:nowComponents];
    
    NSArray *calendarArray = [self.event.eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSPredicate *fetchCalendarEvents = [self.event.eventStore predicateForEventsWithStartDate:[NSDate date] endDate:endDate calendars:calendarArray];
    NSArray *events = [self.event.eventStore eventsMatchingPredicate:fetchCalendarEvents];
    
    [self.eventMutableArray removeAllObjects];
    for (EKCalendar *calendar in events)
    {
        self.event = [Event new];
        self.event.eventTitle = calendar.title;
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
        [self.menuBarButtonItem setImage:[UIImage imageNamed:@"menu"]];
        [self.menuBarButtonItem setTarget:self.revealViewController];
        [self.menuBarButtonItem setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Instagram
-(void)configureInstagram
{
    Instagram *instagram = [Instagram new];
    
    [instagram accessingInstagram];
    
    if (instagram.accessToken != nil)
    {
        NSLog(@"it is not nil");
        [instagram requestInfoFromInstagram]; 
    }
}

#pragma mark - CLLocation
-(void)configureCLLocationManager
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager startUpdatingLocation];
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
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormmatter = [NSDateFormatter new];
    [dateFormmatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormmatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *currentTime = [dateFormmatter stringFromDate:today];
    
    self.timeView.backgroundColor = [UIColor whiteColor];
    self.timeNumberLabel.text = currentTime;
    self.timeNumberLabel.textColor = [UIColor colorWithRed:0.11 green:0.60 blue:0.84 alpha:0.8];
    self.timeNumberLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:35];
    self.timeLabel.font = [UIFont fontWithName:@"Palatino" size:20];
    self.timeLabel.textColor = [UIColor colorWithRed:0.11 green:0.60 blue:0.84 alpha:0.8];
    
    NSLog(@"this is the currentTime: %@",currentTime);
}

#pragma mark - news
-(void)obtainNewsArticles
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
//    NSURL *url = [NSURL URLWithString:@"http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=news_desk:(%22Business%22%20%22Foreign%22)&begin_date=20140929&sort=newest&api-key=c1adfeb2360f7ffc9e7645ad1f32b378:16:69887340"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://content.guardianapis.com/search?page-size=15&section=world|technology|sport|business&api-key=cjj5325rskk27bs7s3nby8uc"];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if (connectionError)
        {
            NSLog(@"%@", connectionError);
        }
        else
        {
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
                
//                news.headlines = [results valueForKeyPath:@"headline.main"];
//                news.web_url = [results valueForKeyPath:@"web_url"];
//                news.snippet = [results valueForKeyPath:@"snippet"];
               [self.headlineNews addObject:news];
            }
        }
               dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView transitionWithView:self.newsTableView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
                {
                    [self.newsTableView reloadData];
                } completion:nil];
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    }];
}

#pragma mark - News TableView
-(void)configureANBlurredTableView
{
    self.refreshNewsTable = [UIRefreshControl new];
    self.refreshNewsTable.tintColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    
    NSAttributedString *refreshMessage = [[NSAttributedString alloc] initWithString:@"Pull down to get news update" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.refreshNewsTable.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:refreshMessage];
    
    [self.refreshNewsTable addTarget:self action:@selector(updateNewsTable) forControlEvents:UIControlEventValueChanged];
    [self.newsTableView addSubview:self.refreshNewsTable];
    
    [self.newsTableView setBlurTintColor:[UIColor colorWithWhite:0.11 alpha:0.1]];
    [self.newsTableView setAnimateTintAlpha:YES];
    [self.newsTableView setStartTintAlpha:0.45f];
    [self.newsTableView setEndTintAlpha:0.75f];
    [self.newsTableView setBackgroundImage:[UIImage imageNamed:@"background"]];
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
    return self.headlineNews.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    News *news = [self.headlineNews objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = news.webTitle;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = news.sectionName;
    cell.detailTextLabel.numberOfLines = 0;
    
    if ([news.sectionName isEqualToString:@"Business"])
    {
        cell.detailTextLabel.textColor = [UIColor redColor];
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
        cell.detailTextLabel.textColor = [UIColor purpleColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor redColor];
    cell.detailTextLabel.textColor = [UIColor redColor];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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

#pragma mark - weather
-(void)obtainWeatherInfoForUserLocation
{
    [self userLatitudeCoordinate:self.weather.userLatitudeCoordinate userLongitudeCoordinate:self.weather.userLongitudeCoordinate];
}

-(void)userLatitudeCoordinate:(float)userLatitudeCoordinate userLongitudeCoordinate:(float)userLongitudeCoordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/2a2305a7d918131c/geolookup/conditions/q/%f,%f.json", userLatitudeCoordinate, userLongitudeCoordinate];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError)
         {
             UIAlertView *connectionError = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Hmm..there is a strong disturbance in the connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [connectionError show];
         }
         else
         {
             NSError *error;
             
             NSDictionary *weatherForecastDetails = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
             
             NSDictionary *current_observation = weatherForecastDetails[@"current_observation"];
             
             self.weather = [Weather new];
             self.weather.locationWeatherCelcius = [current_observation[@"temp_c"]floatValue];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.temperatureLabel.text = [NSString stringWithFormat:@"%.f ºC",self.weather.locationWeatherCelcius];
                 
                 [self settingTemperatureImageAnimation];
             });
         }
         
     }];
}

-(void)settingTemperatureImageAnimation
{
    if (self.weather.locationWeatherCelcius < 20.f)
    {
        NSArray *coldWeatherImage = @[[UIImage imageNamed:@"hot1"],
                                     [UIImage imageNamed:@"hot2"]];
        
        self.temperatureImage.animationImages = coldWeatherImage;
        self.temperatureImage.animationDuration = 2;
        [self.temperatureImage startAnimating];
        
    }
    else if (self.weather.locationWeatherCelcius > 20.f)
    {
        NSArray *hotWeatherImage = @[[UIImage imageNamed:@"hot1"],
                                     [UIImage imageNamed:@"hot2"]];
        
        self.temperatureImage.animationImages = hotWeatherImage;
        self.temperatureImage.animationDuration = 2;
        [self.temperatureImage startAnimating];
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.newsTableView indexPathForSelectedRow];
    News *news = [self.headlineNews objectAtIndex:indexPath.row];
    WebNewsViewController *wnvc = segue.destinationViewController;
    wnvc.news = news;
}

@end
