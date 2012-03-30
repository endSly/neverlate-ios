//
//  EPDTimePanelView.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPDTimePanelView : UIView

@property (nonatomic, readonly) UILabel * stationLabel;

@property (nonatomic, readonly) UILabel * dest1Label1;
@property (nonatomic, readonly) UILabel * time1Label1;
@property (nonatomic, readonly) UILabel * dest1Label2;
@property (nonatomic, readonly) UILabel * time1Label2;

@property (nonatomic, readonly) UILabel * dest2Label1;
@property (nonatomic, readonly) UILabel * time2Label1;
@property (nonatomic, readonly) UILabel * dest2Label2;
@property (nonatomic, readonly) UILabel * time2Label2;

@end
