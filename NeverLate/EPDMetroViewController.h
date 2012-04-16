//
//  EPDMetroViewController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GADBannerView.h"

@class EPDStation;

@interface EPDMetroViewController : UITableViewController <CLLocationManagerDelegate> {
    NSArray *_stations;
    
    EPDStation *_selectedStation;
    
    NSInteger _stationsOrder;
    
    CLLocationManager *_locationManager;
    
    NSMutableDictionary *_stationsTimes;
    
    NSTimer *_reloadTimer;
    NSTimer *_reloadAllDataTimer;
    
    GADBannerView *_bannerView;
    
    int _currentTime; // In minutes from 00:00
    
    UIButton *_sortButton;
}

- (IBAction)orderSelectionChanged:(id)sender;

- (IBAction)showMenu:(id)sender;

@end
