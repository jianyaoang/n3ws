//
//  HeadlinesViewController.h
//  n3ws
//
//  Created by Jian Yao Ang on 9/24/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instagram.h"
#import "Section.h"

@interface HeadlinesViewController : UIViewController
@property (strong, nonatomic) Instagram *instagram;
@property (strong, nonatomic) NSMutableArray *instagramAccountsMutableArray;

@property (strong, nonatomic) Section *section;


@end
