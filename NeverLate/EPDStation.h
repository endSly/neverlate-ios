//
//  EPDStation.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EPDObjectManager.h"

@interface EPDStation : EPDManagedObject {
    NSArray *_connectedStations;
}

@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *joints;

@property (nonatomic, readonly) NSArray *stationLocations;
@property (nonatomic, readonly) NSArray *connections;
@property (nonatomic, readonly) NSArray *connectedStations;

- (void)timeToStation:(EPDStation *)to time:(int *)time direction:(int *)direction;

@end
