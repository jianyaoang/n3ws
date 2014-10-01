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
//accessToken = 258596838.0389991.12fd1cd16e60428fa56c32c286d15d01
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.accessToken = [userDefaults objectForKey:@"accessToken"];
    
    if (self.accessToken == nil)
    {
        self.isAcessTokenNil = YES;
        [SimpleAuth authorize:@"instagram" completion:^(id responseObject, NSError *error)
        {
            
//            NSString *accessToken = responseObject[@"credentials"][@"token"];
            self.accessToken = responseObject[@"credentials"][@"token"];
            [userDefaults setObject:self.accessToken forKey:@"accessToken"];
            [userDefaults synchronize];
            self.isAcessTokenNil = NO;
            
            if (self.isAcessTokenNil == NO)
            {
                [self requestInfoFromInstagram];
            }
        }];
    }
}

-(void)requestInfoFromInstagram
{
    NSLog(@"requestInfoFromInstagram");
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/locations/search?lat=41.8819&lng=-87.6278&access_token=%@",self.accessToken];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
    {
        self.data = [[NSData alloc] initWithContentsOfURL:location];
                                          
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingAllowFragments error:&error];
                                          
        NSLog(@"responseDictionary %@", responseDictionary);
    }];
    
    [task resume];
}

@end
