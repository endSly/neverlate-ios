//
//  EPDMetroViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDMetroViewController.h"

#import <math.h>
#import "EPDMetroStationCell.h"
#import "EPDStationDetailViewController.h"
#import "EPDTime.h"
#import "EPDStation.h"
#import "EPDStationLocation.h"

@interface EPDMetroViewController ()

- (float)distanceFrom:(CLLocationCoordinate2D)coordinate toLatitude:(float)lat longitude:(float)lon;

- (void)orderStationsAlphabeticaly;

- (void)orderStationsByProximity;

@end

@implementation EPDMetroViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    _bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    _bannerView.adUnitID = @"a14f75833f65366";
    _bannerView.rootViewController = self;
    [_bannerView loadRequest:[GADRequest request]];
    
    [self reloadAllData];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    
    _reloadTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:YES];
    
    _reloadAllDataTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(reloadAllData) userInfo:nil repeats:YES];
    
    [self.tableView reloadData];
}

- (void)reloadAllData
{
    _stations = [EPDStation findAll];
    _stationsTimes = [NSMutableDictionary dictionaryWithCapacity:_stations.count];
    [self orderStationsByProximity];
}

- (IBAction)orderSelectionChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self orderStationsByProximity];
            break;
            
        case 1:
            [self orderStationsAlphabeticaly];
            break;
    }
    
    [self.tableView reloadData];
}

#define PI 3.14159265f
#define DEG_TO_RAD(deg) ((deg) * PI / 180.0f)

- (float)distanceFrom:(CLLocationCoordinate2D)coordinate toLatitude:(float)lat longitude:(float)lon
{
    const static float R = 6371.0f * 1000.0f;
    const float 
    lat0 = DEG_TO_RAD(lat),
    lat1 = DEG_TO_RAD(coordinate.latitude),
    dLat = lat0 - lat1,
    dLon = DEG_TO_RAD(lon - coordinate.longitude);
    
    const float a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat0) * cos(lat1); 
    const float c = 2 * atan2(sqrt(a), sqrt(1-a)); 
    const float d = R * c;
    
    return d;
}

- (float)headingFrom:(CLLocationCoordinate2D)coordinate toLatitude:(float)lat longitude:(float)lon
{
    const float 
    lat2 = DEG_TO_RAD(lat),
    lat1 = DEG_TO_RAD(coordinate.latitude),
    lon2 = DEG_TO_RAD(lon),
    lon1 = DEG_TO_RAD(coordinate.longitude);
    
    return fmod(
                atan2(
                      sin(lon2-lon1)*cos(lat2),
                      cos(lat1)*sin(lat2)
                      - sin(lat1)*cos(lat2)*cos(lon2-lon1)),
               2*PI);
}

- (void)orderStationsAlphabeticaly
{
    _stations = [_stations sortedArrayUsingComparator:^NSComparisonResult(EPDStation *station1, EPDStation *station2) {
        return [station1.name compare:station2.name];
    }];
}

- (void)orderStationsByProximity
{
    _stations = [_stations sortedArrayUsingComparator:^NSComparisonResult(EPDStation *station1, EPDStation *station2) {
        
        float distance1 = INFINITY, distance2 = INFINITY;
        
        for (EPDStationLocation *loc in station1.stationLocations) {
            distance1 = MIN(distance1, [self distanceFrom:_locationManager.location.coordinate 
                                               toLatitude:loc.lat.floatValue
                                                longitude:loc.lng.floatValue]);
        
        }
        
        for (EPDStationLocation *loc in station2.stationLocations) {
            distance2 = MIN(distance2, [self distanceFrom:_locationManager.location.coordinate 
                                               toLatitude:loc.lat.floatValue
                                                longitude:loc.lng.floatValue]);
            
        }
        
        return distance1 > distance2;
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EPDStationDetailViewController *controller = segue.destinationViewController;
    controller.station = _selectedStation;
    controller.bannerView = _bannerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _stations.count;
}

- (void)updateTimes:(NSArray *)times ofStation:(EPDStation *)station forCell:(EPDMetroStationCell *)cell async:(BOOL)async
{
    
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) 
                                                              fromDate:[NSDate date]];
    
    const int current = comps.hour * 60 + comps.minute;
    
    times = [times sortedArrayUsingComparator:^NSComparisonResult(EPDTime *time1, EPDTime *time2) {
        int time1Diff = time1.time.intValue - current;
        if (time1Diff < 0)
            time1Diff += 24 * 60;
        
        int time2Diff = time2.time.intValue - current;
        if (time2Diff < 0)
            time2Diff += 24 * 60;
        
        return time1Diff > time2Diff;
    }];
    
    [_stationsTimes setObject:times forKey:station.id];
    
    if (cell.station == ((EPDTime *)[times objectAtIndex:0]).station) {
        
        const dispatch_block_t updateCellTimes = ^{
            EPDTime *time1 = [times objectAtIndex:0];
            EPDTime *time2 = [times objectAtIndex:1];
            
            int minutes1 = time1.time.intValue - current + 1;
            int minutes2 = time2.time.intValue - current + 1;
            
            if (minutes1 <= 120) {
                cell.time1Label.text = [NSString stringWithFormat:@"%@ %02i", time1.directionStation.name,  minutes1];
            } else {
                cell.time1Label.text = [NSString stringWithFormat:@"%@ +120", time1.directionStation.name];
            }
            
            if (minutes2 <= 120) {
                cell.time2Label.text = [NSString stringWithFormat:@"%@ %02i", time2.directionStation.name, minutes2];
            } else {
                cell.time2Label.text = [NSString stringWithFormat:@"%@ +120", time2.directionStation.name];
            }
        };
        if (async) {
            dispatch_async(dispatch_get_main_queue(), updateCellTimes);
        } else {
            updateCellTimes();
        }
    }

}

- (void)configureCell:(EPDMetroStationCell *)cell forStation:(EPDStation *)station
{
    cell.station = station;
    cell.textLabel.text = station.name;
    
    float distance = INFINITY;
    EPDStationLocation *location;
    for (EPDStationLocation *loc in station.stationLocations) {
        float d = [self distanceFrom:_locationManager.location.coordinate 
                          toLatitude:loc.lat.floatValue
                           longitude:loc.lng.floatValue];
        if (d < distance) {
            distance = d;
            location = loc;
        }
    }
    
    float heading = [self headingFrom:_locationManager.location.coordinate  
                           toLatitude:location.lat.floatValue 
                            longitude:location.lng.floatValue];
    
    cell.heading = heading - DEG_TO_RAD(_locationManager.heading.trueHeading);
    
    NSArray *times = [_stationsTimes objectForKey:station.id];
    if(!times) {
        [EPDTime findWhere:@"station_id = ? AND daytype = ?" 
                    params:[NSArray arrayWithObjects:station.id, [NSNumber numberWithInt:[EPDTime dayTypeForDate:[NSDate date]]], nil]
                     block:^(NSArray *t) {
                         [self updateTimes:t ofStation:station forCell:cell async:YES];
                     }];
    } else {
        [self updateTimes:times ofStation:station forCell:cell async:NO];
    }
    
    if (distance > 2000.0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1fKm", distance / 1000.0f];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%im", ((int) round(distance / 10.0f)) * 10];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MetroStationCell";
    
    EPDMetroStationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[EPDMetroStationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
        cell.textLabel.font = [UIFont fontWithName:@"AtRotisSemiSans" size:20.0f];
    }

    [self configureCell:cell forStation:[_stations objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _bannerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedStation = [_stations objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"StationDetailSegue" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Location Manager delegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    GADRequest *request = [GADRequest request];
    [request setLocationWithLatitude:newLocation.coordinate.latitude 
                           longitude:newLocation.coordinate.longitude 
                            accuracy:newLocation.horizontalAccuracy];
    [_bannerView loadRequest:request];
    
    [self orderStationsByProximity];
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [self.tableView reloadData];
}

@end
