//
//  EPDStationLocation.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDStationLocation.h"

@implementation EPDStationLocation

@synthesize station_id;
@synthesize lat;
@synthesize lng;
@synthesize location_name;

+ (NSString *)tableName
{
    return @"station_locations";
}

@end
