//
//  EPDConnection.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDObjectManager.h"

@class EPDStation;

@interface EPDConnection : EPDManagedObject

@property (nonatomic, retain) NSNumber *station_1_id;
@property (nonatomic, retain) NSNumber *station_2_id;
@property (nonatomic, retain) NSNumber *gap;

@property (nonatomic, readonly) EPDStation *stationFrom;
@property (nonatomic, readonly) EPDStation *stationTo;

@end
