//
//  EPDStation.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDStation.h"

#import "EPDConnection.h"
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

- (NSArray *)stationLocations 
{
    return [_objectManager locationsForStation:self];
}

- (NSArray *)connections
{
    return [_objectManager connectionsForStation:self];
}

- (NSArray *)connectedStations
{
    if (!_connectedStations) {
        NSMutableArray *connectedStations = [NSMutableArray arrayWithCapacity:self.connections.count];
        for (EPDConnection *c in self.connections) {
            [connectedStations addObject:c.stationFrom == self ? c.stationTo : c.stationFrom];
        }
        _connectedStations = connectedStations;
    }
    return _connectedStations;
}

- (void)timeToStation:(EPDStation *)to time:(int *)time direction:(int *)direction
{
    *time = 0;
    *direction = 0;
    [self timeFromStation:self toStation:to lastStation:nil time:time direction:direction];
}

- (void)timeFromStation:(EPDStation *)from toStation:(EPDStation *)to lastStation:(EPDStation *)last time:(int *)time direction:(int *)direction
{
    if (from == to) {
        *time = 0;
        return;
    }
    
    int totalTime = -1, dir = 0;
    
    for (EPDConnection *c in from.connections) {
        EPDStation *otherStation = (c.stationFrom == from) ? c.stationTo : c.stationFrom;
        
        if (otherStation == last)
            continue;
        
        int t, d;
        [self timeFromStation:otherStation toStation:to lastStation:from time:&t direction:&d];
        
        if (t >= 0) {
            totalTime = t + c.gap.intValue;
            dir = [from.connections indexOfObject:c];
            break;
        }
    }
    
    *direction = dir;
    *time = totalTime;
}

@end
