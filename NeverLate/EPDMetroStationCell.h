//
//  EPDMetroStationCell.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/4/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPDStation;

@interface EPDMetroStationCell : UITableViewCell

@property (nonatomic, assign) UILabel * time1Label;
@property (nonatomic, assign) UILabel * time2Label;
@property (nonatomic, retain) EPDStation * station;

@end
