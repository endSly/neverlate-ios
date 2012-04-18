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
        [self mapCSV:@"/Users/endika/Downloads/transitemt/stop_times.txt"];
        
    }
    return self;
}

- (NSArray *)mapCSV:(NSString *)path
{
    CSVParser *parser = [[CSVParser alloc] initWithFile:path];
    NSLog(@"begin");
    [parser parseFileLines:^(NSArray *line) {
        //NSLog(@"%@", line);
    }];
    NSLog(@"end");
    return nil;
}

@end
