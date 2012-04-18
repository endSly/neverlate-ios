//
//  GTFSDataSource.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/16/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTFSDataSource : NSObject {
    NSArray * agency;
    NSArray * stops;
    NSArray * routes;
    NSArray * trips;
    NSArray * stop_times;
    NSArray * calendar;
    NSArray * calendar_dates;
    NSArray * fare_attributes;
    NSArray * fare_rules;
    NSArray * shapes;
    NSArray * frequencies;
    NSArray * transfers;
    NSArray * feed_info;
}

- (id)initWithPath:(NSString *)path;

- (NSArray *)mapCSV:(NSString *)path;

@end
