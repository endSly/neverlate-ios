//
//  EPDMetroViewController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class EPDStation;

@interface EPDMetroViewController : UITableViewController <CLLocationManagerDelegate> {
    NSArray *_stations;
    
    EPDStation *_selectedStation;
    
    CLLocationManager *_locationManager;
}

- (IBAction)orderSelectionChanged:(UISegmentedControl *)sender;

@end
