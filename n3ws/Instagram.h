//
//  Instagram.h
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimpleAuth.h>

@interface Instagram : NSObject <UIAlertViewDelegate>
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSString *imagesURL;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *imageID;
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) UIAlertView *loginErrorMessage;
@property BOOL isAccessTokenNil;
@property (strong, nonatomic) UIImage *instagramImage;

-(void)accessingInstagram;
//-(void)requestInfoFromInstagram;

@end
