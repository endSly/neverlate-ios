//
//  EPDStationDetailViewController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPDStation;
@class EPDTimePanelView;

@interface EPDStationDetailViewController : UITableViewController {
    NSArray *_times;
    EPDTimePanelView *_headerView;
    
    NSArray *_connections;
}

@property (nonatomic, retain) EPDStation * station;

@end
