//
//  EPDMetroViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDMetroViewController.h"

#import <math.h>
#import "EPDSlidingViewController.h"
#import "EPDMetroStationCell.h"
#import "EPDStationDetailViewController.h"
#import "EPDTime.h"
#import "EPDStation.h"
#import "EPDStationLocation.h"
#import "EPDMenuViewController.h"
#import "ECSlidingViewController.h"

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
    
    self.navigationController.navigationBar.layer.shadowRadius = 4.0;
    self.navigationController.navigationBar.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.navigationController.navigationBar.layer.masksToBounds = NO;
    self.navigationController.navigationBar.layer.shouldRasterize = YES;
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0,4);
    
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [menuButton setImage:[UIImage imageNamed:@"ShowMenu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    _sortButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_sortButton setImage:[UIImage imageNamed:@"MenuSortAlphabetically"] forState:UIControlStateNormal];
    [_sortButton addTarget:self action:@selector(orderSelectionChanged:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_sortButton];
    
    self.navigationController.navigationBar.tintColor = ((EPDSlidingViewController *) self.slidingViewController).objectManager.color;
    self.title = ((EPDSlidingViewController *) self.slidingViewController).objectManager.name;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0xc0 / 255.0 green:0xc0 / 255.0 blue:0xc0 / 255.0 alpha:1];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    
    _reloadTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(reloadData) userInfo:nil repeats:YES];
    
    _reloadAllDataTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(reloadAllData) userInfo:nil repeats:YES];
    
    [self reloadAllData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadData];
}

- (void)reloadData
{
    [self.tableView reloadData];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) 
                                                              fromDate:[NSDate date]];
    
    _currentTime = comps.hour * 60 + comps.minute;
    
    [self order];
}

- (void)reloadAllData
{
    _stations = [((EPDSlidingViewController *) self.slidingViewController).objectManager allStations];
    _stationsTimes = [NSMutableDictionary dictionaryWithCapacity:_stations.count];
    
    [self reloadData];
}

- (void)order
{
    switch (_stationsOrder) {
        case 0:
            [self orderStationsByProximity];
            break;
            
        case 1:
            [self orderStationsAlphabeticaly];
            break;
    }
    
    [self.tableView reloadData];
}

- (IBAction)orderSelectionChanged:(id)sender
{
    if (_stationsOrder == 0) {
        [_sortButton setImage:[UIImage imageNamed:@"MenuRadar"] forState:UIControlStateNormal];
        _stationsOrder = 1;
    } else {
        [_sortButton setImage:[UIImage imageNamed:@"MenuSortAlphabetically"] forState:UIControlStateNormal];
        _stationsOrder = 0;
    }
    
    [self order];
}

- (IBAction)showMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
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
    @try {
        if (async || ((EPDTime *)[times objectAtIndex:0]).timeInt < _currentTime) {
            times = [times sortedArrayUsingComparator:^NSComparisonResult(EPDTime *time1, EPDTime *time2) {
                int time1Diff = time1.timeInt - _currentTime;
                if (time1Diff < 0)
                    time1Diff += 24 * 60;
                
                int time2Diff = time2.timeInt - _currentTime;
                if (time2Diff < 0)
                    time2Diff += 24 * 60;
                
                return time1Diff > time2Diff;
            }];
        }
        
        [_stationsTimes setObject:times forKey:station.id];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    
    
    const dispatch_block_t updateCellTimes = ^{
        @try {
            if (cell.station != ((EPDTime *)[times objectAtIndex:0]).station)
                return;
            
            // Get next times
            int index = 0;
            EPDTime *time1 = nil;
            while (!time1 && index < times.count) {
                EPDTime *t = [times objectAtIndex:index];
                if (t.directionStation != station)
                    time1 = t;
                index++;
            }
            EPDTime *time2 = nil;
            while (!time2 && index < times.count) {
                EPDTime *t = [times objectAtIndex:index];
                if (t.directionStation != station)
                    time2 = t;
                index++;
            }
            
            int minutes1 = time1.timeInt - _currentTime + 1;
            int minutes2 = time2.timeInt - _currentTime + 1;
            
            if (minutes1 <= 0)
                minutes1 += 24*60;
            if (minutes2 <= 0)
                minutes2 += 24*60;
            
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
        }
        @catch (NSException *exception) {
            NSLog(@"Eception: %@", exception);
        }
        
    };
    if (async) {
        dispatch_async(dispatch_get_main_queue(), updateCellTimes);
    } else {
        updateCellTimes();
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
        [((EPDSlidingViewController *) self.slidingViewController).objectManager timesForStation:station date:[NSDate date] block:^(NSArray *t) {
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
    }

    [self configureCell:cell forStation:[_stations objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
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
    
    [self order];
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [self.tableView reloadData];
}

@end
