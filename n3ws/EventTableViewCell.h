//
//  EventTableViewCell.h
//  n3ws
//
//  Created by Jian Yao Ang on 10/3/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventStartDate;
@property (strong, nonatomic) IBOutlet UILabel *eventLocation;

@end
