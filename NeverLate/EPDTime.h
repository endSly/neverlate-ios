//
//  EPDTime.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDObjectManager.h"

@class EPDStation;

@interface EPDTime : EPDManagedObject

@property (nonatomic, retain) NSNumber *station_id;
@property (nonatomic, retain) NSNumber *direction;
@property (nonatomic, retain) NSNumber *daytype;
@property (nonatomic, retain) NSNumber *time;
@property (nonatomic, readonly) NSInteger timeInt;

@property (nonatomic, readonly) EPDStation *directionStation;
@property (nonatomic, readonly) EPDStation *station;

+ (int)dayTypeForWeekday:(int)weekday;
+ (int)dayTypeForDate:(NSDate *)date;

@end
