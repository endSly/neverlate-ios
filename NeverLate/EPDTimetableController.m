//
//  EPDTimetableController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/4/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDTimetableController.h"

#import "EPDSlidingViewController.h"
#import "EPDTimesViewController.h"
#import "EPDStation.h"
#import "CustomNavigationBar.h"
#import "EPDBannerController.h"

@interface EPDTimetableController ()

@end

@implementation EPDTimetableController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ((CustomNavigationBar *)self.navigationController.navigationBar).navigationController = self.navigationController;
    
    self.tableView.frame = CGRectMake(0, 264, 320, 148);
    self.navigationController.navigationBarHidden = YES;
    
    self.navigationController.navigationBar.tintColor = ((EPDSlidingViewController *) self.slidingViewController).objectManager.color;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    _originStation = nil;
    _destinationStation = nil;
    _date = [NSDate date];
    
    _stations = [[((EPDSlidingViewController *) self.slidingViewController).objectManager allStations] sortedArrayUsingComparator:^NSComparisonResult(EPDStation *obj1, EPDStation *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EPDTimesViewController *timesController = segue.destinationViewController;
    timesController.originStation = _originStation;
    timesController.destinationStation = _destinationStation;
    timesController.date = _date;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_originStation)
        return _stations.count;
    return _stations.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_originStation)
        return @"Seleccione Destino";
    return @"Seleccione Origen";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    static UIFont *font = nil;
    if (!font)
        font = [UIFont fontWithName:@"AtRotisSemiSans" size:18.0f];
    
    cell.textLabel.font = font;
    cell.textLabel.text = ((EPDStation *) [_stations objectAtIndex:indexPath.row]).name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_originStation) {
        _originStation = (EPDStation *) [_stations objectAtIndex:indexPath.row];
    
        NSMutableArray *newStations = [_stations mutableCopy];
        [newStations removeObject:_originStation];
        _stations = newStations;
    
        [self.tableView scrollToTop];
        [self.tableView reloadData];
    
    } else {
        
        _destinationStation = (EPDStation *) [_stations objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"TimesSegue" sender:self];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [EPDBannerController sharedBanner].bannerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}

#pragma mark - Month View data source

- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate
{
    return [NSArray array];
}

#pragma mark - Month View delegate

- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date 
{
    _date = date;
    
    [self.tableView reloadData];
}


@end
