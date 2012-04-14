//
//  EPDMetroStationCell.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/4/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDMetroStationCell.h"

#import "EPDStation.h"

@implementation EPDMetroStationCell

@synthesize station = _station;
@synthesize time1Label = _time1Label;
@synthesize time2Label = _time2Label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UILabel *time1Label = [[UILabel alloc] initWithFrame:CGRectMake(4, 32, 152, 16)];
        time1Label.textColor = [UIColor grayColor];
        [self addSubview:time1Label];
        self.time1Label = time1Label;
        
        UILabel *time2Label = [[UILabel alloc] initWithFrame:CGRectMake(160, 32, 152, 16)];
        time2Label.textColor = [UIColor grayColor];
        [self addSubview:time2Label];
        self.time2Label = time2Label;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(4, 2, 240, 24);
    self.detailTextLabel.frame = CGRectMake(240, 2, 76, 24);
}

- (void)prepareForReuse
{
    self.textLabel.text = _station.name;
    _time1Label.text = @"";
    _time2Label.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
