//
//  EPDObjectManager.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FMDatabase.h>

@class EPDObjectManager;

@interface EPDManagedObject : NSObject {
    EPDObjectManager *_objectManager;
}

+ (NSString *)tableName;

- (NSArray *)hasMany:(Class)class foreignKey:(NSString *)key value:(NSObject *)value;
- (EPDManagedObject *)hasOne:(Class)class foreignKey:(NSString *)key value:(NSObject *)value;
- (EPDManagedObject *)belongsTo:(Class)class foreignKey:(NSString *)key value:(NSObject *)value;

@end

@class EPDStation;

@interface EPDObjectManager : NSObject {
    dispatch_queue_t _databaseQueue;
    
    NSMutableDictionary *_queriesCache;
    
    NSMutableDictionary *_allStations;
    NSMutableDictionary *_allConnections;
    NSMutableDictionary *_allLocations;
}

@property (nonatomic, readonly) FMDatabase * database;

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) UIColor * color;

- (id)initWithDatabasePath:(NSString *)databasePath;

- (void)drainCache;

- (NSArray *)cachedObjectsOfType:(Class)class  where:(NSString *)predicate params:(NSArray *)params;

- (NSArray *)findObjectsOfType:(Class)class;
- (NSArray *)findObjectsOfType:(Class)class  where:(NSString *)predicate params:(NSArray *)params;

- (void)findObjectsOfType:(Class)class block:(void(^)(NSArray *))block;
- (void)findObjectsOfType:(Class)class  where:(NSString *)predicate params:(NSArray *)params block:(void(^)(NSArray *))block;

- (NSArray *)allStations;
- (EPDStation *)stationWithId:(NSNumber *)stationId;
- (NSArray *)locationsForStation:(EPDStation *)station;
- (NSArray *)connectionsForStation:(EPDStation *)station;
- (NSArray *)timesForStation:(EPDStation *)station date:(NSDate *)date;
- (void)timesForStation:(EPDStation *)station date:(NSDate *)date block:(void(^)(NSArray *))block;

@end
