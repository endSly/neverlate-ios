//
//  EPDStationLocation.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDObjectManager.h"

@interface EPDStationLocation : EPDManagedObject

@property (nonatomic, retain) NSNumber *station_id;
@property (nonatomic, retain) NSNumber *lat;
@property (nonatomic, retain) NSNumber *lng;
@property (nonatomic, retain) NSNumber *location_name;

@end
