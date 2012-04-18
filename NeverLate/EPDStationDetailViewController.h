//
//  EPDStationDetailViewController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@class EPDStation;
@class EPDTimePanelView;
@class EPDObjectManager;

@interface EPDStationDetailViewController : UITableViewController {
    NSTimer *_timeRefreshTimer;
    
    NSArray *_times;
    EPDTimePanelView *_headerView;
    
    NSArray *_stations;
    
    EPDObjectManager *_objectManager;
}

@property (nonatomic, retain) EPDStation * station;
@property (nonatomic, retain) EPDStation * destinationStation;

- (IBAction)showMap:(id)sender;

@end
