//
//  EPDObjectManager.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FMDatabase.h>

@interface EPDManagedObject : NSObject <NSCoding>

+ (NSString *)tableName;

+ (void)findAll:(void(^)(NSArray *))block;
+ (void)findWhere:(NSString *)predicate params:(NSArray *)params block:(void(^)(NSArray *))block;

- (NSArray *)hasMany:(__unsafe_unretained Class)class foreignKey:(NSString *)key value:(NSObject *)value;
- (EPDManagedObject *)hasOne:(__unsafe_unretained Class)class foreignKey:(NSString *)key value:(NSObject *)value;
- (EPDManagedObject *)belongsTo:(__unsafe_unretained Class)class foreignKey:(NSString *)key value:(NSObject *)value;

@end

@interface EPDObjectManager : NSObject {
    dispatch_queue_t _databaseQueue;
    
    NSMutableDictionary *_queuesCache;
}

@property (nonatomic, readonly) FMDatabase * database;

+ (EPDObjectManager *)sharedManager;

- (NSArray *)findObjectsOfType:(__unsafe_unretained Class)class;
- (NSArray *)findObjectsOfType:(__unsafe_unretained Class)class  where:(NSString *)predicate params:(NSArray *)params;

- (void)findObjectsOfType:(__unsafe_unretained Class)class block:(void(^)(NSArray *))block;
- (void)findObjectsOfType:(__unsafe_unretained Class)class  where:(NSString *)predicate params:(NSArray *)params block:(void(^)(NSArray *))block;

@end
