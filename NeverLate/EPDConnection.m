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

+ (NSArray *)getCache
{
    static NSArray *connectionsCache = nil;
    
    if (!connectionsCache) {
        connectionsCache = [[EPDObjectManager sharedManager] findObjectsOfType:self];
    }
    
    return connectionsCache;
}

+ (NSArray *)findAll
{
    return [self getCache];
}

+ (void)findAll:(void(^)(NSArray *))block
{
    block([self getCache]);
}


+ (NSString *)tableName
{
    return @"connections";
}

- (EPDStation *)stationFrom
{
    return [EPDStation findById:self.station_1_id];
}

- (EPDStation *)stationTo
{
    return [EPDStation findById:self.station_2_id];
}

@end
