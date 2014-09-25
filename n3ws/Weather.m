//
//  Weather.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/25/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "Weather.h"

@implementation Weather


//-(void)userLatitudeCoordinate:(float)userLatitudeCoordinate userLongitudeCoordinate:(float)userLongitudeCoordinate
//{
//    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/0ceb96c5a0bd0b04/geolookup/conditions/q/%f,%f.json", userLatitudeCoordinate, userLongitudeCoordinate];//41.881900,-87.627800
//    
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//    {
//        if (connectionError)
//        {
//            UIAlertView *connectionError = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Hmm..there is a strong disturbance in the connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [connectionError show];
//        }
//        else
//        {
//            NSError *error;
//            
//            NSDictionary *weatherForecastDetails = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//            
//            NSDictionary *current_observation = weatherForecastDetails[@"current_observation"];
//            
//            self.weather = [Weather new];
//            self.weather.locationWeatherCelcius = [current_observation[@"temp_c"]floatValue];
//            
//            NSLog(@"weather.locationWeatherCelcius %f", self.weather.locationWeatherCelcius);
//        }
//        
//    }];
//    
//}

@end
