//
//  EPDStationDetailViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDStationDetailViewController.h"

#import "EPDSlidingViewController.h"
#import "EPDTimePanelView.h"
#import "EPDStation.h"
#import "EPDConnection.h"
#import "EPDTime.h"
#import "EPDStationLocation.h"
#import "EPDMapViewController.h"
#import "CustomNavigationBar.h"

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

    _objectManager = ((EPDSlidingViewController *) self.slidingViewController).objectManager;
    
    self.title = _station.name;
    
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [menuButton setImage:[UIImage imageNamed:@"MenuNavigate"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    UIButton* backButton = [((CustomNavigationBar *)self.navigationController.navigationBar) backButtonWith:[UIImage imageNamed:@"BarBackButton.png"] highlight:nil leftCapWidth:14.0];
    backButton.titleLabel.textColor = [UIColor colorWithRed:254.0/255.0 green:239.0/255.0 blue:218.0/225.0 alpha:1];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    _headerView = [[EPDTimePanelView alloc] initWithPanelsCount:_station.connections.count];
    
    NSMutableArray *mutableStations = [[_objectManager allStations] mutableCopy];
    [mutableStations removeObject:_station];
    _stations = [mutableStations sortedArrayUsingComparator:^NSComparisonResult(EPDStation *obj1, EPDStation *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    
    _timeRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 
                                                         target:self 
                                                       selector:@selector(reloadTimeTable) 
                                                       userInfo:nil 
                                                        repeats:YES];
    
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
    [self updateTimes:[_objectManager timesForStation:_station date:[NSDate date]]];
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
        int time1Diff = time1.timeInt - current;
        if (time1Diff < 0)
            time1Diff += 24 * 60;
        
        int time2Diff = time2.timeInt - current;
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
    @try {
        
        _headerView.stationLabel.backgroundColor = _objectManager.color;
        if (self.destinationStation) {
            int time, direction;
            [_station timeToStation:self.destinationStation time:&time direction:&direction];
            _headerView.stationLabel.text = [NSString stringWithFormat:@"%@ > %@ en %i minutos", _station.name, self.destinationStation.name, time];
        } else {
            _headerView.stationLabel.text = _station.name;
        }
        
        
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) 
                                                                  fromDate:[NSDate date]];
        
        const int current = comps.hour * 60 + comps.minute;
        
        int stationDirection = 0, totalTime = 0;
        if (self.destinationStation) {
            [self.station  timeToStation:self.destinationStation time:&totalTime  direction:&stationDirection];
            NSLog(@"From: %@ To: %@ Time:%i Direction: %i", self.station.name, self.destinationStation.name, totalTime, stationDirection);
        }
        
        int connectionsCount = MAX(1, self.destinationStation ? 1 : _station.connections.count);
        NSMutableArray *soonTimes = [NSMutableArray arrayWithCapacity:connectionsCount];
        for (int i = 0; i < connectionsCount; i++) {
            [soonTimes addObject:[NSMutableArray arrayWithCapacity:2]];
        }
        
        int timesAdded = 0;
        
        for (EPDTime *time in _times) {
            int direction, t;
            [self.station  timeToStation:time.directionStation time:&t  direction:&direction];
            
            if (!t 
                || direction < 0 
                || (self.destinationStation && stationDirection != direction)) {
                continue;
            }
            
            NSMutableArray *times = [soonTimes objectAtIndex:self.destinationStation ? 0 : direction];
            if (times.count > 2)
                continue;
            
            [times addObject:time];
            
            if (++timesAdded > connectionsCount * 2)
                break;
            
        }
        
        for (int i = 0; i < connectionsCount; i++) {
            @try {
                EPDPanelView *panel = [_headerView.panels objectAtIndex:i];
                EPDTime *time1 = [[soonTimes objectAtIndex:i] objectAtIndex:0];
                
                panel.destLabel1.text = time1.directionStation.name;
                int minutes1 = time1.timeInt - current + 1;
                if (minutes1 <= 0)
                    minutes1 += 24*60;
                if (minutes1 >= 120) {
                    panel.timeLabel1.text = @"+120";
                } else {
                    panel.timeLabel1.text = [NSString stringWithFormat:@"%i", minutes1];
                }
                
                EPDTime *time2 = [[soonTimes objectAtIndex:i] objectAtIndex:1];
                panel.destLabel2.text = time2.directionStation.name;
                int minutes2 = time2.timeInt - current + 1;
                if (minutes2 <= 0)
                    minutes2 += 24*60;
                if (minutes2 >= 120) {
                    panel.timeLabel2.text = @"+120";
                } else {
                    panel.timeLabel2.text = [NSString stringWithFormat:@"%i", minutes2];
                }
                
            }
            @catch (NSException *exception) {
                NSLog(@"Exception: %@", exception);
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in %@#updateTimeTable: %@", self.class, exception);
    }
    @finally {
        [self.tableView reloadData];
    }
    
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
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i:%02i", time.timeInt / 60, time.timeInt % 60];
        
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
    return _headerView.frame.size.height;
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
        
        int direction, time;
        [_station timeToStation:self.destinationStation time:&time direction:&direction];
        
        NSMutableArray *newTimes = [NSMutableArray arrayWithCapacity:_times.count / 2];
        for (EPDTime *t in _times) {
            int timeDirection;
            [_station timeToStation:t.directionStation time:&time direction:&timeDirection];
            if (timeDirection == direction && t.directionStation != _station)
                [newTimes addObject:t];
        }
        _times = newTimes;
        
        _headerView = [[EPDTimePanelView alloc] initWithPanelsCount:1];
        [self updateTimeTable];
        [self.tableView reloadData];
        
    }
}

@end
