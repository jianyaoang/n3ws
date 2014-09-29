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
@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSURL *imageURL;

@end
