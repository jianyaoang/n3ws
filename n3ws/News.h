//
//  News.h
//  n3ws
//
//  Created by Jian Yao Ang on 9/29/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject
@property (strong, nonatomic) NSString *headlines;
@property (strong, nonatomic) NSString *snippet;
@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSURL *web_url;

@property (strong, nonatomic) NSString *webTitle;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSString *webUrl;


@end
