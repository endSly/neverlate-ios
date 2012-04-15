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

@synthesize panels = _panels;

- (id)initWithPanelsCount:(int)panelsCount
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 28 + 65 * panelsCount)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = 0.5;
        
        UIFont *boldFont = [UIFont fontWithName:@"AtRotisSemiSans" size:18.0f];
        
        _stationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 28)];
        _stationLabel.font = boldFont;
        _stationLabel.textColor = [UIColor whiteColor];
        _stationLabel.backgroundColor = [UIColor redColor];
        [self addSubview:_stationLabel];
        
        NSMutableArray *panels = [NSMutableArray arrayWithCapacity:panelsCount];
        for (int i = 0; i < panelsCount; i++) {
            EPDPanelView *panel = [[EPDPanelView alloc] init];
            panel.frame = CGRectMake(0, 28 + 65 * i, 320, 65);
            [panels addObject:panel];
            [self addSubview:panel];
        }
        _panels = panels;
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

@implementation EPDPanelView

@synthesize destLabel1 = _destLabel1;
@synthesize timeLabel1 = _timeLabel1;
@synthesize destLabel2 = _destLabel2;
@synthesize timeLabel2 = _timeLabel2;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 65)];
    if (self) {
        UIFont *regularFont = [UIFont fontWithName:@"MyriadPro-Regular" size:28.0f];

        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PanelBackground"]];
        
        UIColor *panelColor = [UIColor colorWithRed:0x88/255.0 green:0x88/255.0 blue:0x50/255.0 alpha:1];
        
        
        _destLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 32)];
        _destLabel1.backgroundColor = [UIColor clearColor];
        _destLabel1.textColor = panelColor;
        _destLabel1.font = regularFont;
        [self addSubview:_destLabel1];
        
        _destLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 280, 32)];
        _destLabel2.backgroundColor = [UIColor clearColor];
        _destLabel2.textColor = panelColor;
        _destLabel2.font = regularFont;
        [self addSubview:_destLabel2];
        
        _timeLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, 75, 32)];
        _timeLabel1.textAlignment = UITextAlignmentRight;
        _timeLabel1.backgroundColor = [UIColor clearColor];
        _timeLabel1.textColor = panelColor;
        _timeLabel1.font = regularFont;
        [self addSubview:_timeLabel1];
        
        _timeLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(240, 35, 75, 32)];
        _timeLabel2.textAlignment = UITextAlignmentRight;
        _timeLabel2.backgroundColor = [UIColor clearColor];
        _timeLabel2.textColor = panelColor;
        _timeLabel2.font = regularFont;
        [self addSubview:_timeLabel2];

    }
    return self;
}

@end
