//
//  EPDObjectManager.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDObjectManager.h"

@implementation EPDManagedObject

+ (id)findById:(NSNumber *)id
{
    return [[[EPDObjectManager sharedManager] 
             findObjectsOfType:self where:@"id = ?" params:[NSArray arrayWithObject:id]]
            lastObject];
}

+ (NSArray *)findAll
{
    return [[EPDObjectManager sharedManager] findObjectsOfType:self];
}

+ (NSArray *)findWhere:(NSString *)predicate params:(NSArray *)params
{
    return [[EPDObjectManager sharedManager] findObjectsOfType:self where:predicate params:params];
}

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
        
        _queriesCache = [[NSMutableDictionary alloc] initWithCapacity:100];

        [_databse open];
    }
    
    return self;
}

- (void)drainCache
{
    [_queriesCache removeAllObjects];
}

- (NSArray *)executeQuery:(NSString *)query withArguments:(NSArray *)args forObjectsOfClass:(__unsafe_unretained Class)class
{
    NSString *queryHash = [NSString stringWithFormat:@"%@%@", query, args];
    NSArray *result = [_queriesCache objectForKey:queryHash];
    
    if (!result) {
        FMResultSet *resultSet = [_databse executeQuery:query withArgumentsInArray:args];
        
        NSMutableArray *objects = [[NSMutableArray alloc] init];
        
        while ([resultSet next]) {
            EPDManagedObject* object = [[class alloc] init];
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

- (NSArray *)findObjectsOfType:(__unsafe_unretained Class)class
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@", [class tableName]];
    return [self executeQuery:query withArguments:nil forObjectsOfClass:class];
}

- (NSArray *)findObjectsOfType:(__unsafe_unretained Class)class  where:(NSString *)predicate params:(NSArray *)params
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE %@", [class tableName], predicate];
    return [self executeQuery:query withArguments:params forObjectsOfClass:class];
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
