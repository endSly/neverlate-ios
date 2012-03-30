//
//  EPDMetroViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDMetroViewController.h"

#import <math.h>
#import "EPDTime.h"
#import "EPDStation.h"
#import "EPDStationLocation.h"

@interface EPDMetroViewController ()

@end

@implementation EPDMetroViewController

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

    _locationManager = [[CLLocationManager alloc] init];
    
    [EPDStation findAll:^(NSArray *stations) {
        _stations = stations;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self orderStationsByProximity];
        });
    }];
}

- (void)setStations:(NSArray *)stations
{
    _stations = stations;
    
    [self.tableView reloadData];
}

#define DEG_TO_RAD(deg) ((deg) * 3.14159265f / 180.0f)

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

- (void)orderStationsByProximity
{
    self.stations = [_stations sortedArrayUsingComparator:^NSComparisonResult(EPDStation *station1, EPDStation *station2) {
        
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
        
        return distance1 < distance2;
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
    [segue.destinationViewController performSelector:@selector(setStation:) withObject:_selectedStation];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
        cell.textLabel.font = [UIFont fontWithName:@"MyriadPro-Bold" size:20.0f];
    }
    EPDStation *station = [_stations objectAtIndex:indexPath.row];
    
    cell.textLabel.text = station.name;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedStation = [_stations objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"StationDetailSegue" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
