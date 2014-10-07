//
//  Weather.h
//  n3ws
//
//  Created by Jian Yao Ang on 9/25/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Weather : NSObject <CLLocationManagerDelegate>
@property float userLatitudeCoordinate;
@property float userLongitudeCoordinate;

@property float locationWeatherCelcius;
@property (strong, nonatomic) NSString *weatherStatus;
@property (strong, nonatomic) NSString *temperature_String;

//-(void)userLatitudeCoordinate:(float)userLatitudeCoordinate userLongitudeCoordinate:(float)userLongitudeCoordinate;

@end
