//
//  EPDTime.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDTime.h"

#import "EPDStation.h"

@implementation EPDTime

@synthesize station_id;
@synthesize direction;
@synthesize daytype;
@synthesize time;

+ (NSString *)tableName
{
    return @"times";
}

- (EPDStation *)directionStation
{
    return (EPDStation *) [self hasOne:[EPDStation class] foreignKey:@"id" value:self.direction];
}

- (EPDStation *)station
{
    return (EPDStation *) [self belongsTo:[EPDStation class] foreignKey:@"id" value:self.station_id];
}

@end
