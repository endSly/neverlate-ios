//
//  EPDConnection.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDConnection.h"

#import "EPDStation.h"

@implementation EPDConnection

@synthesize station_1_id;
@synthesize station_2_id;
@synthesize gap;

+ (NSString *)tableName
{
    return @"connections";
}

- (EPDStation *)stationFrom
{
    return [_objectManager stationWithId:self.station_1_id];
}

- (EPDStation *)stationTo
{
    return [_objectManager stationWithId:self.station_2_id];
}

@end
