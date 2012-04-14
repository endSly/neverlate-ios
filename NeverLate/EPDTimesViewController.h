//
//  EPDTimesViewController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/5/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPDStation;

@interface EPDTimesViewController : UITableViewController {
    NSArray *_times;
    
    int _travelTime;
    int _direction;
}

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) EPDStation *originStation;
@property (nonatomic, retain) EPDStation *destinationStation;

@end
