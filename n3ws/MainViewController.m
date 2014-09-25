//
//  MainViewController.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "MainViewController.h"
#import <SWRevealViewController.h>
#import <CoreLocation/CoreLocation.h>
#import "Instagram.h"
#import "Weather.h"

@interface MainViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong, nonatomic) IBOutlet UIImageView *temperatureImage;

@property (strong, nonatomic) Weather *weather;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weather = [Weather new];
    
    [self configureBarButtonItemAbility];
    [self configureInstagram];
    [self configureCLLocationManager];
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
    self.currentLocation = [locations lastObject];
    NSLog(@"current coordinates location -- latitude: %f, longitude: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
    self.weather.userLatitudeCoordinate = self.currentLocation.coordinate.latitude;
    self.weather.userLongitudeCoordinate = self.currentLocation.coordinate.longitude;
    
    [self obtainWeatherInfoForUserLocation];
    
    [self.locationManager stopUpdatingLocation];

//    CLGeocoder *geocoder = [CLGeocoder new];
//    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
//        
//        if (!error)
//        {
//            CLPlacemark *placemark = [placemarks lastObject];
//            NSLog(@"placemark : %@", placemark);
//            
//            NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
//            NSLog(@"placemark.country %@",placemark.country);
//            NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
//                [self.locationManager stopUpdatingLocation];
//        }
//        else
//        {
//            NSLog(@"error found: %@", error);
////            UIAlertView *unableToDetectLocation = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Yikes..we can't seem to locate you" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
////            [unableToDetectLocation show];
//        }
//    }];
}

#pragma mark - weather
-(void)obtainWeatherInfoForUserLocation
{
    [self.weather userLatitudeCoordinate:self.weather.userLatitudeCoordinate userLongitudeCoordinate:self.weather.userLongitudeCoordinate];
}






@end
