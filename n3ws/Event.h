//
//  Event.h
//  n3ws
//
//  Created by Jian Yao Ang on 10/3/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface Event : NSObject
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) NSString *eventTitle;

@end
