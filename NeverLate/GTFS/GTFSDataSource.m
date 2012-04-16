//
//  GTFSDataSource.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/16/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "GTFSDataSource.h"

#import "CSVParser.h"

@implementation GTFSDataSource

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        CSVParser *parser = [[CSVParser alloc] initWithFile:@"/Users/endika/Downloads/google_transit/stop_times.txt"];
        NSArray *a = [parser parseFile];
        NSLog(@"%@", a);
    }
    return self;
}

@end
