//
//  Stock.h
//  n3ws
//
//  Created by Jian Yao Ang on 9/30/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stock : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *symbol;
@property (strong, nonatomic) NSString *percentChange;
@property (strong, nonatomic) NSString *ask;

@end
