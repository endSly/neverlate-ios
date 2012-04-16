//
//  EPDObjectManager.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDObjectManager.h"

#import "EPDStation.h"
#import "EPDStationLocation.h"
#import "EPDConnection.h"
#import "EPDTime.h"

@interface EPDManagedObject (Private)

- (void)setObjectManager:(EPDObjectManager *)manager;

@end

@implementation EPDManagedObject

+ (NSString *)tableName
{
    return @"";
}

- (void)setObjectManager:(EPDObjectManager *)manager
{
    _objectManager = manager;
}

@end


@implementation EPDObjectManager

@synthesize database = _database;
@synthesize color = _color;
@synthesize name = _name;

- (id)initWithDatabasePath:(NSString *)databasePath
{
    self = [super init];
    
    if (self) {
        _database = [FMDatabase databaseWithPath:databasePath];
        _databaseQueue = dispatch_queue_create([databasePath cStringUsingEncoding:NSUTF8StringEncoding], 0);
        
        _queriesCache = [[NSMutableDictionary alloc] initWithCapacity:100];

        [_database openWithFlags:SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX];
    }
    
    return self;
}

- (void)drainCache
{
    [_queriesCache removeAllObjects];
}

- (NSArray *)executeQuery:(NSString *)query withArguments:(NSArray *)args forObjectsOfClass:(Class)class
{
    NSString *queryHash = [NSString stringWithFormat:@"%@%@", query, args];
    NSArray *result = [_queriesCache objectForKey:queryHash];
    
    if (!result) {
        FMResultSet *resultSet = [_database executeQuery:query withArgumentsInArray:args];
        
        NSMutableArray *objects = [[NSMutableArray alloc] init];
        
        while ([resultSet next]) {
            EPDManagedObject* object = [[class alloc] init];
            [object setObjectManager:self];
            for (int i = 0; i < resultSet.columnCount; i++) {
                [object setValue:[resultSet objectForColumnIndex:i] forKey:[resultSet columnNameForIndex:i]];
            }
            
            [objects addObject:object];
        }
        [_queriesCache setObject:objects forKey:queryHash];
        result = objects;
    }
    
    return result;
}

- (NSArray *)findObjectsOfType:(Class)class
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@", [class tableName]];
    return [self executeQuery:query withArguments:nil forObjectsOfClass:class];
}

- (NSArray *)findObjectsOfType:(Class)class  where:(NSString *)predicate params:(NSArray *)params
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE %@", [class tableName], predicate];
    return [self executeQuery:query withArguments:params forObjectsOfClass:class];
}

- (void)findObjectsOfType:(Class)class block:(void(^)(NSArray *))block
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(_databaseQueue, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        block([self findObjectsOfType:class]);
    });
}

- (void)findObjectsOfType:(Class)class  where:(NSString *)predicate params:(NSArray *)params block:(void(^)(NSArray *))block
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(_databaseQueue, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        block([self findObjectsOfType:class where:predicate params:params]);
    });
}

- (NSArray *)allStations
{
    if (!_allStations) {
        NSArray *stations = [self findObjectsOfType:[EPDStation class]];
        NSMutableDictionary *allStations = [NSMutableDictionary dictionaryWithCapacity:stations.count];
        
        for (EPDStation *s in stations) {
            [allStations setObject:s forKey:s.id];
        }
        _allStations = allStations;
    }
    
    return [_allStations allValues];
}

- (EPDStation *)stationWithId:(NSNumber *)stationId
{
    if (!_allStations) {
        [self allStations];
    }
    return [_allStations objectForKey:stationId];
}

- (NSArray *)locationsForStation:(EPDStation *)station
{
    if (!_allLocations) {
        _allLocations = [NSMutableDictionary dictionaryWithCapacity:[self allStations].count];
    }
    
    NSArray *locations = [_allLocations objectForKey:station.id];
    if (!locations) {
        locations = [self findObjectsOfType:[EPDStationLocation class] where:@"station_id = ?" params:[NSArray arrayWithObject:station.id]];
        [_allLocations setObject:locations forKey:station.id];
    }
    return locations;
}

- (NSArray *)connectionsForStation:(EPDStation *)station
{
    if (!_allConnections) {
        _allConnections = [NSMutableDictionary dictionaryWithCapacity:[self allStations].count];
    }
    
    NSArray *connections = [_allConnections objectForKey:station.id];
    if (!connections) {
        connections = [self findObjectsOfType:[EPDConnection class] where:@"station_1_id = ? OR station_2_id = ?" params:[NSArray arrayWithObjects:station.id, station.id, nil]];
        [_allConnections setObject:connections forKey:station.id];
    }
    return connections;
}

- (NSArray *)timesForStation:(EPDStation *)station date:(NSDate *)date
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) 
                                                              fromDate:date];
    
    int daytype = [EPDTime dayTypeForWeekday:comps.weekday];
    int nextDaytype = [EPDTime dayTypeForWeekday:((comps.weekday % 7) + 1)];
    
    NSArray *times = [self findObjectsOfType:[EPDTime class] 
                                       where:@"station_id = ? AND daytype = ?" 
                                      params:[NSArray arrayWithObjects:station.id, [NSNumber numberWithInt:daytype], nil]];
    
    if (comps.hour > 22 && nextDaytype != daytype) {
        // Merge two days times
        
        int currentTime = comps.hour * 60 + comps.minute;
        NSMutableArray *resultTimes = [NSMutableArray arrayWithCapacity:times.count * 1.2];
        
        NSArray *nextTimes = [self findObjectsOfType:[EPDTime class] 
                                               where:@"station_id = ? AND daytype = ?" 
                                              params:[NSArray arrayWithObjects:station.id, [NSNumber numberWithInt:nextDaytype], nil]];
        
        for (EPDTime *t in times) {
            if (t.time.intValue >= currentTime) {
                [resultTimes addObject:t];
            }
        }
        
        for (EPDTime *t in nextTimes) {
            if (t.time.intValue < currentTime) {
                [resultTimes addObject:t];
            }
        }
        
        return resultTimes;
    }
    
    return times;
}

- (void)timesForStation:(EPDStation *)station date:(NSDate *)date block:(void(^)(NSArray *))block
{
    dispatch_async(_databaseQueue, ^{
        block([self timesForStation:station date:date]);
    });
}

@end
