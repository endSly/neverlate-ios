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
@property (nonatomic, readonly) NSArray * panels;

- (id)initWithPanelsCount:(int)panelsCount;

@end


@interface EPDPanelView : UIView

@property (nonatomic, readonly) UILabel * destLabel1;
@property (nonatomic, readonly) UILabel * timeLabel1;
@property (nonatomic, readonly) UILabel * destLabel2;
@property (nonatomic, readonly) UILabel * timeLabel2;

@end
