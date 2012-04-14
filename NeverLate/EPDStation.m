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

+ (NSDictionary *)getCache
{
    static NSDictionary *stationsCache = nil;
    
    if (!stationsCache) {
        NSArray *stations = [[EPDObjectManager sharedManager] findObjectsOfType:self];
        NSMutableArray *ids = [NSMutableArray arrayWithCapacity:stations.count];
        
        for (EPDStation *s in stations) {
            [ids addObject:s.id];
        }
        stationsCache = [NSDictionary dictionaryWithObjects:stations forKeys:ids];
    }
    
    return stationsCache;
}

+ (id)findById:(NSNumber *)id
{
    return [[self getCache] objectForKey:id];
}

+ (NSArray *)findAll
{
    return [[self getCache] allValues];
}

+ (void)findAll:(void(^)(NSArray *))block
{
    block([[self getCache] allValues]);
}

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
    if (!_locations) {
        _locations = [self hasMany:[EPDStationLocation class] foreignKey:@"station_id" value:self.id];
    }
    
    return _locations;
}

- (NSArray *)connections
{
    if (!_connections) {
        NSMutableArray *connections = [[NSMutableArray alloc] initWithCapacity:2];
        
        for (EPDConnection *c in [EPDConnection findAll]) {
            if ([c.station_1_id isEqualToNumber:self.id] || [c.station_2_id isEqualToNumber:self.id])
                [connections addObject:c];
        }
        
        _connections = connections;
    }
    
    return _connections;
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

- (int)getDirectionToStation:(EPDStation *)to
{
    // Returns
    if (self == to)
        return 0;
    
    for (EPDConnection *connection in [EPDConnection findAll]) {
        if (connection.stationFrom == to
            || connection.stationTo == to) {
            return -1;
        }
        
        if (connection.stationFrom == self
            || connection.stationTo == self) {
            return 1;
        }
    }
    return 2; // Should not return 2
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
        EPDStation *otherStation;
        
        if (c.stationFrom == from) { 
            otherStation = c.stationTo;
            dir = 1;
        } else {
            otherStation = c.stationFrom;
            dir = -1;
        }
        
        if (otherStation == last)
            continue;
        
        int t, d;
        [self timeFromStation:otherStation toStation:to lastStation:from time:&t direction:&d];
        
        if (t >= 0) {
            totalTime = t + c.gap.intValue;
            break;
        }
    }
    
    if (!*direction)
        *direction = dir;
    *time = totalTime;
}

@end
