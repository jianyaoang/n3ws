//
//  Instagram.h
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimpleAuth.h>

#import "Weather.h"

@interface Instagram : NSObject
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) Weather *weather;

-(void)accessingInstagram;

@end
