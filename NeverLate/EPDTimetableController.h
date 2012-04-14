//
//  EPDTimetableController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/4/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <TapkuLibrary/TapkuLibrary.h>

@class EPDStation;

@interface EPDTimetableController : TKCalendarMonthTableViewController {
    NSArray *_stations;
    
    EPDStation *_originStation;
    EPDStation *_destinationStation;
    
    NSDate *_date;
}

@end
