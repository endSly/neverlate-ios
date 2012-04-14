//
//  EPDStationDetailViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDStationDetailViewController.h"

#import "EPDTimePanelView.h"
#import "EPDStation.h"
#import "EPDConnection.h"
#import "EPDTime.h"
#import "EPDStationLocation.h"
#import "EPDMapViewController.h"


@interface EPDStationDetailViewController ()

- (void)reloadTimeTable;

@end

@implementation EPDStationDetailViewController

@synthesize station = _station;
@synthesize destinationStation = _destinationStation;
@synthesize bannerView = _bannerView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = _station.name;
    
    _headerView = [[EPDTimePanelView alloc] init];
    
    NSMutableArray *mutableStations = [[EPDStation findAll] mutableCopy];
    [mutableStations removeObject:_station];
    _stations = [mutableStations sortedArrayUsingComparator:^NSComparisonResult(EPDStation *obj1, EPDStation *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    
    _timeRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 
                                                         target:self 
                                                       selector:@selector(reloadTimeTable) 
                                                       userInfo:nil 
                                                        repeats:YES];
    
    _connections = [EPDConnection findAll];
    
    [self reloadTimeTable];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
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

- (void)reloadTimeTable
{
    NSNumber *daytype = [NSNumber numberWithInt:[EPDTime dayTypeForDate:[NSDate date]]];
    
    NSArray *times = [EPDTime findWhere:@"station_id = ? AND daytype = ?" 
                                 params:[NSArray arrayWithObjects:_station.id, daytype, nil]];
    
    [self updateTimes:times];
}

- (IBAction)showMap:(id)sender
{
    [self performSegueWithIdentifier:@"StationMapSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EPDMapViewController *mapController = segue.destinationViewController;
    mapController.stationToShow = self.station;
}

- (void)updateTimes:(NSArray *)times
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) 
                                                              fromDate:[NSDate date]];
    
    const int current = comps.hour * 60 + comps.minute;
    _times = [times sortedArrayUsingComparator:^NSComparisonResult(EPDTime *time1, EPDTime *time2) {
        int time1Diff = time1.time.intValue - current;
        if (time1Diff < 0)
            time1Diff += 24 * 60;
        
        int time2Diff = time2.time.intValue - current;
        if (time2Diff < 0)
            time2Diff += 24 * 60;
        
        return time1Diff > time2Diff;
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTimeTable];
    });
    
       
    [self.tableView reloadData];
}

- (void)updateTimeTable
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) 
                                                              fromDate:[NSDate date]];
    
    const int current = comps.hour * 60 + comps.minute;
    
    int stationDirection = 0, totalTime = 0;
    if (self.destinationStation) {
        [self.station  timeToStation:self.destinationStation time:&totalTime  direction:&stationDirection];
        NSLog(@"From: %@ To: %@ Time:%i Direction: %i", self.station.name, self.destinationStation.name, totalTime, stationDirection);
    }
    
    EPDTime *soonTimes[4] = {nil, nil, nil, nil};
    int dir1 = 0, dir2 = 0, dir0 = 0;
    
    for (EPDTime *time in _times) {
        int direction = [_station getDirectionToStation:time.directionStation];
        if (direction == 0)
            dir0++;
        
        if (direction < 0 && dir1 < 2 && !(self.destinationStation && stationDirection > 0)) {
            soonTimes[dir1] = time;
            dir1++;
        }
        
        if (direction > 0 && dir2 < 2 &&  !(self.destinationStation && stationDirection < 0)) {
            soonTimes[2 + dir2] = time;
            dir2++;
        }
        
        if (dir0 + dir1 + dir2 > 4)
            break;
    }
    
    if (self.destinationStation) {
        int time, direction;
        [_station timeToStation:self.destinationStation time:&time direction:&direction];
        _headerView.stationLabel.text = [NSString stringWithFormat:@"%@ > %@ en %i minutos", _station.name, self.destinationStation.name, time];
    } else {
        _headerView.stationLabel.text = _station.name;
    }
    
    EPDTime *time = soonTimes[0];
    if (time) {
        _headerView.dest1Label1.text = time.directionStation.name;
        NSLog(@"%i, %i - %i", time.time.intValue - current + 1, time.time.intValue, current);
        int waitTime = time.time.intValue - current + 1;
        if (waitTime < 0 || waitTime > 120)
            _headerView.time1Label1.text = [NSString stringWithFormat:@"+120"];
        else
            _headerView.time1Label1.text = [NSString stringWithFormat:@"%i", waitTime];
    } else {
        _headerView.dest1Label1.text = nil;
        _headerView.time1Label1.text = nil;
        _headerView.time1Label1.text = nil;
        
    }
    time = soonTimes[1];
    if (time) {
        _headerView.dest1Label2.text = time.directionStation.name;
        int waitTime = time.time.intValue - current + 1;
        if (waitTime < 0 || waitTime > 120)
            _headerView.time1Label2.text = [NSString stringWithFormat:@"+120"];
        else
            _headerView.time1Label2.text = [NSString stringWithFormat:@"%i", waitTime];
    } else {
        _headerView.dest1Label2.text = nil;
        _headerView.time1Label2.text = nil;
        _headerView.time1Label2.text = nil;
        
    }
    time = soonTimes[2];
    if (time) {
        _headerView.dest2Label1.text = time.directionStation.name;
        int waitTime = time.time.intValue - current + 1;
        if (waitTime < 0 || waitTime > 120)
            _headerView.time2Label1.text = [NSString stringWithFormat:@"+120"];
        else
            _headerView.time2Label1.text = [NSString stringWithFormat:@"%i", waitTime];
    } else {
        _headerView.dest2Label1.text = nil;
        _headerView.time2Label1.text = nil;
        _headerView.time2Label1.text = nil;
        
    }
    time = soonTimes[3];
    if (time) {
        _headerView.dest2Label2.text = time.directionStation.name;
        int waitTime = time.time.intValue - current + 1;
        if (waitTime < 0 || waitTime > 120)
            _headerView.time2Label2.text = [NSString stringWithFormat:@"+120"];
        else
            _headerView.time2Label2.text = [NSString stringWithFormat:@"%i", waitTime];
    } else {
        _headerView.dest2Label2.text = nil;
        _headerView.time2Label2.text = nil;
        _headerView.time2Label2.text = nil;
        
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.destinationStation) {
        return _times.count;
    }
    return _stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static UIFont *font = nil;
    if (!font)
        font = [UIFont fontWithName:@"AtRotisSemiSans" size:18.0f];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = font;
    }

    if (self.destinationStation) {
        EPDTime *time = [_times objectAtIndex:indexPath.row];
        
        cell.textLabel.text = time.directionStation.name;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i:%02i", time.time.intValue / 60, time.time.intValue % 60];
        
    } else {
        EPDStation *station = [_stations objectAtIndex:indexPath.row];
        cell.textLabel.text = station.name;
        
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _bannerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 192.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.destinationStation) {
        self.destinationStation = [_stations objectAtIndex:indexPath.row];
        
        int direction = [_station getDirectionToStation:self.destinationStation];
        NSMutableArray *newTimes = [NSMutableArray arrayWithCapacity:_times.count / 2];
        for (EPDTime *t in _times) {
            if ([_station getDirectionToStation:t.directionStation] == direction)
                [newTimes addObject:t];
        }
        _times = newTimes;
        
        [self.tableView reloadData];
        [self updateTimeTable];
        self.tableView.contentOffset = CGPointMake(0,0);
    }
}

@end
