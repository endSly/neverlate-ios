//
//  EPDObjectManager.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDObjectManager.h"

@implementation EPDManagedObject

+ (void)findAll:(void(^)(NSArray *))block
{
    [[EPDObjectManager sharedManager] findObjectsOfType:self block:block];
}

+ (void)findWhere:(NSString *)predicate params:(NSArray *)params block:(void(^)(NSArray *))block
{
    [[EPDObjectManager sharedManager] findObjectsOfType:self where:predicate params:params block:block];
}

- (NSArray *)hasMany:(__unsafe_unretained Class)class foreignKey:(NSString *)key value:(NSObject *)value
{
    return [[EPDObjectManager sharedManager] findObjectsOfType:class 
                                                         where:[NSString stringWithFormat:@"%@ = ?", key] 
                                                        params:[NSArray arrayWithObject:value]];
}

- (EPDManagedObject *)hasOne:(__unsafe_unretained Class)class foreignKey:(NSString *)key value:(NSObject *)value
{
    return [[[EPDObjectManager sharedManager] findObjectsOfType:class 
                                                         where:[NSString stringWithFormat:@"%@ = ?", key] 
                                                        params:[NSArray arrayWithObject:value]]
            lastObject];
}

- (EPDManagedObject *)belongsTo:(__unsafe_unretained Class)class foreignKey:(NSString *)key value:(NSObject *)value
{
    return [[[EPDObjectManager sharedManager] findObjectsOfType:class 
                                                          where:[NSString stringWithFormat:@"%@ = ?", key] 
                                                         params:[NSArray arrayWithObject:value]]
            lastObject];
}

@end


@implementation EPDObjectManager

@synthesize database = _databse;

+ (EPDObjectManager *)sharedManager
{
    static EPDObjectManager *manager = nil;
    
    if (!manager) {
        manager = [[EPDObjectManager alloc] init];
    }
    return manager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _databse = [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"metro-times" ofType:@"sqlite3"]];
        _databaseQueue = dispatch_queue_create("databaseDispatchQueue", 0);
        
        _queuesCache = [[NSMutableDictionary alloc] initWithCapacity:20];

        [_databse open];
    }
    
    return self;
}

- (NSArray *)findObjectsOfType:(__unsafe_unretained Class)class
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@", [class tableName]];
    FMResultSet *resultSet = [_databse executeQuery:query];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    while ([resultSet next]) {
        EPDManagedObject* object = [[class alloc] init];
        for (int i = 0; i < resultSet.columnCount; i++) {
            [object setValue:[resultSet objectForColumnIndex:i] forKey:[resultSet columnNameForIndex:i]];
        }
        [objects addObject:object];
    }
    
    return objects;
}

- (NSArray *)findObjectsOfType:(__unsafe_unretained Class)class  where:(NSString *)predicate params:(NSArray *)params
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE %@", [class tableName], predicate];
    FMResultSet *resultSet = [_databse executeQuery:query withArgumentsInArray:params];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    while ([resultSet next]) {
        EPDManagedObject* object = [[class alloc] init];
        for (int i = 0; i < resultSet.columnCount; i++) {
            [object setValue:[resultSet objectForColumnIndex:i] forKey:[resultSet columnNameForIndex:i]];
        }
        
        
        [objects addObject:object];
    }
    
    return objects;
}

- (void)findObjectsOfType:(__unsafe_unretained Class)class block:(void(^)(NSArray *))block
{
    dispatch_async(_databaseQueue, ^{
        block([self findObjectsOfType:class]);
    });
}

- (void)findObjectsOfType:(__unsafe_unretained Class)class  where:(NSString *)predicate params:(NSArray *)params block:(void(^)(NSArray *))block
{
    dispatch_async(_databaseQueue, ^{
        block([self findObjectsOfType:class where:predicate params:params]);
    });
}

@end
