//
//  EPDStation.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDStation.h"

#import "EPDStationLocation.h"
#import "EPDTime.h"

@implementation EPDStation

@synthesize id;
@synthesize name;
@synthesize joints;

+ (NSString *)tableName
{
    return @"stations";
}

- (NSArray *)times 
{
    return [self hasMany:[EPDTime class] foreignKey:@"station_id" value:self.id];
}

- (NSArray *)stationLocations 
{
    return [self hasMany:[EPDStationLocation class] foreignKey:@"station_id" value:self.id];
}


@end
