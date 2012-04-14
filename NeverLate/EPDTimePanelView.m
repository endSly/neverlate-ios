//
//  EPDTimePanelView.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDTimePanelView.h"

#import <QuartzCore/QuartzCore.h>

@implementation EPDTimePanelView

@synthesize stationLabel = _stationLabel;

@synthesize dest1Label1 = _dest1Label1;
@synthesize time1Label1 = _time1Label1;
@synthesize dest1Label2 = _dest1Label2;
@synthesize time1Label2 = _time1Label2;

@synthesize dest2Label1 = _dest2Label1;
@synthesize time2Label1 = _time2Label1;
@synthesize dest2Label2 = _dest2Label2;
@synthesize time2Label2 = _time2Label2;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 300, 192)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0, 8);
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = 0.5;
        
        UIFont *boldFont = [UIFont fontWithName:@"AtRotisSemiSans" size:18.0f];
        UIFont *regularFont = [UIFont fontWithName:@"MyriadPro-Regular" size:30.0f];
        
        _stationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 28)];
        _stationLabel.font = boldFont;
        _stationLabel.textColor = [UIColor whiteColor];
        _stationLabel.backgroundColor = [UIColor redColor];
        [self addSubview:_stationLabel];
        
        UIColor *panelColor = [UIColor colorWithRed:0xAA/255.0 green:0xAA/255.0 blue:0x66/255.0 alpha:1];
        
        {
            UIView *panelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 28, 320, 80)];
            panelContainer.backgroundColor = [UIColor colorWithRed:0x77/255.0 green:0x77/255.0 blue:0x40/255.0 alpha:1];
            
            _dest1Label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 35)];
            _dest1Label1.backgroundColor = [UIColor clearColor];
            _dest1Label1.textColor = panelColor;
            _dest1Label1.font = regularFont;
            [panelContainer addSubview:_dest1Label1];
            
            _dest1Label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 280, 35)];
            _dest1Label2.backgroundColor = [UIColor clearColor];
            _dest1Label2.textColor = panelColor;
            _dest1Label2.font = regularFont;
            [panelContainer addSubview:_dest1Label2];
            
            _time1Label1 = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, 75, 35)];
            _time1Label1.textAlignment = UITextAlignmentRight;
            _time1Label1.backgroundColor = [UIColor clearColor];
            _time1Label1.textColor = panelColor;
            _time1Label1.font = regularFont;
            [panelContainer addSubview:_time1Label1];
            
            _time1Label2 = [[UILabel alloc] initWithFrame:CGRectMake(240, 45, 75, 35)];
            _time1Label2.textAlignment = UITextAlignmentRight;
            _time1Label2.backgroundColor = [UIColor clearColor];
            _time1Label2.textColor = panelColor;
            _time1Label2.font = regularFont;
            [panelContainer addSubview:_time1Label2];
            
            [self addSubview:panelContainer];
        }
        
        {
            UIView *panelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 320, 80)];
            panelContainer.backgroundColor = [UIColor colorWithRed:0x77/255.0 green:0x77/255.0 blue:0x40/255.0 alpha:1];
            
            _dest2Label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 35)];
            _dest2Label1.backgroundColor = [UIColor clearColor];
            _dest2Label1.textColor = panelColor;
            _dest2Label1.font = regularFont;
            [panelContainer addSubview:_dest2Label1];
            
            _dest2Label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 280, 35)];
            _dest2Label2.backgroundColor = [UIColor clearColor];
            _dest2Label2.textColor = panelColor;
            _dest2Label2.font = regularFont;
            [panelContainer addSubview:_dest2Label2];
            
            _time2Label1 = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, 75, 35)];
            _time2Label1.textAlignment = UITextAlignmentRight;
            _time2Label1.backgroundColor = [UIColor clearColor];
            _time2Label1.textColor = panelColor;
            _time2Label1.font = regularFont;
            [panelContainer addSubview:_time2Label1];
            
            _time2Label2 = [[UILabel alloc] initWithFrame:CGRectMake(240, 45, 75, 35)];
            _time2Label2.textAlignment = UITextAlignmentRight;
            _time2Label2.backgroundColor = [UIColor clearColor];
            _time2Label2.textColor = panelColor;
            _time2Label2.font = regularFont;
            [panelContainer addSubview:_time2Label2];
            
            [self addSubview:panelContainer];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
