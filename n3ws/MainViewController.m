//
//  MainViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

static NSString *const API = @"c1adfeb2360f7ffc9e7645ad1f32b378:16:69887340";

#import "MainViewController.h"
#import <SWRevealViewController.h>
#import <CoreLocation/CoreLocation.h>
#import "Instagram.h"
#import "Weather.h"
#import "News.h"

@interface MainViewController () <CLLocationManagerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeNumberLabel;
@property (strong, nonatomic) IBOutlet UIView *timeView;

@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong, nonatomic) IBOutlet UIImageView *temperatureImage;

@property (strong, nonatomic) IBOutlet UIScrollView *newsScrollView;
@property (strong, nonatomic) IBOutlet UILabel *newsHeadlineTag;
@property (strong, nonatomic) IBOutlet UIPageControl *newsPageControl;
@property (strong, nonatomic) NSArray *newsImages;
@property (strong, nonatomic) NSMutableArray *headlineNews;


@property (strong, nonatomic) Weather *weather;
@property (strong, nonatomic) News *news;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weather = [Weather new];
    self.headlineNews = [NSMutableArray new];
    
    [self configureBarButtonItemAbility];
    [self configureInstagram];
    [self configureCLLocationManager];
    [self obtainAndDisplayTime];
    [self obtainNewsArticles];
}

#pragma mark - Menu Bar Button Item
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

#pragma mark - Instagram
-(void)configureInstagram
{
    Instagram *instagram = [Instagram new];
    
    [instagram accessingInstagram];
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
    
    self.timeNumberLabel.text = currentTime;
    
    NSLog(@"this is the currentTime: %@",currentTime);
}

#pragma mark - news
-(void)obtainNewsArticles
{
    NSURL *url = [NSURL URLWithString:@"http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=news_desk:(%22Business%22)&begin_date=20140929&sort=newest&api-key=c1adfeb2360f7ffc9e7645ad1f32b378:16:69887340"];

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
            
            //retrieve headlines images
            NSDictionary *headlinesImages = [newsDetails valueForKeyPath:@"response.docs.multimedia.legacy.xlarge"];
            
        
            //getting headlines
            NSDictionary *headlines = [newsDetails valueForKeyPath:@"response.docs.headline.main"];
         
            for (NSString *headline in headlines)
            {
                News *news = [News new];
                news.headlines = headline;
                [self.headlineNews addObject:news];
            }
            NSLog(@"self.headlineNews ~~~~~ %@", self.headlineNews);
            
            
            
//            NSMutableArray *headlineMutableArray = [NSMutableArray arrayWithObjects:headlines,headlinesImages, nil];
        }
        
    }];
}

-(void)configuringNewsScrollView
{
    CGFloat width = 0.0f;
    
    NSArray *images = @[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hot1"]],
                        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hot2"]]];

    for (UIImageView *newsImages in images)
    {
//        [self.newsScrollView addSubview:newsImages];
//        
//        newsImages.frame = CGRectMake(width, 0, self.view.frame.size.width, self.view.frame.size.height);
//        newsImages.contentMode = UIViewContentModeScaleAspectFit;
//        width += newsImages.frame.size.width;

//        UIImage *image = [UIImage imageWithData:imageData];
        
        UIImage *image;
        //resize image block
        CGSize newSize = CGSizeMake(self.newsScrollView.frame.size.width, self.newsScrollView.frame.size.height);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *newsImageView = [[UIImageView alloc] initWithImage:newImage];
        [self.newsScrollView addSubview:newsImageView];
        
        newsImageView.frame = CGRectOffset(self.newsScrollView.bounds, width, 0);
        newsImageView.contentMode = UIViewContentModeScaleAspectFit;
        newsImageView.clipsToBounds = YES;
        width += newsImageView.frame.size.width;
    }
    
    self.newsScrollView.contentMode = UIViewContentModeScaleAspectFit;
    self.newsScrollView.contentSize = CGSizeMake(width, self.newsScrollView.frame.size.height);
    self.newsScrollView.delegate = self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.newsScrollView.frame.size.width;
    int page = floor((self.newsScrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    self.newsPageControl.currentPage = page;
//    self.newsPageControl.numberOfPages = newsImageArray.count;
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


@end
