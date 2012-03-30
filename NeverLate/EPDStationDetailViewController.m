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

static const int daytypes[] = {-1, 3, 0, 0, 0, 0, 1, 2}; // Sunday is 1


@interface EPDStationDetailViewController ()

- (void)reloadTimeTable;

@end

@implementation EPDStationDetailViewController

@synthesize station = _station;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = _station.name;
    _headerView = [[EPDTimePanelView alloc] init];
    
    [EPDConnection findAll:^(NSArray *connections) {
        _connections = connections;
        
        [self reloadTimeTable];
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

- (void)reloadTimeTable
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSWeekdayCalendarUnit) fromDate:[NSDate date]];
    
    NSNumber *daytype = [NSNumber numberWithInt:daytypes[comps.weekday]];
    
    [EPDTime findWhere:@"station_id = ? AND daytype = ?" 
                params:[NSArray arrayWithObjects:_station.id, daytype, nil] 
                 block:^(NSArray *times) {
                     [self updateTimeTable:times];
                 }];
}

- (int)getDirectionToStation:(EPDStation *)to from:(EPDStation *)from
{
    // Returns
    if ([from.id isEqual:to.id])
        return 0;
    
    for (EPDConnection *connection in _connections) {
        if ([connection.station_1_id isEqual:to.id] 
            || [connection.station_2_id isEqual:to.id]) {
            return -1;
        }
        
        if ([connection.station_1_id isEqual:from.id] 
            || [connection.station_2_id isEqual:from.id]) {
            return 1;
        }
    }
    return 2; // Should not return 2
}

- (void)updateTimeTable:(NSArray *)times
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
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
        EPDTime *soonTimes[4] = {nil, nil, nil, nil};
        int dir1 = 0, dir2 = 0, dir0 = 0;
        
        for (EPDTime *time in _times) {
            int direction = [self getDirectionToStation:time.directionStation from:_station];
            if (direction == 0)
                dir0++;
            
            if (direction < 0 && dir1 < 2) {
                soonTimes[dir1] = time;
                dir1++;
            }
            
            if (direction > 0 && dir2 < 2) {
                soonTimes[2 + dir2] = time;
                dir2++;
            }
            
            if (dir0 + dir1 + dir2 > 4)
                break;
        }
        
        _headerView.stationLabel.text = _station.name;
        
        EPDTime *time = soonTimes[0];
        if (time) {
            _headerView.dest1Label1.text = time.directionStation.name;
            NSLog(@"%i, %i - %i", time.time.intValue - current + 1, time.time.intValue, current);
            int waitTime = time.time.intValue - current + 1;
            if (waitTime < 0 || waitTime > 120)
                _headerView.time1Label1.text = [NSString stringWithFormat:@"+120"];
            else
                _headerView.time1Label1.text = [NSString stringWithFormat:@"%i", waitTime];
        }
        time = soonTimes[1];
        if (time) {
            _headerView.dest1Label2.text = time.directionStation.name;
            int waitTime = time.time.intValue - current + 1;
            if (waitTime < 0 || waitTime > 120)
                _headerView.time1Label2.text = [NSString stringWithFormat:@"+120"];
            else
                _headerView.time1Label2.text = [NSString stringWithFormat:@"%i", waitTime];
        }
        time = soonTimes[2];
        if (time) {
            _headerView.dest2Label1.text = time.directionStation.name;
            int waitTime = time.time.intValue - current + 1;
            if (waitTime < 0 || waitTime > 120)
                _headerView.time2Label1.text = [NSString stringWithFormat:@"+120"];
            else
                _headerView.time2Label1.text = [NSString stringWithFormat:@"%i", waitTime];
        }
        time = soonTimes[3];
        if (time) {
            _headerView.dest2Label2.text = time.directionStation.name;
            int waitTime = time.time.intValue - current + 1;
            if (waitTime < 0 || waitTime > 120)
                _headerView.time2Label2.text = [NSString stringWithFormat:@"+120"];
            else
                _headerView.time2Label2.text = [NSString stringWithFormat:@"%i", waitTime];
        }

    });
    
       
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _times.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    

    EPDTime *time = [_times objectAtIndex:indexPath.row];
    int minutes = time.time.intValue;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %i:%02i", time.directionStation.name, minutes / 60, minutes % 60];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 192.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
