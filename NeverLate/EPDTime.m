//
//  EPDTime.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDTime.h"

#import "EPDStation.h"

static const int daytypes[] = {-1, 3, 0, 0, 0, 0, 1, 2}; // Sunday is 1

@implementation EPDTime

@synthesize station_id;
@synthesize direction;
@synthesize daytype;
@synthesize time;

+ (int)dayTypeForDate:(NSDate *)date
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSWeekdayCalendarUnit) fromDate:date];
    
    return daytypes[comps.weekday];
}

+ (NSString *)tableName
{
    return @"times";
}

- (EPDStation *)directionStation
{
    return [_objectManager stationWithId:self.direction];
}

- (EPDStation *)station
{
    return [_objectManager stationWithId:self.station_id];
}



@end
