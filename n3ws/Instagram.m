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
        self.isAccessTokenNil = YES;
        [SimpleAuth authorize:@"instagram" completion:^(id responseObject, NSError *error)
        {
            if (!error)
            {
                self.accessToken = responseObject[@"credentials"][@"token"];
                [userDefaults setObject:self.accessToken forKey:@"accessToken"];
                [userDefaults synchronize];
                self.isAccessTokenNil = NO;
            }
            else
            {
                self.loginErrorMessage = [[UIAlertView alloc] initWithTitle:@"n3ws" message:@"Please login to Instagram account in order to use the following feature: Headlines, Entertainment, Food, Travel" delegate:self cancelButtonTitle:@"No Instagram Account" otherButtonTitles: @"Login Instagram", nil];
                self.loginErrorMessage.delegate = self;
                self.loginErrorMessage.tag = 1;
                [self.loginErrorMessage show];
            }
        }];
    }
}

//
////-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
////{
////    if (alertView.tag == 1)
////    {
////        [self accessingInstagram];
////    }
////}
//
//-(void)requestInfoFromInstagram
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//       
//        NSLog(@"requestInfoFromInstagram");
//        
//        NSURLSession *session = [NSURLSession sharedSession];
//        NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/66/media/recent/?access_token=%@",self.accessToken];
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
//          {
//              self.data = [[NSData alloc] initWithContentsOfURL:location];
//              
//              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingAllowFragments error:&error];
//              
//          }];
//        
//        [task resume];
//        
//    });
//}

@end
