//
//  Instagram.m
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "Instagram.h"

@implementation Instagram

-(void)accessingInstagram
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.accessToken = [userDefaults objectForKey:@"accessToken"];
    
    if (self.accessToken == nil)
    {
        [SimpleAuth authorize:@"instagram" completion:^(id responseObject, NSError *error) {
            NSString *accessToken = responseObject[@"credentials"][@"token"];
            [userDefaults setObject:accessToken forKey:@"accessToken"];
            [userDefaults synchronize];
        }];
    }
    else
    {
        NSLog(@"logged in");
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/locations/search?lat=41.8819&lng=-87.6278&access_token=%@",self.accessToken];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            
            self.data = [[NSData alloc] initWithContentsOfURL:location];
            
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingAllowFragments error:&error];
            
            NSLog(@"responseDictionary %@", responseDictionary);
        }];
        [task resume];
    }
}

@end
