//
//  InstagramTableViewCell.m
//  n3ws
//
//  Created by Jian Yao Ang on 10/7/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "InstagramTableViewCell.h"

@implementation InstagramTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end